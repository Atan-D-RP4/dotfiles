local config = require("niri.config")
local log = require("niri.utils.log")
local EventDispatcher = require("niri.events.dispatcher")
local ipc = require("niri.events.ipc")
local Promise = require("niri.promise")

---@class NiriState
---@field outputs table<string, OutputData> Cached outputs keyed by name
---@field windows table<number, WindowData> Cached windows keyed by id
---@field workspaces table<number, WorkspaceData> Cached workspaces keyed by id
---@field layers table[] Cached layer surfaces
---@field keyboard_layouts KeyboardLayoutsData|nil Cached keyboard layouts
---@field overview_open boolean Whether overview is open
---@field focused_window_id number|nil ID of focused window
---@field focused_output_name string|nil Name of focused output
---@field _initialized boolean Whether initial cache population is done

---@class NiriModule
---@field config table
---@field state NiriState Cached IPC state for synchronous access
---@field setup fun(opts?: table): NiriModule
---@field start fun(): nil
---@field autocmd fun(events: string|string[], callback: function): nil
---@field request fun(command: RequestType, callback: fun(ok: boolean, response: any)): nil
---@field command fun(command: RequestType|Action, timeout?: number): boolean, any
---@field async_command fun(command: RequestType|Action, sockpath?: string): Promise
---@field get_window fun(id: number): WindowData|nil
---@field get_workspace fun(id: number): WorkspaceData|nil
---@field get_output fun(name: string): OutputData|nil
---@field get_focused_window fun(): WindowData|nil
---@field get_focused_output fun(): OutputData|nil
---@field is_fullscreen fun(window_id?: number): boolean
---@field pick_window fun(callback: fun(ok: boolean, window: WindowData|nil)): nil
---@field pick_color fun(callback: fun(ok: boolean, color: table|nil)): nil
---@field output_config fun(output: string, action: table, callback: fun(ok: boolean, response: any)): nil

local M = {}

M.state = {
	outputs = {},
	windows = {},
	workspaces = {},
	layers = {},
	keyboard_layouts = nil,
	overview_open = false,
	focused_window_id = nil,
	focused_output_name = nil,
	_initialized = false,
}

local function cache_outputs(outputs_dict)
	M.state.outputs = {}
	for name, output in pairs(outputs_dict) do
		M.state.outputs[name] = output
	end
end

local function cache_windows(windows_list)
	M.state.windows = {}
	for _, window in ipairs(windows_list) do
		M.state.windows[window.id] = window
		if window.is_focused then
			M.state.focused_window_id = window.id
		end
	end
end

local function cache_workspaces(workspaces_list)
	M.state.workspaces = {}
	for _, ws in ipairs(workspaces_list) do
		M.state.workspaces[ws.id] = ws
	end
end

local function update_window(window)
	if window and window.id then
		M.state.windows[window.id] = window
	end
end

local function remove_window(window_id)
	M.state.windows[window_id] = nil
	if M.state.focused_window_id == window_id then
		M.state.focused_window_id = nil
	end
end

local function refresh_cache(request_type, cache_fn, on_done, extract_key)
	ipc.command(request_type, function(ok, resp)
		if ok and resp then
			local data = extract_key and resp[extract_key] or resp
			if data then
				cache_fn(data)
			end
		end
		if on_done then
			on_done()
		end
	end, M.config.sockpath)
end

---@param id number
---@return WindowData|nil
function M.get_window(id)
	return M.state.windows[id]
end

---@param id number
---@return WorkspaceData|nil
function M.get_workspace(id)
	return M.state.workspaces[id]
end

---@param name string
---@return OutputData|nil
function M.get_output(name)
	return M.state.outputs[name]
end

---@return WindowData|nil
function M.get_focused_window()
	if M.state.focused_window_id then
		return M.state.windows[M.state.focused_window_id]
	end
	return nil
end

---@return OutputData|nil
function M.get_focused_output()
	if M.state.focused_output_name then
		return M.state.outputs[M.state.focused_output_name]
	end
	return nil
end

---@param window_id number|nil
---@return boolean
function M.is_fullscreen(window_id)
	local win
	if window_id then
		win = M.state.windows[window_id]
	else
		win = M.get_focused_window()
	end

	if not win or not win.layout or not win.layout.tile_size then
		return false
	end

	local output
	if win.workspace_id then
		local ws = M.state.workspaces[win.workspace_id]
		if ws and ws.output then
			output = M.state.outputs[ws.output]
		end
	end
	if not output then
		output = M.get_focused_output()
	end
	if not output then
		return false
	end

	local tile_w = win.layout.tile_size.width or win.layout.tile_size[1]
	local tile_h = win.layout.tile_size.height or win.layout.tile_size[2]
	local out_w = output.logical and output.logical.width or output.logical_width
	local out_h = output.logical and output.logical.height or output.logical_height

	return tile_w == out_w and tile_h == out_h
end

---@param callback fun(ok: boolean, window: WindowData|nil)
function M.pick_window(callback)
	ipc.command("PickWindow", function(ok, resp)
		callback(ok, resp)
	end, M.config.sockpath)
end

---@param callback fun(ok: boolean, color: table|nil)
function M.pick_color(callback)
	ipc.command("PickColor", function(ok, resp)
		callback(ok, resp)
	end, M.config.sockpath)
end

---@param output_name string
---@param action table
---@param callback fun(ok: boolean, response: any)
function M.output_config(output_name, action, callback)
	local cmd = { Output = { output = output_name, action = action } }
	ipc.command(cmd, function(ok, resp)
		callback(ok, resp)
	end, M.config.sockpath)
end

---@param opts table?
---@return NiriModule
function M.setup(opts)
	M.config = config.setup(opts)
	M.config.dispatcher = EventDispatcher:new()

	return M
end

---@return nil
function M.start()
	if M.config.version_check then
		ipc.command("Version", function(ok, resp)
			if ok then
				log.info("Connected to Niri IPC, version:", resp["Version"])
				M.config.version = resp["Version"]
			else
				log.error("Socket path:", M.config.sockpath)
				log.error("Failed to get Niri version:", resp)
			end
		end, M.config.sockpath)
	end

	local pending = 6
	local function on_init_done()
		pending = pending - 1
		if pending == 0 then
			M.state._initialized = true
			log.debug("State cache initialized")
		end
	end

	refresh_cache("Outputs", cache_outputs, on_init_done, "Outputs")
	refresh_cache("Windows", cache_windows, on_init_done, "Windows")
	refresh_cache("Workspaces", cache_workspaces, on_init_done, "Workspaces")
	refresh_cache("Layers", function(layers)
		M.state.layers = layers
	end, on_init_done, "Layers")
	refresh_cache("KeyboardLayouts", function(kl)
		M.state.keyboard_layouts = kl
	end, on_init_done, "KeyboardLayouts")
	ipc.command("FocusedOutput", function(ok, resp)
		if ok and resp and resp.FocusedOutput then
			M.state.focused_output_name = resp.FocusedOutput.name
		end
		on_init_done()
	end, M.config.sockpath)

	M.config.dispatcher:on({ "WindowsChanged" }, function(wrapped)
		if wrapped.data and wrapped.data.windows then
			cache_windows(wrapped.data.windows)
		end
	end)

	M.config.dispatcher:on({ "WindowOpenedOrChanged" }, function(wrapped)
		if wrapped.data and wrapped.data.window then
			update_window(wrapped.data.window)
		end
	end)

	M.config.dispatcher:on({ "WindowClosed" }, function(wrapped)
		if wrapped.data and wrapped.data.id then
			remove_window(wrapped.data.id)
		end
	end)

	M.config.dispatcher:on({ "WindowFocusChanged" }, function(wrapped)
		M.state.focused_window_id = wrapped.data and wrapped.data.id or nil
	end)

	M.config.dispatcher:on({ "WindowLayoutsChanged" }, function(wrapped)
		if wrapped.data and wrapped.data.changes then
			for _, change in ipairs(wrapped.data.changes) do
				local win_id, layout = change[1], change[2]
				if M.state.windows[win_id] then
					local old_layout = M.state.windows[win_id].layout
					if old_layout then
						for k, v in pairs(layout) do
							old_layout[k] = v
						end
					else
						M.state.windows[win_id].layout = layout
					end
				end
			end
		end
	end)

	M.config.dispatcher:on({ "WorkspacesChanged" }, function(wrapped)
		if wrapped.data and wrapped.data.workspaces then
			cache_workspaces(wrapped.data.workspaces)
		end
	end)

	M.config.dispatcher:on({ "WorkspaceActivated" }, function(wrapped)
		if wrapped.data then
			local ws = M.state.workspaces[wrapped.data.id]
			if ws then
				for _, w in pairs(M.state.workspaces) do
					if w.output == ws.output then
						w.is_active = (w.id == wrapped.data.id)
					end
				end
			end
		end
	end)

	M.config.dispatcher:on({ "KeyboardLayoutsChanged" }, function(wrapped)
		if wrapped.data and wrapped.data.keyboard_layouts then
			M.state.keyboard_layouts = wrapped.data.keyboard_layouts
		end
	end)

	M.config.dispatcher:on({ "KeyboardLayoutSwitched" }, function(wrapped)
		if wrapped.data and M.state.keyboard_layouts then
			M.state.keyboard_layouts.current_layout = wrapped.data.idx
		end
	end)

	M.config.dispatcher:on({ "OverviewOpenedOrClosed" }, function(wrapped)
		if wrapped.data then
			M.state.overview_open = wrapped.data.is_open
		end
	end)

	ipc.stream_events(M.config.sockpath, M.config.dispatcher)

	local uv = require("luv")
	local ok, err = pcall(uv.run)
	if not ok then
		if err ~= "interrupted!" then
			log.error("Event loop error:", err)
		end
	end
end

---@param events EventVariant[]
---@param callback function
---@return nil
function M.autocmd(events, callback)
	M.config.dispatcher:on(events, callback)
end

--- Execute a command with callback-based async result
--- This is ONLY way to run commands from within event callbacks
---@param command RequestType|Action
---@param callback fun(ok: boolean, response: any)
---@param timeout number?
function M.run_command(command, callback, timeout)
	timeout = timeout or 5000

	local uv = require("luv")
	local timer = uv.new_timer()

	timer:start(timeout, 0, function()
		timer:close()
		callback(false, "Command timeout after " .. (timeout / 1000) .. " seconds")
	end)

	ipc.command(command, function(ok, resp)
		timer:close()
		callback(ok, resp)
	end, M.config.sockpath)
end

--- Execute a command synchronously
--- WARNING: This only works when NOT called from within an event callback!
--- From event callbacks, use M.run_command() instead with a callback
---@param command RequestType|Action
---@param timeout number?
---@return boolean, ResponseData|ActionResult
function M.request(command, timeout)
	timeout = timeout or 5000

	local result = nil
	local finished = false
	local uv = require("luv")

	local timer = uv.new_timer()
	timer:start(timeout, 0, function()
		if not finished then
			finished = true
			timer:close()
			result = { success = false, error = "Command timeout after " .. (timeout / 1000) .. " seconds" }
		end
	end)

	ipc.command(command, function(ok, resp)
		if not finished then
			finished = true
			timer:close()
			if ok then
				result = { success = true, data = resp }
			else
				result = { success = false, error = resp }
			end
		end
	end, M.config.sockpath)

	while not finished do
		uv.run("nowait")
	end

	if not result then
		result = { success = false, error = "No result received" }
	end

	return result.success, result.data or result.error
end

---@param command RequestType|Action
---@param sockpath string?
---@return Promise
function M.async_request(command, sockpath)
	sockpath = sockpath or M.config.sockpath

	return Promise.new(function(resolve, reject)
		ipc.command(command, function(ok, resp)
			if ok then
				resolve(resp)
			else
				reject(resp)
			end
		end, sockpath)
	end)
end

return M

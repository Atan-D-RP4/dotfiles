#!/usr/bin/env luajit

package.path = package.path .. ";/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua"
package.path = package.path .. ";/usr/share/lua/5.2/?.lua;/usr/share/lua/5.2/?/init.lua"

-- Simple logging system with levels
local log = {
	level = os.getenv("NIRI_EVENTS_LOG_LEVEL") or "info",
	levels = {
		error = 0,
		warn = 1,
		info = 2,
		debug = 3,
	},
}

function log:should_log(level)
	return self.levels[level] <= self.levels[self.level]
end

function log:serialize(tbl, indent)
	indent = indent or 0
	local toprint = "{\n"
	indent = indent + 2
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if type(k) == "number" then
			toprint = toprint .. "[" .. k .. "] = "
		else
			toprint = toprint .. k .. " = "
		end
		if type(v) == "table" then
			toprint = toprint .. self:serialize(v, indent + 2) .. ",\n"
		elseif type(v) == "string" then
			toprint = toprint .. string.format("%q", v) .. ",\n"
		else
			toprint = toprint .. tostring(v) .. ",\n"
		end
	end
	indent = indent - 2
	toprint = toprint .. string.rep(" ", indent) .. "}"
	return toprint
end

function log:format_message(...)
	local args = { ... }
	local messages = {}
	for i, v in ipairs(args) do
		if type(v) == "table" then
			table.insert(messages, self:serialize(v))
		else
			table.insert(messages, tostring(v))
		end
	end
	return table.concat(messages, " ")
end

function log:error(...)
	if self:should_log("error") then
		io.stderr:write("[ERROR] " .. self:format_message(...) .. "\n")
	end
end

function log:warn(...)
	if self:should_log("warn") then
		io.stderr:write("[WARN] " .. self:format_message(...) .. "\n")
	end
end

function log:info(...)
	if self:should_log("info") then
		io.stdout:write("[INFO] " .. self:format_message(...) .. "\n")
	end
end

function log:debug(...)
	if self:should_log("debug") then
		io.stdout:write("[DEBUG] " .. self:format_message(...) .. "\n")
	end
end

-- Load dkjson module
local dkjson = require("dkjson")

-- Load luv
package.cpath = package.cpath .. ";/usr/lib/lib?.so"
local uv = require("luv")

-- Get IPC socket path for Niri
local sockpath = os.getenv("NIRI_SOCKET")
if not sockpath then
	error("NIRI_SOCKET not set")
end

-- Event dispatcher (with wildcard/list matching)
local Event = {}
Event.__index = Event

function Event:new()
	return setmetatable({ listeners = {} }, self)
end

function Event:on(event_name, callback)
	if type(event_name) == "table" then
		for _, ev in ipairs(event_name) do
			self:on(ev, callback)
		end
	else
		self.listeners[event_name] = self.listeners[event_name] or {}
		table.insert(self.listeners[event_name], callback)
	end
end

function Event:off(event_name, callback)
	if type(event_name) == "table" then
		for _, ev in ipairs(event_name) do
			self:off(ev, callback)
		end
	else
		local list = self.listeners[event_name]
		if not list then
			return
		end
		for i = #list, 1, -1 do
			if list[i] == callback then
				table.remove(list, i)
			end
		end
	end
end

function Event:emit(event_name, ...)
	-- specific
	local list = self.listeners[event_name]
	if list then
		for _, cb in ipairs(list) do
			local ok, err = pcall(cb, ...)
			if not ok then
				io.stderr:write(("Error in callback for event '%s': %s\n"):format(event_name, err))
			end
		end
	end
	-- wildcard
	local wc = self.listeners["*"]
	if wc then
		for _, cb in ipairs(wc) do
			local ok, err = pcall(cb, event_name, ...)
			if not ok then
				io.stderr:write(("Error in wildcard callback for '%s': %s\n"):format(event_name, err))
			end
		end
	end
end

local dispatcher = Event:new()

local function niri_autocmd(event_names, callback)
	dispatcher:on(event_names, callback)
end

-- Send Niri command via IPC socket
local function niri_command(cmd, callback)
	-- Create pipe for socket
	local pipe = uv.new_pipe(false)

	-- Connect to Niri socket
	uv.pipe_connect(pipe, sockpath, function(err)
		if err then
			return callback(false, "connect error: " .. tostring(err))
		end

		-- Format command: Niri expects JSON on a single line
		-- For simple string requests like "Version", just encode the string
		-- For complex objects like actions, encode the whole object
		local cmd_str = dkjson.encode(cmd) .. "\n"

		-- Write the JSON command
		pipe:write(cmd_str, function(write_err)
			if write_err then
				pipe:close()
				return callback(false, "write error: " .. tostring(write_err))
			end

			-- Read response (newline-terminated JSON)
			local response = ""
			uv.read_start(pipe, function(read_err, chunk)
				if read_err then
					pipe:close()
					return callback(false, "read error: " .. tostring(read_err))
				end

				if chunk then
					response = response .. chunk
					-- Process once we have complete response (ends with newline)
					if response:sub(-1) == "\n" then
						pipe:read_stop()
						pipe:close()

						-- Parse JSON response
						local parsed, pos, parse_err = dkjson.decode(response, 1, nil)
						if parse_err then
							callback(false, "JSON parse error at pos " .. tostring(pos) .. ": " .. tostring(parse_err))
						elseif parsed and parsed.Ok then
							callback(true, parsed.Ok)
						elseif parsed and parsed.Err then
							callback(false, parsed.Err)
						else
							callback(false, "Unknown response format: " .. response)
						end
					end
				else
					-- EOF
					pipe:read_stop()
					pipe:close()
					if response ~= "" then
						local parsed, pos, parse_err = dkjson.decode(response, 1, nil)
						if parse_err then
							callback(false, "JSON parse error at pos " .. tostring(pos) .. ": " .. tostring(parse_err))
						elseif parsed and parsed.Ok then
							callback(true, parsed.Ok)
						elseif parsed and parsed.Err then
							callback(false, parsed.Err)
						else
							callback(false, "Unknown response format: " .. response)
						end
					else
						callback(false, "Connection closed without response")
					end
				end
			end)
		end)
	end)
end

-- Get version info
niri_command("Version", function(ok, resp)
	if not ok then
		log:error("Failed to get Niri version:", resp)
	else
		log:info("Connected to Niri IPC, version:", resp["Version"])
	end
end)

-- Connect to Niri socket for event streaming
local event_pipe = uv.new_pipe(false)
local read_buffer = ""

uv.pipe_connect(event_pipe, sockpath, function(err)
	if err then
		error("Failed to connect to event socket: " .. tostring(err))
	end

	-- Send event stream request (plain string "EventStream" encoded as JSON)
	local event_request = dkjson.encode("EventStream") .. "\n"
	uv.write(event_pipe, event_request)

	uv.read_start(event_pipe, function(err2, chunk)
		if err2 then
			error("Read error on event socket: " .. tostring(err2))
		end

		if not chunk then
			event_pipe:read_stop()
			event_pipe:close()
			return
		end

		read_buffer = read_buffer .. chunk
		while true do
			local s, e = read_buffer:find("\n", 1, true)
			if not s or not e then
				break
			end
			local line = read_buffer:sub(1, s - 1)
			read_buffer = read_buffer:sub(e + 1)

			-- Parse Niri JSON events
			if line ~= "" and line ~= "null" then
				local event_data, pos, parse_err = dkjson.decode(line, 1, nil)
				if not parse_err then
					-- Skip Ok/Err responses (these are IPC confirmations, not events)
					if event_data.Ok or event_data.Err then
						-- Ignore IPC response
					elseif event_data then
						for event_type, data in pairs(event_data) do
							dispatcher:emit(event_type, data)
						end
					end
				else
					io.stderr:write("JSON parse error in event: ", parse_err, "\nLine was: ", line, "\n")
				end
			end
		end
	end)
end)

-- Autocmds - using Niri event names
niri_autocmd({ "MonitorAdded", "MonitorRemoved" }, function(data)
	log:debug("Monitor event:", data)
end)

-- Uncomment to see all events
-- niri_autocmd("*", function(ev, data)
-- 	log:debug("Event", ev, "fired with data:", data)
-- end)

niri_autocmd("WindowOpenedOrChanged", function(data)
	if data and data.window then
		-- Match data.title against a pattern
		local title = data.window.title or ""
		local app_id = data.window.app_id or ""

		-- Check if it's a browser extension window
		if
			(title:match("Extension.*") or title:match("extension.*"))
			and (app_id:match("zen") or app_id:match("firefox"))
		then
			-- Make the window floating via IPC
			-- Proper format: {"Action":{"WindowFloatingToggle":{"window":{"id":123}}}}
			local cmd_obj = {
				Action = {
					MoveWindowToFloating = {
						id = data.window.id,
					},
				},
			}

			niri_command(cmd_obj, function(ok, resp)
				if not ok then
					log:error("Error toggling window floating:", resp)
				else
					log:debug("Successfully toggled floating for window", data.window.id)
				end
			end)
		end
	end
end)

niri_autocmd("ConfigReloaded", function()
	log:info("Config reloaded")
end)

-- Run the libuv loop
uv.run()

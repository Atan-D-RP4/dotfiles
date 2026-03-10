-- Events: https://yalter.github.io/niri/niri_ipc/enum.Event.html
-- Actions: https://yalter.github.io/niri/niri_ipc/enum.Action.html
-- Request: https://yalter.github.io/niri/niri_ipc/enum.Request.html

-- Get current script directory
local function get_script_dir()
	local path = arg and arg[0]
	if not path then
		return nil
	end

	path = io.popen("readlink -f " .. path, "r"):read("*l")
	return path:match("(.*/)")
end

local script_dir = get_script_dir()

package.cpath = package.cpath .. ";/usr/lib/lib?.so"
package.path = package.path .. ";/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua"
package.path = package.path .. ";/usr/share/lua/5.2/?.lua;/usr/share/lua/5.2/?/init.lua"
package.path = package.path .. ";" .. script_dir .. "?.lua;" .. script_dir .. "?/init.lua"
package.path = package.path .. ";" .. script_dir .. "/lua/?.lua;" .. script_dir .. "/lua/?/init.lua"

local niri = require("niri")
local log = require("niri.utils.log")
local uv = require("luv")
require("niri.types")

--- Niri Setup
uv.sleep(1000) -- Wait for niri to start
niri.setup({
	sockpath = os.getenv("NIRI_SOCKET"),
	debug_events = os.getenv("NIRI_DEBUG_EVENTS") or false,
})

---
--- Helper Functions
---

---@param text string
---@param pattern_list string[]
local function matches_pattern(text, pattern_list)
	for _, pattern in ipairs(pattern_list) do
		if text:match(pattern) then
			return true
		end
	end
	return false
end

---
--- Autocommands
---

niri.autocmd("ConfigLoaded", function(data)
	if data and data.failed then
		log.error("Failed to load config:", data.failed)
	else
		log.info("Config reloaded successfully")
	end
end)

niri.autocmd("WindowOpenedOrChanged", function(ctx)
	if true then
		return
	end
	log.debug("WindowOpenedOrChanged event data:", ctx.data)
	if not (ctx and ctx.data and ctx.data.window) then
		return
	end
	local title = ctx.data.window.title or ""
	local app_id = ctx.data.window.app_id or ""

	local extension_ok = matches_pattern(title, {
		"^[Ee]xtension:",
		"[Ee]xtension %(",
		" - .*[Ee]xtension",
	})

	local browser_app = matches_pattern(app_id, { "zen", "firefox" })

	local reject_if_not_extension = matches_pattern(title, {
		": .* — Zen Browser$",
		"^Zen Browser$",
		"^Firefox$",
		"^Mozilla Firefox$",
	}) and not extension_ok

	local match_accepted = browser_app
		and (extension_ok or matches_pattern(title, {
			"[Ss]ign [Ii]n",
			"[Ll]og [Ii]n",
			"[Ss]ign [Uu]p",
		}))
		and not reject_if_not_extension

	if not match_accepted then
		return
	end

	if ctx.data.window.is_floating then
		log.info("Window is already floating, no action needed:", ctx.data.window.title)
		return
	end

	local window_id = ctx.data.window.id

	log.info("Detected browser pop-up window:", ctx.data.window.title)
	local actions = {
		{ "MoveWindowToFloating", { id = window_id } },
		{ "MoveFloatingWindow", { id = window_id, x = { SetFixed = 100 }, y = { SetFixed = 100 } } },
		{ "SetWindowWidth", { id = window_id, change = { SetFixed = 635 } } },
		{ "SetWindowHeight", { id = window_id, change = { SetFixed = 640 } } },
		{ "ToggleWindowUrgent", { id = window_id } },
	}

	for _, action in ipairs(actions) do
		niri.execute_action(
			{ [action[1]] = action[2] },
			"Successfully executed action" .. log.format_message(action),
			"Failed to execute action" .. log.format_message(action)
		)
	end
end)

niri.autocmd("ScreenshotCaptured", function(ctx)
	-- Open the screenshot using the default image viewer
	log.info(ctx)
	uv.spawn("satty", {
		args = {
			"--filename",
			ctx.data.path,
		},
	}, function(code, signal)
		if code ~= 0 then
			log.error("Failed to open screenshot:", ctx.data.path)
			log.error("Exit code:", code, "Signal:", signal)
		end
	end)
end)

-- niri.autocmd("WindowLayoutsChanged", function(wrapped)
-- 	log.info(wrapped.event)
-- 	local changes = wrapped.data.changes
-- 	for _, change in ipairs(changes) do
-- 		local window_id = change[1]
-- 		log.info(change)
-- 		if niri.is_fullscreen(window_id) then
-- 			log.info("Window went fullscreen:", window_id)
-- 		else
-- 			log.info("Window exited fullscreen:", window_id)
-- 		end
-- 	end
-- end)

niri.autocmd({ "WindowOpenedOrChanged", "WindowClosed" }, function(_ctx)
	if true then
		return
	end
	local timer = uv.new_timer()
	timer:start(100, 0, function()
		local active_workspace
		for _, workspace in pairs(niri.state.workspaces) do
			if workspace.is_active then
				log.info("Active workspace:", workspace)
				active_workspace = workspace
			end
		end

		local tiled_windows_in_workspace = {}
		for _, window in pairs(niri.state.windows) do
			if window.workspace_id == active_workspace.id and not window.is_floating then
				table.insert(tiled_windows_in_workspace, window)
			end
		end

		local actions = {
			{ "MaximizeWindowToEdges", { id = tiled_windows_in_workspace[1].id } },
		}
		for _, action in ipairs(actions) do
			niri.execute_action(
				{ [action[1]] = action[2] },
				"Successfully maximised column" .. log.format_message(action),
				"Failed to maximise column" .. log.format_message(action)
			)
		end
		timer:stop()
		timer:close()
	end)
end)

--- Niri IPC Event Stream Start
log.info(niri.request("Version", 500))
niri.start()

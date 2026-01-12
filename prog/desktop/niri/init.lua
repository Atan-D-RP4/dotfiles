-- Events: https://yalter.github.io/niri/niri_ipc/enum.Event.html
-- Actions: https://yalter.github.io/niri/niri_ipc/enum.Action.html
-- Request: https://yalter.github.io/niri/niri_ipc/enum.Request.html

-- Get current script directory
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)")

package.path = package.path .. ";/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua"
package.path = package.path .. ";/usr/share/lua/5.2/?.lua;/usr/share/lua/5.2/?/init.lua"
package.path = package.path .. ";" .. script_dir .. "?.lua;" .. script_dir .. "?/init.lua"
package.path = package.path .. ";" .. script_dir .. "/lua/?.lua;" .. script_dir .. "/lua/?/init.lua"
package.cpath = package.cpath .. ";/usr/lib/lib?.so"

local niri = require("niri")
local log = require("niri.utils.log")
local ipc = require("niri.events.ipc")
local uv = require("luv")

niri.setup({
	sockpath = os.getenv("NIRI_SOCKET"),
	debug_events = os.getenv("NIRI_DEBUG_EVENTS") or false,
})

local function is_fullscreen(window_id) end

log.info(niri.request("FocusedWindow"), function(ok, resp)
	log.info("Focused window:", ok, resp)
end)

if niri.config.debug_events then
	niri.autocmd("*", function(event_name, data)
		log.debug("[Event]", event_name, data)
		print("----------------------------------------")
	end)
end

niri.autocmd("ConfigLoaded", function(data)
	if data and data.failed then
		log.error("Failed to load config:", data.failed)
	else
		log.info("Config reloaded successfully")
	end
end)

niri.autocmd({ "MonitorAdded", "MonitorRemoved" }, function(data)
	log.debug("Monitor event:", data)
end)

local patterns = {
	browser = {
		title = { "Extension.*", "extension.*" },
		app_id = { "zen", "firefox" },
	},
}

local function matches_pattern(text, pattern_list)
	for _, pattern in ipairs(pattern_list) do
		if text:match(pattern) then
			return true
		end
	end
	return false
end

local function is_browser_extension(window)
	local title = window.title or ""
	local app_id = window.app_id or ""

	return matches_pattern(title, patterns.browser.title) and matches_pattern(app_id, patterns.browser.app_id)
end

local function create_window_action(action, window_id)
	return {
		Action = {
			[action] = {
				id = window_id,
			},
		},
	}
end

local function execute_command(cmd_obj, success_msg, error_msg)
	ipc.command(cmd_obj, function(ok, resp)
		if ok then
			if success_msg then
				log.debug(success_msg, resp)
			end
		else
			log.error(error_msg or "Command failed:", resp)
		end
	end, niri.config.sockpath)
end

niri.autocmd("WindowOpenedOrChanged", function(data)
	log.debug("----------------------------------------")
	log.debug("Window event:", data)
	if data and data.window and is_browser_extension(data.window) then
		local cmd = {
			Action = {
				MoveWindowToFloating = {
					id = data.window.id,
				},
			},
		}
		execute_command(cmd, "Successfully toggled floating for window", "Error toggling window floating")
	end
end)

niri.autocmd("ScreenshotCaptured", function(data)
	-- Open the screenshot using the default image viewer
	uv.spawn("satty", {
		args = {
			"--filename",
			data.path,
		},
	}, function(code, signal)
		if code ~= 0 then
			log.error("Failed to open screenshot:", data.path)
		end
	end)
end)

niri.autocmd("WindowOpenedOrChanged", function(data) end)

niri.start()

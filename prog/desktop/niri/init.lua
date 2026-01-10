#!/usr/bin/env luajit

package.path = package.path .. ";/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua"
package.path = package.path .. ";/usr/share/lua/5.2/?.lua;/usr/share/lua/5.2/?/init.lua"
package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"
package.cpath = package.cpath .. ";/usr/lib/lib?.so"

local niri = require("niri")
local log = require("niri.utils.log")
local ipc = require("niri.events.ipc")

niri.setup({
	sockpath = os.getenv("NIRI_SOCKET"),
	debug_events = os.getenv("NIRI_DEBUG_EVENTS") or false,
})

if niri.config.debug_events then
	niri.config.dispatcher:on("*", function(event_name, data)
		log.debug("[Event]", event_name, data)
		print("----------------------------------------")
	end)
end

niri.config.dispatcher:on("ConfigReloaded", function()
	log.info("Configuration reloaded.")
end)

niri.config.dispatcher:on({ "MonitorAdded", "MonitorRemoved" }, function(data)
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

niri.config.dispatcher:on("WindowOpenedOrChanged", function(data)
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

niri.start()

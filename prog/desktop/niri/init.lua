-- Events: https://yalter.github.io/niri/niri_ipc/enum.Event.html
-- Actions: https://yalter.github.io/niri/niri_ipc/enum.Action.html
-- Request: https://yalter.github.io/niri/niri_ipc/enum.Request.html

-- Get current script directory
local function get_script_dir()
	local path = arg and arg[0]
	if not path then
		return nil
	end

	path = assert(io.popen("readlink -f " .. path, "r")):read("*l")
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
local ipc = require("niri.events.ipc")
local uv = require("luv")
require("niri.types")
local types = require("lua.niri.types")

--- Niri Setup
uv.sleep(1000) -- Wait for niri to start
niri.setup({
	sockpath = os.getenv("NIRI_SOCKET"),
	debug_events = os.getenv("NIRI_DEBUG_EVENTS") or false,
})

---
--- Helper Functions
---

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
	local patterns = {
		browser = {
			title = { "Extension.*", "extension.*" },
			app_id = { "zen", "firefox" },
		},
	}

	return matches_pattern(title, patterns.browser.title) and matches_pattern(app_id, patterns.browser.app_id)
end

local function execute_action(cmd_obj, success_msg, error_msg)
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
	log.debug("WindowOpenedOrChanged event data:", ctx.data)
	if ctx and ctx.data and ctx.data.window and is_browser_extension(ctx.data.window) then
		log.info("Detected browser extension window:", ctx.data.window.title)
		execute_action({
			Action = {
				MoveWindowToFloating = {
					id = ctx.data.window.id,
				},
			},
		}, "Successfully toggled floating for window", "Error toggling window floating")
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

niri.autocmd("WindowLayoutsChanged", function(wrapped)
	log.info(wrapped.event)
	local changes = wrapped.data.changes
	for _, change in ipairs(changes) do
		local window_id = change[1]
		log.info(change)
		if niri.is_fullscreen(window_id) then
			log.info("Window went fullscreen:", window_id)
		else
			log.info("Window exited fullscreen:", window_id)
		end
	end
end)

--- Niri IPC Event Stream Start
log.info(niri.request("Version", 500))
niri.start()

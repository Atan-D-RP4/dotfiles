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
	if not (ctx and ctx.data and ctx.data.window) then
		return
	end
	local match_accepted = matches_pattern(
		ctx.data.window.title,
		{ "[Ee]xtension.*", ".*Sign [Ii]n.*", ".*Log [Ii]n.*", ".*Sign [Uu]p.*" }
	) and matches_pattern(ctx.data.window.app_id, { "zen", "firefox" })
	-- Reject main browser windows (they have " | " in title like "Page | Site — Browser")
	local match_rejected = matches_pattern(ctx.data.window.title, {
		".* | .* — Zen Browser$",
		".* | .* — Firefox$",
		".* | .* — Mozilla Firefox$",
		"^Zen Browser$",
		"^Firefox$",
		"^Mozilla Firefox$",
	})

	if not match_accepted or match_rejected then
		return
	end

	if ctx.data.window.is_floating then
		log.info("Window is already floating, no action needed:", ctx.data.window.title)
		return
	end

	local window_id = ctx.data.window.id

	log.info("Detected browser pop-up window:", ctx.data.window.title)
	local actions = {
		{
			MoveWindowToFloating = { id = window_id },
		},
	}

	for _, action in ipairs(actions) do
		log.info("Executing action:", action)
		execute_action({
			Action = action,
		}, "Successfully executed action", "Failed to execute action")
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

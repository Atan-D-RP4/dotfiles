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

niri.setup({
	sockpath = os.getenv("NIRI_SOCKET"),
	debug_events = os.getenv("NIRI_DEBUG_EVENTS") or false,
})

log.info(niri.request("Workspaces", 500))
log.info(niri.request("Windows", 500))

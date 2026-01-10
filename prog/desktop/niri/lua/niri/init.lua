local config = require("niri.config")
local log = require("niri.utils.log")
local EventDispatcher = require("niri.events.dispatcher")
local ipc = require("niri.events.ipc")

local M = {}

function M.setup(opts)
	M.config = config.setup(opts)
	M.config.dispatcher = EventDispatcher:new()

	return M
end

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

	ipc.stream_events(M.config.sockpath, M.config.dispatcher)

	local uv = require("luv")
	local ok, err = pcall(uv.run)
	if not ok then
		if err ~= "interrupted!" then
			log.error("Event loop error:", err)
		end
	end
end

return M


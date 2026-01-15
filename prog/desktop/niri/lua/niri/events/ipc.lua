local dkjson = require("dkjson")
local uv = require("luv")
local config = require("niri.config")
local log = require("niri.utils.log")
local types = require("niri.types")

---@class IpcModule
---@field command fun(cmd: types.RequestType|types.Action, callback: fun(ok: boolean, response: any), sockpath?: string): nil
---@field stream_events fun(sockpath: string, event_dispatcher: any): nil

local M = {}

---@param response string
---@param callback fun(ok: boolean, response: any)
local function handle_response(response, callback)
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

---@param cmd types.RequestType|types.Action
---@param callback fun(ok: boolean, response: any)
---@param sockpath string?
function M.command(cmd, callback, sockpath)
	sockpath = sockpath or config.get("sockpath")
	local pipe = uv.new_pipe(false)

	uv.pipe_connect(pipe, sockpath, function(err)
		if err then
			return callback(false, "connect error: " .. tostring(err))
		end

		local cmd_str = dkjson.encode(cmd) .. "\n"

		pipe:write(cmd_str, function(write_err)
			if write_err then
				pipe:close()
				callback(false, "write error: " .. tostring(write_err))
				return
			end

			local response = ""
			uv.read_start(pipe, function(read_err, chunk)
				if read_err then
					pipe:close()
					callback(false, "read error: " .. tostring(read_err))
					return
				end

				if chunk then
					response = response .. chunk
					if response:sub(-1) == "\n" then
						pipe:read_stop()
						pipe:close()
						handle_response(response, callback)
					end
				else
					pipe:read_stop()
					pipe:close()
					if response ~= "" then
						handle_response(response, callback)
					else
						callback(false, "Connection closed without response")
					end
				end
			end)
		end)
	end)
end

---@param sockpath string
---@param event_dispatcher any
function M.stream_events(sockpath, event_dispatcher)
	sockpath = sockpath or config.get("sockpath")
	local event_pipe = uv.new_pipe(false)
	local read_buffer = ""

	---@param dispatcher any
	local function connect_to_socket(dispatcher)
		uv.pipe_connect(event_pipe, sockpath, function(err)
			if err then
				log.error("Failed to connect to event socket:", err)
				if config.get("auto_reconnect") then
					uv.sleep(config.get("reconnect_delay"))
					return connect_to_socket(dispatcher)
				end
				error("Failed to connect to event socket: " .. tostring(err))
			end

			local event_request = dkjson.encode("EventStream") .. "\n"
			uv.write(event_pipe, event_request)

			uv.read_start(event_pipe, function(err2, chunk)
				local ok, cb_err = pcall(function()
					if err2 then
						log.error("Read error on event socket:", err2)
						event_pipe:read_stop()
						event_pipe:close()
						if config.get("auto_reconnect") then
							uv.sleep(config.get("reconnect_delay"))
							return connect_to_socket(dispatcher)
						end
						return
					end

					if not chunk then
						event_pipe:read_stop()
						event_pipe:close()
						if config.get("auto_reconnect") then
							uv.sleep(config.get("reconnect_delay"))
							return connect_to_socket(dispatcher)
						end
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

						if line ~= "" and line ~= "null" then
							local event_data, pos, parse_err = dkjson.decode(line, 1, nil)
							if not parse_err then
								if not (event_data.Ok or event_data.Err) and event_data then
									for event_type, data in pairs(event_data) do
										dispatcher:emit(event_type, data)
									end
								end
							else
								log.error("JSON parse error in event:", parse_err, "Line:", line)
							end
						end
					end
				end)

				if not ok then
					log.error("Event handler error:", cb_err)
				end
			end)
		end)
	end

	connect_to_socket(event_dispatcher)
end

return M

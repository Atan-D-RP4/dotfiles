-- kanata_client.lua
-- LuaJIT + luv + dkjson
-- Fully typed (LuaLS annotations)

local uv = require("luv")
local json = require("dkjson")

------------------------------------------------------------
-- Event emitter
------------------------------------------------------------

local function new_emitter()
	return { handlers = {} }
end

local function on(self, event, fn)
	self.handlers[event] = self.handlers[event] or {}
	table.insert(self.handlers[event], fn)
end

local function emit(self, event, ...)
	local list = self.handlers[event]
	if not list then
		return
	end
	for _, fn in ipairs(list) do
		fn(...)
	end
end

------------------------------------------------------------
-- Client
------------------------------------------------------------

local KanataClient = {}
KanataClient.__index = KanataClient

function KanataClient.new(opts)
	opts = opts or {}
	local self = setmetatable({}, KanataClient)
	self.host = opts.host or "127.0.0.1"
	self.port = opts.port or 7070
	self.tcp = uv.new_tcp()
	self.buffer = ""
	self.emitter = new_emitter()
	self._closing = false
	return self
end

------------------------------------------------------------
-- Connection
------------------------------------------------------------

function KanataClient:connect(timeout_ms)
	timeout_ms = timeout_ms or 5000

	local timer = uv.new_timer()

	timer:start(timeout_ms, 0, function()
		emit(self.emitter, "error", "connection timeout")
		self:close()
	end)

	self.tcp:connect(self.host, self.port, function(err)
		timer:stop()
		timer:close()

		if err then
			emit(self.emitter, "error", err)
			return
		end

		emit(self.emitter, "connected")
		self:_start_read()
	end)
end

function KanataClient:_start_read()
	self.tcp:read_start(function(err, chunk)
		if err then
			emit(self.emitter, "error", err)
			self:close()
			return
		end

		if not chunk then
			emit(self.emitter, "closed")
			self:close()
			return
		end

		self.buffer = self.buffer .. chunk
		self:_process_buffer()
	end)
end

function KanataClient:_process_buffer()
	while true do
		local newline = self.buffer:find("\n", 1, true)
		if not newline then
			break
		end

		local line = self.buffer:sub(1, newline - 1)
		self.buffer = self.buffer:sub(newline + 1)

		self:_handle_line(line)
	end
end

function KanataClient:_handle_line(line)
	local obj, _, err = json.decode(line)

	if not obj then
		emit(self.emitter, "parse_error", err or line)
		return
	end

	-- ServerResponse (internally tagged)
	if obj.status then
		emit(self.emitter, "response", obj)

		if obj.status == "Ok" then
			emit(self.emitter, "ok")
		elseif obj.status == "Error" then
			emit(self.emitter, "error_response", obj.msg)
		end
		return
	end

	-- Externally tagged enum
	for k, v in pairs(obj) do
		emit(self.emitter, "message", k, v)
		emit(self.emitter, k, v)
	end
end

------------------------------------------------------------
-- Sending
------------------------------------------------------------

function KanataClient:_send(tbl)
	if self._closing then
		return
	end

	local encoded = json.encode(tbl)
	self.tcp:write(encoded .. "\n", function(err)
		if err then
			emit(self.emitter, "error", err)
		end
	end)
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------

function KanataClient:change_layer(name)
	self:_send({ ChangeLayer = { new = name } })
end

function KanataClient:hello()
	self:_send({ Hello = {} })
end

function KanataClient:on(event, fn)
	on(self.emitter, event, fn)
end

function KanataClient:close()
	if self._closing then
		return
	end
	self._closing = true

	pcall(function()
		self.tcp:read_stop()
	end)
	pcall(function()
		self.tcp:close()
	end)
end

------------------------------------------------------------
-- Main (only when executed directly)
------------------------------------------------------------

local function main()
	local client = KanataClient.new()

	client:on("connected", function()
		print("Connected to Kanata")
		client:hello()
	end)

	client:on("HelloOk", function(data)
		print("Version:", data.version)
		print("Protocol:", data.protocol)
		print("Capabilities:", table.concat(data.capabilities, ", "))
	end)

	client:on("error", function(err)
		print("Error:", err)
	end)

	client:on("LayerChange", function(data)
		print("Layer changed to:", data.new)
	end)

	client:on("MessagePush", function(data)
		print("Pushed message:", data.message[1])
	end)

	client:connect()
	uv.run()
end

-- If required, ... contains module name.
-- If executed directly, ... is nil.
if ... == nil then
	main()
end

return KanataClient

local log = require("niri.utils.log")
local types = require("niri.types")

---@class EventDispatcher
---@field listeners table<string, function[]>
---@field new fun(): EventDispatcher
---@field on fun(self: EventDispatcher, events: types.EventVariant[], callback: fun(data: types.EventData)): EventDispatcher
---@field off fun(self: EventDispatcher, events: types.EventVariant[], callback: function): EventDispatcher
---@field emit fun(self: EventDispatcher, event_name: types.EventVariant, data: types.EventData): EventDispatcher

local M = {}

---@return EventDispatcher
function M.new()
	return setmetatable({ listeners = {} }, {
		__index = M
	})
end

---@param events types.EventVariant[]
---@return string[]
local function normalize_events(events)
	if type(events) ~= "table" then
		return { events }
	end
	return events
end

---@param callbacks function[]
---@param data types.EventData
local function execute_callbacks(callbacks, data)
	for _, cb in ipairs(callbacks) do
		local ok, err = pcall(cb, data)
		if not ok then
			log.error("Callback error:", err)
		end
	end
end

---@param events types.EventVariant[]
---@param callback fun(data: types.EventData)
---@return EventDispatcher
function M:on(events, callback)
	events = normalize_events(events)
	for _, event in ipairs(events) do
		self.listeners[event] = self.listeners[event] or {}
		table.insert(self.listeners[event], callback)
	end
	return self
end

---@param events types.EventVariant[]
---@param callback function
---@return EventDispatcher
function M:off(events, callback)
	events = normalize_events(events)
	for _, event in ipairs(events) do
		local list = self.listeners[event]
		if list then
			for i = #list, 1, -1 do
				if list[i] == callback then
					table.remove(list, i)
				end
			end
		end
	end
	return self
end

---@param event_name types.EventVariant
---@param data types.EventData
---@return EventDispatcher
function M:emit(event_name, data)
	local wrapped = { event = event_name, data = data }
	
	local specific_callbacks = self.listeners[event_name]
	if specific_callbacks then
		execute_callbacks(specific_callbacks, wrapped)
	end
	
	local wildcard_callbacks = self.listeners["*"]
	if wildcard_callbacks then
		execute_callbacks(wildcard_callbacks, wrapped)
	end
	
	return self
end

return M
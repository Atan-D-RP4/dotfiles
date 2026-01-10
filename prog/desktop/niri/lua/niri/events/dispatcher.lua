local log = require("niri.utils.log")

local M = {}

function M.new()
	return setmetatable({ listeners = {} }, {
		__index = M
	})
end

local function normalize_events(events)
	if type(events) ~= "table" then
		return { events }
	end
	return events
end

local function execute_callbacks(callbacks, ...)
	for _, cb in ipairs(callbacks) do
		local ok, err = pcall(cb, ...)
		if not ok then
			log.error("Callback error:", err)
		end
	end
end

function M:on(events, callback)
	events = normalize_events(events)
	for _, event in ipairs(events) do
		self.listeners[event] = self.listeners[event] or {}
		table.insert(self.listeners[event], callback)
	end
	return self
end

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

function M:emit(event_name, ...)
	local specific_callbacks = self.listeners[event_name]
	if specific_callbacks then
		execute_callbacks(specific_callbacks, ...)
	end
	
	local wildcard_callbacks = self.listeners["*"]
	if wildcard_callbacks then
		execute_callbacks(wildcard_callbacks, event_name, ...)
	end
end

return M
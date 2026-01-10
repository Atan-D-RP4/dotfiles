local M = {}

local defaults = {
	version_check = true,
	sockpath = os.getenv("NIRI_SOCKET"),
	log_level = os.getenv("NIRI_EVENTS_LOG_LEVEL") or "info",
	debug_events = os.getenv("NIRI_DEBUG_EVENTS") and true or false,
	auto_reconnect = true,
	reconnect_delay = 1000,
}

local current_config = nil

setmetatable(M, {
	__index = function(_, key)
		return defaults[key]
	end
})

function M.setup(opts)
	local cfg = {}
	for k, v in pairs(defaults) do
		cfg[k] = v
	end
	for k, v in pairs(opts or {}) do
		cfg[k] = v
	end
	current_config = cfg
	return cfg
end

function M.get(key)
	return current_config and current_config[key] or defaults[key]
end

return M


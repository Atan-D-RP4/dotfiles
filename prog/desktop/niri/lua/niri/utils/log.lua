local config = require("niri.config")

local M = {
	levels = {
		error = 0,
		warn = 1,
		info = 2,
		debug = 3,
	},
}

function M.should_log(level)
	return M.levels[level] <= M.levels[config.get("log_level")]
end

function M.serialize(tbl, indent)
	indent = indent or 0
	local toprint = "{\n"
	indent = indent + 2
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if type(k) == "number" then
			toprint = toprint .. "[" .. k .. "] = "
		else
			toprint = toprint .. k .. " = "
		end
		if type(v) == "table" then
			toprint = toprint .. M.serialize(v, indent + 2) .. ",\n"
		elseif type(v) == "string" then
			toprint = toprint .. string.format("%q", v) .. ",\n"
		else
			toprint = toprint .. tostring(v) .. ",\n"
		end
	end
	indent = indent - 2
	toprint = toprint .. string.rep(" ", indent) .. "}"
	return toprint
end

function M.format_message(...)
	local args = { ... }
	local messages = {}
	for i, v in ipairs(args) do
		if type(v) == "table" then
			table.insert(messages, M.serialize(v))
		else
			table.insert(messages, tostring(v))
		end
	end
	return table.concat(messages, " ")
end

for level in pairs(M.levels) do
	M[level] = function(...)
		if M.should_log(level) then
			local output = io[level == "error" and "stderr" or "stdout"]
			output:write("[" .. level:upper() .. "] " .. M.format_message(...) .. "\n")
			output:flush()
		end
	end
end

return M
local log = require("niri.utils.log")
local types = require("niri.types")

---@class AsyncModule
---@field async fun(fn: function): function
---@field await fun(fn: function, ...: any): ... any
---@field async_run fun(fn: function, ...: any): function
---@field sync fun(fn: function): ... any
---@field await_sync fun(fn: function, timeout_ms?: integer): ... any

local M = {}

---@param thread thread|nil
---@return boolean
local function is_thread(thread)
	return type(thread) == "thread"
end

---@return thread|nil
local function get_current_thread()
	return coroutine.running()
end

---@param fn function
---@return function
function M.async(fn)
	---@return any
	return function(...)
		local args = { ... }
		local thread = coroutine.create(function()
			fn(table.unpack(args))
		end)
		local result = { coroutine.resume(thread) }
		if not result[1] then
			log.error("Async thread error: " .. tostring(result[2]))
		end
		return table.unpack(result, 2)
	end
end

---@param fn function
---@param ... any
---@return ... any
function M.await(fn, ...)
	local thread = get_current_thread()
	if not is_thread(thread) then
		error("await() must be called within an async() function", 2)
	end

	local callback_args = nil
	local callback_fired = false
	local callback_mutex = false

	---@param ... any
	local function callback(...)
		if callback_mutex then
			return
		end
		callback_mutex = true
		callback_fired = true
		callback_args = { ... }
		coroutine.resume(thread)
	end

	fn(callback, ...)

	if not callback_fired then
		coroutine.yield()
	end

	callback_mutex = false
	return table.unpack(callback_args)
end

---@param fn function
---@param ... any
---@return function
function M.async_run(fn, ...)
	local args = { ... }
	local thread = coroutine.create(function()
		fn(table.unpack(args))
	end)
	---@return nil
	return function()
		if coroutine.status(thread) ~= "dead" then
			coroutine.resume(thread)
		end
	end
end

---@param fn function
---@return ... any
function M.sync(fn)
	local co = coroutine.create(fn)
	local result = { coroutine.resume(co) }
	if not result[1] then
		error(result[2], 2)
	end
	return table.unpack(result, 2)
end

---@param fn function
---@param timeout_ms integer
---@return ... any
function M.await_sync(fn, timeout_ms)
	timeout_ms = timeout_ms or 5000

	local thread = get_current_thread()
	if not is_thread(thread) then
		error("await_sync() must be called within an async() function", 2)
	end

	local result = nil
	local finished = false

	---@param ... any
	fn(function(...)
		if finished then
			return
		end
		finished = true
		result = { ... }
		coroutine.resume(thread)
	end)

	if not finished then
		local uv = require("luv")
		local start_time = uv.now()

		while not finished do
			uv.run("nowait")
			if uv.now() - start_time > timeout_ms then
				error("await_sync timeout after " .. timeout_ms .. "ms", 2)
			end
		end
	end

	return table.unpack(result)
end

return M

---@class Promise
---@field after fun(self: Promise, cb: fun(value: any)): Promise
---@field catch fun(self: Promise, cb: fun(error: any)): Promise
---@field finally fun(self: Promise, cb: fun()): Promise
---@field settle fun(self: Promise, cb: fun(success: boolean, value: any)): Promise
---@field await_sync fun(self: Promise, timeout_ms?: integer): (string, any)
---@field cancel fun(self: Promise): Promise
---@field is_pending fun(self: Promise): boolean
---@field is_fulfilled fun(self: Promise): boolean
---@field is_rejected fun(self: Promise): boolean
---@field is_cancelled fun(self: Promise): boolean
---@field state fun(self: Promise): string
---@field resolve fun(self: Promise, res: any): Promise
---@field reject fun(self: Promise, err: any): Promise

---@class PromiseModule
---@field new fun(resolver?: fun(resolve: fun(value: any), reject: fun(error: any))): Promise
---@field resolve fun(value: any): Promise
---@field reject fun(error: any): Promise
---@field all fun(promises: Promise[]): Promise
---@field race fun(promises: Promise[]): Promise

local M = {}

---@param callbacks function[]
---@param ... any
local function run_callbacks(callbacks, ...)
	for _, cb in ipairs(callbacks) do
		local ok, err = pcall(cb, ...)
		if not ok then
			error("Promise callback error: " .. tostring(err))
		end
	end
end

---@param resolver? fun(resolve: fun(value: any), reject: fun(error: any))
---@return Promise
function M.new(resolver)
	local state = 'pending'
	local value = nil
	local callbacks = {
		fulfilled = {},
		rejected = {},
		finally = {},
	}

	---@param res any
	local function settle_fulfill(res)
		if state ~= 'pending' then
			return
		end
		state = 'fulfilled'
		value = res
		run_callbacks(callbacks.fulfilled, res)
		run_callbacks(callbacks.finally)
		callbacks = { fulfilled = {}, rejected = {}, finally = {} }
	end

	---@param err any
	local function settle_reject(err)
		if state ~= 'pending' then
			return
		end
		state = 'rejected'
		value = err
		run_callbacks(callbacks.rejected, err)
		run_callbacks(callbacks.finally)
		callbacks = { fulfilled = {}, rejected = {}, finally = {} }
	end

	---@type Promise
	local promise = {}

	---@param cb fun(value: any)
	---@return Promise
	function promise:after(cb)
		if type(cb) ~= 'function' then
			return self
		end
		if state == 'fulfilled' then
			cb(value)
		elseif state == 'pending' then
			table.insert(callbacks.fulfilled, cb)
		end
		return self
	end

	---@param cb fun(error: any)
	---@return Promise
	function promise:catch(cb)
		if type(cb) ~= 'function' then
			return self
		end
		if state == 'rejected' then
			cb(value)
		elseif state == 'pending' then
			table.insert(callbacks.rejected, cb)
		end
		return self
	end

	---@param cb fun()
	---@return Promise
	function promise:finally(cb)
		if type(cb) ~= 'function' then
			return self
		end
		if state ~= 'pending' then
			cb()
		else
			table.insert(callbacks.finally, cb)
		end
		return self
	end

	---@return Promise
	function promise:cancel()
		if state == 'pending' then
			state = 'cancelled'
			value = nil
			run_callbacks(callbacks.finally)
			callbacks = { fulfilled = {}, rejected = {}, finally = {} }
		end
		return self
	end

	---@return boolean
	function promise.is_pending()
		return state == 'pending'
	end

	---@return boolean
	function promise.is_fulfilled()
		return state == 'fulfilled'
	end

	---@return boolean
	function promise.is_rejected()
		return state == 'rejected'
	end

	---@return boolean
	function promise.is_cancelled()
		return state == 'cancelled'
	end

	---@return string
	function promise.state()
		return state
	end

	---@param cb fun(success: boolean, value: any)
	---@return Promise
	function promise:settle(cb)
		if type(cb) ~= 'function' then
			error('settle() requires callback', 2)
		end
		if state == 'fulfilled' then
			cb(true, value)
		elseif state == 'rejected' then
			cb(false, value)
		elseif state == 'cancelled' then
			cb(false, 'Promise was cancelled')
		else
			self:after(function(res)
				cb(true, res)
			end):catch(function(err)
				cb(false, err)
			end)
		end
		return self
	end

	---@param timeout_ms? integer
	---@return string, any
	function promise:await_sync(timeout_ms)
		timeout_ms = timeout_ms or math.huge

		if state ~= 'pending' then
			return state, value
		end

		local uv = require("luv")
		local start_time = uv.now()

		while state == 'pending' do
			uv.run("nowait")
			if uv.now() - start_time > timeout_ms then
				return 'timeout', nil
			end
		end

		return state, value
	end

	---@param res any
	---@return Promise
	function promise:resolve(res)
		settle_fulfill(res)
		return self
	end

	---@param err any
	---@return Promise
	function promise:reject(err)
		settle_reject(err)
		return self
	end

	if type(resolver) == 'function' then
		local ok, err = pcall(resolver, function(v)
			settle_fulfill(v)
		end, function(e)
			settle_reject(e)
		end)
		if not ok then
			settle_reject(err)
		end
	end

	return promise
end

---@param value any
---@return Promise
function M.resolve(value)
	return M.new(function(resolve)
		resolve(value)
	end)
end

---@param error any
---@return Promise
function M.reject(error)
	return M.new(function(_, reject)
		reject(error)
	end)
end

---@param promises Promise[]
---@return Promise
function M.all(promises)
	return M.new(function(resolve, reject)
		if #promises == 0 then
			resolve({})
			return
		end

		local results = {}
		local remaining = #promises

		if remaining == 0 then
			resolve({})
			return
		end

		for i, p in ipairs(promises) do
			p:after(function(value)
				results[i] = value
				remaining = remaining - 1
				if remaining == 0 then
					resolve(results)
				end
			end):catch(reject)
		end
	end)
end

---@param promises Promise[]
---@return Promise
function M.race(promises)
	return M.new(function(resolve, reject)
		for _, p in ipairs(promises) do
			p:after(resolve):catch(reject)
		end
	end)
end

return M

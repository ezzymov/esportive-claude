--!strict
-- Tiny signal. Handlers run in their own thread, in connect order.

local Signal = {}
Signal.__index = Signal

export type Connection = { Disconnect: (self: Connection) -> () }

function Signal.new()
	return setmetatable({ _handlers = {} :: { (...any) -> () } }, Signal)
end

function Signal:Connect(fn: (...any) -> ()): Connection
	table.insert(self._handlers, fn)
	local handlers = self._handlers
	return {
		Disconnect = function()
			local i = table.find(handlers, fn)
			if i then
				table.remove(handlers, i)
			end
		end,
	} :: any
end

function Signal:Fire(...: any)
	for _, fn in table.clone(self._handlers) do
		task.spawn(fn, ...)
	end
end

function Signal:Wait(): ...any
	local thread = coroutine.running()
	local conn
	conn = self:Connect(function(...)
		conn:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

return Signal

local function new_stack(t)
	local _stack = {
		push = function(self, ...)
			local tArgs = {...}
			for i = 1, #tArgs do
				self[#self + 1] = tArgs[i]
			end
		end,
		pop = function(self, n)
			local n = n or 1
			if n > #self then
				error("Underflow in stack")
			end
			local ret = {}
			for i = n, 1, -1 do
				ret[#ret + 1] = table.remove(self)
			end
			return unpack(ret)
		end,
		peek = function(self)
			return (#self >= 1 and self[#self] or nil)
		end,
		clear = function(self)
			self:pop(#self)
		end,
		empty = function(self)
			return not (#self >= 1)
		end,
		reverse = function(self)
			for i = #self, 1, -1 do
				table.insert(self, table.remove(self, i))
			end
		end,
		clone = function(self)
			local new = new_stack()
			new:push(unpack(self))
			return new
		end
	}
	return setmetatable(t or {}, {__index = _stack})
end
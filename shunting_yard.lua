--# Begin Bit Api #--

local bit = {}
bit["bnot"] = function(n)
    local tbl = bit.tobits(n)
    local size = math.max(table.getn(tbl), 32)
    for i = 1, size do
        if(tbl[i] == 1) then
            tbl[i] = 0
        else
            tbl[i] = 1
        end
    end
    return bit.tonumb(tbl)
end
bit["band"] = function(m, n)
    local tbl_m = bit.tobits(m)
    local tbl_n = bit.tobits(n)
    bit.expand(tbl_m, tbl_n)
    local tbl = {}
    local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
    for i = 1, rslt do
        if(tbl_m[i]== 0 or tbl_n[i] == 0) then
            tbl[i] = 0
        else
            tbl[i] = 1
        end
    end
    return bit.tonumb(tbl)
end
bit["bor"] = function(m, n)
    local tbl_m = bit.tobits(m)
    local tbl_n = bit.tobits(n)
    bit.expand(tbl_m, tbl_n)
    local tbl = {}
    local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
    for i = 1, rslt do
        if(tbl_m[i]== 0 and tbl_n[i] == 0) then
            tbl[i] = 0
        else
            tbl[i] = 1
        end
    end
    return bit.tonumb(tbl)
end
bit["bxor"] = function(m, n)
    local tbl_m = bit.tobits(m)
    local tbl_n = bit.tobits(n)
    bit.expand(tbl_m, tbl_n)
    local tbl = {}
    local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
    for i = 1, rslt do
        if(tbl_m[i] ~= tbl_n[i]) then
            tbl[i] = 1
        else
            tbl[i] = 0
        end
    end
    return bit.tonumb(tbl)
end
bit["brshift"] = function(n, bits)
    bit.checkint(n)
    local high_bit = 0
    if(n < 0) then
        n = bit.bnot(math.abs(n)) + 1
        high_bit = 2147483648
    end
    for i=1, bits do
        n = n/2
        n = bit.bor(math.floor(n), high_bit)
    end
    return math.floor(n)
end
bit["blshift"] = function(n, bits)
    bit.checkint(n)
    if(n < 0) then
        n = bit.bnot(math.abs(n)) + 1
    end
    for i=1, bits do
        n = n*2
    end
    return bit.band(n, 4294967295)
end
bit["bxor2"] = function(m, n)
    local rhs = bit.bor(bit.bnot(m), bit.bnot(n))
    local lhs = bit.bor(m, n)
    local rslt = bit.band(lhs, rhs)
    return rslt
end
bit["blogic_rshift"] = function(n, bits)
    bit.checkint(n)
    if(n < 0) then
        n = bit.bnot(math.abs(n)) + 1
    end
    for i=1, bits do
        n = n/2
    end
    return math.floor(n)
end
bit["tobits"] = function(n)
    bit.checkint(n)
    if(n < 0) then
        return bit.tobits(bit.bnot(math.abs(n)) + 1)
    end
    local tbl = {}
    local cnt = 1
    while (n > 0) do
        local last = math.fmod(n,2)
        if(last == 1) then
            tbl[cnt] = 1
        else
            tbl[cnt] = 0
        end
        n = (n-last)/2
        cnt = cnt + 1
    end
    return tbl
end
bit["tonumb"] = function(tbl)
    local n = table.getn(tbl)
    local rslt = 0
    local power = 1
    for i = 1, n do
        rslt = rslt + tbl[i]*power
        power = power*2
    end
    return rslt
end
bit["checkint"] = function(n)
    if(n - math.floor(n) > 0) then
        error("trying to use bitwise operation on non-integer!")
    end
end
bit["expand"] = function(tbl_m, tbl_n)
    local big = {}
    local small = {}
    if(table.getn(tbl_m) > table.getn(tbl_n)) then
        big = tbl_m
        small = tbl_n
    else
        big = tbl_n
        small = tbl_m
    end
    for i = table.getn(small) + 1, table.getn(big) do
        small[i] = 0
    end
end

--# End Of Bit Api #--

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

local FUNCTIONS = {
	["abs"]  = math.abs,
	["acos"] = math.acos,
	["asin"] = math.asin,
	["atan"] = math.atan,
	["cos"]  = math.cos,
	["cosh"] = math.cosh,
	["deg"]  = math.deg,
	["exp"]  = math.exp,
	["log"]  = math.log,
	["pow"]  = math.pow,
	["rad"]  = math.rad,
	["sin"]  = math.sin,
	["sinh"] = math.sinh,
	["sqrt"] = math.sqrt,
	["tan"]  = math.tan,
	["tanh"] = math.tanh
}

local stackOps, stackRPN, stackAnswer = new_stack(), new_stack(), new_stack()

local function tokenize(expr)
    local pos = 1
    local function parsebypattern(pat)
        local capture, newpos = string.match(expr, pat, pos)
        if newpos then pos = newpos; return capture end
    end
    local function parsenondelim()
    	return parsebypattern("^([^%|%^%&%+%-%*%/%%%~%>%<%,%(%)]+)()")
    end
    local function parsedelim()
    	return parsebypattern("^([%|%^%&%+%-%*%/%%%~%,%(%)])()")
    		or parsebypattern("^(%>%>)()")
    		or parsebypattern("^(%<%<)()")
    end
    return
    	function()
    		return parsedelim() or parsenondelim()
    	end
end

local function parsenumber(t)
	if t:sub(1, 2) == '0b' then
		return tonumber(t:sub(3, t:len()), 2)
	elseif t:sub(1, 2) == '0o' then
		return tonumber(t:sub(3, t:len()), 8)
	elseif t:sub(1, 2) == '0x' then
		return tonumber(t:sub(3, t:len()), 16)
	else
		return tonumber(t)
	end
end

local function isSeperator(t) return t == ',' end
local function isOpenBracket(t) return t == '(' end
local function isCloseBracket(t) return t == ')' end
local function isNumber(t) 
	return parsenumber(t) ~= nil
end
local function isOperator(t) 
	return t == '|' or t == '^' or t == '&' 
		or t == '<<' or t == '>>' or t == '+' 
		or t == '-' or t == '*' or t == '/' 
		or t == '%' or t == '~'
end
local function isLeftAssoc(op)
	if op == '~' then
		return false
	else
		return true
	end
end
local function isFunction(t)
	return FUNCTIONS[t] ~= nil
end

local function getPrecedence(op)
	return ({
		['|']  = 1,
		['^']  = 2,
		['&']  = 3,
		['<<'] = 4,
		['>>'] = 4,
		['+']  = 5,
		['-']  = 5,
		['*']  = 6,
		['/']  = 6,
		['%']  = 6,
		['~']  = 7  
	})[op]
end	

local function parse(expr)
	stackOps:clear()
	stackRPN:clear()
	local expr = expr:gsub("([ \t])", "")
					 :gsub("°", "*" .. math.pi .. "/180")
					 :gsub("%(%-", "(0-")
					 :gsub("%,%-", ",0-")
					 :gsub("%(%+", "(0+")
					 :gsub("%,%+", ",0+")
	if expr:sub(1, 1) == '-' or expr:sub(1, 1) == '+' then
		expr = '0' .. expr
	end
	for token in tokenize(expr) do
		if isSeperator(token) then
			while not stackOps:empty() and not isOpenBracket(stackOps:peek()) do
				stackRPN:push(stackOps:pop())
			end
		elseif isOpenBracket(token) then
			stackOps:push(token)
		elseif isCloseBracket(token) then
			while not stackOps:empty() and not isOpenBracket(stackOps:peek()) do
				stackRPN:push(stackOps:pop())
			end
			stackOps:pop()
			if not stackOps:empty() and isFunction(stackOps:peek()) then
				stackRPN:push(stackOps:pop())
			end
		elseif isNumber(token) then
			stackRPN:push(token)
		elseif isOperator(token) then
			while not stackOps:empty() and isOperator(stackOps:peek()) and ((isLeftAssoc(token) and getPrecedence(token) <= getPrecedence(stackOps:peek())) or (getPrecedence(token) < getPrecedence(stackOps:peek()))) do
				stackRPN:push(stackOps:pop())
			end
			stackOps:push(token)
		elseif isFunction(token) then
			stackOps:push(token)
		else
			error("Unrecognized token "..token)
		end
	end
	while not stackOps:empty() do
		stackRPN:push(stackOps:pop())
	end		
	stackRPN:reverse()
end

local function evaluate()
	if stackRPN:empty() then
		return ""
	end
	stackAnswer:clear()
	local stackRPN = stackRPN:clone()
	while not stackRPN:empty() do
		local token = stackRPN:pop()
		if isNumber(token) then
			stackAnswer:push(parsenumber(token))
		elseif isOperator(token) then
			if token == '~' then
				stackAnswer:push(bit.bnot(stackAnswer:pop()))
			else
				local a, b = stackAnswer:pop(2)
				if token == '|' then
					stackAnswer:push(bit.bor(b, a))
				elseif token == '^' then
					stackAnswer:push(bit.bxor(b, a))
				elseif token == '&' then
					stackAnswer:push(bit.band(b, a))
				elseif token == '<<' then
					stackAnswer:push(bit.blshift(b, a))
				elseif token == '>>' then
					stackAnswer:push(bit.brshift(b, a))
				elseif token == '+' then
					stackAnswer:push(b + a)
				elseif token == '-'	then
					stackAnswer:push(b - a)
				elseif token == '*' then
					stackAnswer:push(b * a)
				elseif token == '/' then
					stackAnswer:push(b / a)
				elseif token == '%' then
					stackAnswer:push(b % a)
				end
			end
		elseif isFunction(token) then
			local a = stackAnswer:pop()
			if token == "pow" then
				stackAnswer:push(FUNCTIONS[token](stackAnswer:pop(), a))
			else
				stackAnswer:push(FUNCTIONS[token](a))
			end
		end
	end
	if #stackAnswer > 1 then
		error("Some operator missing or too many args for function")
	end
	return stackAnswer:pop()
end

local expr = "0b1000 << 2 ^ 0o72 | 0xF"

parse(expr)
print(string.format("Expression: %s", expr))
local s = stackRPN:clone()
s:reverse()
print(string.format("RPN representation: %s", table.concat(s, " ")))
print(string.format("Result: %d", evaluate()))
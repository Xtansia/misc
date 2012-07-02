local validChars = "<>+-[].,"
local cellPoint
local charPoint
local cells
local prg

local function contains(str, find)
    if not str then return nil end
    str = tostring(str)
	for n=1, #str-#find+1 do
		if str:sub(n,n+#find-1) == find then return true end
	end
	return false
end

function init( nCells )
	cellPoint = 1
	charPoint = 1
	cells = {}
	for n = 1, nCells do
		cells[n] = 0
	end
end

function setProg( str )
	prg = ""
	for n = 1, #str do
		if contains( validChars, str:sub(n, n) ) then
			prg = prg .. str:sub(n, n)
		end
	end
end

function getChar()
	local c = prg:sub(charPoint, charPoint)
	return c
end

function jumpWhileStart()
	local lvl = 0
	for i = charPoint-1, 1, -1 do
		local chr = prg:sub(i, i)
		if chr == "[" then
			if lvl > 0 then
				lvl = lvl - 1
			else
				charPoint = i
				return true
			end
		elseif chr == "]" then
			lvl = lvl + 1
		end
	end
	return true
end

function jumpWhileEnd()
	local lvl = 0
	for i = charPoint + 1, #prg do
		local chr = prg:sub(i, i)
		if chr == "[" then
			lvl = lvl + 1
		elseif chr == "]" then
			if lvl <= 0 then
				charPoint = i + 1
				return true
			else
				lvl = lvl - 1
			end
		end
	end
	return false
end

function interpInstr( instr )
	if instr == "" or instr == nil then
		return false
	end
	if instr == "<" then
		if cellPoint > 1 then
			cellPoint = cellPoint - 1
		else
			cellPoint = 1
		end
	elseif instr == ">" then
		if cellPoint < #cells then
			cellPoint = cellPoint + 1
		end
	elseif instr == "+" then
		cells[cellPoint] = cells[cellPoint] + 1
	elseif instr == "-" then
		cells[cellPoint] = cells[cellPoint] - 1
	elseif instr == "[" then
		if cells[cellPoint] <= 0 then
			return jumpWhileEnd()
		end
	elseif instr == "]" then
		return jumpWhileStart()
	elseif instr == "." then
		io.write(string.char(cells[cellPoint]))
	elseif instr == "," then
		cells[cellPoint] = string.byte(io.read(1))
	end
	charPoint = charPoint + 1
	return true
end

function fullInterp()
	while interpInstr( getChar() ) do end
end

init( 1000 )
setProg("+[>,.[-]<]")
fullInterp()

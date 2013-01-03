local tArgs = {...}
local param = tArgs[1]
local tBE = tArgs[2]
if not tBE or not param then
	error("Usage: rot47 <-f:-s> <FileName:String>")
end

local function rot47(char)
	local p = string.byte(char)
	if p >= string.byte('!') and p <= string.byte('O') then
		p = ((p + 47) % 127)
	elseif p >= string.byte('P') and p <= string.byte('~') then
		p = ((p - 47) % 127)
	end
	return string.char(p)
end

function rot47String( str )
	local rotdStr = ""
	for n=1, str:len() do
		rotdStr = rotdStr..rot47(str:sub(n,n))
	end
	return rotdStr
end

function rot47File( filename )
	local origfile = io.open(filename, "r")
	local fCont = origfile:read("*a")
	origfile:close()
	local encfCont = rot47String( fCont )
	local encdfilename = ""
	print(encfCont)
	if filename:sub(filename:len()-5) == ".rot47" then
		encdfilename = filename:sub(1,filename:len()-6)..".rerot47"
	else
		encdfilename = filename..".rot47"
	end
	local encfile = io.open(encdfilename, "w")
	encfile:write(encfCont)
	encfile:close()
	return encfCont, encdfilename
end

if param == "-f" then
	local encdFileCont, encdFileName = rot47File(tBE)
	print("Encoded File: "..tBE.." | To File: "..encdFileName)
elseif param == "-s" then
	local encdStr = rot47String(tBE)
	print("Encoded String: "..tBE.." | To String: "..encdStr)
else
	error("Unknown Parameter: "..param)
end

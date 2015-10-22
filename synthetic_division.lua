local function synthetic_division (polynomial, divisor)
	if divisor[1] ~= 1 then error("divisor must be a monic polynomial") end

	local work_divisor = {}
	for i = 2, #divisor do
		work_divisor[i - 1] = -divisor[i]
	end

	local work_table = {}
	for i = 1, 1 + #work_divisor do
		work_table[i] = {}
		for j = 1, #polynomial do
			work_table[i][j] = 0
		end
	end

	for i = 1, #polynomial do
		work_table[1][i] = polynomial[i]
	end

	local result = {}
	result[1] = work_table[1][1]

	for i = 2, #polynomial do
		if i + #work_divisor - 1 <= #polynomial then
			for j = 1, #work_divisor do
				work_table[#work_table - j + 1][i + j - 1] = result[i - 1] * work_divisor[j]
			end
		end
		for j = 1, #work_table do
			result[i] = (result[i] or 0) + work_table[j][i]
		end
	end

	local remainder = {}

	for i = 1, #work_divisor do
		table.insert(remainder, 1, table.remove(result))
	end

	return result, remainder
end

local function polynomial_tostring(polynomial)
	local str = ""
	for i = 1, #polynomial do
		local coeff = polynomial[i]
		local deg = #polynomial - i
		if coeff ~= 0 then
			str = str .. (i == 1 and (coeff < 0 and "-" or "") or (coeff > 0 and " + " or " - ")) .. (math.abs(coeff) == 1 and "" or math.abs(coeff)) .. (deg > 0 and "x"..(deg > 1 and "^"..deg or "") or "")
		end
	end
	return str
end

local polynomial = {1, -12, 0, -42}
local divisor 	 = {1, 1, -3}

local result, remainder = synthetic_division(polynomial, divisor)

print("Polynomial: "..polynomial_tostring(polynomial))
print("Divisor: "..polynomial_tostring(divisor))
print("Result: "..polynomial_tostring(result))
print("Remainder: "..polynomial_tostring(remainder))

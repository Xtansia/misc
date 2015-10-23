local function synthetic_division (polynomial, divisor_factor)
	local degree = table.maxn(polynomial)
	local work_table = {
		[degree] = polynomial[degree]
	}

	for i = degree - 1, 0, -1 do
		work_table[i] = (polynomial[i] or 0) + work_table[i + 1] * divisor_factor
	end

	local result = {}
	local remainder = work_table[0]

	for i = 1, table.maxn(work_table) do
		result[i - 1] = work_table[i]
	end

	return result, remainder
end

local function polynomial_tostring(polynomial)
	local degree = table.maxn(polynomial)
	local str = ""
	for i = degree, 0, -1 do
		local coeff = polynomial[i]
		local abs_coeff = math.abs(coeff)
		if abs_coeff > 0 then
			if i == degree then
				str = str .. (coeff < 0 and "-" or "")
			else
				str = str .. " " .. (coeff > 0 and "+" or "-") .. " "
			end
			if i > 0 then
				str = str .. (abs_coeff > 1 and abs_coeff or "") .. "x"
				if i > 1 then
					str = str .. "^" .. i
				end
			else
				str = str .. abs_coeff
			end
		end
	end
	return str
end

local polynomial = {
	[3] = 1,	--   x^3
	[2] = 6,	-- + 6x^2
	[1] = 10,	-- + 10x
	[0] = 3		-- + 3
}
local divisor_factor = -3	-- x + 3 -> x = -3

local result, remainder = synthetic_division(polynomial, divisor_factor)

print("Polynomial: "..polynomial_tostring(polynomial))
print("Divisor: "..polynomial_tostring({[1]=1, [0]=-divisor_factor}))
print("Result: "..polynomial_tostring(result))
print("Remainder: "..remainder)

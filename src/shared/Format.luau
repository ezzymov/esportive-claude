--!strict
-- Number formatting for the HUD: 950, 12.5K, 3.40M, 1.20B.

local Format = {}

local SUFFIXES = { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }

function Format.Short(n: number): string
	local abs = math.abs(n)
	for _, s in SUFFIXES do
		if abs >= s[1] then
			local v = n / s[1]
			local digits = if math.abs(v) >= 100 then 0 elseif math.abs(v) >= 10 then 1 else 2
			return string.format(`%.{digits}f%s`, v, s[2])
		end
	end
	return tostring(math.floor(n))
end

function Format.Cash(n: number): string
	return "$" .. Format.Short(n)
end

return Format

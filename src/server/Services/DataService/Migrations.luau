--!strict
-- Save shape versions, per [[Save Versioning & Migrations]].
-- Migrations[n] turns a v(n) save into v(n+1). One step per version, pure, safe to re-run, never lowers a value.
-- v1 is the first shape, so the chain is empty.

local Migrations = {}

Migrations.CURRENT_VERSION = 1

local steps: { [number]: (data: any) -> () } = {
	-- [1] = function(data) ... end, -- v1 → v2
}

function Migrations.Run(data: any): (boolean, string?)
	local from = data.Version or 1
	for v = from, Migrations.CURRENT_VERSION - 1 do
		local step = steps[v]
		if not step then
			return false, `missing migration {v}`
		end
		local ok, err = pcall(step, data)
		if not ok then
			return false, `migration {v} failed: {err}`
		end
		data.Version = v + 1
	end
	data.Version = math.max(from, data.Version or 1)
	return true
end

return Migrations

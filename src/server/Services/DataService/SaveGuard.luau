--!strict
-- Save guard, layer 1 of [[Backups & Recovery]]. Runs before every write and returns (ok, checkName, detail).
-- Baseline = data as loaded this session; Ledger = net currency change logged through EconomyService:Transact.

local HttpService = game:GetService("HttpService")

local Config = require(script.Parent.Config)

local SaveGuard = {}

export type Baseline = { Currencies: { [string]: number }, RosterCount: number, InventoryCount: number }

local GUARDED_CURRENCIES = { "Cash", "Gems", "Shards" }

local function count(t: any): number
	local n = 0
	if type(t) == "table" then
		for _ in t do
			n += 1
		end
	end
	return n
end

local function inventoryCount(inv: any): number
	if type(inv) ~= "table" then
		return 0
	end
	return count(inv.Parts) + count(inv.Accessories) + count(inv.Cosmetics) + count(inv.Boosters)
end

-- Returns the path of the first NaN/inf number, or nil.
local function findBadNumber(t: any, path: string): string?
	for k, v in t do
		if type(v) == "number" and (v ~= v or v == math.huge or v == -math.huge) then
			return `{path}.{k}`
		elseif type(v) == "table" then
			local bad = findBadNumber(v, `{path}.{k}`)
			if bad then
				return bad
			end
		end
	end
	return nil
end

function SaveGuard.Baseline(data: any): Baseline
	return {
		Currencies = table.clone(data.Currencies),
		RosterCount = count(data.Roster),
		InventoryCount = inventoryCount(data.Inventory),
	}
end

function SaveGuard.Check(
	data: any,
	baseline: Baseline,
	ledger: { [string]: number },
	allowedWipes: { [string]: string }
): (boolean, string?, string?)
	-- Profile shape
	if type(data) ~= "table" or type(data.Version) ~= "number" or type(data.Currencies) ~= "table" or type(data.Roster) ~= "table" then
		return false, "Shape", "missing Version/Currencies/Roster"
	end

	-- NaN / inf
	local bad = findBadNumber(data, "Data")
	if bad then
		return false, "NaN", bad
	end

	-- Negative values
	for name, value in data.Currencies do
		if type(value) ~= "number" or value < 0 then
			return false, "Negative", `{name} = {tostring(value)}`
		end
	end

	-- Wipe detection
	if baseline.RosterCount >= 1 and count(data.Roster) == 0 and not allowedWipes.Roster then
		return false, "Wipe", `Roster {baseline.RosterCount} -> 0`
	end
	if baseline.InventoryCount >= 10 and inventoryCount(data.Inventory) == 0 and not allowedWipes.Inventory then
		return false, "Wipe", `Inventory {baseline.InventoryCount} -> 0`
	end

	-- Currency jump: actual must match baseline + logged transactions (± margin)
	for _, name in GUARDED_CURRENCIES do
		local base = baseline.Currencies[name] or 0
		local expected = base + (ledger[name] or 0)
		local actual = data.Currencies[name] or 0
		if math.abs(actual - expected) > Config.CurrencyMargin * math.abs(base) + 1e-6 then
			return false, "CurrencyJump", `{name} {actual} vs expected {expected}`
		end
	end

	-- Size
	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
	if not ok then
		return false, "Encode", tostring(encoded)
	end
	if #encoded > Config.SizeLimitBytes then
		return false, "Size", `{#encoded} bytes`
	elseif #encoded > Config.SizeWarnBytes then
		warn(`[SaveGuard] profile is {#encoded} bytes (warn at {Config.SizeWarnBytes})`)
	end

	return true
end

return SaveGuard

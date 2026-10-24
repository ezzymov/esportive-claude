--!strict
-- Case odds + rolls ([[Case Unboxing]]). Shared so the Odds panel shows exactly what the server rolls.
-- Server: CaseRoll.Open(def, pity, rng) → { Rarity, Type, ItemId?, Forced? } (CaseService mints player cards).
-- Client: CaseRoll.Odds(def), CaseRoll.PityLeft(def, counters).
-- Order of one open: rarity (with pity) → drop type available at that rarity → item from that type's pool.

local Config = script.Parent.Config
local Cases = require(Config.Cases)
local Rarities = require(Config.Rarities)
local Parts = require(Config.Parts)
local Accessories = require(Config.Accessories)

local CaseRoll = {}

export type Drop = { Rarity: string, Type: string, ItemId: string?, Forced: string? }

local ORDER = Rarities.Order
local TYPES = { "Player", "Part", "Accessory" } -- fixed order: pairs order isn't stable across machines

local rank: { [string]: number } = {}
for i, r in ORDER do
	rank[r] = i
end
CaseRoll.Rank = rank

-- Item pools per type and rarity, sorted so a seeded pick is the same everywhere.
local pools: { [string]: { [string]: { string } } } = { Part = {}, Accessory = {} }
for _, r in ORDER do
	pools.Part[r] = {}
	pools.Accessory[r] = {}
end
for id, item in Parts.Items :: any do
	local tier = Parts.Tiers[item.Tier]
	if tier and not item.Retired then
		table.insert(pools.Part[tier.Rarity], id)
	end
end
for id, item in Accessories.Items :: any do
	if pools.Accessory[item.Tier] and not item.Retired then
		table.insert(pools.Accessory[item.Tier], id)
	end
end
for _, byRarity in pools do
	for _, list in byRarity do
		table.sort(list)
	end
end
CaseRoll.Pools = pools

local function weights(def: any): { [string]: number }
	return if def.Guaranteed then { [def.Guaranteed] = 100 } else def.Odds
end

-- True if the case can drop `rarity` or better.
function CaseRoll.CanDrop(def: any, rarity: string): boolean
	for r, w in weights(def) do
		if w > 0 and rank[r] >= rank[rarity] then
			return true
		end
	end
	return false
end

local function hasPool(t: string, rarity: string): boolean
	return t == "Player" or #pools[t][rarity] > 0
end

-- Drop types possible at a rarity, re-weighted to sum to 1: { { Type, P } }.
function CaseRoll.TypeSplit(def: any, rarity: string): { { Type: string, P: number } }
	local types = def.Types or Cases.Types
	local list, total = {}, 0
	for _, t in TYPES do
		local w = types[t] or 0
		if w > 0 and hasPool(t, rarity) then
			table.insert(list, { Type = t, P = w })
			total += w
		end
	end
	for _, e in list do
		e.P /= total
	end
	return list
end

-- Odds panel rows, rarity order, P > 0 only: { { Rarity, P (0–1), Types = { { Type, P } } } }.
function CaseRoll.Odds(def: any): { any }
	local w = weights(def)
	local total = 0
	for _, r in ORDER do
		total += w[r] or 0
	end
	local rows = {}
	for _, r in ORDER do
		if (w[r] or 0) > 0 then
			table.insert(rows, { Rarity = r, P = w[r] / total, Types = CaseRoll.TypeSplit(def, r) })
		end
	end
	return rows
end

-- Opens left until each pity guarantee this case can trigger: { { Rarity, Left } }, lowest rarity first.
function CaseRoll.PityLeft(def: any, counters: { [string]: number }?): { { Rarity: string, Left: number } }
	local out = {}
	if def.Guaranteed then
		return out
	end
	for _, r in ORDER do
		local need = Cases.Pity[r]
		if need and CaseRoll.CanDrop(def, r) then
			table.insert(out, { Rarity = r, Left = math.max(1, need - ((counters or {})[r] or 0)) })
		end
	end
	return out
end

-- Rolls a rarity. pity = counters (read only, nil = no pity). Returns (rarity, pity rarity that kicked in or nil).
function CaseRoll.Rarity(def: any, pity: { [string]: number }?, rng: Random): (string, string?)
	local w = weights(def)
	local floor, forced = 1, nil
	if pity and not def.Guaranteed then
		for i = #ORDER, 1, -1 do
			local r = ORDER[i]
			local need = Cases.Pity[r]
			if need and CaseRoll.CanDrop(def, r) and (pity[r] or 0) + 1 >= need then
				floor, forced = i, r
				break
			end
		end
	end
	local total = 0
	for i = floor, #ORDER do
		total += w[ORDER[i]] or 0
	end
	local x = rng:NextNumber() * total
	for i = floor, #ORDER do
		x -= w[ORDER[i]] or 0
		if x < 0 then
			return ORDER[i], forced
		end
	end
	for i = #ORDER, floor, -1 do -- float edge: the top rarity with weight
		if (w[ORDER[i]] or 0) > 0 then
			return ORDER[i], forced
		end
	end
	return ORDER[floor], forced
end

-- Counters after an open that dropped `rarity` (mutates pity).
function CaseRoll.AdvancePity(def: any, pity: { [string]: number }, rarity: string)
	if def.Guaranteed then
		return
	end
	for r in Cases.Pity do
		if CaseRoll.CanDrop(def, r) then
			pity[r] = if rank[rarity] >= rank[r] then 0 else (pity[r] or 0) + 1
		end
	end
end

function CaseRoll.Type(def: any, rarity: string, rng: Random): string
	local split = CaseRoll.TypeSplit(def, rarity)
	local x = rng:NextNumber()
	for _, e in split do
		x -= e.P
		if x < 0 then
			return e.Type
		end
	end
	return split[#split].Type
end

-- One open. Mutates pity when given (pass nil to roll the raw configured odds).
function CaseRoll.Open(def: any, pity: { [string]: number }?, rng: Random): Drop
	local rarity, forced = CaseRoll.Rarity(def, pity, rng)
	if pity then
		CaseRoll.AdvancePity(def, pity, rarity)
	end
	local t = CaseRoll.Type(def, rarity, rng)
	local item = nil
	if t ~= "Player" then
		local list = pools[t][rarity]
		item = list[rng:NextInteger(1, #list)]
	end
	return { Rarity = rarity, Type = t, ItemId = item, Forced = forced }
end

-- Config check: odds sum to 100, rarities known, every rarity with odds has something to drop.
function CaseRoll.Validate(): { string }
	local problems = {}
	for _, id in Cases.Order do
		local def = (Cases :: any)[id]
		if not def then
			table.insert(problems, `{id}: listed in Order but not defined`)
			continue
		end
		if not def.Guaranteed then
			local sum = 0
			for r, w in def.Odds do
				if not rank[r] then
					table.insert(problems, `{id}: unknown rarity {r}`)
				end
				sum += w
			end
			if math.abs(sum - 100) > 1e-6 then
				table.insert(problems, `{id}: odds sum to {sum}, not 100`)
			end
		end
		for r, w in weights(def) do
			if w > 0 and #CaseRoll.TypeSplit(def, r) == 0 then
				table.insert(problems, `{id}: nothing to drop at {r}`)
			end
		end
	end
	return problems
end

return CaseRoll

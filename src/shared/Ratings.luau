--!strict
-- Shared rating math (server + UI use the same numbers): OVR, Level badge, gear, station parts, condition,
-- PlayerPower, station income. [[Skill Levels & Ratings]]: OVR and Level use base stats only; gear shows separately.

local Config = script.Parent.Config
local Roles = require(Config.Roles)
local Accessories = require(Config.Accessories)
local Parts = require(Config.Parts)
local Economy = require(Config.Economy)
local Match = require(Config.Match)

local Ratings = {}

local tierRank: { [string]: number } = {}
for i, t in Accessories.TierOrder do
	tierRank[t] = i
end

function Ratings.WeightedOvr(stats: { [string]: number }, role: string): number
	local weights = Roles.Weights[role] or Roles.Weights.Flex
	local total = 0
	for _, stat in Roles.Stats do
		total += (stats[stat] or 0) * weights[stat]
	end
	return total
end

function Ratings.Ovr(card: any): number
	return math.round(Ratings.WeightedOvr(card.Stats, card.Role))
end

-- Level 1–10 and its badge color.
function Ratings.Level(ovr: number): (number, Color3)
	local level, hex = 1, Roles.Levels[1][2]
	for i, row in Roles.Levels do
		if ovr >= row[1] then
			level, hex = i, row[2]
		end
	end
	return level, Color3.fromHex(hex)
end

-- The tier an accessory counts as at a stage ([[Accessories]] → stage tier cap). nil stage = no cap.
function Ratings.CappedTier(tier: string, stage: number?): string
	if not stage then
		return tier
	end
	local cap = Accessories.StageCap[math.clamp(stage, 1, #Accessories.StageCap)]
	return if (tierRank[tier] or 0) > (tierRank[cap] or 0) then cap else tier
end

-- Gear bonus per stat from the card's accessories, stage-capped per item, then capped at +12 per stat.
function Ratings.Gear(card: any, stage: number?): { [string]: number }
	local gear = {}
	for _, itemId in card.Accessories or {} do
		local item = Accessories.Items[itemId]
		if item then
			local bonus = Accessories.TierBonus[Ratings.CappedTier(item.Tier, stage)] or 0
			gear[item.Stat] = math.min((gear[item.Stat] or 0) + bonus, Accessories.GearCapPerStat)
		end
	end
	return gear
end

-- partMult of one station ([[PC Setups]]): Σ tier StatMult × slot weight, +3% for 3+ parts of one brand,
-- +7% when all five slots hold a real part.
function Ratings.PartMult(station: any): number
	local mult, filled = 0, 0
	local brands: { [string]: number } = {}
	for slot, partId in (station and station.Parts) or {} do
		local item = Parts.Items[partId]
		local tier = item and Parts.Tiers[item.Tier]
		if tier and item.Slot == slot then
			mult += tier.StatMult * (Parts.SlotWeight[slot] or 0)
			filled += 1
			if item.Brand then
				brands[item.Brand] = (brands[item.Brand] or 0) + 1
			end
		end
	end
	for _, n in brands do
		if n >= 3 then
			mult += Parts.SetBonus.ThreeSameBrand
			break
		end
	end
	if filled >= #Parts.Slots then
		mult += Parts.SetBonus.FullStation
	end
	return mult
end

-- Morale and fatigue right now: fatigue recovers and morale drifts back to Base over time (stored with *At times).
function Ratings.Condition(card: any, now: number): (number, number)
	local M, F = Match.Morale, Match.Fatigue
	local morale = card.Morale or M.Base
	if card.MoraleAt then
		local drift = (now - card.MoraleAt) / 3600 * M.DriftPerHour
		morale = if morale > M.Base then math.max(M.Base, morale - drift) else math.min(M.Base, morale + drift)
	end
	local fatigue = card.Fatigue or 0
	if card.FatigueAt then
		fatigue = math.max(0, fatigue - (now - card.FatigueAt) / 60 * F.RecoverPerMinute)
	end
	return morale, fatigue
end

-- PlayerPower = Σ((stat + gear) × titleWeight) × (1 + partMult) × moraleMult × fatigueMult ([[Match Simulation]]).
-- Traits and map leans are applied by the sim on top. opts.Gear overrides the card's own gear (Pure mode = {}).
function Ratings.PlayerPower(card: any, titleWeights: { [string]: number }, morale: number?, opts: { Gear: { [string]: number }?, PartMult: number?, Fatigue: number? }?): number
	local o = opts or {}
	local gear = o.Gear or Ratings.Gear(card)
	local power = 0
	for _, stat in Roles.Stats do
		power += ((card.Stats[stat] or 0) + (gear[stat] or 0)) * (titleWeights[stat] or 0)
	end
	local m = morale or 50
	local fatigueMult = if (o.Fatigue or 0) > Match.Fatigue.Threshold then Match.Fatigue.Mult else 1
	return power * (1 + (o.PartMult or 0)) * (0.85 + m / 100 * 0.3) * fatigueMult
end

-- One seated player's station income per second ([[Economy Design]]): base × (1 + OVR/100).
function Ratings.StationIncome(card: any, tier: number?): number
	local row = Economy.StationTiers[tier or 1]
	if not row then
		return 0
	end
	return row.Income * (1 + Ratings.Ovr(card) / Economy.OvrDivisor)
end

return Ratings

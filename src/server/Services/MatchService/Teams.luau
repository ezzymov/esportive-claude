--!strict
-- Team building for the match engine: AI teams from a seed, sim entries for your five (gear, parts, condition),
-- chemistry, lineup snapshots (tournament lock) and the card views the client draws.

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Generator = require(ReplicatedStorage.Shared.Generator)
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Roles = require(ReplicatedStorage.Shared.Config.Roles)
local Rarities = require(ReplicatedStorage.Shared.Config.Rarities)
local AITeams = require(ReplicatedStorage.Shared.Config.AITeams)
local Match = require(ReplicatedStorage.Shared.Config.Match)

local Teams = {}

-- The highest rarity whose OVR range holds `ovr`.
local function rarityFor(ovr: number): string
	local best = "Common"
	for _, r in Rarities.Order do
		local range = Rarities[r].Ovr
		if ovr >= range[1] and ovr <= range[2] then
			best = r
		end
	end
	return best
end

-- An AI team's five (one per role) around an average OVR. Same (teamId, seed, ovr) → same cards everywhere.
function Teams.AI(teamId: string, seed: number, ovr: number): { any }
	local def = (AITeams :: any)[teamId]
	local rng = Random.new(seed)
	local cards = {}
	for i, role in Roles.Order do
		local target = math.clamp(math.round(ovr + (def.Bias or 0) + rng:NextInteger(-3, 3)), 20, 95)
		local card = Generator.Card(`ai-{teamId}-{seed}-{i}`, rng:NextInteger(1, 2 ^ 30), rarityFor(target), { Role = role, Ovr = target })
		card.Source = "AI"
		for _, stat in Roles.Stats do
			local add = ((def.Lean or {})[stat] or 0) + (if def.Variance then rng:NextInteger(-def.Variance, def.Variance) else 0)
			card.Stats[stat] = math.clamp(card.Stats[stat] + add, 1, 99)
		end
		card.Morale = def.Morale or Match.MoraleDefault
		cards[i] = card
	end
	return cards
end

-- Generated pickup / stand-in players.
function Teams.Pugs(n: number, rng: Random, rarity: string, source: string, ovr: { number }?): { any }
	local out = {}
	for _ = 1, n do
		local card = Generator.Card(HttpService:GenerateGUID(false), rng:NextInteger(1, 2 ^ 30), rarity, if ovr then { Ovr = rng:NextInteger(ovr[1], ovr[2]) } else nil)
		card.Source = source
		table.insert(out, card)
	end
	return out
end

local function pairKey(a: string, b: string): string
	return if a < b then `{a}|{b}` else `{b}|{a}`
end
Teams.PairKey = pairKey

-- Matches played together, averaged over every pair of the five (stand-ins count 0).
function Teams.Chemistry(data: any, cards: { any }): number
	local sum, n = 0, 0
	for i = 1, #cards do
		for j = i + 1, #cards do
			sum += (data.Chemistry or {})[pairKey(cards[i].Id, cards[j].Id)] or 0
			n += 1
		end
	end
	return if n > 0 then sum / n else 0
end

-- Sim entry for one of your players. mode "Pure" drops gear + parts ([[Accessories]] → Gear Mode).
-- gearOf(card) and partOf(cardId) come from GearService / StationService.
function Teams.Entry(card: any, mode: string, now: number, gearOf: (any) -> { [string]: number }, partOf: (string) -> number): any
	local morale, fatigue = Ratings.Condition(card, now)
	return {
		Card = card,
		Gear = if mode == "Pure" then {} else gearOf(card),
		PartMult = if mode == "Pure" then 0 else partOf(card.Id),
		Morale = morale,
		Fatigue = fatigue,
		Best = card.BestKills or 0,
	}
end

-- Sim entry for an AI / pug card.
function Teams.Plain(card: any): any
	return { Card = card, Gear = {}, PartMult = 0, Morale = card.Morale or Match.MoraleDefault, Fatigue = 0 }
end

-- What the client needs to draw a player (names are rebuilt server-side so pugs and AI need no lookups).
function Teams.View(card: any, tag: string, founderName: string?): any
	return {
		Id = card.Id,
		Name = if card.Source == "Founder" then founderName or "You" else Generator.Name(card),
		Role = card.Role,
		Rarity = card.Rarity,
		Ovr = Ratings.Ovr(card),
		Stats = card.Stats,
		Trait = card.Trait,
		Source = card.Source,
		Seed = card.Seed,
		KeyId = card.KeyId,
		Tag = if card.Source == "Pug" or card.Source == "StandIn" then "" else tag,
	}
end

-- Lineup snapshot (tournament lock): just what the sim needs, frozen.
function Teams.Snapshot(entries: { any }, chemistry: number, mastery: { [string]: number }): any
	local players = {}
	for _, e in entries do
		local c = e.Card
		table.insert(players, {
			Card = { Id = c.Id, Seed = c.Seed, Source = c.Source, KeyId = c.KeyId, Rarity = c.Rarity, Role = c.Role, Stats = table.clone(c.Stats), Trait = c.Trait },
			Gear = e.Gear,
			PartMult = e.PartMult,
			Morale = e.Morale,
			Fatigue = e.Fatigue,
			Best = e.Best,
		})
	end
	return { Players = players, Chemistry = chemistry, Mastery = table.clone(mastery) }
end

return Teams

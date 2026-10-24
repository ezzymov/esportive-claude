--!strict
-- Seeded player generator ([[Player Generator]]). Same seed → same stats, name, look on every device.
-- The server rolls stats once and saves them (they change later with XP); name, bio and look are rebuilt from
-- Seed on demand and never stored.

local Config = script.Parent.Config
local Roles = require(Config.Roles)
local Rarities = require(Config.Rarities)
local Traits = require(Config.Traits)
local Names = require(Config.Names)
local KeyPlayers = require(Config.KeyPlayers)
local Ratings = require(script.Parent.Ratings)

local Generator = {}

Generator.GEN_VERSION = 1

-- FNV-1a 32-bit, so a uuid string gives a stable seed.
function Generator.Hash(s: string): number
	local h = 2166136261
	for i = 1, #s do
		h = bit32.bxor(h, string.byte(s, i))
		h = (h * 16777619) % 4294967296
	end
	return h
end

local function pick<T>(rng: Random, list: { T }): T
	return list[rng:NextInteger(1, #list)]
end

-- Moves every stat by the same amount so the role-weighted OVR lands on target, then fixes rounding.
local function rescale(stats: { [string]: number }, role: string, target: number)
	local shift = target - Ratings.WeightedOvr(stats, role)
	for stat, v in stats do
		stats[stat] = math.clamp(math.round(v + shift), 1, 99)
	end
	-- Rounding can leave OVR one off; nudge the heaviest stat for this role.
	local weights = Roles.Weights[role]
	local heaviest = "Aim"
	for _, stat in Roles.Stats do
		if weights[stat] > weights[heaviest] then
			heaviest = stat
		end
	end
	for _ = 1, 10 do
		local ovr = math.round(Ratings.WeightedOvr(stats, role))
		if ovr == target then
			break
		end
		stats[heaviest] = math.clamp(stats[heaviest] + (if ovr < target then 1 else -1), 1, 99)
	end
end

local function rollTrait(rng: Random, rarity: string): string?
	local def = Rarities[rarity]
	local allowed = Traits.Allowed[rarity]
	if not def or not allowed or rng:NextNumber() >= def.TraitChance then
		return nil
	end
	local wantNegative = rng:NextNumber() < (Traits.NegativeShare[rarity] or 0)
	local pool = {}
	for id, t in Traits :: any do
		if type(t) == "table" and t.Tier and allowed[t.Tier] and (t.Negative == true) == wantNegative then
			table.insert(pool, id)
		end
	end
	table.sort(pool) -- pairs order isn't stable across machines; sort before the seeded pick
	return if #pool > 0 then pick(rng, pool) else nil
end

-- A generated card. opts.Role forces a role; opts.Source defaults to "Generated" ("Pug" for pickup teammates).
function Generator.Card(id: string, seed: number, rarity: string, opts: { Role: string?, Source: string?, Ovr: number? }?): any
	local o = opts or {}
	local rng = Random.new(seed)
	local def = Rarities[rarity]
	local target = o.Ovr or rng:NextInteger(def.Ovr[1], def.Ovr[2])
	local role = o.Role or pick(rng, Roles.Order)
	local weights = Roles.Weights[role]

	-- Archetype-lite: the two stats the role weighs most go high, the lowest goes low, the rest ±5, noise ±4.
	local ranked = table.clone(Roles.Stats)
	table.sort(ranked, function(a, b)
		if weights[a] == weights[b] then
			return a < b
		end
		return weights[a] > weights[b]
	end)
	local stats: { [string]: number } = {}
	for i, stat in ranked do
		local bias = if i <= 2 then rng:NextInteger(8, 15) elseif i == #ranked then -rng:NextInteger(8, 15) else rng:NextInteger(-5, 5)
		stats[stat] = target + bias + rng:NextInteger(-4, 4)
	end
	rescale(stats, role, target)

	local potential = math.clamp(target + 5 + math.floor(20 * rng:NextNumber() ^ 2), def.Potential[1], math.min(def.Potential[2], 99))
	potential = math.max(potential, target)

	local age = if rng:NextNumber() < 0.8 then rng:NextInteger(17, 24) else rng:NextInteger(15, 30)
	return {
		Id = id,
		Seed = seed,
		Source = o.Source or "Generated",
		Rarity = rarity,
		Role = role,
		Stats = stats,
		Potential = potential,
		Trait = rollTrait(rng, rarity),
		Age = age,
		Country = rng:NextInteger(1, #Names.Countries),
		GenVersion = Generator.GEN_VERSION,
		Morale = 50,
	}
end

-- A hand-made key player copy: fixed role/trait, stats ±StatJitter.
function Generator.KeyCard(id: string, seed: number, keyId: string): any
	local key = KeyPlayers[keyId]
	assert(type(key) == "table", `[Generator] unknown key player {keyId}`)
	local rng = Random.new(seed)
	local stats: { [string]: number } = {}
	for i, stat in Roles.Stats do
		stats[stat] = math.clamp(key.Stats[i] + rng:NextInteger(-KeyPlayers.StatJitter, KeyPlayers.StatJitter), 1, 99)
	end
	local card = {
		Id = id,
		Seed = seed,
		Source = "Key",
		KeyId = keyId,
		Rarity = key.Rarity,
		Role = key.Role,
		Stats = stats,
		Potential = 0,
		Trait = key.Trait,
		Age = key.Age,
		Country = 1,
		GenVersion = Generator.GEN_VERSION,
		Morale = 50,
	}
	local band = KeyPlayers.PotentialBand
	card.Potential = math.min(99, Ratings.Ovr(card) + rng:NextInteger(band[1], band[2]))
	return card
end

-- The Founder ([[Founder (You)]]): all stats ~30, +6 in the role's top stat, OVR exactly 30, Potential 70.
function Generator.Founder(id: string, role: string): any
	local weights = Roles.Weights[role]
	local top = "Aim"
	for _, stat in Roles.Stats do
		if weights[stat] > weights[top] then
			top = stat
		end
	end
	local stats: { [string]: number } = {}
	for _, stat in Roles.Stats do
		stats[stat] = if stat == top then 36 else 30
	end
	rescale(stats, role, 30)
	return {
		Id = id,
		Seed = Generator.Hash(id),
		Source = "Founder",
		Rarity = "Founder",
		Role = role,
		Stats = stats,
		Potential = 70,
		Trait = "PlayerOwner",
		Xp = {},
		Accessories = { Mouse = "TapedMouse" },
		GenVersion = Generator.GEN_VERSION,
		Morale = 55, -- Player-Owner: +5% team morale
	}
end

-- Gamer tag rebuilt from the seed. Key players use their fixed name. Founders use the live display name (UI).
function Generator.Name(card: any): string
	if card.KeyId and KeyPlayers[card.KeyId] then
		return KeyPlayers[card.KeyId].Name
	end
	local rng = Random.new((card.Seed or 0) + 7)
	for _ = 1, 20 do
		local word = pick(rng, Names.TagWords)
		local style = pick(rng, Names.TagStyles)
		local tag = word
		if style == "digit" then
			tag = string.gsub(word, "[oie]", { o = "0", i = "1", e = "3" }, 1)
		elseif style == "caps" then
			tag = string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2, -2) .. string.upper(string.sub(word, -1))
		elseif style == "suffix" then
			tag = word .. pick(rng, Names.Suffixes)
		end
		local lower = string.lower(tag)
		local blocked = false
		for _, bad in Names.Blocked do
			if string.find(lower, bad, 1, true) then
				blocked = true
				break
			end
		end
		if not blocked then
			return tag
		end
	end
	return "player" .. tostring((card.Seed or 0) % 1000)
end

function Generator.Bio(card: any): string
	if card.KeyId and KeyPlayers[card.KeyId] then
		return KeyPlayers[card.KeyId].Bio
	end
	local rng = Random.new((card.Seed or 0) + 13)
	local country = Names.Countries[card.Country or 1] or Names.Countries[1]
	return `{Generator.Name(card)} is a {card.Age or 20}-year-old {card.Role} from {country[2]}, {country[1]}, who {pick(rng, Names.Quirks)}.`
end

local SKIN = { "FFDBAC", "F1C27D", "E0AC69", "C68642", "8D5524", "5C3A21", "FFE0BD", "EAC086", "D1A27C", "A16E4B", "7A4E2D", "4A2C17" }
local SHIRT = { "334155", "B91C1C", "15803D", "1D4ED8", "CA8A04", "7C3AED", "0F766E", "BE185D", "52525B", "EA580C" }
local HAIR = { "1C1917", "3F2A1D", "6B4423", "A16207", "D6D3D1", "7F1D1D", "1E3A8A", "065F46", "DB2777", "F5F5F4" }

-- Body colors for greybox rigs. "Own Tees" ([[Jersey Progression]] tier 1): every player keeps a seeded tee color.
function Generator.Look(card: any): { Skin: Color3, Shirt: Color3, Pants: Color3, Hair: Color3 }
	if card.KeyId and KeyPlayers[card.KeyId] then
		local l = KeyPlayers[card.KeyId].Look
		return { Skin = Color3.fromHex(l.Skin), Shirt = Color3.fromHex(l.Shirt), Pants = Color3.fromHex(l.Pants), Hair = Color3.fromHex(l.Hair) }
	end
	local rng = Random.new((card.Seed or 0) + 29)
	return {
		Skin = Color3.fromHex(pick(rng, SKIN)),
		Shirt = Color3.fromHex(pick(rng, SHIRT)),
		Pants = Color3.fromHex(pick(rng, { "1F2937", "374151", "1E3A8A", "44403C", "0F172A" })),
		Hair = Color3.fromHex(pick(rng, HAIR)),
	}
end

-- Auto team name: [Adjective] [Noun] + tag from the initials.
function Generator.TeamName(rng: Random): (string, string)
	local adj, noun = pick(rng, Names.TeamAdjectives), pick(rng, Names.TeamNouns)
	local tag = string.upper(string.sub(adj, 1, 2) .. string.sub(noun, 1, 1))
	return `{adj} {noun}`, tag
end

return Generator

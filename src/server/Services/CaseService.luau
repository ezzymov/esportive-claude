--!strict
-- CaseService ([[Case Unboxing]], [[Case Library]]): every roll happens here with one Random.new() (Shared/CaseRoll
-- holds the odds math the Odds panel shows). Pity counters live in Profile.PityCounters.
--   Case/Open (RF) caseId, count ∈ {1,5,10}, owned → { Drops, Shards, Pity }. Rate 2/s ([[Services & Remotes]]).
--     owned = open crates from Inventory.Cases; otherwise buy them (price × count, Cash or Gems; no Robux).
--   Case/ClaimFree (RF) → the free Rookie Crate every 30 min from Stage 2.
-- Duplicates become Shards: a part once you own one per desk, an accessory once you own one per roster player,
-- a player once the roster is full. Forced save on Legendary+ (and on the FTUE crate).
-- StarterCrate = the Stage 1 FTUE crate: one Rare player rolled when granted (Ftue.StarterRoll), so rejoining
-- can't reroll it.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lib = script.Parent.Parent.Lib
local Remote = require(Lib.Remote)
local Log = require(Lib.Log)
local Bus = require(Lib.Bus)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local AnalyticsService = require(script.Parent.AnalyticsService)
local RosterService = require(script.Parent.RosterService)
local Generator = require(ReplicatedStorage.Shared.Generator)
local CaseRoll = require(ReplicatedStorage.Shared.CaseRoll)
local Cases = require(ReplicatedStorage.Shared.Config.Cases)
local Hiring = require(ReplicatedStorage.Shared.Config.Hiring)

local CaseService = { Tier = 3 }

local rng = Random.new()
local busy: { [Player]: boolean } = {}

local function guid(): string
	return HttpService:GenerateGUID(false)
end

local function bump(player: Player, path: string, n: number)
	DataService:Update(player, path, function(v)
		return (v or 0) + n
	end)
end

-- Copies you own (unequipped + equipped) and copies you can still use.
local function partCopies(data: any, itemId: string): (number, number)
	local owned = data.Inventory.Parts[itemId] or 0
	local desks = 0
	for _, station in data.Stations do
		desks += 1
		for _, id in station.Parts or {} do
			if id == itemId then
				owned += 1
			end
		end
	end
	return owned, desks
end

local function accessoryCopies(data: any, itemId: string): (number, number)
	local owned = data.Inventory.Accessories[itemId] or 0
	local players = 0
	for _, card in data.Roster do
		players += 1
		for _, id in card.Accessories or {} do
			if id == itemId then
				owned += 1
			end
		end
	end
	return owned, players
end

function CaseService:GrantCase(player: Player, caseId: string, n: number, reason: string): boolean
	if not (Cases :: any)[caseId] or not DataService:GetProfile(player) then
		return false
	end
	bump(player, "Inventory.Cases." .. caseId, n)
	Log.Info("Case", `{player.Name} +{n} {caseId} ({reason})`)
	Bus.Fire(player, "CaseGranted", caseId)
	return true
end

-- The FTUE crate (Stage 1 team-game win). The Rare is rolled now and saved.
function CaseService:GrantCrate(player: Player): boolean
	local data = DataService:GetProfile(player)
	if not data then
		return false
	end
	if not data.Ftue.StarterRoll.Id then
		local roll = { Id = guid(), Seed = rng:NextInteger(1, 2 ^ 30) }
		DataService:Update(player, "Ftue.StarterRoll", function()
			return roll
		end)
	end
	bump(player, "Inventory.Cases.StarterCrate", 1)
	bump(player, "Ftue.CratesEarned", 1)
	Bus.Fire(player, "CrateGranted", "StarterCrate")
	DataService:SaveNow(player, "CrateGranted")
	return true
end

-- Turns one roll into what the player gets. Mutates nothing in the profile except through Update.
local function deliver(player: Player, data: any, caseId: string, drop: CaseRoll.Drop, walkIn: boolean): any
	local out: any = { Type = drop.Type, Rarity = drop.Rarity, Forced = drop.Forced, Shards = 0, New = false }
	if drop.Type == "Player" then
		local card
		if caseId == "StarterCrate" and data.Ftue.StarterRoll.Id then
			local roll = data.Ftue.StarterRoll
			card = Generator.Card(roll.Id, roll.Seed, drop.Rarity)
			DataService:Update(player, "Ftue.StarterRoll", function()
				return {}
			end)
		else
			card = Generator.Card(guid(), rng:NextInteger(1, 2 ^ 30), drop.Rarity)
		end
		out.Card = card
		local max = Hiring.RosterMax[data.Stage] or Hiring.RosterMax[#Hiring.RosterMax]
		if RosterService:RosterCount(data) >= max then
			out.Shards = Cases.Shards[drop.Rarity] or 0
			out.Reason = "RosterFull"
		else
			RosterService:AddCard(player, card, walkIn)
			out.New = true
		end
		return out
	end

	local itemId = drop.ItemId :: string
	out.ItemId = itemId
	local owned, usable
	if drop.Type == "Part" then
		owned, usable = partCopies(data, itemId)
	else
		owned, usable = accessoryCopies(data, itemId)
	end
	out.New = not data.Collection[itemId]
	if owned >= math.max(usable, 1) then
		out.Shards = Cases.Shards[drop.Rarity] or 0
		out.Reason = "Duplicate"
	else
		bump(player, `Inventory.{if drop.Type == "Part" then "Parts" else "Accessories"}.{itemId}`, 1)
	end
	if out.New then
		DataService:Update(player, "Collection." .. itemId, function()
			return os.time()
		end)
	end
	return out
end

local function open(player: Player, caseId: string, count: number, owned: boolean?): (boolean, any)
	local def = (Cases :: any)[caseId]
	local data = DataService:GetProfile(player)
	if not def or type(def) ~= "table" or not data then
		return false, "Unknown"
	end
	if busy[player] then
		return false, "Busy"
	end
	if (Cases.CountStage[count] or math.huge) > data.Stage then
		return false, { NeedStage = Cases.CountStage[count] }
	end
	local useOwned = owned == true or def.Hidden == true
	if useOwned then
		if (data.Inventory.Cases[caseId] or 0) < count then
			return false, "NoCase"
		end
	else
		if (def.Stage or math.huge) > data.Stage then
			return false, { NeedStage = def.Stage }
		end
		local cost = def.Price * count
		if (data.Currencies[def.Currency] or 0) < cost then
			return false, { Need = cost - (data.Currencies[def.Currency] or 0), Currency = def.Currency }
		end
	end

	busy[player] = true
	local ok, result = pcall(function()
		if useOwned then
			bump(player, "Inventory.Cases." .. caseId, -count)
		else
			local paid, err = EconomyService:Transact(player, { [def.Currency] = -def.Price * count }, `CaseBuy:{caseId}x{count}`)
			if not paid then
				return { Error = err }
			end
		end

		local pity = table.clone(data.PityCounters)
		local drops, shards, best, forced = {}, 0, "Common", false
		local walked = false
		for _ = 1, count do
			local drop = CaseRoll.Open(def, pity, rng)
			local wantWalk = drop.Type == "Player" and not walked
			local got = deliver(player, data, caseId, drop, wantWalk)
			if wantWalk and got.New then
				walked = true
			end
			shards += got.Shards
			forced = forced or drop.Forced ~= nil
			if CaseRoll.Rank[drop.Rarity] > CaseRoll.Rank[best] then
				best = drop.Rarity
			end
			table.insert(drops, got)
		end
		if shards > 0 then
			EconomyService:Transact(player, { Shards = shards }, `CaseDuplicates:{caseId}`)
		end
		DataService:Update(player, "PityCounters", function()
			return pity
		end)
		bump(player, "CaseStats.Opened", count)
		bump(player, "Ftue.CratesOpened", count)

		local summary = {}
		for _, d in drops do
			table.insert(summary, `{d.Rarity} {d.ItemId or d.Type}{if d.Shards > 0 then " (+" .. d.Shards .. " Shards)" else ""}`)
		end
		Log.Info("Case", `{player.Name} opened {caseId} ×{count}{if useOwned then " (owned)" else ""} → {table.concat(summary, ", ")}`)
		AnalyticsService:Custom(player, "CaseOpened", count, { caseId = caseId, best = best, pity = forced })
		Bus.Fire(player, "CaseOpened", { CaseId = caseId, Count = count, Best = best })
		if CaseRoll.Rank[best] >= CaseRoll.Rank[Cases.SaveAtRarity] or caseId == "StarterCrate" then
			DataService:SaveNow(player, `CaseOpened:{best}`)
		end
		return { Drops = drops, Shards = shards, Pity = pity }
	end)
	busy[player] = nil
	if not ok then
		error(result)
	end
	if result.Error then
		return false, result.Error
	end
	return true, result
end

CaseService.Open = open -- Studio DevHooks "Open"

local function claimFree(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data then
		return false, "NotLoaded"
	end
	if data.Stage < Cases.Free.Stage then
		return false, "Locked"
	end
	local now = os.time()
	local at = data.CaseStats.NextFreeAt
	if at == 0 or now < at then
		return false, { NextIn = if at == 0 then Cases.Free.Every else at - now }
	end
	DataService:Update(player, "CaseStats.NextFreeAt", function()
		return now + Cases.Free.Every
	end)
	CaseService:GrantCase(player, Cases.Free.CaseId, 1, "FreeTimer")
	AnalyticsService:Custom(player, "FreeCrateClaimed", 1)
	return true, Cases.Free.CaseId
end

-- Starts the free-crate timer once the player reaches its stage; moves an unopened M1 FTUE crate to StarterCrate.
local function tick(player: Player)
	local data = DataService:GetProfile(player)
	if not data then
		return
	end
	if data.Stage >= Cases.Free.Stage and data.CaseStats.NextFreeAt == 0 then
		DataService:Update(player, "CaseStats.NextFreeAt", function()
			return os.time() + Cases.Free.Every
		end)
	end
end

local function onLoaded(player: Player, data: any)
	if data.Ftue.StarterRoll.Id and (data.Inventory.Cases.RookieCrate or 0) > 0 and (data.Inventory.Cases.StarterCrate or 0) == 0 then
		bump(player, "Inventory.Cases.RookieCrate", -1)
		bump(player, "Inventory.Cases.StarterCrate", 1)
	end
	tick(player)
end

function CaseService:Init()
	for _, problem in CaseRoll.Validate() do
		warn(`[Case] config: {problem}`)
	end
	Remote.Function("Case", "Open", {
		Args = { Remote.T.OneOf(Cases.Order), Remote.T.OneOf(Cases.Counts), Remote.T.Boolean() },
		Rate = { Count = 2, Per = 1 },
	}, open)
	Remote.Function("Case", "ClaimFree", { Rate = { Count = 2, Per = 1 } }, claimFree)
	DataService.ProfileLoaded:Connect(onLoaded)
end

function CaseService:Start()
	Players.PlayerRemoving:Connect(function(player)
		busy[player] = nil
	end)
	while true do
		task.wait(5)
		for _, player in Players:GetPlayers() do
			tick(player)
		end
	end
end

return CaseService

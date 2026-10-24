--!strict
-- RosterService ([[Player Hiring]], [[Founder (You)]]): the Founder card, station seating + income, Founder XP,
-- the free-agent board (Rusty featured) and Roster/Hire.
--   Roster/GetFreeAgents (RF) → { Unlocked, FreeDesks, Listings = { { Id, Card, Price, Featured, ExpiresAt } } }
--   Roster/Hire (RF) listingId → card id. Checks: board unlocked (2nd desk), listing exists + not expired,
--     a free desk, cash. The hired player walks in and sits at the free desk.
--   Roster/Hired (S→C) cardId → client plays the short hire mini-scene.
-- Guardrail ([[Stage 1 - Garage Squad]]): no hire by 12 min of play → Rusty drops to $100 + Aunt Dee text.
-- M2 ([[Screen - Roster]]): roster cap by stage (Hiring.RosterMax), the active five = the players at desks 1–5,
--   Roster/Lineup (RF) cardId, desk → seats a bench player at a desk (whoever sat there goes to the bench),
--   Roster/Release (RF) cardId → gear back to the inventory, card removed. Never the Founder.

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
local PlotService = require(script.Parent.PlotService)
local GearService = require(script.Parent.GearService)
local Generator = require(ReplicatedStorage.Shared.Generator)
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Hiring = require(ReplicatedStorage.Shared.Config.Hiring)
local Rarities = require(ReplicatedStorage.Shared.Config.Rarities)
local Pads = require(ReplicatedStorage.Shared.Config.Pads)
local Roles = require(ReplicatedStorage.Shared.Config.Roles)
local Accessories = require(ReplicatedStorage.Shared.Config.Accessories)

local RosterService = { Tier = 3 }

type Listing = { Id: string, Card: any, Price: number, Featured: boolean, ExpiresAt: number }
type Board = { Listings: { [string]: Listing }, RolledAt: number }

local boards: { [Player]: Board } = {}
local hiredRemote: RemoteEvent
local rng = Random.new()

local function guid(): string
	return HttpService:GenerateGUID(false)
end

local function count(t: any): number
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end

function RosterService:RosterCount(data: any): number
	return count(data.Roster)
end

function RosterService:RosterMax(data: any): number
	return Hiring.RosterMax[math.clamp(data.Stage, 1, #Hiring.RosterMax)]
end

-- The players who play matches: the Founder, then whoever sits at desks 2, 3, … (up to Hiring.ActiveSize).
function RosterService:ActiveFive(data: any): { any }
	local out = {}
	local founder = data.Roster[data.FounderUuid]
	if founder then
		table.insert(out, founder)
	end
	local slots = {}
	for slot in data.Stations do
		if slot ~= "1" then
			table.insert(slots, tonumber(slot) :: number)
		end
	end
	table.sort(slots)
	for _, n in slots do
		local card = data.Roster[data.Stations[tostring(n)].PlayerId]
		if card and card.Source ~= "Founder" and #out < Hiring.ActiveSize then
			table.insert(out, card)
		end
	end
	return out
end

-- Seated = players at a desk. The Founder counts once the PC is powered.
function RosterService:SeatedCount(data: any): number
	local n = 0
	for _, station in data.Stations do
		if station.PlayerId ~= "" and data.Roster[station.PlayerId] then
			n += 1
		end
	end
	return n
end

local function freeSlots(data: any): { string }
	local slots = {}
	for slot, station in data.Stations do
		if station.PlayerId == "" or not data.Roster[station.PlayerId] then
			table.insert(slots, slot)
		end
	end
	table.sort(slots)
	return slots
end

local function isSeated(data: any, cardId: string): boolean
	for _, station in data.Stations do
		if station.PlayerId == cardId then
			return true
		end
	end
	return false
end

-- Puts every unseated roster player at a free desk. Returns the ids that got seated.
function RosterService:SeatUnseated(player: Player): { string }
	local data = DataService:GetProfile(player)
	if not data then
		return {}
	end
	local seated = {}
	local free = freeSlots(data)
	local ids = {}
	for id in data.Roster do
		table.insert(ids, id)
	end
	table.sort(ids)
	for _, id in ids do
		if #free == 0 then
			break
		end
		if not isSeated(data, id) and data.Roster[id].Source ~= "Founder" then
			local slot = table.remove(free, 1) :: string
			DataService:Update(player, `Stations.{slot}.PlayerId`, function()
				return id
			end)
			table.insert(seated, id)
		end
	end
	return seated
end

-- Adds a card to the roster and seats it if a desk is free. walkIn plays the hire scene for it.
function RosterService:AddCard(player: Player, card: any, walkIn: boolean?): boolean
	local ok = DataService:Update(player, "Roster." .. card.Id, function()
		return card
	end)
	if not ok then
		return false
	end
	RosterService:SeatUnseated(player)
	PlotService:Refresh(player, { WalkIn = if walkIn then card.Id else nil })
	return true
end

-- Founder ---------------------------------------------------------------------------------------------------

function RosterService:CreateFounder(player: Player): any
	local data = DataService:GetProfile(player)
	if not data then
		return nil
	end
	if data.FounderUuid ~= "" and data.Roster[data.FounderUuid] then
		return data.Roster[data.FounderUuid]
	end
	local role = data.Team.FounderRole
	if not table.find(Roles.Order, role) then
		role = "Flex"
	end
	local card = Generator.Founder(guid(), role)
	DataService:Update(player, "Roster." .. card.Id, function()
		return card
	end)
	DataService:Update(player, "FounderUuid", function()
		return card.Id
	end)
	DataService:Update(player, "Stations.1", function()
		return { PlayerId = card.Id, Tier = 1, Parts = {} }
	end)
	Log.Info("Roster", `{player.Name} Founder minted ({role}, OVR {Ratings.Ovr(card)})`)
	return card
end

function RosterService:GetFounder(player: Player): any
	local data = DataService:GetProfile(player)
	return data and data.Roster[data.FounderUuid]
end

-- Founder XP from minigames ([[Founder (You)]] → How your Founder grows). 100 XP = +1, capped at Potential.
-- Returns the whole stat points gained.
function RosterService:AddFounderXp(player: Player, stat: string, xp: number): number
	local data = DataService:GetProfile(player)
	local founder = data and data.Roster[data.FounderUuid]
	if not founder or not founder.Stats[stat] then
		return 0
	end
	local gained = 0
	DataService:Update(player, "Roster." .. founder.Id, function(card)
		card.Xp = card.Xp or {}
		local total = (card.Xp[stat] or 0) + math.floor(xp)
		while total >= 100 and card.Stats[stat] < card.Potential do
			total -= 100
			card.Stats[stat] += 1
			gained += 1
		end
		card.Xp[stat] = if card.Stats[stat] >= card.Potential then 0 else total
		return card
	end)
	return gained
end

-- Income provider for EconomyService: Σ seated players' station income. The Founder desk pays only while you sit.
local function income(player: Player, data: any, offline: boolean): number
	local total = 0
	for slot, station in data.Stations do
		local card = data.Roster[station.PlayerId]
		if card then
			local founderDesk = slot == "1"
			if not founderDesk or (not offline and PlotService:IsFounderSeated(player)) then
				total += Ratings.StationIncome(card, station.Tier)
			end
		end
	end
	return total
end

-- Free agents -----------------------------------------------------------------------------------------------

local function rustyHired(data: any): boolean
	for _, card in data.Roster do
		if card.KeyId == Hiring.Featured.KeyId then
			return true
		end
	end
	return false
end

local function boardUnlocked(data: any): boolean
	return data.HQ.PadsBought.Desk2 == true
end

local function featuredPrice(data: any): number
	return if data.Ftue.RustyDiscount then Hiring.Featured.DiscountPrice else Hiring.Featured.Price
end

local function generatedPrice(card: any): number
	local def = Rarities[card.Rarity]
	return def.BaseValue + math.max(0, Ratings.Ovr(card) - def.Ovr[1]) * Hiring.PerOvr
end

local function getBoard(player: Player, data: any): Board
	local board = boards[player]
	local now = os.time()
	if not board or now - board.RolledAt >= Hiring.Refresh then
		board = { Listings = {}, RolledAt = now }
		for _ = 1, Hiring.Generated do
			local card = Generator.Card(guid(), rng:NextInteger(1, 2 ^ 30), Hiring.GeneratedRarity)
			local id = guid()
			board.Listings[id] = { Id = id, Card = card, Price = generatedPrice(card), Featured = false, ExpiresAt = now + Hiring.Refresh }
		end
		boards[player] = board
	end
	-- Rusty stays featured (same copy, seeded per account) until hired.
	local featuredId = "Featured_" .. Hiring.Featured.KeyId
	if rustyHired(data) then
		board.Listings[featuredId] = nil
	elseif not board.Listings[featuredId] then
		local seed = Generator.Hash(tostring(player.UserId) .. Hiring.Featured.KeyId)
		board.Listings[featuredId] = { Id = featuredId, Card = Generator.KeyCard(guid(), seed, Hiring.Featured.KeyId), Price = 0, Featured = true, ExpiresAt = 0 }
	end
	local featured = board.Listings[featuredId]
	if featured then
		featured.Price = featuredPrice(data)
	end
	return board
end

local function boardText(data: any): string
	if not boardUnlocked(data) then
		return "FREE AGENTS\nsoon"
	end
	if rustyHired(data) then
		return "FREE AGENTS\nnew flyers every 10 min"
	end
	return `FREE AGENTS\n★ Rusty · ${featuredPrice(data)}`
end

function RosterService:RefreshBoard(player: Player)
	local data = DataService:GetProfile(player)
	if data then
		PlotService:SetBoard(player, boardText(data))
	end
end

local function getFreeAgents(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data then
		return false, "NotLoaded"
	end
	local unlocked = boardUnlocked(data)
	local out = {}
	if unlocked then
		for _, l in getBoard(player, data).Listings do
			table.insert(out, { Id = l.Id, Card = l.Card, Price = l.Price, Featured = l.Featured, ExpiresAt = l.ExpiresAt })
		end
		table.sort(out, function(a, b)
			if a.Featured ~= b.Featured then
				return a.Featured
			end
			return a.Price < b.Price
		end)
	end
	return true, { Unlocked = unlocked, FreeDesks = #freeSlots(data), Listings = out }
end

local function hire(player: Player, listingId: string): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data then
		return false, "NotLoaded"
	end
	if not boardUnlocked(data) then
		return false, "Locked"
	end
	local board = getBoard(player, data)
	local listing = board.Listings[listingId]
	if not listing then
		return false, "Gone"
	end
	if not listing.Featured and os.time() > listing.ExpiresAt then
		return false, "Expired"
	end
	if #freeSlots(data) == 0 then
		return false, "NoDesk"
	end
	if RosterService:RosterCount(data) >= RosterService:RosterMax(data) then
		return false, "RosterFull"
	end
	local paid, err = EconomyService:Transact(player, { Cash = -listing.Price }, `Hire:{listing.Card.KeyId or listing.Card.Rarity}`)
	if not paid then
		return false, if err == "Insufficient" then { Need = listing.Price - data.Currencies.Cash } else err
	end
	board.Listings[listingId] = nil
	local card = listing.Card
	local first = RosterService:RosterCount(data) <= 1
	RosterService:AddCard(player, card, true)
	if first and data.Ftue.FirstHireAt == 0 then
		DataService:Update(player, "Ftue.FirstHireAt", function()
			return AnalyticsService:PlaySeconds(player)
		end)
	end
	AnalyticsService:Custom(player, "PlayerHired", listing.Price, { key = card.KeyId or "", rarity = card.Rarity, discount = data.Ftue.RustyDiscount })
	hiredRemote:FireClient(player, card.Id)
	Bus.Fire(player, "PlayerHired", card.Id)
	RosterService:RefreshBoard(player)
	DataService:SaveNow(player, "Hire")
	return true, card.Id
end

-- Lineup + release ----------------------------------------------------------------------------------------------

local function seatOf(data: any, cardId: string): string?
	for slot, station in data.Stations do
		if station.PlayerId == cardId then
			return slot
		end
	end
	return nil
end

local function lineup(player: Player, cardId: string, slot: string): (boolean, any)
	local data = DataService:GetProfile(player)
	local card = data and data.Roster[cardId]
	if not card then
		return false, "NoPlayer"
	end
	if card.Source == "Founder" or slot == "1" then
		return false, "FounderDesk" -- desk 1 is yours
	end
	if GearService.InMatch(player) then
		return false, "InMatch"
	end
	local station = data.Stations[slot]
	if not station then
		return false, "NoDesk"
	end
	local current = seatOf(data, cardId)
	if current == slot then
		return true, slot
	end
	local occupant = station.PlayerId
	if current then
		DataService:Update(player, `Stations.{current}.PlayerId`, function()
			return if data.Roster[occupant] then occupant else ""
		end)
	end
	DataService:Update(player, `Stations.{slot}.PlayerId`, function()
		return cardId
	end)
	PlotService:Refresh(player)
	Bus.Fire(player, "LineupChanged", cardId)
	return true, slot
end

local function release(player: Player, cardId: string): (boolean, any)
	local data = DataService:GetProfile(player)
	local card = data and data.Roster[cardId]
	if not card then
		return false, "NoPlayer"
	end
	if card.Source == "Founder" then
		return false, "Founder" -- [[Founder (You)]]: can't be traded or released
	end
	if GearService.InMatch(player) then
		return false, "InMatch"
	end
	GearService:StripCard(player, cardId)
	local slot = seatOf(data, cardId)
	if slot then
		DataService:Update(player, `Stations.{slot}.PlayerId`, function()
			return ""
		end)
	end
	DataService:Update(player, "Roster." .. cardId, function()
		return nil
	end)
	DataService:Update(player, "Chemistry", function(chem)
		for key in table.clone(chem or {}) do
			if string.find(key, cardId, 1, true) then
				chem[key] = nil
			end
		end
		return chem or {}
	end)
	RosterService:SeatUnseated(player)
	PlotService:Refresh(player)
	AnalyticsService:Custom(player, "PlayerReleased", 1, { rarity = card.Rarity, key = card.KeyId or "" })
	Log.Info("Roster", `{player.Name} released {Generator.Name(card)} ({card.Rarity})`)
	Bus.Fire(player, "PlayerReleased", cardId)
	DataService:SaveNow(player, "Release")
	return true, cardId
end

-- Pacing guardrail tick.
local function checkDiscount(player: Player)
	local data = DataService:GetProfile(player)
	if not data or data.Ftue.RustyDiscount or rustyHired(data) or RosterService:RosterCount(data) >= 2 then
		return
	end
	if AnalyticsService:PlaySeconds(player) >= Hiring.Featured.DiscountAfter then
		DataService:Update(player, "Ftue.RustyDiscount", function()
			return true
		end)
		AnalyticsService:Custom(player, "RustyDiscount", AnalyticsService:PlaySeconds(player))
		Log.Info("Roster", `{player.Name} Rusty discount → ${Hiring.Featured.DiscountPrice}`)
		Bus.Fire(player, "Line", "TUT_HIRE_DISCOUNT")
		RosterService:RefreshBoard(player)
	end
end

function RosterService:Init()
	EconomyService.IncomeProvider = income
	hiredRemote = Remote.Push("Roster", "Hired")
	Remote.Function("Roster", "GetFreeAgents", { Mutates = false, Rate = { Count = 2, Per = 1 } }, getFreeAgents)
	Remote.Function("Roster", "Hire", { Args = { Remote.T.String(64) }, Rate = { Count = 2, Per = 1 } }, hire)
	Remote.Function("Roster", "Lineup", { Args = { Remote.T.String(64), Remote.T.String(4) }, Rate = { Count = 4, Per = 1 } }, lineup)
	Remote.Function("Roster", "Release", { Args = { Remote.T.String(64) }, Rate = { Count = 1, Per = 2 } }, release)

	Bus.On(function(player, event, payload)
		if event == "PadBought" then
			local pad = Pads.ById[payload]
			if pad and pad.Builds.Accessory then
				local founder = RosterService:GetFounder(player)
				local item = Accessories.Items[pad.Builds.Accessory]
				if founder and item then
					DataService:Update(player, `Roster.{founder.Id}.Accessories.{item.Slot}`, function()
						return pad.Builds.Accessory
					end)
				end
			end
			if pad and pad.Builds.Desk then
				RosterService:SeatUnseated(player)
			end
			PlotService:Refresh(player)
			RosterService:RefreshBoard(player)
		elseif event == "PlotReady" then
			RosterService:SeatUnseated(player)
			PlotService:Refresh(player)
			RosterService:RefreshBoard(player)
		end
	end)
end

function RosterService:Start()
	Players.PlayerRemoving:Connect(function(player)
		boards[player] = nil
	end)
	while true do
		task.wait(5)
		for _, player in Players:GetPlayers() do
			checkDiscount(player)
		end
	end
end

return RosterService

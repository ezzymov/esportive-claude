--!strict
-- StationService ([[PC Setups]], [[Screen - Tech Shop]]): station parts and income tiers, and the Tech Shop.
--   Shop/GetStock (RF) → { Items = { { Kind, Id, Price } }, RefreshAt, Stage } (same stock everywhere per 10-min window)
--   Shop/Buy (RF) kind ∈ Part | Accessory, id → one copy into the inventory; the item must be in the current stock.
--   Station/Equip (RF) slot, partId → part from Inventory.Parts into Stations[slot].Parts[part slot]; old one back.
--   Station/Unequip (RF) slot, partSlot → part back to the inventory.
--   Station/Upgrade (RF) slot → next income tier (Economy.StationTiers price), up to TechShop.MaxStationTier[stage].
-- PartMult(data, cardId, mode): the partMult of the desk a card sits at (0 in Pure mode / on the bench).

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
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Parts = require(ReplicatedStorage.Shared.Config.Parts)
local Accessories = require(ReplicatedStorage.Shared.Config.Accessories)
local Economy = require(ReplicatedStorage.Shared.Config.Economy)
local TechShop = require(ReplicatedStorage.Shared.Config.TechShop)

local StationService = { Tier = 3 }

local function byStage<T>(list: { T }, stage: number): T
	return list[math.clamp(stage, 1, #list)]
end

function StationService:PartMult(data: any, cardId: string, mode: string?): number
	if mode == "Pure" then
		return 0
	end
	for _, station in data.Stations do
		if station.PlayerId == cardId then
			return Ratings.PartMult(station)
		end
	end
	return 0
end

-- Tech Shop stock --------------------------------------------------------------------------------------------------

-- Deterministic per (window, stage): every server shows the same stock. Returns items + when it changes.
function StationService:Stock(stage: number, now: number?): ({ { Kind: string, Id: string, Price: number } }, number)
	local t = now or os.time()
	local window = t // TechShop.Refresh
	local rng = Random.new(window * 7919 + stage)
	local function pick(candidates: { string }, n: number): { string }
		table.sort(candidates)
		local out = {}
		while #out < n and #candidates > 0 do
			table.insert(out, table.remove(candidates, rng:NextInteger(1, #candidates)) :: string)
		end
		table.sort(out)
		return out
	end
	local partTiers = byStage(TechShop.PartTiers, stage)
	local parts = {}
	for id, item in Parts.Items :: any do
		if table.find(partTiers, item.Tier) and not item.Retired then
			table.insert(parts, id)
		end
	end
	local accTiers = byStage(TechShop.AccessoryTiers, stage)
	local accs = {}
	for id, item in Accessories.Items :: any do
		local slot = Accessories.Slots[item.Slot]
		if table.find(accTiers, item.Tier) and slot and slot.Stage <= stage and not item.Retired then
			table.insert(accs, id)
		end
	end
	local items = {}
	for _, id in pick(parts, TechShop.PartSlots) do
		table.insert(items, { Kind = "Part", Id = id, Price = Parts.Tiers[Parts.Items[id].Tier].Price })
	end
	for _, id in pick(accs, TechShop.AccessorySlots) do
		table.insert(items, { Kind = "Accessory", Id = id, Price = Accessories.TierPrice[Accessories.Items[id].Tier] })
	end
	return items, (window + 1) * TechShop.Refresh
end

local function getStock(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data then
		return false, "NotLoaded"
	end
	if data.Stage < TechShop.Stage then
		return false, "Locked"
	end
	local items, refreshAt = StationService:Stock(data.Stage)
	return true, { Items = items, RefreshAt = refreshAt, Stage = data.Stage }
end

local function buy(player: Player, kind: string, id: string): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data then
		return false, "NotLoaded"
	end
	if data.Stage < TechShop.Stage then
		return false, "Locked"
	end
	local found = nil
	for _, item in (StationService:Stock(data.Stage)) do
		if item.Kind == kind and item.Id == id then
			found = item
			break
		end
	end
	if not found then
		return false, "NotInStock" -- includes a stale stock list after the 10-min refresh
	end
	local paid, err = EconomyService:Transact(player, { Cash = -found.Price }, `TechShop:{id}`)
	if not paid then
		return false, if err == "Insufficient" then { Need = found.Price - data.Currencies.Cash } else err
	end
	if kind == "Part" then
		DataService:Update(player, "Inventory.Parts." .. id, function(v)
			return (v or 0) + 1
		end)
	else
		GearService:Grant(player, id, 1)
	end
	DataService:Update(player, "Collection." .. id, function(v)
		return v or os.time()
	end)
	AnalyticsService:Custom(player, "TechShopBuy", found.Price, { item = id })
	Bus.Fire(player, "TechShopBuy", id)
	return true, id
end

-- Stations ----------------------------------------------------------------------------------------------------------

local function equip(player: Player, slot: string, partId: string): (boolean, any)
	local data = DataService:GetProfile(player)
	local part = Parts.Items[partId]
	if not data or not part then
		return false, "Unknown"
	end
	local station = data.Stations[slot]
	if not station then
		return false, "NoStation"
	end
	if GearService.InMatch(player) then
		return false, "InMatch"
	end
	if (data.Inventory.Parts[partId] or 0) < 1 then
		return false, "NotOwned"
	end
	local old = station.Parts and station.Parts[part.Slot]
	DataService:Update(player, "Inventory.Parts." .. partId, function(v)
		return (v or 0) - 1
	end)
	if old and Parts.Items[old] then
		DataService:Update(player, "Inventory.Parts." .. old, function(v)
			return (v or 0) + 1
		end)
	end
	DataService:Update(player, `Stations.{slot}.Parts`, function(p)
		p = p or {}
		p[part.Slot] = partId
		return p
	end)
	Log.Info("Station", `{player.Name} desk {slot} {part.Slot} ← {partId}`)
	PlotService:Refresh(player)
	Bus.Fire(player, "PartEquipped", partId)
	return true, partId
end

local function unequip(player: Player, slot: string, partSlot: string): (boolean, any)
	local data = DataService:GetProfile(player)
	local station = data and data.Stations[slot]
	local old = station and station.Parts and station.Parts[partSlot]
	if not old then
		return false, "Empty"
	end
	if GearService.InMatch(player) then
		return false, "InMatch"
	end
	DataService:Update(player, `Stations.{slot}.Parts.{partSlot}`, function()
		return nil
	end)
	DataService:Update(player, "Inventory.Parts." .. old, function(v)
		return (v or 0) + 1
	end)
	PlotService:Refresh(player)
	return true, old
end

local function upgrade(player: Player, slot: string): (boolean, any)
	local data = DataService:GetProfile(player)
	local station = data and data.Stations[slot]
	if not station then
		return false, "NoStation"
	end
	if data.Stage < TechShop.Stage then
		return false, "Locked"
	end
	local nextTier = (station.Tier or 1) + 1
	local row = Economy.StationTiers[nextTier]
	if not row then
		return false, "MaxTier"
	end
	local cap = byStage(TechShop.MaxStationTier, data.Stage)
	if nextTier > cap then
		return false, { NeedStage = (function()
			for s = data.Stage + 1, #TechShop.MaxStationTier do
				if TechShop.MaxStationTier[s] >= nextTier then
					return s
				end
			end
			return 99
		end)() }
	end
	local paid, err = EconomyService:Transact(player, { Cash = -row.Price }, `TechShop:StationTier{nextTier}`)
	if not paid then
		return false, if err == "Insufficient" then { Need = row.Price - data.Currencies.Cash } else err
	end
	DataService:Update(player, `Stations.{slot}.Tier`, function()
		return nextTier
	end)
	Log.Info("Station", `{player.Name} desk {slot} → tier {nextTier} (${row.Income}/s base)`)
	PlotService:Refresh(player)
	Bus.Fire(player, "StationUpgraded", nextTier)
	DataService:SaveNow(player, "StationUpgrade")
	return true, nextTier
end

function StationService:Init()
	local slotArg = Remote.T.String(4)
	Remote.Function("Shop", "GetStock", { Mutates = false, Rate = { Count = 2, Per = 1 } }, getStock)
	Remote.Function("Shop", "Buy", { Args = { Remote.T.OneOf({ "Part", "Accessory" }), Remote.T.String(64) }, Rate = { Count = 3, Per = 1 } }, buy)
	Remote.Function("Station", "Equip", { Args = { slotArg, Remote.T.String(64) }, Rate = { Count = 4, Per = 1 } }, equip)
	Remote.Function("Station", "Unequip", { Args = { slotArg, Remote.T.OneOf(Parts.Slots) }, Rate = { Count = 4, Per = 1 } }, unequip)
	Remote.Function("Station", "Upgrade", { Args = { slotArg }, Rate = { Count = 2, Per = 1 } }, upgrade)
end

return StationService

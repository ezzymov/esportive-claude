--!strict
-- GearService ([[Accessories]]): accessory equip/unequip and the gear stats the match sim uses.
--   Accessory/Equip (RF) cardId, itemId → moves one copy from Inventory.Accessories onto the card's slot (the old
--     item goes back). Checks: card in roster, a free copy owned, slot unlocked at your stage, not in a match. 4/s.
--   Accessory/Unequip (RF) cardId, slot → item back to the inventory.
-- GetGearStats(card, stage, mode): Full = stage-capped tier bonuses, max +12 per stat; Pure = nothing (Ranked,
-- the scrim "Pure skill" toggle). Never trusts a client value.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lib = script.Parent.Parent.Lib
local Remote = require(Lib.Remote)
local Log = require(Lib.Log)
local Bus = require(Lib.Bus)
local DataService = require(script.Parent.DataService)
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Accessories = require(ReplicatedStorage.Shared.Config.Accessories)

local GearService = { Tier = 3 }

-- MatchService sets this so gear can't change mid-match (the sim snapshots gear at match start).
GearService.InMatch = function(_player: Player): boolean
	return false
end

function GearService:GetGearStats(card: any, stage: number, mode: string?): { [string]: number }
	if mode == "Pure" then
		return {}
	end
	return Ratings.Gear(card, stage)
end

function GearService:Grant(player: Player, itemId: string, n: number)
	if Accessories.Items[itemId] then
		DataService:Update(player, "Inventory.Accessories." .. itemId, function(v)
			return (v or 0) + n
		end)
	end
end

local function slotUnlocked(data: any, slot: string, card: any): boolean
	local def = Accessories.Slots[slot]
	-- Founder-mouse exception: the Founder's mouse slot works from Stage 1 ([[Accessories]]).
	return def ~= nil and (data.Stage >= def.Stage or (slot == "Mouse" and card.Source == "Founder"))
end

local function equip(player: Player, cardId: string, itemId: string): (boolean, any)
	local data = DataService:GetProfile(player)
	local item = Accessories.Items[itemId]
	if not data or not item then
		return false, "Unknown"
	end
	local card = data.Roster[cardId]
	if not card then
		return false, "NoPlayer"
	end
	if GearService.InMatch(player) then
		return false, "InMatch"
	end
	if not slotUnlocked(data, item.Slot, card) then
		return false, { NeedStage = Accessories.Slots[item.Slot].Stage }
	end
	if (data.Inventory.Accessories[itemId] or 0) < 1 then
		return false, "NotOwned"
	end
	local old = card.Accessories and card.Accessories[item.Slot]
	DataService:Update(player, "Inventory.Accessories." .. itemId, function(v)
		return (v or 0) - 1
	end)
	if old and old ~= "TapedMouse" and Accessories.Items[old] then
		GearService:Grant(player, old, 1)
	end
	DataService:Update(player, `Roster.{cardId}.Accessories`, function(acc)
		acc = acc or {}
		acc[item.Slot] = itemId
		return acc
	end)
	Log.Info("Gear", `{player.Name} equipped {itemId} on {cardId}`)
	Bus.Fire(player, "GearEquipped", itemId)
	return true, itemId
end

local function unequip(player: Player, cardId: string, slot: string): (boolean, any)
	local data = DataService:GetProfile(player)
	local card = data and data.Roster[cardId]
	if not card then
		return false, "NoPlayer"
	end
	if GearService.InMatch(player) then
		return false, "InMatch"
	end
	local old = card.Accessories and card.Accessories[slot]
	if not old then
		return false, "Empty"
	end
	DataService:Update(player, `Roster.{cardId}.Accessories.{slot}`, function()
		return nil
	end)
	if old ~= "TapedMouse" then
		GearService:Grant(player, old, 1)
	end
	return true, old
end

-- Every accessory a card wears goes back to the inventory (release, trade).
function GearService:StripCard(player: Player, cardId: string)
	local data = DataService:GetProfile(player)
	local card = data and data.Roster[cardId]
	if not card then
		return
	end
	for slot in table.clone(card.Accessories or {}) do
		unequip(player, cardId, slot)
	end
end

function GearService:Init()
	Remote.Function("Accessory", "Equip", { Args = { Remote.T.String(64), Remote.T.String(64) }, Rate = { Count = 4, Per = 1 } }, equip)
	Remote.Function("Accessory", "Unequip", { Args = { Remote.T.String(64), Remote.T.OneOf(Accessories.SlotOrder) }, Rate = { Count = 4, Per = 1 } }, unequip)
end

return GearService

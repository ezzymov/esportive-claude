--!strict
-- GearController ([[Accessories]], [[PC Setups]]): Inventory → Parts / Accessories tabs and the gear pickers.
--   Parts: spare parts → Equip → pick a desk (partMult before → after).
--   Accessories: spare accessories → Equip → pick a player (their stat before → after, stage-capped).
--   PickAccessory(cardId, slot): the Roster drawer's Gear slots open this.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Generator = require(ReplicatedStorage.Shared.Generator)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Parts = require(ReplicatedStorage.Shared.Config.Parts)
local Accessories = require(ReplicatedStorage.Shared.Config.Accessories)
local Roles = require(ReplicatedStorage.Shared.Config.Roles)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)

local GearController = { Tier = 6 }

local function stage(): number
	return StateController:Get("Stage") or 1
end

local function cardName(card: any): string
	return if card.Source == "Founder" then "You" else Generator.Name(card)
end

local function toastFail(res: any)
	HudController:Toast(if type(res) == "table" and res.NeedStage then `That slot opens at Stage {res.NeedStage}` elseif res == "InMatch" then "Not during a match." else `Couldn't equip ({tostring(res)})`, Theme.Colors.Warning)
end

-- Small list picker on top of other modals. options = { { Text, Color?, OnPick } }.
function GearController:Choose(title: string, options: { { Text: string, Color: Color3?, OnPick: () -> () } }, empty: string?)
	local overlay = UIController:GetGui("Overlay")
	local modal = Components.Modal(overlay, { Title = title, Width = 0.42, Height = 0.7, ZIndex = 40 })
	local list = New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0, Parent = modal.Body })
	Components.List(list, Theme.Space.S)
	if #options == 0 then
		Components.Paragraph(empty or "Nothing to pick.", Theme.Type.Body, Theme.Colors.TextMuted).Parent = list
	end
	for i, opt in options do
		local b = Components.Button({ Text = opt.Text, Kind = "Secondary", Width = 300, Order = i, OnClick = function()
			modal.Close()
			opt.OnPick()
		end })
		b.Size = UDim2.new(1, -8, 0, 46)
		b.TextSize = Theme.Type.Caption + 2
		b.TextWrapped = true
		if opt.Color then
			b.TextColor3 = opt.Color
		end
		b.Parent = list
	end
end

local function equipAccessory(cardId: string, itemId: string)
	local ok, res = (Net.Get("Accessory", "Equip") :: RemoteFunction):InvokeServer(cardId, itemId)
	if ok then
		Components.Play(Theme.Sounds.Pop, 1.2, 0.5)
	else
		toastFail(res)
	end
end

-- "Aim 41 → 43" for a card if it wore itemId.
local function accessoryDelta(card: any, itemId: string): (string, number)
	local item = Accessories.Items[itemId]
	local before = Ratings.Gear(card, stage())[item.Stat] or 0
	local preview = table.clone(card)
	preview.Accessories = table.clone(card.Accessories or {})
	preview.Accessories[item.Slot] = itemId
	local after = Ratings.Gear(preview, stage())[item.Stat] or 0
	local base = card.Stats[item.Stat] or 0
	return `{Roles.StatNames[item.Stat]} {base + before} → {base + after}`, after - before
end

-- Owned spare accessories for one card's slot.
function GearController:PickAccessory(cardId: string, slot: string)
	local card = StateController:Get("Roster." .. cardId)
	if not card then
		return
	end
	local def = Accessories.Slots[slot]
	if stage() < def.Stage and not (slot == "Mouse" and card.Source == "Founder") then
		HudController:Toast(`{slot} slot opens at Stage {def.Stage}.`, Theme.Colors.Warning)
		return
	end
	local options = {}
	for id, n in StateController:Get("Inventory.Accessories") or {} do
		local item = Accessories.Items[id]
		if n > 0 and item and item.Slot == slot then
			local text, delta = accessoryDelta(card, id)
			table.insert(options, { Text = `{item.Name} ({item.Tier}) ×{n}   {text}`, Color = if delta > 0 then Theme.Colors.Success elseif delta < 0 then Theme.Colors.Danger else nil, OnPick = function()
				equipAccessory(cardId, id)
			end })
		end
	end
	table.sort(options, function(a, b)
		return a.Text < b.Text
	end)
	local current = card.Accessories and card.Accessories[slot]
	if current and current ~= "TapedMouse" then
		table.insert(options, { Text = `Take off {Accessories.Items[current] and Accessories.Items[current].Name or current}`, Color = Theme.Colors.TextMuted, OnPick = function()
			local ok, res = (Net.Get("Accessory", "Unequip") :: RemoteFunction):InvokeServer(cardId, slot)
			if not ok then
				toastFail(res)
			end
		end })
	end
	GearController:Choose(`{def.Icon} {slot} · {cardName(card)}`, options, `No spare {string.lower(slot)}s. The Tech Shop sells them; crates drop them.`)
end

local function grid(parent: Instance): ScrollingFrame
	local g = New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0, Parent = parent })
	New("UIGridLayout", { CellSize = UDim2.fromOffset(Theme.Components.PlayerCard.Width, Theme.Components.PlayerCard.Height + 56), CellPadding = UDim2.fromOffset(Theme.Space.M, Theme.Space.M), SortOrder = Enum.SortOrder.LayoutOrder, Parent = g })
	Components.Padding(g, Theme.Space.XS, Theme.Space.XS)
	return g
end

-- Inventory tab: spare items of one kind with Equip buttons. kind = "Part" | "Accessory".
local function renderItems(parent: Frame, kind: string): () -> ()
	local g = grid(parent)
	local function render()
		for _, c in g:GetChildren() do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		local owned = {}
		for id, n in StateController:Get(if kind == "Part" then "Inventory.Parts" else "Inventory.Accessories") or {} do
			if n > 0 then
				table.insert(owned, id)
			end
		end
		table.sort(owned)
		if #owned == 0 then
			Components.Paragraph(if kind == "Part" then "No spare parts. Equipped parts live on your desks (Shop → Tech Shop)." else "No spare accessories. Equipped ones show on each player's card (Roster).", Theme.Type.Body, Theme.Colors.TextMuted).Parent = g
		end
		for i, id in owned do
			local holder = New("Frame", { BackgroundTransparency = 1, LayoutOrder = i, Parent = g })
			Components.ItemCard(kind, id, 1).Parent = holder
			local n = StateController:Get(`Inventory.{if kind == "Part" then "Parts" else "Accessories"}.{id}`) or 0
			New("TextLabel", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 4), Size = UDim2.fromOffset(40, 18), BackgroundTransparency = 1, FontFace = Theme.Fonts.Bold, TextSize = 13, TextColor3 = Theme.Colors.Text, TextXAlignment = Enum.TextXAlignment.Right, Text = `×{n}`, ZIndex = 4, Parent = holder })
			local b = Components.Button({ Text = "Equip", Width = Theme.Components.PlayerCard.Width, OnClick = function()
				if kind == "Part" then
					GearController:PickDesk(id)
				else
					GearController:PickPlayer(id)
				end
			end })
			b.Position = UDim2.fromOffset(0, Theme.Components.PlayerCard.Height + 4)
			b.Size = UDim2.fromOffset(Theme.Components.PlayerCard.Width, 48)
			b.Parent = holder
		end
	end
	render()
	local stop = StateController:Observe(if kind == "Part" then "Inventory.Parts" else "Inventory.Accessories", function()
		if g.Parent then
			render()
		end
	end)
	return stop
end

function GearController:PickDesk(partId: string)
	local item = Parts.Items[partId]
	local options = {}
	local slots = {}
	for slot in StateController:Get("Stations") or {} do
		table.insert(slots, slot)
	end
	table.sort(slots, function(a, b)
		return (tonumber(a) or 0) < (tonumber(b) or 0)
	end)
	for _, slot in slots do
		local station = StateController:Get("Stations." .. slot)
		local preview = table.clone(station.Parts or {})
		local current = preview[item.Slot] and Parts.Items[preview[item.Slot]]
		preview[item.Slot] = partId
		local before, after = Ratings.PartMult(station), Ratings.PartMult({ Parts = preview })
		local card = StateController:Get("Roster." .. station.PlayerId)
		table.insert(options, {
			Text = string.format("Desk %s · %s · %s → %+.1f%%%s", slot, if card then cardName(card) else "empty", string.format("%+.1f%%", before * 100), after * 100, if current then ` (swaps out {current.Name})` else ""),
			Color = if after > before then Theme.Colors.Success elseif after < before then Theme.Colors.Danger else nil,
			OnPick = function()
				local ok, res = (Net.Get("Station", "Equip") :: RemoteFunction):InvokeServer(slot, partId)
				if ok then
					Components.Play(Theme.Sounds.Pop, 1.2, 0.5)
				else
					toastFail(res)
				end
			end,
		})
	end
	GearController:Choose(`{Parts.Icons[item.Slot]} {item.Name} → which desk?`, options)
end

function GearController:PickPlayer(itemId: string)
	local item = Accessories.Items[itemId]
	local options = {}
	for id, card in StateController:Get("Roster") or {} do
		local text, delta = accessoryDelta(card, itemId)
		table.insert(options, { Text = `{cardName(card)} · {text}`, Color = if delta > 0 then Theme.Colors.Success elseif delta < 0 then Theme.Colors.Danger else nil, OnPick = function()
			equipAccessory(id, itemId)
		end })
	end
	table.sort(options, function(a, b)
		return a.Text < b.Text
	end)
	GearController:Choose(`{Accessories.Slots[item.Slot].Icon} {item.Name} → who wears it?`, options)
end

function GearController:RenderParts(parent: Frame): () -> ()
	return renderItems(parent, "Part")
end

function GearController:RenderAccessories(parent: Frame): () -> ()
	return renderItems(parent, "Accessory")
end

return GearController

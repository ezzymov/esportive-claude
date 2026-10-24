--!strict
-- TechShopController ([[Screen - Tech Shop]], [[PC Setups]], [[Accessories]]): rendered in the Shop's Tech tab.
--   Left: this window's stock (parts + plain accessories) as item cards with Buy buttons ("$X more" when short);
--     accessories above your stage cap say "Full bonus at Stage N". "New stock in 12:34".
--   Right: your desks: income tier + Upgrade, the five part slots with partMult, and parts you own to equip there
--     with the change it makes ("+0.9% → +2.1%").
-- Also binds the café counter prompt (opens the Shop on this tab).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local Format = require(ReplicatedStorage.Shared.Format)
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Generator = require(ReplicatedStorage.Shared.Generator)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Parts = require(ReplicatedStorage.Shared.Config.Parts)
local Accessories = require(ReplicatedStorage.Shared.Config.Accessories)
local Economy = require(ReplicatedStorage.Shared.Config.Economy)
local TechShop = require(ReplicatedStorage.Shared.Config.TechShop)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local StateController = require(script.Parent.StateController)
local HudController = require(script.Parent.HudController)

local TechShopController = { Tier = 6 }

local function pct(x: number): string
	return string.format("+%.1f%%", x * 100)
end

-- "Desk 2 · rook1e" / "Desk 1 · You".
function TechShopController:DeskLabel(slot: string): string
	local station = StateController:Get("Stations." .. slot)
	local card = station and StateController:Get("Roster." .. station.PlayerId)
	local who = if card then (if card.Source == "Founder" then "You" else Generator.Name(card)) else "empty"
	return `Desk {slot} · {who}`
end

local function sortedSlots(): { string }
	local slots = {}
	for slot in StateController:Get("Stations") or {} do
		table.insert(slots, slot)
	end
	table.sort(slots, function(a, b)
		return (tonumber(a) or 0) < (tonumber(b) or 0)
	end)
	return slots
end

local function failText(res: any): string
	return if type(res) == "table" and res.Need then `Need {Format.Cash(res.Need)} more`
		elseif type(res) == "table" and res.NeedStage then `Unlocks at Stage {res.NeedStage}`
		elseif res == "NotInStock" then "Sold out: the stock just changed."
		else `Couldn't do that ({tostring(res)})`
end

function TechShopController:Render(parent: Frame): () -> ()
	local stops: { () -> () } = {}
	local alive = true
	local mobile = Components.IsMobile()
	local stage = StateController:Get("Stage") or 1
	if stage < TechShop.Stage then
		Components.Paragraph(`The Tech Shop opens at Stage {TechShop.Stage}.`, Theme.Type.Body, Theme.Colors.TextMuted).Parent = parent
		return function() end
	end
	local left = New("ScrollingFrame", { BackgroundTransparency = 1, Size = if mobile then UDim2.fromScale(1, 0.5) else UDim2.fromScale(0.6, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0, Parent = parent })
	Components.List(left, Theme.Space.S)
	local timer = Components.Paragraph("Loading stock…", Theme.Type.Body, Theme.Colors.TextMuted)
	timer.LayoutOrder = 0
	timer.Parent = left
	local grid = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = left })
	New("UIGridLayout", { CellSize = UDim2.fromOffset(Theme.Components.PlayerCard.Width, Theme.Components.PlayerCard.Height + 56), CellPadding = UDim2.fromOffset(Theme.Space.M, Theme.Space.M), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
	local right = New("ScrollingFrame", {
		BackgroundColor3 = Theme.Colors.Panel,
		Position = if mobile then UDim2.fromScale(0, 0.52) else UDim2.fromScale(0.62, 0),
		Size = if mobile then UDim2.fromScale(1, 0.48) else UDim2.fromScale(0.38, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		BorderSizePixel = 0,
		Parent = parent,
	})
	Components.Corner(right, Theme.Radius.M)
	Components.Padding(right, Theme.Space.M, Theme.Space.M)
	local desksBody = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -14, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = right })

	local refreshAt = 0
	local affordables: { () -> () } = {} -- stock buttons
	local deskAfford: { () -> () } = {} -- upgrade buttons
	local selectedDesk = "1"

	local function renderStock()
		local ok, stock = (Net.Get("Shop", "GetStock") :: RemoteFunction):InvokeServer()
		if not alive then
			return
		end
		for _, c in grid:GetChildren() do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		table.clear(affordables)
		if not ok then
			timer.Text = "The Tech Shop is closed right now."
			return
		end
		refreshAt = stock.RefreshAt
		for i, item in stock.Items do
			local holder = New("Frame", { BackgroundTransparency = 1, LayoutOrder = i, Parent = grid })
			Components.ItemCard(item.Kind, item.Id, 1).Parent = holder
			if item.Kind == "Accessory" then
				local def = Accessories.Items[item.Id]
				if def and Ratings.CappedTier(def.Tier, stage) ~= def.Tier then
					local needStage = 0
					for s = stage + 1, #Accessories.StageCap do
						if Ratings.CappedTier(def.Tier, s) == def.Tier then
							needStage = s
							break
						end
					end
					local warn = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -8), Size = UDim2.fromOffset(130, 20), BackgroundColor3 = Theme.Colors.Warning, FontFace = Theme.Fonts.Bold, TextSize = 11, TextColor3 = Theme.Colors.Bg, Text = `Full bonus at Stage {needStage}`, ZIndex = 4, Parent = holder })
					Components.Corner(warn, Theme.Radius.S)
				end
				local owned = (StateController:Get("Inventory.Accessories." .. item.Id) or 0)
				if owned > 0 then
					New("TextLabel", { Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(46, 18), BackgroundTransparency = 1, FontFace = Theme.Fonts.Bold, TextSize = 12, TextColor3 = Theme.Colors.Text, Text = `own {owned}`, ZIndex = 4, Parent = holder })
				end
			end
			local busy = false
			local b, setEnabled = Components.Button({ Text = Format.Cash(item.Price), Width = Theme.Components.PlayerCard.Width, Color = Theme.Colors.Success, OnClick = function()
				if busy then
					return
				end
				busy = true
				local bought, res = (Net.Get("Shop", "Buy") :: RemoteFunction):InvokeServer(item.Kind, item.Id)
				busy = false
				if bought then
					Components.Play(Theme.Sounds.Buy, 1.3, 0.5)
					HudController:Toast(if item.Kind == "Part" then "Bought! Equip it on a desk →" else "Bought! Equip it from Roster → player → Gear.", Theme.Colors.Success)
				else
					HudController:Toast(failText(res), Theme.Colors.Warning)
					if res == "NotInStock" then
						task.spawn(renderStock)
					end
				end
			end })
			b.Position = UDim2.fromOffset(0, Theme.Components.PlayerCard.Height + 4)
			b.Size = UDim2.fromOffset(Theme.Components.PlayerCard.Width, 48)
			b.Parent = holder
			local function afford()
				local cash = StateController:Get("Currencies.Cash") or 0
				setEnabled(cash >= item.Price)
				b.Text = if cash >= item.Price then Format.Cash(item.Price) else `{Format.Cash(item.Price - cash)} more`
			end
			afford()
			table.insert(affordables, afford)
		end
	end

	local renderDesks: () -> ()
	renderDesks = function()
		table.clear(deskAfford)
		desksBody:ClearAllChildren()
		Components.List(desksBody, Theme.Space.S)
		local o = 0
		local function add(inst: GuiObject)
			o += 1
			inst.LayoutOrder = o
			inst.Parent = desksBody
		end
		local title = Components.Paragraph("Your desks", Theme.Type.H2, Theme.Colors.Text)
		title.FontFace = Theme.Fonts.Heading
		add(title)
		local cap = TechShop.MaxStationTier[math.clamp(stage, 1, #TechShop.MaxStationTier)]
		for _, slot in sortedSlots() do
			local station = StateController:Get("Stations." .. slot)
			local tier = station.Tier or 1
			local card = StateController:Get("Roster." .. station.PlayerId)
			local income = if card then Ratings.StationIncome(card, tier) else 0
			local row = New("TextButton", { Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = if slot == selectedDesk then Theme.Colors.Bg else Theme.Colors.Panel, Text = "", AutoButtonColor = false })
			Components.Corner(row, Theme.Radius.M)
			local edge = Components.Stroke(row, if slot == selectedDesk then Theme.Colors.Accent else Theme.Colors.TextMuted)
			edge.Transparency = if slot == selectedDesk then 0 else 0.7
			New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -170, 0, 24), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = TechShopController:DeskLabel(slot), Parent = row })
			New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 32), Size = UDim2.new(1, -170, 0, 22), FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Caption + 1, TextColor3 = Theme.Colors.TextMuted, TextXAlignment = Enum.TextXAlignment.Left, Text = string.format("Tier %d · $%.2f/s · parts %s", tier, income, pct(Ratings.PartMult(station))), Parent = row })
			row.Activated:Connect(function()
				selectedDesk = slot
				renderDesks()
			end)
			local nextRow = Economy.StationTiers[tier + 1]
			local upgrade, setUp = Components.Button({ Text = if not nextRow then "Max tier" elseif tier + 1 > cap then `Tier {tier + 1} · later` else `Tier {tier + 1} · {Format.Cash(nextRow.Price)}`, Kind = "Secondary", Width = 150, OnClick = function()
				local done, res = (Net.Get("Station", "Upgrade") :: RemoteFunction):InvokeServer(slot)
				if done then
					Components.Play(Theme.Sounds.Buy, 1.3, 0.5)
					HudController:Toast(`Desk {slot} → tier {res}: ${Economy.StationTiers[res].Income}/s base`, Theme.Colors.Success)
				else
					HudController:Toast(failText(res), Theme.Colors.Warning)
				end
			end })
			upgrade.AnchorPoint = Vector2.new(1, 0.5)
			upgrade.Position = UDim2.new(1, -8, 0.5, 0)
			upgrade.Size = UDim2.fromOffset(150, 40)
			upgrade.TextSize = Theme.Type.Caption + 2
			upgrade.Parent = row
			local function canUpgrade()
				setUp(nextRow ~= nil and tier + 1 <= cap and (StateController:Get("Currencies.Cash") or 0) >= nextRow.Price)
			end
			canUpgrade()
			table.insert(deskAfford, canUpgrade)
			add(row)
		end

		-- Selected desk: slots + parts you own for it.
		local station = StateController:Get("Stations." .. selectedDesk)
		if not station then
			return
		end
		local head = Components.Paragraph(`{TechShopController:DeskLabel(selectedDesk)} · parts {pct(Ratings.PartMult(station))}`, Theme.Type.Body, Theme.Colors.Accent)
		head.FontFace = Theme.Fonts.Bold
		add(head)
		for _, partSlot in Parts.Slots do
			local id = station.Parts and station.Parts[partSlot]
			local item = id and Parts.Items[id]
			local line = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30) })
			New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -90, 1, 0), FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Caption + 2, TextColor3 = if item then Theme.Rarity[Parts.Tiers[item.Tier].Rarity] else Theme.Colors.TextMuted, TextXAlignment = Enum.TextXAlignment.Left, Text = `{Parts.Icons[partSlot]} {partSlot}: {if item then item.Name else "Dusty Starter"}`, Parent = line })
			if item then
				local off = Components.Button({ Text = "Remove", Kind = "Secondary", Width = 84, OnClick = function()
					local done, res = (Net.Get("Station", "Unequip") :: RemoteFunction):InvokeServer(selectedDesk, partSlot)
					if not done then
						HudController:Toast(failText(res), Theme.Colors.Warning)
					end
				end })
				off.AnchorPoint = Vector2.new(1, 0.5)
				off.Position = UDim2.new(1, 0, 0.5, 0)
				off.Size = UDim2.fromOffset(84, 28)
				off.TextSize = Theme.Type.Caption
				off.Parent = line
			end
			add(line)
		end
		local owned = {}
		for id, n in StateController:Get("Inventory.Parts") or {} do
			if n > 0 and Parts.Items[id] then
				table.insert(owned, id)
			end
		end
		table.sort(owned)
		local sub = Components.Paragraph(if #owned > 0 then "Your parts (tap to equip on this desk):" else "No spare parts. Buy some on the left or open crates.", Theme.Type.Caption + 1, Theme.Colors.TextMuted)
		add(sub)
		for _, id in owned do
			local item = Parts.Items[id]
			local preview = table.clone(station.Parts or {})
			preview[item.Slot] = id
			local before, after = Ratings.PartMult(station), Ratings.PartMult({ Parts = preview })
			local delta = after - before
			local b = Components.Button({ Text = `{Parts.Icons[item.Slot]} {item.Name} ×{StateController:Get("Inventory.Parts." .. id)}   {pct(before)} → {pct(after)}`, Kind = "Secondary", Width = 300, OnClick = function()
				local done, res = (Net.Get("Station", "Equip") :: RemoteFunction):InvokeServer(selectedDesk, id)
				if done then
					Components.Play(Theme.Sounds.Pop, 1.2, 0.5)
				else
					HudController:Toast(failText(res), Theme.Colors.Warning)
				end
			end })
			b.Size = UDim2.new(1, 0, 0, 40)
			b.TextSize = Theme.Type.Caption + 1
			b.TextColor3 = if delta > 0 then Theme.Colors.Success elseif delta < 0 then Theme.Colors.Danger else Theme.Colors.Text
			add(b)
		end
	end

	task.spawn(renderStock)
	renderDesks()
	for _, path in { "Stations", "Inventory.Parts", "Roster" } do
		table.insert(stops, StateController:Observe(path, function()
			if alive then
				renderDesks()
			end
		end))
	end
	table.insert(stops, StateController:Observe("Currencies", function()
		for _, f in affordables do
			f()
		end
		for _, f in deskAfford do
			f()
		end
	end))
	task.spawn(function()
		while alive and parent.Parent do
			local left = refreshAt - os.time()
			if refreshAt > 0 then
				timer.Text = `New stock in {Components.Clock(left)}`
				if left <= 0 then
					refreshAt = 0
					renderStock()
				end
			end
			task.wait(1)
		end
	end)
	return function()
		alive = false
		for _, s in stops do
			s()
		end
	end
end

return TechShopController

--!strict
-- RosterController ([[Screen - Roster]], [[Player Hiring]], [[Founder (You)]]).
--   Roster rail button (appears with the first hire) and the cork-board prompt open the Roster screen.
--   Tabs: Players (cards + detail drawer with stat bars, Potential ghost bar, gear) · Free Agents (Roster/Hire).
--   Founder card reveal after Power On, stat-bump popup when the Founder improves, hire walk-in camera (≤ 4 s).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Net = require(ReplicatedStorage.Shared.Net)
local Format = require(ReplicatedStorage.Shared.Format)
local Generator = require(ReplicatedStorage.Shared.Generator)
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Roles = require(ReplicatedStorage.Shared.Config.Roles)
local Traits = require(ReplicatedStorage.Shared.Config.Traits)
local Match = require(ReplicatedStorage.Shared.Config.Match)
local Accessories = require(ReplicatedStorage.Shared.Config.Accessories)
local Hiring = require(ReplicatedStorage.Shared.Config.Hiring)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local MyPlot = require(script.Parent.Parent.UI.MyPlot)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)
local GearController = require(script.Parent.GearController)

local RosterController = { Tier = 4 }

local player = Players.LocalPlayer
local screenOpen = false

-- PlayerCard + display name for UI.
function RosterController:View(card: any): any
	local v = table.clone(card)
	v.Name = if card.Source == "Founder" then player.DisplayName else Generator.Name(card)
	return v
end

local function roster(): { any }
	local list = {}
	for _, card in StateController:Get("Roster") or {} do
		table.insert(list, RosterController:View(card))
	end
	table.sort(list, function(a, b)
		if (a.Source == "Founder") ~= (b.Source == "Founder") then
			return a.Source == "Founder" -- Founder always first
		end
		return Ratings.Ovr(a) > Ratings.Ovr(b)
	end)
	return list
end

local function stationOf(cardId: string): string?
	for slot, s in StateController:Get("Stations") or {} do
		if s.PlayerId == cardId then
			return slot
		end
	end
	return nil
end

local function failToast(res: any)
	HudController:Toast(if res == "InMatch" then "Not during a match." elseif res == "Founder" or res == "FounderDesk" then "Desk 1 is yours." else `Couldn't do that ({tostring(res)})`, Theme.Colors.Warning)
end

local function detail(parent: Instance, view: any, owned: boolean?)
	parent:ClearAllChildren()
	Components.List(parent, Theme.Space.XS)
	local stage = StateController:Get("Stage") or 1
	local ovr = Ratings.Ovr(view)
	New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.H2, TextColor3 = Theme.Rarity[view.Rarity] or Theme.Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = `{view.Name} · OVR {ovr}`, LayoutOrder = 1, Parent = parent })
	local bio = Components.Paragraph(if view.Source == "Founder" then "You. The first player on your team. Grows from what you actually do." else Generator.Bio(view), Theme.Type.Caption + 1, Theme.Colors.TextMuted)
	bio.LayoutOrder = 2
	bio.Parent = parent
	local gear = Ratings.Gear(view, stage)
	for i, stat in Roles.Stats do
		local row = Components.StatRow(stat, view.Stats[stat] or 0, view.Potential or 0, gear[stat])
		row.LayoutOrder = 10 + i
		row.Parent = parent
	end
	local trait = view.Trait and Traits[view.Trait]
	local morale, fatigue = Ratings.Condition(view, os.time())
	local seat = stationOf(view.Id)
	local lines = {
		`Potential: {if view.Source == "Founder" then tostring(view.Potential) else "★★★☆☆ (scout to reveal)"}`,
		`Trait: {if trait then trait.Name .. " — " .. trait.Desc else "none"}`,
		`Station: {if not owned then "free agent" elseif seat then "Desk " .. seat .. (if (tonumber(seat) or 99) <= 5 then " · active five" else "") else "bench"}`,
		string.format("Morale %d · Fatigue %d%s", morale, fatigue, if fatigue > Match.Fatigue.Threshold then " (tired: -10% in matches)" else ""),
		if view.Source == "Founder" then "Salary: none (you're the owner) · can't be traded or released" else "Salary: from Stage 5",
	}
	for i, text in lines do
		local p = Components.Paragraph(text, Theme.Type.Caption + 1, Theme.Colors.Text)
		p.LayoutOrder = 20 + i
		p.Parent = parent
	end

	if not owned then
		return -- free-agent listing: no gear or lineup actions
	end
	-- Gear ([[Accessories]]): six slots, tap to change. Bonuses count up to your stage's tier cap.
	local gearHead = Components.Paragraph(`Gear (counts up to {Accessories.StageCap[math.clamp(stage, 1, #Accessories.StageCap)]} at Stage {stage}, max +{Accessories.GearCapPerStat} per stat)`, Theme.Type.Caption + 1, Theme.Colors.Accent)
	gearHead.FontFace = Theme.Fonts.Bold
	gearHead.LayoutOrder = 40
	gearHead.Parent = parent
	for i, slot in Accessories.SlotOrder do
		local def = Accessories.Slots[slot]
		local itemId = view.Accessories and view.Accessories[slot]
		local item = itemId and Accessories.Items[itemId]
		local locked = stage < def.Stage and not (slot == "Mouse" and view.Source == "Founder")
		local text = if locked then `{def.Icon} {slot}: 🔒 Stage {def.Stage}`
			elseif item then `{def.Icon} {slot}: {item.Name} (+{Accessories.TierBonus[Ratings.CappedTier(item.Tier, stage)] or 0} {Roles.StatNames[item.Stat]})`
			else `{def.Icon} {slot}: empty`
		local b = Components.Button({ Text = text, Kind = "Secondary", Width = 300, Order = 40 + i, OnClick = function()
			GearController:PickAccessory(view.Id, slot)
		end })
		b.Size = UDim2.new(1, 0, 0, 36)
		b.TextSize = Theme.Type.Caption + 1
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.TextColor3 = if item then Theme.Rarity[if item.Tier == "Starter" then "Common" else item.Tier] or Theme.Colors.Text else Theme.Colors.TextMuted
		Components.Padding(b, Theme.Space.M, 0)
		b.Parent = parent
	end

	if view.Source == "Founder" then
		return
	end
	-- Lineup ([[Screen - Roster]] → Swap): seat this player at a desk; whoever sat there goes to the bench.
	local swap = Components.Button({ Text = if seat then "Move to another desk" else "Put in the lineup", Width = 300, Order = 60, OnClick = function()
		local options = {}
		local slots = {}
		for s in StateController:Get("Stations") or {} do
			if s ~= "1" and s ~= seat then
				table.insert(slots, s)
			end
		end
		table.sort(slots, function(a, b)
			return (tonumber(a) or 0) < (tonumber(b) or 0)
		end)
		for _, s in slots do
			local occ = StateController:Get("Roster." .. (StateController:Get(`Stations.{s}.PlayerId`) or ""))
			table.insert(options, { Text = `Desk {s}{if occ then " · swap with " .. RosterController:View(occ).Name .. " (OVR " .. Ratings.Ovr(occ) .. ")" else " · empty"}`, OnPick = function()
				local ok, res = (Net.Get("Roster", "Lineup") :: RemoteFunction):InvokeServer(view.Id, s)
				if not ok then
					failToast(res)
				end
			end })
		end
		GearController:Choose(`Seat {view.Name}`, options, "Buy another desk first.")
	end })
	swap.Size = UDim2.new(1, 0, 0, 44)
	swap.Parent = parent
	local release = Components.Button({ Text = "Release", Kind = "Danger", Width = 300, Order = 61, OnClick = function()
		GearController:Choose(`Release {view.Name}?`, {
			{ Text = `Yes, release {view.Name} (gear goes back to your inventory)`, Color = Theme.Colors.Danger, OnPick = function()
				local ok, res = (Net.Get("Roster", "Release") :: RemoteFunction):InvokeServer(view.Id)
				if ok then
					HudController:Toast(`{view.Name} left the team.`, Theme.Colors.TextMuted)
				else
					failToast(res)
				end
			end },
			{ Text = "Keep them", OnPick = function() end },
		})
	end })
	release.Size = UDim2.new(1, 0, 0, 40)
	release.Parent = parent
end

local function grid(parent: Instance): Frame
	local g = New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0, Parent = parent })
	New("UIGridLayout", { CellSize = UDim2.fromOffset(Theme.Components.PlayerCard.Width, Theme.Components.PlayerCard.Height + 56), CellPadding = UDim2.fromOffset(Theme.Space.M, Theme.Space.M), SortOrder = Enum.SortOrder.LayoutOrder, Parent = g })
	Components.Padding(g, Theme.Space.XS, Theme.Space.XS)
	return g
end

function RosterController:Open(tab: string?)
	if screenOpen then
		return
	end
	screenOpen = true
	UIController:SetMenu("Roster", true)
	local overlay = UIController:GetGui("Overlay")
	local stops: { () -> () } = {}
	local modal = Components.Modal(overlay, { Title = "Roster", Width = 0.8, Height = 0.85, OnClose = function()
		screenOpen = false
		for _, s in stops do
			s()
		end
		UIController:RegisterTarget("HireButton", nil)
		UIController:SetMenu("Roster", false)
	end })
	local body = modal.Body
	local mobile = Components.IsMobile()
	local header = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), Parent = body })
	Components.List(header, Theme.Space.S, true)
	local power = New("TextLabel", { AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Size = UDim2.fromOffset(320, 44), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.TextMuted, TextXAlignment = Enum.TextXAlignment.Right, LayoutOrder = 10, Parent = header })
	local content = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 1, -56), Parent = body })
	local left = New("Frame", { BackgroundTransparency = 1, Size = if mobile then UDim2.fromScale(1, 0.55) else UDim2.fromScale(0.58, 1), Parent = content })
	local drawer = New("ScrollingFrame", {
		BackgroundColor3 = Theme.Colors.Panel,
		Position = if mobile then UDim2.fromScale(0, 0.57) else UDim2.fromScale(0.6, 0),
		Size = if mobile then UDim2.fromScale(1, 0.43) else UDim2.fromScale(0.4, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		BorderSizePixel = 0,
		Parent = content,
	})
	Components.Corner(drawer, Theme.Radius.M)
	Components.Padding(drawer, Theme.Space.M, Theme.Space.M)
	local drawerBody = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -14, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = drawer })

	local tabButtons: { [string]: TextButton } = {}
	local current = tab or "Players"
	local render: (string) -> ()

	local selectedId: string? = nil
	local function renderPlayers()
		local g = grid(left)
		local list = roster()
		local stage = StateController:Get("Stage") or 1
		local now = os.time()
		local total, roles = 0, {}
		local selectedView = nil
		for i, view in list do
			local seat = stationOf(view.Id)
			local active = seat ~= nil and (tonumber(seat) or 99) <= 5
			if active then
				-- Same numbers the match sim starts from (Full mode, before traits/maps/chemistry).
				local morale, fatigue = Ratings.Condition(view, now)
				local station = StateController:Get("Stations." .. seat)
				total += Ratings.PlayerPower(view, Match.TitleWeights, morale, { Gear = Ratings.Gear(view, stage), PartMult = Ratings.PartMult(station), Fatigue = fatigue })
				roles[view.Role] = true
			end
			if view.Id == selectedId then
				selectedView = view
			end
			local holder = New("Frame", { BackgroundTransparency = 1, LayoutOrder = i, Parent = g })
			local card = Components.PlayerCard(view)
			card.Parent = holder
			local tag = New("TextLabel", { Position = UDim2.fromOffset(0, Theme.Components.PlayerCard.Height + 4), Size = UDim2.fromOffset(Theme.Components.PlayerCard.Width, 22), BackgroundColor3 = if active then Theme.Colors.Success else Theme.Colors.Panel, FontFace = Theme.Fonts.Bold, TextSize = 13, TextColor3 = if active then Theme.Colors.Bg else Theme.Colors.TextMuted, Text = if active then `ACTIVE · Desk {seat}` else "BENCH", Parent = holder })
			Components.Corner(tag, Theme.Radius.S)
			local tap = New("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5, Parent = card })
			tap.Activated:Connect(function()
				selectedId = view.Id
				detail(drawerBody, view, true)
			end)
		end
		local icons = {}
		for _, role in Roles.Order do
			table.insert(icons, if roles[role] then `<font color="#34D399">{string.sub(role, 1, 3)}</font>` else string.sub(role, 1, 3))
		end
		local n = 0
		for _ in StateController:Get("Roster") or {} do
			n += 1
		end
		local max = Hiring.RosterMax[math.clamp(stage, 1, #Hiring.RosterMax)]
		power.RichText = true
		power.Text = `Team Power {math.floor(total)}  ·  {table.concat(icons, " ")}  ·  {n}/{max}`
		local show = selectedView or list[1]
		if show then
			selectedId = show.Id
			detail(drawerBody, show, true)
		end
	end

	local function renderFreeAgents()
		local g = grid(left)
		power.Text = "Loading…"
		local ok, info = (Net.Get("Roster", "GetFreeAgents") :: RemoteFunction):InvokeServer()
		if not ok or not info.Unlocked then
			g:ClearAllChildren()
			local p = Components.Paragraph("The free-agent board opens once you have a 2nd desk.", Theme.Type.Body, Theme.Colors.TextMuted)
			p.Parent = g
			power.Text = ""
			return
		end
		power.Text = `Free desks: {info.FreeDesks}  ·  new flyers every 10 min`
		for i, listing in info.Listings do
			local view = RosterController:View(listing.Card)
			local holder = New("Frame", { BackgroundTransparency = 1, LayoutOrder = i, Parent = g })
			local card = Components.PlayerCard(view)
			card.Parent = holder
			if listing.Featured then
				local star = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(100, 22), BackgroundColor3 = Theme.Colors.Warning, FontFace = Theme.Fonts.Heading, TextSize = 13, TextColor3 = Theme.Colors.Bg, Text = "★ FEATURED", ZIndex = 4, Parent = card })
				Components.Corner(star, Theme.Radius.S)
			end
			local tapCard = New("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 3, Parent = card })
			tapCard.Activated:Connect(function()
				detail(drawerBody, view)
			end)
			local busy = false
			local hireBtn, setEnabled = Components.Button({ Text = `Hire {Format.Cash(listing.Price)}`, Width = Theme.Components.PlayerCard.Width, Color = Theme.Colors.Success })
			hireBtn.Position = UDim2.fromOffset(0, Theme.Components.PlayerCard.Height + 4)
			hireBtn.Size = UDim2.fromOffset(Theme.Components.PlayerCard.Width, 48)
			hireBtn.TextSize = Theme.Type.Body
			hireBtn.Parent = holder
			local function afford()
				setEnabled((StateController:Get("Currencies.Cash") or 0) >= listing.Price and info.FreeDesks > 0)
			end
			table.insert(stops, StateController:Observe("Currencies.Cash", afford))
			if listing.Featured or i == 1 then
				UIController:RegisterTarget("HireButton", hireBtn)
			end
			hireBtn.Activated:Connect(function()
				if busy then
					return
				end
				if info.FreeDesks <= 0 then
					HudController:Toast("Buy a desk first.", Theme.Colors.Warning)
					return
				end
				busy = true
				local hired, result = (Net.Get("Roster", "Hire") :: RemoteFunction):InvokeServer(listing.Id)
				busy = false
				if hired then
					modal.Close()
				elseif type(result) == "table" and result.Need then
					HudController:Toast(`Need {Format.Cash(result.Need)} more`, Theme.Colors.Warning)
				else
					HudController:Toast(`Couldn't hire ({tostring(result)})`, Theme.Colors.Danger)
					render("FreeAgents")
				end
			end)
		end
		if info.Listings[1] then
			detail(drawerBody, RosterController:View(info.Listings[1].Card))
		end
	end

	render = function(id: string)
		current = id
		for k, b in tabButtons do
			b.BackgroundColor3 = if k == id then Theme.Colors.Accent else Theme.Colors.Panel
			b.TextColor3 = if k == id then Theme.Colors.Bg else Theme.Colors.Text
		end
		left:ClearAllChildren()
		drawerBody:ClearAllChildren()
		UIController:RegisterTarget("HireButton", nil)
		if id == "Players" then
			renderPlayers()
		else
			renderFreeAgents()
		end
	end
	for i, id in { "Players", "FreeAgents" } do
		local b = New("TextButton", { Size = UDim2.fromOffset(150, 44), Text = if id == "FreeAgents" then "Free Agents" else id, FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, LayoutOrder = i, AutoButtonColor = false, Parent = header })
		Components.Corner(b, Theme.Radius.M)
		tabButtons[id] = b
		b.Activated:Connect(function()
			render(id)
		end)
	end
	render(current)
	-- Lineup, gear and release change the roster while the screen is open: redraw the Players tab.
	for _, path in { "Roster", "Stations" } do
		table.insert(stops, StateController:Observe(path, function()
			if screenOpen and current == "Players" then
				render("Players")
			end
		end))
	end
end

-- Big Founder card after Power On ("You · OVR 30").
function RosterController:RevealFounder()
	local founderId = StateController:Get("FounderUuid")
	local deadline = os.clock() + 5
	while (not founderId or founderId == "" or not StateController:Get("Roster." .. founderId)) and os.clock() < deadline do
		task.wait(0.1)
		founderId = StateController:Get("FounderUuid")
	end
	local card = founderId and StateController:Get("Roster." .. founderId)
	if not card then
		return
	end
	UIController:SetMenu("FounderReveal", true)
	local overlay = UIController:GetGui("Overlay")
	local modal = Components.Modal(overlay, { Title = "Your Founder card", Width = 0.45, Height = 0.78, OnClose = function()
		UIController:SetMenu("FounderReveal", false)
	end })
	local view = RosterController:View(card)
	local big = Components.PlayerCard(view, 1.5)
	big.AnchorPoint = Vector2.new(0.5, 0)
	big.Position = UDim2.fromScale(0.5, 0)
	big.Parent = modal.Body
	local scale = New("UIScale", { Scale = 0.3, Parent = big })
	TweenService:Create(scale, TweenInfo.new(0.5, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	local text = Components.Paragraph(`You · OVR {Ratings.Ovr(view)} · {view.Role}. You're the first player on {StateController:Get("Team.Name") or "your team"}. Your desk earns while you sit at it.`, Theme.Type.Body, Theme.Colors.Text)
	text.Position = UDim2.new(0, 0, 0, Theme.Components.PlayerCard.Height * 1.5 + Theme.Space.L)
	text.TextXAlignment = Enum.TextXAlignment.Center
	text.Parent = modal.Body
	local ok = Components.Button({ Text = "Let's go", Width = 200, OnClick = modal.Close })
	ok.AnchorPoint = Vector2.new(0.5, 1)
	ok.Position = UDim2.fromScale(0.5, 1)
	ok.Parent = modal.Body
end

-- Small card popup when the Founder's stats or gear go up ("card shows +Aim").
local function watchFounder()
	local last: { [string]: number } = {}
	local lastGear: { [string]: number } = {}
	local primed = false
	StateController:Observe("Roster", function()
		local id = StateController:Get("FounderUuid")
		local card = id and id ~= "" and StateController:Get("Roster." .. id)
		if not card then
			return
		end
		local gear = Ratings.Gear(card)
		local gains = {}
		for _, stat in Roles.Stats do
			local v, g = card.Stats[stat] or 0, gear[stat] or 0
			if primed then
				if v > (last[stat] or v) then
					table.insert(gains, `+{v - (last[stat] or v)} {Roles.StatNames[stat]}`)
				end
				if g > (lastGear[stat] or 0) then
					table.insert(gains, `+{g - (lastGear[stat] or 0)} {Roles.StatNames[stat]} (gear)`)
				end
			end
			last[stat], lastGear[stat] = v, g
		end
		primed = true
		if #gains == 0 then
			return
		end
		local overlay = UIController:GetGui("Overlay")
		local pop = New("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, -260, 0.55, 0), Size = UDim2.fromOffset(Theme.Components.PlayerCard.Width + 24, Theme.Components.PlayerCard.Height + 64), BackgroundTransparency = 1, ZIndex = 25, Parent = overlay })
		local c = Components.PlayerCard(RosterController:View(card))
		c.Parent = pop
		New("TextLabel", { Position = UDim2.fromOffset(0, Theme.Components.PlayerCard.Height + 6), Size = UDim2.fromOffset(Theme.Components.PlayerCard.Width + 24, 52), BackgroundTransparency = 1, TextWrapped = true, FontFace = Theme.Fonts.Heading, TextSize = 18, TextColor3 = Theme.Colors.Success, Text = table.concat(gains, "\n"), Parent = pop }, { New("UIStroke", { Thickness = 2, Color = Theme.Colors.Bg }) })
		TweenService:Create(pop, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Position = UDim2.new(0, Theme.Space.L + 140, 0.55, 0) }):Play()
		task.delay(3.2, function()
			TweenService:Create(pop, TweenInfo.new(0.2), { Position = UDim2.new(0, -260, 0.55, 0) }):Play()
			task.wait(0.2)
			pop:Destroy()
		end)
	end)
end

-- Hire mini-scene: camera on the new player walking in (≤ 4 s, never longer than 5 s outside the intro).
local function onHired(cardId: string)
	local card = StateController:Get("Roster." .. cardId)
	local name = if card then Generator.Name(card) else "Your new player"
	HudController:Toast(`{name} joined {StateController:Get("Team.Name") or "the team"}!`, Theme.Colors.Success)
	local plot = MyPlot.Model()
	local npc: Model? = nil
	local deadline = os.clock() + 2
	while not npc and os.clock() < deadline do
		npc = plot and plot:FindFirstChild("Npc_" .. cardId, true) :: Model?
		task.wait(0.1)
	end
	if not npc then
		return
	end
	local camera = Workspace.CurrentCamera
	UIController:SetCinematic("Hire", true)
	camera.CameraType = Enum.CameraType.Scriptable
	local t0 = os.clock()
	while os.clock() - t0 < 3.8 and npc.Parent do
		local p = npc:GetPivot()
		camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt((p * CFrame.new(5, 4, -8)).Position, p.Position + Vector3.new(0, 1.5, 0)), 0.15)
		task.wait()
	end
	camera.CameraType = Enum.CameraType.Custom
	UIController:SetCinematic("Hire", false)
end

function RosterController:Start()
	StateController:WaitUntilLoaded()
	HudController:WaitUntilShown()
	HudController:AddRail("Left", "Roster", { Icon = "👥", Label = "Roster", Color = Theme.Rail.Roster, Order = 1, OnClick = function()
		RosterController:Open("Players")
	end })
	StateController:Observe("Roster", function(r)
		local n = 0
		for _ in r or {} do
			n += 1
		end
		HudController:ShowRail("Roster", n >= 2) -- appears with the first hire ([[Screen - Main HUD]] → States)
	end)
	Net.Get("Roster", "Hired").OnClientEvent:Connect(onHired)
	watchFounder()

	-- Cork board prompt (free-agent board), once the 2nd desk is bought.
	task.spawn(function()
		local prompt: ProximityPrompt? = nil
		while true do
			local board = MyPlot.Find("FreeAgentBoard")
			local unlocked = StateController:Get("HQ.PadsBought.Desk2") == true
			if board and board:IsA("BasePart") and unlocked and not prompt then
				prompt = New("ProximityPrompt", { ActionText = "Free agents", ObjectText = "Cork board", MaxActivationDistance = 10, RequiresLineOfSight = false, Parent = board })
				;(prompt :: ProximityPrompt).Triggered:Connect(function()
					RosterController:Open("FreeAgents")
				end)
			end
			task.wait(0.5)
		end
	end)
end

return RosterController

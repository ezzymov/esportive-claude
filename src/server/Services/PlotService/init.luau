--!strict
-- PlotService ([[Plot & HQ]], [[World Layout & Presentation]]): builds the Hub and the 6-plot ring, assigns one plot
-- per player on join (freed on leave), spawns you in your driveway, owns the HQ build (pads, desks, banner, NPCs at
-- their stations) and the Founder seat. Server checks on Plot/BuyPad: pad exists, unlocked, prereqs, not owned,
-- within 12 studs of YOUR plot's pad, cash.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Lib = script.Parent.Parent.Lib
local Remote = require(Lib.Remote)
local Log = require(Lib.Log)
local Bus = require(Lib.Bus)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local Pads = require(ReplicatedStorage.Shared.Config.Pads)
local Team = require(ReplicatedStorage.Shared.Config.Team)
local World = require(ReplicatedStorage.Shared.Config.World)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local PlotFrame = require(ReplicatedStorage.Shared.PlotFrame)
local Generator = require(ReplicatedStorage.Shared.Generator)
local Hub = require(script.Hub)
local Garage = require(script.Garage)

local PlotService = { Tier = 2 }

local MAX_DISTANCE = 12 -- studs, [[Security & Anti-Exploit]]
local PAD_DEBOUNCE = 0.5 -- seconds per player per pad, [[Plot & HQ]]

type Desk = { Model: Model, Seat: Seat, Screen: TextLabel, Sign: BasePart }
type Plot = {
	Index: number,
	Owner: Player?,
	Refs: Garage.Refs,
	Pads: { [string]: BasePart },
	Desks: { [string]: Desk }, -- slot "2", "3"
	Npcs: { [string]: { CardId: string, Model: Model } }, -- by slot
	Banner: BasePart?,
	SeatedSince: number?,
	Annex: Model?, -- Stage 2 café annex
	Shelf: Model?, -- Stage 3 trophy shelf
	ShelfCount: number?,
}

local plots: { Plot } = {}
local byPlayer: { [Player]: Plot } = {}
local lastPress: { [Player]: { [string]: number } } = {}

-- Named unlock conditions used by Config/Pads (Unlock field).
PlotService.Unlocks = {
	PickupWon = function(data: any): boolean
		return (data.Ftue.PickupWins or 0) >= 1
	end,
	Hired = function(data: any): boolean
		local n = 0
		for _ in data.Roster do
			n += 1
		end
		return n >= 2
	end,
	Stage2 = function(data: any): boolean
		return data.Stage >= 2
	end,
}

local TROPHY_STAGE = 3 -- the shelf goes up with Local Circuit ([[HQ Era Visual Guide]] floor plan)

local function owns(data: any, padId: string): boolean
	return data.HQ.PadsBought[padId] == true
end

-- The pad entry currently shown on a physical pad group, or nil (all bought / still locked).
local function shownPad(data: any, group: string): Pads.Pad?
	for _, id in Pads.Order do
		local pad = Pads.ById[id]
		if pad.Group == group and not owns(data, id) then
			for _, req in pad.Requires do
				if not owns(data, req) then
					return nil
				end
			end
			if pad.Unlock and not PlotService.Unlocks[pad.Unlock](data) then
				return nil
			end
			return pad
		end
	end
	return nil
end
PlotService.ShownPad = shownPad

local function teamColor(data: any): Color3
	local idx = data.Team.Colors.Primary or Team.DefaultPrimary
	return Color3.fromHex(Team.Colors[idx] or Team.Colors[1])
end

-- Public API ------------------------------------------------------------------------------------------

function PlotService:GetPlot(player: Player): Plot?
	return byPlayer[player]
end

function PlotService:AnchorCF(player: Player, name: string): CFrame?
	local plot = byPlayer[player]
	return if plot then PlotFrame.Anchor(plot.Refs.Origin, name) else nil
end

-- True if the character is within maxDist studs of the named anchor on their own plot (or a public copy of it,
-- e.g. the Arcade Corner Aim Trainer).
function PlotService:IsNear(player: Player, name: string, maxDist: number?): boolean
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return false
	end
	local limit = maxDist or MAX_DISTANCE
	local cf = self:AnchorCF(player, name)
	if cf and (root.Position - cf.Position).Magnitude <= limit + 4 then -- +4: anchors sit at the object's base
		return true
	end
	local hub = Workspace:FindFirstChild("Hub")
	if hub then
		for _, part in hub:GetDescendants() do
			if part:IsA("BasePart") and part:GetAttribute("Anchor") == name and part:GetAttribute("Public") then
				if (root.Position - part.Position).Magnitude <= limit + 4 then
					return true
				end
			end
		end
	end
	return false
end

function PlotService:IsFounderSeated(player: Player): boolean
	local plot = byPlayer[player]
	return plot ~= nil and plot.SeatedSince ~= nil
end

function PlotService:SeatedSeconds(player: Player): number
	local plot = byPlayer[player]
	return if plot and plot.SeatedSince then os.clock() - plot.SeatedSince else 0
end

function PlotService:SetWhiteboard(player: Player, text: string)
	local plot = byPlayer[player]
	if plot then
		plot.Refs.Whiteboard.Text = text
	end
end

function PlotService:SetBoard(player: Player, text: string)
	local plot = byPlayer[player]
	if plot then
		plot.Refs.Board.Text = text
	end
end

function PlotService:SetCabinet(player: Player, on: boolean)
	local plot = byPlayer[player]
	if plot then
		local label = plot.Refs.CabinetScreen
		label.Text = if on then "AIM TRAINER\nINSERT COIN" else ""
		-- The client reads "On" from the screen part (label → SurfaceGui → part).
		local screenPart = label.Parent and label.Parent.Parent
		if screenPart then
			screenPart:SetAttribute("On", on)
		end
	end
end

-- Shows/hides the neighbor's broken PC on the Tech Fix bench.
function PlotService:SetBenchJob(player: Player, ready: boolean)
	local plot = byPlayer[player]
	if plot then
		local pc = plot.Refs.BenchPC
		pc.Transparency = if ready then 0 else 1
		local smoke = pc:FindFirstChildOfClass("Smoke")
		if smoke then
			smoke.Enabled = ready
		end
		pc:SetAttribute("JobReady", ready)
	end
end

local function setMonitor(plot: Plot, data: any)
	local label = plot.Refs.Monitor
	if not data.Flags.StationPowered then
		label.Text = "NO SIGNAL"
		label.TextColor3 = Theme.Colors.TextMuted
	elseif plot.SeatedSince then
		label.Text = "● LIVE\npracticing on stream"
		label.TextColor3 = Theme.Colors.Danger
	else
		label.Text = "SIT TO EARN"
		label.TextColor3 = Theme.Colors.Accent
	end
end

-- Banner -----------------------------------------------------------------------------------------------

function PlotService:RefreshBanner(player: Player, animate: boolean?)
	local plot = byPlayer[player]
	local data = DataService:GetProfile(player)
	if not plot or not data then
		return
	end
	if plot.Banner then
		plot.Banner:Destroy()
		plot.Banner = nil
	end
	if data.Flags.TeamCreated then
		plot.Banner = Garage.Banner(plot.Refs.Dynamic, plot.Refs.Origin, data.Team.Name, data.Team.Tag, teamColor(data), animate == true)
	end
end

-- Founder tee ([[Jersey Progression]] tier 1): torso + arms in the chosen tee color, classic shirt removed.
function PlotService:ApplyTee(player: Player)
	local data = DataService:GetProfile(player)
	local character = player.Character
	if not data or not character or not data.Flags.TeamCreated then
		return
	end
	local idx = data.Team.Colors.Tee or data.Team.Colors.Primary or Team.DefaultPrimary
	local color = Color3.fromHex(Team.Colors[idx] or Team.Colors[1])
	for _, name in { "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "Torso" } do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			part.Color = color
		end
	end
	for _, child in character:GetChildren() do
		if child:IsA("Shirt") or child:IsA("ShirtGraphic") then
			child:Destroy()
		end
	end
	local colors = character:FindFirstChildOfClass("BodyColors")
	if colors then
		colors.TorsoColor3 = color
	end
end

-- Desks + NPCs -----------------------------------------------------------------------------------------

local function buildDesk(plot: Plot, slot: string, animate: boolean): Desk
	local anchorName = "Desk" .. slot
	local cf = PlotFrame.Anchor(plot.Refs.Origin, anchorName)
	local model = Instance.new("Model")
	model.Name = "Station" .. slot
	local seat, screen = Garage.Station(model, cf, if slot == "2" then "Card" elseif slot == "3" then "Door" else "Cafe")
	screen.Text = "HIRING"
	screen.TextColor3 = Theme.Colors.Warning
	local sign = Instance.new("Part")
	sign.Name = "HiringSign"
	sign.Anchored = true
	sign.CanCollide = false
	sign.Size = Vector3.new(2.4, 1.2, 0.1)
	sign.CFrame = cf * CFrame.new(-2, 3.8, 1.3) * CFrame.Angles(math.rad(-15), math.rad(180), 0)
	sign.Color = Color3.fromHex("FEF3C7")
	sign.Parent = model
	local text = Instance.new("SurfaceGui")
	text.Face = Enum.NormalId.Front
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Text = "HIRING"
	label.FontFace = Theme.Fonts.Marker
	label.TextColor3 = Color3.fromHex("B91C1C")
	label.Parent = text
	text.Parent = sign
	model:SetAttribute("Anchor", anchorName)
	model.Parent = plot.Refs.Dynamic

	if animate then
		-- Build tween < 1 s: rise from under the floor.
		local target = model:GetPivot()
		local value = Instance.new("CFrameValue")
		value.Value = target * CFrame.new(0, -4, 0)
		model:PivotTo(value.Value)
		value.Changed:Connect(function(v)
			model:PivotTo(v)
		end)
		local tween = TweenService:Create(value, TweenInfo.new(0.6, Enum.EasingStyle.Back), { Value = target })
		tween.Completed:Connect(function()
			value:Destroy()
		end)
		tween:Play()
	end
	return { Model = model, Seat = seat, Screen = screen, Sign = sign }
end

local function npcName(card: any): string
	return Generator.Name(card)
end

local function seatNpc(model: Model, seat: Seat)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		seat:Sit(humanoid)
	end
end

-- Spawns (or walks in) the NPC for `card` at desk `slot`.
local function placeNpc(plot: Plot, slot: string, desk: Desk, card: any, walkIn: boolean)
	local model = Garage.Npc(card, npcName(card))
	local origin = plot.Refs.Origin
	local start = if walkIn
		then PlotFrame.Garage(origin) * CFrame.new(0, 3, World.Garage.Inside.Z / 2 + 6) * CFrame.Angles(0, math.rad(180), 0)
		else desk.Seat.CFrame * CFrame.new(0, 2, 0)
	model:PivotTo(start)
	model.Parent = plot.Refs.Dynamic
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root and root:CanSetNetworkOwnership() then
		root:SetNetworkOwner(nil)
	end
	plot.Npcs[slot] = { CardId = card.Id, Model = model }
	desk.Sign.Transparency = 1
	desk.Sign:FindFirstChildOfClass("SurfaceGui").Enabled = false
	desk.Screen.Text = npcName(card)
	desk.Screen.TextColor3 = Theme.Rarity[card.Rarity] or Theme.Colors.Text

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if walkIn and humanoid then
		task.spawn(function()
			humanoid:MoveTo((desk.Seat.CFrame * CFrame.new(0, 0, 2)).Position)
			local done = false
			local conn = humanoid.MoveToFinished:Connect(function()
				done = true
			end)
			local deadline = os.clock() + 6
			while not done and os.clock() < deadline and model.Parent do
				task.wait(0.1)
			end
			conn:Disconnect()
			if model.Parent then
				seatNpc(model, desk.Seat)
			end
		end)
	else
		task.defer(seatNpc, model, desk.Seat)
	end
end

-- Rebuilds everything that depends on the owner's profile. opts.WalkIn = card id that walks in (hire scene);
-- opts.Animate = tween newly built desks in (right after a pad purchase).
function PlotService:Refresh(player: Player, opts: { WalkIn: string?, Animate: boolean? }?)
	local walkInCardId = opts and opts.WalkIn
	local animate = opts ~= nil and opts.Animate == true
	local plot = byPlayer[player]
	local data = DataService:GetProfile(player)
	if not plot or not data then
		return
	end

	-- Pads: one physical pad per group, visible only when its next entry is unlocked.
	PlotService:RefreshPads(player)

	-- Café annex (Stage 2): replaces the café ghost outline.
	if data.Stage >= 2 and not plot.Annex then
		plot.Annex = Garage.Annex(plot.Refs.Dynamic, plot.Refs.Origin, teamColor(data))
		local ghost = plot.Refs.Model:FindFirstChild("GhostCafe")
		if ghost and ghost:IsA("BasePart") then
			ghost.Transparency = 1
		end
	end
	-- Trophy shelf (Stage 3 or the first trophy), rebuilt when the count changes.
	if (data.Stage >= TROPHY_STAGE or #data.Trophies > 0) and plot.ShelfCount ~= #data.Trophies then
		if plot.Shelf then
			plot.Shelf:Destroy()
		end
		plot.Shelf = Garage.TrophyShelf(plot.Refs.Dynamic, plot.Refs.Origin, data.Trophies)
		plot.ShelfCount = #data.Trophies
	end

	-- Desks 2..n from Stations.
	for slot, station in data.Stations do
		if slot ~= "1" and not plot.Desks[slot] then
			plot.Desks[slot] = buildDesk(plot, slot, animate)
		end
		local desk = plot.Desks[slot]
		local cardId = station.PlayerId
		local npc = plot.Npcs[slot]
		if desk then
			if npc and npc.CardId ~= cardId then
				npc.Model:Destroy()
				plot.Npcs[slot] = nil
				npc = nil
				desk.Sign.Transparency = 0
				desk.Sign:FindFirstChildOfClass("SurfaceGui").Enabled = true
				desk.Screen.Text = "HIRING"
			end
			local card = data.Roster[cardId]
			if not npc and card then
				placeNpc(plot, slot, desk, card, cardId == walkInCardId)
			end
		end
	end

	-- Founder mouse visual.
	local founder = data.Roster[data.FounderUuid]
	if founder and founder.Accessories and founder.Accessories.Mouse == "ClikkBasic" then
		plot.Refs.FounderMouse.Color = Color3.fromHex("0EA5E9")
		plot.Refs.FounderMouse.Material = Enum.Material.Neon
	end
	setMonitor(plot, data)
end

-- Plot assignment -------------------------------------------------------------------------------------

local function spawnCF(plot: Plot): CFrame
	return PlotFrame.Anchor(plot.Refs.Origin, "Spawn") + Vector3.new(0, 3, 0)
end

function PlotService:SpawnCF(player: Player): CFrame?
	local plot = byPlayer[player]
	return if plot then spawnCF(plot) else nil
end

local function onFounderSeat(plot: Plot)
	local seat = plot.Refs.FounderSeat
	local occupant = seat.Occupant
	local owner = plot.Owner
	if occupant then
		local who = Players:GetPlayerFromCharacter(occupant.Parent)
		if who ~= owner then
			occupant.Sit = false -- only the owner can sit at the Founder desk
			return
		end
		plot.SeatedSince = os.clock()
	else
		plot.SeatedSince = nil
	end
	if owner then
		local data = DataService:GetProfile(owner)
		if data then
			setMonitor(plot, data)
		end
		Bus.Fire(owner, if occupant then "Seated" else "Unseated")
	end
end

local function assign(player: Player)
	for _, plot in plots do
		if not plot.Owner then
			plot.Owner = player
			byPlayer[player] = plot
			plot.Refs.Model:SetAttribute("OwnerUserId", player.UserId)
			player:SetAttribute("PlotIndex", plot.Index)
			plot.Refs.Model:AddPersistentPlayer(player)
			for _, part in plot.Pads do
				part:SetAttribute("OwnerUserId", player.UserId)
			end
			Log.Info("Plot", `{player.Name} → Plot {plot.Index}`)
			return plot
		end
	end
	Log.Event("no_free_plot", player)
	return nil
end

local function release(player: Player)
	local plot = byPlayer[player]
	byPlayer[player] = nil
	if not plot then
		return
	end
	plot.Owner = nil
	plot.SeatedSince = nil
	plot.Refs.Model:SetAttribute("OwnerUserId", 0)
	pcall(function()
		plot.Refs.Model:RemovePersistentPlayer(player)
	end)
	plot.Refs.Dynamic:ClearAllChildren()
	plot.Desks, plot.Npcs, plot.Banner = {}, {}, nil
	plot.Annex, plot.Shelf, plot.ShelfCount = nil, nil, nil
	local ghost = plot.Refs.Model:FindFirstChild("GhostCafe")
	if ghost and ghost:IsA("BasePart") then
		ghost.Transparency = 0.6
	end
	plot.Pads = {}
	for _, pad in Pads.Order do
		local group = Pads.ById[pad].Group
		if not plot.Pads[group] then
			plot.Pads[group] = Garage.Pad(plot.Refs.Dynamic, plot.Refs.Origin, group, 0)
			plot.Pads[group].Transparency = 1
			plot.Pads[group].CanTouch = false
		end
	end
	plot.Refs.Whiteboard.Text = ""
	plot.Refs.Board.Text = "FREE AGENTS\nsoon"
	plot.Refs.Monitor.Text = "NO SIGNAL"
	plot.Refs.CabinetScreen.Text = ""
	plot.Refs.FounderMouse.Color = Color3.fromHex("D6D3D1")
	plot.Refs.FounderMouse.Material = Enum.Material.SmoothPlastic
	PlotService:SetBenchJob(player, false)
end

local function buildPlots()
	local folder = Instance.new("Folder")
	folder.Name = "Plots"
	for i = 1, World.PlotCount do
		local origin = PlotFrame.Plot(i)
		local model = Instance.new("Model")
		model.Name = "Plot" .. i
		model.ModelStreamingMode = Enum.ModelStreamingMode.PersistentPerPlayer
		model:SetAttribute("Index", i)
		model:SetAttribute("Origin", origin)
		model:SetAttribute("OwnerUserId", 0)
		local refs = Garage.BuildStatic(model, origin)
		local dynamic = Instance.new("Folder")
		dynamic.Name = "Dynamic"
		dynamic.Parent = model
		refs.Dynamic = dynamic
		local plot: Plot = { Index = i, Owner = nil, Refs = refs, Pads = {}, Desks = {}, Npcs = {}, Banner = nil, SeatedSince = nil }
		for _, id in Pads.Order do
			local group = Pads.ById[id].Group
			if not plot.Pads[group] then
				plot.Pads[group] = Garage.Pad(dynamic, origin, group, 0)
				plot.Pads[group].Transparency = 1
				plot.Pads[group].CanTouch = false
			end
		end
		refs.FounderSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
			onFounderSeat(plot)
		end)
		plots[i] = plot
		model.Parent = folder
		task.wait() -- one plot per frame
	end
	folder.Parent = Workspace
end

-- Plot/BuyPad --------------------------------------------------------------------------------------------

local function buyPad(player: Player, padId: string): (boolean, any)
	local pad = Pads.ById[padId]
	if not pad then
		Log.Event("bad_pad_id", player, padId)
		return false, "UnknownPad"
	end

	local presses = lastPress[player] or {}
	lastPress[player] = presses
	local now = os.clock()
	if presses[padId] and now - presses[padId] < PAD_DEBOUNCE then
		return false, "Debounce"
	end
	presses[padId] = now

	local data = DataService:GetProfile(player)
	local plot = byPlayer[player]
	if not data or not plot then
		return false, "NotLoaded"
	end
	if owns(data, padId) then
		return false, "Owned"
	end
	if shownPad(data, pad.Group) ~= pad then
		return false, "Locked"
	end

	local part = plot.Pads[pad.Group]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not part or not root or (root.Position - part.Position).Magnitude > MAX_DISTANCE then
		Log.Event("pad_too_far", player, padId)
		return false, "TooFar"
	end

	local paid, err = EconomyService:Transact(player, { Cash = -pad.Price }, `BuyPad:{padId}`)
	if not paid then
		return false, if err == "Insufficient" then { Need = pad.Price - data.Currencies.Cash } else err
	end
	DataService:Update(player, "HQ.PadsBought." .. padId, function()
		return true
	end)
	DataService:Update(player, "HQ.HQLevel", function(level)
		return (level or 0) + 1
	end)
	if pad.Builds.Desk then
		local slot = tostring(pad.Builds.Desk)
		DataService:Update(player, "Stations." .. slot, function(old)
			return old or { PlayerId = "", Tier = 1, Parts = {} }
		end)
	end
	PlotService:Refresh(player, { Animate = true }) -- build the desk first, so it tweens in
	Bus.Fire(player, "PadBought", padId) -- RosterService seats players / equips gear; tutorial re-checks
	DataService:SaveNow(player, `BuyPad:{padId}`)
	return true, padId
end

-- Pad visibility only (cheap): unlocks depend on facts like "won a Pickup Game" or "hired someone".
function PlotService:RefreshPads(player: Player)
	local plot = byPlayer[player]
	local data = DataService:GetProfile(player)
	if not plot or not data then
		return
	end
	for group, part in plot.Pads do
		local pad = shownPad(data, group)
		part.Transparency = if pad then 0.15 else 1
		part.CanTouch = pad ~= nil
		part:SetAttribute("PadId", if pad then pad.Id else "")
	end
end

function PlotService:Init()
	Remote.Function("Plot", "BuyPad", { Args = { Remote.T.String(64) } }, buyPad)
	-- Any gameplay fact can unlock a pad (Config/Pads Unlock), so re-check after each one.
	Bus.On(function(player, event)
		if event ~= "Line" then
			PlotService:RefreshPads(player)
		end
	end)
end

function PlotService:Start()
	Hub.Build()
	buildPlots()

	local function onPlayer(player: Player)
		local plot = assign(player)
		player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam -- see into the garage past its roof
		local function onCharacter(character: Model)
			local p = byPlayer[player]
			if not p then
				return
			end
			character:WaitForChild("HumanoidRootPart", 10)
			task.wait()
			character:PivotTo(spawnCF(p))
		end
		player.CharacterAdded:Connect(onCharacter)
		player.CharacterAppearanceLoaded:Connect(function()
			PlotService:ApplyTee(player)
		end)
		if player.Character then
			task.spawn(onCharacter, player.Character)
		end
		if plot then
			local data = DataService:WaitForProfile(player)
			if data then
				PlotService:RefreshBanner(player)
				PlotService:Refresh(player)
				Bus.Fire(player, "PlotReady")
			end
		end
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayer, player)
	end
	Players.PlayerRemoving:Connect(function(player)
		release(player)
		lastPress[player] = nil
	end)
end

return PlotService

--!strict
-- MatchController ([[Screen - Match HUD]], [[Caster & Commentary]]): plays a match the server already decided
-- ([[Match Simulation]] → Output). Nothing here changes a result or a reward.
--   Pre-match: both teams, Team Power, map + veto bans, PURE tag, the opponent's trash talk.
--   Broadcast Stage built locally far from the Hub (y = 10000): your avatar + players vs the other five.
--   HUD: scoreboard (tags, score, round, map), your five left / theirs right (kills, alive), kill feed (last 4),
--   caster lower-third, momentum pop, "CLIP MOMENT!" toast, 1×/2× speed and Skip.
--   Clutch Moment on the first match-point round (Pickup Games + scrims): tap in the green for up to +10%.
--   Post-match: VICTORY / DEFEAT (+ UPSET! / COMEBACK!), score, MVP card, Match Rating per player, rewards, clip moments.
-- Entry points: StartPickup() · StartScrim(offerId, pure, bans) · Watch(plan, result) (tournament replays).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Net = require(ReplicatedStorage.Shared.Net)
local Build = require(ReplicatedStorage.Shared.Build)
local Format = require(ReplicatedStorage.Shared.Format)
local Generator = require(ReplicatedStorage.Shared.Generator)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Team = require(ReplicatedStorage.Shared.Config.Team)
local Match = require(ReplicatedStorage.Shared.Config.Match)
local Minigames = require(ReplicatedStorage.Shared.Config.Minigames)
local Cases = require(ReplicatedStorage.Shared.Config.Cases)
local Maps = require(ReplicatedStorage.Shared.Config.Maps)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local Caster = require(script.Parent.Parent.UI.Caster)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)

local MatchController = { Tier = 4 }

local player = Players.LocalPlayer
local STAGE_Y = 10000
local playing = false
local lastStart = -math.huge

local RATING_LABELS = { { 1.35, "MVP performance" }, { 1.2, "Star game" }, { 1.1, "Good" }, { 1.0, "Solid" }, { 0.85, "Below average" }, { 0, "Rough game" } }
local MOMENT_NAMES = { Ace = "Ace", Clutch = "Clutch", Flawless = "Flawless round", Comeback = "Comeback", Upset = "Upset", Record = "Personal best" }

function MatchController:IsPlaying(): boolean
	return playing
end

function MatchController:CooldownLeft(): number
	return math.max(0, math.ceil(lastStart + Minigames.Pickup.Cooldown - os.clock()))
end

local function ratingLabel(r: number): string
	for _, row in RATING_LABELS do
		if r >= row[1] then
			return row[2]
		end
	end
	return ""
end

local function hex(c: string?): Color3
	return if c then Color3.fromHex(c) else Theme.Colors.Danger
end

-- A rig for the broadcast: your own avatar clone for the Founder, a stripped recolored clone for everyone else.
local function rig(view: any, isFounder: boolean, teeColor: Color3): Model
	local character = player.Character
	local m: Model
	if character then
		character.Archivable = true
		m = character:Clone()
	else
		m = Instance.new("Model")
		Build.Part(m, "HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), "FFFFFF", { Transparency = 1 })
		Build.Part(m, "Head", Vector3.new(1.2, 1.2, 1.2), CFrame.new(0, 1.6, 0), "F1C27D")
		m.PrimaryPart = m:FindFirstChild("HumanoidRootPart") :: BasePart
	end
	local look = if isFounder then nil else Generator.Look(view)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
		elseif d:IsA("Script") or d:IsA("LocalScript") then
			d:Destroy()
		elseif d:IsA("Humanoid") then
			d.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		elseif not isFounder and (d:IsA("Accessory") or d:IsA("Clothing") or d:IsA("ShirtGraphic") or d:IsA("Decal") and d.Name ~= "face") then
			d:Destroy()
		end
	end
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
			local n = d.Name
			local torso = n == "UpperTorso" or n == "LowerTorso" or n == "Torso" or n == "LeftUpperArm" or n == "RightUpperArm"
			if isFounder then
				if torso then
					d.Color = teeColor
				end
			elseif look then
				d.Color = if torso then look.Shirt elseif string.find(n, "Leg") or string.find(n, "Foot") then look.Pants else look.Skin
			end
		end
	end
	return m
end

local function buildStage(plan: any): (Folder, { A: { Model }, B: { Model } }, CFrame)
	local folder = New("Folder", { Name = "MatchStage", Parent = Workspace })
	local center = CFrame.new(0, STAGE_Y, 0)
	local mapDef = (Maps :: any)[plan.MapId or ""]
	local mapColor = if mapDef then Color3.fromHex(mapDef.Color) else Theme.Colors.Accent
	Build.Part(folder, "Floor", Vector3.new(120, 1, 80), center * CFrame.new(0, -0.5, 0), Theme.Colors.Bg, { Material = Enum.Material.SmoothPlastic })
	Build.Part(folder, "Backdrop", Vector3.new(120, 40, 1), center * CFrame.new(0, 20, -40), Theme.Colors.Panel)
	local screen = Build.Part(folder, "BigScreen", Vector3.new(60, 18, 0.5), center * CFrame.new(0, 22, -39), "0B1020", { Material = Enum.Material.Neon })
	Build.Text(screen, Enum.NormalId.Back, `{plan.Event or plan.Title}\n{plan.Map}`, { TextColor3 = mapColor })
	New("PointLight", { Range = 60, Brightness = 2, Color = mapColor, Parent = screen })
	local teamIdx = StateController:Get("Team.Colors.Tee") or StateController:Get("Team.Colors.Primary") or 1
	local tee = Color3.fromHex(Team.Colors[teamIdx] or Team.Colors[1])
	local rigs = { A = {}, B = {} }
	for side, sign in { A = -1, B = 1 } do
		local team = plan.Teams[side]
		for i, view in team.Players do
			local x = (i - 3) * 9
			local deskCF = center * CFrame.new(x, 0, sign * 10) * CFrame.Angles(0, if sign < 0 then math.rad(180) else 0, 0) -- teams face each other
			Build.Part(folder, "Desk", Vector3.new(6, 3, 3), deskCF * CFrame.new(0, 1.5, -1.5), hex(team.Color), { Material = Enum.Material.Neon, Transparency = 0.4 })
			Build.Part(folder, "Monitor", Vector3.new(3, 2, 0.3), deskCF * CFrame.new(0, 4, -2.4), "111827")
			local isFounder = view.Source == "Founder"
			local m = rig(view, isFounder, tee)
			m:PivotTo(deskCF * CFrame.new(0, 3, 1.5))
			m.Parent = folder
			local head = m:FindFirstChild("Head") :: BasePart?
			if head then
				local stand = view.Source == "Pug" or view.Source == "StandIn"
				local name = if view.Tag ~= "" and not stand then `[{view.Tag}] {view.Name}` else view.Name
				Build.Nameplate(head, name, if stand then Theme.Colors.TextMuted elseif side == "B" then hex(team.Color) else (Theme.Rarity[view.Rarity] or Theme.Colors.Text), if stand then (if view.Source == "Pug" then "PUG" else "STAND-IN") else view.Role)
			end
			rigs[side][i] = m
		end
	end
	return folder, rigs, center
end

local function clutchMinigame(gui: ScreenGui): number
	local box = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.62), Size = UDim2.fromOffset(560, 150), BackgroundColor3 = Theme.Colors.Bg, BackgroundTransparency = 0.1, ZIndex = 20, Parent = gui })
	Components.Corner(box, Theme.Radius.L)
	Components.Stroke(box, Theme.Colors.Warning)
	New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.H2, TextColor3 = Theme.Colors.Warning, Text = "CLUTCH MOMENT! Tap in the green", ZIndex = 21, Parent = box })
	local track = New("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 56), Size = UDim2.new(0.9, 0, 0, 28), BackgroundColor3 = Theme.Colors.Panel, ZIndex = 21, Parent = box })
	Components.Corner(track, Theme.Radius.S)
	New("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(0.18, 1), BackgroundColor3 = Theme.Colors.Success, ZIndex = 22, Parent = track })
	local needle = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(0, 6, 1.6, 0), BackgroundColor3 = Theme.Colors.Text, ZIndex = 23, Parent = track })
	local tapBtn = Components.Button({ Text = "TAP!", Width = 180 })
	tapBtn.AnchorPoint = Vector2.new(0.5, 1)
	tapBtn.Position = UDim2.new(0.5, 0, 1, -8)
	tapBtn.ZIndex = 24
	tapBtn.Parent = box
	local result: number? = nil
	local t0 = os.clock()
	local pos = 0
	local conn = RunService.RenderStepped:Connect(function()
		pos = (math.sin((os.clock() - t0) * 3.2 - math.pi / 2) + 1) / 2
		needle.Position = UDim2.fromScale(pos, 0.5)
	end)
	local function hit()
		if result == nil then
			result = math.clamp(1 - math.abs(pos - 0.5) / 0.5, 0, 1) ^ 2
		end
	end
	tapBtn.Activated:Connect(hit)
	local key = UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
			hit()
		end
	end)
	while result == nil and os.clock() - t0 < 4 do
		task.wait()
	end
	conn:Disconnect()
	key:Disconnect()
	local q = result or 0
	box:Destroy()
	return q
end

-- Pre-match card ([[Screen - Match HUD]] → Opened from): lineups, power, map, veto, PURE, trash talk. ~3 s or tap.
local function preMatch(gui: ScreenGui, plan: any)
	local card = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(760, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Colors.Bg, BackgroundTransparency = 0.05, ZIndex = 30, Parent = gui })
	Components.Corner(card, Theme.Radius.L)
	Components.Stroke(card, Theme.Colors.Accent)
	Components.Padding(card, Theme.Space.XL, Theme.Space.L)
	Components.List(card, Theme.Space.S, false, Enum.HorizontalAlignment.Center)
	local A, B = plan.Teams.A, plan.Teams.B
	local function line(text: string, size: number, color: Color3?, order: number, font: Font?)
		local l = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, size + 8), FontFace = font or Theme.Fonts.Bold, TextSize = size, TextColor3 = color or Theme.Colors.Text, RichText = true, TextWrapped = true, Text = text, LayoutOrder = order, ZIndex = 31, Parent = card })
		return l
	end
	line(string.upper(plan.Event or (if plan.Kind == "Scrim" then "Scrim" elseif plan.Kind == "Pickup" then "Pickup Game" else plan.Title)), Theme.Type.Caption + 2, Theme.Colors.TextMuted, 1)
	line(`<font color="#{hex(A.Color):ToHex()}">{A.Name}</font>  vs  <font color="#{hex(B.Color):ToHex()}">{B.Name}</font>`, Theme.Type.H1, nil, 2, Theme.Fonts.Heading)
	local edge = if B.Power > 0 then (A.Power / B.Power - 1) * 100 else 0
	line(string.format("Team Power %d vs %d  (%+.0f%%)", A.Power, B.Power, edge), Theme.Type.Body, if edge >= 0 then Theme.Colors.Success else Theme.Colors.Warning, 3)
	local mapLine = `🗺 {plan.Map}`
	if plan.Veto and plan.Veto.Bans and #plan.Veto.Bans > 0 then
		local bans = {}
		for _, b in plan.Veto.Bans do
			local def = (Maps :: any)[b.Map]
			table.insert(bans, `{if b.Side == "A" then A.Tag else B.Tag} banned {if def then def.Name else b.Map}`)
		end
		mapLine ..= "   ·   " .. table.concat(bans, " · ")
	end
	line(mapLine, Theme.Type.Body, Theme.Colors.Accent, 4)
	if plan.Pure then
		line("PURE SKILL · gear and station parts off", Theme.Type.Body, Theme.Colors.Warning, 5)
	end
	if B.Talk and B.Talk ~= "" then
		line(`{B.Tag ~= "" and B.Tag or B.Name}: "{B.Talk}"`, Theme.Type.Body, Theme.Colors.TextMuted, 6, Theme.Fonts.Body)
	end
	local scale = New("UIScale", { Scale = 0.85, Parent = card })
	TweenService:Create(scale, TweenInfo.new(Theme.Tween.Open, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	local t0 = os.clock()
	local tapped = false
	local tap = New("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 29, Parent = gui, Activated = function()
		tapped = true
	end })
	while os.clock() - t0 < 3.2 and not tapped do
		task.wait()
	end
	tap:Destroy()
	card:Destroy()
end

local function resultScreen(gui: ScreenGui, plan: any, r: any, onContinue: () -> ())
	local win = r.Winner == "A"
	local champion = r.Champion == true
	local modal = Components.Modal(gui, { Title = if champion then "🏆 CHAMPIONS" elseif win then "VICTORY" else "DEFEAT", Width = 0.62, Height = 0.86, NoClose = true, ZIndex = 30 })
	modal.Title.TextColor3 = if win then Theme.Colors.Success else Theme.Colors.Danger
	local body = modal.Body
	local list = New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -64), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0, ZIndex = 32, Parent = body })
	Components.List(list, Theme.Space.S)
	local o = 0
	local function add(inst: GuiObject)
		o += 1
		inst.LayoutOrder = o
		inst.ZIndex = 32
		for _, d in inst:GetDescendants() do
			if d:IsA("GuiObject") then
				d.ZIndex = 33
			end
		end
		inst.Parent = list
	end
	local function text(t: string, size: number, color: Color3?, font: Font?)
		add(New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, size + 8), FontFace = font or Theme.Fonts.Body, TextSize = size, TextColor3 = color or Theme.Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, RichText = true, TextWrapped = true, Text = t }))
	end
	text(`{plan.Teams.A.Tag} {r.Score[1]} – {r.Score[2]} {plan.Teams.B.Name}   ·   {plan.Map}`, 34, Theme.Colors.Text, Theme.Fonts.Heading)
	local chips = {}
	if win and r.Upset then
		table.insert(chips, "UPSET!")
	end
	if win and r.Comeback then
		table.insert(chips, "COMEBACK!")
	end
	if plan.Pure then
		table.insert(chips, "PURE")
	end
	if #chips > 0 then
		text(table.concat(chips, "  ·  "), Theme.Type.H2, Theme.Colors.Warning, Theme.Fonts.Heading)
	end
	-- MVP card + your five's Match Ratings.
	local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, Theme.Components.PlayerCard.Height + 8) })
	local mvpView = plan.Teams[r.Mvp.Side].Players[r.Mvp.Index]
	if mvpView then
		local mvpCard = Components.PlayerCard(mvpView)
		mvpCard.Parent = row
		New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, -4), Size = UDim2.fromOffset(60, 20), FontFace = Theme.Fonts.Heading, TextSize = 14, TextColor3 = Theme.Colors.Warning, Text = "MVP", Parent = mvpCard })
	end
	local ratings = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(Theme.Components.PlayerCard.Width + Theme.Space.L, 0), Size = UDim2.new(1, -(Theme.Components.PlayerCard.Width + Theme.Space.L), 1, 0), Parent = row })
	Components.List(ratings, 2)
	local best: { [number]: number } = {}
	for _, rec in r.Records or {} do
		best[rec.Index] = rec.Kills
	end
	for i, view in plan.Teams.A.Players do
		local rating = (r.Ratings.A or {})[i] or 1
		local stand = view.Source == "Pug" or view.Source == "StandIn"
		New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
			FontFace = Theme.Fonts.Body,
			TextSize = Theme.Type.Body,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = if stand then Theme.Colors.TextMuted elseif rating >= 1.35 then Theme.Colors.Warning else Theme.Colors.Text,
			RichText = true,
			Text = `{if stand then (if view.Source == "Pug" then "PUG " else "STAND-IN ") else ""}{view.Name} · <b>{string.format("%.2f", rating)}</b> {ratingLabel(rating)}{if best[i] then " · 🏅 best " .. best[i] else ""}`,
			LayoutOrder = i,
			Parent = ratings,
		})
	end
	add(row)
	local rewards = r.Rewards or {}
	local parts = {}
	if (rewards.Cash or 0) > 0 then
		table.insert(parts, `+{Format.Cash(rewards.Cash)}`)
	end
	if (rewards.Fame or 0) > 0 then
		table.insert(parts, `<font color="#FBBF24">+{rewards.Fame} ★</font>`)
	end
	if #parts > 0 then
		text(table.concat(parts, "   "), Theme.Type.H2, Theme.Colors.Success, Theme.Fonts.Heading)
	end
	if r.Place then
		text(if r.Place == 1 then "🏆 Trophy added to your shelf!" else `Finished {if r.Place == 2 then "2nd" elseif r.Place <= 4 then "3rd–4th" else "5th–8th"}`, Theme.Type.Body, Theme.Colors.Warning, Theme.Fonts.Bold)
	end
	if rewards.Case and rewards.Case ~= "" then
		local def = (Cases :: any)[rewards.Case]
		text(`🎁 {if def then def.Name else rewards.Case} added to your Inventory!`, Theme.Type.Body, Theme.Colors.Accent, Theme.Fonts.Bold)
	end
	if rewards.Crate then
		text("🎁 Rookie Crate earned!", Theme.Type.H2, Theme.Rarity.Rare, Theme.Fonts.Heading)
	end
	if r.Clutch then
		text(`Clutch round {r.Clutch.Round}: {if r.Clutch.Won then "won" else "lost"} ({math.floor(r.Clutch.Quality * 100)}% timing)`, Theme.Type.Caption + 1, Theme.Colors.TextMuted)
	end
	if r.Moments and #r.Moments > 0 then
		local names = {}
		for _, m in r.Moments do
			local v = plan.Teams[m.Side].Players[m.Index]
			table.insert(names, `{MOMENT_NAMES[m.Type] or m.Type} · R{m.Round} {v and v.Name or "?"}`)
		end
		text(`📸 {#r.Moments} clip moment{if #r.Moments == 1 then "" else "s"} saved: {table.concat(names, ", ")}. (Clip Studio opens at Stage 4.)`, Theme.Type.Caption + 1, Theme.Colors.Accent)
	end
	local cont = Components.Button({ Text = "Continue", Width = 220, OnClick = function()
		modal.Close()
		onContinue()
	end })
	cont.AnchorPoint = Vector2.new(0.5, 1)
	cont.Position = UDim2.fromScale(0.5, 1)
	cont.ZIndex = 33
	cont.Parent = body
	if champion then
		for _ = 1, 40 do
			local piece = New("Frame", { Position = UDim2.fromScale(math.random(), -0.05), Size = UDim2.fromOffset(10, 16), BackgroundColor3 = Color3.fromHSV(math.random(), 0.8, 1), Rotation = math.random(0, 90), ZIndex = 40, Parent = gui })
			TweenService:Create(piece, TweenInfo.new(1.6 + math.random() * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.fromScale(math.random(), 1.1), Rotation = math.random(180, 720) }):Play()
			task.delay(3.2, piece.Destroy, piece)
		end
		Components.Play(Theme.Sounds.Cheer, 1, 1)
	end
end

-- Plays a decided match. resolve(quality) → { Rounds, Result } (called once, at the Clutch Moment or the end).
function MatchController:Play(plan: any, resolve: (number) -> any)
	playing = true
	UIController:SetCinematic("Match", true)
	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	local folder, rigs, center = buildStage(plan)
	local intensity = plan.Intensity or 1
	local A, B = plan.Teams.A, plan.Teams.B

	local gui = New("ScreenGui", { Name = "MatchHUD", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 50, Parent = player:WaitForChild("PlayerGui") })
	New("UIScale", { Scale = (UIController:GetGui("HUD"):FindFirstChildOfClass("UIScale") :: UIScale).Scale, Parent = gui })
	camera.CFrame = CFrame.lookAt((center * CFrame.new(0, 26, 46)).Position, center.Position)
	preMatch(gui, plan)
	local tokens = { team = A.Name, opponent = B.Name, map = plan.Map }
	Caster.Show(gui, "MatchStart", intensity, tokens, 40)

	-- Scoreboard (top center).
	local board = New("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 48), Size = UDim2.fromOffset(560, 64), BackgroundColor3 = Theme.Colors.Bg, BackgroundTransparency = 0.15, Parent = gui })
	Components.Corner(board, Theme.Radius.M)
	Components.Stroke(board, Theme.Colors.Accent)
	local score = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0.6, 0), FontFace = Theme.Fonts.Heading, TextSize = 30, TextColor3 = Theme.Colors.Text, RichText = true, Parent = board })
	local sub = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.6), Size = UDim2.new(1, 0, 0.4, 0), FontFace = Theme.Fonts.Body, TextSize = 15, TextColor3 = Theme.Colors.TextMuted, Parent = board })
	-- Side panels: name + kills; dimmed when dead this round.
	local panels: { [string]: { TextLabel } } = { A = {}, B = {} }
	local totals = { A = {}, B = {} } :: any
	for side, anchorX in { A = 0, B = 1 } do
		local team = plan.Teams[side]
		local panel = New("Frame", { AnchorPoint = Vector2.new(anchorX, 0), Position = UDim2.new(anchorX, if anchorX == 0 then 16 else -16, 0, 130), Size = UDim2.fromOffset(250, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = gui })
		Components.List(panel, 4, false, if anchorX == 0 then Enum.HorizontalAlignment.Left else Enum.HorizontalAlignment.Right)
		for i, view in team.Players do
			totals[side][i] = 0
			local l = New("TextLabel", { Size = UDim2.fromOffset(250, 28), BackgroundColor3 = Theme.Colors.Bg, BackgroundTransparency = 0.25, FontFace = Theme.Fonts.Bold, TextSize = 15, TextColor3 = if side == "A" then Theme.Colors.Text else hex(team.Color), TextXAlignment = if anchorX == 0 then Enum.TextXAlignment.Left else Enum.TextXAlignment.Right, Text = "", LayoutOrder = i, Parent = panel })
			Components.Corner(l, Theme.Radius.S)
			Components.Padding(l, Theme.Space.S, 0)
			panels[side][i] = l
		end
	end
	local function drawPanels(dead: { [string]: { [number]: boolean } }?)
		for side, list in panels do
			for i, l in list do
				local view = plan.Teams[side].Players[i]
				l.Text = `{view.Name}  ·  {totals[side][i]} K`
				l.TextTransparency = if dead and dead[side][i] then 0.55 else 0
			end
		end
	end
	drawPanels()
	local feed = New("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -280, 0, 130), Size = UDim2.fromOffset(300, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = gui })
	Components.List(feed, 3, false, Enum.HorizontalAlignment.Right)
	local banner = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.7), Size = UDim2.fromOffset(600, 50), BackgroundTransparency = 1, FontFace = Theme.Fonts.Heading, TextSize = 36, TextColor3 = Theme.Colors.Text, Text = "", Parent = gui }, { New("UIStroke", { Thickness = 3, Color = Theme.Colors.Bg }) })
	local toast = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.36), Size = UDim2.fromOffset(420, 46), BackgroundColor3 = Theme.Colors.Accent2, FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.H2, TextColor3 = Theme.Colors.Text, Text = "", Visible = false, Parent = gui })
	Components.Corner(toast, Theme.Radius.M)

	-- Controls: 1× / 2× and Skip.
	local speed = 1
	local skipped = false
	local controls = New("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -24, 1, -24), Size = UDim2.fromOffset(0, 48), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Parent = gui })
	Components.List(controls, Theme.Space.S, true)
	local speedBtn: TextButton
	speedBtn = Components.Button({ Text = "1×", Kind = "Secondary", Width = 70, Order = 1, OnClick = function()
		speed = if speed == 1 then 2 else 1
		speedBtn.Text = `{speed}×`
	end })
	speedBtn.Parent = controls
	local skip = Components.Button({ Text = "Skip >>", Kind = "Secondary", Width = 150, Order = 2, OnClick = function()
		skipped = true
	end })
	skip.Parent = controls

	local resolved: any = nil
	local function getResolved(quality: number): any
		if not resolved then
			resolved = resolve(quality)
		end
		return resolved
	end

	local a, b = 0, 0
	local streak, streakSide = 0, ""
	local said: { [string]: boolean } = {}
	local function drawScore()
		score.Text = `<font color="#{hex(A.Color):ToHex()}">{A.Tag ~= "" and A.Tag or A.Name}</font>  {a} – {b}  <font color="#{hex(B.Color):ToHex()}">{B.Tag ~= "" and B.Tag or B.Name}</font>`
		sub.Text = `{plan.Title} · {plan.Map} · Round {a + b + 1}{if plan.Pure then " · PURE" else ""}`
	end
	drawScore()

	local function flashToast(text: string, color: Color3)
		toast.Text = text
		toast.BackgroundColor3 = color
		toast.Visible = true
		local s = New("UIScale", { Scale = 0.6, Parent = toast })
		TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		task.delay(1.3, function()
			s:Destroy()
			toast.Visible = false
		end)
	end

	local function playRound(round: any, index: number)
		local target = Match.FirstTo
		if round.W == "A" then
			a += 1
		else
			b += 1
		end
		if streakSide == round.W then
			streak += 1
		else
			streak, streakSide = 1, round.W
		end
		-- Kill feed + who died this round.
		for _, c in feed:GetChildren() do
			if c:IsA("TextLabel") then
				c:Destroy()
			end
		end
		local dead = { A = {}, B = {} }
		local seq = round.Seq or {}
		for n = math.max(1, #seq - 3), #seq do
			local k = seq[n]
			local killerSide, victimSide = if k[1] == 1 then "A" else "B", if k[1] == 1 then "B" else "A"
			local killer = plan.Teams[killerSide].Players[k[2]]
			local victim = plan.Teams[victimSide].Players[k[3]]
			local line = New("TextLabel", { Size = UDim2.fromOffset(300, 24), BackgroundColor3 = Theme.Colors.Bg, BackgroundTransparency = 0.3, FontFace = Theme.Fonts.Bold, TextSize = 14, TextColor3 = if killerSide == "A" then Theme.Colors.Accent else hex(B.Color), Text = `{killer and killer.Name or "?"}  ⦿  {victim and victim.Name or "?"}`, LayoutOrder = n, Parent = feed })
			Components.Corner(line, Theme.Radius.S)
		end
		for _, k in seq do
			dead[if k[1] == 1 then "B" else "A"][k[3]] = true
		end
		for side, list in round.Kills do
			for i, k in list do
				totals[side][i] += k
			end
		end
		drawPanels(dead)
		local won = round.W == "A"
		banner.Text = if round.Event == "Ace" then "ACE!" elseif round.Event == "Clutch" then `CLUTCH 1v{round.Clutch}!` elseif won then "Round won" else "Round lost"
		banner.TextColor3 = if won then Theme.Colors.Success else Theme.Colors.Danger
		drawScore()
		-- One caster line per round, most exciting first.
		local hero = plan.Teams[round.W].Players[round.MVP]
		local t = { team = if won then A.Name else B.Name, opponent = if won then B.Name else A.Name, player = hero and hero.Name or "?", score = `{a}–{b}`, map = plan.Map, n = round.Clutch or streak }
		local overtime = a == target - 1 and b == target - 1
		if round.Event == "Ace" or round.Event == "Clutch" then
			Caster.Show(gui, round.Event, intensity, t, 40)
			flashToast("📸 CLIP MOMENT!", Theme.Colors.Accent2)
		elseif overtime and not said.Overtime then
			said.Overtime = true
			Caster.Show(gui, "Overtime", intensity, t, 40)
		elseif (a == target - 1 or b == target - 1) and not said.MatchPoint then
			said.MatchPoint = true
			Caster.Show(gui, "MatchPoint", intensity, t, 40)
		elseif streak == 4 or streak == 7 then
			t.n = streak
			Caster.Show(gui, "Momentum", intensity, t, 40)
			flashToast(`🔥 MOMENTUM · {streak} in a row`, if won then Theme.Colors.Success else Theme.Colors.Danger)
		elseif a + b == Match.Halftime then
			Caster.Show(gui, "Halftime", intensity, t, 40)
		elseif round.Event == "Flawless" and won then
			Caster.Show(gui, "Flawless", intensity, t, 40)
		end
		-- Camera: wide every other round, otherwise a push-in on the round MVP.
		local r = rigs[round.W][round.MVP]
		if index % 2 == 1 or not r then
			camera.CFrame = CFrame.lookAt((center * CFrame.new(-34, 18, 0)).Position, center.Position + Vector3.new(0, 3, 0))
		else
			local p = r:GetPivot()
			camera.CFrame = CFrame.lookAt((p * CFrame.new(0, 3, -7)).Position, p.Position + Vector3.new(0, 2, 0))
		end
	end

	local function waitRound(): boolean
		local t = os.clock()
		while os.clock() - t < (plan.RoundSeconds or Match.RoundSeconds) / speed do
			if skipped then
				return false
			end
			task.wait()
		end
		return true
	end

	banner.Text = `{A.Name} vs {B.Name}`
	local index = 0
	if waitRound() then
		for _, round in plan.Rounds do
			index += 1
			playRound(round, index)
			if not waitRound() then
				break
			end
		end
		local quality = 0
		if not skipped and plan.ClutchRound then
			banner.Text = "MATCH POINT"
			quality = clutchMinigame(gui)
		end
		local res = getResolved(quality)
		if not skipped then
			for _, round in res.Rounds do
				index += 1
				playRound(round, index)
				if not waitRound() then
					break
				end
			end
		end
	end
	local res = getResolved(0)
	local r = res.Result
	a, b = r.Score[1], r.Score[2]
	drawScore()
	controls.Visible = false
	banner.Text = if r.Champion then "CHAMPIONS!" elseif r.Winner == "A" then "VICTORY" else "DEFEAT"
	local endTokens = { team = A.Name, opponent = B.Name, score = `{a}–{b}`, map = plan.Map }
	if r.Winner == "A" and r.Upset then
		Caster.Show(gui, "Upset", intensity, endTokens, 40)
	elseif r.Winner == "A" and r.Comeback then
		Caster.Show(gui, "Comeback", intensity, endTokens, 40)
	elseif r.Records and r.Records[1] then
		local v = A.Players[r.Records[1].Index]
		Caster.Show(gui, "Record", intensity, { player = v and v.Name or "?", n = r.Records[1].Kills }, 40)
	else
		Caster.Show(gui, if r.Winner == "A" then "Victory" else "Defeat", if r.Champion then 3 else intensity, endTokens, 40)
	end
	-- Let the closing line land over the banner, then the result screen takes the bottom of the screen.
	task.wait(if skipped then 1.2 else 2.4)
	Caster.Hide()

	local done = false
	resultScreen(gui, plan, r, function()
		done = true
	end)
	while not done do
		task.wait()
	end
	gui:Destroy()
	folder:Destroy()
	camera.CameraType = Enum.CameraType.Custom
	UIController:SetCinematic("Match", false)
	playing = false
	if r.Rewards and (r.Rewards.Cash or 0) > 0 then
		HudController:Float(`+{Format.Cash(r.Rewards.Cash)}`, Theme.Colors.Success)
	end
end

local function failToast(res: any, what: string)
	HudController:Toast(if type(res) == "table" and res.Cooldown then `Next {what} in {res.Cooldown}s`
		elseif type(res) == "table" and res.NeedStage then `Opens at Stage {res.NeedStage}`
		elseif res == "TooFar" then "Sit at your desk to play."
		elseif res == "InMatch" then "Finish your current match first."
		elseif res == "RateLimited" then "One moment…"
		else `Can't start ({tostring(res)})`, Theme.Colors.Warning)
end

-- Two-part matches (Clutch Moment between the parts): the server keeps the rest until Match/Resolve.
local function resolver(plan: any): (number) -> any
	return function(quality: number)
		local ok, res = (Net.Get("Match", "Resolve") :: RemoteFunction):InvokeServer(plan.MatchId, quality)
		return if ok then res else { Rounds = {}, Result = { Winner = "B", Score = { 0, 0 }, Ratings = { A = {}, B = {} }, Mvp = { Side = "A", Index = 1 }, Rewards = { Cash = 0, Fame = 0 }, Moments = {} } }
	end
end

function MatchController:StartPickup()
	if playing then
		return
	end
	local ok, plan = (Net.Get("Match", "StartPickup") :: RemoteFunction):InvokeServer()
	if not ok then
		if type(plan) == "table" and plan.Cooldown then
			lastStart = os.clock() - Minigames.Pickup.Cooldown + plan.Cooldown
		end
		failToast(plan, "Pickup Game")
		return
	end
	lastStart = os.clock()
	MatchController:Play(plan, resolver(plan))
end

function MatchController:StartScrim(offerId: string, pure: boolean, bans: { string }): boolean
	if playing then
		return false
	end
	local ok, plan = (Net.Get("Match", "StartScrim") :: RemoteFunction):InvokeServer(offerId, pure, bans)
	if not ok then
		failToast(plan, "scrim")
		return false
	end
	MatchController:Play(plan, resolver(plan))
	return true
end

-- Tournament replay: every round is in the plan; the result is already final.
function MatchController:Watch(plan: any, result: any)
	if playing then
		return
	end
	MatchController:Play(plan, function()
		return { Rounds = {}, Result = result }
	end)
end

return MatchController

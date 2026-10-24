--!strict
-- TutorialController ([[Tutorial & Onboarding]]): draws the Guided FTUE the server runs. Holds no state besides the
-- stall timer. One popup at a time, one arrow at a time.
--   Goal banner (top right, 3 s on a new step) → objective card (bottom center, progress bar, collapsible)
--   World target: chevron trail on the ground (team color) from your feet + Highlight on the target
--   UI target: bouncing pointer next to the button
--   Aunt Dee texts (phone popup, bottom right), Hector shouts (banner, never blocks input)
--   Stall ladder: 30 s pulse · 60 s Dee hint · 120 s Dee call with "Show me" (walks you there)
--   The stall clock pauses while a menu or cinematic is open.

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Net = require(ReplicatedStorage.Shared.Net)
local Format = require(ReplicatedStorage.Shared.Format)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Team = require(ReplicatedStorage.Shared.Config.Team)
local Steps = require(ReplicatedStorage.Shared.Config.Tutorial.Steps)
local Lines = require(ReplicatedStorage.Shared.Config.Tutorial.Lines)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local MyPlot = require(script.Parent.Parent.UI.MyPlot)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)

local TutorialController = { Tier = 6 }

local player = Players.LocalPlayer
local CHEVRON_GAP = 3.5
local MAX_CHEVRONS = 40
local POPUP_HOLD = 5.5

local overlay: ScreenGui
local hud: ScreenGui
local queue: { { Id: string, Call: boolean? } } = {}
local popupBusy = false
local stall = 0
local stallFired = { Pulse = false, Hint = false, Call = false }
local currentStep: string? = nil
local chevrons: { BasePart } = {}
local chevronFolder: Folder
local highlight: Highlight
local pointer: TextLabel
local objective: { Frame: Frame, Text: TextLabel, Bar: Frame, SetBar: (number) -> (), Value: TextLabel, Body: Frame }? = nil
local path: { Vector3 } = {}
local lastPathAt = 0
local offPlotWarned = false

local function teamColor(): Color3
	local idx = StateController:Get("Team.Colors.Primary") or Team.DefaultPrimary
	return Color3.fromHex(Team.Colors[idx] or Team.Colors[1])
end

-- Popups ----------------------------------------------------------------------------------------------------

local function showHector(text: string)
	local banner = New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.2),
		Size = UDim2.fromScale(0.8, 0.09),
		BackgroundTransparency = 1,
		TextScaled = true,
		FontFace = Theme.Fonts.Heading,
		TextColor3 = Theme.Colors.Warning,
		Text = `🎙 {text}`,
		ZIndex = 40,
		Parent = overlay,
	}, { New("UIStroke", { Thickness = 4, Color = Theme.Colors.Bg }), New("UITextSizeConstraint", { MaxTextSize = 44 }) })
	local scale = New("UIScale", { Scale = 0.3, Parent = banner })
	TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	task.delay(2.8, function()
		TweenService:Create(banner, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		task.wait(0.3)
		banner:Destroy()
	end)
end

-- Aunt Dee phone popup. call = true adds "Show me" (walks you to the target) and waits for a tap.
local function showDee(text: string, call: boolean?): ()
	local mobile = Components.IsMobile()
	-- The card itself is the tap target (a full-size child button inside the auto-sizing list would feed back).
	local tapped = false
	local card = New("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 400, 1, -Theme.Space.XXXL * 2),
		Size = UDim2.fromOffset(if mobile then 330 else 380, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Colors.Panel,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 35,
		Parent = overlay,
		Activated = function()
			if not call then
				tapped = true
			end
		end,
	})
	Components.Corner(card, Theme.Radius.L)
	Components.Stroke(card, Theme.Colors.Accent2)
	Components.Padding(card, Theme.Space.M, Theme.Space.M)
	Components.List(card, Theme.Space.S)
	local head = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 1, ZIndex = 36, Parent = card })
	local face = New("TextLabel", { Size = UDim2.fromOffset(40, 40), BackgroundColor3 = Color3.fromHex("C2A36B"), Text = "D", FontFace = Theme.Fonts.Heading, TextSize = 22, TextColor3 = Theme.Colors.Bg, ZIndex = 36, Parent = head })
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = face })
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(52, 0),
		Size = UDim2.new(1, -52, 1, 0),
		FontFace = Theme.Fonts.Bold,
		TextSize = Theme.Type.Body,
		TextColor3 = Theme.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = if call then "📞 Aunt Dee is calling…" else "💬 Aunt Dee",
		ZIndex = 36,
		Parent = head,
	})
	local msg = Components.Paragraph(text, Theme.Type.Body, Theme.Colors.Text)
	msg.LayoutOrder = 2
	msg.ZIndex = 36
	msg.Parent = card
	if call then
		local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), LayoutOrder = 3, ZIndex = 36, Parent = card })
		Components.List(row, Theme.Space.S, true)
		local show = Components.Button({ Text = "Show me", Width = 150, OnClick = function()
			tapped = true
			TutorialController:ShowMe()
		end })
		show.ZIndex = 38
		show.Parent = row
		local later = Components.Button({ Text = "Later", Kind = "Secondary", Width = 120, OnClick = function()
			tapped = true
		end })
		later.ZIndex = 38
		later.Parent = row
	end
	TweenService:Create(card, TweenInfo.new(Theme.Tween.Open, Enum.EasingStyle.Back), { Position = UDim2.new(1, -Theme.Space.L, 1, -Theme.Space.XXXL * 2) }):Play()
	local started = os.clock()
	while not tapped and (call or os.clock() - started < POPUP_HOLD) and card.Parent do
		task.wait(0.1)
		if call and os.clock() - started > 20 then
			break
		end
	end
	TweenService:Create(card, TweenInfo.new(Theme.Tween.Close), { Position = UDim2.new(1, 400, 1, -Theme.Space.XXXL * 2) }):Play()
	task.wait(Theme.Tween.Close)
	card:Destroy()
end

local function pump()
	if popupBusy then
		return
	end
	popupBusy = true
	task.spawn(function()
		while #queue > 0 do
			-- No popups during cinematics (intro, match broadcast, hire scene) or before control is handed over.
			while UIController:IsCinematic() or not HudController:IsShown() do
				task.wait(0.25)
			end
			local item = table.remove(queue, 1) :: any
			local line = Lines[item.Id]
			if line then
				local text = string.gsub(line.Text, "{team}", StateController:Get("Team.Name") or "your team")
				if line.Speaker == "Hector" then
					showHector(text)
					task.wait(0.4)
				else
					showDee(text, item.Call)
				end
			end
		end
		popupBusy = false
	end)
end

function TutorialController:Say(lineId: string, call: boolean?)
	for _, q in queue do
		if q.Id == lineId then
			return -- already queued
		end
	end
	table.insert(queue, { Id = lineId, Call = call })
	pump()
end

-- Goal banner + objective card -------------------------------------------------------------------------------

local function goalBanner(text: string)
	local banner = New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -Theme.Space.L, 0, 84),
		Size = UDim2.fromOffset(520, 56),
		BackgroundTransparency = 1,
		TextScaled = true,
		FontFace = Theme.Fonts.Heading,
		TextColor3 = Theme.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = text .. "!",
		ZIndex = 20,
		Parent = hud,
	}, { New("UIStroke", { Thickness = 4, Color = Theme.Colors.Bg }) })
	local scale = New("UIScale", { Scale = 0.6, Parent = banner })
	TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	task.delay(3, function()
		TweenService:Create(banner, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		task.wait(0.3)
		banner:Destroy()
	end)
end

local function buildObjective(slot: Frame)
	local frame = New("Frame", {
		Name = "Objective",
		Size = UDim2.fromOffset(420, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Colors.Panel,
		Visible = false,
		Parent = slot,
	})
	Components.Corner(frame, Theme.Radius.M)
	Components.Stroke(frame, Theme.Colors.Accent)
	Components.Padding(frame, Theme.Space.L, Theme.Space.M)
	Components.List(frame, Theme.Space.S)
	local top = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 1, Parent = frame })
	local text = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 1, 0),
		FontFace = Theme.Fonts.Bold,
		TextSize = Theme.Type.Body + 2,
		TextColor3 = Theme.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "",
		Parent = top,
	})
	local body = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = frame })
	Components.List(body, Theme.Space.XS)
	local bar, setBar = Components.Bar(Theme.Colors.Success)
	bar.LayoutOrder = 1
	bar.Parent = body
	local value = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Caption, TextColor3 = Theme.Colors.TextMuted, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = body })
	local arrow = New("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.fromOffset(36, 28), BackgroundTransparency = 1, Text = "-", FontFace = Theme.Fonts.Bold, TextSize = 22, TextColor3 = Theme.Colors.TextMuted, Parent = top })
	arrow.Activated:Connect(function()
		body.Visible = not body.Visible
		arrow.Text = if body.Visible then "-" else "+"
	end)
	objective = { Frame = frame, Text = text, Bar = bar, SetBar = setBar, Value = value, Body = body }
end

local function refreshObjective()
	local o = objective
	if not o then
		return
	end
	local step = currentStep and Steps.ById[currentStep]
	o.Frame.Visible = step ~= nil
	if not step then
		return
	end
	o.Text.Text = "🎯 " .. step.Goal
	if step.Progress then
		local data = StateController:Get("")
		local ok, have, need, what = pcall(step.Progress, data, {})
		if ok then
			o.Bar.Visible = true
			o.SetBar(have / need)
			o.Value.Visible = true
			o.Value.Text = if what == "Cash" then `{Format.Cash(have)} / {Format.Cash(need)}` else `★ {have} / {need}`
			if what == "Cash" and have < need and (stall > Steps.Stall.Hint) and (StateController:Get("Currencies.Cash") or 0) < 20 then
				TutorialController:Say("TUT_BROKE")
			end
			return
		end
	end
	o.Bar.Visible = false
	o.Value.Visible = false
end

-- Targets ---------------------------------------------------------------------------------------------------

local function seatedAtDesk(): boolean
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local seat = humanoid and humanoid.SeatPart
	return seat ~= nil and seat:GetAttribute("Anchor") == "FounderSeat"
end

local function visibleGui(g: GuiObject?): boolean
	local node: Instance? = g
	while node and node:IsA("GuiObject") do
		if not node.Visible then
			return false
		end
		node = node.Parent
	end
	if node and node:IsA("ScreenGui") then
		return node.Enabled
	end
	return node ~= nil
end

-- Current target: ("Ui", gui) | ("World", instance) | nil.
local function target(): (string?, any)
	local step = currentStep and Steps.ById[currentStep]
	if not step then
		return nil, nil
	end
	local t = step.Target
	if t.UiWhenSeated and seatedAtDesk() then
		local g = UIController:GetTarget(t.UiWhenSeated)
		if g and visibleGui(g) then
			return "Ui", g
		end
		return nil, nil -- seated: the desk panel is the target, nothing in the world
	end
	if t.Ui then
		local g = UIController:GetTarget(t.Ui)
		if g and visibleGui(g) then
			return "Ui", g
		end
	end
	if t.World then
		local inst = MyPlot.Find(t.World)
		if inst then
			return "World", inst
		end
	end
	return nil, nil
end

local function worldPos(inst: Instance): Vector3
	if inst:IsA("Model") then
		return inst:GetPivot().Position
	end
	return (inst :: BasePart).Position
end

local function ensureChevrons()
	while #chevrons < MAX_CHEVRONS do
		local p = New("Part", {
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
			Transparency = 1,
			Size = Vector3.new(2.2, 0.05, 2.2),
			Parent = chevronFolder,
		})
		local gui = New("SurfaceGui", { Face = Enum.NormalId.Top, LightInfluence = 0, AlwaysOnTop = false, Parent = p })
		New("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			TextScaled = true,
			FontFace = Theme.Fonts.Heading,
			Text = ">",
			Rotation = -90,
			TextColor3 = Color3.new(1, 1, 1),
			Parent = gui,
		}, { New("UIStroke", { Thickness = 2, Color = Theme.Colors.Bg }) })
		table.insert(chevrons, p)
	end
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function hideChevrons()
	for _, c in chevrons do
		c.Parent = nil
	end
end

local function computePath(from: Vector3, to: Vector3)
	lastPathAt = os.clock()
	task.spawn(function()
		local p = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true })
		local ok = pcall(function()
			p:ComputeAsync(from, to)
		end)
		if ok and p.Status == Enum.PathStatus.Success then
			local pts = {}
			for _, w in p:GetWaypoints() do
				table.insert(pts, w.Position)
			end
			path = pts
		else
			path = { from, to }
		end
	end)
end

-- Lays chevrons along the path, starting a few studs ahead of the player.
local function drawChevrons(color: Color3, pulse: boolean)
	ensureChevrons()
	rayParams.FilterDescendantsInstances = { chevronFolder, player.Character :: any }
	local placed = 0
	local carry = 2
	for i = 1, #path - 1 do
		local a, b = path[i], path[i + 1]
		local seg = b - a
		local len = Vector3.new(seg.X, 0, seg.Z).Magnitude
		if len > 0.1 then
			local d = carry
			while d < len and placed < MAX_CHEVRONS do
				local pos = a + seg * (d / len)
				placed += 1
				local c = chevrons[placed]
				local flat = Vector3.new(seg.X, 0, seg.Z).Unit
				-- Sit on whatever floor is under this point (waypoints are at foot level, the first point is the HRP).
				local hit = Workspace:Raycast(pos + Vector3.new(0, 4, 0), Vector3.new(0, -14, 0), rayParams)
				local ground = if hit then Vector3.new(pos.X, hit.Position.Y + 0.08, pos.Z) else pos - Vector3.new(0, 2.8, 0)
				c.CFrame = CFrame.lookAt(ground, ground + flat)
				local label = (c:FindFirstChildOfClass("SurfaceGui") :: SurfaceGui):FindFirstChildOfClass("TextLabel") :: TextLabel
				label.TextColor3 = color
				label.TextTransparency = if pulse then 0.1 * math.sin(os.clock() * 8) + 0.1 else 0.15
				c.Parent = chevronFolder
				d += CHEVRON_GAP
			end
			carry = d - len
		end
	end
	for i = placed + 1, #chevrons do
		chevrons[i].Parent = nil
	end
end

local pointerDead = false

-- The UI pointer is parented to its target button so it follows layouts; it dies when the target is destroyed.
local function makePointer(): TextLabel
	pointerDead = false
	local p = New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Size = UDim2.fromOffset(48, 48),
		BackgroundTransparency = 1,
		FontFace = Theme.Fonts.Heading,
		TextSize = 44,
		TextColor3 = Theme.Colors.Warning,
		Text = "▼",
		Visible = false,
		ZIndex = 90,
		Parent = overlay,
	}, { New("UIStroke", { Thickness = 3, Color = Theme.Colors.Bg }) })
	p.Destroying:Connect(function()
		if pointer == p then
			pointerDead = true
		end
	end)
	return p
end

-- "Show me": walk your avatar to the current world target.
function TutorialController:ShowMe()
	local kind, inst = target()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if kind ~= "World" or not humanoid then
		return
	end
	if humanoid.SeatPart then
		humanoid.Sit = false
	end
	for _, w in path do
		humanoid:MoveTo(w)
		local reached = false
		local conn = humanoid.MoveToFinished:Connect(function()
			reached = true
		end)
		local t = os.clock()
		while not reached and os.clock() - t < 3 do
			task.wait()
		end
		conn:Disconnect()
	end
	local _ = inst
end

-- Per-frame draw: arrow/pointer, highlight, stall ladder.
local function update(dt: number)
	local kind, inst = target()
	local paused = UIController:IsMenuOpen() or UIController:IsCinematic()
	if currentStep and Steps.ById[currentStep] and not paused then
		stall += dt
	end
	local pulse = stall >= Steps.Stall.Pulse

	-- UI pointer
	if kind == "Ui" and not UIController:IsCinematic() then
		-- The pointer rides on the target itself, so it follows it through layouts and UIScale.
		local g = inst :: GuiObject
		if pointerDead then
			pointer = makePointer() -- the last target was destroyed and took the pointer with it
		end
		if pointer.Parent ~= g then
			pointer.Parent = g
		end
		pointer.Visible = true
		local bob = math.sin(os.clock() * (if pulse then 9 else 5)) * 6
		pointer.Position = UDim2.new(0.5, 0, 0, -4 + bob)
	else
		pointer.Visible = false
	end

	-- World arrow + highlight
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if kind == "World" and root and not paused then
		local goal = worldPos(inst)
		highlight.Adornee = inst
		highlight.Enabled = true
		highlight.FillTransparency = if pulse then 0.55 + 0.25 * math.sin(os.clock() * 8) else 0.8
		if os.clock() - lastPathAt > 1 then
			computePath(root.Position, goal)
		end
		if #path > 0 then
			path[1] = root.Position -- always start at your feet
		end
		if (root.Position - goal).Magnitude > 7 then
			drawChevrons(teamColor(), pulse)
		else
			hideChevrons()
		end
		local origin = MyPlot.Origin()
		if origin and not offPlotWarned and (root.Position - (origin * CFrame.new(0, 0, -128)).Position).Magnitude > 260 then
			offPlotWarned = true
			TutorialController:Say("TUT_OFFPLOT")
		end
	else
		highlight.Enabled = false
		hideChevrons()
	end

	-- Stall ladder
	local step = currentStep and Steps.ById[currentStep]
	if step then
		if stall >= Steps.Stall.Hint and not stallFired.Hint then
			stallFired.Hint = true
			if step.Lines.Hint then
				TutorialController:Say(step.Lines.Hint)
			end
			(Net.Get("Tutorial", "Stall") :: RemoteEvent):FireServer(step.Id, 1)
		end
		if stall >= Steps.Stall.Call and not stallFired.Call then
			stallFired.Call = true
			if step.Lines.Call then
				TutorialController:Say(step.Lines.Call, true)
			end
			(Net.Get("Tutorial", "Stall") :: RemoteEvent):FireServer(step.Id, 2)
		end
	end
end

local function onStep(stepId: string?)
	if stepId == currentStep then
		return
	end
	currentStep = if stepId and Steps.ById[stepId] then stepId else nil
	stall = 0
	stallFired = { Pulse = false, Hint = false, Call = false }
	offPlotWarned = false
	path = {}
	lastPathAt = 0
	local step = currentStep and Steps.ById[currentStep]
	if step then
		goalBanner(step.Goal)
		if step.Lines.Intro then
			TutorialController:Say(step.Lines.Intro)
		end
	end
	refreshObjective()
end

-- Promotion banner (Stage/Promoted from ProgressionService): "Café Rookies" after Stage 1, "Local Circuit" at 500 Fame.
local function promoted(stage: number, name: string, text: string?)
	UIController:SetMenu("Promotion", true)
	local dim = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Colors.Bg, BackgroundTransparency = 1, Active = true, ZIndex = 45, Parent = overlay })
	TweenService:Create(dim, TweenInfo.new(0.3), { BackgroundTransparency = 0.25 }):Play()
	local col = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromScale(0.8, 0.5), BackgroundTransparency = 1, ZIndex = 46, Parent = dim })
	Components.List(col, Theme.Space.L, false, Enum.HorizontalAlignment.Center)
	New("TextLabel", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.H1, TextColor3 = Theme.Colors.Warning, Text = "PROMOTED!", LayoutOrder = 1, ZIndex = 47, Parent = col })
	local big = New("TextLabel", { Size = UDim2.new(1, 0, 0, 96), BackgroundTransparency = 1, TextScaled = true, FontFace = Theme.Fonts.Heading, TextColor3 = Theme.Colors.Text, Text = `Stage {stage}: {name}`, LayoutOrder = 2, ZIndex = 47, Parent = col }, { New("UIStroke", { Thickness = 4, Color = Theme.Colors.Accent }) })
	New("TextLabel", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.TextMuted, Text = text or "", TextWrapped = true, LayoutOrder = 3, ZIndex = 47, Parent = col })
	local scale = New("UIScale", { Scale = 0.2, Parent = big })
	TweenService:Create(scale, TweenInfo.new(0.5, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	local ok = Components.Button({ Text = "Let's go!", Width = 220, OnClick = function()
		dim:Destroy()
		UIController:SetMenu("Promotion", false)
	end })
	ok.LayoutOrder = 4
	ok.ZIndex = 48
	ok.Parent = col
end

function TutorialController:Start()
	StateController:WaitUntilLoaded()
	overlay = UIController:GetGui("Overlay")
	hud = UIController:GetGui("HUD")
	chevronFolder = New("Folder", { Name = "TutorialChevrons", Parent = Workspace })
	highlight = New("Highlight", { FillColor = Theme.Colors.Accent, OutlineColor = Theme.Colors.Text, FillTransparency = 0.8, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Enabled = false, Parent = chevronFolder })
	pointer = makePointer()

	Net.Get("Tutorial", "Lines").OnClientEvent:Connect(function(ids: { string })
		for _, id in ids do
			TutorialController:Say(id)
		end
	end)
	Net.Get("Stage", "Promoted").OnClientEvent:Connect(promoted)

	HudController:WaitUntilShown()
	local slot = HudController:GetObjectiveSlot()
	if slot then
		buildObjective(slot)
	end
	StateController:Observe("Tutorial.Step", onStep)
	StateController:Observe("Currencies", refreshObjective)
	StateController:Observe("Ftue", refreshObjective)
	RunService.Heartbeat:Connect(update)
end

return TutorialController

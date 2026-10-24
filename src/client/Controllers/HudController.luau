--!strict
-- HudController ([[Screen - Main HUD]]): currency pills, stage ring, rail buttons, contextual buttons, toasts,
-- "Saved ✓" tick and floating "+N" rewards. Stage 1 shows only the Cash pill (Gems from Stage 2, Followers from
-- Stage 4; Fame is the stage ring). The HUD stays hidden until FlowController hands control over after the intro.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Net = require(ReplicatedStorage.Shared.Net)
local Format = require(ReplicatedStorage.Shared.Format)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Stages = require(ReplicatedStorage.Shared.Config.Stages)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)

local HudController = { Tier = 2 }

local PILLS = {
	{ Currency = "Cash", Color = Theme.Colors.Success, Format = Format.Cash, Stage = 1 },
	{ Currency = "Gems", Color = Theme.Colors.Accent, Format = Format.Short, Stage = 2 },
	{ Currency = "Followers", Color = Theme.Colors.Accent2, Format = Format.Short, Stage = 4 },
}

local gui: ScreenGui? = nil
local toasts: Frame? = nil
local pending: { { any } } = {}
local pills: { [string]: Frame } = {}
local rails: { [string]: Frame } = {}
local railButtons: { [string]: TextButton } = {}
local badges: { [string]: TextLabel } = {}
local contextSlot: Frame? = nil
local objectiveSlot: Frame? = nil
local contexts: { [string]: TextButton } = {}
local built = false
local shown = false
local waitingShow: { thread } = {}

function HudController:Toast(text: string, color: Color3?)
	if toasts and shown then
		Components.Toast(toasts, text, color)
	else
		table.insert(pending, { text, color })
	end
end

function HudController:GetGui(): ScreenGui?
	return gui
end

function HudController:GetPill(currency: string): Frame?
	return pills[currency]
end

-- Floating reward text that rises from a world part (or the Cash pill when no part) and fades in ~1 s.
function HudController:Float(text: string, color: Color3?, part: BasePart?)
	local c = color or Theme.Colors.Success
	if part then
		local board = New("BillboardGui", {
			Size = UDim2.fromOffset(160, 40),
			StudsOffsetWorldSpace = Vector3.new(0, 3, 0),
			AlwaysOnTop = true,
			Adornee = part,
			Parent = gui,
		})
		local label = New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			FontFace = Theme.Fonts.Heading,
			TextSize = 28,
			TextColor3 = c,
			TextStrokeTransparency = 0.2,
			Text = text,
			Parent = board,
		})
		TweenService:Create(board, TweenInfo.new(1.1), { StudsOffsetWorldSpace = Vector3.new(0, 7, 0) }):Play()
		TweenService:Create(label, TweenInfo.new(1.1), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		task.delay(1.2, board.Destroy, board)
		return
	end
	local pill = pills.Cash
	if not pill or not gui then
		return
	end
	local label = New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, Theme.Space.S + Theme.Components.CurrencyPill.Height + Theme.Space.L),
		Size = UDim2.fromOffset(200, 32),
		FontFace = Theme.Fonts.Heading,
		TextSize = Theme.Type.H2,
		TextColor3 = c,
		Text = text,
		ZIndex = 5,
		Parent = gui, -- not the pill: its list layout would swallow the position
	})
	New("UIStroke", { Thickness = 2, Color = Theme.Colors.Bg, Parent = label })
	TweenService:Create(label, TweenInfo.new(1), { Position = UDim2.new(0.5, 0, 0, Theme.Space.S + Theme.Components.CurrencyPill.Height + Theme.Space.XXXL * 2), TextTransparency = 1 }):Play()
	task.delay(1.05, label.Destroy, label)
end

-- Rail buttons ([[Screen - Main HUD]] → Button style): chunky colored panel, icon + label (icon only on mobile),
-- red "!" or count badge top-right. side = "Left" | "Right"; order fixes the slot so unlocks never shuffle others.
function HudController:AddRail(side: string, id: string, props: { Icon: string, Label: string, Color: Color3, Order: number, OnClick: () -> () }): TextButton
	local rail = rails[side]
	assert(rail, "[HUD] rails not built")
	local mobile = Components.IsMobile()
	local size = if mobile then Theme.Components.RailButton.Mobile else Theme.Components.RailButton.Desktop
	local button = New("TextButton", {
		Name = id,
		AutoButtonColor = false,
		Size = UDim2.fromOffset(if mobile then size else size * 2.3, size),
		BackgroundColor3 = props.Color,
		Text = "",
		LayoutOrder = props.Order,
		Visible = false,
		Parent = rail,
		Activated = props.OnClick,
	})
	Components.Corner(button, Theme.Radius.M)
	New("UIStroke", { Thickness = 3, Color = Theme.Colors.Bg, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = button })
	local inner = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -6, 1, -6), Position = UDim2.fromOffset(3, 3), Parent = button })
	Components.Corner(inner, Theme.Radius.M - 2)
	New("UIStroke", { Thickness = 1.5, Color = Components.Brighten(props.Color, 0.25), Parent = inner })
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		FontFace = Theme.Fonts.Heading,
		TextSize = size * 0.5,
		TextColor3 = Theme.Colors.Text,
		Text = props.Icon,
		Parent = button,
	})
	if not mobile then
		local label = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(size - 4, 0),
			Size = UDim2.new(1, -size, 1, 0),
			FontFace = Theme.Fonts.Heading,
			TextSize = Theme.Type.Body,
			TextColor3 = Theme.Colors.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = props.Label,
			Parent = button,
		})
		New("UIStroke", { Thickness = 1.5, Color = Theme.Colors.Bg, Parent = label })
	end
	local badge = New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -4, 0, 4),
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = Theme.Colors.Danger,
		FontFace = Theme.Fonts.Heading,
		TextSize = 16,
		TextColor3 = Theme.Colors.Text,
		Text = "!",
		Visible = false,
		ZIndex = 3,
		Parent = button,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = badge })
	railButtons[id] = button
	badges[id] = badge
	return button
end

-- Shows a rail button with the unlock pop (0.3 s Back + sparkle scale).
function HudController:ShowRail(id: string, visible: boolean)
	local button = railButtons[id]
	if not button or button.Visible == visible then
		return
	end
	button.Visible = visible
	if visible then
		local scale = New("UIScale", { Scale = 0.2, Parent = button })
		TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		task.delay(0.35, scale.Destroy, scale)
	end
end

function HudController:SetBadge(id: string, text: string?)
	local badge = badges[id]
	if badge then
		badge.Visible = text ~= nil
		badge.Text = text or ""
	end
end

-- Contextual buttons above the objective card, max 2, newest on top.
function HudController:SetContext(id: string, text: string, color: Color3, onClick: () -> ())
	if not contextSlot then
		return
	end
	local existing = contexts[id]
	if existing then
		existing.Text = text
		return
	end
	local count = 0
	for _ in contexts do
		count += 1
	end
	if count >= 2 then
		return
	end
	local button = Components.Button({ Text = text, Width = 260, Color = color, OnClick = onClick })
	button.Name = id
	button.LayoutOrder = -math.floor(os.clock() * 10)
	button.Parent = contextSlot
	contexts[id] = button
	UIController:RegisterTarget(id, button)
end

function HudController:ClearContext(id: string)
	local b = contexts[id]
	if b then
		b:Destroy()
		contexts[id] = nil
		UIController:RegisterTarget(id, nil)
	end
end

-- The objective card lives here; TutorialController fills it.
function HudController:GetObjectiveSlot(): Frame?
	return objectiveSlot
end

local function buildSavedTick(parent: Instance): TextLabel
	local tick = Components.Label({ Text = "Saved", Font = Theme.Fonts.Body, Size = Theme.Type.Caption, Color = Theme.Colors.Success })
	tick.AnchorPoint = Vector2.new(0.5, 0)
	-- Under the currency row (not inside the pill: its list layout would place the tick next to the number).
	tick.Position = UDim2.new(0.5, 0, 0, Theme.Space.S + Theme.Components.CurrencyPill.Height + Theme.Space.XS)
	tick.TextTransparency = 1
	local outline = tick:FindFirstChildOfClass("UIStroke")
	if outline then
		outline.Transparency = 1
	end
	tick.Parent = parent
	return tick
end

local function flashSaved(tick: TextLabel)
	local outline = tick:FindFirstChildOfClass("UIStroke") -- fade the outline with the text, or it lingers
	TweenService:Create(tick, TweenInfo.new(Theme.Tween.Fill), { TextTransparency = 0 }):Play()
	if outline then
		TweenService:Create(outline, TweenInfo.new(Theme.Tween.Fill), { Transparency = 0.3 }):Play()
	end
	task.delay(1.5, function()
		TweenService:Create(tick, TweenInfo.new(Theme.Tween.Open), { TextTransparency = 1 }):Play()
		if outline then
			TweenService:Create(outline, TweenInfo.new(Theme.Tween.Open), { Transparency = 1 }):Play()
		end
	end)
end

local function buildStageRing(parent: ScreenGui)
	local box = New("Frame", {
		Name = "StageRing",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -Theme.Space.L, 0, Theme.Space.S),
		Size = UDim2.fromOffset(220, 64),
		BackgroundColor3 = Theme.Colors.Panel,
		Parent = parent,
	})
	Components.Corner(box, Theme.Radius.M)
	Components.Stroke(box, Theme.Colors.Warning)
	Components.Padding(box, Theme.Space.M, Theme.Space.S)
	local title = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		FontFace = Theme.Fonts.Heading,
		TextSize = 18,
		TextColor3 = Theme.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = box,
	})
	local track, set = Components.Bar(Theme.Colors.Warning, 10)
	track.Position = UDim2.fromOffset(0, 28)
	track.Size = UDim2.new(0.62, 0, 0, 10)
	track.Parent = box
	local fame = New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 22),
		Size = UDim2.new(0.36, 0, 0, 22),
		FontFace = Theme.Fonts.Bold,
		TextSize = 15,
		TextColor3 = Theme.Colors.Warning,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = box,
	})
	local function refresh()
		local stage = StateController:Get("Stage") or 1
		local value = StateController:Get("Currencies.Fame") or 0
		local current, nextStage = Stages[stage], Stages[stage + 1]
		title.Text = `Stage {stage} · {if current then current.Name else ""}` -- no upper(): it skips accents ("CAFé")
		if nextStage then
			fame.Text = `★ {Format.Short(value)}/{Format.Short(nextStage.Fame)}`
			set((value - current.Fame) / (nextStage.Fame - current.Fame))
		else
			fame.Text = `★ {Format.Short(value)}`
			set(1)
		end
	end
	StateController:Observe("Currencies.Fame", refresh)
	StateController:Observe("Stage", refresh)
end

local function build(screen: ScreenGui)
	gui = screen
	local row = Components.Row(Theme.Components.CurrencyPill.Gap)
	row.Name = "Currencies"
	row.AnchorPoint = Vector2.new(0.5, 0)
	row.Position = UDim2.new(0.5, 0, 0, Theme.Space.S)
	row.Parent = screen

	local savedTick: TextLabel? = nil
	for i, p in PILLS do
		local pill = Components.CurrencyPill(Theme.Icons[p.Currency], p.Color, p.Format, i)
		pill.Frame.Name = p.Currency
		pill.Frame.Parent = row
		pills[p.Currency] = pill.Frame
		local first = true
		StateController:Observe("Currencies." .. p.Currency, function(value)
			pill.Set(tonumber(value) or 0, not first)
			first = false
		end)
		StateController:Observe("Stage", function(stage)
			pill.Frame.Visible = (stage or 1) >= p.Stage
		end)
		if p.Currency == "Cash" then
			savedTick = buildSavedTick(screen)
		end
	end
	buildStageRing(screen)

	for _, side in { "Left", "Right" } do
		local rail = New("Frame", {
			Name = side .. "Rail",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(if side == "Left" then 0 else 1, 0.5),
			Position = UDim2.new(if side == "Left" then 0 else 1, if side == "Left" then Theme.Space.L else -Theme.Space.L, 0.45, 0),
			Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			Parent = screen,
		})
		Components.List(rail, Theme.Space.S, false, if side == "Left" then Enum.HorizontalAlignment.Left else Enum.HorizontalAlignment.Right)
		rails[side] = rail
	end

	-- Bottom center: contextual buttons above the objective card.
	local bottom = New("Frame", {
		Name = "Bottom",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -Theme.Space.XL),
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		Parent = screen,
	})
	Components.List(bottom, Theme.Space.S, false, Enum.HorizontalAlignment.Center)
	contextSlot = New("Frame", { Name = "ContextSlot", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 1, Parent = bottom })
	Components.List(contextSlot :: Frame, Theme.Space.S, false, Enum.HorizontalAlignment.Center)
	objectiveSlot = New("Frame", { Name = "ObjectiveSlot", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 2, Parent = bottom })

	local list = New("Frame", {
		Name = "Toasts",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.25),
		AutomaticSize = Enum.AutomaticSize.XY,
		Parent = screen,
	})
	Components.List(list, Theme.Space.S, false, Enum.HorizontalAlignment.Center)
	toasts = list

	Net.Get("Data", "Saved").OnClientEvent:Connect(function()
		if savedTick then
			flashSaved(savedTick)
		end
	end)
	Net.Get("Economy", "OfflineEarned").OnClientEvent:Connect(function(amount: number, seconds: number)
		local minutes = math.floor(seconds / 60)
		HudController:Toast(`Welcome back! Your team earned {Format.Cash(amount)} in {minutes} min.`, Theme.Colors.Success)
	end)
	built = true
end

-- Called by FlowController when control is handed to the player.
function HudController:Show()
	while not built do
		task.wait()
	end
	if shown then
		return
	end
	shown = true
	local screen = gui :: ScreenGui
	screen:SetAttribute("Ready", true)
	screen.Enabled = not UIController:IsCinematic()
	for _, t in pending do
		HudController:Toast(t[1], t[2])
	end
	table.clear(pending)
	for _, thread in waitingShow do
		task.spawn(thread)
	end
	table.clear(waitingShow)
end

function HudController:IsShown(): boolean
	return shown
end

function HudController:WaitUntilShown()
	if not shown then
		table.insert(waitingShow, coroutine.running())
		coroutine.yield()
	end
end

function HudController:WaitUntilBuilt()
	while not built do
		task.wait()
	end
end

function HudController:Start()
	local screen = UIController:GetGui("HUD")
	StateController:WaitUntilLoaded()
	build(screen)
end

return HudController

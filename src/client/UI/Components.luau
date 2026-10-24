--!strict
-- Style Guide components built from Theme tokens. Sizes are 1080p design units (UIScale does the rest);
-- layout comes from anchors, UIListLayout and AutomaticSize, never from hardcoded screen positions.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(ReplicatedStorage.Shared.Config.Theme)

local Components = {}

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function stroke(parent: Instance, color: Color3): UIStroke
	local s = Instance.new("UIStroke")
	s.Thickness = Theme.Stroke.Thickness
	s.Transparency = Theme.Stroke.Transparency
	s.Color = color
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function padding(parent: Instance, x: number, y: number)
	local p = Instance.new("UIPadding")
	p.PaddingLeft, p.PaddingRight = UDim.new(0, x), UDim.new(0, x)
	p.PaddingTop, p.PaddingBottom = UDim.new(0, y), UDim.new(0, y)
	p.Parent = parent
end

function Components.Label(props: { Text: string, Font: Font, Size: number, Color: Color3?, Order: number? }): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.AutomaticSize = Enum.AutomaticSize.X
	l.Size = UDim2.fromOffset(0, props.Size)
	l.FontFace = props.Font
	l.TextSize = props.Size
	l.TextColor3 = props.Color or Theme.Colors.Text
	l.Text = props.Text
	l.LayoutOrder = props.Order or 0
	local s = Instance.new("UIStroke") -- readable over busy backgrounds
	s.Thickness = 1.5
	s.Color = Theme.Colors.Bg
	s.Transparency = 0.3
	s.Parent = l
	return l
end

-- Row that centers its children horizontally with the given gap.
function Components.Row(gap: number): Frame
	local f = Instance.new("Frame")
	f.BackgroundTransparency = 1
	f.AutomaticSize = Enum.AutomaticSize.XY
	f.Size = UDim2.fromOffset(0, 0)
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, gap)
	layout.Parent = f
	return f
end

export type Pill = { Frame: Frame, Set: (value: number, animate: boolean) -> () }

-- Currency pill: icon left, number right, h 40. Count-up 0.4 s; pulse green on gain, red on spend.
function Components.CurrencyPill(icon: string, iconColor: Color3, format: (number) -> string, order: number): Pill
	local spec = Theme.Components.CurrencyPill
	local frame = Components.Row(Theme.Space.S)
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.Size = UDim2.fromOffset(0, spec.Height)
	frame.BackgroundTransparency = 0
	frame.BackgroundColor3 = Theme.Colors.Panel
	frame.LayoutOrder = order
	corner(frame, Theme.Radius.S)
	local edge = stroke(frame, Theme.Colors.Accent)
	padding(frame, Theme.Space.M, 0)
	local scale = Instance.new("UIScale")
	scale.Parent = frame

	Components.Label({ Text = icon, Font = Theme.Fonts.Bold, Size = Theme.Type.Number, Color = iconColor, Order = 1 }).Parent = frame
	local number = Components.Label({ Text = "", Font = Theme.Fonts.Bold, Size = Theme.Type.Number, Order = 2 })
	number.Parent = frame

	local shown = Instance.new("NumberValue")
	shown.Changed:Connect(function(v)
		number.Text = format(v)
	end)
	local current: number? = nil

	local function pulse(color: Color3)
		edge.Color = color
		edge.Transparency = 0
		local up = TweenService:Create(scale, TweenInfo.new(Theme.Tween.Pulse, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), { Scale = Theme.Tween.PulseScale })
		up:Play()
		TweenService:Create(edge, TweenInfo.new(Theme.Tween.CountUp), { Color = Theme.Colors.Accent, Transparency = Theme.Stroke.Transparency }):Play()
	end

	local function set(value: number, animate: boolean)
		if current == value then
			return
		end
		local previous = current
		current = value
		if not animate or previous == nil then
			shown.Value = value
			number.Text = format(value)
			return
		end
		TweenService:Create(shown, TweenInfo.new(Theme.Tween.CountUp, Enum.EasingStyle.Quad), { Value = value }):Play()
		pulse(if value > previous then Theme.Colors.Success else Theme.Colors.Danger)
	end

	return { Frame = frame, Set = set }
end

-- Toast: w 360 h 64, slides in from the top, holds 3 s, slides out. Max 2 visible; extras replace the oldest.
function Components.Toast(container: Frame, text: string, color: Color3?)
	local spec = Theme.Components.Toast
	local existing = {}
	for _, child in container:GetChildren() do
		if child:IsA("Frame") then
			table.insert(existing, child)
		end
	end
	if #existing >= spec.Max then
		existing[1]:Destroy()
	end

	local holder = Instance.new("Frame") -- fixed slot in the list; the card slides inside it
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromOffset(spec.Width, spec.Height)
	holder.LayoutOrder = os.clock() * 1000 // 1
	holder.ClipsDescendants = false

	local card = Instance.new("Frame")
	card.BackgroundColor3 = Theme.Colors.Panel
	card.Size = UDim2.fromScale(1, 1)
	card.Position = UDim2.fromScale(0, -1)
	card.BackgroundTransparency = 1
	corner(card, Theme.Radius.M)
	stroke(card, color or Theme.Colors.Accent)
	padding(card, Theme.Space.L, Theme.Space.S)
	card.Parent = holder

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.FontFace = Theme.Fonts.Body
	label.TextSize = Theme.Type.Body
	label.TextColor3 = Theme.Colors.Text
	label.TextWrapped = true
	label.Text = text
	label.TextTransparency = 1
	label.Parent = card

	holder.Parent = container
	local info = TweenInfo.new(Theme.Tween.Open, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(card, info, { Position = UDim2.fromScale(0, 0), BackgroundTransparency = 0 }):Play()
	TweenService:Create(label, info, { TextTransparency = 0 }):Play()

	task.delay(Theme.Tween.Open + spec.Hold, function()
		if not holder.Parent then
			return
		end
		local out = TweenInfo.new(Theme.Tween.Close)
		TweenService:Create(card, out, { Position = UDim2.fromScale(0, -1), BackgroundTransparency = 1 }):Play()
		TweenService:Create(label, out, { TextTransparency = 1 }):Play()
		task.wait(Theme.Tween.Close)
		holder:Destroy()
	end)
end

-- Full-screen blocking overlay with a title and a line of text (shutdown / update message).
function Components.Overlay(gui: ScreenGui, title: string, body: string): Frame
	local dim = Instance.new("Frame")
	dim.Name = "Overlay"
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Theme.Colors.Bg
	dim.BackgroundTransparency = 1
	dim.Active = true -- swallow input
	dim.ZIndex = 50

	local column = Instance.new("Frame")
	column.BackgroundTransparency = 1
	column.AnchorPoint = Vector2.new(0.5, 0.5)
	column.Position = UDim2.fromScale(0.5, 0.5)
	column.Size = UDim2.fromScale(0.9, 0)
	column.AutomaticSize = Enum.AutomaticSize.Y
	column.ZIndex = 51
	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, Theme.Space.L)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = column
	column.Parent = dim

	local t = Components.Label({ Text = title, Font = Theme.Fonts.Heading, Size = Theme.Type.H1, Color = Theme.Colors.Accent, Order = 1 })
	t.ZIndex = 52
	t.Parent = column
	local b = Components.Label({ Text = body, Font = Theme.Fonts.Body, Size = Theme.Type.Body, Order = 2 })
	b.AutomaticSize = Enum.AutomaticSize.Y
	b.Size = UDim2.fromScale(1, 0)
	b.TextWrapped = true
	b.ZIndex = 52
	b.Parent = column

	dim.Parent = gui
	TweenService:Create(dim, TweenInfo.new(Theme.Tween.Open), { BackgroundTransparency = 0.15 }):Play()
	return dim
end

-- M1 components ------------------------------------------------------------------------------------------------
local New = require(script.Parent.New)
local UserInputService = game:GetService("UserInputService")
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Roles = require(ReplicatedStorage.Shared.Config.Roles)
local Traits = require(ReplicatedStorage.Shared.Config.Traits)

Components.Corner = corner
Components.Stroke = stroke
Components.Padding = padding

-- Phone-sized touch device (no keyboard): rail buttons 52, modals 95% wide ([[UI Style Guide]]).
function Components.IsMobile(): boolean
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Components.Brighten(c: Color3, amount: number): Color3
	local h, s, v = c:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(v + amount, 0, 1))
end

-- Returns (button, setEnabled).
-- Primary (cyan fill, dark text, h 56), Secondary (panel fill, cyan stroke, h 48), Danger (h 48).
-- States: hover brighten 10%, pressed scale 0.95, disabled 40% opacity.
function Components.Button(props: { Text: string, Kind: string?, Width: number?, Order: number?, Color: Color3?, OnClick: (() -> ())? }): (TextButton, (boolean) -> ())
	local kind = props.Kind or "Primary"
	local spec = if kind == "Primary" then Theme.Components.PrimaryButton else Theme.Components.SecondaryButton
	local fill = props.Color or (if kind == "Primary" then Theme.Colors.Accent elseif kind == "Danger" then Theme.Colors.Danger else Theme.Colors.Panel)
	local scale = New("UIScale", {})
	local button = New("TextButton", {
		AutoButtonColor = false,
		Size = UDim2.fromOffset(props.Width or Theme.Components.PrimaryButton.MinWidth, spec.Height),
		BackgroundColor3 = fill,
		Text = props.Text,
		FontFace = Theme.Fonts.Heading,
		TextSize = Theme.Type.Body + 2,
		TextColor3 = if kind == "Primary" then Theme.Colors.Bg else Theme.Colors.Text,
		LayoutOrder = props.Order or 0,
	}, { scale })
	corner(button, Theme.Radius.M)
	if kind == "Secondary" then
		stroke(button, Theme.Colors.Accent)
	end
	local enabled = true
	button.MouseEnter:Connect(function()
		if enabled then
			TweenService:Create(button, TweenInfo.new(Theme.Tween.Hover), { BackgroundColor3 = Components.Brighten(fill, 0.1) }):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(Theme.Tween.Hover), { BackgroundColor3 = fill }):Play()
		scale.Scale = 1
	end)
	button.MouseButton1Down:Connect(function()
		if enabled then
			TweenService:Create(scale, TweenInfo.new(Theme.Tween.Press), { Scale = 0.95 }):Play()
		end
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(scale, TweenInfo.new(Theme.Tween.Press), { Scale = 1 }):Play()
	end)
	button.Activated:Connect(function()
		if enabled and props.OnClick then
			props.OnClick()
		end
	end)
	local function setEnabled(on: boolean)
		enabled = on
		button.BackgroundTransparency = if on then 0 else 0.6
		button.TextTransparency = if on then 0 else 0.6
	end
	return button, setEnabled
end

export type Modal = { Root: Frame, Panel: Frame, Body: Frame, Title: TextLabel, Close: () -> () }

-- Modal: 60% of the screen (mobile 95%), dim backdrop 50%, ✕ top-right, open 0.25 s Back / close 0.15 s.
function Components.Modal(gui: Instance, props: { Title: string, Width: number?, Height: number?, NoClose: boolean?, OnClose: (() -> ())?, ZIndex: number? }): Modal
	local mobile = Components.IsMobile()
	local z = props.ZIndex or 20
	local root = New("Frame", {
		Name = "Modal_" .. props.Title,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Colors.Shadow,
		BackgroundTransparency = 1,
		Active = true,
		ZIndex = z,
		Parent = gui,
	})
	local scale = New("UIScale", { Scale = 0.85 })
	local panel = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(if mobile then 0.95 else (props.Width or 0.6), props.Height or 0.8),
		BackgroundColor3 = Theme.Colors.Bg,
		ZIndex = z + 1,
		Parent = root,
	}, { scale })
	corner(panel, Theme.Radius.L)
	stroke(panel, Theme.Colors.Accent)
	padding(panel, if mobile then Theme.PanelPadding.Mobile else Theme.PanelPadding.Desktop, Theme.Space.L)
	local title = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -60, 0, Theme.Type.H1 + 8),
		FontFace = Theme.Fonts.Heading,
		TextSize = Theme.Type.H1,
		TextColor3 = Theme.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = props.Title,
		ZIndex = z + 2,
		Parent = panel,
	})
	local body = New("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, Theme.Type.H1 + 8 + Theme.Space.M),
		Size = UDim2.new(1, 0, 1, -(Theme.Type.H1 + 8 + Theme.Space.M)),
		ZIndex = z + 2,
		Parent = panel,
	})
	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		TweenService:Create(root, TweenInfo.new(Theme.Tween.Close), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(scale, TweenInfo.new(Theme.Tween.Close), { Scale = 0.85 }):Play()
		task.delay(Theme.Tween.Close, function()
			root:Destroy()
		end)
		if props.OnClose then
			props.OnClose()
		end
	end
	if not props.NoClose then
		local x = New("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(Theme.TouchMin, Theme.TouchMin),
			BackgroundColor3 = Theme.Colors.Panel,
			Text = "X",
			FontFace = Theme.Fonts.Bold,
			TextSize = Theme.Type.H2,
			TextColor3 = Theme.Colors.Text,
			ZIndex = z + 3,
			Parent = panel,
			Activated = close,
		})
		corner(x, Theme.Radius.M)
	end
	TweenService:Create(root, TweenInfo.new(Theme.Tween.Open), { BackgroundTransparency = 0.5 }):Play()
	TweenService:Create(scale, TweenInfo.new(Theme.Tween.Open, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	return { Root = root, Panel = panel, Body = body, Title = title, Close = close }
end

-- Progress bar h 12, rounded, accent gradient, fill tween 0.3 s.
function Components.Bar(color: Color3?, height: number?): (Frame, (number) -> ())
	local track = New("Frame", {
		Size = UDim2.new(1, 0, 0, height or Theme.Components.ProgressBar.Height),
		BackgroundColor3 = Theme.Colors.Panel,
	})
	corner(track, Theme.Radius.S)
	local fill = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = color or Theme.Colors.Accent, Parent = track })
	corner(fill, Theme.Radius.S)
	New("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 200)), Parent = fill })
	return track, function(frac: number)
		TweenService:Create(fill, TweenInfo.new(Theme.Tween.Fill), { Size = UDim2.fromScale(math.clamp(frac, 0, 1), 1) }):Play()
	end
end

-- Wrapped body text that grows downward.
function Components.Paragraph(text: string, size: number?, color: Color3?): TextLabel
	return New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		FontFace = Theme.Fonts.Body,
		TextSize = size or Theme.Type.Body,
		TextColor3 = color or Theme.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text,
	})
end

-- Player card 140×190 ([[UI Style Guide]] → Player card): rarity frame, OVR top-left, Level badge, name, role, trait.
-- view = { Name, Rarity, Role, Stats, Trait, Source, Accessories } (a PlayerCard plus a display Name).
function Components.PlayerCard(view: any, scaleBy: number?): Frame
	local s = scaleBy or 1
	local spec = Theme.Components.PlayerCard
	local color = Theme.Rarity[view.Rarity] or Theme.Colors.TextMuted
	local founder = view.Source == "Founder"
	local ovr = Ratings.Ovr(view)
	local level, levelColor = Ratings.Level(ovr)
	local card = New("Frame", {
		Size = UDim2.fromOffset(spec.Width * s, spec.Height * s),
		BackgroundColor3 = Theme.Colors.Panel,
	})
	corner(card, Theme.Radius.M)
	local edge = stroke(card, color)
	edge.Thickness = 3
	edge.Transparency = 0
	New("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Components.Brighten(color, -0.35), Theme.Colors.Panel),
		Parent = card,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8 * s, 4 * s),
		Size = UDim2.fromOffset(60 * s, 34 * s),
		FontFace = Theme.Fonts.Heading,
		TextSize = 32 * s,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.Colors.Text,
		Text = tostring(ovr),
		Parent = card,
	})
	local badge = New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6 * s, 0, 6 * s),
		Size = UDim2.fromOffset(40 * s, 22 * s),
		BackgroundColor3 = levelColor,
		FontFace = Theme.Fonts.Bold,
		TextSize = 13 * s,
		TextColor3 = Theme.Colors.Bg,
		Text = `Lv {level}`,
		Parent = card,
	})
	corner(badge, Theme.Radius.S)
	-- Portrait placeholder: initial in a rarity circle (avatar thumbnails come with the card art pass).
	local portrait = New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 40 * s),
		Size = UDim2.fromOffset(64 * s, 64 * s),
		BackgroundColor3 = Components.Brighten(color, -0.15),
		FontFace = Theme.Fonts.Heading,
		TextSize = 34 * s,
		TextColor3 = Theme.Colors.Text,
		Text = string.upper(string.sub(view.Name or "?", 1, 1)),
		Parent = card,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = portrait })
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4 * s, 110 * s),
		Size = UDim2.new(1, -8 * s, 0, 24 * s),
		FontFace = Theme.Fonts.Bold,
		TextSize = 18 * s,
		TextScaled = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = Theme.Colors.Text,
		Text = if founder then `You · {view.Name}` else view.Name,
		Parent = card,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4 * s, 136 * s),
		Size = UDim2.new(1, -8 * s, 0, 18 * s),
		FontFace = Theme.Fonts.Body,
		TextSize = 14 * s,
		TextColor3 = color,
		Text = if founder then `FOUNDER · {view.Role}` else `{view.Rarity} · {view.Role}`,
		Parent = card,
	})
	local trait = view.Trait and Traits[view.Trait]
	if trait then
		local chip = New("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -8 * s),
			Size = UDim2.new(1, -16 * s, 0, 22 * s),
			BackgroundColor3 = Theme.Colors.Bg,
			FontFace = Theme.Fonts.Body,
			TextSize = 13 * s,
			TextColor3 = Theme.Colors.TextMuted,
			Text = trait.Name,
			Parent = card,
		})
		corner(chip, Theme.Radius.S)
	end
	return card
end

-- Item def, rarity and one-line effect for a part or accessory ("+3 Aim", "+2.1% power · CPU").
local Parts = require(ReplicatedStorage.Shared.Config.Parts)
local Accessories = require(ReplicatedStorage.Shared.Config.Accessories)

function Components.ItemInfo(kind: string, itemId: string): (any, string, string, string)
	if kind == "Part" then
		local item = Parts.Items[itemId]
		local tier = item and Parts.Tiers[item.Tier]
		if not item or not tier then
			return nil, "Common", "?", ""
		end
		local pct = tier.StatMult * (Parts.SlotWeight[item.Slot] or 0) * 100
		return item, tier.Rarity, Parts.Icons[item.Slot] or "?", string.format("+%.1f%% power · %s", pct, item.Slot)
	end
	local item = Accessories.Items[itemId]
	if not item then
		return nil, "Common", "?", ""
	end
	local slot = Accessories.Slots[item.Slot]
	return item, if item.Tier == "Starter" then "Common" else item.Tier, slot and slot.Icon or "?", `+{Accessories.TierBonus[item.Tier] or 0} {Roles.StatNames[item.Stat] or item.Stat}`
end

-- Item card, same size and frame as the player card: rarity edge, icon, name, tier, effect line.
function Components.ItemCard(kind: string, itemId: string, scaleBy: number?): Frame
	local s = scaleBy or 1
	local spec = Theme.Components.PlayerCard
	local item, rarity, icon, line = Components.ItemInfo(kind, itemId)
	local color = Theme.Rarity[rarity] or Theme.Colors.TextMuted
	local card = New("Frame", { Size = UDim2.fromOffset(spec.Width * s, spec.Height * s), BackgroundColor3 = Theme.Colors.Panel })
	corner(card, Theme.Radius.M)
	local edge = stroke(card, color)
	edge.Thickness = 3
	edge.Transparency = 0
	New("UIGradient", { Rotation = 90, Color = ColorSequence.new(Components.Brighten(color, -0.35), Theme.Colors.Panel), Parent = card })
	New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8 * s, 6 * s), Size = UDim2.new(1, -16 * s, 0, 18 * s), FontFace = Theme.Fonts.Bold, TextSize = 13 * s, TextColor3 = color, TextXAlignment = Enum.TextXAlignment.Left, Text = string.upper(if kind == "Part" then "PC part" else "Accessory"), Parent = card })
	New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 30 * s), Size = UDim2.fromOffset(72 * s, 72 * s), BackgroundTransparency = 1, TextSize = 56 * s, Text = icon, Parent = card })
	New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(4 * s, 108 * s), Size = UDim2.new(1, -8 * s, 0, 36 * s), FontFace = Theme.Fonts.Bold, TextSize = 16 * s, TextWrapped = true, TextColor3 = Theme.Colors.Text, Text = if item then item.Name else itemId, Parent = card })
	New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(4 * s, 146 * s), Size = UDim2.new(1, -8 * s, 0, 16 * s), FontFace = Theme.Fonts.Body, TextSize = 13 * s, TextColor3 = color, Text = if kind == "Part" and item then `{Parts.Tiers[item.Tier].Name} · {rarity}` else rarity, Parent = card })
	local chip = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -6 * s), Size = UDim2.new(1, -12 * s, 0, 20 * s), BackgroundColor3 = Theme.Colors.Bg, FontFace = Theme.Fonts.Bold, TextSize = 12 * s, TextColor3 = Theme.Colors.Success, Text = line, Parent = card })
	corner(chip, Theme.Radius.S)
	return card
end

-- One stat row: name, bar (base) + ghost bar (Potential), value with gear ("Aim 28 +1").
function Components.StatRow(stat: string, value: number, potential: number, gear: number?): Frame
	local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28) })
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.35, 0, 1, 0),
		FontFace = Theme.Fonts.Body,
		TextSize = Theme.Type.Caption + 2,
		TextColor3 = Theme.Colors.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = Roles.StatNames[stat] or stat,
		Parent = row,
	})
	local track = New("Frame", {
		Position = UDim2.new(0.35, 0, 0.5, -6),
		Size = UDim2.new(0.45, 0, 0, 12),
		BackgroundColor3 = Theme.Colors.Panel,
		Parent = row,
	})
	corner(track, Theme.Radius.S)
	local ghost = New("Frame", { Size = UDim2.fromScale(potential / 100, 1), BackgroundColor3 = Theme.Colors.Accent, BackgroundTransparency = 0.75, Parent = track })
	corner(ghost, Theme.Radius.S)
	local fill = New("Frame", { Size = UDim2.fromScale(value / 100, 1), BackgroundColor3 = Theme.Colors.Accent, Parent = track })
	corner(fill, Theme.Radius.S)
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.82, 0, 0, 0),
		Size = UDim2.new(0.18, 0, 1, 0),
		FontFace = Theme.Fonts.Bold,
		TextSize = Theme.Type.Caption + 2,
		TextColor3 = Theme.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Right,
		RichText = true,
		Text = if gear and gear > 0 then `{value} <font color="#34D399">+{gear}</font>` else tostring(value),
		Parent = row,
	})
	return row
end

-- Tab pills in a row ([[UI Style Guide]] → tabs). tabs = { { Id, Label } }. Returns select(id) (also called once now).
function Components.Tabs(parent: Instance, tabs: { { Id: string, Label: string } }, first: string, onSelect: (string) -> ()): (string) -> ()
	local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), Parent = parent })
	Components.List(row, Theme.Space.S, true)
	local buttons: { [string]: TextButton } = {}
	local function select(id: string)
		for k, b in buttons do
			b.BackgroundColor3 = if k == id then Theme.Colors.Accent else Theme.Colors.Panel
			b.TextColor3 = if k == id then Theme.Colors.Bg else Theme.Colors.Text
		end
		onSelect(id)
	end
	for i, t in tabs do
		local b = New("TextButton", { Size = UDim2.fromOffset(0, 44), AutomaticSize = Enum.AutomaticSize.X, Text = t.Label, FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, LayoutOrder = i, AutoButtonColor = false, Parent = row })
		corner(b, Theme.Radius.M)
		padding(b, Theme.Space.L, 0)
		buttons[t.Id] = b
		b.Activated:Connect(function()
			select(t.Id)
		end)
	end
	select(first)
	return select
end

-- Sound helper: plays a one-shot sound locally.
local SoundService = game:GetService("SoundService")
function Components.Play(soundId: string, speed: number?, volume: number?)
	if soundId == "" then
		return
	end
	local s = New("Sound", { SoundId = soundId, PlaybackSpeed = speed or 1, Volume = volume or 0.5, Parent = SoundService })
	s.Ended:Connect(function()
		s:Destroy()
	end)
	s:Play()
	task.delay(8, function()
		if s.Parent then
			s:Destroy()
		end
	end)
end

-- "12:34" / "1:02:03".
function Components.Clock(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	if s >= 3600 then
		return string.format("%d:%02d:%02d", s // 3600, s % 3600 // 60, s % 60)
	end
	return string.format("%d:%02d", s // 60, s % 60)
end

-- Vertical list layout helper.
function Components.List(parent: Instance, gap: number?, horizontal: boolean?, align: Enum.HorizontalAlignment?): UIListLayout
	return New("UIListLayout", {
		FillDirection = if horizontal then Enum.FillDirection.Horizontal else Enum.FillDirection.Vertical,
		Padding = UDim.new(0, gap or Theme.Space.S),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		Parent = parent,
	})
end

return Components

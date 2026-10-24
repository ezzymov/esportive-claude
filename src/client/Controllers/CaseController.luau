--!strict
-- CaseController ([[Screen - Case Opening]], [[Case Unboxing]]). The server rolls; this only shows the result.
--   Shelf (select view): case cards, price or owned count, Open ×1/×5/×10, ⓘ Odds panel, pity bar ("Epic in 4"),
--     free-crate timer. Drawn inside the Shop (mode "Shop" = buy) and Inventory (mode "Owned") screens.
--   Reveal (fullscreen): drop 0.6 s → shake with a rarity-colored glow 1.2 s → lid pop + beam 0.4 s → card flip 0.8 s →
--     NEW! or "+12 Shards". ×5/×10: grid of face-down cards whose edge glows their rarity; tap to flip or Reveal all.
--     Skip from frame 1. Rarity stings rise in pitch per tier, cheer volume scales with rarity, Mythic shakes the
--     screen, Hector/Dr. Data react ([[Caster & Commentary]]).
--   HUD context buttons: "Open Rookie Crate" for the FTUE crate, "Free Rookie Crate!" when the timer is up.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Net = require(ReplicatedStorage.Shared.Net)
local Format = require(ReplicatedStorage.Shared.Format)
local CaseRoll = require(ReplicatedStorage.Shared.CaseRoll)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Cases = require(ReplicatedStorage.Shared.Config.Cases)
local Rarities = require(ReplicatedStorage.Shared.Config.Rarities)
local Parts = require(ReplicatedStorage.Shared.Config.Parts)
local Accessories = require(ReplicatedStorage.Shared.Config.Accessories)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local Caster = require(script.Parent.Parent.UI.Caster)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)
local RosterController = require(script.Parent.RosterController)
local TutorialController = require(script.Parent.TutorialController)

local CaseController = { Tier = 6 }

local Z = 60 -- reveal sits above every modal
local opening = false
local CURRENCY_ICON = { Cash = "$", Gems = "💎" }

local function def(caseId: string): any
	return (Cases :: any)[caseId]
end

local function priceText(d: any, count: number): string
	local cost = d.Price * count
	return if d.Currency == "Cash" then Format.Cash(cost) else `{CURRENCY_ICON[d.Currency] or ""}{Format.Short(cost)}`
end

local function rarityColor(r: string): Color3
	return Theme.Rarity[r] or Theme.Colors.Text
end

local function reduced(): boolean
	return (StateController:Get("Settings.ReducedMotion") or false) == true
end

-- Reveal -------------------------------------------------------------------------------------------------------

local function dropCard(drop: any, scaleBy: number): Frame
	if drop.Type == "Player" then
		return Components.PlayerCard(RosterController:View(drop.Card), scaleBy)
	end
	return Components.ItemCard(drop.Type, drop.ItemId, scaleBy)
end

local function dropName(drop: any): string
	if drop.Type == "Player" then
		return RosterController:View(drop.Card).Name
	end
	local item = if drop.Type == "Part" then Parts.Items[drop.ItemId] else Accessories.Items[drop.ItemId]
	return if item then item.Name else tostring(drop.ItemId)
end

-- "NEW!" / "+12 Shards" / "Roster full · +30 Shards" badge text.
local function badge(drop: any): (string, Color3)
	if drop.Shards > 0 then
		return if drop.Reason == "RosterFull" then `Roster full · +{drop.Shards} Shards` else `Duplicate · +{drop.Shards} Shards`, Theme.Colors.Accent
	end
	return if drop.New then "NEW!" else "Added", Theme.Colors.Warning
end

local function sting(rarity: string)
	Components.Play(Theme.Sounds.Sting, Theme.StingSpeed[rarity], 0.6)
	local cheer = Theme.CheerVolume[rarity] or 0
	if cheer > 0 then
		Components.Play(Theme.Sounds.Cheer, 1, cheer)
	end
	if rarity == "Mythic" then
		Components.Play(Theme.Sounds.Boom, 1, 0.8)
	end
end

local function shakeScreen(frame: GuiObject, seconds: number)
	if reduced() then
		return
	end
	local base = frame.Position
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < seconds and frame.Parent do
			local k = 1 - (os.clock() - t0) / seconds
			frame.Position = base + UDim2.fromOffset(math.random(-12, 12) * k, math.random(-12, 12) * k)
			task.wait(0.03)
		end
		frame.Position = base
	end)
end

local function rainbow(parent: Instance)
	New("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("EF4444")),
			ColorSequenceKeypoint.new(0.25, Color3.fromHex("F59E0B")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("34D399")),
			ColorSequenceKeypoint.new(0.75, Color3.fromHex("3B82F6")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("A855F7")),
		}),
		Parent = parent,
	})
end

-- Full-screen stage the reveal plays on. Returns (root, content, footer).
local function stage(title: string): (Frame, Frame, Frame)
	local overlay = UIController:GetGui("Overlay")
	local root = New("Frame", { Name = "CaseReveal", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Active = true, ZIndex = Z, Parent = overlay })
	TweenService:Create(root, TweenInfo.new(0.6), { BackgroundTransparency = 0.12 }):Play() -- lights dim
	local content = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = Z, Parent = root })
	New("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, Theme.Space.XL), Size = UDim2.new(0.9, 0, 0, 40), FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.H1, TextColor3 = Theme.Colors.Text, Text = title, ZIndex = Z + 1, Parent = root })
	local footer = New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -Theme.Space.XL), Size = UDim2.fromOffset(0, 56), AutomaticSize = Enum.AutomaticSize.X, ZIndex = Z + 2, Parent = root })
	Components.List(footer, Theme.Space.M, true, Enum.HorizontalAlignment.Center)
	return root, content, footer
end

local function footerButton(footer: Frame, text: string, kind: string, order: number, onClick: () -> ()): TextButton
	local b = Components.Button({ Text = text, Kind = kind, Width = 200, Order = order, OnClick = onClick })
	b.ZIndex = Z + 3
	b.Parent = footer
	return b
end

-- Single open: the five beats from [[Screen - Case Opening]].
local function revealOne(content: Frame, footer: Frame, d: any, drop: any)
	local skipped = false
	local skip = footerButton(footer, "Skip >>", "Secondary", 9, function()
		skipped = true
	end)
	local function hold(seconds: number): boolean
		local t0 = os.clock()
		while os.clock() - t0 < seconds do
			if skipped then
				return false
			end
			task.wait()
		end
		return true
	end
	local color = rarityColor(drop.Rarity)
	local fast = reduced()

	local glow = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromOffset(40, 40), BackgroundColor3 = Theme.Rarity.Common, BackgroundTransparency = 0.35, ZIndex = Z + 1, Parent = content })
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glow })
	local crate = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, -0.2), Size = UDim2.fromOffset(220, 220), BackgroundTransparency = 1, Text = d.Icon or "📦", TextSize = 170, ZIndex = Z + 2, Parent = content })
	local crateScale = New("UIScale", { Parent = crate })

	-- 1 · drop (0.6 s)
	Components.Play(Theme.Sounds.Drop, 1, 0.6)
	TweenService:Create(crate, TweenInfo.new(if fast then 0.2 else 0.6, Enum.EasingStyle.Bounce), { Position = UDim2.fromScale(0.5, 0.45) }):Play()
	if hold(if fast then 0.2 else 0.6) then
		-- 2 · shake + glow telegraph (1.2 s): the glow climbs the rarity ladder up to the drop's rarity.
		Components.Play(Theme.Sounds.Shake, 1, 0.4)
		local shake = TweenService:Create(crate, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), { Rotation = 7 })
		if not fast then
			shake:Play()
		end
		TweenService:Create(glow, TweenInfo.new(if fast then 0.3 else 1.2, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(420, 420), BackgroundTransparency = 0.55 }):Play()
		local top = CaseRoll.Rank[drop.Rarity]
		local stepTime = (if fast then 0.3 else 1.2) / top
		local reached = true
		for i = 1, top do
			glow.BackgroundColor3 = rarityColor(Rarities.Order[i])
			if not hold(stepTime) then
				reached = false
				break
			end
		end
		shake:Cancel()
		crate.Rotation = 0
		-- 3 · lid pop + beam (0.4 s)
		if reached then
			Components.Play(Theme.Sounds.Pop, 1, 0.6)
			Components.Play(Theme.Sounds.Beam, 1, 0.4)
			local beam = New("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.55), Size = UDim2.new(0, 60, 0.55, 0), BackgroundColor3 = color, BackgroundTransparency = 0.2, ZIndex = Z + 1, Parent = content })
			New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = beam })
			if drop.Rarity == "Mythic" then
				rainbow(beam)
			end
			TweenService:Create(beam, TweenInfo.new(0.4), { Size = UDim2.new(0, 260, 0.75, 0) }):Play()
			TweenService:Create(crateScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 }):Play()
			hold(0.4)
			task.delay(0.6, function()
				TweenService:Create(beam, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
				task.wait(0.5)
				beam:Destroy()
			end)
		end
	end
	crate.Visible = false
	skip:Destroy()

	-- 4 · card flip (0.8 s) + 5 · result
	local holder = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromOffset(4, Theme.Components.PlayerCard.Height * 1.6), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = Z + 3, Parent = content })
	local card = dropCard(drop, 1.6)
	card.AnchorPoint = Vector2.new(0.5, 0)
	card.Position = UDim2.fromScale(0.5, 0)
	card.Parent = holder
	TweenService:Create(holder, TweenInfo.new(if skipped then 0 else 0.4, Enum.EasingStyle.Back), { Size = UDim2.fromOffset(Theme.Components.PlayerCard.Width * 1.6, Theme.Components.PlayerCard.Height * 1.6) }):Play()
	TweenService:Create(glow, TweenInfo.new(0.3), { BackgroundColor3 = color, Size = UDim2.fromOffset(480, 480), BackgroundTransparency = 0.6 }):Play()
	sting(drop.Rarity)
	if drop.Rarity == "Mythic" or drop.Rarity == "Legendary" then
		shakeScreen(content, if drop.Rarity == "Mythic" then 1.2 else 0.5)
	end
	local text, badgeColor = badge(drop)
	New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.74), Size = UDim2.new(0.9, 0, 0, 40), BackgroundTransparency = 1, FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.H1, TextColor3 = color, Text = `{string.upper(drop.Rarity)} · {dropName(drop)}`, ZIndex = Z + 3, Parent = content }, { New("UIStroke", { Thickness = 2, Color = Theme.Colors.Bg }) })
	local b = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.74), Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = badgeColor, FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.Bg, Text = text, ZIndex = Z + 3, Parent = content })
	b.Position = UDim2.new(0.5, 0, 0.74, 48)
	Components.Corner(b, Theme.Radius.S)
	Components.Padding(b, Theme.Space.M, 0)
	if drop.Forced then
		New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.74, 88), Size = UDim2.new(0.9, 0, 0, 22), BackgroundTransparency = 1, FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Caption, TextColor3 = Theme.Colors.TextMuted, Text = `Pity guarantee: {drop.Forced} or better`, ZIndex = Z + 3, Parent = content })
	end
	Caster.Show(content, "Case" .. drop.Rarity, 1, nil, Z + 4)
end

-- ×5 / ×10: face-down grid; each back glows its rarity. Returns when every card is flipped.
local function revealMany(content: Frame, footer: Frame, drops: { any })
	local n = #drops
	local cols = if n > 5 then 5 else n
	local cardScale = if n > 5 then 0.8 else 0.95
	local w, h = Theme.Components.PlayerCard.Width * cardScale, Theme.Components.PlayerCard.Height * cardScale
	local grid = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.48), Size = UDim2.fromOffset(cols * (w + 12), math.ceil(n / cols) * (h + 40)), BackgroundTransparency = 1, ZIndex = Z + 1, Parent = content })
	New("UIGridLayout", { CellSize = UDim2.fromOffset(w, h + 28), CellPadding = UDim2.fromOffset(12, 12), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
	local flipped = 0
	local flips: { () -> () } = {}
	for i, drop in drops do
		local slot = New("Frame", { BackgroundTransparency = 1, LayoutOrder = i, ZIndex = Z + 1, Parent = grid })
		local back = New("TextButton", { Size = UDim2.fromOffset(w, h), BackgroundColor3 = Theme.Colors.Panel, Text = "?", FontFace = Theme.Fonts.Heading, TextSize = 56, TextColor3 = Theme.Colors.TextMuted, AutoButtonColor = false, ZIndex = Z + 2, Parent = slot })
		Components.Corner(back, Theme.Radius.M)
		local edge = Components.Stroke(back, rarityColor(drop.Rarity)) -- rarity telegraph on the card back
		edge.Thickness = 4
		edge.Transparency = 0.2
		local done = false
		local function flip()
			if done then
				return
			end
			done = true
			back:Destroy()
			local card = dropCard(drop, cardScale)
			card.Parent = slot
			local scale = New("UIScale", { Scale = 0.2, Parent = card })
			TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
			local text, color = badge(drop)
			local tag = New("TextLabel", { Position = UDim2.fromOffset(0, h + 4), Size = UDim2.fromOffset(w, 22), BackgroundColor3 = color, FontFace = Theme.Fonts.Bold, TextSize = 12, TextScaled = false, TextColor3 = Theme.Colors.Bg, Text = text, ZIndex = Z + 3, Parent = slot })
			Components.Corner(tag, Theme.Radius.S)
			sting(drop.Rarity)
			flipped += 1
		end
		back.Activated:Connect(flip)
		flips[i] = flip
	end
	local revealAll: TextButton
	revealAll = footerButton(footer, "Reveal all", "Primary", 1, function()
		revealAll.Visible = false
		for i, flip in flips do
			flip()
			if i < n then
				task.wait(if reduced() then 0.05 else 0.18)
			end
		end
	end)
	while flipped < n do
		task.wait()
	end
	revealAll:Destroy()
	-- Hector reacts to the best pull.
	local best = drops[1]
	for _, d in drops do
		if CaseRoll.Rank[d.Rarity] > CaseRoll.Rank[best.Rarity] then
			best = d
		end
	end
	Caster.Show(content, "Case" .. best.Rarity, 1, nil, Z + 4)
	if best.Rarity == "Mythic" or best.Rarity == "Legendary" then
		shakeScreen(content, 0.6)
	end
end

-- Opens `count` crates through the server, plays the reveal, returns when the player closes it.
function CaseController:Open(caseId: string, count: number, owned: boolean)
	if opening then
		return
	end
	opening = true
	local d = def(caseId)
	local ok, res = (Net.Get("Case", "Open") :: RemoteFunction):InvokeServer(caseId, count, owned)
	if not ok then
		opening = false
		local msg = if type(res) == "table" and res.Need then `Need {if res.Currency == "Cash" then Format.Cash(res.Need) else Format.Short(res.Need) .. " " .. res.Currency} more`
			elseif type(res) == "table" and res.NeedStage then `Unlocks at Stage {res.NeedStage}`
			elseif res == "NoCase" then "You don't have enough of those crates."
			elseif res == "RateLimited" or res == "Busy" then "One at a time!"
			else `Couldn't open it ({tostring(res)})`
		HudController:Toast(msg, Theme.Colors.Warning)
		return
	end
	UIController:SetMenu("CaseReveal", true)
	UIController:SetCinematic("CaseReveal", true)
	if caseId == "StarterCrate" then
		TutorialController:Say("TUT_UNBOX_GLOW")
	end
	local root, content, footer = stage(if count > 1 then `{d.Name} ×{count}` else d.Name)
	if count == 1 then
		revealOne(content, footer, d, res.Drops[1])
	else
		revealMany(content, footer, res.Drops)
	end
	if res.Shards > 0 then
		New("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -Theme.Space.XL - 64), Size = UDim2.new(0.9, 0, 0, 26), BackgroundTransparency = 1, FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.Accent, Text = `+{res.Shards} Shards from duplicates`, ZIndex = Z + 3, Parent = root })
	end
	local closed = false
	local again = false
	footerButton(footer, if caseId == "StarterCrate" then "Nice!" else "Done", "Primary", 1, function()
		closed = true
	end)
	local canAgain = if owned then (StateController:Get("Inventory.Cases." .. caseId) or 0) >= count
		else not d.Hidden and (StateController:Get("Currencies." .. d.Currency) or 0) >= d.Price * count
	if canAgain then
		footerButton(footer, if owned then `Open again ×{count}` else `Again · {priceText(d, count)}`, "Secondary", 2, function()
			closed, again = true, true
		end)
	end
	while not closed do
		task.wait()
	end
	TweenService:Create(root, TweenInfo.new(Theme.Tween.Close), { BackgroundTransparency = 1 }):Play()
	root:Destroy()
	UIController:SetCinematic("CaseReveal", false)
	UIController:SetMenu("CaseReveal", false)
	opening = false
	if again then
		CaseController:Open(caseId, count, owned)
	end
end

function CaseController:IsOpening(): boolean
	return opening
end

-- Odds panel ([[Screen - Settings & Odds]] → Odds & Rules uses the same rows) --------------------------------------

function CaseController:OddsRows(parent: Instance, caseId: string, order: number): number
	local d = def(caseId)
	local o = order
	local function line(text: string, color: Color3?, size: number?)
		o += 1
		local p = Components.Paragraph(text, size or Theme.Type.Caption + 2, color or Theme.Colors.Text)
		p.RichText = true
		p.LayoutOrder = o
		p.Parent = parent
	end
	line(`<b>{d.Name}</b>{if d.Price then " · " .. priceText(d, 1) else " · reward only"}`, Theme.Colors.Text, Theme.Type.Body)
	for _, row in CaseRoll.Odds(d) do
		local parts = {}
		for _, t in row.Types do
			table.insert(parts, string.format("%s %.1f%%", t.Type, t.P * 100))
		end
		local hex = rarityColor(row.Rarity):ToHex()
		local ovr = Rarities[row.Rarity] and Rarities[row.Rarity].Ovr
		line(string.format('<font color="#%s"><b>%s %.2f%%</b></font>   %s%s', hex, row.Rarity, row.P * 100, table.concat(parts, " · "), if ovr then `   (players OVR {ovr[1]}–{ovr[2]})` else ""))
	end
	if d.Guaranteed then
		line(`Always one {d.Guaranteed} player.`, Theme.Colors.TextMuted)
	else
		local pity = {}
		for _, p in CaseRoll.PityLeft(d, nil) do
			table.insert(pity, `{p.Rarity} or better within {Cases.Pity[p.Rarity]} opens`)
		end
		if #pity > 0 then
			line("Pity: " .. table.concat(pity, " · ") .. ". Only opens of cases that can drop that rarity count.", Theme.Colors.TextMuted)
		end
	end
	return o
end

local function oddsPanel(caseId: string)
	local overlay = UIController:GetGui("Overlay")
	local modal = Components.Modal(overlay, { Title = "Odds", Width = 0.5, Height = 0.75, ZIndex = 40 })
	local list = New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0, ZIndex = 43, Parent = modal.Body })
	Components.List(list, Theme.Space.S)
	local o = CaseController:OddsRows(list, caseId, 0)
	local shards = {}
	for _, r in Rarities.Order do
		table.insert(shards, `{r} {Cases.Shards[r]}`)
	end
	for i, text in {
		"Drop types are rolled after the rarity. A type with nothing at that rarity is skipped and the others share its chance.",
		"Duplicates turn into Shards: a part once you own one per desk, an accessory once you own one per player, a player once your roster is full.",
		"Shards per duplicate: " .. table.concat(shards, " · "),
	} do
		local p = Components.Paragraph(text, Theme.Type.Caption + 1, Theme.Colors.TextMuted)
		p.LayoutOrder = o + i
		p.Parent = list
	end
	for _, d in list:GetDescendants() do
		if d:IsA("GuiObject") then
			d.ZIndex = 43
		end
	end
end

-- Shelf --------------------------------------------------------------------------------------------------------

-- Draws the case shelf into `parent`. mode "Shop" buys; "Owned" opens crates from Inventory.Cases.
-- Returns a cleanup function.
function CaseController:RenderShelf(parent: Frame, mode: string, onOpen: (() -> ())?): () -> ()
	local stops: { () -> () } = {}
	local updaters: { () -> () } = {}
	local mobile = Components.IsMobile()
	local selected: string? = nil
	local shelf = New("ScrollingFrame", { BackgroundTransparency = 1, Size = if mobile then UDim2.new(1, 0, 0, 236) else UDim2.new(0.55, 0, 1, 0), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.XY, ScrollBarThickness = 6, BorderSizePixel = 0, Parent = parent })
	New("UIGridLayout", { CellSize = UDim2.fromOffset(176, 220), CellPadding = UDim2.fromOffset(Theme.Space.M, Theme.Space.M), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = if mobile then Enum.FillDirection.Vertical else Enum.FillDirection.Horizontal, Parent = shelf })
	Components.Padding(shelf, Theme.Space.XS, Theme.Space.XS)
	local panel = New("ScrollingFrame", {
		BackgroundColor3 = Theme.Colors.Panel,
		Position = if mobile then UDim2.fromOffset(0, 244) else UDim2.fromScale(0.57, 0),
		Size = if mobile then UDim2.new(1, 0, 1, -244) else UDim2.fromScale(0.43, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		BorderSizePixel = 0,
		Parent = parent,
	})
	Components.Corner(panel, Theme.Radius.M)
	Components.Padding(panel, Theme.Space.M, Theme.Space.M)
	local details = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -14, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = panel })

	local function visible(): { string }
		local list = {}
		local owned = StateController:Get("Inventory.Cases") or {}
		for _, id in Cases.Order do
			local d = def(id)
			if mode == "Owned" and (owned[id] or 0) > 0 or mode == "Shop" and not d.Hidden then
				table.insert(list, id)
			end
		end
		return list
	end

	local renderDetails: () -> ()
	local function renderShelf()
		for _, c in shelf:GetChildren() do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		local ids = visible()
		if not selected or not table.find(ids, selected) then
			selected = ids[1]
		end
		if #ids == 0 then
			local p = Components.Paragraph(if mode == "Owned" then "No crates yet. Buy them in the Shop or win them in tournaments." else "Nothing on the shelf yet.", Theme.Type.Body, Theme.Colors.TextMuted)
			p.Parent = shelf
		end
		local stage = StateController:Get("Stage") or 1
		local owned = StateController:Get("Inventory.Cases") or {}
		for i, id in ids do
			local d = def(id)
			local color = Color3.fromHex(d.Color)
			local locked = mode == "Shop" and (d.Stage or 99) > stage
			local card = New("TextButton", { BackgroundColor3 = Theme.Colors.Bg, Text = "", AutoButtonColor = false, LayoutOrder = i, Parent = shelf })
			Components.Corner(card, Theme.Radius.L)
			local edge = Components.Stroke(card, if id == selected then Theme.Colors.Accent else color)
			edge.Thickness = if id == selected then 4 else 2
			edge.Transparency = 0
			New("UIGradient", { Rotation = 90, Color = ColorSequence.new(Components.Brighten(color, -0.3), Theme.Colors.Bg), Parent = card })
			New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 12), Size = UDim2.new(1, 0, 0, 110), Text = d.Icon or "📦", TextSize = 92, TextTransparency = if locked then 0.6 else 0, Parent = card })
			New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 128), Size = UDim2.new(1, -12, 0, 26), FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.Text, Text = d.Name, Parent = card })
			local sub = if mode == "Owned" then `Owned ×{owned[id] or 0}` elseif locked then `🔒 Stage {d.Stage}` else priceText(d, 1)
			New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 158), Size = UDim2.new(1, -12, 0, 22), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, TextColor3 = if locked then Theme.Colors.TextMuted else Theme.Colors.Success, Text = sub, Parent = card })
			if d.Guaranteed then
				New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 184), Size = UDim2.new(1, -12, 0, 20), FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Caption, TextColor3 = rarityColor(d.Guaranteed), Text = `Guaranteed {d.Guaranteed}`, Parent = card })
			end
			card.Activated:Connect(function()
				selected = id
				renderShelf()
				renderDetails()
			end)
		end
	end

	renderDetails = function()
		table.clear(updaters)
		details:ClearAllChildren()
		Components.List(details, Theme.Space.S)
		local id = selected
		if not id then
			return
		end
		local d = def(id)
		local stage = StateController:Get("Stage") or 1
		local owned = (StateController:Get("Inventory.Cases") or {})[id] or 0
		local o = 0
		local function add(inst: GuiObject)
			o += 1
			inst.LayoutOrder = o
			inst.Parent = details
		end
		local head = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36) })
		New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -110, 1, 0), FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.H2, TextColor3 = Color3.fromHex(d.Color), TextXAlignment = Enum.TextXAlignment.Left, Text = d.Name, Parent = head })
		local oddsBtn = Components.Button({ Text = "ⓘ Odds", Kind = "Secondary", Width = 104, OnClick = function()
			oddsPanel(id)
		end })
		oddsBtn.AnchorPoint = Vector2.new(1, 0)
		oddsBtn.Position = UDim2.fromScale(1, 0)
		oddsBtn.Size = UDim2.fromOffset(104, 36)
		oddsBtn.TextSize = Theme.Type.Caption + 2
		oddsBtn.Parent = head
		add(head)
		add(Components.Paragraph(d.Look or "", Theme.Type.Caption + 1, Theme.Colors.TextMuted))
		-- Quick odds strip (full panel behind ⓘ).
		local strip = {}
		for _, row in CaseRoll.Odds(d) do
			table.insert(strip, string.format('<font color="#%s">%s %g%%</font>', rarityColor(row.Rarity):ToHex(), row.Rarity, math.floor(row.P * 1000 + 0.5) / 10))
		end
		local s = Components.Paragraph(table.concat(strip, "  ·  "), Theme.Type.Caption + 1)
		s.RichText = true
		add(s)
		-- Pity bar: "Epic in 4 · Legendary in 31".
		local pityParts = {}
		for _, p in CaseRoll.PityLeft(d, StateController:Get("PityCounters")) do
			table.insert(pityParts, `{p.Rarity} in {p.Left}`)
		end
		if #pityParts > 0 then
			local pity = Components.Paragraph("Pity: " .. table.concat(pityParts, " · "), Theme.Type.Body, Theme.Colors.Warning)
			pity.FontFace = Theme.Fonts.Bold
			add(pity)
		end
		if mode == "Owned" then
			add(Components.Paragraph(`You have {owned}.`, Theme.Type.Body))
		elseif (d.Stage or 99) > stage then
			add(Components.Paragraph(`Unlocks at Stage {d.Stage}. Win the Local Cup to get one sooner.`, Theme.Type.Body, Theme.Colors.TextMuted))
		end
		-- Buttons are built once per selection; money changes (income ticks every second) only update them in place,
		-- so a click is never lost to a rebuild.
		local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
		New("UIGridLayout", { CellSize = UDim2.fromOffset(156, 52), CellPadding = UDim2.fromOffset(Theme.Space.S, Theme.Space.S), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })
		local function money(): number
			return StateController:Get("Currencies." .. (d.Currency or "Cash")) or 0
		end
		for i, count in Cases.Counts do
			local needStage = Cases.CountStage[count] or 99
			local canStage = needStage <= stage and (mode == "Owned" or (d.Stage or 99) <= stage)
			local function enough(): boolean
				return if mode == "Owned" then owned >= count else money() >= (d.Price or math.huge) * count
			end
			local label = if needStage > stage then `×{count} · Stage {needStage}` elseif mode == "Owned" then `Open ×{count}` else `×{count} · {priceText(d, count)}`
			local b, setEnabled = Components.Button({ Text = label, Kind = if count == 1 then "Primary" else "Secondary", Width = 156, Order = i, OnClick = function()
				if opening or not canStage then
					return
				end
				if not enough() then
					local need = (d.Price or 0) * count - money()
					HudController:Toast(if mode == "Owned" then "Not enough crates." else `Need {if d.Currency == "Cash" then Format.Cash(need) else Format.Short(need)} more`, Theme.Colors.Warning)
					return
				end
				if onOpen then
					onOpen()
				end
				CaseController:Open(id, count, mode == "Owned")
			end })
			b.Name = `Open{count}`
			b.TextSize = Theme.Type.Body - 2
			setEnabled(canStage and enough())
			b.Parent = row
			table.insert(updaters, function()
				setEnabled(canStage and enough())
			end)
		end
		add(row)
		if mode == "Shop" and id == Cases.Free.CaseId and stage >= Cases.Free.Stage then
			local timer = Components.Paragraph("", Theme.Type.Caption + 2, Theme.Colors.Success)
			add(timer)
			local function tick()
				local at = StateController:Get("CaseStats.NextFreeAt") or 0
				local left = at - os.time()
				timer.Text = if at == 0 then "Free crate timer starts soon." elseif left > 0 then `Free {d.Name} in {Components.Clock(left)}` else "Free crate ready! Claim it from the button on your screen."
			end
			tick()
			table.insert(updaters, tick)
		end
	end

	renderShelf()
	renderDetails()
	-- Rebuild only when what's on the shelf changes; money and the timer update in place.
	for _, path in { "Inventory.Cases", "PityCounters", "Stage" } do
		table.insert(stops, StateController:Observe(path, function()
			if parent.Parent then
				renderShelf()
				renderDetails()
			end
		end))
	end
	table.insert(stops, StateController:Observe("Currencies", function()
		for _, u in updaters do
			u()
		end
	end))
	local alive = true
	task.spawn(function()
		while alive and parent.Parent do
			for _, u in updaters do
				u()
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

-- HUD context buttons ---------------------------------------------------------------------------------------------

local function contextButtons()
	StateController:Observe("Inventory.Cases", function(cases)
		local n = (cases or {}).StarterCrate or 0
		if n > 0 then
			HudController:SetContext("CrateButton", "🎁 Open Rookie Crate", Theme.Rarity.Rare, function()
				CaseController:Open("StarterCrate", 1, true)
			end)
		else
			HudController:ClearContext("CrateButton")
		end
	end)
	-- Free Rookie Crate (real-time timer, server-checked).
	task.spawn(function()
		while true do
			local at = StateController:Get("CaseStats.NextFreeAt") or 0
			local ready = at > 0 and os.time() >= at and (StateController:Get("Stage") or 1) >= Cases.Free.Stage
			if ready then
				HudController:SetContext("FreeCrate", "🎁 Free Rookie Crate!", Theme.Colors.Success, function()
					local ok, res = (Net.Get("Case", "ClaimFree") :: RemoteFunction):InvokeServer()
					if ok then
						HudController:ClearContext("FreeCrate")
						CaseController:Open(res, 1, true)
					else
						HudController:Toast(if type(res) == "table" and res.NextIn then `Next free crate in {Components.Clock(res.NextIn)}` else "Not yet!", Theme.Colors.Warning)
					end
				end)
			else
				HudController:ClearContext("FreeCrate")
			end
			task.wait(1)
		end
	end)
end

function CaseController:Start()
	StateController:WaitUntilLoaded()
	HudController:WaitUntilShown()
	contextButtons()
end

return CaseController

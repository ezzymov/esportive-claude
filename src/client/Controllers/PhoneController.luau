--!strict
-- PhoneController ([[Screen - Main HUD]] → Phone): right-rail Phone button, visible from Stage 1.
-- M1 apps: Messages (Aunt Dee's texts so far), Settings (Replay intro, Rename team — free until Stage 2).
-- M2/M3: Odds & Rules ([[Screen - Settings & Odds]]) and Leaderboards (Stage 3).
-- Dee's Tips replay, Social, Collection etc. arrive with their features.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Lines = require(ReplicatedStorage.Shared.Config.Tutorial.Lines)
local Steps = require(ReplicatedStorage.Shared.Config.Tutorial.Steps)
local Cases = require(ReplicatedStorage.Shared.Config.Cases)
local Competition = require(ReplicatedStorage.Shared.Config.Competition)
local Economy = require(ReplicatedStorage.Shared.Config.Economy)
local Format = require(ReplicatedStorage.Shared.Format)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)
local CutsceneController = require(script.Parent.CutsceneController)
local TeamCreatorController = require(script.Parent.TeamCreatorController)
local CaseController = require(script.Parent.CaseController)

local PhoneController = { Tier = 6 }

local log: { string } = {}
local unread = 0
local open = false

local function remember(id: string)
	local line = Lines[id]
	if line and line.Speaker == "Dee" then
		table.insert(log, line.Text)
		unread += 1
		HudController:SetBadge("Phone", tostring(unread))
	end
end

local function show()
	if open then
		return
	end
	open = true
	unread = 0
	HudController:SetBadge("Phone", nil)
	UIController:SetMenu("Phone", true)
	local overlay = UIController:GetGui("Overlay")
	local modal = Components.Modal(overlay, { Title = "Phone", Width = 0.36, Height = 0.82, OnClose = function()
		open = false
		UIController:SetMenu("Phone", false)
	end })
	local list = New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -190), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0, Parent = modal.Body })
	Components.List(list, Theme.Space.S)
	New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.TextMuted, TextXAlignment = Enum.TextXAlignment.Left, Text = "💬 Messages · Aunt Dee", LayoutOrder = 0, Parent = list })
	for i = #log, math.max(1, #log - 20), -1 do
		local bubble = Components.Paragraph(log[i], Theme.Type.Body, Theme.Colors.Text)
		bubble.BackgroundTransparency = 0
		bubble.BackgroundColor3 = Theme.Colors.Panel
		bubble.LayoutOrder = #log - i + 1
		Components.Corner(bubble, Theme.Radius.M)
		Components.Padding(bubble, Theme.Space.M, Theme.Space.S)
		bubble.Parent = list
	end
	local row = New("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 180), BackgroundTransparency = 1, Parent = modal.Body })
	Components.List(row, Theme.Space.S, false, Enum.HorizontalAlignment.Center)
	New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Caption, TextColor3 = Theme.Colors.TextMuted, Text = "⚙ Apps", LayoutOrder = 0, Parent = row })
	local apps = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 104), LayoutOrder = 3, Parent = row })
	New("UIGridLayout", { CellSize = UDim2.new(0.5, -4, 0, 48), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = apps })
	local odds = Components.Button({ Text = "📊 Odds & Rules", Kind = "Secondary", Order = 1, OnClick = function()
		modal.Close()
		task.wait(0.2)
		PhoneController:OddsAndRules()
	end })
	odds.TextSize = Theme.Type.Caption + 2
	odds.Parent = apps
	local boards, setBoards = Components.Button({ Text = "🏅 Leaderboards", Kind = "Secondary", Order = 2, OnClick = function()
		modal.Close()
		task.wait(0.2)
		PhoneController:Leaderboards()
	end })
	boards.TextSize = Theme.Type.Caption + 2
	setBoards((StateController:Get("Stage") or 1) >= Competition.Leaderboards.Stage)
	boards.Parent = apps
	local replay = Components.Button({ Text = "Replay intro", Kind = "Secondary", Width = 260, Order = 3, OnClick = function()
		modal.Close()
		task.wait(0.2)
		CutsceneController:PlayIntro(true)
	end })
	replay.TextSize = Theme.Type.Caption + 2
	replay.Parent = apps
	local free = (StateController:Get("Stage") or 1) < 2
	local rename, setRename = Components.Button({ Text = if free then "Rename team (free)" else "Rename team (39 R$)", Kind = "Secondary", Width = 260, Order = 4, OnClick = function()
		if (StateController:Get("Stage") or 1) < 2 then
			modal.Close()
			task.wait(0.2)
			TeamCreatorController:Open(false)
		end
	end })
	setRename(free)
	rename.TextSize = Theme.Type.Caption + 2
	rename.Parent = apps
end

local function sheet(title: string): ScrollingFrame
	local overlay = UIController:GetGui("Overlay")
	UIController:SetMenu("PhoneSheet", true)
	local modal = Components.Modal(overlay, { Title = title, Width = 0.55, Height = 0.82, OnClose = function()
		UIController:SetMenu("PhoneSheet", false)
	end })
	local list = New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0, Parent = modal.Body })
	Components.List(list, Theme.Space.S)
	return list
end

-- [[Screen - Settings & Odds]] → Odds & Rules: every case's odds + pity (same rows as the case screen) and how
-- matches are decided, in plain words.
function PhoneController:OddsAndRules()
	local list = sheet("Odds & Rules")
	local o = 0
	for _, id in Cases.Order do
		o = CaseController:OddsRows(list, id, o) + 1
	end
	local rules = {
		"<b>Duplicates</b> become Shards: a part once you own one per desk, an accessory once you own one per player, a player once your roster is full.",
		"<b>How matches are decided:</b> each team's power comes from its five players' stats (plus gear and PC parts unless it's a Pure match), morale, fatigue, chemistry, role coverage and how well the lineup fits the map. Every round is a weighted coin flip from the power difference; the weaker team always keeps at least an 8% chance per round, and 3+ round streaks give momentum.",
		"<b>Tournaments</b> play on a timer. Your lineup and map bans lock shortly before each match, and matches play even if you leave. Same seed, same result: skipping a wait can't reroll a match.",
		string.format("<b>Offline income</b>: hired players' desks earn at %d%% for up to %d hours.", Economy.Offline.Rate * 100, Economy.Offline.CapSeconds // 3600),
	}
	for i, text in rules do
		local p = Components.Paragraph(text, Theme.Type.Caption + 2, Theme.Colors.Text)
		p.RichText = true
		p.LayoutOrder = o + i
		p.Parent = list
	end
end

-- [[Social & Multiplayer]] → Leaderboards (Stage 3): top 10 by Fame and by trophies.
function PhoneController:Leaderboards()
	local list = sheet("Leaderboards")
	local loading = Components.Paragraph("Loading…", Theme.Type.Body, Theme.Colors.TextMuted)
	loading.Parent = list
	local ok, res = (Net.Get("Leaderboard", "Get") :: RemoteFunction):InvokeServer()
	loading:Destroy()
	if not ok then
		Components.Paragraph("Leaderboards are resting. Try again in a minute.", Theme.Type.Body, Theme.Colors.TextMuted).Parent = list
		return
	end
	local o = 0
	for _, board in res.Boards do
		o += 1
		local head = Components.Paragraph(`{board.Icon} {board.Name}{if res.Live then "" else " (this server)"}`, Theme.Type.H2, Theme.Colors.Warning)
		head.FontFace = Theme.Fonts.Heading
		head.LayoutOrder = o
		head.Parent = list
		if #board.Rows == 0 then
			o += 1
			local p = Components.Paragraph("Nobody yet. Reach Stage 3 to get on the board.", Theme.Type.Body, Theme.Colors.TextMuted)
			p.LayoutOrder = o
			p.Parent = list
		end
		for _, row in board.Rows do
			o += 1
			local p = Components.Paragraph(`{row.Rank}. {row.Name}  ·  {Format.Short(row.Value)}{if row.You then "  (you)" else ""}`, Theme.Type.Body, if row.You then Theme.Colors.Accent else Theme.Colors.Text)
			p.LayoutOrder = o
			p.Parent = list
		end
	end
end

function PhoneController:Start()
	StateController:WaitUntilLoaded()
	Net.Get("Tutorial", "Lines").OnClientEvent:Connect(function(ids: { string })
		for _, id in ids do
			remember(id)
		end
	end)
	StateController:Observe("Tutorial.Step", function(stepId)
		local step = Steps.ById[stepId or ""]
		if step and step.Lines.Intro then
			remember(step.Lines.Intro)
		end
	end)
	HudController:WaitUntilShown()
	HudController:AddRail("Right", "Phone", { Icon = "📱", Label = "Phone", Color = Theme.Rail.Phone, Order = 9, OnClick = show })
	HudController:ShowRail("Phone", true)
	HudController:SetBadge("Phone", if unread > 0 then tostring(unread) else nil)
end

return PhoneController

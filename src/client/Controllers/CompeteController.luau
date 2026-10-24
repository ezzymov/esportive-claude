--!strict
-- CompeteController ([[Screen - Main HUD]] rail #2 Compete, red, Stage 3; [[Screen - Bracket]], [[Matches & Tournaments]]).
--   Scrims: three AI offers (warm-up / even / tough) with the map veto (tap maps in the order you'd ban them; power
--     for you vs them on each map), the Pure skill toggle and Start.
--   Tournaments: the Local Cup card (format, prizes, Register) → the bracket: rounds left to right, your path in your
--     team color, "Next match in 3:12 · locks in 2:12", ⏩ Skip (Time Skip Ticket), your veto order, Watch, Close.
--   HUD: "▶ Watch" context button when a played match is unwatched; "while you were away" recap on join.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local Format = require(ReplicatedStorage.Shared.Format)
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Generator = require(ReplicatedStorage.Shared.Generator)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Competition = require(ReplicatedStorage.Shared.Config.Competition)
local Maps = require(ReplicatedStorage.Shared.Config.Maps)
local Cases = require(ReplicatedStorage.Shared.Config.Cases)
local Match = require(ReplicatedStorage.Shared.Config.Match)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)
local MatchController = require(script.Parent.MatchController)

local CompeteController = { Tier = 7 }

local isOpen = false
local closeOpen: (() -> ())? = nil

local function mapName(id: string): string
	local def = (Maps :: any)[id]
	return if def then def.Name else id
end

local function failToast(res: any)
	HudController:Toast(if type(res) == "table" and res.NeedStage then `Opens at Stage {res.NeedStage}`
		elseif res == "AlreadyIn" then "You're already in a tournament."
		elseif res == "NoTicket" then "You need a Time Skip Ticket to skip."
		elseif res == "RateLimited" then "One moment…"
		else `Couldn't do that ({tostring(res)})`, Theme.Colors.Warning)
end

-- Plays your match from a tournament round (the server regenerates it from the seed + your lineup snapshot).
function CompeteController:Watch(round: number)
	local ok, res = (Net.Get("Tournament", "Watch") :: RemoteFunction):InvokeServer(round)
	if not ok then
		failToast(res)
		return
	end
	if closeOpen then
		closeOpen()
	end
	MatchController:Watch(res.Plan, res.Result)
end

-- Scrims ----------------------------------------------------------------------------------------------------------

local function renderScrims(parent: Frame): () -> ()
	local alive = true
	local mobile = Components.IsMobile()
	local status = Components.Paragraph("Loading offers…", Theme.Type.Body, Theme.Colors.TextMuted)
	status.Parent = parent
	local ok, board = (Net.Get("Match", "ScrimBoard") :: RemoteFunction):InvokeServer()
	if not alive or not parent.Parent then
		return function() end
	end
	status:Destroy()
	if not ok then
		Components.Paragraph(if type(board) == "table" and board.NeedStage then `Scrims open at Stage {board.NeedStage}.` else "Scrims are closed right now.", Theme.Type.Body, Theme.Colors.TextMuted).Parent = parent
		return function() end
	end
	local selected = board.Offers[2] or board.Offers[1]
	local bans: { string } = {}
	local pure = false
	local left = New("Frame", { BackgroundTransparency = 1, Size = if mobile then UDim2.fromScale(1, 0.42) else UDim2.fromScale(0.44, 1), Parent = parent })
	Components.List(left, Theme.Space.S)
	local right = New("ScrollingFrame", { BackgroundColor3 = Theme.Colors.Panel, Position = if mobile then UDim2.fromScale(0, 0.44) else UDim2.fromScale(0.46, 0), Size = if mobile then UDim2.fromScale(1, 0.56) else UDim2.fromScale(0.54, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0, Parent = parent })
	Components.Corner(right, Theme.Radius.M)
	Components.Padding(right, Theme.Space.M, Theme.Space.M)
	local detail = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -14, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = right })
	local renderDetail: () -> ()

	local function renderOffers()
		left:ClearAllChildren()
		Components.List(left, Theme.Space.S)
		if board.StandIns > 0 then
			local p = Components.Paragraph(`{board.StandIns} stand-in{if board.StandIns == 1 then "" else "s"} will fill your five. More desks = more of your own players.`, Theme.Type.Caption + 1, Theme.Colors.Warning)
			p.LayoutOrder = 0
			p.Parent = left
		end
		for i, offer in board.Offers do
			local color = Color3.fromHex(offer.Team.Color)
			local b = New("TextButton", { Size = UDim2.new(1, 0, 0, 92), BackgroundColor3 = if offer == selected then Theme.Colors.Bg else Theme.Colors.Panel, Text = "", AutoButtonColor = false, LayoutOrder = i, Parent = left })
			Components.Corner(b, Theme.Radius.M)
			local edge = Components.Stroke(b, color)
			edge.Thickness = if offer == selected then 3 else 2
			edge.Transparency = if offer == selected then 0 else 0.5
			New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -24, 0, 26), FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.Body + 2, TextColor3 = color, TextXAlignment = Enum.TextXAlignment.Left, Text = `{offer.Label} · {offer.Team.Name} [{offer.Team.Tag}]`, Parent = b })
			New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 34), Size = UDim2.new(1, -24, 0, 20), FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Caption + 1, TextColor3 = Theme.Colors.TextMuted, TextXAlignment = Enum.TextXAlignment.Left, Text = `{offer.Team.Style} · avg OVR {offer.Ovr}`, Parent = b })
			New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 58), Size = UDim2.new(1, -24, 0, 24), FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Caption + 1, TextColor3 = Theme.Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = `"{offer.Team.Talk}"`, Parent = b })
			b.Activated:Connect(function()
				selected = offer
				table.clear(bans)
				renderOffers()
				renderDetail()
			end)
		end
	end

	renderDetail = function()
		detail:ClearAllChildren()
		Components.List(detail, Theme.Space.S)
		local o = 0
		local function add(inst: GuiObject)
			o += 1
			inst.LayoutOrder = o
			inst.Parent = detail
		end
		local head = Components.Paragraph(`vs {selected.Team.Name}`, Theme.Type.H2, Color3.fromHex(selected.Team.Color))
		head.FontFace = Theme.Fonts.Heading
		add(head)
		add(Components.Paragraph(if board.Veto then "Map veto (Bo1): tap maps in the order you'd ban them. You ban first, they ban next, the last map is played. Leave it empty to auto-ban your weakest map." else "Map: random from the pool.", Theme.Type.Caption + 1, Theme.Colors.TextMuted))
		for _, m in selected.Maps do
			local you = if pure then m.YouPure else m.You
			local edge = if m.Them > 0 then (you / m.Them - 1) * 100 else 0
			local banIdx = table.find(bans, m.Id)
			local def = (Maps :: any)[m.Id]
			local fav = selected.Team.Favorite == m.Id
			local b = Components.Button({ Text = string.format("%s%s · %s · you %d vs %d (%+.0f%%) · mastery %d%s", if banIdx then `BAN {banIdx} · ` else "", def.Name, def.Pace, you, m.Them, edge, m.Mastery, if fav then " · their favorite" else ""), Kind = "Secondary", Width = 300, OnClick = function()
				if not board.Veto then
					return
				end
				local at = table.find(bans, m.Id)
				if at then
					table.remove(bans, at)
				else
					table.insert(bans, m.Id)
				end
				renderDetail()
			end })
			b.Size = UDim2.new(1, 0, 0, 44)
			b.TextSize = Theme.Type.Caption + 2
			b.TextColor3 = if banIdx then Theme.Colors.Danger elseif edge >= 0 then Theme.Colors.Success else Theme.Colors.Text
			add(b)
		end
		-- Fatigue warning for your five.
		local tired = {}
		for _, card in StateController:Get("Roster") or {} do
			local _, fatigue = Ratings.Condition(card, os.time())
			if fatigue > Match.Fatigue.Threshold then
				table.insert(tired, if card.Source == "Founder" then "You" else Generator.Name(card))
			end
		end
		if #tired > 0 then
			add(Components.Paragraph(`Tired (-10%): {table.concat(tired, ", ")}. Rest a few minutes between scrims.`, Theme.Type.Caption + 1, Theme.Colors.Warning))
		end
		local pureBtn = Components.Button({ Text = if pure then "✔ Pure skill (no gear, no parts)" else "Pure skill: off (full gear)", Kind = "Secondary", Width = 300, OnClick = function()
			pure = not pure
			renderDetail()
		end })
		pureBtn.Size = UDim2.new(1, 0, 0, 44)
		add(pureBtn)
		local wait = board.Cooldown
		local start = Components.Button({ Text = if wait > 0 then `Scrim in {wait}s` else "▶ Start scrim", Width = 300, OnClick = function()
			if closeOpen then
				closeOpen()
			end
			MatchController:StartScrim(selected.Id, pure, table.clone(bans))
		end })
		start.Size = UDim2.new(1, 0, 0, 56)
		add(start)
		add(Components.Paragraph(string.format("Win: up to %s and %d★ × their power / yours. Scrims build chemistry (+%d mastery on the map) and fatigue (+%d).", Format.Cash(Competition.Scrim.WinCash.Max), Competition.Scrim.WinFame, Match.Mastery.Scrim, Match.Fatigue.Add.Scrim), Theme.Type.Caption + 1, Theme.Colors.TextMuted))
	end

	renderOffers()
	renderDetail()
	return function()
		alive = false
	end
end

-- Tournaments -----------------------------------------------------------------------------------------------------

local ROUND_W = 230

local function prizeLines(def: any): { string }
	local out = {}
	for i, p in def.Prizes do
		local nextP = def.Prizes[i + 1]
		local place = if p.Place == 1 then "1st" elseif nextP and nextP.Place - 1 > p.Place then `{p.Place}–{nextP.Place - 1}` elseif p.Place == 2 then "2nd" else `{p.Place}–{def.Teams}`
		local extras = {}
		if p.Case then
			table.insert(extras, (Cases :: any)[p.Case].Name)
		end
		if p.Trophy then
			table.insert(extras, "🏆 trophy")
		end
		table.insert(out, `{place}: {Format.Cash(p.Cash)} · {p.Fame} ★{if #extras > 0 then " · " .. table.concat(extras, " · ") else ""}`)
	end
	return out
end

local function renderTournaments(parent: Frame): () -> ()
	local stops: { () -> () } = {}
	local alive = true
	local timer: TextLabel? = nil

	local function render()
		parent:ClearAllChildren()
		timer = nil
		local t = StateController:Get("Tournament")
		local stage = StateController:Get("Stage") or 1
		if not t then
			-- Tournament list (just the Local Cup for now).
			Components.List(parent, Theme.Space.M)
			for i, id in Competition.Tournaments.Order do
				local def = (Competition.Tournaments :: any)[id]
				local card = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Colors.Panel, LayoutOrder = i, Parent = parent })
				Components.Corner(card, Theme.Radius.L)
				Components.Stroke(card, Theme.Colors.Warning)
				Components.Padding(card, Theme.Space.L, Theme.Space.L)
				Components.List(card, Theme.Space.S)
				local title = Components.Paragraph(`🏆 {def.Name}`, Theme.Type.H1, Theme.Colors.Warning)
				title.FontFace = Theme.Fonts.Heading
				title.LayoutOrder = 1
				title.Parent = card
				local info = Components.Paragraph(`{def.Teams} teams · single elimination · registration {math.floor(def.Registration / 60)} min · {math.floor(def.Wait / 60)} min between your matches. Your lineup locks {def.LockBefore}s before each match; it plays even if you leave.`, Theme.Type.Body, Theme.Colors.Text)
				info.LayoutOrder = 2
				info.Parent = card
				local prizes = Components.Paragraph(table.concat(prizeLines(def), "\n"), Theme.Type.Body, Theme.Colors.Success)
				prizes.LayoutOrder = 3
				prizes.Parent = card
				local reg, setReg = Components.Button({ Text = if stage < def.Stage then `Stage {def.Stage}` else "Register", Width = 240, Order = 4, OnClick = function()
					local ok, res = (Net.Get("Tournament", "Register") :: RemoteFunction):InvokeServer(id)
					if ok then
						HudController:Toast(`Registered for the {def.Name}! First match in {math.floor(def.Registration / 60)} min.`, Theme.Colors.Success)
					else
						failToast(res)
					end
				end })
				setReg(stage >= def.Stage)
				reg.Parent = card
			end
			local log = StateController:Get("TournamentLog") or {}
			if #log > 0 then
				local lines = {}
				for _, e in log do
					table.insert(lines, `{e.Name}: {if e.Place == 1 then "🏆 won" elseif e.Place == 2 then "2nd" elseif e.Place > 0 and e.Place <= 4 then "3rd–4th" elseif e.Place > 0 then "5th–8th" else "—"}`)
				end
				local p = Components.Paragraph("Recent: " .. table.concat(lines, " · "), Theme.Type.Caption + 1, Theme.Colors.TextMuted)
				p.LayoutOrder = 99
				p.Parent = parent
			end
			return
		end

		local def = (Competition.Tournaments :: any)[t.Def]
		local you = t.You
		local yourColor = Color3.fromHex(t.Teams[you].Color)
		-- Header.
		New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.H2, TextColor3 = Theme.Colors.Warning, TextXAlignment = Enum.TextXAlignment.Left, RichText = true, Text = `🏆 {def.Name}   <font color="#94A3B8" size="16">{prizeLines(def)[1]}</font>`, Parent = parent })
		-- Bracket tree: one column per round.
		local tree = New("ScrollingFrame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 40), Size = UDim2.new(0.7, 0, 1, -150), CanvasSize = UDim2.fromOffset(#t.Rounds * (ROUND_W + 20), 0), ScrollBarThickness = 6, BorderSizePixel = 0, ScrollingDirection = Enum.ScrollingDirection.X, Parent = parent })
		for r, round in t.Rounds do
			local col = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset((r - 1) * (ROUND_W + 20), 0), Size = UDim2.new(0, ROUND_W, 1, 0), Parent = tree })
			New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.TextMuted, Text = round.Name, Parent = col })
			local n = #round.Matches
			for m, match in round.Matches do
				local y = (m - 0.5) / n -- spread boxes so later rounds sit between their feeders
				local box = New("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, y, 14), Size = UDim2.fromOffset(ROUND_W, 64), BackgroundColor3 = Theme.Colors.Panel, Parent = col })
				Components.Corner(box, Theme.Radius.M)
				local mine = match.A == you or match.B == you
				local edge = Components.Stroke(box, if mine then yourColor else Theme.Colors.TextMuted)
				edge.Thickness = if mine then 3 else 1
				edge.Transparency = if mine then 0 else 0.7
				for k, side in { "A", "B" } do
					local idx = (match :: any)[side]
					local team = idx > 0 and t.Teams[idx]
					local scoreText = if match.Score then tostring(match.Score[k]) else ""
					local out = match.W ~= 0 and match.W ~= idx and idx > 0
					New("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(10, 4 + (k - 1) * 28),
						Size = UDim2.new(1, -20, 0, 26),
						FontFace = if idx == you then Theme.Fonts.Heading else Theme.Fonts.Bold,
						TextSize = Theme.Type.Body,
						TextColor3 = if not team then Theme.Colors.TextMuted elseif idx == you then yourColor else Color3.fromHex(team.Color),
						TextTransparency = if out then 0.6 else 0,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						RichText = true,
						Text = if team then `{team.SeedNo}. {team.Name}   <b>{scoreText}</b>` else "TBD",
						Parent = box,
					})
				end
				if match.Map and match.Map ~= "" then
					New("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 1, 2), Size = UDim2.fromOffset(ROUND_W, 14), FontFace = Theme.Fonts.Body, TextSize = 12, TextColor3 = Theme.Colors.TextMuted, TextXAlignment = Enum.TextXAlignment.Right, Text = mapName(match.Map), Parent = box })
				end
			end
		end
		-- Side panel: prizes + your veto order.
		local side = New("ScrollingFrame", { BackgroundColor3 = Theme.Colors.Panel, Position = UDim2.new(0.72, 0, 0, 40), Size = UDim2.new(0.28, 0, 1, -150), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0, Parent = parent })
		Components.Corner(side, Theme.Radius.M)
		Components.Padding(side, Theme.Space.M, Theme.Space.M)
		local sideBody = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -14, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = side })
		Components.List(sideBody, Theme.Space.S)
		local prizes = Components.Paragraph("Prizes\n" .. table.concat(prizeLines(def), "\n"), Theme.Type.Caption + 1, Theme.Colors.Success)
		prizes.LayoutOrder = 1
		prizes.Parent = sideBody
		if t.Status == "Running" and #t.Pool >= 3 then
			local vetoHead = Components.Paragraph("Your ban order (locked into each match):", Theme.Type.Caption + 1, Theme.Colors.Accent)
			vetoHead.LayoutOrder = 2
			vetoHead.Parent = sideBody
			for i, id in t.Pool do
				local banIdx = table.find(t.Bans or {}, id)
				local b = Components.Button({ Text = `{if banIdx then "BAN " .. banIdx .. " · " else ""}{mapName(id)}`, Kind = "Secondary", Width = 200, Order = 2 + i, OnClick = function()
					local list = table.clone(t.Bans or {})
					local at = table.find(list, id)
					if at then
						table.remove(list, at)
					else
						table.insert(list, id)
					end
					local ok, res = (Net.Get("Tournament", "SetBans") :: RemoteFunction):InvokeServer(list)
					if not ok then
						failToast(res)
					end
				end })
				b.Size = UDim2.new(1, 0, 0, 36)
				b.TextSize = Theme.Type.Caption + 1
				b.TextColor3 = if banIdx then Theme.Colors.Danger else Theme.Colors.Text
				b.Parent = sideBody
			end
		end

		-- Bottom bar: status, next match countdown, Skip / Watch / Close.
		local bar = New("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 100), BackgroundColor3 = Theme.Colors.Bg, Parent = parent })
		Components.Corner(bar, Theme.Radius.M)
		Components.Padding(bar, Theme.Space.M, Theme.Space.S)
		local statusText = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(0.55, 0, 1, 0), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, RichText = true, Text = "", Parent = bar })
		timer = statusText
		local buttons = New("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(0, 56), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Parent = bar })
		Components.List(buttons, Theme.Space.S, true)
		if t.Unwatched and t.Unwatched > 0 then
			local w = Components.Button({ Text = `▶ Watch {t.Rounds[t.Unwatched].Name}`, Width = 220, Order = 1, OnClick = function()
				CompeteController:Watch(t.Unwatched)
			end })
			w.Parent = buttons
		end
		if t.Status == "Running" then
			local tickets = StateController:Get("Inventory.TimeSkips.Quick") or 0
			local skip, setSkip = Components.Button({ Text = `⏩ Skip ({tickets})`, Kind = "Secondary", Width = 150, Order = 2, OnClick = function()
				local ok, res = (Net.Get("Tournament", "Skip") :: RemoteFunction):InvokeServer()
				if not ok then
					failToast(res)
				end
			end })
			setSkip(tickets > 0)
			skip.Parent = buttons
		else
			local close = Components.Button({ Text = "Close", Kind = "Secondary", Width = 140, Order = 3, OnClick = function()
				(Net.Get("Tournament", "Close") :: RemoteFunction):InvokeServer()
			end })
			close.Parent = buttons
			-- Older rounds can be rewatched.
			for r in t.Mine or {} do
				if r ~= t.Unwatched then
					local again = Components.Button({ Text = `Replay {t.Rounds[r].Name}`, Kind = "Secondary", Width = 190, Order = 10 + r, OnClick = function()
						CompeteController:Watch(r)
					end })
					again.Parent = buttons
				end
			end
		end
	end

	local function tick()
		local t = StateController:Get("Tournament")
		if not t or not timer then
			return
		end
		local def = (Competition.Tournaments :: any)[t.Def]
		if t.Status == "Won" then
			timer.Text = `<font color="#FBBF24">🏆 CHAMPIONS!</font> {def.Name} won · trophy on your shelf`
			return
		elseif t.Status == "Eliminated" then
			local last = t.Mine[#t.Mine]
			timer.Text = `Knocked out in the {if last then t.Rounds[last.Round].Name else "bracket"} · {if t.Place == 2 then "2nd" elseif t.Place <= 4 then "3rd–4th" else "5th–8th"} · {Format.Cash(t.Prize and t.Prize.Cash or 0)} + {t.Prize and t.Prize.Fame or 0} ★`
			return
		end
		local now = os.time()
		for _, round in t.Rounds do
			if not round.Played then
				local plays, locks = round.PlaysAt - now, round.LocksAt - now
				timer.Text = if plays <= 0 then `{round.Name}: playing now…`
					else `{round.Name} in <b>{Components.Clock(plays)}</b>{if locks > 0 then " · lineup locks in " .. Components.Clock(locks) else " · lineup locked"}\nTrain, scrim or open crates while you wait.`
				return
			end
		end
	end

	render()
	table.insert(stops, StateController:Observe("Tournament", function()
		if alive and parent.Parent then
			render()
			tick()
		end
	end))
	task.spawn(function()
		while alive and parent.Parent do
			tick()
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

function CompeteController:Open(tab: string?)
	if isOpen then
		return
	end
	isOpen = true
	UIController:SetMenu("Compete", true)
	local overlay = UIController:GetGui("Overlay")
	local cleanup: (() -> ())? = nil
	local modal = Components.Modal(overlay, { Title = "Compete", Width = 0.86, Height = 0.88, OnClose = function()
		isOpen = false
		closeOpen = nil
		if cleanup then
			cleanup()
		end
		UIController:SetMenu("Compete", false)
	end })
	closeOpen = modal.Close
	local content = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 1, -52), Parent = modal.Body })
	Components.Tabs(modal.Body, { { Id = "Scrims", Label = "⚔ Scrims" }, { Id = "Tournaments", Label = "🏆 Tournaments" } }, tab or (if StateController:Get("Tournament") then "Tournaments" else "Scrims"), function(id)
		if cleanup then
			cleanup()
			cleanup = nil
		end
		content:ClearAllChildren()
		cleanup = if id == "Scrims" then renderScrims(content) else renderTournaments(content)
	end)
end

-- "While you were away" recap ([[Matches & Tournaments]] → Offline).
local function recap(lines: { string })
	local overlay = UIController:GetGui("Overlay")
	local modal = Components.Modal(overlay, { Title = "While you were away", Width = 0.5, Height = 0.6, NoClose = true })
	local body = Components.Paragraph(table.concat(lines, "\n"), Theme.Type.Body + 2, Theme.Colors.Text)
	body.Parent = modal.Body
	local ok = Components.Button({ Text = "See the bracket", Width = 240, OnClick = function()
		modal.Close()
		task.spawn(function()
			(Net.Get("Tournament", "Close") :: RemoteFunction):InvokeServer() -- clears the recap (archives if finished)
		end)
		CompeteController:Open("Tournaments")
	end })
	ok.AnchorPoint = Vector2.new(0.5, 1)
	ok.Position = UDim2.fromScale(0.5, 1)
	ok.Parent = modal.Body
end

function CompeteController:Start()
	StateController:WaitUntilLoaded()
	HudController:WaitUntilShown()
	HudController:AddRail("Left", "Compete", { Icon = "⚔", Label = "Compete", Color = Theme.Colors.Danger, Order = 2, OnClick = function()
		CompeteController:Open()
	end })
	StateController:Observe("Stage", function(stage)
		HudController:ShowRail("Compete", (stage or 1) >= Competition.Stage)
	end)
	local recapShown = false
	StateController:Observe("Tournament", function(t)
		-- Watch button for your latest played match.
		if t and t.Unwatched and t.Unwatched > 0 and not MatchController:IsPlaying() then
			HudController:SetContext("NextMatch", `▶ Watch {t.Rounds[t.Unwatched].Name}`, Theme.Colors.Danger, function()
				CompeteController:Watch(t.Unwatched)
			end)
		else
			HudController:ClearContext("NextMatch")
		end
		HudController:SetBadge("Compete", if t and t.Unwatched and t.Unwatched > 0 then "!" else nil)
		if t and t.Recap and #t.Recap > 0 and not recapShown then
			recapShown = true
			recap(t.Recap)
		end
	end)
	Net.Get("Tournament", "MatchReady").OnClientEvent:Connect(function(_round: number, line: string)
		HudController:Toast(`🏆 {line} · tap ▶ Watch`, Theme.Colors.Warning)
	end)
end

return CompeteController

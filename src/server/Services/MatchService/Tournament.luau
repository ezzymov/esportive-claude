--!strict
-- Timed tournaments ([[Matches & Tournaments]] → Tournament timing): the Local Cup, 8 AI-filled teams, single elim.
-- Register → the server fixes the bracket, the AI teams and a tournament seed. Each round has a lock time (your
-- lineup, gear and map bans are snapshotted) and a play time. Lazy resolution: on join and on a 10 s tick while
-- you're online, every round whose time has passed resolves in order from the seed + snapshot, so a tournament
-- gives the same results whenever it's computed. Rounds that resolve on join become a recap. AI-only for now.
--   Tournament/Register (RF) defId        Tournament/SetBans (RF) { mapIds } (your veto order, used at lock)
--   Tournament/Watch (RF) round → plan with every round + result (regenerated, nothing new is paid)
--   Tournament/Skip (RF) → spends a Time Skip Ticket (Quick): your next match plays now
--   Tournament/Close (RF) → archives a finished tournament (also clears the recap)
--   Tournament/MatchReady (S→C) round, line → "Watch" toast while online

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lib = script.Parent.Parent.Parent.Lib
local Remote = require(Lib.Remote)
local Log = require(Lib.Log)
local Bus = require(Lib.Bus)
local Services = script.Parent.Parent
local DataService = require(Services.DataService)
local EconomyService = require(Services.EconomyService)
local AnalyticsService = require(Services.AnalyticsService)
local CaseService = require(Services.CaseService)
local RosterService = require(Services.RosterService)
local MapService = require(Services.MapService)
local PlotService = require(Services.PlotService)
local Generator = require(ReplicatedStorage.Shared.Generator)
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Competition = require(ReplicatedStorage.Shared.Config.Competition)
local AITeams = require(ReplicatedStorage.Shared.Config.AITeams)
local Maps = require(ReplicatedStorage.Shared.Config.Maps)
local Match = require(ReplicatedStorage.Shared.Config.Match)
local Team = require(ReplicatedStorage.Shared.Config.Team)
local Sim = require(script.Parent.Sim)
local Teams = require(script.Parent.Teams)

local Tournament = {}

local MS: any = nil -- MatchService (Entries, AfterMatch, InMatch); set in Init to avoid a require cycle
local readyRemote: RemoteEvent
local busy: { [Player]: boolean } = {}
local rng = Random.new()

-- Seed in each bracket slot for n teams (power of 2): 1 meets n first, 1 and 2 only meet in the final.
-- n = 8 → { 1, 8, 4, 5, 2, 7, 3, 6 }.
local function slotOrder(n: number): { number }
	local order = { 1, 2 }
	while #order < n do
		local nextOrder = {}
		for _, s in order do
			table.insert(nextOrder, s)
			table.insert(nextOrder, 2 * #order + 1 - s)
		end
		order = nextOrder
	end
	return order
end

local function defOf(t: any): any
	return (Competition.Tournaments :: any)[t.Def]
end

local function mix(...: number): number
	local h = 0
	for _, n in { ... } do
		h = (h * 31 + n) % 1073741789
	end
	return h + 1
end

-- Your active five + stand-ins, as sim entries (Full gear: tournaments always count everything).
local function lineupEntries(player: Player, data: any): ({ any }, { any })
	local cards = table.clone(RosterService:ActiveFive(data))
	for _, standIn in Teams.Pugs(5 - #cards, Random.new(#cards + 1), "Common", "StandIn", { 32, 38 }) do
		table.insert(cards, standIn)
	end
	return MS:Entries(player, data, cards, "Full"), cards
end

local function aiCards(t: any, idx: number): { any }
	local team = t.Teams[idx]
	return Teams.AI(team.Id, team.Seed, team.Ovr)
end

local function plain(cards: { any }): { any }
	local out = {}
	for _, c in cards do
		table.insert(out, Teams.Plain(c))
	end
	return out
end

local function cardsOf(entries: { any }): { any }
	local out = {}
	for _, e in entries do
		table.insert(out, e.Card)
	end
	return out
end

-- Sim setup for one bracket match. Your side comes from the round's snapshot.
local function setupFor(t: any, r: number, m: number, mapId: string): Sim.Setup
	local round = t.Rounds[r]
	local match = round.Matches[m]
	local function side(idx: number): any
		if idx == t.You then
			local snap = t.Snapshots[r]
			return { Players = snap.Players, Chemistry = snap.Chemistry, Mastery = snap.Mastery[mapId] or 0, Fit = MapService:Fit(cardsOf(snap.Players), mapId) }
		end
		local cards = aiCards(t, idx)
		local fav = (AITeams :: any)[t.Teams[idx].Id].Favorite
		return { Players = plain(cards), Chemistry = 30, Mastery = if fav == mapId then 60 else 25, Fit = MapService:Fit(cards, mapId) }
	end
	return {
		A = side(match.A),
		B = side(match.B),
		Seed = mix(t.Seed, r, m),
		Weights = MapService:Weights(mapId),
		Kind = "Tournament",
		Final = r == #t.Rounds,
		Hour = tonumber(os.date("!%H", round.PlaysAt)) or 12,
	}
end

-- Bo1 veto for a bracket match: you use your snapshotted ban order; AI teams auto-ban.
local function vetoFor(t: any, r: number, m: number): any
	local match = t.Rounds[r].Matches[m]
	local pool = t.Pool
	if #pool < 3 then
		return { Map = pool[1 + mix(t.Seed, r, m) % #pool], Bans = {} }
	end
	local cache = {}
	local function edge(id: string): number
		if not cache[id] then
			local s = Sim.New(setupFor(t, r, m, id))
			cache[id] = s.PowerA / math.max(s.PowerB, 1)
		end
		return cache[id]
	end
	local favB = if match.B ~= t.You then (AITeams :: any)[t.Teams[match.B].Id].Favorite else nil
	local bansA = if match.A == t.You then t.Snapshots[r].Bans else nil
	return MapService:Veto(pool, bansA, edge, favB)
end

local function playMatch(t: any, r: number, m: number): (Sim.State, any)
	local veto = vetoFor(t, r, m)
	local s = Sim.New(setupFor(t, r, m, veto.Map))
	Sim.Finish(s, 0)
	return s, veto
end

local function placeFor(t: any, r: number, won: boolean): number
	if won then
		return 1
	end
	return 2 ^ (#t.Rounds - r) + 1 -- final loss 2nd, semi 3rd–4th, quarter 5th–8th
end

local function prizeFor(def: any, place: number): any
	local prize = def.Prizes[#def.Prizes]
	for _, p in def.Prizes do
		if p.Place <= place then
			prize = p
		end
	end
	return prize
end

local function placeText(place: number): string
	return if place == 1 then "Champions" elseif place == 2 then "2nd" elseif place <= 4 then "3rd–4th" else "5th–8th"
end

-- Pays the placement prize once.
local function finish(player: Player, t: any, place: number)
	local def = defOf(t)
	local prize = prizeFor(def, place)
	EconomyService:Transact(player, { Cash = prize.Cash or 0, Fame = prize.Fame or 0 }, `Tournament:{t.Def}:P{place}`)
	if prize.Case then
		CaseService:GrantCase(player, prize.Case, 1, `Tournament:{t.Def}`)
	end
	if prize.Trophy then
		DataService:Update(player, "Trophies", function(list)
			table.insert(list, { Def = t.Def, Name = def.Name, Place = place, At = os.time() })
			return list
		end)
	end
	DataService:Update(player, "Competition", function(c)
		c.Cups = (c.Cups or 0) + 1
		c.CupWins = (c.CupWins or 0) + (if place == 1 then 1 else 0)
		return c
	end)
	DataService:Update(player, "Tournament.Place", function()
		return place
	end)
	DataService:Update(player, "Tournament.Status", function()
		return if place == 1 then "Won" else "Eliminated"
	end)
	DataService:Update(player, "Tournament.Prize", function()
		return { Cash = prize.Cash or 0, Fame = prize.Fame or 0, Case = prize.Case or "", Trophy = prize.Trophy == true }
	end)
	AnalyticsService:Custom(player, "TournamentFinished", place, { def = t.Def })
	Log.Info("Tournament", `{player.Name} {def.Name}: {placeText(place)} (+${prize.Cash or 0}, +{prize.Fame or 0} Fame{if prize.Case then ", " .. prize.Case else ""})`)
	Bus.Fire(player, "TournamentFinished", { Place = place, Def = t.Def })
	PlotService:Refresh(player) -- trophy shelf
	DataService:SaveNow(player, "TournamentFinished")
end

-- Profile.Tournament holds arrays (rounds, matches, snapshots), and Update paths use string keys, so changes to
-- array elements go through the whole tournament table.
local function mutate(player: Player, fn: (any) -> ())
	DataService:Update(player, "Tournament", function(t)
		if t then
			fn(t)
		end
		return t
	end)
end

local function snapshot(player: Player, data: any, t: any, r: number)
	local entries, cards = lineupEntries(player, data)
	local snap = Teams.Snapshot(entries, Teams.Chemistry(data, cards), data.MapMastery or {})
	snap.Bans = table.clone(t.Bans or {})
	mutate(player, function(tt)
		tt.Snapshots[r] = snap
	end)
end

-- Resolves every round that's due, in order. offline = rounds that played while you were away (→ recap).
function Tournament.ResolveDue(player: Player, offline: boolean?)
	if busy[player] then
		return
	end
	local data = DataService:GetProfile(player)
	local t = data and data.Tournament
	if not t or t.Status ~= "Running" then
		return
	end
	busy[player] = true
	local ok, err = pcall(function()
		local def = defOf(t)
		local now = os.time()
		local recap = {}
		for r, round in t.Rounds do
			if t.Status ~= "Running" then
				break
			end
			if round.Played then
				continue
			end
			if not t.Snapshots[r] and now >= round.LocksAt then
				snapshot(player, data, t, r)
			end
			if now < round.PlaysAt then
				break
			end
			if not t.Snapshots[r] then
				snapshot(player, data, t, r)
			end
			local winners = {}
			local mine = nil
			for m, match in round.Matches do
				local s, veto = playMatch(t, r, m)
				local summary = Sim.Summary(s)
				local w = if summary.Winner == "A" then match.A else match.B
				mutate(player, function(tt)
					local mm = tt.Rounds[r].Matches[m]
					mm.W = w
					mm.Score = { s.A, s.B }
					mm.Map = veto.Map
				end)
				table.insert(winners, w)
				if match.A == t.You then
					local opp = t.Teams[match.B]
					local won = w == t.You
					local snapCards = cardsOf(t.Snapshots[r].Players)
					local mvp = summary.Mvp
					local mvpCard = if mvp.Side == "A" then snapCards[mvp.Index] else aiCards(t, match.B)[mvp.Index]
					mine = {
						Round = r,
						Opponent = opp.Name,
						Win = won,
						Score = { s.A, s.B },
						Map = veto.Map,
						Mvp = if mvpCard.Source == "Founder" then player.DisplayName else Generator.Name(mvpCard),
					}
					mutate(player, function(tt)
						tt.Mine[r] = mine
					end)
					MS:AfterMatch(player, "Tournament", snapCards, won, veto.Map, summary.Kills.A)
					local line = `{def.RoundNames[r] or ("Round " .. r)}: {if won then "won" else "lost"} {s.A}–{s.B} vs {opp.Name} on {(Maps :: any)[veto.Map].Name}`
					table.insert(recap, line)
					DataService:Update(player, "Tournament.Unwatched", function()
						return r
					end)
					if not offline then
						readyRemote:FireClient(player, r, line)
					end
					AnalyticsService:Custom(player, "TournamentMatch", if won then 1 else 0, { round = r, def = t.Def })
				end
			end
			mutate(player, function(tt)
				tt.Rounds[r].Played = true
				-- Next round's pairings. Keep "you" on side A so your snapshot is always team A in the sim.
				local nextRound = tt.Rounds[r + 1]
				if nextRound then
					for i, mm in nextRound.Matches do
						mm.A, mm.B = winners[2 * i - 1], winners[2 * i]
						if mm.B == tt.You then
							mm.A, mm.B = mm.B, mm.A
						end
					end
				end
			end)
			if mine and not mine.Win then
				local place = placeFor(t, r, false)
				table.insert(recap, `Knocked out: {placeText(place)}`)
				finish(player, t, place)
			elseif mine and mine.Win and r == #t.Rounds then
				table.insert(recap, `🏆 {def.Name} champions!`)
				finish(player, t, 1)
			end
		end
		if offline and #recap > 0 then
			DataService:Update(player, "Tournament.Recap", function()
				return recap
			end)
		end
	end)
	busy[player] = nil
	if not ok then
		warn(`[Tournament] resolve failed for {player.Name}: {err}`)
	end
end

local function archive(player: Player, data: any)
	local t = data.Tournament
	if not t then
		return
	end
	DataService:Update(player, "TournamentLog", function(log)
		table.insert(log, 1, { Def = t.Def, Place = t.Place or 0, At = t.RegisteredAt, Name = defOf(t).Name })
		while #log > Competition.LogSize do
			table.remove(log)
		end
		return log
	end)
	DataService:Update(player, "Tournament", function()
		return nil
	end)
end

local function register(player: Player, defId: string): (boolean, any)
	local data = DataService:GetProfile(player)
	local def = (Competition.Tournaments :: any)[defId]
	if not data or not def then
		return false, "Unknown"
	end
	if data.Stage < def.Stage then
		return false, { NeedStage = def.Stage }
	end
	local current = data.Tournament
	if current and current.Status == "Running" then
		return false, "AlreadyIn" -- one tournament at a time
	end
	if current then
		archive(player, data)
	end
	local seed = rng:NextInteger(1, 2 ^ 30)
	local trng = Random.new(seed)
	local now = os.time()
	-- Seven AI teams spread across the band, plus you; seeded by strength.
	local ids = table.clone(AITeams.Order)
	local entrants = {}
	local band = def.Ovr
	for k = 0, def.Teams - 2 do
		local id = table.remove(ids, trng:NextInteger(1, #ids)) :: string
		local ai = (AITeams :: any)[id]
		local ovr = band[2] - k * (band[2] - band[1]) / math.max(def.Teams - 2, 1) + trng:NextInteger(-1, 1)
		table.insert(entrants, { Id = id, Name = ai.Name, Tag = ai.Tag, Color = ai.Color, Ovr = math.round(ovr), Seed = trng:NextInteger(1, 2 ^ 30) })
	end
	local mineCards = RosterService:ActiveFive(data)
	local myOvr = 0
	for _, c in mineCards do
		myOvr += Ratings.Ovr(c)
	end
	myOvr = if #mineCards > 0 then myOvr / #mineCards else 30
	table.insert(entrants, { Id = "You", Name = data.Team.Name, Tag = data.Team.Tag, Color = Team.Colors[data.Team.Colors.Primary or 1] or Team.Colors[1], Ovr = math.round(myOvr), Seed = 0 })
	table.sort(entrants, function(a, b)
		return a.Ovr > b.Ovr
	end)
	for i, e in entrants do
		e.SeedNo = i
	end
	local slots = {}
	local you = 0
	for i, seedNo in slotOrder(def.Teams) do
		slots[i] = entrants[seedNo]
		if entrants[seedNo].Id == "You" then
			you = i
		end
	end
	local rounds = {}
	local nRounds = 0
	local left = def.Teams
	while left > 1 do -- integer log2 (math.log can land on 2.999…)
		left //= 2
		nRounds += 1
	end
	for r = 1, nRounds do
		local playsAt = now + def.Registration + (r - 1) * def.Wait
		local matches = {}
		for m = 1, def.Teams // 2 ^ r do
			table.insert(matches, if r == 1 then { A = 2 * m - 1, B = 2 * m, W = 0 } else { A = 0, B = 0, W = 0 })
		end
		-- Your first match: you on side A.
		if r == 1 then
			for _, mm in matches do
				if mm.B == you then
					mm.A, mm.B = mm.B, mm.A
				end
			end
		end
		table.insert(rounds, { Name = def.RoundNames[r] or `Round {r}`, LocksAt = playsAt - def.LockBefore, PlaysAt = playsAt, Played = false, Matches = matches })
	end
	local t = {
		Id = tostring(seed),
		Def = defId,
		Seed = seed,
		RegisteredAt = now,
		Status = "Running",
		You = you,
		Teams = slots,
		Rounds = rounds,
		Pool = MapService:Pool(data.Stage),
		Snapshots = {},
		Mine = {},
		Bans = {},
		Place = 0,
		Unwatched = 0,
		Recap = {},
	}
	DataService:Update(player, "Tournament", function()
		return t
	end)
	AnalyticsService:Custom(player, "TournamentRegistered", 1, { def = defId })
	Log.Info("Tournament", `{player.Name} registered for {def.Name} (bracket slot {you}, {math.round(myOvr)} OVR)`)
	Bus.Fire(player, "TournamentRegistered", defId)
	DataService:SaveNow(player, "TournamentRegistered")
	return true, t.Id
end

local function setBans(player: Player, bans: { string }): (boolean, any)
	local data = DataService:GetProfile(player)
	local t = data and data.Tournament
	if not t or t.Status ~= "Running" then
		return false, "NoTournament"
	end
	for _, id in bans do
		if not table.find(t.Pool, id) then
			return false, "BadMap"
		end
	end
	DataService:Update(player, "Tournament.Bans", function()
		return table.clone(bans)
	end)
	return true, bans
end

-- Your match in round r, played back from the seed + snapshot (no new rewards).
local function watch(player: Player, r: number): (boolean, any)
	local data = DataService:GetProfile(player)
	local t = data and data.Tournament
	if not t or not t.Rounds[r] or not t.Rounds[r].Played or not t.Snapshots[r] then
		return false, "NotPlayed"
	end
	local m = nil
	for i, mm in t.Rounds[r].Matches do
		if mm.A == t.You then
			m = i
		end
	end
	if not m then
		return false, "NotYours"
	end
	local s, veto = playMatch(t, r, m)
	local summary = Sim.Summary(s)
	local def = defOf(t)
	local match = t.Rounds[r].Matches[m]
	local opp = t.Teams[match.B]
	local final = r == #t.Rounds
	local mineCards = cardsOf(t.Snapshots[r].Players)
	local function views(cards: { any }, tag: string): { any }
		local out = {}
		for _, c in cards do
			table.insert(out, Teams.View(c, tag, player.DisplayName))
		end
		return out
	end
	local endedRun = (summary.Winner ~= "A") or final
	local prize = if endedRun and t.Place > 0 then t.Prize else nil
	if t.Unwatched == r then
		DataService:Update(player, "Tournament.Unwatched", function()
			return 0
		end)
	end
	local def2 = (Maps :: any)[veto.Map]
	return true, {
		Plan = {
			MatchId = `T{t.Id}-{r}`,
			Kind = "Tournament",
			Title = Match.TitleName,
			Event = `{def.Name} · {def.RoundNames[r] or ("Round " .. r)}`,
			MapId = veto.Map,
			Map = def2.Name,
			Veto = veto,
			Pure = false,
			Intensity = if final then 3 else 2,
			Teams = {
				A = { Name = data.Team.Name, Tag = data.Team.Tag, Color = t.Teams[t.You].Color, Players = views(mineCards, data.Team.Tag), Power = math.floor(s.PowerA) },
				B = { Name = opp.Name, Tag = opp.Tag, Color = opp.Color, Talk = (AITeams :: any)[opp.Id].Talk[1 + t.Seed % #(AITeams :: any)[opp.Id].Talk], Players = views(aiCards(t, match.B), opp.Tag), Power = math.floor(s.PowerB) },
			},
			Rounds = s.Rounds,
			RoundSeconds = Match.RoundSeconds,
		},
		Result = {
			Winner = summary.Winner,
			Score = summary.Score,
			Ratings = summary.Ratings,
			Mvp = summary.Mvp,
			Moments = summary.Moments,
			Upset = summary.Upset,
			Comeback = summary.Comeback,
			Records = summary.Records,
			Rewards = if prize then { Cash = prize.Cash, Fame = prize.Fame, Case = prize.Case, Trophy = prize.Trophy } else { Cash = 0, Fame = 0 },
			Place = if endedRun then t.Place else nil,
			Champion = final and summary.Winner == "A",
		},
	}
end

local function skip(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	local t = data and data.Tournament
	if not t or t.Status ~= "Running" then
		return false, "NoTournament"
	end
	if (data.Inventory.TimeSkips.Quick or 0) < 1 then
		return false, "NoTicket"
	end
	Tournament.SkipToNext(player, "Ticket")
	return true, "Skipped"
end

-- Moves your next unplayed round to now (later rounds keep their spacing). Same seed: it can't reroll a result.
function Tournament.SkipToNext(player: Player, reason: string): boolean
	local data = DataService:GetProfile(player)
	local t = data and data.Tournament
	if not t or t.Status ~= "Running" then
		return false
	end
	local now = os.time()
	local nextR = nil
	for r, round in t.Rounds do
		if not round.Played then
			nextR = r
			break
		end
	end
	if not nextR then
		return false
	end
	local delta = t.Rounds[nextR].PlaysAt - now
	if delta <= 0 then
		Tournament.ResolveDue(player)
		return true
	end
	if reason == "Ticket" then
		DataService:Update(player, "Inventory.TimeSkips.Quick", function(n)
			return math.max(0, (n or 0) - 1)
		end)
	end
	DataService:Update(player, "Tournament.Rounds", function(rounds)
		for r = nextR, #rounds do
			rounds[r].PlaysAt -= delta
			rounds[r].LocksAt = math.min(rounds[r].LocksAt - delta, now)
		end
		return rounds
	end)
	Log.Info("Tournament", `{player.Name} skipped {delta}s ({reason})`)
	Tournament.ResolveDue(player)
	return true
end

local function close(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	local t = data and data.Tournament
	if not t then
		return false, "NoTournament"
	end
	if t.Status == "Running" then
		if #t.Recap > 0 then
			DataService:Update(player, "Tournament.Recap", function()
				return {}
			end)
			return true, "RecapCleared"
		end
		return false, "Running"
	end
	archive(player, data)
	return true, "Closed"
end

function Tournament.Init(matchService: any)
	MS = matchService
	readyRemote = Remote.Push("Tournament", "MatchReady")
	local defIds = {}
	for _, id in Competition.Tournaments.Order do
		table.insert(defIds, id)
	end
	Remote.Function("Tournament", "Register", { Args = { Remote.T.OneOf(defIds) }, Rate = { Count = 1, Per = 2 } }, register)
	Remote.Function("Tournament", "SetBans", { Args = { Remote.T.StringList(32, 8) }, Rate = { Count = 2, Per = 1 } }, setBans)
	Remote.Function("Tournament", "Watch", { Args = { Remote.T.Int(1, 8) }, Rate = { Count = 1, Per = 2 } }, watch)
	Remote.Function("Tournament", "Skip", { Rate = { Count = 1, Per = 2 } }, skip)
	Remote.Function("Tournament", "Close", { Rate = { Count = 2, Per = 1 } }, close)
	DataService.ProfileLoaded:Connect(function(player)
		task.defer(Tournament.ResolveDue, player, true) -- rounds that played while you were away → recap
	end)
end

function Tournament.Start()
	Players.PlayerRemoving:Connect(function(player)
		busy[player] = nil
	end)
	while true do
		task.wait(10)
		for _, player in Players:GetPlayers() do
			task.spawn(Tournament.ResolveDue, player)
		end
	end
end

return Tournament

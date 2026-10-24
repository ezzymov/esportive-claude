--!strict
-- MatchService ([[Match Simulation]], [[Matches & Tournaments]], [[Founder (You)]] → Pickup Games).
-- Builds both teams, runs the engine (Sim), streams a compact MatchResult to the client (it only plays it back),
-- pays rewards and applies after-match effects (fatigue, morale, chemistry, map mastery, personal bests).
--   Match/StartPickup (RF) → plan. Your active five + pugs vs a pickup lobby (tougher by stage); 75 s cooldown, pity.
--   Match/ScrimBoard (RF) → 3 AI scrim offers with your/their power per map (for the veto). Stage 3.
--   Match/StartScrim (RF) offerId, pure, bans → plan. Bo1 veto, then the match: Full gear, or Pure with the toggle.
--   Match/Resolve (RF) matchId, clutchQuality 0–1 → { Rounds (rest), Result }. Skip = 0. Idempotent.
-- Rewards land when the match resolves (on Resolve, after ResolveTimeout, or when the player leaves).
-- Pickup pity: the first ever Pickup Game is a guaranteed win; before the FTUE crate, a team game after a
-- team-game loss is too (keeps "first unbox by ~11 min").
-- Timed tournaments live in MatchService/Tournament.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lib = script.Parent.Parent.Lib
local Remote = require(Lib.Remote)
local Log = require(Lib.Log)
local Bus = require(Lib.Bus)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local AnalyticsService = require(script.Parent.AnalyticsService)
local PlotService = require(script.Parent.PlotService)
local RosterService = require(script.Parent.RosterService)
local CaseService = require(script.Parent.CaseService)
local GearService = require(script.Parent.GearService)
local StationService = require(script.Parent.StationService)
local MapService = require(script.Parent.MapService)
local Ratings = require(ReplicatedStorage.Shared.Ratings)
local Generator = require(ReplicatedStorage.Shared.Generator)
local Minigames = require(ReplicatedStorage.Shared.Config.Minigames)
local Match = require(ReplicatedStorage.Shared.Config.Match)
local Maps = require(ReplicatedStorage.Shared.Config.Maps)
local AITeams = require(ReplicatedStorage.Shared.Config.AITeams)
local Traits = require(ReplicatedStorage.Shared.Config.Traits)
local Competition = require(ReplicatedStorage.Shared.Config.Competition)
local Team = require(ReplicatedStorage.Shared.Config.Team)
local Sim = require(script.Sim)
local Teams = require(script.Teams)
local Tournament = require(script.Tournament)

local MatchService = { Tier = 4 }

local PICKUP = Minigames.Pickup
local SCRIM = Competition.Scrim

type Active = {
	Id: string,
	Kind: string,
	State: Sim.State,
	Sent: number, -- rounds already sent to the client
	Cards: { any }, -- team A cards in order (owned + pugs)
	Owned: number,
	Pity: boolean,
	MapId: string,
	Mode: string,
	Opponent: string,
	Resolved: any?,
	StartedAt: number,
}

local active: { [Player]: Active } = {}
local lastStart: { [Player]: number } = {}
local lastScrim: { [Player]: number } = {}
type Offer = { Id: string, TeamId: string, Ovr: number, Seed: number, Name: string }
local boards: { [Player]: { Offers: { Offer }, RolledAt: number } } = {}
local rng = Random.new()

local function guid(): string
	return HttpService:GenerateGUID(false)
end

local function seed(): number
	return rng:NextInteger(1, 2 ^ 30)
end

local function teamColor(data: any): string
	return Team.Colors[data.Team.Colors.Primary or Team.DefaultPrimary] or Team.Colors[1]
end

local function owned(card: any): boolean
	return card.Source ~= "Pug" and card.Source ~= "StandIn" and card.Source ~= "AI"
end

local function avgOvr(cards: { any }): number
	local sum = 0
	for _, c in cards do
		sum += Ratings.Ovr(c)
	end
	return if #cards > 0 then sum / #cards else 30
end

-- Sim entries for team A: your cards (gear/parts/condition, mode-aware) + pugs/stand-ins plain.
function MatchService:Entries(player: Player, data: any, cards: { any }, mode: string): { any }
	local now = os.time()
	local out = {}
	for _, card in cards do
		if owned(card) then
			table.insert(out, Teams.Entry(card, mode, now, function(c)
				return GearService:GetGearStats(c, data.Stage, mode)
			end, function(id)
				return StationService:PartMult(data, id, mode)
			end))
		else
			table.insert(out, Teams.Plain(card))
		end
	end
	return out
end

local function plainEntries(cards: { any }): { any }
	local out = {}
	for _, c in cards do
		table.insert(out, Teams.Plain(c))
	end
	return out
end

-- Setup for one map. aiMastery: AI teams know their favorite map best.
function MatchService:Setup(player: Player, data: any, entriesA: { any }, cardsA: { any }, cardsB: { any }, mapId: string, aiTeam: string?, s: number, kind: string, final: boolean?): Sim.Setup
	local fav = aiTeam and (AITeams :: any)[aiTeam] and (AITeams :: any)[aiTeam].Favorite
	return {
		A = { Players = entriesA, Chemistry = Teams.Chemistry(data, cardsA), Mastery = (data.MapMastery or {})[mapId] or 0, Fit = MapService:Fit(cardsA, mapId) },
		B = { Players = plainEntries(cardsB), Chemistry = 30, Mastery = if fav == mapId then 60 else 25, Fit = MapService:Fit(cardsB, mapId) },
		Seed = s,
		Weights = MapService:Weights(mapId),
		Kind = kind,
		Final = final,
		Hour = tonumber(os.date("!%H")) or 12,
	}
end

local function views(cards: { any }, tag: string, player: Player): { any }
	local out = {}
	for _, c in cards do
		table.insert(out, Teams.View(c, tag, player.DisplayName))
	end
	return out
end

-- The plan the client plays: teams, map, veto, the rounds so far and where the Clutch Moment is.
function MatchService:Plan(player: Player, data: any, a: any, state: Sim.State, cardsB: { any }, b: { Name: string, Tag: string, Color: string, Talk: string? }, extra: any?): any
	local mapDef = (Maps :: any)[a.MapId]
	local plan = {
		MatchId = a.Id,
		Kind = a.Kind,
		Title = Match.TitleName,
		MapId = a.MapId,
		Map = if mapDef then mapDef.Name else a.MapId,
		Pure = a.Mode == "Pure",
		Intensity = 1,
		Teams = {
			A = { Name = data.Team.Name, Tag = data.Team.Tag, Color = teamColor(data), Players = views(a.Cards, data.Team.Tag, player), Power = math.floor(state.PowerA) },
			B = { Name = b.Name, Tag = b.Tag, Color = b.Color, Talk = b.Talk, Players = views(cardsB, b.Tag, player), Power = math.floor(state.PowerB) },
		},
		Rounds = Sim.RoundsSince(state, 0),
		ClutchRound = state.ClutchAt,
		RoundSeconds = Match.RoundSeconds,
	}
	for k, v in extra or {} do
		(plan :: any)[k] = v
	end
	return plan
end

-- After-match effects on your players: fatigue, morale, chemistry, mastery, matches played, personal bests.
function MatchService:AfterMatch(player: Player, kind: string, cards: { any }, won: boolean, mapId: string?, kills: { number }?)
	local data = DataService:GetProfile(player)
	if not data then
		return
	end
	local now = os.time()
	local mine = {}
	local hype, calm = 0, 1
	for _, c in cards do
		if owned(c) and data.Roster[c.Id] then
			table.insert(mine, c)
			local e = c.Trait and (Traits :: any)[c.Trait] and (Traits :: any)[c.Trait].Effect
			if e and e.WinMorale then
				hype += e.WinMorale
			end
			if e and e.MoraleLossMult then
				calm = math.min(calm, e.MoraleLossMult)
			end
		end
	end
	local fatigueAdd = Match.Fatigue.Add[kind] or 0
	for i, c in cards do
		if owned(c) and data.Roster[c.Id] then
			DataService:Update(player, "Roster." .. c.Id, function(card)
				local morale, fatigue = Ratings.Condition(card, now)
				local e = card.Trait and (Traits :: any)[card.Trait] and (Traits :: any)[card.Trait].Effect
				local change = if won then Match.Morale.Win + hype elseif e and e.NoMoraleLoss then 0 else Match.Morale.Loss * calm
				card.Morale = math.clamp(math.round(morale + change), 0, 100)
				card.MoraleAt = now
				card.Fatigue = math.clamp(math.round(fatigue + fatigueAdd), 0, 100)
				card.FatigueAt = now
				card.MatchesPlayed = (card.MatchesPlayed or 0) + 1
				local k = kills and kills[i]
				if k and k > (card.BestKills or 0) then
					card.BestKills = k
				end
				return card
			end)
		end
	end
	if #mine >= 2 then
		DataService:Update(player, "Chemistry", function(chem)
			chem = chem or {}
			for i = 1, #mine do
				for j = i + 1, #mine do
					local key = Teams.PairKey(mine[i].Id, mine[j].Id)
					chem[key] = math.min((chem[key] or 0) + 1, Match.Chemistry.Cap)
				end
			end
			return chem
		end)
	end
	if mapId and kind ~= "Pickup" then
		MapService:AddMastery(player, mapId, if kind == "Scrim" then Match.Mastery.Scrim else Match.Mastery.Match)
	end
end

-- Pickup Games -------------------------------------------------------------------------------------------------

local function pickupTeams(data: any): ({ any }, { any }, number, string)
	local teamA = table.clone(RosterService:ActiveFive(data))
	local ownedCount = #teamA
	for _, pug in Teams.Pugs(5 - #teamA, rng, PICKUP.PugRarity, "Pug") do
		table.insert(teamA, pug)
	end
	local band = PICKUP.OpponentOvrByStage[math.clamp(data.Stage, 1, #PICKUP.OpponentOvrByStage)]
	local teamB = Teams.Pugs(5, rng, "Common", "AI", band)
	local opponentName = Generator.TeamName(rng)
	return teamA, teamB, ownedCount, opponentName
end

local function randomMap(stage: number): string
	local pool = MapService:Pool(stage)
	return pool[rng:NextInteger(1, #pool)]
end

local function finishRewards(player: Player, data: any, a: Active, summary: any): any
	local s = a.State
	local win = summary.Winner == "A"
	local rewards = { Cash = 0, Fame = 0, Crate = false }
	if a.Kind == "Pickup" then
		local ratio = math.clamp(s.PowerB / math.max(s.PowerA, 1), PICKUP.FameRatioClamp[1], PICKUP.FameRatioClamp[2])
		local firstWin = win and data.Ftue.PickupWins == 0
		if win then
			rewards.Cash = if firstWin then PICKUP.WinCash.Base else math.clamp(math.round(PICKUP.WinCash.Base * ratio), PICKUP.WinCash.Min, PICKUP.WinCash.Max)
			rewards.Fame = math.round(PICKUP.WinFame * (if firstWin then 1 else ratio))
		else
			rewards.Cash = PICKUP.LossCash
			rewards.Fame = PICKUP.LossFame
		end
		EconomyService:Transact(player, { Cash = rewards.Cash, Fame = rewards.Fame }, if win then "PickupWin" else "PickupLoss")
		DataService:Update(player, "Ftue.PickupGames", function(n)
			return (n or 0) + 1
		end)
		if win then
			DataService:Update(player, "Ftue.PickupWins", function(n)
				return (n or 0) + 1
			end)
		end
		local teamGame = a.Owned >= 2
		if teamGame and data.Ftue.CratesEarned == 0 then
			if win then
				rewards.Crate = CaseService:GrantCrate(player)
			else
				DataService:Update(player, "Ftue.TeamPugLosses", function(n)
					return (n or 0) + 1
				end)
			end
		end
		if not win then
			Bus.Fire(player, "Line", "TUT_LOSS")
		end
	elseif a.Kind == "Scrim" then
		local ratio = math.clamp(s.PowerB / math.max(s.PowerA, 1), SCRIM.FameRatioClamp[1], SCRIM.FameRatioClamp[2])
		if win then
			rewards.Cash = math.clamp(math.round(SCRIM.WinCash.Base * ratio), SCRIM.WinCash.Min, SCRIM.WinCash.Max)
			rewards.Fame = math.round(SCRIM.WinFame * ratio)
		else
			rewards.Cash = SCRIM.LossCash
			rewards.Fame = SCRIM.LossFame
		end
		EconomyService:Transact(player, { Cash = rewards.Cash, Fame = rewards.Fame }, if win then "ScrimWin" else "ScrimLoss")
		DataService:Update(player, "Competition", function(c)
			c.Scrims = (c.Scrims or 0) + 1
			c.ScrimWins = (c.ScrimWins or 0) + (if win then 1 else 0)
			return c
		end)
	end
	return rewards
end

-- Grants rewards once and builds the result the client shows.
local function resolve(player: Player, a: Active, quality: number, skipped: boolean): any
	if a.Resolved then
		return a.Resolved
	end
	local s = a.State
	if not a.Pity then
		Sim.Finish(s, quality)
	end
	local summary = Sim.Summary(s)
	local data = DataService:GetProfile(player)
	local rewards = { Cash = 0, Fame = 0, Crate = false }
	if data then
		rewards = finishRewards(player, data, a, summary)
		MatchService:AfterMatch(player, a.Kind, a.Cards, summary.Winner == "A", a.MapId, summary.Kills.A)
	end
	local win = summary.Winner == "A"
	a.Resolved = {
		Rounds = Sim.RoundsSince(s, a.Sent),
		Result = {
			Winner = summary.Winner,
			Score = summary.Score,
			Ratings = summary.Ratings,
			Mvp = summary.Mvp,
			Moments = summary.Moments,
			Upset = summary.Upset,
			Comeback = summary.Comeback,
			Records = summary.Records,
			Rewards = rewards,
			Clutch = if s.ClutchAt and a.Kind ~= "Tournament" then { Round = s.ClutchAt, Won = s.Rounds[s.ClutchAt] ~= nil and s.Rounds[s.ClutchAt].W == "A", Quality = quality } else nil,
		},
	}
	a.Sent = #s.Rounds
	AnalyticsService:Custom(player, "MatchFinished", if win then 1 else 0, {
		type = if a.Kind == "Pickup" and a.Owned >= 2 then "TeamPickup" else a.Kind,
		powerDiff = math.floor(s.PowerA - s.PowerB),
		skipped = skipped,
	})
	Log.Info("Match", `{player.Name} {a.Kind} {s.A}-{s.B} {if win then "WIN" else "loss"} on {a.MapId} (power {math.floor(s.PowerA)} vs {math.floor(s.PowerB)}{if a.Pity then ", pity" else ""}{if a.Mode == "Pure" then ", pure" else ""})`)
	Bus.Fire(player, if a.Kind == "Pickup" then "PickupFinished" else "ScrimFinished", { Win = win, Owned = a.Owned })
	DataService:SaveNow(player, a.Kind .. "Finished")
	task.delay(5, function()
		if active[player] == a then
			active[player] = nil
		end
	end)
	return a.Resolved
end

local function startPickup(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data or not RosterService:GetFounder(player) then
		return false, "NoFounder"
	end
	local current = active[player]
	if current and not current.Resolved then
		return false, "InMatch"
	end
	local wait = (lastStart[player] or -math.huge) + PICKUP.Cooldown - os.clock()
	if wait > 0 then
		return false, { Cooldown = math.ceil(wait) }
	end
	if not PlotService:IsNear(player, "FounderDesk", PICKUP.MaxDistance) then
		return false, "TooFar"
	end
	lastStart[player] = os.clock()

	local teamA, teamB, ownedCount, opponentName = pickupTeams(data)
	local pity = (PICKUP.PityFirstGame and data.Ftue.PickupGames == 0)
		or (ownedCount >= 2 and data.Ftue.CratesEarned == 0 and data.Ftue.TeamPugLosses >= PICKUP.CratePityAfterLosses)
	local mapId = randomMap(data.Stage)
	local entriesA = MatchService:Entries(player, data, teamA, "Full")

	local state: Sim.State
	if pity then
		-- Re-simulate until A wins, then hand out the rounds in two parts like a normal match.
		for attempt = 1, 60 do
			local setup = MatchService:Setup(player, data, entriesA, teamA, teamB, mapId, nil, seed(), "Pickup")
			if attempt > 30 then
				setup.A.Chemistry = 1e6 -- extremely unlikely; capped chemistry boost guarantees termination
				setup.A.Fit = 1.5
			end
			state = Sim.New(setup)
			Sim.Finish(state, 0)
			if state.Winner == "A" then
				break
			end
		end
	else
		state = Sim.New(MatchService:Setup(player, data, entriesA, teamA, teamB, mapId, nil, seed(), "Pickup"))
		Sim.RunToClutch(state)
	end

	local a: Active = { Id = guid(), Kind = "Pickup", State = state, Sent = 0, Cards = teamA, Owned = ownedCount, Pity = pity, MapId = mapId, Mode = "Full", Opponent = opponentName, Resolved = nil, StartedAt = os.clock() }
	local clutchAt = state.ClutchAt
	a.Sent = math.min(if clutchAt then clutchAt - 1 else #state.Rounds, #state.Rounds)
	active[player] = a
	task.delay(Match.ResolveTimeout, function()
		if active[player] == a and not a.Resolved then
			resolve(player, a, 0, true)
		end
	end)
	Bus.Fire(player, "PickupStarted")
	local plan = MatchService:Plan(player, data, a, state, teamB, { Name = opponentName, Tag = "", Color = "F87171" })
	plan.Rounds = {}
	for i = 1, a.Sent do
		table.insert(plan.Rounds, state.Rounds[i])
	end
	return true, plan
end

-- Scrims ---------------------------------------------------------------------------------------------------------

local function scrimLineup(data: any): { any }
	local cards = table.clone(RosterService:ActiveFive(data))
	for _, standIn in Teams.Pugs(5 - #cards, Random.new(#cards + 1), "Common", "StandIn", { 32, 38 }) do
		table.insert(cards, standIn)
	end
	return cards
end

-- The AI OVR whose Team Power is closest to `target` on `mapId` (bisection; each AI team has its own bias/leans).
local function ovrForPower(player: Player, data: any, entriesA: { any }, cardsA: { any }, teamId: string, teamSeed: number, mapId: string, target: number): number
	local lo, hi = 20, 95
	for _ = 1, 9 do
		local mid = (lo + hi) / 2
		local s = Sim.New(MatchService:Setup(player, data, entriesA, cardsA, Teams.AI(teamId, teamSeed, mid), mapId, teamId, 1, "Scrim"))
		if s.PowerB < target then
			lo = mid
		else
			hi = mid
		end
	end
	return math.round((lo + hi) / 2)
end

local function getBoard(player: Player, data: any, refresh: boolean?): { Offers: { Offer }, RolledAt: number }
	local board = boards[player]
	local now = os.time()
	if refresh or not board or now - board.RolledAt >= SCRIM.BoardRefresh then
		-- Calibrated on Team Power (not OVR), so "Even match" really is even when the board rolls.
		local cardsA = scrimLineup(data)
		local entriesA = MatchService:Entries(player, data, cardsA, "Full")
		local mapId = MapService:Pool(data.Stage)[1]
		local mine = Sim.New(MatchService:Setup(player, data, entriesA, cardsA, cardsA, mapId, nil, 1, "Scrim")).PowerA
		local teams = table.clone(AITeams.Order)
		board = { Offers = {}, RolledAt = now }
		for _, o in SCRIM.Offers do
			local teamId = table.remove(teams, rng:NextInteger(1, #teams)) :: string
			local teamSeed = seed()
			local ovr = ovrForPower(player, data, entriesA, cardsA, teamId, teamSeed, mapId, mine * o.Power)
			table.insert(board.Offers, { Id = o.Id, TeamId = teamId, Ovr = ovr, Seed = teamSeed, Name = o.Name })
		end
		boards[player] = board
	end
	return board
end

-- Power on every map in the pool (yours Full and Pure, theirs), for the veto screen.
local function mapPowers(player: Player, data: any, cardsA: { any }, cardsB: { any }, teamId: string): { any }
	local out = {}
	local full = MatchService:Entries(player, data, cardsA, "Full")
	local pure = MatchService:Entries(player, data, cardsA, "Pure")
	for _, mapId in MapService:Pool(data.Stage) do
		local sFull = Sim.New(MatchService:Setup(player, data, full, cardsA, cardsB, mapId, teamId, 1, "Scrim"))
		local sPure = Sim.New(MatchService:Setup(player, data, pure, cardsA, cardsB, mapId, teamId, 1, "Scrim"))
		table.insert(out, { Id = mapId, Name = (Maps :: any)[mapId].Name, You = math.floor(sFull.PowerA), YouPure = math.floor(sPure.PowerA), Them = math.floor(sFull.PowerB), Mastery = (data.MapMastery or {})[mapId] or 0 })
	end
	return out
end

local function scrimBoard(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data then
		return false, "NotLoaded"
	end
	if data.Stage < Competition.Stage then
		return false, { NeedStage = Competition.Stage }
	end
	local board = getBoard(player, data)
	local cardsA = scrimLineup(data)
	local offers = {}
	for _, o in board.Offers do
		local def = (AITeams :: any)[o.TeamId]
		local cardsB = Teams.AI(o.TeamId, o.Seed, o.Ovr)
		table.insert(offers, {
			Id = o.Id,
			Label = o.Name,
			Team = { Id = o.TeamId, Name = def.Name, Tag = def.Tag, Color = def.Color, Style = def.Style, Talk = def.Talk[1 + o.Seed % #def.Talk], Favorite = def.Favorite },
			Ovr = math.round(avgOvr(cardsB)),
			Maps = mapPowers(player, data, cardsA, cardsB, o.TeamId),
		})
	end
	local wait = (lastScrim[player] or -math.huge) + SCRIM.Cooldown - os.clock()
	return true, {
		Offers = offers,
		Cooldown = math.max(0, math.ceil(wait)),
		Veto = data.Stage >= Maps.VetoStage,
		RefreshAt = board.RolledAt + SCRIM.BoardRefresh,
		StandIns = 5 - #RosterService:ActiveFive(data),
	}
end

local function startScrim(player: Player, offerId: string, pure: boolean, bans: { string }): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data or not RosterService:GetFounder(player) then
		return false, "NoFounder"
	end
	if data.Stage < Competition.Stage then
		return false, { NeedStage = Competition.Stage }
	end
	local current = active[player]
	if current and not current.Resolved then
		return false, "InMatch"
	end
	local wait = (lastScrim[player] or -math.huge) + SCRIM.Cooldown - os.clock()
	if wait > 0 then
		return false, { Cooldown = math.ceil(wait) }
	end
	local board = getBoard(player, data)
	local offer = nil
	for _, o in board.Offers do
		if o.Id == offerId then
			offer = o
		end
	end
	if not offer then
		return false, "NoOffer"
	end
	lastScrim[player] = os.clock()
	local mode = if pure then "Pure" else "Full"
	local def = (AITeams :: any)[offer.TeamId]
	local cardsA = scrimLineup(data)
	local cardsB = Teams.AI(offer.TeamId, offer.Seed, offer.Ovr)
	local entriesA = MatchService:Entries(player, data, cardsA, mode)
	local pool = MapService:Pool(data.Stage)
	local veto = nil
	local mapId: string
	if data.Stage >= Maps.VetoStage and #pool >= 3 then
		local cache = {}
		veto = MapService:Veto(pool, bans, function(id)
			if not cache[id] then
				local s = Sim.New(MatchService:Setup(player, data, entriesA, cardsA, cardsB, id, offer.TeamId, 1, "Scrim"))
				cache[id] = s.PowerA / math.max(s.PowerB, 1)
			end
			return cache[id]
		end, def.Favorite)
		mapId = veto.Map
	else
		mapId = pool[rng:NextInteger(1, #pool)]
	end
	local state = Sim.New(MatchService:Setup(player, data, entriesA, cardsA, cardsB, mapId, offer.TeamId, seed(), "Scrim"))
	Sim.RunToClutch(state)
	local ownedCount = #RosterService:ActiveFive(data)
	local a: Active = { Id = guid(), Kind = "Scrim", State = state, Sent = 0, Cards = cardsA, Owned = ownedCount, Pity = false, MapId = mapId, Mode = mode, Opponent = def.Name, Resolved = nil, StartedAt = os.clock() }
	a.Sent = #state.Rounds
	active[player] = a
	getBoard(player, data, true) -- fresh offers next time
	task.delay(Match.ResolveTimeout, function()
		if active[player] == a and not a.Resolved then
			resolve(player, a, 0, true)
		end
	end)
	Bus.Fire(player, "ScrimStarted")
	return true, MatchService:Plan(player, data, a, state, cardsB, { Name = def.Name, Tag = def.Tag, Color = def.Color, Talk = def.Talk[1 + offer.Seed % #def.Talk] }, { Veto = veto })
end

local function resolveRemote(player: Player, matchId: string, quality: number): (boolean, any)
	local a = active[player]
	if not a or a.Id ~= matchId then
		return false, "NoMatch"
	end
	return true, resolve(player, a, quality, quality == 0)
end

function MatchService:InMatch(player: Player): boolean
	local a = active[player]
	return a ~= nil and a.Resolved == nil
end

function MatchService:Init()
	GearService.InMatch = function(player)
		return MatchService:InMatch(player)
	end
	Remote.Function("Match", "StartPickup", { Rate = { Count = 1, Per = 3 } }, startPickup) -- Match/Start 1 per 3 s
	Remote.Function("Match", "ScrimBoard", { Mutates = false, Rate = { Count = 2, Per = 1 } }, scrimBoard)
	Remote.Function("Match", "StartScrim", { Args = { Remote.T.String(16), Remote.T.Boolean(), Remote.T.StringList(32, 8) }, Rate = { Count = 1, Per = 3 } }, startScrim)
	Remote.Function("Match", "Resolve", { Args = { Remote.T.String(64), Remote.T.Number(0, 1) }, Rate = { Count = 2, Per = 1 } }, resolveRemote)
	DataService.ProfileReleasing:Connect(function(player)
		local a = active[player]
		if a and not a.Resolved then
			resolve(player, a, 0, true) -- leaving mid-match still pays out
		end
	end)
	Tournament.Init(MatchService)
end

function MatchService:Start()
	Players.PlayerRemoving:Connect(function(player)
		task.defer(function()
			active[player] = nil
			lastStart[player] = nil
			lastScrim[player] = nil
			boards[player] = nil
		end)
	end)
	Tournament.Start()
end

-- Studio/QA: next Pickup Game / scrim ignores the cooldown.
function MatchService:ResetCooldown(player: Player)
	lastStart[player] = nil
	lastScrim[player] = nil
end

return MatchService

--!strict
-- Match engine ([[Match Simulation]]), server only. Deterministic: the same setup + seed gives the same match, so a
-- tournament round can resolve later (even while you're offline) with the same result.
--   PlayerPower = Σ((stat + gear) × mapWeight × (1 + trait stat mults)) × (1 + partMult) × moraleMult × fatigueMult
--                 × (1 + trait "all stats" mults that hold this round)
--   TeamPower   = Σ PlayerPower × chemistry × synergy × MapFit × MapMastery   (coach / tactic / home = 1 until staff)
--   pRound      = 1 / (1 + 10^((B − A) / 400 × K)), clamp 0.08–0.92, + momentum (3+ round streak: +3%/round, max +9%)
-- Every round: winner from pRound, then a kill sequence (the winners lose Binomial(4, q) players), the round MVP,
-- events (Ace / Clutch / Flawless) and Clip Moments; Comeback / Upset / Record are match-level.
-- Tuning check (command bar): print(require(game.ServerScriptService.Services.MatchService.Sim).Batch(170, 204, 10000))

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roles = require(ReplicatedStorage.Shared.Config.Roles)
local Traits = require(ReplicatedStorage.Shared.Config.Traits)
local Match = require(ReplicatedStorage.Shared.Config.Match)

local Sim = {}

export type Entry = {
	Card: any,
	Gear: { [string]: number }?, -- already stage-capped; {} in Pure mode
	PartMult: number?, -- 0 in Pure mode
	Morale: number?,
	Fatigue: number?,
	Best: number?, -- personal best kills (owned players), for the Record moment
}
export type Side = { Players: { Entry }, Chemistry: number?, Mastery: number?, Fit: number? }
export type Setup = {
	A: Side,
	B: Side,
	Seed: number,
	Weights: { [string]: number }, -- map-adjusted title weights
	Kind: string?, -- "Pickup" | "Scrim" | "Tournament"
	Final: boolean?,
	Hour: number?, -- server hour 0–23 (Night Owl / Early Bird)
}
export type Round = { W: string, MVP: number, Kills: { A: { number }, B: { number } }, Seq: { { number } }, Event: string?, Clutch: number? }
export type Moment = { Round: number, Type: string, Side: string, Index: number, Quality: number, Seed: number, Kills: number? }

type Player = {
	Base: { [string]: number }, -- stat + gear
	StatMult: { [string]: number }, -- trait stat mults (always on)
	Effect: any?,
	Flat: number, -- (1 + partMult) × moraleMult × fatigueMult
	KillWeight: number,
	Role: string,
}

export type State = {
	A: number,
	B: number,
	StreakA: number,
	StreakB: number,
	Target: number,
	PowerA: number, -- at kick-off, before round conditions
	PowerB: number,
	Pull: number, -- upset floor: power gap × Pull (1 = off)
	Setup: Setup,
	P: { A: { Player }, B: { Player } },
	Mult: { A: number, B: number },
	Rng: Random,
	Rounds: { Round },
	ClutchAt: number?, -- round index of the Clutch Moment (first match-point round)
	Done: boolean,
	Winner: string?,
	Stats: { A: { any }, B: { any } },
	MinDiff: number,
	MaxDiff: number,
	Moments: { Moment },
}

local function traitOf(card: any): any?
	local t = card.Trait and (Traits :: any)[card.Trait]
	return if type(t) == "table" then t.Effect else nil
end

local function prepare(entry: Entry, weights: { [string]: number }, teamMorale: number): Player
	local card = entry.Card
	local gear = entry.Gear or {}
	local base, mult = {}, {}
	local effect = traitOf(card)
	for _, stat in Roles.Stats do
		base[stat] = ((card.Stats[stat] or 0) + (gear[stat] or 0)) * (weights[stat] or 0)
		mult[stat] = math.clamp(if effect and effect.Stats then effect.Stats[stat] or 0 else 0, -Traits.StatCap, Traits.StatCap)
	end
	local morale = math.clamp((entry.Morale or card.Morale or Match.MoraleDefault) + teamMorale, 0, 100)
	local fatigueMult = if (entry.Fatigue or 0) > Match.Fatigue.Threshold then Match.Fatigue.Mult else 1
	return {
		Base = base,
		StatMult = mult,
		Effect = effect,
		Flat = (1 + (entry.PartMult or 0)) * (0.85 + morale / 100 * 0.3) * fatigueMult,
		KillWeight = (card.Stats.Aim or 30) + (card.Stats.Reflexes or 30) + (gear.Aim or 0) + (gear.Reflexes or 0),
		Role = card.Role,
	}
end

-- Round conditions for one side.
local function conditions(s: State, side: string): { [string]: boolean }
	local mine = if side == "A" then s.A else s.B
	local theirs = if side == "A" then s.B else s.A
	local played = s.A + s.B
	local setup = s.Setup
	local hour = setup.Hour or 12
	return {
		MatchPoint = s.A == s.Target - 1 or s.B == s.Target - 1,
		Trailing4 = theirs - mine >= 4,
		Ahead = mine > theirs,
		Behind = mine < theirs,
		First5 = played < 5,
		After5 = played >= 5,
		LostStreak3 = (if side == "A" then s.StreakB else s.StreakA) >= 3,
		Night = hour >= 18,
		Morning = hour >= 6 and hour < 12,
		Final = setup.Final == true,
		Scrim = setup.Kind == "Scrim",
	}
end

local function playerPower(p: Player, cond: { [string]: boolean }): number
	local e = p.Effect
	local all = 0
	if e then
		if e.All and e.When and cond[e.When] then
			all += e.All
		end
		if e.Early and cond.First5 then
			all += e.Early
		end
		if e.Behind and cond.Behind then
			all += e.Behind
		end
		if e.InFinal and cond.Final then
			all += e.InFinal
		end
		all = math.clamp(all, -Traits.StatCap, Traits.StatCap)
	end
	local power = 0
	for _, stat in Roles.Stats do
		local m = p.StatMult[stat]
		if stat == "Clutch" and e and e.ClutchFinal and cond.MatchPoint then
			m = math.min(m + e.ClutchFinal, Traits.StatCap)
		end
		power += p.Base[stat] * (1 + m)
	end
	return power * p.Flat * (1 + all)
end

local function sidePower(s: State, side: string, cond: { [string]: boolean }): number
	local total = 0
	for _, p in (s.P :: any)[side] do
		total += playerPower(p, cond)
	end
	return total * (s.Mult :: any)[side]
end

-- chemistry × synergy × MapFit × MapMastery, plus team-wide trait bonuses.
local function sideMult(side: Side): number
	local roles, chemBonus = {}, 0
	for _, entry in side.Players do
		roles[entry.Card.Role] = true
		local e = traitOf(entry.Card)
		if e and e.Team and e.Team.Chemistry then
			chemBonus += e.Team.Chemistry
		end
	end
	local covered = 0
	for _, role in Roles.Order do
		if roles[role] then
			covered += 1
		end
	end
	local chemistry = 1 + math.min(side.Chemistry or 0, Match.Chemistry.Cap) * Match.Chemistry.PerMatch + chemBonus
	local synergy = if covered == #Roles.Order then Match.Synergy else 1
	local mastery = 1 + math.clamp(side.Mastery or 0, 0, Match.Mastery.Max) / 100 * Match.MasteryBonus
	return chemistry * synergy * (side.Fit or 1) * mastery
end

local function teamMorale(side: Side): number
	local bonus = 0
	for _, entry in side.Players do
		local e = traitOf(entry.Card)
		if e and e.Team and e.Team.Morale then
			bonus += e.Team.Morale
		end
	end
	return bonus
end

function Sim.PRound(powerA: number, powerB: number, pull: number?): number
	local p = 1 / (1 + 10 ^ ((powerB - powerA) * (pull or 1) / 400 * Match.K))
	return math.clamp(p, Match.PRoundClamp[1], Match.PRoundClamp[2])
end

local function momentum(streak: number): number
	if streak < Match.Momentum.Streak then
		return 0
	end
	return math.min((streak - Match.Momentum.Streak + 1) * Match.Momentum.Bonus, Match.Momentum.Max)
end

local NEUTRAL = {}

function Sim.New(setup: Setup): State
	local s: State = {
		A = 0,
		B = 0,
		StreakA = 0,
		StreakB = 0,
		Target = Match.FirstTo,
		PowerA = 0,
		PowerB = 0,
		Pull = 1,
		Setup = setup,
		P = { A = {}, B = {} },
		Mult = { A = sideMult(setup.A), B = sideMult(setup.B) },
		Rng = Random.new(setup.Seed),
		Rounds = {},
		ClutchAt = nil,
		Done = false,
		Winner = nil,
		Stats = { A = {}, B = {} },
		MinDiff = 0,
		MaxDiff = 0,
		Moments = {},
	}
	for _, side in { "A", "B" } do
		local def = (setup :: any)[side]
		local tm = teamMorale(def)
		for i, entry in def.Players do
			(s.P :: any)[side][i] = prepare(entry, setup.Weights, tm);
			(s.Stats :: any)[side][i] = { K = 0, D = 0, Open = 0, Clutch = 0, Multi = 0 }
		end
	end
	s.PowerA = sidePower(s, "A", NEUTRAL)
	s.PowerB = sidePower(s, "B", NEUTRAL)
	local floor = Match.UpsetFloor
	if floor.Chance > 0 and s.Rng:NextNumber() < floor.Chance then
		s.Pull = floor.Pull
	end
	return s
end

local function weightedPick(rng: Random, list: { number }, weight: (number) -> number): number
	local sum = 0
	for _, i in list do
		sum += weight(i)
	end
	local r = rng:NextNumber() * sum
	for _, i in list do
		r -= weight(i)
		if r <= 0 then
			return i
		end
	end
	return list[#list]
end

-- Plays one round. bonusA is added to team A's pRound (Clutch Moment).
function Sim.Step(s: State, bonusA: number?)
	if s.Done then
		return
	end
	local powerA = sidePower(s, "A", conditions(s, "A"))
	local powerB = sidePower(s, "B", conditions(s, "B"))
	local p = Sim.PRound(powerA, powerB, s.Pull) + momentum(s.StreakA) - momentum(s.StreakB)
	p = math.clamp(p, Match.PRoundClamp[1], Match.PRoundClamp[2]) + (bonusA or 0)
	local rng = s.Rng
	local aWins = rng:NextNumber() < p
	local W, L = if aWins then "A" else "B", if aWins then "B" else "A"
	local players = s.P :: any
	local stats = s.Stats :: any

	-- Winners lose Binomial(4, q) players; closer rounds cost more.
	local D = Match.Deaths
	local pLoser = math.clamp(if aWins then 1 - p else p, 0, 1)
	local q = math.clamp(D.Base + D.Spread * pLoser, D.Min, D.Max)
	local deaths = 0
	for _ = 1, 4 do
		if rng:NextNumber() < q then
			deaths += 1
		end
	end
	-- Kill order: 4 winner kills + the loser kills shuffled, then the round-ending winner kill.
	local events = {}
	for _ = 1, 4 do
		table.insert(events, W)
	end
	for _ = 1, deaths do
		table.insert(events, L)
	end
	for i = #events, 2, -1 do
		local j = rng:NextInteger(1, i)
		events[i], events[j] = events[j], events[i]
	end
	table.insert(events, W)

	local alive = { A = {}, B = {} } :: any
	local kills = { A = {}, B = {} } :: any
	for _, side in { "A", "B" } do
		for i in players[side] do
			table.insert(alive[side], i)
			kills[side][i] = 0
		end
	end
	local seq = {}
	local clutchBy, clutchVs = nil, 0
	for n, killerSide in events do
		local victimSide = if killerSide == "A" then "B" else "A"
		if #alive[killerSide] == 0 or #alive[victimSide] == 0 then
			break
		end
		local roster = players[killerSide]
		local killer = weightedPick(rng, alive[killerSide], function(i)
			local w = roster[i].KillWeight
			return if n == 1 and roster[i].Role == "Entry" then w * Match.EntryFirstDuel else w
		end)
		local vi = rng:NextInteger(1, #alive[victimSide])
		local victim = table.remove(alive[victimSide], vi) :: number
		kills[killerSide][killer] += 1
		stats[killerSide][killer].K += 1
		stats[victimSide][victim].D += 1
		if n == 1 then
			stats[killerSide][killer].Open += 1
		end
		table.insert(seq, { if killerSide == "A" then 1 else 2, killer, victim })
		if killerSide == L and #alive[W] == 1 and not clutchBy then
			clutchBy, clutchVs = alive[W][1], #alive[L] -- last one standing vs everyone left
		end
	end

	local mvp, best = 1, -1
	for i, k in kills[W] do
		if k > best or (k == best and i == clutchBy) then
			mvp, best = i, k
		end
	end
	for side, list in kills do
		for i, k in list do
			if k >= 3 then
				stats[side][i].Multi += 1
			end
		end
	end
	local event: string? = nil
	local roundNo = #s.Rounds + 1
	local C = Match.Clips
	if best >= 5 then
		event = "Ace"
		table.insert(s.Moments, { Round = roundNo, Type = "Ace", Side = W, Index = mvp, Quality = C.Ace, Seed = rng:NextInteger(1, 2 ^ 30) })
	elseif clutchBy and clutchVs >= 2 then
		event = "Clutch"
		stats[W][clutchBy].Clutch += 1
		table.insert(s.Moments, { Round = roundNo, Type = "Clutch", Side = W, Index = clutchBy, Quality = C.Clutch + C.ClutchPerExtra * (clutchVs - 2), Seed = rng:NextInteger(1, 2 ^ 30), Kills = clutchVs })
	elseif deaths == 0 then
		event = "Flawless"
		table.insert(s.Moments, { Round = roundNo, Type = "Flawless", Side = W, Index = mvp, Quality = C.Flawless, Seed = rng:NextInteger(1, 2 ^ 30) })
	end

	if aWins then
		s.A += 1
		s.StreakA += 1
		s.StreakB = 0
	else
		s.B += 1
		s.StreakB += 1
		s.StreakA = 0
	end
	s.MinDiff = math.min(s.MinDiff, s.A - s.B)
	s.MaxDiff = math.max(s.MaxDiff, s.A - s.B)
	table.insert(s.Rounds, {
		W = W,
		MVP = mvp,
		Kills = { A = kills.A, B = kills.B },
		Seq = seq,
		Event = event,
		Clutch = if event == "Clutch" then clutchVs else nil,
	})

	-- Overtime: at (target-1)-(target-1) the target moves up by a first-to-4 block.
	if s.A == s.Target - 1 and s.B == s.Target - 1 then
		s.Target += Match.Overtime.FirstTo - 1
	end
	if s.A >= s.Target or s.B >= s.Target then
		s.Done = true
		s.Winner = if s.A > s.B then "A" else "B"
	elseif not s.ClutchAt and (s.A == s.Target - 1 or s.B == s.Target - 1) then
		s.ClutchAt = #s.Rounds + 1 -- the next round is the "final round" Clutch Moment
	end
end

-- Runs rounds until the Clutch Moment round is next (or the match ends).
function Sim.RunToClutch(s: State)
	while not s.Done and not (s.ClutchAt and #s.Rounds + 1 >= s.ClutchAt) do
		Sim.Step(s)
	end
end

-- Finishes the match. The clutch bonus applies to the clutch round only.
function Sim.Finish(s: State, clutchQuality: number)
	while not s.Done do
		local bonus = if s.ClutchAt and #s.Rounds + 1 == s.ClutchAt then Match.ClutchBonus * math.clamp(clutchQuality, 0, 1) else 0
		Sim.Step(s, bonus)
	end
end

-- HLTV-style Match Rating ([[Skill Levels & Ratings]]): 0.45 kills + 0.25 survival + 0.30 impact (opening kills,
-- clutches ×2, 3+ kill rounds), each vs the 10-player average. 1.00 = average.
function Sim.Ratings(s: State): { A: { number }, B: { number } }
	local rounds = math.max(#s.Rounds, 1)
	local sumK, sumS, sumI, n = 0, 0, 0, 0
	local function impact(st: any): number
		return st.Open + 2 * st.Clutch + st.Multi
	end
	for _, side in { "A", "B" } do
		for _, st in (s.Stats :: any)[side] do
			sumK += st.K
			sumS += (rounds - st.D) / rounds
			sumI += impact(st)
			n += 1
		end
	end
	local avgK, avgS, avgI = math.max(sumK / n, 0.01), math.max(sumS / n, 0.01), sumI / n
	local out = { A = {}, B = {} }
	for _, side in { "A", "B" } do
		for i, st in (s.Stats :: any)[side] do
			local imp = if avgI > 0 then impact(st) / avgI else 1
			local r = 0.45 * st.K / avgK + 0.25 * ((rounds - st.D) / rounds) / avgS + 0.30 * imp;
			(out :: any)[side][i] = math.floor(r * 100 + 0.5) / 100
		end
	end
	return out
end

-- Final summary: winner, score, ratings, MVP, clip moments (incl. Comeback / Upset / Record), per-player kills.
function Sim.Summary(s: State): any
	local ratings = Sim.Ratings(s)
	local mvpSide, mvpIdx, best = "A", 1, -1
	for _, side in { "A", "B" } do
		for i, r in (ratings :: any)[side] do
			if r > best then
				mvpSide, mvpIdx, best = side, i, r
			end
		end
	end
	local W = s.Winner or "A"
	local C = Match.Clips
	local moments = table.clone(s.Moments)
	local winnerBest = 1
	do
		local top = -1
		for i, r in (ratings :: any)[W] do
			if r > top then
				winnerBest, top = i, r
			end
		end
	end
	local comeback = (W == "A" and s.MinDiff <= -C.ComebackDeficit) or (W == "B" and s.MaxDiff >= C.ComebackDeficit)
	if comeback then
		table.insert(moments, { Round = #s.Rounds, Type = "Comeback", Side = W, Index = winnerBest, Quality = C.Comeback, Seed = s.Rng:NextInteger(1, 2 ^ 30) })
	end
	local wPower, lPower = if W == "A" then s.PowerA else s.PowerB, if W == "A" then s.PowerB else s.PowerA
	local upset = lPower >= wPower * C.UpsetRatio
	if upset then
		table.insert(moments, { Round = #s.Rounds, Type = "Upset", Side = W, Index = winnerBest, Quality = C.Upset, Seed = s.Rng:NextInteger(1, 2 ^ 30) })
	end
	local records = {}
	for i, entry in s.Setup.A.Players do
		local k = s.Stats.A[i].K
		if entry.Best and entry.Best > 0 and k > entry.Best then
			table.insert(moments, { Round = #s.Rounds, Type = "Record", Side = "A", Index = i, Quality = C.Record, Seed = s.Rng:NextInteger(1, 2 ^ 30), Kills = k })
			table.insert(records, { Index = i, Kills = k }) -- a list: sparse number keys don't survive remotes
		end
	end
	-- Keep the best few, shown in match order.
	table.sort(moments, function(a, b)
		if a.Quality ~= b.Quality then
			return a.Quality > b.Quality
		end
		return a.Round < b.Round
	end)
	while #moments > C.Max do
		table.remove(moments)
	end
	table.sort(moments, function(a, b)
		return a.Round < b.Round
	end)
	local kills = { A = {}, B = {} }
	for _, side in { "A", "B" } do
		for i, st in (s.Stats :: any)[side] do
			(kills :: any)[side][i] = st.K
		end
	end
	return {
		Winner = W,
		Score = { s.A, s.B },
		Ratings = ratings,
		Mvp = { Side = mvpSide, Index = mvpIdx },
		Moments = moments,
		Kills = kills,
		Upset = upset,
		Comeback = comeback,
		Records = records,
		Power = { math.floor(s.PowerA), math.floor(s.PowerB) },
	}
end

-- Rounds after index `from` (the part of a match not yet sent to the client).
function Sim.RoundsSince(s: State, from: number): { Round }
	local out = {}
	for i = from + 1, #s.Rounds do
		table.insert(out, s.Rounds[i])
	end
	return out
end

-- Five identical Flex players with the given team power (title weights sum to 1, morale 50 → mult 1).
function Sim.FakeSide(power: number): Side
	local per = power / 5
	local players = {}
	for i = 1, 5 do
		players[i] = { Card = { Role = "Flex", Stats = { Aim = per, Reflexes = per, GameSense = per, Teamwork = per, Clutch = per, Consistency = per }, Morale = 50 }, Morale = 50 }
	end
	return { Players = players }
end

-- Tuning check: win rate of a team with powerA vs powerB over n matches.
function Sim.Batch(powerA: number, powerB: number, n: number): string
	local wins, roundsA, roundsB = 0, 0, 0
	for i = 1, n do
		local s = Sim.New({ A = Sim.FakeSide(powerA), B = Sim.FakeSide(powerB), Seed = i, Weights = Match.TitleWeights })
		Sim.Finish(s, 0)
		if s.Winner == "A" then
			wins += 1
		end
		roundsA += s.A
		roundsB += s.B
	end
	return string.format("A %.0f vs B %.0f: A wins %.1f%%, avg score %.1f-%.1f", powerA, powerB, wins / n * 100, roundsA / n, roundsB / n)
end

return Sim

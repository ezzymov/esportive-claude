--!strict
-- MinigameService: the Stage 1 player-played earners ([[Founder (You)]], [[Playable Games]]).
-- The client plays; the server owns every number. Sanity caps per [[Security & Anti-Exploit]]: run tokens, min/max
-- run time, max score per second, cooldowns, diminishing returns, distance to the object on your own plot.
--   Station/BeginSetup (RF) → ok          Station/PowerOn (RF) → Founder card (mints "You · OVR 30")
--   Minigame/AimStart (RF) → run          Minigame/AimFinish (RF) runId, hits → { Cash, AimGained, Hits }
--   Minigame/TechStart (RF) → job         Minigame/TechFinish (RF) jobId → { Cash }
--   Minigame/ReactStart (RF) → run        Minigame/ReactFinish (RF) runId, hits → { Cash, ReflexesGained, Hits }
--     Reaction Test (Stage 2): timing bars, hits ≤ rounds, run ≥ rounds × 0.35 s, same cooldown/diminishing as Aim.

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
local TutorialService = require(script.Parent.TutorialService)
local Minigames = require(ReplicatedStorage.Shared.Config.Minigames)

local MinigameService = { Tier = 4 }

local AIM = Minigames.AimTrainer
local TECH = Minigames.TechFix
local REACT = Minigames.ReactionTest

type Session = {
	SetupAt: number?,
	Aim: { Id: string, At: number }?,
	LastAim: number,
	AimRuns: { number }, -- os.clock() of recent runs, for diminishing returns
	React: { Id: string, At: number }?,
	LastReact: number,
	ReactRuns: { number },
	Job: { Id: string, At: number, Neighbor: string }?,
	NextJobAt: number,
	BenchShown: boolean?,
	CabinetOn: boolean?,
}
local sessions: { [Player]: Session } = {}
local rng = Random.new()

local function session(player: Player): Session
	local s = sessions[player]
	if not s then
		s = { LastAim = -math.huge, AimRuns = {}, LastReact = -math.huge, ReactRuns = {}, NextJobAt = 0 }
		sessions[player] = s
	end
	return s
end

local function bump(player: Player, path: string)
	DataService:Update(player, path, function(v)
		return (v or 0) + 1
	end)
end

-- PC setup (cable minigame) ----------------------------------------------------------------------------------

local function beginSetup(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data then
		return false, "NotLoaded"
	end
	if not data.Flags.TeamCreated then
		return false, "NameTeamFirst"
	end
	if data.Flags.StationPowered then
		return false, "AlreadyPowered"
	end
	if not PlotService:IsNear(player, "FounderDesk") then
		return false, "TooFar"
	end
	session(player).SetupAt = os.clock()
	return true, Minigames.CableSetup.Cables
end

local function powerOn(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	local s = session(player)
	if not data or not s.SetupAt then
		return false, "NoSetup"
	end
	if data.Flags.StationPowered then
		return false, "AlreadyPowered"
	end
	if os.clock() - s.SetupAt < Minigames.CableSetup.MinSeconds then
		Log.Event("setup_too_fast", player, string.format("%.2fs", os.clock() - s.SetupAt))
		return false, "TooFast"
	end
	s.SetupAt = nil
	local founder = RosterService:CreateFounder(player)
	if not founder then
		return false, "Error"
	end
	DataService:Update(player, "Flags.StationPowered", function()
		return true
	end)
	PlotService:Refresh(player)
	Bus.Fire(player, "StationPowered")
	DataService:SaveNow(player, "PowerOn")
	return true, founder.Id
end

-- Aim Trainer --------------------------------------------------------------------------------------------------

local function aimStart(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data or not RosterService:GetFounder(player) then
		return false, "NoFounder"
	end
	if not TutorialService:Reached(player, "AimTrainer") then
		return false, "Locked"
	end
	if not PlotService:IsNear(player, "AimCabinet", AIM.MaxDistance) then
		return false, "TooFar"
	end
	local s = session(player)
	local wait = s.LastAim + AIM.Cooldown - os.clock()
	if wait > 0 then
		return false, { Cooldown = math.ceil(wait) }
	end
	local id = HttpService:GenerateGUID(false)
	s.Aim = { Id = id, At = os.clock() }
	return true, { RunId = id, Seed = rng:NextInteger(1, 2 ^ 30), Duration = AIM.Duration, Interval = AIM.SpawnInterval, Life = AIM.TargetLife }
end

local function aimFinish(player: Player, runId: string, hits: number): (boolean, any)
	local s = session(player)
	local run = s.Aim
	if not run or run.Id ~= runId then
		return false, "NoRun"
	end
	s.Aim = nil
	local elapsed = os.clock() - run.At
	if elapsed < AIM.Duration - 1.5 or elapsed > AIM.Duration + 30 then
		Log.Event("aim_bad_time", player, string.format("%.1fs", elapsed))
		return false, "BadTime"
	end
	-- Max targets the server could have shown, and the auto-clicker cap.
	local maxTargets = math.floor(AIM.Duration / AIM.SpawnInterval) + 1
	local cap = math.min(maxTargets, math.floor(AIM.MaxHitsPerSecond * AIM.Duration))
	if hits > cap then
		Log.Event("aim_score_cap", player, `{hits} > {cap}`)
		hits = cap
	end
	s.LastAim = os.clock()

	-- Diminishing returns after FullRuns runs in the window.
	local now = os.clock()
	local recent = {}
	for _, t in s.AimRuns do
		if now - t < AIM.Diminish.Window then
			table.insert(recent, t)
		end
	end
	table.insert(recent, now)
	s.AimRuns = recent
	local mult = if #recent > AIM.Diminish.FullRuns then AIM.Diminish.Mult else 1

	local pay = math.clamp(AIM.Pay.Base + hits * AIM.Pay.PerHit, AIM.Pay.Min, AIM.Pay.Max)
	pay = math.floor(pay * mult)
	EconomyService:Transact(player, { Cash = pay }, "AimTrainer")
	local gained = RosterService:AddFounderXp(player, "Aim", hits * AIM.AimXpPerHit * mult)
	bump(player, "Ftue.AimRuns")
	AnalyticsService:Custom(player, "AimTrainerRun", hits, { pay = pay })
	Bus.Fire(player, "AimRun", hits)
	return true, { Cash = pay, AimGained = gained, Hits = hits }
end

-- Reaction Test ----------------------------------------------------------------------------------------------------

local function reactStart(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data or not RosterService:GetFounder(player) then
		return false, "NoFounder"
	end
	if data.Stage < REACT.Stage then
		return false, { NeedStage = REACT.Stage }
	end
	if not PlotService:IsNear(player, "ReactionCabinet", REACT.MaxDistance) then
		return false, "TooFar"
	end
	local s = session(player)
	local wait = s.LastReact + REACT.Cooldown - os.clock()
	if wait > 0 then
		return false, { Cooldown = math.ceil(wait) }
	end
	local id = HttpService:GenerateGUID(false)
	s.React = { Id = id, At = os.clock() }
	return true, {
		RunId = id,
		Seed = rng:NextInteger(1, 2 ^ 30),
		Rounds = REACT.Rounds,
		ZoneStart = REACT.ZoneStart,
		ZoneEnd = REACT.ZoneEnd,
		Sweep = REACT.SweepSeconds,
	}
end

local function reactFinish(player: Player, runId: string, hits: number): (boolean, any)
	local s = session(player)
	local run = s.React
	if not run or run.Id ~= runId then
		return false, "NoRun"
	end
	s.React = nil
	local elapsed = os.clock() - run.At
	if elapsed < REACT.Rounds * REACT.MinRoundSeconds or elapsed > REACT.MaxSeconds then
		Log.Event("react_bad_time", player, string.format("%.1fs", elapsed))
		return false, "BadTime"
	end
	if hits > REACT.Rounds then
		Log.Event("react_score_cap", player, `{hits} > {REACT.Rounds}`)
		hits = REACT.Rounds
	end
	s.LastReact = os.clock()
	local now = os.clock()
	local recent = {}
	for _, t in s.ReactRuns do
		if now - t < REACT.Diminish.Window then
			table.insert(recent, t)
		end
	end
	table.insert(recent, now)
	s.ReactRuns = recent
	local mult = if #recent > REACT.Diminish.FullRuns then REACT.Diminish.Mult else 1
	local pay = math.floor(math.clamp(REACT.Pay.Base + hits * REACT.Pay.PerHit, REACT.Pay.Min, REACT.Pay.Max) * mult)
	EconomyService:Transact(player, { Cash = pay }, "ReactionTest")
	local gained = RosterService:AddFounderXp(player, "Reflexes", hits * REACT.ReflexesXpPerHit * mult)
	AnalyticsService:Custom(player, "ReactionTestRun", hits, { pay = pay })
	Bus.Fire(player, "ReactionRun", hits)
	return true, { Cash = pay, ReflexesGained = gained, Hits = hits }
end

-- Tech Fix jobs ---------------------------------------------------------------------------------------------------

local function jobReady(player: Player, s: Session): boolean
	return s.Job == nil and os.clock() >= s.NextJobAt and TutorialService:Reached(player, "TechFix")
end

local function techStart(player: Player): (boolean, any)
	local s = session(player)
	if not RosterService:GetFounder(player) then
		return false, "NoFounder"
	end
	if s.Job then
		return true, { JobId = s.Job.Id, Neighbor = s.Job.Neighbor, Steps = TECH.Steps } -- resume after closing the UI
	end
	if not jobReady(player, s) then
		return false, { NextIn = math.max(0, math.ceil(s.NextJobAt - os.clock())) }
	end
	if not PlotService:IsNear(player, "TechBench", TECH.MaxDistance) then
		return false, "TooFar"
	end
	local data = DataService:GetProfile(player)
	local neighbor = if data and data.Ftue.TechFixJobs == 0 then TECH.Neighbors[1] else TECH.Neighbors[rng:NextInteger(1, #TECH.Neighbors)]
	s.Job = { Id = HttpService:GenerateGUID(false), At = os.clock(), Neighbor = neighbor }
	return true, { JobId = s.Job.Id, Neighbor = neighbor, Steps = TECH.Steps }
end

local function techFinish(player: Player, jobId: string): (boolean, any)
	local s = session(player)
	local job = s.Job
	if not job or job.Id ~= jobId then
		return false, "NoJob"
	end
	local elapsed = os.clock() - job.At
	if elapsed < TECH.MinSeconds then
		Log.Event("techfix_too_fast", player, string.format("%.1fs", elapsed))
		return false, "TooFast"
	end
	s.Job = nil
	if elapsed > TECH.MaxSeconds then
		s.NextJobAt = os.clock() + TECH.JobEvery
		return false, "TooSlow"
	end
	local data = DataService:GetProfile(player)
	local first = data ~= nil and data.Ftue.TechFixJobs == 0
	local pay = if first then TECH.FirstPay else rng:NextInteger(TECH.Pay[1], TECH.Pay[2])
	EconomyService:Transact(player, { Cash = pay }, "TechFix")
	bump(player, "Ftue.TechFixJobs")
	s.NextJobAt = os.clock() + TECH.JobEvery
	PlotService:SetBenchJob(player, false)
	s.BenchShown = false
	AnalyticsService:Custom(player, "TechFixDone", pay, { seconds = math.floor(elapsed) })
	Bus.Fire(player, "TechFixDone")
	return true, { Cash = pay, Neighbor = job.Neighbor }
end

-- World state: cabinet screen "flickers on" at the AimTrainer step; the neighbor's PC appears when a job is ready.
local function tickWorld(player: Player)
	local s = session(player)
	local cabinet = TutorialService:Reached(player, "AimTrainer")
	if s.CabinetOn ~= cabinet then
		s.CabinetOn = cabinet
		PlotService:SetCabinet(player, cabinet)
	end
	local bench = s.Job ~= nil or jobReady(player, s)
	if s.BenchShown ~= bench then
		s.BenchShown = bench
		PlotService:SetBenchJob(player, bench)
	end
end

function MinigameService:Init()
	Remote.Function("Station", "BeginSetup", { Rate = { Count = 2, Per = 1 } }, beginSetup)
	Remote.Function("Station", "PowerOn", { Rate = { Count = 2, Per = 1 } }, powerOn)
	Remote.Function("Minigame", "AimStart", { Rate = { Count = 2, Per = 1 } }, aimStart)
	Remote.Function("Minigame", "AimFinish", { Args = { Remote.T.String(64), Remote.T.Int(0, 1000) }, Rate = { Count = 2, Per = 1 } }, aimFinish)
	Remote.Function("Minigame", "ReactStart", { Rate = { Count = 2, Per = 1 } }, reactStart)
	Remote.Function("Minigame", "ReactFinish", { Args = { Remote.T.String(64), Remote.T.Int(0, 100) }, Rate = { Count = 2, Per = 1 } }, reactFinish)
	Remote.Function("Minigame", "TechStart", { Rate = { Count = 2, Per = 1 } }, techStart)
	Remote.Function("Minigame", "TechFinish", { Args = { Remote.T.String(64) }, Rate = { Count = 2, Per = 1 } }, techFinish)
	Bus.On(function(player, event)
		if event == "PlotReady" then
			local s = session(player)
			s.BenchShown, s.CabinetOn = nil, nil
			tickWorld(player)
		end
	end)
end

function MinigameService:Start()
	Players.PlayerRemoving:Connect(function(player)
		sessions[player] = nil
	end)
	while true do
		task.wait(1)
		for _, player in Players:GetPlayers() do
			if PlotService:GetPlot(player) and DataService:GetProfile(player) then
				tickWorld(player)
			end
		end
	end
end

return MinigameService

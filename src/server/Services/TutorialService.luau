--!strict
-- TutorialService ([[Tutorial & Onboarding]]): moves the Guided FTUE forward from server facts only.
-- After every Bus event (and once a second) it re-runs the current step's Check; a passing step completes at once,
-- so doing things early or out of order never has to be redone. Steps are never completed by the client.
-- State lives in Profile.Tutorial (replicated through State/Delta); the client only draws it.
--   Tutorial/Lines (S→C)   { lineId, … } to show (step done lines, guardrail texts, Hector shouts)
--   The last step promotes to Stage 2 through ProgressionService (Stage/Promoted banner).
--   Tutorial/Stall (RE)    stepId, level 1–3 → analytics only (TutorialStallHint)

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
local Steps = require(ReplicatedStorage.Shared.Config.Tutorial.Steps)
local Lines = require(ReplicatedStorage.Shared.Config.Tutorial.Lines)
local ProgressionService = require(script.Parent.ProgressionService)

local TutorialService = { Tier = 6 }

local linesRemote: RemoteEvent
local stepStarted: { [Player]: number } = {} -- os.clock() when the current step started (this session)
local busy: { [Player]: boolean } = {}

local function context(player: Player, data: any): any
	local roster, seated = 0, 0
	for _ in data.Roster do
		roster += 1
	end
	for _, station in data.Stations do
		if station.PlayerId ~= "" and data.Roster[station.PlayerId] then
			seated += 1
		end
	end
	return { SeatedSeconds = PlotService:SeatedSeconds(player), RosterCount = roster, SeatedCount = seated }
end

function TutorialService:PushLines(player: Player, ids: { string })
	local valid = {}
	for _, id in ids do
		if Lines[id] then
			table.insert(valid, id)
		end
	end
	if #valid > 0 then
		linesRemote:FireClient(player, valid)
	end
end

-- True once the player has reached (started or finished) the given step.
function TutorialService:Reached(player: Player, stepId: string): boolean
	local data = DataService:GetProfile(player)
	if not data then
		return false
	end
	local current = data.Tutorial.Step
	if current == Steps.Done then
		return true
	end
	local have, need = Steps.Index[current], Steps.Index[stepId]
	return have ~= nil and need ~= nil and have >= need
end

function TutorialService:CurrentGoal(data: any): string
	local step = Steps.ById[data.Tutorial.Step]
	return if step then step.Goal else ""
end

-- "Garage Graduate": +25 Gems etc. come from Config/Stages[2].Promo ([[Tutorial & Onboarding]] → Rewards).
local function promote(player: Player)
	ProgressionService:Promote(player, 2)
end

local function startStep(player: Player, data: any, stepId: string)
	stepStarted[player] = os.clock()
	local step = Steps.ById[stepId]
	if step then
		AnalyticsService:Custom(player, "TutorialStepStarted", Steps.Index[stepId], { step = stepId })
		PlotService:SetWhiteboard(player, `GOAL: {string.upper(step.Goal)}`)
		if stepId == Steps.RenameRemindBefore then
			TutorialService:PushLines(player, { "TUT_RENAME_REMIND" })
		end
	else
		PlotService:SetWhiteboard(player, "GOAL: CAFÉ ROOKIES!")
	end
end

-- Completes as many steps as currently pass, in order.
function TutorialService:Advance(player: Player)
	if busy[player] then
		return
	end
	busy[player] = true
	for _ = 1, #Steps.List do
		local data = DataService:GetProfile(player)
		if not data then
			break
		end
		local step = Steps.ById[data.Tutorial.Step]
		if not step then
			break
		end
		local ok, passed = pcall(step.Check, data, context(player, data))
		if not ok then
			warn(`[Tutorial] {step.Id} check errored: {passed}`)
			break
		end
		if not passed then
			break
		end
		local seconds = math.floor(os.clock() - (stepStarted[player] or os.clock()))
		local idx = Steps.Index[step.Id]
		local nextStep = Steps.List[idx + 1]
		local nextId = if nextStep then nextStep.Id else Steps.Done
		if step.Lines.Done then
			TutorialService:PushLines(player, step.Lines.Done) -- before the step change, so they show before the next intro
		end
		DataService:Update(player, "Tutorial.Completed." .. step.Id, function()
			return os.time()
		end)
		DataService:Update(player, "Tutorial.Step", function()
			return nextId
		end)
		AnalyticsService:Custom(player, "TutorialStepCompleted", seconds, { step = step.Id })
		AnalyticsService:Funnel(player, step.Funnel)
		AnalyticsService:Beat(player, step.Id)
		startStep(player, data, nextId)
		if nextId == Steps.Done then
			promote(player)
		end
	end
	busy[player] = false
end

local function onLoaded(player: Player, data: any)
	if data.Tutorial.Step == "" or (data.Tutorial.Step ~= Steps.Done and not Steps.ById[data.Tutorial.Step]) then
		-- Unknown step (FTUE changed): restart at the first unfinished step; Check skips anything already done.
		DataService:Update(player, "Tutorial.Step", function()
			return Steps.List[1].Id
		end)
	end
	stepStarted[player] = os.clock()
end

function TutorialService:Init()
	linesRemote = Remote.Push("Tutorial", "Lines")
	Remote.Event("Tutorial", "Stall", {
		Args = { Remote.T.String(32), Remote.T.Int(1, 3) },
		Rate = { Count = 1, Per = 10 },
		Mutates = false,
	}, function(player, stepId, level)
		AnalyticsService:Custom(player, "TutorialStallHint", level, { step = stepId })
	end)

	DataService.ProfileLoaded:Connect(onLoaded)
	Bus.On(function(player, event, payload)
		if event == "Line" then
			TutorialService:PushLines(player, { payload })
			return
		end
		if event == "PlotReady" then
			local data = DataService:GetProfile(player)
			if data then
				startStep(player, data, data.Tutorial.Step)
				if data.Flags.IntroSeen and data.Tutorial.Step ~= Steps.Done and data.Tutorial.Step ~= Steps.List[1].Id then
					TutorialService:PushLines(player, { "TUT_WELCOMEBACK" })
				end
			end
		end
		TutorialService:Advance(player)
	end)
end

function TutorialService:Start()
	Players.PlayerRemoving:Connect(function(player)
		stepStarted[player] = nil
		busy[player] = nil
	end)
	while true do
		task.wait(1)
		for _, player in Players:GetPlayers() do
			task.spawn(TutorialService.Advance, TutorialService, player)
		end
	end
end

return TutorialService

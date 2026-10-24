--!strict
-- ProgressionService ([[Progression Guide]]): stage promotions. Stage 1 → 2 comes from the tutorial's last step
-- (TutorialService calls Promote); from Stage 2 on, reaching the next stage's Fame gate promotes, up to
-- Stages.MaxStage (the last stage whose content exists). Rewards + banner text from Config/Stages Promo.
--   Stage/Promoted (S→C) stage, name, text → promotion banner

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
local Stages = require(ReplicatedStorage.Shared.Config.Stages)

local ProgressionService = { Tier = 5 }

local promotedRemote: RemoteEvent

function ProgressionService:Promote(player: Player, stage: number): boolean
	local data = DataService:GetProfile(player)
	local def = Stages[stage]
	if not data or not def or data.Stage >= stage then
		return false
	end
	DataService:Update(player, "Stage", function()
		return stage
	end)
	local promo = def.Promo or {}
	if promo.Achievement then
		DataService:Update(player, "Achievements." .. promo.Achievement, function()
			return os.time()
		end)
	end
	if promo.Gems and promo.Gems > 0 then
		EconomyService:Transact(player, { Gems = promo.Gems }, `Promotion:Stage{stage}`)
	end
	promotedRemote:FireClient(player, stage, def.Name, promo.Text or "")
	AnalyticsService:Custom(player, "StageReached", stage)
	PlotService:Refresh(player, { Animate = true }) -- era pieces (café annex, trophy shelf) build in
	Bus.Fire(player, "Promoted", stage)
	DataService:SaveNow(player, "Promotion")
	Log.Info("Progression", `{player.Name} promoted to Stage {stage} ({def.Name})`)
	return true
end

-- Fame-gated promotions from Stage 2 up to MaxStage.
local function check(player: Player)
	local data = DataService:GetProfile(player)
	if not data or data.Stage < 2 or data.Stage >= Stages.MaxStage then
		return
	end
	local nextStage = Stages[data.Stage + 1]
	if nextStage and (data.Currencies.Fame or 0) >= nextStage.Fame then
		ProgressionService:Promote(player, data.Stage + 1)
	end
end

function ProgressionService:Init()
	promotedRemote = Remote.Push("Stage", "Promoted")
	Bus.On(function(player, event)
		if event ~= "Line" and event ~= "Promoted" then
			check(player)
		end
	end)
end

function ProgressionService:Start()
	while true do
		task.wait(2)
		for _, player in Players:GetPlayers() do
			check(player)
		end
	end
end

return ProgressionService

--!strict
-- OnboardingService: the one-shot steps before the tutorial ([[Screen - Start]], [[Intro Cutscene]], [[Screen - Starter Letter]]).
--   Onboarding/Intro (RE)  kind ∈ Started | Skipped | Finished, atSecond → IntroSeen flag + analytics.
--     The cutscene itself runs locally; the server only records that it was seen. Replays don't change progress.
--   Starter/Collect (RF)   no args → grants the starter gift once, sets StarterLetterSeen, returns the amount.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lib = script.Parent.Parent.Lib
local Remote = require(Lib.Remote)
local Bus = require(Lib.Bus)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local AnalyticsService = require(script.Parent.AnalyticsService)
local Economy = require(ReplicatedStorage.Shared.Config.Economy)

local OnboardingService = { Tier = 3 }

local function onIntro(player: Player, kind: string, atSecond: number?)
	local data = DataService:GetProfile(player)
	if not data then
		return
	end
	local at = math.floor(atSecond or 0)
	AnalyticsService:Custom(player, "Intro" .. kind, at, { replay = data.Flags.IntroSeen })
	if kind == "Started" or data.Flags.IntroSeen then
		return
	end
	DataService:Update(player, "Flags.IntroSeen", function()
		return true
	end)
	AnalyticsService:Funnel(player, "IntroDone")
	AnalyticsService:Beat(player, "Intro")
	Bus.Fire(player, "IntroDone", kind)
end

local function collect(player: Player): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data then
		return false, "NotLoaded"
	end
	if data.Flags.StarterLetterSeen then
		return false, "AlreadyCollected"
	end
	DataService:Update(player, "Flags.StarterLetterSeen", function()
		return true
	end)
	local ok, err = EconomyService:Transact(player, { Cash = Economy.StarterGift }, "StarterGift")
	if not ok then
		return false, err
	end
	DataService:SaveNow(player, "StarterGift")
	Bus.Fire(player, "StarterCollected")
	return true, Economy.StarterGift
end

function OnboardingService:Init()
	Remote.Event("Onboarding", "Intro", {
		Args = { Remote.T.OneOf({ "Started", "Skipped", "Finished" }), Remote.T.Number(0, 600) },
		Rate = { Count = 3, Per = 5 },
	}, onIntro)
	Remote.Function("Starter", "Collect", { Rate = { Count = 2, Per = 5 } }, collect)
end

return OnboardingService

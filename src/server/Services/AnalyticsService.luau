--!strict
-- AnalyticsService ([[Analytics & Metrics]]): wraps Roblox AnalyticsService for the FTUE funnel, custom events and
-- economy events, tracks play time (Ftue.PlaySeconds, used by the 12-min hire guardrail) and records when each
-- Stage 1 beat lands (Ftue.BeatAt) so a test run can be compared with the beat sheet.
-- Every Roblox call is pcall'd: analytics must never break gameplay.

local Players = game:GetService("Players")
local RobloxAnalytics = game:GetService("AnalyticsService")

local Lib = script.Parent.Parent.Lib
local Log = require(Lib.Log)
local DataService = require(script.Parent.DataService)

local AnalyticsService = { Tier = 0 }

-- Onboarding funnel ([[Analytics & Metrics]] → FTUE funnel). Step numbers must stay stable once live.
AnalyticsService.FunnelSteps = {
	"Join", "IntroDone", "TeamNamed", "PowerOn", "SitDesk", "FirstPickupWin", "AimTrainer", "FirstTechFix",
	"FirstUpgrade", "SecondDesk", "FirstHire", "TeamPugWin", "FirstUnbox", "ThirdDesk", "Stage2",
}
local stepNumber: { [string]: number } = {}
for i, name in AnalyticsService.FunnelSteps do
	stepNumber[name] = i
end

local FLUSH_EVERY = 30 -- seconds between PlaySeconds writes
local SHOP_REASONS = { "BuyPad", "Hire", "CaseBuy", "TechShop" } -- Transact reasons logged as Shop, not Gameplay
local sessionClock: { [Player]: number } = {} -- os.clock() of the last PlaySeconds flush

local function flush(player: Player)
	local at = sessionClock[player]
	if not at then
		return
	end
	local now = os.clock()
	local whole = math.floor(now - at)
	if whole >= 1 then
		sessionClock[player] = at + whole
		DataService:Update(player, "Ftue.PlaySeconds", function(v)
			return (v or 0) + whole
		end)
	end
end

local function fmt(seconds: number): string
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end
AnalyticsService.Format = fmt

-- Total seconds this profile has spent in game, including the unflushed part of this session.
function AnalyticsService:PlaySeconds(player: Player): number
	local data = DataService:GetProfile(player)
	if not data then
		return 0
	end
	local at = sessionClock[player]
	return (data.Ftue.PlaySeconds or 0) + (if at then math.floor(os.clock() - at) else 0)
end

function AnalyticsService:Custom(player: Player, name: string, value: number?, fields: { [string]: any }?)
	local custom = nil
	if fields then
		custom = {}
		local keys = { Enum.AnalyticsCustomFieldKeys.CustomField01, Enum.AnalyticsCustomFieldKeys.CustomField02, Enum.AnalyticsCustomFieldKeys.CustomField03 }
		local i = 0
		local names = {}
		for k in fields do
			table.insert(names, k)
		end
		table.sort(names)
		for _, k in names do
			i += 1
			if i > #keys then
				break
			end
			custom[keys[i].Name] = `{k}={tostring(fields[k])}`
		end
	end
	pcall(RobloxAnalytics.LogCustomEvent, RobloxAnalytics, player, name, value or 1, custom)
end

-- FTUE funnel step, logged once per profile.
function AnalyticsService:Funnel(player: Player, name: string)
	local step = stepNumber[name]
	local data = DataService:GetProfile(player)
	if not step or not data or data.Ftue.Funnel[name] then
		return
	end
	local at = self:PlaySeconds(player)
	DataService:Update(player, "Ftue.Funnel." .. name, function()
		return at
	end)
	pcall(RobloxAnalytics.LogOnboardingFunnelStepEvent, RobloxAnalytics, player, step, name)
	Log.Info("Funnel", `{player.Name} step {step} {name} at {fmt(at)}`)
end

-- Records the play-time minute a Stage 1 beat completed (once).
function AnalyticsService:Beat(player: Player, stepId: string)
	local data = DataService:GetProfile(player)
	if not data or data.Ftue.BeatAt[stepId] then
		return
	end
	local at = self:PlaySeconds(player)
	DataService:Update(player, "Ftue.BeatAt." .. stepId, function()
		return at
	end)
	Log.Info("Beat", `{player.Name} {stepId} at {fmt(at)}`)
end

-- flow: "Source" | "Sink". Skips per-second income ticks (summarized by EconomyService instead).
function AnalyticsService:Economy(player: Player, flow: string, currency: string, amount: number, balance: number, reason: string)
	local flowType = if flow == "Source" then Enum.AnalyticsEconomyFlowType.Source else Enum.AnalyticsEconomyFlowType.Sink
	local shop = false
	for _, prefix in SHOP_REASONS do
		if string.find(reason, prefix, 1, true) then
			shop = true
			break
		end
	end
	local txType = if shop then Enum.AnalyticsEconomyTransactionType.Shop.Name else Enum.AnalyticsEconomyTransactionType.Gameplay.Name
	pcall(RobloxAnalytics.LogEconomyEvent, RobloxAnalytics, player, flowType, currency, math.abs(amount), balance, txType, reason)
end

function AnalyticsService:Init()
	-- Suspicious-event stand-in from M0 now also lands in analytics ([[Security & Anti-Exploit]] → Logging).
	Log.Sink = function(name: string, player: Player?, details: string?)
		if player then
			AnalyticsService:Custom(player, name, 1, { detail = string.sub(details or "", 1, 50) })
		end
	end

	DataService.ProfileLoaded:Connect(function(player)
		sessionClock[player] = os.clock()
		AnalyticsService:Funnel(player, "Join")
	end)
	DataService.ProfileReleasing:Connect(function(player)
		flush(player)
		sessionClock[player] = nil
	end)
end

function AnalyticsService:Start()
	Players.PlayerRemoving:Connect(function(player)
		task.defer(function()
			sessionClock[player] = nil
		end)
	end)
	while true do
		task.wait(FLUSH_EVERY)
		for player in sessionClock do
			flush(player)
		end
	end
end

return AnalyticsService

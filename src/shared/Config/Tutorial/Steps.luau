--!strict
-- Guided FTUE steps ([[Tutorial & Onboarding]] → Guided FTUE, matches [[Stage 1 - Garage Squad]]).
-- Check(data, ctx) is pure: TutorialService re-runs it after every gameplay event, so out-of-order completion works.
-- ctx = { SeatedSeconds, RosterCount, SeatedCount } (server-computed, not saved).
-- Progress(data, ctx) → (have, need, label) drives the objective card bar.
-- Target: World = garage anchor name, Ui = registered UI target. UiWhenSeated swaps to a UI target while seated.
-- Funnel = AnalyticsService onboarding funnel step logged on completion ([[Analytics & Metrics]] → FTUE funnel).

local Hiring = require(script.Parent.Parent.Hiring)

local function cash(data: any): number
	return data.Currencies.Cash or 0
end

local function rustyPrice(data: any): number
	return if data.Ftue.RustyDiscount then Hiring.Featured.DiscountPrice else Hiring.Featured.Price
end

export type Step = {
	Id: string,
	Goal: string,
	Lines: { Intro: string?, Hint: string?, Call: string?, Done: { string }? },
	Target: { World: string?, Ui: string?, UiWhenSeated: string? },
	Check: (data: any, ctx: any) -> boolean,
	Progress: ((data: any, ctx: any) -> (number, number, string))?,
	Funnel: string,
	Beat: string, -- target minute from the beat sheet, for the test-run report
}

local steps: { Step } = {
	{
		Id = "NameTeam",
		Goal = "Name your team",
		Lines = { Intro = "TUT_NAMETEAM_1", Hint = "TUT_NAMETEAM_HINT", Call = "TUT_NAMETEAM_CALL", Done = { "TUT_NAMETEAM_DONE" } },
		Target = { Ui = "TeamConfirm" },
		Check = function(data)
			return data.Flags.TeamCreated
		end,
		Funnel = "TeamNamed",
		Beat = "0:50",
	},
	{
		Id = "PowerOn",
		Goal = "Set up your PC",
		Lines = { Intro = "TUT_POWERON_1", Hint = "TUT_POWERON_HINT", Call = "TUT_POWERON_CALL", Done = { "TUT_POWERON_DONE" } },
		Target = { World = "FounderDesk" },
		Check = function(data)
			return data.Flags.StationPowered
		end,
		Funnel = "PowerOn",
		Beat = "1:30",
	},
	{
		Id = "SitDesk",
		Goal = "Sit at your desk",
		Lines = { Intro = "TUT_SITDESK_1", Hint = "TUT_SITDESK_HINT", Call = "TUT_SITDESK_CALL", Done = { "TUT_SITDESK_DONE" } },
		Target = { World = "FounderSeat" },
		Check = function(data, ctx)
			return ctx.SeatedSeconds >= 5 or data.Ftue.PickupGames > 0
		end,
		Funnel = "SitDesk",
		Beat = "1:45",
	},
	{
		Id = "FirstPug",
		Goal = "Play a Pickup Game",
		Lines = { Intro = "TUT_FIRSTPUG_1", Hint = "TUT_FIRSTPUG_HINT", Call = "TUT_FIRSTPUG_CALL", Done = { "HEC_FIRSTWIN" } },
		Target = { World = "FounderSeat", UiWhenSeated = "PickupButton" },
		Check = function(data)
			return data.Ftue.PickupWins >= 1
		end,
		Funnel = "FirstPickupWin",
		Beat = "2:30",
	},
	{
		Id = "AimTrainer",
		Goal = "Try the arcade cabinet",
		Lines = { Intro = "TUT_AIM_1", Hint = "TUT_AIM_HINT", Call = "TUT_AIM_CALL", Done = { "TUT_AIM_DONE" } },
		Target = { World = "AimCabinet" },
		Check = function(data)
			return data.Ftue.AimRuns >= 1
		end,
		Funnel = "AimTrainer",
		Beat = "4:00",
	},
	{
		Id = "TechFix",
		Goal = "Fix the neighbor's PC",
		Lines = { Intro = "TUT_TECHFIX_1", Hint = "TUT_TECHFIX_HINT", Call = "TUT_TECHFIX_CALL", Done = { "TUT_TECHFIX_DONE" } },
		Target = { World = "TechBench" },
		Check = function(data)
			return data.Ftue.TechFixJobs >= 1
		end,
		Funnel = "FirstTechFix",
		Beat = "5:30",
	},
	{
		Id = "FirstUpgrade",
		Goal = "Buy a better mouse",
		Lines = { Intro = "TUT_UPGRADE_1", Hint = "TUT_UPGRADE_HINT", Call = "TUT_UPGRADE_CALL", Done = { "TUT_UPGRADE_DONE" } },
		Target = { World = "Pad_Mouse" },
		Check = function(data)
			return data.HQ.PadsBought.Founder_Mouse == true
		end,
		Progress = function(data)
			return cash(data), 150, "Cash"
		end,
		Funnel = "FirstUpgrade",
		Beat = "6:30",
	},
	{
		Id = "SecondDesk",
		Goal = "Buy a 2nd desk",
		Lines = { Intro = "TUT_DESK2_1", Hint = "TUT_DESK2_HINT", Call = "TUT_DESK2_CALL", Done = { "TUT_DESK2_DONE" } },
		Target = { World = "Pad_Desk2" },
		Check = function(data)
			return data.HQ.PadsBought.Desk2 == true
		end,
		Progress = function(data)
			return cash(data), 300, "Cash"
		end,
		Funnel = "SecondDesk",
		Beat = "7:30",
	},
	{
		Id = "FirstHire",
		Goal = "Hire your first teammate",
		Lines = { Intro = "TUT_HIRE_1", Hint = "TUT_HIRE_HINT", Call = "TUT_HIRE_CALL", Done = { "HEC_FIRSTHIRE", "TUT_HIRE_DONE" } },
		Target = { World = "FreeAgentBoard", Ui = "HireButton" },
		Check = function(_, ctx)
			return ctx.RosterCount >= 2
		end,
		Progress = function(data)
			return cash(data), rustyPrice(data), "Cash"
		end,
		Funnel = "FirstHire",
		Beat = "8:30",
	},
	{
		Id = "TeamPug",
		Goal = "Win a Pickup Game with your squad",
		Lines = { Intro = "TUT_TEAMPUG_1", Hint = "TUT_TEAMPUG_HINT", Call = "TUT_TEAMPUG_CALL", Done = { "HEC_DYNASTY" } },
		Target = { World = "FounderSeat", UiWhenSeated = "PickupButton" },
		Check = function(data)
			return data.Ftue.CratesEarned >= 1
		end,
		Funnel = "TeamPugWin",
		Beat = "10:00",
	},
	{
		Id = "FirstUnbox",
		Goal = "Open your Rookie Crate",
		Lines = { Intro = "TUT_UNBOX_1", Hint = "TUT_UNBOX_HINT", Call = "TUT_UNBOX_CALL", Done = { "HEC_FIRSTRARE" } },
		Target = { Ui = "CrateButton" },
		Check = function(data)
			return data.Ftue.CratesOpened >= 1
		end,
		Funnel = "FirstUnbox",
		Beat = "11:00",
	},
	{
		Id = "SeatRare",
		Goal = "Buy a 3rd desk for your new player",
		Lines = { Intro = "TUT_SEAT_1", Hint = "TUT_SEAT_HINT", Call = "TUT_SEAT_CALL", Done = { "TUT_SEAT_DONE" } },
		Target = { World = "Pad_Desk3" },
		Check = function(_, ctx)
			return ctx.SeatedCount >= 3
		end,
		Progress = function(data)
			return cash(data), 500, "Cash"
		end,
		Funnel = "ThirdDesk",
		Beat = "12:30",
	},
	{
		Id = "Promotion",
		Goal = "Reach 100 Fame",
		Lines = { Intro = "TUT_PROMO_1", Hint = "TUT_PROMO_HINT", Call = "TUT_PROMO_CALL", Done = { "HEC_PROMO_S2", "TUT_GRADUATE" } },
		Target = { World = "FounderSeat", UiWhenSeated = "PickupButton" },
		Check = function(data, ctx)
			return (data.Currencies.Fame or 0) >= 100 and ctx.SeatedCount >= 3
		end,
		Progress = function(data)
			return data.Currencies.Fame or 0, 100, "Fame"
		end,
		Funnel = "Stage2",
		Beat = "14:00",
	},
}

local byId: { [string]: Step } = {}
local index: { [string]: number } = {}
for i, s in steps do
	byId[s.Id] = s
	index[s.Id] = i
end

return {
	Version = 1,
	List = steps,
	ById = byId,
	Index = index,
	Done = "Done",
	Stall = { Pulse = 30, Hint = 60, Call = 120 },
	RenameRemindBefore = "Promotion", -- TUT_RENAME_REMIND plays when this step starts
}

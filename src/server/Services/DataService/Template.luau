--!strict
-- The full Profile from [[Data Schema]]. New fields with defaults don't need a Version bump: Reconcile() fills them in.
-- Rules (ProfileStore): no Instances/userdata/functions, no mixed or gappy arrays. Fields that default to nil
-- (PendingEvent, Tournament) are listed as comments because a nil key can't live in a table.

return {
	Version = 1,
	-- Colors = { Primary = index, Tee = index } into Config/Team.Colors; Jersey = { Garment = "OwnTee" }.
	-- FounderRole = role picked in the Team Creator; the Founder card is minted with it at Power On.
	Team = { Name = "", Tag = "", LogoId = 0, Colors = {}, Jersey = {}, FounderRole = "Flex" },
	Currencies = { Cash = 0, Gems = 0, Shards = 0, Fame = 0, Followers = 0, LegacyPoints = 0 },
	Stage = 1,
	Rebirths = 0,
	Roster = {}, -- [id] = PlayerCard
	-- Parts / Accessories = [itemId] = unequipped copies; equipped ones live on Stations[slot].Parts / card.Accessories.
	Inventory = {
		Parts = {},
		Accessories = {},
		Cosmetics = {},
		Boosters = {},
		TimeSkips = { Quick = 0, Hour = 0, Big = 0 },
		Cases = {}, -- [caseId] = count; StarterCrate = the FTUE crate
	},
	-- Opened = lifetime opens; NextFreeAt = os.time() of the next free Rookie Crate (0 = timer not started).
	CaseStats = { Opened = 0, NextFreeAt = 0 },
	-- [slot as string "1".."n"] = { PlayerId = card id or "", Tier = 1, Parts = {} }. Slot "1" is the Founder's desk.
	Stations = {},
	FounderUuid = "",
	-- One-shot onboarding flags ([[Screen - Start]], [[Screen - Starter Letter]], [[Intro Cutscene]]).
	Flags = { IntroSeen = false, StarterLetterSeen = false, TeamCreated = false, StationPowered = false },
	-- Stage 1 counters ([[Founder (You)]] → Profile.Ftue). PlaySeconds = total time in game, used by the 12-min guardrail.
	-- StarterRoll = the FTUE crate's (StarterCrate) Rare, rolled once when the crate is granted ({ Id, Seed } once set).
	-- BeatAt = [step id] = PlaySeconds when it completed (test-run report). Funnel = onboarding steps already logged.
	Ftue = {
		PlaySeconds = 0,
		PickupGames = 0,
		PickupWins = 0,
		TeamPugLosses = 0,
		AimRuns = 0,
		TechFixJobs = 0,
		CratesEarned = 0,
		CratesOpened = 0,
		FirstHireAt = 0,
		RustyDiscount = false,
		StarterRoll = {},
		BeatAt = {},
		Funnel = {},
	},
	-- [[Tutorial & Onboarding]] → Server / data requirements. Step = current step id, "Done" when finished.
	Tutorial = { Version = 1, Step = "NameTeam", Completed = {}, Skipped = false, HintLevel = "Full" },
	Staff = {},
	Sponsors = {},
	Clips = {},
	Trophies = {}, -- array of { Def, Name, Place, At }
	PityCounters = { Epic = 0, Legendary = 0, Mythic = 0 },
	-- Match sim ([[Match Simulation]]): Chemistry["idA|idB"] (ids sorted) = matches played together;
	-- MapMastery[mapId] = 0–100; Competition = lifetime counts; TournamentLog = last finished tournaments (newest first).
	Chemistry = {},
	MapMastery = {},
	Competition = { Scrims = 0, ScrimWins = 0, Cups = 0, CupWins = 0 },
	TournamentLog = {},
	Quests = {},
	Settings = {},
	LastSeen = 0,
	HQ = { Era = "Garage", PadsBought = {}, Decor = {}, HQLevel = 0 },
	Training = {},
	Rivals = {},
	Achievements = {},
	Collection = {},
	Arena = {},
	Hype = 0,
	LegacyPoints = 0,
	LegacyPerks = {},
	LegacyHall = {},
	Snapshot = {},
	-- PendingEvent = nil,
	EventCooldownUntil = 0,
	Streak = { Day = 0, LastClaim = 0 },
	PassTier = 0,
	Purchases = {},
	-- Tournament = nil,
	ClaimedGrants = {},
	ModNotes = {},
	Warnings = {},
}

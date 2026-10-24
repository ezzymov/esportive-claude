--!strict
-- Minigame + Pickup Game numbers ([[Founder (You)]] → Earning money yourself, [[Playable Games]]).
-- Server sanity caps per [[Security & Anti-Exploit]]: max score per second, min/max run time, cooldowns.

return {
	CableSetup = {
		Cables = { { Name = "Power", Color = "F87171" }, { Name = "Video", Color = "22D3EE" }, { Name = "USB", Color = "FBBF24" } },
		MinSeconds = 2, -- BeginSetup → PowerOn can't be faster than this
	},

	AimTrainer = {
		Duration = 20, -- seconds per run
		SpawnInterval = 0.6, -- one target every N s (server knows the max possible targets)
		TargetLife = 1.3,
		MaxHitsPerSecond = 2.5, -- auto-clicker cap
		Pay = { Base = 20, PerHit = 2, Min = 20, Max = 80 },
		AimXpPerHit = 8, -- 100 XP = +1 Aim (Founder)
		Cooldown = 15, -- seconds between runs
		Diminish = { Window = 600, FullRuns = 5, Mult = 0.5 }, -- after 5 runs in 10 min, pay × 0.5
		MaxDistance = 12,
	},

	TechFix = {
		JobEvery = 90, -- a new neighbor job 90 s after the last one was finished
		MinSeconds = 6, -- can't repair faster than this
		MaxSeconds = 300,
		FirstPay = 200, -- beat sheet: the first job pays $200
		Pay = { 100, 250 },
		Neighbors = { "Mrs. Park", "Mr. Okafor", "the twins next door", "Coach Diaz" },
		Steps = { "Plug", "Swap", "Dust" },
		MaxDistance = 12,
	},

	-- Stage 2's new toy ([[Stage Beat Sheets 2-10]]): timing bars. A marker sweeps; stop it in the green zone.
	-- The zone shrinks every round. Hits pay Cash and Reflexes XP for the Founder.
	ReactionTest = {
		Stage = 2,
		Rounds = 8,
		ZoneStart = 0.26, -- green zone width (fraction of the bar) in round 1
		ZoneEnd = 0.10, -- … and in the last round
		SweepSeconds = { 1.2, 0.7 }, -- one pass across the bar, round 1 → last round
		MinRoundSeconds = 0.35, -- server: a run can't be faster than Rounds × this
		MaxSeconds = 90,
		Pay = { Base = 25, PerHit = 6, Min = 25, Max = 80 },
		ReflexesXpPerHit = 12, -- 100 XP = +1 Reflexes (Founder)
		Cooldown = 15,
		Diminish = { Window = 600, FullRuns = 5, Mult = 0.5 },
		MaxDistance = 12,
	},

	Pickup = {
		Cooldown = 75, -- seconds from one Pickup Game start to the next
		WinCash = { Base = 150, Min = 120, Max = 200 },
		LossCash = 50,
		WinFame = 60, -- × (opponent / your power), clamp 0.5–2 ([[Economy Design]] FameGain)
		LossFame = 10,
		FameRatioClamp = { 0.5, 2 },
		-- Pickup lobby OVR by stage: Garage-level at Stage 1, tougher later so wins keep paying Fame toward the next gate.
		OpponentOvrByStage = { { 28, 38 }, { 34, 48 }, { 40, 54 } },
		PugRarity = "Common",
		PityFirstGame = true, -- first ever Pickup Game is a guaranteed win
		CratePityAfterLosses = 1, -- before the Rookie Crate is earned: guaranteed win after this many team-game losses
		MaxDistance = 12, -- from your desk
	},
}

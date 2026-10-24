--!strict
-- Traits ([[Trait Library]], starter list in [[Balance Tables]]). Shown on cards; Effect is what the match sim uses.
-- Tier: which rarities may roll it (⚪ White, 🔵 Blue, 🟣 Purple, 🟡 Gold). Negative = counts toward the bad-trait share.
--
-- Effect (all optional, read by MatchService/Sim):
--   Stats = { Aim = 0.10 }      per-stat multiplier (+10%), always on
--   All = 0.05, When = "…"      every stat ×(1 + All) while the condition holds
--   When: MatchPoint · Trailing4 · Ahead · Behind · First5 · After5 · LostStreak3 · Night · Morning · Final · Scrim
--   Team = { Chemistry = 0.05, Morale = 5 }   team-wide while in the active five
--   NoMoraleLoss = true · MoraleLossMult = 0.7 · WinMorale = 5   (applied after the match)
-- Stacking cap: trait bonus to one stat ≤ +30% (StatCap).

return {
	PlayerOwner = { Name = "Player-Owner", Desc = "+5% team morale while in the active five", Tier = "Founder", Effect = { Team = { Morale = 5 } } },

	-- ⚪ White
	ClassClown = { Name = "Class Clown", Desc = "Keeps the room laughing. -3% Game Sense", Tier = "White", Effect = { Stats = { GameSense = -0.03 } } },
	Loyal = { Name = "Loyal", Desc = "Never leaves, -10% salary", Tier = "White" },
	NightOwl = { Name = "Night Owl", Desc = "+5% stats in matches 18:00–24:00 server time", Tier = "White", Effect = { All = 0.05, When = "Night" } },
	EarlyBird = { Name = "Early Bird", Desc = "+5% stats in matches 06:00–12:00 server time", Tier = "White", Effect = { All = 0.05, When = "Morning" } },
	TiltProne = { Name = "Tilt-Prone", Desc = "-10% stats after 3 lost rounds in a row; +5% Aim", Tier = "White", Negative = true, Effect = { Stats = { Aim = 0.05 }, All = -0.10, When = "LostStreak3" } },
	GlassCannon = { Name = "Glass Cannon", Desc = "Aim +10%, Consistency -10%", Tier = "White", Negative = true, Effect = { Stats = { Aim = 0.10, Consistency = -0.10 } } },
	Showboat = { Name = "Showboat", Desc = "More Clip Moments, -5% Teamwork", Tier = "White", Effect = { Stats = { Teamwork = -0.05 }, ClipBonus = 0.15 } },
	SlowStarter = { Name = "Slow Starter", Desc = "-5% first 5 rounds, +8% after", Tier = "White", Negative = true, Effect = { All = 0.08, When = "After5", Early = -0.05 } },
	FrontRunner = { Name = "Front-Runner", Desc = "+8% when ahead, -5% when behind", Tier = "White", Effect = { All = 0.08, When = "Ahead", Behind = -0.05 } },
	StageFright = { Name = "Stage Fright", Desc = "-8% in finals, +5% in scrims", Tier = "White", Negative = true, Effect = { All = 0.05, When = "Scrim", InFinal = -0.08 } },

	-- 🔵 Blue
	RisingStar = { Name = "Rising Star", Desc = "+30% training XP", Tier = "Blue" },
	Streamer = { Name = "Streamer", Desc = "+20% clip views", Tier = "Blue" },
	IceCold = { Name = "Ice Cold", Desc = "No morale penalty after losses", Tier = "Blue", Effect = { NoMoraleLoss = true } },
	TeamLeader = { Name = "Team Leader", Desc = "+5% team chemistry", Tier = "Blue", Effect = { Team = { Chemistry = 0.05 } } },
	SprayMaster = { Name = "Spray Master", Desc = "+6% Aim", Tier = "Blue", Effect = { Stats = { Aim = 0.06 } } },
	Lurker = { Name = "Lurker", Desc = "+8% Clutch, -5% Teamwork", Tier = "Blue", Effect = { Stats = { Clutch = 0.08, Teamwork = -0.05 } } },
	CalmVoice = { Name = "Calm Voice", Desc = "Team morale loss from defeats -30%", Tier = "Blue", Effect = { MoraleLossMult = 0.7 } },
	HypeMachine = { Name = "Hype Machine", Desc = "Wins give the whole team +5 morale extra", Tier = "Blue", Effect = { WinMorale = 5 } },

	-- 🟣 Purple
	ClutchGod = { Name = "Clutch God", Desc = "Clutch ×1.25 in final rounds", Tier = "Purple", Effect = { Stats = {}, ClutchFinal = 0.25 } },
	Closer = { Name = "Closer", Desc = "+10% all stats at match point", Tier = "Purple", Effect = { All = 0.10, When = "MatchPoint" } },
	ComebackKid = { Name = "Comeback Kid", Desc = "+12% all stats when trailing by 4+ rounds", Tier = "Purple", Effect = { All = 0.12, When = "Trailing4" } },
	FlickWizard = { Name = "Flick Wizard", Desc = "+12% Reflexes, -4% Consistency", Tier = "Purple", Effect = { Stats = { Reflexes = 0.12, Consistency = -0.04 } } },

	-- 🟡 Gold
	BigStage = { Name = "Big Stage", Desc = "+10% all stats in finals", Tier = "Gold", Effect = { All = 0.10, When = "Final" } },
	Unshakeable = { Name = "Unshakeable", Desc = "Immune to morale loss", Tier = "Gold", Effect = { NoMoraleLoss = true } },
	Adaptable = { Name = "Adaptable", Desc = "No off-title stat penalty", Tier = "Gold" },

	StatCap = 0.30,

	-- Which trait tiers each rarity may roll.
	Allowed = {
		Common = { White = true },
		Uncommon = { White = true },
		Rare = { White = true, Blue = true },
		Epic = { White = true, Blue = true, Purple = true },
		Legendary = { Blue = true, Purple = true, Gold = true },
		Mythic = { Purple = true, Gold = true },
	},
	NegativeShare = { Common = 0.30, Uncommon = 0.15, Rare = 0.05, Epic = 0, Legendary = 0, Mythic = 0 },
}

--!strict
-- The 10 stages from [[Progression Guide]]. Fame is the gate and is never spent.
-- Promo = what the promotion banner gives and says (ProgressionService). Stage 1 → 2 comes from the tutorial's last
-- step; from then on, reaching the next stage's Fame promotes — up to MaxStage, the last stage whose content exists.

local stages: any = {
	{ Id = 1, Name = "Garage Squad", Fame = 0, Unlocks = { "Plot", "OwnStation", "Founder", "PickupGames", "AimTrainer", "TechFix", "TeamCreator" } },
	{
		Id = 2,
		Name = "Café Rookies",
		Fame = 100,
		Unlocks = { "RookieCrate", "ReactionTest", "TechShop", "RosterSlots5" },
		Promo = { Gems = 25, Achievement = "GarageGraduate", Text = "Garage Graduate · +25 💎 · The café annex is open: Tech Shop, Rookie Crates, Reaction Test, café PCs 4 and 5" },
	},
	{
		Id = 3,
		Name = "Local Circuit",
		Fame = 500,
		Unlocks = { "Scrims", "LocalCup", "TrainingCenter", "Leaderboards" },
		Promo = { Gems = 25, Achievement = "LocalCircuit", Text = "+25 💎 · Compete is open: scrims and the Local Cup · trophy shelf · leaderboards" },
	},
	{ Id = 4, Name = "Rising Org", Fame = 2_000, Unlocks = { "ClipEditor", "FirstSponsor", "ProCrate", "FriendScrims" } },
	{ Id = 5, Name = "Semi-Pro Division", Fame = 8_000, Unlocks = { "StaffHiring", "GamingHouse", "SecondTitle" } },
	{ Id = 6, Name = "Pro League", Fame = 30_000, Unlocks = { "StreamingBooth", "MerchStore", "EliteCrate", "RegionalTournaments" } },
	{ Id = 7, Name = "National Champions", Fame = 100_000, Unlocks = { "TrophyHall", "ThirdTitle", "Academy", "TransferMarket" } },
	{ Id = 8, Name = "International Stage", Fame = 400_000, Unlocks = { "Arena", "LegendCrate", "GlobalSponsors" } },
	{ Id = 9, Name = "World Contenders", Fame = 1_500_000, Unlocks = { "MythicParts", "WorldsLive", "StadiumUpgrades" } },
	{ Id = 10, Name = "World Champions", Fame = 5_000_000, Unlocks = { "FranchiseRebirth" } },
}

stages.MaxStage = 3 -- Stage 4+ content isn't built yet; Fame keeps counting past the gate

return stages

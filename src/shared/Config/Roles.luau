--!strict
-- Roles and stats from [[Balance Tables]] → Role stat weights. OVR = role-weighted average of base stats.
-- Stat order everywhere: Aim / Reflexes / GameSense / Teamwork / Clutch / Consistency ([[Key Players]]).

return {
	Stats = { "Aim", "Reflexes", "GameSense", "Teamwork", "Clutch", "Consistency" },
	StatNames = {
		Aim = "Aim",
		Reflexes = "Reflexes",
		GameSense = "Game Sense",
		Teamwork = "Teamwork",
		Clutch = "Clutch",
		Consistency = "Consistency",
	},

	Order = { "Entry", "Support", "Sniper", "Strategist", "Flex" },
	Weights = {
		Entry = { Aim = 0.30, Reflexes = 0.25, GameSense = 0.10, Teamwork = 0.10, Clutch = 0.10, Consistency = 0.15 },
		Support = { Aim = 0.10, Reflexes = 0.10, GameSense = 0.20, Teamwork = 0.35, Clutch = 0.10, Consistency = 0.15 },
		Sniper = { Aim = 0.35, Reflexes = 0.20, GameSense = 0.10, Teamwork = 0.05, Clutch = 0.20, Consistency = 0.10 },
		Strategist = { Aim = 0.05, Reflexes = 0.10, GameSense = 0.40, Teamwork = 0.25, Clutch = 0.05, Consistency = 0.15 },
		Flex = { Aim = 0.17, Reflexes = 0.17, GameSense = 0.17, Teamwork = 0.17, Clutch = 0.16, Consistency = 0.16 },
	},
	Blurb = {
		Entry = "First in. Aim and reflexes.",
		Support = "Sets up the team. Teamwork.",
		Sniper = "Long shots. Aim and clutch.",
		Strategist = "Calls the plays. Game sense.",
		Flex = "A bit of everything.",
	},

	-- Player Level 1–10 badge by OVR ([[Skill Levels & Ratings]]): { min OVR, color hex }.
	Levels = {
		{ 0, "9CA3AF" },
		{ 30, "9CA3AF" },
		{ 38, "4ADE80" },
		{ 45, "4ADE80" },
		{ 52, "FBBF24" },
		{ 59, "FBBF24" },
		{ 66, "FB923C" },
		{ 73, "FB923C" },
		{ 81, "EF4444" },
		{ 89, "EF4444" },
	},
}

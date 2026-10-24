--!strict
-- Aim Arena maps ([[Maps & Map Pool]], [[Map Library]]). Each map leans the title weights (Lean, added then
-- re-normalized) and favors roles (Roles: MapFit = clamp(1 + Σ role bonus of the five / 5, 0.95–1.05)).
-- Pool by stage: the first N maps of Order with InPool. Veto opens with the Stage 3 pool (3 maps = ban, ban, decider);
-- the vault says Stage 4, but a Bo1 veto needs at least 3 maps.

return {
	Title = "AimArena",
	Order = { "NeonDocks", "OldArcade", "SkylineMall", "FrostbyteLabs", "Monorail", "JungleRuins" },
	PoolSize = { 3, 3, 3, 5, 5, 5, 5, 5, 5, 5 }, -- by stage
	VetoStage = 3,

	NeonDocks = {
		Name = "Neon Docks",
		Pace = "Balanced",
		Theme = "Night shipping port: stacked containers, cranes, neon signs",
		Lean = { Aim = 0.05 },
		Roles = { Sniper = 0.10, Entry = -0.03 },
		Color = "22D3EE",
		InPool = true,
	},
	OldArcade = {
		Name = "Old Arcade",
		Pace = "Fast",
		Theme = "Abandoned 80s arcade: glowing cabinets, a ball pit, the prize counter",
		Lean = { Reflexes = 0.05 },
		Roles = { Entry = 0.10, Sniper = -0.05 },
		Color = "E040FB",
		InPool = true,
	},
	SkylineMall = {
		Name = "Skyline Mall",
		Pace = "Balanced",
		Theme = "Rooftop mall at sunset: escalators and a food court mid",
		Lean = { Teamwork = 0.05 },
		Roles = { Flex = 0.05, Support = 0.03 },
		Color = "FBBF24",
		InPool = true,
	},
	FrostbyteLabs = {
		Name = "Frostbyte Labs",
		Pace = "Slow",
		Theme = "Snowy research base: glass corridors, server towers",
		Lean = { GameSense = 0.05 },
		Roles = { Strategist = 0.10, Entry = -0.05 },
		Color = "93C5FD",
		InPool = true,
	},
	Monorail = {
		Name = "Monorail",
		Pace = "Fast",
		Theme = "Future city: a train cuts through mid every 30 s",
		Lean = { Clutch = 0.05 },
		Roles = { Entry = 0.05, Sniper = 0.03 },
		Color = "34D399",
		InPool = true,
	},
	JungleRuins = {
		Name = "Jungle Ruins",
		Pace = "Balanced",
		Theme = "Stone ruins, a waterfall and rope bridges",
		Lean = { Consistency = 0.05 },
		Roles = { Support = 0.05 },
		Color = "65A30D",
		InPool = false, -- rotates in later
	},
}

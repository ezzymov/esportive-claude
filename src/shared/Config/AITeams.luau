--!strict
-- Home-region AI teams ([[Content Catalog]] → AI teams, personalities from [[Rivalries & Storylines]]).
-- Rosters are generated from a seed (one player per role), so the same seed gives the same team everywhere —
-- that's what lets tournaments resolve later with the same result.
--   Bias = OVR offset from the band the event asks for · Lean = stat points on every player · Variance = extra ±
--   per stat (chaos) · Morale = team morale · Favorite = map they never ban · Talk = pre-match trash talk.

return {
	Order = { "ApexCartel", "TurboTigers", "Frostbyte", "GlitchSyndicate", "PhantomLag", "StaticDrift", "CrimsonVortex", "NeonJackals" },

	ApexCartel = {
		Name = "Apex Cartel",
		Tag = "APX",
		Color = "F59E0B",
		Style = "Arrogant champs",
		Bias = 4,
		Lean = { Aim = 3 },
		Morale = 60,
		Favorite = "NeonDocks",
		Talk = { "Garage kids? Cute.", "We've got a trophy cabinet. You've got a garage.", "Try not to cry on stream." },
	},
	TurboTigers = {
		Name = "Turbo Tigers",
		Tag = "TTG",
		Color = "FB923C",
		Style = "Underdog buddies",
		Bias = -4,
		Lean = { Teamwork = 4 },
		Morale = 70, -- weak but always up for it
		Favorite = "SkylineMall",
		Talk = { "We believe!", "Good luck! Not too much though.", "Tigers never quit. Sometimes we nap." },
	},
	Frostbyte = {
		Name = "Frostbyte",
		Tag = "FRB",
		Color = "93C5FD",
		Style = "Tryhard nerds",
		Bias = 1,
		Lean = { GameSense = 8 },
		Morale = 50,
		Favorite = "FrostbyteLabs",
		Talk = { "We ran the numbers.", "Your rotations are 0.4 seconds slow. We checked.", "Statistically, this is over." },
	},
	GlitchSyndicate = {
		Name = "Glitch Syndicate",
		Tag = "GLX",
		Color = "A855F7",
		Style = "Chaos gremlins",
		Bias = 0,
		Variance = 10,
		Morale = 55,
		Favorite = "OldArcade",
		Talk = { "lol lmao gg", "we have no plan and that's the plan", "brb eating cereal" },
	},
	PhantomLag = {
		Name = "Phantom Lag",
		Tag = "PHL",
		Color = "64748B",
		Style = "Silent killers",
		Bias = 2,
		Lean = { Clutch = 8 },
		Morale = 50,
		Favorite = "Monorail",
		Talk = { "...", ".", "…" },
	},
	StaticDrift = {
		Name = "Static Drift",
		Tag = "SDR",
		Color = "22D3EE",
		Style = "Steady grinders",
		Bias = 0,
		Lean = { Consistency = 6 },
		Morale = 50,
		Favorite = "FrostbyteLabs",
		Talk = { "Slow and steady.", "We practice eight hours a day. Do you?", "See you in the final, maybe." },
	},
	CrimsonVortex = {
		Name = "Crimson Vortex",
		Tag = "CRV",
		Color = "EF4444",
		Style = "Aggro rushers",
		Bias = 1,
		Lean = { Reflexes = 6 },
		Morale = 55,
		Favorite = "OldArcade",
		Talk = { "We don't wait. We go.", "Blink and you lose.", "Rush B. Always rush B." },
	},
	NeonJackals = {
		Name = "Neon Jackals", -- "Neon Wolves" in the catalog; renamed so it can't clash with a player's auto-name
		Tag = "NJK",
		Color = "E040FB",
		Style = "Flashy showmen",
		Bias = -1,
		Lean = { Aim = 4, Teamwork = -2 },
		Morale = 60,
		Favorite = "Monorail",
		Talk = { "Hope you brought sunglasses.", "Our highlight reel is longer than your roster.", "Smile for the clip!" },
	},
}

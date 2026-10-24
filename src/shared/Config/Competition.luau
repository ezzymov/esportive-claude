--!strict
-- Compete hub ([[Matches & Tournaments]], [[Screen - Bracket]]): scrims, timed tournaments and leaderboards.
-- Fame per match = base × (their power / yours), clamp 0.5–2 ([[Economy Design]] → FameGain).
-- Tournament prizes: 1st from [[Balance Tables]] → Tournament prize pools; the other places are first guesses.

return {
	Stage = 3, -- the Compete button appears with Local Circuit

	Scrim = {
		Cooldown = 45, -- seconds between scrims; fatigue is the real limit
		BoardRefresh = 300, -- offers reroll every 5 min (and after you play one)
		-- Opponent Team Power = yours (Full gear, first map in the pool) × Power, when the board rolls.
		Offers = {
			{ Id = "Easy", Name = "Warm-up", Power = 0.85 },
			{ Id = "Even", Name = "Even match", Power = 1.0 },
			{ Id = "Hard", Name = "Tough test", Power = 1.15 },
		},
		WinCash = { Base = 400, Min = 200, Max = 800 },
		LossCash = 100,
		WinFame = 40,
		LossFame = 8,
		FameRatioClamp = { 0.5, 2 },
	},

	Tournaments = {
		Order = { "LocalCup" },
		LocalCup = {
			Name = "Local Cup",
			Stage = 3,
			Teams = 8, -- single elimination, 3 rounds
			RoundNames = { "Quarterfinal", "Semifinal", "Final" },
			Registration = 120, -- seconds until round 1 plays
			Wait = 300, -- between your matches
			LockBefore = 60, -- lineup snapshot this long before each round plays
			-- AI teams' OVR band; seeds spread across it. AI fives cover every role and have chemistry, so a typical
			-- Stage 3 roster (avg OVR ~45) sits mid-bracket: the first trophy usually takes a cup or three.
			Ovr = { 36, 50 },
			-- Highest Place ≤ your place wins: 1st, 2nd, 3–4th, 5–8th.
			Prizes = {
				{ Place = 1, Cash = 10_000, Fame = 300, Case = "ProCrate", Trophy = true },
				{ Place = 2, Cash = 4_000, Fame = 150, Case = "RookieCrate" },
				{ Place = 3, Cash = 1_500, Fame = 75 },
				{ Place = 5, Cash = 500, Fame = 25 },
			},
		},
	},
	LogSize = 5, -- finished tournaments kept in Profile.TournamentLog

	Leaderboards = {
		Stage = 3,
		Refresh = 60, -- seconds between OrderedDataStore reads / writes
		Top = 10,
		Boards = {
			{ Id = "Fame", Name = "Fame", Store = "LB_Fame_v1", Icon = "★" },
			{ Id = "Trophies", Name = "Trophies", Store = "LB_Trophies_v1", Icon = "🏆" },
		},
	},
}

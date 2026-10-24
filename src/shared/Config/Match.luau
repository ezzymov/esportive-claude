--!strict
-- [[Match Simulation]] numbers: TeamPower + Elo-style rounds, first to 13 (Aim Arena, MR12, OT first to 4).
-- Maps live in Config/Maps, AI teams in Config/AITeams, scrim + tournament rewards in Config/Competition.

return {
	Title = "AimArena",
	TitleName = "Aim Arena",
	-- Title stat weights for PlayerPower (Aim Arena favors Aim + Reflexes, [[Playable Games]]). Maps adjust these.
	TitleWeights = { Aim = 0.30, Reflexes = 0.25, GameSense = 0.15, Teamwork = 0.10, Clutch = 0.10, Consistency = 0.10 },

	FirstTo = 13,
	Halftime = 12,
	Overtime = { At = 12, FirstTo = 4 },
	K = 1.0, -- pRound = 1 / (1 + 10^((B - A) / 400 × K))
	PRoundClamp = { 0.08, 0.92 },
	Momentum = { Streak = 3, Bonus = 0.03, Max = 0.09 },
	ClutchBonus = 0.10, -- final-round Clutch Moment adds up to +10% pRound (Pickup Games + scrims)
	-- Match-level upset floor ([[Match Simulation]] → M1 measured, option b): with Chance, a match plays with the
	-- power gap × Pull. Off (0) until the 2× target is decided; the upset test prints both.
	UpsetFloor = { Chance = 0, Pull = 0.5 },

	MoraleDefault = 50,
	Synergy = 1.05, -- all 5 roles covered
	Chemistry = { PerMatch = 0.002, Cap = 50 }, -- 1 + min(matchesTogether, 50) × 0.002
	-- Fatigue 0–100: > Threshold = ×Mult in matches. Added per match to each player who played; recovers over time.
	Fatigue = { Threshold = 70, Mult = 0.9, RecoverPerMinute = 2, Add = { Pickup = 2, Scrim = 6, Tournament = 10 } },
	-- Morale 0–100 drifts back to Base. Win/Loss are per player after a match (traits change them).
	Morale = { Base = 50, DriftPerHour = 6, Win = 3, Loss = -4 },
	MapFitClamp = { 0.95, 1.05 },
	MasteryBonus = 0.05, -- MapMastery = 1 + mastery / 100 × MasteryBonus
	Mastery = { Scrim = 2, Match = 1, Max = 100 },

	-- Round detail: winners lose Binomial(4, q) players, q = clamp(Base + Spread × the loser's pRound).
	Deaths = { Base = 0.25, Spread = 0.4, Min = 0.12, Max = 0.55 },
	EntryFirstDuel = 1.5, -- Entry players' weight for the opening kill
	-- Clip Moment base quality ([[Match Simulation]] → Clip Moment triggers). Max = moments kept per match.
	Clips = { Ace = 90, Clutch = 75, ClutchPerExtra = 5, Comeback = 85, ComebackDeficit = 5, Upset = 80, UpsetRatio = 1.5, Flawless = 50, Record = 60, Max = 6 },

	RoundSeconds = 2, -- client playback speed (1×)
	ResolveTimeout = 120, -- server resolves an open match after this many seconds
}

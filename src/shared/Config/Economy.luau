--!strict
-- Economy numbers from [[Economy Design]] / [[Balance Tables]] / [[Progression Guide]].

return {
	Currencies = { "Cash", "Gems", "Shards", "Fame", "Followers", "LegacyPoints" },
	NeverSpent = { Fame = true }, -- Fame is a gate, never a cost

	-- Station income per second, before multipliers. Tier 1 is every Stage 1 desk.
	StationTiers = {
		{ Income = 1, Price = 0 },
		{ Income = 2.5, Price = 100 },
		{ Income = 6, Price = 500 },
		{ Income = 15, Price = 2_500 },
		{ Income = 40, Price = 12_000 },
		{ Income = 100, Price = 60_000 },
		{ Income = 250, Price = 300_000 },
		{ Income = 650, Price = 1_500_000 },
	},
	-- StationIncome/s = base × (1 + OVR / OvrDivisor) for each seated player ([[Economy Design]]).
	-- Your own (Founder) station only pays while you sit at it; hired players' stations always pay.
	OvrDivisor = 100,

	IncomeTick = 1, -- seconds between income payouts

	-- OfflineIncome = min(cap, elapsed) × rate × income/s. Offline counts hired stations only (you aren't seated).
	Offline = { CapSeconds = 4 * 3600, Rate = 0.5, MinSeconds = 60 },

	StarterGift = 50, -- Aunt Dee's bill on the [[Screen - Starter Letter]]
}

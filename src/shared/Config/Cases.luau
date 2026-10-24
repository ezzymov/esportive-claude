--!strict
-- Cases ([[Case Unboxing]], [[Case Library]], odds from [[Balance Tables]] → Case drop tables). Every number here is
-- shown to players in the Odds panel, so the panel and the server roll read the same table (Shared/CaseRoll).
-- Paid-for-Robux cases are NOT here on purpose: the paid-crate policy is still open ([[Monetization]]).
--
-- A case: { Name, Price, Currency ("Cash" | "Gems"), Stage (buy from), Odds (rarity weights, %), Types?, Guaranteed?,
--           Hidden? (never sold, only granted), Icon, Color, Look }. Odds must sum to 100.

return {
	Order = { "StarterCrate", "RookieCrate", "ProCrate" }, -- shelf order in the Shop / Inventory

	Counts = { 1, 5, 10 }, -- Open ×1 / ×5 / ×10
	CountStage = { [1] = 1, [5] = 2, [10] = 4 }, -- ×10 from Stage 4 (the Fast Open pass comes with monetization)

	-- Drop type split for every case ([[Balance Tables]]: Player 40 · Part 35 · Cosmetic 15 · Booster 7 · Staff 3).
	-- Cosmetics are Accessories for now; Boosters and Staff aren't built, so their 10% goes to Player.
	-- A type with nothing at the rolled rarity drops out and the rest are re-weighted (no Common parts exist).
	Types = { Player = 50, Part = 35, Accessory = 15 },

	-- Pity ([[Economy Design]]): the Nth open without that rarity or better is guaranteed it. Counters only count opens
	-- of cases that can drop the rarity, so cheap crates can't bank pity for expensive ones. One family (Core) for now.
	Pity = { Epic = 10, Legendary = 50, Mythic = 300 },

	-- Duplicates → Shards. A part is a duplicate once you own one per desk; an accessory once you own one per roster
	-- player; a player once the roster is full.
	Shards = { Common = 5, Uncommon = 12, Rare = 30, Epic = 80, Legendary = 250, Mythic = 1000 },

	-- Stage 2 beat: a free Rookie Crate every 30 min (real time, one banked at most).
	Free = { CaseId = "RookieCrate", Every = 30 * 60, Stage = 2 },

	SaveAtRarity = "Legendary", -- forced save when an open drops this or better

	-- Stage 1 FTUE crate: shown as "Rookie Crate", always one Rare player, rolled when granted (no reroll on rejoin).
	StarterCrate = {
		Name = "Rookie Crate",
		Guaranteed = "Rare",
		Types = { Player = 100 },
		Hidden = true,
		Icon = "🎁",
		Color = "3B82F6",
		Look = "Cardboard box with tape and a sticker",
	},

	RookieCrate = {
		Name = "Rookie Crate",
		Price = 500,
		Currency = "Cash",
		Stage = 2,
		Odds = { Common = 60, Uncommon = 28, Rare = 10, Epic = 2, Legendary = 0, Mythic = 0 },
		Icon = "📦",
		Color = "3B82F6",
		Look = "Cardboard box with tape and a sticker",
	},

	ProCrate = {
		Name = "Pro Crate",
		Price = 5_000,
		Currency = "Cash",
		Stage = 4, -- [[Case Library]]; the Local Cup winner gets one earlier
		Odds = { Common = 25, Uncommon = 35, Rare = 28, Epic = 10, Legendary = 2, Mythic = 0 },
		Icon = "🧳",
		Color = "22D3EE",
		Look = "Metal flight case, cyan trim",
	},
}

--!strict
-- Tech Shop ([[Screen - Tech Shop]], [[PC Setups]], [[Accessories]]). Stock rotates every Refresh seconds; the same
-- window shows the same stock on every server (seeded by the window number and your stage).
-- Part prices = Parts.Tiers[tier].Price; accessory prices = Accessories.TierPrice; station tiers = Economy.StationTiers.
-- Lists are by stage (index = stage; the last entry covers later stages).

return {
	Stage = 2, -- the Tech Shop opens with Café Rookies
	Refresh = 10 * 60,
	PartSlots = 6, -- parts in stock at once
	AccessorySlots = 4,

	PartTiers = { {}, { "Budget", "Mid" }, { "Budget", "Mid", "HighEnd" } },
	-- Common–Rare plain models; a Rare at Stage 2 shows "Full bonus at Stage 3".
	AccessoryTiers = { {}, { "Common", "Uncommon", "Rare" }, { "Common", "Uncommon", "Rare" } },
	-- Highest station income tier you can buy. Tier 2 = $100 → $2.5/s, tier 3 = $500 → $6/s, tier 4 = $2.5k → $15/s.
	MaxStationTier = { 1, 3, 4, 5, 6, 7, 8, 8, 8, 8 },
}

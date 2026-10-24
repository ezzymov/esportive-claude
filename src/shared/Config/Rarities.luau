--!strict
-- Player rarity table from [[Balance Tables]]. Colors live in Theme.Rarity. Salary is per week.

return {
	Order = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" },

	Common = { Ovr = { 30, 45 }, Potential = { 40, 60 }, Salary = 900, TraitChance = 0.10, BaseValue = 300 },
	Uncommon = { Ovr = { 40, 55 }, Potential = { 50, 70 }, Salary = 2_000, TraitChance = 0.25, BaseValue = 1_200 },
	Rare = { Ovr = { 50, 65 }, Potential = { 60, 80 }, Salary = 4_000, TraitChance = 0.50, BaseValue = 5_000 },
	Epic = { Ovr = { 60, 75 }, Potential = { 70, 88 }, Salary = 7_000, TraitChance = 0.80, BaseValue = 25_000 },
	Legendary = { Ovr = { 72, 86 }, Potential = { 82, 95 }, Salary = 12_000, TraitChance = 1.00, BaseValue = 150_000 },
	Mythic = { Ovr = { 85, 95 }, Potential = { 92, 99 }, Salary = 18_000, TraitChance = 1.00, BaseValue = 1_000_000, UniqueTrait = true },
	-- Case pity lives in Config/Cases.
}

--!strict
-- Free-agent board ([[Player Hiring]]) + the Stage 1 first-hire guardrail ([[Stage 1 - Garage Squad]] → Pacing guardrails).

return {
	Refresh = 600, -- seconds; the generated listings reroll every 10 min
	Generated = 2, -- generated Commons on the board next to the featured key player
	GeneratedRarity = "Common",
	-- Price of a generated listing = BaseValue (Rarities) + (OVR - min OVR) × PerOvr
	PerOvr = 10,

	Featured = {
		KeyId = "Rusty",
		Price = 250,
		DiscountPrice = 100,
		DiscountAfter = 12 * 60, -- play seconds with no hire → price drop + Aunt Dee text
	},

	MaxDistance = 12, -- from the cork board

	-- Roster size cap by stage ([[Player Hiring]]: active five + a bench of up to 3). Stage 1: 3 desks + the crate's Rare.
	-- A case player that doesn't fit becomes Shards.
	RosterMax = { 4, 8, 8, 8, 8, 8, 9, 9, 10, 10 },
	ActiveSize = 5,
}

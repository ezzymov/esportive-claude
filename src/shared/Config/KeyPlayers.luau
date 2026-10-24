--!strict
-- Hand-made key players ([[Key Players]]). Fixed name/role/trait/look; each copy rolls stats ±StatJitter around Stats.
-- Stats order: Aim / Reflexes / GameSense / Teamwork / Clutch / Consistency. M1 ships Rusty only.

return {
	StatJitter = 3,
	PotentialBand = { 8, 14 }, -- Potential = OVR + this range

	Rusty = {
		Name = "Rusty",
		Rarity = "Common",
		Role = "Support",
		Stats = { 38, 35, 42, 48, 30, 40 },
		Trait = "ClassClown",
		Vibe = "Goofball",
		Look = { Skin = "C99E7B", Shirt = "E07A2E", Pants = "3B4252", Hair = "8A4B2A" }, -- oversized orange hoodie
		Bio = "Your friend from school. Dad's old headset, held together with duct tape.",
		Country = { "Canada", "Halifax" },
		Age = 17,
	},
}

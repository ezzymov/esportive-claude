--!strict
-- Team identity limits + color presets ([[Team Identity]], [[Screen - Team Creator]], [[Jersey Progression]] tier 1).

return {
	NameMax = 20,
	TagMin = 3,
	TagMax = 4,

	-- 12 presets; saved as an index so the palette can be retuned without touching saves.
	Colors = {
		"22D3EE", "E040FB", "34D399", "FBBF24", "F87171", "3B82F6",
		"A855F7", "F97316", "F8FAFC", "64748B", "14B8A6", "EC4899",
	},
	DefaultPrimary = 1,

	-- Jersey tier 1 (Garage, HQ Lv 0): "Own Tees". The Founder's tee color is pickable from minute one;
	-- by default it follows the team color.
	Garments = {
		OwnTee = { Name = "Own Tee", HqLevel = 0 },
	},
}

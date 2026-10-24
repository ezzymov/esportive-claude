--!strict
-- Mirrors [[UI Style Guide]]: palette, rarity colors, type scale, spacing, components, motion. Edit both together.

local function hex(h: string): Color3
	return Color3.fromHex(h)
end

local GOTHAM = "rbxasset://fonts/families/GothamSSm.json"

return {
	Colors = {
		Bg = hex("0F1426"), -- background panel
		Panel = hex("1A2140"), -- panel raised
		Accent = hex("22D3EE"), -- primary (cyan)
		Accent2 = hex("E040FB"), -- secondary (magenta)
		Success = hex("34D399"),
		Warning = hex("FBBF24"),
		Danger = hex("F87171"),
		Text = hex("F8FAFC"),
		TextMuted = hex("94A3B8"),
		Shadow = hex("000000"),
	},

	Rarity = {
		Common = hex("9CA3AF"),
		Uncommon = hex("4ADE80"),
		Rare = hex("3B82F6"),
		Epic = hex("A855F7"),
		Legendary = hex("F59E0B"),
		Mythic = hex("EF4444"), -- shimmering gradient in card frames
		Founder = hex("FACC15"), -- unique gold Founder frame ([[Founder (You)]]), not a normal rarity
	},

	Fonts = {
		Heading = Font.new(GOTHAM, Enum.FontWeight.Heavy), -- GothamBlack
		Bold = Font.new(GOTHAM, Enum.FontWeight.Bold), -- GothamBold (numbers)
		Body = Font.new(GOTHAM, Enum.FontWeight.Medium), -- GothamMedium
		Hand = Font.fromEnum(Enum.Font.IndieFlower), -- Starter Letter handwriting (placeholder pick)
		Marker = Font.fromEnum(Enum.Font.PermanentMarker), -- bedsheet banner spray paint
	},

	-- Type scale at 1080p; UIScale handles other screens.
	Type = {
		Display = 48,
		H1 = 32,
		H2 = 24,
		Body = 18,
		Caption = 14,
		Number = 20, -- 20–40
	},

	-- Base unit 4 px. Use only these.
	Space = { XS = 4, S = 8, M = 12, L = 16, XL = 24, XXL = 32, XXXL = 48 },
	Radius = { S = 8, M = 12, L = 20 },
	Stroke = { Thickness = 2, Transparency = 0.4 },
	PanelPadding = { Desktop = 16, Mobile = 12 },
	TouchMin = 44,

	Components = {
		PrimaryButton = { Height = 56, MinWidth = 160 },
		SecondaryButton = { Height = 48 },
		CurrencyPill = { Height = 40, Gap = 8 },
		RailButton = { Desktop = 64, Mobile = 52 },
		PlayerCard = { Width = 140, Height = 190 },
		ProgressBar = { Height = 12 },
		Toast = { Width = 360, Height = 64, Hold = 3, Max = 2 },
	},

	Tween = {
		Hover = 0.1,
		Press = 0.08,
		Open = 0.25, -- Back easing
		Close = 0.15,
		CountUp = 0.4,
		Pulse = 0.15,
		PulseScale = 1.08,
		Fill = 0.3,
	},

	-- UIScale = clamp(short screen side / DesignHeight, Min, Max). Min keeps 64 px rail buttons ≥ 44 px touch targets.
	Scale = { DesignHeight = 1080, Min = 0.75, Max = 1.25 },

	-- Placeholder glyphs until the icon set is uploaded ([[UI Style Guide]] → Iconography).
	Icons = { Cash = "$", Gems = "💎", Fame = "★", Followers = "👥" },

	-- Rail button colors ([[Screen - Main HUD]] → The 9 permanent buttons).
	Rail = { Roster = hex("3B82F6"), Phone = hex("334155") },

	-- Start screen tip line, rotates every 4 s ([[Screen - Start]]).
	Tips = {
		"Sit at your desk to earn while you practice.",
		"Hired players earn even when you walk away.",
		"Wins bring Fame. Fame unlocks new stages.",
		"The arcade cabinet trains your aim.",
		"Neighbors pay well for a quick PC repair.",
	},

	Textures = { Stud = "" }, -- upload Style Guide/Roblox_Texture_stud-tile.png and paste the asset id

	-- Placeholder sounds (Studio built-ins) until the audio pass ([[Art & Audio Direction]]). Swap ids here.
	Sounds = {
		Sting = "rbxasset://sounds/electronicpingshort.wav", -- rarity sting, pitch rises per tier (StingSpeed)
		Cheer = "rbxasset://sounds/victory.wav", -- crowd cheer, volume scales with rarity (CheerVolume)
		Drop = "rbxasset://sounds/bass.wav",
		Shake = "rbxasset://sounds/clickfast.wav",
		Pop = "rbxasset://sounds/snap.wav",
		Beam = "rbxasset://sounds/flashbulb.wav",
		Boom = "rbxasset://sounds/impact_explosion_03.mp3", -- Mythic
		Buy = "rbxasset://sounds/electronicpingshort.wav",
	},
	StingSpeed = { Common = 0.8, Uncommon = 0.95, Rare = 1.1, Epic = 1.3, Legendary = 1.5, Mythic = 1.8 },
	CheerVolume = { Common = 0, Uncommon = 0, Rare = 0.25, Epic = 0.45, Legendary = 0.7, Mythic = 1 },

	-- Rarity telegraph order for the case glow.
	RarityOrder = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" },
}

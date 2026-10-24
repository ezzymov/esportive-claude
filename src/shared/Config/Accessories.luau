--!strict
-- Accessories ([[Accessories]]): personal gear, one stat each, flat bonus by tier. OVR ignores gear;
-- cards show it separately ("Aim 28 +1"). Gear cap +12 per stat.
-- M1: the Founder starts with the taped mouse (no bonus); the Stage 1 mouse pad ($150 = Common Tech Shop price)
-- swaps it for a plain Common mouse.
-- M2: items are plain models (no seed/finish yet). Owned copies are counts in Inventory.Accessories; a card's
-- Accessories[slot] holds the item Id.

return {
	GearCapPerStat = 12,
	TierOrder = { "Starter", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" },
	TierBonus = { Starter = 0, Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 6, Mythic = 8 },
	TierPrice = { Common = 150, Uncommon = 1_200, Rare = 10_000 }, -- Tech Shop; Epic+ come from cases

	-- Stage tier cap: the bonus counts only up to this tier at your stage ("Full bonus at Stage N").
	-- Stage 1 is the Founder-mouse exception (Common).
	StageCap = { "Common", "Uncommon", "Rare", "Epic", "Epic", "Legendary", "Legendary", "Mythic", "Mythic", "Mythic" },

	SlotOrder = { "Mouse", "Keyboard", "Headset", "Sleeve", "Glasses", "Charm" },
	Slots = {
		Mouse = { Stat = "Aim", Stage = 2, Icon = "🖱" },
		Keyboard = { Stat = "Consistency", Stage = 2, Icon = "⌨" },
		Headset = { Stat = "Teamwork", Stage = 2, Icon = "🎧" },
		Sleeve = { Stat = "Reflexes", Stage = 3, Icon = "💪" },
		Glasses = { Stat = "GameSense", Stage = 3, Icon = "👓" },
		Charm = { Stat = "Clutch", Stage = 3, Icon = "🍀" },
	},

	Items = {
		TapedMouse = { Name = "Taped Mouse", Slot = "Mouse", Stat = "Aim", Tier = "Starter", Brand = "Clikk" },
		-- Mouse · Aim
		ClikkBasic = { Name = "Clikk Basic", Slot = "Mouse", Stat = "Aim", Tier = "Common", Brand = "Clikk" },
		RustyClicker = { Name = "Rusty Clicker", Slot = "Mouse", Stat = "Aim", Tier = "Common", Brand = "Clikk" },
		ClikkGlide = { Name = "Clikk Glide", Slot = "Mouse", Stat = "Aim", Tier = "Uncommon", Brand = "Clikk" },
		ClikkFeather2 = { Name = "Clikk Feather 2", Slot = "Mouse", Stat = "Aim", Tier = "Rare", Brand = "Clikk" },
		ClikkComet = { Name = "Clikk Comet Tail", Slot = "Mouse", Stat = "Aim", Tier = "Epic", Brand = "Clikk" },
		ClikkNebula = { Name = "Clikk Nebula", Slot = "Mouse", Stat = "Aim", Tier = "Legendary", Brand = "Clikk" },
		-- Keyboard · Consistency
		ClikkTypist = { Name = "Clikk Typist", Slot = "Keyboard", Stat = "Consistency", Tier = "Common", Brand = "Clikk" },
		ClikkTactile60 = { Name = "Clikk Tactile 60", Slot = "Keyboard", Stat = "Consistency", Tier = "Uncommon", Brand = "Clikk" },
		ClikkSwitchblade = { Name = "Clikk Switchblade", Slot = "Keyboard", Stat = "Consistency", Tier = "Rare", Brand = "Clikk" },
		ClikkPixelPal = { Name = "Clikk Pixel Pal", Slot = "Keyboard", Stat = "Consistency", Tier = "Epic", Brand = "Clikk" },
		ClikkMonolith = { Name = "Clikk Monolith", Slot = "Keyboard", Stat = "Consistency", Tier = "Legendary", Brand = "Clikk" },
		-- Headset · Teamwork
		PulseBuds = { Name = "Pulse Buds", Slot = "Headset", Stat = "Teamwork", Tier = "Common", Brand = "PulseAudio" },
		PulseEcho = { Name = "Pulse Echo", Slot = "Headset", Stat = "Teamwork", Tier = "Uncommon", Brand = "PulseAudio" },
		PulseHalo = { Name = "Pulse Halo", Slot = "Headset", Stat = "Teamwork", Tier = "Rare", Brand = "PulseAudio" },
		PulseNova = { Name = "Pulse Nova", Slot = "Headset", Stat = "Teamwork", Tier = "Epic", Brand = "PulseAudio" },
		PulseZenith = { Name = "Pulse Zenith", Slot = "Headset", Stat = "Teamwork", Tier = "Legendary", Brand = "PulseAudio" },
		-- Arm Sleeve · Reflexes
		GripTechSleeve = { Name = "GripTech Sleeve", Slot = "Sleeve", Stat = "Reflexes", Tier = "Common", Brand = "GripTech" },
		GripTechFlex = { Name = "GripTech Flex", Slot = "Sleeve", Stat = "Reflexes", Tier = "Uncommon", Brand = "GripTech" },
		GripTechPro = { Name = "GripTech Pro", Slot = "Sleeve", Stat = "Reflexes", Tier = "Rare", Brand = "GripTech" },
		GripTechCarbon = { Name = "GripTech Carbon", Slot = "Sleeve", Stat = "Reflexes", Tier = "Epic", Brand = "GripTech" },
		GripTechPhantom = { Name = "GripTech Phantom", Slot = "Sleeve", Stat = "Reflexes", Tier = "Legendary", Brand = "GripTech" },
		-- Glasses · Game Sense
		BlueShiftBasics = { Name = "BlueShift Basics", Slot = "Glasses", Stat = "GameSense", Tier = "Common", Brand = "BlueShift" },
		BlueShiftLenses = { Name = "BlueShift Lenses", Slot = "Glasses", Stat = "GameSense", Tier = "Uncommon", Brand = "BlueShift" },
		BlueShiftVision = { Name = "BlueShift Vision", Slot = "Glasses", Stat = "GameSense", Tier = "Rare", Brand = "BlueShift" },
		BlueShiftOracle = { Name = "BlueShift Oracle", Slot = "Glasses", Stat = "GameSense", Tier = "Epic", Brand = "BlueShift" },
		BlueShiftPrism = { Name = "BlueShift Prism", Slot = "Glasses", Stat = "GameSense", Tier = "Legendary", Brand = "BlueShift" },
		-- Lucky Charm · Clutch
		LuckyDiceCharm = { Name = "Lucky Dice Charm", Slot = "Charm", Stat = "Clutch", Tier = "Common" },
		CloverCharm = { Name = "Four-Leaf Clover", Slot = "Charm", Stat = "Clutch", Tier = "Uncommon" },
		HorseshoeCharm = { Name = "Tiny Horseshoe", Slot = "Charm", Stat = "Clutch", Tier = "Rare" },
		GoldenCatCharm = { Name = "Golden Cat", Slot = "Charm", Stat = "Clutch", Tier = "Epic" },
		PhoenixCharm = { Name = "Phoenix Feather", Slot = "Charm", Stat = "Clutch", Tier = "Legendary" },
	},
}

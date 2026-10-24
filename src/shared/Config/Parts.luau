--!strict
-- PC part tiers ([[Balance Tables]]) and parts ([[Content Catalog]]). Brands in Config/Brands.
-- Saves store part Ids only; never delete an Id, mark it Retired = true instead.
-- Dusty Starter is what an empty slot counts as, so it has no items.

return {
	Slots = { "CPU", "GPU", "Monitor", "Chair", "Desk" }, -- mouse/keyboard/headset are Accessories
	Icons = { CPU = "🧠", GPU = "🎞", Monitor = "🖥", Chair = "💺", Desk = "🌈" }, -- placeholder glyphs

	-- partMult = Σ tier StatMult × SlotWeight (+ set bonuses), so a full station of one tier = that tier's StatMult.
	SlotWeight = { CPU = 0.30, GPU = 0.25, Monitor = 0.25, Chair = 0.10, Desk = 0.10 },

	Tiers = {
		Order = { "DustyStarter", "Budget", "Mid", "HighEnd", "Pro", "Prototype" },
		DustyStarter = { Name = "Dusty Starter", Rarity = "Common", StatMult = 0.00, Price = 0 },
		Budget = { Name = "Budget", Rarity = "Uncommon", StatMult = 0.03, Price = 200 },
		Mid = { Name = "Mid", Rarity = "Rare", StatMult = 0.07, Price = 2_000 },
		HighEnd = { Name = "High-End", Rarity = "Epic", StatMult = 0.12, Price = 20_000 },
		Pro = { Name = "Pro", Rarity = "Legendary", StatMult = 0.18, Price = 200_000 },
		Prototype = { Name = "Prototype", Rarity = "Mythic", StatMult = 0.25, Price = nil }, -- craft / Legend Crate
	},

	SetBonus = { ThreeSameBrand = 0.03, FullStation = 0.07 }, -- partMult is 0 in Pure mode (Ranked)

	Items = {
		-- CPU · NovaCore
		NovaCoreN3 = { Name = "NovaCore N3", Slot = "CPU", Tier = "Budget", Brand = "NovaCore" },
		NovaCoreN5 = { Name = "NovaCore N5", Slot = "CPU", Tier = "Mid", Brand = "NovaCore" },
		NovaCoreN7X = { Name = "NovaCore N7X", Slot = "CPU", Tier = "HighEnd", Brand = "NovaCore" },
		NovaCoreN9 = { Name = "NovaCore N9 Pro", Slot = "CPU", Tier = "Pro", Brand = "NovaCore" },
		NovaCoreQuantumX = { Name = "NovaCore Quantum X", Slot = "CPU", Tier = "Prototype", Brand = "NovaCore" },
		-- GPU · Vektor
		VektorEmber30 = { Name = "Vektor Ember 30", Slot = "GPU", Tier = "Budget", Brand = "Vektor" },
		VektorBlaze60 = { Name = "Vektor Blaze 60", Slot = "GPU", Tier = "Mid", Brand = "Vektor" },
		VektorFlare80 = { Name = "Vektor Flare 80", Slot = "GPU", Tier = "HighEnd", Brand = "Vektor" },
		VektorInferno90 = { Name = "Vektor Inferno 90", Slot = "GPU", Tier = "Pro", Brand = "Vektor" },
		-- Monitor · Hexaview
		Hexaview75 = { Name = "Hexaview 75", Slot = "Monitor", Tier = "Budget", Brand = "Hexaview" },
		Hexaview144 = { Name = "Hexaview 144", Slot = "Monitor", Tier = "Mid", Brand = "Hexaview" },
		Hexaview240 = { Name = "Hexaview 240", Slot = "Monitor", Tier = "HighEnd", Brand = "Hexaview" },
		HexaviewBlade360 = { Name = "Hexaview Blade 360", Slot = "Monitor", Tier = "Pro", Brand = "Hexaview" },
		-- Chair · ThroneWorks
		ThroneWorksSquire = { Name = "ThroneWorks Squire", Slot = "Chair", Tier = "Budget", Brand = "ThroneWorks" },
		ThroneWorksKnight = { Name = "ThroneWorks Knight", Slot = "Chair", Tier = "Mid", Brand = "ThroneWorks" },
		ThroneWorksRoyal = { Name = "ThroneWorks Royal", Slot = "Chair", Tier = "HighEnd", Brand = "ThroneWorks" },
		ThroneWorksEmperor = { Name = "ThroneWorks Emperor", Slot = "Chair", Tier = "Pro", Brand = "ThroneWorks" },
		-- Desk · Lumora (RGB)
		LumoraGlow = { Name = "Lumora Glow Desk", Slot = "Desk", Tier = "Budget", Brand = "Lumora" },
		LumoraNeonStrip = { Name = "Lumora Neon Strip", Slot = "Desk", Tier = "Mid", Brand = "Lumora" },
		LumoraPrism = { Name = "Lumora Prism", Slot = "Desk", Tier = "HighEnd", Brand = "Lumora" },
		LumoraAurora = { Name = "Lumora Aurora", Slot = "Desk", Tier = "Pro", Brand = "Lumora" },
	},
}

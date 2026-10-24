--!strict
-- Hub + plot geometry from [[World Layout & Presentation]] and the Garage era of [[HQ Era Visual Guide]].
-- Plot frame: origin = front-center of the plot on the road edge; local +Z points at the road, -Z goes back.
-- Garage frame: origin = garage floor center; +Z = roll-up door (road side). Anchor yaw: 0 = faces -Z (back wall).

return {
	PlotCount = 6,
	PlotSize = 256,
	PlotFrontRadius = 320, -- plot front edge distance from the plaza center
	Road = { Inner = 280, Outer = 320, Segments = 36 },
	PlazaRadius = 120,
	GroundSize = 1400,

	-- Zone depths from the road (studs): Frontage 32 · A 72 · B 80 · C 72.
	Zones = { { "Frontage", 32 }, { "A", 72 }, { "B", 80 }, { "C", 72 } },

	-- Districts sit between plots (after plot i, before plot i+1). Unbuilt ones show "Coming soon".
	DistrictRadius = 385,
	Districts = {
		{ Name = "Streamr Tower", Opens = "Stage 4" },
		{ Name = "Tournament Hall", Opens = "Stage 3" },
		{ Name = "Trading Post", Opens = "Stage 4" },
		{ Name = "Arcade Corner", Opens = nil, Built = true }, -- Aim Trainer cabinet open to everyone
		{ Name = "Sponsor Street", Opens = "Stage 3" },
		{ Name = "Season Gate", Opens = nil },
	},

	Garage = {
		Offset = Vector3.new(-100, 0, -48), -- garage center in plot space (front-left corner of Zone A)
		Inside = Vector3.new(40, 14, 32), -- width, wall height, depth
		DoorWidth = 14,
		DoorHeight = 11,

		-- Anchors in garage space: { position, yaw degrees }.
		Anchors = {
			FounderDesk = { Vector3.new(-12, 0, 7), 0 },
			Desk2 = { Vector3.new(-8, 0, -5), 0 },
			Desk3 = { Vector3.new(6, 0, -5), 0 },
			Pad_Mouse = { Vector3.new(-3, 0, 10), 0 },
			Pad_Desk2 = { Vector3.new(-8, 0, -2), 0 },
			Pad_Desk3 = { Vector3.new(6, 0, -2), 0 },
			FreeAgentBoard = { Vector3.new(19.6, 6, 5), 90 }, -- cork board on the right wall
			Whiteboard = { Vector3.new(19.6, 6, -7), 90 },
			TechBench = { Vector3.new(13, 0, 13), 180 },
			AimCabinet = { Vector3.new(-16, 0, -12), 180 },
			Couch = { Vector3.new(-2, 0, -13), 180 },
			Boxes = { Vector3.new(14, 0, -12.5), 0 },
			Spawn = { Vector3.new(0, 0, 28), 0 },
			CashCollector = { Vector3.new(-12, 0, 44), 0 },
			Mailbox = { Vector3.new(12, 0, 44), 0 },
			VanStop = { Vector3.new(10, 0, 62), 90 },
			TrophyShelf = { Vector3.new(6, 6, -15.6), 0 }, -- back wall, Stage 3
			-- Café annex (Stage 2), built against the garage's right wall: x 21–57, z −16–16, own door + awning.
			Desk4 = { Vector3.new(30, 0, -9), 0 },
			Desk5 = { Vector3.new(42, 0, -9), 0 },
			Pad_Desk4 = { Vector3.new(30, 0, -6), 0 },
			Pad_Desk5 = { Vector3.new(42, 0, -6), 0 },
			TechCounter = { Vector3.new(51, 0, 6), 90 },
			ReactionCabinet = { Vector3.new(25, 0, 9), 270 },
			CaseVault = { Vector3.new(52, 0, -11), 0 },
		},
		Cafe = { Center = Vector3.new(39, 0, 0), Inside = Vector3.new(36, 13, 32), DoorWidth = 8 },
	},

	-- Garage era palette ([[HQ Era Visual Guide]] → Materials & palette).
	Palette = {
		Concrete = "6B6B6B",
		Plywood = "B08A5A",
		Rust = "8A4B2A",
		FadedPaint = "9DB4C0",
		Bulb = "FFC27A",
		Road = "2B2F3A",
		Sidewalk = "8A8F99",
		Grass = "3F5B35",
		Dirt = "6E5A43",
		Plaza = "4B5563",
	},
}

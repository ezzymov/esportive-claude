--!strict
-- Garage era greybox ([[HQ Era Visual Guide]] → 1. Garage). Static shell + props for every plot; dynamic pieces
-- (banner, pads, desks 2–3, NPCs) are built per owner by PlotService. Parts that tutorial arrows or prompts target
-- carry an "Anchor" attribute (names in Config/World.Garage.Anchors).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Build = require(ReplicatedStorage.Shared.Build)
local PlotFrame = require(ReplicatedStorage.Shared.PlotFrame)
local Generator = require(ReplicatedStorage.Shared.Generator)
local World = require(ReplicatedStorage.Shared.Config.World)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)

local Garage = {}

local P = World.Palette
local G = World.Garage

export type Refs = {
	Model: Model,
	Origin: CFrame,
	Dynamic: Folder,
	Door: BasePart,
	FounderSeat: Seat,
	FounderMouse: BasePart,
	Monitor: TextLabel,
	Board: TextLabel,
	Whiteboard: TextLabel,
	BenchPC: BasePart,
	CabinetScreen: TextLabel,
}

local function anchor(part: BasePart, name: string): BasePart
	part:SetAttribute("Anchor", name)
	return part
end

-- Garage-space CFrame → world.
local function at(origin: CFrame, pos: Vector3, yaw: number?): CFrame
	return PlotFrame.Garage(origin) * CFrame.new(pos) * CFrame.Angles(0, math.rad(yaw or 0), 0)
end

local function anchorCF(origin: CFrame, name: string): CFrame
	return PlotFrame.Anchor(origin, name)
end

-- A table with four legs. top = height of the tabletop surface.
local function table_(parent: Instance, name: string, cf: CFrame, size: Vector3, color: string, top: number)
	Build.Part(parent, name, Vector3.new(size.X, 0.4, size.Z), cf * CFrame.new(0, top - 0.2, 0), color, { Material = Enum.Material.WoodPlanks })
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			Build.Part(parent, "Leg", Vector3.new(0.3, top - 0.4, 0.3), cf * CFrame.new(sx * (size.X / 2 - 0.3), (top - 0.4) / 2, sz * (size.Z / 2 - 0.3)), "4B5563")
		end
	end
end

local function seat(parent: Instance, name: string, cf: CFrame, taped: boolean): Seat
	local s = Instance.new("Seat")
	s.Name = name
	s.Anchored = true
	s.Size = Vector3.new(2.2, 0.4, 2.2)
	s.CFrame = cf * CFrame.new(0, 1.8, 0)
	s.Color = Color3.fromHex(if taped then "475569" else "6B7280")
	s.Material = Enum.Material.Fabric
	s.TopSurface = Enum.SurfaceType.Smooth
	s.Parent = parent
	Build.Part(parent, "Back", Vector3.new(2.2, 2.4, 0.3), cf * CFrame.new(0, 3.2, 1.05), s.Color, { Material = Enum.Material.Fabric })
	Build.Part(parent, "Stem", Vector3.new(0.3, 1.6, 0.3), cf * CFrame.new(0, 0.8, 0), "1F2937")
	if taped then
		Build.Part(parent, "Tape", Vector3.new(2.3, 0.45, 0.5), cf * CFrame.new(0, 1.82, 0.2), "D6D3D1", { CanCollide = false })
		Build.Part(parent, "Tape", Vector3.new(0.5, 2.5, 0.35), cf * CFrame.new(0.4, 3.2, 1.05), "D6D3D1", { CanCollide = false })
	end
	return s
end

-- One PC station: table, monitor (with screen label), tower, keyboard, mouse, chair. cf = desk center on the floor.
function Garage.Station(parent: Instance, cf: CFrame, style: string): (Seat, TextLabel, BasePart)
	local color = if style == "Founder" then P.Plywood elseif style == "Card" then "57534E" elseif style == "Cafe" then "7A5230" else "A16207"
	table_(parent, "Desk", cf, Vector3.new(6, 0, 3), color, 3)
	if style == "Door" then
		-- Desk 3: a door laid on two sawhorses.
		Build.Part(parent, "DoorKnob", Vector3.new(0.3, 0.3, 0.3), cf * CFrame.new(2.6, 3.15, 1.2), "FBBF24")
	end
	local books = Build.Part(parent, "Books", Vector3.new(1.8, 0.6, 1.2), cf * CFrame.new(0, 3.3, -0.8), "7C2D12")
	local monitor = Build.Part(parent, "Monitor", Vector3.new(2.6, 1.8, 0.25), books.CFrame * CFrame.new(0, 1.2, 0), "111827")
	local screenLabel = Build.Text(monitor, Enum.NormalId.Back, "", { TextColor3 = Theme.Colors.Accent, BackgroundTransparency = 0, BackgroundColor3 = Color3.fromHex("0B1020") })
	Build.Part(parent, "Tower", Vector3.new(1.1, 2.2, 2.2), cf * CFrame.new(2.3, 4.1, -0.3), if style == "Founder" then "E7E5E4" else "374151")
	Build.Part(parent, "Keyboard", Vector3.new(2, 0.15, 0.6), cf * CFrame.new(-0.2, 3.08, 0.6), "1F2937")
	local mouse = Build.Part(parent, "Mouse", Vector3.new(0.35, 0.2, 0.5), cf * CFrame.new(1.2, 3.1, 0.6), if style == "Founder" then "D6D3D1" else "1F2937")
	local chair = seat(parent, "Seat", cf * CFrame.new(0, 0, 2.6), style == "Founder")
	return chair, screenLabel, mouse
end

local function shell(m: Model, origin: CFrame)
	local w, h, d = G.Inside.X, G.Inside.Y, G.Inside.Z
	local half, door = w / 2, G.DoorWidth
	Build.Part(m, "Floor", Vector3.new(w, 0.4, d), at(origin, Vector3.new(0, 0.2, 0)), P.Concrete, { Material = Enum.Material.Concrete })
	Build.Part(m, "OilStain", Vector3.new(5, 0.05, 3), at(origin, Vector3.new(4, 0.42, 6)), "27272A", { CanCollide = false, Transparency = 0.3 })
	Build.Part(m, "Rug", Vector3.new(8, 0.06, 7), at(origin, Vector3.new(-12, 0.43, 8)), "7F1D1D", { Material = Enum.Material.Fabric, CanCollide = false })
	Build.Part(m, "BackWall", Vector3.new(w + 2, h, 1), at(origin, Vector3.new(0, h / 2, -d / 2 - 0.5)), P.FadedPaint, { Material = Enum.Material.Brick })
	Build.Part(m, "LeftWall", Vector3.new(1, h, d), at(origin, Vector3.new(-half - 0.5, h / 2, 0)), P.FadedPaint, { Material = Enum.Material.Brick })
	Build.Part(m, "RightWall", Vector3.new(1, h, d), at(origin, Vector3.new(half + 0.5, h / 2, 0)), P.FadedPaint, { Material = Enum.Material.Brick })
	local side = (w - door) / 2
	for _, sx in { -1, 1 } do
		Build.Part(m, "FrontWall", Vector3.new(side + 1, h, 1), at(origin, Vector3.new(sx * (door / 2 + side / 2 + 0.5), h / 2, d / 2 + 0.5)), P.FadedPaint, { Material = Enum.Material.Brick })
	end
	Build.Part(m, "Lintel", Vector3.new(door, h - G.DoorHeight, 1), at(origin, Vector3.new(0, G.DoorHeight + (h - G.DoorHeight) / 2, d / 2 + 0.5)), P.Rust, { Material = Enum.Material.CorrodedMetal })
	Build.Part(m, "Roof", Vector3.new(w + 3, 1, d + 3), at(origin, Vector3.new(0, h + 0.5, 0)), "52525B", { Material = Enum.Material.CorrodedMetal })
end

-- Builds the static garage + frontage + lot for one plot. Returns refs PlotService needs later.
function Garage.BuildStatic(m: Model, origin: CFrame): Refs
	local size = World.PlotSize
	local lot = Build.Part(m, "Lot", Vector3.new(size, 0.2, size), origin * CFrame.new(0, 0.1, -size / 2), P.Dirt, { Material = Enum.Material.Ground })
	lot:SetAttribute("PlotLot", true)
	-- Chain-link fence (sides + back; the frontage stays open to the road).
	for _, f in {
		{ Vector3.new(1, 6, size), Vector3.new(-size / 2, 3, -size / 2) },
		{ Vector3.new(1, 6, size), Vector3.new(size / 2, 3, -size / 2) },
		{ Vector3.new(size, 6, 1), Vector3.new(0, 3, -size) },
	} do
		Build.Part(m, "Fence", f[1], origin * CFrame.new(f[2]), "9CA3AF", { Material = Enum.Material.DiamondPlate, Transparency = 0.55 })
	end

	-- Ghost outlines of future rooms (Café annex in Zone A, then Zones B and C).
	local zA, zB = -32, -104
	for _, g in {
		{ "GhostCafe", Vector3.new(150, 14, 64), Vector3.new(35, 7, (zA + zB) / 2) },
		{ "GhostZoneB", Vector3.new(230, 18, 72), Vector3.new(0, 9, -144) },
		{ "GhostZoneC", Vector3.new(230, 24, 64), Vector3.new(0, 12, -220) },
	} do
		Build.Part(m, g[1], g[2], origin * CFrame.new(g[3]), Theme.Colors.Accent, { Material = Enum.Material.ForceField, Transparency = 0.6, CanCollide = false, CanQuery = false, CastShadow = false })
	end

	shell(m, origin)

	-- Roll-up door: stored rolled up (open). The intro cutscene closes it locally and rolls it up.
	local door = Build.Part(m, "GarageDoor", Vector3.new(G.DoorWidth, 1.2, 0.4), at(origin, Vector3.new(0, G.DoorHeight - 0.6, G.Inside.Z / 2 + 0.2)), "A8A29E", { Material = Enum.Material.CorrodedMetal, CanCollide = false })
	door:SetAttribute("ClosedHeight", G.DoorHeight)

	-- Frontage: driveway, cone, crossed-out sign, Cash Collector (coffee can on a milk crate), mailbox.
	local frontDepth = World.Zones[1][2]
	Build.Part(m, "Driveway", Vector3.new(G.DoorWidth + 2, 0.25, frontDepth), origin * CFrame.new(G.Offset.X, 0.13, -frontDepth / 2), "9CA3AF", { Material = Enum.Material.Concrete })
	Build.Part(m, "Cone", Vector3.new(1, 2, 1), at(origin, Vector3.new(-9, 1, 22)), "F97316")
	local noParking = Build.Part(m, "NoParking", Vector3.new(3, 2, 0.2), at(origin, Vector3.new(9, 4, 20), 180), "F8FAFC")
	Build.Text(noParking, Enum.NormalId.Front, "<s>NO</s> PARKING", { TextColor3 = Color3.fromHex("B91C1C"), RichText = true })
	Build.Part(m, "NoParkingPole", Vector3.new(0.3, 3, 0.3), at(origin, Vector3.new(9, 1.5, 20)), "6B7280")
	local cc = anchorCF(origin, "CashCollector")
	Build.Part(m, "MilkCrate", Vector3.new(2, 1.6, 2), cc * CFrame.new(0, 0.8, 0), "2563EB", { Material = Enum.Material.DiamondPlate })
	local can = Build.Cylinder(m, "CashCollector", 1.4, 1.2, (cc * CFrame.new(0, 2.3, 0)).Position, "A16207", { Material = Enum.Material.Metal })
	anchor(can, "CashCollector")
	local mb = anchorCF(origin, "Mailbox")
	Build.Part(m, "MailboxPost", Vector3.new(0.4, 3.5, 0.4), mb * CFrame.new(0, 1.75, 0) * CFrame.Angles(0, 0, math.rad(6)), "78350F")
	Build.Part(m, "Mailbox", Vector3.new(1.2, 1.2, 2), mb * CFrame.new(0.3, 4, 0), "4B5563", { Material = Enum.Material.Metal })

	-- Inside: bulb, pegboard, couch, boxes, fridge, dead plant, posters.
	local bulb = Build.Part(m, "Bulb", Vector3.new(0.6, 0.8, 0.6), at(origin, Vector3.new(0, G.Inside.Y - 1.2, 0)), P.Bulb, { Material = Enum.Material.Neon, CanCollide = false })
	local light = Instance.new("PointLight")
	light.Name = "BulbLight"
	light.Color = Color3.fromHex(P.Bulb)
	light.Range = 34
	light.Brightness = 1.4
	light.Shadows = true
	light.Parent = bulb
	Build.Part(m, "Wire", Vector3.new(0.1, 1, 0.1), at(origin, Vector3.new(0, G.Inside.Y - 0.4, 0)), "111827", { CanCollide = false })
	Build.Part(m, "Pegboard", Vector3.new(10, 5, 0.3), at(origin, Vector3.new(-7, 7, -15.7)), "B45309", { Material = Enum.Material.Wood })
	local couchCF = anchorCF(origin, "Couch")
	Build.Part(m, "Couch", Vector3.new(8, 1.6, 3), couchCF * CFrame.new(0, 0.8, 0), "57534E", { Material = Enum.Material.Fabric })
	Build.Part(m, "CouchBack", Vector3.new(8, 2.2, 0.8), couchCF * CFrame.new(0, 2.2, -1.1), "57534E", { Material = Enum.Material.Fabric })
	local boxes = anchorCF(origin, "Boxes")
	local xmas = Build.Part(m, "BoxXmas", Vector3.new(3, 2.4, 2.4), boxes * CFrame.new(-1.5, 1.2, 0), "B08A5A", { Material = Enum.Material.Cardboard })
	Build.Text(xmas, Enum.NormalId.Back, "DEE: XMAS", { TextColor3 = Color3.fromHex("1C1917"), FontFace = Theme.Fonts.Marker })
	local dnt = Build.Part(m, "BoxDoNotTouch", Vector3.new(2.6, 2, 2.2), boxes * CFrame.new(-1.3, 3.4, 0), "A3825A", { Material = Enum.Material.Cardboard })
	Build.Text(dnt, Enum.NormalId.Back, "DEE: DO NOT TOUCH", { TextColor3 = Color3.fromHex("1C1917"), FontFace = Theme.Fonts.Marker })
	Build.Part(m, "MiniFridge", Vector3.new(2.4, 3, 2.4), boxes * CFrame.new(2.4, 1.5, 0), "E5E7EB", { Material = Enum.Material.Metal })
	Build.Part(m, "Pot", Vector3.new(1.2, 1, 1.2), at(origin, Vector3.new(18.5, 0.9, 14.5)), "9A3412")
	Build.Part(m, "DeadPlant", Vector3.new(0.3, 1.6, 0.3), at(origin, Vector3.new(18.5, 2.1, 14.5), 20), "713F12")
	for i, title in { "AIM ARENA", "TOWER CLASH", "DROP ZONE" } do
		local poster = Build.Part(m, "Poster", Vector3.new(3, 4, 0.1), at(origin, Vector3.new(-19.9, 8, -10 + i * 5), -90) * CFrame.Angles(0, 0, math.rad((i - 2) * 4)), Theme.Colors.Panel)
		Build.Text(poster, Enum.NormalId.Front, title, { TextColor3 = if i == 1 then Theme.Colors.Accent elseif i == 2 then Theme.Colors.Accent2 else Theme.Colors.Warning })
	end

	-- Founder station (the starter PC + taped chair).
	local fd = anchorCF(origin, "FounderDesk")
	local founderModel = Build.Model(m, "FounderStation")
	local founderSeat, monitor, mouse = Garage.Station(founderModel, fd, "Founder")
	anchor(founderModel:FindFirstChild("Desk") :: BasePart, "FounderDesk")
	anchor(founderSeat, "FounderSeat")
	monitor.Text = "NO SIGNAL"

	-- Whiteboard + cork board (free-agent board) on the right wall.
	local wb = Build.Part(m, "Whiteboard", Vector3.new(6, 3.5, 0.2), anchorCF(origin, "Whiteboard"), "F8FAFC")
	local whiteboard = Build.Text(wb, Enum.NormalId.Front, "GOAL: SET UP THE PC", { TextColor3 = Color3.fromHex("1D4ED8"), FontFace = Theme.Fonts.Marker })
	local cork = Build.Part(m, "CorkBoard", Vector3.new(6, 4, 0.25), anchorCF(origin, "FreeAgentBoard"), "B45309", { Material = Enum.Material.Wood })
	anchor(cork, "FreeAgentBoard")
	local board = Build.Text(cork, Enum.NormalId.Front, "FREE AGENTS\nsoon", { TextColor3 = Color3.fromHex("FEF3C7"), FontFace = Theme.Fonts.Marker })

	-- Tech Fix bench by the door, with the neighbor's PC (shown only while a job is waiting).
	local tb = anchorCF(origin, "TechBench")
	local bench = Build.Part(m, "TechBench", Vector3.new(6, 0.5, 2.6), tb * CFrame.new(0, 3, 0), "78716C", { Material = Enum.Material.WoodPlanks })
	anchor(bench, "TechBench")
	Build.Part(m, "BenchBase", Vector3.new(5.6, 2.8, 2.2), tb * CFrame.new(0, 1.4, 0), "57534E")
	Build.Part(m, "BenchPegboard", Vector3.new(6, 3, 0.2), tb * CFrame.new(0, 5.5, 1.2), "B45309", { Material = Enum.Material.Wood })
	local benchPC = Build.Part(m, "NeighborPC", Vector3.new(1.2, 2.2, 2), tb * CFrame.new(0, 4.35, 0), "A8A29E", { Transparency = 1, CanCollide = false })
	local smoke = Instance.new("Smoke")
	smoke.Size = 0.5
	smoke.RiseVelocity = 1
	smoke.Opacity = 0.15
	smoke.Enabled = false
	smoke.Parent = benchPC

	-- Aim Trainer arcade cabinet in the back corner. Screen stays dark until it "flickers on".
	local ac = anchorCF(origin, "AimCabinet")
	local cab = Build.Part(m, "AimCabinet", Vector3.new(3.6, 7, 3), ac * CFrame.new(0, 3.5, 0), "312E81")
	anchor(cab, "AimCabinet")
	local screenPart = Build.Part(m, "CabinetScreen", Vector3.new(2.8, 2.2, 0.2), ac * CFrame.new(0, 4.8, -1.55), "0B1020", { Material = Enum.Material.Neon })
	local cabinetScreen = Build.Text(screenPart, Enum.NormalId.Front, "", { TextColor3 = Theme.Colors.Accent })

	return {
		Model = m,
		Origin = origin,
		Dynamic = nil :: any,
		Door = door,
		FounderSeat = founderSeat,
		FounderMouse = mouse,
		Monitor = monitor,
		Board = board,
		Whiteboard = whiteboard,
		BenchPC = benchPC,
		CabinetScreen = cabinetScreen,
	}
end

-- Café annex ([[HQ Era Visual Guide]] → Café Corner, Stage 2): a rented café against the garage's right wall with its
-- own door + awning. Tech Shop counter, Reaction Test cabinet, case vault (old walk-in fridge); the two café PCs are
-- desks 4–5 (built by PlotService like the other desks). Built per owner into `parent`.
function Garage.Annex(parent: Instance, origin: CFrame, teamColor: Color3): Model
	local m = Build.Model(parent, "CafeAnnex")
	local c = World.Garage.Cafe
	local w, h, d = c.Inside.X, c.Inside.Y, c.Inside.Z
	local cx = c.Center.X
	local wall = "8C4A3C" -- exposed brick
	Build.Part(m, "CafeFloor", Vector3.new(w, 0.4, d), at(origin, Vector3.new(cx, 0.2, 0)), "1F2937", { Material = Enum.Material.Marble })
	for i = 0, 5 do -- checker strips
		Build.Part(m, "Tile", Vector3.new(w, 0.05, 2.5), at(origin, Vector3.new(cx, 0.42, -d / 2 + 2 + i * 5.5)), "E5E7EB", { CanCollide = false })
	end
	Build.Part(m, "CafeBack", Vector3.new(w + 1, h, 1), at(origin, Vector3.new(cx, h / 2, -d / 2 - 0.5)), wall, { Material = Enum.Material.Brick })
	Build.Part(m, "CafeRight", Vector3.new(1, h, d), at(origin, Vector3.new(cx + w / 2 + 0.5, h / 2, 0)), wall, { Material = Enum.Material.Brick })
	local side = (w - c.DoorWidth) / 2
	for _, sx in { -1, 1 } do
		Build.Part(m, "CafeFront", Vector3.new(side, h, 1), at(origin, Vector3.new(cx + sx * (c.DoorWidth / 2 + side / 2), h / 2, d / 2 + 0.5)), wall, { Material = Enum.Material.Brick })
	end
	Build.Part(m, "CafeLintel", Vector3.new(c.DoorWidth, h - 9, 1), at(origin, Vector3.new(cx, 9 + (h - 9) / 2, d / 2 + 0.5)), wall, { Material = Enum.Material.Brick })
	Build.Part(m, "CafeRoof", Vector3.new(w + 2, 1, d + 2), at(origin, Vector3.new(cx, h + 0.5, 0)), "3F3F46", { Material = Enum.Material.Metal })
	Build.Part(m, "Awning", Vector3.new(c.DoorWidth + 6, 0.3, 4), at(origin, Vector3.new(cx, 10, d / 2 + 2.6)) * CFrame.Angles(math.rad(-18), 0, 0), teamColor, { Material = Enum.Material.Fabric, CanCollide = false })
	local sign = Build.Part(m, "OpenSign", Vector3.new(6, 1.6, 0.2), at(origin, Vector3.new(cx + 8, 7, d / 2 + 1.1), 180), "0B1020", { Material = Enum.Material.Neon })
	Build.Text(sign, Enum.NormalId.Front, "OPEN", { TextColor3 = Theme.Colors.Accent2 })
	local lamp = Build.Part(m, "Pendant", Vector3.new(1.2, 0.8, 1.2), at(origin, Vector3.new(cx, h - 1.5, 0)), "FDE68A", { Material = Enum.Material.Neon, CanCollide = false })
	local light = Instance.new("PointLight")
	light.Range, light.Brightness, light.Color = 30, 1.2, Color3.fromHex("FDE68A")
	light.Parent = lamp

	-- Tech Shop counter (the old coffee counter) + shelves of boxed parts.
	local tc = anchorCF(origin, "TechCounter")
	local counter = Build.Part(m, "TechCounter", Vector3.new(10, 3.6, 2.6), tc * CFrame.new(0, 1.8, 0), "7A5230", { Material = Enum.Material.Wood })
	anchor(counter, "TechCounter")
	Build.Part(m, "Espresso", Vector3.new(1.2, 1.4, 1.2), tc * CFrame.new(-4, 4.3, 0), "A1A1AA", { Material = Enum.Material.Metal })
	local board = Build.Part(m, "ShopSign", Vector3.new(8, 2, 0.2), tc * CFrame.new(0, 8, 2.6) * CFrame.Angles(0, math.rad(180), 0), "111827")
	Build.Text(board, Enum.NormalId.Front, "TECH SHOP", { TextColor3 = Theme.Colors.Accent })
	for i = -1, 1 do
		Build.Part(m, "PartBox", Vector3.new(1.8, 1.4, 1.4), tc * CFrame.new(i * 2.6, 5.2, 2.2), if i == 0 then "22D3EE" else "B08A5A", { Material = Enum.Material.Cardboard })
	end

	-- Reaction Test cabinet (Stage 2's new toy).
	local rc = anchorCF(origin, "ReactionCabinet")
	local cab = Build.Part(m, "ReactionCabinet", Vector3.new(3.6, 7, 3), rc * CFrame.new(0, 3.5, 0), "831843")
	anchor(cab, "ReactionCabinet")
	local screen = Build.Part(m, "ReactionScreen", Vector3.new(2.8, 2.2, 0.2), rc * CFrame.new(0, 4.8, -1.55), "0B1020", { Material = Enum.Material.Neon })
	Build.Text(screen, Enum.NormalId.Front, "REACTION\nTEST", { TextColor3 = Theme.Colors.Warning })

	-- Case vault: the old walk-in fridge, a pedestal under a spotlight.
	local cv = anchorCF(origin, "CaseVault")
	Build.Part(m, "FridgeBox", Vector3.new(8, 9, 0.6), cv * CFrame.new(0, 4.5, 3.2), "E5E7EB", { Material = Enum.Material.Metal, Transparency = 0.3 })
	local pedestal = Build.Cylinder(m, "CaseVault", 2.4, 3.2, (cv * CFrame.new(0, 1.2, 0)).Position, "312E81", { Material = Enum.Material.Marble })
	anchor(pedestal, "CaseVault")
	Build.Part(m, "VaultCrate", Vector3.new(2, 2, 2), cv * CFrame.new(0, 3.4, 0) * CFrame.Angles(0, math.rad(20), 0), "B08A5A", { Material = Enum.Material.Cardboard })
	local spot = Instance.new("SpotLight")
	spot.Face, spot.Range, spot.Brightness, spot.Angle, spot.Color = Enum.NormalId.Bottom, 14, 3, 40, Color3.fromHex("BFDBFE")
	spot.Parent = Build.Part(m, "Spot", Vector3.new(0.6, 0.4, 0.6), cv * CFrame.new(0, h - 2, 0), "111827", { CanCollide = false })
	return m
end

-- Trophy shelf on the garage back wall (Stage 3): one gold cup per trophy, newest on the right (max 8 shown).
function Garage.TrophyShelf(parent: Instance, origin: CFrame, trophies: { any }): Model
	local m = Build.Model(parent, "TrophyShelf")
	local cf = anchorCF(origin, "TrophyShelf")
	local shelf = Build.Part(m, "Shelf", Vector3.new(9, 0.4, 1.6), cf * CFrame.new(0, -1.2, 0.7), "78350F", { Material = Enum.Material.Wood })
	anchor(shelf, "TrophyShelf")
	Build.Part(m, "ShelfSign", Vector3.new(4, 0.6, 0.1), cf * CFrame.new(0, -1.75, 1.5), "FEF3C7")
	local shown = math.min(#trophies, 8)
	for i = 1, shown do
		local t = trophies[#trophies - shown + i]
		local x = -3.9 + (i - 1) * 1.1
		local base = cf * CFrame.new(x, -0.85, 0.7)
		Build.Part(m, "CupBase", Vector3.new(0.6, 0.3, 0.6), base, "1C1917")
		local cup = Build.Cylinder(m, "Cup", 0.9, 0.7, (base * CFrame.new(0, 0.6, 0)).Position, if t.Place == 1 then "F59E0B" else "CBD5E1", { Material = Enum.Material.Metal, Reflectance = 0.2 })
		cup:SetAttribute("Trophy", t.Name or "")
	end
	if shown == 0 then
		local note = Build.Part(m, "Empty", Vector3.new(3.4, 0.9, 0.1), cf * CFrame.new(0, -0.5, 0.2), "FEF3C7")
		Build.Text(note, Enum.NormalId.Front, "TROPHIES GO HERE", { TextColor3 = Color3.fromHex("78350F"), FontFace = Theme.Fonts.Marker })
	end
	return m
end

-- Buy pad (classic tycoon pad, step on it).
function Garage.Pad(parent: Instance, origin: CFrame, group: string, ownerId: number): BasePart
	local pad = Build.Part(parent, group, Vector3.new(5, 0.4, 5), anchorCF(origin, group) * CFrame.new(0, 0.6, 0), Theme.Colors.Panel, { Material = Enum.Material.Neon, CanCollide = false })
	pad:SetAttribute("PadGroup", group)
	pad:SetAttribute("OwnerUserId", ownerId)
	anchor(pad, group)
	return pad
end

-- Bedsheet banner over the door with the team name in spray paint. Drops in with a tween when animate = true.
function Garage.Banner(parent: Instance, origin: CFrame, name: string, tag: string, color: Color3, animate: boolean): BasePart
	local full = Vector3.new(16, 2.8, 0.15)
	local cf = at(origin, Vector3.new(0, 12.6, G.Inside.Z / 2 + 1.1))
	local sheet = Build.Part(parent, "Banner", if animate then Vector3.new(full.X, 0.2, full.Z) else full, if animate then cf * CFrame.new(0, 1.3, 0) else cf, "F5F5F4", { Material = Enum.Material.Fabric, CanCollide = false })
	Build.Text(sheet, Enum.NormalId.Back, `{name}  [{tag}]`, { TextColor3 = color, FontFace = Theme.Fonts.Marker })
	if animate then
		TweenService:Create(sheet, TweenInfo.new(0.8, Enum.EasingStyle.Bounce), { Size = full, CFrame = cf }):Play()
	end
	return sheet
end

-- Greybox NPC for a hired player: an R15 rig with seeded body colors when it loads, a block rig otherwise.
function Garage.Npc(card: any, displayName: string): Model
	local look = Generator.Look(card)
	local ok, rig = pcall(function()
		local desc = Instance.new("HumanoidDescription")
		desc.HeadColor, desc.LeftArmColor, desc.RightArmColor = look.Skin, look.Skin, look.Skin
		desc.TorsoColor, desc.LeftLegColor, desc.RightLegColor = look.Shirt, look.Pants, look.Pants
		return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	end)
	local model: Model
	if ok and rig then
		model = rig
		for _, name in { "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm" } do
			local part = model:FindFirstChild(name)
			if part and part:IsA("BasePart") then
				part.Color = look.Shirt -- "Own Tee" ([[Jersey Progression]] tier 1)
			end
		end
	else
		model = Instance.new("Model")
		local root = Build.Part(model, "HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), look.Shirt, { Anchored = false, Transparency = 1 })
		local torso = Build.Part(model, "Torso", Vector3.new(2, 2, 1), CFrame.new(), look.Shirt, { Anchored = false })
		local head = Build.Part(model, "Head", Vector3.new(1.2, 1.2, 1.2), CFrame.new(0, 1.6, 0), look.Skin, { Anchored = false })
		for _, p in { torso, head } do
			local weld = Instance.new("WeldConstraint")
			weld.Part0, weld.Part1 = root, p
			weld.Parent = root
		end
		Instance.new("Humanoid").Parent = model
		model.PrimaryPart = root
	end
	model.Name = "Npc_" .. tostring(card.Id)
	local head = model:FindFirstChild("Head") :: BasePart?
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
	if head then
		Build.Nameplate(head, displayName, Theme.Rarity[card.Rarity] or Theme.Colors.Text, card.Role)
	end
	return model
end

return Garage

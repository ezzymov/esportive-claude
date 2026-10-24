--!strict
-- Greybox Hub ([[World Layout & Presentation]]): ground, Spawn Plaza with jumbotron + fountain, Ring Road,
-- spokes, and the six district lots between plots. Unbuilt districts are visible behind a barrier with "Coming soon".

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Build = require(ReplicatedStorage.Shared.Build)
local PlotFrame = require(ReplicatedStorage.Shared.PlotFrame)
local World = require(ReplicatedStorage.Shared.Config.World)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)

local Hub = {}

local P = World.Palette

local function buildPlaza(root: Instance)
	local plaza = Build.Model(root, "SpawnPlaza")
	Build.Cylinder(plaza, "Paving", 0.4, World.PlazaRadius * 2, Vector3.new(0, 0.2, 0), P.Plaza, { Material = Enum.Material.Slate })
	Build.Cylinder(plaza, "FountainRim", 2, 28, Vector3.new(0, 1, 40), P.Sidewalk, { Material = Enum.Material.Concrete })
	Build.Cylinder(plaza, "FountainWater", 1.6, 24, Vector3.new(0, 1.2, 40), "38BDF8", { Material = Enum.Material.Glass, Transparency = 0.3, CanCollide = false })
	Build.Part(plaza, "StatuePlinth", Vector3.new(8, 4, 8), CFrame.new(0, 2, -40), P.Sidewalk, { Material = Enum.Material.Marble })
	Build.Part(plaza, "Statue", Vector3.new(3, 9, 3), CFrame.new(0, 8.5, -40), "F59E0B", { Material = Enum.Material.Metal })

	-- Four-sided jumbotron on pillars, visible from every driveway.
	for _, off in { Vector3.new(14, 0, 14), Vector3.new(-14, 0, 14), Vector3.new(14, 0, -14), Vector3.new(-14, 0, -14) } do
		Build.Part(plaza, "Pillar", Vector3.new(3, 46, 3), CFrame.new(off + Vector3.new(0, 23, 0)), "1F2937", { Material = Enum.Material.Metal })
	end
	local screen = Build.Part(plaza, "Jumbotron", Vector3.new(32, 18, 32), CFrame.new(0, 55, 0), Theme.Colors.Bg, { Material = Enum.Material.Neon })
	for _, face in { Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right } do
		Build.Text(screen, face, "eSports Tycoon\nCLIP OF THE HOUR", { TextColor3 = Theme.Colors.Accent })
	end

	-- Physical leaderboard (Stage 3 feature, [[Social & Multiplayer]] → Leaderboards). LeaderboardService fills it.
	local boardCF = CFrame.lookAt(Vector3.new(-46, 10, 46), Vector3.new(0, 10, 0))
	for _, x in { -11.5, 11.5 } do
		Build.Part(plaza, "BoardPost", Vector3.new(1.2, 20, 1.2), boardCF * CFrame.new(x, 0, 0.8), "1F2937", { Material = Enum.Material.Metal })
	end
	local board = Build.Part(plaza, "Leaderboard", Vector3.new(24, 16, 0.6), boardCF, Theme.Colors.Bg, { Material = Enum.Material.SmoothPlastic })
	Build.Text(board, Enum.NormalId.Front, "TOP TEAMS\nloading…", { TextColor3 = Theme.Colors.Warning, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top })
end

local function buildRoad(root: Instance)
	local road = Build.Model(root, "RingRoad")
	local r = (World.Road.Inner + World.Road.Outer) / 2
	local width = World.Road.Outer - World.Road.Inner
	local n = World.Road.Segments
	local length = 2 * math.pi * r / n + 1
	for k = 0, n - 1 do
		local a = math.rad(k * 360 / n)
		local dir = PlotFrame.Direction(a)
		local cf = CFrame.lookAt(dir * r, dir * r + dir) -- X = along the road, Z = across it
		Build.Part(road, "Road", Vector3.new(length, 0.3, width), cf + Vector3.new(0, 0.15, 0), P.Road, { Material = Enum.Material.Asphalt })
		Build.Part(road, "Line", Vector3.new(length * 0.5, 0.32, 0.6), cf + Vector3.new(0, 0.16, 0), "FBBF24", { CanCollide = false })
	end
	-- Streetlights on the inner curb.
	for k = 0, 11 do
		local dir = PlotFrame.Direction(math.rad(k * 30 + 15))
		local base = dir * (World.Road.Inner - 4)
		Build.Part(road, "LightPole", Vector3.new(1, 18, 1), CFrame.new(base + Vector3.new(0, 9, 0)), "374151", { Material = Enum.Material.Metal })
		local lamp = Build.Part(road, "Lamp", Vector3.new(3, 1, 3), CFrame.new(base + Vector3.new(0, 18.5, 0)), "FDE68A", { Material = Enum.Material.Neon })
		local light = Instance.new("PointLight")
		light.Color = Color3.fromHex("FDE68A")
		light.Range = 40
		light.Brightness = 1.2
		light.Parent = lamp
	end
end

local function buildDistricts(root: Instance)
	local districts = Build.Model(root, "Districts")
	for i, d in World.Districts do
		local a = PlotFrame.Angle(i) + math.rad(180 / World.PlotCount) -- halfway to the next plot
		local dir = PlotFrame.Direction(a)
		local center = dir * World.DistrictRadius
		local cf = CFrame.lookAt(center, center + dir)
		local lot = Build.Model(districts, d.Name)

		-- Spoke from the plaza to the district.
		local inner, outer = World.PlazaRadius, World.Road.Inner
		Build.Part(lot, "Spoke", Vector3.new(12, 0.3, outer - inner), CFrame.lookAt(dir * ((inner + outer) / 2), dir * outer) + Vector3.new(0, 0.15, 0), P.Sidewalk, { Material = Enum.Material.Concrete })
		Build.Part(lot, "Lot", Vector3.new(60, 0.3, 60), cf + Vector3.new(0, 0.15, 0), if d.Built then "1E1B4B" else P.Dirt, { Material = if d.Built then Enum.Material.SmoothPlastic else Enum.Material.Ground })

		if d.Built then
			-- Arcade Corner: a small dark room with a public Aim Trainer cabinet.
			Build.Part(lot, "BackWall", Vector3.new(40, 16, 1), cf * CFrame.new(0, 8, -14), "312E81")
			local sign = Build.Part(lot, "Sign", Vector3.new(30, 5, 0.5), cf * CFrame.new(0, 18, -14) * CFrame.Angles(0, math.rad(180), 0), Theme.Colors.Accent2, { Material = Enum.Material.Neon })
			Build.Text(sign, Enum.NormalId.Front, d.Name)
			local cab = Build.Part(lot, "AimCabinet", Vector3.new(4, 7, 3), cf * CFrame.new(0, 3.5, -10) * CFrame.Angles(0, math.rad(180), 0), "1F2937")
			cab:SetAttribute("Anchor", "AimCabinet")
			cab:SetAttribute("Public", true)
			local screen = Build.Part(lot, "Screen", Vector3.new(3, 2.4, 0.2), cab.CFrame * CFrame.new(0, 1.6, -1.55), Theme.Colors.Accent, { Material = Enum.Material.Neon })
			Build.Text(screen, Enum.NormalId.Front, "AIM TRAINER", { TextColor3 = Theme.Colors.Bg })
			-- Reaction Test cabinet (Stage 2+; the server checks the stage).
			local react = Build.Part(lot, "ReactionCabinet", Vector3.new(4, 7, 3), cf * CFrame.new(8, 3.5, -10) * CFrame.Angles(0, math.rad(180), 0), "831843")
			react:SetAttribute("Anchor", "ReactionCabinet")
			react:SetAttribute("Public", true)
			local rs = Build.Part(lot, "Screen", Vector3.new(3, 2.4, 0.2), react.CFrame * CFrame.new(0, 1.6, -1.55), Theme.Colors.Warning, { Material = Enum.Material.Neon })
			Build.Text(rs, Enum.NormalId.Front, "REACTION TEST", { TextColor3 = Theme.Colors.Bg })
		else
			for _, side in { -1, 1 } do
				Build.Part(lot, "Barrier", Vector3.new(26, 3, 1), cf * CFrame.new(side * 15, 1.5, 26), "F97316", { Material = Enum.Material.SmoothPlastic })
			end
			local sign = Build.Part(lot, "Sign", Vector3.new(24, 6, 0.5), cf * CFrame.new(0, 6, 26) * CFrame.Angles(0, math.rad(180), 0), "1F2937")
			local opens = if d.Opens then `Opens at {d.Opens}` else "Opens soon"
			Build.Text(sign, Enum.NormalId.Front, `{d.Name}\nComing soon · {opens}`, { TextColor3 = Theme.Colors.Warning })
		end
	end
end

function Hub.Build(): Folder
	local old = Workspace:FindFirstChild("Baseplate")
	if old then
		old:Destroy() -- replaced by the bigger ground below
	end
	local root = Instance.new("Folder")
	root.Name = "Hub"
	Build.Part(root, "Ground", Vector3.new(World.GroundSize, 2, World.GroundSize), CFrame.new(0, -1, 0), P.Grass, { Material = Enum.Material.Grass })
	buildPlaza(root)
	buildRoad(root)
	buildDistricts(root)
	-- Hub lighting: permanent early dusk ([[World Layout & Presentation]] → Look by area).
	local Lighting = game:GetService("Lighting")
	Lighting.ClockTime = 17.4
	Lighting.Ambient = Color3.fromRGB(70, 60, 80)
	Lighting.OutdoorAmbient = Color3.fromRGB(120, 105, 125)
	local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
	if spawn then
		spawn.CFrame = CFrame.new(0, 0.5, 70) -- plaza edge; players are moved to their plot on spawn
	end
	root.Parent = Workspace
	return root
end

return Hub

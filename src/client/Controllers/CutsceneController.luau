--!strict
-- CutsceneController: [[Intro Cutscene]] "The Drop-Off". Runs locally (other players never see it), ~52 s, hold-to-skip
-- after 5 s, re-watchable from Phone → Settings. Uses a clone of your own avatar; the van, Aunt Dee and the PC box
-- are client-side greybox props destroyed at the end. Shots and captions come from Config/Cutscenes/IntroLines.
-- Skipping lands in exactly the same state as finishing. Reports Onboarding/Intro (Started / Skipped / Finished).

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Net = require(ReplicatedStorage.Shared.Net)
local Build = require(ReplicatedStorage.Shared.Build)
local PlotFrame = require(ReplicatedStorage.Shared.PlotFrame)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local World = require(ReplicatedStorage.Shared.Config.World)
local Intro = require(ReplicatedStorage.Shared.Config.Cutscenes.IntroLines)
local New = require(script.Parent.Parent.UI.New)
local Components = require(script.Parent.Parent.UI.Components)
local MyPlot = require(script.Parent.Parent.UI.MyPlot)
local UIController = require(script.Parent.UIController)

local CutsceneController = { Tier = 2 }

local player = Players.LocalPlayer
local playing = false

local function avatarClone(): Model
	local character = player.Character
	local clone: Model? = nil
	if character then
		character.Archivable = true
		local ok, result = pcall(function()
			return character:Clone()
		end)
		if ok and result then
			clone = result
		end
	end
	if not clone then
		-- Fallback rig in the team-to-be colors.
		local m = Instance.new("Model")
		local root = Build.Part(m, "HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), Theme.Colors.Accent, { Transparency = 1 })
		Build.Part(m, "Torso", Vector3.new(2, 2, 1), CFrame.new(), Theme.Colors.Accent)
		Build.Part(m, "Head", Vector3.new(1.2, 1.2, 1.2), CFrame.new(0, 1.6, 0), "F1C27D")
		m.PrimaryPart = root
		clone = m
	end
	local m = clone :: Model
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
		elseif d:IsA("Script") or d:IsA("LocalScript") then
			d:Destroy()
		elseif d:IsA("Humanoid") then
			d.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
	end
	-- Backpack prop over the outfit.
	local torso = m:FindFirstChild("UpperTorso") or m:FindFirstChild("Torso")
	if torso and torso:IsA("BasePart") then
		Build.Part(m, "Backpack", Vector3.new(1.6, 1.8, 0.8), torso.CFrame * CFrame.new(0, 0, 0.9), "B91C1C", { CanCollide = false })
	end
	m.Name = "IntroYou"
	return m
end

local function buildVan(parent: Instance): Model
	local van = Build.Model(parent, "Van")
	local root = Build.Part(van, "Root", Vector3.new(1, 1, 1), CFrame.new(), "000000", { Transparency = 1, CanCollide = false })
	van.PrimaryPart = root
	local o = CFrame.new()
	Build.Part(van, "Body", Vector3.new(7, 6, 16), o * CFrame.new(0, 1, 1), "E7E5E4", { CanCollide = false })
	Build.Part(van, "Cab", Vector3.new(7, 4.5, 4), o * CFrame.new(0, 0.2, -8.5), "E7E5E4", { CanCollide = false })
	Build.Part(van, "Windshield", Vector3.new(6.4, 2.2, 0.2), o * CFrame.new(0, 1.3, -10.45), "93C5FD", { Material = Enum.Material.Glass, Transparency = 0.5, CanCollide = false })
	Build.Part(van, "SideWindow", Vector3.new(0.2, 2, 3), o * CFrame.new(3.52, 1.4, -8.4), "93C5FD", { Material = Enum.Material.Glass, Transparency = 0.5, CanCollide = false })
	Build.Part(van, "Dent", Vector3.new(0.3, 2, 3), o * CFrame.new(3.55, 0, -2) * CFrame.Angles(0, 0, math.rad(8)), "A8A29E", { CanCollide = false })
	local sticker = Build.Part(van, "Sticker", Vector3.new(0.1, 1, 4), o * CFrame.new(-3.55, 1.5, 3), "FBBF24", { CanCollide = false })
	Build.Text(sticker, Enum.NormalId.Left, "STUDENT DRIVER", { TextColor3 = Color3.fromHex("111827") })
	for _, w in { Vector3.new(3.3, -2.1, -7), Vector3.new(-3.3, -2.1, -7), Vector3.new(3.3, -2.1, 6), Vector3.new(-3.3, -2.1, 6) } do
		local wheel = Build.Part(van, "Wheel", Vector3.new(1, 2.6, 2.6), o * CFrame.new(w), "111827", { CanCollide = false })
		wheel.Shape = Enum.PartType.Cylinder
	end
	-- Aunt Dee in the driver's seat: cardigan, reading glasses on a chain.
	Build.Part(van, "DeeBody", Vector3.new(1.8, 1.8, 1), o * CFrame.new(-1.6, 0.3, -8), "C2A36B", { CanCollide = false })
	Build.Part(van, "DeeHead", Vector3.new(1.1, 1.1, 1.1), o * CFrame.new(-1.6, 1.8, -8), "E0AC69", { CanCollide = false })
	Build.Part(van, "DeeHair", Vector3.new(1.2, 0.5, 1.2), o * CFrame.new(-1.6, 2.45, -8), "D6D3D1", { CanCollide = false })
	Build.Part(van, "DeeGlasses", Vector3.new(0.9, 0.2, 0.1), o * CFrame.new(-1.6, 1.9, -8.6), "111827", { CanCollide = false })
	return van
end

-- Rebases every part of a prop model so it can be moved with PivotTo.
local function placeVan(van: Model, cf: CFrame)
	van:PivotTo(cf)
end

function CutsceneController:IsPlaying(): boolean
	return playing
end

-- isReplay: from Settings (no letter / progress). onFirstFrame runs once shot 1 is set up (Flow fades in).
function CutsceneController:PlayIntro(isReplay: boolean, onFirstFrame: (() -> ())?)
	if playing then
		return
	end
	local origin = MyPlot.Origin()
	if not origin then
		if onFirstFrame then
			onFirstFrame()
		end
		return
	end
	playing = true
	local report = Net.Get("Onboarding", "Intro") :: RemoteEvent
	report:FireServer("Started", 0)
	UIController:SetCinematic("Intro", true)

	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	local garage = PlotFrame.Garage(origin)
	local function gp(x: number, y: number, z: number): Vector3
		return (garage * CFrame.new(x, y, z)).Position
	end
	-- x = distance along the ring road from your plot's center line (plot-space X), following the curve.
	local laneRadius = World.PlotFrontRadius - 14
	local plotAngle = PlotFrame.Angle(MyPlot.Index() or 1)
	local function vanAt(x: number): CFrame
		local a = plotAngle + x / laneRadius
		local pos = PlotFrame.Direction(a) * laneRadius + Vector3.new(0, 3.7, 0)
		local forward = -Vector3.new(math.cos(a), 0, math.sin(a)) -- driving toward smaller x
		return CFrame.lookAt(pos, pos + forward)
	end

	-- Lighting: dusk preset during the cutscene, restored after.
	local saved = { ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness }
	Lighting.ClockTime = 17.9

	-- Props.
	local props = Instance.new("Folder")
	props.Name = "IntroProps"
	props.Parent = Workspace
	local van = buildVan(props)
	local you = avatarClone()
	you.Parent = props
	local box = Build.Part(props, "PCBox", Vector3.new(2.4, 2.4, 2.4), CFrame.new(), "B08A5A", { Material = Enum.Material.Cardboard, CanCollide = false })
	Build.Text(box, Enum.NormalId.Front, "PC - THIS SIDE UP", { TextColor3 = Color3.fromHex("1C1917"), FontFace = Theme.Fonts.Marker })

	-- Hide the real character (local only) so only the clone acts.
	local hidden: { [BasePart]: number } = {}
	local function hideReal(on: boolean)
		local character = player.Character
		if not character then
			return
		end
		for _, d in character:GetDescendants() do
			if d:IsA("BasePart") then
				if on then
					hidden[d] = d.LocalTransparencyModifier
					d.LocalTransparencyModifier = 1
				else
					d.LocalTransparencyModifier = 0
				end
			end
		end
	end
	hideReal(true)
	local hideLoop = RunService.RenderStepped:Connect(function()
		local character = player.Character
		if character then
			for _, d in character:GetDescendants() do
				if d:IsA("BasePart") then
					d.LocalTransparencyModifier = 1
				end
			end
		end
	end)

	-- Door closed, bulb off (local), opened in shot 7.
	local plot = MyPlot.Model()
	local door = plot and plot:FindFirstChild("GarageDoor", true) :: BasePart?
	local bulbLight = plot and plot:FindFirstChild("BulbLight", true) :: PointLight?
	local doorOpenCF, doorOpenSize = if door then door.CFrame else nil, if door then door.Size else nil
	if door then
		local h = World.Garage.DoorHeight
		door.Size = Vector3.new(door.Size.X, h, door.Size.Z)
		door.CFrame = (doorOpenCF :: CFrame) * CFrame.new(0, -(h / 2 - 0.6), 0)
	end
	if bulbLight then
		bulbLight.Enabled = false
	end

	-- UI: letterbox, captions, skip, phone, title card.
	local gui = New("ScreenGui", { Name = "Cutscene", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 800, Parent = player:WaitForChild("PlayerGui") })
	for _, top in { true, false } do
		New("Frame", {
			AnchorPoint = Vector2.new(0, if top then 0 else 1),
			Position = UDim2.fromScale(0, if top then 0 else 1),
			Size = UDim2.fromScale(1, 0.11),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Parent = gui,
		})
	end
	local caption = New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.86),
		Size = UDim2.fromScale(0.8, 0.07),
		BackgroundTransparency = 1,
		TextScaled = true,
		RichText = true,
		FontFace = Theme.Fonts.Body,
		TextColor3 = Theme.Colors.Text,
		Text = "",
		Parent = gui,
	}, { New("UIStroke", { Thickness = 2, Color = Color3.new(0, 0, 0) }), New("UITextSizeConstraint", { MaxTextSize = 30 }) })
	local skip = New("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -24, 1, -24),
		Size = UDim2.fromOffset(200, 52),
		BackgroundColor3 = Theme.Colors.Panel,
		BackgroundTransparency = 0.2,
		Text = "Hold to skip",
		FontFace = Theme.Fonts.Bold,
		TextSize = Theme.Type.Body,
		TextColor3 = Theme.Colors.Text,
		Visible = false,
		Parent = gui,
	})
	Components.Corner(skip, Theme.Radius.M)
	local skipFill = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Colors.Accent, BackgroundTransparency = 0.5, ZIndex = 0, Parent = skip })
	Components.Corner(skipFill, Theme.Radius.M)

	local t0 = os.clock()
	local skipped = false
	local holding: number? = nil
	skip.MouseButton1Down:Connect(function()
		holding = os.clock()
	end)
	skip.MouseButton1Up:Connect(function()
		holding = nil
	end)
	skip.MouseLeave:Connect(function()
		holding = nil
	end)
	local keyDown = UserInputService.InputBegan:Connect(function(input)
		if skip.Visible and (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonB) then
			holding = os.clock()
		end
	end)
	local keyUp = UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonB then
			holding = nil
		end
	end)

	-- Per-frame: captions, skip availability + hold, van follow cam.
	local vanX = Instance.new("NumberValue")
	vanX.Value = 260
	local follow: CFrame? = nil -- camera offset in van space while following
	local followLook: CFrame? = nil
	local frame = RunService.RenderStepped:Connect(function()
		local t = os.clock() - t0
		placeVan(van, vanAt(vanX.Value))
		if follow and followLook then
			local vcf = vanAt(vanX.Value)
			camera.CFrame = CFrame.lookAt((vcf * follow).Position, (vcf * followLook).Position)
		end
		local text = ""
		for _, c in Intro.Captions do
			if t >= c.At and t < c.Until then
				text = `<b>{c.Speaker}:</b> {c.Text}`
			end
		end
		caption.Text = text
		skip.Visible = t >= Intro.SkipAfter
		if holding then
			local held = os.clock() - holding
			skipFill.Size = UDim2.fromScale(math.clamp(held / Intro.SkipHold, 0, 1), 1)
			if held >= Intro.SkipHold then
				skipped = true
			end
		else
			skipFill.Size = UDim2.fromScale(0, 1)
		end
	end)

	local function at(seconds: number): boolean
		while os.clock() - t0 < seconds do
			if skipped then
				return false
			end
			task.wait()
		end
		return not skipped
	end
	local camTween: Tween? = nil
	local function cam(cf: CFrame, seconds: number, style: Enum.EasingStyle?)
		follow = nil
		if camTween then
			camTween:Cancel()
		end
		camTween = TweenService:Create(camera, TweenInfo.new(seconds, style or Enum.EasingStyle.Sine), { CFrame = cf });
		(camTween :: Tween):Play()
	end
	local function moveVan(x: number, seconds: number, style: Enum.EasingStyle?, dir: Enum.EasingDirection?)
		TweenService:Create(vanX, TweenInfo.new(seconds, style or Enum.EasingStyle.Linear, dir or Enum.EasingDirection.Out), { Value = x }):Play()
	end

	local function setShell(inside: boolean)
		for _, name in { "Body", "Cab", "Dent", "Sticker" } do
			local p = van:FindFirstChild(name)
			if p and p:IsA("BasePart") then
				p.Transparency = if inside then 1 else 0
			end
		end
	end
	local dir = origin.Position.Unit
	task.spawn(function()
		-- 1 · Skyline: slow push across the plaza toward your plot.
		camera.CFrame = CFrame.lookAt(-dir * 330 + Vector3.new(0, 240, 0), Vector3.new(0, 40, 0))
		you:PivotTo(vanAt(400)) -- parked out of view
		if onFirstFrame then
			task.spawn(onFirstFrame)
		end
		cam(CFrame.lookAt(-dir * 150 + Vector3.new(0, 170, 0), origin.Position), 5, Enum.EasingStyle.Linear)
		if not at(5) then
			return
		end
		-- 2 · Van tracking shot along the ring road.
		vanX.Value = 260
		moveVan(130, 5)
		follow, followLook = CFrame.new(-26, 4, 8), CFrame.new(0, 0, -4)
		if not at(10) then
			return
		end
		-- 3 · Inside the van, over your shoulder, radio casters.
		you:PivotTo(vanAt(vanX.Value) * CFrame.new(1.6, -0.4, -8))
		box.CFrame = vanAt(vanX.Value) * CFrame.new(1.6, -0.2, -9.4)
		moveVan(-20, 12)
		local seat = CFrame.new(1.6, -0.4, -8)
		local seatConn = RunService.RenderStepped:Connect(function()
			local v = vanAt(vanX.Value)
			you:PivotTo(v * seat)
			box.CFrame = v * CFrame.new(1.6, -0.2, -9.4)
		end)
		follow, followLook = CFrame.new(2.4, 2.4, -5.6), CFrame.new(0, 1.5, -30)
		setShell(true) -- the camera sits inside the van: hide its shell
		if not at(17) then
			seatConn:Disconnect()
			return
		end
		-- 4 · Phone close-up: peak rank + Aunt Dee's text.
		local phone = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 1.5),
			Size = UDim2.fromScale(0.22, 0.62),
			BackgroundColor3 = Color3.fromHex("111827"),
			Parent = gui,
		}, { New("UIAspectRatioConstraint", { AspectRatio = 0.5 }), New("UICorner", { CornerRadius = UDim.new(0.08, 0) }), New("UIStroke", { Thickness = 4, Color = Color3.fromHex("374151") }) })
		New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromScale(0.08, 0.1), Size = UDim2.fromScale(0.84, 0.12), TextScaled = true, FontFace = Theme.Fonts.Heading, TextColor3 = Color3.fromHex("C0C0C0"), Text = Intro.Phone.Rank, Parent = phone })
		local bubble = New("TextLabel", { BackgroundColor3 = Theme.Colors.Accent, Position = UDim2.fromScale(0.08, 0.55), Size = UDim2.fromScale(0.84, 0.14), TextScaled = true, FontFace = Theme.Fonts.Body, TextColor3 = Theme.Colors.Bg, Text = `{Intro.Phone.From}: {Intro.Phone.Text}`, Visible = false, Parent = phone }, { New("UICorner", { CornerRadius = UDim.new(0.3, 0) }) })
		TweenService:Create(phone, TweenInfo.new(0.5, Enum.EasingStyle.Back), { Position = UDim2.fromScale(0.5, 0.5) }):Play()
		if not at(19) then
			seatConn:Disconnect()
			return
		end
		bubble.Visible = true
		TweenService:Create(phone, TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 5, true), { Rotation = 2 }):Play() -- buzz
		if not at(21.5) then
			seatConn:Disconnect()
			return
		end
		TweenService:Create(phone, TweenInfo.new(0.4), { Position = UDim2.fromScale(0.5, 1.5) }):Play()
		if not at(22) then
			seatConn:Disconnect()
			return
		end
		-- 5 · Wide street: the van pulls up at YOUR plot.
		setShell(false)
		local stop = World.Garage.Anchors.VanStop[1]
		local stopX = World.Garage.Offset.X + stop.X
		moveVan(stopX, 5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		cam(CFrame.lookAt((origin * CFrame.new(20, 14, 34)).Position, (origin * CFrame.new(stopX, 2, 0)).Position), 0.01)
		task.delay(0.05, function()
			cam(CFrame.lookAt((origin * CFrame.new(-20, 10, 38)).Position, (origin * CFrame.new(stopX - 10, 3, -10)).Position), 5.5)
		end)
		if not at(28) then
			seatConn:Disconnect()
			return
		end
		seatConn:Disconnect()
		-- 6 · Low angle: you step out, box on the curb, Aunt Dee leans out.
		you:PivotTo(CFrame.lookAt(gp(8, 3, 52), gp(8, 3, 0)))
		box.CFrame = CFrame.new(gp(6, 1.3, 50))
		camera.CFrame = CFrame.lookAt(gp(13, 1.2, 58), gp(4, 9, 30))
		cam(CFrame.lookAt(gp(12, 2, 57), gp(2, 10, 26)), 5)
		if not at(33) then
			return
		end
		-- 7 · Garage door rolls up (from inside the dark garage, looking out); bulb clunks on.
		camera.CFrame = CFrame.lookAt(gp(0, 5, -9), gp(0, 4.5, 20))
		if door and doorOpenCF and doorOpenSize then
			TweenService:Create(door, TweenInfo.new(2.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = doorOpenSize, CFrame = doorOpenCF }):Play()
		end
		you:PivotTo(CFrame.lookAt(gp(0, 3, 22), gp(0, 3, 0)))
		box.CFrame = CFrame.new(gp(0, 3.2, 20.8))
		if not at(35.5) then
			return
		end
		if bulbLight then
			bulbLight.Enabled = true
		end
		local walk = Instance.new("CFrameValue")
		walk.Value = you:GetPivot()
		walk.Changed:Connect(function(v)
			you:PivotTo(v)
			box.CFrame = v * CFrame.new(0, 0.2, -1.2)
		end)
		TweenService:Create(walk, TweenInfo.new(2.4), { Value = CFrame.lookAt(gp(0, 3, 9), gp(0, 3, 0)) }):Play()
		if not at(38) then
			return
		end
		-- 8 · Medium shot: the PC comes out of the box onto the fold table.
		local fd = World.Garage.Anchors.FounderDesk[1]
		you:PivotTo(CFrame.lookAt(gp(fd.X, 3, fd.Z + 4), gp(fd.X, 3, fd.Z)))
		box.CFrame = CFrame.new(gp(fd.X - 2, 4.3, fd.Z))
		camera.CFrame = CFrame.lookAt(gp(fd.X + 7, 6.5, fd.Z + 8), gp(fd.X, 3.5, fd.Z))
		cam(CFrame.lookAt(gp(fd.X + 5, 5.5, fd.Z + 6), gp(fd.X, 3.5, fd.Z)), 5)
		task.delay(2.5, function()
			if box.Parent then
				box.Transparency = 1 -- unpacked: the beige tower, cracked monitor and taped mouse are on the desk
			end
		end)
		if not at(43) then
			return
		end
		-- 9 · Van honks twice and drives off; camera rises over the empty plot and its ghost outlines.
		moveVan(-420, 5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		camera.CFrame = CFrame.lookAt(gp(0, 9, 44), gp(0, 6, 0))
		cam(CFrame.lookAt((origin * CFrame.new(-40, 150, 120)).Position, (origin * CFrame.new(0, 0, -128)).Position), 5)
		if not at(48) then
			return
		end
		-- 10 · Title card.
		local title = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromScale(0.6, 0.15), BackgroundTransparency = 1, TextScaled = true, FontFace = Theme.Fonts.Heading, TextColor3 = Theme.Colors.Text, TextTransparency = 1, Text = Intro.Title.Logo, Parent = gui }, { New("UIStroke", { Thickness = 4, Color = Theme.Colors.Accent }) })
		local tag = New("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.56), Size = UDim2.fromScale(0.6, 0.06), BackgroundTransparency = 1, TextScaled = true, FontFace = Theme.Fonts.Body, TextColor3 = Theme.Colors.Text, TextTransparency = 1, Text = Intro.Title.Tagline, Parent = gui })
		TweenService:Create(title, TweenInfo.new(0.6), { TextTransparency = 0 }):Play()
		TweenService:Create(tag, TweenInfo.new(0.6), { TextTransparency = 0 }):Play()
		at(Intro.Length)
	end)

	while not skipped and os.clock() - t0 < Intro.Length do
		task.wait()
	end
	local endedAt = os.clock() - t0

	-- Cleanup: identical end state whether skipped or finished.
	frame:Disconnect()
	if camTween then
		camTween:Cancel()
	end
	hideLoop:Disconnect()
	keyDown:Disconnect()
	keyUp:Disconnect()
	hideReal(false)
	props:Destroy()
	vanX:Destroy()
	gui:Destroy()
	if door and doorOpenCF and doorOpenSize then
		door.Size, door.CFrame = doorOpenSize, doorOpenCF
	end
	if bulbLight then
		bulbLight.Enabled = true
	end
	Lighting.ClockTime = saved.ClockTime
	Lighting.Brightness = saved.Brightness
	camera.CameraType = Enum.CameraType.Custom
	UIController:SetCinematic("Intro", false)
	report:FireServer(if skipped then "Skipped" else "Finished", math.floor(endedAt))
	playing = false
end

return CutsceneController

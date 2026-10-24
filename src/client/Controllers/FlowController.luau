--!strict
-- FlowController: first-join sequence ([[Screen - Start]] → [[Intro Cutscene]] → [[Screen - Starter Letter]] →
-- [[Screen - Team Creator]]), then hands control to the player and the tutorial. Returning players see the Start
-- screen and drop straight into their garage (no cutscene, no letter).

local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Net = require(ReplicatedStorage.Shared.Net)
local Signal = require(ReplicatedStorage.Shared.Signal)
local Format = require(ReplicatedStorage.Shared.Format)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Lines = require(ReplicatedStorage.Shared.Config.Tutorial.Lines)
local Economy = require(ReplicatedStorage.Shared.Config.Economy)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local MyPlot = require(script.Parent.Parent.UI.MyPlot)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)
local CutsceneController = require(script.Parent.CutsceneController)
local TeamCreatorController = require(script.Parent.TeamCreatorController)

local FlowController = { Tier = 3 }

FlowController.Ready = false
FlowController.ReadySignal = Signal.new()

local player = Players.LocalPlayer

local function startGui(): ScreenGui
	return New("ScreenGui", {
		Name = "Start",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 900,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = player:WaitForChild("PlayerGui"),
	})
end

local function fadeBlack(gui: ScreenGui, to: number, seconds: number): Frame
	local black = gui:FindFirstChild("Black") :: Frame?
	if not black then
		black = New("Frame", { Name = "Black", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 100, Parent = gui })
	end
	local f = black :: Frame
	local t = TweenService:Create(f, TweenInfo.new(seconds), { BackgroundTransparency = to })
	t:Play()
	t.Completed:Wait()
	return f
end

-- [[Screen - Start]]: blurred live shot of your own plot, logo, loading bar → PRESS TO PLAY, rotating tip line.
local function startScreen(gui: ScreenGui)
	local camera = Workspace.CurrentCamera
	local blur = New("BlurEffect", { Name = "StartBlur", Size = 14, Parent = Lighting })
	camera.CameraType = Enum.CameraType.Scriptable
	local orbit: RBXScriptConnection? = nil
	local origin = MyPlot.Origin()
	if origin then
		local garage = origin * CFrame.new(-100, 6, -48)
		local t0 = os.clock()
		orbit = RunService.RenderStepped:Connect(function()
			local a = math.rad(-25 + math.sin((os.clock() - t0) * 0.15) * 15)
			local pos = (garage * CFrame.Angles(0, a, 0) * CFrame.new(0, 14, 70)).Position
			camera.CFrame = CFrame.lookAt(pos, garage.Position)
		end)
	end

	local mobile = Components.IsMobile()
	local dim = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Colors.Bg, BackgroundTransparency = 0.45, Parent = gui })
	local logo = New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.36),
		Size = UDim2.fromScale(if mobile then 0.7 else 0.45, 0.16),
		BackgroundTransparency = 1,
		TextScaled = true,
		FontFace = Theme.Fonts.Heading,
		Text = "eSports Tycoon",
		TextColor3 = Theme.Colors.Text,
		Parent = dim,
	}, {
		New("UIStroke", { Thickness = 4, Color = Theme.Colors.Accent }),
		New("UIGradient", { Rotation = 90, Color = ColorSequence.new(Theme.Colors.Text, Theme.Colors.Accent) }),
	})
	local float = TweenService:Create(logo, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = UDim2.new(0.5, 0, 0.36, -4) })
	float:Play()
	local press = New("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, if mobile then 0.72 else 0.6),
		Size = UDim2.fromOffset(420, 64),
		BackgroundTransparency = 1,
		FontFace = Theme.Fonts.Heading,
		TextSize = Theme.Type.H1,
		TextColor3 = Theme.Colors.Text,
		Text = "PRESS TO PLAY",
		Visible = false,
		Parent = dim,
	}, { New("UIStroke", { Thickness = 2, Color = Theme.Colors.Bg }) })
	local pressScale = New("UIScale", { Parent = press })
	TweenService:Create(pressScale, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Scale = 1.05 }):Play()
	local track, setBar = Components.Bar(Theme.Colors.Accent, 14)
	track.AnchorPoint = Vector2.new(0.5, 1)
	track.Position = UDim2.new(0.5, 0, 1, -64)
	track.Size = UDim2.new(0.9, 0, 0, 14)
	track.Parent = dim
	local tip = New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -28),
		Size = UDim2.new(0.9, 0, 0, 24),
		BackgroundTransparency = 1,
		FontFace = Theme.Fonts.Body,
		TextSize = Theme.Type.Body,
		TextColor3 = Theme.Colors.TextMuted,
		Text = Theme.Tips[1],
		Parent = dim,
	})
	local note = New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.66, 30),
		Size = UDim2.fromOffset(500, 22),
		BackgroundTransparency = 1,
		FontFace = Theme.Fonts.Body,
		TextSize = Theme.Type.Caption,
		TextColor3 = Theme.Colors.Warning,
		Text = "",
		Parent = dim,
	})

	local alive = true
	task.spawn(function()
		local i = 1
		while alive do
			task.wait(4)
			i = i % #Theme.Tips + 1
			tip.Text = Theme.Tips[i]
		end
	end)

	-- Preload the garage (and the intro's props are greybox, so nothing else to fetch).
	local ready = false
	task.spawn(function()
		local plot = MyPlot.Model()
		local list = if plot then plot:GetDescendants() else {}
		local total, done = math.max(#list, 1), 0
		local ok = pcall(function()
			ContentProvider:PreloadAsync(list, function()
				done += 1
				setBar(done / total)
			end)
		end)
		if not ok then
			note.Text = "Some assets didn't load. Playing anyway."
		end
		setBar(1)
		task.wait(0.35)
		track.Visible = false
		press.Visible = true
		ready = true
	end)

	local pressed = Signal.new()
	local function go()
		if ready then
			pressed:Fire()
		end
	end
	press.Activated:Connect(go)
	local tap = New("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 0, Parent = dim, Activated = go })
	local key = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard or input.KeyCode == Enum.KeyCode.ButtonA then
			go()
		end
	end)
	pressed:Wait()
	alive = false
	key:Disconnect()
	tap:Destroy()
	fadeBlack(gui, 0, 0.4)
	float:Cancel()
	if orbit then
		orbit:Disconnect()
	end
	blur:Destroy()
	dim:Destroy()
end

-- [[Screen - Starter Letter]]: tilted note from Aunt Dee; clicking the bill (the only button) collects the gift.
local function starterLetter(overlay: ScreenGui)
	UIController:SetMenu("Letter", true)
	local mobile = Components.IsMobile()
	local dim = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Active = true, ZIndex = 30, Parent = overlay })
	TweenService:Create(dim, TweenInfo.new(0.3), { BackgroundTransparency = 0.55 }):Play()
	local paper = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, -0.6),
		Size = UDim2.fromScale(if mobile then 0.6 else 0.42, if mobile then 0.85 else 0.6),
		Rotation = -2,
		BackgroundColor3 = Color3.fromHex("FBF7EE"),
		ZIndex = 31,
		Parent = dim,
	}, {
		New("UIAspectRatioConstraint", { AspectRatio = 1.25 }),
		New("UIStroke", { Thickness = 3, Color = Color3.fromHex("1C1917") }),
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})
	local function hand(text: string, pos: UDim2, size: UDim2, textSize: number, align: Enum.TextXAlignment, color: Color3?): TextLabel
		return New("TextLabel", {
			BackgroundTransparency = 1,
			Position = pos,
			Size = size,
			FontFace = Theme.Fonts.Hand,
			TextScaled = true,
			TextColor3 = color or Color3.fromHex("1C1917"),
			TextXAlignment = align,
			Text = text,
			ZIndex = 32,
			Parent = paper,
		}, { New("UITextSizeConstraint", { MaxTextSize = textSize }) })
	end
	hand("Aunt Dee\n14 Garage Row", UDim2.fromScale(0.62, 0.05), UDim2.fromScale(0.34, 0.12), 22, Enum.TextXAlignment.Right, Color3.fromHex("78716C"))
	hand(`Dear {player.DisplayName},`, UDim2.fromScale(0.07, 0.17), UDim2.fromScale(0.8, 0.1), 34, Enum.TextXAlignment.Left)
	hand("Sell Lemons.", UDim2.fromScale(0.07, 0.32), UDim2.fromScale(0.86, 0.17), 72, Enum.TextXAlignment.Left)
	hand(`Make {Theme.Icons.Cash} {Theme.Icons.Cash} {Theme.Icons.Cash}.`, UDim2.fromScale(0.07, 0.49), UDim2.fromScale(0.86, 0.17), 72, Enum.TextXAlignment.Left)
	hand("- Aunt Dee", UDim2.fromScale(0.55, 0.7), UDim2.fromScale(0.4, 0.1), 34, Enum.TextXAlignment.Right)
	hand(Lines.TUT_STARTER_LETTER.Text .. " ;)", UDim2.fromScale(0.36, 0.84), UDim2.fromScale(0.6, 0.12), 24, Enum.TextXAlignment.Left)

	-- The bill: only way to dismiss. 20 px padding around it for the hit area.
	local billHit = New("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.14, 0.86),
		Size = UDim2.fromScale(0.3, 0.26),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 34,
		Parent = paper,
	})
	local bill = New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -20, 1, -20),
		BackgroundColor3 = Color3.fromHex("4ADE80"),
		Rotation = 8,
		FontFace = Theme.Fonts.Heading,
		TextScaled = true,
		TextColor3 = Color3.fromHex("14532D"),
		Text = Format.Cash(Economy.StarterGift),
		ZIndex = 35,
		Parent = billHit,
	}, {
		New("UIStroke", { Thickness = 3, Color = Color3.fromHex("14532D") }),
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIPadding", { PaddingLeft = UDim.new(0.15, 0), PaddingRight = UDim.new(0.15, 0), PaddingTop = UDim.new(0.15, 0), PaddingBottom = UDim.new(0.15, 0) }),
	})
	New("Frame", { -- paper clip
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.75, 0, 0, 10),
		Size = UDim2.new(0.12, 0, 0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = 36,
		Parent = bill,
	}, { New("UIStroke", { Thickness = 3, Color = Color3.fromHex("94A3B8") }), New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	TweenService:Create(paper, TweenInfo.new(0.6, Enum.EasingStyle.Back), { Position = UDim2.fromScale(0.5, 0.5) }):Play()
	local bob = TweenService:Create(bill, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = UDim2.new(0.5, 0, 0.5, -3) })
	bob:Play()
	billHit.MouseEnter:Connect(function()
		bill.BackgroundColor3 = Color3.fromHex("86EFAC")
	end)
	billHit.MouseLeave:Connect(function()
		bill.BackgroundColor3 = Color3.fromHex("4ADE80")
	end)

	local collect = Net.Get("Starter", "Collect") :: RemoteFunction
	local done = Signal.new()
	local busy = false
	local function click()
		if busy then
			return
		end
		busy = true
		local ok, amount = collect:InvokeServer()
		if not ok and amount ~= "AlreadyCollected" then
			busy = false
			HudController:Toast("Couldn't collect that. Try again.", Theme.Colors.Danger)
			return
		end
		bob:Cancel()
		-- Bill flies to the Cash pill, +N floats, paper slides off the bottom.
		local pill = HudController:GetPill("Cash")
		local abs = bill.AbsolutePosition
		local flyer = bill:Clone()
		flyer.AnchorPoint = Vector2.new(0, 0)
		flyer.Rotation = 8
		flyer.Size = UDim2.fromOffset(bill.AbsoluteSize.X, bill.AbsoluteSize.Y)
		flyer.Position = UDim2.fromOffset(abs.X, abs.Y)
		flyer.ZIndex = 60
		flyer.Parent = overlay
		bill.Visible = false
		if pill then
			local target = pill.AbsolutePosition
			TweenService:Create(flyer, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.fromOffset(target.X, target.Y), Size = UDim2.fromOffset(40, 24), Rotation = 0 }):Play()
		end
		task.wait(0.5)
		flyer:Destroy()
		if type(amount) == "number" then
			HudController:Float(`+{Format.Cash(amount)}`, Theme.Colors.Success)
		end
		TweenService:Create(paper, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.fromScale(0.5, 1.7) }):Play()
		TweenService:Create(dim, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
		task.wait(0.4)
		dim:Destroy()
		done:Fire()
	end
	billHit.Activated:Connect(click)
	local key = UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.ButtonA then
			click()
		end
	end)
	done:Wait()
	key:Disconnect()
	UIController:SetMenu("Letter", false)
end

local function handOver()
	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		camera.CameraSubject = humanoid
	end
end

function FlowController:WaitUntilReady()
	if not FlowController.Ready then
		FlowController.ReadySignal:Wait()
	end
end

function FlowController:Start()
	local gui = startGui()
	StateController:WaitUntilLoaded()
	MyPlot.Wait(20)
	HudController:WaitUntilBuilt()
	startScreen(gui)

	local flags = StateController:Get("Flags") or {}
	if not flags.IntroSeen then
		CutsceneController:PlayIntro(false, function()
			fadeBlack(gui, 1, 0.4) -- reveal shot 1
		end)
	else
		handOver()
		fadeBlack(gui, 1, 0.4)
	end
	gui:Destroy()
	handOver()
	HudController:Show()

	local overlay = UIController:GetGui("Overlay")
	if not (StateController:Get("Flags.StarterLetterSeen")) then
		starterLetter(overlay)
	end
	if not (StateController:Get("Flags.TeamCreated")) then
		TeamCreatorController:Open(true)
	end
	FlowController.Ready = true
	FlowController.ReadySignal:Fire()
end

return FlowController

--!strict
-- StationController: your Founder desk ([[Founder (You)]], [[PC Setups]]).
--   Before Power On: "Set up PC" prompt → cable minigame (drag 3 cables to matching ports, ghost hand demo once)
--   → POWER ON → Station/PowerOn mints the Founder card → card reveal ("You · OVR 30").
--   While seated: the desk panel (Play Pickup Game + cooldown) and a floating +$ over the monitor as you earn.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Net = require(ReplicatedStorage.Shared.Net)
local Format = require(ReplicatedStorage.Shared.Format)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local Drag = require(script.Parent.Parent.UI.Drag)
local MyPlot = require(script.Parent.Parent.UI.MyPlot)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)
local MatchController = require(script.Parent.MatchController)
local RosterController = require(script.Parent.RosterController)

local StationController = { Tier = 5 }

local player = Players.LocalPlayer
local setupOpen = false

-- Cable minigame. Returns when powered on or closed.
local function cableSetup()
	if setupOpen then
		return
	end
	local ok, cables = (Net.Get("Station", "BeginSetup") :: RemoteFunction):InvokeServer()
	if not ok then
		HudController:Toast(if cables == "TooFar" then "Get closer to your desk." elseif cables == "NameTeamFirst" then "Name your team first." else "Can't set up right now.", Theme.Colors.Warning)
		return
	end
	setupOpen = true
	UIController:SetMenu("Setup", true)
	local overlay = UIController:GetGui("Overlay")
	local modal = Components.Modal(overlay, { Title = "Set up your PC", Width = 0.6, Height = 0.75, OnClose = function()
		setupOpen = false
		UIController:SetMenu("Setup", false)
	end })
	local body = modal.Body
	New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.TextMuted, Text = "Drag each cable to the port with the same color.", Parent = body })
	local tower = New("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -24, 0.48, 0), Size = UDim2.fromOffset(200, 300), BackgroundColor3 = Color3.fromHex("E7E5E4"), Parent = body })
	Components.Corner(tower, Theme.Radius.M)
	New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), FontFace = Theme.Fonts.Bold, TextSize = 16, TextColor3 = Color3.fromHex("57534E"), Text = "BACK OF TOWER", Parent = tower })
	local order = { 2, 3, 1 } -- ports in a different order than the plugs
	local ports: { Frame } = {}
	for i, idx in order do
		local c = cables[idx]
		local port = New("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 40 + (i - 1) * 84), Size = UDim2.fromOffset(84, 64), BackgroundColor3 = Color3.fromHex("1C1917"), Parent = tower })
		Components.Corner(port, Theme.Radius.S)
		New("UIStroke", { Thickness = 4, Color = Color3.fromHex(c.Color), Parent = port })
		New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), FontFace = Theme.Fonts.Bold, TextSize = 14, TextColor3 = Color3.fromHex(c.Color), Text = c.Name, Parent = port })
		ports[idx] = port
	end
	local plugged = 0
	local power, setPower = Components.Button({ Text = "POWER ON", Width = 240, Color = Theme.Colors.Success })
	power.AnchorPoint = Vector2.new(0.5, 1)
	power.Position = UDim2.fromScale(0.5, 1)
	power.Parent = body
	setPower(false)
	local detach = {}
	local plugs: { GuiObject } = {}
	for i, c in cables do
		local plug = New("TextLabel", {
			Position = UDim2.fromOffset(40, 70 + (i - 1) * 90),
			Size = UDim2.fromOffset(120, 56),
			BackgroundColor3 = Color3.fromHex(c.Color),
			FontFace = Theme.Fonts.Heading,
			TextSize = 18,
			TextColor3 = Theme.Colors.Bg,
			Text = c.Name,
			Active = true,
			ZIndex = 25,
			Parent = body,
		})
		Components.Corner(plug, Theme.Radius.M)
		plugs[i] = plug
		detach[i] = Drag.Attach(plug, function(pos)
			if Drag.Inside(ports[i], pos) then
				local p = ports[i]
				plug.Parent = p -- snap into the port
				plug.Position = UDim2.fromScale(0, 0)
				plug.Size = UDim2.fromScale(1, 1)
				plug.Text = "OK"
				plug.Active = false
				detach[i]()
				plugged += 1
				if plugged == #cables then
					setPower(true)
					local pulse = TweenService:Create(power, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Size = UDim2.fromOffset(256, 60) })
					pulse:Play()
				end
				return true
			end
			return false
		end)
	end
	-- Ghost demo: a translucent hand drags the first cable once.
	task.spawn(function()
		task.wait(0.6)
		local hand = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(48, 48), TextSize = 40, Text = "👆", TextTransparency = 0.35, ZIndex = 40, Parent = body })
		local f = plugs[1].AbsoluteSize.X / 120 -- screen px per design px
		local from = (plugs[1].AbsolutePosition - body.AbsolutePosition) / f + Vector2.new(60, 28)
		local to = (ports[1].AbsolutePosition - body.AbsolutePosition) / f + Vector2.new(42, 32)
		hand.Position = UDim2.fromOffset(from.X, from.Y)
		local t = TweenService:Create(hand, TweenInfo.new(1.2, Enum.EasingStyle.Quad), { Position = UDim2.fromOffset(to.X, to.Y) })
		t:Play()
		t.Completed:Wait()
		TweenService:Create(hand, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		task.wait(0.3)
		hand:Destroy()
	end)

	local busy = false
	power.Activated:Connect(function()
		if plugged < #cables or busy then
			return
		end
		busy = true
		power.Text = "Booting…"
		local done, result = (Net.Get("Station", "PowerOn") :: RemoteFunction):InvokeServer()
		if done then
			modal.Close()
			task.wait(0.2)
			RosterController:RevealFounder()
		else
			busy = false
			power.Text = "POWER ON"
			HudController:Toast(if result == "TooFast" then "Give it a second…" else `Didn't boot ({tostring(result)})`, Theme.Colors.Warning)
		end
	end)
end

local function prompt(part: BasePart, action: string, object: string, onTrigger: () -> ()): ProximityPrompt
	local p = New("ProximityPrompt", {
		ActionText = action,
		ObjectText = object,
		HoldDuration = 0,
		MaxActivationDistance = 10,
		RequiresLineOfSight = false,
		Parent = part,
	})
	p.Triggered:Connect(onTrigger)
	return p
end

-- Desk panel while seated: Play Pickup Game (+ cooldown), and floating income over the monitor.
local function deskPanel()
	local lastCash = StateController:Get("Currencies.Cash") or 0
	local accum, lastFloat = 0, os.clock()
	StateController:Observe("Currencies.Cash", function(cash)
		local seated = (function()
			local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			return h ~= nil and h.SeatPart ~= nil and h.SeatPart:GetAttribute("Anchor") == "FounderSeat"
		end)()
		local diff = (cash or 0) - lastCash
		lastCash = cash or 0
		if seated and diff > 0 and diff < 5 then
			accum += diff -- income ticks only (rewards show their own text)
		end
	end)
	RunService.Heartbeat:Connect(function()
		local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		local seated = h ~= nil and h.SeatPart ~= nil and h.SeatPart:GetAttribute("Anchor") == "FounderSeat"
		local powered = StateController:Get("Flags.StationPowered")
		if seated and powered and not MatchController:IsPlaying() then
			local wait = MatchController:CooldownLeft()
			local text = if wait > 0 then `Next Pickup Game in {wait}s` else "▶ Play Pickup Game"
			HudController:SetContext("PickupButton", text, if wait > 0 then Theme.Colors.TextMuted else Theme.Colors.Accent, function()
				if MatchController:CooldownLeft() <= 0 then
					MatchController:StartPickup()
				end
			end)
		else
			HudController:ClearContext("PickupButton")
		end
		if seated and os.clock() - lastFloat >= 5 then
			lastFloat = os.clock()
			if accum >= 1 then
				local monitor = MyPlot.Find("FounderDesk")
				HudController:Float(`+{Format.Cash(accum)}`, Theme.Colors.Success, if monitor and monitor:IsA("BasePart") then monitor else nil)
				accum = 0
			end
		end
	end)
end

function StationController:Start()
	StateController:WaitUntilLoaded()
	HudController:WaitUntilShown()
	-- "Set up PC" prompt on the Founder desk until powered.
	task.spawn(function()
		local p: ProximityPrompt? = nil
		while true do
			local desk = MyPlot.Find("FounderDesk")
			local need = StateController:Get("Flags.TeamCreated") and not StateController:Get("Flags.StationPowered")
			if desk and desk:IsA("BasePart") and need and not p then
				p = prompt(desk, "Set up PC", "Starter PC", cableSetup)
			elseif p and not need then
				p:Destroy()
				p = nil
			end
			task.wait(0.5)
		end
	end)
	deskPanel()
end

return StationController

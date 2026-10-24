--!strict
-- MinigameController: Aim Trainer cabinet + Tech Fix bench ([[Playable Games]], [[Founder (You)]]).
-- The client only plays; the server issues run/job tokens, caps the score and pays ([[Security & Anti-Exploit]]).
--   Aim Trainer: 20 s, a target every 0.6 s (seeded by the server), tap/click to hit → Cash + Founder Aim XP.
--   Tech Fix: a neighbor's broken PC on the bench → plug 2 cables, swap the bad RAM, wipe the dust → pay.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

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

local MinigameController = { Tier = 5 }

local player = Players.LocalPlayer
local busy = false

-- Aim Trainer ------------------------------------------------------------------------------------------------

local function aimTrainer(source: BasePart?)
	if busy then
		return
	end
	busy = true
	local ok, run = (Net.Get("Minigame", "AimStart") :: RemoteFunction):InvokeServer()
	if not ok then
		busy = false
		local msg = if type(run) == "table" and run.Cooldown then `Cabinet's cooling down ({run.Cooldown}s)` elseif run == "Locked" then "It won't turn on yet." elseif run == "TooFar" then "Get closer to the cabinet." else `Can't play ({tostring(run)})`
		HudController:Toast(msg, Theme.Colors.Warning)
		return
	end
	UIController:SetMenu("AimTrainer", true)
	local overlay = UIController:GetGui("Overlay")
	local modal = Components.Modal(overlay, { Title = "Aim Trainer", Width = 0.75, Height = 0.85, NoClose = true })
	local arena = New("Frame", { BackgroundColor3 = Color3.fromHex("0B1020"), Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 1, -40), ClipsDescendants = true, Parent = modal.Body })
	Components.Corner(arena, Theme.Radius.M)
	local hud = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.H2, TextColor3 = Theme.Colors.Text, Text = "Get ready…", Parent = modal.Body })
	task.wait(1)

	local rng = Random.new(run.Seed)
	local hits, spawned = 0, 0
	local t0 = os.clock()
	local nextSpawn = 0
	while os.clock() - t0 < run.Duration do
		local t = os.clock() - t0
		hud.Text = `Hits {hits}   ·   {math.ceil(run.Duration - t)}s`
		if t >= nextSpawn then
			nextSpawn += run.Interval
			spawned += 1
			local size = rng:NextInteger(54, 84)
			local target = New("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(rng:NextNumber(0.08, 0.92), rng:NextNumber(0.1, 0.9)),
				Size = UDim2.fromOffset(size, size),
				BackgroundColor3 = Theme.Colors.Danger,
				Text = "",
				AutoButtonColor = false,
				Parent = arena,
			})
			New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = target })
			New("UIStroke", { Thickness = 6, Color = Theme.Colors.Text, Parent = target })
			local hit = false
			target.Activated:Connect(function()
				if hit then
					return
				end
				hit = true
				hits += 1
				TweenService:Create(target, TweenInfo.new(0.12), { Size = UDim2.fromOffset(size * 1.4, size * 1.4), BackgroundTransparency = 1 }):Play()
				task.delay(0.12, target.Destroy, target)
			end)
			task.delay(run.Life, function()
				if target.Parent and not hit then
					target:Destroy()
				end
			end)
		end
		task.wait()
	end
	for _, c in arena:GetChildren() do
		if c:IsA("TextButton") then
			c:Destroy()
		end
	end
	hud.Text = `Time! {hits} hits`
	local done, result = (Net.Get("Minigame", "AimFinish") :: RemoteFunction):InvokeServer(run.RunId, hits)
	if done then
		local line = `+{Format.Cash(result.Cash)}` .. (if result.AimGained > 0 then `  ·  Aim +{result.AimGained}` else "  ·  Aim XP")
		hud.Text = line
		HudController:Float(`+{Format.Cash(result.Cash)}`, Theme.Colors.Success, source)
	else
		hud.Text = "That run didn't count."
	end
	task.wait(1.6)
	modal.Close()
	UIController:SetMenu("AimTrainer", false)
	busy = false
end

-- Reaction Test ([[Stage Beat Sheets 2-10]] Stage 2 new toy) -------------------------------------------------------
-- 8 rounds of timing bars: a marker sweeps back and forth; stop it in the green zone. The zone shrinks and the marker
-- speeds up each round. Tap STOP, click, or press Space.

local function reactionTest(source: BasePart?)
	if busy then
		return
	end
	busy = true
	local ok, run = (Net.Get("Minigame", "ReactStart") :: RemoteFunction):InvokeServer()
	if not ok then
		busy = false
		local msg = if type(run) == "table" and run.Cooldown then `Cabinet's cooling down ({run.Cooldown}s)` elseif type(run) == "table" and run.NeedStage then `Opens at Stage {run.NeedStage}` elseif run == "TooFar" then "Get closer to the cabinet." else `Can't play ({tostring(run)})`
		HudController:Toast(msg, Theme.Colors.Warning)
		return
	end
	UIController:SetMenu("ReactionTest", true)
	local overlay = UIController:GetGui("Overlay")
	local modal = Components.Modal(overlay, { Title = "Reaction Test", Width = 0.6, Height = 0.6, NoClose = true })
	local hud = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.H2, TextColor3 = Theme.Colors.Text, Text = "Stop the marker in the green!", Parent = modal.Body })
	local track = New("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 70), Size = UDim2.new(0.92, 0, 0, 56), BackgroundColor3 = Color3.fromHex("0B1020"), Parent = modal.Body })
	Components.Corner(track, Theme.Radius.M)
	local zone = New("Frame", { Size = UDim2.fromScale(0.2, 1), BackgroundColor3 = Theme.Colors.Success, Parent = track })
	local marker = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(0, 8, 1.4, 0), BackgroundColor3 = Theme.Colors.Text, ZIndex = 3, Parent = track })
	local result = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 140), Size = UDim2.new(1, 0, 0, 40), FontFace = Theme.Fonts.Heading, TextSize = Theme.Type.H1, TextColor3 = Theme.Colors.Text, Text = "", Parent = modal.Body })
	local stopped = false
	local stopBtn = Components.Button({ Text = "STOP!", Width = 220, OnClick = function()
		stopped = true
	end })
	stopBtn.AnchorPoint = Vector2.new(0.5, 1)
	stopBtn.Position = UDim2.fromScale(0.5, 1)
	stopBtn.Parent = modal.Body
	local key = UserInputService.InputBegan:Connect(function(input, processed)
		if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA or (not processed and input.UserInputType == Enum.UserInputType.MouseButton1) then
			stopped = true
		end
	end)
	task.wait(0.8)

	local rng = Random.new(run.Seed)
	local hits = 0
	for round = 1, run.Rounds do
		local t = (round - 1) / math.max(1, run.Rounds - 1)
		local width = run.ZoneStart + (run.ZoneEnd - run.ZoneStart) * t
		local sweep = run.Sweep[1] + (run.Sweep[2] - run.Sweep[1]) * t
		local left = rng:NextNumber(0.05, 0.95 - width)
		zone.Position = UDim2.fromScale(left, 0)
		zone.Size = UDim2.fromScale(width, 1)
		hud.Text = `Round {round}/{run.Rounds}   ·   Hits {hits}`
		result.Text = ""
		stopped = false
		local t0 = os.clock()
		local pos = 0
		while not stopped and os.clock() - t0 < sweep * 3 do
			local phase = ((os.clock() - t0) / sweep) % 2
			pos = if phase < 1 then phase else 2 - phase
			marker.Position = UDim2.fromScale(pos, 0.5)
			task.wait()
		end
		local hit = stopped and pos >= left and pos <= left + width
		if hit then
			hits += 1
		end
		result.Text = if hit then "HIT!" elseif stopped then "MISS" else "TOO SLOW"
		result.TextColor3 = if hit then Theme.Colors.Success else Theme.Colors.Danger
		Components.Play(Theme.Sounds.Sting, if hit then 1.2 else 0.7, 0.4)
		task.wait(0.45)
	end
	key:Disconnect()
	stopBtn.Visible = false
	hud.Text = `Done! {hits}/{run.Rounds} hits`
	local done, res = (Net.Get("Minigame", "ReactFinish") :: RemoteFunction):InvokeServer(run.RunId, hits)
	if done then
		result.Text = `+{Format.Cash(res.Cash)}` .. (if res.ReflexesGained > 0 then `  ·  Reflexes +{res.ReflexesGained}` else "  ·  Reflexes XP")
		result.TextColor3 = Theme.Colors.Success
		HudController:Float(`+{Format.Cash(res.Cash)}`, Theme.Colors.Success, source)
	else
		result.Text = "That run didn't count."
	end
	task.wait(1.6)
	modal.Close()
	UIController:SetMenu("ReactionTest", false)
	busy = false
end

-- Tech Fix ---------------------------------------------------------------------------------------------------

local function techFix(bench: BasePart)
	if busy then
		return
	end
	busy = true
	local ok, job = (Net.Get("Minigame", "TechStart") :: RemoteFunction):InvokeServer()
	if not ok then
		busy = false
		HudController:Toast(if type(job) == "table" and job.NextIn then `No PCs to fix yet (next in {job.NextIn}s)` elseif job == "TooFar" then "Get closer to the bench." else `Can't fix right now ({tostring(job)})`, Theme.Colors.Warning)
		return
	end
	UIController:SetMenu("TechFix", true)
	local overlay = UIController:GetGui("Overlay")
	local closedEarly = false
	local modal = Components.Modal(overlay, { Title = `Fix {job.Neighbor}'s PC`, Width = 0.65, Height = 0.8, OnClose = function()
		closedEarly = true
	end })
	local body = modal.Body
	local status = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.TextMuted, Parent = body })
	local area = New("Frame", { BackgroundColor3 = Color3.fromHex("292524"), Position = UDim2.fromOffset(0, 36), Size = UDim2.new(1, 0, 1, -36), Parent = body })
	Components.Corner(area, Theme.Radius.M)
	local stepDone = false

	-- 1 · Plug: two cables into the motherboard.
	status.Text = "1/3 · Plug the cables back in"
	local plugs = { { "Power", "F87171" }, { "SATA", "22D3EE" } }
	local plugged = 0
	for i, c in plugs do
		local port = New("Frame", { Position = UDim2.new(0.7, 0, 0, 40 + (i - 1) * 110), Size = UDim2.fromOffset(90, 70), BackgroundColor3 = Color3.fromHex("111827"), Parent = area })
		Components.Corner(port, Theme.Radius.S)
		New("UIStroke", { Thickness = 4, Color = Color3.fromHex(c[2]), Parent = port })
		local plug = New("TextLabel", { Position = UDim2.fromOffset(40, 40 + (i - 1) * 110), Size = UDim2.fromOffset(110, 60), BackgroundColor3 = Color3.fromHex(c[2]), Text = c[1], FontFace = Theme.Fonts.Bold, TextSize = 18, TextColor3 = Theme.Colors.Bg, Active = true, ZIndex = 25, Parent = area })
		Components.Corner(plug, Theme.Radius.M)
		local detach: () -> () = function() end
		detach = Drag.Attach(plug, function(pos)
			if Drag.Inside(port, pos) then
				plug.Parent = port
				plug.Position = UDim2.fromScale(0, 0)
				plug.Size = UDim2.fromScale(1, 1)
				plug.Text = "OK"
				detach()
				plugged += 1
				return true
			end
			return false
		end)
	end
	while plugged < #plugs and not closedEarly do
		task.wait(0.1)
	end
	if not closedEarly then
		area:ClearAllChildren()
		-- 2 · Swap: tap the burnt RAM stick, then the new one.
		status.Text = "2/3 · Swap the burnt RAM stick"
		local old = New("TextButton", { Position = UDim2.fromScale(0.2, 0.3), Size = UDim2.fromOffset(160, 50), BackgroundColor3 = Color3.fromHex("7F1D1D"), Text = "🔥 Old RAM", FontFace = Theme.Fonts.Bold, TextSize = 18, TextColor3 = Theme.Colors.Text, Parent = area })
		Components.Corner(old, Theme.Radius.S)
		local fresh = New("TextButton", { Position = UDim2.fromScale(0.6, 0.6), Size = UDim2.fromOffset(160, 50), BackgroundColor3 = Color3.fromHex("166534"), Text = "New RAM", FontFace = Theme.Fonts.Bold, TextSize = 18, TextColor3 = Theme.Colors.Text, Visible = false, Parent = area })
		Components.Corner(fresh, Theme.Radius.S)
		old.Activated:Connect(function()
			old:Destroy()
			fresh.Visible = true
		end)
		fresh.Activated:Connect(function()
			TweenService:Create(fresh, TweenInfo.new(0.3), { Position = UDim2.fromScale(0.2, 0.3) }):Play()
			task.delay(0.35, function()
				stepDone = true
			end)
		end)
		while not stepDone and not closedEarly do
			task.wait(0.1)
		end
	end
	if not closedEarly then
		area:ClearAllChildren()
		-- 3 · Dust: wipe six dust bunnies.
		status.Text = "3/3 · Wipe out the dust"
		local left = 6
		local rng = Random.new()
		for _ = 1, 6 do
			local dust = New("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(rng:NextNumber(0.1, 0.9), rng:NextNumber(0.15, 0.85)), Size = UDim2.fromOffset(70, 70), BackgroundColor3 = Color3.fromHex("A8A29E"), BackgroundTransparency = 0.2, Text = "", Parent = area })
			New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dust })
			local function wipe()
				if dust.Parent then
					left -= 1
					TweenService:Create(dust, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
					task.delay(0.15, dust.Destroy, dust)
				end
			end
			dust.Activated:Connect(wipe)
			dust.MouseEnter:Connect(wipe) -- rubbing over it works on desktop
		end
		while left > 0 and not closedEarly do
			task.wait(0.1)
		end
	end
	if not closedEarly then
		status.Text = "Booting…"
		local done, result = (Net.Get("Minigame", "TechFinish") :: RemoteFunction):InvokeServer(job.JobId)
		if not done and result == "TooFast" then
			task.wait(2)
			done, result = (Net.Get("Minigame", "TechFinish") :: RemoteFunction):InvokeServer(job.JobId)
		end
		if done then
			status.Text = `Fixed! {job.Neighbor} paid {Format.Cash(result.Cash)}`
			status.TextColor3 = Theme.Colors.Success
			HudController:Float(`+{Format.Cash(result.Cash)}`, Theme.Colors.Success, bench)
		else
			status.Text = `Didn't count ({tostring(result)})`
		end
		task.wait(1.4)
		modal.Close()
	end
	UIController:SetMenu("TechFix", false)
	busy = false
end

local function prompt(part: BasePart, action: string, object: string, onTrigger: () -> ()): ProximityPrompt
	local p = New("ProximityPrompt", { ActionText = action, ObjectText = object, MaxActivationDistance = 10, RequiresLineOfSight = false, Parent = part })
	p.Triggered:Connect(onTrigger)
	return p
end

function MinigameController:Start()
	StateController:WaitUntilLoaded()
	-- Public Arcade Corner cabinets. The Hub streams in, so bind them whenever they arrive.
	task.spawn(function()
		local hub = Workspace:WaitForChild("Hub")
		local function bind(d: Instance)
			if d:IsA("BasePart") and d:GetAttribute("Anchor") == "AimCabinet" and not d:FindFirstChildOfClass("ProximityPrompt") then
				prompt(d, "Play", "Aim Trainer", function()
					aimTrainer(d)
				end)
			elseif d:IsA("BasePart") and d:GetAttribute("Anchor") == "ReactionCabinet" and not d:FindFirstChildOfClass("ProximityPrompt") then
				prompt(d, "Play", "Reaction Test", function()
					reactionTest(d)
				end)
			end
		end
		hub.DescendantAdded:Connect(bind)
		for _, d in hub:GetDescendants() do
			bind(d)
		end
	end)
	-- Own plot: cabinet prompt once its screen is on; bench prompt while a job waits.
	task.spawn(function()
		local cabPrompt: ProximityPrompt? = nil
		local benchPrompt: ProximityPrompt? = nil
		local reactPrompt: ProximityPrompt? = nil
		while true do
			-- Café annex Reaction Test cabinet (exists from Stage 2).
			if reactPrompt and not reactPrompt.Parent then
				reactPrompt = nil
			end
			local react = MyPlot.Find("ReactionCabinet")
			if react and react:IsA("BasePart") and not reactPrompt then
				reactPrompt = prompt(react, "Play", "Reaction Test", function()
					reactionTest(react :: BasePart)
				end)
			end
			-- A prompt dies with its part if the part streams out; recreate it then.
			if cabPrompt and not cabPrompt.Parent then
				cabPrompt = nil
			end
			if benchPrompt and not benchPrompt.Parent then
				benchPrompt = nil
			end
			local plot = MyPlot.Model()
			local cab = MyPlot.Find("AimCabinet")
			local screen = plot and plot:FindFirstChild("CabinetScreen", true)
			local on = screen ~= nil and screen:GetAttribute("On") == true
			if cab and cab:IsA("BasePart") and on and not cabPrompt then
				cabPrompt = prompt(cab, "Play", "Aim Trainer", function()
					aimTrainer(cab :: BasePart)
				end)
			elseif cabPrompt and not on then
				cabPrompt:Destroy()
				cabPrompt = nil
			end
			local bench = MyPlot.Find("TechBench")
			local pc = plot and plot:FindFirstChild("NeighborPC", true)
			local ready = pc ~= nil and pc:GetAttribute("JobReady") == true
			if bench and bench:IsA("BasePart") and ready and not benchPrompt then
				benchPrompt = prompt(bench, "Fix PC", "Neighbor's PC", function()
					techFix(bench :: BasePart)
				end)
			elseif benchPrompt and not ready then
				benchPrompt:Destroy()
				benchPrompt = nil
			end
			task.wait(0.5)
		end
	end)
end

return MinigameController

--!strict
-- TeamCreatorController ([[Screen - Team Creator]]): opens pre-filled with an auto-name (one tap to accept).
-- Left: rotating avatar preview in your tee color + logo badge + team name. Right: tabs Name · Logo · Jersey.
-- Name tab also holds the Founder role picker ([[Founder (You)]]). Jersey = tier 1 only ([[Jersey Progression]]):
-- Own Tee + tee color (follows team color by default); later garments show their unlock instead of "???".
-- Confirm calls Team/SetIdentity; the server filters the text (never the client) and drops the banner.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Net = require(ReplicatedStorage.Shared.Net)
local Signal = require(ReplicatedStorage.Shared.Signal)
local Generator = require(ReplicatedStorage.Shared.Generator)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Team = require(ReplicatedStorage.Shared.Config.Team)
local Roles = require(ReplicatedStorage.Shared.Config.Roles)
local Names = require(ReplicatedStorage.Shared.Config.Names)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)

local TeamCreatorController = { Tier = 2 }

local player = Players.LocalPlayer
local rng = Random.new()
local isOpen = false

-- Later Garage garments, shown locked with their unlock ([[Jersey Progression]] → Unlock ladder).
local LOCKED_GARMENTS = { { "Marker Tee", 2 }, { "Thrift Hoodie", 3 }, { "Iron-On Letters", 4 }, { "Matching Tees", 5 } }

local function trim(s: string): string
	return (string.gsub(string.gsub(s, "^%s+", ""), "%s+$", ""))
end

local function autoTag(name: string): string
	local tag, last = "", ""
	for word in string.gmatch(name, "%w+") do
		tag ..= string.upper(string.sub(word, 1, 1))
		last = word
	end
	if #tag < Team.TagMin then
		-- "Garage Squad" → GS + Q → GSQ
		tag ..= string.upper(string.sub(last, 2, 1 + Team.TagMin - #tag))
	end
	return string.sub(tag, 1, Team.TagMax)
end

local function preview(parent: Instance, getColor: () -> Color3): (() -> (), () -> ())
	local vp = New("ViewportFrame", {
		Size = UDim2.fromScale(1, 0.72),
		BackgroundColor3 = Theme.Colors.Panel,
		Ambient = Color3.fromRGB(180, 180, 190),
		LightColor = Color3.new(1, 1, 1),
		Parent = parent,
	})
	Components.Corner(vp, Theme.Radius.L)
	local world = New("WorldModel", { Parent = vp })
	local cam = New("Camera", { FieldOfView = 40, Parent = vp })
	vp.CurrentCamera = cam
	local rig: Model? = nil
	local character = player.Character
	if character then
		character.Archivable = true
		local ok, clone = pcall(function()
			return character:Clone()
		end)
		if ok and clone then
			rig = clone
			for _, d in clone:GetDescendants() do
				if d:IsA("BasePart") then
					d.Anchored = true
				elseif d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Shirt") or d:IsA("ShirtGraphic") then
					d:Destroy()
				end
			end
			clone:PivotTo(CFrame.new(0, 0, 0))
			clone.Parent = world
		end
	end
	cam.CFrame = CFrame.lookAt(Vector3.new(0, 1.2, -9), Vector3.new(0, 0.6, 0))
	local function recolor()
		if not rig then
			return
		end
		local c = getColor()
		for _, name in { "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "Torso" } do
			local p = rig:FindFirstChild(name)
			if p and p:IsA("BasePart") then
				p.Color = c
			end
		end
	end
	local angle = 0
	local conn = RunService.RenderStepped:Connect(function(dt)
		angle += math.rad(20) * dt -- 20°/s
		if rig then
			rig:PivotTo(CFrame.Angles(0, angle, 0))
		end
	end)
	recolor()
	return recolor, function()
		conn:Disconnect()
	end
end

local function swatchRow(parent: Instance, selected: number, onPick: (number) -> ()): (number) -> ()
	local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	New("UIGridLayout", { CellSize = UDim2.fromOffset(Theme.TouchMin, Theme.TouchMin), CellPadding = UDim2.fromOffset(Theme.Space.S, Theme.Space.S), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })
	local strokes = {}
	for i, hex in Team.Colors do
		local b = New("TextButton", { Text = "", BackgroundColor3 = Color3.fromHex(hex), LayoutOrder = i, AutoButtonColor = false, Parent = row })
		Components.Corner(b, Theme.Radius.S)
		local s = New("UIStroke", { Thickness = 3, Color = Theme.Colors.Text, Transparency = if i == selected then 0 else 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = b })
		strokes[i] = s
		b.Activated:Connect(function()
			onPick(i)
		end)
	end
	return function(i: number)
		for j, s in strokes do
			s.Transparency = if j == i then 0 else 1
		end
	end
end

local function label(text: string, parent: Instance, order: number)
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		FontFace = Theme.Fonts.Bold,
		TextSize = Theme.Type.Body,
		TextColor3 = Theme.Colors.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text,
		LayoutOrder = order,
		Parent = parent,
	})
end

local function textBox(parent: Instance, text: string, maxLen: number, order: number, width: number?): TextBox
	local box = New("TextBox", {
		Size = UDim2.new(width or 1, 0, 0, 48),
		BackgroundColor3 = Theme.Colors.Panel,
		FontFace = Theme.Fonts.Bold,
		TextSize = Theme.Type.H2,
		TextColor3 = Theme.Colors.Text,
		PlaceholderColor3 = Theme.Colors.TextMuted,
		ClearTextOnFocus = false,
		Text = text,
		LayoutOrder = order,
		Parent = parent,
	})
	Components.Corner(box, Theme.Radius.M)
	Components.Stroke(box, Theme.Colors.Accent)
	Components.Padding(box, Theme.Space.M, 0)
	box:GetPropertyChangedSignal("Text"):Connect(function()
		if utf8.len(box.Text) and (utf8.len(box.Text) :: number) > maxLen then
			box.Text = string.sub(box.Text, 1, utf8.offset(box.Text, maxLen + 1) - 1)
		end
	end)
	return box
end

-- Opens the creator; yields until a name is accepted (first time) or the panel is closed (rename).
function TeamCreatorController:Open(firstTime: boolean)
	if isOpen then
		return
	end
	isOpen = true
	UIController:SetMenu("TeamCreator", true)
	local overlay = UIController:GetGui("Overlay")
	local team = StateController:Get("Team") or {}
	local founderMinted = (StateController:Get("FounderUuid") or "") ~= ""
	local state = {
		Name = if team.Name and team.Name ~= "" then team.Name else Names.DefaultTeamName,
		Tag = if team.Tag and team.Tag ~= "" then team.Tag else autoTag(Names.DefaultTeamName),
		Role = team.FounderRole or "Flex",
		Primary = (team.Colors and team.Colors.Primary) or Team.DefaultPrimary,
		Tee = (team.Colors and team.Colors.Tee) or Team.DefaultPrimary,
		FollowTeam = not (team.Colors and team.Colors.Tee and team.Colors.Tee ~= team.Colors.Primary),
	}
	local done = Signal.new()
	local modal = Components.Modal(overlay, {
		Title = "Create your team",
		Width = 0.8,
		Height = 0.88,
		NoClose = firstTime,
		OnClose = function()
			done:Fire()
		end,
	})
	local mobile = Components.IsMobile()
	local body = modal.Body

	-- Left: preview.
	local left = New("Frame", { BackgroundTransparency = 1, Size = if mobile then UDim2.new(1, 0, 0.34, 0) else UDim2.new(0.4, -Theme.Space.L, 1, -72), Parent = body })
	local recolor, stopPreview = preview(left, function()
		return Color3.fromHex(Team.Colors[if state.FollowTeam then state.Primary else state.Tee])
	end)
	local badge = New("TextLabel", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromOffset(Theme.Space.M, Theme.Space.M),
		Size = UDim2.fromOffset(64, 64),
		FontFace = Theme.Fonts.Heading,
		TextSize = 22,
		TextColor3 = Theme.Colors.Bg,
		Parent = left,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = badge })
	local bigName = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.74, 0),
		Size = UDim2.new(1, 0, 0.18, 0),
		TextScaled = true,
		FontFace = Theme.Fonts.Marker,
		TextColor3 = Theme.Colors.Text,
		Parent = left,
	})

	-- Right: tabs.
	local right = New("Frame", {
		BackgroundTransparency = 1,
		Position = if mobile then UDim2.new(0, 0, 0.36, 0) else UDim2.new(0.4, 0, 0, 0),
		Size = if mobile then UDim2.new(1, 0, 0.64, -72) else UDim2.new(0.6, 0, 1, -72),
		Parent = body,
	})
	local tabs = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), Parent = right })
	Components.List(tabs, Theme.Space.S, true)
	local pages: { [string]: ScrollingFrame } = {}
	local tabButtons: { [string]: TextButton } = {}
	local function showTab(id: string)
		for k, p in pages do
			p.Visible = k == id
			tabButtons[k].BackgroundColor3 = if k == id then Theme.Colors.Accent else Theme.Colors.Panel
			tabButtons[k].TextColor3 = if k == id then Theme.Colors.Bg else Theme.Colors.Text
		end
	end
	for i, id in { "Name", "Logo", "Jersey" } do
		local b = New("TextButton", { Size = UDim2.fromOffset(120, 44), Text = id, FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Body, LayoutOrder = i, AutoButtonColor = false, Parent = tabs })
		Components.Corner(b, Theme.Radius.M)
		tabButtons[id] = b
		b.Activated:Connect(function()
			showTab(id)
		end)
		local page = New("ScrollingFrame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 56),
			Size = UDim2.new(1, 0, 1, -56),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 6,
			BorderSizePixel = 0,
			Parent = right,
		})
		Components.List(page, Theme.Space.S)
		Components.Padding(page, Theme.Space.XS, Theme.Space.XS)
		pages[id] = page
	end

	-- Name tab: name + 🎲, tag, Founder role.
	local namePage = pages.Name
	label("Team name", namePage, 1)
	local nameRow = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), LayoutOrder = 2, Parent = namePage })
	local nameBox = textBox(nameRow, state.Name, Team.NameMax, 1, 1)
	nameBox.Size = UDim2.new(1, -60, 1, 0)
	local dice = New("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.fromOffset(52, 48), Text = "🎲", TextSize = 26, BackgroundColor3 = Theme.Colors.Panel, Parent = nameRow })
	Components.Corner(dice, Theme.Radius.M)
	label("Tag (3–4 letters)", namePage, 3)
	local tagBox = textBox(namePage, state.Tag, Team.TagMax, 4, 0.4)
	local errorLabel = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.Danger, TextXAlignment = Enum.TextXAlignment.Left, Text = "", LayoutOrder = 5, Parent = namePage })
	label(if founderMinted then "Your Founder role (set)" else "Your Founder role", namePage, 6)
	local roleGrid = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 7, Parent = namePage })
	New("UIGridLayout", { CellSize = UDim2.new(0.5, -Theme.Space.S, 0, 64), CellPadding = UDim2.fromOffset(Theme.Space.S, Theme.Space.S), SortOrder = Enum.SortOrder.LayoutOrder, Parent = roleGrid })
	local roleButtons: { [string]: TextButton } = {}
	local function paintRoles()
		for role, b in roleButtons do
			local on = role == state.Role
			b.BackgroundColor3 = if on then Theme.Colors.Accent2 else Theme.Colors.Panel
		end
	end
	for i, role in Roles.Order do
		local b = New("TextButton", {
			Text = `<b>{role}</b>\n<font size="14">{Roles.Blurb[role]}</font>`,
			RichText = true,
			TextWrapped = true,
			FontFace = Theme.Fonts.Body,
			TextSize = 18,
			TextColor3 = Theme.Colors.Text,
			LayoutOrder = i,
			AutoButtonColor = false,
			Parent = roleGrid,
		})
		Components.Corner(b, Theme.Radius.M)
		roleButtons[role] = b
		b.Activated:Connect(function()
			if not founderMinted then
				state.Role = role
				paintRoles()
			end
		end)
	end
	paintRoles()

	-- Logo tab: team colors (shape + icon grids arrive with the Logo pass).
	label("Team color (banner, logo, LED strips later)", pages.Logo, 1)
	local setPrimary: (number) -> () = function() end
	-- Jersey tab: Own Tee + tee color, locked garments.
	label("Garment", pages.Jersey, 1)
	local garments = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = pages.Jersey })
	New("UIGridLayout", { CellSize = UDim2.fromOffset(120, 72), CellPadding = UDim2.fromOffset(Theme.Space.S, Theme.Space.S), SortOrder = Enum.SortOrder.LayoutOrder, Parent = garments })
	local own = New("TextLabel", { Text = "Own Tee\nequipped", TextWrapped = true, FontFace = Theme.Fonts.Bold, TextSize = 16, TextColor3 = Theme.Colors.Bg, BackgroundColor3 = Theme.Colors.Success, LayoutOrder = 0, Parent = garments })
	Components.Corner(own, Theme.Radius.M)
	for i, g in LOCKED_GARMENTS do
		local l = New("TextLabel", { Text = `🔒 {g[1]}\nHQ Lv {g[2]}`, TextWrapped = true, FontFace = Theme.Fonts.Body, TextSize = 14, TextColor3 = Theme.Colors.TextMuted, BackgroundColor3 = Theme.Colors.Panel, LayoutOrder = i, Parent = garments })
		Components.Corner(l, Theme.Radius.M)
	end
	label("Tee color", pages.Jersey, 3)
	local follow = New("TextButton", { Size = UDim2.fromOffset(260, 44), FontFace = Theme.Fonts.Bold, TextSize = 16, TextColor3 = Theme.Colors.Text, BackgroundColor3 = Theme.Colors.Panel, LayoutOrder = 4, Parent = pages.Jersey })
	Components.Corner(follow, Theme.Radius.M)
	local teeHolder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 5, Parent = pages.Jersey })
	local refresh: () -> () = function() end
	local setTee = swatchRow(teeHolder, state.Tee, function(i)
		state.Tee = i
		state.FollowTeam = false
		refresh()
	end)

	refresh = function()
		local primary = Color3.fromHex(Team.Colors[state.Primary])
		badge.BackgroundColor3 = primary
		badge.Text = state.Tag
		bigName.Text = state.Name
		bigName.TextColor3 = primary
		follow.Text = if state.FollowTeam then "ON · Follow team color" else "OFF · Follow team color"
		setTee(if state.FollowTeam then state.Primary else state.Tee)
		recolor()
	end
	local primaryHolder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = pages.Logo })
	setPrimary = swatchRow(primaryHolder, state.Primary, function(i)
		state.Primary = i
		setPrimary(i)
		refresh()
	end)
	follow.Activated:Connect(function()
		state.FollowTeam = not state.FollowTeam
		refresh()
	end)

	nameBox:GetPropertyChangedSignal("Text"):Connect(function()
		local tagWasAuto = tagBox.Text == autoTag(state.Name)
		state.Name = nameBox.Text
		if tagWasAuto then
			tagBox.Text = autoTag(state.Name) -- auto-filled from the name until edited
		end
		errorLabel.Text = ""
		refresh()
	end)
	tagBox:GetPropertyChangedSignal("Text"):Connect(function()
		local clean = string.upper(string.gsub(tagBox.Text, "[^%w]", ""))
		if clean ~= tagBox.Text then
			tagBox.Text = clean
			return
		end
		state.Tag = clean
		errorLabel.Text = ""
		refresh()
	end)
	dice.Activated:Connect(function()
		local name, tag = Generator.TeamName(rng)
		nameBox.Text = name
		tagBox.Text = tag
		TweenService:Create(dice, TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 4, true), { Rotation = 15 }):Play()
	end)

	-- Confirm: disabled until the name/tag look valid (UX only; the server re-validates and filters).
	local confirm, setEnabled = Components.Button({ Text = "Confirm", Width = 260 })
	confirm.AnchorPoint = Vector2.new(0.5, 1)
	confirm.Position = UDim2.fromScale(0.5, 1)
	confirm.Parent = body
	UIController:RegisterTarget("TeamConfirm", confirm)
	local pending = false
	local function valid(): boolean
		local n = trim(state.Name)
		local len = utf8.len(n) or 0
		return len >= 1 and len <= Team.NameMax and #state.Tag >= Team.TagMin and #state.Tag <= Team.TagMax
	end
	RunService.Heartbeat:Connect(function()
		if confirm.Parent then
			setEnabled(valid() and not pending)
		end
	end)
	local remote = Net.Get("Team", "SetIdentity") :: RemoteFunction
	confirm.Activated:Connect(function()
		if pending or not valid() then
			return
		end
		pending = true
		confirm.Text = "Checking…"
		local tee = if state.FollowTeam then state.Primary else state.Tee
		local ok, result = remote:InvokeServer(trim(state.Name), state.Tag, state.Role, state.Primary, tee)
		pending = false
		confirm.Text = "Confirm"
		if ok then
			HudController:Toast(`Welcome, {result.Name} [{result.Tag}]!`, Theme.Colors.Success)
			modal.Close()
		elseif result == "Filtered" then
			errorLabel.Text = "That name isn't allowed. Try another or randomize."
			showTab("Name")
		elseif result == "BadTag" then
			errorLabel.Text = "Tags are 3–4 letters or numbers."
			showTab("Name")
		elseif result == "RateLimited" then
			errorLabel.Text = "One sec…"
		else
			errorLabel.Text = `Couldn't save that ({tostring(result)}). Try again.`
		end
	end)

	showTab("Name")
	refresh()
	done:Wait()
	stopPreview()
	UIController:RegisterTarget("TeamConfirm", nil)
	UIController:SetMenu("TeamCreator", false)
	isOpen = false
end

return TeamCreatorController

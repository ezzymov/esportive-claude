--!strict
-- Greybox helpers shared by the server world builder and client-side Stages (intro, match broadcast).
-- Build.Part(parent, name, size, cframe, color, props?) → anchored Part. Build.Text(part, face, text, props?) → label.

local Build = {}

local function toColor(c: any): Color3
	if typeof(c) == "Color3" then
		return c
	end
	return Color3.fromHex(c)
end

function Build.Part(parent: Instance?, name: string, size: Vector3, cf: CFrame, color: any, props: { [string]: any }?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = toColor(color)
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if props then
		for k, v in props do
			(p :: any)[k] = v
		end
	end
	p.Parent = parent
	return p
end

-- Vertical cylinder (axis along Y) of the given height and diameter.
function Build.Cylinder(parent: Instance?, name: string, height: number, diameter: number, pos: Vector3, color: any, props: { [string]: any }?): Part
	local p = Build.Part(nil, name, Vector3.new(height, diameter, diameter), CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)), color, props)
	p.Shape = Enum.PartType.Cylinder
	p.Parent = parent
	return p
end

function Build.Model(parent: Instance?, name: string): Model
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

-- SurfaceGui with one scaled TextLabel. Returns the label (its parent is the SurfaceGui).
function Build.Text(part: BasePart, face: Enum.NormalId, text: string, props: { [string]: any }?): TextLabel
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0.2
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
	if props then
		for k, v in props do
			(label :: any)[k] = v
		end
	end
	label.Parent = gui
	gui.Parent = part
	return label
end

-- Overhead nameplate (BillboardGui) above a part.
function Build.Nameplate(adornee: BasePart, text: string, color: Color3?, sub: string?): BillboardGui
	local board = Instance.new("BillboardGui")
	board.Name = "Nameplate"
	board.Size = UDim2.fromOffset(200, 50)
	board.StudsOffset = Vector3.new(0, 3, 0)
	board.MaxDistance = 60
	board.Adornee = adornee
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0.6, 0)
	label.TextScaled = true
	label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.4
	label.Text = text
	label.Parent = board
	if sub then
		local s = label:Clone()
		s.Position = UDim2.fromScale(0, 0.6)
		s.Size = UDim2.fromScale(1, 0.4)
		s.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
		s.TextColor3 = Color3.fromHex("94A3B8")
		s.Text = sub
		s.Parent = board
	end
	board.Parent = adornee
	return board
end

return Build

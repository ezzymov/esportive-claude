-- Loading screen: holds until the client has the profile snapshot (LocalPlayer attribute "StateReady",
-- set by StateController), so the HUD never flashes default values ([[Data Persistence]] → Player-facing).
-- ReplicatedFirst runs before ReplicatedStorage replicates, so colors are copied from Theme here.

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")

local BG = Color3.fromHex("0F1426")
local ACCENT = Color3.fromHex("22D3EE")
local MUTED = Color3.fromHex("94A3B8")
local FONT = "rbxasset://fonts/families/GothamSSm.json"

local player = Players.LocalPlayer
ReplicatedFirst:RemoveDefaultLoadingScreen()

local gui = Instance.new("ScreenGui")
gui.Name = "LoadingScreen"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = BG
bg.Active = true
bg.Parent = gui

local function label(text, weight, sizeScale, color, y)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Position = UDim2.fromScale(0.5, y)
	l.Size = UDim2.fromScale(0.9, sizeScale)
	l.TextScaled = true
	l.FontFace = Font.new(FONT, weight)
	l.TextColor3 = color
	l.Text = text
	l.Parent = bg
	return l
end

label("eSports Tycoon", Enum.FontWeight.Heavy, 0.08, ACCENT, 0.45)
local status = label("Loading your save", Enum.FontWeight.Medium, 0.035, MUTED, 0.54)

gui.Parent = player:WaitForChild("PlayerGui")

local dots = 0
while not player:GetAttribute("StateReady") do
	dots = (dots + 1) % 4
	status.Text = "Loading your save" .. string.rep(".", dots)
	task.wait(0.4)
end

local fade = TweenInfo.new(0.25)
TweenService:Create(bg, fade, { BackgroundTransparency = 1 }):Play()
for _, child in bg:GetChildren() do
	TweenService:Create(child, fade, { TextTransparency = 1 }):Play()
end
task.wait(0.25)
gui:Destroy()

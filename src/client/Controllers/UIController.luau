--!strict
-- UIController: owns the ScreenGuis from StarterGui and their UIScale (mobile-first, [[UI Style Guide]]).
-- UIScale = clamp(short screen side / 1080, Min, Max); every size inside is in 1080p design units.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Theme = require(ReplicatedStorage.Shared.Config.Theme)

local UIController = { Tier = 1 }

local scales: { UIScale } = {}

local function computeScale(): number
	local camera = Workspace.CurrentCamera
	local size = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local short = math.min(size.X, size.Y)
	return math.clamp(short / Theme.Scale.DesignHeight, Theme.Scale.Min, Theme.Scale.Max)
end

local function refresh()
	local s = computeScale()
	for _, scale in scales do
		scale.Scale = s
	end
end

-- Returns the named ScreenGui from PlayerGui, with a managed UIScale.
function UIController:GetGui(name: string): ScreenGui
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = playerGui:WaitForChild(name) :: ScreenGui
	local scale = gui:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = gui
	end
	if not table.find(scales, scale :: UIScale) then
		table.insert(scales, scale :: UIScale)
		refresh()
	end
	return gui
end

-- Menus + cinematics: the tutorial stall clock pauses while either is up ([[Tutorial & Onboarding]] → Stall ladder);
-- the HUD hides during cinematics ([[Screen - Main HUD]]).
local Signal = require(ReplicatedStorage.Shared.Signal)

UIController.Changed = Signal.new() -- fires when menus / cinematic / UI targets change
local menus: { [string]: boolean } = {}
local cinematic: { [string]: boolean } = {}
local targets: { [string]: GuiObject } = {}

function UIController:SetMenu(name: string, open: boolean)
	menus[name] = if open then true else nil
	UIController.Changed:Fire()
end

function UIController:IsMenuOpen(): boolean
	return next(menus) ~= nil
end

function UIController:SetCinematic(name: string, on: boolean)
	cinematic[name] = if on then true else nil
	local hud = Players.LocalPlayer:FindFirstChild("PlayerGui") and Players.LocalPlayer.PlayerGui:FindFirstChild("HUD")
	if hud and hud:GetAttribute("Ready") then
		(hud :: ScreenGui).Enabled = next(cinematic) == nil
	end
	UIController.Changed:Fire()
end

function UIController:IsCinematic(): boolean
	return next(cinematic) ~= nil
end

-- UI targets the tutorial can point at ("PickupButton", "CrateButton", "HireButton", "TeamConfirm").
function UIController:RegisterTarget(name: string, gui: GuiObject?)
	targets[name] = gui
	UIController.Changed:Fire()
end

function UIController:GetTarget(name: string): GuiObject?
	local t = targets[name]
	if t and t.Parent and t.Visible then
		return t
	end
	return nil
end

function UIController:Start()
	local function watchCamera()
		local camera = Workspace.CurrentCamera
		if camera then
			camera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh)
		end
		refresh()
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
	watchCamera()
end

return UIController

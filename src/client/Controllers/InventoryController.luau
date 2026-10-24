--!strict
-- InventoryController ([[Screen - Main HUD]] rail #4 Inventory, purple, from the first case / Stage 2):
--   Cases (owned crates → [[Screen - Case Opening]]) · Parts · Accessories. Badge = crates waiting to be opened.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local MyPlot = require(script.Parent.Parent.UI.MyPlot)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)
local CaseController = require(script.Parent.CaseController)
local GearController = require(script.Parent.GearController)

local InventoryController = { Tier = 7 }

local isOpen = false

function InventoryController:Open(tab: string?)
	if isOpen then
		return
	end
	isOpen = true
	UIController:SetMenu("Inventory", true)
	local overlay = UIController:GetGui("Overlay")
	local cleanup: (() -> ())? = nil
	local modal = Components.Modal(overlay, { Title = "Inventory", Width = 0.82, Height = 0.86, OnClose = function()
		isOpen = false
		if cleanup then
			cleanup()
		end
		UIController:SetMenu("Inventory", false)
	end })
	local content = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 1, -52), Parent = modal.Body })
	Components.Tabs(modal.Body, {
		{ Id = "Cases", Label = "📦 Cases" },
		{ Id = "Parts", Label = "🖥 Parts" },
		{ Id = "Accessories", Label = "🖱 Accessories" },
	}, tab or "Cases", function(id)
		if cleanup then
			cleanup()
			cleanup = nil
		end
		content:ClearAllChildren()
		if id == "Cases" then
			cleanup = CaseController:RenderShelf(content, "Owned", function()
				modal.Close()
			end)
		elseif id == "Parts" then
			cleanup = GearController:RenderParts(content)
		else
			cleanup = GearController:RenderAccessories(content)
		end
	end)
end

function InventoryController:Start()
	StateController:WaitUntilLoaded()
	HudController:WaitUntilShown()
	HudController:AddRail("Left", "Inventory", { Icon = "🎒", Label = "Inventory", Color = Color3.fromHex("7C3AED"), Order = 4, OnClick = function()
		InventoryController:Open()
	end })
	local function refresh()
		local cases = StateController:Get("Inventory.Cases") or {}
		local n = 0
		for _, c in cases do
			n += c
		end
		local stage = StateController:Get("Stage") or 1
		HudController:ShowRail("Inventory", stage >= 2 or n > 0 and (StateController:Get("CaseStats.Opened") or 0) > 0)
		-- The FTUE crate has its own button; count the rest.
		local waiting = n - (cases.StarterCrate or 0)
		HudController:SetBadge("Inventory", if waiting > 0 then tostring(waiting) else nil)
	end
	StateController:Observe("Inventory.Cases", refresh)
	StateController:Observe("Stage", refresh)
	-- Café case vault pedestal → owned crates.
	task.spawn(function()
		local prompt: ProximityPrompt? = nil
		while true do
			if prompt and not prompt.Parent then
				prompt = nil
			end
			local vault = MyPlot.Find("CaseVault")
			if vault and vault:IsA("BasePart") and not prompt then
				prompt = New("ProximityPrompt", { ActionText = "Open crates", ObjectText = "Case Vault", MaxActivationDistance = 10, RequiresLineOfSight = false, Parent = vault })
				;(prompt :: ProximityPrompt).Triggered:Connect(function()
					InventoryController:Open("Cases")
				end)
			end
			task.wait(0.5)
		end
	end)
end

return InventoryController

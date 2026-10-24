--!strict
-- ShopController ([[Screen - Main HUD]] rail #3 Shop, green, from Stage 2): the Shop screen with tabs
--   Cases (buy crates → [[Screen - Case Opening]]) · Tech Shop ([[Screen - Tech Shop]]).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Components = require(script.Parent.Parent.UI.Components)
local New = require(script.Parent.Parent.UI.New)
local MyPlot = require(script.Parent.Parent.UI.MyPlot)
local StateController = require(script.Parent.StateController)
local UIController = require(script.Parent.UIController)
local HudController = require(script.Parent.HudController)
local CaseController = require(script.Parent.CaseController)
local TechShopController = require(script.Parent.TechShopController)

local ShopController = { Tier = 7 }

local STAGE = 2
local isOpen = false

function ShopController:Open(tab: string?)
	if isOpen then
		return
	end
	isOpen = true
	UIController:SetMenu("Shop", true)
	local overlay = UIController:GetGui("Overlay")
	local cleanup: (() -> ())? = nil
	local modal: Components.Modal
	modal = Components.Modal(overlay, { Title = "Shop", Width = 0.82, Height = 0.86, OnClose = function()
		isOpen = false
		if cleanup then
			cleanup()
		end
		UIController:SetMenu("Shop", false)
	end })
	local content = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 1, -52), Parent = modal.Body })
	Components.Tabs(modal.Body, { { Id = "Cases", Label = "📦 Cases" }, { Id = "Tech", Label = "🛠 Tech Shop" } }, tab or "Cases", function(id)
		if cleanup then
			cleanup()
			cleanup = nil
		end
		content:ClearAllChildren()
		if id == "Cases" then
			cleanup = CaseController:RenderShelf(content, "Shop")
		else
			cleanup = TechShopController:Render(content)
		end
	end)
end

function ShopController:Start()
	StateController:WaitUntilLoaded()
	HudController:WaitUntilShown()
	HudController:AddRail("Left", "Shop", { Icon = "🛒", Label = "Shop", Color = Theme.Colors.Success, Order = 3, OnClick = function()
		ShopController:Open()
	end })
	StateController:Observe("Stage", function(stage)
		HudController:ShowRail("Shop", (stage or 1) >= STAGE)
	end)
	-- Café Tech Shop counter → this screen on the Tech tab (the part streams in, so keep checking).
	task.spawn(function()
		local prompt: ProximityPrompt? = nil
		while true do
			if prompt and not prompt.Parent then
				prompt = nil
			end
			local counter = MyPlot.Find("TechCounter")
			if counter and counter:IsA("BasePart") and not prompt then
				prompt = New("ProximityPrompt", { ActionText = "Tech Shop", ObjectText = "Counter", MaxActivationDistance = 10, RequiresLineOfSight = false, Parent = counter })
				;(prompt :: ProximityPrompt).Triggered:Connect(function()
					ShopController:Open("Tech")
				end)
			end
			task.wait(0.5)
		end
	end)
end

return ShopController

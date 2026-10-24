--!strict
-- SystemController: shows the "Updating… progress saved" overlay on Remotes/System/ServerClosing.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local Components = require(script.Parent.Parent.UI.Components)
local UIController = require(script.Parent.UIController)

local SystemController = { Tier = 2 }

function SystemController:Start()
	local gui = UIController:GetGui("Overlay")
	local shown: Frame? = nil
	Net.Get("System", "ServerClosing").OnClientEvent:Connect(function(reasonText: string)
		if shown then
			return
		end
		shown = Components.Overlay(gui, "Saving…", tostring(reasonText))
	end)
end

return SystemController

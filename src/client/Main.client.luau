-- Client entry point: boots every Controller in StarterPlayerScripts/Controllers (Init all, then Start all).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Shared.Loader)

Loader.Load(script.Parent:WaitForChild("Controllers"))

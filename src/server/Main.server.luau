-- Server entry point: boots every Service in ServerScriptService/Services (Init all, then Start all).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Shared.Loader)

Loader.Load(script.Parent.Services)

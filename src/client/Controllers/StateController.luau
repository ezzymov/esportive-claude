--!strict
-- StateController: read-only mirror of the profile, kept current by Remotes/State/Delta (path, value).
-- Path "" is the full snapshot the server sends once the profile loads. Deltas before it are ignored
-- (the snapshot already contains them). UI reads from here and never writes; the server owns all data.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local Path = require(ReplicatedStorage.Shared.Path)
local Signal = require(ReplicatedStorage.Shared.Signal)

local StateController = { Tier = 0 }

StateController.IsLoaded = false
StateController.Loaded = Signal.new()

local mirror: any = nil
local observers: { { Path: string, Fn: (any) -> () } } = {}

local function notify(changedPath: string)
	for _, o in table.clone(observers) do
		if Path.Related(o.Path, changedPath) then
			task.spawn(o.Fn, Path.Get(mirror, o.Path))
		end
	end
end

local function apply(path: string, value: any)
	if path == "" then
		mirror = value
		local first = not StateController.IsLoaded
		StateController.IsLoaded = true
		notify("")
		if first then
			StateController.Loaded:Fire()
			Players.LocalPlayer:SetAttribute("StateReady", true) -- ReplicatedFirst loading screen waits on this
		end
		return
	end
	if not StateController.IsLoaded then
		return
	end
	local parent, key = Path.Parent(mirror, path)
	if parent and key then
		parent[key] = value
		notify(path)
	end
end

-- Current value at a dot path (nil before load). Treat returned tables as read-only.
function StateController:Get(path: string): any
	return if mirror then Path.Get(mirror, path) else nil
end

-- Calls fn(value) now (if loaded) and whenever the path, an ancestor, or a descendant changes.
function StateController:Observe(path: string, fn: (any) -> ()): () -> ()
	local entry = { Path = path, Fn = fn }
	table.insert(observers, entry)
	if StateController.IsLoaded then
		task.spawn(fn, self:Get(path))
	end
	return function()
		local i = table.find(observers, entry)
		if i then
			table.remove(observers, i)
		end
	end
end

function StateController:WaitUntilLoaded()
	if not StateController.IsLoaded then
		StateController.Loaded:Wait()
	end
end

function StateController:Init()
	Net.Get("State", "Delta").OnClientEvent:Connect(apply)
end

return StateController

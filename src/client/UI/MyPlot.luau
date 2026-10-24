--!strict
-- Client lookups on your own plot: the plot model, its origin frame, and parts by "Anchor" attribute
-- (FounderDesk, FounderSeat, AimCabinet, TechBench, Pad_Mouse, FreeAgentBoard…). Streaming-safe: lookups can return
-- nil until the part streams in, so callers retry.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local MyPlot = {}

local player = Players.LocalPlayer

function MyPlot.Index(): number?
	return player:GetAttribute("PlotIndex") :: number?
end

function MyPlot.Model(): Model?
	local index = MyPlot.Index()
	local plots = Workspace:FindFirstChild("Plots")
	return if index and plots then plots:FindFirstChild("Plot" .. index) :: Model? else nil
end

function MyPlot.Wait(timeout: number?): Model?
	local deadline = os.clock() + (timeout or 30)
	while os.clock() < deadline do
		local m = MyPlot.Model()
		if m and m:GetAttribute("Origin") then
			return m
		end
		task.wait(0.1)
	end
	return nil
end

function MyPlot.Origin(): CFrame?
	local m = MyPlot.Model()
	return if m then m:GetAttribute("Origin") :: CFrame? else nil
end

-- First BasePart (or Model) under your plot with Anchor == name.
function MyPlot.Find(name: string): Instance?
	local m = MyPlot.Model()
	if not m then
		return nil
	end
	for _, d in m:GetDescendants() do
		if d:GetAttribute("Anchor") == name and (d:IsA("BasePart") or d:IsA("Model")) then
			return d
		end
	end
	return nil
end

-- World position of an anchor's object (model pivot or part position).
function MyPlot.Position(name: string): Vector3?
	local inst = MyPlot.Find(name)
	if not inst then
		return nil
	end
	if inst:IsA("Model") then
		return inst:GetPivot().Position
	end
	return (inst :: BasePart).Position
end

return MyPlot

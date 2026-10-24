--!strict
-- Plot and garage coordinate frames from Config/World, shared so client Stages (intro cutscene) line up with the
-- server-built plot. Plot i sits at angle (i-1)·60° around the plaza; its local +Z faces the ring road.

local World = require(script.Parent.Config.World)

local PlotFrame = {}

function PlotFrame.Angle(index: number): number
	return math.rad((index - 1) * 360 / World.PlotCount)
end

-- Unit vector from the plaza center out through plot `index`.
function PlotFrame.Direction(angle: number): Vector3
	return Vector3.new(math.sin(angle), 0, -math.cos(angle))
end

-- Origin = front-center of the plot on the road edge. LookVector points away from the plaza (back of the plot).
function PlotFrame.Plot(index: number): CFrame
	local dir = PlotFrame.Direction(PlotFrame.Angle(index))
	local front = dir * World.PlotFrontRadius
	return CFrame.lookAt(front, front + dir)
end

function PlotFrame.Garage(plotCF: CFrame): CFrame
	return plotCF * CFrame.new(World.Garage.Offset)
end

-- World CFrame of a garage anchor (World.Garage.Anchors[name]).
function PlotFrame.Anchor(plotCF: CFrame, name: string): CFrame
	local a = World.Garage.Anchors[name]
	assert(a, `[PlotFrame] unknown anchor {name}`)
	return PlotFrame.Garage(plotCF) * CFrame.new(a[1]) * CFrame.Angles(0, math.rad(a[2]), 0)
end

return PlotFrame

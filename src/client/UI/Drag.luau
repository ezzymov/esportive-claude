--!strict
-- Drag a GuiObject with mouse or touch. onDrop(screenPos) returns true to keep it there; otherwise it snaps back.
-- Used by the cable minigames (PC setup, Tech Fix).

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Drag = {}

-- True if a screen point is inside a GuiObject.
function Drag.Inside(gui: GuiObject, pos: Vector2): boolean
	local a, s = gui.AbsolutePosition, gui.AbsoluteSize
	return pos.X >= a.X and pos.X <= a.X + s.X and pos.Y >= a.Y and pos.Y <= a.Y + s.Y
end

function Drag.Attach(handle: GuiObject, onDrop: (Vector2) -> boolean): () -> ()

	local dragging: InputObject? = nil
	local startPos: Vector2 = Vector2.zero
	local startUdim: UDim2 = handle.Position
	local scale = 1
	local conns = {}
	local function currentScale(): number
		-- Screen pixels per design pixel (UIScale on the ScreenGui).
		local gui = handle:FindFirstAncestorOfClass("ScreenGui")
		local s = gui and gui:FindFirstChildOfClass("UIScale")
		return if s then s.Scale else 1
	end
	table.insert(conns, handle.InputBegan:Connect(function(input)
		if dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = input
			startPos = Vector2.new(input.Position.X, input.Position.Y)
			startUdim = handle.Position
			-- Screen px per design px: from the handle itself (covers ScreenGui + modal UIScales).
			scale = if handle.Size.X.Offset > 0 then handle.AbsoluteSize.X / handle.Size.X.Offset else currentScale()
			handle.ZIndex += 5
		end
	end))
	table.insert(conns, UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		local move = input.UserInputType == Enum.UserInputType.MouseMovement or (input.UserInputType == Enum.UserInputType.Touch and input == dragging)
		if move then
			local delta = (Vector2.new(input.Position.X, input.Position.Y) - startPos) / scale
			handle.Position = startUdim + UDim2.fromOffset(delta.X, delta.Y)
		end
	end))
	table.insert(conns, UserInputService.InputEnded:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input == dragging then
			dragging = nil
			handle.ZIndex -= 5
			local center = handle.AbsolutePosition + handle.AbsoluteSize / 2
			if not onDrop(center) then
				TweenService:Create(handle, TweenInfo.new(0.15), { Position = startUdim }):Play()
			end
		end
	end))
	return function()
		for _, c in conns do
			c:Disconnect()
		end
	end
end

return Drag

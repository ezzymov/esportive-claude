--!strict
-- Server gameplay event bus. Services fire facts ("PlayerHired", "PickupFinished"…); TutorialService and
-- AnalyticsService listen. Keeps feature services from requiring the tutorial (no require cycles).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Shared.Signal)

local Bus = {}

local signal = Signal.new()

function Bus.Fire(player: Player, event: string, payload: any?)
	signal:Fire(player, event, payload)
end

-- fn(player, event, payload)
function Bus.On(fn: (Player, string, any) -> ())
	return signal:Connect(fn)
end

return Bus

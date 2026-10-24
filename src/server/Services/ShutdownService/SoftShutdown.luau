--!strict
-- Fallback for "Shut Down All Servers" / emergency fixes. Normal releases use Migrate To Latest Update.
-- Closing server: teleport everyone to a reserved server with TeleportData.SoftShutdown = true.
-- Reserved server: show the overlay, wait for old servers to close, send everyone to a public server together.
-- Teleports don't run in Studio; ShutdownService skips this there.

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local SoftShutdown = {}

local ARRIVAL_WAIT = 5

local function kickAll(message: string)
	for _, player in Players:GetPlayers() do
		player:Kick(message)
	end
end

function SoftShutdown.MovePlayers(message: string)
	local players = Players:GetPlayers()
	if #players == 0 then
		return
	end
	local ok, err = pcall(function()
		local options = Instance.new("TeleportOptions")
		options.ShouldReserveServer = true
		options:SetTeleportData({ SoftShutdown = true })
		TeleportService:TeleportAsync(game.PlaceId, players, options)
	end)
	if not ok then
		warn(`[SoftShutdown] teleport failed, kicking: {err}`)
		kickAll(message) -- saves are already done, so a kick is safe
		return
	end
	-- Anyone still here after the teleport window gets the same message.
	task.wait(8)
	kickAll(message)
end

local function isSoftShutdownArrival(player: Player): boolean
	local joinData = player:GetJoinData()
	local data = joinData and joinData.TeleportData
	return type(data) == "table" and data.SoftShutdown == true
end

-- On the reserved server: hold arrivals briefly, then move them all to a fresh public server.
function SoftShutdown.HandleArrivals(message: string, closingRemote: RemoteEvent)
	if game.PrivateServerId == "" or game.PrivateServerOwnerId ~= 0 then
		return -- only reserved servers (not public, not VIP)
	end
	local function onPlayer(player: Player)
		if not isSoftShutdownArrival(player) then
			return
		end
		closingRemote:FireClient(player, message)
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, p in Players:GetPlayers() do
		onPlayer(p)
	end

	-- Batch everyone present every few seconds so parties travel together and late arrivals aren't stranded.
	while true do
		task.wait(ARRIVAL_WAIT)
		local players = Players:GetPlayers()
		if #players > 0 then
			local ok, err = pcall(TeleportService.TeleportAsync, TeleportService, game.PlaceId, players)
			if not ok then
				warn(`[SoftShutdown] return teleport failed: {err}`)
			end
		end
	end
end

return SoftShutdown

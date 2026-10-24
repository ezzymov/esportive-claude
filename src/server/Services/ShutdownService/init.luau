--!strict
-- ShutdownService: the one BindToClose ([[Shutdown & Update Handling]]).
-- 1. stop new work → 2. flushers (parallel) → 3. soft shutdown (live servers only) → 4. wait for profile release.
-- Other services register a flusher; they never bind their own BindToClose.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Lib = script.Parent.Parent.Lib
local Remote = require(Lib.Remote)
local Log = require(Lib.Log)
local DataService = require(script.Parent.DataService)
local SoftShutdown = require(script.SoftShutdown)

local ShutdownService = { Tier = 0 }

ShutdownService.IsClosing = false
ShutdownService.Message = "Updating eSports Tycoon. Your progress is saved. Moving you to a new server…"

local BUDGET = 25 -- seconds; 5 s margin under Roblox's 30 s
local flushers: { [string]: () -> () } = {}
local closingRemote: RemoteEvent

function ShutdownService:RegisterFlusher(name: string, fn: () -> ())
	flushers[name] = fn
end

-- Runs every flusher in its own thread; returns when all finish or the deadline hits.
function ShutdownService:RunFlushers(timeout: number)
	local remaining = 0
	for name, fn in flushers do
		remaining += 1
		task.spawn(function()
			local ok, err = pcall(fn)
			if not ok then
				warn(`[Shutdown] flusher {name} failed: {err}`)
			end
			remaining -= 1
		end)
	end
	local deadline = os.clock() + timeout
	while remaining > 0 and os.clock() < deadline do
		task.wait()
	end
	if remaining > 0 then
		Log.Event("shutdown_flush_timeout", nil, `{remaining} flusher(s) still running`)
	end
end

local function onClose()
	local started = os.clock()
	ShutdownService.IsClosing = true -- 1. stop new work
	DataService.IsClosing = true
	closingRemote:FireAllClients(ShutdownService.Message)

	ShutdownService:RunFlushers(BUDGET * 0.4) -- 2.

	if not RunService:IsStudio() and #Players:GetPlayers() > 0 then
		DataService:ReleaseAll() -- save + unlock first so the next server can take the lock at once
		DataService:WaitForAllReleased(BUDGET * 0.3)
		SoftShutdown.MovePlayers(ShutdownService.Message) -- 3.
	end

	DataService:ReleaseAll() -- 4.
	DataService:WaitForAllReleased(math.max(0, BUDGET - (os.clock() - started)))
end

function ShutdownService:Init()
	closingRemote = Remote.Push("System", "ServerClosing")

	-- Every client remote returns "ServerClosing" once shutdown starts.
	Remote.AddGuard(function()
		return if ShutdownService.IsClosing then "ServerClosing" else nil
	end)

	ShutdownService:RegisterFlusher("DataService", function()
		DataService:StampLastSeen()
	end)

	game:BindToClose(onClose)
end

function ShutdownService:Start()
	SoftShutdown.HandleArrivals(ShutdownService.Message, closingRemote)
end

return ShutdownService

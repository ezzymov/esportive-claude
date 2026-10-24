--!strict
-- EconomyService: Transact is the ONLY way a currency changes ([[Security & Anti-Exploit]] rule 4).
-- Every call is checked (known currency, whole finite numbers, no negative balance, Fame never spent),
-- logged, and recorded in DataService's ledger so the save guard can verify it.
-- Also owns the station income tick and offline earnings (capped at 4 h).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lib = script.Parent.Parent.Lib
local Remote = require(Lib.Remote)
local Log = require(Lib.Log)
local DataService = require(script.Parent.DataService)
local ShutdownService = require(script.Parent.ShutdownService)
local AnalyticsService = require(script.Parent.AnalyticsService)
local Economy = require(ReplicatedStorage.Shared.Config.Economy)

local EconomyService = { Tier = 1 }

local LOG_TICK_EVERY = 60 -- seconds; income ticks are summarized, not logged one by one

local isCurrency: { [string]: boolean } = {}
for _, name in Economy.Currencies do
	isCurrency[name] = true
end

type Earner = { Remainder: number, LastTick: number, Logged: number, LastLog: number }
local earners: { [Player]: Earner } = {}
local offlineRemote: RemoteEvent

local function isWhole(n: any): boolean
	return type(n) == "number" and n == n and n % 1 == 0 and math.abs(n) < 2 ^ 53
end

-- deltas: { Cash = 100, Gems = -5 }. Returns (true) or (false, reason). All-or-nothing.
function EconomyService:Transact(player: Player, deltas: { [string]: number }, reason: string): (boolean, string?)
	if type(reason) ~= "string" or reason == "" then
		return false, "NoReason"
	end
	local data = DataService:GetProfile(player)
	if not data then
		return false, "NotLoaded"
	end
	for name, amount in deltas do
		if not isCurrency[name] or not isWhole(amount) then
			return false, "BadDelta"
		end
		if amount < 0 and Economy.NeverSpent[name] then
			return false, "NeverSpent"
		end
		if (data.Currencies[name] or 0) + amount < 0 then
			return false, "Insufficient"
		end
	end

	local ok = DataService:Update(player, "Currencies", function(c)
		for name, amount in deltas do
			c[name] = (c[name] or 0) + amount
		end
		return c
	end)
	if not ok then
		return false, "NotLoaded"
	end
	DataService:RecordLedger(player, deltas)

	if reason ~= "IncomeTick" then
		local parts = {}
		for name, amount in deltas do
			table.insert(parts, `{name} {if amount >= 0 then "+" else ""}{amount} → {data.Currencies[name]}`)
			AnalyticsService:Economy(player, if amount >= 0 then "Source" else "Sink", name, amount, data.Currencies[name], reason)
		end
		Log.Info("Economy", `{player.Name} {table.concat(parts, ", ")} ({reason})`)
	end
	return true
end

-- Station income comes from RosterService (it knows who sits where). offline = true leaves out the Founder's
-- own desk, which only pays while you sit at it ([[Founder (You)]] → Earning money yourself).
EconomyService.IncomeProvider = function(_player: Player, _data: any, _offline: boolean): number
	return 0
end

function EconomyService:GetIncomePerSecond(player: Player, data: any, offline: boolean?): number
	return EconomyService.IncomeProvider(player, data, offline == true)
end

-- Pays income earned since the earner's last tick, carrying fractions to the next one.
local function pay(player: Player, e: Earner, now: number)
	local data = DataService:GetProfile(player)
	if not data then
		return
	end
	e.Remainder += EconomyService:GetIncomePerSecond(player, data) * (now - e.LastTick)
	e.LastTick = now
	local whole = math.floor(e.Remainder)
	if whole >= 1 and EconomyService:Transact(player, { Cash = whole }, "IncomeTick") then
		e.Remainder -= whole
		e.Logged += whole
	end
	if now - e.LastLog >= LOG_TICK_EVERY and e.Logged > 0 then
		Log.Info("Economy", `{player.Name} Cash +{e.Logged} (IncomeTick, last {LOG_TICK_EVERY}s)`)
		AnalyticsService:Economy(player, "Source", "Cash", e.Logged, data.Currencies.Cash, "IncomeTick")
		e.Logged = 0
		e.LastLog = now
	end
end

local function grantOffline(player: Player, data: any)
	local lastSeen = data.LastSeen or 0
	local now = os.time()
	if lastSeen > 0 then -- 0 = brand-new save, nothing to pay
		local elapsed = math.clamp(now - lastSeen, 0, Economy.Offline.CapSeconds)
		local amount = math.floor(elapsed * Economy.Offline.Rate * EconomyService:GetIncomePerSecond(player, data, true))
		if elapsed >= Economy.Offline.MinSeconds and amount > 0 then
			if EconomyService:Transact(player, { Cash = amount }, "OfflineEarnings") then
				task.defer(offlineRemote.FireClient, offlineRemote, player, amount, elapsed)
			end
		end
	end
	DataService:Update(player, "LastSeen", function()
		return now -- so a quick rejoin can't pay the same time twice
	end)
end

function EconomyService:Init()
	offlineRemote = Remote.Push("Economy", "OfflineEarned")

	DataService.ProfileLoaded:Connect(function(player, data)
		grantOffline(player, data)
		local now = os.clock()
		earners[player] = { Remainder = 0, LastTick = now, Logged = 0, LastLog = now }
	end)
	DataService.ProfileReleasing:Connect(function(player)
		local e = earners[player]
		if e then
			pay(player, e, os.clock()) -- partial tick before the final save
			earners[player] = nil
		end
	end)
	ShutdownService:RegisterFlusher("EconomyService", function()
		local now = os.clock()
		for player, e in earners do
			pay(player, e, now)
		end
	end)
end

function EconomyService:Start()
	Players.PlayerRemoving:Connect(function(player)
		task.defer(function()
			earners[player] = nil
		end)
	end)
	while not ShutdownService.IsClosing do -- the tick stops on shutdown so nothing unsaved is added
		task.wait(Economy.IncomeTick)
		local now = os.clock()
		for player, e in earners do
			pay(player, e, now)
		end
	end
end

return EconomyService

--!strict
-- DataService: the only code that touches the player DataStore ([[Data Persistence]] rule 1).
-- ProfileStore session lock, migrations, Reconcile, save guard, read-only for newer saves, rate-limited SaveNow.
--
-- Other services read GetProfile() and change data only through Update() (EconomyService owns Currencies).
-- ProfileStore saves whatever is in profile.Data; we keep the live table in session.Data and, right before each
-- write (OnSave), point profile.Data at it only if the save guard passes. Otherwise the last good save is rewritten.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Lib = script.Parent.Parent.Lib
local ProfileStore = require(Lib.Packages.ProfileStore)
local Remote = require(Lib.Remote)
local Log = require(Lib.Log)
local Signal = require(ReplicatedStorage.Shared.Signal)
local Path = require(ReplicatedStorage.Shared.Path)

local Config = require(script.Config)
local Template = require(script.Template)
local Migrations = require(script.Migrations)
local SaveGuard = require(script.SaveGuard)

local DataService = { Tier = 0 }

DataService.ProfileLoaded = Signal.new() -- (player, data)
DataService.ProfileReleasing = Signal.new() -- (player, data): last chance to write
DataService.IsClosing = false

type Session = {
	Profile: any,
	Data: any, -- live data, mutated only via Update
	Raw: any, -- untouched copy of the data as loaded (written back if this session must not save)
	LastGood: any, -- copy of the last data actually written
	Loaded: boolean,
	ReadOnly: boolean,
	NoSave: boolean,
	Released: boolean,
	Releasing: boolean?,
	Baseline: SaveGuard.Baseline?,
	Ledger: { [string]: number },
	AllowedWipes: { [string]: string },
	GuardBlocks: number,
	LastSaveNow: number,
	SaveQueued: boolean,
	ForcedPending: boolean,
}

local sessions: { [Player]: Session } = {}
local pendingRelease: { [string]: number } = {} -- [profile key] = userId, until the final save lands
local store: any
local deltaRemote: RemoteEvent
local savedRemote: RemoteEvent

local function deepCopy<T>(t: T): T
	if type(t) ~= "table" then
		return t
	end
	local copy = {}
	for k, v in t :: any do
		copy[k] = deepCopy(v)
	end
	return copy :: any
end

local function kick(player: Player, message: string)
	if player.Parent == Players then
		player:Kick(message)
	end
end

local function onSave(player: Player, s: Session)
	local profile = s.Profile
	if s.ReadOnly or s.NoSave or not s.Loaded then
		profile.Data = s.Raw -- write back exactly what was loaded
		return
	end
	s.Data.LastSeen = os.time()
	local ok, check, detail = SaveGuard.Check(s.Data, s.Baseline :: any, s.Ledger, s.AllowedWipes)
	if ok then
		profile.Data = s.Data
		s.GuardBlocks = 0
		return
	end
	profile.Data = s.LastGood
	s.GuardBlocks += 1
	s.ForcedPending = false
	Log.Event("save_guard_blocked", player, `{check}: {detail} (#{s.GuardBlocks})`)
	if s.GuardBlocks >= Config.MaxGuardBlocks then
		task.defer(kick, player, Config.Messages.GuardKick)
	end
end

local function hookProfile(player: Player, s: Session)
	local profile = s.Profile
	profile.OnSave:Connect(function()
		onSave(player, s)
	end)
	profile.OnLastSave:Connect(function()
		pendingRelease[profile.Key] = player.UserId
	end)
	profile.OnAfterSave:Connect(function(lastSaved)
		s.LastGood = deepCopy(lastSaved)
		pendingRelease[profile.Key] = nil
		if s.ForcedPending then
			s.ForcedPending = false
			savedRemote:FireClient(player)
		end
	end)
	profile.OnSessionEnd:Connect(function()
		if sessions[player] == s then
			sessions[player] = nil
		end
		local closing = DataService.IsClosing or ProfileStore.IsClosing
		if not s.Released and not closing and not s.ReadOnly and not s.NoSave then
			kick(player, Config.Messages.OtherServer)
		end
	end)
end

local function load(player: Player)
	local profile = store:StartSessionAsync(Config.KeyPrefix .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})
	if profile == nil then
		Log.Event("profile_load_failed", player)
		kick(player, Config.Messages.LoadFailed) -- never start on a blank profile
		return
	end
	if player.Parent ~= Players then
		profile:EndSession() -- left during load
		return
	end
	profile:AddUserId(player.UserId)

	local s: Session = {
		Profile = profile,
		Data = profile.Data,
		Raw = deepCopy(profile.Data),
		LastGood = deepCopy(profile.Data),
		Loaded = false,
		ReadOnly = false,
		NoSave = false,
		Released = false,
		Baseline = nil,
		Ledger = {},
		AllowedWipes = {},
		GuardBlocks = 0,
		LastSaveNow = -math.huge,
		SaveQueued = false,
		ForcedPending = false,
	}
	sessions[player] = s
	hookProfile(player, s)

	local version = profile.Data.Version or 1
	if version > Migrations.CURRENT_VERSION then
		s.ReadOnly = true
		Log.Event("version_mismatch_redirect", player, `save v{version} > server v{Migrations.CURRENT_VERSION}`)
		profile:EndSession()
		kick(player, Config.Messages.NewerVersion)
		return
	end

	local ok, err = Migrations.Run(profile.Data)
	if not ok then
		s.NoSave = true
		Log.Event("migration_failed", player, `v{version}: {err}`)
		profile:EndSession()
		kick(player, Config.Messages.Migration)
		return
	end
	profile:Reconcile()

	s.Data = profile.Data
	s.Baseline = SaveGuard.Baseline(s.Data)
	s.Loaded = true
	Log.Info("Data", `loaded {player.Name} (v{s.Data.Version}, mock={tostring(profile.is_mock or ProfileStore.DataStoreState ~= "Access")})`)

	DataService.ProfileLoaded:Fire(player, s.Data) -- handlers run now; offline earnings etc.
	deltaRemote:FireClient(player, "", s.Data) -- first full snapshot; ends the client loading screen
end

local function release(player: Player)
	local s = sessions[player]
	if not s or s.Released or s.Releasing then
		return
	end
	s.Releasing = true
	if s.Loaded then
		-- Handlers run synchronously up to their first yield, while Update still accepts writes.
		DataService.ProfileReleasing:Fire(player, s.Data)
		s.Data.LastSeen = os.time()
	end
	s.Released = true
	if s.Profile:IsActive() then
		pendingRelease[s.Profile.Key] = player.UserId
		s.Profile:EndSession()
	end
	sessions[player] = nil
end

-- Public API ------------------------------------------------------------------------------------------

-- Returns the live data table (read it, don't write it), or nil while loading / read-only.
function DataService:GetProfile(player: Player): any
	local s = sessions[player]
	return if s and s.Loaded and not s.ReadOnly then s.Data else nil
end

function DataService:WaitForProfile(player: Player, timeout: number?): any
	local deadline = os.clock() + (timeout or 30)
	while player.Parent == Players and os.clock() < deadline do
		local data = self:GetProfile(player)
		if data then
			return data
		end
		task.wait(0.1)
	end
	return nil
end

-- The only way to change saved data. fn(oldValue) returns the new value (may mutate tables in place).
-- Sends State/Delta (path, value) to the owner. Returns (true, newValue) or false.
function DataService:Update(player: Player, path: string, fn: (any) -> any): (boolean, any)
	local s = sessions[player]
	if not s or not s.Loaded or s.ReadOnly or s.Released then
		return false, nil
	end
	assert(path ~= "", "[DataService] Update needs a path")
	local parent, key = Path.Parent(s.Data, path)
	if parent == nil or key == nil then
		return false, nil
	end
	local value = fn(parent[key])
	parent[key] = value
	deltaRemote:FireClient(player, path, value)
	return true, value
end

-- EconomyService only: logs a currency change so the save guard can match it.
function DataService:RecordLedger(player: Player, deltas: { [string]: number })
	local s = sessions[player]
	if s then
		for name, amount in deltas do
			s.Ledger[name] = (s.Ledger[name] or 0) + amount
		end
	end
end

-- Lets an intended wipe (e.g. rebirth resets Roster) pass the save guard.
function DataService:ExpectWipe(player: Player, field: string, reason: string)
	local s = sessions[player]
	if s then
		s.AllowedWipes[field] = reason
	end
end

-- Forced save, max 1 per profile per Config.SaveNowCooldown s; extra calls collapse into one save at window end.
function DataService:SaveNow(player: Player, reason: string): boolean
	local s = sessions[player]
	if not s or not s.Loaded or s.ReadOnly or s.Released or not s.Profile:IsActive() then
		return false
	end
	local wait = s.LastSaveNow + Config.SaveNowCooldown - os.clock()
	if wait > 0 then
		if not s.SaveQueued then
			s.SaveQueued = true
			task.delay(wait, function()
				s.SaveQueued = false
				if sessions[player] == s then
					self:SaveNow(player, reason .. " (queued)")
				end
			end)
		end
		return true
	end
	s.LastSaveNow = os.clock()
	s.ForcedPending = true
	s.Profile:Save()
	Log.Info("Data", `SaveNow {player.Name}: {reason}`)
	return true
end

function DataService:IsReadOnly(player: Player): boolean
	local s = sessions[player]
	return s ~= nil and s.ReadOnly
end

-- Shutdown helpers ([[Shutdown & Update Handling]]) -------------------------------------------------

function DataService:StampLastSeen()
	for _, s in sessions do
		if s.Loaded and not s.ReadOnly then
			s.Data.LastSeen = os.time()
		end
	end
end

function DataService:ReleaseAll()
	for player in sessions do
		release(player)
	end
end

function DataService:WaitForAllReleased(timeout: number): boolean
	local deadline = os.clock() + timeout
	while next(pendingRelease) and os.clock() < deadline do
		task.wait()
	end
	if next(pendingRelease) then
		local ids = {}
		for _, userId in pendingRelease do
			table.insert(ids, tostring(userId))
		end
		Log.Event("shutdown_save_timeout", nil, table.concat(ids, ","))
		return false
	end
	return true
end

-- Lifecycle -------------------------------------------------------------------------------------------

function DataService:Init()
	local base = ProfileStore.New(Config.StoreName, Template)
	store = if RunService:IsStudio() and Config.ForceMockInStudio then base.Mock else base

	deltaRemote = Remote.Push("State", "Delta")
	savedRemote = Remote.Push("Data", "Saved")

	-- Data-changing remotes wait for a loaded, writable profile.
	Remote.AddGuard(function(player, spec)
		if spec.Mutates == false then
			return nil
		end
		local s = sessions[player]
		if not s or not s.Loaded then
			return "NotLoaded"
		elseif s.ReadOnly then
			return "ReadOnly"
		end
		return nil
	end)

	ProfileStore.OnError:Connect(function(message, storeName, key)
		Log.Event("datastore_error", nil, `{storeName}/{key}: {message}`)
	end)

	require(script.DevHooks).Install({ sessions = sessions, load = load, release = release, service = DataService })
end

function DataService:Start()
	Players.PlayerAdded:Connect(load)
	Players.PlayerRemoving:Connect(release)
	for _, player in Players:GetPlayers() do
		task.spawn(load, player)
	end
	task.spawn(function()
		while ProfileStore.DataStoreState == "NotReady" do
			task.wait()
		end
		local mock = store == nil or ProfileStore.DataStoreState ~= "Access" or Config.ForceMockInStudio and RunService:IsStudio()
		Log.Info("Data", if mock
			then "MOCK store: data will NOT persist between sessions (turn on Studio API access to test saves)"
			else `live DataStore "{Config.StoreName}"`)
	end)
end

return DataService

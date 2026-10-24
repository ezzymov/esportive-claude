--!strict
-- LeaderboardService ([[Social & Multiplayer]] → Leaderboards, Stage 3): simple global boards from OrderedDataStore
-- (Fame, Trophies; stores in Config/Competition, add them to [[DataStore Registry]]). Every 60 s: scores of Stage 3+
-- players that changed are written, the top 10 are read and shown on the Spawn Plaza board and in the Phone app.
-- In Studio on the mock store (or with no DataStore access) the boards rank this server's players only.
--   Leaderboard/Get (RF) → { Live, Boards = { { Id, Name, Icon, Rows = { { Rank, Name, Value, You } } } } }

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Lib = script.Parent.Parent.Lib
local Remote = require(Lib.Remote)
local Log = require(Lib.Log)
local DataService = require(script.Parent.DataService)
local DataConfig = require(script.Parent.DataService.Config)
local Competition = require(ReplicatedStorage.Shared.Config.Competition)
local Format = require(ReplicatedStorage.Shared.Format)

local LeaderboardService = { Tier = 5 }

local LB = Competition.Leaderboards
local live = not (RunService:IsStudio() and DataConfig.ForceMockInStudio)
local stores: { [string]: OrderedDataStore } = {}
local written: { [Player]: { [string]: number } } = {}
local cache: { [string]: { { UserId: number, Value: number } } } = {}
local names: { [number]: string } = {}

local function score(data: any, boardId: string): number
	if boardId == "Fame" then
		return math.floor(data.Currencies.Fame or 0)
	elseif boardId == "Trophies" then
		return #data.Trophies
	end
	return 0
end

local function nameOf(userId: number): string
	local cached = names[userId]
	if cached then
		return cached
	end
	local p = Players:GetPlayerByUserId(userId)
	local data = p and DataService:GetProfile(p)
	if data and data.Team.Name ~= "" then
		names[userId] = `[{data.Team.Tag}] {data.Team.Name}`
		return names[userId]
	end
	local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	names[userId] = if ok then name else `Player {userId}`
	return names[userId]
end

local function write(player: Player)
	local data = DataService:GetProfile(player)
	if not data or data.Stage < LB.Stage then
		return
	end
	local last = written[player] or {}
	written[player] = last
	for _, board in LB.Boards do
		local v = score(data, board.Id)
		if last[board.Id] ~= v then
			last[board.Id] = v
			local store = stores[board.Id]
			if live and store then
				local ok, err = pcall(store.SetAsync, store, tostring(player.UserId), v)
				if not ok then
					Log.Event("datastore_error", player, `{board.Store}: {err}`)
					live = false -- no access (Studio without API access): rank this server only
				end
			end
		end
	end
end

local function read()
	for _, board in LB.Boards do
		local rows = {}
		local store = stores[board.Id]
		local ok = false
		if live and store then
			ok = pcall(function()
				local page = store:GetSortedAsync(false, LB.Top):GetCurrentPage()
				for _, entry in page do
					table.insert(rows, { UserId = tonumber(entry.key) or 0, Value = entry.value })
				end
			end)
		end
		if not ok then
			table.clear(rows)
			for _, p in Players:GetPlayers() do
				local data = DataService:GetProfile(p)
				if data and data.Stage >= LB.Stage then
					table.insert(rows, { UserId = p.UserId, Value = score(data, board.Id) })
				end
			end
			table.sort(rows, function(a, b)
				return a.Value > b.Value
			end)
			while #rows > LB.Top do
				table.remove(rows)
			end
		end
		cache[board.Id] = rows
	end
end

local function render()
	local hub = Workspace:FindFirstChild("Hub")
	local board = hub and hub:FindFirstChild("Leaderboard", true)
	local gui = board and board:FindFirstChildOfClass("SurfaceGui")
	local label = gui and gui:FindFirstChildOfClass("TextLabel")
	if not label then
		return
	end
	local lines = { "★ TOP TEAMS BY FAME" .. (if live then "" else " (this server)") }
	for i, row in cache.Fame or {} do
		table.insert(lines, `{i}. {nameOf(row.UserId)}  ·  {Format.Short(row.Value)} ★`)
	end
	if #(cache.Fame or {}) == 0 then
		table.insert(lines, "Reach Stage 3 to get on the board!")
	end
	label.RichText = false
	label.Text = table.concat(lines, "\n")
end

local function get(player: Player): (boolean, any)
	local boards = {}
	for _, board in LB.Boards do
		local rows = {}
		for i, row in cache[board.Id] or {} do
			table.insert(rows, { Rank = i, Name = nameOf(row.UserId), Value = row.Value, You = row.UserId == player.UserId })
		end
		table.insert(boards, { Id = board.Id, Name = board.Name, Icon = board.Icon, Rows = rows })
	end
	return true, { Live = live, Boards = boards }
end

function LeaderboardService:Init()
	if live then
		for _, board in LB.Boards do
			local ok, store = pcall(DataStoreService.GetOrderedDataStore, DataStoreService, board.Store)
			if ok then
				stores[board.Id] = store
			else
				live = false
			end
		end
	end
	Remote.Function("Leaderboard", "Get", { Mutates = false, Rate = { Count = 1, Per = 2 } }, get)
	DataService.ProfileReleasing:Connect(function(player)
		task.spawn(write, player)
	end)
end

function LeaderboardService:Start()
	Players.PlayerRemoving:Connect(function(player)
		task.defer(function()
			written[player] = nil
		end)
	end)
	while true do
		for _, player in Players:GetPlayers() do
			write(player)
		end
		read()
		render()
		task.wait(LB.Refresh)
	end
end

return LeaderboardService

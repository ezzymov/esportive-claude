--!strict
-- Creates Remotes/<Service>/<Action> and wraps client→server handlers with:
--   guards (ServerClosing, profile not loaded, read-only), per-player rate limit, arg type/range checks, pcall.
-- Rate limits per [[Services & Remotes]]: default 10 calls/s, over limit = drop + log.
--
-- Remote.Function("Plot", "BuyPad", { Args = { Remote.T.String(64) } }, function(player, padId) return true end)
-- RemoteFunction handlers return (ok: boolean, result: any). The client receives exactly that.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Log = require(script.Parent.Log)

local Remote = {}

export type Spec = {
	Args: { (any) -> boolean }?,
	Rate: { Count: number, Per: number }?, -- default 10 per 1 s
	Mutates: boolean?, -- default true: blocked while the profile is loading or read-only
}

type Guard = (player: Player, spec: Spec) -> string?

local DEFAULT_RATE = { Count = 10, Per = 1 }
local guards: { Guard } = {}
local buckets: { [Player]: { [string]: { Tokens: number, At: number } } } = {}

local root = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
root.Name = "Remotes"
root.Parent = ReplicatedStorage

local function getOrCreate(service: string, action: string, className: string): Instance
	local folder = root:FindFirstChild(service)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = service
		folder.Parent = root
	end
	assert(not folder:FindFirstChild(action), `[Remote] {service}/{action} created twice`)
	local remote = Instance.new(className)
	remote.Name = action
	remote.Parent = folder
	return remote
end

-- Token bucket: Count calls per Per seconds.
local function allow(player: Player, key: string, rate: { Count: number, Per: number }): boolean
	local playerBuckets = buckets[player]
	if not playerBuckets then
		playerBuckets = {}
		buckets[player] = playerBuckets
	end
	local now = os.clock()
	local b = playerBuckets[key]
	if not b then
		b = { Tokens = rate.Count, At = now }
		playerBuckets[key] = b
	end
	b.Tokens = math.min(rate.Count, b.Tokens + (now - b.At) * rate.Count / rate.Per)
	b.At = now
	if b.Tokens < 1 then
		return false
	end
	b.Tokens -= 1
	return true
end

local function check(player: Player, key: string, spec: Spec, ...: any): string?
	for _, guard in guards do
		local reason = guard(player, spec)
		if reason then
			return reason
		end
	end
	if not allow(player, key, spec.Rate or DEFAULT_RATE) then
		Log.Event("rate_limited", player, key)
		return "RateLimited"
	end
	local validators = spec.Args or {}
	local n = select("#", ...)
	if n > #validators then
		Log.Event("bad_remote_args", player, `{key} too many args ({n})`)
		return "BadArgs"
	end
	for i, validate in validators do
		local value = select(i, ...)
		if not validate(value) then
			Log.Event("bad_remote_args", player, `{key} arg {i} = {tostring(value)}`)
			return "BadArgs"
		end
	end
	return nil
end

-- Guards run before every client call. Return a reason string to reject.
function Remote.AddGuard(guard: Guard)
	table.insert(guards, guard)
end

function Remote.Function(service: string, action: string, spec: Spec, handler: (Player, ...any) -> (boolean, any))
	local key = `{service}/{action}`
	local rf = getOrCreate(service, action, "RemoteFunction") :: RemoteFunction
	rf.OnServerInvoke = function(player, ...)
		local reason = check(player, key, spec, ...)
		if reason then
			return false, reason
		end
		local ok, success, result = pcall(handler, player, ...)
		if not ok then
			warn(`[Remote] {key} errored: {success}`)
			return false, "Error"
		end
		return success, result
	end
	return rf
end

function Remote.Event(service: string, action: string, spec: Spec, handler: (Player, ...any) -> ())
	local key = `{service}/{action}`
	local re = getOrCreate(service, action, "RemoteEvent") :: RemoteEvent
	re.OnServerEvent:Connect(function(player, ...)
		if check(player, key, spec, ...) then
			return
		end
		local ok, err = pcall(handler, player, ...)
		if not ok then
			warn(`[Remote] {key} errored: {err}`)
		end
	end)
	return re
end

-- Server → client only. Any client fire is logged as suspicious and ignored.
function Remote.Push(service: string, action: string): RemoteEvent
	local key = `{service}/{action}`
	local re = getOrCreate(service, action, "RemoteEvent") :: RemoteEvent
	re.OnServerEvent:Connect(function(player)
		if allow(player, key, DEFAULT_RATE) then
			Log.Event("client_fired_server_only_remote", player, key)
		end
	end)
	return re
end

-- Arg validators: type + range checks. Numbers must be finite.
local function finite(v: any): boolean
	return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge
end

Remote.T = {
	String = function(maxLen: number)
		return function(v: any)
			return type(v) == "string" and #v > 0 and #v <= maxLen
		end
	end,
	Int = function(min: number, max: number)
		return function(v: any)
			return finite(v) and v % 1 == 0 and v >= min and v <= max
		end
	end,
	Number = function(min: number, max: number)
		return function(v: any)
			return finite(v) and v >= min and v <= max
		end
	end,
	OneOf = function(options: { any })
		return function(v: any)
			return table.find(options, v) ~= nil
		end
	end,
	Boolean = function()
		return function(v: any)
			return type(v) == "boolean"
		end
	end,
	-- Array of up to maxCount strings, each 1..maxLen long, no other keys.
	StringList = function(maxLen: number, maxCount: number)
		return function(v: any)
			if type(v) ~= "table" then
				return false
			end
			local n = 0
			for k, s in v do
				n += 1
				if type(k) ~= "number" or type(s) ~= "string" or #s == 0 or #s > maxLen or n > maxCount then
					return false
				end
			end
			return n == #v
		end
	end,
}

Players.PlayerRemoving:Connect(function(player)
	buckets[player] = nil
end)

return Remote

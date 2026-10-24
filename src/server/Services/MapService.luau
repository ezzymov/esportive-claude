--!strict
-- MapService ([[Maps & Map Pool]], [[Map Library]]): the Aim Arena map pool by stage, map leans (title weights),
-- MapFit, the Bo1 veto and Map Mastery (Profile.MapMastery 0–100: +2 per scrim, +1 per tournament match).
-- Pure helpers so the match sim and the tournament resolver (which runs without the client) give the same map.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local Maps = require(ReplicatedStorage.Shared.Config.Maps)
local Match = require(ReplicatedStorage.Shared.Config.Match)

local MapService = { Tier = 4 }

local weightCache: { [string]: { [string]: number } } = {}

function MapService:Pool(stage: number): { string }
	local n = Maps.PoolSize[math.clamp(stage, 1, #Maps.PoolSize)]
	local out = {}
	for _, id in Maps.Order do
		if #out >= n then
			break
		end
		if (Maps :: any)[id].InPool then
			table.insert(out, id)
		end
	end
	return out
end

function MapService:Def(mapId: string): any
	return (Maps :: any)[mapId]
end

-- Title weights with the map's lean added, re-normalized to sum to 1.
function MapService:Weights(mapId: string?): { [string]: number }
	local key = mapId or ""
	local cached = weightCache[key]
	if cached then
		return cached
	end
	local w = table.clone(Match.TitleWeights)
	local def = mapId and (Maps :: any)[mapId]
	if def then
		for stat, add in def.Lean or {} do
			w[stat] = (w[stat] or 0) + add
		end
	end
	local sum = 0
	for _, v in w do
		sum += v
	end
	for stat, v in w do
		w[stat] = v / sum
	end
	weightCache[key] = w
	return w
end

-- MapFit = clamp(1 + Σ role bonus of the five / 5, 0.95–1.05).
function MapService:Fit(cards: { any }, mapId: string?): number
	local def = mapId and (Maps :: any)[mapId]
	if not def then
		return 1
	end
	local sum = 0
	for _, card in cards do
		sum += (def.Roles or {})[card.Role] or 0
	end
	return math.clamp(1 + sum / math.max(#cards, 1), Match.MapFitClamp[1], Match.MapFitClamp[2])
end

function MapService:MasteryMult(mastery: number?): number
	return 1 + math.clamp(mastery or 0, 0, Match.Mastery.Max) / 100 * Match.MasteryBonus
end

-- Bo1 veto: A bans first, sides alternate until one map is left ([[Maps & Map Pool]] → Map veto).
-- banA = A's ban order (missing/used maps skipped → auto: the map where A is weakest). The AI (B) bans the map
-- where A is strongest, never its favorite. edge(mapId) = A's power / B's power on that map.
function MapService:Veto(pool: { string }, banA: { string }?, edge: (string) -> number, favoriteB: string?): { Map: string, Bans: { { Side: string, Map: string } } }
	local left = table.clone(pool)
	local bans = {}
	local side = "A"
	while #left > 1 do
		local pick: string? = nil
		if side == "A" then
			for _, id in banA or {} do
				if table.find(left, id) then
					pick = id
					break
				end
			end
			if not pick then
				local worst = math.huge
				for _, id in left do
					local e = edge(id)
					if e < worst then
						worst, pick = e, id
					end
				end
			end
		else
			local best = -math.huge
			for _, id in left do
				local e = edge(id)
				if id ~= favoriteB and e > best then
					best, pick = e, id
				end
			end
			pick = pick or left[1]
		end
		table.remove(left, table.find(left, pick) :: number)
		table.insert(bans, { Side = side, Map = pick :: string })
		side = if side == "A" then "B" else "A"
	end
	return { Map = left[1], Bans = bans }
end

function MapService:AddMastery(player: Player, mapId: string, n: number)
	if not (Maps :: any)[mapId] then
		return
	end
	DataService:Update(player, "MapMastery." .. mapId, function(v)
		return math.min(Match.Mastery.Max, (v or 0) + n)
	end)
end

return MapService

--!strict
-- Case odds test ([[Case Unboxing]]): rolls every case through the same Shared/CaseRoll code the server uses and
-- prints actual vs configured odds. Runs in Edit or Play (command bar):
--   require(game.ServerScriptService.Tests.CaseOdds).Run()          -- 100,000 rolls per case
--   require(game.ServerScriptService.Tests.CaseOdds).Run(1_000_000)
-- Part 1 rolls the raw odds (pity off): every rarity must land within 4 standard errors of its configured %.
-- Part 2 rolls one long streak with pity on: no gap between drops of a pity rarity may exceed its guarantee.
-- Returns true when every check passes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CaseRoll = require(ReplicatedStorage.Shared.CaseRoll)
local Cases = require(ReplicatedStorage.Shared.Config.Cases)
local Rarities = require(ReplicatedStorage.Shared.Config.Rarities)

local CaseOdds = {}

local function pct(x: number): string
	return string.format("%7.3f%%", x * 100)
end

function CaseOdds.Run(n: number?): boolean
	local rolls = n or 100_000
	local passed = true
	local function fail(msg: string)
		passed = false
		warn("[CaseOdds] FAIL " .. msg)
	end
	for _, problem in CaseRoll.Validate() do
		fail("config: " .. problem)
	end

	for _, caseId in Cases.Order do
		local def = (Cases :: any)[caseId]
		local rng = Random.new(os.clock() * 1e6 // 1)
		local started = os.clock()
		print(string.format("\n[CaseOdds] ===== %s (%s) · %d rolls =====", caseId, def.Name, rolls))

		-- Part 1: raw odds.
		local byRarity: { [string]: number } = {}
		local byType: { [string]: { [string]: number } } = {}
		for i = 1, rolls do
			local d = CaseRoll.Open(def, nil, rng)
			byRarity[d.Rarity] = (byRarity[d.Rarity] or 0) + 1
			byType[d.Rarity] = byType[d.Rarity] or {}
			byType[d.Rarity][d.Type] = (byType[d.Rarity][d.Type] or 0) + 1
			if i % 20_000 == 0 then
				task.wait()
			end
		end
		print("  Rarity       configured     actual      z")
		for _, row in CaseRoll.Odds(def) do
			local got = (byRarity[row.Rarity] or 0) / rolls
			local se = math.sqrt(row.P * (1 - row.P) / rolls)
			local z = if se > 0 then (got - row.P) / se else 0
			print(string.format("  %-10s %s  %s  %6.2f", row.Rarity, pct(row.P), pct(got), z))
			if math.abs(z) > 4 then
				fail(`{caseId} {row.Rarity}: {pct(got)} vs {pct(row.P)} (z {string.format("%.1f", z)})`)
			end
			local parts = {}
			local inRarity = byRarity[row.Rarity] or 0
			for _, t in row.Types do
				local tGot = if inRarity > 0 then (byType[row.Rarity][t.Type] or 0) / inRarity else 0
				table.insert(parts, string.format("%s %.1f%%→%.1f%%", t.Type, t.P * 100, tGot * 100))
			end
			print("      types: " .. table.concat(parts, " · "))
		end
		for r, count in byRarity do
			if ((def.Odds or {})[r] or (if def.Guaranteed == r then 100 else 0)) == 0 then
				fail(`{caseId} dropped {r} ({count}×) but its odds are 0`)
			end
		end

		-- Part 2: pity on, one player opening `rolls` times in a row.
		if not def.Guaranteed then
			local pity = { Epic = 0, Legendary = 0, Mythic = 0 }
			local hits: { [string]: number } = {}
			local gap: { [string]: number } = {}
			local maxGap: { [string]: number } = {}
			local forced = 0
			for i = 1, rolls do
				local d = CaseRoll.Open(def, pity, rng)
				if d.Forced then
					forced += 1
				end
				for _, r in Rarities.Order do
					if Cases.Pity[r] and CaseRoll.CanDrop(def, r) then
						gap[r] = (gap[r] or 0) + 1
						if CaseRoll.Rank[d.Rarity] >= CaseRoll.Rank[r] then
							hits[r] = (hits[r] or 0) + 1
							maxGap[r] = math.max(maxGap[r] or 0, gap[r])
							gap[r] = 0
						end
					end
				end
				if i % 20_000 == 0 then
					task.wait()
				end
			end
			print(string.format("  With pity (%d forced opens):", forced))
			for _, r in Rarities.Order do
				local need = Cases.Pity[r]
				if need and CaseRoll.CanDrop(def, r) then
					local configured = 0
					for _, row in CaseRoll.Odds(def) do
						if CaseRoll.Rank[row.Rarity] >= CaseRoll.Rank[r] then
							configured += row.P
						end
					end
					print(string.format("    %s+ : configured %s → effective %s · longest gap %d (guarantee %d)", r, pct(configured), pct((hits[r] or 0) / rolls), maxGap[r] or 0, need))
					if (maxGap[r] or 0) > need then
						fail(`{caseId} {r}+ gap {maxGap[r]} > pity {need}`)
					end
				end
			end
		end
		print(string.format("  (%.2f s)", os.clock() - started))
	end
	print(if passed then "\n[CaseOdds] PASS" else "\n[CaseOdds] FAILED (see warnings)")
	return passed
end

return CaseOdds

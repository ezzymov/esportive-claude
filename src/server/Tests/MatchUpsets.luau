--!strict
-- Upset-rate test ([[Match Simulation]] → Tuning targets): sims matches at several power gaps through the real
-- match engine and prints how often the weaker team wins. Runs in Edit or Play (command bar):
--   require(game.ServerScriptService.Tests.MatchUpsets).Run()        -- 1,000 matches per gap
--   require(game.ServerScriptService.Tests.MatchUpsets).Run(10_000)
-- Prints the current config, then the same gaps with the optional match-level upset floor (Match.UpsetFloor,
-- option b in the vault) set to hit the 2× target, so it can be decided from the numbers. Targets: equal 50% · +20% ~70%
-- for the stronger team · 2× ~92%. Returns the rows.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Match = require(ReplicatedStorage.Shared.Config.Match)
local Sim = require(script.Parent.Parent.Services.MatchService.Sim)

local MatchUpsets = {}

local GAPS = { 0, 0.1, 0.2, 0.3, 0.5, 1.0, 1.5 } -- stronger team = base × (1 + gap)
local TARGETS: { [number]: string } = { [0] = "50%", [0.2] = "~70%", [1.0] = "~92%" }
local BASE = 200 -- weaker team power (a Stage 3 five is ~200–260)

local function run(n: number, label: string): { any }
	print(string.format("\n[MatchUpsets] %s · %d matches per gap", label, n))
	print("  gap     strong  weak   stronger wins   upsets   target   avg score   clip moments/match")
	local rows = {}
	for _, gap in GAPS do
		local strong, weak = BASE * (1 + gap), BASE
		local wins, roundsW, roundsL, moments = 0, 0, 0, 0
		for i = 1, n do
			-- Alternate sides so side A has no edge.
			local strongIsA = i % 2 == 0
			local s = Sim.New({
				A = Sim.FakeSide(if strongIsA then strong else weak),
				B = Sim.FakeSide(if strongIsA then weak else strong),
				Seed = i * 7919 + math.floor(gap * 1000),
				Weights = Match.TitleWeights,
			})
			Sim.Finish(s, 0)
			local strongWon = (s.Winner == "A") == strongIsA
			if strongWon then
				wins += 1
			end
			local w, l = math.max(s.A, s.B), math.min(s.A, s.B)
			roundsW += w
			roundsL += l
			moments += #Sim.Summary(s).Moments
			if i % 250 == 0 then
				task.wait()
			end
		end
		local row = { Gap = gap, StrongWin = wins / n, Upset = 1 - wins / n }
		table.insert(rows, row)
		print(string.format("  +%3d%%   %5.0f  %5.0f   %12.1f%%   %5.1f%%   %6s   %4.1f-%-4.1f   %.1f", gap * 100, strong, weak, row.StrongWin * 100, row.Upset * 100, TARGETS[gap] or "", roundsW / n, roundsL / n, moments / n))
	end
	return rows
end

function MatchUpsets.Run(n: number?): { any }
	local count = n or 1000
	local floor = Match.UpsetFloor
	local saved = { Chance = floor.Chance, Pull = floor.Pull }
	local rows = run(count, string.format("current config (K %.2f, clamp %.2f–%.2f, upset floor %d%%)", Match.K, Match.PRoundClamp[1], Match.PRoundClamp[2], floor.Chance * 100))
	-- At 2× the normal engine almost never loses, so the floor has to carry the whole 8%: a coin-flip match (Pull 0)
	-- 16% of the time gives 1 − 0.16/2 = 92% at 2×, and only shaves ~3 points off the +20% case.
	floor.Chance, floor.Pull = 0.16, 0
	run(count, "what-if: upset floor 16% of matches played as a coin flip (UpsetFloor = { Chance = 0.16, Pull = 0 })")
	floor.Chance, floor.Pull = saved.Chance, saved.Pull
	return rows
end

return MatchUpsets

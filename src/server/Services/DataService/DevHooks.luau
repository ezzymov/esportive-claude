--!strict
-- Studio-only QA hooks for the [[Data Persistence]] acceptance tests. Never installed on live servers.
-- Command bar (server):  game.ServerStorage.DevHooks.Data:Invoke("Peek", game.Players:GetPlayers()[1])
--   Peek               → version, currencies, ledger, guard blocks
--   SaveNow            → forced save through the normal 10 s cooldown
--   UnloggedCash n     → adds n Cash WITHOUT Transact, then SaveNow (save guard must block)
--   SeedRoster         → adds a test card and treats it as loaded, so a later wipe counts
--   ZeroRoster         → Roster = {} with no logged reason, then SaveNow (save guard must block)
--   SetVersion n       → sets Data.Version (simulate a newer save), then Reload to see read-only
--   Reload             → end the session, wait for release, start a new one (leave + rejoin on one server)
--   Beats              → Stage 1 beat times (play time each tutorial step completed) vs the beat sheet
--   Cash n             → logged +n Cash (Transact), for skipping ahead in tests
--   PickupNow/ScrimNow → clears the Pickup Game + scrim cooldowns
--   TourneyNext        → your next tournament round plays now     Tickets n → +n Quick Time Skip Tickets
--   Desks              → café PCs 4–5 (Stage 2+)                  Recruit rarity → a generated player joins
--   FreeNow            → the free Rookie Crate is ready now
--   PlayTime n         → adds n seconds to Ftue.PlaySeconds (12-min guardrail test)
--   Fame/Gems/Shards n → logged grant
--   Stage n            → jump to stage n (Fame raised to its gate)
--   Skip n             → fresh profile → Stage 1 finished, at stage n (mock store; run before pressing a key)
--   Case id | {id, n}  → grant cases          Open {id, count, owned} → Case/Open path, prints the drops

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local DevHooks = {}

function DevHooks.Install(ctx: { sessions: any, load: (Player) -> (), release: (Player) -> (), service: any })
	if not RunService:IsStudio() then
		return
	end
	local folder = ServerStorage:FindFirstChild("DevHooks") or Instance.new("Folder")
	folder.Name = "DevHooks"
	folder.Parent = ServerStorage
	local fn = Instance.new("BindableFunction")
	fn.Name = "Data"
	fn.Parent = folder

	fn.OnInvoke = function(cmd: string, player: Player, arg: any)
		local s = ctx.sessions[player]
		if cmd == "Reload" then
			local key = s and s.Profile.Key
			ctx.release(player)
			ctx.service:WaitForAllReleased(15)
			task.wait(0.5)
			ctx.load(player)
			return `reloaded {key}`
		end
		if not s then
			return "no session"
		end
		local d = s.Data
		if cmd == "SaveNow" then
			return ctx.service:SaveNow(player, "DevHooks:SaveNow") -- respects the cooldown
		elseif cmd == "Peek" then
			return {
				Version = d.Version,
				Currencies = table.clone(d.Currencies),
				Ledger = table.clone(s.Ledger),
				PadsBought = table.clone(d.HQ.PadsBought),
				Roster = d.Roster,
				Stations = d.Stations,
				Step = d.Tutorial.Step,
				Ftue = d.Ftue,
				Flags = d.Flags,
				Stage = d.Stage,
				GuardBlocks = s.GuardBlocks,
				ReadOnly = s.ReadOnly,
				LastSeen = d.LastSeen,
			}
		elseif cmd == "Beats" then
			-- Stage 1 test-run report: when each beat completed (play time m:ss), in beat-sheet order.
			local Steps = require(game:GetService("ReplicatedStorage").Shared.Config.Tutorial.Steps)
			local lines = {}
			local intro = d.Ftue.BeatAt.Intro
			table.insert(lines, `Intro      target 0:52  actual {if intro then string.format("%d:%02d", intro // 60, intro % 60) else "—"}`)
			for _, step in Steps.List do
				local at = d.Ftue.BeatAt[step.Id]
				table.insert(lines, `{step.Id}  target {step.Beat}  actual {if at then string.format("%d:%02d", at // 60, at % 60) else "—"}`)
			end
			return table.concat(lines, "\n")
		elseif cmd == "Cash" then
			-- Logged grant through EconomyService (passes the save guard).
			return require(script.Parent.Parent.EconomyService):Transact(player, { Cash = tonumber(arg) or 1000 }, "DevHooks:Cash")
		elseif cmd == "PlayTime" then
			-- Adds n seconds of play time (tests the 12-min Rusty guardrail without waiting).
			ctx.service:Update(player, "Ftue.PlaySeconds", function(v)
				return (v or 0) + (tonumber(arg) or 60)
			end)
			return d.Ftue.PlaySeconds
		elseif cmd == "PickupNow" or cmd == "ScrimNow" then
			require(script.Parent.Parent.MatchService):ResetCooldown(player)
			return "cooldown cleared"
		elseif cmd == "TourneyNext" then
			-- Your next tournament round plays now (same seed, like a Time Skip Ticket without the ticket).
			local Tournament = require(script.Parent.Parent.MatchService.Tournament)
			Tournament.SkipToNext(player, "DevHooks")
			local t = d.Tournament
			return if t then `{t.Status} · place {t.Place} · unwatched {t.Unwatched}` else "no tournament"
		elseif cmd == "Desks" then
			-- Café PCs 4–5 without walking to the pads (needs Stage 2).
			for slot = 2, 5 do
				ctx.service:Update(player, `HQ.PadsBought.Desk{slot}`, function()
					return true
				end)
				if not d.Stations[tostring(slot)] then
					ctx.service:Update(player, "Stations." .. slot, function()
						return { PlayerId = "", Tier = 1, Parts = {} }
					end)
				end
			end
			require(script.Parent.Parent.RosterService):SeatUnseated(player)
			require(script.Parent.Parent.PlotService):Refresh(player)
			return "desks 1–5"
		elseif cmd == "Recruit" then
			-- arg = rarity ("Epic"): a generated player joins (bench if no desk is free).
			local Generator = require(game:GetService("ReplicatedStorage").Shared.Generator)
			local card = Generator.Card(game:GetService("HttpService"):GenerateGUID(false), math.random(1, 2 ^ 30), tostring(arg or "Rare"))
			require(script.Parent.Parent.RosterService):AddCard(player, card)
			return `{card.Rarity} {Generator.Name(card)} ({card.Role})`
		elseif cmd == "FreeNow" then
			-- The free Rookie Crate timer runs out now (the HUD button appears within a second).
			ctx.service:Update(player, "CaseStats.NextFreeAt", function()
				return os.time()
			end)
			return "free crate ready"
		elseif cmd == "Tickets" then
			ctx.service:Update(player, "Inventory.TimeSkips.Quick", function(n)
				return (n or 0) + (tonumber(arg) or 3)
			end)
			return d.Inventory.TimeSkips.Quick
		elseif cmd == "Fame" or cmd == "Gems" or cmd == "Shards" then
			return require(script.Parent.Parent.EconomyService):Transact(player, { [cmd] = tonumber(arg) or 100 }, `DevHooks:{cmd}`)
		elseif cmd == "Stage" then
			-- Jump to a stage (no promotion rewards). Fame is raised to the stage's gate so it doesn't promote back.
			local Stages = require(game:GetService("ReplicatedStorage").Shared.Config.Stages)
			local stage = math.clamp(tonumber(arg) or 2, 1, #Stages)
			ctx.service:Update(player, "Stage", function()
				return stage
			end)
			local need = Stages[stage].Fame - (d.Currencies.Fame or 0)
			if need > 0 then
				require(script.Parent.Parent.EconomyService):Transact(player, { Fame = need }, "DevHooks:Stage")
			end
			return `Stage {stage}`
		elseif cmd == "Skip" then
			-- Fresh profile → finished Stage 1 at stage `arg` (default 2): team, Founder, 3 desks, Rusty + a Rare,
			-- tutorial done, $5k. Run it right after joining a mock-store Play session, before pressing a key.
			local Services = script.Parent.Parent
			local RosterService = require(Services.RosterService)
			local Generator = require(game:GetService("ReplicatedStorage").Shared.Generator)
			local HttpService = game:GetService("HttpService")
			local function set(path: string, value: any)
				ctx.service:Update(player, path, function()
					return value
				end)
			end
			set("Flags.IntroSeen", true)
			set("Flags.StarterLetterSeen", true)
			set("Team.Name", "Test Squad")
			set("Team.Tag", "TST")
			set("Team.Colors", { Primary = 1, Tee = 1 })
			set("Flags.TeamCreated", true)
			RosterService:CreateFounder(player)
			set("Flags.StationPowered", true)
			for _, pad in { "Founder_Mouse", "Desk2", "Desk3" } do
				set("HQ.PadsBought." .. pad, true)
			end
			set("Roster." .. d.FounderUuid .. ".Accessories.Mouse", "ClikkBasic")
			for slot = 2, 3 do
				if not d.Stations[tostring(slot)] then
					set("Stations." .. slot, { PlayerId = "", Tier = 1, Parts = {} })
				end
			end
			RosterService:AddCard(player, Generator.KeyCard(HttpService:GenerateGUID(false), 1234, "Rusty"))
			RosterService:AddCard(player, Generator.Card(HttpService:GenerateGUID(false), 4321, "Rare"))
			set("Tutorial.Step", "Done")
			set("Ftue.PickupGames", 3)
			set("Ftue.PickupWins", 2)
			set("Ftue.CratesEarned", 1)
			set("Ftue.CratesOpened", 1)
			local Economy = require(Services.EconomyService)
			Economy:Transact(player, { Cash = 5000 }, "DevHooks:Skip")
			local Stages = require(game:GetService("ReplicatedStorage").Shared.Config.Stages)
			local stage = math.clamp(tonumber(arg) or 2, 1, #Stages)
			set("Stage", stage)
			Economy:Transact(player, { Fame = math.max(0, Stages[stage].Fame - (d.Currencies.Fame or 0)) }, "DevHooks:Skip")
			require(Services.PlotService):RefreshBanner(player)
			require(Services.PlotService):Refresh(player)
			return `skipped to Stage {stage}`
		elseif cmd == "Case" then
			-- arg = "ProCrate" or { "ProCrate", 10 }
			local id, n = if type(arg) == "table" then arg[1] else arg, if type(arg) == "table" then tonumber(arg[2]) or 1 else 1
			return require(script.Parent.Parent.CaseService):GrantCase(player, id or "RookieCrate", n, "DevHooks")
		elseif cmd == "Open" then
			-- arg = { caseId, count, owned } → same path as Case/Open, returns a summary
			local a = if type(arg) == "table" then arg else { arg }
			local ok, res = require(script.Parent.Parent.CaseService).Open(player, a[1] or "RookieCrate", tonumber(a[2]) or 1, a[3] == true)
			if not ok then
				return res
			end
			local lines = {}
			for _, drop in res.Drops do
				table.insert(lines, `{drop.Rarity} {drop.ItemId or drop.Type}{if drop.Forced then " (pity)" else ""}{if drop.Shards > 0 then " → +" .. drop.Shards .. " Shards" else ""}`)
			end
			return table.concat(lines, ", ") .. ` | pity Epic {res.Pity.Epic} Legendary {res.Pity.Legendary}`
		elseif cmd == "UnloggedCash" then
			d.Currencies.Cash += tonumber(arg) or 1_000_000
		elseif cmd == "SeedRoster" then
			d.Roster.TEST = { Id = "TEST", Name = "Test Card", Rarity = "Common" }
			s.Baseline.RosterCount = 1
			return "seeded"
		elseif cmd == "ZeroRoster" then
			d.Roster = {}
		elseif cmd == "SetVersion" then
			d.Version = tonumber(arg) or 2
		else
			return "unknown command"
		end
		s.LastSaveNow = -math.huge -- skip the cooldown for tests
		return ctx.service:SaveNow(player, `DevHooks:{cmd}`)
	end
end

return DevHooks

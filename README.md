# eSports Tycoon

Roblox esports management tycoon. Design docs (source of truth) live in the Obsidian vault in `eSports Tycoon Vault/`; code lives in `src/` and syncs to Studio with Rojo.

## Layout

| Folder | Studio location | What |
|---|---|---|
| `src/first` | ReplicatedFirst | Loading screen (holds until the profile loads) |
| `src/shared` | ReplicatedStorage/Shared | `Config/*` (content + numbers, see below), `Ratings` (OVR, Level, gear, PlayerPower, station income), `Generator` (seeded players, names, looks), `PlotFrame` (plot/garage coordinates), `Build` (greybox helpers), Loader, Signal, Path, Format, Net |
| — | ReplicatedStorage/Remotes | Created at runtime by the server: `Remotes/<Service>/<Action>` |
| `src/server` | ServerScriptService | `Main` (boots services), `Services/*` (one per feature), `Lib/*` (Remote, Log, Bus, vendored ProfileStore) |
| `src/gui` | StarterGui | Empty `HUD` and `Overlay` ScreenGuis; controllers build into them |
| `src/client` | StarterPlayerScripts | `Main` (boots controllers), `Controllers/*`, `UI/*` (Components, New, Drag, MyPlot) |

Services and controllers are tables with optional `Tier`, `Init()` and `Start()`. The loader runs every `Init` in Tier order, then every `Start` in its own thread. Services talk to the tutorial and analytics through `Lib/Bus` (gameplay facts like `PlayerHired`), so feature services never require the tutorial.

### Config (`src/shared/Config`)
Economy, Pads, Stages, Rarities, Parts, Brands, Theme (M0) · Roles (stat weights, Level badges), Traits, Names, KeyPlayers (Rusty), Accessories, Minigames (Aim Trainer, Tech Fix, Pickup Games), Match (sim constants), Hiring (board + 12-min guardrail), Cases (Rookie Crate placeholder), Team (name/tag limits, colors), World (ring + garage anchors) · `Tutorial/Steps` + `Tutorial/Lines` · `Cutscenes/IntroLines`.

M2/M3 tuning lives here too, nothing is hardcoded in services:
| Module | What you tune |
|---|---|
| `Cases` | Every case: price, currency, stage, rarity odds; drop-type split; pity (Epic 10 / Legendary 50 / Mythic 300); duplicate Shards; free Rookie Crate timer; ×5/×10 stage gates |
| `Parts`, `Accessories`, `TechShop`, `Brands` | Part + accessory catalogs (tiers, slot weights, set bonuses, stage tier cap), Tech Shop stock size/refresh/tiers, station-tier cap by stage |
| `Match` | Engine: K, clamp, momentum, upset floor (off), chemistry, fatigue, morale, map fit/mastery, kill-sequence deaths, clip moment qualities |
| `Maps`, `AITeams` | Aim Arena maps (lean, role fit, pool by stage, veto stage), 8 AI teams (bias, stat lean, favorite map, trash talk) |
| `Competition` | Scrim offers + rewards, Local Cup (timing, OVR band, prizes), leaderboards |
| `CasterLines` | Hector / Dr. Data lines per event (5+ per match event) and case reactions |
| `Stages` | Promotion rewards/banner text; `MaxStage` = last stage with content (3) |

### Services (M1)
| Service | Owns | Remotes |
|---|---|---|
| AnalyticsService | Roblox funnel/custom/economy events, play time, beat times | — |
| PlotService | Hub + 6-plot ring, plot assignment, spawn, pads, desks, NPCs, banner, Founder seat | `Plot/BuyPad` |
| OnboardingService | Intro seen flag, starter gift | `Onboarding/Intro`, `Starter/Collect` |
| TeamService | Name/tag (TextService filter), Founder role, colors | `Team/SetIdentity` |
| RosterService | Founder card, seating + station income, Founder XP, free agents, guardrail | `Roster/GetFreeAgents`, `Roster/Hire`, `Roster/Hired` (S→C) |
| CaseService | Rookie Crate placeholder (guaranteed Rare, rolled on grant) | `Case/Open` |
| MinigameService | PC cable setup, Aim Trainer, Tech Fix (server caps) | `Station/BeginSetup`, `Station/PowerOn`, `Minigame/AimStart|AimFinish|TechStart|TechFinish` |
| MatchService | Pickup Games: TeamPower + Elo rounds, Clutch round, pity | `Match/StartPickup`, `Match/Resolve` |
| TutorialService | Guided FTUE steps, promotion to Stage 2 (through ProgressionService) | `Tutorial/Lines`, `Tutorial/Stall` |

### Services (M2 Unboxing + M3 Competition)
| Service | Owns | Remotes |
|---|---|---|
| CaseService | Rolls (one `Random.new()`), pity, duplicates → Shards, buy or open owned ×1/×5/×10, free Rookie Crate, FTUE `StarterCrate`; SaveNow on Legendary+. Odds math is `Shared/CaseRoll` (the Odds panel reads the same code) | `Case/Open` (caseId, count, owned) 2/s, `Case/ClaimFree` |
| GearService | Accessory equip/unequip, gear stats with stage tier cap, Full/Pure mode | `Accessory/Equip`, `Accessory/Unequip` |
| StationService | Station parts + income tiers, Tech Shop stock (same per 10-min window everywhere) | `Shop/GetStock`, `Shop/Buy`, `Station/Equip`, `Station/Unequip`, `Station/Upgrade` |
| RosterService (+) | Roster cap by stage, active five = desks 1–5, lineup swaps, release | `Roster/Lineup`, `Roster/Release` |
| MinigameService (+) | Reaction Test (Stage 2) with server caps | `Minigame/ReactStart`, `Minigame/ReactFinish` |
| MapService | Map pool by stage, leans, MapFit, Bo1 veto, mastery | — |
| MatchService | `Sim` (full engine), `Teams` (AI teams, entries, snapshots), Pickup Games, scrims, `Tournament` (Local Cup) | `Match/StartPickup`, `Match/ScrimBoard`, `Match/StartScrim`, `Match/Resolve`, `Tournament/Register|SetBans|Watch|Skip|Close`, `Tournament/MatchReady` (S→C) |
| ProgressionService | Stage promotions (Fame gates up to `Stages.MaxStage`), banner | `Stage/Promoted` (S→C) |
| LeaderboardService | Fame + Trophies OrderedDataStores (`LB_Fame_v1`, `LB_Trophies_v1`), plaza board | `Leaderboard/Get` |
| PlotService (+) | Café annex (Stage 2: Tech Shop counter, Reaction Test, case vault, café PCs 4–5), trophy shelf (Stage 3) | — |

Client: `CaseController` (shelf + reveal), `ShopController` (Shop rail: Cases · Tech Shop), `InventoryController` (Inventory rail: Cases · Parts · Accessories), `TechShopController`, `GearController` (pickers), `CompeteController` (Compete rail: Scrims · Tournaments/bracket), `MatchController` (Match HUD), `UI/Caster` (lower-third), Phone apps Odds & Rules + Leaderboards.

## Sync with Rojo

Rojo 7.7.1 is pinned in `aftman.toml` and the project serves on port **34873** (34872 is taken by another project).

```bash
rojo serve default.project.json
```

In Studio: Plugins → Rojo → set the port to `34873` → Connect. If you change `default.project.json` (new top-level folders), restart `rojo serve` and reconnect; the running server doesn't pick up new services on its own.

## Test in Studio

**Data persistence needs API access.** Without it, ProfileStore uses its mock store and data resets every Play session (Output says `MOCK store`). To test saving: Home → Game Settings → Security → *Enable Studio Access to API Services*. To force the mock even with access on, set `ForceMockInStudio = true` in `src/server/Services/DataService/Config.luau`. **The Stage 1 FTUE needs a brand-new profile**, so test it on the mock store (every Play is a new player).

Play Solo (F5), Stage 1 slice:
1. Loading screen → **Start screen** over a blurred shot of your own garage → press any key / tap.
2. **Intro cutscene** (~52 s, your own avatar). *Hold to skip* appears after 5 s. Skipping lands in the same state.
3. **Starter Letter** from Aunt Dee: click the bill → +$50 flies to the Cash pill.
4. **Team Creator**: auto-name "Garage Squad / GSQ", 🎲 randomize, role picker, team + tee color. Confirm → the bedsheet banner drops over the garage door, your torso turns your tee color.
5. Tutorial: goal banner (top right), objective card (bottom), chevron trail + highlight, Aunt Dee texts (bottom right). Stand still 60 s for a hint, 120 s for a call with **Show me**.
6. Desk → **Set up PC** prompt → drag 3 cables → POWER ON → Founder card "You · OVR 30". Sit in the taped chair: income starts (~$1.30/s, only while seated).
7. Seated: **▶ Play Pickup Game** (first one is a guaranteed win, $150 + 60 ★). Try the Clutch Moment tap, or Skip.
8. **Aim Trainer** cabinet (back-left corner, also in Arcade Corner) → 20 s targets. **Tech Fix** bench by the door → plug, swap RAM, dust → $200.
9. Pads: **Better Mouse** $150 (card popup "+1 Aim (gear)") → **2nd Desk** $300 → cork board **Free agents** → hire **Rusty** ($250, $100 after 12 min of play with no hire). Rusty walks in and sits; his desk earns while you're away.
10. Win a Pickup Game with Rusty → **Open Rookie Crate** button → guaranteed Rare → **3rd Desk** $500 seats them → at 100 ★ the **Café Rookies** promotion banner (+25 💎).

**M2 + M3 (Stage 2 → first trophy).** ⚠ With Studio API access on, Play loads your **real** profile from the live store, and the dev hooks below change it. Set `ForceMockInStudio = true` first (Output must say `MOCK store`). Each Play is then a fresh player; skip the FTUE from the **server** command bar *before* pressing a key on the Start screen:

```lua
local H, p = game.ServerStorage.DevHooks.Data, game.Players:GetPlayers()[1]
H:Invoke("Skip", p, 2); H:Invoke("Cash", p, 30000)   -- Stage 2, team + 3 desks + Rusty + a Rare
```
1. **Case Opening**: left rail **Shop** → Cases. Rookie Crate $500: ×1 plays the full reveal (drop → shake with a glow that climbs to the rarity → lid pop + beam → card flip → NEW! / "+12 Shards"); ×5 shows face-down cards whose edges glow their rarity (tap or **Reveal all**); ×10 says "Stage 4". **ⓘ Odds** lists every rarity %, the drop-type split and pity. The pity line counts down ("Epic in 7"); the 10th open without an Epic is forced Epic ("Pity guarantee"). Pro Crate is locked until Stage 4 (win the Local Cup for one, or `H:Invoke("Case", p, {"ProCrate", 5})` → **Inventory** → Cases).
2. **Free crate**: 30 min after reaching Stage 2 a "🎁 Free Rookie Crate!" button appears (one banks at most). Shortcut: `H:Invoke("FreeNow", p)`.
3. **Café annex** (right of the garage): **Tech Shop** counter prompt, **Reaction Test** cabinet (8 timing bars → cash + Founder Reflexes XP; also in Arcade Corner), case vault pedestal → Inventory, café PC pads 4 ($1.5k) and 5 ($2k).
4. **Tech Shop** (Shop → Tech Shop): stock rotates every 10 min ("New stock in 9:58"). Buy a part → right panel: pick a desk → equip it from "Your parts" (shows `+0.0% → +1.8%`). Desk tier upgrade $100 / $500 (tier 4 says "later" until Stage 3).
5. **Gear + roster**: **Roster** → a player → Gear slots (Mouse/Keyboard/Headset at Stage 2, the rest 🔒 Stage 3) → pick an owned accessory (shows `Aim 41 → 43`). Rare accessories count as Uncommon at Stage 2. Bench players: **Put in the lineup** swaps them onto a desk; **Release** asks first. The header shows Team Power, role coverage and `5/8`.
6. **Stage 3**: win Pickup Games (lobbies get tougher at Stage 2) or `H:Invoke("Fame", p, 400)` → "PROMOTED! Stage 3: Local Circuit" banner, trophy shelf on the garage back wall, **Compete** rail button.
7. **Scrims** (Compete → Scrims): three offers. Tap maps in ban order (or leave empty for auto), toggle **Pure skill**, **Start scrim**. Pre-match card (power, map, bans, trash talk) → Match HUD (scoreboard, both fives with kills, kill feed, caster lower-third, momentum / CLIP MOMENT toasts, 1×/2×, Skip) → Clutch Moment on match point → result (MVP card, Match Ratings, rewards, clip moments). 45 s cooldown; players gain fatigue (+6), so after many scrims the roster shows "tired (-10%)".
8. **Local Cup** (Compete → Tournaments → Register): bracket of 8, "Quarterfinal in 2:00 · lineup locks in 1:00". It resolves on its own every 5 min, even if you leave (rejoin → "While you were away" recap). Shortcut: `H:Invoke("TourneyNext", p)` plays your next round now; `H:Invoke("Tickets", p, 3)` enables **⏩ Skip**. After each match: toast + **▶ Watch** button replays it. Win → 🏆 Champions confetti, $10k + 300★ + Pro Crate, a cup on the shelf. Stronger team for testing: `H:Invoke("Desks", p)` then `H:Invoke("Recruit", p, "Epic")`.
9. **Leaderboards**: Phone → Leaderboards (Stage 3) and the board at the plaza. In Studio on the mock store they rank this server only.
10. **Odds & Rules**: Phone → Odds & Rules lists every case and how matches are decided.

**Tests** (command bar, Edit or a Play server):
```lua
require(game.ServerScriptService.Tests.CaseOdds).Run()      -- 100,000 rolls per case: actual vs configured odds (z-scores), type split, pity gaps
require(game.ServerScriptService.Tests.MatchUpsets).Run()   -- 1,000 matches per power gap: upset rate vs targets, plus the upset-floor what-if
```
In Edit mode the command bar caches `require`: after changing code, run tests in a fresh Play session (or reopen the place).

New dev hooks: `Fame/Gems/Shards n`, `Stage n`, `Skip n`, `Case id | {id, n}`, `Open {id, count, owned}`, `FreeNow`, `ScrimNow`, `TourneyNext`, `Tickets n`, `Desks`, `Recruit rarity`.

2-player local server: Test → Clients and Servers → Local Server, 2 players → Start. Each player gets their own plot on the ring and only sees their own tutorial, pads and cutscene.

Studio-only QA hooks (server command bar, never on live servers):

```lua
local H, p = game.ServerStorage.DevHooks.Data, game.Players:GetPlayers()[1]
H:Invoke("Peek", p)               -- version, currencies, ledger, step, Ftue, flags, roster, stations
H:Invoke("Beats", p)              -- Stage 1 report: when each beat landed (play time) vs the beat sheet
H:Invoke("Cash", p, 500)          -- logged +500 Cash (passes the save guard), to skip ahead
H:Invoke("PickupNow", p)          -- clear the Pickup Game cooldown
H:Invoke("PlayTime", p, 720)      -- +12 min of play time: Rusty drops to $100 + Aunt Dee text within 5 s
H:Invoke("UnloggedCash", p, 1e6)  -- save guard must block (CurrencyJump)
H:Invoke("SeedRoster", p); H:Invoke("ZeroRoster", p)  -- save guard must block (Wipe)
H:Invoke("SaveNow", p)            -- forced save, 1 per 10 s
H:Invoke("Reload", p)             -- end session + start a new one (leave/rejoin on one server)
H:Invoke("SetVersion", p, 2); H:Invoke("Reload", p)  -- newer save → read-only + kick. Mock store only!
```

Match tuning check (command bar): `print(require(game.ServerScriptService.Services.MatchService.Sim).Batch(170, 204, 10000))` prints the stronger team's win rate. The full sweep is `Tests.MatchUpsets` (below).

**Rojo + OneDrive:** if Studio stops picking up changes (the serve process exits or the watcher misses saves in the OneDrive folder), restart `rojo serve default.project.json` and press **Connect** in the plugin (port 34873).

Never run `SetVersion` against the live DataStore: that profile won't load until a v2 server exists.

## Vendored

`src/server/Lib/Packages/ProfileStore.luau` — ProfileStore by loleris (MadStudioRoblox), commit `45c9847`, Apache-2.0 (license next to it).

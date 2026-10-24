---
tags: [system]
---
# Services & Remotes

Server services and the remotes they expose. One service per feature (see [[Claude Session Primer]]). Extends [[Data Schema]].

## Services
| Service | Owns | Depends on |
|---|---|---|
| DataService | Profile load/save, session lock, migrations, save guard, daily snapshots ([[Data Persistence]]) | — |
| ShutdownService | `BindToClose`, flushers, soft shutdown on update ([[Shutdown & Update Handling]]) | DataService |
| EconomyService | Currencies, transactions, income tick, offline earnings | DataService |
| PlotService | Plot assignment, pads, HQ build, decor | EconomyService |
| RosterService | Hire, release, train, morale, fatigue, contracts | EconomyService |
| StationService | Parts equip, station stats, income tiers, Tech Shop stock + buys | RosterService, GearService |
| CaseService | Rolls, pity, duplicates → shards | EconomyService, RosterService |
| MatchService | Match sim, timed tournaments (lazy round resolution), seasons, ladder | RosterService, StationService |
| ClipService | ClipData creation, feed, views tick (cutscenes render client-side, see [[Clip Cutscene System]]) | MatchService |
| MapService | Map pool, veto, mastery | MatchService |
| SponsorService | Offers, contracts, merch | ObjectiveService |
| StaffService | Staff hire, levels, tactics | EconomyService |
| ObjectiveService | Quests, achievements, sponsor objectives | all (event bus) |
| SocialService | Visits, likes, friend scrims, trades | MatchService |
| TradeService | Trade sessions, locks, atomic commit, AI transfer list, market escrow | DataService, EconomyService |
| EventService | Live events, codes, boosts | ObjectiveService |
| MonetizationService | `ProcessReceipt`, gamepasses, products | EconomyService |
| AnalyticsService | Funnel events | — |
| MarketService | Skin markets per title: listings, escrow, buy orders, price history, payouts ([[Skin Marketplace]]) | DataService, EconomyService, TradeService |
| MilestoneService | Game-wide CCU tracking (MemoryStore), peak CCU, milestone flags (e.g. Dev Crate price, dev boost) | — |
| AbuseEventService | Admin Abuse Events: schedule, runs, caps, cooldowns, pickups ([[Admin Abuse Events]]) | EconomyService, CaseService, AdminService |
| TimeSkipService | Time Skip Tickets: validate and apply skips to any service's timer ([[Time Skip Tickets]]) | MatchService, RosterService, StaffService |
| AdminService | Admin roles, grants + mailbox delivery, moderation, live-ops controls, audit log ([[Admin Panel]]) | DataService, all services |
| ShowcaseService | Global top teams list, dev exclusion ([[Social & Multiplayer]]) | DataService |
| OnboardingService | Intro-seen flag, Starter Letter gift ([[Intro Cutscene]], [[Screen - Starter Letter]]) | EconomyService |
| TeamService | Team name/tag (TextService filter), colors, Founder role ([[Team Identity]]) | PlotService |
| MinigameService | PC cable setup → Founder card, Aim Trainer, Tech Fix jobs, server score caps ([[Playable Games]]) | RosterService, TutorialService |
| TutorialService | Guided FTUE steps from server facts; its last step promotes to Stage 2 through ProgressionService ([[Tutorial & Onboarding]]) | PlotService, ProgressionService |
| GearService | Accessory equip/unequip, gear stats with the stage tier cap, Full/Pure mode ([[Accessories]]) | DataService |
| ProgressionService | Stage promotions: Fame gates from Stage 2 up to `Stages.MaxStage` (the last stage whose content exists), promotion rewards + banner ([[Progression Guide]]) | EconomyService, PlotService |
| LeaderboardService | Fame + Trophies global boards (OrderedDataStore), plaza board ([[Social & Multiplayer]] → Leaderboards) | DataService |

**M1 notes (2026-10-23):** PlotService also builds the Hub + 6-plot ring and owns the Founder seat. RosterService owns the Founder card, seating, station income (EconomyService asks it through an income provider) and the free-agent board. AnalyticsService also tracks play time and when each Stage 1 beat lands. Services report gameplay facts (`PlayerHired`, `PickupFinished`, `PadBought`…) on a server event bus (`Lib/Bus`); TutorialService, AnalyticsService and PlotService listen, so feature services never require the tutorial.

**M2/M3 notes (2026-10-23):** CaseService rolls through `Shared/CaseRoll`, the same module the Odds panel reads. MatchService is split into `Sim` (deterministic engine), `Teams` (AI teams from a seed, sim entries, lineup snapshots) and `Tournament` (timed Local Cup: registration, lock snapshots, lazy seeded resolution on join + 10 s tick, offline recap, replays). MapService is pure helpers + mastery and runs before MatchService (tier 4). RosterService also owns the roster cap, the active five (desks 1–5), lineup swaps and release. PlotService builds the Stage 2 café annex and the Stage 3 trophy shelf.

## Remote naming
`Remotes/<Service>/<Action>`: e.g. `Remotes/Case/Open`, `Remotes/Roster/Hire`. RemoteFunction only when the client needs a reply; otherwise RemoteEvent + state sync.

## Core remotes
| Remote | Type | Args | Server checks |
|---|---|---|---|
| Plot/BuyPad | RF | padId | owns plot, prereqs, cash |
| Roster/Hire | RF | listingId | listing exists, cash, slot free |
| Roster/Release | RF | cardId | not the Founder, not mid-match; gear back to the inventory, chemistry pairs cleared; 1 per 2 s. M2 build: the confirm is a client dialog, no confirm token yet |
| Roster/Train | RF | playerId, stat, duration | slot free, fatigue < 100 |
| Station/Equip | RF | slot, partId | part owned (spare copy), station exists, not mid-match; old part returns |
| Case/Open | RF | caseId, count, owned | price × count (or owned crates), count ∈ {1,5,10}, stage gates; 2/s |
| Match/Start | RF | matchType | roster valid, not in match, cooldown. Built as `Match/StartPickup` and `Match/StartScrim` (below) |
| Clip/Upload | RF | clipId, thumb, titlePreset, tag | clip owned, preset valid |
| Sponsor/Respond | RF | offerId, choice | offer valid |
| Social/Like | RE | targetUserId | once per day |
| Code/Redeem | RF | code | not redeemed, active |
| Tournament/Register | RF | tournamentDefId | stage unlocked, no tournament running (a finished one is archived); missing desks are filled with stand-ins |
| TimeSkip/Use | RF | timerKind, timerId, size | skippable kind, timer running and owned, ticket owned ([[Time Skip Tickets]]) |
| AbuseEvent/State | RE (S→C) | runId, eventId, endsAt, collected | server only |
| Admin/Terminal | RF | console, line | role per command, reason required ([[Admin Panel]] → *12*, *13*) |
| System/ServerClosing | RE (S→C) | reasonText | server only; shows the "Updating… progress saved" overlay |
| Data/Saved | RE (S→C) | — | server only; fired after a forced save (`SaveNow`) lands; shows the "Saved ✓" tick |
| Economy/OfflineEarned | RE (S→C) | amount, seconds | server only; offline earnings paid on join; shows a toast |
| Onboarding/Intro | RE | kind (Started / Skipped / Finished), atSecond | analytics; first Skipped/Finished sets `Flags.IntroSeen` |
| Starter/Collect | RF | — | not collected yet → grants the starter gift once |
| Team/SetIdentity | RF | name, tag, founderRole, primary, tee | 1–20 chars, tag 3–4 A–Z0–9, TextService filter + block list, free before Stage 2; 1 per 2 s |
| Station/BeginSetup | RF | — | team created, not powered, within 12 studs of the Founder desk |
| Station/PowerOn | RF | — | setup begun ≥ 2 s ago → mints the Founder card |
| Minigame/AimStart | RF | — | Founder exists, tutorial reached AimTrainer, near a cabinet, 15 s cooldown → run token + seed |
| Minigame/AimFinish | RF | runId, hits | token matches, run time 18.5–50 s, hits ≤ targets shown and ≤ 2.5/s |
| Minigame/TechStart | RF | — | job ready (tutorial reached TechFix, 90 s since the last), near the bench → job token |
| Minigame/TechFinish | RF | jobId | token matches, 6–300 s |
| Roster/GetFreeAgents | RF | — | read-only; board unlocked once the 2nd desk is owned |
| Roster/Hired | RE (S→C) | cardId | server only; plays the hire walk-in camera |
| Match/StartPickup | RF | — | Founder exists, near the desk, not in a match, 75 s cooldown; 1 per 3 s |
| Match/Resolve | RF | matchId, clutchQuality 0–1 | open match of this player; Skip = 0; idempotent |
| Tutorial/Lines | RE (S→C) | { lineId } | server only; Dee texts / Hector shouts |
| Tutorial/Stall | RE | stepId, level | analytics only; 1 per 10 s |
| Stage/Promoted | RE (S→C) | stage, name, text | server only; promotion banner (replaces M1's `Tutorial/Promoted`) |
| Case/ClaimFree | RF | — | Stage 2+, the 30-min free Rookie Crate timer has run out (one banked at most) |
| Accessory/Equip | RF | cardId, itemId | card in roster, a free copy owned, slot unlocked at stage (Founder mouse from Stage 1), not mid-match; 4/s |
| Accessory/Unequip | RF | cardId, slot | card in roster, slot filled, not mid-match; 4/s |
| Shop/GetStock | RF | — | read-only; Stage 2+; stock is fixed per 10-min window and stage |
| Shop/Buy | RF | kind (Part / Accessory), id | item in the current stock, cash; 3/s |
| Station/Unequip | RF | slot, partSlot | part on that desk, not mid-match |
| Station/Upgrade | RF | slot | next income tier exists, ≤ `TechShop.MaxStationTier[stage]`, cash; 2/s |
| Roster/Lineup | RF | cardId, desk | not the Founder / desk 1, desk exists, not mid-match; whoever sat there goes to the bench |
| Minigame/ReactStart | RF | — | Founder, Stage 2+, near a Reaction Test cabinet, 15 s cooldown → run token + seed |
| Minigame/ReactFinish | RF | runId, hits | token matches, run ≥ rounds × 0.35 s and ≤ 90 s, hits ≤ rounds |
| Match/ScrimBoard | RF | — | read-only; Stage 3+; three AI offers calibrated on Team Power, per-map power for the veto |
| Match/StartScrim | RF | offerId, pure, bans { mapIds } | Stage 3+, offer exists, not in a match, 45 s cooldown; 1 per 3 s |
| Tournament/SetBans | RF | { mapIds } | running tournament, maps in its pool; used at each lock |
| Tournament/Watch | RF | round | your played match in that round; regenerated from seed + snapshot, pays nothing |
| Tournament/Skip | RF | — | running tournament + a Quick Time Skip Ticket: your next match plays now (same seed) |
| Tournament/Close | RF | — | finished → archived to `TournamentLog`; running → clears the offline recap |
| Tournament/MatchReady | RE (S→C) | round, line | server only; "Watch" toast while online |
| Leaderboard/Get | RF | — | read-only; top 10 Fame + Trophies (this server only when the store is unavailable) |
- `Case/Open` (M2): `caseId, count ∈ {1, 5, 10}, owned` → `{ Drops, Shards, Pity }`. `owned = true` opens crates from `Inventory.Cases`, otherwise buys them (price × count, Cash or Gems; no Robux). ×5 from Stage 2, ×10 from Stage 4.
- `Tournament/Register` replaces the generic `Match/Start("Tournament", …)` idea: tournaments play on a timer, so there is nothing for the client to start.

## State sync
- Server pushes profile deltas via `Remotes/State/Delta` (path + value). Client keeps a read-only mirror for UI.
- Currency HUD listens to `Currencies.*` paths.

## Rate limits (per player)
Default 10 calls/s per remote; `Case/Open` 2/s; `Match/Start` 1 per 3 s. Over limit = drop + log.

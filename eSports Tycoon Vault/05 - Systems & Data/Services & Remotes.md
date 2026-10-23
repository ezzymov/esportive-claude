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
| StationService | Parts equip, station stats | RosterService |
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

## Remote naming
`Remotes/<Service>/<Action>`: e.g. `Remotes/Case/Open`, `Remotes/Roster/Hire`. RemoteFunction only when the client needs a reply; otherwise RemoteEvent + state sync.

## Core remotes
| Remote | Type | Args | Server checks |
|---|---|---|---|
| Plot/BuyPad | RF | padId | owns plot, prereqs, cash |
| Roster/Hire | RF | listingId | listing exists, cash, slot free |
| Roster/Release | RE | playerId | owns player, confirm token |
| Roster/Train | RF | playerId, stat, duration | slot free, fatigue < 100 |
| Station/Equip | RF | slot, partId | owns part, slot unlocked |
| Case/Open | RF | caseId, count | price × count, count ∈ {1,5,10} |
| Match/Start | RF | matchType | roster valid, not in match, cooldown |
| Clip/Upload | RF | clipId, thumb, titlePreset, tag | clip owned, preset valid |
| Sponsor/Respond | RF | offerId, choice | offer valid |
| Social/Like | RE | targetUserId | once per day |
| Code/Redeem | RF | code | not redeemed, active |
| Tournament/Register | RF | tournamentDefId | stage unlocked, no tournament running, valid lineup |
| TimeSkip/Use | RF | timerKind, timerId, size | skippable kind, timer running and owned, ticket owned ([[Time Skip Tickets]]) |
| AbuseEvent/State | RE (S→C) | runId, eventId, endsAt, collected | server only |
| Admin/Terminal | RF | console, line | role per command, reason required ([[Admin Panel]] → *12*, *13*) |
| System/ServerClosing | RE (S→C) | reasonText | server only; shows the "Updating… progress saved" overlay |

## State sync
- Server pushes profile deltas via `Remotes/State/Delta` (path + value). Client keeps a read-only mirror for UI.
- Currency HUD listens to `Currencies.*` paths.

## Rate limits (per player)
Default 10 calls/s per remote; `Case/Open` 2/s; `Match/Start` 1 per 3 s. Over limit = drop + log.

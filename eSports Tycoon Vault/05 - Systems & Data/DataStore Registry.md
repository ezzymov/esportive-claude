---
tags: [system, data, persistence, reference]
status: designed
priority: P0
updated: 2026-10-21
system_type: Infrastructure
engine_layer: ServerService
dependencies:
  - "[[Data Persistence]]"
affected_ui: []
roblox_execution_environment: ServerScriptService
---
# DataStore Registry

> Every place the game stores data, in one list. **Add a row before you create a new store in code.** Part of [[Data Persistence]].

## Rule: does it survive?
| Storage | Survives server shutdown? | Survives update? | Use it for |
|---|---|---|---|
| Lua tables on the server | ❌ | ❌ | Working state only. Saved through DataService. |
| **MemoryStore** (SortedMap, Queue, HashMap) | ✅ for a while | ✅ | Cache, cross-server search, reservations, CCU counts. **Can expire, never the only copy.** |
| **DataStore** | ✅ | ✅ | Anything a player would be upset to lose |
| **OrderedDataStore** | ✅ | ✅ | Leaderboard scores only (numbers) |
| MessagingService | ❌ (fire and forget) | ❌ | Pings like "check your mail". Never data. |

## Persistent stores (DataStore)
| Store | Key | Owner service | Holds | Backup | Source note |
|---|---|---|---|---|---|
| `PlayerData` (ProfileStore) | `Player_<userId>` | DataService | The whole `Profile` | Versions + daily snapshot + save guard | [[Data Schema]], [[Data Persistence]] |
| `PlayerBackups` | `<userId>:<YYYY-MM-DD>` | DataService | Daily + pre-update profile copies, 7 days | — (it is the backup) | [[Backups & Recovery]] |
| `AdminMail` | `<userId>` | AdminService | Pending grants for offline players | Versions | [[Admin Panel]] |
| `AdminAudit` | `<ActionId>` | AdminService | Append-only admin action log | Never edited or deleted | [[Admin Panel]] |
| `TradeAudit` | `<TradeId>` | TradeService | Completed trade records | Append-only | [[Trading System]] |
| `MarketEscrow` | `<ListingId>` | MarketService | Listed items + state (`Listed/Reserved/Sold/Cancelled/Expired`) | Versions; recovery job every 10 min | [[Skin Marketplace]], [[Transfer Market]] |
| `MarketPayouts` | `<userId>` | MarketService | Seller payouts waiting to be claimed | Versions | [[Skin Marketplace]] |
| `PriceHistory` | `<Title>:<SkinId>` | MarketService | Daily price points | Rebuildable from sales log | [[Skin Marketplace]] |
| `Milestones` | `PeakCCU`, `Milestones` | MilestoneService | Peak CCU, milestone flags | Versions | [[Dev Players]] |
| `ClipArchive` | `<ClipId>` | ClipService | Clips over 10k views | Versions | [[Clip Cutscene System]] |
| `ShowcaseSnapshots` | `<userId>` | ShowcaseService | Roster snapshots of showcased teams | Rebuildable from profiles | [[Social & Multiplayer]] |
| `LiveOpsConfig` | `Current` | AdminService | Live flags (`ReadOnlyMode`, events, boosts) | Versions | [[Admin Panel]], [[Live Ops & Events]] |

## Leaderboards (OrderedDataStore)
| Store | Key | Value | Source note |
|---|---|---|---|
| `TopTeams_<Season>` | `<userId>` | Team rating | [[Social & Multiplayer]] |
| `LB_Fame_v1` | `<userId>` | All-time Fame (Stage 3+ players), written by LeaderboardService at most once a minute when it changes and on leave | [[Social & Multiplayer]] → Leaderboards |
| `LB_Trophies_v1` | `<userId>` | Trophy count | [[Social & Multiplayer]] → Leaderboards |

## Caches (MemoryStore, can be lost)
| Map | Rebuilt from | Source note |
|---|---|---|
| `ServerCounts` | Each server rewrites every 30 s | [[Dev Players]] |
| Market search index per `Title:SkinId` | `MarketEscrow` (recovery job) | [[Skin Marketplace]] |
| Market order book | Buy-order records in `MarketEscrow` | [[Skin Marketplace]] |
| Trending clips | Views/likes in `ClipArchive` and live counters | [[Clip Cutscene System]] |
| Top teams cache | `TopTeams_<Season>` | [[Social & Multiplayer]] |
| Global market listings | Escrow DataStore | [[Transfer Market]] |

If a MemoryStore map is wiped, nothing is lost. The owner service rebuilds it from the DataStore in the right-hand column.

## Budget
Roblox gives each server a request budget per minute that grows with player count. Every store above goes through one shared **`DataStoreQueue`** module:
- Priority: **1** purchases + trade/market commits → **2** profile saves → **3** mail, audit → **4** snapshots, archive, price history.
- Retries with backoff (1 s, 2 s, 4 s, 8 s, then log `datastore_error`).
- If the budget is low, priority 4 waits. Priority 1 never waits behind it.
- Admin Panel shows remaining budget ([[Admin Panel]] → *This server*).

## Size budget (per profile)
The hard limit per key is 4 MB. Target: under 200 KB for a normal player.
| Field | Cap | When full |
|---|---|---|
| `Roster` | Bench + academy slots ([[Balance Tables]]) | Can't sign more |
| `Clips` | 50 newest saved, older ones only in `ClipArchive` if popular | Oldest dropped |
| Trade log in profile | 50 newest | Full history in `TradeAudit` |
| `ClaimedGrants`, `Purchases` | No cap (small IDs). Compact entries older than 90 days into a count. | — |
| `Warnings`, `ModNotes` | 100 | Oldest moved to `AdminAudit` |

## Acceptance criteria
- [ ] Every `DataStoreService:GetDataStore` call in code matches a row here (grep check).
- [ ] Wipe each MemoryStore map in the test place → service rebuilds it, no player loses anything.

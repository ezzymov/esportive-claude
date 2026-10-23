---
tags: [index, system, claude]
updated: 2026-10-21
---
# Claude Index: Vault → Code Execution Guide

> Read this first when turning the vault into Luau. It tells you **what to build, in what order, and which note is the source of truth** for each piece.
> Session rules (server-authoritative, config-driven, TextService filtering, small testable steps) live in [[Claude Session Primer]]. Code layout lives in [[Data Schema]] → *Folder layout*.

**How to read a feature note:** every note in `02 - Features` has frontmatter keys `system_type`, `engine_layer`, `dependencies`, `affected_ui`, `roblox_execution_environment`. Build a note's `dependencies` before the note itself. Build its `affected_ui` screens last.

---

## 1. System Architecture Map (build order)

Build in layers. Never start a layer until the one above it compiles and passes a Play Solo test.

```
L1 Configs ──► L2 Data Types ──► L3 Server Services ──► L4 Client Controllers ──► L5 UI
ReplicatedStorage/   Shared types +      ServerScriptService/     StarterPlayerScripts/     StarterGui/
Shared/Config/*      Profile template    Services/*               Controllers/*             ScreenGuis
```

### L1 · Configs (`ReplicatedStorage/Shared/Config`)
Pure data ModuleScripts. No logic, no requires except other configs.

| Module | Source note |
|---|---|
| `Rarities`, `Stages`, part tiers, station income, prize pools, drop tables | [[Balance Tables]], formulas in [[Economy Design]] |
| `Pads.lua` | [[Plot & HQ]] |
| `Parts.lua`, `Brands.lua`, `PlayerNames.lua`, `Cosmetics.lua`, `AITeams.lua` | [[Content Catalog]] (`AITeams` also in [[Rivalries & Storylines]]) |
| `Cases.lua` | [[Case Library]] |
| `Traits.lua` | [[Trait Library]] |
| `KeyPlayers.lua` | [[Key Players]] |
| `AvatarPools.lua` | [[Player Generator]] |
| `Furry.lua` | [[Furry Variants]] |
| `DevPlayers.lua` | [[Dev Players]] |
| `Maps.lua` | [[Maps & Map Pool]] + [[Map Library]] |
| Game title definitions (sides, roles, loadouts) | [[Game Titles Overview]], [[Aim Arena]], [[Spectra]], [[Tower Clash]], [[Drop Zone]], [[Kart Rift]], [[Brawl Legends]]; content libraries [[Agent Library]], [[Hero Library]], [[Champion Library]] |
| `Skins.lua` | [[Skin Marketplace]], [[Skin Library]], [[Skin Pattern System]] |
| `StickerWords.lua` | [[Sticker System]] |
| `Sponsors.lua` | [[Sponsors]] |
| `LifeEvents.lua` | [[Player Life Events]] |
| `Events.lua` | [[Live Ops & Events]] |
| `Seasons.lua` | [[Monthly Seasons]] |
| `CasterLines.lua` | [[Caster & Commentary]] |
| `VoiceLines.lua`, `VoiceText.lua` | [[Player Voice Lines]], [[Pro Voice Lines]] |
| `Tutorial/*`, `Cutscenes/*` | [[Tutorial & Onboarding]], [[Tutorial Voice Script]], [[Intro Cutscene]] |
| `Theme.lua` | [[UI Style Guide]] |

### L2 · Data Types (`ReplicatedStorage/Shared/Types` + `DataService` template)
| Type | Source note |
|---|---|
| `Profile` (root save table, `Version`, migrations) | [[Data Schema]], [[Save Versioning & Migrations]] |
| `PlayerCard` | [[Data Schema]], generation rules in [[Player Generator]], stat/OVR math in [[Skill Levels & Ratings]] |
| `ClipData` | [[Clip Cutscene System]] → *1. ClipData* |
| Match input/output payload | [[Match Simulation]] → *Inputs* / *Output* |
| Skin instance (seed, wear, stickers) | [[Skin Pattern System]], [[Sticker System]] |
| Trade session / market listing | [[Trading System]], [[Skin Marketplace]] |

### L3 · Server Services (`ServerScriptService/Services`)
Order follows the **Depends on** column in [[Services & Remotes]]. Tier 0 boots first.

| Tier | Services | Primary feature notes |
|---|---|---|
| 0 | `DataService`, `ShutdownService`, `AnalyticsService`, `MilestoneService` | [[Data Schema]], [[Data Persistence]], [[Shutdown & Update Handling]], [[Save Versioning & Migrations]], [[Backups & Recovery]], [[Analytics & Metrics]], [[Dev Players]] (CCU milestones) |
| 1 | `EconomyService` | [[Economy Design]], [[Fan Base & Arena]] |
| 2 | `PlotService`, `RosterService`, `StaffService`, `MonetizationService` | [[Plot & HQ]], [[Player Hiring]], [[Founder (You)]], [[Friend Signings]], [[Academy & Youth]], [[Player Life Events]], [[Staff & Training]], [[Monetization]] |
| 3 | `StationService`, `CaseService`, `TradeService` | [[PC Setups]], [[Case Unboxing]], [[Trading System]], [[Transfer Market]] |
| 4 | `MatchService` | [[Match Simulation]], [[Matches & Tournaments]], [[Playable Games]], [[Rivalries & Storylines]] |
| 5 | `ClipService`, `MapService`, `SocialService`, `ObjectiveService`, `MarketService`, `ShowcaseService` | [[Clips & Traction]], [[Maps & Map Pool]], [[Social & Multiplayer]], [[Daily Loops & Quests]], [[Achievements & Collections]], [[Skin Marketplace]] |
| 6 | `SponsorService`, `EventService`, `SeasonService`*, `TutorialService`* | [[Sponsors]], [[Live Ops & Events]], [[Monthly Seasons]], [[Tutorial & Onboarding]] |
| 7 | `AdminService` (depends on all) | [[Admin Panel]] |

\* Named in the feature note but **not yet listed** in [[Services & Remotes]]. Add them there before coding.
Cross-cutting rules for every service: [[Security & Anti-Exploit]] (validation, rate limits, purchases, logging).

### L4 · Client Controllers (`StarterPlayerScripts/Controllers`)
| Controller | Source note |
|---|---|
| `StateController` (read-only profile mirror from `State/Delta`) | [[Services & Remotes]] → *State sync* |
| `UIController` (screen router, `Theme`, UIScale) | [[Data Schema]], [[UI Style Guide]] |
| `CutsceneController` | [[Intro Cutscene]] |
| `TutorialController` (draws only, holds no state) | [[Tutorial & Onboarding]] |
| `CaseOpenController` | [[Case Unboxing]], [[Screen - Case Opening]] |
| Clip playback: Choreographer, Stage Builder, Camera Director, Editor | [[Clip Cutscene System]] → *2–5*, *11. Build order* |
| Caster / voice playback | [[Caster & Commentary]], [[Player Voice Lines]], [[Pro Voice Lines]] |

### L5 · UI (`StarterGui`)
World geometry (hub, districts, plot zones, streaming budgets) follows [[World Layout & Presentation]].
Build each screen to its spec in `04 - UI References/Screens`, styled by [[UI Style Guide]]. Hub: [[UI Reference Hub]], [[Screen Notes]].
Order matches the prototype slice: [[Screen - Main HUD]] → [[Screen - Team Creator]] → [[Screen - Roster]] → [[Screen - Tech Shop]] → [[Screen - Match HUD]] → [[Screen - Bracket]] → [[Screen - Case Opening]] → [[Screen - Settings & Odds]] → everything else.

---

## 2. Key Data Models

### Player state (per-user, saved)
- [[Data Schema]]: **the `Profile` table. Single source of truth for saved fields.**
- [[Founder (You)]]: the founder card, which is always on the roster.
- [[Economy Design]]: `Currencies` (Cash, Gems, Shards, Fame, Followers, LegacyPoints), faucets and sinks.
- [[Progression Guide]]: `Stage`, unlock gates, currencies by stage.
- [[Franchise Rebirth]]: what `Rebirths` / `LegacyPerks` reset vs keep.
- [[Daily Loops & Quests]]: `Quests`, `Streak`.
- [[Achievements & Collections]]: `Achievements`, `Collection`.

### Team & roster state
- [[Data Schema]] → `PlayerCard`, `Roster`, `Stations`, `Staff`, `Team`.
- [[Player Generator]]: how a card is created (seeded stats, names, look, vibe).
- [[Skill Levels & Ratings]]: stat levels, OVR, hidden Potential, Match Rating, ladder.
- [[Trait Library]]: trait effects and combos.
- [[Team Identity]]: `Team` name / tag / logo / jersey and text-filter rules.
- [[PC Setups]]: `Stations[slot].Parts` and their stat effects.
- [[Staff & Training]]: `Staff`, `Training`.
- [[Rivalries & Storylines]]: `Rivals`.

### Global configuration (shared, read-only)
- [[Balance Tables]]: every tunable number.
- [[Content Catalog]]: brands, parts, names, AI teams, cosmetics.
- [[Case Library]]: case contents and odds. [[Furry Variants]] adds the furry roll layer.
- [[Key Players]], [[Pro Player References]], [[Gamertag Bank]], [[Dev Players]]: hand-made players.
- [[Map Library]], [[Game Titles Overview]]: titles and maps.
- [[Skin Library]], [[Skin Pattern System]]: cosmetics.
- [[Monthly Seasons]], [[Live Ops & Events]]: time-boxed config.

### Global / cross-server state (not in Profile)
- [[Skin Marketplace]]: listings, buy orders, price history (DataStore + MemoryStore).
- [[Trading System]], [[Transfer Market]]: trade sessions, escrow.
- [[Social & Multiplayer]]: Global Top Teams showcase.
- [[Admin Panel]]: grants mailbox, audit log, admin roles (`ServerStorage/AdminConfig`).
- [[Dev Players]]: CCU milestones via `MilestoneService`.

---

## 3. Client–Server Network Map

Remote convention: `Remotes/<Service>/<Action>`. Use a RemoteFunction (RF) only when the client needs a reply. State flows back through `Remotes/State/Delta`. Default rate limits are in [[Services & Remotes]] → *Rate limits*.

> There are no separate "client remote API" notes. Remote tables live in [[Services & Remotes]] (*Core remotes*) and in the feature or screen notes listed below. The **Remote spec** column says where each table is.

| Server service | Remotes | Remote spec | Client / UI note |
|---|---|---|---|
| DataService | `State/Delta` (S→C) | [[Services & Remotes]] | every screen (HUD mirror) |
| PlotService | `Plot/BuyPad` | [[Services & Remotes]] | [[Screen - Main HUD]] |
| RosterService | `Roster/Hire`, `Roster/Release`, `Roster/Train` | [[Services & Remotes]] | [[Screen - Roster]], [[Screen - Staff & Training]] |
| StationService | `Station/Equip` | [[Services & Remotes]] | [[Screen - Tech Shop]] |
| CaseService | `Case/Open` | [[Services & Remotes]] | [[Screen - Case Opening]], [[Screen - Settings & Odds]] |
| MatchService | `Match/Start` | [[Services & Remotes]] | [[Screen - Bracket]], [[Screen - Match HUD]] |
| ClipService | `Clip/Upload`, `Clip/Fetch`, `Clip/Like`, `Clip/Report`, `Clip/SetTheater` | [[Services & Remotes]], [[Screen - Clip Feed]] | [[Screen - Clip Feed]] |
| SponsorService | `Sponsor/Respond` | [[Services & Remotes]] | [[Screen - Sponsors]] |
| SocialService | `Social/Like` | [[Services & Remotes]] | [[Social & Multiplayer]] (no screen yet) |
| EventService | `Code/Redeem` | [[Services & Remotes]] | [[Screen - Settings & Odds]] |
| TradeService | `Trade/Request`, `Respond`, `SetOffer`, `Ready`, `Confirm`, `Cancel`, `Undo`, `Phrase` | [[Trading System]] | [[Screen - Trade]] |
| MarketService | `Market/Browse`, `GetSkin`, `List`, `Cancel`, `Buy`, `PlaceOrder`, `CancelOrder` | [[Skin Marketplace]] | [[Screen - Skin Marketplace]] |
| *(sticker handlers)* | `Sticker/Apply`, `Save`, `SaveDesign`, `Print`, `PostCraft`, `Peel`, `Scrape` | [[Sticker System]] | [[Screen - Sticker Editor]] |
| SeasonService* | `GetSeasonState` (RF), `ClaimHeadliner` (RE) | [[Monthly Seasons]] | [[Screen - Main HUD]], [[Screen - Store]] |
| TutorialService* | `Tutorial/*` | [[Tutorial & Onboarding]] | `TutorialController` |
| MonetizationService | `ProcessReceipt` (no client remote) | [[Monetization]], [[Security & Anti-Exploit]] → *Purchases* | [[Screen - Store]] |
| ObjectiveService | state sync only | [[Daily Loops & Quests]] | [[Screen - Quests]] |
| AdminService | `Remotes/Admin/*`, each gated by `AdminService:Require` | [[Admin Panel]] | [[Screen - Admin Panel]] |

\* Not yet in [[Services & Remotes]]. Sticker remotes have no owning service listed; decide whether they go under `MarketService` or a new `StickerService`.

---

## 4. Top 5 Core Feature Files (playable prototype)

Target: the Stage 1 vertical slice from [[Roadmap]] M0–M1/M3: *join → earn → hire → passive income → scrim → save → rejoin*.

| # | Note | Why it's critical |
|---|---|---|
| 1 | [[Data Schema]] | Profile, PlayerCard, folder layout and the server-authoritative rules. Nothing saves or loads without it. |
| 2 | [[Services & Remotes]] | Service dependency graph, remote names, server checks and state sync. It's the skeleton every feature hangs on. |
| 3 | [[Plot & HQ]] | The tycoon core: buy pads, HQ growth, passive-income source. It's the first thing the player touches. |
| 4 | [[Player Hiring]] | Roster creation and the first hire. With [[Founder (You)]], it gives you a team to play with. |
| 5 | [[Match Simulation]] | Turns roster stats into wins, cash and Fame, which closes the loop. [[Matches & Tournaments]] supplies the match types (start with Scrim). |

**Read alongside:** [[Data Persistence]] (before writing `DataService`), [[DataStore Registry]] (before creating any store), [[Stage 1 - Garage Squad]] (minute-by-minute slice), [[Balance Tables]] (starting numbers), [[Security & Anti-Exploit]] (before writing any remote).
**Next after the prototype:** [[PC Setups]] → [[Case Unboxing]] → [[Tutorial & Onboarding]].

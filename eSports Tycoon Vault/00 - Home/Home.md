# 🏆 eSports Tycoon — Home

> Build an esports organization from a garage squad to a world-champion franchise. Roblox, built in Studio with Claude.

## Map of the vault
| Folder                          | What lives there                                                                                                                         |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| [[Game Pitch]]                  | One-page pitch, pillars, core loop                                                                                                       |
| [[Feature Index]]               | Every feature, status, priority                                                                                                          |
| [[Progression Guide]]           | Stage-by-stage player journey + pacing                                                                                                   |
| [[UI Reference Hub]]            | Screenshots, mockups, style guide                                                                                                        |
| [[Economy Design]]              | Currencies, sinks/faucets, formulas                                                                                                      |
| [[Data Schema]]                 | DataStore + module layout                                                                                                                |
| [[Data Persistence]]            | No-data-loss rules: session lock, saves, shutdown/updates, migrations, backups                                                           |
| [[DataStore Registry]]          | Every DataStore/MemoryStore, owner, backup                                                                                               |
| [[Claude Session Primer]]       | Paste at the start of each Claude/Studio session                                                                                         |
| [[Roadmap]]                     | Milestones and current sprint                                                                                                            |
| [[Art & Audio Direction]]       | World look, lighting, VFX, music, SFX                                                                                                    |
| [[Stage Beat Sheets 2-10]]      | Beat-by-beat plan for every stage                                                                                                        |
| [[Balance Tables]]              | Rarity, parts, income, prizes, drop tables                                                                                               |
| [[Match Simulation]]            | How matches are decided                                                                                                                  |
| [[Services & Remotes]]          | Server services and remote API                                                                                                           |
| [[Security & Anti-Exploit]]     | Exploit defenses, purchase safety                                                                                                        |
| [[Analytics & Metrics]]         | Funnels, KPIs, targets                                                                                                                   |
| [[Content Catalog]]             | Brands, parts, names, AI teams, cosmetics                                                                                                |
| [[Glossary]]                    | Terms used across the vault                                                                                                              |
| [[Intro Cutscene]]              | First-load cutscene: dropped off at your garage                                                                                          |
| [[Tutorial & Onboarding]]       | Aunt Dee's guided FTUE, unlock lessons, help app                                                                                         |
| [[Player Voice Lines]]          | Voice-line system + generic lines per vibe for normal players                                                                            |
| [[Pro Voice Lines]]             | A separate 12–14 line voice pack for every named pro                                                                                     |
| [[Tutorial Voice Script]]       | Every voiced tutorial line, ready to record                                                                                              |
| [[Founder (You)]]               | You are your team's first player; earn money solo before hiring                                                                          |
| [[Furry Variants]]              | 4% of generated players unbox as cartoon animal-people (13 species, cosmetic only)                                                       |
| [[Player Generator]]            | Random stats, names, looks, vibes for Common–Epic players                                                                                |
| [[Key Players]]                 | 2–3 hand-made players per title per rarity (Common–Epic)                                                                                 |
| [[Friend Signings]]             | Sign Roblox friends with their real avatar                                                                                               |
| [[Pro Player References]]       | Star players + their real-life inspirations (vault only)                                                                                 |
| [[Skill Levels & Ratings]]      | Stat labels, Level 1–10, Match Rating, ladder tiers                                                                                      |
| [[Trait Library]]               | Every player trait, combos, Mythic uniques                                                                                               |
| [[Game Titles Overview]]        | The 6 in-tycoon esports games: [[Aim Arena]], [[Spectra]], [[Tower Clash]], [[Drop Zone]], [[Kart Rift]], [[Brawl Legends]]              |
| [[Agent Library]]               | 26 realistic Aim Arena Agents (cosmetic)                                                                                                 |
| [[Hero Library]]                | 20 Spectra heroes with laser blasters and abilities                                                                                      |
| [[Champion Library]]            | 30 Tower Clash Champions + draft comps                                                                                                   |
| [[Gamertag Bank]]               | Natural pro-style gamer tags + generator rules                                                                                           |
| [[Clip Cutscene System]]        | Clips as watchable 3D cutscenes: choreographer, camera, editor                                                                           |
| [[Maps & Map Pool]]             | Map effects, mastery, veto, rotation                                                                                                     |
| [[Map Library]]                 | All maps per title + event maps + hub world layout                                                                                       |
| [[HQ Era Visual Guide]]         | What every HQ era looks like: exterior, floor plans, props, lighting, sound, region skins                                                |
| [[Jersey Progression]]          | Kits grow with the HQ: garage tees → real jerseys → stage kits; colors free to change                                                    |
| [[World Layout & Presentation]] | How the game is presented: hub map, districts, plot anatomy, where each activity happens                                                 |
| [[Skin Pattern System]]         | Seeds, condition, finishes, signature patterns, trackers                                                                                 |
| [[Sticker System]]              | Stickers on skins: placement, finishes, capsules, Sticker Maker; power on accessories                                                    |
| [[Admin Abuse Events]] | Scheduled (Sat 17:00 UTC + surprise) or admin-triggered free chaos: Cash Rain, Crate Drop, Luck Surge, Mythic Raffle… |
| [[Time Skip Tickets]] | 15 min / 1 h / 4 h tickets that finish one timer (tournament waits, training…) |
| [[Accessories]]                 | Mouse, keyboard, headset, sleeve, glasses, charm: cosmetics with stat power (tier + stickers), off in Ranked                             |
| [[Skin Library]]                | ~80 skin ideas by collection, region, event + patches/charms                                                                             |
| [[Case Library]]                | Every case: core, themed, role, title, region, event, special, crafting                                                                  |
| [[Dev Players]]                 | The devs as cards (3zzy, Philip, appropriateuser): +30% over your best in 2 specialty stats, Dev Crate (500 R$ / 2,500 Gems, equal odds) |
| [[Skin Marketplace]]            | Six player-run "online" skin markets (one per title), dev launch prices, stickers sell with the skin                                     |
| [[Admin Panel]]                 | Dev-only panel: give any player/case to any account, moderation, live ops, audit log                                                     |
| [[Monthly Seasons]]             | Proposal: a season per calendar month, real-life themes, exclusive Season Case + new pros                                                |

## Folder conventions
- `00 - Home` – this page, glossary, decisions log
- `01 - Vision` – why the game exists
- `02 - Features` – one note per feature (use [[Feature Template]])
- `03 - Progression` – stages, unlock gates, pacing math
- `04 - UI References` – **all visual reference material** (see [[UI Reference Hub]])
- `05 - Systems & Data` – technical design that Claude reads when coding
- `06 - Studio + Claude Workflow` – how we work
- `07 - Roadmap` – milestones, sprint logs, bug list
- `Templates` – Obsidian templates (set as Templates folder in core plugin)
- `Attachments` – pasted images land here (Settings → Files & Links → Default location)

## Naming rules
- Notes: `Title Case`, no dates in names except logs (`2026-10-20 Sprint 1`).
- Tags: `#feature`, `#system`, `#ui`, `#stage/1`…`#stage/10`, `#status/idea|designed|building|done`.
- Link generously with `[[wikilinks]]`; every feature note links to its progression stage and UI screens.

## Suggested plugins
Dataview (feature status tables), Excalidraw (UI wireframes), Kanban (roadmap), Templater (optional), Canvas (core; use for the loop diagram).

## Live dashboard (needs Dataview)
```dataview
TABLE status, priority, stage
FROM "02 - Features"
WHERE file.name != "Feature Index"
SORT priority ASC
```

## Decisions log
| Date | Decision | Why |
|---|---|---|
| 2026-10-20 | Vault created | Single source of truth for design + Claude context |
| 2026-10-20 | Async snapshot PvP for launch, no real-time PvP | Simpler, safer, works with offline players |
| 2026-10-20 | AI transfer list at launch, global market post-launch | Duplication/exploit risk |
| 2026-10-20 | Prediction Pick'em uses no currency | Avoid gambling mechanics |
| 2026-10-20 | Player starts as the team's only player (Founder) and earns money before the first hire | Personal stake, makes the first hire a milestone |
| 2026-10-20 | Aunt Dee is the only tutorial guide; Aim Trainer is Stage 1, Reaction Test is Stage 2's new toy | One clear, personal voice; no duplicate unlock |
| 2026-10-20 | Auto team name; free rename until Stage 2, then 39 R$ | No hard lock in the FTUE |
| 2026-10-20 | All tutorial lines fully voiced (recorded manually); income never pauses; Robux boosts don't skip tutorial steps | Polish + fair pacing |
| 2026-10-21 | ProfileStore + save guard + daily snapshots; old-version servers never save newer profiles; ship with Migrate To Latest Update | No player data loss on crash, shutdown or update |
| 2026-10-21 | Cosmetics get power only through Accessories (tier + stickers, +12/stat cap); seed/condition/finish never give power; mouse/keyboard/headset move from PC parts to Accessories; Ranked is Pure (player power only), scrims Full with a Pure toggle; in-match gear stays pure style | Cosmetics should matter, without making ranked pay-to-win |
| 2026-10-21 | HUD has 9 permanent buttons: left Roster · Compete · Shop · Inventory · Quests, right Store · Gift · Map · Phone; everything else in Phone apps or contextual buttons | Mobile space, muscle memory, no clutter as features unlock |
| 2026-10-22 | In-game name stays "Admin Abuse"; Sat 17:00 UTC slot and tournament timings approved as starting values | Discoverability; tune in playtests |
| 2026-10-21 | Tournaments take real time (15 min Local Cup → ~8 h Worlds), resolve lazily from a fixed seed, play on while offline; Time Skip Tickets skip waits without changing results | Tournaments feel like events, give the HQ loop purpose between rounds, create return moments |
| 2026-10-21 | Admin Abuse Events (auto schedule + manual), Moderation Terminal and global Announcement Terminal in the Admin Panel; terminals call the same audited actions as buttons, no raw code | Hype/CCU spikes; faster moderation without new back doors |
| 2026-10-20 | Shooters use realistic firearms (fictional names), Spectra uses laser blasters; no blood, deaths ragdoll; audience 13+ pending maturity label | Owner's direction |

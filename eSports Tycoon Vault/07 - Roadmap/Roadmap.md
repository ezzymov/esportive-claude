# Roadmap

## Milestones
| M | Name | Contents | Done when |
|---|---|---|---|
| M0 | Foundations | Vault, data layer, currency HUD, plot with buy buttons | Join, earn, save, rejoin |
| M1 | Stage 1 slice | Intro cutscene, Founder, Pickup Games, Tech Fix, team creator, stations, first hire, passive income | 15-min FTUE playable |
| M2 | Unboxing | Case service, odds, pity, reveal UI | Open all Rookie/Pro cases |
| M3 | Competition | Scrim + Local Cup sim, Fame, bracket UI | Win first trophy |
| M4 | Traction | Clip moments, editor, feed, sponsors | 1k followers path |
| M5 | Depth | Staff, training, minigames, stages 5–7 | Mid-game loop |
| M6 | Launch polish | Monetization, quests, tutorial, SFX, perf | Closed playtest |
| M7 | Live ops | Events, rebirth, leaderboards, trading | Public launch |

## Current sprint
- [ ] Decide final team of fictional game titles
- [ ] Collect 20 UI references per folder in [[UI Reference Hub]]
- [x] Build Stage 1 plot in Studio (M1 slice, greybox)
- [ ] Human playtest of the Stage 1 slice (beat times vs [[Stage 1 - Garage Squad]] → *Playtest*)
- [ ] Decide the 2× power match target ([[Match Simulation]] → *M2/M3 measured*: `UpsetFloor = { Chance = 0.16, Pull = 0 }` hits 50 / ~70 / ~92%; off for now)
- [x] Data layer + autosave: build to [[Data Persistence]] (DataService + ShutdownService + Migrations v1 + save guard)
- [ ] Review [[Balance Tables]] in a spreadsheet (`Attachments/Economy.xlsx`)
- [ ] Decide paid-crate policy (see [[Monetization]] open question)
- [x] Write 5 caster lines per match event ([[Caster & Commentary]])

## Sprint log
- 2026-10-23 — M2 Unboxing + M3 Competition code (greybox). CaseService with shared CaseRoll (odds panel = server roll), Rookie/Pro/Starter crates, pity 10/50/300, duplicates → Shards, ×1/×5/×10, free Rookie Crate every 30 min; Case Opening reveal (rarity glow, stings, caster reactions, multi-open grid) + Shop/Inventory rails. Stage 2: café annex (Tech Shop counter, Reaction Test, case vault, café PCs 4–5), Tech Shop (rotating parts + accessories, desk tiers), GearService (stage tier cap, Full/Pure), roster cap + lineup + release. Full Match Simulation (traits, morale, fatigue, chemistry, synergy, momentum, MapFit/Mastery, kill sequence, Clip Moments, Match Rating), MapService (pool + Bo1 veto), Match HUD with Hector/Dr. Data lines, scrims (power-calibrated offers), timed Local Cup (lock snapshots, lazy seeded rounds, offline recap, watch replays), trophy shelf, Stage 3 promotion (ProgressionService), Fame/Trophies leaderboards. Tests: 100k-roll case odds (pass) and 1k-match upset sweep. Vault updated: statuses, Services & Remotes, Data Schema, DataStore Registry, Balance Tables, Match Simulation, Case Library, Maps, Content Catalog, Plot & HQ, Stage 2 beat sheet.
- 2026-10-23 — M1 Stage 1 slice code (greybox): 6-plot ring around Spawn Plaza + districts (Arcade Corner cabinet), PlotService assignment/spawn, Garage era garage. Start screen, Intro Cutscene (10 shots, own avatar, hold-to-skip), Starter Letter, Team Creator (TextService filter, Founder role, tee color, bedsheet banner). PC cable setup → Founder card, seated-only desk income, Player Generator + OVR, Rusty, free-agent board + 12-min guardrail, Pickup Games (TeamPower + Elo rounds, Clutch round, pity), Aim Trainer + Tech Fix with server caps, mouse/desk pads, Rookie Crate placeholder (guaranteed Rare), Guided FTUE (13 steps, chevrons, goal banner, objective card, Dee texts/calls, promotion to Café Rookies), 15-step onboarding funnel. Scripted test run finished Stage 1 at 8:11 play time. Vault updated: Stage 1 playtest, Balance Tables Stage 1 numbers, Plot & HQ pads, Accessories mouse exception, Match Simulation measured, Tutorial gating + step 13, 3 new voice lines, Data Schema, Services & Remotes, Analytics funnel, HUD, statuses → building.
- 2026-10-22 — M0 Foundations code: Rojo layout, service/controller loader, Remote helper (rate limits + arg checks), DataService (ProfileStore, v1 migrations, save guard, read-only, SaveNow 1/10 s), ShutdownService, EconomyService (Transact, income tick, 4 h offline), state mirror, HUD pills + Saved tick, test buy pad. Cross-server save test pending Studio API access.
- 2026-10-21 — Added Admin Abuse Events (14 events, weekly Abuse Hour Sat 17:00 UTC, surprise events ~3 h, manual from panel with approval rules), Moderation Terminal + global Announcement Terminal in the Admin Panel, timed tournaments (registration, lock times, lazy seeded resolution, offline recap), Time Skip Tickets (15 min / 1 h / 4 h, free daily sources, Gem/Robux packs).
- 2026-10-21 — Decided always-visible HUD buttons ([[Screen - Main HUD]]): 9 permanent (Roster, Compete, Shop, Inventory, Quests | Store, Gift, Map, Phone) with unlock timing, Phone apps for the rest, contextual buttons (Collect, Next match, Claim crate, Event, Back to HQ, Rebirth, Skip), mobile 2-column fallback.
- 2026-10-21 — Added Reference Board - Simulator UI: 7 Roblox simulator refs (shops, settings toggles, colored item cards, VIP banner, Figma→Studio cards, grid + preview picker, tab pills), linked into Store, Settings & Odds, Tech Shop, Skin Marketplace, Roster, Sticker Editor, Team Creator, Main HUD and Shop. Open: bright vs dark-neon style.
- 2026-10-21 — Added Accessories: 6 personal gear slots (mouse, keyboard, headset moved from PC parts + arm sleeve, glasses, lucky charm), one stat each, tier bonus +1 to +8 with stage tier cap, stat-tagged stickers (matching/off-stat, Full Set, Signed gear), +12 cap per stat. Gear Mode: Ranked always Pure, scrims/friend scrims Full with Pure toggle. Updated Sticker System, Skin Pattern System, PC Setups, Match Simulation, Balance Tables, Matches & Tournaments, Social & Multiplayer, Monetization, Data Schema, Tech Shop, Content Catalog, Skill Levels, Glossary.
- 2026-10-21 — Added Jersey Progression: 6 kit tiers tied to HQ era + HQ Level (own tees → matching tees → screen-print → practice top → team jersey → pro kit → stage kit/Worlds kit), free color changes with Home/Away/Alt, pattern skins scale with the garment.
- 2026-10-21 — Added HQ Era Visual Guide: all 6 eras in detail (exterior, floor plans, rooms, stations, palette, lighting, sound, NPC life), kept items across eras (taped chair, garage door, bedsheet banner), era cinematics, region skins, visitor route. Fixed era order (Training Center before Gaming House) in Glossary and Plot & HQ.
- 2026-10-21 — Added World Layout & Presentation: 6-plot ring road around Spawn Plaza with a district between each plot, 256 × 256 plot zones by era, where every activity happens (walkable vs local Stages), fast travel, visibility, lighting zones, performance budgets, build order per milestone.
- 2026-10-21 — Added Golden Touch admin command ([[Admin Panel]] → *10*): guaranteed gold (★ → Legendary → top rarity) from every case the panel user opens; `/gold on [n]`; live = Owner + two-person approval, items untradeable, pity and odds stats untouched.
- 2026-10-21 — Added data-loss protection notes: [[Data Persistence]] hub, [[Shutdown & Update Handling]], [[Save Versioning & Migrations]], [[Backups & Recovery]], [[DataStore Registry]].
- 2026-10-20 — Vault scaffolded.
- 2026-10-21 — Furry Variants: seasonal species boosts + 12 limited season fur palettes, and the Critter Crate ($12k Cash, 40% furry, furry pity every 4th open).
- 2026-10-21 — Added Furry Variants: 4% of generated players unbox as furries (13 species in 4 tiers, cosmetic only, odds disclosed, Critter Crew collection, trade multiplier, show-as-human setting).
- 2026-10-21 — Reworked Dev Crate odds: 0.2% (Stage 3) → 1.5% cap, plus Dev Pity (guaranteed dev every 75 opens); 150 CCU price rise to 1,000 R$ per open confirmed.
- 2026-10-21 — Dev Players update: third dev is appropriateuser; 3zzy gamepass removed, Dev Crate now 500 R$ or 2,500 Gems per open with odds shown and equal pull chance per dev; Philip and appropriateuser voice packs (30 lines each).
- 2026-10-21 — Reworked 3zzy into Dev Players: Dev ✦ tier (3zzy Aim+Clutch, Philip Game Sense+Teamwork, third dev Aim+Reflexes), specialty stats = best-in-stat ×1.3 (×1.4 at 200 CCU), Dev Crate replaces Signature Case, dev voice packs.
- 2026-10-21 — Added Player Voice Lines (system, 8 generic vibe pools, 176 lines) and Pro Voice Lines (62 separate pro packs, 782 lines incl. Mythic TRAIT lines).
- 2026-10-21 — Added 3zzy (Signature Pro): Signature rarity, OVR = best player ×1.2 (×1.3 at 200 CCU), 500 R$ pass (1,000 R$ at 150 CCU), Signature Case 0.01%→1.5% by progress, 86 voice lines. Documented as the one exception to the no-pay-for-power rule.
- 2026-10-21 — Added Skin Marketplace + Screen - Skin Marketplace: six player-run "online" skin markets (one per title), dev Launch Prices → sales-median pricing, buy orders, stickers sold with the skin unless removed before listing.
- 2026-10-21 — Added Admin Panel + Screen - Admin Panel: role-gated grants of any player/case to any account (mailbox delivery, cross-server), moderation, item trace, live ops, tester tools, audit log.
- 2026-10-21 — Added Global Top Teams showcase: best teams visible game-wide on every server; dev accounts excluded in a later phase.
- 2026-10-21 — Proposed Monthly Seasons: 12 real-calendar themes, Season Case per month, 36 new season pros (12 Mythic headliners), Sparks, Season Signing.
- 2026-10-20 — Added 7 missing feature notes, 10 new feature notes, 14 screen specs, stage beat sheets 2–10, balance tables, match sim, services/remotes, security, analytics, content catalog, art & audio direction, glossary.
- 2026-10-20 — Added Intro Cutscene (drop-off at the garage) and Founder (You); reworked Stage 1 so you start solo and earn money before hiring.
- 2026-10-20 — Renamed the 25 pro-inspired stars to tags that copy their real counterparts' naming style (thud ← donk, cl3an ← s1mple, VyxEe ← ZywOo…).
- 2026-10-20 — Combat rework: realistic CS2-style firearms in Aim Arena + Drop Zone (fictional names, CS2 counterparts vault-only), knives & gloves, ragdoll deaths, no blood. New hero shooter title Spectra with laser blasters + Hero Library (old Operatives). Operative Library → Agent Library (realistic agents).
- 2026-10-20 — Added Sticker System + Screen - Sticker Editor.
- 2026-10-20 — Added Operative Library, Champion Library, Gamertag Bank. Renamed clashing names (Bastion→Bulwark, Tusk→Hornback, Echo→Mirra, Rook→Parapet, Ironhide→Shellback, Wisp-Light→Flicker, Sera→Seren).
- 2026-10-20 — Added Game Titles folder (overview + 5 title notes), loadouts, nameplates and gear skins in clips.
- 2026-10-20 — Added Player Generator, Key Players (48 hand-made Common–Epic), Friend Signings.
- 2026-10-20 — Reworked clips into 3D cutscenes (Clip Cutscene System), added Maps & Map Pool + Map Library.
- 2026-10-20 — Added Skin Pattern System + Skin Library.
- 2026-10-20 — Added Trading System + Screen - Trade.
- 2026-10-20 — Added Trait Library and Case Library.
- 2026-10-20 — Added Microtransaction Ideas (passes, products, cosmetics, bundles, season, social, avoid list).
- 2026-10-20 — Added Pro Player References (26 stars with real-life inspirations) and Skill Levels & Ratings.

## Bugs / playtest notes
(make a note per playtest: date, tester, what confused them)
- 2026-10-23 — tester: Claude (Studio via MCP, M2/M3 build, mock store). Fixed: income ticks rebuilt the case shelf every second and ate clicks; tournament rounds after the first never resolved; "Even" scrim offers were 21% harder (now calibrated on Team Power); the final caster line covered Continue. Note: with Studio API access on, Play loads the live profile; force the mock before using dev hooks.
- 2026-10-23 — tester: Claude (scripted bot, M1 build). Full Stage 1 at 8:11 vs 14:00 on the sheet; purchases land 2–3 min early because ~$600 is in hand by 4:20. Bugs fixed during testing: mouse pad never appeared after the first win (pads didn't re-check unlocks); tutorial pointer broke when its button was destroyed; Dee popup sized itself huge; chevrons buried under the floor; Gotham glyph boxes; Dee texts showing during cinematics.
- 2026-10-23 — tester: project owner (Studio). Aim Trainer cabinet couldn't be interacted with: the server set the cabinet's "On" flag on the screen's SurfaceGui, the client looked on the part, so no prompt appeared. Fixed; Arcade Corner cabinet prompt now also binds when the Hub streams in late.

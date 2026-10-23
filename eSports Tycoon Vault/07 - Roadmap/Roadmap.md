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
- [ ] Build Stage 1 plot in Studio
- [ ] Data layer + autosave: build to [[Data Persistence]] (DataService + ShutdownService + Migrations v1 + save guard)
- [ ] Review [[Balance Tables]] in a spreadsheet (`Attachments/Economy.xlsx`)
- [ ] Decide paid-crate policy (see [[Monetization]] open question)
- [ ] Write 5 caster lines per match event ([[Caster & Commentary]])

## Sprint log
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

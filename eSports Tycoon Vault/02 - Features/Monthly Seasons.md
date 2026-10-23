---
tags: [feature, live-ops, proposal]
status: proposal
priority: P1
stage: 2
updated: 2026-10-21
system_type: Infrastructure
engine_layer: ServerService
dependencies:
  - "[[Data Schema]]"
  - "[[Services & Remotes]]"
  - "[[Security & Anti-Exploit]]"
  - "[[Case Library]]"
  - "[[Skin Library]]"
  - "[[Map Library]]"
  - "[[Balance Tables]]"
  - "[[Economy Design]]"
  - "[[Analytics & Metrics]]"
affected_ui:
  - "[[Screen - Main HUD]]"
  - "[[Screen - Quests]]"
  - "[[Screen - Store]]"
  - "[[Screen - Case Opening]]"
roblox_execution_environment: ServerScriptService
---
# Monthly Seasons

## Summary
Each calendar month is a **Season**. Its theme follows the real-life time of year: December–February are winter seasons, March–May spring, June–August summer, September–November fall. Every season reskins the hub, HQ, HUD, music and one map. It runs its own Circuit Pass and quests, and releases **one exclusive Season Case** with **new named pro players**: 1 Mythic headliner and 2 Legendaries. When the month ends, the case is vaulted and its players can only be traded for.

This proposal replaces the "Seasonal major every 4–6 weeks" cadence in [[Live Ops & Events]] and folds the existing event cases in [[Case Library]] (Summer Cup, Spooky Showdown, Winter Major, Cyber Spring) into the matching months.

**Why monthly and tied to the real calendar**
- Players can predict it ("it's October, so Spooky season"), which builds anticipation and gives a return reason on the 1st of every month.
- One clock for everyone, so trading values and leaderboards line up.
- Content is easy to schedule: 12 theme slots that repeat each year, with new players each year.
- It matches the existing ~4-week Circuit Pass length, so the pass becomes the season pass.

---

## Player-facing behavior

### The season cycle
| When (UTC) | What happens |
|---|---|
| **Day 1, 00:00** | **Season Premiere.** The hub and HQ switch to the new theme on the spot (no rejoin). The headliner gets a walk-on reveal on the plaza jumbotron (same format as a key player's intro). New Circuit Pass and season quests. Login gift: 1 free Season Case. |
| **Days 1–7** | **Opening week.** 1.5× Season Tokens. Season map enters the map pool. |
| **Mid-month weekend** | **Mid-Season Cup.** A weekend boost (2× clip views) plus a themed tournament with the Season Case as a prize. |
| **Last 3 days** | **Season Finale.** Season Major tournament, a themed Worlds Live bracket, 2× Season Tokens. A countdown banner says "Season Case leaves in 2d 4h". |
| **Last day, 23:59:59** | Season ends. The Season Case is vaulted. Leftover tokens convert to Cash. Leftover Sparks convert to Shards. Season standings are frozen and season rewards are mailed. The season's top teams stay on the game-wide **Hall of Champions** ([[Social & Multiplayer]] → Global Top Teams showcase). |

### What changes each season
| Layer | Changes | Notes |
|---|---|---|
| Hub / plaza | Decor set, lighting preset, skybox, ambient VFX (snow, leaves, petals, fireflies) | Built as a swap-in decor folder for each season |
| Your HQ | Free seasonal overlay (wreath on the garage door, pumpkins on desks, string lights) | Setting: **Seasonal decor on/off** |
| HUD | Banner color, season icon, token icon, case-shelf glow | Uses the season palette tokens in the [[UI Style Guide]] |
| Audio | Lobby music remix + case-open stinger | [[Art & Audio Direction]] |
| Map | 1 themed map variant in rotation for the month | [[Map Library]] → Limited / event maps |
| Caster | 10–15 themed lines ("Spooky clutch from Phantom!") | [[Caster & Commentary]] |
| Furries | 2 boosted species + a limited season fur palette | [[Furry Variants]] → Seasonal species & fur palettes |
| Store | Season Case, season skin collection, season sticker capsule, season jersey | [[Case Library]], [[Skin Library]], [[Sticker System]] |
| Circuit Pass | 30 tiers, themed rewards; tier 30 free track = **Season Signing** | [[Daily Loops & Quests]] |
| Quests | 3 season quests per day + 1 season storyline (4 chapters, one per week) | Pays Season Tokens + Season XP |

### Season players
- Each season adds **3 named pros**: 1 Mythic headliner and 2 Legendaries. They are spread across the 6 game titles, so every title gets 2 Mythics a year.
- Each season also adds **3 seasonal key players** (Rare/Epic, themed looks) made with the [[Key Players]] rules. They drop from the Season Case and also show up as rival-team players during that month.
- Every season player card carries a **season stamp** (e.g. `S1 · OCT 2026`). Cards pulled during the original month also get an **Original** foil. That foil is the collector status symbol.
- **In Season bonus:** during their home month each year, season players get +3 Form. This is a small, flavorful reason to field them, not a power spike.
- Season players are tradable at any time ([[Trading System]]). Leaving the case makes them scarce, which gives them trading value.

### Getting the headliner without luck: Sparks
Every Season Case open gives **1 Spark**. At **120 Sparks** you can claim the season's Mythic headliner directly (once per season). Sparks don't carry over. Leftovers convert to Shards at season end (1 Spark = 2 Shards).

### Getting a Legendary for free: Season Signing
Circuit Pass tier 30 on the **free track** lets you pick 1 of the 2 season Legendaries. A free player who finishes the pass always leaves the season with a named season pro.

---

## Year 1 season calendar
Meteorological seasons, so each 3-month block shares a look and each month adds its own twist. Lunar New Year (late Jan–Feb) and the game's Anniversary are short **overlay events** on top of whatever month they fall in, not seasons of their own.

| Month | Real season | Season name | Theme & palette | Token | Season map |
|---|---|---|---|---|---|
| **Dec** | Winter | **Winter Major** | Snow, ice arenas, warm string lights. Ice blue + warm gold | Snowflakes ❄️ | Snow Globe (Aim Arena), existing |
| **Jan** | Winter | **Polar Circuit** | Northern lights, frozen lakes, new-year fresh start. Teal + violet aurora | Auroras 🌌 | Frozen Lake (Kart Rift ice track, low grip) |
| **Feb** | Winter | **Crush Cup** | Rivals and duos, pink/red neon over snow, heart "crushed screen" VFX | Hearts 💘 | Duo Deck (Tower Clash, 2v2 bot-lane arena) |
| **Mar** | Spring | **Spring Split** | Thaw, first sprouts, fresh rosters (nod to the esports "spring split"). Mint + soft yellow | Sprouts 🌱 | Thawing Fields (Drop Zone, flood zones recede over the match) |
| **Apr** | Spring | **Cyber Spring** | Chrome and holo, neon rain showers. April 1 = silly-modifier day. Chrome + cyan | Raindrops 💧 | Rainline (Spectra, wet-neon city) |
| **May** | Spring | **Bloom Bash** | Flower gardens, pastels, school finals season. Pastel pink + lilac + green | Petals 🌸 | Greenhouse (Brawl Legends stage) |
| **Jun** | Summer | **Summer Cup** | Beach, surf, sunny skies. Sky blue + sand + coral | Shells 🐚 | Beach Bash (Drop Zone), existing |
| **Jul** | Summer | **Heatwave Open** | Heat haze, pool parties, fireworks nights. Hot orange + pool blue | Sparks ✨ *(name TBD, clashes with Spark meter)* | Sunscorch (Aim Arena, desert resort) |
| **Aug** | Summer | **Midnight Carnival** | Summer-night fair, Ferris wheel, glowsticks. Deep navy + neon | Tickets 🎟️ | Fairground (Drop Zone, rides as cover) |
| **Sep** | Fall | **Varsity Fall** | Back to school, campus, first falling leaves. School colors (maroon + gold) | Pencils ✏️ | Campus Quad (Tower Clash) |
| **Oct** | Fall | **Spooky Showdown** | Haunted, pumpkins, fog, playful ghosts (no gore). Orange + purple + black | Candy 🍬 | Pumpkin Patch (Aim Arena), existing |
| **Nov** | Fall | **Harvest Clash** | Autumn harvest, lanterns, cozy cabins, red/orange leaves. Rust + amber | Acorns 🌰 | Maple Run (Kart Rift, leaf piles = slow zones) |

> July's token needs a different name. "Sparks" is already the pity meter. Options: **Embers**, **Fireworks**, **Popsicles**.

---

## Year 1 season players
Stat order: **Aim / Reflexes / Game Sense / Teamwork / Clutch / Consistency**. Mythic OVR 85–95, Legendary 72–86 ([[Balance Tables]]). Tags follow the [[Gamertag Bank]] styles with a small seasonal nod, and all are original (no real-life inspiration). Before shipping, run every tag through the real-pro block list. If a team wants a real-pro archetype for a headliner, record it in [[Pro Player References]] first, as that note requires.

### Mythic headliners (one per season, 2 per title per year)
| Season | Tag | Title | Role | Stats | Mythic unique 🔴 | Look / hook |
|---|---|---|---|---|---|---|
| Winter Major (Dec) | **kelvin** | Aim Arena | Sniper | 96 / 92 / 90 / 78 / 94 / 97 | **Absolute Zero**: in clutch rounds, the opponents' Consistency −10 | White parka over jersey, frost on the scope. Never speaks above a whisper |
| Polar Circuit (Jan) | **bOREAL** | Spectra | Entry (duelist) | 97 / 98 / 82 / 76 / 88 / 84 | **Northern Lights**: first kill each round adds +2% team Aim for the round (stacks 3×) | Aurora-gradient visor; HQ desk glows green at night |
| Crush Cup (Feb) | **sw00n** | Tower Clash | Entry (bot carry) | 94 / 93 / 86 / 90 / 90 / 85 | **Duo Queue**: with a Support on the roster, both get +6 Teamwork, and "Dynamic Duo" triggers without matched Duo Partners | Heart-shaped sunglasses, pink jacket. Comes with a voice line for every support they've played with |
| Spring Split (Mar) | **sprig** | Drop Zone | Flex | 88 / 90 / 92 / 84 / 93 / 86 | **Fresh Roster**: +30% training XP for every player who joined your roster this month | Teen rookie with a sprout hair-clip. Starts at Potential 99 |
| Cyber Spring (Apr) | **dr1zzle** | Spectra | Sniper | 96 / 94 / 88 / 80 / 90 / 92 | **Static Charge**: each won round stores 1 charge; at 5 the next duel is auto-won | Chrome rain jacket, holo umbrella emote |
| Bloom Bash (May) | **bl00m** | Brawl Legends | Flex | 90 / 94 / 93 / 70 / 92 / 90 | **Late Bloomer+**: +1 to all stats each round they're behind (resets per match, max +5) | Flower crown over a headband, petal VFX on parries |
| Summer Cup (Jun) | **Marisol Vega** | Kart Rift | Entry | 82 / 98 / 90 / 72 / 91 / 94 | **Slipstream Queen**: overtake chance +20% in the final lap | Surfboard-pattern helmet; real-name style like Sem Kortland |
| Heatwave Open (Jul) | **Swelter** | Aim Arena | Entry | 97 / 95 / 84 / 76 / 86 / 88 | **Heat Check**: each kill in a round adds +3 Aim for the rest of that round (cooldown next round) | Bucket hat, sweatband, fireworks taunt |
| Midnight Carnival (Aug) | **FerrisKid** | Drop Zone | Strategist (IGL) | 84 / 86 / 96 / 94 / 90 / 88 | **Ringleader**: +1 placement point per surviving teammate in final circle | Glowstick bracelets, ringmaster coat over hoodie |
| Varsity Fall (Sep) | **h0nors** | Tower Clash | Strategist (mid) | 88 / 86 / 98 / 92 / 90 / 95 | **Valedictorian**: +15% XP for every player on the roster under age 20 | Letterman jacket, glasses, carries a trophy-shaped pencil case |
| Spooky Showdown (Oct) | **Phantom** | Brawl Legends | Entry | 94 / 97 / 88 / 62 / 97 / 86 | **Vanish**: once per match, a lost round is replayed (10%); sits alongside Hideki's The Parry | Translucent ghost hoodie, eyes glow through the hood. Already named in [[Case Library]] |
| Harvest Clash (Nov) | **Rowan Hale** | Kart Rift | Flex | 80 / 96 / 92 / 78 / 90 / 98 | **Steady Harvest**: Consistency can't drop below 92; +5% prize money from races they finish top 3 | Plaid racing suit, maple-leaf helmet decal |

### Legendaries (two per season)
| Season | Tag | Title | Role | Stats | Trait | Look |
|---|---|---|---|---|---|---|
| Dec | **Frostbite** | Brawl Legends | Entry | 88 / 90 / 82 / 60 / 88 / 82 | Ice Cold | Ice-blue gauntlets *(already named in [[Case Library]])* |
| Dec | **sleet** | Drop Zone | Support | 78 / 80 / 86 / 92 / 84 / 88 | Utility God | Grey rain poncho, goggles |
| Jan | **tundra** | Tower Clash | Support | 74 / 78 / 90 / 94 / 82 / 88 | Team Leader | Fur-hood parka, compass |
| Jan | **Resolute** | Kart Rift | Flex | 76 / 92 / 86 / 70 / 84 / 92 | Early Bird | New-year party hat on helmet |
| Feb | **bestie** | Tower Clash | Support | 76 / 80 / 88 / 95 / 84 / 86 | Duo Partner (pairs with sw00n) | Friendship-bracelet stack |
| Feb | **Rosewood** | Aim Arena | Strategist (IGL) | 70 / 72 / 92 / 92 / 76 / 84 | Calm Voice | Rose pin, vintage headset |
| Mar | **breezy** | Spectra | Flex | 86 / 88 / 82 / 80 / 84 / 86 | Bridge | Windbreaker, kite emote |
| Mar | **pollen** | Kart Rift | Entry | 78 / 92 / 80 / 68 / 86 / 80 | Hot Hand | Bee-stripe suit |
| Apr | **Prankster** | Brawl Legends | Entry | 88 / 90 / 80 / 60 / 84 / 74 | Showboat | Joke-glasses, whoopee-cushion taunt (April 1 star) |
| Apr | **ch1me** | Aim Arena | Support | 80 / 82 / 86 / 90 / 88 / 86 | Utility God | Wind-chime earrings, rain hood |
| May | **lilac** | Aim Arena | Sniper | 90 / 88 / 82 / 76 / 86 / 88 | Ice Cold | Pastel purple hair, flower on the scope |
| May | **Clover** | Drop Zone | Strategist (IGL) | 76 / 78 / 92 / 90 / 82 / 86 | Lucky Socks | Four-leaf clover badge |
| Jun | **Sunny** | Spectra | Entry (duelist) | 90 / 92 / 78 / 74 / 82 / 78 | Hype Machine | Sunglasses, surf shorts *(already named in [[Case Library]])* |
| Jun | **Cabana** | Tower Clash | Flex | 82 / 84 / 88 / 84 / 82 / 86 | Bridge | Hawaiian-print jersey |
| Jul | **Sparkler** | Brawl Legends | Flex | 86 / 90 / 84 / 66 / 88 / 82 | Hot Hand | Firework-burst jacket |
| Jul | **Lido** | Kart Rift | Entry | 78 / 94 / 82 / 70 / 86 / 84 | Front-Runner | Pool-float helmet |
| Aug | **Funhouse** | Spectra | Strategist (IGL) | 72 / 76 / 92 / 92 / 80 / 84 | Shot Caller | Mirror-maze visor |
| Aug | **c0tton** | Aim Arena | Support | 78 / 80 / 86 / 92 / 86 / 88 | Loyal | Cotton-candy pink hair |
| Sep | **quizz** | Spectra | Strategist (IGL) | 72 / 74 / 94 / 90 / 80 / 86 | Studious | Backpack with pins, flash cards |
| Sep | **Recess** | Brawl Legends | Entry | 88 / 90 / 80 / 64 / 86 / 78 | Rising Star | Playground-ball emote, untied laces |
| Oct | **grimsby** | Aim Arena | Sniper | 90 / 88 / 84 / 74 / 90 / 86 | Clutch God | Lantern charm, long black coat |
| Oct | **Banshee** | Drop Zone | Entry | 88 / 90 / 78 / 70 / 86 / 78 | Glass Cannon | Shriek emote, white-streaked hair |
| Nov | **acorn** | Tower Clash | Flex | 80 / 82 / 90 / 86 / 84 / 90 | Late Bloomer | Acorn-cap beanie |
| Nov | **Bonfire** | Spectra | Entry (duelist) | 90 / 88 / 80 / 74 / 86 / 80 | Hype Machine | Flannel over jersey, marshmallow emote |

Traits used for Legendaries must exist in [[Trait Library]] or be added there first. The 12 new Mythic uniques go in [[Trait Library]] → Mythic uniques.

### Year 2 and later
Themes repeat every year, but **players never do**. Year 2's October has a new headliner and Legendaries with the same Spooky theme and a new twist (e.g. "Spooky Showdown II: Haunted Arcade"). Last year's case returns only on a **Throwback shelf** in the same month:
- Lower player odds than the original run.
- Cards drop **without** the Original foil, so original-run cards stay the collector version.
- Sparks don't count toward Throwback headliners. Those come only from luck or trading.

---

## Rules & numbers

### Season Case
| Field | Value |
|---|---|
| Price | 100 Season Tokens **or** 60 Gems (Robux version only if policy allows, same odds) |
| Unlock | Stage 2 (same as the Rookie Crate) |
| Odds (C/U/R/E/L/M) | 0 / 35 / 35 / 21 / 8 / 1 |
| Legendary slot | 50% one of the 2 season Legendaries, 50% normal Legendary pool |
| Mythic slot | 100% the season headliner (its own case = the only Mythic in the pool) |
| Other drops | Season skin collection, season jersey, season stickers, the 3 seasonal key players, boosters |
| ★ slot | 0.26% season knife/glove finish (Aim Arena items), like event weapon cases |
| Pity | Own pity family "Season": guaranteed Epic+ every 10 opens, Legendary+ every 50 |
| Dupes | Named season pros can't drop twice until you own every named pro in that case. Later dupes → Shards |
| Sparks | +1 per open, claim the headliner at 120 |

### Season Tokens (rough faucet, tune in [[Economy Design]])
| Source | Tokens |
|---|---|
| Daily season quests (3) | 15 / 20 / 30 |
| Storyline chapter (weekly) | 80 |
| Mid-Season Cup / Season Major placements | 20–150 |
| Match wins during the season | 2 each (cap 40/day) |
| Circuit Pass free track | ~400 across the pass |

An active free player earns about **1,800–2,200 tokens a month**, which is about 18–22 Season Cases. That puts the Spark claim (120 opens) out of reach on tokens alone, on purpose: Sparks are the reward for heavy play or Gem spending. The Season Signing gives every pass finisher a guaranteed Legendary.

### Token shop (spend instead of opening cases)
| Item | Price |
|---|---|
| Season jersey | 250 |
| Season emote | 300 |
| Seasonal key player (choose 1 of 3) | 600 |
| Season sticker capsule | 60 |
| Throwback Case (Year 2+) | 120 |

### Circuit Pass alignment
- The pass now runs for the **calendar month** (28–31 days) instead of "~4 weeks".
- Tune tier XP so all 30 tiers are reachable in **24 active days**, which leaves slack for February and for players who miss days.
- **Catch-up:** in the last 7 days, Season XP is ×1.5 for anyone under tier 20.
- Pass rewards stay cosmetic or boosters plus the Season Signing. No exclusive stat power ([[Monetization]]).

### Power-creep guardrails
- Season player stats stay inside the existing rarity bands. Headliners average about 90 OVR, same as current Mythics.
- Mythic uniques are reviewed side by side with the existing uniques in [[Trait Library]]. None should beat One-Tap Legend or Big Brain in sim win rate (check with a [[Match Simulation]] batch run).
- "In Season" +3 Form is the only time-gated stat bonus.

---

## Server / data requirements
```lua
-- Shared/Config/Seasons.lua
SeasonDef = {
  Id = "2026-10",                 -- year-month, also the stamp on cards
  Number = 1,                     -- "S1", counted from launch month
  Theme = "SpookyShowdown",       -- key into ThemeSets (decor, lighting, palette, music)
  StartsAt = 1790812800,          -- 1st 00:00 UTC
  EndsAt   = 1793491199,          -- last day 23:59:59 UTC
  Token = { Id = "Candy", Icon = "rbxassetid://…" },
  Case = "SeasonCase_2026_10",    -- CaseDef in Cases.lua, PityFamily = "Season"
  Headliner = "Phantom",
  Legendaries = { "grimsby", "Banshee" },
  KeyPlayers = { … },
  PassId = "Circuit_2026_10",
  MapVariant = "PumpkinPatch",
  Overlays = { "Anniversary" },   -- optional overlay events inside the month
}
```
- **SeasonService** (server) reads `os.time()` (UTC) every 60 s and picks the active `SeasonDef`. It fires `SeasonChanged` on rollover and sets a `CurrentSeason` attribute on `ReplicatedStorage`, which clients use to switch themes. No restart needed, per the existing acceptance criterion in [[Live Ops & Events]].
- **Rollover job:** convert tokens → Cash and Sparks → Shards **lazily on next join** (store `LastSeasonId` in the profile), not in a server-wide sweep.
- Player card data gets `SeasonId` and `Original = true/false`. These are set once at mint, server-side, and never editable.
- Case purchase checks `StartsAt <= now <= EndsAt` on the server at purchase time. The client timer is cosmetic only.
- Ship the next 2 seasons in config ahead of time so a missed deploy never leaves a month without content. If no `SeasonDef` matches, fall back to an "Off-Season" neutral theme.
- Add to [[Data Schema]]: `Profile.Season = { Id, Tokens, Sparks, SparkClaimed, PassXP, PassTier, StorylineChapter }`.
- Add to [[Services & Remotes]]: `SeasonService`, `GetSeasonState` (RemoteFunction), `ClaimHeadliner` (RemoteEvent, validated).

## UI screens
- [[Screen - Main HUD]]: season banner + token counter + days-left chip.
- [[Screen - Case Opening]]: Season Case shelf slot, Spark meter (x/120), "Leaves in…" timer.
- [[Screen - Quests]]: Season tab (dailies, storyline, pass).
- [[Screen - Store]]: Season token shop tab.
- New: **Screen - Season Hub** (season art, headliner showcase, roadmap of the month's events, last season's results).

## Dependencies
[[Live Ops & Events]] · [[Case Library]] · [[Case Unboxing]] · [[Daily Loops & Quests]] · [[Pro Player References]] · [[Key Players]] · [[Trait Library]] · [[Map Library]] · [[Trading System]] · [[Economy Design]] · [[Monetization]]

## Edge cases / exploit risks
- **Clock tricks:** only server time counts. A client changing its device clock does nothing.
- **Open case UI at rollover:** the purchase is re-checked against `EndsAt` on the server. If it's too late, the purchase is rejected and the player is refunded with a toast.
- **Mid-month joiners:** front-loaded storyline chapter 1, pass catch-up XP, and a "New this season" free case for first-time players.
- **Trading spike at season end:** expected and fine. Watch for duping attempts on season cards ([[Security & Anti-Exploit]] trade logs).
- **Southern hemisphere players:** June is winter for them. See open questions.
- **Sensitive dates:** themes stay seasonal and secular (no religious holiday names). Lunar New Year and similar run as optional overlays with their own art pass.
- **Roblox policy:** paid random items need odds disclosure and have age/region rules. Verify current policy before selling Season Cases for Robux ([[Case Unboxing]] → Policy note).

## Acceptance criteria
- [ ] Theme, case shelf and pass switch at 00:00 UTC on the 1st with no server restart
- [ ] Season Case can't be bought outside its month (server-checked)
- [ ] Season cards show the season stamp and Original foil, and keep them through trades
- [ ] Spark meter claims the headliner exactly once per season
- [ ] Token → Cash and Spark → Shard conversion happens once per player per season
- [ ] Free-track tier 30 always grants a choice of season Legendary
- [ ] Off-Season fallback loads if no SeasonDef matches the current date
- [ ] Season standings and champions are the same on every server (global showcase); dev accounts are excluded once that filter ships
- [ ] Seasonal decor toggle hides HQ overlays without affecting the hub

## Analytics to track
Return rate on day 1 of each month · % of DAU opening ≥1 Season Case · Spark claim rate (payers vs non-payers) · pass completion rate by month length · season-card trade volume in the final 3 days vs after vaulting · headliner usage in rosters 1 month later (checks for power creep). See [[Analytics & Metrics]].

## Open questions
- **Hemispheres:** use one global northern-hemisphere calendar (simpler, keeps trading in sync) or flip themes by region? Recommendation: **one global calendar**. Lean on cultural and event themes (Varsity, Carnival, Crush Cup) more than weather where they work for both hemispheres.
- **Launch month:** Season 1 = launch month. If launch is mid-month, run a short "Preseason" until the 1st, or give Season 1 extra days?
- **July token name** (clashes with Sparks).
- Should Mythic headliners appear as stage bosses on AI rival teams during their month, like named Legendaries do ([[Rivalries & Storylines]])? It's good marketing for the case, so probably yes.
- Spark threshold: 120 is a starting point. Simulate against real open rates after the first 2 seasons.
- Robux-priced Season Case: yes, no, or Gems only at launch?

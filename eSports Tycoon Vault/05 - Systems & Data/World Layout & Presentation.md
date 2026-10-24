---
tags: [system, world, map, design]
status: building
priority: P0
stage: 1
updated: 2026-10-21
system_type: World
engine_layer: Workspace
dependencies:
  - "[[Plot & HQ]]"
  - "[[Map Library]]"
  - "[[Art & Audio Direction]]"
  - "[[Social & Multiplayer]]"
affected_ui:
  - "[[Screen - Main HUD]]"
roblox_execution_environment: Workspace + StarterPlayerScripts
---
# World Layout & Presentation

> How the game looks and feels from the player's seat: where you spawn, what you walk through, where each activity happens, and what other players can see. Match maps (Neon Docks, etc.) are a different thing: they live in [[Map Library]] and only appear inside match broadcasts and clips.

## The three kinds of space
| Space | What it is | Who sees it | Examples |
|---|---|---|---|
| **The Hub** | One shared world per server that you walk around in | Everyone in the server | Spawn Plaza, Ring Road, districts |
| **Your Plot** | Your HQ: a tycoon plot that grows from a garage into an arena | Everyone (outside); you + visitors (inside) | Practice Floor, Case Vault, Trophy Hall |
| **Stages** | Spaces built only on your screen, reached by the camera, not by walking | Only you | Match broadcasts, clip cutscenes, case reveal close-ups, the intro cutscene |

**The rule:** the Hub and your Plot are the places you *walk* to and show off in. Stages are where the *spectacle* happens. Walking teaches you where things are. Once you've found something, a HUD button takes you straight there.

---

## Server size
- **6 plots per server, max 6 players.** One plot each, assigned on join, freed on leave ([[Plot & HQ]] → *Edge cases*).
- One extra reserved slot so friends can always follow each other in (Roblox "Follow" / join). If all 6 plots are taken, the 7th player is a visitor with no plot and gets moved to a fresh server after 60 s with a message.

## Top-down map
The plots sit around a **ring road**. Between each pair of plots is a district. All of it surrounds the Spawn Plaza in the middle. Every plot touches two districts, and every district is ~12 s on foot from the plaza.

```
                            [ PLOT 1 ]
              Season Gate ·             · Streamr Tower
        [ PLOT 6 ]      ╭───── Ring Road ─────╮      [ PLOT 2 ]
                        │                     │
       Sponsor Street · │    SPAWN  PLAZA     │ · Tournament Hall
                        │  (jumbotron, boards,│
        [ PLOT 5 ]      │   statue, fountain) │      [ PLOT 3 ]
                        ╰─────────────────────╯
              Arcade Corner ·           · Trading Post
                            [ PLOT 4 ]
```
- **Ring Road** (garage-row street, the one Aunt Dee's van drives in the [[Intro Cutscene]]): 40 studs wide, sidewalks, streetlights, parked props. Each plot's front faces the road.
- **Spokes**: a straight walkway from each district to the plaza, so the plaza is visible from every plot's driveway.
- Rough size: plaza radius 120 studs, plot front at ~320 studs from center, whole map ~1,400 studs across.
- Walk speed is the default 16 studs/s. Plot → own district: ~5 s. Plot → plaza: ~12 s. Across the map: ~45 s (that's why fast travel exists).

## Districts
| Area | Position | Unlocks | What you do there | Detail note |
|---|---|---|---|---|
| **Spawn Plaza** | Center | Always | Jumbotron (Clip of the Hour, Worlds Live, Top Team spotlight), physical leaderboard wall (top 10, global), Worlds champion statue, code board, daily-reward fountain | [[Social & Multiplayer]], [[Live Ops & Events]] |
| **Streamr Tower** | Between Plot 1–2 | Stage 4 | Tall building with trending clips playing on its side. Go inside to browse the feed. | [[Clips & Traction]], [[Screen - Clip Feed]] |
| **Tournament Hall** | Between Plot 2–3 | Stage 3 | Bracket boards, Worlds Live sign-up, Pick'em kiosk | [[Matches & Tournaments]], [[Prediction Pick'em]] |
| **Trading Post** | Between Plot 3–4 | Stage 4 (trading) | Trade booths (stand in one, the other player joins), AI Transfer List kiosk, skin market terminals | [[Trading System]], [[Transfer Market]], [[Skin Marketplace]] |
| **Arcade Corner** | Between Plot 4–5 | Always | Minigame cabinets open to everyone: Aim Trainer, Reaction Test, Rhythm Warm-up. Server high-score board on each cabinet. | [[Playable Games]] |
| **Sponsor Street** | Between Plot 5–6 | Stage 3 | Shopfronts with fictional sponsor brands, sponsor offer board | [[Sponsors]], [[Screen - Sponsors]] |
| **Season Gate** | Between Plot 6–1 | Always | This month's themed pavilion: Season Case display, headliner statue, Season Hub | [[Monthly Seasons]] |

Locked districts are **still visible** with a barrier and a sign ("Opens at Stage 3: Local Cup"). Seeing what's coming is part of the pull ([[Progression Guide]]).

---

## Plot anatomy
Each plot is a **256 × 256 stud** square. Everything you build stays inside it, from the Garage to the Arena.

```
                 ┌──────────────────────── 256 ────────────────────────┐
  back (away     │  ZONE C · Backyard → Courtyard → Arena bowl (w/ B)  │
  from road)     │  bleachers, Main Stage, jumbotron                   │
                 ├─────────────────────────────────────────────────────┤
                 │  ZONE B · Training wing → Gaming House → Campus     │
                 │  Training Center · Gaming House 2nd floor ·         │
                 │  Clip Studio · Streaming Booth · Merch · Academy    │
                 ├─────────────────────────────────────────────────────┤
                 │  ZONE A · Core (eras 1–2)                           │
                 │  Garage → Practice Floor · Café annex: Tech Shop,   │
                 │  Case Vault · Trophy shelf                          │
                 ├─────────────────────────────────────────────────────┤
  front (road)   │  FRONTAGE: driveway · Cash Collector · team banner  │
                 │  · mailbox (admin grants, fan mail) · Like sign     │
                 └─────────────── Ring Road ───────────────────────────┘
```
- **Frontage** is always built and always public. It's what passers-by see: your team banner (team colors, [[Team Identity]]), fan crowd ([[Fan Base & Arena]]), the Like sign (HQ visits), and the Cash Collector.
- **Ghost outlines**: unbuilt rooms show as faint wireframe outlines on the plot, so you can see where the next thing goes. This is the "empty plot with outlines" shot at the end of the [[Intro Cutscene]].
- **Buy pads** sit at the edge of the room they build, max 3 visible ([[Plot & HQ]] → *Buy pad rules*). The [[Screen - Main HUD]] objective arrow points to the next one.
- **Era swap**: the camera pulls up and back over the plot, the old shell dissolves and the new one builds in ([[Art & Audio Direction]] → *VFX*). Ghost outlines for the next zone appear after.
- **Rebirth** ([[Franchise Rebirth]]) resets the plot to the Garage. The cinematic plays in reverse, and Legacy decor stays.

### Era → zone
| Era | Stage | Uses | From the road it looks like |
|---|---|---|---|
| Garage | 1 | Small corner of Zone A | One shabby garage, bedsheet banner, flickering bulb |
| Café Corner | 2 | All of Zone A | Garage + rented café shopfront, neon OPEN sign |
| Training Center | 3–5 | Zone A + first wing of B | Glass practice wing behind the café |
| Gaming House | 5 | Zone A–B, 2 floors | A proper team house, LED strips in team colors |
| Studio Campus | 6–7 | All of Zone A–B | Several connected buildings, streaming booth on the roof |
| Arena | 8–10 | Whole plot: stadium on B + C, Players' Building on A | A stadium bowl rising behind the campus, visible from the plaza |

Full look per era: [[HQ Era Visual Guide]]. Zone depths from the road: Frontage 32 · A 72 · B 80 · C 72 studs.

The Arena is **stylized and compact** (about 1,500 seats as models, the rest as crowd cards), so it fits Zones B + C. It's meant to tower over the neighbours. That's the show-off payoff.

---

## Where each activity happens
| Activity | Where you go | How it's presented |
|---|---|---|
| First join | [[Intro Cutscene]] (Stage) → you land in your garage | Cutscene is local. Van stops at your real plot. |
| Earn passive income | Practice Floor on your plot | Roster NPCs typing at stations, coins flow into the Cash Collector at the front |
| Play as the Founder | Sit at your own PC on the Practice Floor | Camera moves to your monitor, minigame UI fills the screen ([[Founder (You)]], [[Playable Games]]) |
| Hire players | Free-agent board on your Practice Floor wall | Proximity prompt → [[Screen - Roster]]. Hired player walks in through the garage door and sits down. |
| Upgrade PCs | Tech Shop counter (café annex) | Prompt → [[Screen - Tech Shop]]. Parts visibly change on the station. |
| Open cases | Case Vault room on your plot | Case drops onto a lit pedestal, then the reveal close-up is a Stage ([[Screen - Case Opening]]). A **rarity beam shoots up from your plot roof** that the whole server sees. Mythic triggers the server "Mythic Hype" boost. |
| Play a match | Start from the Practice Floor (scrims) or Arena (home matches) | Pre-match screen → **broadcast Stage**: client builds the match map far away and the camera goes there ([[Clip Cutscene System]] → *Stage Builder*). [[Screen - Match HUD]] overlays it. Back on your plot after. |
| Tournaments | Tournament Hall, or from any plot via HUD | Bracket on the hall's big board + [[Screen - Bracket]] |
| Edit and watch clips | Clip Studio (your plot) or Streamr Tower | Replay Theater screen in your HQ that visitors can watch too |
| Trade | Trading Post booth | Both players stand at the booth → [[Screen - Trade]] |
| Train players | Training Center wing | Players run drills on the glass practice floor ([[Screen - Staff & Training]]) |
| Visit a friend | Walk up their driveway, or HUD → Map → Visit tab (also Phone → Social) | You can walk through their HQ, see trophies, Like it, challenge them |
| Worlds Live | Plaza jumbotron + Tournament Hall | Server-wide broadcast everyone can watch together |

## Fast travel
- HUD **Map** button (after the tutorial). Destinations: My HQ, Plaza, and any district you've **already walked to once**. Teleport is instant with a short fade.
- A **"Back to HQ"** button appears whenever you're more than 100 studs from your plot.
- Visits: HUD → Map → Visit tab → pick a player → you appear at the foot of their driveway.

## What other players see
| Seen by everyone | Only you |
|---|---|
| Your plot exterior, era, banner, team colors | Intro cutscene |
| Your fan crowd outside | Match broadcasts and clip cutscenes (each player builds their own Stage) |
| Your roster NPCs at their stations (through windows / inside when visiting) | Case reveal close-up |
| Rarity beam above your plot when you open a case; Mythic Hype banner | Menus and screens |
| Your Replay Theater clip (when visiting) | Tutorial arrows and Aunt Dee prompts |

## Look by area
Lighting presets from [[Art & Audio Direction]]. Roblox lighting is per client, so the client switches presets when you cross into a zone.
| Zone | Lighting / mood | Music |
|---|---|---|
| Hub (plaza, road, districts) | Permanent dusk: warm streetlights, neon signage, cyan/magenta accents | Hub synthwave loop |
| Inside your plot | Your current era's preset (Garage tungsten → Café neon → Gaming House LEDs → Arena spotlights) | Era track |
| Inside someone else's plot | Their era's preset | Their era track |
| Arcade Corner | Darker, arcade neon | Chiptune-flavored loop |
| Season Gate | Season palette ([[Monthly Seasons]]) | Season track |

Seasonal dressing: on the 1st of each month the Season Gate, plaza banners and jumbotron frame swap to the new theme. Nothing else in the Hub changes, so it stays familiar.

## Performance budgets (mobile-first)
- `Workspace.StreamingEnabled = true`. Each plot is its own streaming model so it loads as a whole. Distant plots show a **low-detail shell** (era exterior only, no interiors).
- Part budgets: plaza ≤ 3,000 · each district ≤ 1,500 · each plot ≤ 6,000 at Arena era · interiors only stream in when you're within ~150 studs.
- NPC caps: ≤ 40 animated NPCs on mobile (roster + fans combined). Beyond that, fans become billboard crowd cards ([[Fan Base & Arena]]).
- Stages (matches, clips) are built far from the Hub (`y = 10000`) and destroyed when done, so they never compete with the Hub for memory at the same time as plot interiors. Hub interiors pause animations while a Stage is open.

## Build order
| Milestone | Build |
|---|---|
| M0 | Ring road, 6 empty plots with frontage + Cash Collector, plain plaza with spawn, plot assignment |
| M1 | Garage + Café eras, ghost outlines, Arcade Corner (Aim Trainer), intro cutscene path, fast-travel button |
| M2 | Case Vault room + rarity beam |
| M3 | Tournament Hall, leaderboard wall, Training Center wing |
| M4 | Streamr Tower, Sponsor Street, Clip Studio, jumbotron |
| M5–M7 | Gaming House, Studio Campus, Arena era, Trading Post, Season Gate dressing |

Until a district is built, its slot on the ring holds a construction-site placeholder with "Coming soon".

## Acceptance criteria
- [ ] A new player spawns at their own plot after the intro, never at a random spot.
- [ ] From any plot driveway, the plaza jumbotron is visible.
- [ ] Every district is reachable on foot from the plaza in ≤ 15 s.
- [ ] A Legendary case open on Plot 3 shows a beam visible from Plot 6.
- [ ] Arena-era plot stays inside its 256 × 256 square.
- [ ] Mobile (low-end device): 6 Arena-era plots in one server stay ≥ 30 FPS in the plaza.
- [ ] Opening a match broadcast doesn't stream in any extra Hub parts.

## Open questions
- 6 plots per server, or 8 with a smaller plot? 6 keeps the ring readable on phones.
- Vehicles (scooter/hoverboard as a cosmetic for faster travel), or keep fast travel only?
- Should visitors be able to watch your match broadcast live from your Arena seats? Ties to the [[Fan Base & Arena]] open question.

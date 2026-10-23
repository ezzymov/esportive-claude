---
tags: [feature, art, world, hq]
status: designed
priority: P1
stage: 1
updated: 2026-10-21
system_type: World
engine_layer: Workspace
dependencies:
  - "[[Plot & HQ]]"
  - "[[World Layout & Presentation]]"
  - "[[Art & Audio Direction]]"
  - "[[Team Identity]]"
affected_ui: []
roblox_execution_environment: Workspace + StarterPlayerScripts
---
# HQ Era Visual Guide

> What your HQ looks like at every era, inside and out: layout, props, stations, materials, lighting, sound, and the life inside it. Rules and prices live in [[Plot & HQ]]. Where the plot sits in the world: [[World Layout & Presentation]].

**Story through the eras:** each HQ should look like the *same team* one step further along. Something from the last era always comes along, so the story "from a garage to a stadium" stays visible.

## Era overview
| # | Era | Stage | Plot zones used | One-line look | Signature build | Part budget |
|---|---|---|---|---|---|---|
| 1 | **Garage** | 1 | Corner of A | A borrowed, dusty garage with one old PC | Starter PC + taped chair | 600 |
| 2 | **Café Corner** | 2 | All of A | Garage knocked through into a rented LAN café | Tech Shop counter + Case Vault | 1,200 |
| 3 | **Training Center** | 3–4 | A + left half of B | A clean glass practice wing behind the café | Analyst wall | 2,000 |
| 4 | **Gaming House** | 5 | A + B, 2 floors | A proper team house in team colors | Bootcamp Dorms | 3,500 |
| 5 | **Studio Campus** | 6–7 | A + B + courtyard in C | Several modern buildings joined by a skybridge | Streaming Booth | 5,000 |
| 6 | **Arena** | 8–10 | Whole plot, stadium on B + C | A stadium bowl that towers over the street | Main Stage | 6,000 |

Plot zones (256 × 256 studs, from the road back): **Frontage** 32 studs deep → **Zone A** 72 → **Zone B** 80 → **Zone C** 72. See [[World Layout & Presentation]] → *Plot anatomy*.

### Things every era keeps
| Kept item | Where it ends up |
|---|---|
| **The taped chair** (your first chair) | Garage desk → café corner → Training Center doorway → Gaming House lounge → Trophy Hall display case → Arena entrance plinth with a plaque: "Where it started." |
| **The original garage door** | Gets painted in Café, framed in Gaming House as the side entrance to "The Garage" (Founder's corner), then becomes the Arena's players' tunnel door |
| **The bedsheet banner** | Hangs in every era. Framed under glass from Studio Campus on. |
| **Founder's PC** | Gets upgraded with parts like every station, but the beige case shell stays as a cosmetic ([[Founder (You)]]) |
| **Cash Collector** | Always at the front of the driveway. Its look changes per era (below). |

---

## 1. Garage (Stage 1)
**Feel:** humble, warm, a little funny. You really are starting with nothing.

### From the road
- One single-car garage in the **front-left corner of Zone A** (40 × 32 studs inside). The rest of the plot is a weedy dirt lot behind a chain-link fence, with **ghost outlines** of future rooms.
- Dented roll-up door, peeling paint. Your **bedsheet banner** with the team name in spray paint hangs over the door ([[Team Identity]]).
- Cracked driveway, an orange traffic cone, a "NO PARKING" sign someone crossed out.
- **Cash Collector:** an old coffee can on a milk crate by the curb. Coins clink in.
- **Mailbox:** dented, on a wonky post. Admin grants and fan mail pop out of it.

### Floor plan
```
 ┌──────────── back wall ───────────────┐
 │ pegboard + tools   │ boxes (Aunt Dee) │
 │  [old couch]       │ mini-fridge      │
 │                                      │
 │ [Desk 2 pad]   [Desk 3 pad]          │
 │                                      │
 │ [FOUNDER PC]  whiteboard  cork board │
 │  fold table    "GOAL"     (free      │
 │                            agents)   │
 └──────── roll-up door (road) ─────────┘
```

### Inside
- **Concrete floor** with an oil stain, a worn rug under the Founder desk.
- **Founder PC:** beige tower, a small 60 Hz monitor on a stack of books, a membrane keyboard, and **the taped chair**.
- **Desk 2 and 3 (pads):** mismatched, a card table and a door laid on two sawhorses. Each gets a cheap chair.
- **Whiteboard:** "GOAL: $250 → HIRE SOMEONE" in marker. It updates with your next objective ([[Stage 1 - Garage Squad]]).
- **Cork board:** the free-agent board. Paper flyers with player photos. Prompt → [[Screen - Roster]].
- **Tech Fix bench:** a pegboard workbench for the Stage 1 Tech Fix jobs.
- Boxes labeled "DEE: XMAS" and "DEE: DO NOT TOUCH", a dead plant, a mini-fridge with one soda.
- Posters of the fictional titles ([[Game Titles Overview]]), slightly crooked.

### Stations
Cheap: small monitors, wired mice, folding chairs. Upgrades show as the parts change ([[PC Setups]]): a bigger monitor, a headset hook, a first RGB strip.

### Materials & palette
Concrete `#6B6B6B`, plywood `#B08A5A`, rust `#8A4B2A`, faded paint `#9DB4C0`. Low saturation. Team color only on the bedsheet banner.

### Lighting & sound
- One **bare tungsten bulb** (warm `#FFC27A`) with a slow flicker, plus monitor glow. Dust particles in the light.
- Interior color correction: saturation −0.2, slight warm tint.
- Sound: bulb hum, PC fan whine, a dripping pipe, traffic outside, the door rattle when someone walks in.

### Life
- You (Founder) sit at your PC playing Pickup Games. Hired players walk in through the roll-up door, look around, and sit at their desk.
- A couple of fans peek under the garage door at 0–1k Followers ([[Fan Base & Arena]]).

### Grows during the era
Desk 2 → first hire (Rusty) → Desk 3 → fairy lights along the ceiling → a second-hand couch cushion → the garage feels full and cramped. That's the cue for the café.

---

## 2. Café Corner (Stage 2)
**Feel:** scrappy but lively. You've moved up to a real place, just a rented one.

### From the road
- The garage wall is **knocked through** into a rented corner café next door, called **Byte & Brew** (fictional). Together they fill Zone A.
- Neon **OPEN** sign, a striped **awning in your team colors** (the first time team colors take over a building).
- Chalkboard sandwich board on the sidewalk: "LAN NIGHT FRIDAY", later your team tag.
- The garage door is **painted** in your primary team color.
- **Cash Collector:** a café tip jar on a little stand by the door.

### Floor plan
```
 ┌──── Case Vault (old walk-in fridge) ──┬─── back storeroom ───┐
 │  [pedestal + spotlight]               │  parts boxes         │
 ├───────────────────────────────────────┤                      │
 │ GARAGE (Practice Floor, 3 desks)      │ CAFÉ: row of 5 PCs   │
 │ knocked-through wall ↔                │ on high counters     │
 │                                       │  [Reaction Test cab] │
 │ trophy shelf (Stage 3)                │ TECH SHOP COUNTER    │
 └──── painted garage door ──────────────┴── café door + awning ┘
```

### Inside
- **Café floor:** a row of 5 rented café PCs on high counters with stools: the 5-slot roster. Menu chalkboard reused as the **roster board** (names in chalk).
- **Tech Shop counter:** the old coffee counter. Shelves behind it hold boxed parts from the fictional brands (NovaCore, Vektor, Pulse Audio, see [[Content Catalog]]). Espresso machine still on the end. Prompt → [[Screen - Tech Shop]].
- **Case Vault:** the old walk-in fridge in the back, frost on the door. Inside, a single pedestal under a spotlight where cases land ([[Case Unboxing]]).
- **Reaction Test cabinet:** a retro arcade cabinet by the window (Stage 2's new toy).
- **Garage side** stays the Practice Floor, now with a rug and a mini-fridge that's actually stocked.

### Stations
Matching café PCs (same model, scuffed). Players start adding personal touches: a plushie, a photo, a sticker on the monitor.

### Materials & palette
Wood counters `#7A5230`, tiled floor (black/white check), exposed brick `#8C4A3C`, chrome stools. Neon accents cyan `#22D3EE` and pink `#E040FB`. Team color on the awning, door, and aprons.

### Lighting & sound
- Pendant lamps over the counter, pink/cyan neon rim light from the signs, the garage half still warm tungsten. Two moods in one room on purpose.
- Sound: café chatter (low), espresso machine hiss now and then, keyboards, chillwave music track.

### Life
- Players sip drinks at their stations, high-five after scrim wins.
- **Café LAN Night** (Stage 2 boss): chairs face the wall TV, fairy lights on, a small AI crowd of locals.

### Grows during the era
Roster board fills up → first crates in the vault → a trophy shelf over the garage desks appears at Stage 3.

---

## 3. Training Center (Stage 3–4)
**Feel:** the team is getting serious. Clean, bright, a bit clinical, in contrast with the warm café.

### From the road
- A **glass-and-white wing** rises behind the café on the left half of Zone B. You see it over the café roof.
- The café façade gets a proper team sign (a lightbox with your logo) next to the Byte & Brew sign.
- Stage 4: the **first sponsor banner** (local sponsor) hangs on the wall ([[Sponsors]]).
- **Cash Collector:** a small register kiosk.

### Inside
- **Glass Practice Room:** matching white desks in a row, dual monitors, a scrim board (big screen with the ladder rank and your next match) ([[Matches & Tournaments]]).
- **Analyst wall:** a large screen with heatmaps, round timelines, and player stat graphs. It shows your real roster's data ([[Skill Levels & Ratings]]).
- **Training pods:** treadmills for the reaction drill, a VR-style rig for aim drills, a whiteboard with set plays ([[Staff & Training]]).
- The **taped chair** sits by the door with a sticky note: "don't throw out".
- **Stage 4 add-on, Clip Studio:** a small edit suite off the practice room, with an editing desk, ring lights, and the **Replay Theater** screen that visitors can watch ([[Clips & Traction]]).
- The garage turns into the **tech bench and storage** room.

### Materials & palette
White panels `#F1F5F9`, glass, light grey carpet, black desks. Team color in a stripe at desk height around the room.

### Lighting & sound
- Cool, even LED panel light (neutral white). Color correction: contrast +0.05, no tint. It's the first era that looks "pro".
- Sound: quieter, crisp mechanical keyboards, a coach's whistle on drill completion, low ventilation hum.

### Life
- Players run drills, the analyst wall changes graphs, players gather at the scrim board before matches.
- Your **rival's banner** ([[Rivalries & Storylines]]) gets pinned on the analyst wall with a red X.

---

## 4. Gaming House (Stage 5)
**Feel:** home. The team lives here now. Cozy, lived-in, and full of team colors.

### From the road
- Zones A and B rebuild into a **two-story team house** with a flat roof, big windows, and a **balcony** over the driveway.
- Rooftop lightbox sign with your logo, lit up at night (the Hub is always dusk, so it's always on).
- **LED strips** in team colors line the eaves and windows.
- The old garage door is kept and framed as a side entrance with a sign: **"The Garage"** (the Founder's corner inside).
- Zone C becomes a **backyard**: a basketball hoop, a BBQ, beanbags, string lights (a placeholder for the Arena).
- Fans queue on the sidewalk with signs at 10k+ Followers ([[Fan Base & Arena]]).
- **Cash Collector:** a branded team safe by the front gate.

### Floor plan
```
 GROUND FLOOR                              UPPER FLOOR
 ┌─────────────┬──────────┬───────────┐    ┌──────────────┬───────────┐
 │ Practice    │ Staff    │ Case      │    │ Bootcamp     │ Dorm bath │
 │ Floor (RGB) │ Offices  │ Vault     │    │ Dorms (bunks)│ + laundry │
 ├─────────────┼──────────┼───────────┤    ├──────────────┼───────────┤
 │ Lounge      │ Kitchen  │ Tech Shop │    │ Training     │ Balcony   │
 │ (sofa, TV)  │          │           │    │ Center (moves│ over road │
 ├─────────────┴──┬───────┴───────────┤    │ upstairs)    │           │
 │ "The Garage"   │ entrance hall     │    └──────────────┴───────────┘
 └── side door ───┴── front door ─────┘
```

### Inside
- **Practice Floor:** RGB desks in team colors, proper gaming chairs, acoustic panels on the walls.
- **Lounge:** big sofa, a large TV showing your last match, a console, the **taped chair** in the corner as a joke throne.
- **Kitchen:** fridge full of fictional energy drinks, a team schedule on the fridge door, dirty dishes that disappear when you hire a Manager ([[Staff & Training]]).
- **Staff Offices:** the coach's tactics whiteboard, the analyst's desk, the manager's desk with paperwork.
- **Case Vault:** a real bank-style vault door that spins open on each case.
- **Bootcamp Dorms (upstairs):** bunk beds with team bedsheets, each labeled with a player's name. Fatigued players go to lie down here ([[Plot & HQ]] → *Bootcamp Dorms*).
- **"The Garage":** the Founder's corner. The original fold table, your first poster, the bedsheet banner. Visitors love finding it.

### Stations
Full RGB in team colors, gaming chairs with the team logo, headset stands, small personal items per player (plushies, figures, flags for the player's nationality from [[Player Generator]]).

### Materials & palette
Warm wood floors, soft fabric, painted walls in your **secondary team color**, LED strips in the **primary** color. A homey mix of neon and wood.

### Lighting & sound
- Warm ambient with team-color LED accents. Lamps in the lounge, cooler light on the Practice Floor.
- Sound: TV murmur, kitchen sounds, players chatting, laughter after wins, a washer spinning upstairs.

### Life
- Players cook, play console, nap in the dorms, and walk between rooms. This is the era where the HQ feels alive.
- The coach paces at the whiteboard before matches.

---

## 5. Studio Campus (Stage 6–7)
**Feel:** a real organization. Modern, branded, busy, built to be seen.

### From the road
- The Gaming House stays as the **Team House**, joined by **two new modern buildings** and a **glass skybridge** on the second floor.
- **Big LED façade screen** on the main building plays your top clip on loop. People in the street stop and watch it ([[Clips & Traction]]).
- **Sponsor billboards** (Energy-tier sponsors) on the side walls ([[Sponsors]]).
- **Merch Store** at street level on the Frontage, with your jersey drops in the window ([[Fan Base & Arena]], [[Sponsors]]). Its interior should read as a real esports merch shop (hero banner, category shelves, product grid); see the [[Sponsors]] reference image.
- Zone C becomes a **courtyard** with your logo painted on the ground, plus a fan queue line with barriers.
- **Cash Collector:** a sleek branded pay terminal at the gate.

### Buildings
| Building | Rooms | Notes |
|---|---|---|
| **Team House** (old Gaming House) | Practice Floor, lounge, kitchen, dorms, "The Garage" | Unchanged inside. Familiar. |
| **Media Building** | Streaming Booth (rooftop glass box with a red ON AIR light), Clip Studio (moves here, bigger), Replay Theater with seats | The Streaming Booth is visible from the street and glows when someone streams ([[Plot & HQ]] → *Streaming Booth*) |
| **Ops Building** | Staff Offices, Tech Shop (showroom style, parts on lit plinths), Case Vault (dark room with a ring of light), Merch Store on the ground floor | |
| **Stage 7: Trophy Hall** | Long dark hall, marble floor, spotlit trophy plinths, title banners hanging from the ceiling, the **taped chair** in a display case | Visitors can Like it ([[Plot & HQ]] → *Trophy Hall*) |
| **Stage 7: Academy Wing** | Classroom-style desks for youth prospects in hoodies, a coach at the front, a "Next Gen" banner | [[Academy & Youth]] |

### Materials & palette
Glass, brushed metal, dark concrete `#2B2F3A`, neon trims. **Team colors as architectural lighting** (façade washes, underlit stairs). Sponsor colors only on their billboards.

### Lighting & sound
- Architectural uplights on the outside, polished interiors with spot lighting. Color correction: contrast +0.08, bloom slightly up.
- Sound: the façade screen's clip audio (quiet, spatial), studio chatter, the Streaming Booth's muffled voice, the merch store's door chime.

### Life
- Staff walk between buildings over the skybridge. A streamer player sits in the booth. Academy kids practice. Fans with signs wait in the courtyard (100k+ Followers: they wear your jersey).

---

## 6. Arena (Stage 8–10)
**Feel:** full spectacle. The thing everyone in the server can see from the plaza.

### From the road
- Zones B and C become a **stadium bowl** (horseshoe shape, ~152 × 256 studs, up to ~90 studs tall). It rises behind the campus and **towers over the neighbouring plots**.
- **LED ribbon** around the top of the bowl scrolls your team name, next match, and score.
- On home match days, **searchlights** sweep the sky from the roof. They're visible from anywhere in the Hub.
- The campus buildings stack into Zone A: Team House + Media and Ops floors become one tall **Players' Building** connected to the arena by the **players' tunnel** (through the original garage door).
- Stage 10: **gold accents** everywhere ([[Art & Audio Direction]] → *Color story*), the **Worlds trophy** on a plinth at the main entrance, next to the taped chair.
- **Cash Collector:** a row of ticket turnstiles at the gate that spin as income comes in.

### Floor plan (arena level)
```
                ┌──────────── back of plot ─────────────┐
                │        MAIN STAGE                      │
                │  [Booth A 5 desks]  ⬛  [Booth B 5 desks]│
                │        jumbotron cube above ⬛          │
                │  caster desk (side)       pyro line    │
                │ ╲                                    ╱ │
                │  ╲   bleachers (horseshoe)          ╱  │
                │   ╲   VIP boxes on top tier        ╱   │
                │    ╲______ concourse ring _______╱    │
                │      concessions · merch · tunnel     │
                └──────── Players' Building (Zone A) ───┘
```

### Inside
- **Main Stage:** two glass soundproof booths with 5 desks each, facing each other. A **jumbotron cube** hangs above. An LED floor shows your logo. A caster desk sits stage-side ([[Caster & Commentary]]).
- **Bleachers:** ~1,500 seats as models. Beyond that, flat crowd cards. Fill follows your Followers and ticket price ([[Fan Base & Arena]]). Empty seats show as folded-up seats, so a half-full arena reads honestly.
- **Concourse ring:** concessions stands, a merch stall, trophy cases, the players' tunnel.
- **VIP boxes** on the top tier (stadium upgrade).
- **Rafters:** a hanging **banner for every title you've won** (Local Cup, National Finals, Worlds…), plus your jersey numbers once players retire or reach Legend status ([[Franchise Rebirth]] → Legend player).
- **Stadium upgrades** ([[Fan Base & Arena]] → *Stadium upgrades*): jumbotron, pyro cannons along the stage front, light-show truss, mascot entrance, concessions. Each one is a pad and visibly adds to the arena.
- The Players' Building has the Practice Floor, dorms, offices, Trophy Hall and "The Garage". Same rooms, stacked.

### Materials & palette
Dark venue (`#0F1426` from the [[UI Style Guide]]), black steel trusses, glossy stage floor, **team colors in the seats** (seat colors spell your logo or tag when the stadium is empty). Gold `#F59E0B` trims at Stage 10.

### Lighting & sound
- Dark house lights, **high-contrast spotlights**, moving beams, haze. Color correction: contrast +0.15, bloom up. This is the [[Art & Audio Direction]] Arena preset.
- On match days: walk-out spotlights, pyro bursts on wins, confetti cannons in team colors.
- Sound: crowd murmur scaled to fill, crowd roar on rounds, **your chant** from the chant builder ([[Fan Base & Arena]]), big-room EDM between matches, the caster PA echo.

### Life
- Home matches: players walk out of the tunnel, wave, enter the booths. The crowd stands on clutch rounds.
- Off days: ground staff sweep, the jumbotron shows clip highlights, a few fans tour the concourse.

---

## What the team wears
Each era unlocks new garments, from mismatched garage tees to Arena stage kits: [[Jersey Progression]].

## Era upgrade cinematics
Each one follows the [[Plot & HQ]] rule (camera pulls up and back, old shell dissolves, new one builds in with sparks). Max 6 s, skippable.
| Upgrade | Special beat | Caster line |
|---|---|---|
| Garage → Café | A sledgehammer knocks through the garage wall, dust, the OPEN sign flickers on | "They've outgrown the garage. Café Rookies, everyone." |
| Café → Training Center | The glass wing slides up out of the ground behind the café | "Look at that setup. These kids are training like pros." |
| Training Center → Gaming House | The camera rises with the second floor building in; the bedsheet banner gets framed | "From a garage to a gaming house. They're for real now." |
| Gaming House → Studio Campus | The skybridge extends across, the façade screen powers on with your best clip | "This isn't a team anymore. It's an organization." |
| Studio Campus → Arena | The ground opens, the stadium bowl rises, searchlights fire into the sky, the whole server gets a toast: "<Team> just opened their Arena!" | "Ladies and gentlemen… welcome to the house that <Team> built." |
| Rebirth (reverse) | Trophies fly into a crate, the plot collapses, the new region's garage builds in ([[Franchise Rebirth]]) | "Back to the garage. But this time, they know the way." |

## Region skins (after Rebirth)
Each region from [[Franchise Rebirth]] re-skins **the shells only**. Room layout, pad positions and anchors stay the same, so one `Pads.lua` works everywhere.
| Era | Home Region | Neon Coast | Frost Peaks | Sandstorm Bay | Sky Islands |
|---|---|---|---|---|---|
| Garage | Suburban garage | Surf-shack garage, surfboards | Log woodshed, snow on roof | Adobe garage, rug awning | Garage on a floating rock, rope bridge |
| Café | Byte & Brew corner café | Beach smoothie bar | Ski-lodge cocoa bar | Spice-market stall café | Airship-dock tea house |
| Training Center | Glass wing | Glass beach pavilion | Heated glass dome | Shaded courtyard with fans | Cloud-glass platform |
| Gaming House | Two-story house | Stucco villa, palm trees | Timber chalet | Sandstone townhouse | Floating mansion |
| Studio Campus | Modern glass campus | Pastel art-deco blocks | Alpine resort | Glass desert towers | Linked floating platforms |
| Arena | Horseshoe stadium | Beach stadium, sunset sky | Ice dome arena | Sandstone colosseum | Floating arena ringed by airships |

"Mixed" regions (Rebirth 5+) pick a random skin per era. Legacy decor and the taped chair carry over.

## Decor slots
Every era has fixed **decor anchors** on top of free placement ([[Plot & HQ]] → *Decor & customization*): 4 wall-poster spots, 2 neon-sign spots, 1 rug, 1 window, plus more per era (Café +2, Gaming House +6, Campus +8, Arena +10). Neon signs from [[Content Catalog]] ("GG", "Clutch", team tag, "No Lag Zone").

## Visitor route
When someone visits ([[Social & Multiplayer]]), soft floor arrows point a short tour so the best parts are seen:
Garage: Founder PC → whiteboard. Café: roster board → Case Vault. Training Center: analyst wall → Replay Theater. Gaming House: lounge → "The Garage". Campus: façade screen → Trophy Hall. Arena: Main Stage → rafters → Worlds trophy.

## Build rules (Studio)
- Shells live in `ServerStorage/HQ/<Region>/<Era>`. Rooms are sub-models named by the pad `Builds` IDs in `Shared/Config/Pads.lua`.
- Every room has attachments for **station seats**, **NPC idle points**, **decor anchors**, and **camera anchors** for the era cinematic.
- Interiors stay inside their zone box; nothing crosses into a neighbour's plot.
- A **low-detail exterior shell** (≤ 15% of the era's parts) per era and region, for distant plots ([[World Layout & Presentation]] → *Performance budgets*).
- Big props are slightly oversized so they read on phones ([[Art & Audio Direction]] → *Scale*).

## Acceptance criteria
- [ ] Each era is clearly different from the road at plaza distance (silhouette test with lights off).
- [ ] The taped chair, garage door and bedsheet banner appear in every era.
- [ ] Team colors change the awning (Café), LED strips (Gaming House), façade wash (Campus) and seats (Arena).
- [ ] Each era stays within its part budget and plot zones.
- [ ] Region skins reuse the same room anchors (pads, stations and decor land in the same spots).
- [ ] The Arena opening toast shows on every player's screen in the server.

## Open questions
- Should visitors be able to sit in your Arena bleachers during a home match? (See [[Fan Base & Arena]].)
- Café name: keep "Byte & Brew", or let players rename the café like the team?

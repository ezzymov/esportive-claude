---
tags: [feature]
status: building
priority: P1
stage: 3
system_type: DataModel
engine_layer: ReplicatedShared
dependencies:
  - "[[Map Library]]"
  - "[[Match Simulation]]"
  - "[[Clip Cutscene System]]"
affected_ui:
  - "[[Screen - Bracket]]"
  - "[[Screen - Match HUD]]"
roblox_execution_environment: ReplicatedStorage
---
# Maps & Map Pool

## Summary
Every fictional game title is played on maps. Maps change who wins (each favors certain roles and stats), give a strategy layer (map veto), and are the sets where clip cutscenes happen ([[Clip Cutscene System]]). Map list: [[Map Library]].

## How maps affect matches
- Each map has **stat weights** that adjust the title's normal weights. Example: Neon Docks has long sightlines → Sniper role +10%, Aim weight +0.05.
- Each map has a **pace**: Fast (favors Entry/Reflexes), Balanced, Slow (favors Strategist/Game Sense).
- Formula hook in [[Match Simulation]]: `TeamPower × MapFit × MapMastery`.
  - `MapFit` = how well your roster's roles/stats match the map's weights (0.95–1.05).
  - `MapMastery` = your team's practice on that map (1.00–1.05).

## Map Mastery
- Each team has 0–100 mastery per map. Scrims and matches on a map give +2/+1; training a map in the Training Center gives more.
- Mastery tiers: Unfamiliar (0–19), Practiced (20–49), Comfortable (50–79), Home Turf (80–100).
- Mastery decays slowly (−1/day) for maps not played, so players rotate.
- Coach staff boosts mastery gain; Analyst shows the opponent's mastery in the pre-match screen.

## Player map preferences
- Each player has a hidden **Comfort Map** (+3% on it) and **Hate Map** (−3%). Revealed after 3 matches on that map.
- Trait **Map Specialist**: +10% on one named map.
- Card shows small map icons for comfort/hate once revealed.

## Map veto (pick/ban)
Uses the **Strategy Draft** minigame from [[Playable Games]].
| Format | Veto |
|---|---|
| Bo1 | Ban, ban, ban, ban, decider |
| Bo3 | Ban, ban, pick, pick, ban, ban, decider |
| Bo5 (finals) | Ban, ban, pick, pick, pick, pick, decider |
- Players get 10 s per choice with the map's stat weights, both teams' mastery and the AI opponent's favorites shown.
- **Auto-veto** button picks the best option for you (default for players who skip).
- AI teams have favorite and banned maps based on their personality ([[Rivalries & Storylines]]).

## Map pool and rotation
- Each title has an **active pool of 5 maps** out of 6+.
- Each season one map rotates out and one returns or is new. Announced at season start ("Neon Docks leaves the pool, Monorail joins").
- Scrims and ladder can use any map; tournaments use only the active pool.

## Map modifiers (special events and finals)
| Modifier | Effect | Where |
|---|---|---|
| Night Mode | Darker lighting, Reflexes weight +0.05 | Finals, Spooky event |
| Storm | Rain/snow visuals, Consistency weight +0.05 | Winter Major |
| Crowd Roar | Home-field bonus doubled | Your Arena home matches |
| Mirror | Map flipped (cosmetic + mastery counts 50%) | Weekend events |
| Low Gravity | Bigger jumps in cutscenes, Clutch weight +0.05 | Event only |

## Unlocks
- Stage 1–3: the first **3** maps of Aim Arena (Neon Docks, Old Arcade, Skyline Mall). Pickup Games pick random.
- **Stage 3: veto in scrims and the Local Cup** (Bo1: you ban, they ban, the last map plays). Changed from "first 2 maps, veto at Stage 4" (2026-10-23): a veto needs at least 3 maps.
- Stage 4: full 5-map pool (ban, ban, ban, ban, decider).

### Built in M3 (2026-10-23)
- `Config/Maps`: per map a stat lean (added to the title weights, then re-normalized) and role bonuses (e.g. Neon Docks Sniper +10% / Entry −3%). `MapFit = clamp(1 + Σ role bonus of the five / 5, 0.95–1.05)`.
- Veto: tap maps in the order you'd ban them (empty = auto-ban your weakest map). AI teams ban the map where you're strongest and never their favorite. Scrim offers show your vs their power on every map in the pool. Tournament ban order is snapshotted at each lock.
- Mastery: +2 per scrim, +1 per tournament match on the played map, `MapMastery = 1 + mastery / 100 × 0.05`. AI teams count as 60 on their favorite map, 25 elsewhere.
- Not built yet: mastery decay, Comfort / Hate maps, Map Specialist, map modifiers, the veto screen's 10 s timer, Bo3/Bo5.
- New titles bring their own pools when unlocked (Tower Clash Stage 5, Drop Zone Stage 7).

## Server / data requirements
- `Shared/Config/Maps.lua` → `{Id, Title, Name, Pace, StatWeights, RoleBonus, ClipSpots, ClipStage, InPool}`
- `Profile.MapMastery = {[mapId] = n}`, `PlayerCard.ComfortMap`, `PlayerCard.HateMap`, `PlayerCard.MapsRevealed`

## UI screens
- Veto screen (map cards with art, weights, mastery bars, ban/pick buttons)
- Map info page in Bracket and pre-match ([[Screen - Bracket]], [[Screen - Match HUD]])

## Acceptance criteria
- [ ] Map choice changes Team Power shown in pre-match
- [ ] Veto works in Bo1/Bo3/Bo5 and auto-veto picks a sensible map
- [ ] Mastery rises from scrims and shows in the veto screen

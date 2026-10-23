---
tags: [feature, titles]
status: designed
priority: P2
stage: 6
system_type: DataModel
engine_layer: ReplicatedShared
dependencies:
  - "[[Match Simulation]]"
  - "[[Map Library]]"
  - "[[Skin Pattern System]]"
affected_ui:
  - "[[Screen - Match HUD]]"
roblox_execution_environment: ReplicatedStorage
---
# Brawl Legends

A cartoon arena fighter played as a **5v5 crew battle**: players fight 1v1 in a relay, and whoever loses all their stocks is out. Stages: [[Map Library]] → Brawl Legends.

## Crew battle format
- Each crew has **5 players** and a shared pool of **15 stocks** (3 each).
- Player 1 from each crew fights. When a player runs out of stocks, the next player on that crew comes in. Stocks left over carry on.
- The crew that runs out of players first loses.
- Order matters: **Opener** (goes first), mid-crew, **Anchor** (goes last). Set in the lineup screen.
- Match = Bo3 crew battles, one stage per battle (veto).

## Fighters (12 at launch, fictional)
| Fighter | Style | Signature move (cutscene) |
|---|---|---|
| **Knuckle Bot** | Heavy robot | Rocket punch |
| **Pip** | Small and fast | Triple air-spin |
| **Madame Mop** | Janitor hero | Mop sweep |
| **Captain Comet** | Space pilot | Jetpack dive |
| **Sir Clank** | Knight in tin armor | Shield bash |
| **Noodle** | Stretchy | Long-arm grab |
| **Blaze Fox** | Fire fox | Flame dash |
| **Ms. Thunder** | Wrestler | Thunder slam |
| **Toaster** | Living toaster | Toast launcher |
| **Shade** | Ninja | Shadow step |
| **Gummy** | Gummy bear | Bounce |
| **Old Ref** | Retired referee | Red card stun |
Each roster player has a **main fighter** (from archetype) and 2 secondaries. Counter-picking is the Strategist's job.

## Fight flow (what the sim tracks)
- Each stock: neutral (spacing), punish (combo), finisher (ring-out over the edge or KO meter full).
- **Super meter** fills over time; full meter = signature move.
- **Parry**: a well-timed block that turns defense into offense (the "Parry Comeback" clip).
- Hits show impact sparks and shockwaves (no blood). KOs ragdoll the fighter; ring-outs launch them off the stage.

## How stats show up
| Stat | Effect | Cutscene |
|---|---|---|
| Aim | Landing hits | Clean combos |
| Reflexes | Parries, dodges | Parry flash, quick dodges |
| Game Sense | Reads, spacing | Baits a move and punishes it |
| Teamwork | Small: crew order bonus | Teammates cheer from the bench |
| Clutch | Wins on last stock | Last-stock comeback slow-mo |
| Consistency | Doesn't drop stocks cheaply | Fewer silly ring-outs |

## Roles
Entry = Opener · Flex = Anchor · Support = mid-crew stabilizer · Sniper = zoner (keeps distance) · Strategist = counter-picker/captain.

## What a crew battle looks like (cutscene)
- 2D-style side camera (2.5D) on a small stage, crowd in the background.
- Top bar: both crews' 5 nameplates with stock icons (hearts) under each name. Current fighters glow.
- Fighters' nameplates float above them: `NW | Kick Kat`.
- Switching players: tag-team animation (high-five on the bench, new fighter jumps in).
- End: last ring-out in slow-mo, winning crew rushes the stage.

## Clip moments
Perfect Stock (no damage taken) · Parry Comeback · Super Finish · Ring-out · Combo 50+ · Reverse Sweep (Anchor beats 3+ players).

## Skins and loadout
Per player: **Fighter outfit skins** (for main + secondaries), **Hit effect** (stars, hearts, pixels), **Victory pose**, **Entrance animation**, **Taunt**. Patterned outfits use seeds/conditions ([[Skin Pattern System]]).

## Links
[[Game Titles Overview]] · [[Maps & Map Pool]] · [[Clip Cutscene System]]

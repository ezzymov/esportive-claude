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
# Kart Rift

Team kart racing. Fast, colorful, easy to read. A side league with weekend cups. Tracks: [[Map Library]] → Kart Rift.

## Format
- **4v4 team race**: 4 of your players race against 4 from the other team (8 karts).
- Your 5th player is the **Pit Strategist** (best: Strategist role). They don't race; they boost the team (pit timing, boost plan, reading rivals).
- Points by finish: 1st 15 · 2nd 12 · 3rd 10 · 4th 8 · 5th 6 · 6th 4 · 7th 2 · 8th 1. Team with more points wins the race.
- A match = 3 races on 3 tracks (veto like maps). Most race wins takes the match.

## Race flow
1. **Grid:** start order from qualifying (Reflexes + Consistency).
2. **Lap 1:** item boxes, drafting, early overtakes.
3. **Lap 2:** pit window (Strategist decides), boost chains.
4. **Final lap:** big overtakes, photo finishes.

## Items
| Item | Effect |
|---|---|
| **Boost Can** | Speed burst |
| **Bubble Shield** | Blocks one hit |
| **Goo Puddle** | Slows the kart behind |
| **Magnet** | Pulls toward the kart ahead |
| **Spring Hop** | Jump over hazards or take shortcuts |
| **Confetti Cannon** | Spins out karts nearby (team-safe) |

## How stats show up
| Stat | Effect | Cutscene |
|---|---|---|
| Reflexes | Corner speed, dodging items | Clean drift lines |
| Aim | Item hits | Goo Puddle lands right in front of a rival |
| Game Sense | Racing line, shortcut use | Takes the hidden shortcut |
| Teamwork | Blocking for teammates | Teammate holds back rivals |
| Clutch | Last-lap overtakes | Slow-mo pass at the finish line |
| Consistency | Fewer crashes | No spin-outs |

## Roles
Entry = lead racer · Sniper = drafter (slipstream) · Support = blocker · Flex = any · Strategist = Pit Strategist (doesn't race).

## What a race looks like (cutscene)
- Grid shot with all 8 karts, nameplates above helmets, team colors on the karts.
- TV-style chase cams, helicopter shots over the track, on-board POV.
- Position tower on the left (`1. NW | Drift Queen`).
- Finish: checkered flag, photo-finish freeze-frame if the gap is under 0.1 s.

## Clip moments
Last-lap Overtake · Photo Finish · Shortcut Steal · Boost Chain · Comeback from Last · Team 1-2-3-4 Finish.

## Skins and loadout
Per racer: **Kart body skin**, **Wheels**, **Boost trail**, **Helmet**, **Horn sound**, **Finish celebration**. Kart body skins use pattern seeds and condition ([[Skin Pattern System]]); Battle-Worn karts get dents and scratches.

## Links
[[Game Titles Overview]] · [[Maps & Map Pool]] · [[Clip Cutscene System]]

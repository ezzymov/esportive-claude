---
tags: [feature]
status: idea
priority: P0
stage: 1
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Balance Tables]]"
  - "[[Case Library]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Tech Shop]]"
roblox_execution_environment: ServerScriptService
---
# PC Setups

Each player sits at a **station**. Station quality gives bonuses and generates visible income/fans. The station belongs to the **seat**: whoever sits there gets its bonus.

> **Mouse, keyboard and headset moved to [[Accessories]]** (2026-10-21). They now belong to the player, not the station, and give flat points to one stat each. Station parts are the team's infrastructure; accessories are personal gear.

## Components (slots)
| Slot | Effect |
|---|---|
| CPU | Match performance multiplier |
| GPU | FPS → Reflexes bonus, stream quality |
| Monitor (Hz) | Aim bonus |
| Chair | Fatigue resistance, morale |
| Desk / RGB / decor | Cosmetic + small fame boost |

Station part bonuses (`partMult`) are switched off in the Ranked Ladder (Pure mode, see [[Accessories]] → *Gear Mode*).

## Tiers
Dusty Starter → Budget → Mid → High-End → Pro → Prototype (Mythic). Fictional brands only.

## Mechanics
- Parts drop from cases or are bought in the **Tech Shop** (stock rotates).
- Part rarity/tier grants a % stat multiplier; sets of the same brand give set bonus.
- Station upgrades visually change the model in the HQ (RGB glow, bigger monitors).
- Overclock minigame (optional, risk/reward) to boost a part temporarily.
- Parts wear? (Open: probably no, avoid frustration.)

Links: [[Accessories]] · [[Player Hiring]] · [[Plot & HQ]] · [[Case Unboxing]] · UI: [[Screen - Tech Shop]]

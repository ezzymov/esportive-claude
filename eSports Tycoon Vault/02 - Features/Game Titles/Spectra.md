---
tags: [feature, titles]
status: designed
priority: P1
stage: 6
system_type: DataModel
engine_layer: ReplicatedShared
dependencies:
  - "[[Match Simulation]]"
  - "[[Map Library]]"
  - "[[Hero Library]]"
  - "[[Champion Library]]"
  - "[[Skin Pattern System]]"
affected_ui:
  - "[[Screen - Match HUD]]"
roblox_execution_environment: ReplicatedStorage
---
# Spectra

A 5v5 **hero shooter** with **laser blasters** and hero abilities, in the style of Overwatch / Valorant-type games but with original heroes and rules. Bright, stylized and fast. Heroes: [[Hero Library]]. Maps: [[Map Library]] → Spectra.

> **Content rules.** Laser blasters and sci-fi abilities. No blood or gore. Eliminated heroes **ragdoll** with a short energy flicker, then respawn (in modes with respawns).

## Sides
| Side | Name | Color |
|---|---|---|
| Team 1 | **Solaris** | Gold / white |
| Team 2 | **Umbra** | Violet / black |
Each roster player controls one **Hero**. Nameplates show `[team tag] gamer tag` + hero icon.

## Modes (map decides the mode)
| Mode | How it works | Win |
|---|---|---|
| **Control** | Capture and hold a zone; first to 100% | Best of 3 rounds |
| **Escort** | Push the **Core Cart** through checkpoints; defenders stop it | Further distance / time bank |
| **Breach** | Round-based: attackers activate one of two **Relays**, defenders stop them (closest to Aim Arena) | First to 7 rounds |
- Respawns in Control and Escort (10 s), none in Breach.
- Series: Bo3 / Bo5 with map pick per mode.

## Hero classes
| Class | Job | Roster role fit |
|---|---|---|
| **Vanguard** (tank) | Shields, space, front line | Entry, Support |
| **Striker** (damage) | Kills and picks | Entry, Flex, Sniper |
| **Sharpshooter** (damage) | Long range | Sniper |
| **Medic** (support) | Heals, buffs | Support |
| **Controller** | Zone control, crowd control, info | Strategist |
Team comp: 1–2 Vanguards, 2 Strikers/Sharpshooters, 1–2 Medic/Controller. Classic comps give small bonuses like Tower Clash comps ([[Champion Library]]): **Dive**, **Brawl**, **Poke**.

## Abilities
Each hero has a **laser blaster** (primary fire), **2 abilities** with cooldowns, and an **Ultimate** that charges from damage, healing and objective time. Ultimates are the biggest clip moments. Full list in [[Hero Library]].

## How stats show up
| Stat | Effect | Cutscene |
|---|---|---|
| Aim | Laser accuracy, headshots | Clean beam hits |
| Reflexes | Dodging, reacting to ultimates | Dash out of an enemy ultimate |
| Game Sense | Ultimate timing, positioning | Ultimates used at the right moment |
| Teamwork | Ability combos | Two ultimates combined |
| Clutch | Last-second objective holds | Overtime contest saves |
| Consistency | Fewer feeding deaths | Steady performance |

## What a match looks like (cutscene)
- Hero select screen with each roster player's name under their pick.
- Bright, stylized arenas; laser beams in side colors; ability VFX large and readable.
- Eliminations: hero ragdolls with a brief energy flicker, respawn timer on the HUD.
- **Ultimate moments**: slow-mo, voice line, screen tint, kill feed fills with the hero's icon.
- "Team kill" banner when all 5 enemies are down.

## Clip moments
Team Wipe · Ultimate Combo · Overtime Save · Payload Final Push · 1v3 Hold · Sharpshooter Triple.

## Skins and loadout
Per roster player: **Hero skins** for their top 3 heroes, **blaster skin** per hero, **ultimate voice line**, **spray**, **victory pose**, **elimination effect color**. Pattern skins use [[Skin Pattern System]]; blasters take stickers ([[Sticker System]]).

## Unlock
Stage 6, as its own league. 10 heroes free at unlock; the rest from Spectra tokens or Spectra Crates ([[Case Library]]).

## Links
[[Game Titles Overview]] · [[Hero Library]] · [[Clip Cutscene System]] · [[Pro Player References]]

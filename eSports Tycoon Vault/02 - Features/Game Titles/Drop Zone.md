---
tags: [feature, titles]
status: designed
priority: P1
stage: 7
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
# Drop Zone

A battle royale: 20 squads of 3 drop onto an island, gather gear, and fight while a shrinking storm forces them together. Last squad standing wins. Maps: [[Map Library]] → Drop Zone.

## Squads
- Your team sends **3 of your 5 players** per game (pick in the lineup screen). The other 2 sit out and recover fatigue, or rotate in between games.
- 19 other squads are AI teams or other real players' snapshots in friend lobbies.
- Nameplates: `[team tag] gamer tag` above each player, squad color ring under their feet.

## Tournament format
- A tournament day = **3–6 games**. Points per game:
  - Placement: 1st 12 · 2nd 9 · 3rd 7 · 4th 5 · 5th 4 · 6th–10th 2 · 11th–15th 1
  - +1 per elimination
- Highest total wins the day. A **Victory Drop** (1st place) is the big clip moment.

## Game flow
1. **Drop:** a cargo plane (the **Sky Barge**) flies across the map; squads jump and parachute down.
2. **Loot (0–3 min):** grab firearms, armor, helmets, meds and attachments from buildings and crates.
3. **Storm circles:** 7 circles, each smaller. Outside the circle you take steady damage.
4. **Rotations:** moving to the next circle, often in vehicles. **Supply drops** fall by parachute with top-tier gear.
5. **Final circle:** 3–5 squads left in a tiny area.
- Downed players can be **revived** by a squadmate; fully eliminated players ragdoll. No blood or gore.

## Gear (realistic)
Firearms reuse the [[Aim Arena]] weapon roster (same fictional names, same skins), plus BR-only weapons. CS2/real-world counterparts are vault-only references.
| Item | Type | Counterpart (reference only) | Notes |
|---|---|---|---|
| **Viper-18**, **Bulldog .50** | Pistols | Glock-18, Desert Eagle | Early game |
| **Kite-7**, **Badger 45**, **Ring 90** | SMGs | MP7, UMP-45, P90 | Close range |
| **Volk-47**, **Lancer A4**, **Gallo AR** | Assault rifles | AK-47, M4A4, Galil AR | Main weapons |
| **Ridge DMR** | Marksman rifle (BR only) | Semi-auto DMR | Mid-long range |
| **Swallow 08** | Bolt-action | SSG 08 | Long range |
| **Longbow** | Heavy sniper (supply drop only) | AWP | One-shot body kill |
| **Pump 12**, **Breacher 1014** | Shotguns | Nova, XM1014 | Buildings |
| **Hammer 249** | LMG (supply drop only) | M249 | Suppression |
| **Attachments** | Scopes (red dot, 2×, 4×, 8×), suppressor, extended mag, grip | — | Shown on the weapon in clips |
| **Vest L1–L3**, **Helmet L1–L3** | Armor | — | Visible on the character |
| **Bandage**, **First-Aid Kit**, **Med Case** | Heals | — | — |
| **Smoke**, **Frag**, **Flashbang** | Grenades | Same as Aim Arena | — |
| **Parachute** | Movement | — | Redeploy from towers and jump pads on some maps |
| **Buggy / Dirt Bike / Pickup / Speedboat** | Vehicles | — | Fast rotations (map-dependent) |
Loot rarity uses our rarity colors on the ground glow for readability.

## How stats show up
| Stat | Effect | Cutscene |
|---|---|---|
| Aim | Win fights | Clean long-range headshots |
| Reflexes | React to third parties | Quick turn when ambushed |
| Game Sense | Drop spot, rotations, circle reading | Squad already in the next circle |
| Teamwork | Revives, focus fire | Medic revives in clips |
| Clutch | Final-circle wins | Slow-mo last elimination |
| Consistency | Placement points every game | Rarely dies early |

## Roles
Entry = fragger · Support = medic (revives) · Sniper = marksman · Strategist = caller (rotations) · Flex = scout. Squad picks 3 roles; best combo is Fragger + Medic + Caller.

## What a game looks like (cutscene)
- **Drop:** Sky Barge flies over, your 3 players jump, parachutes open in team color, nameplates on.
- **Mini-map overlay** shows storm circle and squads left counter ("Squads 7 / 20").
- **Fights:** cut to your squad's fights: muzzle flash, tracers, armor sparks, eliminated players ragdoll. Other squads' fights show as kill-feed lines with weapon icons in their skins.
- **Storm:** blue-grey wall closing in, tense music.
- **Victory Drop:** final elimination in slow-mo, flare smoke in team color, squad pose with "VICTORY DROP" banner.

## Clip moments
Final Circle Win · Squad Wipe (eliminate all 3 enemies) · Long-range Snipe · Hot-drop Survival · Vehicle Escape · Revive Under Fire.

## Skins and loadout
Per roster player: **Outfit skin**, **Parachute skin**, **Backpack skin**, **weapon skins** (shared with Aim Arena), **knife**, **gloves**, **Drop trail** (smoke color), **Victory emote**. Weapons take stickers ([[Sticker System]]). All show in clips with seeds/conditions ([[Skin Pattern System]]).

## Match HUD
Squads remaining, storm timer, your 3 players' health and armor, placement points table between games.

## Links
[[Game Titles Overview]] · [[Maps & Map Pool]] · [[Clip Cutscene System]]

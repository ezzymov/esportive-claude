---
tags: [feature, titles]
status: designed
priority: P1
stage: 5
system_type: DataModel
engine_layer: ReplicatedShared
dependencies:
  - "[[Match Simulation]]"
  - "[[Map Library]]"
  - "[[Champion Library]]"
  - "[[Skin Pattern System]]"
affected_ui:
  - "[[Screen - Match HUD]]"
roblox_execution_environment: ReplicatedStorage
---
# Tower Clash

A 5v5 lane-battle game (MOBA style): three lanes, a jungle, towers, and a core to destroy. One long game per map instead of rounds. Maps: [[Map Library]] → Tower Clash.

## Sides
| Side | Name | Base look | Color |
|---|---|---|---|
| Bottom-left | **Sunforge** | Golden forge-city with glowing anvils | Gold/orange |
| Top-right | **Moonveil** | Silver moon-temple with floating crystals | Silver/violet |
Each player controls one **Champion**. Nameplates above Champions show the roster player's gamer tag + team tag, plus a level number.

## Match format
- One game = 20–35 in-game minutes, shown as a 60–90 s cutscene.
- Series: Bo1 (ladder), Bo3 (playoffs), Bo5 (finals). Side choice goes to the higher seed.

## Game flow (what the sim tracks)
1. **Draft:** each team bans 3 and picks 5 Champions (the Strategy Draft minigame from [[Playable Games]] can boost this).
2. **Laning (0–14 min):** lanes farm **Bits** (minion waves). Lane winners get gold and levels.
3. **Objectives:** the **Titans** (two big neutral monsters) spawn: **Ember Titan** (team-wide damage buff) and **Tide Titan** (helps push towers).
4. **Teamfights (14+ min):** 5v5 fights around objectives decide most games.
5. **Siege:** take 3 towers per lane, then the **Gate**, then the **Heart Crystal**. Destroying the Heart wins.

## Champions
30 fictional Champions with classes, lanes, draft tags, abilities and skins: [[Champion Library]].
Unlike Aim Arena Agents, Champions matter: the draft builds a team comp (Dive, Poke & Siege, Protect the Carry, Pick, Split Push) that gives small bonuses and counters. 10 Champions are free when Tower Clash unlocks.

## Roles
| Roster role | Lane / job | Champion classes |
|---|---|---|
| Entry | Top lane, frontline | Guardian, Brawler |
| Strategist | Jungle, shot caller | Assassin, Brawler |
| Flex | Mid lane | Mage, Assassin |
| Sniper | Bot lane carry | Marksman |
| Support | Bot lane support | Support, Healer |

## How stats show up
| Stat | Effect | Cutscene |
|---|---|---|
| Aim | Skill-shot accuracy | Abilities land on target |
| Reflexes | Dodges, reaction to ganks | Champion side-steps a meteor |
| Game Sense | Map control, objective timing | Team shows up at Titan first |
| Teamwork | Teamfight combos | Abilities chain together |
| Clutch | Wins low-health fights and Titan steals | Last-second Titan steal in slow-mo |
| Consistency | Gold lead holds | Fewer "thrown" fights |

## What a game looks like (cutscene)
- **Draft screen:** 10 Champion portraits with the roster player's name under each pick.
- **Top-down map view** (drone camera) with Champion icons moving down lanes; zooms in for fights.
- **Teamfight:** camera at 45° angle, ability VFX in side colors, damage numbers hidden (keeps it readable), defeated Champions ragdoll and fade, with a respawn timer on the HUD.
- **Titan fight:** big creature roars, both teams arrive, "Titan Steal" clip moment if the losing team steals it.
- **End:** Heart Crystal shatters, winning team's Champions do a pose with nameplates.

## Clip moments
Pentakill Teamfight · Titan Steal · Backdoor Push (sneak destroy the Heart) · Outplay 1v2 · Tower Dive · Base Race. Templates in [[Clip Cutscene System]].

## Skins and loadout
Each roster player's Tower Clash loadout:
- **Champion skins** for their top 3 Champions (e.g. Pyrra "Neon Comet", Brakk "Gingerbread").
- **Recall effect** (animation when going back to base).
- **Ward skin** (vision totem).
- **Emote** for after a tag.
Skins use [[Skin Pattern System]] seeds/conditions where they have patterns (e.g. armor patterns), and show in all cutscenes and clips.

## Match HUD
Gold graph, tower count, Titan timers, Champion portraits with levels, kill score (shown as "tags").

## Links
[[Game Titles Overview]] · [[Maps & Map Pool]] · [[Clip Cutscene System]]

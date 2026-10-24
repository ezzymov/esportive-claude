---
tags: [feature]
status: building
priority: P0
stage: 1
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Player Generator]]"
  - "[[Key Players]]"
  - "[[Pro Player References]]"
  - "[[Trait Library]]"
  - "[[Skill Levels & Ratings]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Roster]]"
roblox_execution_environment: ServerScriptService
---
# Player Hiring & Roster

## You start solo
The team starts with one player: **you** ([[Founder (You)]]). You earn your first money yourself and hire your first teammate around minute 8 ([[Stage 1 - Garage Squad]]).

## Sources of players
1. **Free agents board** – refreshes every 10 min, cheap, low rarity
2. **Scouting** – spend time + cash to scout a region; reveals hidden potential
3. **Case drops** – see [[Case Unboxing]]
4. **Transfer market** – buy from other players (tax sink)
5. **Academy** – train your own prospects
6. **Friends Board** – sign your Roblox friends with their real avatar, see [[Friend Signings]]

Most players are randomly generated ([[Player Generator]]); a few hand-made key players exist per title and rarity ([[Key Players]]); named stars at the top ([[Pro Player References]]).

## Player card
- Name, nickname, country flag, age, role (Entry, Support, Sniper, Strategist, Flex)
- Stats (1–100): **Aim, Reflexes, Game Sense, Teamwork, Clutch, Consistency**
- **Potential** (hidden until scouted/trained)
- **Trait** (e.g. Clutch God, Tilt-Prone, Streamer, Team Leader, Rising Star)
- Salary, contract length, morale, fatigue
- Rarity color frame

## Roster rules
- Active roster: 5 slots (grows with HQ upgrades → sub bench of up to 3)
- Role synergy bonus when roster covers all roles
- Chemistry builds with matches played together

## Management actions
Train (stat XP, costs time/fatigue) · Bench · Release · Re-sign · Sell · Promote from academy

## Hooks
Morale drops after losses/long grinds; boosts from wins, good chairs, coach, bonuses.

Links: [[PC Setups]] (gear boosts stats) · [[Staff & Training]] · [[Matches & Tournaments]] · UI: [[Screen - Roster]]

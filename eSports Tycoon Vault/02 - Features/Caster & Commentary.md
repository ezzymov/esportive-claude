---
tags: [feature, new]
status: building
priority: P1
stage: 1
system_type: UIController
engine_layer: ClientController
dependencies:
  - "[[Match Simulation]]"
  - "[[Player Voice Lines]]"
  - "[[Pro Voice Lines]]"
affected_ui:
  - "[[Screen - Match HUD]]"
roblox_execution_environment: StarterPlayerScripts
---
# Caster & Commentary

## Summary
A pair of fictional casters narrate the whole game: tutorial, matches, case reveals, promotions. They are the game's personality and the cheapest way to deliver "Spectacle" (pillar 3).

## Cast
| Caster | Personality | Role |
|---|---|---|
| **"Hype" Hector** | Loud, excited, puns | Play-by-play, big moments |
| **Dr. Data** | Calm analyst, dry humor | Stats, pre-match, tutorial tips |

## Where they speak
- Tutorial: Hector cheers milestones only. Aunt Dee is the tutorial guide, not the casters ([[Tutorial & Onboarding]])
- Match: round start, kills, clutches, aces, upsets, match point, victory
- Case reveal: rarity-scaled reactions ("THAT'S A MYTHIC! I'm going to need a minute.")
- Promotions, sponsor signings, rivalry matches
- Idle HQ: occasional ambient lines (max 1 per 3 min)

> Players have their own voice lines too (pros get personal packs, everyone else shares a vibe pool): [[Player Voice Lines]] · [[Pro Voice Lines]]. Casters have priority over player lines.

## Line system
- Lines grouped by **event** and **intensity** (1–3). Picker avoids repeats (last 5 per event).
- Template tokens: `{team}`, `{player}`, `{rival}`, `{score}`. All tokens are server-filtered names.
- Text bubble + lower-third always; voice audio optional later (record ~200 lines).
- Settings: caster frequency (Off / Low / Normal).

## Example lines
- Round start: "Here we go, {team} looking hungry!"
- Clutch: "1v3... {player} is NOT leaving this server without a fight!"
- Upset: "Nobody had {team} winning this. NOBODY."
- Rival: "{rival} again. You can feel the tension from the cheap seats."
- Rare pull: "Ooh, blue glow, that's a nice one."

## Server / data requirements
- `Shared/Config/CasterLines.lua` → `{[event] = {[intensity] = {lines}}}`
- Client picks the line from the event the server sends (no server cost).

## Acceptance criteria
- [ ] Every match event in [[Match Simulation]] has at least 5 lines
- [ ] No line repeats within 5 uses of the same event

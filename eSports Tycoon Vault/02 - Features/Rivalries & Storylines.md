---
tags: [feature, new]
status: idea
priority: P2
stage: 3
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Match Simulation]]"
  - "[[Data Schema]]"
affected_ui: []
roblox_execution_environment: ServerScriptService
---
# Rivalries & Storylines

## Summary
Recurring AI teams with personalities turn faceless matches into a story. A rival follows you up the divisions, trash-talks, and the payoff of finally beating them in a final is huge.

## AI team personalities
| Archetype | Example team | Behavior | Voice line style |
|---|---|---|---|
| Arrogant champs | Apex Cartel | Strong, always in finals | "Garage kids? Cute." |
| Underdog buddies | Turbo Tigers | Weak but lucky upsets | "We believe!" |
| Tryhard nerds | Frostbyte | High Game Sense, picks counters | "We ran the numbers." |
| Chaos gremlins | Glitch Syndicate | High variance, random tactics | "lol lmao gg" |
| Silent killers | Phantom Lag | Never talk, high Clutch | "..." |

Each region in [[Franchise Rebirth]] has its own set of 8 AI teams.

## Rival system
- After your first loss to a named team, they become your **Rival** (banner on the HQ wall, rival meter).
- Rival meter: wins vs them fill it, losses drain it. Full meter = "Rivalry settled" achievement + exclusive jersey decal of their logo crossed out.
- Beating your rival gives +50% Fame for that match.
- A new rival is assigned each stage band (3, 5, 7, 9).

## Storyline beats (scripted, lightweight)
| Stage | Beat |
|---|---|
| 3 | Rival laughs at your Local Cup entry; you meet them in the final |
| 5 | Rival tries to poach your best player (offer event, see [[Player Life Events]]) |
| 7 | National final vs rival, caster hype package |
| 9 | Old rival joins you as an ally vs a new overseas superteam |

## Delivery
- Text-only "inbox messages" and pre-match trash talk bubbles (preset lines, no generated text).
- Caster lines reference the rivalry (see [[Caster & Commentary]]).

## Server / data requirements
- `Profile.Rivals = {[teamId] = {Meter, Wins, Losses, Settled}}`
- AI teams in `Shared/Config/AITeams.lua` with personality, stat profile, logo, lines.

## Acceptance criteria
- [ ] First loss to a named AI team marks them as Rival with HQ banner
- [ ] Pre-match screen shows rivalry meter and trash talk line

## Open questions
- Let real players declare each other rivals? Fun but needs anti-harassment design; P3.

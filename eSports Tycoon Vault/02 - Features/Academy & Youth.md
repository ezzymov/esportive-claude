---
tags: [feature, new]
status: idea
priority: P2
stage: 7
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Player Generator]]"
  - "[[Skill Levels & Ratings]]"
  - "[[Trait Library]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Roster]]"
roblox_execution_environment: ServerScriptService
---
# Academy & Youth

## Summary
Grow your own stars. Prospects start weak but can have high hidden Potential. Long-term investment that pays off as a cheap superstar.

## How it works
- Academy Wing room (Stage 7) has 3 slots (+2 with upgrades).
- **Youth Tryouts** every 6 h: 5 prospects appear (age 15–17, OVR 25–45, Potential 50–99 hidden as a star range).
- Scout staff narrows the star range.
- Sign a prospect for a small fee. They train at 1.5× XP but can't play pro matches until OVR ≥ 55 or 7 real days.
- **Promote** to main roster or sell on the [[Transfer Market]].
- Academy league: prospects play auto-sim youth matches for XP and small Fame.

## Payoff
- Homegrown players get trait **Homegrown**: +10% morale, −20% salary forever.
- Achievement chain: promote 1 / 5 / 20 academy players.

## Server / data requirements
- Prospects stored in `Profile.Roster` with `Academy = true`.
- Tryout seed stored per profile per 6 h window (no reroll by rejoin).

## Acceptance criteria
- [ ] Tryouts refresh on 6 h schedule and survive rejoin with same prospects
- [ ] Promotion moves player to bench and applies Homegrown trait

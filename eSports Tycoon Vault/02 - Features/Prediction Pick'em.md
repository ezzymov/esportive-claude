---
tags: [feature, new]
status: idea
priority: P3
stage: 4
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Bracket]]"
roblox_execution_environment: ServerScriptService
---
# Prediction Pick'em (no betting)

## Summary
Free prediction game for spectators during Worlds Live and big tournaments. **Nothing is wagered.** You never spend currency to predict, so it is not gambling.

## Rules
- Before each bracket round, pick the winner of each match (free).
- Correct picks earn **Pick'em Points**. Streaks multiply points (×1.5 at 3, ×2 at 5).
- Points go to a weekly Pick'em leaderboard. Top 10% get a cosmetic badge; everyone gets a small participation crate if they picked all rounds.
- No currency input, no odds-based payouts, no trading of points.

## Why it matters
Gives non-competing players something to do during Worlds Live and keeps the plaza busy.

## Acceptance criteria
- [ ] No code path lets the player spend Cash, Gems or Robux on a pick
- [ ] Points reset weekly

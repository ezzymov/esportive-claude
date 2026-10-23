---
tags: [feature, new]
status: idea
priority: P2
stage: 4
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Trait Library]]"
  - "[[Data Schema]]"
affected_ui: []
roblox_execution_environment: ServerScriptService
---
# Player Life Events (drama)

## Summary
Random, light events that make roster players feel like people. Each event is a choice card with 2–3 options and clear trade-offs. Max 1 event per 20 min of play so it never nags.

## Event list (starter pool)
| Event | Trigger | Choices |
|---|---|---|
| Contract demand | Player OVR rose 10+ since signing | Pay +30% salary · Promise playtime (morale +) · Refuse (morale −20, may leave in 1 week) |
| Poach offer | Rival offers for your best player | Accept cash (sell at 1.5× value) · Counter (salary +20%) · Ignore |
| Burnout | Fatigue > 80 for 2 days | Force rest 2 h · Push through (−stats, risk "Burned Out" trait) |
| Streamer dream | Player has Streamer trait, Followers milestone | Let them stream (followers +, training −) · Keep focused |
| Birthday | Random | Throw a party ($, morale +15 team-wide) · Skip |
| Hot streak | 3 MVPs in a row | Hype post (clip views +) · Keep humble (chemistry +) |
| Homesick | Long bootcamp | Send home 1 h · Video call (small morale +) |
| Viral moment | Clip > 100k views | Merch drop with their face · Ignore |
| Mentor | Veteran + rookie on roster | Pair them (rookie XP +25% for a week) · No |

## Traits that interact
- **Team Leader**: fewer negative events team-wide.
- **Tilt-Prone**: more burnout events.
- **Streamer**: unlocks streamer events.
- **Loyal**: never accepts poach offers.

## Rules
- Events never delete a player without warning; leaving takes 1 in-game week with reminders.
- All text is preset. No real-world sensitive topics.

## Server / data requirements
- `Shared/Config/LifeEvents.lua` → `{Id, Weight, Condition(fn name), Choices = {{Label, Effects}}}`
- `Profile.EventCooldownUntil`, `Profile.PendingEvent`

## UI
Choice card modal (portrait, short story text, 2–3 buttons with effect icons).

## Acceptance criteria
- [ ] Events respect 20-min cooldown
- [ ] Each choice applies exactly the effects listed on its button

## Open questions
- Should the player be able to turn events off in Settings? Lean yes ("Calm mode").

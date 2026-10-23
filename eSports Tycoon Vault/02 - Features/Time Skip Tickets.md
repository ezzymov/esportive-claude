---
tags: [feature, economy]
status: designed
priority: P1
stage: 3
updated: 2026-10-21
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Matches & Tournaments]]"
  - "[[Staff & Training]]"
  - "[[Monetization]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Bracket]]"
  - "[[Screen - Staff & Training]]"
  - "[[Screen - Store]]"
roblox_execution_environment: ServerScriptService
---
# Time Skip Tickets

## Summary
A consumable that **finishes a wait instantly**. Tournaments now take real time between rounds ([[Matches & Tournaments]] → *Tournament timing*), training runs on timers ([[Staff & Training]]), and so do a few other systems. A Time Skip Ticket fast-forwards **one** of those timers.

Tickets are earned for free all the time and can also be bought. They save time; they never change results.

## Ticket sizes
| Ticket | Skips up to | Look |
|---|---|---|
| **Quick Skip** | 15 min | Blue ticket |
| **Hour Skip** | 1 h | Purple ticket |
| **Big Skip** | 4 h | Gold ticket |

- One ticket = one timer. If the timer has less time left than the ticket, the rest is **not refunded**. The skip button always suggests the **smallest ticket that covers it**, and shows "Quick Skip covers 9:12 of 9:12 ✓".
- Not enough for a long timer? You can use several tickets on the same timer, one after another (e.g. two Hour Skips on a 1 h 40 min wait).
- Gems still work as a fallback: `ceil(minutesLeft / 10)` Gems ([[Staff & Training]]). Tickets are the cheaper, more common route.

## What tickets can skip
| Timer | Skippable | Notes |
|---|---|---|
| **Tournament: wait for your next match** | ✅ | Resolves the round now (including other bracket matches). Result is the same as it would have been (deterministic seed, see *Fairness*) |
| **Tournament: registration window** | ✅ | Starts round 1 now; AI fills empty slots |
| **Training session** | ✅ | [[Staff & Training]] |
| **Scouting / Potential reveal** | ✅ | |
| **Fatigue recovery** | ✅ | Players fully rested |
| **Academy youth growth tick** | ✅ | [[Academy & Youth]] |
| **Sponsor contract cooldown** | ✅ | Next offer arrives now |
| **Season / Ranked / daily reset** | ❌ | Shared calendar for everyone |
| **Playtime gifts, free crate timer** | ❌ | Rewards for playing/returning; skipping them would turn tickets into free crates |
| **Live events, Worlds Live, Admin Abuse Events** | ❌ | Shared with other players |
| **Market listing / trade cooldowns** | ❌ | Anti-abuse timers |

## Sources
| Source | Tickets |
|---|---|
| Quests: daily quest chest | 1 Quick Skip / day |
| Daily streak | Day 3: Quick Skip · Day 7: Hour Skip |
| Circuit Pass free track | Quick/Hour Skips every few tiers; premium track adds Big Skips |
| Achievements | Hour Skips on stage-boss achievements |
| Tournament placement | Top 4: Quick Skip; win: Hour Skip (so winning one tournament speeds up the next) |
| [[Admin Abuse Events]] | **Time Warp** gives everyone a ticket |
| Codes | Common reward for update codes |
| Gems (Shop → Speed tab) | Quick 15 💎 · Hour 50 💎 · Big 160 💎 |
| Robux (Store → Boosters) | Packs, see below |

Free path rule ([[Monetization]]): an active daily player earns roughly **1 Quick Skip a day + 1 Hour Skip a week** without paying. Tickets are speed, never power.

### Robux packs (dev products)
| Pack | Contents | Price idea (R$) |
|---|---|---|
| Skip Starter | 5 Quick Skips | 39 |
| Hour Bundle | 3 Hour Skips | 79 |
| Big Bundle | 3 Big Skips + 2 Hour Skips | 249 |
Replaces the separate "Instant Training" product in [[Microtransaction Ideas]]. Prices follow the no-pressure rules: no countdown, no "only today".

## Fairness
- **Same result, just sooner.** Tournament rounds use a seed fixed at registration, and your lineup snapshot is taken when the round **locks**. Skipping moves the lock time to now: your current lineup plays with the same seed, so you can't skip-and-reroll for a better result.
- **Ranked can't be skipped** (no timers there anyway), so tickets never touch Ranked.
- Skipping never grants extra rewards; it just gets you to them faster.
- Tickets are **untradeable** (keeps them out of the trade economy) and kept on rebirth.

## Player-facing UI
- Every skippable timer shows a small **⏩ Skip** button next to it. Tap → sheet with your tickets (count per size), the suggested one highlighted, and the Gem price as a fallback.
- [[Screen - Bracket]]: "Next match in 12:40 · ⏩ Skip" under your next opponent.
- Inventory → Boosters tab lists ticket counts ([[Screen - Main HUD]] → Inventory).
- Using a ticket plays a fast-forward whoosh and the timer spins down in 0.6 s.

## Server / data requirements
```lua
Profile.Inventory.TimeSkips = { Quick = 0, Hour = 0, Big = 0 }

-- Shared/Config/TimeSkips.lua
TimeSkips = {
  Sizes = { Quick = 900, Hour = 3600, Big = 14400 },
  Skippable = { "TournamentWait", "TournamentRegistration", "Training", "Scouting", "Fatigue", "AcademyTick", "SponsorCooldown" },
}
```
| Remote | Args | Server checks |
|---|---|---|
| TimeSkip/Use | timerKind, timerId, size | timer kind in `Skippable`, timer belongs to player and is still running, player has a ticket of that size, not mid-match. Reduces the timer's `EndsAt` by the ticket size (min now). Rate limit 4/s |
- Timers are stored as absolute server times (`EndsAt`), so a skip is just `EndsAt = max(now, EndsAt - size)` followed by the owning service's normal "timer finished" path.
- Analytics: `time_skip_used { kind, size, secondsSaved, wasted }` to tune ticket sizes.

## Acceptance criteria
- [ ] A Quick Skip on a 10-min training finishes it instantly; leftover time isn't refunded
- [ ] Skipping a tournament wait resolves the round with the same seed; result matches an un-skipped run of the same lineup
- [ ] Unskippable timers (free crate, season reset, events) show no Skip button and reject the remote
- [ ] Tickets can't be traded
- [ ] A daily player gets ~1 Quick Skip/day for free

## Open questions
- Should the Founder's solo jobs (Tech Fix) have a timer worth skipping, or stay timer-free?
- Add a 24 h "Day Skip" for late-game Worlds waits? Lean no: Big Skips stack.

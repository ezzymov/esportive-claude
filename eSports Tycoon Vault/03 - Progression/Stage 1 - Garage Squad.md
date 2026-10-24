---
tags: [stage/1]
---
# Stage 1 — Garage Squad (First-Time User Experience)

**Goal:** the player understands the loop and feels momentum inside 15 minutes. **You start as the only player on your team** ([[Founder (You)]]) and earn your own money before hiring anyone. Opening: [[Intro Cutscene]].

## Beat sheet
| Min | Beat | Player action | Reward |
|---|---|---|---|
| 0:00 | **[[Intro Cutscene]]**: dropped off by Aunt Dee at your garage | Watch (skip after 5 s) | — |
| 0:50 | **Name your team** + pick your Founder role ([[Team Identity]]) | Type/randomize name, tag, role | Bedsheet banner with your team name hangs on the garage door |
| 1:30 | **Set up your PC**: plug 3 cables, press Power On | Short drag minigame | Founder card created ("You · OVR 30"), your station starts earning while you sit |
| 2:30 | **First Pickup Game**: you + 4 random pugs | Watch the cutscene (your avatar with your name), optional Clutch Moment | $150 on win (pity: guaranteed win), first Fame |
| 4:00 | **Aim Trainer** cabinet flickers on in the corner | Play one round | Cash + Founder Aim XP |
| 5:30 | **Tech Fix job**: a neighbor drops off a broken PC | Repair minigame | $200 |
| 6:30 | **First upgrade**: better mouse for your own desk | Buy pad ($150) | Founder stat bump shown on card |
| 7:30 | **Buy 2nd desk** (pad appears at $300) | Walk to pad | Empty desk with a "Hiring" sign |
| 8:30 | **Hire your first teammate**: free agent board unlocks; Rusty is the featured hire ([[Key Players]]) | Hire ($250) | Rusty intro mini-scene, his station earns even when you walk away |
| 10:00 | **Pickup Game with 2 owned + 3 pugs** | Watch | Win → free Rookie Crate |
| 11:00 | **First unbox** ([[Case Unboxing]]) | Open crate | Guaranteed Rare player |
| 12:30 | Buy 3rd desk, seat the Rare player | Walk to pad | Income ↑, garage looks busier |
| 14:00 | Roster 3/5, promotion banner: "Café Rookies" | — | Unlock Stage 2 |

## Why start solo
- Gives the player a personal stake: their own avatar is on the team and in the clips.
- Teaches every money source (station, matches, minigames, jobs) before the roster takes over.
- Makes the **first hire** feel like a real milestone instead of a free handout.
- Keeps the "garage to glory" story honest: you really did start with nothing.

## Pacing guardrails
- Player should have $250 for the first hire by **~8 min** even if they only sit at the desk and play the guaranteed Pickup Game.
- If the player is slow (no hire by 12 min), Aunt Dee texts: "Your friend from school is looking for a team…" and Rusty's price drops to $100.
- First unbox by **~11 min** ([[Progression Guide]] pacing rule).
- **Guaranteed wins** (M1): the first ever Pickup Game is a pity win. Before the Rookie Crate is earned, a team Pickup Game after one team-game loss is also a guaranteed win, so the crate can't slip far past ~11 min.

## Playtest — M1 build (2026-10-23)
Scripted test run in Studio (bot using the real remotes, walking and pads, with human-length pauses for each match, minigame and popup; it sat at the desk and played a Pickup Game whenever the cooldown allowed while saving up). A first-time human who explores will be slower, so these are the **fast end**.
| Beat | Sheet | Actual |
|---|---|---|
| Intro (watched fully) | 0:52 | 0:58 |
| Name team | 0:50 | 1:37 |
| PC setup / sit | 1:30 | 2:15 |
| First Pickup win (pity) | 2:30 | 3:11 |
| Aim Trainer | 4:00 | 3:56 |
| Tech Fix | 5:30 | 4:18 |
| Better mouse / 2nd desk | 6:30 / 7:30 | 4:18 / 4:24 |
| Hire Rusty | 8:30 | 5:36 |
| Team Pickup win → crate | 10:00 | 7:46 (one loss, then the crate pity win) |
| First unbox (Rare) | 11:00 | 7:59 |
| 3rd desk + promotion | 12:30 / 14:00 | 8:11 |

- Guardrails: pity win ✓, unbox at 7:59 ✓, 12-min Rusty drop ✓ (tested with the `PlayTime` dev hook). Sit-only player affords mouse + desk + Rusty at ≈ 8:40 (calculated).
- An efficient player has ~$600 by 4:20 (gift 50 + pickup 150 + aim ~50 + tech 200 + desk income), so purchases land well before the sheet's times.
- **Pacing knobs** if human playtests also come in under ~12 min: Pickup Game cooldown (75 s), 3rd desk price ($500), or unlocking the mouse pad after Tech Fix instead of after the first win. Retune after a human playtest, not from the bot alone.

## Tutorial rules
Full design: [[Tutorial & Onboarding]].
- Max 1 popup at a time, always with an arrow; skippable after the first run.
- Never lock the camera for more than 5 s **outside** the intro cutscene (the intro is skippable).
- Aunt Dee's texts (phone popup) give hints when the player stalls for 60 s.

## Success metrics
- ≥90% finish or skip the intro · ≥80% win the first Pickup Game · ≥70% make the first hire · ≥65% reach first unbox · ≥50% reach Stage 2 · D1 retention ≥25%

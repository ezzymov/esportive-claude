---
tags: [feature, system, stage/1]
status: idea
priority: P0
stage: 1
system_type: UIController
engine_layer: ClientController
dependencies:
  - "[[Tutorial Voice Script]]"
  - "[[Intro Cutscene]]"
  - "[[Stage 1 - Garage Squad]]"
  - "[[Services & Remotes]]"
  - "[[Analytics & Metrics]]"
affected_ui:
  - "[[Screen - Main HUD]]"
  - "[[Screen - Team Creator]]"
  - "[[Screen - Roster]]"
  - "[[Screen - Case Opening]]"
  - "[[Screen - Tech Shop]]"
roblox_execution_environment: StarterPlayerScripts
---
# Tutorial & Onboarding

> Brainstorm draft (2026-10-20). Nothing here is locked. See **Open questions** at the bottom.

## Summary
One tutorial system that runs the whole game's teaching, in three layers:
1. **Guided FTUE**: the Stage 1 objective chain from [[Intro Cutscene]] to the "Café Rookies" promotion ([[Stage 1 - Garage Squad]]).
2. **Unlock tutorials**: a short 1–3 step lesson the first time each new system opens in Stages 2–10 ([[Stage Beat Sheets 2-10]]).
3. **Help on demand**: a phone app where the player can replay any lesson or ask for a hint.

The core idea: **you learn by doing, not by reading.** Every step is one action, with one arrow and one short line of text. The guide is a character the player already met in the [[Intro Cutscene]], not a nameless UI.

## Guide: Aunt Dee (decided 2026-10-20)
**Aunt Dee is the only tutorial voice.** She teaches everything: where to go, how systems work, and hints when the player is stuck. One voice keeps it clear and personal.
| Who | Channel | Role in the tutorial | Tone |
|---|---|---|---|
| **Aunt Dee** | Phone texts (popup at bottom right); phone **calls** for stall help | All instructions, all lessons, all hints | Warm, teasing, not a gamer ("I don't know what a 'K/D' is but yours is bad") |
| **"Hype" Hector** | Shout banner | Celebrates milestones only (first win, first hire, first unbox). **Never gives instructions** | Loud, never blocks input |
| **Dr. Data** | — | Not part of the tutorial. Stays in matches, case reveals and the "?" screen cards ([[Caster & Commentary]]) | — |

Dee's lines should explain systems in plain words, as if she's figuring it out with you ("So gear makes your stats go up? And stats win games? Buy the mouse, then.").

## Voiceover (decided 2026-10-20)
**Every tutorial line is fully voiced**, including Dee's texts, her stall calls, the "?" cards and Hector's milestone shouts. Lines are **recorded manually** by the team.
- Each line has a stable id (`TUT_SECOND_DESK`) that links its caption text and its audio asset, so a line can ship with text first and get audio later without code changes.
- Captions always show alongside the audio (mobile, muted players, accessibility).
- A new line plays only when the previous one finishes or is dismissed (no overlap), which matches the one-popup-at-a-time rule.
- Settings: a **Voice volume** slider separate from Music and SFX.
- Recording list: [[Tutorial Voice Script]] (id, speaker, line, direction, status, asset id).

## Visual reference (Build a PC)
![[BuildAPC_Tutorial_chevron-path_build-first-pc.png]]

What to copy from it:
- **Chevron trail on the ground** (white `>` arrows in a row) from the player to the target. Simpler and more readable than a beam.
- **Big outlined banner, top right**, one short goal in chunky white text with a dark stroke ("Build your first PC!"). Same spot every step, so the eye learns where to look.
- **Floating reward text** above the object when the player earns something (`+2/step`, small, bright, outlined). Shown at the source, not in a popup.
- **Clean ground**: no extra markers beside the path. The target has one highlight, nothing else.

Our version: chevrons in the team color, banner text from `Lines.lua`, reward text in green for cash and gold for Gems.

## Teaching toolkit
| Tool | What it is | When to use |
|---|---|---|
| **Objective tracker** | Top-left pill: one current goal + progress (`Earn $250 · $180/250`) | Always on during the FTUE, can be collapsed |
| **Goal banner** | Big outlined text, top right ("Build your first PC!"). Same position every step | Every FTUE step. Replaces the tracker text while a step is new (3 s), then the tracker takes over |
| **World arrow** | Chevron trail on the ground from your avatar's feet to the target (see [[#Visual reference (Build a PC)]]), bouncing chevron at the end | Any target in the 3D world (pads, desks, cabinet) |
| **Floating reward** | Small outlined `+N` text that rises from the object and fades (~1 s) | Any time the step or a station pays out |
| **UI pointer** | Animated hand/arrow on a button, with a soft pulse | Any target in the UI (Hire, Open, Buy) |
| **Highlight** | Roblox `Highlight` outline on the target model | Together with the world arrow |
| **Spotlight dim** | Screen dims except for a cutout around one UI element | **Only** for the first time a big screen opens (Roster, Case, Tech Shop). Max 3 in the whole FTUE |
| **Ghost demo** | Translucent hand showing a drag once (cable plug, repair minigame) | Minigames with a gesture |
| **Stall hint** | Escalating help if the player is stuck (see below) | Every step |

## Stall ladder (per step)
| Seconds without progress | What happens |
|---|---|
| 0 | Normal: tracker + arrow |
| 30 | Arrow pulses brighter, target bounces |
| 60 | Aunt Dee texts a hint (from [[Stage 1 - Garage Squad]] tutorial rules) |
| 120 | Dee **calls**: a short phone popup with a "Show me" button that auto-walks your avatar to the target (`Humanoid:MoveTo`) |
| 12 min with no hire | Pacing guardrail: Rusty's price drops to $100 (already in Stage 1 notes) |

The clock pauses while a menu is open or a match is playing, so we don't nag players who are busy.

## Guided FTUE — step list
Matches the [[Stage 1 - Garage Squad]] beat sheet. Each step completes on a **server event**, not on a button press.

| # | Step id | Goal shown | Guide line (draft) | Completes when | Reward |
|---|---|---|---|---|---|
| 1 | `NameTeam` | Name your team | Dee: "Every team needs a name. Make it loud." | `TeamCreated` (typed **or** auto-name accepted) | Banner on the garage |
| 2 | `PowerOn` | Set up your PC | Dee: "Plug it in. Red cable, red port. I'm not a tech." | `StationPowered` | Founder card reveal |
| 3 | `SitDesk` | Sit at your desk | Dee: "Sit down. Apparently sitting makes money now." | Seated 5 s | $1/s starts, cash ticker highlighted |
| 4 | `FirstPug` | Play a Pickup Game | Dee: "Some randoms need a fifth. Go." | `PickupFinished` (guaranteed win) | $150, first Fame, Hector shout |
| 5 | `AimTrainer` | Try the arcade cabinet | Dee: "That thing still works? Huh." | One run | Cash + Aim XP, card shows "+Aim" |
| 6 | `TechFix` | Fix the neighbor's PC | Dee: "Mrs. Park's PC died again. She pays." | `TechFixDone` | $200 |
| 7 | `FirstUpgrade` | Buy a better mouse | Dee: "Better mouse, better aim. Even I get that." | Mouse purchased | Card stat delta animation |
| 8 | `SecondDesk` | Buy a 2nd desk ($300) | Dee: "You can't carry the team alone. Literally." | Desk bought | "Hiring" sign |
| 9 | `FirstHire` | Hire your first teammate | Dee: "Your friend Rusty's looking for a team…" | `PlayerHired` | Rusty intro mini-scene |
| 10 | `TeamPug` | Pickup Game with your squad | Dee: "Two of you now. Go win something." (Hector shout on win: "The dynasty begins!") | Match won | Free Rookie Crate |
| 11 | `FirstUnbox` | Open the crate | Dee: "If it glows blue, that's good. I think." | `CaseOpened` (Starter Crate) | Guaranteed Rare |
| 12 | `SeatRare` | Seat your new player | Dee: "Third desk's on me. Kidding. $X." | 3 players seated | Income up |
| 13 | `Promotion` | — | Hector: "Café Rookies, here we come!" | Fame ≥ 100 | Stage 2 cinematic, "Garage Graduate" badge |

**Out-of-order rule:** when a step starts, the server checks whether it's already done (for example, the player bought the 2nd desk early). If so, it completes at once and moves on. The player never has to redo something.

**Free roam:** the tracker never locks movement or the menus, and nothing is a hard lock.

**Team name (decided 2026-10-20):** the Team Creator opens with a ready-made **auto-name** (e.g. "Garage Squad" + random tag) that the player can accept with one tap or replace. Renaming is **free until Stage 2**; Dee reminds them once before the promotion ("Last chance to change that name for free!"). From Stage 2 on, renaming costs **39 R$** ([[Microtransaction Ideas]] → Name Change). Every name goes through TextService filtering.

## Unlock tutorials (Stages 2–10)
A small lesson (1–3 steps) plays the first time each system unlocks. Same toolkit, all from Aunt Dee, no stall calls (only an arrow + a Dee text at 60 s).

| Unlock | Steps |
|---|---|
| Reaction Test cabinet (S2) | Play 1 round → see "+Reflexes" on the Founder card |
| Tech Shop (S2) | Open shop → buy a Budget mouse → see the stat delta |
| Rookie Crate timer (S2) | Point at the timer → "free every 30 min" |
| 5-man roster / role synergy (S2) | Open Roster → drag a player into a role slot |
| Scrims + Ladder (S3) | Open the scrim board → play 1 → see ladder points |
| Training Center (S3) | Queue 1 training |
| Clip Studio (S4) | Trim 1 clip → match a trending tag → upload |
| Sponsors (S4) | Read 1 offer → sign |
| Staff (S5) | Hire the free Coach → set 1 tactic |
| 2nd game title (S5) | Assign 5 players to Tower Clash |
| Transfer list (S5) | Sell 1 duplicate |
| Streaming Booth, Merch (S6) | Assign a streamer / design a drop |
| Academy (S7) | Sign 1 prospect |
| Arena (S8) | Set ticket price |
| Rebirth (S10) | Legacy screen walkthrough (3 cards) |

As the team grows, Dee's texts can get prouder and less confused (she's "learning esports" with you), which gives her a small story arc across the stages.

Each unlock tutorial = **1 config entry**, so new features ship with their lesson.

## Help on demand
- **Phone → "Dee's Tips" app**: a list of every lesson the player has seen, with a "Replay" button (cosmetic only, no rewards a second time).
- **"?" chip** on every big screen header: opens a single Aunt Dee card explaining that screen.
- **Settings → Tutorial hints**: Full / Light (no stall calls) / Off (lessons only on request).

## Skipping
- **Intro cutscene skip ≠ tutorial skip.** Skipping the cutscene drops you into step 1 as normal.
- After step 2 there's a small **"I've played before"** link on the tracker. Tapping it:
  - Asks for confirmation once.
  - Grants every remaining **guaranteed** reward that matters to the economy (guaranteed Rare from the Starter Crate, Rusty available at $250). Nothing else is free: you still earn the cash.
  - Turns on Light hints.
- Players who reach a step's condition on their own get the reward anyway, so skipping is never a loss and never a big gain.

## Rewards
- Small rewards per step are already on the beat sheet; the tutorial **doesn't add extra cash** (that would break the 8-min-hire pacing in [[Balance Tables]]).
- On completion (decided 2026-10-20): "Garage Graduate" achievement ([[Achievements & Collections]]) + **25 Gems + a cosmetic**. Cosmetic idea: the taped-up mouse from the intro as a desk trophy (amount and item still to tune).

## Server / data requirements
```lua
-- Merge with Profile.Ftue from [[Founder (You)]]
Profile.Tutorial = {
    Version = 1,              -- bump when the FTUE changes; old players aren't re-taught
    Step = "PowerOn",         -- current Guided FTUE step id, nil when done
    Completed = { NameTeam = 1792542581 }, -- step id → unix time
    Seen = { TechShop = true },            -- unlock tutorials seen
    Skipped = false,
    HintLevel = "Full",       -- Full | Light | Off
    StarterRoll = nil,        -- the Starter Crate result, rolled ONCE and saved
}
```
- `TutorialService` (server): listens to gameplay events (`TeamCreated`, `PlayerHired`, `CaseOpened`…), moves steps forward, grants rewards once, fires `TutorialStepChanged` to the client.
- `TutorialController` (client): draws the tracker, arrows, highlights, phone texts. **Holds no state** besides the stall timer.
- Config: `ReplicatedStorage/Shared/Config/Tutorial/Steps.lua`
  ```lua
  { Id = "SecondDesk", Guide = "Dee", Line = "TUT_SECOND_DESK", Target = "Pad_Desk2",
    CompleteOn = "DeskBought", Check = function(profile) return #profile.Desks >= 2 end,
    HintAfter = 60, Reward = nil }
  ```
  `Line` is a key into `Shared/Config/Tutorial/Lines.lua` → `{ Speaker, Text, SoundId }`. `SoundId` can be nil until the line is recorded (caption only), and text keys keep translation easy.
- Remotes ([[Services & Remotes]]): `Tutorial.SkipFtue` (one-shot, rate-limited), `Tutorial.SetHintLevel`, `Tutorial.ReplayLesson` (cosmetic only). Steps are **never** completed by the client.

## UI screens
- Objective tracker + phone popup live on [[Screen - Main HUD]]
- Spotlight moments on [[Screen - Roster]], [[Screen - Case Opening]], [[Screen - Tech Shop]], [[Screen - Team Creator]]
- New: Phone "Dee's Tips" app (needs a screen note)

## Dependencies
- [[Intro Cutscene]], [[Founder (You)]], [[Team Identity]], [[PC Setups]], [[Player Hiring]], [[Case Unboxing]], [[Playable Games]]
- [[Caster & Commentary]] (portraits + line system can be shared)
- [[Analytics & Metrics]] (FTUE funnel)

## Edge cases / exploit risks
| Case | Handling |
|---|---|
| Rejoin to reroll the guaranteed Rare | `StarterRoll` is rolled once on the server and saved before the crate opens |
| Disconnect mid-step | Step state is saved; on rejoin the tracker resumes, minigames restart from the beginning |
| Player spends all cash before the hire | The pacing guardrail (Rusty $100 at 12 min) still applies. Dee: "Spent it all? Classic." |
| Player wanders off the plot | Arrow turns into an edge-of-screen pointer: "Back to the garage" |
| Visitors on your plot during the FTUE | Arrows and popups are local; visitors don't see them. Trading/visits stay locked until Stage 4 anyway |
| Guaranteed Pickup Game win farmed | Guarantee only for `FirstPug` (flag on profile), not on rejoin |
| Existing players after an FTUE update | `Version` check: players past the old step list are marked complete |
| Mobile | UI pointer targets the actual on-screen buttons; the world arrow uses the edge pointer when the target is off-screen; text ≤ 12 words for small screens |

## Analytics
Add to [[Analytics & Metrics]]: `TutorialStepStarted(step)`, `TutorialStepCompleted(step, seconds)`, `TutorialStallHint(step, level)`, `TutorialSkipped(atStep)`, `LessonReplayed(id)`. The **time per step** chart is the main tuning tool: any step with a median > 90 s needs a rework.

## Acceptance criteria
- [ ] A new player is guided from control handover to Stage 2 without reading more than 12 words at once
- [ ] Only one popup / one arrow on screen at a time
- [ ] Every step completes from a server event; completing out of order works
- [ ] Rejoining mid-FTUE resumes at the same step with no duplicate rewards
- [ ] "I've played before" skip keeps the guaranteed Rare and doesn't hand out extra cash
- [ ] Every unlock in Stages 2–10 has a config entry and plays once
- [ ] Lessons can be replayed from the phone app
- [ ] Hint level setting works (Full / Light / Off)

## Decisions
| Date | Decision |
|---|---|
| 2026-10-20 | Aim Trainer is a **Stage 1** unlock. Stage 2's new toy becomes the **Reaction Test** cabinet (proposed) |
| 2026-10-20 | **Aunt Dee** is the only tutorial guide; Hector only celebrates; Dr. Data stays out of the tutorial |
| 2026-10-20 | Team gets an auto-name; renaming is free until Stage 2, then costs a small Robux price |
| 2026-10-20 | Completion reward = Gems + a cosmetic |
| 2026-10-20 | All tutorial lines are fully voiced; recorded manually |
| 2026-10-20 | Passive income **keeps ticking** during spotlights and popups (nothing in the tutorial pauses the economy) |
| 2026-10-20 | Robux boosts during the FTUE (e.g. 2× cash) **don't skip steps**; the player goes through the same steps, just faster |
| 2026-10-20 | Rename after Stage 2 costs **39 R$** |

## Open questions
1. Is the **Reaction Test** the right Stage 2 new toy, or do you want something else there?

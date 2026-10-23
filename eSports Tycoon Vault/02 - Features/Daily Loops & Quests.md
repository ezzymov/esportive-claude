---
tags: [feature]
status: idea
priority: P1
stage: 1
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Data Schema]]"
  - "[[Services & Remotes]]"
affected_ui:
  - "[[Screen - Quests]]"
roblox_execution_environment: ServerScriptService
---
# Daily Loops & Quests

## Summary
Reasons to come back every day and a steady drip of short goals. One shared **objective engine** powers quests, sponsor objectives, achievements and battle-pass tasks.

## Daily login streak
| Day | Reward |
|---|---|
| 1 | $ (scaled to stage) |
| 2 | 5 Gems |
| 3 | Rookie Crate |
| 4 | 1 h 2× income booster |
| 5 | 10 Gems |
| 6 | Pro Crate |
| 7 | Streak Chest (Epic+ guaranteed item) |
- Missing a day drops streak by 2 days, not to 0 (soft reset, less punishing).
- Streak shown as a calendar strip on join.

## Daily quests (3 per day)
- Rolled from a pool weighted to the player's stage. One easy, one medium, one hard.
- Examples: Collect $X · Win 2 scrims · Open 1 case · Train any stat · Upload a clip · Score 80+ in Aim Trainer · Visit a friend's HQ · Equip a new part.
- Reward: Cash + Season XP; completing all 3 = bonus Gems.
- 1 free reroll per day.

## Weekly challenge
One bigger goal (e.g. "Win a Local Cup", "Get 10k clip views"). Reward: Pro/Elite Crate.

## Season Pass ("Circuit Pass")
- 30 tiers per season (~4 weeks). Free track + premium track (Robux).
- Season XP from quests, matches, clips.
- Free track must include meaningful rewards (crates, gems); premium = cosmetics, boosters, exclusive jersey.

## Playtime rewards
Session-based gifts. The player sees one **Gift** button on the HUD with a countdown to the next gift, always visible so the next goal is never hidden.

| Session time | Reward | Notes |
|---|---|---|
| 5 min | $ (scaled to stage) | First gift arrives during the FTUE, so it doubles as a teaching beat ("Dee: Free money. Don't spend it all.") |
| 15 min | 10 Gems | |
| 30 min | Rookie Crate | Also the repeating timer: a free Rookie Crate every 30 min |
| 60 min | 1 h 2× income booster | |

- Claim from the Gift button or the Quests screen. Unclaimed gifts stay until claimed (no expiry).
- Timer counts only while the player is in a server and not AFK (no input for 5 min pauses it).
- Countdown shows on the HUD gift icon as `mm:ss`. No "hurry" text.
- Playtime is saved to `Profile.Playtime` so leaving and rejoining does not reset the gift ladder.

## Offline earnings
- Offline earnings popup on join (cap 4 h, +Manager, 8 h with gamepass).

## Reward feedback
- Claiming any reward plays a short chime, a `+N` floating reward on the HUD ([[Tutorial & Onboarding]] → Floating reward), and a counter tick on the currency that changed.
- Locked gifts look dim with a lock icon. Ready gifts pulse. Claimed gifts show a check.

## Objective engine
```lua
Objective = { Type = "WinMatch" | "OpenCase" | "CollectCash" | ..., Target = 3, Filter = { MatchType = "Scrim" } }
```
Server fires `ObjectiveService:Record(player, type, amount, context)` from every relevant service. Quests, sponsors and achievements subscribe.

## UI screens
- [[Screen - Quests]]

## Acceptance criteria
- [ ] New day rollover at 00:00 UTC rolls fresh quests
- [ ] Progress updates live on HUD tracker
- [ ] Streak survives rejoin and handles missed day correctly

## Open questions
- Local midnight vs UTC reset? UTC is simpler and fair across servers.

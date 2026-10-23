---
tags: [system]
---
# Match Simulation

Server-authoritative match engine. Server decides every round, then streams a compact event list to clients, who play the cinematic. Feeds [[Matches & Tournaments]], [[Clips & Traction]], [[Caster & Commentary]].

## Inputs
- Both rosters (5 active players with stats, role, trait, morale, fatigue)
- Station bonuses (parts), staff (Coach, Analyst), tactic, home-field bonus
- Each player's **gear stats** from [[Accessories]] + stickers (`GearService:GetGearStats`, snapshot at match start)
- **Gear Mode**: `"Full"` or `"Pure"` (below)
- Game title (sets stat weights, see [[Playable Games]])

## Gear Mode
| Mode | Used by | Effect on the formulas below |
|---|---|---|
| **Full** | Tournaments, seasons, Scrim and Friend Scrim (default) | Everything counts |
| **Pure** | **Ranked Ladder (always)**; Scrim / Friend Scrim when the "Pure skill" toggle is on | `gearStat_i = 0`, `partMult = 0`, `coachBonus = 0`, `homeBonus = 1`. Stats, traits, morale, fatigue, chemistry, tactic, synergy and maps still count |
The server sets the mode from the match type and stored challenge settings. The client never sends it for Ranked. Details: [[Accessories]] → *Gear Mode*.

## Team Power
```
gearStat_i   = min(accessoryBonus_i + stickerBonus_i, 12)   -- 0 in Pure mode; see [[Accessories]]
PlayerPower  = Σ((stat_i + gearStat_i) × titleWeight_i) × (1 + partMult) × moraleMult × fatigueMult × traitMult
TeamPower    = Σ PlayerPower × chemistry × (1 + coachBonus) × tacticMult × homeBonus × synergy × MapFit × MapMastery
-- MapFit 0.95–1.05, MapMastery 1.00–1.05, see [[Maps & Map Pool]]
moraleMult   = 0.85 + morale/100 × 0.3          -- morale 0–100 → 0.85–1.15
fatigueMult  = fatigue > 70 and 0.9 or 1
chemistry    = 1 + min(matchesTogether, 50) × 0.002 -- up to +10%
synergy      = 1.05 if all 5 roles covered else 1
```

## Round resolution (best of N rounds, e.g. first to 13 for Aim Arena)
```
pRound = 1 / (1 + 10^((PowerB - PowerA) / 400 × k))   -- Elo-style, k tunes upset rate
pRound = clamp(pRound, 0.08, 0.92)                    -- always a chance
momentum: winning 3+ rounds in a row gives +3% pRound next round (max +9%)
```
- Each round also picks: round MVP (weighted by Aim/Clutch), kill count per player, and any **Clip Moment**.
- Final round "Clutch Moment": optional player input minigame can add up to +10% pRound (see [[Playable Games]]).

## Clip Moment triggers
| Moment | Condition | Base quality |
|---|---|---|
| Ace | One player gets 5 kills in a round | 90 |
| Clutch | Last player alive wins vs 2+ | 75 + 5 per extra enemy |
| Comeback | Win match after trailing by 5+ rounds | 85 |
| Upset | Win vs team with 1.5× power | 80 |
| Flawless | Win round with 0 deaths | 50 |
| Record | Player personal best kills | 60 |

## Output (sent to client)
```lua
MatchResult = {
  MatchId, Teams = {A, B}, Winner, Score = {13, 9},
  Rounds = { {Winner = "A", MVP = id, Kills = {...}, Event = "Clutch"}, ... },
  MapId = "NeonDocks",
  ClipMoments = { {Round = 17, Type = "Ace", PlayerId = id, Quality = 90, Seed = 48213, Context = {...}} },
  -- each ClipMoment becomes ClipData for the [[Clip Cutscene System]]
  Rewards = { Cash, Fame, XP = {[id] = n} },
}
```
Each player entry also carries `MatchRating` (see [[Skill Levels & Ratings]]). Payload kept < 8 KB. Client plays at 1 round per 2–3 s with a **Skip to result** button (rewards already granted server-side).

## Tuning targets
- Equal power: 50% win rate.
- 20% more power: ~70% win rate.
- 2× power: ~92% (floor 8% upset).
- Same stats, full gear vs no gear (Full mode): ~65–70%. Same matchup in Pure mode: 50%.
- Average match length watched: 45–75 s.

## Testing
- Command bar script `MatchSim:RunBatch(teamA, teamB, 10000)` prints win rate and average score to verify tuning.

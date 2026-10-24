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

### M1 measured (2026-10-23, `K = 1`, 4,000 matches each)
| Matchup | Target | Measured | Avg score |
|---|---|---|---|
| Equal (170 vs 170) | 50% | 49.0% | 11.3–11.4 |
| +20% (204 vs 170) | ~70% | 70.4% | 12.4–10.0 |
| 2× (340 vs 170) | ~92% | **99.4%** | 13.0–4.3 |
- ⚠ **Open:** the 2× target can't be hit with a per-round clamp: even 8% per round almost never adds up to a first-to-13 upset. Options: (a) accept ~99% at 2× and drop the 92% target, (b) add a match-level upset floor (e.g. 8% of matches run with pRound pulled toward 0.5), or (c) a lower K with a softer curve. Equal and +20% are on target.
- M1 implements the Stage 1 subset: PlayerPower uses base stats + accessory gear × Aim Arena title weights (Aim .30, Reflexes .25, Game Sense .15, Teamwork .10, Clutch .10, Consistency .10) × moraleMult; TeamPower adds synergy. No parts, fatigue, traits, chemistry, staff, maps yet.
- Clutch Moment: offered on the first match-point round; a timing tap adds up to +10% pRound on that round only. The server simulates up to that round, waits for the tap (or Skip = 0), then finishes. Rewards are granted when the match resolves, also on timeout (120 s) or when the player leaves.

### M2/M3 build (2026-10-23)
Code: `MatchService/Sim` (engine), `Teams` (AI teams, entries, snapshots), `Tournament`; numbers in `Config/Match`, `Maps`, `AITeams`, `Traits`.
- **PlayerPower** = Σ((stat + gear) × map-adjusted title weight × (1 + trait stat mults)) × (1 + partMult) × moraleMult × fatigueMult × (1 + trait "all stats" mults that hold this round). Map leans are added to the title weights, then re-normalized.
- **TeamPower** = Σ PlayerPower × chemistry (incl. Team Leader +5%) × synergy × MapFit × MapMastery. Coach, tactic and home field stay 1 until staff/arenas exist. Pure mode = no gear, no parts.
- **Trait conditions per round:** match point, trailing by 4+, ahead/behind, first 5 rounds / after, 3 lost rounds in a row, night/morning (UTC hour of the match), finals, scrims. Trait bonus per stat capped at ±30%.
- **Round detail:** winner from pRound, then the winners lose Binomial(4, q) players, q = clamp(0.25 + 0.4 × the loser's pRound, 0.12–0.55). Kill order is shuffled with the round-ending kill last; killers weighted by Aim + Reflexes (Entry ×1.5 on the opening duel). Clutch = the winners' last player standing vs 2+.
- **Clip Moments** (top 6 kept): Ace 90, Clutch 75 + 5 per extra enemy, Flawless 50, Comeback 85 (won after trailing by 5+), Upset 80 (beat 1.5× power), Record 60 (personal best kills). ~2.7–3.4 per match.
- **Match Rating:** 0.45 kills + 0.25 survival + 0.30 impact (opening kills, clutches ×2, 3+ kill rounds), each vs the 10-player average. Damage and assists aren't simulated yet, so their weight moved to these three.
- **Deterministic:** same setup + seed → same match. Tournament rounds resolve later (even offline) and replays regenerate from the stored seed + lineup snapshot; verified in Studio (replayed final = recorded 14–16).
- Clutch Moment input: Pickup Games and scrims. Tournaments take no input (they can resolve while you're offline).
- Payload: plan with rounds up to the Clutch Moment ~5.8 KB, the rest + result ~2.3 KB.

### M2/M3 measured (2026-10-23, 1,000 matches per gap, `Tests.MatchUpsets`)
| Stronger team | Target | `K = 1`, no floor | Upset floor `{ Chance = 0.16, Pull = 0 }` |
|---|---|---|---|
| Equal | 50% | 48.0% | 51.8% |
| +10% | — | 61.2% | 59.8% |
| +20% | ~70% | 73.4% | 69.4% |
| +30% | — | 80.9% | 78.7% |
| +50% | — | 94.0% | 84.9% |
| 2× | ~92% | 100.0% | 91.9% |
| 2.5× | — | 100.0% | 92.1% |
- Option (b) works if it plays 16% of matches as a coin flip (Pull 0): 1 − 0.16/2 = 92% at 2×, and only ~3 points off the +20% case. A half-gap pull (Pull 0.5) barely moves 2× (99%). The floor is in `Config/Match.UpsetFloor`, **off** until the target is decided.

## Testing
- Command bar: `print(require(game.ServerScriptService.Services.MatchService.Sim).Batch(powerA, powerB, 10000))` prints the win rate and average score to verify tuning.
- Full sweep: `require(game.ServerScriptService.Tests.MatchUpsets).Run()` prints the upset rate at 0–150% power gaps, with and without the upset floor.

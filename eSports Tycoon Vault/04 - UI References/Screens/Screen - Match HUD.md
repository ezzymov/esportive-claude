---
tags: [ui]
screen: Match HUD
status: building
---
# Screen - Match HUD

## Purpose
Broadcast-style overlay while a match plays. See [[Match Simulation]] and [[Caster & Commentary]].

## Opened from / closes to
Pre-match screen (lineup, power comparison, tactic picker, rival trash talk) → Match HUD → Post-match results.

## Layout
| Region | Contents |
|---|---|
| Top center | Scoreboard: team logos, tags, score, round number, round timer |
| Top right | Kill feed (last 4 events) |
| Bottom | Caster lower-third: caster portrait, line text |
| Left | Your 5 players: portrait, alive/dead, kills this match |
| Right | Opponent 5 players |
| Center (pop) | Momentum bar when a streak happens; "CLIP MOMENT!" toast with camera icon |
| Bottom right | Speed toggle (1× / 2×) + **Skip** |

## Post-match results
Win/Loss banner, score, MVP card, rewards list (Cash, Fame, XP per player), clip moments captured ("2 clips ready → Edit"), Continue button.

## States
- Clutch Moment minigame: overlay prompt in final round ("Tap the targets!") with 5 s timer; optional, can ignore.
- Upset: special banner "UPSET!".

## Data it reads / remotes it calls
Receives `MatchResult` from `Match/Start`. Calls `Match/ClutchInput(score)` during Clutch Moment.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Server reply | `MatchResult` from `Match/Start` ([[Match Simulation]] → Output): rounds, events, score, MVP, rewards, clip moments, opponent team | Scoreboard, kill feed, player lists, momentum, post-match screen |
| Profile | `Team` (logo, tag, colours), `Roster` (portraits) | Your side |
| Config | `CasterLines.lua` ([[Caster & Commentary]]) | Caster lower-third |
| Profile | `Settings.CasterVol`, `.CasterFreq`, `.ReducedMotion` | Caster frequency, shake |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Speed 1× / 2×, Skip | none | — | — | Local playback of `MatchResult` |
| Clutch Moment taps | ⚠ `Match/ClutchInput` | RE | matchId, score | applied bonus in delta |
| "2 clips ready → Edit" | none | — | — | Opens [[Screen - Clip Feed]] editor |
| Continue | none | — | — | Close to hub |

### State Validation
- Accept clutch input only during its 5-second window, only once per match, and clamp the score to the minigame maximum.
- The HUD replays a result the server already decided. Never derive rewards from the client playback.

---
tags: [ui]
screen: Bracket
status: designed
---
# Screen - Bracket

## Purpose
Show a tournament: who plays whom, your path, prizes. See [[Matches & Tournaments]].

## Opened from / closes to
HUD → Compete → tournament card. Closes to Compete hub.

## Layout
- **Header:** tournament name + logo, prize pool, Fame reward, entry requirement.
- **Bracket tree:** horizontal, left to right rounds. Match boxes show logos, tags, score. Your path glows in team color; eliminated teams dim.
- Mobile: bracket pans/zooms (pinch), auto-centers on your next match.
- **Bottom bar:** next-match status: "Next match in 12:40 · locks in 10:40" + **⏩ Skip** ([[Time Skip Tickets]]), then "Watch next match" when it's played. Scouting button (Analyst), tactic chip. Lineup/gear can change until the lock time.
- **Waiting state:** tournaments take real time ([[Matches & Tournaments]] → *Tournament timing*), so the bar also suggests things to do meanwhile (train, scrim, open cases), and offline results show as a recap.
- **Side panel:** placement rewards table (1st, 2nd, 3–4th, 5–8th).

## States
- Not started: "Register" button, then the registration countdown (+ ⏩ Skip).
- Eliminated: banner "Knocked out in Quarterfinals" + rewards earned.
- Champion: trophy animation + confetti.

## Data it reads / remotes it calls
Reads tournament state. Calls `Match/Start("Tournament", tournamentId)`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Server reply | ⚠ `Match/GetTournament` RF → `{ id, name, prizePool, fameReward, entryReq, rounds[ matches{ teams, score, winner } ], yourNextMatch, state }` | Header, bracket tree, states |
| Config | Prize pools ([[Balance Tables]]) | Placement rewards panel |
| Profile | `Team` (colour, logo), `Roster` + `Stations` (valid lineup), `Stage`, `Currencies.Fame` | Your path glow, entry requirement check |
| Profile | `Staff` (Analyst owned) | Scouting button visibility |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Enter / Play next match | `Match/Start` | RF | "Tournament", tournamentId | `MatchResult` → [[Screen - Match HUD]] |
| Scouting (Analyst) | ⚠ `Match/Scout` | RF | tournamentId, opponentId | opponent summary |
| Tactic chip | ⚠ `Match/SetTactic` | RE | tacticId | state delta |

### State Validation
- The roster is valid (5 active players), the team isn't already in a match, and the 3-second `Match/Start` cooldown has elapsed.
- The entry requirement is met (stage / Fame), the tournament is open, and you're not eliminated.
- Show Scouting only if an Analyst is hired.

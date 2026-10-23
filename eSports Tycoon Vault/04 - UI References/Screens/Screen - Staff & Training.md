---
tags: [ui]
screen: Staff & Training
status: designed
---
# Screen - Staff & Training

## Purpose
Hire/level staff, queue training. See [[Staff & Training]].

## Layout
- Tabs: Staff · Training · Bootcamp.
- **Staff:** 8 role slots as cards (locked silhouettes until unlocked). Each card: portrait, rarity, level stars, effect text, Level Up button (cost), Hire button for empty slots.
- **Training:** queue slots row on top (timer rings, Skip with Gems). Below: pick player → pick stat (6 big buttons with current/Potential) → pick duration (15 m / 1 h / 4 h) showing XP gain and fatigue cost.
- **Bootcamp:** roster preview, cost, duration, expected gains, Start.

## Data it reads / remotes it calls
Reads `Staff`, `Training`, `Roster`. Calls `Staff/Hire`, `Staff/LevelUp`, `Roster/Train`, `Training/Skip`, `Bootcamp/Start`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Staff` (role, rarity, level) | Staff slot cards |
| Profile | `Training` (queue: playerId, stat, endsAt) | Queue timer rings |
| Profile | `Roster` → `Stats`, `Potential`, `Fatigue` | Training picker |
| Profile | `Currencies.Cash`, `.Gems`, `Stage`, `HQ` (Training Center level) | Costs, unlocks, queue slot count |
| Config | Staff roles, level costs, training XP/fatigue per duration ([[Staff & Training]], [[Balance Tables]]) | Effect text, gain preview |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Hire (empty slot) | ⚠ `Staff/Hire` | RF | role | ok / error |
| Level Up | ⚠ `Staff/LevelUp` | RF | role | new level |
| Start training | `Roster/Train` | RF | playerId, stat, duration | ok / error |
| Skip with Gems | ⚠ `Training/Skip` | RF | queueIndex | ok / error |
| Bootcamp Start | ⚠ `Bootcamp/Start` | RF | — | endsAt |

### State Validation
- **Hire / Level Up:** the slot is unlocked, level < 5, and you can afford the cost.
- **Train:** a queue slot is free (1 at Stage 3, up to 5), `Fatigue` < 100, duration ∈ {15 m, 1 h, 4 h}, and the stat is below `Potential`.
- **Skip:** `Gems` ≥ the skip cost for the remaining time.

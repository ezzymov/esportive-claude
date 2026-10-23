---
tags: [ui]
screen: Rebirth
status: designed
---
# Screen - Rebirth

## Purpose
Explain and confirm Franchise Rebirth, then spend Legacy Points. See [[Franchise Rebirth]].

## Layout
- **Step 1 – Legacy summary:** two columns "You keep" / "Resets" with icons; big LP earned number; next region card with modifier.
- **Step 2 – Choose Legend:** roster grid, pick 1 (or 2 with perk).
- **Step 3 – Confirm:** plain sentence "This resets your cash, roster, and HQ. You keep trophies, cosmetics, Gems and 25% of followers." Hold-to-confirm button (2 s).
- **Perk tree:** 5 branches as vertical columns, nodes with rank pips, cost, effect tooltip. Respec costs Gems.

## Data it reads / remotes it calls
Calls `Rebirth/Preview()`, `Rebirth/Confirm(legendIds)`, `Legacy/BuyPerk(perkId)`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Server reply | `Rebirth/Preview` → `{ lpEarned, keeps[], resets[], nextRegion, modifier }` | Step 1 summary |
| Profile | `Trophies` (Worlds won), `Rebirths` | Screen unlock |
| Profile | `Roster` | Step 2 legend grid |
| Profile | `LegacyPoints`, `LegacyPerks`, `LegacyHall`, `Currencies.Gems` | Perk tree, respec cost |
| Config | Perk tree (5 branches, ranks, costs) ([[Franchise Rebirth]]) | Nodes, tooltips |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Open screen | ⚠ `Rebirth/Preview` | RF | — | preview |
| Hold-to-confirm (2 s) | ⚠ `Rebirth/Confirm` | RF | legendIds | new profile state |
| Perk node | ⚠ `Legacy/BuyPerk` | RF | perkId | ok / error |
| Respec | ⚠ `Legacy/Respec` | RF | — | refunded LP |

### State Validation
- Worlds has been won (unlock gate).
- `legendIds` has 1 entry (2 with the perk), and every id is in `Roster`.
- The hold lasted the full 2 seconds. Fire only on completion.
- **Perk:** `LegacyPoints` ≥ cost, prerequisite ranks are met, and the perk isn't at max rank. Respec needs `Gems` ≥ cost.

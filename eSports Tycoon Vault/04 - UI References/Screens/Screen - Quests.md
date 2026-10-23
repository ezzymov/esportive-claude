---
tags: [ui]
screen: Quests
status: designed
---
# Screen - Quests

## Purpose
Daily login, daily quests, weekly challenge, season pass, achievements. See [[Daily Loops & Quests]] and [[Achievements & Collections]].

## Layout
- Tabs: Daily · Pass · Achievements · Collection.
- **Daily:** 7-day streak strip at top (claimed ✓, today glowing). **Playtime strip** under it: four gift tiles (5 / 15 / 30 / 60 min) with a live session countdown to the next one ([[Daily Loops & Quests]] → Playtime rewards). 3 quest rows (icon, text, progress bar, reward, Claim). Reroll button. Weekly challenge card below. Reset timer.
- **Pass:** horizontal scroll of 30 tiers, free row and premium row, current tier marker, XP bar, "Unlock Premium" button.
- **Achievements:** list grouped by category, Bronze/Silver/Gold pips.
- **Collection:** grid with silhouettes, filters by category/rarity, completion %.

## States
Claimable items pulse; HUD Quests button shows badge count.

## Data it reads / remotes it calls
Calls `Quest/Claim(id)`, `Quest/Reroll(id)`, `Pass/ClaimTier(n, track)`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Quests` (id, progress, goal, claimed, rerolledToday) | Daily rows, weekly card |
| Profile | `Streak { Day, LastClaim }` | 7-day strip |
| Profile | `PassTier`, `Purchases` (premium pass), ⚠ `PassXP` | Pass tab |
| Profile | `Achievements`, `Collection` | Achievements / Collection tabs |
| Config | Quest pool, pass rewards, achievement list ([[Daily Loops & Quests]], [[Achievements & Collections]]) | Text, rewards, silhouettes |
| Server time | Daily/weekly reset time | Reset timer |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Claim (quest) | ⚠ `Quest/Claim` | RF | questId | reward |
| Reroll | ⚠ `Quest/Reroll` | RF | questId | new quest |
| Claim (pass tier) | ⚠ `Pass/ClaimTier` | RF | tier, track ("free" / "premium") | reward |
| Claim login streak | ⚠ `Streak/Claim` | RF | — | reward |
| Unlock Premium | `MarketplaceService:PromptGamePassPurchase` | — | passId | grant via `ProcessReceipt` |

### State Validation
- **Quest claim:** `progress ≥ goal` and not already claimed.
- **Reroll:** the quest isn't claimed and today's free reroll is unused (1 per day).
- **Pass claim:** `tier ≤ PassTier`, not already claimed, and the premium track needs the pass in `Purchases`.
- **Streak:** `LastClaim` is before today's reset.

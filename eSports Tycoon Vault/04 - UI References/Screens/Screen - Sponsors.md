---
tags: [ui]
screen: Sponsors
status: designed
---
# Screen - Sponsors

## Purpose
Inbox of offers, active contracts, merch. See [[Sponsors]].

## Layout
- Tabs: Offers · Active · Merch.
- **Offers:** cards with brand logo, tier chip, weekly pay, objectives list, duration. Buttons: Accept · Negotiate · Decline.
- **Negotiate modal:** 3 tone buttons with risk meter.
- **Active:** contract cards with objective progress bars, weeks left, Cancel (confirm with penalty text).
- **Merch:** jersey preview, income/min, "Limited Drop" button with cooldown. Style the merch tab like a real esports webstore: hero banner, "Shop by category" header, product card grid. See [[Sponsors]] → Merch store.

![[ESL-Shop_Merch_counter-strike-hero.png]]
- Jersey preview strip at top showing patch slots filled.

## Data it reads / remotes it calls
Reads `Sponsors`. Calls `Sponsor/Respond(offerId, choice)`, `Sponsor/Cancel(id)`, `Merch/Drop()`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Sponsors` → offers `{ offerId, brandId, tier, weeklyPay, objectives, duration, expiresAt }`, active `{ id, objectives{progress, goal}, weeksLeft, cancelPenalty }`, ⚠ merch `{ incomePerMin, dropEndsAt, dropCooldownUntil }` | Offers / Active / Merch tabs |
| Profile | `Currencies.Followers` | Tier unlocks, slot cap |
| Profile | `Team.Jersey`, `Staff` (Manager) | Patch strip; negotiate risk meter |
| Config | `Sponsors.lua` ([[Sponsors]]) | Brand logos, tiers |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Accept / Decline / Negotiate (tone) | `Sponsor/Respond` | RF | offerId, choice (`accept` / `decline` / `negotiate:Humble\|Confident\|Bold`) | result (Bold may lose the offer) |
| Cancel contract (after confirm) | ⚠ `Sponsor/Cancel` | RF | contractId | penalty applied |
| Limited Drop | ⚠ `Merch/Drop` | RF | — | dropEndsAt |

### State Validation
- **Accept:** the offer hasn't expired and active contracts < slot cap (≤ 6).
- **Cancel:** show the penalty text and require confirmation.
- **Limited Drop:** `dropCooldownUntil` has passed (12-hour cooldown).
- Objective progress is display only. The server counts it from real events.

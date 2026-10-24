---
tags: [ui]
screen: Case Opening
status: building
---
# Screen - Case Opening

## Purpose
Choose a case, see odds, open, enjoy the reveal. Main dopamine screen. See [[Case Unboxing]].

## Opened from / closes to
HUD → Inventory → Cases tab, the Shop after buying a case, or the Case Vault room in HQ. Reveal closes back to case select.

## Layout
**Select view**
- Horizontal carousel of case models (3D in ViewportFrames), selected case centered and larger.
- Under case: name, price, currency icon, buttons **Open ×1**, **Open ×5**, **Open ×10** (×10 unlocks Stage 4 or gamepass).
- "ⓘ Odds" button top right of case → odds panel listing each rarity % and example drops.
- Pity bar below: "Epic in 4 · Legendary in 31".

**Reveal view (fullscreen)**
1. Case drops on stage, lights dim (0.6 s)
2. Shake with glow color telegraph (1.2 s)
3. Lid pop + beam (0.4 s)
4. Card flip, stats pop in (0.8 s)
5. Result card with NEW! badge or "+12 Shards" for duplicates
- Skip button bottom right from frame 1.
- Multi-open: grid of 5/10 face-down cards, flip one by one or "Reveal all".

## States
- Not enough currency: Open buttons grey with "Get more" link to Store/earn tips.
- Mythic: screen shake, rainbow beam, server-wide announcement toast.

## Animations / sounds
Rarity stings rising pitch per tier; crowd cheer volume scales with rarity.

## Data it reads / remotes it calls
Reads `PityCounters`, currency. Calls `Case/Open(caseId, count)` → returns list of drops (already granted).

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Currencies.Cash`, `.Gems` | Open button affordability |
| Profile | `PityCounters { Epic, Legendary, Mythic }` | Pity bar "Epic in 4 · Legendary in 31" |
| Profile | `Stage`, `Purchases` (×10 gamepass) | ×10 unlock |
| Config | `Cases.lua` ([[Case Library]]): price, currency, odds, drop pools, availability | Carousel, odds panel |
| Config | `Furry.lua` ([[Furry Variants]]) | Furry odds line |
| Server reply | `Case/Open` → `{ drops[] }` (already granted) | Reveal sequence, NEW! / "+12 Shards" |
| Server signal | ⚠ `Notify/Announce` (server-wide Mythic pull) | Announcement toast |
| Profile | `Settings` (reduced motion) | Shorter reveal, no shake |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Open ×1 / ×5 / ×10 | `Case/Open` | RF | caseId, count | drops list |
| ⓘ Odds | none | — | — | Local panel from config |
| Get more | none | — | — | Opens [[Screen - Store]] |
| Skip / Reveal all | none | — | — | Local playback |

### State Validation
- `count` ∈ {1, 5, 10}. ×10 needs `Stage` ≥ 4 or the gamepass.
- Balance in the case's currency ≥ `price × count`.
- The case is currently available (not vaulted, not upcoming).
- Lock the Open buttons from the call until the reveal finishes (server limit is 2/s).

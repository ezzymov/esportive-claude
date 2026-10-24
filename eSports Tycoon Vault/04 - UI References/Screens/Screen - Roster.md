---
tags: [ui]
screen: Roster
status: building
---
# Screen - Roster

## Purpose
See and manage all players: active five, bench, academy. See [[Player Hiring]].

## Opened from / closes to
HUD left rail → Roster. Also from tapping a player NPC at a station.

## Layout
Large panel (80% width desktop, fullscreen mobile).
- **Header:** tabs Active · Bench · Academy · Free Agents; Team Power number; synergy icons for 5 roles (lit when covered).
- **Grid:** player cards 140×190, rarity frame, portrait, name, role icon, OVR big number, trait chip, morale face.
- **Detail drawer** (slides from right on card tap): 6 stat bars with Potential ghost bar, trait description, salary, contract weeks left, morale/fatigue meters, station assigned.
- **Actions** (drawer bottom): Train · Swap · Bench · Release · Sell. Release/Sell need confirm dialog.
- Drag-and-drop between Active and Bench on desktop; tap "Swap" then target on mobile.

## States
- Empty slot: dashed card "+ Hire" → Free Agents tab.
- Training: card shows timer ribbon.
- Fatigued (>70): orange tint + warning icon.

## Animations / sounds
Card flip on open drawer; OVR count-up on stat change; swap whoosh.

## References
More context: [[Reference Board - Simulator UI]].
| Image | Source | What to copy |
|---|---|---|
| ![[StudGUI_Auras_grid-plus-preview-panel.webp]] | Stud GUI pack | Gear tab picker: grid of owned accessories (tile tinted by rarity) + big preview on the right with the stat bonus where they show "x???" and a green Equip button |

## Data it reads / remotes it calls
Reads `Roster`, `Stations`. Calls `Roster/Hire`, `Roster/Release`, `Roster/Train`, `Roster/Swap`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Roster[id]` → `PlayerCard { Id, Name, Role, Rarity, Stats, Potential, Trait, Salary, Morale, Fatigue, Tradeable, Source }` | Cards, detail drawer, stat bars + Potential ghost bar |
| Profile | `Stations[slot].PlayerId` | "Station assigned" in drawer; Active vs Bench split |
| Profile | `Training` (playerId, stat, endsAt) | Training timer ribbon |
| Profile | `Currencies.Cash` | Hire button affordability |
| PlayerCard | ⚠ `ContractWeeksLeft` | Contract line in drawer |
| Config | `Traits.lua` ([[Trait Library]]), role weights ([[Balance Tables]]) | Trait text; OVR / Team Power display via shared calc module |
| Server reply | ⚠ `Roster/GetFreeAgents` RF → listings `{ listingId, PlayerCard, price, expiresAt }` | Free Agents tab |
| Server reply | ⚠ `Roster/GetAcademy` (or `Profile.Academy`) | Academy tab ([[Academy & Youth]]) |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| "+ Hire" / Free Agent card → Hire | `Roster/Hire` | RF | listingId | ok / error |
| Train | `Roster/Train` | RF | playerId, stat, duration | ok / error (or open [[Screen - Staff & Training]]) |
| Swap / Bench / drag-drop | ⚠ `Roster/Swap` | RF | playerId, targetPlayerId or slot | new lineup |
| Release (after confirm) | `Roster/Release` | RE | playerId, confirmToken | state delta |
| Sell (after confirm) | ⚠ `Transfer/List` ([[Transfer Market]]) | RF | playerId, price | listingId |

### State Validation
- **Hire:** a roster slot is free and `Cash` ≥ the listing price, and the listing's `expiresAt` hasn't passed.
- **Train:** `Fatigue` < 100, the player isn't already training, and a training queue slot is free.
- **Swap / Bench:** active lineup stays ≤ 5 and the team isn't in a match.
- **Release / Sell:** never offer these for the Founder card (`Source == "Founder"`, see [[Founder (You)]]). Show the confirm dialog before firing. Sell needs `Tradeable == true`.
- Debounce every action button until the reply or delta arrives.

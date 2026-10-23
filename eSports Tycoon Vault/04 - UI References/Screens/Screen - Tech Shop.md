---
tags: [ui]
screen: Tech Shop
status: designed
---
# Screen - Tech Shop

## Purpose
Buy and equip PC parts and plain accessories. See [[PC Setups]] and [[Accessories]].

## Opened from / closes to
HUD → Shop → Tech tab, Roster → Gear ("Buy more"), or walking up to the Tech Shop counter (ProximityPrompt).

## Layout
- **Top:** category tabs with icons: CPU · GPU · Monitor · Chair · Decor | **Accessories** (Mouse · Keyboard · Headset · Sleeve · Glasses · Charm). Stock refresh timer on the right ("New stock in 12:34").
- **Accessories tab:** cards show tier color and a flat bonus ("+3 Aim"). The right panel switches from the station selector to a **player** selector (accessories go on the player, not the seat). Items above the stage tier cap show "Full bonus at Stage N". Equip calls `Accessory/Equip` ([[Accessories]]).
- **Left 65%:** item grid, cards show part image, brand logo, tier color, stat bonus ("+7% Aim"), price button.
- **Right 35%:** station preview (ViewportFrame of the desk), station selector dropdown (Station 1–N, with player name), **stat delta preview**: current → new in green/red.
- **Bottom:** Owned tab toggle to equip parts from inventory.

## States
- Can't afford: price button grey, shows "$X more".
- Owned: "Equip" instead of price.
- Set bonus progress: brand chip "Vektor 2/3".

## Animations / sounds
Buy: cha-ching + part flies into the station preview. Equip: snap SFX + RGB flash on the desk in the world.

## References
More context: [[Reference Board - Simulator UI]].
| Image | Source | What to copy |
|---|---|---|
| ![[FruitSim_Store_colored-item-cards-and-tabs.png]] | Fruit simulator | 2×2 colored item cards with icon, price, stat line ("+7% Aim" / "+3 Aim") and green Buy button; category tabs under the grid; currency pill with + in the header |

## Data it reads / remotes it calls
Reads `Inventory.Parts`, `Stations`, shop stock. Calls `Shop/Buy(partId)`, `Station/Equip(slot, partId)`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Currencies.Cash` | Price buttons, "$X more" |
| Profile | `Inventory.Parts` | Owned tab; "Equip" instead of price |
| Profile | `Stations[slot] { PlayerId, Parts }` + `Roster[id].Name` | Station selector; stat delta preview |
| Config | `Parts.lua`, `Brands.lua` ([[Content Catalog]]), part tiers ([[Balance Tables]]) | Item cards, brand set bonus "Vektor 2/3" |
| Server reply | ⚠ shop stock `{ partIds[], refreshAt }` (`Shop/GetStock` RF or a profile field) | Item grid; "New stock in 12:34" |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Price button | ⚠ `Shop/Buy` | RF | partId | ok / error |
| Equip | `Station/Equip` | RF | slot, partId | ok / error |

### State Validation
- **Buy:** the part is in the current stock, `Cash` ≥ price, and `refreshAt` hasn't passed (otherwise refetch the stock).
- **Equip:** the part is in `Inventory.Parts`, the station slot is unlocked, and the part's category matches the slot.
- Compute the stat delta preview locally from config. It's display only.

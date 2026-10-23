---
tags: [ui]
screen: Store
status: designed
---
# Screen - Store

## Purpose
Robux purchases: gamepasses, Gems, boosters, cosmetics. See [[Monetization]].

## Layout
- Tabs: Featured · Passes · Gems · Boosters · Cosmetics.
- **Featured:** one big banner (Starter Pack / event bundle), 2 smaller tiles.
- **Passes:** cards with icon, name, one-line effect, Robux price, "Owned ✓" when bought.
- **Gems:** 4 packs, bonus % chips on larger packs.
- **Boosters:** active booster timers at top, buy cards below.
- Every price shows the Robux icon. Purchase always goes through the native Roblox prompt.

## Rules
No countdown timers on purchase tiles, no "only X left" pressure text. See [[Monetization]] principles and the offer placement table in [[Microtransaction Ideas]].

## References
More context: [[Reference Board - Simulator UI]].
| Image | Source | What to copy |
|---|---|---|
| ![[HatchSim_Shop_starter-pack-and-tile-rows.png]] | Pet-hatching simulator | Rows by type: wide Starter Pack banner, row of 3 pass tiles, row of 3 Gem packs (small/medium/large), wide 2× Cash banner. One color per row, dark Robux price pill on each card |
| ![[PlazaGame_GameShop_vip-banner-square-tiles.png]] | Plaza game | VIP banner with a bullet list of perks + price on the right (ours is a gamepass, not a subscription), square tiles with NEW tags |
| ![[FigBlox_Store_figma-to-studio-tilted-cards.png]] | Figma → Studio plugin demo | Tilted oversized 3D icons breaking the card edge, NEW!/VIP badges |
| ![[StudGUI_Tabs_stud-texture-pills.png]] | Stud GUI pack | Tab pills, one color per tab (Featured · Passes · Gems · Boosters · Cosmetics) |

## Data it reads / remotes it calls
`MarketplaceService:PromptGamePassPurchase` / `PromptProductPurchase`. Server grants via `ProcessReceipt`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Purchases` (owned passes, one-time offers bought) | "Owned ✓", hide claimed bundles |
| Profile | `Inventory.Boosters` | Active booster timers |
| Config | Gamepass / product IDs and tab layout ([[Monetization]], [[Microtransaction Ideas]]) | Cards |
| Roblox | `MarketplaceService:GetProductInfo` | Live Robux prices |
| Roblox | `PolicyService:GetPolicyInfoForPlayerAsync` (`ArePaidRandomItemsRestricted`) | Hide paid random items where restricted |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Buy pass | `MarketplaceService:PromptGamePassPurchase` | — | passId | `PromptGamePassPurchaseFinished` |
| Buy Gems / booster / bundle | `MarketplaceService:PromptProductPurchase` | — | productId | Server grants in `ProcessReceipt` → state delta |

### State Validation
- Hide or disable the buy button for passes you already own.
- Respect the PolicyService restrictions before showing random-item products.
- **Never grant anything on the client.** Wait for the state delta after `ProcessReceipt`.
- No countdowns and no scarcity text (rule from [[Monetization]]).

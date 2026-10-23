---
tags: [ui]
screen: Skin Marketplace
status: designed
---
# Screen - Skin Marketplace

## Purpose
The six "online" skin markets, one per game title, run by players. Rules: [[Skin Marketplace]].

## Opened from / closes to
- Phone app **Markets** (HUD phone button), or the PC in your HQ (walk up → "Go online").
- Inventory skin card → **Sell on market** (opens straight to the Sell screen) or **View on market**.
- Closes back to wherever you were.

## Layout
Looks like a web browser so it feels "online": a fake tab strip on top with one tab per title site you've unlocked (Armory Exchange, Neon Bazaar, Clash Emporium, Supply Drop, Pit Lane, Fight Night Closet). Each site has its own logo, colors and fake URL in an address bar (`armory.exchange/skins/viper-neon-tide`).

| Region | Contents |
|---|---|
| Browser chrome | Site tabs · back/forward · fake URL bar (tappable search) · your Cash · ✕ |
| Site header | Site logo, nav: **Featured · Browse · Sell · My Listings · Buy Orders · History** |
| Main area | The current page (below) |

Mobile: site tabs collapse into a dropdown; nav becomes a bottom tab bar.

### Featured page
- Hero banner: newest skins with **Launch price** tags and a "New" ribbon (first 14 days).
- Rows: Trending (most sales 24 h) · Biggest movers (▲▼ % vs 7 days ago) · Cheapest ★ (Armory Exchange only) · Just listed with stickers.

### Browse page
- Left filters (bottom sheet on mobile): slot, rarity, price range, condition tier, finish, has stickers / no stickers / sticker name, tracker, edition.
- Grid of **skin cards**: art, name, rarity frame, "from $X" (lowest listing), listing count, small 7-day sparkline.

### Skin page
- Top: big 3D preview, name, rarity, collection, Launch Price marker.
- **Price chart**: 30-day median line + volume bars, Launch Price as a dashed line, hover for daily values.
- Stat strip: Lowest listing · Highest buy order · 24 h sales · Listings.
- **Listings table**, cheapest first: price, condition bar (`0.083 Fresh`), seed, finish badge, tracker, **sticker icons** (tap to see sticker names, finishes and wear %), **Inspect**, **Buy**.
- **Buy order** box: max price, quantity, filters → Place order.

### Inspect modal
3D rotate/zoom of the exact listed copy with stickers at their real wear. Info panel: seed, condition, finish, tracker, edition, each sticker (name, finish, wear %). Button: **Buy for $X**.

### Buy confirmation
Plain-language summary of the exact item and stickers, price, your Cash after. A second confirm for prices over $10,000 on under-13 accounts. Result: "Bought! It's in your inventory" or "Just sold to someone else. You weren't charged."

### Sell screen
1. Pick a skin (inventory grid filtered to this title; un-listable ones show 🔒 with the reason).
2. **Sticker check panel** (only if the skin has stickers): sticker thumbnails with wear, and the line "🏷️ These stickers will be sold with the skin." Buttons: **Keep them on** · **Remove stickers first** (opens peel/scrape tools; peel shows Sticker Savers owned, scrape shows a red destroy warning with the sticker's value).
3. Price: suggested price (lowest listing + sticker bonus), allowed band slider, "You receive $X after the 10% fee".
4. Loadout warning if equipped ("Removes it from Nova Kaze's Aim Arena loadout").
5. **List it**.

### My Listings / Buy Orders / History
- My Listings: active listings with time left, Cancel; sold ones show buyer tag + payout.
- Buy Orders: open orders, escrowed Cash, Cancel.
- History: all your sales and purchases with price, fee, date.

## States
- **Market frozen** (admin): orange banner "This market is paused for maintenance. Your listings are safe."
- **Locked by stage/age**: browse only, Buy/Sell disabled with the requirement shown.
- **Item on hold**: 🔒 "Can be listed in 14 h" countdown.
- **Empty listing**: "No one is selling this right now. Place a buy order?"

## References
More context: [[Reference Board - Simulator UI]].
| Image | Source | What to copy |
|---|---|---|
| ![[FruitSim_Store_colored-item-cards-and-tabs.png]] | Fruit simulator | Sell / Buy mode tabs across the top of the panel |

## Data it reads / remotes it calls
`Market/Browse`, `Market/GetSkin`, `Market/List`, `Market/Cancel`, `Market/Buy`, `Market/PlaceOrder`, `Market/CancelOrder`, `Sticker/Peel`, `Sticker/Scrape`. See [[Skin Marketplace]] → Remotes.

## Style notes
Each site gets its own skin in the [[UI Style Guide]] palette (gunmetal/orange, holo, parchment/gold, military, checkered, arcade neon), but layout and buttons stay identical across sites so players learn it once. Prices always show Cash; never Robux.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Currencies.Cash`, `Stage` | Browser chrome Cash; Sell needs Stage 4 |
| Profile | Skin inventory with hold / lock / equipped state and loadout owner | Sell picker 🔒 reasons, loadout warning |
| Profile | ⚠ unlocked titles, ⚠ my listings / buy orders / history | Site tabs, My Listings, Buy Orders, History |
| Server signal | ⚠ under-13 flag (server-computed) | Second confirm over $10,000 |
| Server reply | `Market/Browse` → skin cards (lowest price, count, 7-day sparkline) | Browse grid, Featured rows |
| Server reply | `Market/GetSkin` → listings, 30-day price history, highest buy order, 24 h sales | Skin page, chart, Inspect |
| Server signal | ⚠ `Market/State` (frozen flag per title) | "Market paused" banner |
| Config | `Skins.lua` (launch price, rarity, collection), site themes ([[UI Style Guide]]) | Cards, site styling |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Browse / filters / search | `Market/Browse` | RF | title, slot?, query?, filters, page | page of skins |
| Open skin page | `Market/GetSkin` | RF | title, skinId | listings + history |
| List it | `Market/List` | RF | skinUuid, price | listingId |
| Cancel listing | `Market/Cancel` | RF | listingId | ok |
| Buy | `Market/Buy` | RF | listingId, expectedPrice, purchaseId | ok / "Just sold to someone else" |
| Place order | `Market/PlaceOrder` | RF | skinId, maxPrice, qty, filters | orderId |
| Cancel order | `Market/CancelOrder` | RF | orderId | ok |
| Remove stickers first | `Sticker/Peel`, `Sticker/Scrape` | RF | skinUuid, index | ok |

### State Validation
- **Buy:** `Cash` ≥ price, and it's not your own listing. Send `expectedPrice` as displayed. Generate `purchaseId` (GUID) once per click so retries are idempotent. Under-13 accounts get a second confirm over $10,000.
- **List:** Stage ≥ 4. The skin isn't on hold, locked, or equipped in a match, and has no custom stickers. Price within the allowed band. Fewer than 20 active listings.
- **Place order:** `Cash` ≥ `maxPrice × qty` and fewer than 20 open orders.
- If the market is frozen, disable Buy, List and Place order.
- Rate limits: `Market/Buy` 2/s, `Market/List` 1/s, `Market/Browse` 5/s. Debounce search typing.

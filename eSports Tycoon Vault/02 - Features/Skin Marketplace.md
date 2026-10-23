---
tags: [feature, economy, trading]
status: designed
priority: P2
stage: 4
updated: 2026-10-21
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Skin Library]]"
  - "[[Skin Pattern System]]"
  - "[[Economy Design]]"
  - "[[Services & Remotes]]"
  - "[[Security & Anti-Exploit]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Skin Marketplace]]"
roblox_execution_environment: ServerScriptService
---
# Skin Marketplace

## Summary
Each of the six game titles has its own **"online" skin market**: a fictional website you open from your phone or the PC in your HQ. Players list skins for Cash and other players buy them from any server. The players run it: there are no shop prices, only what others ask. For new skins, the **devs set a starting price** (the Launch Price) so the item feels valuable from day one; after that, real sales take over the price.

**Applied stickers are sold with the skin.** If you want to keep them, take them off before you list.

This extends the Global Market from [[Transfer Market]] / [[Trading System]] to skins. Escrow, tax and safety rules match those notes unless this note says otherwise. UI: [[Screen - Skin Marketplace]].

---

## The six markets
Every market only sells that title's gear skins (slots from [[Skin Pattern System]] → In-game gear slots). Each is styled like its own website, with a fake URL bar, its own logo and colors.

| Title | Market name | Fake URL | Sells | Look |
|---|---|---|---|---|
| [[Aim Arena]] | **Armory Exchange** | `armory.exchange` | Firearm skins, ★ knives & gloves, agents, charms, Charge skins | Dark gunmetal, orange accents, ★ section front and center |
| [[Spectra]] | **Neon Bazaar** | `neon.bazaar` | Hero skins, blaster skins, sprays, voice lines, victory poses | Holo gradients, glowing cards |
| [[Tower Clash]] | **Clash Emporium** | `clash.emporium` | Champion skins, recall effects, ward skins, emotes | Fantasy shop, parchment + gold |
| [[Drop Zone]] | **Supply Drop** | `supply.drop` | Outfits, parachutes, backpacks, drop trails (shared weapon skins are listed in Armory Exchange) | Military crates, airdrop smoke |
| [[Kart Rift]] | **Pit Lane** | `pitlane.shop` | Kart bodies, wheels, boost trails, helmets, horns | Garage, checkered flags |
| [[Brawl Legends]] | **Fight Night Closet** | `fightnight.closet` | Fighter outfits, hit effects, entrances, taunts | Arcade neon, boxing posters |

- A market unlocks for **browsing** when its title unlocks. Buying and selling need the trading requirements below.
- HQ skins (jersey, desk, monitor, chair, PC tower…) are not in any title market. See open questions.

---

## Player-facing behavior

### Buying
1. Open the phone app **Markets** (or the PC in your HQ) and pick a title's site.
2. Browse **Featured** (new skins, trending, biggest price moves), or by slot, or search.
3. Each skin page shows:
   - lowest listing
   - a 30-day price chart (median sale price per day + volume)
   - the Launch Price marker
   - the number of listings
   - a list of individual listings, each with its own seed, condition, finish, tracker and **stickers**
4. **Inspect** any listing in 3D (stickers included, at their real wear) before buying.
5. **Buy now** → confirmation shows exactly what you get ("Viper Rifle · Neon Tide · 0.083 Fresh · seed 412 · 2 stickers: Neon Cat (Holo, 100%), Team Tag (80%)") and the price.
6. The skin arrives in your inventory immediately (or within seconds if the seller is on another server).

### Buy orders
- No listing at your price? Place a **buy order**: skin, max price, quantity (≤ 5), and optional filters (minimum condition tier, finish, "no stickers").
- When someone lists a matching skin at or below your price, it sells to the oldest matching order automatically. Your Cash is held in escrow while the order is open.
- Orders last 7 days, and you can cancel any time (full refund).

### Selling
1. Open your inventory → pick a skin → **Sell on market**, or use the site's **Sell** tab.
2. The listing screen shows:
   - Suggested price: the current lowest listing, plus the sticker bonus if it has stickers.
   - The price band you're allowed to use, and the fee ("You receive $8,100 after the 10% fee").
   - **Sticker check** (see below).
3. Confirm. The skin moves into **escrow**: it leaves your loadouts and inventory and can't be used while listed.
4. When it sells, the Cash (minus fee) goes to your account, even if you're offline (paid on next join).
5. Cancel any time while unsold → the skin comes back unchanged. Listings expire after **7 days** and return automatically.

### Stickers on listed skins
Applied stickers **always go with the skin**. Before listing, the sell screen shows a **Sticker check** panel if the skin has any:

> 🏷️ This skin has 3 stickers. **They'll be sold with it.**
> [Keep them on and list] · [Remove stickers first]

**Remove stickers first** opens the sticker tools from [[Sticker System]]:
- **Peel with Sticker Saver**: the sticker goes back to your inventory at its current wear (uses 1 Sticker Saver).
- **Scrape off**: the sticker is destroyed. A warning shows its value.

Rules:
- You can only remove stickers **before** listing. Once listed, the skin is in escrow and its stickers are locked with it. To change them, cancel the listing first.
- The buyer gets the stickers exactly as they were: same finish, wear and placement.
- **Custom stickers** (Sticker Maker designs) can only be traded to friends, so a skin with a custom sticker **can't be listed** until that sticker is removed. The sell button explains why.
- The listing price **suggestion** adds the sticker bonus from [[Sticker System]] (`Σ stickerValue × finish × wear × 0.25`). Sellers choose their own price inside the band. The band is based on the skin alone, so stickers can push the price up only within the band's upper limit.
- Listings with stickers show sticker icons on the listing row. Buyers can filter by **has stickers / no stickers / specific sticker**.

---

## Pricing: dev launch prices → player prices

### Launch Price (dev-set)
- Every skin has a `LaunchPrice` in config, set by the devs when the skin ships. It's the "this is what it's worth" anchor. It shows as a marker on the price chart and as "Launch price $X" on the skin page.
- Devs set it on purpose **above** the AI sell-back value. This tells players the skin is worth chasing and makes opening cases for skins feel rewarding.
- Starting formula: `LaunchPrice = BaseValue(rarity) × CaseScarcity × 1.5`, rounded to a nice number, then hand-tuned. *(Tune in [[Balance Tables]].)*

### Price discovery (first 14 days of a skin)
- Listings must be within **75%–200% of LaunchPrice**. This stops a crash on day one when lots of copies drop at once, and stops absurd asks.

### Reference Price (after 14 days, or after 20 sales)
- `ReferencePrice` = the **median** of the last 30 days of sales. Only sales from **≥ 5 different buyers** count, and sales between flagged linked accounts are excluded.
- The listing band becomes **50%–300% of ReferencePrice**, the same band as the [[Transfer Market]].
- If a skin has too few sales to calculate, it falls back to LaunchPrice.
- Per-copy modifiers widen the band upward: condition, finish, signature pattern, tracker, edition ([[Skin Pattern System]] → Trade value modifiers). A Void-finish ✦ copy can list far above a plain one.

### Dev controls (via [[Admin Panel]])
- Re-anchor a LaunchPrice (e.g. when a skin is mispriced at launch).
- Freeze one skin or a whole market (incident switch).
- Delist a listing (e.g. a duped item). The item goes back to the seller or into the removed archive.

### Fees
- **10% market fee** on every sale, paid by the seller, destroyed (Cash sink), same as the Global Market.
- No listing fee. Cancelling is free.

---

## Who can use it
Same rules as [[Trading System]] → Safety rules, with one change: skin markets open at **Stage 4** (not Stage 7). Skins are cosmetic, so the economy risk is lower than with player cards.
- Account ≥ 3 days old on Roblox, ≥ 2 h in this game.
- Max **20 active listings** and **20 active buy orders** per player.
- Max **50 purchases per day**.
- Under-13 accounts: can buy and sell, but see a simpler UI with no buy orders, and a confirm step on every purchase over $10,000.

### What can be listed
| Item | Listable? | Why |
|---|---|---|
| Skins from Cash/Gem cases, quests, Circuit Pass free track | ✅ | |
| Skins received in a trade or bought on the market | ✅ after **24 h** hold | Same hold as trading (stops laundering) |
| Season / event skins | ✅ after the season or event ends | Matches the event-limited rule in [[Trading System]] |
| ★ knives & gloves | ✅ after 7-day hold | Same as named Mythics |
| Skins from Robux-bought crates or bundles | ❌ by default | Account-bound, per [[Transfer Market]] policy |
| Admin-granted skins | ❌ unless an Owner enabled Tradeable | [[Admin Panel]] |
| Skins with a custom sticker applied | ❌ until removed | Custom stickers are friends-only |
| Equipped skins | ✅ | Auto-unequipped on listing, with a confirm ("This removes it from Nova Kaze's loadout") |

Tracker counts and edition banners stay on the skin. Old clips keep their snapshot of the skin ([[Skin Pattern System]] → Loadouts).

---

## Server / data requirements
```lua
-- Shared/Config/Skins.lua (added fields)
SkinDef = { ..., Title = "AimArena", LaunchPrice = 12000, LaunchedAt = 1790812800, Marketable = true }

Listing = {
  ListingId, Title, SkinId, SellerUserId,
  Item = SkinItem,               -- full item incl. Applied.Stickers, moved into escrow
  Price, CreatedAt, ExpiresAt,
  State = "Listed" | "Reserved" | "Sold" | "Cancelled" | "Expired",
  ReservedBy?, ReservedUntil?,
}
BuyOrder = { OrderId, Title, SkinId, BuyerUserId, MaxPrice, Qty, Filters, EscrowCash, ExpiresAt }
Sale = { SaleId, ListingId, SkinId, Seller, Buyer, Price, Fee, Time, HadStickers }
```
- **MarketService** (new; [[Services & Remotes]]), one instance per server, all talking to shared stores:
  - **Search index:** `MemoryStoreSortedMap` per `Title:SkinId`, sorted by price → fast "lowest listing" and listing pages.
  - **Escrow:** `MarketEscrow` DataStore, key = ListingId (the item lives here while listed).
  - **Order book:** `MemoryStoreSortedMap` per `Title:SkinId:orders`, sorted by MaxPrice desc then time.
  - **History:** each `Sale` is appended to `MarketSales`; an hourly job rolls them into daily median/volume for charts and `ReferencePrice`.
- **Buy flow** (atomic, idempotent by `PurchaseId`):
  1. Buyer's server sets the listing to `Reserved` (MemoryStore `UpdateAsync`, 30 s TTL). Only one buyer can win.
  2. Deduct Cash from the buyer's (session-locked, local) profile and save.
  3. Mark the escrow record `Sold` with `UpdateAsync`.
  4. Deliver the item into the buyer's profile.
  5. Queue the payout (price − fee) into the seller's **mailbox** (same mailbox as [[Admin Panel]] grants). The seller gets it instantly if online (MessagingService ping) or on next join.
  6. If step 3 fails (already sold/cancelled) → refund the buyer and release.
- **Listing flow:** validate (owned, not locked, no custom stickers, in band, under limits). Then remove from profile + write escrow in one save step, then index. Stickers are part of the `SkinItem` and move with it; no separate sticker records.
- **Cancel / expire:** escrow `Listed → Cancelled/Expired`, item back via mailbox.
- **Recovery job:** every 10 min, find `Reserved` past TTL → back to `Listed`; find escrow records with no index entry → re-index or return.

### Remotes
| Remote | Type | Args | Server checks |
|---|---|---|---|
| Market/Browse | RF | title, slot?, query?, filters, page | title unlocked |
| Market/GetSkin | RF | title, skinId | — |
| Market/List | RF | skinUuid, price | owns, not held/locked/equipped-in-match, no custom stickers, in band, < 20 listings, Stage 4 |
| Market/Cancel | RF | listingId | is seller, state Listed |
| Market/Buy | RF | listingId, expectedPrice, purchaseId | price unchanged, Cash ≥ price, not own listing, daily cap |
| Market/PlaceOrder | RF | skinId, maxPrice, qty, filters | Cash ≥ maxPrice × qty (escrowed), < 20 orders |
| Market/CancelOrder | RF | orderId | is owner |
| Sticker/Peel, Sticker/Scrape | RF | (from [[Sticker System]]) | skin not listed (not in escrow) |

Rate limits: `Market/Buy` 2/s, `Market/List` 1/s, `Market/Browse` 5/s.

## UI screens
- [[Screen - Skin Marketplace]]
- Inventory item card: **Sell on market** button + "Listed" badge.
- [[Screen - Admin Panel]] → Items & Economy: market freeze, re-anchor, delist.

## Dependencies
[[Skin Pattern System]] · [[Skin Library]] · [[Sticker System]] · [[Trading System]] · [[Transfer Market]] · [[Economy Design]] · [[Balance Tables]] · [[Admin Panel]] · [[Security & Anti-Exploit]] · [[Game Titles Overview]]

## Edge cases / exploit risks
- **Two buyers click at once:** the MemoryStore reservation lets exactly one win; the other sees "Just sold" and isn't charged.
- **Seller changes stickers after listing:** impossible, because the skin is in escrow. Sticker remotes reject items that aren't in the profile.
- **Price-change swap:** `Market/Buy` sends `expectedPrice`. If the listing changed (cancel + relist), the buy fails safely.
- **Wash trading to pump prices** (selling between own alts): the 10% fee makes it costly; ReferencePrice uses the median from ≥ 5 distinct buyers; repeated sales between the same two accounts are flagged in the [[Admin Panel]] flag queue.
- **Market cornering** (one player buys all copies to set the price): allowed within the bands (it's a player economy), but the 300% cap and new case drops limit it. Watch with the dashboard.
- **Server crash mid-purchase:** each step is idempotent by `PurchaseId`, and the recovery job fixes stuck reservations. The rule is "either the buyer has the item and the seller has a payout queued, or neither changed".
- **MemoryStore limits:** cap listings per skin index shown at 200 (cheapest first); paging beyond uses the escrow DataStore.
- **Real-money trading:** prices are only in Cash; no Robux shown anywhere. Off-platform selling is reportable and against the rules.

## Acceptance criteria
- [ ] Each title has its own market showing only that title's skins
- [ ] New skins can only be listed inside 75–200% of their LaunchPrice for the first 14 days
- [ ] After discovery, the band follows the sales median
- [ ] A listed skin keeps all applied stickers exactly (finish, wear, position), and the buyer receives them
- [ ] Stickers can be peeled or scraped before listing, and not while listed
- [ ] Skins with custom stickers can't be listed
- [ ] Buying, cancelling and expiry always leave exactly one copy of the skin in the system
- [ ] Sellers get paid while offline, exactly once
- [ ] Buy orders fill automatically when a matching listing appears
- [ ] 10% fee is removed from the economy on each sale

## Open questions
- **HQ skins** (jersey, desk, chair, PC tower…): add a seventh "Setup Market" (`setup.store`)? Recommend yes, same rules.
- Should devs also **seed small "house" listings** at LaunchPrice on day one (limited stock, then gone) to set the price in action? This creates supply, so only for very limited skins.
- Show the Launch Price forever, or hide it after discovery so the market feels fully player-run?
- Does Stage 4 for skins vs Stage 7 for player cards feel confusing? Alternative: unify the global market at Stage 5.

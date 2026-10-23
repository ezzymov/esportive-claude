---
tags: [ui]
screen: Shop
status: designed
---
# Screen - Shop

## Purpose
The case and item shop, opened from the HUD **Shop** button ([[Screen - Main HUD]]). Sells crates and boosters for Cash, Gems or Robux, with the odds shown on every random item ([[Case Unboxing]], [[Monetization]]). Robux-only passes and products stay on [[Screen - Store]].

## Opened from / closes to
- Opens: HUD Shop button, or a "Shop" link from [[Screen - Case Opening]] after a case is opened.
- Closes to: the screen that opened it. One main panel open at a time, always an obvious ✕.

## Layout (anchors, sizes, regions)
- **Header bar:** full width, green, title "Shop" in chunky white text with dark stroke. ✕ button top right (red square).
- **Panel body:** stud texture behind the content at 10% opacity ([[UI Style Guide]] → Textures). Keeps the empty space around the banner from looking flat.
- **Section title:** centered "-- FEATURED --" in yellow with dark outline, above the banner.
- **Featured banner:** the current case, full width, themed art (Halloween-style for the seasonal case). Layout inside:
  - Top left: **New!** tag (red, only when the case is new this week). Case name in large yellow outlined text.
  - Middle: a row of **item tiles** (6 max), each with the item picture, the **drop chance** in white at the bottom, and a black frame. The rarest item sits on the right with a rainbow border and its chance in yellow.
  - Bottom: a **price row**, one button per purchase option, each with a small gift icon button beside it.
- **Right rail tabs** (4 max, icon + label, colored like [[Screen - Main HUD]] → Button style): Featured · Speed (training boosters) · Money (cash packs) · Stars (Gems).

## Price buttons
| Option | Color | Label |
|---|---|---|
| Top bundle (Robux) | Red | Robux icon + price, then "50 Crates" under it |
| Standard (Gems) | Green | Gem icon + price, then "10 Crates" under it |
| Small (Cash) | Green | Cash icon + price, then "1 Crate" under it |
| Gift | Purple, icon only | Opens "Gift to a friend" for the same item ([[Microtransaction Ideas]]: Gift anything) |

- Every price shows its currency icon. Robux always goes through the native prompt.
- Crate counts under each price are plain text, no emphasis.

## Odds
- Every item tile shows its drop chance. The full table is in [[Screen - Settings & Odds]] → Odds & Rules.
- Chances must add up to 100%. Checked in the config, not by the client.

## Rules
- **Conflict to decide:** the reference uses a countdown ("11d 20h 46m 40s"), "Limited Time!" text and a crossed-out old price. [[Monetization]] and [[Screen - Store]] ban fake urgency and countdown timers on purchase tiles. Proposed: drop the countdown and "Limited Time!" text, keep **New!** (factual). Keep a crossed-out price only when the old price really was charged, never as a fake anchor. Decide before M6 (see [[Monetization]] open questions).
- Seasonal cases can end (see [[Live Ops & Events]]). The end date is shown in the Event section, not on the case banner.
- No pay prompts that block play. Opening a case from Cash never shows a Robux upsell.

## References
| Image | Source | What to copy |
|---|---|---|
| ![[BuildAPC_Shop_featured-egg-odds.png]] | Build a PC (Roblox) | Green header with a chunky title and red ✕, featured banner with item tiles showing drop chances, colored price buttons with a gift button beside each, and rail tabs by category |
| ![[StudGUI_Tabs_stud-texture-pills.png]] | Stud GUI pack | Rail tab style: colored pills with texture and a darker bottom edge |

**Copy the layout, not the copy.** Their countdown and "Limited Time!" text don't go in. Our case names, items and palette replace theirs.

## Our mockup
_Not drawn yet. Add `Mockups - Ours/Shop v1` when the layout is approved._

## Data it reads / remotes it calls
- Reads `Cases.lua` (items, weights, odds), `Shop.lua` (featured case, tiles, prices), `Profile.Currencies`.
- Calls `Case/Open(caseId, count)` (RF) from the price buttons, `Gift/Send(itemId, friendId)` (RF) from the gift buttons, and `MarketplaceService:PromptProductPurchase` for Robux options.
- Server grants items. The client only greys out what the player can't afford.
- ⚠ `Shop.lua` (featured case and tab layout) and `Gift/Send` aren't in [[Services & Remotes]] yet.

## Animations / sounds
- Tile hover: scale 1.05. Rarest tile: slow rainbow border shimmer.
- Price press: scale 0.96 then back.
- Open result: handed to [[Screen - Case Opening]].

## Accessibility
- Odds text ≥ 14 px on mobile, rarity shown with shapes as well as color ([[Screen - Settings & Odds]] → Colorblind rarity icons).
- Mobile: tiles scroll sideways, price row stays visible at the bottom.

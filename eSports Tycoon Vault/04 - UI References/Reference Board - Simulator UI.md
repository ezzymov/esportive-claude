---
tags: [ui, reference]
updated: 2026-10-21
---
# Reference Board: Simulator UI

Seven Roblox simulator UI references (shops, settings, inventory pickers, tabs). Files are in `Screenshots - Roblox Games/`. Each one is linked from the screen spec it feeds. **Copy layouts and patterns, never art, names or copy.**

## The shared look
Every reference here uses the same family of choices. Together they describe one consistent style:
| Pattern | What it looks like | Seen in |
|---|---|---|
| **Colored header bar** | Solid red / blue / green bar across the top of the modal, title in chunky white text with a thick dark stroke | 1, 2, 3, 4, 6 |
| **Square ✕ in the header** | Red rounded square with a white ✕, top right, sometimes overlapping the panel corner | 2, 3, 6 |
| **Light body, colored cards** | White or pale panel body. Each card has its own saturated color (cyan, purple, yellow, green…), so items read at a glance | 1, 3, 4, 5 |
| **Subtle background texture** | Checkerboard (1, 3), gear pattern (2) or Lego studs (6, 7) inside headers, cards and tabs at low contrast | 1, 2, 3, 6, 7 |
| **Dark price pill** | Black/dark rounded pill with the Robux icon + number, pinned to the bottom of the card | 1, 4, 5 |
| **Big 3D icon breaking the card edge** | Item art oversized and tilted, overlapping the card border | 1, 5 |
| **Thick outlines everywhere** | 3–4 px dark stroke on panels, cards, text and icons; a darker bottom edge makes buttons look raised | all |
| **Rounded pill font** | Fredoka-style rounded heavy font, white with dark stroke | all |
| **"NEW!" badge** | Small tilted red/yellow tag on the card corner | 4, 5 |

## Per reference
| # | Image | Source | What to copy | Feeds |
|---|---|---|---|---|
| 1 | ![[HatchSim_Shop_starter-pack-and-tile-rows.png]] | Pet-hatching simulator | Store as stacked **rows by type**: wide Starter Pack banner → row of 3 pass tiles → row of 3 currency packs (10 / 50 / 100) → wide 2× Cash banner. Each row has one color. Also the HUD: 2-column icon rail on the left, level bar + green cash pill bottom center, quick bar bottom left | [[Screen - Store]], [[Screen - Main HUD]] |
| 2 | ![[Enz0s_Settings_toggle-rows.webp]] | UI designer showcase (Enz0s) | Settings as **one big row per setting**: label left, pill toggle right (green on / red off). Disabled rows fade to ~50%. Blue header with a gear pattern | [[Screen - Settings & Odds]] |
| 3 | ![[FruitSim_Store_colored-item-cards-and-tabs.png]] | Fruit/food simulator | **2×2 item cards**, each a different color, with icon, price, **stat line ("+500 HP")** and a green Buy button. Category tabs underneath (Food / Swords / Boosts, selected = green). Top mode tabs **Sell / Base / Buy**. Currency pill with "+" in the header | [[Screen - Tech Shop]], [[Screen - Skin Marketplace]] |
| 4 | ![[PlazaGame_GameShop_vip-banner-square-tiles.png]] | Hangout/plaza game | Wide **VIP banner** with a bullet list of perks and the price button on the right. Row of square product tiles with black price pills and "NEW" tags | [[Screen - Store]] |
| 5 | ![[FigBlox_Store_figma-to-studio-tilted-cards.png]] | Figma → Roblox Studio plugin demo | Store cards with **tilted, oversized 3D icons**, "NEW!" and VIP badges. Also shows a **workflow**: design in Figma, import into Studio as real `ImageLabel`/`Frame` instances | [[Screen - Store]], [[Claude Session Primer]] |
| 6 | ![[StudGUI_Auras_grid-plus-preview-panel.webp]] | "Stud GUI" pack | **Grid + preview panel**: 4-column grid of items on the left (tile background tinted by rarity), selected item large on the right with its multiplier and a big green action button. Locked items show **"???"**. Title bar includes what the category does ("Auras – Increase Belly Size") | [[Screen - Roster]] (Gear tab), [[Screen - Sticker Editor]], [[Screen - Team Creator]] |
| 7 | ![[StudGUI_Tabs_stud-texture-pills.png]] | "Stud GUI" pack | **Vertical tab pills**: one color per tab (Exclusive magenta, Potions cyan, Passes orange, Rewards blue), stud texture, white stroked text, darker bottom edge | [[Screen - Store]], [[Screen - Shop]] (rail tabs) |

## How this maps to our screens
- **Store** ([[Screen - Store]]): row structure from #1, VIP-style banner from #4 (as a **gamepass**, not a subscription), tab pills from #7.
- **Tech Shop** ([[Screen - Tech Shop]]): 2×2 colored cards from #3, with the stat line showing our numbers ("+7% Aim" for parts, "+3 Aim" for [[Accessories]]).
- **Gear / inventory pickers**: the grid + preview layout from #6 for the Roster → Gear tab, the sticker picker and the jersey pattern picker. Selected item's stat bonus goes where #6 shows "x???".
- **Settings** ([[Screen - Settings & Odds]]): row-per-setting toggles from #2. Sliders (volumes) use the same row with a slider instead of a toggle.
- **Collection Log / locked items**: "???" on locked tiles from #6 (matches Signature Patterns shown as "???" in [[Skin Pattern System]]).

## Don't copy
- **Subscriptions and €-priced offers (#4):** we sell gamepasses and dev products in Robux only ([[Monetization]]).
- **"A great offer you can't refuse!" style copy (#1):** pressure wording is against [[Monetization]] principle 3. Use plain descriptions.
- **Their icons, art and game names.** All icons get drawn for us ([[UI Style Guide]] → Iconography).

## Open question: which look?
These references are bright, light-bodied and cartoony. [[UI Style Guide]] still describes a **dark navy "neon-night arena"** look. The existing screen specs ([[Screen - Shop]], BuildAPC refs) already lean bright. Pick one:
1. **Bright simulator** everywhere (matches these refs and the Roblox audience).
2. **Hybrid:** bright simulator for menus (Shop, Store, Settings, inventory), dark neon for esports moments (Match HUD, Bracket, Case reveal, broadcast).
3. **Dark neon** everywhere (these refs only give layouts).

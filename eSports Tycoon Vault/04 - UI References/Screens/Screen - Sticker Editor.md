---
tags: [ui]
screen: Sticker Editor
status: designed
---
# Screen - Sticker Editor

## Purpose
Place stickers on skins and design custom stickers. Rules in [[Sticker System]].

## Opened from / closes to
Inventory → skin → **Stickers**, Loadout screen → item → **Customize**, Tech Shop owned items. Closes back to where it was opened.

## Layout
### Apply mode
| Region | Contents |
|---|---|
| Center (70%) | 3D item preview (ViewportFrame), drag to rotate, pinch to zoom; sticker areas outlined as dashed shapes |
| Left rail | Area list (Area 1–N) with filled/empty dots; tap to jump camera to it |
| Bottom drawer | Sticker inventory: filters (Capsule, Finish, Signature, Custom), sort by newest/value; stacks show "×3" |
| On-canvas handles | Move (drag), rotate ring, scale corner, flip button |
| Top bar | Undo · Redo · Snap toggle · Match-lighting toggle · ✕ |
| Bottom bar | **Apply** (primary), Scrape (on selected applied sticker), Sticker Saver count |

### Maker mode (tab)
- Left: shape grid → background color/gradient → outline toggle.
- Center: big sticker canvas with layer handles.
- Right: icon library (search + categories), layer list (max 3) with color/size/rotate.
- Bottom: text picker (preset words, team tag, roster tags), finish picker (locked finishes show cost), **Save Design**, **Print ×N**.

## States
- Apply confirm modal: "Applying uses up this sticker. Continue?"
- Scrape confirm when wear would hit 0%: "This will remove the sticker for good."
- Area full: area outline turns red, "This area is full".
- Item trade-locked: editor read-only with 🔒 banner.

## Animations / sounds
Sticker peel sound when picked up, satisfying "thwap" when applied, scrape = scratchy sound + small paper bits; Holo/Gold shimmer previews in real time.

## References
More context: [[Reference Board - Simulator UI]].
| Image | Source | What to copy |
|---|---|---|
| ![[StudGUI_Auras_grid-plus-preview-panel.webp]] | Stud GUI pack | Sticker picker: grid + preview panel; title bar says what the category does |

## Data it reads / remotes it calls
Reads inventory, skin's `Applied.Stickers`, designs. Calls `Sticker/Apply`, `Sticker/Scrape`, `Sticker/Save`, `Sticker/SaveDesign`, `Sticker/Print`, `Sticker/PostCraft`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | Skin instance `{ uuid, skinId, Applied.Stickers[{ stickerId, area, transform, wear }], tradeLocked, listed }` | 3D preview, area dots |
| Profile | Sticker inventory (uuid, stickerId, finish, count), ⚠ `StickerSavers`, ⚠ finish tokens, `Currencies.Cash` | Bottom drawer, Saver count, Print cost |
| Profile | ⚠ `StickerDesigns` (designId, layers) | Maker mode |
| Config | Sticker areas per model, `StickerWords.lua`, icon library, finishes ([[Sticker System]]) | Area outlines, text picker |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Apply (after confirm) | `Sticker/Apply` | RF | skinUuid, stickerUuid, area, transform | ok / error |
| Scrape | `Sticker/Scrape` | RF | skinUuid, index | new wear |
| Save (peel with Sticker Saver) | `Sticker/Save` | RF | skinUuid, index | sticker back in inventory |
| Save Design | `Sticker/SaveDesign` | RF | designData | designId |
| Print ×N | `Sticker/Print` | RF | designId, count | stickers |
| Post to Craft Gallery | `Sticker/PostCraft` | RF | skinUuid | ok / cooldown |
| Move / rotate / scale / flip, Undo / Redo, Snap | none | — | — | Local transform state |

### State Validation
- **Apply:** the area has a free slot. Clamp the transform: U/V 0–1, scale 0.7–1.3. Show the "uses up this sticker" confirm. The skin isn't trade-locked or listed. Max 2 per second.
- **Scrape:** if wear would reach 0%, show the "remove for good" confirm.
- **Save:** you own at least 1 Sticker Saver.
- **Maker:** ≤ 3 layers, words only from `StickerWords.lua`, and a free design slot.
- **Print:** `Cash` and finish tokens cover `count`.
- ⚠ [[Skin Marketplace]] calls the peel action `Sticker/Peel`. This screen and [[Sticker System]] call it `Sticker/Save`. Pick one name.

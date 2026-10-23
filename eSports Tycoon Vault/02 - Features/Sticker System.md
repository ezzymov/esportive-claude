---
tags: [feature, cosmetics]
status: designed
priority: P1
stage: 3
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Skin Pattern System]]"
  - "[[Accessories]]"
  - "[[Case Library]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Sticker Editor]]"
  - "[[Screen - Settings & Odds]]"
roblox_execution_environment: ServerScriptService
---
# Sticker System

## Summary
Stickers let players **customize the skins their roster uses**: firearms, laser blasters, Agent and hero armor, karts, desks, monitors, PC towers, helmets and more. Stick them where you want, rotate and scale them, and they show in matches, clips and the HQ. Stickers are their own collectibles: they drop from **Sticker Capsules**, events, tournaments and achievements, and players can **design their own** in the Sticker Maker.

Builds on [[Skin Pattern System]] (skins, loadouts) and shows in [[Clip Cutscene System]]. Real-world reference: CS2 stickers (slots on weapons, scraping, capsules, autographs), with our own names and rules.

> **Power only on accessories.** Stickers on [[Accessories]] (mouse, keyboard, headset, arm sleeve, glasses, lucky charm) add stat power (section 3b). Stickers anywhere else are cosmetic only. All sticker power is off in the Ranked Ladder (Pure mode, see [[Accessories]] → *Gear Mode*).

## 1. Where stickers go
### Accessories (stickers add power)
| Accessory | Sticker slots | Placement |
|---|---|---|
| Mouse | 2 | Palm rest, side |
| Keyboard | 3 | Top frame, case side, spacebar edge |
| Headset | 2 | Ear cups |
| Arm Sleeve | 2 | Forearm, upper arm |
| Glasses | 2 | Left and right arm |
| Lucky Charm | 1 | Charm face |

### Everything else (cosmetic only)
| Item | Sticker slots | Placement |
|---|---|---|
| Firearms ([[Aim Arena]], [[Drop Zone]]) | 4 (Longbow 5) | Receiver, stock, near grip, top rail (CS-style) |
| Laser blasters ([[Spectra]]) | 3 | Body panels |
| Agent armor / hero armor | 3 | Shoulder, chest plate, back plate |
| Charge (Aim Arena) | 2 | Two side panels |
| Kart body ([[Kart Rift]]) | 6 | Hood, both sides, rear, spoiler |
| Racing helmet | 3 | Sides, back |
| Fighter outfit ([[Brawl Legends]]) | 2 | Chest, back |
| Desk | 4 | Desk top edge, front |
| Monitor | 3 | Bezel corners, back |
| PC Tower | 4 | Glass side, front panel |
| Jersey | Uses **patches** instead (4), see [[Skin Pattern System]] |
Champions ([[Tower Clash]]) don't take stickers; their **ward** and **recall banner** do (1 each).

## 2. Placement editor
- **Slot areas:** each skin model defines 2–6 sticker areas (flat or gently curved panels). Inside an area, the sticker can be moved freely.
- **Controls:** drag to move · two-finger rotate (or slider) · pinch to scale (70%–130%) · flip · snap toggle (0°/45°/90°).
- **Layering:** stickers in the same area can overlap; tap "Bring forward / Send back".
- **Preview:** rotate the item in 3D, toggle "match lighting" to see it like in a cutscene.
- **Apply:** confirm screen says "Applying uses up this sticker." Applied stickers are part of the skin from then on.
- Mobile: big handles, undo/redo, "Center" button.

### Roblox implementation
- Each sticker area = invisible flat `Part` (or thin MeshPart for curves) welded to the skin model, named `StickerArea_N`.
- Each placed sticker = `SurfaceGui` on that area with an `ImageLabel` (position, rotation, size from the saved transform). Layering via `ZIndex`.
- Finishes = layered `ImageLabel`s (shine texture with `UIGradient` animated by rotation tween; holo = moving gradient; glitter = sparkle sprite sheet).
- Wear = `ImageTransparency` + a scratch mask image on top.
- Built client-side from saved data; all transforms clamped server-side.

## 3. Sticker finishes
| Finish | Look | Drop chance in capsules |
|---|---|---|
| **Paper** | Matte, flat | 70% |
| **Glossy** | Shiny highlight | 18% |
| **Holo** | Rainbow sheen that moves with the camera | 8% |
| **Glitter** | Sparkle particles on the surface | 2.5% |
| **Foil** | Metallic, reflective | 1.2% |
| **Gold** | Solid gold with shine | 0.25% |
| **Lenticular** | Animated: flips between 2 images as the camera moves | 0.05% |
Finish odds show in the Odds panel of every capsule ([[Screen - Settings & Odds]]).

## 3b. Sticker power (accessories only)
Every capsule, tournament, signature, achievement and event sticker has a **stat tag**: Aim, Reflexes, Game Sense, Teamwork, Clutch or Consistency. The tag is part of the sticker def (a Crown is always Clutch, a Crosshair always Aim), shown as a small icon on the sticker card. Each capsule covers all 6 stats.
| Finish | Paper | Glossy | Holo | Glitter | Foil | Gold | Lenticular |
|---|---|---|---|---|---|---|---|
| Power | +0.5 | +1 | +1.5 | +2 | +2.5 | +3 | +4 |
- **Matching** the accessory's stat (Aim sticker on a mouse) = full power. **Off-stat** = half power, to the sticker's own stat.
- **Full Set:** every slot on one accessory filled from the same capsule → +1 to the accessory's stat (accessories with 2+ slots).
- **Signed gear:** a player's own signature sticker on their own accessory → +2 Clutch on top. (On weapons and karts it's still the cosmetic nameplate sparkle.)
- Counts toward the **+12 gear cap per stat** ([[Accessories]]).
- **No power from:** custom Sticker Maker designs, team stickers, sponsor stickers. They can go on accessories but add 0. Otherwise printing Gold-style stickers for Cash would bypass capsules.
- **Pure mode** (Ranked, and scrims with the toggle): sticker power is ignored.

## 4. Wear and scraping
- Applied stickers start at **100%**.
- **Scrape** (optional): each scrape takes off 20% and makes it look more worn. At 0% the sticker is gone.
- Stickers don't wear by themselves; only the owner scrapes them (players like the "battle-worn" look on purpose).
- **Wear never changes power.** A sticker at 20% gives the same power as at 100%, until it's scraped to 0.
- Removing a sticker = scraping it to 0. It's destroyed.
- **Sticker Saver** (consumable, from quests or 100 Shards): peels one sticker off cleanly and returns it to inventory at its current wear. Limited so stickers stay valuable. Now that accessory stickers carry power, this is the **respec** tool: moving a Gold sticker to a new accessory costs a Saver.

## 5. Sticker sources
| Source | Stickers |
|---|---|
| **Sticker Capsules** (cases) | Themed capsules, see section 7 |
| **Tournaments** | Tournament stickers with event name + year; winners get the Champion version |
| **Signature stickers** | Autograph-style stickers of your roster's key players and named stars ([[Key Players]], [[Pro Player References]]) |
| **Team stickers** | Free: your own team logo and tag, in Paper; Holo/Gold versions from milestones |
| **Sponsor stickers** | Each sponsor contract gives its brand sticker (fictional brands, [[Sponsors]]) |
| **Achievements** | Unique sticker per Gold achievement ([[Achievements & Collections]]) |
| **Events** | Event-only stickers ([[Live Ops & Events]]) |
| **Daily / Pass** | Season Pass and daily streak rewards ([[Daily Loops & Quests]]) |
| **Sticker Maker** | Your own designs (section 6) |

### Signature stickers (autographs)
- Each key player and named star has a signature sticker: their gamer tag in a handwriting-style font + small doodle.
- Putting a player's signature sticker on **their own** weapon/kart gives a sparkle on the nameplate in clips ("Signed gear"). On **their own accessory** it also gives +2 Clutch (section 3b).
- **Friend signature:** for [[Friend Signings]], a sticker with the friend's display name in a handwriting font (no photo). Only made if the friend allowed signing.

## 6. Sticker Maker (design your own)
Roblox games can't let players upload images, so custom stickers are **built from parts**:
1. **Shape:** circle, square, rounded rectangle, star, shield, heart, speech bubble, splat, badge (12 shapes).
2. **Background:** color or gradient from the palette, optional outline.
3. **Icon layers (up to 3):** from an icon library (crosshair, crown, skull-cartoon, flame, lightning, paw, controller, heart, star, trophy, cat, ghost, dice, pizza…). Each layer: color, size, rotation, position.
4. **Text (optional):** up to 12 characters from **preset words** ("GG", "CLUTCH", "ACE", "NO LAG", "W", "1V5", "GLHF") or your **team tag** or a roster player's tag. No free typing.
5. **Finish:** Paper free; Glossy and Holo cost Shards; Glitter/Foil need a **Finish Token** (from capsules/events).
6. **Save as design**, then **Print** (costs Cash) to get sticker items to apply.

- Up to 10 saved designs (20 with Pro Editor pass, [[Microtransaction Ideas]]).
- Custom stickers are **tradeable only to friends**, and show a "Custom" corner mark.
- Preset words are chosen to be friendly (no taunts like "EZ"). Text list lives in `Shared/Config/StickerWords.lua`.
- Designs are stored as data (shape, colors, layers), not images, so they render the same everywhere and pass moderation automatically.

## 7. Sticker Capsules
| Capsule | Price | Unlock | Contents |
|---|---|---|---|
| **Starter Capsule** | $800 | Stage 3 | GG, Heart, Lightning, Star, Crown, Smiley, Thumbs Up, Controller, Pizza, Ghost (Paper/Glossy heavy) |
| **Neon Nights Capsule** | $4,000 | Stage 4 | Neon cat, Synth sun, Laser grid, Arcade coin, Night city, Glow skull (cartoon), Neon "W" |
| **Critter Capsule** | $3,000 | Stage 4 | Cat, Frog, Duck, Capybara, Axolotl, Shiba, Penguin, Bee, Raccoon, Sloth |
| **Snack Capsule** | $3,000 | Stage 4 | Ramen, Boba, Taco, Donut, Pickle, Cookie, Fries, Energy Drink (fictional), Onigiri, Toast |
| **Meme-lite Capsule** | 25 Gems | Stage 5 | "Touch Grass", "Lag?", "Skill Issue" (friendly), "One More Game", "Mom I'm On TV", "brb snacks" |
| **Map Capsule** | $6,000 | Stage 5 | Mini art of each map: Neon Docks crane, Old Arcade ball pit, Monorail train… ([[Map Library]]) |
| **Agent Capsule** | 40 Gems | Stage 4 | Faction patches and Agent portraits ([[Agent Library]]) |
| **Hero Capsule** | 40 Gems | Stage 6 | Chibi stickers of Spectra heroes ([[Hero Library]]) |
| **Champion Capsule** | 40 Gems | Stage 6 | Chibi Champions ([[Champion Library]]) |
| **Signature Capsule** | 60 Gems | Stage 6 | Signature stickers of key players (random) |
| **Legends Signature Capsule** | 150 Gems | Stage 8 | Signature stickers of named stars, higher Holo/Gold odds |
| **Tournament Capsule** | Token | During tournaments | Tournament logo + team stickers of the AI teams in it |
| **Event Capsules** | Event tokens | Events | Pumpkin, Snowman, Beach Ball, Lantern, Cake… |
Capsules use the same pity and odds-display rules as cases ([[Case Library]], [[Case Unboxing]]).

## 8. Sticker sets & crafts
- **Matching set bonus:** 4 stickers from the same capsule on one item → small sparkle on the item in the HQ and a "Full Set" tag in the inspect view. On an **accessory**, filling every slot from one capsule counts as a Full Set and also gives +1 to its stat (section 3b).
- **Crafts:** a finished stickered skin can be saved as a **Craft** (screenshot + data) and posted to the **Craft Gallery** in the Streamr Tower ([[Map Library]] → World map). Others can like it.
- **Craft of the Week** wins a trophy, a gold frame for the craft, and a plaza showcase pedestal.

## 9. Value and trading
- Applied stickers stay on the skin when traded ([[Trading System]]). The skin's value gets a sticker bonus:
  `StickerBonus = Σ (stickerBaseValue × finishMult × wear% × share)`, where `share` = **0.25** on cosmetic items (so stickers don't make skins absurdly valuable) and **0.5** on accessories (applied power stickers are worth more). Power doesn't depend on wear, but trade value still does.
- Unapplied stickers trade like any item. Custom stickers trade only to friends.
- **Market listings** ([[Skin Marketplace]]): applied stickers are sold with the skin. To keep them, peel (Sticker Saver) or scrape them **before** listing; while listed, stickers are locked in escrow. Skins with a custom sticker can't be listed until it's removed.
- Finish multipliers: Paper 1 · Glossy 1.5 · Holo 3 · Glitter 5 · Foil 8 · Gold 25 · Lenticular 60.

## 10. In matches and clips
- Stickers render on weapons, karts, armor and helmets in every cutscene (snapshot in ClipData with the loadout).
- **Inspect beat** in the clip editor has the hero inspect their weapon, CS-style, showing stickers up close.
- Kill feed shows a tiny sparkle on the weapon icon if it has a Gold or Lenticular sticker.
- Low graphics: animated finishes show as static.

## 11. Data
```lua
StickerItem = { Uuid, DefId, Finish, Custom = nil | DesignData, ObtainedAt, Source }
-- StickerDef (config) gets StatTag = "Aim" | "Reflexes" | "GameSense" | "Teamwork" | "Clutch" | "Consistency" | nil
-- nil for custom, team and sponsor stickers (no power). Power is computed by GearService, never stored.

-- On a skin item:
SkinItem.Applied.Stickers = {
  { DefId, Finish, Custom = nil | DesignData, FromUuid,
    Area = 2, U = 0.42, V = 0.61, Rotation = 30, Scale = 1.1, Flip = false, Z = 1,
    Wear = 1.0 },
}

DesignData = { Shape = "Star", Bg = {Color, Gradient}, Outline = true,
               Layers = { {Icon = "Cat", Color, Size, Rot, U, V} }, Text = {WordId or "TeamTag"}, Finish }
```

### Remotes
| Remote | Args | Server checks |
|---|---|---|
| Sticker/Apply | skinUuid, stickerUuid, area, transform | owns both, area exists for that model, slot count not exceeded, transform within limits, skin not trade-locked, accessory not in a live match |
| Sticker/Scrape | skinUuid, index | owns skin, sticker exists; wear −0.2 |
| Sticker/Save | skinUuid, index | owns a Sticker Saver; returns sticker to inventory |
| Sticker/SaveDesign | designData | valid shapes/icons/words, ≤ 3 layers, design slots free |
| Sticker/Print | designId, count | cash, finish tokens |
| Sticker/PostCraft | skinUuid | owns skin, cooldown |

## UI screens
- [[Screen - Sticker Editor]]
- Sticker tab in Inventory, Craft Gallery in Clip Feed / Streamr Tower

## Edge cases / exploit risks
- Transform spam: rate limit Apply to 2/s; clamp U/V 0–1, scale 0.7–1.3.
- Stickers placed off-model: areas are bounded; anything outside is rejected.
- Offensive combos in Sticker Maker (icons + words arranged rudely): keep icon/word lists friendly, report button on crafts, moderators can remove a design from the gallery.
- Applying to a skin in an active trade: blocked by TradeLocked.

## Acceptance criteria
- [ ] A player can place, rotate, scale and apply a sticker on a weapon skin and see it in the next match cutscene
- [ ] Scraping reduces wear visibly and removes at 0%
- [ ] Sticker Maker designs render identically on other clients
- [ ] Traded skins keep their stickers
- [ ] Capsule odds panel shows finish chances
- [ ] A matching sticker on an accessory adds its finish power; off-stat adds half; cosmetic items and custom stickers add 0
- [ ] Sticker power is ignored in Ranked

## Open questions
- Allow Sticker Maker text from a filtered free-text box for 13+ accounts? Lean no; preset words are safer and good enough.
- Should custom stickers be tradeable to everyone? Lean no (keeps "made for my friend" special and limits misuse).

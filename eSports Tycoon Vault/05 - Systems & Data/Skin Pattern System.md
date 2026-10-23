---
tags: [system, cosmetics]
updated: 2026-10-21
---
# Skin Pattern System

Cosmetic skins for jerseys, desks, PC parts and peripherals, with CS2-style hidden variety: every drop rolls a **pattern seed**, a **condition**, and sometimes a **special finish**. Two copies of the same skin can look different, so rare-looking rolls become chase items and trade value (see [[Trading System]]).

> **Cosmetic only, except accessories.** Skins in the 6 [[Accessories]] slots (Mouse, Keyboard, Headset, Arm Sleeve, Glasses, Lucky Charm) give a stat bonus from their **rarity tier**. Nothing else ever changes stats: no jersey, weapon, knife, glove, Agent, hero, kart or station skin, and on any item **pattern seed, condition, finish, Signature Pattern, phase, fade and Tracker never change power**. All accessory power is off in the Ranked Ladder (see [[Accessories]] → *Gear Mode*, [[Monetization]]).

## Real-world reference
| CS2 idea | What it is in CS2 | Our version |
|---|---|---|
| Pattern index / paint seed (0–1000) | Shifts how the paint lines up on the model | **Pattern Seed 0–999** shifts texture offset, rotation and hue |
| Float / wear (0.00–1.00) | Scratches and fading, named tiers | **Condition 0.000–1.000**, named tiers |
| Rare patterns (e.g. "blue gem" Case Hardened, Fade %, Doppler phases) | Some seeds or phases are famous and worth far more | **Signature Patterns** (named rare seeds) and **Phases** |
| StatTrak™ | Counter of kills with the item | **Tracker** counter of wins / clip moments |
| Stickers / charms | Apply on top of skins | **Patches & Charms** |
| Souvenir | Drops at Majors with event stickers | **Championship Edition** from tournaments |
Names above are only for our reference. Don't use "StatTrak", "Doppler", "Case Hardened" or other CS2 names in game.

## Skin slots
| Slot | Applies to | Seen where |
|---|---|---|
| Jersey | Roster NPCs + your avatar | HQ, matches, clip thumbnails, bracket |
| Desk | Station desk | HQ |
| Monitor bezel | Monitor part model | HQ, Tech Shop |
| Chair | Chair part | HQ |
| PC Tower | Case side panel + RGB | HQ |
| Case Reveal stage | Unboxing stage | Case opening |
| Trophy shelf | Trophy Hall display | HQ |

### Accessory slots (give power, see [[Accessories]])
| Slot | Stat | Seen where |
|---|---|---|
| Mouse | Aim | HQ, match close-ups |
| Keyboard | Consistency | HQ, match close-ups |
| Headset | Teamwork | HQ, matches (on NPC head) |
| Arm Sleeve | Reflexes | HQ, matches |
| Glasses | Game Sense | HQ, matches |
| Lucky Charm | Clutch | Swings from the headset |
Accessories belong to the roster player (`PlayerCard.Accessories`), not the station.

### In-game gear slots (per title)
| Title | Gear slots |
|---|---|
| [[Aim Arena]] | Agent, each firearm (pistols, SMGs, rifles, snipers, heavy), **knife**, **gloves**, Charge, weapon charm, stickers |
| [[Spectra]] | Hero skins, blaster skin per hero, ultimate voice line, spray, victory pose, elimination color |
| [[Tower Clash]] | Champion skins (top 3 Champions), recall effect, ward skin, emote |
| [[Drop Zone]] | Outfit, parachute, backpack, weapons (shared with Aim Arena), knife, gloves, drop trail, victory emote |
| [[Kart Rift]] | Kart body, wheels, boost trail, helmet, horn, finish celebration |
| [[Brawl Legends]] | Fighter outfits (main + 2), hit effect, victory pose, entrance, taunt |

### Loadouts
- Every roster player has a **Loadout per title**. You assign skins you own to each slot.
- Each skin item (one UUID) can be equipped on **one player at a time**, so collecting more copies matters.
- Unassigned slots use the default team-color look.
- Loadouts show in matches, cutscenes and clips. Clips save a **snapshot** of the loadout, so old clips keep the skin even after you trade it away.
- "Copy loadout" button applies one player's setup to others where you own enough copies.
- `PlayerCard.Loadouts = { AimArena = { Agent = {Raiders = uuid, Wardens = uuid}, Weapons = {["Volk-47"] = uuid, ...}, Knife = uuid, Gloves = uuid, Charge = uuid, Charm = uuid }, ... }`

## 1. Pattern Seed (0–999)
Rolled on drop, stored on the item, never changes.
The seed drives:
- **Texture offset** (U, V) → where the pattern sits on the model
- **Rotation** (0°, 90°, 180°, 270°, or small tilt ±15°)
- **Hue shift** (±0–20° within the skin's palette, only for skins marked "hue-variable")
- **Accent placement** (e.g. which panel gets the glow stripe)

Most seeds look a bit different. Some seeds are **Signature Patterns** (see below).

### Roblox implementation
```lua
-- Seed → deterministic visual params. Same seed always gives the same look.
local function PatternParams(skinDef, seed)
  local rng = Random.new(skinDef.SeedSalt + seed)
  return {
    OffsetU = rng:NextNumber(0, skinDef.TileSize),
    OffsetV = rng:NextNumber(0, skinDef.TileSize),
    Rotation = skinDef.AllowTilt and rng:NextNumber(-15, 15) or ({0, 90, 180, 270})[rng:NextInteger(1, 4)],
    Hue = skinDef.HueVariable and rng:NextNumber(-20, 20) or 0,
  }
end
```
- Apply via `Texture` objects (`OffsetStudsU/V`, `StudsPerTileU/V`) on each face, or via `SurfaceAppearance` variants for meshes.
- Hue shift by picking `Color3` values with `Color3.fromHSV`, not by changing the image.
- Built client-side from `{SkinId, Seed, Condition, Finish}` → no extra server cost.

## 2. Condition (0.000–1.000)
How worn the skin looks. Lower = cleaner.
| Tier | Range | Roll chance | Look |
|---|---|---|---|
| **Mint** | 0.000–0.070 | 8% | Perfect, extra shine |
| **Fresh** | 0.070–0.150 | 22% | Very clean |
| **Played-In** | 0.150–0.380 | 40% | Small scuffs on edges |
| **Well-Loved** | 0.380–0.450 | 15% | Visible scratches, slight fade |
| **Battle-Worn** | 0.450–1.000 | 15% | Heavy scratches, faded paint, stickers peeling |

- Some skins have a limited range (e.g. "Holo" only rolls 0.00–0.20; "Garage Rust" only 0.40–1.00).
- **Implementation:** grime/scratch overlay `Decal` or `Texture` with `Transparency = 1 - condition`. Specular/reflectance lowered as condition rises.
- **Ultra-low condition** (below 0.001) shows a tiny ✦ next to the value. Chase item for collectors.
- Battle-Worn is a style too: some players want the "veteran" look. Never treat it as "bad", just different.

## 3. Finish (rare overlays)
| Finish | Chance (per drop) | Effect |
|---|---|---|
| Standard | ~94% | Normal |
| **Holo** | 4% | Rainbow sheen that shifts with camera angle |
| **Neon Edge** | 1.5% | Glowing outline in team colors |
| **Prism** | 0.4% | Animated color cycle |
| **Void** | 0.1% | Black with starfield animation |
- Finish odds are shown in the case's Odds panel.
- Animated finishes use a scrolling `Texture` (offset tween) or a slow `Color3` cycle; disable animation on Low graphics.

## 4. Signature Patterns (named rare seeds)
Each skin can define a few famous seeds. They're listed in the Collection Log as hidden entries ("???") until someone in the game finds one.
| Skin | Signature | Seeds | What makes it special |
|---|---|---|---|
| Circuit Board | **Golden Trace** | 3 seeds | All traces line up in gold on the front panel |
| Glitch | **Clean Glitch** | 5 seeds | Glitch bands avoid the logo entirely |
| Galaxy | **Twin Suns** | 2 seeds | Two stars sit perfectly on the shoulders |
| Flames | **Full Burn** | 4 seeds | Flames cover the whole front |
| Pixel Camo | **Hidden Smile** | 1 seed | Pixels form a smiley on the back |
| Tiger Stripe | **Clean Stripe** | 3 seeds | Symmetrical stripes |
| Lava Lamp | **Blue Blob** | 6 seeds | Blue blob dominates (our "blue gem" homage) |
- First player in the game to unbox a Signature gets a server-wide announcement and their name in the Collection Log "first finder" line.
- Seed ranges are documented here and in config so the community can hunt them.

## 5. Phases (for gradient skins)
Some gradient skins roll one of 4 **Phases** with fixed odds, each a different palette.
Example: **Aurora** → Phase 1 Green (35%), Phase 2 Teal (35%), Phase 3 Violet (25%), Phase "Crown" Gold (5%).
Shown on the item card as "Aurora · Phase 3".

## 6. Fade % (for fade skins)
Fade skins show a gradient across the model. The seed sets how much of the top color shows: **Fade 80%–100%**. 100% Fade is the chase roll.
`FadePct = 80 + 20 × (seed / 999) ^ 2`, so high fade is rarer.

## 7. Tracker counter (StatTrak-style)
- **Tracker** version of a skin counts something and shows it on the item (small digital display on desk/keyboard/jersey sleeve).
- Jersey counts **match wins**, Keyboard counts **clip moments**, Mouse counts **aces**, Desk counts **tournament wins**.
- Drops at 10% chance in most cases; can also be added with a Tracker Kit (Gems or Shards).
- Counter only counts while the item is equipped. It does **not** reset when traded; the history adds value.

## 8. Patches & Charms
Full sticker design (slots per item, placement editor, finishes, capsules, Sticker Maker, trading value): [[Sticker System]]. Summary below.
- **Patches** (jerseys): up to 4 slots. Sponsor patches go in sponsor slots automatically (see [[Sponsors]]); free slots take achievement, event or team patches.
- **Stickers** (desks, monitors, PC towers: cosmetic; accessories: add power, see [[Sticker System]] → *Sticker power*): up to 4. Stickers can be scraped (each scrape raises its wear; 5 scrapes removes it).
- **Charms** (monitor): 1 dangling charm, physics-swing in HQ. The headset/keyboard charm is now the **Lucky Charm** accessory ([[Accessories]]).
- Patches/stickers/charms drop from Style Crates and events ([[Case Library]]).

## 9. Championship Edition
- Drops only from **Trophy Cases** after winning a tournament.
- Carries the tournament name + date + your team tag printed on the skin.
- Worlds Championship Edition = gold border and confetti finish.

## Item data
```lua
SkinItem = {
  Uuid, SkinId, Slot,
  Tier = "Common" .. "Mythic",    -- from the skin def; only gives power in accessory slots
  Seed = 0..999,
  Condition = 0.000..1.000,
  Finish = "Standard" | "Holo" | "NeonEdge" | "Prism" | "Void",
  Phase = nil | 1..4,             -- gradient skins only
  Tracker = nil | { Kind = "Wins", Count = 0 },
  Edition = nil | { Tournament, Date, TeamTag },
  Applied = { Patches = {}, Stickers = {}, Charm = nil },
  ObtainedAt, Source,
}
```
Rolled on the server at drop time (see [[Security & Anti-Exploit]]). Client only renders.

## Item card display
`Galaxy Jersey · Twin Suns ✦` → rarity frame, finish badge, condition bar with value (`0.031 Mint`), seed number, phase/fade %, tracker count, edition banner.
Inspect mode: 3D rotating preview (ViewportFrame), zoom, toggle wear overlay.

## Trade value modifiers
Base Value × condition mult × finish mult × signature mult. Used by the fairness meter in [[Trading System]].
| Factor | Multiplier |
|---|---|
| Mint / Fresh / Played-In / Well-Loved / Battle-Worn | 1.6 / 1.2 / 1.0 / 0.9 / 0.85 |
| Holo / Neon Edge / Prism / Void | 2 / 4 / 8 / 20 |
| Signature Pattern | 10–50 (per skin config) |
| 100% Fade / Phase Crown | 5 |
| Tracker | 1.3 |
| Championship Edition | 1.5 (Worlds: 4) |

## Acceptance criteria
- [ ] Same seed + condition always renders identically on every client
- [ ] Item card shows seed, condition, finish, phase/fade, tracker
- [ ] Odds panel lists condition, finish and phase chances
- [ ] Low graphics disables animated finishes without breaking the look

Skin list: [[Skin Library]].

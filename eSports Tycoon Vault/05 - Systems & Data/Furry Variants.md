---
tags: [system, content, cosmetic]
status: designed
updated: 2026-10-21
---
# Furry Variants

Any **generated (non-pro) player** has a small chance to be unboxed as a **furry**: a cartoon animal-person version with an animal head, ears, tail and fur, wearing the same team jersey. It's **cosmetic only**. Stats, role, trait, vibe and name are rolled exactly as normal ([[Player Generator]]).

Furries are a fun surprise in the case reveal, a collectible set in the Collection Log, and a small bump in trade value.

---

## Who can be a furry
| Player type | Can be furry? | Why |
|---|---|---|
| Generated players (case drops, free agents, academy, AI rosters, AI transfer list) | ✅ **4% chance** | The whole point |
| Key players ([[Key Players]]) | ❌ | Fixed, hand-made looks |
| Named pros ([[Pro Player References]], [[Monthly Seasons]]) | ❌ | Fixed identities |
| Dev players ([[Dev Players]]) | ❌ | Real people |
| Friend signings ([[Friend Signings]]) | ❌ | They use the friend's real avatar |
| Founder (you) ([[Founder (You)]]) | ❌ | It's your own avatar |

AI rival teams can field furries too, so you'll see them across the league, not just in your own HQ.

---

## Odds
**Furry chance: 4% of every generated player**, at every rarity. If the player is a furry, the species is rolled:

| Species tier | Species | Chance (of furries) | Overall chance per generated player |
|---|---|---|---|
| Common | Cat 15% · Dog 15% · Bunny 15% · Fox 15% | 60% | 0.6% each |
| Uncommon | Wolf 7% · Bear 7% · Raccoon 7% · Mouse 7% | 28% | 0.28% each |
| Rare | Red Panda 4% · Tiger 3% · Owl 3% | 10% | 0.16% / 0.12% / 0.12% |
| Very Rare | Dragon 1.2% · Axolotl 0.8% | 2% | 0.048% / 0.032% |

- Shown in the Odds panel ([[Screen - Settings & Odds]]): "Any generated player: 4% furry variant", plus the species table. A random trait on a case drop is part of what you're paying for, so it must be disclosed like the rest of the odds ([[Case Unboxing]]).
- The species tier is separate from the card's rarity. A Common card can be a Dragon. That's the fun of it.

---

## Look
Built on top of the normal look step in [[Player Generator]] → Look:
| Part | Furry version |
|---|---|
| Head | Species animal head (cartoon, friendly, big readable shapes) |
| Ears | Species ears (fox points, bunny long ears, bear rounds…) |
| Tail | Species tail with idle sway |
| Fur color | Natural palette per species (8 each). **10% chance of a dyed palette** (pastel, neon, two-tone) |
| Hair / facial hair | Replaced by fur tufts |
| Outfit | Same vibe outfit and team jersey as a human player |
| Headset | **Animal-ear headset variant** that sits between or over the ears (one model per ear shape) |
| Extras | Same extras pool (energy can, plushie, scarf…) |

- **Art direction:** wholesome cartoon style matching [[Art & Audio Direction]]. Readable at phone size, never suggestive, all-ages. Build these as **in-house accessories** (13 heads, 13 ear sets, 13 tails, 4 headset variants) so they all match. Don't pull random catalog items.
- **Species idle at the station:** cat stretches, dog's tail wags faster on wins, bunny's nose twitches, owl's head turns, dragon puffs a tiny smoke ring, and so on.
- **Celebration:** the vibe's celebration plus a species flourish (wolf howl pose, fox spin, bear thump).
- **Nameplate / card:** a small 🐾 badge. Very Rare species get a sparkle on the badge.
- **Bio line:** "{Tag} is a 19-year-old **fox** Entry from Lisbon, Portugal who talks to their mouse."

### Display setting
**Settings → Furry variants: Show / Show as human.** "Show as human" renders furries with a normal generated human look on **your screen only**. The card, odds and value don't change. Some players will want this.

---

## Unboxing moment
Added to the reveal beats in [[Case Unboxing]] → Opening animation beats:
1. Normal rarity reveal (glow, beam, card flip).
2. If furry: **paw-print burst** across the card, a species sound (meow, bark, howl, roar, hoot…), then a "FURRY!" tag with the species name.
3. **Very Rare species** (Dragon, Axolotl): a short server shout ("{team} just unboxed a DRAGON furry!") and a small [[Caster & Commentary]] line ("Is that… a dragon? On a garage team?!").

---

## Voice
Furries use their vibe's generic lines ([[Player Voice Lines]]). On `PLAY` and `WIN` events, a short **species sound** plays before the line (bark, purr, howl, chirp…), and the text bubble adds a small action like "*wags tail*". No extra recorded lines are needed: 13 species sounds × 3 variations.

---

## Collection & achievements
- **Collection Log → "Critter Crew"** set: own one furry of each of the 13 species ([[Achievements & Collections]]). Reward: "Paw Print" desk sticker + **Zookeeper** title.
- Achievements:
  - **Pack Mentality:** 5 furries on your active roster at once.
  - **Here Be Dragons:** unbox a Dragon furry.
  - **Secret: "It's Not a Phase":** win a tournament with an all-furry roster.

## Trade value
Applied on top of the card's Base Value ([[Trading System]] → Value guide):
| Variant | Multiplier |
|---|---|
| Common species | ×1.1 |
| Uncommon species | ×1.2 |
| Rare species | ×1.5 |
| Very Rare species | ×3 |
| Dyed fur palette | ×1.2 more |
The fairness meter and the [[Transfer Market]] price band both use this value.

---

## Seasonal species & fur palettes
Each [[Monthly Seasons]] month nudges which species show up and adds a limited **season fur palette**. The overall furry chance **stays 4%**; only the species mix shifts, so the headline odds never change.

- **Boosted species:** the 2 listed species get **×2 weight** for that month, and the rest of the table scales down to fill 100%. The Odds panel shows the live, adjusted species odds while the season is on.
- **Season fur palette:** during its month, **5% of furries** roll that season's palette instead of a natural or dyed one. Cards carry the season stamp (e.g. `S1 · OCT 2026`), like season pros. The palette **never returns in the same form**; next year's same month gets a recolor ("Jack-o'-Lantern II").

| Month | Season | Boosted species (×2) | Season fur palette |
|---|---|---|---|
| Dec | Winter Major | Wolf, Bear (snowy coats) | **Snowcap**: white with ice-blue tips |
| Jan | Polar Circuit | Fox, Owl (arctic fox, snowy owl) | **Aurora**: teal-to-violet gradient |
| Feb | Crush Cup | Bunny, Cat | **Sweetheart**: pink and red |
| Mar | Spring Split | Bunny, Mouse | **Meadow**: mint with soft yellow |
| Apr | Cyber Spring | Axolotl, Raccoon | **Chrome**: silver holo shimmer |
| May | Bloom Bash | Red Panda, Bunny | **Blossom**: pastel pink and lilac |
| Jun | Summer Cup | Dog, Axolotl | **Beach**: sand with coral patches |
| Jul | Heatwave Open | Dragon, Tiger | **Ember**: orange-to-red glow |
| Aug | Midnight Carnival | Raccoon, Owl | **Neon Night**: navy with neon stripes |
| Sep | Varsity Fall | Owl, Dog | **Varsity**: maroon and gold |
| Oct | Spooky Showdown | Cat, Owl (black cats, barn owls) | **Jack-o'-Lantern**: orange and black |
| Nov | Harvest Clash | Fox, Bear | **Maple**: rust and amber |

Example (October): Cat goes from 15 to 30 weight and Owl from 3 to 6, and the table renormalizes. In practice Cat rises to ~25% of furries and Owl to ~5%, and everything else dips slightly.

- Season palettes count for a **Critter Crew: Seasons** collection (all 12 palettes → animated "Four Seasons" fur frame).
- Trade value: season palette **×1.5** (stacks with the species multiplier, replaces the dyed ×1.2).

---

## Critter Crate
A themed case for players who want furries ([[Case Library]] → Themed cases).
| Field | Value |
|---|---|
| Price | **$12,000** Cash |
| Unlock | Stage 3 |
| Contents | **Players only** (generated players) |
| Rarity odds (C/U/R/E/L/M) | 35 / 35 / 20 / 8 / 2 / 0, same as the Talent Crate |
| Furry chance | **40%** per player (10× normal) |
| Species odds | Same table as above, including the current season's boost and palette |
| Furry pity | If 3 opens in a row give no furry, the **4th is a guaranteed furry** |
| Very Rare bonus | Dragon and Axolotl weights ×1.5 in this crate only (shown in its odds) |
| Look | Pet carrier with a paw-print sticker; the reveal stage gets a cozy pet-shop backdrop |

- Its own pity family ("Critter"), separate from the Core/Themed/Season families.
- Cash only: it's a fun cosmetic chase, not a monetization lever.

---

## Data
```lua
-- Rolled from the card seed with its OWN random stream, so it never shifts other seeded rolls
local furRng = Random.new(seed + FURRY_SALT)
local isFurry = card.GenVersion >= 2 and furRng:NextNumber() < Config.Furry.Chance   -- 0.04
local species = isFurry and WeightedPick(furRng, Config.Furry.Species) or nil
local dyed    = isFurry and furRng:NextNumber() < 0.10
```
- **Nothing new is saved.** Like the rest of the look, it's rebuilt from the seed, so the same card is the same species on every device.
- **`GenVersion`:** cards minted before this feature ships have `GenVersion = 1` and can **never** turn into furries. Otherwise 4% of existing players would change overnight.
- The roll happens on the server when the card is minted (seed is server-made), like every other roll ([[Security & Anti-Exploit]]).
- Config: `Shared/Config/Furry.lua` → `{ Chance = 0.04, Species = { {Id="Cat", Weight=15, Tier="Common"}, ... }, DyedChance = 0.10, Seasonal = { ["2026-10"] = { Boost = {"Cat","Owl"}, Palette = "JackOLantern", PaletteChance = 0.05 } } }`.
- **Seasonal rolls are locked at mint time:** the season boost and palette that applied when the card was minted are stored as `MintSeasonId` on the card (one short string), so the look never changes when the season ends.
- The Critter Crate passes `FurryChance = 0.40` to the generator for its drops; the per-card seed stream is the same.

## Acceptance criteria
- [ ] Over 100,000 generated players, about 4% are furries, and species match the table within normal variance
- [ ] Key players, pros, devs, friend signings and the Founder are never furries
- [ ] The same card is the same species and fur on every client and after rejoin
- [ ] Cards minted before release never become furries
- [ ] "Show as human" changes only the local display
- [ ] Odds panel lists the furry chance and species odds
- [ ] Headset fits every ear shape without clipping
- [ ] Overall furry chance stays 4% in every season; only species weights change
- [ ] A season palette card keeps its palette after the season ends
- [ ] Critter Crate: ~40% furries, and never 4 non-furries in a row

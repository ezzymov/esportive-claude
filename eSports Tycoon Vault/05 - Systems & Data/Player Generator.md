---
tags: [system, content]
updated: 2026-10-20
---
# Player Generator

Most players in the game (Common–Epic) are **randomly generated**: stats, name, country, look, personality. Only a few hand-made **key players** per title and rarity exist ([[Key Players]]), plus named stars at Legendary/Mythic ([[Pro Player References]]) and real friends ([[Friend Signings]]).

## Player mix by source
| Rarity | Generated | Key players | Friends | Named stars |
|---|---|---|---|---|
| Common | ~97% | 2–3 per title | — | — |
| Uncommon | ~95% | 2–3 per title | ✅ | — |
| Rare | ~93% | 2–3 per title | ✅ | — |
| Epic | ~90% | 2–3 per title | ✅ | — |
| Legendary | ~60% | — | rare | ✅ |
| Mythic | 0% | — | — | ✅ only |
Key players drop at about 3–10% of their rarity's player drops, so they feel special but common enough to collect.

## Everything is seeded
Each card has a UUID. `seed = hash(uuid)`. All random choices use `Random.new(seed)`, so the same card always has the same name, stats, face and outfit, on every device and after every rejoin. The server only stores the seed plus anything that changes later (trained stats, morale…).

## 1. Stats
### Step by step
1. **Roll target OVR** in the rarity range ([[Balance Tables]]): Common 30–45, Uncommon 40–55, Rare 50–65, Epic 60–75, Legendary 72–86.
2. **Pick role** (Entry, Support, Sniper, Strategist, Flex), weighted by what the title needs.
3. **Pick archetype** (Wonderkid, Veteran IGL, Lurker, Star AWPer, Utility Support, Streamer Star, Tilt Machine… see [[Pro Player References]]). The archetype sets which stats are high and low.
4. **Spread stats** around the target: high stats +8 to +15, low stats −8 to −15, the rest ±5, then add noise ±4.
5. **Rescale** so the role-weighted OVR equals the target.
6. **Potential** = OVR + random 5–25, max 99, weighted toward low values (most players grow a little; a few grow a lot = Hidden Gems).
7. **Trait** from [[Trait Library]], only traits allowed for that rarity (Common/Uncommon: ⚪, Rare: ⚪🔵, Epic: ⚪🔵🟣). Negative traits ~30% on Common, ~15% on Uncommon, ~5% on Rare.
8. **Comfort map / hate map** from the title's map pool ([[Maps & Map Pool]]).
9. **Age** 15–30 (weighted 17–24). Younger = more Potential on average, older = higher Consistency.

```lua
local function GenerateStats(rng, rarity, role, archetype)
  local range = Rarities[rarity].Ovr                       -- {min, max}
  local target = rng:NextInteger(range[1], range[2])
  local stats = {}
  for _, stat in StatList do
    local bias = archetype.Bias[stat] or 0                  -- e.g. +12 Aim, -10 GameSense
    stats[stat] = target + bias + rng:NextInteger(-4, 4)
  end
  local ovr = WeightedOvr(stats, RoleWeights[role])
  local shift = target - ovr
  for stat, v in stats do stats[stat] = math.clamp(math.round(v + shift), 1, 99) end
  return stats, target
end
```

### Level badge feel
Common ≈ Level 1–3 · Uncommon ≈ 3–5 · Rare ≈ 5–7 · Epic ≈ 7–8 ([[Skill Levels & Ratings]]). Training can push any player above their starting band, up to their Potential.

## 2. Names
### Gamer tag
Natural, pro-style tags (short nonsense like `plonk`, digit swaps like `k1ra`, odd capitals like `ZeKKo`, name-based like `tobsen`, everyday words like `kettle`). Styles, weights, generator rules and the full bank: [[Gamertag Bank]].

Every tag is checked against a bad-word list and a **real pro tag block list** (exact and near matches) before use.

### Real name + country
- First/last names from region lists (North America, South America, Europe, CIS, Middle East, Africa, East Asia, Southeast Asia, South Asia, Oceania), so the world feels international.
- Country flag drives a small bio line ("From Lisbon, Portugal").
- Region weights shift with the Rebirth region ([[Franchise Rebirth]]).

### Bio line (template)
"{Tag} is a {age}-year-old {role} from {country} who {quirk}." Quirk list: "never takes off their headset", "eats cereal at 3am", "streams every night", "has a lucky keyboard", "talks to their mouse", "speedruns old games"…

## 3. Look (avatar design)
Built as a `HumanoidDescription` from curated asset pools, then the team jersey goes on top ([[Skin Pattern System]]).
| Part | Pool | Notes |
|---|---|---|
| Skin tone | 12 tones | Even weighting |
| Body | Height 0.95–1.05, width 0.9–1.1 | Subtle variety |
| Face | 30 faces (classic + expressive) | Archetype picks mood |
| Hair | 40 styles × 10 colors (natural + dyed) | Dyed colors more common at Rare+ |
| Facial hair | 8 styles | Age 20+ only, 25% chance |
| Glasses | 10 styles | 20% chance (Nerd vibe 70%) |
| Headwear | caps, beanies, bandanas, hoods, none | Swapped for headset during matches |
| Headset | Matches part slot skin | Always on at a station |
| Extras | energy can, plushie, gum bubble, wristband, scarf | 1 extra max |

Use only Roblox catalog/free assets the game is allowed to use, listed by ID in `Shared/Config/AvatarPools.lua`.

### Furry variant
**4%** of generated players roll a furry look (animal head, ears, tail, fur) instead of a human one. It's cosmetic only and uses its own seeded random stream. Species odds, seasonal species boosts, the Critter Crate, art rules, unboxing beat and data: [[Furry Variants]].

### Vibes (personality packs)
Vibe sets look bias, idle animation, celebration and which generic voice-line pool the player uses ([[Player Voice Lines]]).
| Vibe | Look bias | Idle at station | Celebration |
|---|---|---|---|
| Tryhard | Cap backwards, wristbands | Leans in, fast typing | Fist pump |
| Chill | Hoodie, beanie | Leans back, sips drink | Thumbs up |
| Nerd | Glasses, sweater | Pushes glasses up, notes | Calculator tap |
| Hype | Bright hair, sunglasses | Bounces in chair | Desk Slam |
| Streamer | Cat-ear headset, LED wristband | Waves at "camera" | Heart hands |
| Veteran | Beard, plain tee | Stretches, coffee | Calm nod |
| Mysterious | Hood, face mask | Barely moves | Slow clap |
| Goofball | Funny hat, mismatched colors | Spins chair | Floss-Bot |
Vibe weights tie to trait: Streamer trait → Streamer vibe 70%, Team Leader → Tryhard/Veteran, Class Clown → Goofball.

## 4. Where generated players appear
- Free agent board (refresh every 10 min)
- Case drops ([[Case Library]])
- Youth tryouts ([[Academy & Youth]])
- AI team rosters ([[Rivalries & Storylines]]): AI teams use generated players with a fixed seed per team, plus key players as their stars.
- AI Transfer List ([[Trading System]])

## 5. Data
```lua
PlayerCard = {
  Uuid, Seed, Source = "Generated" | "Key" | "Star" | "Friend" | "Founder" | "Pug",
  KeyId = nil,                -- set for key players
  FriendUserId = nil,         -- set for friend signings
  Rarity, Role, Archetype, Vibe,
  Stats = {...},              -- current (after training)
  Potential, Trait, ComfortMap, HateMap,
  Age, Country, GenVersion,   -- GenVersion ≥ 2 can roll a furry variant (see [[Furry Variants]])
  MintSeasonId,               -- season active at mint (locks seasonal furry boost/palette)
  -- Name, Bio, Look are rebuilt from Seed (not stored)
}
```

## Acceptance criteria
- [ ] Same UUID always produces the same name, look and starting stats
- [ ] 10,000 generated Rare players: OVR all within 50–65, roles spread as configured
- [ ] No two of 100 random players look identical
- [ ] Name block list catches every test bad word

---
tags: [feature, cosmetics, identity, hq]
status: building
priority: P1
stage: 1
updated: 2026-10-21
system_type: Cosmetic
engine_layer: ServerService
dependencies:
  - "[[Team Identity]]"
  - "[[Plot & HQ]]"
  - "[[HQ Era Visual Guide]]"
  - "[[Skin Pattern System]]"
  - "[[Sponsors]]"
affected_ui:
  - "[[Screen - Team Creator]]"
roblox_execution_environment: ServerScriptService
---
# Jersey Progression

## Summary
What your team wears grows with your HQ. In the garage everyone wears whatever T-shirt they own. By the Gaming House you have real esports jerseys, and in the Arena you walk out in stage kits with title patches on the sleeve. **Colors can be changed at any time, for free, at every tier.**

Extends the jersey part of [[Team Identity]]. Matches the HQ looks in [[HQ Era Visual Guide]].

## How a kit is built (4 layers)
| Layer | What it is | Unlocked by | Changeable |
|---|---|---|---|
| **1. Garment** | The kind of clothing: tee, practice top, jersey, stage kit… | **HQ era + HQ Level** (this note) | Pick any garment you've unlocked |
| **2. Colors** | Body, trim, accent (+ print/number color) | Always | Anytime, free |
| **3. Pattern** | A jersey skin from the [[Skin Library]] (Stripes, Galaxy, Pixel Camo…) with seed, condition and finish ([[Skin Pattern System]]) | Cases, shop, trades | Anytime |
| **4. Details** | Crest/logo, number, name or nickname, patches, collar, sleeves | HQ era + HQ Level | Anytime |

How a pattern looks depends on the garment: on a Garage tee it's a **small chest print**, on a Café tee a **big front print**, and from the Team Jersey (Gaming House) on it covers the **whole garment**. Owning a Galaxy jersey early still shows, it just gets bigger as you grow.

---

## Unlock ladder
HQ Level = number of pads bought ([[Plot & HQ]] → *Buy pad rules*). Levels below are **proposed**. Re-tune them once `Pads.lua` has the real pad count per era.

| Era | HQ Lv | Unlock | Type |
|---|---|---|---|
| Garage | 0 | **Own Tees**: each player wears a random tee color of their own | Garment |
| Garage | 0 | Kit color picker (Founder's tee only) | Color |
| Garage | 2 | **Marker Tee**: team tag hand-written on the front | Detail |
| Garage | 3 | **Thrift Hoodie** and **Flannel Over Tee** | Garment |
| Garage | 4 | **Iron-On Letters**: crooked iron-on team name | Detail |
| Garage | 5 | **Matching Tees (3-pack)**: whole roster in the same color for the first time | Garment |
| Café | 6 | **Screen-Print Tee**: logo printed on the chest, 2 colors | Garment |
| Café | 9 | Tag printed on the back | Detail |
| Café | 11 | **LAN Night Polo** and **Bucket Hat** | Garment |
| Café | 14 | Sleeve print | Detail |
| Training Center | 16 | **Practice Top**: athletic cut, raglan sleeves, 3 colors | Garment |
| Training Center | 18 | **Numbers** on front and back | Detail |
| Training Center | 21 | **Scrim Pinnies**: mesh bibs worn over the top in scrims | Garment |
| Training Center | 24 | **Track Jacket**, **Headband**, **Captain armband** (Founder) | Garment |
| Training Center | 27 | Names on the back | Detail |
| Gaming House | 31 | **Team Jersey**: full-body sublimated, patterns cover the whole shirt | Garment |
| Gaming House | 31 | **Home & Away** colorways | Color |
| Gaming House | 34 | Collar and sleeve styles | Detail |
| Gaming House | 37 | **Team Hoodie** (lounge wear) and **Team PJs** (dorms) | Garment |
| Gaming House | 42 | Nickname on the back instead of the name | Detail |
| Gaming House | 46 | All **4 patch slots** (sponsors fill theirs automatically, [[Sponsors]]) | Detail |
| Studio Campus | 51 | **Pro Kit**: stitched crest, embroidered name, sleeve sponsor | Garment |
| Studio Campus | 55 | **Third (Alt) kit** colorway | Color |
| Studio Campus | 60 | **Media Day** outfits: varsity jacket, crest blazer | Garment |
| Studio Campus | 65 | **Streamer Fit** (worn in the Streaming Booth) | Garment |
| Studio Campus | 70 | **Replica Kit** sold in your Merch Store, worn by fans | Merch |
| Arena | 76 | **Stage Kit**: metallic trim, glow piping in your accent color | Garment |
| Arena | 80 | **Walk-out Jacket**: bomber with LED trim, worn in the tunnel | Garment |
| Arena | 85 | **Title patches** on the sleeve, one per title won (automatic) | Detail |
| Arena | 90 | Glow piping pulses on clutch rounds and wins | Detail |
| Arena (Stage 10) | — | **Worlds Kit**: gold star over the crest, **Champion Gold** trim | Garment |

New unlocks pop a toast with a rotating preview: *"New kit unlocked: Practice Top. Try it on?"* and a **Try it** button.

---

## The tiers in detail

### 1. Garage: "Whatever we've got" (HQ Lv 0–5)
The team doesn't match yet. That's the joke and the point.
- **Own Tees:** every player shows up in a random plain tee from their own wardrobe (seeded, so it stays the same). Hiring more players makes the garage look messier and more colorful.
- **Founder** wears your chosen tee color. The color picker works from minute one.
- **Marker Tee:** your tag in thick black marker on the chest, a little lopsided.
- **Thrift Hoodie:** faded, slightly too big, sleeves pushed up. **Flannel Over Tee:** open flannel over the tee.
- **Iron-On Letters:** the team name in mismatched iron-on letters, one letter slightly peeling.
- **Matching Tees (3-pack):** the first time the whole roster wears the same color. Small story beat: the roster cheers the first time it's equipped.
- Patterns show as a small chest print.

### 2. Café: "Merch on a budget" (HQ Lv 6–15)
- **Screen-Print Tee:** your logo printed on the chest, with a slightly cracked print texture. Two colors: shirt + print.
- Tag across the back shoulders, later a sleeve print.
- **LAN Night Polo:** a collared polo for the Café LAN Night boss ([[Stage Beat Sheets 2-10]]).
- **Bucket Hat** with the logo on the front.
- Easter egg: a **Byte & Brew apron** cosmetic that players can put on over the tee.
- Patterns show as a big front print.

### 3. Training Center: "Looking the part" (HQ Lv 16–30)
- **Practice Top:** athletic dry-fit look, raglan sleeves in the trim color, a small crest. Three color slots from here on.
- **Numbers** front and back (players pick 0–99, auto-assigned by default).
- **Scrim Pinnies:** mesh bibs with a big number, worn over the top during scrims. Home side in your primary color, the opponent in a contrasting one.
- **Track Jacket** with a stripe down the sleeve. **Headband.**
- **Captain armband** for the Founder (or any player you name captain).
- Names on the back.

### 4. Gaming House: "Real jerseys" (HQ Lv 31–50)
The moment the team looks like a real esports team.
- **Team Jersey:** full-body sublimated print. **Patterns now cover the whole jersey** with seed, condition and finish showing in full.
- **Collars:** crew, V-neck, polo, mandarin. **Sleeves:** short, long, raglan, long with thumbholes.
- **Home & Away:** two saved colorways. Home is worn at your HQ and home matches; Away is used when you play at someone else's place or in tournaments, and when the opponent's colors are too close to yours.
- **Team Hoodie** for the lounge, **Team PJs** in the dorms (fatigued players nap in them).
- Nickname on the back, and all **4 patch slots** ([[Skin Pattern System]] → *Patches*). Your first sponsor's patch, signed at Stage 4, moves onto the chest.

### 5. Studio Campus: "Pro organization" (HQ Lv 51–75)
- **Pro Kit:** a premium cut with a stitched crest (raised 3D detail), embroidered name, sleeve sponsor slot.
- **Third (Alt) kit:** a third colorway for special events and season matches ([[Monthly Seasons]]).
- **Media Day:** varsity jacket with chenille letters, or a blazer with an embroidered crest. Shows in clip thumbnails and the Global Top Teams spotlight ([[Social & Multiplayer]]).
- **Streamer Fit:** oversized team hoodie + headset, worn by whoever is in the Streaming Booth.
- **Replica Kit:** your current jersey goes on sale in your Merch Store. **Fans in your crowd start wearing it** ([[Fan Base & Arena]]). Merch drops ("Limited Drop" in [[Screen - Sponsors]]) are designed with the same editor.
- **Staff outfits:** coach, analyst and manager switch from casual to team polos.

### 6. Arena: "Stage kits" (HQ Lv 76+)
- **Stage Kit:** tournament-grade jersey with metallic trim and **glow piping** in your accent color. It reads well under stage lighting.
- **Walk-out Jacket:** a bomber with LED trim worn on the tunnel walk-out. Players take it off and hang it on the booth chair before the match.
- **Title patches:** one sleeve patch per title won (Local Cup, Nationals, Worlds…), added automatically, in the order you won them.
- Glow piping pulses on clutch rounds and flashes on the win.
- **Worlds Kit** (Stage 10, after winning Worlds): a gold star above the crest and **Champion Gold** metallic trim. Only Worlds winners can use Champion Gold.

---

## Colors
| Slot | Used on | From |
|---|---|---|
| **Body** | Main shirt color | Garage |
| **Print** | Marker, iron-on, screen print, numbers | Garage (marker), Café (print) |
| **Trim** | Collar, sleeves, side panels | Training Center |
| **Accent** | Stripes, piping, glow (Arena) | Training Center |

- **Follow team colors** (on by default): kit colors match the team colors from [[Team Identity]], so the HQ (banners, LED strips, seats) and the kit stay in sync. Turn it off to pick kit colors separately.
- **Palette:** 32 curated swatches, plus a **full color picker** (hue/saturation/brightness wheel + hex field).
- **Free and unlimited.** No cost, no cooldown. Colors are your team's identity, not something to sell. Paid cosmetics are patterns and garments, never colors.
- **Readability guard:** if the number or name color is too close to the body color, the editor warns and adds an outline automatically, so numbers stay readable on phones.
- **Home vs Away:** each colorway has its own 4 slots (Gaming House on). **Clash rule:** if both teams' kits are too close in a match, the away side switches to its Away kit automatically.
- **Reserved:** Champion Gold (metallic) only for Worlds winners. Normal yellow and gold colors are free for anyone.
- **How color meets patterns:**
  - **Hue ✅ skins** in the [[Skin Library]]: the pattern ink keeps its seeded hue; the base takes your Body color.
  - **Fixed-color skins** (Galaxy, Aurora, Dragon Dance…): the pattern sets the body; your colors only apply to trim, numbers and piping.
  - Neon Edge finish ([[Skin Pattern System]]) already glows in team colors, so it follows your Accent.

## Where the kit shows
Roster NPCs at stations, your own avatar in the HQ (Settings → `AvatarInJersey`), furry players ([[Furry Variants]]), match broadcasts and clips ([[Clip Cutscene System]] → Actors), bracket and scoreboard colors, clip thumbnails, Global Top Teams, and fans wearing replicas.

## Rebirth & regions
- Garments you've unlocked **stay unlocked after rebirth** (cosmetics are kept, see [[Franchise Rebirth]]). Older tiers become **Throwback** kits.
- After a rebirth, the team starts back in **Matching Tees**, so the garage still looks humble. Higher kits are in your wardrobe straight away. Equip one and Aunt Dee jokes: "Fancy jersey for a garage team."
- Region jerseys from the [[Skin Library]] (Sunset Surf, Dune Camo, Cloud Walker…) work as patterns on any garment.

## Server / data requirements
```lua
Profile.Team.Jersey = {
  Garment = "TeamJersey",            -- id from Shared/Config/Kits.lua
  FollowTeamColors = true,
  Colorways = {
    Home = { Body, Print, Trim, Accent },  -- Color3 stored as hex strings
    Away = { Body, Print, Trim, Accent },
    Alt  = { Body, Print, Trim, Accent },  -- Studio Campus+
  },
  PatternSkinUid = nil,               -- owned jersey skin instance (Skin Pattern System)
  Collar = "V", Sleeves = "Short",
  NumberMode = "Auto", NameMode = "Name" | "Nickname" | "None",
  Patches = { [1..4] = PatchId },     -- sponsor slots filled by SponsorService
  Overrides = { [PlayerCardId] = { Number = 7, Captain = true } },
}
-- Profile.Inventory.Cosmetics.Kits = { [GarmentId] = true }  -- unlocked garments, kept on rebirth
```
- `Shared/Config/Kits.lua`: every garment with `Id`, `Era`, `HQLevel`, `ColorSlots`, `PatternScale` ("Chest" | "Front" | "Full"), `DetailSlots`.
- Title patches are not stored per kit. They're built from `Trophies` when the kit is drawn.
- Remote: `Team/SetKit(kitTable)` (RF). Server checks: garment unlocked, pattern skin owned and not in escrow ([[Skin Marketplace]]), colors are valid Color3 hex, Champion Gold only if Worlds won, nickname filtered with `TextService`, numbers 0–99. Rate limit 2/s. Kit changes go through `DataService:Update` ([[Data Persistence]]).
- **Rendering (prototype first):** build each garment as layered clothing with separate tintable pieces for body, trim and accent, plus a pattern overlay and a `SurfaceGui` for number and name. If runtime tinting isn't good enough on phones, fall back to pre-made textures for the 32 palette swatches only, and turn off the free picker.

## UI screens
- [[Screen - Team Creator]] → Jersey tab: garment grid (locked ones show "HQ Lv 31"), color slots with swatches + picker, Home/Away/Alt toggle, pattern picker from owned jersey skins, details, rotating preview on an avatar.
- Re-openable any time from the Roster screen ([[Screen - Roster]]) → "Kit" button.

## Edge cases
- **Pattern skin listed on the market:** it's in escrow, so the kit falls back to the plain garment until the listing ends.
- **Downgrading the garment:** allowed, any unlocked garment any time.
- **Two teams with the same colors in a match:** the clash rule switches the away team's kit. In the Garage era (no Away kit yet), the away side wears scrim pinnies.
- **Low graphics:** glow piping and animated finishes become static.

## Acceptance criteria
- [ ] New team in the garage: roster wears mixed tees; Matching Tees at HQ Lv 5 makes them all match.
- [ ] Each era unlock appears at its HQ Level with a toast and preview.
- [ ] Changing a color updates every roster NPC within 1 s, for free.
- [ ] Follow team colors on: changing team colors also changes the kit and the HQ tints.
- [ ] A Galaxy jersey skin is a chest print on a tee and full-body on the Team Jersey.
- [ ] Number stays readable with any color combo (auto outline).
- [ ] Title patches appear after winning a cup, with no manual step.
- [ ] Champion Gold can't be set by a team that hasn't won Worlds (server rejects).

## Open questions
- Let each player pick a personal number in the Garage era, or only from the Training Center on?
- Should visitors be able to buy your Replica Kit for their own avatar (Robux, a UGC-style item)? It would need Roblox UGC rules checked.
- Are Home/Away kits enough, or add a "Clutch kit" that players swap into for finals?

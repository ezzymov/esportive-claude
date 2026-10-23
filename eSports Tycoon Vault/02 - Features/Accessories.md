---
tags: [feature, cosmetics, progression]
status: designed
priority: P1
stage: 2
updated: 2026-10-21
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Skin Pattern System]]"
  - "[[Sticker System]]"
  - "[[PC Setups]]"
  - "[[Match Simulation]]"
  - "[[Balance Tables]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Tech Shop]]"
  - "[[Screen - Sticker Editor]]"
  - "[[Screen - Roster]]"
roblox_execution_environment: ServerScriptService
---
# Accessories

## Summary
Accessories are the **cosmetics that make a player better**. Each roster player carries 6 personal items (mouse, keyboard, headset, arm sleeve, glasses, lucky charm). Each one boosts **one stat**, and **stickers** applied to it add more. Accessories belong to the player, not the seat: when a player moves station, goes to the bench, or is traded, their accessories go with them (traded players drop their accessories back into your inventory).

This is where cosmetics get a real job. Everything else stays pure style: jerseys, weapon/kart/hero skins, knives, in-match gloves, Agents, desk/monitor/tower skins ([[Skin Pattern System]]).

> **Ranked is pure skill.** All accessory and sticker power is switched off in the Ranked Ladder (see *Gear Mode* below).

## The six accessories
| Accessory | Stat | Sticker slots | Unlock | Notes |
|---|---|---|---|---|
| **Mouse** | Aim | 2 | Stage 2 | Moved from PC parts |
| **Keyboard** | Consistency | 3 | Stage 2 | Moved from PC parts |
| **Headset** | Teamwork | 2 (ear cups) | Stage 2 | Moved from PC parts |
| **Arm Sleeve** | Reflexes | 2 | Stage 3 | Compression sleeve on the mouse arm |
| **Glasses** | Game Sense | 2 (both arms) | Stage 3 | Blue-light gaming glasses |
| **Lucky Charm** | Clutch | 1 (charm face) | Stage 3 | Clips onto the headset and swings with physics. Replaces the old headset/keyboard charm slot; monitor charms and the Aim Arena weapon charm stay cosmetic |

An accessory **is** a skin: it uses the full [[Skin Pattern System]] (seed, condition, finish, Signature Patterns, phases, Tracker). The existing mouse, keyboard and headset skins in the [[Skin Library]] (Duct Tape, Pixel Pal, Comet Tail, Nebula…) are accessories now. The Tech Shop sells plain solid-color models (Rusty Clicker, Clikk Feather 2, Pulse Halo…, see [[Content Catalog]]).

## Where power comes from
**1. Tier (the accessory's rarity) sets the base bonus.** Flat points on the accessory's stat:
| Tier | Base bonus | Max tier that counts |
|---|---|---|
| Common | +1 | Stage 2 |
| Uncommon | +2 | Stage 2 |
| Rare | +3 | Stage 3 |
| Epic | +4 | Stage 4 |
| Legendary | +6 | Stage 6 |
| Mythic | +8 | Stage 8 |
- **Stage tier cap:** you can own (trade for) any tier, but the bonus only counts up to your stage's max tier. A Stage 3 team with a Legendary mouse gets the Rare +3 until Stage 6. The item card shows "Full bonus at Stage 6". This stops trades from skipping progression.

**2. Seed, condition, finish, Signature Pattern, phase, fade and Tracker never change power.** They stay pure look and trade value. A Battle-Worn Comet Tail is exactly as strong as a Mint one. Collectors chase looks; managers chase tiers.

**3. Stickers add tuning.** Every sticker has a **stat tag** (Aim, Reflexes, Game Sense, Teamwork, Clutch, Consistency) and its finish sets the size ([[Sticker System]] → *Sticker power*):
| Finish | Paper | Glossy | Holo | Glitter | Foil | Gold | Lenticular |
|---|---|---|---|---|---|---|---|
| Power | +0.5 | +1 | +1.5 | +2 | +2.5 | +3 | +4 |
- **Matching:** a sticker whose tag matches the accessory's stat gives full power. Off-stat gives **half**, to its own tagged stat. A Gold Clutch sticker on a mouse = +1.5 Clutch.
- **Full Set:** every slot on the accessory filled with stickers from the same capsule → **+1** to the accessory's stat (2+ slots needed, so the Lucky Charm can't get it).
- **Signed gear:** a player's own signature sticker ([[Key Players]], [[Pro Player References]]) on their own accessory → **+2 Clutch** on top of the sticker's normal power. Only counts on the player whose signature it is.
- Sticker power is flat until the sticker is gone. Scraping is visual only; the sticker keeps full power until it's scraped to 0 or peeled with a Sticker Saver.

**4. Cap.** Total gear bonus per stat (accessories + stickers) is capped at **+12**. Gear **can** push a stat past Potential; that's the payoff.

### Example
Sniper with Aim 74:
- Legendary "Comet Tail" mouse: +6 Aim
- Gold Aim sticker (+3) + Holo Aim sticker (+1.5), both from the Neon Nights Capsule: +4.5, Full Set +1
- Total +11.5 → shown as **Aim 74 +11.5**, plays as 85.5.

## Gear Mode (ranked vs scrims)
Every match runs in one of two modes, decided on the server ([[Match Simulation]]):
| Mode | What counts |
|---|---|
| **Full** | Everything: stats, traits, accessories, stickers, station parts, staff, home field |
| **Pure** | Only the players themselves: stats, role, trait, morale, fatigue, chemistry, tactic, maps. **No** accessories, stickers, station parts, coach/staff bonus or home field |

| Match type | Mode |
|---|---|
| **Ranked Ladder** | **Pure, always.** Season Rank leaderboard is pure skill |
| **Scrim** (vs AI) | Full by default; **"Pure skill" toggle** on the scrim screen |
| **Friend Scrim** | Full by default; the challenger picks **Full** or **Pure** on the challenge card. Applies to both sides, including snapshot matches vs offline teams |
| **Tournaments** (Local Cup → Worlds), seasons | Full |

- Roster cards show the gear bonus in a separate color (`Aim 74 +11.5`). In a Pure match the `+` part is greyed out and the match intro shows a **PURE** tag.
- The **Level 1–10 badge and OVR use base stats only**, so they always mean pure skill ([[Skill Levels & Ratings]]). The card shows "Gear OVR" in small text underneath.

## Getting accessories
| Source | What |
|---|---|
| **Tech Shop** | Plain models, Common–Rare. Stock rotates ([[Screen - Tech Shop]] → Accessories tab) |
| **Cases** | Patterned accessories at the skin's rarity ([[Case Library]]). Role cases weight their role's stat (Sniper Case → more mice and charms) |
| **Tournaments** | Trophy Cases drop Championship Edition accessories |
| **Achievements / Pass / events** | Fixed accessories, often with a free sticker |
| **Crafting** | Shards → chosen accessory (Common–Epic) |
| **Trading / Market** | Like any skin ([[Trading System]], [[Skin Marketplace]]) |

**Free path rule ([[Monetization]]):** every tier and every sticker stat tag × finish up to **Gold** must be obtainable without Gems or Robux (tournaments, achievements, events, crafting). Lenticular gets at least one free event source per season. Gem capsules can shift odds, never lock access.

## Equipping
- `PlayerCard.Accessories = { Mouse, Keyboard, Headset, Sleeve, Glasses, Charm }`, each an item Uuid or nil.
- One item can be equipped on one player at a time (same rule as loadouts).
- Empty slot = no bonus, default grey model.
- Equipped accessories show on the roster NPC in the HQ (headset on head, glasses on face, sleeve on arm, charm swinging) and in match cutscenes and clips.
- **Bench players keep their gear**; it just doesn't count until they play.
- Changing accessories is free and instant, except during a live match or while the player is in a trade.

## Rebirth
Accessories are cosmetics, so they're **kept** on rebirth ([[Franchise Rebirth]]). The **stage tier cap** resets with your stage, so a rebirthed team's Mythic mouse gives +1 again until Stage 2, then grows back. That keeps early stages humble without taking anything away.

## Server / data requirements
```lua
-- Accessory items are SkinItems with an accessory Slot (see Skin Pattern System → Item data)
SkinItem.Slot = "Mouse" | "Keyboard" | "Headset" | "Sleeve" | "Glasses" | "Charm"
SkinItem.Tier = "Common" .. "Mythic"    -- from the skin def; drives power

PlayerCard.Accessories = { Mouse = uuid?, Keyboard = uuid?, Headset = uuid?,
                           Sleeve = uuid?, Glasses = uuid?, Charm = uuid? }
```
- `Shared/Config/Accessories.lua`: slot → stat, sticker slot count, unlock stage, tier bonus table, stage tier caps, `GearCapPerStat = 12`.
- `GearService:GetGearStats(playerCard, profile)` → `{ Aim = 11.5, ... }`, already capped and stage-limited. Used by the sim and the roster UI. Never trust a client value.

### Remotes
| Remote | Args | Server checks |
|---|---|---|
| Accessory/Equip | playerCardId, slot, itemUuid | owns item, item slot matches, slot unlocked at stage, item not equipped on someone else, not in escrow/trade, not mid-match. Rate limit 4/s |
| Accessory/Unequip | playerCardId, slot | owns player |
| Match/SetGearMode | matchType, mode | mode allowed for that type (Ranked always Pure) |

## UI screens
- [[Screen - Roster]] → player card → **Gear** tab: 6 slots around a 3D model of the player, stat bonus per slot, total per stat with the +12 cap bar, "Full bonus at Stage N" warnings.
- [[Screen - Tech Shop]] → Accessories tab.
- [[Screen - Sticker Editor]] → accessories show stat tags and a live power preview.

## Edge cases / exploit risks
- **Equipping during a match:** blocked; the sim takes a gear snapshot at match start.
- **Trading a player:** their accessories return to your inventory first; they're never sent with the player.
- **Same item on two players** after a failed save: on load, `GearService` keeps the first and unequips duplicates.
- **Friend scrim mode spoofing:** the server stores the mode on the challenge; the client can't change it after sending.
- **Market listing:** a listed accessory is in escrow and unequipped automatically; the player loses the bonus until the listing ends.

## Acceptance criteria
- [ ] A mouse adds its tier bonus to Aim, limited by the stage tier cap
- [ ] Matching and off-stat stickers add full / half power; Full Set and Signed gear bonuses apply
- [ ] Gear bonus per stat never goes above +12
- [ ] Ranked matches ignore accessories, stickers, station parts, staff and home field (sim batch test: same win rate with and without gear)
- [ ] Scrim and friend scrim Pure toggles work for both sides, including offline snapshots
- [ ] Level badge and OVR don't change when gear changes
- [ ] Condition/seed/finish changes never change power

## Open questions
- Should Arena-era teams get a 7th slot (e.g. "Stage Jacket" → Morale)? Lean no for now.
- Is +12 the right cap? Check in sim batches: a full-gear team vs a no-gear team with the same stats should win ~65–70%, not 90%.

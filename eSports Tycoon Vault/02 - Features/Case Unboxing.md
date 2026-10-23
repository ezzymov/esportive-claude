---
tags: [feature]
status: idea
priority: P0
stage: 2
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Case Library]]"
  - "[[Balance Tables]]"
  - "[[Economy Design]]"
  - "[[Furry Variants]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Case Opening]]"
  - "[[Screen - Settings & Odds]]"
roblox_execution_environment: ServerScriptService
---
# Case Unboxing

Spend currency to open cases that drop players, PC parts, and cosmetics. Main dopamine driver.

## Case tiers
| Case | Price | Currency | Drops |
|---|---|---|---|
| Rookie Crate | 500 | Cash | Common–Rare players, basic parts |
| Pro Crate | 5,000 | Cash | Rare–Epic players, mid parts |
| Elite Crate | 50 | Gems | Epic–Legendary, top parts |
| Legend Crate | 250 | Gems / Robux | Legendary–Mythic, exclusive skins |
| Event Crate | varies | Event tokens | Limited-time items |

Drops above are the main range. Exact odds are in [[Balance Tables]]. 40+ more cases (themed, role, title, region, event, special, crafting) are in [[Case Library]].

## Rarity
Common (60%) · Uncommon (25%) · Rare (10%) · Epic (4%) · Legendary (0.9%) · Mythic (0.1%) — **tune per case, show odds in UI**.

## Drop types
- Player cards (stats + potential + trait)
- PC parts (see [[PC Setups]])
- Cosmetics: jersey, logo pack, desk skin, emote
- Boosters: training XP, clip-view boost, 15-min income boost
- Staff cards (coach/analyst)

## Rules
- **Pity timer:** guaranteed Epic+ every N opens, Legendary+ every M.
- **Duplicates:** convert to Shards → craft chosen items.
- **Odds panel:** always accessible from the case screen.
- **Server-authoritative:** roll on server, send result to client for animation only.
- Skip button + "open ×5/×10" for veterans.

## Opening animation beats
1. Case drops onto the stage, lights dim
2. Shake/charge, color of glow telegraphs rarity
3. Lid pops, beam, card flip
4. Stats appear, "NEW!" or duplicate shard count
5. Crowd cheer SFX scaled to rarity
6. If the player is a **furry variant**: paw-print burst, species sound, "FURRY!" tag ([[Furry Variants]])

## Dependencies
[[Economy Design]] · [[Player Hiring]] · [[Data Schema]] · UI: [[Screen - Case Opening]]

## Policy note
Paid random items on Roblox have disclosure/age rules — verify current Roblox policy before adding Robux cases.

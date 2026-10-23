---
tags: [feature, new]
status: idea
priority: P1
stage: 1
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Daily Loops & Quests]]"
  - "[[Furry Variants]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Quests]]"
roblox_execution_environment: ServerScriptService
---
# Achievements & Collections

## Summary
Long-tail goals for completionists. Achievements reward milestones; the **Collection Log** (Pokédex-style) tracks every player, part and cosmetic you have ever owned.

## Achievement categories
| Category | Examples |
|---|---|
| Business | Earn $1M total · Buy 50 pads · Reach HQ Level 100 |
| Roster | Own a Legendary · Full roster of Epic+ · Max a stat to 99 |
| Competition | Win first scrim · Win 10 tournaments · Undefeated season · Beat a team 2× your power |
| Unboxing | Open 100 cases · Pull a Mythic · Pity-break a Legendary |
| Clips | First clip · 1M total views · Clip of the Week |
| Social | Visit 10 HQs · Win a friend scrim · Complete a trade |
| Secret | Lose 10 in a row ("Character Building") · Name team "Garage" and win Worlds |

- Each has Bronze / Silver / Gold tiers. Rewards: Gems, titles, profile badges, decor.
- **Titles** show under your team name ("Case Goblin", "Clutch Merchant", "Garage Legend").

## Collection Log
- Grid per category (Players by rarity, Parts by slot, Jerseys, Decor, Trophies).
- Unowned items shown as silhouettes with rarity frame. Tapping shows where it drops.
- Set completion rewards: complete all Rare parts = exclusive desk skin, etc.
- Collection score is a leaderboard stat.
- **Critter Crew** set: one furry of each species ([[Furry Variants]]), reward: Paw Print sticker + Zookeeper title.

## Roblox badges
Use real Roblox badges for ~10 major milestones only (first win, first Mythic, Worlds champion, first rebirth). Badges show on the player's Roblox profile and help discovery.

## Server / data requirements
- `Profile.Achievements = {[id] = tier}`, `Profile.Collection = {[itemId] = true}`
- Hooked into objective engine in [[Daily Loops & Quests]].

## Acceptance criteria
- [ ] Toast on achievement unlock with tier color
- [ ] Collection Log shows silhouettes for unowned items

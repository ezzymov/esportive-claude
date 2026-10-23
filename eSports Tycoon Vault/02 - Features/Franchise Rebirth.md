---
tags: [feature]
status: idea
priority: P1
stage: 10
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Balance Tables]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Rebirth]]"
roblox_execution_environment: ServerScriptService
---
# Franchise Rebirth (prestige)

## Summary
After winning Worlds, the player can **re-found the franchise in a new region**. They lose most progress but gain Legacy Points and permanent perks, so the next run is faster and reaches higher. This is the long-term retention loop.

## What resets vs keeps
| Resets | Keeps |
|---|---|
| Cash, Shards | Gems |
| Roster (except 1 "Legend" you choose and your **Founder**, who keeps 50% of stats and gains +5 Potential) | Trophies (moved to Legacy Hall) |
| Stations, parts | Cosmetics, decor items |
| HQ pads | Team name, logo, jersey |
| Staff | 25% of Followers |
| Stage → 1 | Achievements, collection log |

## Legacy Points
`LP = floor( sqrt(TotalFameThisRun / 1000) ) + trophies × 2 + 5 × (WorldsTitles)`

## Legacy perk tree (spend LP)
| Branch | Example perks |
|---|---|
| Business | +10% income per rank (5 ranks), start with $5k, cheaper pads −5% |
| Talent | +1 roster slot (once), starting free agent is Rare, +5% training XP |
| Hype | +10% clip views, start with 1k Followers, sponsors 1 tier earlier |
| Luck | +1 pity step faster, 1 free Pro Crate per rebirth |
| Legend | Keep 2 Legend players, Legend player +5 all stats |

## Regions (new start each rebirth)
| Rebirth | Region | Flavor | Modifier |
|---|---|---|---|
| 0 | Home Region | Default | — |
| 1 | Neon Coast | Beach city, sunset palette | +clip views |
| 2 | Frost Peaks | Snow HQ, cozy cabins | +training XP |
| 3 | Sandstorm Bay | Desert megacity | +prize money |
| 4 | Sky Islands | Floating arenas | +sponsor pay |
| 5+ | Rotating "Mixed" | Random modifier | stacking |

Region changes HQ skin, AI team names, and one rule modifier.

## Flow
1. Win Worlds → "Franchise Legacy" screen unlocks.
2. Screen shows what is kept/lost and the LP you will earn.
3. Choose Legend player(s).
4. Confirm twice (irreversible). Cinematic: trophies fly into a crate, plot collapses, new region builds.
5. Spend LP in perk tree.

## Rules & numbers
- Fame gate for Stage 10 rises per rebirth: `Gate = 5M × 1.6^rebirths`.
- Target: rebirth run N+1 reaches the same point ~2× faster than run N.

## Server / data requirements
- `Profile.Rebirths`, `Profile.LegacyPoints`, `Profile.LegacyPerks = {[perkId]=rank}`, `Profile.LegacyHall = {}`
- Rebirth executed in one atomic profile update; log to analytics.

## UI screens
- [[Screen - Rebirth]]

## Acceptance criteria
- [ ] Rebirth preview shows exact LP before confirm
- [ ] All kept items present after rebirth, all reset items reset
- [ ] Perk effects apply immediately on the new run

## Open questions
- Allow early rebirth (before Worlds) at reduced LP? Possibly at Stage 8+ with 50% LP.

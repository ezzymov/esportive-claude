---
tags: [feature]
status: idea
priority: P2
stage: 0
system_type: Infrastructure
engine_layer: ServerService
dependencies:
  - "[[Content Catalog]]"
  - "[[Monthly Seasons]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Main HUD]]"
roblox_execution_environment: ServerScriptService
---
# Live Ops & Events

## Summary
Live content keeps the game fresh after launch and brings players back for updates. Plan a calendar, keep content config-driven so new events ship without code changes.

> **Proposal (2026-10-21):** [[Monthly Seasons]] would replace the 4–6 week seasonal major with one themed season per calendar month.

## Event types
| Type | Cadence | Example | Reward |
|---|---|---|---|
| Seasonal major | Every 4–6 weeks | Summer Cup, Winter Major, Spooky Showdown | Event Crate, limited jersey, trophy |
| Worlds Live | Weekly (Sat 18:00 UTC) | Server-wide bracket of best teams | Gems, title, plaza statue for winner |
| **Admin Abuse** | Weekly (Sat 17:00 UTC, 60 min) + surprise mini events every ~3 h + manual from the [[Admin Panel]] | Cash Rain, Crate Drop, Luck Surge, Golden Hour, Time Warp, Mythic Raffle ([[Admin Abuse Events]]) | Free, scaled to your income |
| Weekend boost | Most weekends | 2× clip views, 1.5× cash | — |
| Community goal | Per update | "Open 1M cases globally" | Everyone gets a crate |
| Limited title | Per season | New fictional game title for 2 weeks (e.g. "Robo Rumble") | Title-specific trophy |
| Codes | Per update / milestone | `GARAGE2GLORY` | Gems, crate |

## Event tokens
Each seasonal event has its own token earned from event quests and matches. Token shop sells Event Crate, cosmetics, a guaranteed event player. Tokens expire (convert to Cash at end).

## Worlds Live format
1. Opt-in window 30 min before start (notification + plaza countdown).
2. Every opted-in team's snapshot enters a 16/32/64-team bracket (AI fills).
3. Rounds play every 2 min on the plaza jumbotron with caster lines.
4. Spectators use [[Prediction Pick'em]] for free picks.
5. Rewards by placement; champion gets a statue in the plaza until next week. The statue and champion banner show on **every server**, using the global showcase in [[Social & Multiplayer]].

## Update cadence (target)
- Week 0: launch
- Every 2 weeks: small update (balance, 1 new crate, codes)
- Every 4–6 weeks: big update (new event, new title or room, new region)

## Config
`Shared/Config/Events.lua` → `{Id, StartsAt, EndsAt, Crate, TokenName, Quests, Boosts, Theme}`. Server reads current event by time; client themes HUD (banner colors, plaza decor).

## Acceptance criteria
- [ ] Event starts/ends from config time with no server restart
- [ ] Event Crate only purchasable during window
- [ ] Codes redeem once per account

## Open questions
- Cross-server Worlds Live (MessagingService + MemoryStore) or per-server? Per-server first.

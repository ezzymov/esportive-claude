---
tags: [feature, new]
status: idea
priority: P1
stage: 0
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Data Schema]]"
  - "[[Services & Remotes]]"
  - "[[Security & Anti-Exploit]]"
affected_ui:
  - "[[Screen - Store]]"
  - "[[Screen - Settings & Odds]]"
roblox_execution_environment: ServerScriptService
---
# Monetization

## Principles
1. **Never pay-to-win walls.** Robux saves time or adds style. Every gameplay item has a free path.
   - **Accessories & stickers** ([[Accessories]]) are cosmetics with power. Every tier and every sticker stat × finish up to Gold must drop from free sources; Gem capsules only change odds. Their power is **off in the Ranked Ladder** (Pure mode), so ranked and the Season Rank board stay pure skill.
2. **Fair & readable.** Odds shown on every random item. Prices shown in Robux before purchase.
3. **Player-safe.** Many players are young. No fake urgency timers on purchases, no "you'll lose this" pressure, no ads disguised as rewards.
4. **Follow Roblox policy.** Check current rules on paid random items (odds disclosure, age/region limits) before shipping paid crates. Prefer non-random premium items if unsure.

Full idea bank with ratings, bundles, placement rules and ideas to avoid: [[Microtransaction Ideas]].

## Gamepasses (one-time)
| Pass | Effect | Price idea (R$) |
|---|---|---|
| 2× Cash | Doubles all cash income | 399 |
| Auto-Collect | Collector empties itself | 149 |
| VIP Lounge | VIP room, chat tag, +10% Fame | 249 |
| Extra Roster Slot | +1 bench slot | 199 |
| Offline Pro | Offline cap 4 h → 8 h | 149 |
| Fast Open | Skip/×10 case animation at any stage | 99 |
| Auto-Buy Pads | Buys cheapest pad automatically | 199 |

## Developer products (repeatable)
- Gem packs (100 / 550 / 1200 / 3000)
- Cash packs scaled to stage (price fixed, amount = 10 min of current income × multiplier)
- Timed boosters: 2× income 30 min, 2× clip views 30 min
- **Time Skip Ticket** packs (15 min / 1 h / 4 h), also earned free daily ([[Time Skip Tickets]])
- Premium crates (only if policy allows; odds shown, same odds as Gem version)
- **Dev Crate**: 500 R$ per open (or 2,500 Gems), odds shown before purchase. Drops the Dev ✦ players, a documented exception to principle 1. See [[Dev Players]]

## Season Pass
Premium track of the Circuit Pass (see [[Daily Loops & Quests]]). Cosmetics, jersey, boosters. No exclusive stat power.

## Premium Payouts
Design so Roblox Premium members get a small perk (+10% daily login reward) to earn Premium Payouts engagement.

## Store layout
- One Store button on HUD. Tabs: Featured · Passes · Gems · Boosters · Cosmetics.
- First-purchase "Starter Pack" (one per account): Gems + Pro Crate + exclusive jersey.

## Metrics to watch
Conversion rate, ARPDAU, payer retention, % of revenue from passes vs products, refund/complaint rate.

## UI screens
- [[Screen - Store]]

## Open questions
- Remove paid random items entirely and sell only direct cosmetics + Gems? Safer for policy and parents. Decide before M6.

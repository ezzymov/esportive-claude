---
tags: [progression, balance]
---
# Balance Tables (starting values)

All numbers are first guesses for the spreadsheet. Formulas live in [[Economy Design]]. Change values here and in `Shared/Config` together.

## Player rarity
| Rarity | OVR range | Potential range | Salary/week | Trait chance | Base Value |
|---|---|---|---|---|---|
| Common | 30–45 | 40–60 | ~$900 | 10% | $300 |
| Uncommon | 40–55 | 50–70 | ~$2k | 25% | $1.2k |
| Rare | 50–65 | 60–80 | ~$4k | 50% | $5k |
| Epic | 60–75 | 70–88 | ~$7k | 80% | $25k |
| Legendary | 72–86 | 82–95 | ~$12k | 100% | $150k |
| Mythic | 85–95 | 92–99 | ~$18k | 100% + unique | $1M |

## Role stat weights (for OVR)
| Role | Aim | Reflexes | Game Sense | Teamwork | Clutch | Consistency |
|---|---|---|---|---|---|---|
| Entry | 0.30 | 0.25 | 0.10 | 0.10 | 0.10 | 0.15 |
| Support | 0.10 | 0.10 | 0.20 | 0.35 | 0.10 | 0.15 |
| Sniper | 0.35 | 0.20 | 0.10 | 0.05 | 0.20 | 0.10 |
| Strategist | 0.05 | 0.10 | 0.40 | 0.25 | 0.05 | 0.15 |
| Flex | 0.17 | 0.17 | 0.17 | 0.17 | 0.16 | 0.16 |

## PC part tiers
| Tier | Rarity link | Stat mult | Shop price (approx) |
|---|---|---|---|
| Dusty Starter | Common | +0% | free |
| Budget | Uncommon | +3% | $200 |
| Mid | Rare | +7% | $2k |
| High-End | Epic | +12% | $20k |
| Pro | Legendary | +18% | $200k |
| Prototype | Mythic | +25% | craft / Legend Crate |
- Station slots: CPU, GPU, Monitor, Chair, Desk (mouse/keyboard/headset moved to [[Accessories]]).
- Brand set bonus: 3 parts same brand = +3%, full station (5 parts) = +7%.
- All of `partMult` = 0 in Pure mode (Ranked).

## Accessory tiers ([[Accessories]])
Flat points on the accessory's one stat. Bonus counts only up to the stage's max tier.
| Tier | Base bonus | Full bonus from | Tech Shop price (approx) |
|---|---|---|---|
| Common | +1 | Stage 2 | $150 |
| Uncommon | +2 | Stage 2 | $1.2k |
| Rare | +3 | Stage 3 | $10k |
| Epic | +4 | Stage 4 | cases / craft |
| Legendary | +6 | Stage 6 | cases / tournaments |
| Mythic | +8 | Stage 8 | Legend Crate / events |

## Sticker power ([[Sticker System]] → *Sticker power*)
| Finish | Paper | Glossy | Holo | Glitter | Foil | Gold | Lenticular |
|---|---|---|---|---|---|---|---|
| Matching stat | +0.5 | +1 | +1.5 | +2 | +2.5 | +3 | +4 |
| Off-stat (to its own stat) | +0.25 | +0.5 | +0.75 | +1 | +1.25 | +1.5 | +2 |
- Full Set (all slots, same capsule, 2+ slots): +1. Signed gear (own signature on own accessory): +2 Clutch.
- **Gear cap: +12 per stat** (accessories + stickers). Gear can go above Potential.
- All gear = 0 in Pure mode (Ranked).

## Station income per second (base, before multipliers)
| Station tier | Income/s | Price |
|---|---|---|
| 1 | $1 | free |
| 2 | $2.5 | $100 |
| 3 | $6 | $500 |
| 4 | $15 | $2.5k |
| 5 | $40 | $12k |
| 6 | $100 | $60k |
| 7 | $250 | $300k |
| 8 | $650 | $1.5M |

## Traits (starter list)
| Trait | Effect |
|---|---|
| Clutch God | Clutch ×1.25 in final rounds |
| Team Leader | +5% team chemistry, fewer drama events |
| Streamer | +20% clip views, streaming events |
| Rising Star | +30% training XP |
| Tilt-Prone | −10% stats after a lost round streak |
| Ice Cold | No morale penalty after losses |
| Night Owl | +5% stats in matches 18:00–24:00 server time |
| Loyal | Never leaves, −10% salary |
| Glass Cannon | Aim +10%, Consistency −10% |
| Homegrown | +10% morale, −20% salary (academy only) |
| Veteran | +10% XP to teammates (mentor) |
| Showboat | More Clip Moments, −5% Teamwork |
| Prodigy | +40% training XP until age 20 |
| Headshot Machine | +15% chance a won duel becomes a Clip Moment |
| Adaptable | No off-title stat penalty |
| One-Tap Legend / Big Brain / Final Circle / Never Brakes / Combo King | Mythic uniques, see [[Content Catalog]] |

Level 1–10 badges, stat labels and Match Rating: [[Skill Levels & Ratings]]. Full trait list (90+): [[Trait Library]]. All case ideas: [[Case Library]].

## Tournament prize pools
| Tournament | Teams | 1st prize | Fame |
|---|---|---|---|
| Café LAN | 4 | $1k | 50 |
| Local Cup | 8 | $10k | 300 |
| Regional Qualifier | 16 | $60k | 1.5k |
| Semi-Pro Playoffs | 8 | $250k | 5k |
| Pro League (season) | 10 | $1.5M | 20k |
| National Finals | 8 | $8M | 80k |
| International Qualifier | 16 | $40M | 300k |
| Worlds | 16 | $250M | 2M |

## Case drop tables (per case, edit per update)
| Case | Common | Uncommon | Rare | Epic | Legendary | Mythic |
|---|---|---|---|---|---|---|
| Rookie | 60% | 28% | 10% | 2% | 0% | 0% |
| Pro | 25% | 35% | 28% | 10% | 2% | 0% |
| Elite | 0% | 20% | 40% | 30% | 9% | 1% |
| Legend | 0% | 0% | 30% | 45% | 22% | 3% |

Drop type split (all cases): Player 40% · Part 35% · Cosmetic 15% · Booster 7% · Staff 3%.

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
- Per seated player: `base × (1 + OVR/100)` ([[Economy Design]]). Founder at OVR 30 on tier 1 = **$1.30/s**, only while you sit at your desk. Hired players' desks always pay. Offline earnings count hired desks only.
- Tiers 2+ are bought in the Tech Shop (Stage 2), not with Stage 1 pads.

## Stage 1 numbers (M1, 2026-10-23)
Live in `Shared/Config` (Economy, Pads, Minigames, Hiring, Match). First playtest: [[Stage 1 - Garage Squad]] → *Playtest*.
| What | Value | Config |
|---|---|---|
| Starter gift (Starter Letter bill) | $50 | `Economy.StarterGift` |
| Better Mouse / 2nd Desk / 3rd Desk pads | $150 / $300 / $500 | `Pads` |
| Pickup Game win | $150 base × (opponent / your power), clamp $120–200; first ever win = $150 | `Minigames.Pickup.WinCash` |
| Pickup Game loss | $50 | `LossCash` |
| Pickup Game Fame | win 60 × power ratio (ratio clamp 0.5–2; first win = 60), loss 10 | `WinFame`, `LossFame` |
| Pickup Game cooldown | 75 s from one start to the next | `Cooldown` |
| Pickup opponents | 5 generated Commons, OVR 28–38; pugs are Commons 30–45 | `OpponentOvr` |
| Pity | first ever Pickup Game; before the Rookie Crate, a team game after 1 team-game loss | `PityFirstGame`, `CratePityAfterLosses` |
| Aim Trainer | 20 s run, target every 0.6 s; pay $20 + $2/hit (clamp $20–80); 8 Aim XP/hit (100 XP = +1 Aim); 15 s cooldown; × 0.5 after 5 runs in 10 min; cap 2.5 hits/s | `Minigames.AimTrainer` |
| Tech Fix | first job $200, then $100–250; new job 90 s after the last one; min 6 s per repair | `Minigames.TechFix` |
| Free agents | Rusty featured $250 → $100 after 12 min of play with no hire; 2 generated Commons at Base Value + $10 per OVR above 30; refresh 10 min | `Hiring` |
| FTUE crate (shown as "Rookie Crate") | 1 free on the first team-game win; guaranteed Rare, rolled when granted | `Cases.StarterCrate` |
| Garage Graduate | +25 💎 on promotion to Stage 2 | `TutorialService` |

## Stage 2–3 numbers (M2/M3, 2026-10-23)
Live in `Shared/Config` (Cases, TechShop, Parts, Accessories, Minigames, Competition, Match, Stages, Pads).
| What | Value | Config |
|---|---|---|
| Rookie Crate / Pro Crate | $500 from Stage 2 / $5,000 from Stage 4 (the Local Cup winner gets one earlier) | `Cases` |
| Open ×5 / ×10 | from Stage 2 / from Stage 4 | `Cases.CountStage` |
| Free Rookie Crate | every 30 min of real time from Stage 2, one banked at most | `Cases.Free` |
| Duplicate → Shards | Common 5 · Uncommon 12 · Rare 30 · Epic 80 · Legendary 250 · Mythic 1,000. Duplicate = a part once you own one per desk, an accessory once you own one per player, a player once the roster is full | `Cases.Shards` |
| Café PCs (desks 4, 5) | $1,500 · $2,000 (first café pad ≈ 3× the last garage pad) | `Pads` |
| Roster cap | Stage 1: 4 · Stage 2+: 8 (active five + bench of 3) | `Hiring.RosterMax` |
| Tech Shop | 6 parts + 4 accessories in stock, new stock every 10 min. Parts: Budget + Mid at Stage 2, + High-End at Stage 3. Accessories: Common–Rare ($150 / $1.2k / $10k) | `TechShop` |
| Station tier cap | Stage 2: tier 3 ($6/s base) · Stage 3: tier 4 ($15/s) | `TechShop.MaxStationTier` |
| partMult | Σ tier mult × slot weight (CPU .30, GPU .25, Monitor .25, Chair .10, Desk .10), so a full station of one tier = that tier's mult; +3% for 3 parts of one brand, +7% with all five slots filled | `Parts` |
| Accessory stage cap | counts up to Common (Stage 1), Uncommon (2), Rare (3), Epic (4–5), Legendary (6–7), Mythic (8+) | `Accessories.StageCap` |
| Reaction Test | 8 timing rounds, zone 26% → 10%, pay $25 + $6/hit (clamp $25–80), 12 Reflexes XP/hit, 15 s cooldown, ×0.5 after 5 runs in 10 min | `Minigames.ReactionTest` |
| Pickup lobby OVR | Stage 1: 28–38 · Stage 2: 34–48 · Stage 3: 40–54 (keeps wins paying Fame toward the next gate) | `Minigames.Pickup.OpponentOvrByStage` |
| Scrim offers | AI Team Power = yours × 0.85 / 1.0 / 1.15 when the board rolls (every 5 min or after a scrim) | `Competition.Scrim.Offers` |
| Scrim rewards | win $400 × (their power / yours), clamp $200–800, 40 ★ × ratio; loss $100 + 8 ★; 45 s cooldown | `Competition.Scrim` |
| Fatigue / morale | fatigue +2 pickup · +6 scrim · +10 tournament match, recovers 2/min, > 70 = −10% in matches; morale +3 win / −4 loss, drifts back to 50 at 6/h | `Match` |
| Local Cup | registration 2 min, 5 min between rounds, lineup locks 60 s before; AI band OVR 36–50 | `Competition.Tournaments.LocalCup` |
| Stage 3 promotion | +25 💎 at 500 Fame; auto-promotion stops at `Stages.MaxStage` = 3 until Stage 4 content exists | `Stages` |

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
| Local Cup | 8 | $10k | 300 (+ Pro Crate + trophy; 2nd $4k · 150 · Rookie Crate; 3–4th $1.5k · 75; 5–8th $500 · 25) |
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
- **M2 build:** Player 50% · Part 35% · Accessory 15% (cosmetics = accessories for now; boosters and staff aren't built, so their 10% goes to Player). A type with nothing at the rolled rarity drops out and the others share its chance (no Common parts exist, so a Common roll is 77% Player / 23% Accessory).
- **Pity changes the real rates:** with Epic+ guaranteed every 10 opens, the Rookie Crate's 2% Epic becomes ~10.9% over a long run; the Pro Crate's 12% Epic+ becomes ~17%, its 2% Legendary ~3.6% (measured over 100,000 opens, `Tests.CaseOdds`).

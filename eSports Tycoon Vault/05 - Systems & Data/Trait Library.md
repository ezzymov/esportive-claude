---
tags: [content, balance]
updated: 2026-10-20
---
# Trait Library

Every player trait in one place. The starter list in [[Balance Tables]] and the Mythic uniques in [[Pro Player References]] are included here too. Config: `Shared/Config/Traits.lua`.

## Trait rules
- Each player has **1 trait** (Common–Epic) or **2 traits** (Legendary), plus a **unique** for Mythics.
- Trait rarity limits which card rarity can roll it: ⚪ Common, 🔵 Rare, 🟣 Epic, 🟡 Legendary, 🔴 Mythic-only.
- Negative traits only roll on Common–Rare, and always come with a small upside so they never feel like dead cards.
- Traits can be **rerolled** at the Training Center with a Trait Reroll Token (Shards or Gems). Mythic uniques can't be rerolled.
- **Hidden traits** (marked 👁) show as "???" until the player plays 5 matches or a Scout reveals them.
- Keep numbers small: most traits are 5–15%. Stacking cap: total trait bonus to one stat ≤ +30%.

## Combat / performance
| Trait | Tier | Effect |
|---|---|---|
| Clutch God | 🟣 | Clutch ×1.25 in final rounds |
| Ice Cold | 🔵 | No morale penalty after losses |
| Glass Cannon | ⚪ | Aim +10%, Consistency −10% |
| Headshot Machine | 🟣 | +15% chance a won duel becomes a Clip Moment |
| Entry Fragger | 🔵 | +10% chance to win the first duel each round |
| Anchor | 🔵 | +10% Consistency on defense rounds |
| Lurker | 🔵 | +8% Clutch, −5% Teamwork |
| Opening Pick | 🟣 | 20% chance per round to start with a man advantage |
| Eco Hero | 🔵 | +20% win chance on low-economy rounds |
| Spray Master | 🔵 | +6% Aim in long fights |
| Flick Wizard | 🟣 | +12% Reflexes, −4% Consistency |
| Trade King | 🔵 | Teammate deaths are traded 15% more often |
| Closer | 🟣 | +10% all stats at match point |
| Slow Starter | ⚪ | −5% first 5 rounds, +8% after |
| Hot Hand | 🔵 | Each kill streak of 3 gives +3% Aim until death (max +9%) |
| Comeback Kid | 🟣 | +12% all stats when trailing by 4+ rounds |
| Front-Runner | ⚪ | +8% when ahead, −5% when behind |
| Big Stage | 🟡 | +10% all stats in finals and Worlds |
| Stage Fright | ⚪ | −8% in finals, +5% in scrims and ladder |
| One-Trick | ⚪ | +15% in one random title, −10% in others |
| Adaptable | 🟡 | No off-title stat penalty |
| Map Specialist | 🔵 | +10% on one named map ([[Maps & Map Pool]]) |
| Map Nomad | ⚪ | No Hate Map, but no Comfort Map either |
| Cinematic | 🔵 | Clips featuring this player get +1 auto shot variety and +10% views |

## Mental / morale
| Trait | Tier | Effect |
|---|---|---|
| Team Leader | 🟣 | +5% team chemistry, fewer drama events |
| Tilt-Prone | ⚪ | −10% stats after 3 lost rounds in a row; +5% Aim (passionate) |
| Unshakeable | 🟡 | Immune to negative morale events |
| Hype Machine | 🔵 | Wins give the whole team +5 morale extra |
| Calm Voice | 🔵 | Team morale loss from defeats −30% |
| Perfectionist | 🔵 | +8% Consistency, morale drops faster after mistakes |
| Class Clown | ⚪ | +10 team morale per day, −3% Game Sense |
| Homesick 👁 | ⚪ | Morale −10 during bootcamps, +10% morale at home HQ |
| Night Owl | ⚪ | +5% stats in matches 18:00–24:00 server time |
| Early Bird | ⚪ | +5% stats in matches 06:00–12:00 server time |
| Competitor | 🔵 | +10% vs your Rival team |
| Grudge Holder 👁 | ⚪ | +15% vs any team that beat them last time |

## Growth / training
| Trait | Tier | Effect |
|---|---|---|
| Rising Star | 🔵 | +30% training XP |
| Prodigy | 🟡 | +40% training XP until age 20 |
| Late Bloomer 👁 | ⚪ | Training XP −10% until 22, then +25% |
| Gym Rat | 🔵 | Training fatigue −40% |
| Studious | 🔵 | Game Sense training +50% |
| Aim Addict | 🔵 | Aim training +50% |
| Plateau 👁 | ⚪ | Potential capped 5 lower, salary −20% |
| Hidden Gem 👁 | 🔵 | Potential +10 above what scouts show |
| Veteran | 🔵 | +10% XP to teammates (mentor) |
| Mentor | 🟣 | Academy players train +25% while on the same roster |
| Workaholic | 🔵 | Can queue 2 training sessions at once, fatigue +15% |

## Business / fame
| Trait | Tier | Effect |
|---|---|---|
| Streamer | 🔵 | +20% clip views, streaming events |
| Showboat | ⚪ | More Clip Moments, −5% Teamwork |
| Fan Favorite | 🟣 | +15% merch income, +5% Followers from wins |
| Meme Lord | 🔵 | Clips with trending tags get +30% views |
| Sponsor Magnet | 🟣 | Sponsor offers +10% pay |
| Brand Ambassador | 🟡 | +1 sponsor slot while on roster |
| Camera Shy | ⚪ | −20% clip views, +5% Consistency |
| Influencer | 🟡 | Passive +Followers/hour while on roster |
| Cheap Contract | ⚪ | Salary −25% |
| Loyal | ⚪ | Never leaves, −10% salary |
| Diva 👁 | ⚪ | Salary demands +30% each year, +8% Aim |
| Homegrown | 🔵 | +10% morale, −20% salary (academy only) |
| Free Spirit | ⚪ | Contract max 1 season, signing fee −50% |

## Team / synergy
| Trait | Tier | Effect |
|---|---|---|
| Duo Partner | 🔵 | +8% when paired with a specific other player (shown on card) |
| Shot Caller | 🟣 | Coach tactics +50% effect |
| Utility God | 🔵 | Teammates +5% Aim |
| Bridge | 🔵 | Chemistry builds 2× faster |
| Lone Wolf | ⚪ | +10% own stats, team chemistry −5% |
| Same Region | ⚪ | +5% chemistry per teammate from the same country |
| Captain | 🟡 | Team Leader + Shot Caller combined (can't roll both) |
| Glue Guy | 🔵 | Team synergy bonus counts even with 4/5 roles covered |
| Real Friend | special | Friend signings only: +5 team morale, +10% stats while that friend is in your server ([[Friend Signings]]) |

## Fun / flavor (low impact, high personality)
| Trait | Tier | Effect |
|---|---|---|
| Energy Drink Fan | ⚪ | +5% stats if a drink sponsor is active |
| RGB Enjoyer | ⚪ | +5% stats with Lumora RGB parts equipped |
| Lucky Socks 👁 | ⚪ | 5% chance per match to get +10% all stats |
| Snack Monster | ⚪ | Chef staff effect ×2 |
| Keyboard Smasher | ⚪ | Victory emote is always Desk Slam, +3% Clutch |
| Speedrunner | ⚪ | Matches with this player play 20% faster in the cinematic |
| Mic Spammer | ⚪ | Funny voice lines in matches, −2% Teamwork |
| Pet Owner | ⚪ | Brings a pet to HQ (cosmetic), +5 morale daily |

## Mythic uniques 🔴 (one player each)
| Trait | Player | Effect |
|---|---|---|
| Prodigy+ "Wonderkid" | thud | +40% XP, first-duel win chance +20% |
| One-Tap Legend | cl3an | First kill each round guaranteed 30% |
| Metronome | VyxEe | Consistency can't drop below 95 from any effect |
| Big Brain | Bluffer | +10% team Game Sense |
| Final Circle | Mekha | Clutch ×1.5 in last round |
| Never Brakes | Sem Kortland | Reflexes +15 |
| Combo King | Hideki | +2 Clip Moments per match |
| The Parry | Hideki (alt) | Once per match, a lost round becomes a won round (10% chance) |

## Dev uniques ✦
| Trait | Player | Effect |
|---|---|---|
| Main Character | 3zzy | +2 Clip Moments per match; caster and crowd reactions one intensity higher |
| Patch Notes | Philip | Once per match, after a lost round: team +10 Teamwork for the next 2 rounds |
| Hotfix | appropriateuser | After a lost round: +8 Aim and +8 Reflexes for the next round |
See [[Dev Players]].

## Trait combos (secret synergies)
Two traits on the same roster unlock a hidden bonus the first time they're seen; it's logged in the Collection.
| Combo | Bonus |
|---|---|
| Team Leader + Hype Machine | "Locker Room" +5% chemistry |
| Streamer + Meme Lord | "Content House" +15% clip views team-wide |
| Clutch God + Closer | "Ice in Veins" +5% at match point for all |
| Duo Partner + Duo Partner (matched) | "Dynamic Duo" +5% more |
| Mentor + Prodigy | "Master & Apprentice" Prodigy XP +20% more |
| Night Owl + Early Bird | "Shift Work" bonus applies all day for both at half strength |

## Trait sources
- Random roll on card creation (cases, free agents, academy).
- **Trait Reroll Token**: 50 Shards or 30 Gems.
- **Trait Training** (Stage 7): 24 h special training can add a 🔵 trait to a player with only 1 trait slot used.
- Life events (see [[Player Life Events]]) can grant or swap traits, e.g. Burnout → "Burned Out" (temporary −10%, clears after rest).

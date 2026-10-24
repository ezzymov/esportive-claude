---
tags: [system, content]
---
# Content Catalog

Starter content lists. Every list maps to a config module under `ReplicatedStorage/Shared/Config`. All names are fictional.

## Fictional hardware brands (`Brands.lua`)
| Brand | Specialty | Set bonus flavor |
|---|---|---|
| NovaCore | CPUs | +match performance |
| Vektor | GPUs | +Reflexes |
| Pulse Audio | Headsets (accessory) | — (accessories have no brand sets) |
| Hexaview | Monitors | +Aim |
| Clikk | Mice & keyboards (accessory) | — |
| ThroneWorks | Chairs | −fatigue |
| Lumora | RGB & decor | +Fame |
| GripTech | Arm sleeves (accessory) | — |
| BlueShift | Gaming glasses (accessory) | — |

## Example parts (`Parts.lua`)
| Part | Slot | Tier |
|---|---|---|
| Hexaview 144 | Monitor | Mid |
| Hexaview Blade 360 | Monitor | Pro |
| NovaCore Quantum X | CPU | Prototype |
| Vektor Inferno 90 | GPU | Pro |
| ThroneWorks Royal | Chair | High-End |

**M2 catalog** (one part per slot per tier, Budget → Pro; Dusty Starter = an empty slot):
| Slot | Budget | Mid | High-End | Pro |
|---|---|---|---|---|
| CPU | NovaCore N3 | NovaCore N5 | NovaCore N7X | NovaCore N9 Pro (Prototype: Quantum X) |
| GPU | Vektor Ember 30 | Vektor Blaze 60 | Vektor Flare 80 | Vektor Inferno 90 |
| Monitor | Hexaview 75 | Hexaview 144 | Hexaview 240 | Hexaview Blade 360 |
| Chair | ThroneWorks Squire | ThroneWorks Knight | ThroneWorks Royal | ThroneWorks Emperor |
| Desk | Lumora Glow Desk | Lumora Neon Strip | Lumora Prism | Lumora Aurora |

## Example plain accessories (`Accessories.lua`, Tech Shop, see [[Accessories]])
| Accessory | Slot | Tier |
|---|---|---|
| Rusty Clicker | Mouse | Common |
| Clikk Feather 2 | Mouse | Rare |
| Clikk Tactile 60 | Keyboard | Uncommon |
| Pulse Halo | Headset | Rare |
| GripTech Sleeve | Arm Sleeve | Common |
| BlueShift Lenses | Glasses | Uncommon |
| Lucky Dice Charm | Lucky Charm | Common |

**M2 catalog** (Common–Rare sold in the Tech Shop; Epic and Legendary drop from cases):
| Slot (stat) | Common | Uncommon | Rare | Epic | Legendary |
|---|---|---|---|---|---|
| Mouse (Aim) | Clikk Basic, Rusty Clicker | Clikk Glide | Clikk Feather 2 | Clikk Comet Tail | Clikk Nebula |
| Keyboard (Consistency) | Clikk Typist | Clikk Tactile 60 | Clikk Switchblade | Clikk Pixel Pal | Clikk Monolith |
| Headset (Teamwork) | Pulse Buds | Pulse Echo | Pulse Halo | Pulse Nova | Pulse Zenith |
| Arm Sleeve (Reflexes) | GripTech Sleeve | GripTech Flex | GripTech Pro | GripTech Carbon | GripTech Phantom |
| Glasses (Game Sense) | BlueShift Basics | BlueShift Lenses | BlueShift Vision | BlueShift Oracle | BlueShift Prism |
| Lucky Charm (Clutch) | Lucky Dice Charm | Four-Leaf Clover | Tiny Horseshoe | Golden Cat | Phoenix Feather |

## Player name bank (`PlayerNames.lua`)
Gamer tags: see [[Gamertag Bank]] (~200 natural pro-style tags + generator rules). Combine with country flag + generated first name.

## Mythic players (hand-made, one per title)
Full star list with stats and real-life inspirations: [[Pro Player References]].
| Name | Title | Role | Trait |
|---|---|---|---|
| "cl3an" | Aim Arena | Sniper | One-Tap Legend: first kill each round guaranteed 30% |
| "Bluffer" | Tower Clash | Strategist | Big Brain: +10% team Game Sense |
| "Mekha" | Drop Zone | Flex | Final Circle: Clutch ×1.5 in last round |
| "Sem Kortland" | Kart Rift | Entry | Never Brakes: Reflexes +15 |
| "Hideki" | Brawl Legends | Entry | Combo King: +2 Clip Moments per match |

## AI teams (Home Region) (`AITeams.lua`)
Apex Cartel · Turbo Tigers · Frostbyte · Glitch Syndicate · Phantom Lag · Static Drift · Crimson Vortex · Neon Jackals (renamed from Neon Wolves for good in M3, so it can't clash with a player's auto-name "Neon Wolves"). Personalities in [[Rivalries & Storylines]].
- Built in M3: each team has a tag, color, OVR bias, stat lean (Frostbyte +8 Game Sense, Phantom Lag +8 Clutch, Glitch Syndicate ±10 chaos…), favorite map and 3 trash-talk lines. New styles: Static Drift (steady grinders), Crimson Vortex (aggro rushers), Neon Jackals (flashy showmen).

## Cosmetics (`Cosmetics.lua`)
- Jersey patterns: Stripes, Chevron, Circuit, Camo-Pixel, Flames, Galaxy, Glitch, Holo (Mythic)
- Desk skins: Wood, Carbon, Neon Grid, Lava, Ice, Gold
- Victory emotes: Desk Slam, Headset Toss, Floss-Bot, Trophy Lift, Chair Spin
- Neon signs: "GG", "Clutch", team tag, "No Lag Zone"

## Case themes (seasonal)
Summer Cup (beach/neon), Spooky Showdown (pumpkin RGB), Winter Major (ice/frost), Cyber Spring (chrome/holo).

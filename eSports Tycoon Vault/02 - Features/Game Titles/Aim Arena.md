---
tags: [feature, titles]
status: designed
priority: P0
stage: 1
system_type: DataModel
engine_layer: ReplicatedShared
dependencies:
  - "[[Match Simulation]]"
  - "[[Map Library]]"
  - "[[Agent Library]]"
  - "[[Skin Pattern System]]"
  - "[[Trait Library]]"
affected_ui:
  - "[[Screen - Match HUD]]"
roblox_execution_environment: ReplicatedStorage
---
# Aim Arena

The main esports title. A 5v5 round-based tactical shooter in the style of CS2: **realistic firearms**, money rounds, plant and defuse. Original names for everything. Maps: [[Map Library]] → Aim Arena.

> **Content rules.** Realistic weapons and gunfights, **no blood or gore**. Hits show armor sparks, cloth puffs and impact dust; eliminated characters **ragdoll**. Fill out Roblox's content maturity questionnaire before launch: realistic firearms may raise the experience's maturity label and change who can play it (see [[Game Pitch]]).

## Sides
| Side | Name | Job | Color |
|---|---|---|---|
| Attack | **Raiders** | Plant the **Charge** at bombsite A or B | Orange / tan |
| Defense | **Wardens** | Stop the plant, or **defuse** the Charge | Blue / navy |
- Each in-game character is an **Agent** (realistic tactical look, see [[Agent Library]]). All 10 Agents show a nameplate with the controlling roster player's gamer tag + team tag (e.g. `NW | thud`).
- Sides swap at halftime (after round 12).

## Match format
- First to **13 rounds** (24 regulation, MR12). At 12–12: overtime, best of 6 (first to 4), repeat if tied.
- Bo1 for groups and ladder, Bo3 for playoffs, Bo5 for finals. Map veto: [[Maps & Map Pool]].

## Round flow
1. **Freeze time / buy (15 s):** Agents buy weapons, armor and grenades.
2. **Round (1:55):** Raiders take a site; Wardens hold and rotate.
3. **Plant:** Raider plants the Charge (3.2 s). Charge timer 40 s.
4. **Defuse:** Warden defuses (10 s, 5 s with a Defuse Kit).
5. **Round ends:** one team fully eliminated, Charge detonates, defuse completes, or time runs out (Wardens win).
- Health 100. Armor: Vest (body) and Helmet (head). Headshots with a rifle are usually one-hit kills; the helmet flies off on a headshot that the helmet stops.

## Economy
| Event | Money |
|---|---|
| Round win (elimination / time) | +$3,250 |
| Round win (detonation) | +$3,500 |
| Round win (defuse) | +$3,500 |
| Round loss | +$1,400, rising +$500 per loss in a row (max $3,400) |
| Charge planted (Raiders, even on a loss) | +$800 to the team |
| Kill reward | Rifles/pistols $300 · SMGs $600 · Shotguns $900 · Longbow $100 · Knife $1,500 · Zapper $0 |
| Max money | $16,000 |
Round types the sim tracks: **Pistol round**, **Eco**, **Force buy**, **Full buy**, **Half buy**. Eco round wins trigger the "Eco Hero" trait shine ([[Trait Library]]).

## Firearms
In-game names are fictional (real gun brand and model names are trademarks). The CS2 column is for **our reference only** and never appears in the game. Models should look realistic, without copying any manufacturer's logos or markings.

### Pistols
| Weapon | CS2 counterpart | Side | Price | Feel |
|---|---|---|---|---|
| **Viper-18** | Glock-18 | Raiders (default) | Free | Light, fast, burst-fire mode |
| **Warden SD** | USP-S | Wardens (default) | Free | Suppressed, accurate |
| **Ranger P2** | P2000 | Wardens (alt default) | Free | Reliable |
| **Kestrel 250** | P250 | Both | $300 | Cheap armor-piercing |
| **Hornet 57** | Five-SeveN | Wardens | $500 | Big magazine |
| **Tecton 9** | Tec-9 | Raiders | $500 | Run-and-gun |
| **Strider 75** | CZ75-Auto | Both (replaces Hornet/Tecton) | $500 | Full auto, short mag |
| **Bulldog .50** | Desert Eagle | Both | $700 | One-shot headshots |
| **Twin Nines** | Dual Berettas | Both | $300 | Two pistols, flashy |
| **Longhorn R8** | R8 Revolver | Both | $600 | Slow, heavy hits |

### SMGs
| Weapon | CS2 counterpart | Side | Price | Feel |
|---|---|---|---|---|
| **Mako-10** | MAC-10 | Raiders | $1,050 | Spray up close |
| **Wasp-9** | MP9 | Wardens | $1,250 | Fast, mobile |
| **Kite-7** | MP7 | Both | $1,500 | Balanced |
| **Hush-5** | MP5-SD | Both | $1,500 | Suppressed |
| **Badger 45** | UMP-45 | Both | $1,200 | Hard hits, slower |
| **Ring 90** | P90 | Both | $2,350 | Huge mag |
| **Coil** | PP-Bizon | Both | $1,400 | 64-round helical mag |

### Rifles
| Weapon | CS2 counterpart | Side | Price | Feel |
|---|---|---|---|---|
| **Volk-47** | AK-47 | Raiders | $2,700 | One-tap headshot even through a helmet |
| **Lancer A4** | M4A4 | Wardens | $3,100 | Steady spray, 30 rounds |
| **Lancer S** | M4A1-S | Wardens | $2,900 | Suppressed, precise, 20 rounds |
| **Gallo AR** | Galil AR | Raiders | $1,800 | Budget rifle |
| **Clairon** | FAMAS | Wardens | $2,050 | Budget rifle, burst mode |
| **Spectre 553** | SG 553 | Raiders | $3,000 | Scoped rifle |
| **Augur** | AUG | Wardens | $3,300 | Scoped rifle |

### Snipers
| Weapon | CS2 counterpart | Side | Price | Feel |
|---|---|---|---|---|
| **Longbow** | AWP | Both | $4,750 | One-shot body kill, slow; the star weapon of the Sniper role |
| **Swallow 08** | SSG 08 | Both | $1,700 | Light scout rifle, accurate while jumping |
| **Harrier 20** | SCAR-20 | Wardens | $5,000 | Auto-sniper |
| **Gauntlet G3** | G3SG1 | Raiders | $5,000 | Auto-sniper |

### Heavy
| Weapon | CS2 counterpart | Side | Price | Feel |
|---|---|---|---|---|
| **Pump 12** | Nova | Both | $1,050 | Pump shotgun |
| **Breacher 1014** | XM1014 | Both | $2,000 | Auto shotgun |
| **Mag-Box 7** | MAG-7 | Wardens | $1,300 | Box-mag shotgun |
| **Sawback** | Sawed-Off | Raiders | $1,100 | Short-range shotgun |
| **Hammer 249** | M249 | Both | $5,200 | Light machine gun |
| **Gale** | Negev | Both | $1,700 | LMG that gets accurate while firing |

### Grenades and gear
| Item | CS2 counterpart | Price | Effect in sim / cutscene |
|---|---|---|---|
| **Smoke** | Smoke grenade | $300 | Blocks vision for 18 s; grey smoke cloud |
| **Flashbang** | Flashbang | $200 (max 2) | Blinds players looking at it; white flash and ringing sound |
| **Frag** | HE grenade | $300 | Damages armor/health in a radius; blast, dust, ragdoll if lethal |
| **Firebomb** (Raiders) / **Incendiary** (Wardens) | Molotov / Incendiary | $400 / $500 | Area fire for 7 s; denies a spot |
| **Decoy** | Decoy | $50 | Fake gunfire sounds |
| **Vest** / **Vest + Helmet** | Kevlar / Kevlar + Helmet | $650 / $1,000 | Armor |
| **Defuse Kit** | Defuse kit | $400 | Defuse in 5 s (Wardens) |
| **Zapper** | Zeus x27 | $200 | One-shot short-range taser |
| **Knife** | Knife | Free | Melee; the most-wanted skin slot |

## How stats show up
| Stat | What it does in a round | What you see in the cutscene |
|---|---|---|
| Aim | Duel win chance, headshot rate | Clean headshots, helmets flying off |
| Reflexes | Who shoots first on a peek | Fast flicks, counter-strafes |
| Game Sense | Rotations, reading the enemy, timing | Agents rotate early, perfect retakes |
| Teamwork | Trades, utility combos | Flash + smoke executes, instant trade kills |
| Clutch | Odds in 1vX | Calm slow-mo, quiet music, last-second defuse |
| Consistency | Less variance round to round | Steady spray control, fewer whiffs |
Role notes: the **Sniper** role buys the Longbow; the **Strategist** (IGL) gives a tactic bonus; **Entry** gets the first duel each round; **Support** throws utility for others.

## What a match looks like (cutscene)
- **Intro:** camera flies over the map, both team logos slam in, lineups show 5 nameplates per side with each player's Agent.
- **Buy phase:** quick shot of each player's buy (weapon icon in its skin).
- **Round cards:** top-down tactical map with name icons moving, then cut to key duels.
- **Gunfights:** realistic muzzle flash, faint tracers, shell casings, armor sparks on hits, dust and sparks on walls. The losing Agent **ragdolls** (physics ragdoll with an impulse from the shot direction). No blood, no wounds, no gore.
- **Kill feed** (CS-style icons): `NW | thud [Volk-47 ⧉ Galaxy] ⦿ AC | Blitzr`, with icons for headshot ⦿, wallbang, no-scope, through smoke, blinded, and jumping.
- **Plant / defuse:** Charge beeping speeds up, defuse progress bar over the Warden's head, kit icon.
- **Round end:** scoreboard swoosh, round MVP with nameplate glow, money summary.
- Most rounds show 2–4 s of highlights; rounds with Clip Moments play the full cutscene template.

## Nameplates
- Above each Agent: `[team tag] gamer tag`, side-colored, shrinks with distance, greys out on death.
- First-person shots show the name in a lower-third instead.
- Friend signings show the friend's display name ([[Friend Signings]]).
- In friend scrims, the opponents' nameplates are the other real player's roster.
- Setting: Nameplates On / Clips only / Off.

## Weapon skins in matches and clips
- Each roster player has an Aim Arena **Loadout**: Agent, a skin per weapon, **knife**, **gloves**, Charge skin (Raiders), weapon charm, and stickers ([[Sticker System]]).
- Skins keep **seed, condition and finish** ([[Skin Pattern System]]), so a Volk-47 "Galaxy · Twin Suns 0.03" looks exactly like that in every clip.
- Tracker skins show their counter on a small display on the weapon.
- **Knife and gloves** are the rarest drops (★ Rare Special Items, see [[Case Library]]) and show in first-person shots and the knife-out celebration.
- Clip Editor "Inspect" beat: the hero inspects their weapon, CS-style, showing skin and stickers up close.

## Match HUD
See [[Screen - Match HUD]]. Aim Arena adds: team money bar, Charge status, utility icons under each player portrait, armor/helmet icons, side color swap at halftime.

## Studio build notes
- Agents = R15 rigs with Agent accessory sets + weapon Tool models (single MeshPart per weapon where possible, skins via `SurfaceAppearance`).
- **Ragdoll:** on death, replace `Motor6D` joints with `BallSocketConstraint`s (limited angles), apply an impulse from the shot direction, let it settle for 2 s, then anchor. Physics ragdolls can settle slightly differently per device; see [[Clip Cutscene System]].
- Muzzle flash = `PointLight` + particle; tracers = thin `Beam` (0.05 s); impacts = particle + bullet-hole decal on walls only.
- Shared animation pack: walk, run, crouch, peek, aim, ADS, recoil, reload per weapon class, plant, defuse, buy-menu pose, knife inspect, celebrations.

## Links
[[Game Titles Overview]] · [[Maps & Map Pool]] · [[Match Simulation]] · [[Clip Cutscene System]] · [[Pro Player References]] · [[Agent Library]]

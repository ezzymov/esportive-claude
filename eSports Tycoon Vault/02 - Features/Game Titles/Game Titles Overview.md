---
tags: [feature, titles]
status: designed
system_type: DataModel
engine_layer: ReplicatedShared
dependencies:
  - "[[Match Simulation]]"
  - "[[Clip Cutscene System]]"
  - "[[Skin Pattern System]]"
affected_ui:
  - "[[Screen - Match HUD]]"
roblox_execution_environment: ReplicatedStorage
---
# Game Titles Overview

The tycoon has **six fictional esports games** your team competes in. Each one has its own sides, rules, gear, maps and clip style. Matches are simulated on the server ([[Match Simulation]]) and shown as 3D cutscenes ([[Clip Cutscene System]]) with **your players' names over their heads** and **your skins on their gear**.

| Title | Genre | Format | Sides | Unlock | Note |
|---|---|---|---|---|---|
| **Aim Arena** | Tactical shooter (CS2-style, realistic firearms) | 5v5, rounds, first to 13 | Wardens (defend) vs Raiders (attack) | Stage 1 | [[Aim Arena]] |
| **Spectra** | Hero shooter (laser blasters, abilities) | 5v5, Control / Escort / Breach | Solaris vs Umbra | Stage 6 | [[Spectra]] |
| **Tower Clash** | MOBA / lane battler | 5v5, one long game | Sunforge vs Moonveil | Stage 5 | [[Tower Clash]] |
| **Drop Zone** | Battle royale | 20 squads of 3, 3–6 games | Every squad for itself | Stage 7 | [[Drop Zone]] |
| **Kart Rift** | Team kart racing | 4v4 team races + 1 pit strategist | Your team vs one other team | Stage 6 (side league) | [[Kart Rift]] |
| **Brawl Legends** | Arena fighter | 5v5 crew battle (relay) | Your crew vs their crew | Stage 6 (side league) | [[Brawl Legends]] |

## Shared rules across all titles
- **Your roster plays every title**, but stats count differently per title (see each note's stat table). Players can have a main title (+5%) from their archetype or trait.
- **Presentation.** Not aimed at young kids. Aim Arena and Drop Zone use **realistic firearms** (CS2-style); Spectra uses **laser blasters**. **No blood or gore anywhere**: hits show sparks, dust and armor impacts, and eliminated characters **ragdoll**. Real gun brand/model names are not used (trademarks); fictional names with realistic designs.
- **Content maturity.** Realistic weapons can raise the Roblox maturity label. Complete Roblox's maturity questionnaire before launch and set the target audience to match ([[Game Pitch]]).
- **Fictional everything.** No real game names, maps, agents, heroes or items. Our sides, gear and characters are original.
- **Nameplates.** In every match cutscene and clip, each in-game character shows the **gamer tag of the roster player controlling it** (or the friend's display name for [[Friend Signings]]), plus the team tag. Colors follow the side.
- **Skins.** What players equip in their **Loadout** shows up in matches and clips ([[Skin Pattern System]] → Loadouts). Clips save a snapshot, so a clip keeps the skin even if you later trade it away.
- **Real player's role.** You manage between matches (lineup, tactics, veto, loadouts) and can join optional moments (Clutch Moment, Strategy Draft) from [[Playable Games]].

## Role meaning per title
| Roster role | Aim Arena | Spectra | Tower Clash | Drop Zone | Kart Rift | Brawl Legends |
|---|---|---|---|---|---|---|
| Entry | Entry fragger, first through the door | Striker (dive) | Top/solo laner, frontline | Fragger, starts fights | Lead racer | Opener (goes first) |
| Support | Utility, trades, flashes | Medic | Support, shields, vision | Medic, revives | Blocker (slows rivals) | Mid-crew stabilizer |
| Sniper | Longbow (AWP-style) player | Sharpshooter | Ranged carry (bot lane) | Long-range marksman | Drafter (slipstream specialist) | Zoner fighter |
| Strategist | Shot caller (IGL) | Controller / shot caller | Jungler / shot caller | Squad caller (rotations) | Pit strategist (doesn't race) | Coach-captain (counter-picks) |
| Flex | Lurker / any role | Vanguard or any | Mid laner | Scout | Any racer | Anchor (goes last) |

## Season calendar
- Main league: Aim Arena all season.
- Tower Clash, Spectra and Drop Zone get their own leagues when unlocked.
- Kart Rift and Brawl Legends are **side leagues**: weekend cups with smaller prizes, great for Fame and clips.
- Worlds (Stage 10) is Aim Arena; other titles have their own "Champions Cup" finals.

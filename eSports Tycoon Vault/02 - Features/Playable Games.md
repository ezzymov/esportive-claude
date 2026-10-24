---
tags: [feature]
status: building
priority: P1
stage: 2
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Match Simulation]]"
  - "[[Game Titles Overview]]"
  - "[[Security & Anti-Exploit]]"
affected_ui:
  - "[[Screen - Match HUD]]"
roblox_execution_environment: ServerScriptService
---
# Playable Games

Two layers: the **in-world fictional esports titles** your roster competes in, and **minigames the real player plays** to earn.

## Fictional titles (avoid real IP)
| Title | Genre | Role stats weighted |
|---|---|---|
| **Aim Arena** | Tactical shooter | Aim, Reflexes |
| **Tower Clash** | MOBA / lane battler | Game Sense, Teamwork |
| **Drop Zone** | Battle royale | Consistency, Clutch |
| **Kart Rift** | Racing | Reflexes |
| **Brawl Legends** | Fighting | Clutch, Aim |

Each title has its own league, so unlocking a title = a new income stream.

**Full design per title** (sides, rules, gear, characters, cutscene look, skins): [[Game Titles Overview]] → [[Aim Arena]] · [[Tower Clash]] · [[Drop Zone]] · [[Kart Rift]] · [[Brawl Legends]].

## Player-controlled minigames (earn cash/fame/training XP)
- **Aim Trainer** – click targets, score = cash + Aim XP for a chosen player (your Founder by default)
- **Tech Fix** – repair a neighbor's broken PC (plug cables, swap a part, clean dust) for cash; the main early earner before your first hire ([[Founder (You)]])
- **Reaction Test** – timing bars
- **Strategy Draft** – pick/ban order puzzle that buffs next match
- **Rhythm Warm-up** – hit notes to raise team morale
- **Clutch Moment** – optional manual input during the final round of a match for bonus (never required)
- **Pickup Games** – solo queue: your Founder + 4 random pugs; main mode in Stage 1, later a quick Founder-XP mode

Minigame scores also grow your **Founder's** stats (Aim Trainer → Aim, Reaction → Reflexes, Draft → Game Sense, Rhythm → Teamwork, Clutch Moment → Clutch).

## Match presentation
Simplified auto-sim with camera cuts: scoreboard, kill-feed, round timer, commentary text. Key moments flagged as **Clip Moments** for [[Clips & Traction]].

Links: [[Matches & Tournaments]] · [[Player Hiring]] · UI: [[Screen - Match HUD]]

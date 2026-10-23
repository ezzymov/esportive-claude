---
tags: [feature]
status: designed
priority: P1
stage: 4
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Clip Cutscene System]]"
  - "[[Match Simulation]]"
  - "[[Map Library]]"
  - "[[Trait Library]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Clip Feed]]"
  - "[[Screen - Match HUD]]"
roblox_execution_environment: ServerScriptService
---
# Clips & Traction

Highlights from matches become **3D cutscenes you can watch, edit and share**. Good clips grow your fanbase. Technical design: [[Clip Cutscene System]].

## Flow
1. **Clip Moment** happens in a match (ace, clutch, comeback, upset, record, blooper). An **Instant Replay** (5 s) can play right away in the [[Screen - Match HUD]].
2. After the match: "2 clips ready → Edit". The game has already made an **auto-cut**: a cutscene on the actual map with your players in your jerseys, camera shots, slow-mo and caster lines.
3. **Clip Editor:** change camera shot per beat (POV, killcam, orbit, drone…), speed (slow-mo), effects (zoom punch, freeze-frame), filter, music sting, caption, thumbnail frame.
4. **Upload** to the in-game feed (fictional app name: **"Streamr"**).
5. Views and likes grow over real time: simulated audience (clip quality, team fame, trends) + real players watching and liking.
6. Followers ↑ → Fame ↑ → sponsors, merch, Arena crowds.

## What makes it fun
- **You see your team do it.** The clip is your roster, your jerseys, your skin seeds, on a real map ([[Map Library]]).
- **Every clip looks different.** Same moment type, different spot, path and timing from the seed.
- **Editing is a mini creative game.** Better edits = more views. Trending styles (`#SlowMoSunday`, `#POVOnly`) reward trying new things.
- **Show-off.** Your best clip plays on the Replay Theater TV in your HQ, and the server's "Clip of the Hour" plays on the plaza jumbotron.
- **Free camera.** Pause any clip and orbit around the frozen moment.

## Clip types
Highlight · Instant Replay · Match Recap (auto 30 s) · Montage (Stage 6) · Blooper · Team Walkout (Stage 6) · Telestrator Breakdown (Stage 7) · Worlds Moment (Stage 10). Details in [[Clip Cutscene System]].

## Mechanics
- **Clip quality** = moment value × edit score × hero fame. Edit score rewards shot variety, slow-mo on the key beat, music-synced cuts and matching the trending style.
- **Trending tags + trending styles** rotate daily.
- **Collab clips** with friends after friend scrims (both teams get views).
- **Streamer** / **Meme Lord** / **Showboat** traits boost views ([[Trait Library]]).
- **Streaming Booth** gives passive followers while online.
- **Social Media Manager** staff: +views, and auto-edits clips if you skip editing.
- Upload cooldown: 1 clip per 3 min (Stage 4), faster with staff.
- Moderation: captions and titles are preset phrases; report button on every clip.

## Rewards
Followers (permanent), Fame, small ad-revenue cash, Gems at 10k / 100k / 1M views, "Clip of the Week" trophy and plaza feature.

## Acceptance criteria
- [ ] After a match with a Clip Moment, the player can watch a 3D cutscene of it
- [ ] Editor changes show on replay
- [ ] Other players can watch your clip from the feed and see the same thing
- [ ] Top clip plays on the HQ Replay Theater screen

Links: [[Sponsors]] · [[Social & Multiplayer]] · [[Playable Games]] · [[Maps & Map Pool]] · UI: [[Screen - Clip Feed]]

---
tags: [system, clips]
updated: 2026-10-20
---
# Clip Cutscene System

Clips are **real 3D cutscenes** you can watch, edit and share, not static cards. Player-facing design: [[Clips & Traction]]. Maps they play on: [[Map Library]].

## Core idea: a clip is data, not video
Roblox can't record or store video. So a clip is a small recipe that every client turns back into the same 3D scene:

```
ClipData (~2–4 KB)
  → Choreographer (deterministic, seed-based)  → Beat timeline (who moves where, who shoots whom, when)
  → Stage Builder (local map copy + actor rigs) → 3D scene
  → Camera Director (auto shots + player edits) → What you see
```
Same ClipData + same seed = same cutscene on every device. Sharing a clip just means sharing the data.

## 1. ClipData
```lua
ClipData = {
  Id, OwnerId, CreatedAt, Version = 1,
  Title = "Aim Arena", MapId = "NeonDocks", Moment = "Clutch",   -- from Match Simulation
  Seed = 48213,                                                   -- drives choreography variety
  Actors = {                                                      -- snapshot at match time
    { Slot = 1, Side = "Raiders", TeamTag = "NW", Name = "thud",      -- nameplate text
      Source = "Generated" | "Key" | "Star" | "Friend" | "Founder" | "Pug", FriendUserId = nil, UserId = nil, -- Founder = your own avatar + display name; Pug = greyed "PUG" nameplate
      Role = "Entry", Character = "Mako",                             -- Agent / Hero / Champion / Fighter
      Jersey = {SkinId, Seed, Condition, Finish},
      Loadout = { ["Volk-47"] = {SkinId, Seed, Condition, Finish, Tracker = 412, Stickers = {...}}, Knife = {...}, Gloves = {...}, Charm = {...} } },
    ... up to 10 (snapshot at match time; later trades don't change old clips)
  },
  Beats = nil,           -- not stored: rebuilt by Choreographer from Moment + Seed + Map
  Hero = 1,              -- actor slot the clip is about
  Context = { Score = {12, 12}, Round = 24, EnemiesAlive = 3 },
  Edit = {               -- player choices from the editor (see section 5)
    Shots = { [beatIndex] = "Killcam" }, Speed = { [beatIndex] = 0.25 },
    Effects = { {Beat = 4, Fx = "ZoomPunch"} }, Filter = "Neon",
    Music = "SynthDrop01", Caption = {PhraseId = 12}, Intro = true, Outro = true,
    ThumbnailBeat = 4, ThumbnailT = 0.6,
  },
}
```
Stored in the owner's profile (last 20 clips) and in the feed store (see section 8).

## 2. Choreographer (turns a moment into a scene)
The match sim only says *what* happened ("thud clutched a 1v3 in round 24"). The Choreographer decides *how it looks*.

### Building blocks
- **Clip Spots** (authored per map): small areas made for action, e.g. Neon Docks "B Crane". Each spot has:
  - Nav nodes (positions for actors), cover points, peek angles
  - Entry paths for enemies
  - A "hero line" (best route for the hero)
  - Camera anchors (good places for wide/drone/orbit shots)
- **Moment Templates** (authored per title): a script of beats for each moment type.

### Example template: Clutch 1v3 (Aim Arena)
| Beat | Action | Variation from seed |
|---|---|---|
| 1 | Establish: hero alone, teammates' icons greyed in HUD | Which spot, time of day tint |
| 2 | Enemy 1 peeks → hero wins duel (headshot, enemy ragdolls) | Peek side, flick vs tap |
| 3 | Hero repositions (slide/jump/vault) | Path through nodes |
| 4 | Enemies 2 + 3 push together → hero double-kill | Order, timing gap (0.3–0.9 s) |
| 5 | Hero defuses the Charge with seconds left | Defuse animation variant, kit or no kit |
| 6 | Celebration pose + crowd cheer | Emote from player's equipped emote |

### Moment templates per title
| Title | Templates |
|---|---|
| Aim Arena | Ace, Clutch 1vX, Opening Pick, Longbow Collateral (2 in one shot), No-scope, Wallbang, Ninja Defuse, Eco Win, Knife Kill, Flawless Round |
| Spectra | Team Wipe, Ultimate Combo, Overtime Save, Payload Final Push, 1v3 Hold |
| Tower Clash | Pentakill Teamfight, Baron-style Steal ("Titan Steal"), Backdoor Push, Outplay 1v2, Tower Dive |
| Drop Zone | Final Circle Win, Squad Wipe, Long-range Snipe, Hot-drop Survival, Vehicle Escape |
| Kart Rift | Last-lap Overtake, Photo Finish, Shortcut Steal, Boost Chain, Comeback from Last |
| Brawl Legends | Perfect Round, Parry Comeback ("Moment 37" homage), Super Finish, Ring-out, Combo 50+ |
| Any | Upset Win (final round + crowd), Fail/Blooper (funny miss, slips, trips) |

### Determinism rules
- All randomness from `Random.new(clip.Seed)`; never `math.random`.
- Templates are versioned. ClipData stores `Version`; old clips use old template versions.
- No physics in cutscenes except **death ragdolls** (see Stage Builder). All other motion is tweened or played animations, so it looks identical everywhere.

## 3. Stage Builder (making the 3D scene)
- Each map has a **Clip Stage** version: a lightweight copy of just the Clip Spots (target < 2,500 parts, low-poly, baked lighting look). Stored in `ReplicatedStorage/ClipStages/<MapId>`.
- When a clip plays, the **client** clones the stage to a far location (e.g. `Vector3.new(0, 10000, 0)`) and spawns actor rigs. Only that client sees it. Destroyed when the clip ends.
- **Actors:** R15 rigs with team jersey skin (seed/condition/finish from [[Skin Pattern System]]), headset, held weapon for the title (realistic firearm in Aim Arena/Drop Zone, laser blaster in Spectra). Animations from a shared pack: run, crouch-walk, peek, aim, shoot, reload, slide, vault, plant, defuse, emote set.
- **Combat look:** realistic muzzle flash, thin tracers, shell casings, armor sparks and wall impacts (Aim Arena/Drop Zone); colored laser beams (Spectra). **No blood or gore.** Eliminated actors **ragdoll**: `Motor6D` joints swap to limited `BallSocketConstraint`s and get an impulse from the hit direction; the body settles for ~2 s, then anchors. Headshots knock the helmet off if it stopped the shot.
- **Ragdoll determinism:** ragdolls are the one physics exception to the determinism rule. Impulse direction and strength come from the seed, but settling can differ slightly between devices. Everything else (who, when, where) stays identical. Thumbnails and freeze-frames use the moment of the hit, before the ragdoll settles.
- **Small previews** (feed cards, Replay Theater screen, plaza jumbotron) use a `ViewportFrame` + `WorldModel` with a cut-down stage (hero spot only, ≤ 400 parts, 4 actors max).
  - A `ViewportFrame` inside a `SurfaceGui` lets the Replay Theater TV and the plaza jumbotron show clips in the 3D world.

### Nameplates and skins in clips
- Every character shows a **nameplate**: `[TeamTag] Name`, side-colored (`BillboardGui`, scales with distance, greyed out after elimination). Name = the roster player's gamer tag, or the friend's display name for [[Friend Signings]] (fetched live; falls back to a generated name if the friend opted out).
- First-person and close-up shots show the name as a **lower-third** instead (name, role, rarity frame, Match Rating so far).
- **Kill feed** in clips: `NW | thud [Volk-47 icon in its skin] ⦿ AC | Blitzr` with CS-style icons (headshot, wallbang, no-scope, through smoke, blinded).
- Every character renders their **loadout skins** from the snapshot, with seed, condition, finish and tracker count ([[Skin Pattern System]]).
- Applied stickers ([[Sticker System]]) render on weapons, karts, armor and helmets from the snapshot.
- Editor "Inspect" beat: the hero inspects their weapon or knife, CS-style, showing skin and stickers up close (skin name and float, e.g. "Volk-47 · Galaxy · Twin Suns · 0.031").
- Viewer setting: nameplates On / Off for clips.

Per-title presentation details: [[Aim Arena]] · [[Tower Clash]] · [[Drop Zone]] · [[Kart Rift]] · [[Brawl Legends]].

## 4. Camera Director
Automatically picks shots for each beat. Player can override shots in the editor.
| Shot | Use | How |
|---|---|---|
| Wide establishing | Beat 1, sets the scene | Static camera anchor, slow push-in |
| Over-the-shoulder | Hero duels | Offset behind hero's right shoulder |
| First-person POV | Flicks, snipes | Camera at hero's head, weapon viewmodel with skin, gloves and knife |
| Killcam | Seeing the enemy's view of the hero | Enemy POV, then rewind |
| Orbit | Multi-tags, celebrations | 180° orbit around hero, 1.5 s |
| Dolly / tracking | Movement, racing | Camera follows path with lag |
| Drone top-down | Team fights, rotations | High angle over spot, shows positions |
| Slow-mo zoom | Key hit | 0.25× speed + FOV punch-in |
| Freeze-frame | Peak moment | Pause 0.6 s with flash + caption |
| Crowd cut | After big moment | Cut to Arena crowd stand ([[Fan Base & Arena]]) |
| Caster desk cut | Intro/outro | Hector + Dr. Data at the desk ([[Caster & Commentary]]) |
| Split-screen | Hero vs enemy reaction | Two ViewportFrames side by side |

**Auto-director rules:** never repeat the same shot type twice in a row; key beat always gets slow-mo or freeze; cuts on beat changes; total length 8–20 s.

## 5. Clip Editor (how players edit)
Opened from post-match ("2 clips ready → Edit") or My Clips. UI: [[Screen - Clip Feed]].

1. **Watch** the auto-cut once (can skip).
2. **Timeline:** beats shown as chips along the bottom. Tap a beat to:
   - pick camera shot (shot cards with tiny previews)
   - set speed: 0.25× / 0.5× / 1× / 2×
   - add one effect: Zoom Punch, Freeze-Frame, Screen Shake, Flash, Color Pop, Rewind
3. **Style:** filter (Neon, Retro VHS, Black & White + team color, Comic outline, Heat), letterbox on/off, music sting (beat-synced; cuts snap to the beat).
4. **Text:** caption from preset phrases ("NO WAY", "1v3?!", "Clean.", "Built different"), intro card (team logo slam), outro card (final score + MVP).
5. **Thumbnail:** scrub to any frame and pick it; it renders as a live frozen ViewportFrame.
6. **Upload.**

Unlocks over time: Freeze-Frame and filters at Stage 4, Split-screen and Montage at Stage 6, Telestrator at Stage 7 (Analyst staff), Pro Editor pass adds extra filters and music (cosmetic only, see [[Microtransaction Ideas]]).

## 6. Clip types
| Type | What | Unlock |
|---|---|---|
| Highlight | One moment, 8–20 s | Stage 4 |
| Instant Replay | Auto 5 s replay during the match HUD after a Clip Moment (skippable) | Stage 3 |
| Match Recap | Auto 30 s cut of the best 3 moments of a match | Stage 4 |
| Montage | Stitch up to 4 saved highlights, one music track | Stage 6 |
| Blooper | Funny fail moments (slip, miss, team-tag) | Stage 4 |
| Team Walkout | Custom pre-match intro: players walk out through smoke with names | Stage 6 |
| Telestrator Breakdown | Freeze frame + Dr. Data draws arrows and circles (preset drawings) | Stage 7 |
| Worlds Moment | Championship-only clip with gold intro, saved forever in Legacy Hall | Stage 10 |

## 7. Watching clips
| Where | How it plays | Detail level |
|---|---|---|
| Clip Feed card | Static poster frame; tap to play | Small ViewportFrame |
| Fullscreen player | Client builds the Clip Stage far away and moves the camera there; HUD hidden | Full |
| Replay Theater (HQ) | SurfaceGui + ViewportFrame on the big screen; sit in a seat to switch to fullscreen | Small → Full |
| Plaza jumbotron | "Clip of the Hour" loops for everyone in the server | Small |
| Friend's HQ | Their top clip plays in their theater | Small |
| Spectating Worlds Live | Instant replays between matches | Small |

**Player controls (fullscreen):** play/pause, scrub, 0.5×/1×, **free-camera mode** (orbit around the frozen scene; Photo Mode pass adds filters and poses), like ❤, share to friend (sends the Clip ID), report.

## 8. Feed storage
- Owner profile keeps last 20 ClipData.
- Feed: `MemoryStoreSortedMap` for Trending (score = views and likes with time decay) refreshed every 60 s; `DataStore` for permanent records of clips over 10k views.
- "Clip of the Week" winner stored permanently and shown in the plaza.

## 9. Quality and views
`ClipQuality = MomentBase × (1 + EditScore) × HeroFameMult`
`EditScore` (0–0.5): +0.1 shot variety (3+ different shots), +0.1 slow-mo/freeze on the key beat, +0.1 cuts synced to music, +0.1 caption fits the moment, +0.1 matches the **trending style**.

**Trending styles** rotate daily alongside trending tags: e.g. `#SlowMoSunday` (use 0.25×), `#POVOnly` (first-person shots only), `#RetroTape` (VHS filter), `#BlooperFriday`.

Simulated audience reactions show as floating emoji and preset comments ("W", "how??", "clean", "😂") during playback, scaled to views.

## 10. Performance budget
| Item | Budget |
|---|---|
| Clip Stage parts | < 2,500 (full), < 400 (preview) |
| Actors | ≤ 10 full, ≤ 4 preview |
| Build time | < 0.5 s (preload stage when the feed opens) |
| Particles | Tracers + 1 burst per tag; off on Low graphics |
| Memory | Destroy stage and rigs on close; only 1 full stage at a time |

## 11. Build order
1. v1: Aim Arena, 2 maps (Neon Docks, Old Arcade), 3 templates (Ace, Clutch, Opening Pick), auto-director only, fullscreen player.
2. v2: editor (shots, speed, captions, music), feed with Trending.
3. v3: Replay Theater + jumbotron previews, Instant Replay in matches.
4. v4: other titles' templates, Montage, Blooper, Walkout.
5. v5: Telestrator, Worlds Moment.

## Acceptance criteria
- [ ] Two clients playing the same ClipData see identical cutscenes
- [ ] Clip builds and plays in < 1 s on a mid-range phone
- [ ] Editor changes (shot, speed, effect) show instantly on replay
- [ ] Replay Theater screen shows a clip in the 3D world
- [ ] ClipData stays under 4 KB

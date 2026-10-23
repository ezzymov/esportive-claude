---
tags: [ui]
screen: Clip Feed
status: designed
---
# Screen - Clip Feed

## Purpose
Watch, edit, upload, browse and like **3D clip cutscenes**. See [[Clips & Traction]] and [[Clip Cutscene System]].

## Opened from / closes to
HUD → Phone → Streamr app, post-match "Edit clips", Clip Studio room, Streamr Tower in the plaza, tapping the Replay Theater TV.

## Layout

### Player (fullscreen)
- The 3D cutscene fills the screen; HUD hidden.
- Bottom bar: ▶/⏸, scrub bar with beat markers, speed (0.5× / 1×), 🎥 Free Camera, ❤ Like, ↗ Share to friend, ⚑ Report, ✕.
- Top-left: team logo, clip title (preset caption), views count.
- Floating audience reactions (emoji + preset comments) drift up the right side, scaled to views.
- Free Camera: drag to orbit the frozen frame, pinch to zoom, "Back to clip" button.

### Editor
- **Top 65%:** live 3D preview of the clip.
- **Bottom timeline:** beat chips (Establish · Duel · Reposition · Double · Plant · Celebrate). Selected chip glows. Music waveform underneath with beat ticks.
- **Beat panel** (opens above timeline on chip tap):
  - Camera: shot cards with mini preview (Wide, Shoulder, POV, Killcam, Orbit, Drone, Slow-mo Zoom, Freeze, Crowd, Split-screen)
  - Speed: 0.25× / 0.5× / 1× / 2×
  - Effect: none / Zoom Punch / Freeze-Frame / Shake / Flash / Color Pop / Rewind
- **Side tabs:** Style (filter, letterbox, music) · Text (caption phrases, intro card, outro card) · Thumbnail (scrub + "Use this frame").
- **Edit Score meter** (0–5 stars) with hints: "Add slow-mo on the key moment", "Trending: #POVOnly".
- Buttons: ↺ Auto-cut (reset), Preview, **Upload**.

### Feed
- Tabs: Trending · Friends · My Clips · Clip of the Week.
- Vertical cards (phone-like): **live frozen 3D poster** (ViewportFrame), title, team logo, views, likes, ❤. Tap → fullscreen player.
- Trending tags + trending style chips row at top.
- My Clips: views graph over 24 h per clip, "Set as HQ Theater clip" button.

## States
- Building scene: short shimmer on the poster (< 0.5 s).
- Upload cooldown: "Next upload in 3:12".
- Viral: card gets fire border and "VIRAL" chip.
- Low graphics: posters show a still frame without animated finishes.

## Animations / sounds
Shot change in editor plays a quick "whoosh"; music sting preview on select; Upload = camera shutter + notification ping.

## Data it reads / remotes it calls
Reads `Clips`, feed list. Calls `Clip/Upload(clipId, edit)`, `Clip/Like(clipId)`, `Clip/Report(clipId)`, `Clip/SetTheater(clipId)`, `Clip/Fetch(clipId)` (returns ClipData for playback).

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Clips` (my clips: clipId, uploaded, views, likes, views history) | My Clips tab, 24 h graph |
| Server reply | `Clip/Fetch` → `ClipData` ([[Clip Cutscene System]] → 1. ClipData) | Player and editor playback |
| Server reply | ⚠ `Clip/GetFeed` RF (tab, page) → clip summaries, trending tags/styles | Feed tabs |
| Profile | `Stage`, ⚠ `NextUploadAt` | Upload unlock, cooldown "Next upload in 3:12" |
| Profile | `Settings.Graphics` | Static posters on Low |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Open clip | `Clip/Fetch` | RF | clipId | ClipData |
| Upload | `Clip/Upload` | RF | clipId, edit (thumb, titlePreset, tag, beats) | ok / cooldown |
| ❤ Like | `Clip/Like` | RE | clipId | state delta |
| ⚑ Report | `Clip/Report` | RE | clipId, reason | — |
| Set as HQ Theater clip | `Clip/SetTheater` | RE | clipId | state delta |
| ↗ Share to friend | ⚠ `Clip/Share` | RE | clipId, friendUserId | — |
| Editor controls (camera, speed, effects, Auto-cut, Preview) | none | — | — | Local edit state |

### State Validation
- **Upload:** `NextUploadAt` has passed (1 per 3 minutes), the clip is yours and not yet uploaded, and the caption/tag are from the preset lists.
- **Like:** once per clip. Update the UI optimistically and roll back on error.
- **Report:** a reason is selected.
- ⚠ The `Clip/Upload` arguments differ between notes: [[Services & Remotes]] lists `clipId, thumb, titlePreset, tag`, but this screen sends `clipId, edit`. Pick one shape.

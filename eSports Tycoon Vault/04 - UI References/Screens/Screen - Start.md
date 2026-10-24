---
tags: [ui]
screen: Start
status: building
---
# Screen - Start

## Purpose
The first screen after the Roblox loading bar. A title card with one job: press to play. Pressing it starts the [[Intro Cutscene]] for new accounts, or drops returning players straight into their garage. See [[Tutorial & Onboarding]] for what happens after.

## Opened from / closes to
- Opens: game join, after assets preload.
- Closes to: [[Intro Cutscene]] (first join only) → Garage. Returning players → their plot, no cutscene.

## Layout (anchors, sizes, regions)
- **Background:** a slow, blurred live shot of the player's own plot (Garage era) with the Ring Road in view. Dim it so the logo reads. Not a static image: it's the same plot they'll be standing on, so the title screen previews the game.
- **Logo:** centered, upper-middle, about 45% of screen width on desktop, 70% on phone. Placeholder for the eSports Tycoon logo. Bevelled, glowing outline in the team color (default neutral until the team exists).
- **Press to Play:** centered under the logo. Pulses gently. This is the only button on the screen. The whole screen is also a tap target.
- **Loading bar:** full-width strip, rounded, dark outline, filled bar in the brand gradient. Hidden after assets finish loading. If preload is still running when the player presses, the button waits for the bar to fill.
- **Tip line:** one short line under the bar, rotating every 4 s ("Sponsors pay weekly. Keep your Fame up."). Sentence case, not a pun list.
- **Roblox top-left bar:** keep the standard Roblox menu area clear (about 36 px top-left reserved, see [[UI Reference Hub]] constraints).

## Components used
- Logo `ImageLabel` (`UIAspectRatioConstraint`)
- Blur `BlurEffect` on the world camera, not on the UI
- `TextButton` for Press to Play (full-screen hit area)
- Progress bar (`Frame` + `UIGradient`, width tween)
- Tip label with `TweenService` fade

## States
- **Loading:** logo visible, bar filling, Press to Play hidden, tip line visible.
- **Ready:** bar full and gone, Press to Play pulses.
- **Pressed:** fade to black (0.4 s), then cutscene or garage.
- **Error (preload failed):** Press to Play still works. Show a small line "Some assets didn't load. Playing anyway." and continue.

## References
| Image | Source game | What to copy |
|---|---|---|
| ![[BuildAPC_Start_press-to-play.png]] | Build a PC (Roblox) | Logo centered over a blurred live world, one "PRESS TO PLAY" line, full-width loading bar at the bottom, the Roblox top-left bar kept clear |

**Copy the structure, not the look.** Don't reuse their logo, their colors or their tip wording. Our logo, palette and tips go in their place.

## Our mockup
_Not drawn yet. Add `Mockups - Ours/Start v1` when the layout is approved._

## Animations / sounds
- Logo: gentle float (±4 px, 3 s loop). No spinning.
- Press to Play: scale pulse 1.0 → 1.05, 1.2 s loop.
- Press: short whoosh + bass hit, then fade to black.
- Background music: the [[Art & Audio Direction]] title theme starts on the logo, not on the loading bar.

## Data it reads / remotes it calls
- Reads `Profile.Flags.IntroSeen` (boolean). If false → cutscene, else → garage.
- No remote calls. The choice is local. The server still knows which plot to load from the normal join flow ([[Data Persistence]]).
- ✅ `Profile.Flags.IntroSeen` is in [[Data Schema]] (M1, 2026-10-23).

## Rules
- No timers, no "limited time" text, no pay prompts on this screen ([[Monetization]] principles).
- Works one-handed on phone: Press to Play sits in the lower thumb zone on mobile.
- Keyboard and gamepad: any key or the A button presses Play.

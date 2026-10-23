---
tags: [progression, cutscene, stage/1]
status: designed
---
# Intro Cutscene — "The Drop-Off"

The first thing a new player sees. About **50 seconds**, skippable after 5 s, re-watchable from Settings. It sets the story: **you are the first and only player on your team**, with one old PC and a borrowed garage. Everything after this you build yourself. Next steps: [[Stage 1 - Garage Squad]]. Your player card: [[Founder (You)]].

## Start screen (before the cutscene)
New accounts land on the [[Screen - Start]] title screen first: the eSports Tycoon logo over a blurred shot of their own plot, a loading bar, and one **PRESS TO PLAY** button. Pressing it fades to black and starts the cutscene. Returning players (`Flags.IntroSeen = true`) skip the cutscene and go straight to their garage. Layout reference: ![[BuildAPC_Start_press-to-play.png]].

## Story in one line
You've been grinding ranked in your bedroom for years. Now you've moved to the city with a backpack and a secondhand PC to start your own esports team, with no teammates, no money and one garage your aunt is letting you use.

## Characters
| Character | Role | Look |
|---|---|---|
| **You** | The player's own Roblox avatar (`HumanoidDescription` from the user) | Backpack, hoodie layered over their avatar outfit |
| **Aunt Dee** | Drives you, owns the garage, light comic relief | Cardigan, reading glasses on a chain, car keys on a giant keychain |
| **"Hype" Hector** (voice only) | Caster, on the van radio | Heard, not seen ([[Caster & Commentary]]) |
| **Dr. Data** (voice only) | Second caster, dry comments | Heard on the radio |

## Shot list
| # | Time | Shot | What happens | Audio |
|---|---|---|---|---|
| 1 | 0:00–0:05 | **Black screen → city skyline at dusk** (wide aerial) | Slow push over the city. The **Arena** glows in the far distance, the **Streamr Tower** shows a trending clip on its side, the plaza jumbotron plays someone's highlight. Foreshadows everything you'll reach. | Low synth pad, city ambience |
| 2 | 0:05–0:10 | **Tracking shot of a beat-up van** driving across a bridge | Van has a dented door and a "STUDENT DRIVER" sticker someone forgot to remove. | Van engine, radio static |
| 3 | 0:10–0:17 | **Inside the van, over your shoulder** | You hold a cardboard box with an old PC tower in it. Radio: Hector and Dr. Data recap a Worlds final. | Hector: "...and that's how you win a world title!" · Dr. Data: "Every one of those players started somewhere smaller than this." |
| 4 | 0:17–0:22 | **Close-up of your phone** | Ranked screen: "Peak rank: Silver II." Then a text from Aunt Dee (sitting next to you): "we're here 🙂". | Phone buzz |
| 5 | 0:22–0:28 | **Wide street shot**: van pulls up at a run-down row of garages | The van stops at **your plot** in the real world (camera lines up with your plot's position). Other players' plots are visible down the street. | Brakes squeak |
| 6 | 0:28–0:33 | **Low angle: your feet stepping out**, then the box being set on the curb | You step out, look up at the garage. Aunt Dee leans out the window. | Aunt Dee: "Rent's free while you get started. Make me proud. Or at least make some money." |
| 7 | 0:33–0:38 | **Garage door rolls up** (camera inside the dark garage looking out) | Dust, an old fold table, a flickering bulb that turns on with a *clunk*. A dead plant. One chair with tape on it. | Door rattle, bulb hum |
| 8 | 0:38–0:43 | **Medium shot**: you put the PC box on the table | You pull out the tower, a cracked monitor, a mouse with tape on it. | Cardboard, clunk |
| 9 | 0:43–0:48 | **Van drives off**, camera pulls up and back | Van honks twice. Camera rises over the garage, showing an empty plot with faint outlines where future rooms could be (ghosted build preview). | Honk, music swells |
| 10 | 0:48–0:52 | **Title card** over the garage | **eSports Tycoon** logo, then: *"Every team starts with one player. You."* | Music hit |
| — | 0:52 | **Control handed to the player** | Camera eases into normal third-person behind your avatar. First objective: **"Set up your PC"** | UI chime |
| — | 0:53 | **Starter letter slides in** ([[Screen - Starter Letter]]) | Aunt Dee's handwritten note, "Sell Lemons. Make money." with a P.S. and a money bill. Click the bill to collect the gift and dismiss the letter. | Paper rustle |

## Rules
- **Skip** button appears after 5 s (bottom right, hold 1 s to skip so it isn't hit by accident).
- Plays once per account. Settings → **Replay intro**.
- **Your avatar is used throughout** (no generic character). If the avatar fails to load, use a default rig with the team-to-be colors.
- Runs **locally**: other players in the server don't see it. Your plot is reserved and streamed in during shots 1–4.
- Lighting: dusk preset during the cutscene, blends to the Garage era preset ([[Art & Audio Direction]]).
- No popups during the cutscene. Tutorial popups start after control is handed over.
- Mobile: letterbox bars, captions on by default.

## Studio build notes
- `CutsceneController` (client): `Camera.CameraType = Scriptable`, tween through `CameraPoint_1..10` parts stored in `ReplicatedStorage/Cutscenes/Intro`.
- Van, Aunt Dee and props are client-side clones; destroyed at the end.
- The player's character is anchored and animated with an `Animator` playing intro animations (sit in van, step out, set box down).
- Preload: `ContentProvider:PreloadAsync` on the van, the garage model and the music during the loading screen.
- Captions in `Shared/Config/Cutscenes/IntroLines.lua` so they're easy to translate.
- Analytics: log `IntroStarted`, `IntroSkipped(atSecond)`, `IntroFinished` ([[Analytics & Metrics]]).

## Acceptance criteria
- [ ] New account sees the full cutscene with their own avatar, then gets control in the garage
- [ ] Skip works after 5 s and lands in the same state as finishing
- [ ] Van stops at the player's actual plot
- [ ] Replay from Settings works without changing progress

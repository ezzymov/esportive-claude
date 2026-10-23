---
tags: [ui]
screen: Starter Letter
status: designed
---
# Screen - Starter Letter

## Purpose
A handwritten note that slides onto the screen the moment the [[Intro Cutscene]] ends and the player is dropped at the garage. It sets the first goal in one line ("Sell Lemons. Make money.") and gives a small starter gift. Clicking the money bill on the letter removes the letter and collects the gift.

## Opened from / closes to
- Opens: automatically when the cutscene hands control to the player (end of shot 10 / the `0:52` handover in [[Intro Cutscene]]).
- Closes to: the garage with the [[Tutorial & Onboarding]] first step active ("Set up your PC").

## Layout (anchors, sizes, regions)
- **Paper:** centered, slightly tilted (about -2°), about 60% of screen height on desktop, 85% on phone. Off-white with a black hand-drawn outline. Sits over a dimmed, un-blurred garage view.
- **Sender block:** small grey text, top right ("Aunt Dee" + address line in the same spot as the reference).
- **Greeting:** "Dear {PlayerName}," top left, handwriting font.
- **Headline:** large black handwriting, two lines. Line 1 "Sell Lemons." Line 2 "Make [emoji] [emoji] [emoji]." The emoji are stand-ins: in our build use the currency icon.
- **Sign-off:** "- Aunt Dee", bottom right.
- **P.S.:** bottom left, handwriting font: "P.S. Here's a little something to get you started." Emoji wink.
- **Money bill:** green bill with a paper clip, bottom left, overlapping the paper corner. **This is the only button.** Larger hit area than the bill (about 20 px padding).

## Components used
- `ImageLabel` for the paper (with `UIAspectRatioConstraint`) and the bill
- `TextLabel`s in a handwriting font (ask [[Art & Audio Direction]] for the font pick)
- `TweenService` slide-in and slide-out

## States
- **Entering:** paper slides in from the top edge, 0.6 s, slight wobble. Bill is pulsing.
- **Waiting:** paper rests. Bill has a gentle bob (±3 px, 1.5 s loop) and a hover glow.
- **Collecting:** click on the bill. Bill flies to the currency counter on the HUD (0.5 s), `+N` floating reward plays ([[Tutorial & Onboarding]] → Floating reward), then the paper slides off the bottom of the screen.
- **Already collected:** the letter never appears again for this profile.

## Dismiss rules
- Clicking the bill is the only way to dismiss. Clicking the paper, or pressing Esc, does nothing. (Keeps the gift from being skipped by accident.)
- The paper is not dismissible by the Roblox top-left bar or by opening menus. The letter waits until the bill is clicked.
- Bill click is also available with keyboard or gamepad (focus on the bill, Enter / A).

## References
| Image | Source | What to copy |
|---|---|---|
| ![[Starter-Letter_money-clip_dismiss.png]] | Roblox starter letter | Tilted paper with a hand-drawn outline, handwriting font, the bill with a paper clip as the only action, sender in small grey type top right |

**Copy the feel, not the text.** The sender name and wording in the reference are placeholders. Ours comes from Aunt Dee, the character from the [[Intro Cutscene]].

## Our mockup
_Not drawn yet. Add `Mockups - Ours/Starter Letter v1` when the layout is approved._

## Animations / sounds
- Paper slide-in with a paper rustle.
- Bill click: crisp cash "ka-ching" with a short bass hit.
- Paper slide-out: soft whoosh.
- Voice: Aunt Dee's P.S. line recorded as `TUT_STARTER_LETTER` in [[Tutorial Voice Script]] (caption on screen).

## Data it reads / remotes it calls
- Reads `Profile.Flags.StarterLetterSeen` (boolean). If true, the screen never shows.
- Calls `Starter/Collect` (RF, no args). Returns the starter cash amount. The server grants it once and sets the flag. Client never grants money.
- ⚠ `Flags.StarterLetterSeen` and `Starter/Collect` aren't in [[Data Schema]] or [[Services & Remotes]] yet. Add them with the intro acceptance criteria.
- Amount comes from [[Economy Design]] starter formulas (not fixed here).

## Rules
- One starter gift per account. Rejoin or Replay intro doesn't grant it again. Replay intro from Settings doesn't show the letter again either.
- No timers, no pressure text, no pay prompts ([[Monetization]] principles).
- Mobile: paper scales to fit, bill stays inside the thumb zone.

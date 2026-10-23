---
tags: [system, audio, content]
status: draft
updated: 2026-10-21
---
# Player Voice Lines

What your players say during matches, in the HQ and in training. Two kinds:
1. **Pro packs:** every named pro has their **own** lines, never shared. Full list: [[Pro Voice Lines]].
2. **Generic vibe lines:** one shared pool per **vibe** ([[Player Generator]] → Vibes), reused by every normal player with that vibe.

[[Dev Players]] has his own 86-line pack and must always have the most lines of anyone. The other devs (Philip and appropriateuser) have 30-line packs.

Casters are separate ([[Caster & Commentary]]). The tutorial is separate too ([[Tutorial Voice Script]]).

---

## Who uses what
| Player type | Lines used | Fallback |
|---|---|---|
| **3zzy** | His own pack (86 lines) | — |
| **Other devs** (Philip, appropriateuser) | Own pack, 30 lines ([[Pro Voice Lines]] → Dev packs) | Their vibe pool |
| **Named pros**: all stars in [[Pro Player References]] + all season pros in [[Monthly Seasons]] | Own pack: **12 lines** (Legendary/Epic) or **14** (Mythic: +2 lines when their Mythic unique triggers) | Their vibe's generic pool for events they have no line for (e.g. Tilt) |
| **Key players** ([[Key Players]]) | Generic pool of their vibe (set per player in `KeyPlayers.lua`) | — |
| **Generated players** | Generic pool of their vibe (rolled from seed). Furries add a species sound before PLAY/WIN lines ([[Furry Variants]]) | — |
| **Friend signings** ([[Friend Signings]]) | Generic pool; vibe picked when signing | — |
| **Founder (you)** ([[Founder (You)]]) | Silent by default (it's your avatar). Setting: pick a vibe for your Founder or keep muted | — |

Pros always keep their own lines: a pro is never given generic lines for an event their pack covers.

---

## Events
| Event | Key | When it plays | Where |
|---|---|---|---|
| Signing | `SIGN` | Player joins your roster (case pull, hire, trade, season claim) | Signing popup / walk-in |
| Match start | `START` | Before round 1 / race start / first fight | Match HUD (team comms) |
| Big play | `PLAY` | Kill streak, multi-kill, big overtake, combo, Clip Moment | Match HUD |
| Clutch | `CLUTCH` | Last alive, final lap, last life, match point against you | Match HUD |
| Win | `WIN` | Match won | Results screen |
| Loss | `LOSS` | Match lost | Results screen |
| Tilt | `TILT` | Bad round, crash, dropped combo (light and self-directed only) | Match HUD |
| Rival | `RIVAL` | Start of a rivalry match ([[Rivalries & Storylines]]) | Pre-match |
| Teammate | `MATE` | A teammate makes a big play | Match HUD |
| Idle | `IDLE` | Walking past their desk in the HQ | HQ, 3D bubble |
| Training | `TRAIN` | Training starts or finishes | Training Center |
| Trait (Mythic only) | `TRAIT` | Their Mythic unique triggers | Match HUD |

---

## Rules
### Writing
- Short: **≤ 10 words** per line (they show in a bubble and play over action).
- **No dynamic names in audio.** Pros may say their own tag. Nobody voices teammate names, team names or rival names; captions may add `{player}` / `{rival}`.
- Kid-friendly: no swearing, no insults toward teammates, no real-world groups. Trash talk is playful and aimed at the opponent's *play*, not people.
- **Tilt lines are self-directed** ("My bad.") and never blame teammates.
- Pros copy a **playstyle and personality**, never a real person's catchphrase or famous quote ([[Pro Player References]] IP rule).
- Season pros lean into their season theme ([[Monthly Seasons]]).

### Playback
- **One voice at a time.** Casters have priority: a player line waits up to 2 s for the caster, otherwise it's skipped.
- **Match cap:** max 1 player line per round (or per lap or fight), max ~8 per match.
- **Priority** when several players qualify: `CLUTCH` > `TRAIT` > `PLAY` > `MATE` > others; then Signature > Mythic > Legendary > others.
- **Per player cooldown:** 30 s in matches; `IDLE` max once per 3 min per desk, only within 20 studs, one idle line audible at a time.
- **No repeats:** last 4 lines per player per event are skipped.
- Match lines play with a light "team radio" filter. HQ lines play in 3D at the desk.
- Text bubble always shows (muted players, accessibility).
- **Setting:** Player voices: **All / Big moments only / Off** (Big moments = `CLUTCH`, `TRAIT`, `WIN`, `SIGN`).

### Recording & rollout
- **Phase 1 (launch):** text bubbles only, with no audio cost.
- **Phase 2:** record 3zzy + all Mythic packs + the generic pools.
- **Phase 3:** record all Legendary/Epic pro packs.
- Generic pools: each vibe recorded by **2 voices** (A and B); generated players pick A/B from their seed so two Hype players don't sound identical.
- Pros: a small voice cast can cover several pros by changing delivery, but no two pros on the **same title** share a voice actor.
- File names = line id, e.g. `VO_GEN_HYPE_PLAY_1_A.ogg`, `VO_THUD_CLUTCH_1.ogg`. Status per pack: ☐ not recorded · 🎙 recorded · ✅ uploaded.
- All audio goes through Roblox audio upload and moderation.

## Config
```lua
-- Shared/Config/VoiceLines.lua
VoiceLines = {
  Generic = {
    Hype = { SIGN = { "VO_GEN_HYPE_SIGN_1", "VO_GEN_HYPE_SIGN_2" }, PLAY = { ... }, ... },
    ...
  },
  Pros = {
    thud = { Vibe = "Tryhard", Voice = "VA_07", Lines = { SIGN = { "VO_THUD_SIGN_1" }, PLAY = { ... }, TRAIT = { ... } } },
    ...
  },
}
-- Line text lives in Shared/Config/VoiceText.lua (id → text), for captions and localization.
```
- Server fires the **event** (`PlayerLine { cardUuid, event }`). The client picks the line, so there's no server cost and no network audio. This matches how caster lines work.
- **Validation script** (runs with the content checks):
  - every pro in [[Pro Player References]] and [[Monthly Seasons]] has a pack
  - every Mythic has 2 `TRAIT` lines
  - every vibe has ≥ 2 lines per event
  - every line ≤ 10 words
  - 3zzy line count > largest pro pack + 20

---

## Generic vibe lines (shared by normal players)
2 lines per event per vibe = **176 lines**. Add a third line per event in a later update so they repeat less.

### Tryhard
| Event | Line 1 | Line 2 |
|---|---|---|
| SIGN | "Finally. Let's get to work." | "I'm here to win. That's it." |
| START | "Focus. No mistakes." | "Lock in, everyone." |
| PLAY | "Got him." | "That's the standard." |
| CLUTCH | "Quiet. I need to focus." | "I've practiced this." |
| WIN | "Good. Now we practice more." | "Earned it." |
| LOSS | "Unacceptable. Again." | "We review tonight." |
| TILT | "Come on, focus!" | "That was sloppy. My bad." |
| RIVAL | "I want them. Bad." | "I've studied every one of them." |
| MATE | "Good. Keep that level." | "Nice. Exactly right." |
| IDLE | "Rest is for later. Much later." | "One more hour of practice." |
| TRAIN | "Again. Until it's perfect." | "Harder drill, please." |

### Chill
| Event | Line 1 | Line 2 |
|---|---|---|
| SIGN | "Cool, cool. Nice place." | "Hey. Happy to be here." |
| START | "Let's have fun out there." | "No stress, team." |
| PLAY | "Nice." | "Smooth." |
| CLUTCH | "Easy… easy…" | "All good. I got it." |
| WIN | "GG. Snacks?" | "Chill win." |
| LOSS | "It's fine. We'll get 'em." | "Shake it off." |
| TILT | "Whoops. My bad." | "Okay, that one hurt." |
| RIVAL | "Eh. They're alright." | "No beef. Just winning." |
| MATE | "Sick play." | "Love that." |
| IDLE | "Just vibing." | "This chair is comfy." |
| TRAIN | "Few more reps, then a nap." | "Easy pace, steady gains." |

### Nerd
| Event | Line 1 | Line 2 |
|---|---|---|
| SIGN | "Statistically, great signing." | "I brought my notes." |
| START | "Running the numbers. Looks good." | "Remember the plan. Page three." |
| PLAY | "Calculated." | "Exactly as modeled." |
| CLUTCH | "Low odds. I like low odds." | "Variables accounted for." |
| WIN | "Win probability: one hundred percent." | "Data confirmed." |
| LOSS | "Interesting. More data needed." | "Outlier. We move on." |
| TILT | "That wasn't in my model." | "Error detected. Mine." |
| RIVAL | "I've charted all their habits." | "Their patterns are predictable." |
| MATE | "Efficient play." | "Mathematically beautiful." |
| IDLE | "Updating my spreadsheet." | "Did you know… never mind." |
| TRAIN | "Optimizing my routine." | "Small gains. Every day." |

### Hype
| Event | Line 1 | Line 2 |
|---|---|---|
| SIGN | "LET'S GO! I'm on the team!" | "Best day ever!" |
| START | "Let's make some NOISE!" | "Hype up, team!" |
| PLAY | "YEAH!" | "WHAT A PLAY!" |
| CLUTCH | "Watch this! WATCH THIS!" | "Crowd, get loud!" |
| WIN | "WINNERS! That's us!" | "WOOO!" |
| LOSS | "We'll be back LOUDER!" | "Nooo! Next one!" |
| TILT | "Argh! Come on, me!" | "So annoying!" |
| RIVAL | "THESE guys? Let's go!" | "Rivalry day! Best day!" |
| MATE | "YOU'RE INSANE!" | "Let's GO, teammate!" |
| IDLE | "Can we play now? Now?" | "Somebody say hype!" |
| TRAIN | "MORE! FASTER!" | "Training montage time!" |

### Streamer
| Event | Line 1 | Line 2 |
|---|---|---|
| SIGN | "Chat, we got a new team!" | "Don't forget to follow!" |
| START | "Going live! Let's pop off." | "Hi chat! Big match today." |
| PLAY | "Clip it!" | "Chat, did you see that?" |
| CLUTCH | "Chat, quiet. I'm focusing." | "Content incoming." |
| WIN | "GG! Thanks for the support!" | "Chat, we won!" |
| LOSS | "Chat, it was the lag." | "Rough one, chat." |
| TILT | "Chat, I swear I hit that." | "That didn't happen, chat." |
| RIVAL | "Chat, these guys again?" | "This is gonna be content." |
| MATE | "Shout-out to my teammate!" | "Chat, spam hearts for them!" |
| IDLE | "Chat's asking about my setup." | "Hydrate, chat." |
| TRAIN | "Aim training on stream. Thrilling." | "Grinding for you, chat." |

### Veteran
| Event | Line 1 | Line 2 |
|---|---|---|
| SIGN | "Been around. I'll help where I can." | "This team has potential." |
| START | "Steady. Just like practice." | "Breathe, rookies." |
| PLAY | "Still got it." | "Experience, kid." |
| CLUTCH | "Done this a hundred times." | "Slow down. Think." |
| WIN | "Good win. Stay humble." | "That's how it's done." |
| LOSS | "Losses teach more. Learn." | "Happens. Move on." |
| TILT | "Old hands, new mistake." | "Getting rusty." |
| RIVAL | "Played them for years. Same habits." | "Respect them. Then beat them." |
| MATE | "Good kid." | "Proud of that one." |
| IDLE | "My back hurts. Coffee helps." | "Back in my day, chairs were worse." |
| TRAIN | "Fundamentals. Always fundamentals." | "Slow is smooth. Smooth is fast." |

### Mysterious
| Event | Line 1 | Line 2 |
|---|---|---|
| SIGN | "I'll be here. Watching." | "Hm. Interesting team." |
| START | "Let them guess." | "Silence is a weapon." |
| PLAY | "Hm." | "They never saw me." |
| CLUTCH | "Shadows." | "Quietly, now." |
| WIN | "As expected." | "Hm. Good." |
| LOSS | "Noted." | "Next time." |
| TILT | "…Unlucky." | "Hm. No." |
| RIVAL | "I know their secrets." | "They should be worried." |
| MATE | "Not bad." | "…Nice." |
| IDLE | "Don't look at me." | "I'm not here." |
| TRAIN | "Always practicing. In the dark." | "Quiet reps." |

### Goofball
| Event | Line 1 | Line 2 |
|---|---|---|
| SIGN | "Do I get a free hat?" | "Hi! I brought snacks!" |
| START | "Let's goof AND win!" | "Wheee! Game time!" |
| PLAY | "Did I do that?!" | "Boop! Got 'em!" |
| CLUTCH | "Okay, okay, okay, OKAY!" | "Hold my snack." |
| WIN | "Victory dance! Everybody!" | "We did it! I think!" |
| LOSS | "Oopsie daisy." | "At least the snacks were good." |
| TILT | "My hand slipped. On purpose." | "I sneezed!" |
| RIVAL | "Bet they can't do this dance." | "Their jerseys? Questionable." |
| MATE | "You're my hero! Today!" | "Air high five!" |
| IDLE | "Spinning chair speedrun." | "Is that my sandwich?" |
| TRAIN | "Training? I read 'snacking'." | "Look, I'm practicing! Mostly." |

---

## Line counts
| Group | Packs | Lines each | Total |
|---|---|---|---|
| Generic vibes | 8 | 22 | 176 |
| Mythic pros (7 stars + 12 season headliners) | 19 | 14 | 266 |
| Legendary/Epic pros (19 stars + 24 season Legendaries) | 43 | 12 | 516 |
| 3zzy | 1 | 86 | 86 |
| Other devs | 2 | 30 | 60 |
| **Total** | | | **1,104** |

The biggest other pack is 30 lines (devs), and 3zzy has 86, so the 3zzy rule (more than the biggest pack + 20) holds with room to grow.

Links: [[Pro Voice Lines]] · [[Caster & Commentary]] · [[Player Generator]] · [[Pro Player References]] · [[Monthly Seasons]] · [[Art & Audio Direction]]

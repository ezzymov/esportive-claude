---
tags: [system, audio, stage/1]
status: draft
---
# Tutorial Voice Script

Recording script for every voiced line in [[Tutorial & Onboarding]]. **Draft 1 (2026-10-20)** — edit freely before recording.

Speakers: **Aunt Dee** (the guide) and **"Hype" Hector** (milestone shouts only, see [[Caster & Commentary]]).

## Recording rules
- **No numbers in the audio.** Prices and amounts get tuned in [[Balance Tables]], so lines say "enough cash", not "$300". The caption and tracker show the number.
- **No player or team names in the audio.** We can't voice what the player types. Dee says "kid", "your team", "your crew". The caption may add `{team}`.
- **Short.** Normal lines ≤ 12 words (fits the popup). Phone **calls** (stall help at 120 s) can go up to ~25 words.
- **Dee's arc:** in Stage 1 she knows nothing about esports and is a little confused. By Stage 5+ she's picking up the lingo and is openly proud. By Stage 10 she's your biggest fan.
- Record **2 takes** of every line: one warm, one drier. Pick in the edit.
- File names = line id (`TUT_POWERON_1.ogg`), so `Lines.lua` can link them automatically.
- `Status`: ☐ not recorded · 🎙 recorded · ✅ uploaded (fill in the asset id).

## Character sheet — Aunt Dee
| | |
|---|---|
| Age / vibe | Late 50s, owns the garage, cardigan, reading glasses on a chain |
| Voice | Warm, quick, dry jokes. Never shouts (that's Hector's job) |
| Relationship | Loves you, doesn't get gaming, believes in you anyway |
| Verbal habits | Calls you "kid". Gets gaming words slightly wrong early on ("the clicky thing", "your K-D-whatever"). Signs off texts with "xo Dee" only on big moments |
| Never | Swears, mocks the player for losing, explains with jargon |

---

## Stage 1 — Guided FTUE
Each step has: **Intro** (plays when the step starts), **Hint** (60 s stall text), **Call** (120 s stall phone call, ends with the "Show me" button), and sometimes **Done** (on completion).

### 1 · NameTeam
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_NAMETEAM_1 | Dee | "Every team needs a name. Make it loud." | Encouraging, a little dramatic | ☐ | |
| TUT_NAMETEAM_HINT | Dee | "I already picked one for you. Keep it or change it." | Helpful | ☐ | |
| TUT_NAMETEAM_CALL | Dee | "Kid, it's just a name. Tap the button, you can change it later. Free, even. For a while." | Patient, teasing at the end | ☐ | |
| TUT_NAMETEAM_DONE | Dee | "Ooh. I'll paint that on a bedsheet." | Delighted | ☐ | |

### 2 · PowerOn
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_POWERON_1 | Dee | "Plug it in. Red cable, red port. I'm not a tech." | Brisk, self-aware | ☐ | |
| TUT_POWERON_HINT | Dee | "The cables go in the back of the tower. Match the colors." | Helpful | ☐ | |
| TUT_POWERON_CALL | Dee | "Okay, I watched a video. Colors match colors, then you press the big button. That's all I've got." | Proud of her research | ☐ | |
| TUT_POWERON_DONE | Dee | "It turned on! Nobody touch anything." | Genuinely surprised | ☐ | |

### 3 · SitDesk
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_SITDESK_1 | Dee | "Sit down. Apparently sitting makes money now." | Baffled | ☐ | |
| TUT_SITDESK_HINT | Dee | "Your chair's the one with the tape on it." | Dry | ☐ | |
| TUT_SITDESK_CALL | Dee | "Kid, the internet pays you to practice on stream. I don't get it either. Go sit at your desk." | Amused | ☐ | |
| TUT_SITDESK_DONE | Dee | "Look at that number go up. Is that legal?" | Half joking | ☐ | |

### 4 · FirstPug
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_FIRSTPUG_1 | Dee | "Some strangers online need a fifth player. Go help them." | Motherly | ☐ | |
| TUT_FIRSTPUG_HINT | Dee | "Hit the Pickup Game button on your screen." | Helpful | ☐ | |
| TUT_FIRSTPUG_CALL | Dee | "You came all this way to play games. So play one! The button's right there on your desk screen." | Encouraging push | ☐ | |
| HEC_FIRSTWIN | Hector | "FIRST WIN! From a GARAGE! Somebody write this down!" | Full hype | ☐ | |

### 5 · AimTrainer
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_AIM_1 | Dee | "That old arcade thing still works? Huh. Try it." | Surprised, nostalgic | ☐ | |
| TUT_AIM_HINT | Dee | "The cabinet in the corner. It pays a little, too." | Helpful | ☐ | |
| TUT_AIM_CALL | Dee | "Your uncle used to play that cabinet every night. Go see if you're better than him. It shouldn't be hard." | Fond, teasing | ☐ | |
| TUT_AIM_DONE | Dee | "Your aim got better. I could tell. Probably." | Unsure but supportive | ☐ | |

### 6 · TechFix
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_TECHFIX_1 | Dee | "Mrs. Park's computer died again. She pays." | Gossipy | ☐ | |
| TUT_TECHFIX_HINT | Dee | "She left it on the bench by the door." | Helpful | ☐ | |
| TUT_TECHFIX_CALL | Dee | "Mrs. Park keeps calling me about that computer. Please fix it so she stops. I'll owe you." | Exasperated | ☐ | |
| TUT_TECHFIX_DONE | Dee | "She says you're a genius. She also says that about her cat." | Deadpan | ☐ | |

### 7 · FirstUpgrade
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_UPGRADE_1 | Dee | "Better mouse, better aim. Even I get that." | Pleased with herself | ☐ | |
| TUT_UPGRADE_HINT | Dee | "That taped-up mouse has to go. Check the pad." | Helpful | ☐ | |
| TUT_UPGRADE_CALL | Dee | "Kid, your mouse is held together with tape. You have enough cash for a new one. Treat yourself." | Caring | ☐ | |
| TUT_UPGRADE_DONE | Dee | "See? Your numbers went up. I'm learning." | Proud of both of you | ☐ | |

### 8 · SecondDesk
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_DESK2_1 | Dee | "You can't carry a team alone. Literally. Buy another desk." | Wry | ☐ | |
| TUT_DESK2_HINT | Dee | "There's a glowing pad by the wall. Stand on it." | Helpful | ☐ | |
| TUT_DESK2_CALL | Dee | "A team with one player is just… you. Save up and grab that second desk. Somebody's going to need it." | Gentle push | ☐ | |
| TUT_DESK2_DONE | Dee | "An empty desk. Very hopeful. I'll make a 'Hiring' sign." | Warm | ☐ | |

### 9 · FirstHire
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_HIRE_1 | Dee | "Your friend Rusty from school is looking for a team." | Casual, knowing | ☐ | |
| TUT_HIRE_HINT | Dee | "The free agent board is up. Rusty's right at the top." | Helpful | ☐ | |
| TUT_HIRE_CALL | Dee | "Rusty's mom told me he's been waiting by the phone. Don't make him wait. Hire him!" | Playful guilt trip | ☐ | |
| TUT_HIRE_DISCOUNT | Dee | "Good news. Rusty says he'll play for cheap. Very cheap." | Conspiratorial (12-min guardrail) | ☐ | |
| HEC_FIRSTHIRE | Hector | "A SIGNING! The roster doubles! Overnight! Incredible!" | Full hype | ☐ | |
| TUT_HIRE_DONE | Dee | "His desk earns even when you're out. That's the trick." | Explaining something she just figured out | ☐ | |

### 10 · TeamPug
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_TEAMPUG_1 | Dee | "Two of you now. Go win something together." | Encouraging | ☐ | |
| TUT_TEAMPUG_HINT | Dee | "Same button as before. Now Rusty plays too." | Helpful | ☐ | |
| TUT_TEAMPUG_CALL | Dee | "Rusty's been warming up for ten minutes. He's stretching. I didn't know you stretch for this. Go play!" | Amused | ☐ | |
| HEC_DYNASTY | Hector | "The dynasty begins! Remember where you saw it first!" | Full hype | ☐ | |

### 11 · FirstUnbox
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_UNBOX_1 | Dee | "You won a crate! Open it. I love surprises." | Excited | ☐ | |
| TUT_UNBOX_HINT | Dee | "Your crate is waiting. The glowing box." | Helpful | ☐ | |
| TUT_UNBOX_CALL | Dee | "Kid, there's a whole new player in that box. Well, not literally. I hope. Open it!" | Mock worried | ☐ | |
| TUT_UNBOX_GLOW | Dee | "If it glows blue, that's good. I think." | Unsure, plays during the reveal | ☐ | |
| HEC_FIRSTRARE | Hector | "BLUE! That is a RARE pull! What a start!" | Full hype | ☐ | |

### 12 · SeatRare
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_SEAT_1 | Dee | "New player needs a desk. Third one's on me. Kidding." | Deadpan joke | ☐ | |
| TUT_SEAT_HINT | Dee | "Another pad just showed up. You know the drill." | Helpful | ☐ | |
| TUT_SEAT_CALL | Dee | "Your new player is standing in my garage holding a keyboard. It's awkward. Buy them a desk." | Awkward, funny | ☐ | |
| TUT_SEAT_DONE | Dee | "Three of you. It's starting to look like a real team." | Touched | ☐ | |

### 13 · Promotion
| Id | Speaker | Line | Direction | Status | Asset |
|---|---|---|---|---|---|
| TUT_PROMO_1 | Dee | "Win a few more and people will notice. That's Fame, right?" | Curious, guessing at the word (new 2026-10-23: step 13 is now "Reach 100 Fame") | ☐ | |
| TUT_PROMO_HINT | Dee | "Play another Pickup Game. Wins bring Fame." | Helpful | ☐ | |
| TUT_PROMO_CALL | Dee | "The café down the street wants teams with a bit of a name. Win a couple more and they'll call." | Conspiratorial, sets up Stage 2 | ☐ | |
| TUT_RENAME_REMIND | Dee | "Last chance to change your team name for free." | Friendly warning (plays before promotion) | ☐ | |
| HEC_PROMO_S2 | Hector | "Café Rookies, here they come! Out of the garage!" | Full hype | ☐ | |
| TUT_GRADUATE | Dee | "You did it, kid. I'm keeping the old mouse. For the wall." | Proud, a little emotional · xo Dee | ☐ | |

---

## Situational lines (Stage 1)
| Id | Speaker | Line | When | Status | Asset |
|---|---|---|---|---|---|
| TUT_BROKE | Dee | "Spent it all? Classic. Sit at your desk for a bit." | Cash too low for the current goal | ☐ | |
| TUT_OFFPLOT | Dee | "Where are you going? The garage is this way." | Player wanders off the plot | ☐ | |
| TUT_WELCOMEBACK | Dee | "Welcome back! Let's pick up where you left off." | Rejoin mid-FTUE | ☐ | |
| TUT_SKIP_CONFIRM | Dee | "Played before, huh? Okay, hotshot. I'll keep it short." | "I've played before" tapped | ☐ | |
| TUT_LOSS | Dee | "You lost? That's fine. Everybody loses. Go again." | Lost a Pickup Game (after the guaranteed one) | ☐ | |
| TUT_VISITOR | Dee | "Someone's checking out your garage. Wave!" | Another player visits your plot | ☐ | |

---

## Unlock lessons (Stages 2–10)
Dee's voice gets more confident each stage. Each lesson: **Intro** + **Done** (+ a Hint at 60 s for the ones with actions).

| Id | Speaker | Line | Unlock | Status | Asset |
|---|---|---|---|---|---|
| TUT_REACT_1 | Dee | "Another arcade machine? This one tests your reflexes." | Reaction Test (S2) | ☐ | |
| TUT_REACT_DONE | Dee | "Faster hands. Your card says so." | Reaction Test (S2) | ☐ | |
| TUT_SHOP_1 | Dee | "There's a whole shop for gear now. Fancy." | Tech Shop (S2) | ☐ | |
| TUT_SHOP_HINT | Dee | "Start small. A budget mouse is fine." | Tech Shop (S2) | ☐ | |
| TUT_SHOP_DONE | Dee | "Watch the numbers on the card. Green means better." | Tech Shop (S2) | ☐ | |
| TUT_CRATETIMER_1 | Dee | "Free crate every so often. Check the timer." | Rookie Crate timer (S2) | ☐ | |
| TUT_ROLES_1 | Dee | "Five desks! Put each player in the role they like." | 5-man roster (S2) | ☐ | |
| TUT_ROLES_DONE | Dee | "Right player, right role. Look at that bonus." | 5-man roster (S2) | ☐ | |
| TUT_SCRIM_1 | Dee | "Scrims are practice matches. Win them to climb the ladder." | Scrims + Ladder (S3) | ☐ | |
| TUT_SCRIM_DONE | Dee | "Ladder points! I'm told those matter." | Scrims + Ladder (S3) | ☐ | |
| TUT_TRAIN_1 | Dee | "A training room. Send someone in to get better." | Training Center (S3) | ☐ | |
| TUT_TRAIN_DONE | Dee | "They'll be done soon. Even pros practice." | Training Center (S3) | ☐ | |
| TUT_CLIP_1 | Dee | "Your best plays can go online. Let's make a clip." | Clip Studio (S4) | ☐ | |
| TUT_CLIP_HINT | Dee | "Pick a trending tag. More people will see it." | Clip Studio (S4) | ☐ | |
| TUT_CLIP_DONE | Dee | "Uploaded! I'm going to share it with my book club." | Clip Studio (S4) | ☐ | |
| TUT_SPONSOR_1 | Dee | "A company wants to sponsor you. Read before you sign!" | Sponsors (S4) | ☐ | |
| TUT_SPONSOR_DONE | Dee | "Their logo's on your jersey now. Very official." | Sponsors (S4) | ☐ | |
| TUT_STAFF_1 | Dee | "You've got a coach now. First one's free." | Staff (S5) | ☐ | |
| TUT_STAFF_DONE | Dee | "Pick a tactic. The coach handles the yelling." | Staff (S5) | ☐ | |
| TUT_TITLE2_1 | Dee | "A second game? Tower Clash needs its own five players." | 2nd game title (S5) | ☐ | |
| TUT_TITLE2_DONE | Dee | "Two leagues, two paychecks. Now we're talking." | 2nd game title (S5) | ☐ | |
| TUT_TRANSFER_1 | Dee | "Got a duplicate player? Sell them on the transfer list." | Transfer list (S5) | ☐ | |
| TUT_STREAM_1 | Dee | "A streaming booth! Pick your most charming player." | Streaming Booth (S6) | ☐ | |
| TUT_MERCH_1 | Dee | "Fans want your jerseys. Design your first drop." | Merch (S6) | ☐ | |
| TUT_MERCH_DONE | Dee | "I bought three. Don't tell anyone." | Merch (S6) | ☐ | |
| TUT_ACADEMY_1 | Dee | "An academy for young talent. Sign your first prospect." | Academy (S7) | ☐ | |
| TUT_ACADEMY_DONE | Dee | "Look at you, mentoring. I'm getting emotional." | Academy (S7) | ☐ | |
| TUT_ARENA_1 | Dee | "An arena. Your own arena. Set the ticket price." | Arena (S8) | ☐ | |
| TUT_ARENA_DONE | Dee | "Remember the garage? Because I'm trying not to cry." | Arena (S8) | ☐ | |
| TUT_REBIRTH_1 | Dee | "World champions. Now you can start over, stronger." | Rebirth (S10) | ☐ | |
| TUT_REBIRTH_2 | Dee | "You keep your legend, your founder, and your lessons." | Rebirth (S10) | ☐ | |
| TUT_REBIRTH_DONE | Dee | "New city, new garage. I'll drive. xo Dee" | Rebirth (S10) | ☐ | |
| HEC_REBIRTH | Hector | "From the garage to the WORLD! And they're doing it AGAIN!" | Rebirth (S10) | ☐ | |

---

## "?" screen cards
One line per screen. These explain the screen in Dee's words; the card text can carry the details.

| Id | Speaker | Line | Screen | Status | Asset |
|---|---|---|---|---|---|
| HELP_HUD | Dee | "Cash, fame, your goal. Everything important is up top." | [[Screen - Main HUD]] | ☐ | |
| HELP_TEAMCREATOR | Dee | "Name, logo, jersey. This is who you are." | [[Screen - Team Creator]] | ☐ | |
| HELP_ROSTER | Dee | "Your players. Drag them into the active five." | [[Screen - Roster]] | ☐ | |
| HELP_TECHSHOP | Dee | "Better gear, better stats. Compare before you buy." | [[Screen - Tech Shop]] | ☐ | |
| HELP_CASE | Dee | "Open crates here. The odds are always listed." | [[Screen - Case Opening]] | ☐ | |
| HELP_MATCHHUD | Dee | "Your match, live. Tap in for Clutch Moments." | [[Screen - Match HUD]] | ☐ | |
| HELP_BRACKET | Dee | "Win your match, move up the bracket. Simple." | [[Screen - Bracket]] | ☐ | |
| HELP_SPONSORS | Dee | "Sponsors pay you to wear their logo. Read the terms." | [[Screen - Sponsors]] | ☐ | |
| HELP_STAFF | Dee | "Staff make your players better. Coaches, analysts, the works." | [[Screen - Staff & Training]] | ☐ | |
| HELP_QUESTS | Dee | "Daily jobs for extra rewards. New ones every day." | [[Screen - Quests]] | ☐ | |
| HELP_SETTINGS | Dee | "Sound, hints, odds. Make the game yours." | [[Screen - Settings & Odds]] | ☐ | |
| HELP_STORE | Dee | "Extras and boosts. You never need them to win." | [[Screen - Store]] | ☐ | |
| HELP_TRADE | Dee | "Trade with friends. Check both sides before you accept." | [[Screen - Trade]] | ☐ | |
| HELP_CLIPFEED | Dee | "Everyone's best plays. Watch, like, get ideas." | [[Screen - Clip Feed]] | ☐ | |
| HELP_STICKER | Dee | "Stickers go on skins. Place them anywhere you like." | [[Screen - Sticker Editor]] | ☐ | |
| HELP_REBIRTH | Dee | "Start a new run with bonuses. Your legend comes too." | [[Screen - Rebirth]] | ☐ | |

---

## Line count
| Group | Dee | Hector |
|---|---|---|
| Stage 1 steps | 52 | 5 |
| Situational | 6 | 0 |
| Unlock lessons | 32 | 1 |
| "?" cards | 16 | 0 |
| **Total** | **106** | **6** |

~112 lines × 2 takes. At ~3–5 s per line that's roughly **8–10 minutes of finished audio**.

## Open questions
- Is "Mrs. Park" and her cat a recurring neighbor? (Easy callback in later Tech Fix jobs.)
- Does Dee ever appear in person after the intro (e.g. at the Arena opening), or is she phone-only?
- Should Hector's shouts have 2–3 variants each so replays and later stages don't repeat?

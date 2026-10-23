---
tags: [feature, monetization, content]
status: designed
priority: P1
stage: 3
updated: 2026-10-21
system_type: DataModel
engine_layer: ServerService
dependencies:
  - "[[Trait Library]]"
  - "[[Match Simulation]]"
  - "[[Case Library]]"
  - "[[Balance Tables]]"
  - "[[Security & Anti-Exploit]]"
  - "[[Services & Remotes]]"
affected_ui:
  - "[[Screen - Roster]]"
  - "[[Screen - Settings & Odds]]"
roblox_execution_environment: ServerScriptService
---
# Dev Players

## Summary
The game's developers appear as playable cards in a rarity above Mythic: **Dev ✦**. Each dev **specializes in two stats**. In those stats they're always **30% better than the best player you own in that stat**.

| Dev | Specialty stats | Role | Trait |
|---|---|---|---|
| **3zzy** | **Aim + Clutch** | Sniper | Main Character |
| **Philip** | **Game Sense + Teamwork** | Strategist (IGL) | Patch Notes |
| **appropriateuser** | **Aim + Reflexes** | Entry | Hotfix |

The only way to get a dev is the **Dev Crate**. Each open costs **500 R$** or a **very expensive 2,500 Gems**, and the odds are shown up front. **Every dev has the same pull chance.** The total dev chance starts at **0.2%** at Stage 3 and grows with progress, never above **1.5%**. A **Dev Pity** guarantees a dev within **75 opens**. Devs don't duplicate and can never be traded. At **200 CCU** the specialty boost rises from **30% to 40%** for every dev.

> ⚠️ **Exception to the monetization rules.** [[Monetization]] says Robux never buys a stat edge you can't earn free, and [[Microtransaction Ideas]] lists "exclusive stat-power players for Robux" under ideas to avoid. Dev players are a deliberate, documented exception. The same crate can be opened with Gems from quests, so there is a free path, but it's very slow. Don't add more pay-for-power items outside this system.

> 🪪 **Real people.** The devs are real members of the team. Get each dev's OK on their tag, look and voice before shipping. A dev card is a game character. The dev's real Roblox account is still excluded from the global showcase ([[Social & Multiplayer]] → Global Top Teams showcase).

---

## How dev stats work
Each dev has two **specialty stats** and four **normal stats**.
```
pool        = every card on your roster (active + bench + academy) EXCEPT dev cards
boost       = 1.30   (1.40 after the 200 CCU milestone)

specialty   = round( max(pool[stat]) × boost )    -- 30% above your best player IN THAT STAT
normal stat = round( average(pool[stat]) )        -- an ordinary teammate everywhere else
OVR         = role-weighted OVR from those six stats (Balance Tables role weights)
```
- **"Best" is per stat.** 3zzy's Aim scales off your best aimer, and his Clutch scales off your best clutch player, even if those are two different people.
- **Recalculated on every roster change** (hire, release, trade, training gain). Dev stats are derived and never saved, so they can't drift or be edited.
- **Devs never scale off each other.** Dev cards are excluded from the pool, so owning all three can't create a loop.
- **Specialty stats can pass 99.** Dev cards are the only cards allowed to. Hard cap **130**. Floor **50** for specialty stats, so a dev is still useful at Stage 1.
- **Play every title at full stats** (like the Adaptable trait).
- Training is disabled for dev cards (their stats are derived).
- [[Match Simulation]] must accept stats above 99 for Dev ✦ cards only. Every other card stays clamped at 99.

### Example
Your roster (not counting devs): best Aim 88, best Reflexes 91, best Game Sense 84, best Teamwork 80, best Clutch 90. Roster averages are around 70.
| Dev | ×1.3 specialties | ×1.4 after 200 CCU | Normal stats |
|---|---|---|---|
| 3zzy | Aim **114**, Clutch **117** | Aim 123, Clutch 126 | ~70 |
| Philip | Game Sense **109**, Teamwork **104** | 118, 112 | ~70 |
| appropriateuser | Aim **114**, Reflexes **118** | 123, 127 | ~70 |

So devs are monsters in their lane and ordinary elsewhere, which makes them **fit a team** rather than replace it.

---

## The dev cards

### 3zzy
| Field | Value |
|---|---|
| Specialty | **Aim + Clutch** |
| Role | Sniper (game-winning shots under pressure) |
| Trait | **Main Character** (unique): +2 Clip Moments per match; caster and crowd reactions to his plays are one intensity higher |
| Vibe / voice | Confident, funny, a bit of a showman. The face of the game. Dev in-jokes about "his" game |
| Look | *TBD with 3zzy:* his avatar style + a gold "DEV" lanyard as the signature item |
| Voice pack | **86 lines** (the most of anyone; see below) |

### Philip
| Field | Value |
|---|---|
| Specialty | **Game Sense + Teamwork** |
| Role | Strategist (IGL) |
| Trait | **Patch Notes** (unique): once per match, after a lost round, he "patches" the strategy: team +10 Teamwork for the next 2 rounds |
| Vibe / voice | Calm, organized, dry humor. The dev who reads every bug report. Talks about the team like a codebase |
| Look | *TBD with Philip:* his avatar style + a clipboard covered in sticky notes |
| Voice pack | 30 lines ([[Pro Voice Lines]] → Dev packs) |

### appropriateuser
| Field | Value |
|---|---|
| Specialty | **Aim + Reflexes** |
| Role | Entry (first in, fastest hands) |
| Trait | **Hotfix** (unique): after a lost round, +8 Aim and +8 Reflexes for the next round ("pushing a hotfix") |
| Vibe / voice | Plays off his username: extremely polite, formal and apologetic, while being the fastest hands on the team ("Pardon me." *instant headshot*). Fallback vibe: Chill |
| Look | *TBD with appropriateuser:* his avatar style + a neat tie over the jersey and a "Be Nice" desk sign |
| Voice pack | 30 lines ([[Pro Voice Lines]] → Dev packs) |
| Card name | The full username is long. Card frames and nameplates must fit 15 characters without shrinking the text below the [[UI Style Guide]] minimum |

---

## Dev Crate
| Field | Value |
|---|---|
| Price | **500 R$** per open (developer product) **or 2,500 Gems** per open. Same odds either way |
| Unlock | **Stage 3** |
| Contents | **Dev slot** (progress-based chance) + a Legendary/Mythic-heavy pool + dev cosmetics (DEV lanyard, dev desk sticker set, "Patch Notes" jersey, gold dev card frame) |
| Odds without a dev | Rare 25% · Epic 45% · Legendary 24% · Mythic 6%, scaled to fill whatever the dev chance leaves |
| Dev pull chance | **Equal for every dev**: each dev gets exactly 1/3 of the dev chance (1/N if more devs are added) |
| Dev you already own | That dev's share rolls a **Mythic** instead. Per-dev odds never change, and there are no duplicates |
| **Dev Pity** | Every open adds 1. If you reach your **75th open** without a dev, that open is a **guaranteed dev** (picked evenly among devs you don't own). The counter resets whenever you get a dev, by luck or by pity. It counts Gem and Robux opens together, keeps through rebirths, and switches off once you own every dev |
| Other pity | The normal Legendary pity family applies to the rest of the pool |
| Look | Black-and-gold server rack with a glowing ✦ and blinking LEDs |
| Opening | Shows the odds on the crate screen **before** the Robux prompt (see Odds display) |

### Dev chance by progress
Odds use your **highest stage ever reached + rebirths**, so rebirthing never lowers them. The same table applies to both the Robux and Gem versions. Progress raises your luck; the **75-open pity** caps the worst case for everyone.

| Progress | Total dev chance | Each dev (÷3) | Chance of a dev before pity | Avg opens to a dev (with pity) | Avg R$ at 500 | Avg R$ at 1,000 (after 150 CCU) | Avg Gems |
|---|---|---|---|---|---|---|---|
| Stage 3 | 0.2% | 0.067% | 14% | ~70 | ~35,000 | ~70,000 | ~174,000 |
| Stage 4 | 0.3% | 0.1% | 20% | ~67 | ~34,000 | ~67,000 | ~168,000 |
| Stage 5 | 0.4% | 0.13% | 26% | ~65 | ~32,000 | ~65,000 | ~162,000 |
| Stage 6 | 0.5% | 0.17% | 31% | ~63 | ~31,000 | ~63,000 | ~157,000 |
| Stage 7 | 0.65% | 0.22% | 39% | ~60 | ~30,000 | ~60,000 | ~149,000 |
| Stage 8 | 0.8% | 0.27% | 45% | ~57 | ~28,000 | ~57,000 | ~141,000 |
| Stage 9 | 1.0% | 0.33% | 53% | ~53 | ~26,000 | ~53,000 | ~132,000 |
| Stage 10 | 1.15% | 0.38% | 58% | ~50 | ~25,000 | ~50,000 | ~126,000 |
| Rebirth 1 | 1.3% | 0.43% | 63% | ~48 | ~24,000 | ~48,000 | ~120,000 |
| Rebirth 2 | 1.4% | 0.47% | 65% | ~47 | ~23,000 | ~47,000 | ~117,000 |
| Rebirth 3+ | **1.5% (cap)** | **0.5%** | 68% | ~45 | ~23,000 | ~45,000 | ~113,000 |

- "Chance of a dev before pity" = the chance you get one by luck in your first 74 opens. Otherwise pity gives one on open 75. **Worst case per dev: 75 opens** (37,500 R$ at 500, 75,000 R$ at 1,000, 187,500 Gems).
- Averages are per dev. Collecting all three takes about 3× as many opens. Pity resets after each dev.
- Every open also rolls the Legendary/Mythic-heavy pool, so an open without a dev still pays out.
- **Tuning knobs:** the pity count (75) has the biggest effect on cost, more than the chance table. Lower it to make devs cheaper, and keep the progress curve so progress still feels rewarding.

### Odds display
- The crate screen shows **your current total dev chance, the chance for each dev, your Dev Pity progress ("Dev guaranteed in 32 opens") and the full rarity odds** on the screen itself, before any purchase button. The full progress table is one tap away. Owned devs show "Owned → Mythic" next to their share.
- The Robux button reads "Open for 500 R$" and only then opens the native Roblox prompt. Gem and Robux opens use the **identical** roll function ([[Case Library]] rule: Robux versions never have different odds).
- Same info in the Odds panel ([[Screen - Settings & Odds]]).

### Roblox policy (paid random item)
- A Robux-priced crate is a **paid random item**. Check `PolicyService:GetPolicyInfoForPlayerAsync(player).ArePaidRandomItemsRestricted`. For restricted players, **hide the Robux button** (Gem opens may also need hiding, since Gems are sold for Robux). Verify current Roblox rules before launch ([[Case Unboxing]] → Policy note).
- `ProcessReceipt` must be idempotent: store the `PurchaseId` and the roll result **before** returning `PurchaseGranted` ([[Security & Anti-Exploit]] → Purchases). A crash replays the same result, never a reroll.

---

## Milestones (CCU)
CCU = concurrent players across **all** servers.
| Milestone | What happens | How |
|---|---|---|
| **150 CCU** (peak) | Dev Crate Robux price **500 → 1,000 R$** per open (Gem price and odds don't change) | Admin alert. Edit the developer product price in Creator Dashboard (the in-game button reads the live price with `GetProductInfo`) |
| **200 CCU** (peak) | Dev specialty boost **30% → 40%** for every dev and every owner | Automatic: global flag flips, every server recalculates dev stats |

- Milestones use **peak** CCU and are **permanent** once hit.
- 40% is a placeholder; change it in config without a code change.
- Owners get a popup when the 200 CCU boost lands ("Dev update shipped! Your devs are now 40% better in their specialties").
- Per the [[Monetization]] player-safety rule, **don't advertise a coming price rise as "buy before it goes up".**

### Tracking CCU
- Every server writes its player count to a `MemoryStoreSortedMap` ("ServerCounts", key = JobId, 90 s expiry) every 30 s.
- A server holding the leader lock sums the counts every minute. If the sum beats the stored peak, it writes `PeakCCU` to a DataStore.
- When a milestone is crossed, it sets `Milestones[150/200] = { HitAt }` in DataStore and broadcasts on MessagingService. Servers read the flags on start too.
- The [[Admin Panel]] shows live CCU, peak CCU and milestone status. `MilestoneService` in [[Services & Remotes]].

---

## Voice lines
- **3zzy has the most lines of anyone (86).** The validation script fails if `count(3zzy) <= max(count(any other player)) + 20`. The other devs have 30 lines and pros 12–14, all well below.
- Philip's and appropriateuser's full packs: [[Pro Voice Lines]] → Dev packs. System rules: [[Player Voice Lines]].
- Dev lines can be recorded by the devs themselves (with their OK) and go through Roblox audio moderation.

### 3zzy's pack (86 lines)
| Category | Lines | Examples |
|---|---|---|
| Signing / walk-on intro | 5 | "Took you long enough. Let's get to work." |
| Match start (per game title) | 12 (2 × 6) | Aim Arena: "Plant it or don't. I'm winning either way." |
| Big plays | 10 | "Too easy." · "Clip that." |
| Clutch / ace / comeback | 10 | "One versus four? Fair… for them." |
| Win | 6 | "GG. Same time tomorrow?" |
| Loss / tilt (light, never mean) | 6 | "Nah, that one's on the lag." |
| Rival trash talk | 8 | Ties into [[Rivalries & Storylines]] |
| Teammate hype | 5 | "Nice! Almost as good as me." |
| HQ idle / training | 8 | "I made this game. Still can't beat me." |
| Case pulls (your Mythic/Legendary pulls) | 4 | "Okay, I see you." |
| Monthly seasons (one per month) | 12 | October: "Boo. Did I scare you? No? Your aim did." ([[Monthly Seasons]]) |
| **Total** | **86** | |
- Plus **20 caster lines about devs** in [[Caster & Commentary]] ("It's 3zzy! Of course it's 3zzy!" · "Philip just patched the whole strategy!" · "appropriateuser apologizes… and takes the round!").
- Setting: **Dev voices: All / Big moments only / Off**.

---

## Server / data requirements
```lua
-- Shared/Config/DevPlayers.lua
DevPlayers = {
  Boost = { Base = 1.30, AfterMilestone200 = 1.40 },
  SpecialtyFloor = 50, HardCap = 130,
  Devs = {
    { CardId = "DEV_3ZZY",            Tag = "3zzy",            Role = "Sniper",     Specialty = { "Aim", "Clutch" },         Trait = "MainCharacter" },
    { CardId = "DEV_PHILIP",          Tag = "Philip",          Role = "Strategist", Specialty = { "GameSense", "Teamwork" }, Trait = "PatchNotes" },
    { CardId = "DEV_APPROPRIATEUSER", Tag = "appropriateuser", Role = "Entry",      Specialty = { "Aim", "Reflexes" },       Trait = "Hotfix" },
  },
  Crate = { Id = "DevCrate", PriceGems = 2500, DevProductId = 0000000, UnlockStage = 3,
    ChanceByProgress = { [3]=0.002, [4]=0.003, [5]=0.004, [6]=0.005, [7]=0.0065,
                         [8]=0.008, [9]=0.01, [10]=0.0115, R1=0.013, R2=0.014, R3=0.015 },
    MaxChance = 0.015,
    EqualDevShare = true,        -- each dev = total / #Devs; owned dev's share → Mythic
    DevPity = 75,                -- guaranteed dev (unowned, even pick) on this open; resets on any dev
  },
}
-- Profile: Devs = { [CardId] = { Source = "Crate" | "Admin", ObtainedAt } }, DevPityCount = 0
```
- `RosterService:ComputeDevStats(profile, devDef)` runs on every roster change and on the milestone flag. The match sim and UI read the derived stats.
- `CaseService:RollDevCrate(player)` is the one roll function for both Gem and Robux opens. It reads progress → total chance, splits it equally per dev, maps an owned dev's share to Mythic, and forces a dev when `DevPityCount` reaches 75. The pity counter is saved together with the roll result (same `PurchaseId` record for Robux opens).

## Dependencies
[[Monetization]] · [[Microtransaction Ideas]] · [[Case Library]] · [[Case Unboxing]] · [[Match Simulation]] · [[Balance Tables]] · [[Trait Library]] · [[Pro Voice Lines]] · [[Player Voice Lines]] · [[Caster & Commentary]] · [[Admin Panel]] · [[Franchise Rebirth]] · [[Social & Multiplayer]] · [[Security & Anti-Exploit]]

## Edge cases / exploit risks
- **Trading in a stat monster to pump a dev:** devs scale off cards you *own*, and only while you own them. That's fair.
- **Roster of one** (only the Founder): pool max = pool average = the Founder's stats; specialties use the higher of ×1.3 or the floor (50).
- **Robux open interrupted** (disconnect, crash): the roll is stored with the `PurchaseId` before granting, so the player gets exactly that result on next join.
- **Admin grants:** Owner only, logged ([[Admin Panel]]).

## Acceptance criteria
- [ ] Each dev's specialty stats equal round(max of that stat among non-dev roster cards × boost), between 50 and 130
- [ ] Each dev's normal stats equal the non-dev roster average, and all update on roster change
- [ ] Only Dev ✦ cards can show stats above 99
- [ ] Every dev has exactly the same pull chance at every progress level, and the total never exceeds 1.5%
- [ ] An owned dev's share always rolls a Mythic (no duplicates)
- [ ] The 75th open without a dev always gives an unowned dev; the counter resets on any dev and survives rebirth
- [ ] Robux and Gem opens use the same roll function and show the same odds before purchase
- [ ] Robux button hidden where paid random items are restricted
- [ ] A crashed Robux open never rerolls or double-grants
- [ ] 200 CCU milestone switches every dev to ×1.4 on every server without a restart
- [ ] 3zzy has more voice lines than any other player (validation script)

## Open questions
- **Pity count:** 75 is a starting value; tune it after watching real open data.
- **Competitive modes:** devs play at full power in Worlds Live, ladders and the global showcase. Keep that, or cap them in ranked later?
- More CCU milestones later (e.g. 500 CCU → new dev outfits)?

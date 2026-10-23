---
tags: [system, reference]
updated: 2026-10-20
---
# Skill Levels & Ratings

How skill is measured and shown in-game, plus the real-world systems each idea borrows from. Player examples live in [[Pro Player References]].

## Real-world reference systems
Values are from memory as of 2026. Verify current numbers before quoting them anywhere.

| System | Game | How it works | What we borrow |
|---|---|---|---|
| **FACEIT Levels** | CS2 (3rd-party platform) | Levels 1–10 from an Elo number; Level 10 ≈ 2000+ Elo; top players also get a leaderboard rank | Simple 1–10 "level" badge for player skill |
| **CS Rating (Premier)** | CS2 | Number (e.g. 15,000) with color bands: grey < 5k, light blue 5k+, blue 10k+, purple 15k+, pink 20k+, red 25k+, gold 30k+ | Color bands on a big number |
| **HLTV Rating** (2.x / 3.0) | CS pro scene | Per-match performance score, 1.00 ≈ average pro, 1.10+ good, 1.20+ star, 1.30+ elite over a year | Per-match **Match Rating** |
| **Valorant ranks** | Valorant | Iron → Bronze → Silver → Gold → Platinum → Diamond → Ascendant → Immortal → Radiant; 3 sub-tiers each except Radiant | Named ladder tiers with sub-divisions |
| **LoL ranks** | League of Legends | Iron → … → Emerald → Diamond → Master → Grandmaster → Challenger; LP points | Apex tiers limited by leaderboard position |
| **EA FC / FIFA cards** | Football | OVR 1–99, card color bronze < 65, silver 65–74, gold 75+, special cards above | OVR number + card frame by rarity |
| **Football Manager** | Football | Attributes 1–20, current ability vs hidden potential, star ratings from scouts | Hidden **Potential** shown as a star range |
| **Elo / Glicko** | Chess, many games | Rating moves by expected vs actual result | Team ladder rating math |

## Our system (4 layers)

### 1. Stat level (per stat, 1–100)
| Range | Label | Real-world feel |
|---|---|---|
| 1–29 | Casual | Plays for fun |
| 30–44 | Grinder | FACEIT 1–3 |
| 45–59 | Ranked Regular | FACEIT 4–6 |
| 60–69 | High Ranked | FACEIT 7–8 |
| 70–79 | Semi-Pro | FACEIT 9–10, tier-3 pro |
| 80–89 | Pro | Tier-1 / tier-2 pro |
| 90–96 | Star | Top-20 player of the year level |
| 97–100 | Generational | donk / s1mple / Faker tier |
Label shows on the stat bar tooltip.

### 2. OVR + Player Level badge
- OVR = role-weighted average of stats ([[Balance Tables]]).
- **Player Level 1–10** badge (FACEIT-style) shown on every card corner:
| Level | OVR | Badge color |
|---|---|---|
| 1 | < 30 | Grey |
| 2 | 30–37 | Grey |
| 3 | 38–44 | Green |
| 4 | 45–51 | Green |
| 5 | 52–58 | Yellow |
| 6 | 59–65 | Yellow |
| 7 | 66–72 | Orange |
| 8 | 73–80 | Orange |
| 9 | 81–88 | Red |
| 10 | 89+ | Red + glow |
- Rarity (card frame) = how special the card is. Level = how good the player is **right now**. A Common can train up to Level 7–8 if Potential allows.

### 3. Potential (hidden, FM-style)
- Shown as a star range (★★★☆☆–★★★★☆) until scouted.
- Scout staff and training reveal it: exact Potential once revealed.
- Stats cannot exceed Potential. Gear from [[Accessories]] can (up to +12 per stat), but only as a separate bonus.

### Base stats vs gear
- **OVR and the Level 1–10 badge use base stats only.** They always show pure skill and don't move when gear changes.
- Cards show the gear bonus separately (`Aim 74 +11.5`) and a small "Gear OVR" under the main OVR.
- In Pure-mode matches (Ranked), the gear part is greyed out.

### 4. Match Rating (HLTV-style, per match)
```
MatchRating = 0.35 × (kills / avgKills)
            + 0.20 × (survivalRate / avgSurvival)
            + 0.20 × (roundImpact / avgImpact)     -- opening kills, clutches, multi-kills
            + 0.15 × (damage / avgDamage)
            + 0.10 × (assists / avgAssists)
```
Normalized so 1.00 = average for that division.
| Rating | Label |
|---|---|
| < 0.85 | Rough game |
| 0.85–0.99 | Below average |
| 1.00–1.09 | Solid |
| 1.10–1.19 | Good |
| 1.20–1.34 | Star game |
| 1.35+ | MVP performance (gold glow) |
- Shown on post-match results ([[Screen - Match HUD]]) and as a 10-match rolling average on the Roster card.
- Season average decides the end-of-season **Top 20 Players** list (HLTV top 20 homage), a trophy and achievement for each of your players who make it.

## Team ladder (Ranked Ladder)
Team rating uses Elo (`K = 32`, start 1000). Tiers:
| Tier | Rating | Sub-tiers |
|---|---|---|
| Garage | < 1000 | III / II / I |
| Bronze | 1000–1199 | III / II / I |
| Silver | 1200–1399 | III / II / I |
| Gold | 1400–1599 | III / II / I |
| Platinum | 1600–1799 | III / II / I |
| Diamond | 1800–1999 | III / II / I |
| Elite | 2000–2199 | III / II / I |
| Champion | 2200+ | — |
| **Legend** | Top 100 global | Leaderboard only (LoL Challenger / Valorant Radiant style) |
- Season reset: rating pulled 50% toward 1200.
- Tier-up gives a crate and a badge frame for the HQ banner.

## Server / data requirements
- `PlayerCard.Level` derived from OVR (not stored). `PlayerCard.RatingHistory = {last 10}`.
- `Profile.Ladder = { Rating, Peak, SeasonWins, SeasonLosses }`.
- Match Rating computed in [[Match Simulation]] output per player.

## Acceptance criteria
- [ ] Every player card shows OVR, rarity frame and Level 1–10 badge
- [ ] Post-match shows Match Rating per player with label
- [ ] Ladder tier and sub-tier update after each ranked match

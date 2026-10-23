---
tags: [feature]
status: idea
priority: P0
stage: 3
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Match Simulation]]"
  - "[[Skill Levels & Ratings]]"
  - "[[Data Schema]]"
  - "[[Services & Remotes]]"
affected_ui:
  - "[[Screen - Bracket]]"
  - "[[Screen - Match HUD]]"
roblox_execution_environment: ServerScriptService
---
# Matches & Tournaments

## Match types
- **Scrim** – practice, low reward, safe (no rank loss). Full gear by default, "Pure skill" toggle
- **Ranked Ladder** – rating-based. **Always Pure:** only player power counts, no accessories, stickers, station parts, staff or home field
- **Local Cup / Regional / National / International / Worlds** – bracket tournaments, full gear. **Take real time** between rounds (see *Tournament timing*)
- **Friend Scrim** – vs another player's team (see [[Social & Multiplayer]]). Full gear by default; challenger can pick Pure

## Resolution (server)
`TeamPower = Σ((stat + gear) × role weight × station bonus) × chemistry × morale × coach`. Full formula and Gear Mode: [[Match Simulation]], [[Accessories]].
Win probability from power difference + randomness (upsets possible). Server decides; client plays the cinematic.

## Tournament timing
Tournaments **take real time**. You register, then rounds are played on a schedule with waits in between. It makes a tournament feel like an event you follow, gives the HQ loop (training, cases, clips) a purpose between rounds, and creates a natural "come back later" moment. Scrims and Ranked stay instant.

### Durations (starting values, tune in playtests)
| Tournament | Stage | Format | Registration | Wait between your matches | Total (no skips) |
|---|---|---|---|---|---|
| **Local Cup** | 3 | 8 teams, single elim (3 rounds) | 2 min | 5 min | ~15 min |
| **Regional Qualifier** | 4 | 16 teams, single elim (4 rounds) | 5 min | 10 min | ~45 min |
| **Pro League season** | 6 | 8-team round robin (7 matches) + top-4 playoff | — (auto entry) | 20 min | ~3.5 h |
| **Regional tournament** | 6 | 16 teams, groups of 4 → 8-team bracket | 10 min | 15 min | ~1.5 h |
| **National Finals** | 7 | 32 teams, groups → bracket, final Bo3 | 15 min | 20 min | ~3 h |
| **International Qualifier** | 8 | 32 teams, double elim | 15 min | 30 min | ~5 h |
| **Worlds** | 9–10 | Group stage (day 1) → playoffs (day 2), final Bo5 | 30 min | 45 min | ~8 h over 2 sessions |
- Early tournaments are short so the first trophy still lands inside Stage 3's 45 min–2 h window ([[Progression Guide]]). Waits grow with stage, like prices do.
- **One tournament at a time** per team. Scrims, training and Ranked stay available while you wait. Fatigue from scrims **carries into** your next tournament match, so grinding between rounds is a real choice.
- [[Admin Abuse Events]] → *Tournament Blitz* is the one bracket with no waits.

### How a round works
1. **Register** (Compete hub, or the Tournament Hall). Server fixes the bracket, AI opponents and a **tournament seed**.
2. Each of your matches has a **lock time**. Until it locks you can change lineup, tactic and gear. At lock, your lineup is snapshotted.
3. At the match time the match resolves with the seed + snapshot. If you're online you get the **Next match** button ([[Screen - Main HUD]] → contextual buttons) and watch the cinematic (or skip it). Other bracket matches resolve at the same time.
4. Between rounds: [[Screen - Bracket]] shows "Next match in 12:40 · ⏩ Skip" and the opponent's preview.
5. Lose → you're out (or drop to lower bracket in double elim). Win the final → trophy cinematic.

### Offline
- Tournaments keep going while you're offline. Your matches play with your lineup **as of lock time** (your last saved roster if you were offline at lock).
- **Lazy resolution:** nothing runs while no server has your profile. When you join (or when a round's time passes while you're online), the server resolves every round whose time has passed, in order, using the stored seed. Same seed + same snapshot = same result, whenever it's computed.
- On join you get a recap: "While you were away: won QF 13–9, lost SF 11–13 · 3rd place, $X". Rewards are paid then.

### Skipping waits
[[Time Skip Tickets]] (or Gems) skip the registration window or the wait before your next match. Skipping moves the lock to **now**, so the round resolves immediately with your current lineup and the same seed. It saves time; it can't reroll a result.

### Data
```lua
Profile.Tournament = nil | {
  Id, DefId, Seed, RegisteredAt, Bracket = {...},     -- AI teams generated from Seed
  Rounds = { { LocksAt, PlaysAt, Opponent, Snapshot = nil|{...}, Result = nil|{...} }, ... },
  Status = "Registering" | "Running" | "Eliminated" | "Won" | "Done",
}
```
- `MatchService:ResolveDueRounds(profile, now)` runs on join and on a 10 s tick for online players.
- `Shared/Config/Tournaments.lua`: format, team count, registration length, wait per round, prizes per tournament.

## Seasons
12 weeks (real days compressed, e.g. a season = 7 real days). Division promotion/relegation. Season end → rewards + new Event Crate.

## Rewards
Cash prize pool, Fame, trophies on display shelf, cases for top placement, sponsor bonuses.

Links: [[Playable Games]] · [[Sponsors]] · [[Progression Guide]] · UI: [[Screen - Bracket]]

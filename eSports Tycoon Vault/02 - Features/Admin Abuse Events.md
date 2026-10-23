---
tags: [feature, live-ops]
status: designed
priority: P1
stage: 2
updated: 2026-10-21
system_type: Infrastructure
engine_layer: ServerService
dependencies:
  - "[[Admin Panel]]"
  - "[[Live Ops & Events]]"
  - "[[Monetization]]"
  - "[[Economy Design]]"
  - "[[Dev Players]]"
affected_ui:
  - "[[Screen - Admin Panel]]"
  - "[[Screen - Main HUD]]"
roblox_execution_environment: ServerScriptService
---
# Admin Abuse Events

## Summary
> **Decided 2026-10-22:** the in-game name is **Admin Abuse** (the known Roblox term, good for discoverability). The Saturday 17:00 UTC slot and tournament timings stay as written until playtests.

Short, loud, server-wide chaos where the devs "abuse" their powers for everyone's benefit: cash raining from the sky, crates dropping in the plaza, luck surges, instant training, free Time Skip Tickets. The classic Roblox "admin abuse" hour, built for an esports tycoon.

Events run two ways:
- **Automatically on a schedule** (weekly Admin Abuse Hour + small surprise events), with no dev online.
- **Manually** from the [[Admin Panel]] → Live Ops → *Abuse Events*, on this server or **all servers**.

Every event is **free for players**, has a fixed length, and never sells anything. The point is hype, CCU spikes and "be online Saturday" habits, not revenue.

---

## Event library
Each event has a default length, an intensity (1–3), and caps so it can't break the economy. Rewards are **scaled to each player's progress** (minutes of their own income, cases for their stage), so a Stage 9 team and a Stage 2 team both get something that feels big.
| Event | What happens | Default length | Reward / effect (intensity 1 → 3) | Per-player cap |
|---|---|---|---|---|
| **Cash Rain** | Bills fall over every plot and the plaza; walk into them to collect | 3 min | Each bill = 10 s of your income/s; 1× → 3× spawn rate | 15 min of your income |
| **Crate Drop** | Glowing crates parachute into the plaza and districts; first to touch one opens it (everyone nearby gets one too) | 5 min | Stage-appropriate crate (Rookie → Legend Crate tier for your stage) | 3 crates |
| **Luck Surge** | All case opens use boosted Legendary/Mythic odds; the Odds panel switches to the boosted table live | 10 min | Legendary ×1.5 / ×2 / ×3, Mythic ×1.5 / ×2 / ×2 | — |
| **Golden Hour** | Every match pays more (scrims, tournaments, ranked) | 15 min | Cash + Fame ×2 / ×3 / ×5 | — |
| **Training Frenzy** | All training timers run 10× fast; new training is instant | 10 min | — | — |
| **Time Warp** | Everyone gets a free Time Skip Ticket ([[Time Skip Tickets]]) | instant | 15 min / 1 h / 4 h ticket | 1 per event |
| **Sticker Storm** | Sticker capsules float around the plaza like balloons; pop to collect | 5 min | Starter → Neon Nights capsules; higher intensity = better finish odds | 5 capsules |
| **Hype Storm** | Clip views ×5, every clip posted trends, followers tick faster | 15 min | Clip views ×3 / ×5 / ×10 | — |
| **Pro Visit** | A named star from [[Pro Player References]] walks the plaza signing autographs | 10 min | Their signature sticker ([[Sticker System]]) to everyone who talks to them | 1 |
| **Dev Drop-In** | One of the [[Dev Players]] (3zzy, Philip, appropriateuser) appears as a giant NPC on the plaza jumbotron, challenges the server to a show match | 10 min | Everyone who beats the dev team in a one-off scrim gets Gems (25 / 50 / 100) | 1 win |
| **Tournament Blitz** | A Local-Cup-style bracket that runs with **no waits** (normal tournaments take time, see [[Matches & Tournaments]] → *Tournament timing*) | 10 min | Blitz trophy + stage prize ×1 / ×1.5 / ×2 | 1 entry |
| **Mythic Raffle** | Free raffle; every online player is entered automatically. Winners drawn live on the jumbotron | 5 min draw | 1 / 2 / 3 Mythic-tier crates per server | 1 win |
| **Party Mode** *(cosmetic)* | Disco lighting, confetti cannons, low gravity in the plaza, avatars grow 1.5× | 5 min | — | — |
| **Weather Chaos** *(cosmetic)* | Snow in summer, neon rain, a meteor shower over the plaza | 5 min | — | — |

Cosmetic events cost nothing in economy terms and can be thrown in freely to pad a playlist.

## Automatic schedule
Configured in `Shared/Config/AbuseSchedule.lua`. The server reads it by UTC time, so events start with no dev online and no restart.
| Slot | When | What |
|---|---|---|
| **Admin Abuse Hour** | Weekly, **Saturday 17:00 UTC**, 60 min, right before Worlds Live at 18:00 ([[Live Ops & Events]]) | Playlist of 6–8 events, intensity 2. Always ends with **Mythic Raffle** then a 5-min **Party Mode** that hands over to Worlds Live |
| **Surprise events** | Every **3 h ± 30 min** (random per server) | 1 random event from the "mini" pool (Cash Rain, Crate Drop, Sticker Storm, Time Warp, Party Mode, Weather Chaos), intensity 1 |
| **Milestone party** | When game-wide CCU hits a milestone ([[Admin Panel]] → Milestones) | 15-min playlist, intensity 3, all servers |
| **Update launch** | First 2 h after a big update (manual flag in config) | Golden Hour + Luck Surge back to back |

- **Countdown:** scheduled events show a plaza jumbotron countdown and a HUD toast **15 min** and **1 min** before. This is a countdown to free stuff, not a purchase timer, so it doesn't break [[Monetization]] principle 3.
- Global events (Abuse Hour, milestone party) are **synced across servers**: the start time comes from the config, so every server starts on the same second without messaging.
- Surprise events are **per server** and use a seeded random per JobId, so each server's timing is different.

## Manual control (Admin Panel)
Live Ops → **Abuse Events** card ([[Screen - Admin Panel]]):
- Pick an event (or a saved **playlist**), intensity 1–3, length, scope (**This server / All servers**), start **Now** or **at a time**.
- **Stop** any running event (on one server or all).
- **Queue view:** what's running, what's scheduled next (auto + manual), with the source ("Auto: Abuse Hour", "Manual: @3zzy").
- Also available from the Announcement Terminal (`/abuse start cashrain 2 all`, see [[Admin Panel]] → *13. Announcement Terminal*).
| Action | Role |
|---|---|
| Start/stop events on **this server**, intensity 1–2 | Admin |
| **All servers**, or intensity 3 | Admin + **two-person approval**, or Owner alone |
| **Mythic Raffle**, **Luck Surge** at intensity 3 | Owner, or Admin + approval |
| Edit the automatic schedule | Owner (config change, shipped with an update) |
| Moderators | Can't start events |

- **Cooldown:** the same economy event (Cash Rain, Crate Drop, Luck Surge, Golden Hour, Mythic Raffle) can't run on the same server more than **once per 2 h**, auto and manual combined. Cosmetic events have no cooldown.
- When a dev starts an event manually, their avatar gets a **crown + "ADMIN" nameplate** for the event's length and the announcement says who started it ("@3zzy started CASH RAIN!").

## Rules
- **Free only.** No event discounts Robux items, sells anything, or shows a purchase prompt. No "buy now during Luck Surge" messages.
- **Odds stay honest.** Luck Surge changes odds on **every** case, including Gem and Robux ones, and the Odds panel ([[Screen - Settings & Odds]]) shows the boosted table while it runs. Pity counters keep counting normally.
- **Scaled rewards, hard caps.** Cash is always measured in *your* income, so events can't inflate the economy for low-stage players or be meaningless for high-stage ones.
- **Event items** carry `Source = "Event"` + `EventRunId`. They're tradeable like normal drops (unlike admin grants), because everyone online had the same chance.
- **No AFK farming:** physical pickups (Cash Rain bills, crates, capsules) need your avatar to touch them. Players flagged AFK (no input for 15 min) aren't entered in the Mythic Raffle.
- **Ranked is untouched.** Golden Hour boosts rewards only; it never changes match power, so Ranked stays pure ([[Accessories]] → *Gear Mode*).
- **Dev accounts** can't collect event rewards on live (same rule as no self-grants).

## Player-facing UI
- **Top banner** while an event runs: event icon, name, time left, who started it (Auto / @dev). Stacks to 1 line on mobile.
- **Plaza jumbotron** shows the event and the countdown to the next scheduled one.
- **HUD:** the contextual **Event** button ([[Screen - Main HUD]]) opens an "Abuse Events" card: now running, next scheduled, what you've collected this event.
- **Settings:** "Reduce event effects" (fewer falling particles; pickups still work) for low-end phones.

## Server / data requirements
```lua
-- Shared/Config/AbuseEvents.lua
AbuseEvents = {
  CashRain = { Length = 180, Kind = "Economy", Pool = {"Mini","Hour"}, Intensity = { {Rate=1}, {Rate=2}, {Rate=3} }, CapIncomeSeconds = 900 },
  LuckSurge = { Length = 600, Kind = "Economy", Pool = {"Hour"}, Intensity = { {Leg=1.5,My=1.5}, {Leg=2,My=2}, {Leg=3,My=2} } },
  PartyMode = { Length = 300, Kind = "Cosmetic", Pool = {"Mini","Hour"} },
  -- ...
}
-- Shared/Config/AbuseSchedule.lua
AbuseSchedule = {
  { Id = "AbuseHour", Weekly = { Day = "Sat", HourUTC = 17 }, Length = 3600, Playlist = "HourDefault", Scope = "Global", Intensity = 2 },
  { Id = "Surprise", EverySeconds = 10800, JitterSeconds = 1800, Pool = "Mini", Scope = "Server", Intensity = 1 },
}
```
- **`AbuseEventService`** (new): reads the schedule, runs events, enforces caps and cooldowns, pays rewards through `EconomyService` / `CaseService`. Exposes `Start(eventId, intensity, length, scope, startedBy)` and `Stop(runId)` to `AdminService`.
- **Global state:** active global runs are written to a MemoryStore hash `AbuseRuns` (`RunId → {EventId, Intensity, StartsAt, EndsAt, StartedBy}`), so a server that starts mid-event joins in. Manual all-server starts also ping servers via `MessagingService` topic `AbuseEvent` for an instant start.
- **Per-player progress** (collected so far, caps) is held in server memory per run, not saved. Rewards themselves are saved normally the moment they're collected.
- **Audit:** every manual start/stop writes an `AdminAudit` record (`Type = "AbuseEventStart" | "AbuseEventStop"`). Auto runs are logged to analytics (`abuse_event_run`) with participation counts.
- Remotes: `Admin/LiveOps` gains `AbuseStart`, `AbuseStop`, `AbuseQueue`. Players get `AbuseEvent/State` (S→C: running event, time left, collected) and pickups are server-touched parts (no client remote for collecting).

## Edge cases / exploit risks
- **Teleport/speed exploiters hoovering pickups:** pickups validate distance from the server-side character position and a max collect rate; the per-player cap limits the damage anyway.
- **Event overlaps:** max 2 economy events at once per server; extra manual starts queue behind them.
- **Server shutdown mid-event:** collected rewards are already saved; the run ends. Global runs continue on other servers.
- **Luck Surge during a case-opening animation:** the roll happens at the moment the server receives `Case/Open`; the odds used are written into the roll record.
- **Player joins in the last 30 s:** still gets Time Warp / Pro Visit style one-time rewards if they act before the end.

## Acceptance criteria
- [ ] Admin Abuse Hour starts on every server at Saturday 17:00 UTC with no dev online and runs its playlist
- [ ] Surprise events fire roughly every 3 h per server, at different times on different servers
- [ ] An Admin can start any event on their server from the panel; all-server or intensity 3 asks for approval
- [ ] Cash Rain pays in each player's own income and stops at the cap
- [ ] During Luck Surge the Odds panel shows the boosted odds, and pity still counts
- [ ] No event ever shows a purchase prompt or discounts a Robux item
- [ ] Every manual start/stop is in the audit log

## Open questions
- Should top Worlds Live teams get a bonus raffle ticket during the Abuse Hour?

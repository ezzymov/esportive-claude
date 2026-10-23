---
tags: [feature]
status: idea
priority: P2
stage: 4
system_type: Infrastructure
engine_layer: ServerService
dependencies:
  - "[[Services & Remotes]]"
  - "[[Security & Anti-Exploit]]"
  - "[[Data Schema]]"
affected_ui: []
roblox_execution_environment: ServerScriptService
---
# Social & Multiplayer

## Summary
Roblox is social first. Players should see other teams, visit them, play them, and brag. Every social touchpoint also feeds the economy a little (visits give Fame, friend scrims give XP).

## Features
### HQ visits
- Teleport to any player's plot in the server (or a friend's via `TeleportService` reserved lookup later).
- Visitors can **Like** the HQ (1 per visitor per day): +Fame to owner, small Cash to visitor.
- Visitors see trophies, jersey, top clip in Replay Theater, roster on stations.

### Friend scrims (async PvP)
- Challenge any team in the server. Server simulates using both saved rosters. Both players watch the same cinematic.
- No rank loss. Winner gets bonus XP and Fame; loser gets 50% XP.
- If target is offline: play vs their **snapshot** (saved roster). They get a notification on next join.
- **Gear Mode:** the challenge card has a **Full / Pure** toggle (Full by default). Full = accessories, stickers and station parts count; Pure = only player power, for both sides, including snapshots. The mode is shown on the challenge and the match intro. Snapshots include equipped accessories. See [[Accessories]] → *Gear Mode*.

### Leaderboards
| Board | Scope | Reset |
|---|---|---|
| Fame | Global / friends / server | Never (all-time) + seasonal |
| Followers | Global / friends | Never |
| Trophies | Global | Never |
| Season Rank | Global | Every season |
| Clip of the Week | Global | Weekly |
- Global boards use `OrderedDataStore`, refreshed every 60 s, top 100.
- In-world physical leaderboard in the spawn plaza (top 10 with team logo).

### Global Top Teams showcase (game-wide)
The best teams are **the same on every server**. Any player in any server sees the same top teams, not just the best team in their own lobby.
- **Where it shows:**
  - Plaza leaderboard wall (top 10, with team logo, name, owner avatar and OVR)
  - A rotating **Top Team spotlight** on the jumbotron (roster lineup + trophy shelf)
  - The leaderboard panel (top 100 + your own rank)
  - The [[Monthly Seasons]] Season Hub (current season standings + last season's champions)
- **Ranked by:** Fame (all-time) and Season Rank (current season) as separate boards. Worlds Live and Season Major champions get a badge on their entry.
- **Inspect:** clicking a showcased team opens a read-only view of its roster snapshot (players, rarity, OVR, loadout). This view can't be traded from.
- **One source of truth:** scores live in `OrderedDataStore`. A single top-list is cached in `MemoryStoreService` (refreshed every 60 s), and every server reads from it, so all servers show the same order at the same time.
- **Dev exclusion (later phase):** game developers and staff are left out of the showcase and the global top lists, so the top spots always go to real players.
  - The filter checks `Config/Showcase.lua → ExcludedUserIds` plus a role check in the studio's Roblox group (e.g. rank ≥ "Developer").
  - Excluded accounts still have a profile and can see their own rank privately, marked "Dev, not ranked".
  - The filter is applied when the top list is built, so it works for every server at once.
  - Test accounts and alts used for QA go on the same list.
  - The list is managed in the [[Admin Panel]] (Live Ops → Showcase). Admin-granted items don't count toward leaderboard scores.

### Trading
Full design in [[Trading System]]; market side in [[Transfer Market]]. Direct trades between two players in the same server: both sides add players/parts/cosmetics, both confirm twice, 10% Cash tax on value.

### Shared server events
- **Worlds Live** (see [[Live Ops & Events]]): all players' best teams enter one bracket, broadcast on the plaza jumbotron.
- Server-wide boosts: when someone opens a Mythic, everyone gets a 5-min 1.2× income boost ("Mythic Hype").

### Guild-lite: Alliances (P3)
Up to 5 teams form an Alliance. Shared alliance banner, weekly alliance goal, alliance leaderboard.

## Safety
- All typed text filtered (`TextService`). Trade chat uses preset emotes/phrases only.
- Block/mute respected for visits and challenges.
- Trading requires both accounts ≥ 3 days old and ≥ Stage 4 (anti-alt farming).

## Server / data requirements
- Snapshot of roster saved on every roster change (`Profile.Snapshot`).
- MessagingService for cross-server notifications (challenge results).
- `ShowcaseService`: builds the global top list (OrderedDataStore → filter excluded devs → MemoryStore cache), serves it to every server, and stores the roster snapshots of showcased teams.

## UI screens
- Visit list (players in server), challenge dialog, leaderboard panel, trade window.

## Acceptance criteria
- [ ] Two players can friend-scrim and both see the same result
- [ ] Liking a visited HQ increases owner's Fame
- [ ] Global Fame board shows top 100 and own rank
- [ ] Two players on different servers see the same top 10 within 60 s
- [ ] (Later phase) Accounts on the dev exclusion list never appear in the showcase or global top lists

## Open questions
- Real-time PvP tournaments vs snapshot-only? Snapshot-only for launch is safer and simpler.

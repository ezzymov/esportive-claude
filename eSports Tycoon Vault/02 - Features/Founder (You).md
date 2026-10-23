---
tags: [feature]
status: designed
priority: P0
stage: 1
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Player Generator]]"
  - "[[Security & Anti-Exploit]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Team Creator]]"
  - "[[Screen - Roster]]"
roblox_execution_environment: ServerScriptService
---
# Founder (You)

## Summary
**You are the first player on your team.** At the start there is no roster: your own avatar sits at the only PC, plays the first matches, and earns the money to hire your first teammate. Your **Founder card** stays on the team forever, grows with how you play, and shows up in matches and clips with your own avatar and name.

## Founder card
| Field | Value |
|---|---|
| Name | Your Roblox **display name** (nameplate: `[TAG] DisplayName`) |
| Look | Your own avatar, wearing the team jersey and headset |
| Rarity frame | **Founder** (unique gold-and-team-color frame, not a normal rarity) |
| Role | You pick one when you name your team: Entry, Support, Sniper, Strategist or Flex |
| Starting stats | All around 30 (OVR ~30), with +6 in the stat your role likes most |
| Potential | Starts at **70**. +5 per Rebirth (max 95). Founder achievements add +1 each (max +5) |
| Trait | **Player-Owner**: +5% team morale while you're in the active five |
| Salary | None (you're the owner) |

## How your Founder grows
Your Founder doesn't train like other players. It improves from **what you actually do**:
| Your activity | Stat it grows |
|---|---|
| Aim Trainer score | Aim |
| Reaction Test score | Reflexes |
| Strategy Draft wins | Game Sense |
| Rhythm Warm-up streaks | Teamwork |
| Winning Clutch Moments in matches | Clutch |
| Playing on different days (daily streak) | Consistency |
| Matches you play as part of the team | Small XP to all stats |
Minigames: [[Playable Games]]. Founder can also use the Training Center like anyone else once it unlocks.

## Earning money yourself (Stage 1)
Before you can hire anyone, you earn your first cash:
| Way to earn | How | Typical pay |
|---|---|---|
| **Your station** | Sit at your PC: it earns while you're seated (you're "practicing on stream") | $1/s |
| **Pickup Games** | Solo-queue matches: you + 4 random AI teammates ("pugs") vs an AI team. Auto-sim with your Founder in the cutscene | $120–200 per win, $50 per loss |
| **Aim Trainer** | Old arcade cabinet in the garage | $20–80 per run |
| **Tech Fix jobs** | Neighbors bring broken PCs: quick repair minigame (plug cables, swap a part, clean dust) | $100–250 per job, 1 job per 90 s |
| **Garage stream** | After 1st win, your desk shows a tiny viewer count; small passive followers | Followers only |

Once you hire players, **their stations earn even when you're away**, while yours only earns when you sit at it. That's the push to hire: you can't be everywhere.

## Pickup Games (pugs)
- Your Founder + 4 randomly generated players you don't own ([[Player Generator]]), Common rarity, random names and looks.
- Pugs show up with greyed nameplates and "PUG" tags in cutscenes and clips.
- Each hire replaces one pug. At 5 owned players, Pickup Games are replaced by scrims and the ladder.
- Pickup Games stay available later as a quick solo mode ("Solo Queue") for Founder XP.

## Founder later in the game
- You can bench your Founder when better players arrive. Benched Founder becomes **Owner-Coach**: +2% Team Power while not in the active five (stacks with staff Coach).
- Founder **can't be traded, sold or released** ([[Trading System]]).
- Founder keeps loadout slots like any player: your skins show on your own avatar in clips.
- **Rebirth**: Founder is always kept, stats drop to 50% of current, Potential rises +5 ([[Franchise Rebirth]]).
- **Founder clips**: when your Founder makes a Clip Moment, the clip gets a "FOUNDER" badge and +10% views.
- Achievement chain: "Self-Made" (win 10 Pickup Games before your first hire), "Still Got It" (Founder MVP in a Pro League match), "Owner Plays Worlds" (Founder in the active five in a Worlds final).

## Server / data requirements
```lua
PlayerCard = { Uuid, Source = "Founder", UserId = player.UserId, Role, Stats, Potential = 70,
               Trait = "PlayerOwner", Loadouts = {...} }
Profile.FounderUuid = uuid
Profile.Ftue = { IntroDone = false, PickupWins = 0, TechFixJobs = 0, FirstHireAt = nil }
```
- Display name and avatar fetched live (never stored), like [[Friend Signings]].
- Minigame-to-stat XP is server-validated (score caps per second, see [[Security & Anti-Exploit]]).

## UI screens
- Founder card in [[Screen - Roster]] (always first slot, gold frame)
- Founder section in the [[Screen - Team Creator]] (role pick)

## Acceptance criteria
- [ ] New player has exactly one roster member: their Founder with their own avatar and display name
- [ ] Pickup Games show the Founder plus 4 PUG-tagged players
- [ ] Minigame scores raise the matching Founder stats
- [ ] Founder can't be added to trades or released
- [ ] Founder appears in clips with the player's avatar, skins and name

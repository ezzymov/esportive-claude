---
tags: [system, data, persistence]
status: designed
priority: P0
stage: 1
updated: 2026-10-21
system_type: Infrastructure
engine_layer: ServerService
dependencies:
  - "[[Data Schema]]"
  - "[[Services & Remotes]]"
  - "[[Security & Anti-Exploit]]"
affected_ui:
  - "[[Screen - Main HUD]]"
  - "[[Screen - Admin Panel]]"
roblox_execution_environment: ServerScriptService
---
# Data Persistence (Hub)

> **Goal: a player never loses progress.** That includes crashes, leaving mid-action, server shutdowns, and game updates.
> This hub sets the rules. The details are in four child notes:
> - [[Shutdown & Update Handling]]: what happens when a server closes or a new version ships
> - [[Save Versioning & Migrations]]: how old saves load safely in new code
> - [[Backups & Recovery]]: snapshots, save guards, and restoring a player
> - [[DataStore Registry]]: every DataStore and MemoryStore in the game, who owns it, and how it's backed up

## The 8 rules
1. **One owner per save.** `DataService` is the only code that reads or writes the player DataStore. Other services change `profile.Data` through `DataService` helpers. They never call `GetAsync`/`SetAsync`.
2. **Session lock on every profile.** Use **ProfileStore** (loleris). Two servers can never write the same profile at once, so a fast rejoin or teleport can't roll a save back.
3. **Save often, and save right after anything valuable.** ProfileStore autosaves on its own cycle. On top of that, `DataService:SaveNow(player, reason)` runs after the critical events in the table below.
4. **Save on every exit path.** That covers leaving, kicks, teleports, and server shutdown (`BindToClose`). See [[Shutdown & Update Handling]].
5. **Never downgrade a save.** If a profile was written by a newer game version than this server runs, the server **does not save it**. It sends the player to an up-to-date server. See [[Save Versioning & Migrations]].
6. **Never trust a save that looks wiped.** A save guard compares the new data to the last loaded data and blocks impossible drops. See [[Backups & Recovery]].
7. **MemoryStore is a cache.** It can expire or be evicted at any time. Anything that has to survive goes to a DataStore. See [[DataStore Registry]].
8. **Cross-key moves are idempotent.** Trades, market escrow, admin grants, and purchases each carry a unique ID that's recorded before the reward is given, so a crash and retry never gives it twice or loses it.

## Save triggers
| Trigger | How | Why |
|---|---|---|
| Autosave | ProfileStore's built-in cycle | Caps the worst-case loss for passive income |
| Robux purchase (`ProcessReceipt`) | Write `PurchaseId` → `SaveNow` → return `PurchaseGranted` | Robux must never be lost ([[Security & Anti-Exploit]] → *Purchases*) |
| Case open: Legendary or better, or any Dev ✦ | `SaveNow` | Rare pulls are the most painful to lose |
| Trade or market commit | Saved as part of the atomic commit | [[Trading System]], [[Skin Marketplace]] |
| Admin grant claimed | `ClaimedGrants[GrantId] = true` + `SaveNow` | [[Admin Panel]] |
| Stage up / rebirth | `SaveNow` | Big progress jumps |
| Player leaving / teleporting | `profile:EndSession()` | Releases the lock for the next server |
| Server closing | ProfileStore ends all sessions inside `BindToClose` | [[Shutdown & Update Handling]] |

`SaveNow` is rate-limited to **1 per profile every 10 s** (a DataStore key accepts one write about every 6 s). Extra calls inside the window mark the profile dirty, and it saves once when the window ends.

## DataService API (server only)
```lua
DataService:GetProfile(player)          --> profile or nil (nil while still loading)
DataService:WaitForProfile(player, timeout)
DataService:Update(player, path, fn)    -- the only way to change saved data; sends State/Delta
DataService:SaveNow(player, reason)     -- rate-limited forced save
DataService:IsReadOnly(player)          -- true if the profile was written by a newer version
DataService.ProfileLoaded  : Signal(player, profile)
DataService.ProfileReleasing : Signal(player, profile)  -- last chance for services to write
```

## Load flow (on `PlayerAdded`)
1. `ProfileStore:StartSessionAsync("Player_" .. userId, { Cancel = function() return player.Parent ~= Players end })`
2. Got nothing (DataStore is down or the player left) → kick with *"Couldn't load your save. Please rejoin. Your progress is safe."* **Never start a player on a blank profile.** A blank profile could then save over their real data.
3. `profile:AddUserId(userId)` (GDPR), then run the **migrations**, then `profile:Reconcile()` to fill in new template fields.
4. If `Data.Version > CURRENT_VERSION` → read-only mode and send them to a newer server ([[Save Versioning & Migrations]]).
5. Hook `profile.OnSessionEnd` → if the player is still in game, kick with *"Your save was opened on another server."*
6. If the player left during load → `profile:EndSession()` right away.
7. Fire `ProfileLoaded`. Compute offline earnings from `LastSeen` ([[Daily Loops & Quests]]). Send the first full `State/Delta`.

## Player-facing behavior
- Loading screen holds until the profile has loaded. The HUD never shows default values (0 Cash) first, so a slow load never looks like lost data.
- Small **"Saved ✓"** tick next to the Cash counter after each forced save. It reassures players and helps QA.
- Shutdown/update message: *"Updating eSports Tycoon. Your progress is saved. Moving you to a new server…"*

## Edge cases
| Case | Result |
|---|---|
| Player rejoins a new server before the old one released them | ProfileStore waits for the old session, then takes it over. Old server's `OnSessionEnd` kicks the stale copy. |
| DataStore outage at join | Kick with retry message. No blank profile. |
| DataStore outage mid-session | ProfileStore keeps retrying. Data stays in memory. Analytics flags `datastore_error`. |
| Server crash (no `BindToClose`) | Lose at most the time since the last save. Critical events were already force-saved. |
| Profile near the 4 MB value limit | Warn in logs at 1 MB. Cap list fields (clips, trade log, mail). See [[DataStore Registry]] → *Size budget*. |
| Exploit tries to trigger mass saves | Saves are server-only and rate-limited. No remote can force a save. |

## Acceptance criteria
- [ ] Join → earn → leave → rejoin on another server: all values match.
- [ ] Rejoin within 1 s of leaving: no rollback, no duplication.
- [ ] Studio "Shut down all servers" during play: data saved for every player (check with a second join).
- [ ] Load a v1 save after shipping v2: migration runs, nothing lost ([[Save Versioning & Migrations]]).
- [ ] An old-version server never overwrites a newer save.
- [ ] Buy a Developer Product, then force-close the server right away: item delivered exactly once on rejoin.
- [ ] Blocked by the save guard: a test that zeroes `Roster` is refused and logged ([[Backups & Recovery]]).
- [ ] Admin can restore a player to yesterday's version from [[Admin Panel]].

## Open questions
- Use ProfileStore's `Mock` store in Studio by default, with a toggle for live API access?
- Do we need a "Saved ✓" tick for every autosave, or only for forced saves?

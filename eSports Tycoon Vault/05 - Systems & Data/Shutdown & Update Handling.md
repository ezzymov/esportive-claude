---
tags: [system, data, persistence, liveops]
status: building
priority: P0
stage: 1
updated: 2026-10-22
system_type: Infrastructure
engine_layer: ServerService
dependencies:
  - "[[Data Persistence]]"
  - "[[Save Versioning & Migrations]]"
affected_ui:
  - "[[Screen - Main HUD]]"
roblox_execution_environment: ServerScriptService
---
# Shutdown & Update Handling

> How a server closes without losing anything, both when it crashes or empties and when we ship an update. Part of [[Data Persistence]].

## Ways a server ends
| Event | Do we get `BindToClose`? | What we do |
|---|---|---|
| Last player leaves | Yes | Normal flush (below) |
| **Migrate To Latest Update** (Creator Hub) | Yes, servers close gradually | Soft shutdown. **Default way to ship.** |
| Shut Down All Servers | Yes, all at once | Soft shutdown + flush |
| Roblox maintenance or host failure | Usually yes | Flush |
| Hard crash / out of memory | **No** | Nothing runs. Loss is limited by autosave + forced saves ([[Data Persistence]] → *Save triggers*). |

`BindToClose` gets **30 seconds total** for every bound function together. Anything not done by then is lost. So everything below is done in parallel, with a time budget.

## Shutdown sequence (`ShutdownService`, Tier 0)
Bound **once**, in one place. Other services register a flush callback; they don't bind their own `BindToClose`.

```lua
-- ShutdownService (sketch)
local BUDGET = 25 -- seconds; leave a 5 s margin under Roblox's 30 s
game:BindToClose(function()
  ShutdownService.IsClosing = true          -- 1. stop new work
  Remotes.System.ServerClosing:FireAllClients(reasonText)
  ShutdownService:RunFlushers(BUDGET * 0.4)  -- 2. services finish pending writes (parallel)
  if not RunService:IsStudio() and #Players:GetPlayers() > 0 then
    SoftShutdown:MovePlayers()               -- 3. send players to a new server
  end
  -- 4. ProfileStore ends all sessions in its own BindToClose; we just wait for it
  DataService:WaitForAllReleased(BUDGET - elapsed())
end)
```

### 1. Stop new work
When `IsClosing` is true:
- Every remote handler returns `"ServerClosing"`. **No new** case opens, trades, matches, market buys, or purchases start.
- `ProcessReceipt` returns `NotProcessedYet` for new receipts. Roblox retries them on the player's next server, so nothing is lost.
- Trades in progress are **cancelled**: items return to their owners. A trade commit already in progress is allowed to finish ([[Trading System]]).
- The income tick stops, so no value is added that might not get saved.

### 2. Flushers (each service's last write)
| Service | Flushes |
|---|---|
| DataService | Sets `LastSeen = os.time()` for every profile, so offline earnings are correct |
| EconomyService | Pays out the partial income tick |
| AnalyticsService | Sends queued events |
| AdminService | Writes queued `AdminAudit` records |
| MarketService | Finishes reservations in progress, or releases them |
| ClipService | Writes clips that crossed the permanent-record threshold |
| MilestoneService | Writes peak CCU if it changed |

Flushers run in parallel (`task.spawn` each one, then wait on a counter with a deadline). A slow flusher can't block the others.

### 3. Soft shutdown (move players, don't kick them)
Use Roblox's **Migrate To Latest Update** for normal releases. It already moves players to new servers gradually. Our own soft shutdown is the fallback for **Shut Down All Servers** and emergency fixes:
1. Show the overlay: *"Updating eSports Tycoon. Your progress is saved. Moving you to a new server…"*
2. Save and **end each player's session first** (`profile:EndSession()`), so the next server can take the lock right away.
3. `TeleportService:ReserveServer(game.PlaceId)` → teleport everyone there with `TeleportData = { SoftShutdown = true }`.
4. The reserved server sees the flag, shows the same overlay, waits ~5 s for old servers to close, then teleports everyone to a normal public server, keeping parties together.
5. If the teleport fails, kick with the same message. The save is already done, so a kick is safe.

### 4. Wait for release
`DataService:WaitForAllReleased(deadline)` returns when every profile has finished `OnSessionEnd`, or when the deadline hits. If it times out, log `shutdown_save_timeout` with the user IDs that didn't finish. The next session will pick up the last autosave.

## Shipping an update (checklist)
1. Bump `CURRENT_VERSION` if the save shape changed, and add the migration ([[Save Versioning & Migrations]]).
2. Test the migration in the **test place** on real copied saves (admin "copy profile to test" tool).
3. Publish.
4. Creator Hub → **Migrate To Latest Update**. Never use Shut Down All Servers for a normal release.
5. Watch the dashboard for 15 min: `datastore_error`, `shutdown_save_timeout`, `save_guard_blocked`, `version_mismatch_redirect` ([[Analytics & Metrics]]).
6. Add a line to the [[Roadmap]] sprint log with the version number.

## Old and new servers at the same time
During a migration, old and new servers both run for a while. A player can load on a new server (save becomes v2), then land on an old server.
- The old server sees `Data.Version > CURRENT_VERSION` → **read-only**, never saves, and sends the player to a new server. See [[Save Versioning & Migrations]] → *Forward compatibility*.
- Cross-server messages (MessagingService, MemoryStore) carry a `SchemaVersion` field. Receivers ignore messages they don't understand.

## Testing in Studio
- `BindToClose` runs when you stop Play Solo. Skip teleports when `RunService:IsStudio()`.
- Test the real flow in a private test place: join with 2 accounts → Shut Down All Servers → rejoin → check values.
- Test the crash case by kicking out the server (stop the Studio server without `BindToClose`, e.g. end the process) → rejoin → confirm loss ≤ one autosave cycle and no forced-save events were lost.

## Acceptance criteria
- [ ] Shut Down All Servers with 10 test players: 0 timeouts, every save matches.
- [ ] Migrate To Latest Update during an open trade: trade cancels cleanly, nobody loses an item.
- [ ] Robux purchase prompt open during shutdown: receipt is granted exactly once, on the next server.
- [ ] Player on an old server after their save became v2: no save from the old server, player is moved.

---
tags: [system, data, persistence]
status: designed
priority: P0
stage: 1
updated: 2026-10-21
system_type: Infrastructure
engine_layer: ServerService
dependencies:
  - "[[Data Persistence]]"
  - "[[Data Schema]]"
affected_ui: []
roblox_execution_environment: ServerScriptService
---
# Save Versioning & Migrations

> How a save written by an older game version loads safely after an update, and how an older server is kept from damaging a newer save. Part of [[Data Persistence]].

## Version field
- `Profile.Version` is the save shape's version. It starts at `1` ([[Data Schema]]).
- `CURRENT_VERSION` lives in `ServerScriptService/Services/DataService/Migrations.lua`.
- Bump it **only** when the meaning or shape of saved data changes: a renamed field, a moved field, a changed unit, or a new enum value. Adding a new field with a default does **not** need a bump, because `Reconcile()` fills it in.

## Migration chain
```lua
-- Migrations.lua
local Migrations = {}
Migrations.CURRENT_VERSION = 3

-- Each step upgrades exactly one version: [n] turns a v(n) save into v(n+1).
Migrations[1] = function(data)
  -- v1 → v2: Inventory.Boosters list → map keyed by BoosterId
  local map = {}
  for _, b in ipairs(data.Inventory.Boosters or {}) do
    map[b.Id] = (map[b.Id] or 0) + (b.Count or 1)
  end
  data.Inventory.Boosters = map
end

Migrations[2] = function(data)
  -- v2 → v3: LegacyPoints moved into Currencies (kept old field for one release)
  data.Currencies.LegacyPoints = (data.Currencies.LegacyPoints or 0) + (data.LegacyPoints or 0)
  data.LegacyPoints = 0
end

function Migrations.Run(data)
  local from = data.Version or 1
  for v = from, Migrations.CURRENT_VERSION - 1 do
    local ok, err = pcall(Migrations[v], data)
    if not ok then return false, ("migration %d failed: %s"):format(v, err) end
    data.Version = v + 1
  end
  return true
end
return Migrations
```

Load order: **StartSession → version check → Migrations.Run → Reconcile → save guard baseline → ProfileLoaded**.
The version check runs before migrations: a save newer than `CURRENT_VERSION` goes read-only before any code touches it (see *Forward compatibility*).

## Rules for writing a migration
1. **One step per version.** Never jump from v1 to v4 directly. A v1 save runs 1→2→3→4.
2. **Pure and safe to re-run.** Only touch `data`. No DataStore calls, no `wait`. If the server dies mid-load, the next server runs it again on the unchanged save.
3. **Never delete data in the same release that stops using it.** Rename/move → copy to the new place, then leave the old field. Remove the old field 2 versions later. That way a rollback to the previous build still finds its data.
4. **Never lower a value.** If a currency or stat formula changes, convert so the player ends with **at least** what they had.
5. **If a migration fails, the player doesn't play.** Kick with *"We're updating your save. Please rejoin in a minute."* Log `migration_failed` with the version and error. **Don't save.** The save stays exactly as it was until a fix ships.
6. **Test on real saves.** Every migration gets a unit test with a frozen copy of a real older save in `Tests/Fixtures/profile_vN.json`.
7. Write each version bump into the table below.

## Forward compatibility (newer save on an older server)
During a rolling update, a player's save might already be v3 when they land on a server still running v2 code.
```lua
if data.Version > Migrations.CURRENT_VERSION then
  DataService:SetReadOnly(player, true)   -- all saves skipped for this profile
  profile:EndSession()                     -- release the lock without writing
  SoftShutdown:SendToNewestServer(player)  -- or kick: "A new update is out, rejoin!"
  Analytics:Log("version_mismatch_redirect", player)
  return
end
```
Read-only also blocks every remote that changes data, so the player can't earn anything that would be thrown away.

## Config changes that touch saved data
Saved data stores **IDs**, never display names or numbers copied from config. When config changes:
| Change | Safe handling |
|---|---|
| Item / case / part renamed | ID stays the same. Only the display name in config changes. |
| Item removed from the game | Keep the ID in config with `Retired = true`. Never delete it, or saved copies become unknown. |
| Unknown ID in a save (bad data or a removed item) | Keep it in the save, hide it in UI, log `unknown_item_id`. **Never drop it automatically.** |
| Balance change (income, prices) | No migration. Saves hold amounts, not formulas. |
| Season ends (Season Case vaulted) | Owned items stay. Only the shop entry changes ([[Monthly Seasons]]). |

## Version history
| Version | Shipped | Change | Migration |
|---|---|---|---|
| 1 | — | First save shape ([[Data Schema]]) | — |

## Acceptance criteria
- [ ] Each fixture `profile_v1..vN` migrates to current with no errors and no value lower than before.
- [ ] A forced error inside a migration kicks the player and leaves the DataStore value unchanged.
- [ ] A v(N+1) save on a vN server is never written to.
- [ ] Running a migration twice on the same data gives the same result.

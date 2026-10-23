---
tags: [system, data, persistence, security]
status: designed
priority: P1
stage: 1
updated: 2026-10-21
system_type: Infrastructure
engine_layer: ServerService
dependencies:
  - "[[Data Persistence]]"
  - "[[Admin Panel]]"
  - "[[Analytics & Metrics]]"
affected_ui:
  - "[[Screen - Admin Panel]]"
roblox_execution_environment: ServerScriptService
---
# Backups & Recovery

> If something does go wrong (a bug, a bad migration, an exploit), we can see it, stop it from being saved, and put the player back. Part of [[Data Persistence]].

## Three layers
| Layer | What it is | Keeps | Used for |
|---|---|---|---|
| 1. **Save guard** | Check before every save | — | Stops a wiped or broken profile from being written at all |
| 2. **DataStore versions** | Roblox keeps old versions of every key automatically | ~30 days | Restoring one player to an earlier save |
| 3. **Daily snapshot** | Our own copy, once a day per active player | Last 7 days | Recovery that doesn't depend on Roblox's version list, plus pre-update copies |

## 1. Save guard
Runs inside DataService before a profile is written (ProfileStore's pre-save hook). It compares the data about to be saved with the **baseline** (the data loaded at session start plus the changes that went through `EconomyService:Transact` and logged item grants and removals).

Block the save if any of these are true:
| Check | Blocks when |
|---|---|
| Profile shape | `Data` isn't a table, or `Version`, `Currencies`, `Roster` is missing |
| Wipe detection | `Roster` went from ≥ 1 card to 0, or `Inventory` from ≥ 10 items to 0, with no logged reason (rebirth is a logged reason) |
| Currency jump | Cash, Gems, or Shards changed by more than the sum of logged transactions + 5% margin |
| Negative values | Any currency < 0 |
| Size | Encoded size > 3.5 MB (the hard limit is 4 MB) |
| NaN / inf | Any number that's NaN or infinite (breaks JSON) |

When a save is blocked:
1. Don't write. The last good save stays in the DataStore.
2. Log `save_guard_blocked` with the check name and the userId ([[Analytics & Metrics]]). Put a flag in the [[Admin Panel]] flag queue.
3. Keep the player playing. Retry at the next save. If it's blocked 3 times in a row, kick with *"Something went wrong with your save. Your last good save is safe. Please rejoin."*
4. **Never auto-fix.** A person reviews it ([[Security & Anti-Exploit]] → *Never auto-ban from a single signal*).

## 2. DataStore versions (built in)
Roblox stores old versions of each player key. Use `DataStore:ListVersionsAsync` and `GetVersionAsync` to list and read them.
- Each version has a timestamp, so "restore to before 14:00 yesterday" is simple.
- Version history lasts about 30 days. Older history needs layer 3.

## 3. Daily snapshot
- On the first save after midnight UTC, `DataService` also writes a copy to the `PlayerBackups` DataStore. Key: `userId:YYYY-MM-DD`.
- Keep 7 days. On writing day N, remove day N-7.
- **Pre-update snapshot:** before a release that bumps `CURRENT_VERSION`, mark the release in config (`SnapshotBeforeVersion = N`). Each player gets a snapshot on their first load of the new version, **before** the migration runs. This is the fastest way back if a migration is bad.
- Snapshots go through the request queue, so they don't use up the DataStore budget players need ([[DataStore Registry]] → *Budget*).

## Restoring a player (Admin Panel)
New tool in [[Admin Panel]] → **Player → Save History** (admin role `Support` or above):
1. Search by username or userId. Shows the version list (layer 2) and snapshots (layer 3) with time, Cash, Gems, roster count, and Version.
2. **Preview** shows a diff against the current save.
3. **Restore** needs a reason. Big restores (more than 1M Cash or any Mythic/Dev ✦ difference) need **two-person approval**, same as big grants.
4. If the player is online, they get kicked first (*"Support is restoring your save. Rejoin in a moment."*), so the restore can take the session lock.
5. The restored save keeps the **current** `Purchases` and `ClaimedGrants` lists, merged in. That way a restore never re-delivers a Robux purchase or admin grant, and never removes a Robux purchase made after the backup.
6. Logged in `AdminAudit` with the before/after diff.

## Incident playbook (bad update)
1. **Stop the damage:** turn on `LiveOps.ReadOnlyMode` (config flag, see [[Admin Panel]] → Live ops). Every profile loads read-only and nothing is saved.
2. Find which version and time window caused it, from `save_guard_blocked`, `migration_failed`, and player reports.
3. Ship a fix, or roll back to the last good place version (with Version still supported; see rule 3 in [[Save Versioning & Migrations]]).
4. Bulk-restore affected players from their pre-update snapshot, through the admin batch queue (≤ 10 writes/s).
5. Turn off read-only. Post a notice. Compensate if needed (an admin grant with a single `GrantId`, so each player gets it once).
6. Write it up in the [[Roadmap]] sprint log and the Decisions log on [[Home]].

## Acceptance criteria
- [ ] A test that sets `Roster = {}` with no logged reason is blocked and flagged.
- [ ] Restoring yesterday's version keeps a Robux purchase made today.
- [ ] A pre-update snapshot exists for every player who loaded after a version bump.
- [ ] `ReadOnlyMode` on: play for 5 min, rejoin, nothing changed in the DataStore.

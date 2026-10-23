---
tags: [feature, tools, security]
status: designed
priority: P1
stage:
updated: 2026-10-21
system_type: Infrastructure
engine_layer: ServerService
dependencies:
  - "[[Services & Remotes]]"
  - "[[Security & Anti-Exploit]]"
  - "[[Data Schema]]"
  - "[[Analytics & Metrics]]"
  - "[[Player Generator]]"
  - "[[Case Library]]"
  - "[[Admin Abuse Events]]"
affected_ui:
  - "[[Screen - Admin Panel]]"
roblox_execution_environment: ServerScriptService
---
# Admin Panel

## Summary
An in-game panel that only the dev team can open. From it you can:
- give **any eSports player** to **any real Roblox player** (online on any server, or offline)
- give **any case**, currency or item
- look up and fix a player's profile
- moderate players
- run live ops (seasons, events, codes, boosts, **Admin Abuse Events**, **global announcements**)
- moderate and announce from **terminals** (typed commands) as well as buttons
- test the game quickly

Every action is server-checked, needs a reason, and is written to an audit log that can't be edited.

UI spec: [[Screen - Admin Panel]]. Service: `AdminService` ([[Services & Remotes]]).

---

## Who can open it (roles)
Permissions are checked **on the server for every action**. Hiding the button is only cosmetic.

| Role | Who | Can do |
|---|---|---|
| **Owner** | Game owner(s) | Everything, including role changes, custom players, profile restore, wipes, editing the dev-exclusion list |
| **Admin** | Core devs | Grants (players, cases, currency, items), live ops, moderation, profile edits within limits |
| **Moderator** | Trusted community mods | View profiles, kick, temp ban (≤ 7 days), freeze trading, remove stickers/clips, trace items. **No grants.** |
| **Tester** | QA accounts | Test tools on **their own account only**, and only in the test place (not live) |

- Roles come from `ServerStorage/AdminConfig.lua` (UserId → role) **plus** rank in the studio's Roblox group (e.g. rank 250 = Admin). It lives in ServerStorage, so clients can never read the list.
- All Owner/Admin/Tester accounts go on the **dev exclusion list** automatically. They are left out of the global showcase and top lists ([[Social & Multiplayer]] → Global Top Teams showcase).
- The opening key (F2 on desktop, an admin button on mobile, `/admin` in chat) only appears for accounts the server says have a role.

---

## Features

### 1. Give eSports players
Give any player card to any real account.

**Target**
- Search by username, display name or UserId. Shows avatar, team name, stage, and whether they're online (and on which server).
- Multi-target: paste a list of UserIds (giveaways, tournament prizes, bug compensation). Owner only for more than 25 targets.

**What to give: pick a source**
| Source | Contents | Options |
|---|---|---|
| Named stars | Every Mythic/Legendary in [[Pro Player References]] | — |
| Season pros | Every headliner, Legendary and seasonal key player in [[Monthly Seasons]], any year | Season stamp, **Original foil** on/off (default **off** for admin grants) |
| Key players | All of [[Key Players]] | Stat roll (±3 as normal) or exact listed stats |
| Generated | Choose title, rarity, role, archetype, trait. Or paste a **seed** to recreate an exact card ([[Player Generator]]) | Potential band, age |
| Friend signing | A real Roblox user as a player card ([[Friend Signings]]) | Rarity |
| Custom *(Owner only)* | Any name/stats/trait. Name goes through `TextService` filter + real-pro block list ([[Gamertag Bank]]) | Stats 1–99, any trait incl. Mythic uniques |

**Grant options**
- Copies: 1–10.
- **Tradeable:** off by default. Admin-granted cards are untradeable unless an Owner turns it on, so dev grants can't flood the market.
- Overrides for the unique rule: named Mythics are normally one per account. An admin can give a duplicate only by ticking "Ignore unique rule". By default a duplicate becomes Shards like a normal drop.
- Delivery: straight to the roster bench, or a **gift in the mailbox** with a message ("Sorry about the outage, here's Kyr4z!").

### 2. Give cases
- Any case in [[Case Library]]: core, themed, role, title, region, event, **past and future Season Cases**, Throwback, special, crafting, sticker capsules.
- Count 1–100.
- Delivery: added to the target's **case inventory**, unopened, so they get the opening moment themselves.
- **Doesn't count toward pity or Sparks** by default (toggle). This stops grants from skipping progression systems.

### 3. Currencies & items
- Add or remove Cash, Gems, Shards, Fame, Followers, Legacy Points, Season Tokens, Sparks.
- Give PC parts, skins (choose seed, condition and finish, or roll), stickers, cosmetics, boosters, decor, staff cards, trophies.
- Set or remove gamepass-style perks for testing (**Tester/test place only**; never grant real gamepasses that people pay Robux for on live).
- **Limits per action** (Admin): 1M Cash, 5,000 Gems, 10 cases, 5 Mythics. Above that, a second Owner/Admin must approve (**two-person rule**).

### 4. Player lookup & profile tools
- **Profile viewer:** a read-only view of the whole profile (roster, inventory, currencies, stage, purchases, trade log, quest state, season state).
- **Edit (Admin+):** set stage, HQ era, rebirths, pass tier; fix stuck quests; clear stale `TradeLocked` flags; reset tutorial; unstick a match.
- **Remove items:** take back a card or item (e.g. a duped one). It goes to a "removed" archive so it can be restored.
- **Profile history (Owner):** the last 20 saved versions with a diff view. Restore one to undo data loss or exploit damage.
- **Purchase history:** every Robux receipt with `PurchaseId`, for refund and support cases.
- **Wipe (Owner):** full reset, typed confirmation (`WIPE <username>`) + reason.
- **Save History (Support+):** list DataStore versions and daily/pre-update snapshots, preview a diff, restore (two-person approval for big restores). Restores keep `Purchases` and `ClaimedGrants`. See [[Backups & Recovery]].

### 5. Moderation
| Action | Role | Notes |
|---|---|---|
| Kick with message | Mod+ | Shows the reason to the player |
| Temp ban (1 h – 7 d) | Mod+ | Uses Roblox `Players:BanAsync` (covers all servers + alt detection option) |
| Permanent ban | Admin+ | Same API, reason required, appealable |
| Unban | Admin+ | |
| Trade freeze | Mod+ | Blocks trading/market for that account; items stay put |
| Showcase hide | Mod+ | Removes a team from the global showcase (e.g. offensive team name) |
| Rename team | Mod+ | Forces a filtered default name + tells the player why |
| Remove sticker design / clip | Mod+ | [[Sticker System]], [[Clips & Traction]] |
| Warn | Mod+ | In-game notice, logged on the profile |
| Mute (5 min – 24 h) | Mod+ | Blocks chat on all servers (`TextSource.CanSend = false`) |
| Flag queue | Mod+ | Suspicious events from [[Security & Anti-Exploit]] (rate-limit hits, impossible values, dupe UUIDs) waiting for review |

Rule from [[Security & Anti-Exploit]]: **never auto-ban from one signal.** The flag queue is where a human reviews before acting.

### 6. Item & economy tools
- **Trace item:** enter a UUID to see every owner in order, with trade IDs (`Admin:TraceItem` from [[Trading System]]).
- **Dupe check:** results of the daily duplicate-UUID job; one click opens both owners.
- **Economy dashboard:** Cash/Gems created vs spent today, cases opened per type, Mythic pulls per hour, top earners, trade volume, and the biggest admin grants this week. Pulls from [[Analytics & Metrics]].
- **Market controls:** pause the Transfer Market, pause all trading (incident switch), change trade tax.
- **Skin markets** ([[Skin Marketplace]]): set/re-anchor a skin's Launch Price, freeze one skin or a whole title market, delist a listing, view wash-trading flags.

### 7. Live ops
- **Season control:** see the active and upcoming `SeasonDef`s. **Preview** any season's theme on your own client only. **Force-end/extend** the current season by hours (Owner, for outages). [[Monthly Seasons]].
- **Events:** start or stop events, weekend boosts and community goals early; edit times. **Admin Abuse Events** have their own card (*11*).
- **Codes:** create a code (reward, uses, expiry, one per account), see redemption counts, disable a code.
- **Global boost:** e.g. 2× Cash for 1 hour on every server (MessagingService broadcast).
- **Announcements:** a banner, splash, chat or jumbotron message on this server or **all servers**, sent from the **Announcement Terminal** (*13*) or the composer form. Text is filtered; preset styles (info, event, warning, celebrate).
- **Worlds Live:** start a bracket now, cancel one, re-run the final.
- **Showcase:** edit the dev exclusion list (Owner), pin or unpin a spotlight team, refresh the global top list now.
- **Milestones:** live CCU, peak CCU, milestone status. Alert when 150 CCU is hit to update the Dev Crate's Robux price ([[Dev Players]]).
- **Shutdown notice:** "Servers restarting for an update in 5:00" countdown, then a soft shutdown that teleports players back in. Flow: [[Shutdown & Update Handling]].
- **Read-only mode (Owner):** incident switch. Every profile loads read-only and nothing saves until it's turned off ([[Backups & Recovery]] → *Incident playbook*).

### 8. Server tools
- Server browser: every live server (JobId, player count, uptime, version). Join a server, or message it.
- This server: player list with quick actions; server FPS/heartbeat, memory, DataStore budget left.
- **Spectate / teleport to player** (Mod+), invisible to that player.

### 9. Tester tools (own account, test place)
- Set any currency, stage, era or rebirth count instantly.
- **Time travel:** fake the server time for **your session only** to test season rollovers, daily quests and offline income.
- Force the next case result (rarity or exact item) to test reveal animations.
- Force a match result, Clip Moment or life event; skip timers (training, cooldowns).
- Spawn an AI rival team or a fake trade partner.
- Toggle debug overlays (remote call counts, profile delta stream).
- On the live game these tools are **disabled at the server level** (`game.PlaceId ~= TEST_PLACE_ID` → reject).

### 10. Golden Touch: guaranteed gold from any case
While it's on, **every case or crate the panel user opens drops a gold**. Only the person who turned it on gets it. It never affects anyone else's opens.

**What counts as "gold"** (checked in this order for the case being opened):
| Case has… | Forced drop |
|---|---|
| A ★ Rare Special slot ([[Case Library]] → *★ Rare Special Items*) | A ★ knife or glove from **that case's** ★ pool |
| No ★ slot, but Legendary in its drop table | A Legendary from that case's table (Legendary is the gold rarity in the [[UI Style Guide]]) |
| Neither (e.g. Rookie Crate tops out at Epic) | The case's highest rarity |

- The drop always comes **from that case's own pool**. A case never gives an item it can't normally contain.
- Seed, condition, finish and stats still roll normally ([[Skin Pattern System]], [[Player Generator]]). Golden Touch only picks the tier.
- Never forces Mythic or Dev ✦. Dev Crate opens fall back to its Legendary pool.
- Multi-opens (×5, ×10): every item in the batch is gold.

**Commands**
| Input | Does |
|---|---|
| Panel → Testing tab → **Golden Touch** toggle + "opens left" field | On/off, optional open limit |
| `/gold on` | On until you leave the server or turn it off |
| `/gold on 25` | On for the next 25 opens, then turns itself off |
| `/gold off` | Off |
| `/gold` | Shows status: on/off, opens left, where it's allowed |

Chat commands go through `TextChatService` `TextChatCommand`s that are **only created for accounts the server says have the permission**, the same rule as the panel remotes.

**Where it works (rules)**
| Place | Who | Rules |
|---|---|---|
| Test place | Tester+ | Unlimited. Own account only. |
| Live game | **Owner only** | Needs **two-person approval** (same as big grants). Max 25 opens per approval, ends after 1 hour. |

Everything forced on live follows the admin-grant rules in *Rules & numbers*, so it can't leak into the player economy:
- Items get `Source = "AdminForced"` + `GrantedBy` + `ActionId`, are **untradeable**, can't be listed on any [[Skin Marketplace]] or [[Transfer Market]], and show the "Gift" badge.
- Doesn't count for showcase, leaderboards, collections, or achievements.
- **Doesn't touch pity counters** (`PityCounters`, Dev Pity, furry pity), so turning it off leaves real odds exactly as they were.
- Left out of drop-rate analytics, so the economy dashboard and published odds stay accurate ([[Analytics & Metrics]]).
- Robux opens are **blocked** while Golden Touch is on. A paid open must use the published odds ([[Monetization]]), so the panel asks you to turn it off first.
- Every forced open writes an `AdminAudit` record (`Type = "ForcedGold"`, case, item, seed).

**State:** session-only, held in `AdminService` memory per player. **Not saved in the Profile**, so it can never survive a rejoin, a server move or an update ([[Data Persistence]]).

```lua
-- AdminService: Golden Touch state (server only, never saved)
local GoldenTouch = {} -- [userId] = { OpensLeft = number|nil, ExpiresAt = number|nil, ActionId = string }

function AdminService:SetGoldenTouch(admin, enabled, opens)
  self:Require(admin, "GoldenTouch")            -- Tester+ in test place, Owner on live
  local live = not self:IsTestPlace()
  if not enabled then
    GoldenTouch[admin.UserId] = nil
    return self:Audit(admin, "GoldenTouchOff", {})
  end
  if live then
    opens = math.clamp(opens or 25, 1, 25)
    self:RequireApproval(admin, "GoldenTouch", { opens = opens }) -- two-person rule; yields until approved or denied
  end
  local actionId = self:Audit(admin, "GoldenTouchOn", { opens = opens, live = live })
  GoldenTouch[admin.UserId] = {
    OpensLeft = opens,
    ExpiresAt = live and (os.time() + 3600) or nil,
    ActionId = actionId,
  }
end

-- Called by CaseService for each item rolled. Returns a forced tier or nil.
function AdminService:ConsumeGoldenTouch(player, caseDef)
  local gt = GoldenTouch[player.UserId]
  if not gt then return nil end
  if gt.ExpiresAt and os.time() > gt.ExpiresAt then GoldenTouch[player.UserId] = nil return nil end
  if gt.OpensLeft then
    gt.OpensLeft -= 1
    if gt.OpensLeft <= 0 then GoldenTouch[player.UserId] = nil end
  end
  if caseDef.StarPool then return "Star", gt.ActionId end
  if caseDef.Odds.Legendary then return "Legendary", gt.ActionId end
  return caseDef.TopRarity, gt.ActionId
end

Players.PlayerRemoving:Connect(function(p) GoldenTouch[p.UserId] = nil end)
```

```lua
-- CaseService: inside the per-item roll (server only)
local forcedTier, actionId = AdminService:ConsumeGoldenTouch(player, caseDef)
local item
if forcedTier then
  item = self:RollFromTier(caseDef, forcedTier, rng)   -- normal seed/condition/finish roll inside that tier
  item.Source, item.GrantedBy, item.GrantId = "AdminForced", player.UserId, actionId
  item.Tradeable = false
  -- skip: pity update, analytics drop stats, collection/achievement progress
  AdminService:Audit(player, "ForcedGold", { case = caseDef.Id, item = item.Id, seed = item.Seed })
else
  item = self:RollNormal(caseDef, profile, rng)        -- normal path incl. pity
end
```
`Case/Open` rejects Robux-priced opens with `"GoldenTouchActive"` when `ConsumeGoldenTouch` state exists for the player (checked before the purchase prompt).

### 11. Admin Abuse Events
Server-wide free-reward chaos (Cash Rain, Crate Drop, Luck Surge, Golden Hour, Time Warp, Mythic Raffle, Party Mode…), run **automatically** from a schedule (weekly Admin Abuse Hour Sat 17:00 UTC, surprise events every ~3 h per server) or **manually** from Live Ops → *Abuse Events*. Full design: [[Admin Abuse Events]].
- Panel card: event or playlist picker, intensity 1–3, length, scope (This server / All servers), start Now / At time, Stop, and a queue of running + upcoming runs (auto and manual).
- Permissions: Admin = this server, intensity 1–2. All servers or intensity 3 = Owner, or Admin + two-person approval. Mythic Raffle and Luck Surge ×3 = Owner or approval. Moderators can't start events.
- Same economy event max once per 2 h per server; every manual start/stop is audited (`AbuseEventStart`/`AbuseEventStop`).

### 12. Moderation Terminal
A **command-line console** inside the Moderation tab for fast moderation without clicking through menus. It calls the exact same server actions as the buttons (`Admin/Moderate`), with the same permissions, limits, reasons and audit log. It's a faster input, not a back door.

**Commands**
| Command | Role | Does |
|---|---|---|
| `kick <user> <reason>` | Mod+ | Kick with message |
| `ban <user> <1h–7d> <reason>` | Mod+ | Temp ban (`BanAsync`, all servers) |
| `ban <user> perm <reason>` | Admin+ | Permanent ban → asks for approval (two-person rule) |
| `unban <user> <reason>` | Admin+ | |
| `mute <user> <5m–24h> <reason>` | Mod+ | Blocks chat sending (`TextChatService` → `TextSource.CanSend = false` on every server via the mailbox) |
| `unmute <user>` | Mod+ | |
| `warn <user> <reason>` | Mod+ | In-game notice, logged |
| `freeze <user> <reason>` / `unfreeze <user>` | Mod+ | Trade/market freeze |
| `rename <user> <reason>` | Mod+ | Force a filtered default team name |
| `hide <user> <reason>` | Mod+ | Remove from global showcase |
| `remove clip <clipId> <reason>` / `remove sticker <designId> <reason>` | Mod+ | [[Clips & Traction]], [[Sticker System]] |
| `history <user>` | Mod+ | Bans, mutes, warns, flags, notes for that account |
| `flags [n]` | Mod+ | Top of the flag queue; `flags open <id>` shows evidence |
| `note <user> <text>` | Mod+ | Private mod note on the profile |
| `who <user>` | Mod+ | Online state, server, team, stage, account age |
| `tp <user>` / `spectate <user>` | Mod+ | Same as the quick actions |
| `undo` | Mod+ | Reverses your last kick-free action (unban, unmute, unfreeze) within 10 min |
| `help [command]` | All | Usage + role needed |

**Behavior**
- `<user>` accepts username, display name (if unique in server), `@username` or a UserId. **Tab** autocompletes players in this server; **↑/↓** walks your command history (session only).
- **Reason is required** on every action command (it's the last argument, quoted or not). Missing reason → the command is rejected with usage help.
- **Destructive commands** (`ban`, `remove`, `rename`) print a summary and need a second **Enter** (or `-y`) to confirm.
- Output lines: `✓ Banned @user for 3d (ActionId a81f…)` in green, errors in red, approvals pending in yellow. Clicking an ActionId opens it in the Audit Log.
- Bulk: `ban @a @b @c 1d "alt ring"` works up to 5 targets for Mods, 25 for Admins (more = Owner + approval, same as grants).
- The terminal **never accepts free Lua or raw DataStore commands**. Only the commands in this table exist, parsed on the server.
- Rate limit: shares the 30 data-changing actions per minute per admin.

### 13. Announcement Terminal (global)
A console in the Live Ops tab for sending announcements to **this server or every server**. It replaces the old composer as the main tool (the composer form stays for people who prefer clicking; both use `Admin/Announce`).

**Commands**
| Command | Role | Does |
|---|---|---|
| `say <text>` | Admin+ | Banner on **this server** |
| `announce <text>` | Admin+ | Banner on **all servers** |
| `announce -style <info\|event\|warning\|celebrate> -for <30s–10m> -as <banner\|splash\|chat\|jumbotron> <text>` | Admin+ | Styled; `splash` = big center card, `chat` = system chat message, `jumbotron` = plaza screen |
| `countdown <mm:ss> <text>` | Admin+ | Banner with a live countdown, e.g. "Admin Abuse in 10:00!" (all servers) |
| `schedule <HH:MM UTC> <announce …>` | Admin+ | Sends later; listed in the queue |
| `list` | Admin+ | Active + scheduled announcements with IDs |
| `cancel <id>` | Admin+ | Removes it from every server |
| `abuse start <event> [intensity] [this\|all]` / `abuse stop <runId>` | Admin+ | Same as the Abuse Events card (approval rules apply) |
| `shutdown <mm:ss> [message]` | Owner | Starts the update shutdown countdown ([[Shutdown & Update Handling]]) |
| `preview <announce …>` | Admin+ | Shows it on **your screen only** |

**Rules**
- **Filtered:** every text goes through `TextService:FilterStringAsync` → `GetNonChatStringForBroadcastAsync`. If filtering fails, nothing is sent.
- **Preview before global:** the first `announce` in a session shows a preview and needs Enter again. `-y` skips it after that.
- **Limits:** max 1 global announcement per minute, max 3 on screen at once per player (oldest goes first), max 140 characters. `warning` style is Owner only (so players learn it always means something real, like a restart).
- **Delivery:** `MessagingService` topic `Announce` for instant delivery + a MemoryStore list `ActiveAnnouncements` (with `EndsAt`) so servers that start or players who join mid-announcement still see it.
- Every send/cancel writes an `AdminAudit` record (`Type = "Announce"`), with the filtered text.
- No purchase pushes in announcements ("Buy the Starter Pack now!"). Announcements are for events, updates, giveaways and incidents ([[Monetization]] principle 3).

---

## Rules & numbers
- **Reason required** for every action that changes data (dropdown + free text): Compensation, Giveaway/Prize, Bug fix, Exploit cleanup, Testing, Moderation, Other.
- **Two-person rule** for: grants above the limits, more than 25 targets, profile restore, permanent ban, wipes, trading-wide pause. The second approver gets a request in their panel; it expires after 24 h.
- **Rate limit:** 30 data-changing admin actions per minute per admin.
- **Admin-granted items** carry `Source = "Admin"`, `GrantedBy`, `GrantId`, `Reason`. They show a small "Gift" badge if the player inspects the card. By default they are untradeable and **don't count** toward the showcase or leaderboards (prevents boosting friends).
- **No self-grants on live** for Admins. Grants to your own account (or to accounts on the dev list) are blocked in the live place; use the test place. Owner can override with the two-person rule.
- Giveaways must be free to enter (no "buy X to get a Mythic from an admin").

## Server / data requirements
```lua
-- ServerStorage/AdminConfig.lua (never replicated)
AdminConfig = {
  GroupId = 0000000,
  RankRoles = { [255] = "Owner", [250] = "Admin", [200] = "Moderator", [150] = "Tester" },
  UserRoles = { [123456] = "Owner" },          -- overrides group rank
  Limits = { Cash = 1e6, Gems = 5000, Cases = 10, Mythics = 5, Targets = 25 },
  TestPlaceIds = { 0000000 },
}

-- Every admin action is one record in the AdminAudit DataStore (append-only, key = ActionId)
AdminAction = {
  ActionId, Time, AdminUserId, Role, ServerJobId,
  Type = "GrantPlayer" | "GrantCase" | "Currency" | "RemoveItem" | "Ban" | ...,
  Targets = { userId, ... }, Payload = { ... }, Reason, ReasonText,
  ApprovedBy = userId?, Result = "Delivered" | "Queued" | "Failed",
}

-- Mailbox for delivery to players on other servers or offline
-- DataStore "AdminMail", key = userId, value = list of pending grants
Grant = { GrantId, ActionId, Kind = "Player" | "Case" | "Currency" | "Item", Data, Message, CreatedAt }
```
- **Delivery flow:**
  1. `AdminService` validates role, limits and reason, then writes the audit record **first**.
  2. Grant goes into the target's `AdminMail` with `UpdateAsync`.
  3. `MessagingService` pings the target's server (if online). That server's `AdminService` pulls the mailbox into the loaded profile right away.
  4. Offline players get it on next join (DataService drains the mailbox after the profile loads).
  5. `GrantId` makes each grant **idempotent**: a grant ID already in `Profile.ClaimedGrants` is skipped, so a crash or double ping can't deliver twice.
- New card fields: `PlayerCard.Source`, `GrantedBy`, `GrantId`, `Tradeable`, `SeasonId`, `Original` ([[Data Schema]]).
- Remotes: everything under `Remotes/Admin/*`. Each handler starts with `AdminService:Require(player, permission)`. Remotes live in a folder **created only in the authorized player's PlayerGui** at runtime, so normal clients never even see them.
- Panel UI is in `ServerStorage` and cloned into the authorized player's PlayerGui on join, so exploiters can't read or open it.

## UI screens
- [[Screen - Admin Panel]]

## Dependencies
[[Data Schema]] · [[Services & Remotes]] · [[Security & Anti-Exploit]] · [[Trading System]] · [[Case Library]] · [[Pro Player References]] · [[Key Players]] · [[Player Generator]] · [[Monthly Seasons]] · [[Live Ops & Events]] · [[Social & Multiplayer]] · [[Analytics & Metrics]]

## Edge cases / exploit risks
- **Fake admin remote calls:** handlers check the caller's role on the server; a non-admin firing one is logged + flagged (likely an exploiter).
- **Stolen/compromised admin account:** limits + two-person rule cap the damage. Owner can revoke any role instantly (role cache refreshes every 60 s and on every action). The audit log shows exactly what to roll back.
- **Grant to a player mid-trade:** mailbox waits until no trade session is active, then applies.
- **Removing an item that's in a trade or market listing:** cancel the listing/trade first, then remove.
- **Target's profile is session-locked on another server:** never write the profile directly from the admin's server; always go through the mailbox.
- **Rogue admin favoritism:** admin grants are untradeable, don't count for leaderboards, and the weekly report lists the top admin grants by value for the Owner to review.
- **DataStore budget:** bulk grants are queued and sent in batches (≤ 10 writes/s).

## Acceptance criteria
- [ ] A non-admin can't open the panel or call any `Admin/*` action (server-rejected + flagged)
- [ ] Admin can give any named, season, key, generated (by seed) player to an online player on another server; it shows up within 10 s
- [ ] Grants to offline players arrive on next join, exactly once
- [ ] Admin can give any case (incl. vaulted Season Cases); it arrives unopened in case inventory
- [ ] Every data-changing action creates an audit record with admin, target, payload and reason
- [ ] Grants above limits wait for a second approver
- [ ] Tester tools are rejected in the live place
- [ ] Golden Touch: every item from every case is gold (★ → Legendary → top rarity) for the panel user only; another player opening the same case on the same server gets normal odds
- [ ] Golden Touch items are untradeable, unlistable, leave pity counters unchanged, and each has an audit record
- [ ] Golden Touch on live needs Owner + a second approver, stops after 25 opens or 1 hour, and is gone after a rejoin
- [ ] Admin-granted cards are untradeable by default and excluded from leaderboards
- [ ] Ban/kick works across servers and shows the reason
- [ ] Moderation Terminal: `ban @user 1d spam` bans with an audit record; a command without a reason is rejected; a Mod can't run `ban perm`
- [ ] Announcement Terminal: `announce` reaches every server within 5 s, is filtered, and shows for players who join during its duration
- [ ] An Admin can start an Abuse Event on their server; all-server starts need approval

## Open questions
- Should moderators come from the community at launch, or only the dev team for the first months?
- Should players see the "Gift" badge, or should it be admin-only info?
- Web dashboard (Open Cloud DataStore API) later, for support without joining the game?

---
tags: [ui]
screen: Admin Panel
status: designed
---
# Screen - Admin Panel

## Purpose
Dev-only tool for grants, player lookup, moderation, live ops and testing. Rules and permissions: [[Admin Panel]].

## Opened from / closes to
F2 (desktop), the floating 🛡️ button (mobile), or `/admin` in chat. These only exist for accounts with a role. Opens over whatever screen you're on; ✕ or F2 closes it.

## Layout
Side panel, 60% width on desktop; fullscreen on mobile. A dark utility style (not the game's playful style), with a thin **red "ADMIN" strip** at the top so screenshots are never mistaken for normal gameplay. If you're in the live place, it says **LIVE**; in the test place, **TEST**.

| Region | Contents |
|---|---|
| Top strip | ADMIN · role badge · LIVE/TEST · server JobId · pending approvals bell |
| Left rail (tabs) | Players · Give · Moderation · Items & Economy · Live Ops · Servers · Testing · Audit Log |
| Main area | The selected tab |
| Bottom bar | Last action result toast ("Gave thud to @someone, delivered") with **View in log** |

Tabs a role can't use are hidden, not greyed out.

### Players tab
- Search box (username / display name / UserId) → result cards: avatar, team logo + name, stage, online state ("Online · server 4f2a…", "Offline · 3 d ago").
- Selecting a player opens their **profile view** with sub-tabs: Overview · Roster · Inventory · Cases · Currencies · Purchases · Trades · Moderation history · Notes.
- Quick-action row: **Give…** (jumps to Give tab with target filled), Kick, Ban, Trade freeze, Spectate, Teleport to.

### Give tab
Step layout, top to bottom:
1. **Target(s):** chips of selected players, "+ add", "Paste UserIds" for bulk.
2. **Type:** big segmented control: Player · Case · Currency · Item.
3. **Picker:**
   - *Player:* source dropdown (Named stars / Season pros / Key players / Generated / Friend signing / Custom). Then a searchable card grid with rarity color, title icon and OVR. Generated shows title/rarity/role/archetype/trait dropdowns + a Seed field + **Re-roll preview**.
   - *Case:* searchable grid of every case incl. vaulted Season Cases (tag "Vaulted") and future ones (tag "Upcoming"), count stepper 1–100.
   - *Currency:* currency dropdown + amount (negative = remove).
   - *Item:* category tabs (Parts, Skins, Stickers, Cosmetics, Boosters, Decor, Staff, Trophies); skins show seed/condition/finish fields.
4. **Options:** copies, Tradeable toggle, Original foil, Ignore unique rule, Counts toward pity/Sparks, Delivery (roster/inventory vs mailbox gift + message).
5. **Reason:** dropdown + text (required).
6. **Preview card:** exactly what the player will receive, plus a warning line if it hits a limit ("Needs second approval: 6 Mythics > limit 5").
7. **Give** button (or **Request approval**).

### Moderation tab
- **Moderation Terminal** (top half, collapsible): dark console, monospaced, prompt `mod@<server> >`. Command input with Tab autocomplete for players in this server and ↑/↓ history; output scrolls above it with green ✓ / red ✗ / yellow pending lines; ActionIds are clickable (open the Audit Log row). Commands and rules: [[Admin Panel]] → *12. Moderation Terminal*. On mobile the input sits above the keyboard with quick chips: `kick` `mute` `warn` `history`.
- Flag queue list: signal type, player, time, count. Open → evidence (log lines) → Dismiss / Warn / Trade freeze / Ban.
- Active bans list with time left + Unban.
- Reports from players (clips, stickers, team names) with Remove / Keep.

### Items & Economy tab
- **Trace item:** UUID field → owner timeline.
- **Dupe flags** list.
- Economy dashboard cards: Cash in/out today, Gems in/out, cases opened, Mythic pulls/hour, trade volume, admin grants this week.
- Incident switches: Pause trading · Pause Transfer Market · Pause case store (red, confirm + reason).

### Live Ops tab
- Season timeline (previous / current / next 2) with **Preview theme (me only)** and **Extend/End** (Owner).
- Events list with start/stop/edit.
- Codes table + **New code**.
- Global boost launcher.
- **Announcement Terminal**: same console component, prompt `live@global >`. `say`, `announce`, `countdown`, `schedule`, `list`, `cancel`, `abuse`, `preview`, `shutdown`. A strip above it lists active + scheduled announcements with ✕ to cancel. Rules: [[Admin Panel]] → *13. Announcement Terminal*.
- Announcement composer (form alternative): text, style, display (banner / splash / chat / jumbotron), This server / All servers, duration, **Preview** before sending.
- **Abuse Events** card: event/playlist picker, intensity 1–3, length, scope, Start now / at time, Stop; queue of running and upcoming runs with source (Auto / @admin). See [[Admin Abuse Events]].
- Worlds Live controls.
- Showcase: current global top 10, pin spotlight, dev exclusion list (Owner).
- Shutdown countdown launcher.

### Servers tab
Table of live servers (JobId, players, uptime, version) with Join / Message. Current server health panel.

### Testing tab (TEST place only)
Toggles and fields: set currencies, stage, era, rebirths; time-travel clock (date-time picker + "Reset to real time"); force next case result; **Golden Touch** toggle + "opens left" field (gold from every case you open, see [[Admin Panel]] → *10. Golden Touch*; on live it shows for Owner only, with an approval request); force match result; skip timers; spawn AI rival / fake trader; debug overlays.

### Audit Log tab
Filterable table: time, admin, action type, target, summary, reason, approver, result. Filters: admin, target, type, date range. Clicking a row shows the full payload. Read-only for everyone, Owner included.

## States
- **No permission:** panel never loads (nothing to show).
- **Pending approval:** action card shows "Waiting for approval" with who can approve; bell badge for approvers.
- **Delivered / Queued (offline) / Failed:** toast + log row status.
- **Incident switch on:** red banner across the top of the panel for every admin ("Trading paused by @x, 12 min ago").

## Data it reads / remotes it calls
All under `Remotes/Admin/*` (created only for authorized players): `Search`, `GetProfile`, `Grant`, `RemoveItem`, `EditProfile`, `Moderate`, `Terminal`, `TraceItem`, `GetEconomy`, `SetSwitch`, `LiveOps`, `Announce`, `GetServers`, `TestTool`, `GetAudit`, `Approve`. See [[Admin Panel]] → Server / data requirements.

## Style notes
Utility look on purpose: monospaced IDs, compact tables, rarity colors from [[UI Style Guide]] for cards only. Destructive buttons are red and always need a reason and confirmation.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Server | Existence of `Remotes/Admin/*` (created only for authorized players) | Whether the panel can load at all |
| Server reply | ⚠ `Admin/GetSession` → `{ role, permissions[], isTestPlace, jobId, limits, pendingApprovals }` | Top strip, visible tabs, limit warnings, bell |
| Server reply | `Search`, `GetProfile`, `GetEconomy`, `GetServers`, `GetAudit`, `TraceItem` results | Each tab's tables |
| Server signal | ⚠ `Admin/Notify` (S→C: action result, approval request, incident switch) | Result toast, bell badge, red incident banner |
| Config | Case list, player sources, item catalogs (shared configs) | Give tab pickers |

### Player Actions & Remotes
All are `Remotes/Admin/<Action>`. Every server handler starts with `AdminService:Require(player, permission)` ([[Admin Panel]]).
| Control | Remote |
|---|---|
| Player search | `Search` |
| Open profile view | `GetProfile` |
| Give / Request approval | `Grant` |
| Remove item / currency | `RemoveItem` |
| Edit profile fields | `EditProfile` |
| Kick / Ban / Mute / Warn / Trade freeze / Unban / report actions | `Moderate` |
| Moderation & Announcement Terminal input | ⚠ `Terminal` (RF: `{ console = "mod" \| "live", line }` → output lines). Parsed on the server, which then calls the same handlers as `Moderate` / `Announce` / `LiveOps` |
| Trace item UUID | `TraceItem` |
| Economy dashboard | `GetEconomy` |
| Incident switches | `SetSwitch` |
| Seasons, events, codes, boosts, Abuse Events (`AbuseStart` / `AbuseStop` / `AbuseQueue`), Worlds, showcase, shutdown | `LiveOps` |
| Announcement composer | `Announce` |
| Servers tab | `GetServers` |
| Testing tab tools | `TestTool` |
| Audit log | `GetAudit` |
| Approve pending action | `Approve` |

### State Validation
- Hide tabs the role can't use. This is cosmetic only; the server gates every call.
- A reason is required for every write action. Destructive actions (Ban, RemoveItem, SetSwitch, shutdown) need a confirm.
- **Give preview:** compare the grant against `limits` (Cash 1e6, Gems 5,000, Cases 10, Mythics 5, Targets 25). Switch the button to **Request approval** when a limit is exceeded.
- Show the Testing tab only when `isTestPlace`.
- **Announce:** require Preview before the first global send in a session.
- **Terminals:** the client only does autocomplete and history. The server parses every line, checks the role per command, requires a reason, and rejects anything not in the command table.

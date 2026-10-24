---
tags: [ui]
screen: Main HUD
status: building
---
# Screen - Main HUD

## Purpose
Always-on overlay. Shows currencies, current objective, and opens every other panel through **9 permanent buttons** (see *Always-visible buttons*).

## Opened from / closes to
Visible whenever no fullscreen cinematic is playing. Hidden during case reveal and match cinematic (only Skip shows).

## Always-visible buttons (decision 2026-10-21)
**Rule: 9 buttons max on screen at once (fully unlocked), plus info widgets.** Everything else lives inside one of these 9, in the Phone, or in the world. A button earns a permanent spot only if the player uses it **every session** or it's the way into the **core loop** (hire → equip → compete → open → repeat).

### The 9 permanent buttons
| # | Button | Side | Color | Opens | Visible from |
|---|---|---|---|---|---|
| 1 | **Roster** | Left | Blue | [[Screen - Roster]] (tabs: Players · Gear ([[Accessories]]) · Staff & Training · Kit) | First hire (Stage 1) |
| 2 | **Compete** | Left | Red | Compete hub: Scrim · Ranked · Tournaments ([[Screen - Bracket]]) · Friend Scrim | Stage 3 |
| 3 | **Shop** | Left | Green | [[Screen - Shop]] (crates, boosters for Cash/Gems) + Tech Shop tab ([[Screen - Tech Shop]]) | Stage 2 |
| 4 | **Inventory** | Left | Purple | Tabs: **Cases** (owned cases → [[Screen - Case Opening]]) · Skins · Stickers ([[Screen - Sticker Editor]]) · Accessories · Boosters | First case (Stage 2) |
| 5 | **Quests** | Left | Orange | [[Screen - Quests]]: daily quests, achievements, Circuit Pass, streak | Stage 1 |
| 6 | **Store** | Right | Gold | [[Screen - Store]] (Robux only) | After the tutorial |
| 7 | **Gift** | Right | Pink | Playtime gifts with `mm:ss` countdown ([[Daily Loops & Quests]]); "Done for today" state when all claimed | Stage 1 |
| 8 | **Map** | Right | Teal | Fast travel + **Visit** tab ([[World Layout & Presentation]]) | After the tutorial |
| 9 | **Phone** | Right | Dark | App grid (below). Also where Aunt Dee's texts and calls pop up | Stage 1 (from the intro) |

Left rail = **run the team**. Right rail = **meta**: money, gifts, travel, everything else. Order on each rail is fixed, so muscle memory works. New buttons **slot into their place** with the unlock pop, they never push others around.

### Phone apps (the "everything else" menu)
| App | Opens | Unlock |
|---|---|---|
| Settings | [[Screen - Settings & Odds]] (Settings · Odds & Rules · Codes · Credits) | Always |
| Dee's Tips | Lesson replay + hints ([[Tutorial & Onboarding]]) | Always |
| Social | Friends in server, Visit, trade requests ([[Screen - Trade]]), friend scrim challenges | Stage 2 |
| Streamr | [[Screen - Clip Feed]] + clip editor | Stage 4 |
| Mail | Sponsors ([[Screen - Sponsors]]), admin grants, season mail | Stage 4 |
| Market | [[Screen - Skin Marketplace]] | Stage 4 |
| Collection | Collection Log, Trophy list, achievements index ([[Achievements & Collections]]) | Stage 2 |
| Leaderboards | Global / friends boards ([[Social & Multiplayer]]) | Stage 3 |
| Legacy | [[Screen - Rebirth]] + Legacy perks | Stage 10 |
- The Phone button's badge = sum of its apps' badges (e.g. 2 new sponsor offers + 1 trade = **3**).
- An app that gets something urgent (trade request, challenge) also shows a toast with an action button, so you never have to dig.

### Info widgets (always visible, not buttons)
| Region | Anchor | Contents |
|---|---|---|
| Top center | (0.5, 0) offset y 44 (below Roblox top bar) | **Cash** pill (always), **Gems** pill with "+" → Store (Stage 2), **Followers** pill (Stage 4). Height 40, gap 8. Fame isn't a pill; it's the stage ring |
| Top right | (1, 0) | Stage progress ring (Fame to next gate) + stage name. Tap = stage goals |
| Bottom center | (0.5, 1) offset y −24 | Objective card: icon, text, progress bar, arrow to collapse |
| Bottom left | (0, 1) | Timer chips: free crate, active boosters (max 3, then "+2") |
| Toasts | (0.5, 0.25) | Achievement / reward / invite toasts, max 2 stacked |

### Contextual buttons (only when relevant)
Shown in a slot **above the objective card**, max 2 at a time, newest on top. They disappear when handled.
| Button | When |
|---|---|
| **Collect $X** | On join, if offline income is waiting |
| **Next match** | A tournament/season match has been played and is ready to watch (tournaments take real time; skip waits with [[Time Skip Tickets]]) |
| **Claim free crate** | The free crate timer chip turns into this when ready |
| **Event** | During a live event or an [[Admin Abuse Events|Admin Abuse Event]] ([[Live Ops & Events]]); also sits on the right rail under Store for the event's length (the only time there are 10). Abuse events also show a top banner with time left and who started it |
| **Back to my HQ** | While visiting someone's plot or in a district far from home |
| **Rebirth ready** | Stage 10, after winning Worlds |
| **Skip** | During cinematics (case reveal, match, cutscenes); everything else is hidden |

### Not on the HUD (on purpose)
Sponsors, Clips, Settings, Social/Visit, Trade, Market, Collection, Leaderboards, Staff, Kit editor, Tech Shop. They're reached through the Phone, a parent button, or walking up to their room/counter. Sponsors and Clips are big Stage 4 features, but they're **check-ins**, not every-few-seconds actions, so badges on the Phone are enough.

### Mobile layout
- Rail buttons 52×52, icon only, label on long-press.
- Left rail is 5 buttons tall (5 × 52 + 4 × 8 = 292 px). On screens shorter than ~400 px it becomes **2 columns** (3 + 2), like the pet-sim reference.
- Right rail stays 4 tall. Both rails keep clear of the Roblox top bar, the chat button, and the thumb zone used for walking (bottom left on mobile, so timer chips move to top left on touch devices).

## Button style
![[BuildAPC_HUD_side-buttons_shop-index.png]]

What to copy from the reference (Build a PC side buttons):
- **Chunky colored panels**, one color per function: green for shopping (Shop, Store), blue for collection and info (Index = the collection log in [[Achievements & Collections]], Roster). Keeps the rail scannable at a glance.
- **Dark outline + inner light border** on each button, so it reads on any background.
- **Icon on the left, bold label on the right** (white with a dark stroke). The icon carries the meaning, the label confirms it.
- **Attention badge**: a red circle, top right corner, with white `!` (needs action) or a number (count, e.g. claimable quests). Replaces the plain red dot.

Our version: same structure, colors from [[Art & Audio Direction]]. Rail buttons are a bit taller than the reference so they fit the 44 px touch target on mobile. Labels hide on mobile (icon only), as above.

## Components used
Currency pill, rail button (labeled, colored, with `!` or count badge), progress bar, objective card, toast, timer chip.

## States
- New player (intro): only Cash pill, objective card, Phone and Gift. Roster appears with the first hire, Quests after the first quest is given; then each button pops in at its unlock (table above) with a pop-in tween + sparkle and a Dee text explaining it.
- **As built (M1, 2026-10-23):** Stage 1 shows the Cash pill only; Fame lives in the stage ring (top right, "Stage 1 · Garage Squad ★ 60/100"); the Gems pill pops in at Stage 2 and Followers at Stage 4. Phone is on the right rail from the start; Roster joins the left rail with the first hire. The Gift and Quests buttons aren't built yet. Contextual slot in use: "▶ Play Pickup Game" (while seated at your desk, with the cooldown) and "🎁 Open Rookie Crate".
- Attention badge (red circle with `!`, or a count) appears on a rail button when something new is available (claimable quest, new shop stock).
- Currency change: number counts up over 0.4 s, pill pulses green (gain) or red (spend).

## Animations / sounds
Pill pulse 0.15 s scale 1.08; rail button hover scale 1.05; unlock pop 0.3 s Back easing + chime.

## References
More context: [[Reference Board - Simulator UI]].
| Image | Source | What to copy |
|---|---|---|
| ![[HatchSim_Shop_starter-pack-and-tile-rows.png]] | Pet-hatching simulator | 2-column icon rail on the left, level bar + green cash pill bottom center |

## Data it reads / remotes it calls
Reads `Currencies.*`, `Stage`, `Quests`, `Boosters`. Calls none directly; opens panels.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Currencies.Cash`, `.Gems`, `.Fame`, `.Followers` | Currency pills + count-up/pulse on delta |
| Profile | `Stage` | Which rail buttons are visible; stage ring and name |
| Config `Stages` | Fame gate per stage, stage names, unlock list | Stage progress ring; unlock pop-ins |
| Profile | `Quests` (claimable count) | Quests badge dot |
| Profile | `Inventory.Boosters` (id, endsAt) | Booster timer chips |
| Profile | ⚠ `FreeCrateAt` (next free crate time) | Free crate timer chip |
| Server signal | ⚠ current objective (from `TutorialService` / `ObjectiveService`) | Objective card text + progress |
| Server signal | ⚠ `Notify/Toast` (S→C RemoteEvent: type, text, icon) | Achievement / reward toasts (max 2) |
| Client | `UIController` cinematic flag | Hide HUD during case reveal / match cinematic |

### Player Actions & Remotes
| Control | Fires | Notes |
|---|---|---|
| Rail buttons (Roster, Compete, Shop, Inventory, Quests, Store, Gift, Map, Phone) | none | `UIController:Open(screen)` only |
| Phone apps | none | `UIController:Open(screen)` only |
| Contextual buttons | per button | Collect → `Income/CollectOffline`, Claim free crate → `Gift/Claim`, Next match → opens pre-match |
| Objective card arrow toggle | none | Local collapse |

### State Validation
- Show a rail button / phone app only if its unlock condition is met (stage, first hire, first case, tutorial done). Unlock list lives in `Shared/Config/HudButtons.lua`.
- Run the count-up only when the delta path matches `Currencies.*`. Pulse green if the value went up, red if it went down.
- Don't show toasts while a cinematic is playing; queue them and cap at 2 on screen.
- Timers count down from the server's `endsAt` timestamps (`workspace:GetServerTimeNow()`), never from the local clock.

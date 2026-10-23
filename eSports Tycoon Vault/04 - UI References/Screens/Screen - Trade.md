---
tags: [ui]
screen: Trade
status: designed
---
# Screen - Trade

## Purpose
Live trade window between two players. Rules in [[Trading System]].

## Opened from / closes to
Player profile → Trade, or accepting a trade request popup. Closes to wherever the player was.

## Layout
Fullscreen modal on mobile, 80% panel on desktop.
| Region | Contents |
|---|---|
| Top bar | Both team logos and names, ✕ Cancel |
| Left half | **Your offer**: 8 slots (4×2), Shards field, value bar |
| Right half | **Their offer**: 8 slots, Shards, value bar |
| Center strip | Fairness meter (green / yellow / red) |
| Bottom | Your inventory drawer with filter tabs (Players, Parts, Cosmetics, Decor, Shards), search, sort by value |
| Bottom bar | Preset phrase buttons + emotes, **Ready** toggle, tax line ("Trade tax: $1,240") |
| Each side | Ready checkmark that lights green when that player is ready |

Mobile: offers stack vertically (theirs on top, yours below), inventory drawer slides up from the bottom.

## States
- **Editing:** Ready off for both.
- **One ready:** their side shows a green check; your Ready button pulses.
- **Both ready:** 5-second countdown overlay + summary list ("You give / You get").
- **Confirm:** both press Confirm; spinner "Completing trade…".
- **Uneven warning:** red meter shows "This trade looks very uneven" and needs an extra tap on Confirm.
- **Failed:** "Trade failed, nothing changed."
- **Success:** receipt card with both item lists, "Undo (10 min)" note.
- Locked items in your inventory are greyed with 🔒 and a tooltip reason.

## Animations / sounds
Item drops into a slot with a soft snap. Any change on the other side flashes their slot yellow and plays a short alert, so swaps are noticed. Success: handshake SFX + confetti in both team colors.

## Data it reads / remotes it calls
Reads inventory, item values. Calls `Trade/SetOffer`, `Trade/Ready`, `Trade/Confirm`, `Trade/Cancel`, `Trade/Phrase`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Roster` (`Tradeable`), `Inventory.Parts`, `.Cosmetics`, `Currencies.Shards` | Inventory drawer, Shards field |
| Profile | ⚠ item lock state (hold / listed / equipped-in-match + reason) | 🔒 greyed items |
| Profile | `Trade { History, DailyCount, DayStamp }` ([[Trading System]]) | Undo note, daily limit |
| Config | Item value table ([[Balance Tables]]) | Value bars, fairness meter |
| Server signal | ⚠ `Trade/State` (S→C RemoteEvent: both offers, ready flags, countdownEndsAt, status) | Their offer, ready checks, countdown, success/fail |
| Config | Preset phrase list | Phrase buttons |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Trade request | `Trade/Request` | RF | targetUserId | requestId / error |
| Accept / decline popup | `Trade/Respond` | RE | requestId, accept | — |
| Add / remove item, Shards | `Trade/SetOffer` | RF | sessionId, itemIds, shards | ok / error |
| Ready toggle | `Trade/Ready` | RE | sessionId, ready | — |
| Confirm | `Trade/Confirm` | RF | sessionId | receipt / failed |
| ✕ Cancel | `Trade/Cancel` | RE | sessionId | — |
| Phrase button | `Trade/Phrase` | RE | sessionId, phraseId | — |
| Undo (receipt) | `Trade/Undo` | RF | tradeId | ok / error |

### State Validation
- Offer ≤ 8 items and ≤ 1,000 Shards. Every item is owned, `Tradeable`, and not locked.
- Enable Confirm only when both players are ready and the 5-second countdown has finished. Uneven trades need the extra tap.
- Any change from the other side resets your Ready flag. Flash the changed slot.
- **Undo:** within 10 minutes of `At`.
- Rate limit: 5 calls/s per trade remote.

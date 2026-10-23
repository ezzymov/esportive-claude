---
tags: [feature, system]
status: designed
priority: P2
stage: 4
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Security & Anti-Exploit]]"
  - "[[Services & Remotes]]"
  - "[[Data Schema]]"
  - "[[Analytics & Metrics]]"
  - "[[Balance Tables]]"
affected_ui:
  - "[[Screen - Trade]]"
  - "[[Screen - Settings & Odds]]"
roblox_execution_environment: ServerScriptService
---
# Trading System

## Summary
Players swap player cards, parts, cosmetics and Shards with each other. Trading gives duplicates value, helps players finish collections, and makes the game more social. It is also the **highest exploit risk** in the game, so this note is strict about safety.

This note is the source of truth for all trading. [[Transfer Market]] covers the market listing side; [[Social & Multiplayer]] links here for direct trades.

## The 3 ways to trade
| Mode | Unlock | Who with | Speed | Launch? |
|---|---|---|---|---|
| **AI Transfer List** | Stage 5 | AI clubs | Instant, fixed price | ✅ Launch |
| **Direct Trade** | Stage 4 | Real player in the same server | Live, both online | ✅ Launch |
| **Global Market** | Stage 7 | Any real player, any server | Async listings, 24 h | ⏳ Post-launch |

---

## 1. Direct Trade (player ↔ player, same server)

### Flow
1. **Request:** open a player's profile (tap their avatar, the visit list or the leaderboard) → **Trade**. They get a popup: Accept / Decline / Block. Requests expire after 30 s.
2. **Trade window opens** for both players (see [[Screen - Trade]]).
3. **Offer:** each side adds up to **8 items** + optional Shards. Inventory filters: Players · Parts · Cosmetics · Decor · Shards.
4. **Lock in:** each player presses **Ready**. Any change to either offer clears both Ready states.
5. **Review step:** after both are Ready, a 5-second countdown shows a summary of exactly what you give and get, with a value comparison.
6. **Confirm:** both press **Confirm** after the countdown. Server runs the atomic swap.
7. **Done:** both see a receipt card. The trade is logged in both players' Trade History.

Either player can press **Cancel** at any time before both confirm.

### What can be traded
| Item | Tradeable? | Notes |
|---|---|---|
| Player cards (Common–Legendary) | ✅ | Must not be in active roster, training, bootcamp or a match |
| Named Mythic stars | ⚠️ | Tradeable after 7-day hold; max 1 Mythic trade per day |
| PC parts | ✅ | Must be unequipped |
| Cosmetics (from Gem/Cash cases) | ✅ | |
| Decor | ✅ | Must be removed from HQ first |
| Shards | ✅ | Max 1,000 per trade |
| Cash | ❌ | Stops "gifting" cash from alt accounts and real-money selling |
| Gems | ❌ | Premium currency stays on the account |
| Gamepass perks, Robux-bought items | ❌ | Account-bound (safer for policy and refunds) |
| Event-limited items | ⚠️ | Tradeable only after the event ends |
| Staff cards | ✅ | Must be unassigned |
| Trophies, achievements, titles | ❌ | Earned, not traded |
| Academy prospects | ❌ | Homegrown only |
| Your Founder card | ❌ | It's you, see [[Founder (You)]] |
| Friend signings | ❌ | Real friend's avatar; see [[Friend Signings]] |

Untradeable items show a 🔒 icon with the reason in a tooltip.

### Tax
- **10% of the trade's total value in Cash**, paid by each side (based on the value of what they receive). This is a cash sink, not a profit.
- If a player can't afford the tax, the Confirm button is disabled with "Need $X for trade tax".
- Pure cosmetic-for-cosmetic trades under $1,000 value: tax-free (keeps small friendly swaps easy).

### Value guide
Each item has a **Base Value** (see [[Balance Tables]]): rarity + OVR + Potential for players, tier for parts, rarity for cosmetics. Limited items get a scarcity multiplier based on how many exist. Skins also use condition, finish and signature multipliers from [[Skin Pattern System]], plus a sticker bonus from [[Sticker System]]. Furry player cards get a species multiplier ([[Furry Variants]]) (applied stickers stay on the skin when traded; custom stickers trade to friends only).

The trade window shows:
- A value bar for each side.
- A **fairness meter** (green = fair, yellow = one side gets 2× more, red = 4× or more).
- A red meter adds a warning: "This trade looks very uneven. Are you sure?" and needs an extra tap.

The meter never blocks trades between friends. It's there to protect younger players from being talked into bad deals.

---

## 2. AI Transfer List
- Sell any tradeable player or part to AI clubs for **70% of Base Value** instantly.
- Buy from a rotating list of 12 AI-listed players (refreshes every 2 h) at **120% of Base Value**.
- No other players involved, so no exploit risk. Good way to turn duplicates into Cash.

## 3. Global Market (post-launch)
Summary here; full detail in [[Transfer Market]]. **Skins** sell on the per-title [[Skin Marketplace]] (Stage 4, dev Launch Prices, stickers sold with the skin).
- List an item for a Cash price inside **50%–300% of Base Value**.
- Item goes into **escrow** (removed from your inventory) when listed.
- Buyers browse by category, rarity, role, title, price. Purchase is instant.
- Listings last 24 h; unsold items return automatically.
- 10% tax on the sale price, paid by the seller.
- Max 10 active listings per player.

---

## Safety rules
### Account rules
- Account age ≥ **3 days** on Roblox and ≥ **2 h playtime** in this game before trading.
- Stage 4+ for direct trade, Stage 7+ for Global Market.
- **Trade cooldown:** 10 s between trades; max 30 completed trades per day.
- New item hold: items received in a trade can't be re-traded for **24 h** (stops chain-scams and laundering).

### Anti-scam design
- No free-text chat inside the trade window. Only preset phrases: "Add more?", "Looks good!", "No thanks", "What do you want?", plus emotes.
- Any change to an offer resets both Ready states and restarts the countdown. This stops the classic "swap the item at the last second" scam.
- Item cards show full stats, rarity and a "Limited" or "🔒" badge. Look-alike items can't be confused.
- Summary screen lists every item in plain words ("You give: t0KAMI (Legendary Sniper, OVR 84)").
- **Trade undo for 10 minutes:** if both players agree, a completed trade can be reversed from Trade History (both must press Undo). Helps fix honest mistakes.
- Players can turn off trade requests entirely in Settings, or allow Friends only.
- Block stops all requests from that player.

### Parental / age considerations
- Default for accounts under 13: **Friends-only trade requests** (setting can be changed).
- No Robux or real-money value shown anywhere in trading.
- Trading off-platform for Robux or money is against the rules; report button in the trade window and Trade History.

---

## Server design (anti-dupe)
**Golden rule:** an item exists in exactly one place at all times: a profile, a trade lock, or escrow.

### Direct trade steps (server)
1. `Trade/Request(targetUserId)` → checks both players eligible, not already trading.
2. Server creates a `TradeSession { Id, A, B, OfferA, OfferB, ReadyA, ReadyB, State }` in memory.
3. `Trade/SetOffer(sessionId, items, shards)` → validates every item is owned, tradeable, not locked. Items are marked **TradeLocked** in the profile (can't be equipped, sold or listed while locked).
4. Both Ready → countdown → both Confirm.
5. **Commit:**
   - Re-validate everything (ownership, locks, tax, inventory space).
   - Use ProfileStore/session-locked profiles for both players (both are in this server, so both profiles are loaded and locked here).
   - Move items + Shards, deduct tax, clear locks, in one function with no yields between the checks and the writes.
   - Write a **trade log** entry `{TradeId, A, B, ItemsA, ItemsB, Tax, Time}` to both profiles and an audit DataStore.
   - Force-save both profiles immediately.
6. If anything fails, roll back locks and tell both players "Trade failed, nothing changed."

### Disconnects
- Player leaves during trade (before commit): session cancelled, locks cleared on both profiles.
- Server crashes mid-commit: session-locked profiles + the "no yield between check and write" rule means either both saves include the trade or neither does. On next load, any leftover `TradeLocked` flags are cleared.

### Item identity
- Every tradeable item has a **unique ID (UUID)** created when it drops. Trades move IDs, never create new items.
- Audit tool: `Admin:TraceItem(uuid)` shows every owner in order (Items & Economy tab of the [[Admin Panel]]).
- Admin-granted items are untradeable by default (`Tradeable = false`) unless an Owner enables it.
- Daily server job checks for duplicate UUIDs across logs and flags them.

### Remotes
| Remote | Type | Args | Checks |
|---|---|---|---|
| Trade/Request | RF | targetUserId | eligibility, cooldown, block list, settings |
| Trade/Respond | RE | requestId, accept | request valid, not expired |
| Trade/SetOffer | RF | sessionId, itemIds, shards | owned, tradeable, ≤ 8 items, ≤ 1,000 Shards |
| Trade/Ready | RE | sessionId, ready | session state |
| Trade/Confirm | RF | sessionId | countdown done, both ready |
| Trade/Cancel | RE | sessionId | in session |
| Trade/Undo | RF | tradeId | ≤ 10 min, both agree, items still untouched |
| Trade/Phrase | RE | sessionId, phraseId | phrase in preset list |
Rate limit: 5 calls/s per trade remote.

### Data
```lua
Profile.Trade = {
  History = { {TradeId, With, Gave, Got, Tax, At} }, -- last 50
  DailyCount = 0, DayStamp = 0,
  Settings = { Requests = "Everyone" | "Friends" | "Off" },
}
Item = { Uuid, DefId, ObtainedAt, TradeHoldUntil, TradeLocked = false, Source = "Case"|"Trade"|... }
```

---

## UI screens
- [[Screen - Trade]] (trade window)
- Trade History tab in Inventory
- Trade settings in [[Screen - Settings & Odds]]

## Economy impact
- Tax is a big Cash sink for the late game. Track total tax collected per day in [[Analytics & Metrics]].
- Watch for "value inflation": if Legendaries trade far above Base Value, raise their drop rate slightly or add a Selector Case for them ([[Case Library]]).
- AI Transfer List sets a floor (70%) and ceiling (120%) for prices, which keeps values sane.

## Edge cases / exploit risks
| Risk | Defense |
|---|---|
| Duplication on disconnect | Atomic commit, session locks, UUIDs |
| Last-second item swap | Any change resets Ready + countdown |
| Alt accounts funneling items | Account age, playtime, 24 h hold, daily cap, no Cash/Gem trades |
| Real-money trading | No Robux/Cash trades, report button, monitor unusual one-sided trades |
| Scam talk | Preset phrases only, fairness meter, undo window |
| Item in use (equipped/in match) | Items must be free; TradeLocked flag blocks use |
| Inventory full | Check space before commit; block Confirm with message |
| Trading a player mid-contract event | Pending life events for that player are cancelled |

## Acceptance criteria
- [ ] Two players can complete a trade and both inventories update correctly after rejoin
- [ ] Changing an offer resets both Ready states
- [ ] Leaving mid-trade leaves both inventories unchanged
- [ ] Tax deducted correctly; tax-free rule works for small cosmetic swaps
- [ ] Untradeable items can't be added (🔒 shown)
- [ ] 24 h hold blocks re-trading received items
- [ ] Undo within 10 min restores both sides when both agree
- [ ] Stress test: 1,000 scripted trades with random disconnects → zero duplicate UUIDs

## Open questions
- Allow Gems in trades? Recommend **no**: too much real-money-trading risk.
- Cross-server direct trades (friend in another server)? Post-launch, through the Global Market instead.
- Should Mythic stars be tradeable at all? Current answer: yes, with a 7-day hold and 1 per day. Revisit after launch data.

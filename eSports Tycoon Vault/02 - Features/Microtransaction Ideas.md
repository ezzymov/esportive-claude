---
tags: [feature, monetization]
status: idea
priority: P1
stage: 0
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Monetization]]"
  - "[[Analytics & Metrics]]"
affected_ui:
  - "[[Screen - Store]]"
roblox_execution_environment: ServerScriptService
---
# Microtransaction Ideas

Idea bank for Robux purchases. Rules and the core pass list live in [[Monetization]]; this note is the long list to pick from. Robux prices are first guesses; test them.

## Guardrails (check every idea against these)
- ✅ **Saves time, adds style, or adds convenience.** ❌ Never sells a stat edge that you can't earn free.
- ✅ Price shown in Robux before the native prompt. ❌ No fake countdowns, "only 2 left", or guilt text.
- ✅ Odds shown on anything random. ⚠️ Check Roblox's current paid-random-item policy before selling any random item for Robux.
- ✅ Many players are young: no surprise spending, no confusing bundles, no pay-to-skip-a-friend's turn.
- Rate each idea: 🟢 safe · 🟡 needs care · 🔴 avoid.

## 1. Gamepasses (one-time)
Already in [[Monetization]]: 2× Cash, Auto-Collect, VIP Lounge, Extra Roster Slot, Offline Pro, Fast Open, Auto-Buy Pads.

| Pass | Effect | R$ | Rating |
|---|---|---|---|
| Team Bus | Teleport to any room in your HQ instantly | 99 | 🟢 |
| Pro Editor | Extra clip thumbnails, titles, music stings, custom intro card | 149 | 🟢 |
| Jersey Studio Pro | Extra patterns, gradient colors, number fonts, animated sleeve | 199 | 🟢 |
| Second Training Queue | +1 training slot permanently | 249 | 🟡 time-saver, keep free path |
| Caster Pack: Hector Hype+ | Extra caster voice lines and celebration calls | 99 | 🟢 |
| Photo Mode | Free camera, filters, poses for HQ/trophy screenshots | 79 | 🟢 |
| Rivalry Radar | Notifies when your rival is online, rival history stats | 79 | 🟢 |
| Analyst Desk | Detailed post-match stats page (heatmaps, round timeline) | 149 | 🟢 info only |
| Double Daily Quests | 6 daily quests instead of 3 | 199 | 🟡 |
| Lucky Charm | +1 step faster pity on every case | 299 | 🔴 random-odds boost, avoid |
| 2× Followers | Double clip followers | 399 | 🟡 pairs with 2× Cash; don't stack too many multipliers |

## 2. Developer products (repeatable)
| Product | Effect | R$ | Rating |
|---|---|---|---|
| Gem packs | 100 / 550 / 1,200 / 3,000 Gems | 49 / 249 / 499 / 999 | 🟢 |
| Cash Burst | 10 min of current income × 3 | 29–99 (scaled by stage) | 🟢 |
| Hype Boost | 2× clip views 30 min | 49 | 🟢 |
| Server Hype | **Everyone in the server** gets 1.5× income 15 min, buyer gets a shout-out | 99 | 🟢 social, great for Roblox |
| Time Skip Tickets | Packs of 15 min / 1 h / 4 h skips for training, tournament waits, scouting… ([[Time Skip Tickets]]); replaces Instant Training | 39 / 79 / 249 | 🟢 |
| Instant Bootcamp | Finish bootcamp now | 49 | 🟢 |
| Stock Refresh | Refresh Tech Shop stock once | 25 | 🟢 |
| Free Agent Reroll | Refresh free agent board once | 25 | 🟢 |
| Name Change | Rename team after Stage 2 (free until then) | 39 | 🟢 |
| Respec Token | Reset Legacy perk tree | 99 | 🟢 |
| Revive Contract | Undo a sponsor cancel penalty | 39 | 🟡 |
| Tournament Retry | Re-enter a tournament after elimination | 49 | 🔴 feels pay-to-win, use a free daily retry instead |

## 3. Cosmetics (direct buy, no randomness)
| Category | Ideas | R$ |
|---|---|---|
| Jerseys | Holo, Galaxy, Lava, Ice, Glitch, Gold Trim, Retro 90s, Pixel Camo | 49–149 |
| Logos | Animated logo frames, metallic shine, flame aura | 49–99 |
| Desk skins | Carbon, Neon Grid, Gold Throne, Aquarium desk, Floating desk | 79–199 |
| Station FX | RGB wave, lightning keyboard, smoke vents, confetti on kill | 49–149 |
| HQ themes | Cyber Night, Cozy Cabin, Space Station, Haunted Arcade | 199–399 |
| Victory emotes | Chair Spin, Trophy Lift, Desk Slam, Robot Dance (player avatar + roster) | 49–99 |
| Case reveal skins | Change the unboxing stage: volcano, space, arcade, stadium | 99–199 |
| Mascots | Wolf, Robot, Dragon, Slime, Pigeon | 149–299 |
| Crowd FX | Fan flags, cheer sticks, fireworks in team colors | 99 |
| Chat / name tags | "Coach", "Captain", "Org Owner" tag color | 49 |
| Caster outfits | Dress up the casters for your matches | 79 |

## 4. Bundles
| Bundle | Contents | R$ | Notes |
|---|---|---|---|
| Starter Pack (once) | 500 Gems + Pro Crate + Rookie Jersey + 2× Cash 1 h | 99 | Best value, show only first 3 days |
| Garage to Glory | Desk skin + jersey + 1,200 Gems | 399 | Stage 3+ |
| Streamer Kit | Pro Editor pass + Streamer Booth skin + Hype Boost ×3 | 299 | Stage 4+ |
| Arena Pack | Mascot + crowd FX + HQ theme | 499 | Stage 8+ |
| Event bundle | Event jersey + event decor + event tokens | 199–399 | Seasonal only |
Bundles must always cost less than the parts bought separately, and show what's inside before the prompt.

## 5. Season & subscription
| Item | Contents | R$ | Rating |
|---|---|---|---|
| Circuit Pass Premium | Premium track: cosmetics, Gems back (≈ 80% of price), exclusive jersey | 399 / season | 🟢 |
| Circuit Pass+ | Premium + skip 10 tiers | 799 | 🟡 |
| Roblox Subscription "Org Owner Club" | Daily 30 Gems, monthly exclusive cosmetic, +1 free daily case | ~R$ equivalent of $4.99/mo | 🟡 check Roblox subscription rules and age limits |

## 6. Social & creator
| Idea | How it works | Rating |
|---|---|---|
| Gift anything | Buy a gamepass/cosmetic/bundle for a friend in-server | 🟢 |
| Tip jar on HQ | Visitors can tip an HQ owner Robux-bought "Hype Stickers"; owner gets a cosmetic badge | 🟡 avoid real-money transfer between players |
| Clip promo | Pay to feature your clip at the top of the server feed for 10 min | 🟡 limit 1 per 30 min per server |
| Sponsor a server tournament | Buyer funds an extra prize pool (Gems) for everyone in the server Worlds Live | 🟢 |
| Name a trophy | Engrave text on your trophy (filtered) | 🟢 |

## 7. Ideas to avoid 🔴
- Selling exclusive stat-power players or Mythic parts only for Robux.
  - **One documented exception:** [[Dev Players]] (the Dev ✦ players from the Dev Crate: 500 R$ or 2,500 Gems per open, same odds shown up front). Don't add more.. Don't add more.
- Robux-only cases with better odds than the Gem version.
- Energy/stamina systems that block play until you pay.
- Loss-aversion offers ("Pay now or lose your streak").
- Paid trade advantages or paid market listing boosts.
- Any prediction or wager using currency (see [[Prediction Pick'em]]).

## Placement (where offers appear)
| Moment | Offer | Rule |
|---|---|---|
| First 3 days | Starter Pack banner in Store | Max 1 popup per session |
| Not enough Gems at case screen | "Get Gems" link (no popup) | Link only |
| After a big win | Victory emote shop tile on results screen | Small tile, never blocks Continue |
| Long training / tournament wait | ⏩ Skip button beside the timer (tickets first, Gems fallback) | Always show free wait time |
| Season start | Circuit Pass showcase | Once per season |
| Visiting a cool HQ | "Get this theme" button on their decor | Only for buyable items |

## Pricing notes
- Anchor: R$ 99 ≈ cheapest "real" item. Keep 3 price points per category (low, mid, premium).
- Gem pack bonus: +10% at 550, +20% at 1,200, +25% at 3,000.
- Show only the currency an item is sold for. Don't show a Gem price and a Robux price side by side; it confuses players.

## Metrics
Track per item: views, prompt shown, purchases, refunds. Kill or rework items with < 0.2% conversion of viewers after 2 weeks. See [[Analytics & Metrics]].

## UI screens
- [[Screen - Store]]

## Open questions
- Ship the subscription at launch or after the Season Pass proves itself? Lean after.
- Server Hype product: cap how many can stack in a server (suggest max 3 active).

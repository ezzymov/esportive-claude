---
tags: [feature]
status: idea
priority: P1
stage: 4
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Daily Loops & Quests]]"
  - "[[Balance Tables]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Sponsors]]"
roblox_execution_environment: ServerScriptService
---
# Sponsors & Merch

## Summary
Sponsors are mid-game "contracts with goals". They pay weekly cash, put their logo on your jersey, and give the player a reason to chase specific objectives. Merch turns fan count into passive income.

## Sponsor tiers (fictional brands)
| Tier | Unlock (Followers) | Example brands | Weekly pay | Slots |
|---|---|---|---|---|
| Local | 1k | Byte Burger, Corner Comics, Pixel Pizza | $2k–5k | 1 |
| Energy | 10k | VoltRush, ZapFuel, Hyperdrip | $15k–40k | 2 |
| Hardware | 50k | NovaCore, Vektor, Pulse Audio | $100k–250k + parts | 3 |
| Global Tech | 500k | Orbitron, Nexa Systems, Skyline Mobile | $1M+ + exclusive skins | 4 |

## Contract structure
- **Duration:** 1–4 in-game weeks (1 in-game week ≈ 1 real day, see [[Matches & Tournaments]] seasons).
- **Objectives:** 1–3 per contract. Examples: win 3 matches, upload 2 clips, reach 50k followers, finish top 4, wear the sponsor jersey in a final.
- **Payout:** base weekly pay + completion bonus (50% of total base).
- **Jersey patch:** sponsor logo added to the sponsor slot of the jersey automatically.
- **Exclusivity:** two brands from the same category (e.g. two energy drinks) cannot be signed together.
- **Cancel:** you can drop a contract early; penalty = 1 week of pay and −5% Fame gain for 24 h.

## Offer flow
1. Offers arrive in the **Inbox** when thresholds are hit (toast + phone ring SFX).
2. Each offer shows brand, pay, objectives, duration, and a "negotiate" button.
3. **Negotiate** minigame: pick 1 of 3 tones (Humble / Confident / Bold). Bold = +30% pay but 40% chance the brand walks away. Manager staff improves odds.
4. Accept → contract card appears in Sponsors screen with progress bars.

## Merch store

**Look:** a real esports merch shop, not a generic storefront. Think ESL / DreamHack / team webstores: a hero banner with the title's identity (game logo, team colors), "Shop by category" section headers in a bold skewed label, product cards in a clean grid with a hoodie / jersey / collectible mix, and a top nav split into All Products · New · Teams · Gaming · Collectibles · Sale.

![[ESL-Shop_Merch_counter-strike-hero.png]]
*Reference: ESL Shop (Counter-Strike collection). Copy the layout and category structure, not the brand assets.*
- Opens at Stage 6. Sells your team jersey to simulated fans.
- `MerchIncome/min = Followers × 0.002 × JerseyRarityMult × (1 + sponsorCount × 0.1)`
- Limited drops: design a jersey variant, "drop" it for 1 h for 3× merch income (cooldown 12 h).

## Rules & numbers
- Max active contracts = tier slot count (stacks: Local 1 + Energy 2 ...) capped at 6.
- Sponsor reputation stat: completing contracts raises it, cancelling lowers it. Higher reputation = better offers.

## Server / data requirements
- `Profile.Sponsors = { Active = {{Id, StartedAt, Progress = {}}}, Reputation = 0, Inbox = {} }`
- Brand definitions in `Shared/Config/Sponsors.lua`.
- Objectives use the shared quest-objective engine from [[Daily Loops & Quests]].

## UI screens
- [[Screen - Sponsors]]

## Edge cases / exploit risks
- Objectives must be counted server-side from real events (match result, clip upload), never client claims.
- Offline time counts toward duration but not objectives.

## Acceptance criteria
- [ ] First Local sponsor offer arrives at 1k Followers with tutorial arrow
- [ ] Jersey shows sponsor patch within 1 s of signing
- [ ] Completing all objectives pays bonus and logs to Inbox

## Open questions
- Should real-player teams compete for the same limited sponsor (bidding)? Probably P3.

---
tags: [feature, new]
status: idea
priority: P2
stage: 7
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Security & Anti-Exploit]]"
  - "[[Services & Remotes]]"
  - "[[Data Schema]]"
affected_ui: []
roblox_execution_environment: ServerScriptService
---
# Transfer Market

## Summary
A player-driven market for player cards and parts. It gives extra value to duplicates and lets veterans sell surplus to newer players. Big cash sink via tax.

> Skins have their own player-run markets, one per game title: [[Skin Marketplace]]. This note covers player cards and parts.

## Modes
1. **AI transfer list** (Stage 5): buy/sell with AI clubs at fixed values. Always available, no other players needed.
2. **Global market** (Stage 7): list items for other real players, cross-server via MemoryStore.
3. **Direct trade** (Stage 4): in-server trade window, see [[Social & Multiplayer]].

## Pricing
- Every card has a **Base Value** from rarity + OVR + Potential.
- Listing price allowed range: 50%–300% of Base Value (stops wash-trading and scams).
- **Tax: 10%** of sale price destroyed (sink).
- Listings last 24 h; unsold items return to inventory.

## Rules
- Trade lock: named Mythic stars have a 7-day hold before they can be listed (other items 24 h after being received in a trade). Full rules in [[Trading System]].
- Account must be ≥ 3 days old, Stage 7 for global market.
- Max 10 active listings.
- Robux-purchased items can be traded only if Roblox policy allows; default to **untradeable** for paid-crate drops.

## Server / data requirements
- MemoryStoreSortedMap per item category; DataStore for escrow.
- Escrow pattern: item removed from seller profile on listing, held in escrow store, delivered on purchase, returned on expiry. Every step logged.

## Edge cases / exploit risks
- Duplication: atomic escrow with `UpdateAsync` + idempotency key per transaction.
- Seller leaves mid-sale: cash credited on next join via pending payouts.

## Acceptance criteria
- [ ] Listing, buying, expiry all leave exactly one copy of the item in the system
- [ ] Tax correctly removed

## Open questions
- Is a global market worth the exploit risk at launch? Recommend AI list at launch, global post-launch.

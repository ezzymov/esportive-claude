---
tags: [feature]
status: building
priority: P0
stage: 1
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Balance Tables]]"
  - "[[Economy Design]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Main HUD]]"
roblox_execution_environment: ServerScriptService
---
# Plot & HQ

## Summary
The player's plot is the physical heart of the game. It starts as a dusty garage and grows, room by room, into a stadium campus. Every purchase is a classic Roblox tycoon **buy pad** (step on it, pay, the build tweens in). The HQ is also the "show-off" pillar: friends visit it and see your trophies, rigs and banners.

## HQ eras (visual evolution)
Full look per era (exterior, floor plans, props, lighting, sound, region skins): [[HQ Era Visual Guide]].
| Era | Stage | Footprint | Look | Signature build |
|---|---|---|---|---|
| Garage | 1 | 1 room | Concrete floor, fold tables, single bulb, posters | Starter PC |
| Café Corner | 2 | +café annex | Rented LAN café row, neon OPEN sign | Tech Shop counter |
| Training Center | 3–4 | Wing | Glass practice room, analyst wall | Training pods |
| Gaming House | 5 | 2 floors | Lounge, kitchen, dorm beds, LED strips | Bootcamp Dorms |
| Studio Campus | 6–7 | Multi-building | Streaming booth, merch store, trophy hall | Streaming Booth |
| Arena | 8–10 | Stadium | Bleachers, jumbotron, stage, pyro | Main Stage |

Each era swap is a **cinematic**: camera pulls back, old shell dissolves, new one builds in with sparks and a caster line ("From a garage to a gaming house. They're for real now.").

## Rooms
| Room | Unlock | Function |
|---|---|---|
| Practice Floor | 1 | Stations (income + player stats) |
| Tech Shop | 2 | Buy/equip PC parts, see [[PC Setups]] |
| Case Vault | 2 | Case opening stage, see [[Case Unboxing]] |
| Training Center | 3 | Stat training queues, see [[Staff & Training]] |
| Trophy Hall | 3 (shelf) / 7 (hall) | Displays trophies; visitors can "like" it |
| Clip Studio | 4 | Clip editor + Replay Theater, see [[Clips & Traction]] |
| Staff Offices | 5 | Hire/assign staff |
| Bootcamp Dorms | 5 | Fatigue recovers 2× faster |
| Streaming Booth | 6 | Passive followers while online |
| Merch Store | 6 | Passive cash from jersey sales, see [[Sponsors]] |
| Academy Wing | 7 | Youth prospects, see [[Academy & Youth]] |
| Arena | 8 | Spectator crowd, home-field bonus, see [[Fan Base & Arena]] |

## Buy pad rules
- Pads appear in a fixed **build order** per room (dependency chain), max 3 visible at once to avoid clutter.
- Pad shows icon, name, price, and a green glow when affordable. Unaffordable pads are greyed with a progress ring showing % of price you have.
- Pressing a pad you can't afford shows "Need $X more" plus an estimated time at current income.
- Each pad purchase gives +1 "HQ Level". HQ Level gates some decor and is a leaderboard stat.
- **Auto-buy** toggle (gamepass or Stage 6 perk): buys the cheapest pad automatically.

### Stage 1 (Garage) pads — built in M1 (2026-10-23)
Pads unlock in a chain; each one shows only when its `Requires` pads are owned **and** its `Unlock` condition passes (`Shared/Config/Pads`). The server re-checks pad visibility after every gameplay event.
| Pad | Price | Shows when | Builds |
|---|---|---|---|
| Better Mouse | $150 | First Pickup Game won | Clikk Basic mouse on the Founder card (+1 Aim gear) |
| 2nd Desk (card table) | $300 | Better Mouse owned | Station 2 with a "HIRING" sign; unlocks the free-agent board |
| 3rd Desk (door on sawhorses) | $500 | 2nd Desk owned + first hire | Station 3; seats any benched player |
- **Station tier upgrades are not in Stage 1.** The M0 test pad (Station Upgrade 2 for $100 → $2.5/s) broke Stage 1 pacing; station tiers move to the Tech Shop in Stage 2.
- Station income is paid straight to Cash in M1; the Cash Collector (coffee can) is decoration until the collector mechanic is built.

### Stage 2 (Café Corner) — built in M2 (2026-10-23)
The café annex builds in on promotion to Stage 2, as its own building next to the garage ([[HQ Era Visual Guide]] → *2. Café Corner*): Tech Shop counter, Reaction Test cabinet, case vault, and two café PC pads.
| Pad | Price | Shows when | Builds |
|---|---|---|---|
| Café PC 4 | $1,500 | 3rd Desk owned + Stage 2 | Station 4 |
| Café PC 5 | $2,000 | Café PC 4 owned | Station 5 (the active five = desks 1–5) |
- Station income tiers are bought in the Tech Shop: up to tier 3 at Stage 2, tier 4 at Stage 3 (`TechShop.MaxStationTier`).
- Stage 3 adds the trophy shelf on the garage back wall (one cup per trophy, newest 8).

## Decor & customization
- Free-place decor mode (grid snap 1 stud, rotate 90°) for posters, plants, LED strips, neon signs, team banners.
- Decor gives small Fame-per-visit bonus (cap +10%) so it stays cosmetic-first.
- Team colors from [[Team Identity]] auto-tint banners, carpets and LED strips.

## Rules & numbers
- Pad price curve: `PadPrice(n) = 50 × 1.35^n` inside an era; first pad of a new era ≈ 3× last pad of the previous one.
- Station income collected into a **Cash Collector** at the plot entrance (classic tycoon). Manager staff or Auto-Collect gamepass collects automatically.
- Plot persists across sessions; rebuilt from profile on join (target < 3 s build time, stream in rooms nearest the spawn first).

## Server / data requirements
- `Profile.HQ = { Era, PadsBought = {[padId]=true}, Decor = {{Id, CFrame}}, HQLevel }`
- Pads defined in `Shared/Config/Pads.lua` with `{Id, Room, Price, Requires, Builds}`.
- Server validates purchase: pad exists, prereqs met, cash ≥ price, not already owned.

## UI screens
- [[Screen - Main HUD]] (objective pointer to next pad)
- Decor mode toolbar (new screen, later)

## Edge cases / exploit risks
- Player spams pad touch: debounce per player per pad (0.5 s).
- Plot assignment on full servers: 6 plots per server, assign on join, release on leave.
- Rebirth resets pads but keeps decor items in inventory.

## Acceptance criteria
- [ ] New player sees exactly one glowing pad on spawn
- [ ] Buying a pad tweens the build in < 1 s with SFX
- [ ] Rejoin restores all bought pads and decor
- [ ] Era upgrade cinematic plays once, skippable

## Open questions
- Shared HQ district (visible neighbors) vs private plots? See [[Game Pitch]] open questions. → Proposed: shared ring of 6 plots, 256 × 256 studs each, see [[World Layout & Presentation]].

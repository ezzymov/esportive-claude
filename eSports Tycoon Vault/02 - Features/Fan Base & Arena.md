---
tags: [feature, new]
status: idea
priority: P2
stage: 6
system_type: Economy
engine_layer: ServerService
dependencies:
  - "[[Economy Design]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Main HUD]]"
roblox_execution_environment: ServerScriptService
---
# Fan Base & Arena

## Summary
Followers are a number; fans are something you can **see**. Fans show up as NPC crowds in your HQ and Arena, chant your team name, wear your jersey, and give a home-field bonus.

## Fan tiers
| Followers | Visual |
|---|---|
| 0–1k | A couple of fans peek through the garage door |
| 1k–10k | Small crowd outside the café, holding signs |
| 10k–100k | Fan queue at the Gaming House, jersey-wearing NPCs |
| 100k–1M | Bleachers fill at home matches, chants |
| 1M+ | Full Arena, pyro, mascot, flag wave |

NPC count is capped per device (mobile ≤ 40 NPCs, use impostor billboards beyond that).

## Arena (Stage 8)
- Host home matches: your team plays on the Main Stage, crowd scales with Followers.
- **Home-field bonus**: +2% to +8% Team Power based on crowd fill %.
- **Ticket income** per home match: `Tickets = Seats × fillRate × ticketPrice`. Player sets price (Low / Mid / High); high price lowers fill rate.
- **Stadium upgrades:** jumbotron, pyro, light show, mascot, VIP boxes, concessions (each +income or +fill).

## Fan engagement
- **Fan mail**: daily message with a small gift (Cash, Gems, decor) from a random fan.
- **Chant builder**: pick 3 chant words (preset list) that fans shout on wins.
- **Mascot**: unlock and customize a team mascot (cosmetic, appears at matches).
- **Fan Hype meter**: wins/clips raise it, losses lower it. Full hype = 15 min 1.5× merch + tickets.

## Server / data requirements
- `Profile.Arena = {Upgrades = {}, TicketPrice = "Mid", Chant = {}, Mascot = {}}`, `Profile.Hype`
- Crowd rendered client-side only from Followers value.

## Acceptance criteria
- [ ] Crowd size visibly changes at each Followers tier
- [ ] Home matches apply home-field bonus shown in pre-match screen

## Open questions
- Let other real players sit in your Arena as spectators? Yes in P3 with Worlds Live.

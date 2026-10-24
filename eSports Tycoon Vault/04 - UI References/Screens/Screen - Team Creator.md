---
tags: [ui]
screen: Team Creator
status: building
---
# Screen - Team Creator

## Purpose
Name the team, make a logo and jersey. First creative moment of the FTUE (see [[Team Identity]]).

## Opened from / closes to
Auto-opens right after the [[Intro Cutscene]] (~0:50). Also has a **Founder role** picker (Entry / Support / Sniper / Strategist / Flex) for your own player card ([[Founder (You)]]). Opens pre-filled with an auto-name (one tap to accept). Later from Settings → Team: rename is free until Stage 2, then costs a small Robux price. Closes to HQ with banner reveal.

## Layout
Fullscreen modal, two columns (stacked on mobile):
- **Left (preview):** rotating avatar wearing jersey (ViewportFrame), logo badge above, team name in big letters.
- **Right (controls), tabbed:** Name · Logo · Jersey.
  - Name tab: TextBox (max 20 chars) + 🎲 Randomize, Tag box (3–4 chars, auto-filled from name).
  - Logo tab: shape grid (6), icon grid (24), primary/secondary color swatches (12 presets + hue slider later).
  - Jersey tab: pattern grid, sleeve style, number field, nickname toggle. Garment grid (locked by HQ Level), color slots (Body/Print/Trim/Accent) with swatches + free picker, Home/Away/Alt toggle. Full spec: [[Jersey Progression]].
- Bottom: big **Confirm** button (primary), disabled until name passes filter.

## States
- Filtering: spinner on Confirm while server filters.
- Rejected name: red outline + "That name isn't allowed. Try another or randomize."
- Locked items: padlock overlay + "Unlock in cases".

## Animations / sounds
Avatar slow rotate 20°/s; Randomize dice shake; Confirm triggers banner drop in HQ + crowd cheer.

## References
More context: [[Reference Board - Simulator UI]].
| Image | Source | What to copy |
|---|---|---|
| ![[StudGUI_Auras_grid-plus-preview-panel.webp]] | Stud GUI pack | Jersey pattern/garment picker: grid + preview, locked garments show their unlock instead of "???" |

## Data it reads / remotes it calls
`Team/SetIdentity(name, tag, logo, jersey)` RF → returns filtered name or error.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Team { Name, Tag, LogoId, Colors, Jersey }` | Pre-filled fields and preview (auto-name on first open) |
| Profile | `Stage` | Rename is free before Stage 2, then a Robux product |
| Profile | `Inventory.Cosmetics` | Padlock on locked logo / jersey items |
| Profile | Founder card in `Roster` (`Role`) | Founder role picker default |
| Config | Name generator lists `[Adjective] [Noun]` ([[Team Identity]]), logo shapes/icons, jersey patterns, `Theme.lua` colours | Grids, swatches, Randomize |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| 🎲 Randomize | none | — | — | Local generator |
| Confirm | ⚠ `Team/SetIdentity` | RF | name, tag, logo, jersey, ⚠ founderRole | filtered name or error |
| Rename after Stage 2 | `MarketplaceService:PromptProductPurchase` | — | rename productId | grant via `ProcessReceipt` |

### State Validation
- Name is 1–20 characters after trimming. Tag is 3–4 characters, `A–Z0–9` only.
- The chosen logo and jersey items are unlocked (in `Inventory.Cosmetics` or the free set).
- The founder role is one of Entry / Support / Sniper / Strategist / Flex.
- Disable Confirm and show a spinner while the RF is pending. **Never filter text on the client.** The server runs `TextService:FilterStringAsync`; show "That name isn't allowed…" on error.

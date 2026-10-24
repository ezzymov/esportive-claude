---
tags: [ui]
screen: Settings & Odds
status: building
---
# Screen - Settings & Odds

## Purpose
Player settings and the transparency page (odds and rules).

## Layout
- Tabs: Settings · Odds & Rules · Codes · Credits.
- **Settings:** Music / SFX / Caster volume sliders, caster frequency (Off/Low/Normal), Calm mode (no life events), Graphics (Low/Auto/High particles), Show my avatar in jersey, Reduced motion (shorter reveals, no screen shake), Colorblind rarity icons, Furry variants (Show / Show as human, local display only).
- **Odds & Rules:** every case with full rarity odds and pity rules; furry variant chance (4%) and species odds ([[Furry Variants]]); how matches are decided (plain-language summary); trade tax; offline income cap.
- **Codes:** text box + Redeem, list of redeemed codes.

## References
More context: [[Reference Board - Simulator UI]].
| Image | Source | What to copy |
|---|---|---|
| ![[Enz0s_Settings_toggle-rows.webp]] | UI designer showcase | One big row per setting, pill toggle right (green on / red off), disabled rows faded. Volume rows use a slider in the same row |

## Data it reads / remotes it calls
Reads/writes `Settings`. Calls `Code/Redeem(code)`.

## Data & Signal Bindings
> Profile paths come from the client's read-only mirror, which `Remotes/State/Delta` keeps current ([[Services & Remotes]] → State sync). Type names (`Profile`, `PlayerCard`, …) match [[Data Schema]] and will live in `ReplicatedStorage.Shared.Types`. ⚠ marks a field or remote that this screen needs but that [[Data Schema]] or [[Services & Remotes]] doesn't define yet.
> Client checks are UX only: they grey out buttons and avoid wasted calls. The server re-validates everything ([[Security & Anti-Exploit]]).

### Inputs Required
| Source | Field / type | Drives |
|---|---|---|
| Profile | `Settings { MusicVol, SfxVol, CasterVol, CasterFreq, CalmMode, Graphics, AvatarInJersey, ReducedMotion, ColorblindIcons, FurryDisplay }` | Settings tab controls |
| Profile | ⚠ `RedeemedCodes` | Redeemed codes list |
| Config | `Cases.lua`, `Furry.lua`, trade tax and offline income cap ([[Balance Tables]], [[Economy Design]]) | Odds & Rules tab |

### Player Actions & Remotes
| Control | Remote | Type | Args | Returns |
|---|---|---|---|---|
| Any setting change | ⚠ `Settings/Set` | RE | key, value | state delta |
| Redeem | `Code/Redeem` | RF | code | reward or error |

### State Validation
- The key is in the allowed settings list. Each value is in range (volumes 0–1) or one of its enum options (CasterFreq Off/Low/Normal; Graphics Low/Auto/High).
- `FurryDisplay` is local-only display, so apply it right away. Saving it is optional.
- Throttle `Settings/Set` while a slider is being dragged; send once on release.
- **Code:** trim it, uppercase it, check it's not empty, and check it's not already in `RedeemedCodes`.

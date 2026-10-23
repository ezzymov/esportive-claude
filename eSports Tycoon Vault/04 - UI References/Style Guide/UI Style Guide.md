# UI Style Guide

## Mood
Neon-night esports arena: dark navy panels, bright accent glows, chunky rounded buttons, crisp numbers.

## Palette (proposal — edit freely)
| Role | Hex |
|---|---|
| Background panel | `#0F1426` |
| Panel raised | `#1A2140` |
| Primary accent (cyan) | `#22D3EE` |
| Secondary accent (magenta) | `#E040FB` |
| Success | `#34D399` |
| Warning | `#FBBF24` |
| Danger | `#F87171` |
| Text primary | `#F8FAFC` |
| Text muted | `#94A3B8` |

## Rarity colors
Common `#9CA3AF` · Uncommon `#4ADE80` · Rare `#3B82F6` · Epic `#A855F7` · Legendary `#F59E0B` · Mythic `#EF4444` → shimmering gradient

## Typography (Roblox fonts)
Headings: GothamBlack / Bangers-style chunky · Body: GothamMedium · Numbers: GothamBold. Use UIStroke on text over busy backgrounds.

## Components
Buttons (primary / secondary / disabled / pressed), currency pill, progress bar, card frame (per rarity), tab bar, modal, toast, tooltip, confirm dialog. Define states and tween timings (hover 0.1s, press 0.08s, panel open 0.25s Back easing).

## Sound
UI click, buy (cha-ching), error, rarity reveal stings (one per tier), crowd roar, caster stinger.

## Handoff to Claude
Describe each component with sizes and anchor points in the screen note; Claude builds them with Instances via Studio MCP. Keep a `Theme` ModuleScript mirroring this table.

---

## Spacing & sizing scale
Base unit 4 px. Use only: 4 · 8 · 12 · 16 · 24 · 32 · 48.
| Token | Value | Use |
|---|---|---|
| Corner radius S | 8 px (`UICorner` 0, 8) | chips, pills |
| Corner radius M | 12 px | cards, buttons |
| Corner radius L | 20 px | panels, modals |
| Stroke | 2 px `UIStroke`, accent at 40% transparency | panel edges |
| Panel padding | 16 px (mobile 12) | inside panels |
| Touch target min | 44×44 px | all buttons |

## Type scale (at 1080p, `UIScale` handles the rest)
| Style | Font | Size | Use |
|---|---|---|---|
| Display | GothamBlack | 48 | Victory, rarity reveal |
| H1 | GothamBlack | 32 | Panel titles |
| H2 | GothamBold | 24 | Section headers |
| Body | GothamMedium | 18 | Text |
| Caption | GothamMedium | 14 | Labels, timers |
| Number | GothamBold | 20–40 | Currency, OVR |

## Component specs
| Component | Size | States | Notes |
|---|---|---|---|
| Primary button | h 56, min w 160 | default / hover (brighten 10%) / pressed (scale 0.95) / disabled (40% opacity, grey) | Cyan fill, dark text |
| Secondary button | h 48 | same | Raised panel fill, cyan stroke |
| Danger button | h 48 | same | Danger fill; always paired with confirm |
| Currency pill | h 40 | idle / gain pulse / spend pulse | Icon left, number right, "+" button for Gems → Store |
| Rail button | 64×64 (mobile 52) | idle / badge / locked | Icon + label below on desktop |
| Player card | 140×190 | normal / selected / training / fatigued | Rarity frame, OVR top-left |
| Progress bar | h 12 | fill tween 0.3 s | Rounded, gradient from accent |
| Toast | w 360, h 64 | in / hold 3 s / out | Slides from top, max 2 |
| Modal | 60% screen (mobile 95%) | open 0.25 s Back / close 0.15 s | Dim backdrop 50% black; ✕ top-right |
| Tooltip | auto | — | Long-press on mobile |

## Rarity frames (colorblind-safe)
Each rarity has a color **and** a shape cue:
Common plain frame · Uncommon single notch · Rare double notch · Epic corner gems · Legendary wings · Mythic animated gradient + crown.

## Textures
### Stud pattern (panel background)
![[Roblox_Texture_stud-tile.png]]

A repeating stud tile (raised rounded square with an L-shaped shadow) used as a **background on large panels only**, the way the Shop body and Build a PC panels use it. It makes big empty areas feel physical and toy-like.

| Rule | Value |
|---|---|
| Where | Panel body behind content (Shop, Store, Roster, Settings). Never behind text or numbers |
| Opacity | 8–12% over `Panel` (`#1A2140`), so it reads as texture, not a pattern on top of the content |
| Tile size | 32 px at 1080p (scales with `UIScale`). Use `ImageLabel` with `TileSize` |
| Tint | Neutral only. The raw tile is white/grey; tint it to the panel color rather than adding a second colored pattern |
| Reduced motion | Static. Never animate the texture |
| Mobile | Keep, but cut opacity to 6% to keep contrast for text |

Asset: `Style Guide/Roblox_Texture_stud-tile.png`. Upload the tile and add its asset ID to `Theme.lua` as `Textures.Stud`.

## Motion rules
- Everything tweens; nothing pops in instantly.
- UI tweens ≤ 0.3 s. Reveal cinematics ≤ 6 s, always skippable.
- Reduced motion setting: halve durations, remove screen shake and camera bobs.

## Iconography
Flat, thick outline (3 px), two-tone (white + accent). One icon set for currencies, roles, part slots, stats. Store icon sources in `Icons & Assets/` with uploaded asset IDs in `Theme.lua`.

## Theme module sketch
```lua
-- ReplicatedStorage/Shared/Config/Theme.lua
return {
  Colors = { Bg = Color3.fromHex("0F1426"), Panel = Color3.fromHex("1A2140"), Accent = Color3.fromHex("22D3EE"), Accent2 = Color3.fromHex("E040FB") },
  Rarity = { Common = "9CA3AF", Uncommon = "4ADE80", Rare = "3B82F6", Epic = "A855F7", Legendary = "F59E0B", Mythic = "EF4444" },
  Radius = { S = 8, M = 12, L = 20 },
  Tween = { Hover = 0.1, Press = 0.08, Open = 0.25 },
}
```

See also [[Art & Audio Direction]].

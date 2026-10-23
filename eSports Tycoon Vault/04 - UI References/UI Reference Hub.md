# UI Reference Hub

Everything visual. Drop screenshots into the matching subfolder (drag into Obsidian, or paste with Cmd+V and move to the right folder).

## Folder map
| Folder | Put here |
|---|---|
| `Screenshots - Roblox Games` | HUD, shop, inventory, tycoon button/pad UI from top Roblox games |
| `Screenshots - Gacha & Case Opening` | Case-open sequences, rarity cards, odds panels (CS-style crates, mobile gacha, Roblox case games) |
| `Screenshots - Esports & Broadcast` | Tournament brackets, scoreboards, caster overlays, team/player cards, FIFA/Football Manager style rosters |
| `Mockups - Ours` | Our wireframes/Figma exports/Excalidraw boards, one per screen, versioned `v1`, `v2` |
| `Icons & Assets` | Currency icons, rarity frames, part icons, logos (source + exported PNG IDs) |
| `Style Guide` | Colors, fonts, spacing, button states, see [[UI Style Guide]] |

## Reference boards
- [[Reference Board - Simulator UI]]: shops, settings, grid + preview pickers, tab pills (7 refs)

## Naming screenshots
`<source>_<screen>_<what-I-like>.png` → `Bloxburg_Shop_clean-grid.png`, `CSGO_CaseOpen_scroll-reel.png`

## Screen checklist
Full screen specs live in `04 - UI References/Screens/`. Tick a box when references + our mockup are attached.
Each screen gets a note from [[UI Reference Template]] so Claude can read the requirements:

- [ ] [[Screen - Start]]
- [ ] [[Screen - Starter Letter]]
- [ ] [[Screen - Shop]]
- [ ] [[Screen - Main HUD]]
- [ ] [[Screen - Team Creator]]
- [ ] [[Screen - Roster]]
- [ ] [[Screen - Tech Shop]]
- [ ] [[Screen - Case Opening]]
- [ ] [[Screen - Match HUD]]
- [ ] [[Screen - Bracket]]
- [ ] [[Screen - Clip Feed]]
- [ ] [[Screen - Sponsors]]
- [ ] [[Screen - Staff & Training]]
- [ ] [[Screen - Quests]]
- [ ] [[Screen - Settings & Odds]]
- [ ] [[Screen - Rebirth]]
- [ ] [[Screen - Store]]
- [ ] [[Screen - Trade]]
- [ ] [[Screen - Sticker Editor]]

## Roblox UI constraints (design for these)
- **Mobile first:** >half of players are on phones. Min touch target ≈ 44×44 px, keep thumbs-zone for primary buttons.
- Respect **safe area / top bar** (Roblox top-left menu buttons, ~36 px reserved).
- Use `UIScale`, `UIAspectRatioConstraint`, `UIListLayout`/`UIGridLayout`; avoid hardcoded pixel positions.
- One main panel open at a time; always an obvious ✕.
- Max readable text ≈ 14–16 px on mobile; keep numbers abbreviated (1.2K, 3.4M).
- Contrast on rarity colors; colorblind-safe rarity also uses frame shapes/icons.

## Inspiration prompts (search ideas)
Roblox: tycoon/simulator HUDs with currency bars, side button rail · Gacha: pack opening, pity bar, rarity glow · Sports management: FM/FIFA squad screens, card collections · Esports: LoL/Valorant bracket and scoreboard styling, caster lower-thirds · Streaming apps: clip feed, like/follow UI.

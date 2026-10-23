---
tags: [vision, design]
---
# Art & Audio Direction

Visual and audio identity for the whole game. UI specifics live in [[UI Style Guide]].

## One-line look
"Neon esports night": stylized, chunky, readable shapes lit by cyan/magenta glow, warm practical lights in early stages that get bigger and flashier as you climb.

## World art
- **Style:** stylized low-poly with smooth materials (SmoothPlastic, Neon, Glass). No realistic textures. Rounded bevels on furniture.
- **Scale:** slightly oversized props (monitors, trophies) so they read on phones.
- **Lighting:** `Future` lighting. Each HQ era has its own Lighting preset:
  - Garage: warm tungsten bulb, dusty atmosphere, low saturation
  - Café: neon signs, pink/cyan rim light
  - Gaming House: LED strips in team colors, cozy
  - Arena: dark venue, spotlights, beams, high contrast
- **Color story:** stages 1–3 warm and humble; 4–7 team colors take over; 8–10 full spectacle with gold accents.
- **Team colors** tint banners, carpets, LED strips, jerseys, case beams of your own drops.

## Characters
- Roster players are R15 NPC rigs wearing your jersey, with headset and idle animations (typing, stretching, celebrating, tilting).
- Station animations by state: idle, practicing (fast typing), winning (fist pump), losing (head in hands).
- Player's own avatar wears the team jersey when in HQ (toggle in Settings).

## VFX
| Moment | Effect |
|---|---|
| Pad purchase | Build-in tween + spark burst |
| Income collect | Coin fountain into collector |
| Case reveal | Rarity-colored beam, particles, screen flash for Legendary+, confetti for Mythic |
| Match win | Confetti cannons in team colors, trophy shine |
| Clip goes viral | Floating view counter, hearts |
| Era upgrade | Camera pull-back, dissolve, rebuild |

Keep particle counts low on mobile (respect `GraphicsQualityLevel`).

## Camera
- Default Roblox third-person in HQ.
- Cinematic cameras (case reveal, match, era upgrade) use `CameraType.Scriptable` with tween paths, max 6 s, always skippable.

## Audio direction
- **Music:** upbeat synthwave/electronic. Garage lo-fi beat → café chillwave → Arena big-room EDM. Separate menu, match and case-open tracks. Use licensed Roblox audio library only.
- **SFX palette:** clicky mechanical keyboards, mouse clicks, PC fan hum, crowd roar, cash register, case shake rattle, rarity stings rising in pitch per tier.
- **Voice:** casters (see [[Caster & Commentary]]), text-first, voice optional.
- **Mix:** UI SFX −6 dB under music peaks; mute toggles for Music / SFX / Casters separately.

## Reference boards
Drop images in `04 - UI References/Screenshots - Esports & Broadcast` and `Mockups - Ours`. See [[UI Reference Hub]].

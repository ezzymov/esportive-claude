---
tags: [feature]
status: idea
priority: P1
stage: 5
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Skill Levels & Ratings]]"
  - "[[Balance Tables]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Staff & Training]]"
roblox_execution_environment: ServerScriptService
---
# Staff & Training

## Summary
Staff are non-playing hires that give passive multipliers and automation. Training turns time and cash into player stat growth. Together they form the mid-game "depth" layer.

## Staff roles
| Role | Effect (per staff level 1–5) | Unlock |
|---|---|---|
| Coach | +3% Team Power per level; unlocks tactics | 5 |
| Analyst | Reveals opponent weak role; +2% win chance vs scouted teams | 5 |
| Manager | Auto-collect cash; +1 h offline cap per level (max +4 h) | 5 |
| Physio | −10% fatigue gain per level | 5 |
| Scout | +1 free agent rarity roll per level; reveals Potential | 5 |
| Social Media Manager | +8% clip views per level | 5 |
| Chef | +morale regen in Gaming House | 6 |
| Caster Relations | Better commentary lines, +Fame from wins | 7 |

- Staff come from hiring board (cash), case drops (Staff cards), or Event rewards.
- Staff have rarity like players. Higher rarity = higher max level and a unique perk (e.g. Legendary Coach "Mastermind": +1 tactic slot).
- Staff salary paid weekly like players.

## Tactics (Coach)
Pick one pre-match tactic: **Aggressive** (+Aim weight, −Consistency), **Defensive** (+Consistency, −Clutch), **Teamplay** (+Teamwork weight), **Star Focus** (best player stats ×1.15, others ×0.95). Tactics counter each other in a light rock-paper-scissors table so the Analyst's scouting matters.

## Training Center
- Queue slots: 1 at Stage 3, +1 per Training Center upgrade (max 5).
- Pick player + stat + duration (15 min / 1 h / 4 h).
- XP gain: `XP = baseXP(duration) × coachMult × (1 + Potential/200) × moraleMult`
- Stat level-up curve: `XPToNext(stat) = 20 × 1.08^stat`. Stats cap at Potential.
- Training adds Fatigue: 15 min = +5, 1 h = +15, 4 h = +40. Fatigue > 70 = −10% stats in matches.
- Skip timer with a [[Time Skip Tickets|Time Skip Ticket]] (15 min / 1 h / 4 h), or Gems as fallback: `ceil(minutesLeft / 10)` Gems.

## Bootcamp
Stage 5+: send whole roster to a 2 h bootcamp. +chemistry, +small all-stat XP, costs cash, roster unavailable for matches.

## Server / data requirements
- `Profile.Staff = {[id] = {Role, Rarity, Level, Perk, Salary}}`, `Profile.Training = {{PlayerId, Stat, EndsAt}}`
- Timers stored as absolute server time (`os.time()`), resolved on join.

## UI screens
- [[Screen - Staff & Training]]

## Edge cases / exploit risks
- Clock manipulation: only server `os.time()` used.
- Releasing a player mid-training refunds 0 and clears the slot.

## Acceptance criteria
- [ ] Training a stat for 15 min raises it visibly on the card
- [ ] Coach level changes Team Power shown in pre-match screen
- [ ] Manager auto-collect works while player is AFK

## Open questions
- Should staff have morale too? Lean no (keeps it simple).

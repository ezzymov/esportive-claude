# Economy Design

## Faucets (sources)
Station passive income · match prize money · minigames · sponsors (weekly) · merch · clip ad revenue · quests · offline earnings

## Sinks
Hiring/transfer fees · salaries (weekly) · cases · parts · facility buttons · training · staff · rename/reroll · transfer tax (10%)

## Starter formulas (tune in spreadsheet)
```
StationIncome/s   = base × tierMult × (1 + avgPlayerOvr/100) × chemistry
Price(tier n)     = basePrice × 2.5^n
PlayerOvr         = weighted avg of stats by role
WeeklySalary      = Ovr^1.8 × 2
FameGain(match)   = base × (opponentPower / yourPower) clamp 0.5–2
ClipViews/hr      = quality × trendMult × (1 + log10(followers+1))
OfflineIncome     = min(4h, elapsed) × 0.5 × income/s
Pity: Epic every 10 opens, Legendary every 50, Mythic every 300
```

## Sanity checks
- A new player should never be unable to progress because wages > income.
- Keep Gems rate ≈ 1 case/day free for a daily player.
- Track inflation: tune sinks every update; log average cash at each stage.

Value tables: [[Balance Tables]]. Match math: [[Match Simulation]].

Spreadsheet: put in `Attachments/Economy.xlsx` and link here.

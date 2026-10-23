---
tags: [system]
---
# Analytics & Metrics

Use Roblox `AnalyticsService` (funnels, economy, custom events) plus the Creator Dashboard.

## Funnels
**FTUE funnel** (from [[Stage 1 - Garage Squad]]): Join → Intro finished/skipped → Team named → Power On → First Pickup Game win → First Tech Fix → 2nd desk → First hire → First unbox → Stage 2.
**Stage funnel:** reach each Stage 1–10.
**Monetization funnel:** Store opened → item viewed → prompt shown → purchase.

## Economy events
Log every source and sink with `LogEconomyEvent` (currency, amount, balance after, item SKU). Watch Cash and Gems flow per stage.

## Custom events
| Event | Fields |
|---|---|
| CaseOpened | caseId, rarity, pityTriggered |
| MatchFinished | type, win, powerDiff, skipped |
| ClipUploaded | moment, quality, tagMatched |
| SponsorSigned | brandId, tier |
| Rebirth | count, LP, timeInRun |
| TutorialStepSkipped | step |

## Targets (launch)
| Metric | Target |
|---|---|
| D1 retention | ≥ 25% |
| D7 retention | ≥ 8% |
| Avg session | 20–40 min |
| Reach first unbox | ≥ 70% |
| Reach Stage 2 | ≥ 50% |
| Payer conversion | 1.5–3% |
| Match skip rate | < 60% (else matches too long) |

## Review cadence
Weekly: funnels + economy inflation. After each update: compare 3 days before vs after.

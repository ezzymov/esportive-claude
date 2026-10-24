---
tags: [system]
---
# Analytics & Metrics

Use Roblox `AnalyticsService` (funnels, economy, custom events) plus the Creator Dashboard.

## Funnels
**FTUE funnel** (from [[Stage 1 - Garage Squad]]): Join → Intro finished/skipped → Team named → Power On → First Pickup Game win → First Tech Fix → 2nd desk → First hire → First unbox → Stage 2.
- **As built (M1, 2026-10-23):** `LogOnboardingFunnelStepEvent`, one step per tutorial beat. Step numbers are fixed once live: 1 Join · 2 IntroDone · 3 TeamNamed · 4 PowerOn · 5 SitDesk · 6 FirstPickupWin · 7 AimTrainer · 8 FirstTechFix · 9 FirstUpgrade · 10 SecondDesk · 11 FirstHire · 12 TeamPugWin · 13 FirstUnbox · 14 ThirdDesk · 15 Stage2. Each step is logged once per profile, with its play-time second saved in `Ftue.Funnel`.
- Stage 1 success metrics map to: finish/skip intro = step 2, win first Pickup Game = 6, first hire = 11, first unbox = 13, Stage 2 = 15.

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
| IntroStarted / IntroSkipped / IntroFinished | value = second reached, replay |
| TutorialStepStarted / TutorialStepCompleted | step (value = step index / seconds on the step) |
| TutorialStallHint | step (value = level 1 hint, 2 call) |
| PlayerHired | key, rarity, discount (value = price) |
| RustyDiscount | value = play seconds when the 12-min guardrail fired |
| AimTrainerRun / TechFixDone | pay, seconds (value = hits / pay) |
| StageReached | value = stage |
| Suspicious events (`rate_limited`, `bad_remote_args`, `aim_score_cap`, `setup_too_fast`, `techfix_too_fast`, `pad_too_far`…) | detail |
- Economy events: every `Transact` logs `LogEconomyEvent` except the per-second income tick, which is summed into one event per minute.

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

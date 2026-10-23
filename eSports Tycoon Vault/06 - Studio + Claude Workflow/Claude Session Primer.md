# Claude Session Primer

Paste (or point Claude at this note) at the start of each Studio session.

## Project
Roblox esports management tycoon. Design source of truth: this Obsidian vault at `eSports Tycoon Vault/`. Read `[[Home]]`, the relevant `02 - Features` note, `03 - Progression/Progression Guide.md`, and `05 - Systems & Data/Data Schema.md` before coding.

## Rules for Claude
1. Server-authoritative logic; validate all remotes.
2. Config-driven content in ModuleScripts under `ReplicatedStorage/Shared`.
3. Build UI to the screen notes and `UI Style Guide`; mobile-first, UIScale, no hardcoded positions.
4. Fictional brands only. Filter all user text with TextService.
5. Small, testable steps; after each change tell me how to test in Studio (Play Solo / 2-player test).
6. Update the feature note's `status:` and add a line to the Roadmap sprint log when done.

## Workflow loop
1. Pick one item in [[Roadmap]] → 2. Claude reads the feature note → 3. Claude proposes a plan → 4. builds scripts/instances in Studio → 5. test → 6. record decisions in notes.

## Tips
- Work vertical slices: *Stage 1 end-to-end first* (plot → hire → income → scrim → first case).
- Keep scripts small; one Service per feature.
- Version-control the place with Rojo + Git if possible; keep vault in the same repo or beside it.
- Screenshot Studio results into `04 - UI References/Mockups - Ours` for comparison against references.

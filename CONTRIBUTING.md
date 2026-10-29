# Contributing to Cosmic Crystals

The official source of truth is [FoxyLight/Cosmic-Crystals](https://github.com/FoxyLight/Cosmic-Crystals). This is an early Godot 4.7.2 GDScript project, not yet a production Android release.

## Before working

Read:
1. [README](README.md) for current state and local run commands.
2. [Game design](docs/GAME_DESIGN.md) for rules and player experience.
3. [Milestone register](docs/MILESTONES.md) for priorities and issue references.
4. [Technical architecture](docs/TECHNICAL_ARCHITECTURE.md) and [Decision log](docs/DECISIONS.md).
5. [QA plan](docs/QA_TEST_PLAN.md) for acceptance requirements.

Select an open milestone task and explain intended impact. Avoid broad refactors unrelated to the issue and don't implement deferred post-MVP scope without an explicit decision.

## Development workflow

- Branch from latest `main`; use descriptive names such as `feat/m1-turn-animations`, `fix/invalid-swap`, `docs/qa-matrix`.
- Use Godot **4.7.2 standard edition**, GDScript and Compatibility renderer unless [ADR-001](docs/DECISIONS.md) is revised.
- Keep deterministic puzzle rules separate from rendering, animations, input and Godot scene nodes.
- Add a seeded regression test for any rules bug; don't depend on wall-clock animation timing for game correctness.
- Keep credentials, keystores, user data, export binaries, and proprietary assets out of Git.
- Clearly distinguish tested functionality from proposed functionality in code comments and PRs.
- Submit a PR with linked GitHub issue, description, test evidence, platform notes and remaining gaps.
- Don't mark a milestone done until its documented exit gate has evidence.

## Run and test

Open `project.godot` in Godot 4.7.2 and run with F5.

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_board.gd
godot --headless --path . --quit-after 120
```

CI runs these commands. Android and web exports require additional environment setup described in [ANDROID_EXPORT.md](docs/ANDROID_EXPORT.md) and real-device/browser checks. CI green alone is not evidence of Play-ready binaries.

## Documentation and project tracking

- Put player-facing rule changes in the game design.
- Put state/architecture changes in technical architecture and decision log.
- Put scope/dependency changes in the milestone register and relevant GitHub tracking issue.
- Update [PROJECT_STATUS.md](docs/PROJECT_STATUS.md) when a milestone state changes.
- Add validation evidence to [QA_TEST_PLAN.md](docs/QA_TEST_PLAN.md) or milestone issue comments.
- Use the [release plan](docs/RELEASE_PLAN.md) before any store distribution work.

**Licensing:** No application source-code license has been formally selected in this repository. Do not assume the Godot engine's MIT license automatically licenses game code, artwork, music or contributions. Record and verify asset rights before integrating external media.

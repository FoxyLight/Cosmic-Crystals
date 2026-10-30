# Contributing to Cosmic Crystals

The official source of truth is [FoxyLight/Cosmic-Crystals](https://github.com/FoxyLight/Cosmic-Crystals). This is an **Android-only**, five-level Godot 4.7.2 GDScript project, currently product **0.5.1** with M3 user acceptance and M4 human acceptance pending. It is not a production Google Play release.

## Before working

Read:
1. [README](README.md) for current state and local run commands.
2. [Game design](docs/GAME_DESIGN.md) for rules and player experience.
3. [Milestone register](docs/MILESTONES.md) for priorities and issue references.
4. [Technical architecture](docs/TECHNICAL_ARCHITECTURE.md) and [Decision log](docs/DECISIONS.md).
5. [QA plan](docs/QA_TEST_PLAN.md) for acceptance requirements.

Select an open milestone task and explain intended impact. Avoid broad refactors unrelated to the issue and don't implement deferred post-MVP scope without an explicit decision.

## Development workflow

- Branch from latest `main`; use descriptive names such as `feat/m4-accessibility`, `fix/beam-orientation`, `docs/android-qa`.
- Use Godot **4.7.2 standard edition**, GDScript and Compatibility renderer. [ADR-006](docs/DECISIONS.md) makes Android the sole supported product. Desktop/headless Godot is a test environment, not a shipping target.
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

Android CI runs **15 Godot suites, nine Python tests, a headless performance benchmark and an Android debug APK export** with real manifest/signature/pin/asset/checksum checks and disposable-emulator same-key update preservation. See [ANDROID_EXPORT.md](docs/ANDROID_EXPORT.md). There is **no Web job or browser QA**. CI green is not evidence of physical-device M4 acceptance or a Play-ready signed AAB. On the owner's test phone, 10801 → 11001 installed with matching debug identity and a byte-identical save; do not uninstall a different-key legacy app to imitate this result.

## Documentation and project tracking

- Put player-facing rule changes in the game design.
- Put state/architecture changes in technical architecture and decision log.
- Put scope/dependency changes in the milestone register and relevant GitHub tracking issue.
- Update [PROJECT_STATUS.md](docs/PROJECT_STATUS.md) when a milestone state changes.
- Add validation evidence to [QA_TEST_PLAN.md](docs/QA_TEST_PLAN.md) or milestone issue comments. Record exact APK versionCode/versionName, signer mode, build URL and whether results are headless, emulator, or the owner's actual phone. Never invent hardware metrics or claim a human playtest without feedback.
- Use the [release plan](docs/RELEASE_PLAN.md) before any store distribution work. Never commit a private signing identity or overwrite/delete earned progression without authorization. Full product/documentation status is in the [current audit](docs/ANDROID_DOCS_AUDIT_2026_10_30.md).

**Licensing:** No application source-code license has been formally selected in this repository. Do not assume the Godot engine's MIT license automatically licenses game code, artwork, music or contributions. Record and verify asset rights before integrating external media.

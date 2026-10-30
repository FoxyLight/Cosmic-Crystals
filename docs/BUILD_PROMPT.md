# Current AI Development Prompt: Cosmic Crystals (Android Only)

**Updated:** 2026-10-30. **Current source:** product `0.5.2`, Godot `4.7.2` GDScript, Compatibility renderer. This document replaces the original 2026-10-29 cross-platform/build-from-scratch prompt. Consult Git history for that historical prompt. Do **not** add Web/HTML5, browser tests, desktop distribution or iOS development.

Use this brief with a coding agent that can inspect and modify the connected repository **[FoxyLight/Cosmic-Crystals](https://github.com/FoxyLight/Cosmic-Crystals)** and run its Android-relevant tests.

## First, verify the live state

1. Read [PROJECT_STATUS.md](PROJECT_STATUS.md), [MILESTONES.md](MILESTONES.md), [ROADMAP.md](ROADMAP.md), [GAME_DESIGN.md](GAME_DESIGN.md), [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md), [ANDROID_VERSIONING.md](ANDROID_VERSIONING.md), [QA_TEST_PLAN.md](QA_TEST_PLAN.md), [RELEASE_PLAN.md](RELEASE_PLAN.md), [DECISIONS.md](DECISIONS.md) and latest main CI/issue #8.
2. Confirm the *current* `main` commit and `VERSION` instead of relying on examples in this prompt. Preserve the already implemented five-level Lyra journey, saved unlocks/best-star ratings, M1/M2 special interactions, asteroids and all regression tests.
3. Confirm the **Android-only** scope in the workflow: `check` and `android-debug-export` only. Headless/desktop Godot is allowed **as a development/test host**. Do not generate or test Web/iOS deliverables.
4. Distinguish implemented source, local/headless or emulator tests, and user-confirmed physical Android playtests. A green CI run and installed APK do not establish human M4 acceptance.

## Proven baseline (review actual main before editing)

- **M3 #7 is closed:** the player reported a passing five-level Android campaign/relaunch playtest. Five JSON-authored stages, game sessions, home/map/results, star thresholds and schema-1 local saves are implemented.
- **M4 #8 implementation is complete and the player's Android playtest has PASSED:** original audio (17 effects, five music loops), cached players, volume/mute preferences, comfort/reduced-motion and larger-text settings, Android focus/background behavior, visual effects, UI caching and bounded performance diagnostics are implemented. Full measured Android audio-focus, accessibility and performance validation belongs to M5; an overall M4 human playtest PASS was reported on 2026-10-30.
- **Version 0.5.1 / PR #34:** four-match Star Beam direction follows the initiating **swap axis**: left/right → row/horizontal, up/down → column/vertical. The 53-case Beam gesture/scene suite passes; established power formation precedence and stored powers are preserved.
- **Main CI #110:** both Android-only jobs passed, including **15 Godot suites, nine Python tests**, real APK manifest/signature/pinned certificate, bundled assets, SHA-256, and an isolated Android-emulator same-key save-preserving upgrade.
- **APK #110:** versionName `0.5.1-dev.110.1+g7864c820`, versionCode `11001`, [Actions artifact](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426/artifacts/12988237867). GitHub M4 #8 records an **actual Android phone update 10801 → 11001 with byte-identical save data**. This is separate save-integrity evidence; the player **subsequently reported M4 playtest PASS** on 2026-10-30.
- **Debug signing:** main CI has a configured private stable debug keystore/password and public certificate pin. Pull requests use ephemeral signers. Never expose keys, recover private key from GitHub secrets or claim the stable signer is production signing.
- **Legacy signatures:** old 9801 and other differently signed APKs cannot be updated by the new key. Never uninstall/clear a progress-bearing phone without fresh explicit permission, validated backup, and a safely tested migration plan.
- **Release boundary:** no production signed AAB, Google Play track, browser distribution, cloud accounts, monetization or levels 6–20.

## Engineering approach

- Use a feature branch and focused pull request. Reuse `board.gd` / `cosmic_board.gd` (pure deterministic rules), `game_session.gd`, `level_catalog.gd`, `progress_store.gd`, `prototype.gd`, `game_hud.gd`, `campaign_view.gd`, `settings_view.gd`, `game_audio.gd` and `performance_monitor.gd` as appropriate.
- Preserve immutable event snapshots, move/input-lock ordering, replay/last-move victory, blocker-safe falls, no-color inventory reshuffle and schema-1 progress compatibility. Do not invent new gameplay mechanics without an owner request.
- Run all `tests/test_*.gd` under the strict Godot error-log guard, the headless `tests/benchmark_android.gd`, and `python3 -m unittest discover -s tests -p "test_android*.py" -v`. Confirm import and full playable scene.
- Require successful `check` and `android-debug-export`, uniquely versioned Android APK, `build-info.json`, `SHA256SUMS.txt`, embedded manifest verification, matching pinned stable debug signer on **main**, and the isolated emulator update/save test. Main CI's signing mode must be inspected, not assumed.
- Do not downgrade, uninstall or replace an installed Android app simply to test a new APK. Record exact build/commit/device/evidence and get permission before any potentially destructive phone operation.
- Do not claim measured FPS/PSS/thermal, production release readiness, screen-reader accessibility or human listening quality without observed test evidence.

## Next development priorities

1. **M4 completed, now advance M5:** the player accepted the M4 Android audio/comfort/visual/Beam-direction experience overall. Record this in [M4 acceptance](ANDROID_M4_PLAYTEST_2026_10_30.md). For M5, measure sound/headphone levels, hardware media/call interruptions, reduced-motion/system scaling, heavy-effects sessions, exact device/OS, FPS/p95/RAM/PSS/thermals and screen-reader limitations. Do not count unreported item-by-item tests as passed.
2. **M5 Android release candidate:** multi-device tests, measured sustained FPS/p95/RAM/PSS, process death/restart, interruption handling, save compatibility, long-session stability and severity-tracked bugs. No browser/device matrix outside Android.
3. **M6 (separately authorized):** private production/upload signing, signed release AAB, Play internal testing, store/data-safety policies and publication decision. Do not equate debug APK export with Play distribution.

## Delivery requirements

Update the affected project design/technical architecture, QA, status, roadmap, milestones, release notes and issue tracking alongside source changes. Report exactly which behaviors were implemented and verified, the PR/merged commit, CI run, APK `versionName`/`versionCode`/filename/checksum/signing mode, outstanding human-device acceptance and safe installation guidance.

**Do the work, not just a plan.** Merge only after required Android CI passes. Stop rather than risk erasing the player's earned progress.

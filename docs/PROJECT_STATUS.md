# Current Project Status

**Snapshot date:** 2026-10-29  
**Canonical repository:** https://github.com/FoxyLight/Cosmic-Crystals  
**Primary milestone register:** [MILESTONES.md](MILESTONES.md)  
**Status rule:** evidence before checkmarks; dates below are snapshot dates rather than delivery commitments.

## Android playtest sign-off: player-reported PASS (2026-10-29)

The player confirms **“Human playtest passes”** after the Star Beam/combo/Nova fixes, accidental restart correction, and versioned APK rollout. This is evidence of a successful **practical Android gameplay smoke test**. It does **not** establish that every combo/performance/interruption case was individually tested or independently measure the device. The immediately recommended artifact was [v0.2.0-dev.82.1](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40958771036), but its installation was not verified over ADB.

The [Android Playtest Report](ANDROID_PLAYTEST_2026_10_29.md) records the pass, the exact evidence boundary, and the remaining M0/M1/M2 requirements. The reported gameplay reset issue and power audit may be accepted at smoke-test level; full milestone gates remain open.

**Next gameplay priority:** Android acceptance of the new asteroid slice and
power/Nova balance. Debug signing persistence and full device/web QA remain
parallel infrastructure tasks. M3 progression has not started.

## Executive summary

**New M2 slice, product `0.3.0`:** asteroid occupancy/durability, adjacent and
power/Nova damage, one-hit-per-wave deduplication, segmented gravity/refill,
inventory-preserving blocked deadlocks and impact/crack/destruction rendering
are implemented. The prototype has six rocks and requires both 30 crystals and
all rocks within 18 moves. **861,090 new rules assertions and 46 real-scene
assertions pass locally**, with all existing suites retained. CI still produces
uniquely versioned APKs, verified manifests, checksums and Web exports. See
[M2 Asteroids](M2_ASTEROIDS.md) for evidence, limitations and the device checklist.
**M2 remains in progress:** new physical Android playtest, balance and broader
platform/performance acceptance are pending. The earlier player pass covers the
pre-blocker baseline. Historical sections below describe their earlier scope.

**Status: Godot M0/M1 implementation underway; headless rules tests and automated web/debug-APK exports pass, but device/browser QA and Android release distribution remain unproven.**

- **Engine direction:** Godot 4.7.2 standard edition, GDScript, Compatibility renderer. Accepted for continued development, subject to M0 platform sign-off.
- **Completed foundation:** source project, procedural board, deterministic initial boards, swap validation, horizontal/vertical matches, gravity/refill, cascades, basic objectives, and initial automated tests.
- **CI evidence:** [main branch passing workflow](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40935869782) imported Godot, ran `tests/test_board.gd`, and completed a 120-frame headless scene smoke test.
- **Verified in PR #13 CI:** Web and Android debug APK artifacts generated, expanded event replay tests and 120-frame scene smoke test passed ([workflow](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40939726043)).
- **Unverified:** device/browser runtime compatibility and measurements, AAB Gradle/release signing, Play distribution, physical-device input and thermal behavior.
- **M1 in progress:** ordered turn events and swap/clear/drop animations are implemented and an Android human gameplay smoke passes; last-move/interruption tests, prolonged device sessions and production UI are still pending.
- **M4 visual accessibility patch (PR #14):** player feedback identified Solar Amber/white Lunar Opal confusion on Android. New warm/icy fills, dark per-kind outlines and unique geometric silhouettes are implemented with a separate headless visual regression test. The player subsequently tested the updated Android build and confirmed it **looks a lot better** (positive qualitative follow-up, 2026-10-29). Controlled brightness/grayscale checks, broader readability tests and M4 production visual/art/audio acceptance remain open; M4 is not complete. See [Visual Identity](VISUAL_PALETTE.md).
- **M2 first playable slice (PR #16):** Star Beams (row/column), Cosmic Bomb, Supernova, first-pass special combinations, chargeable Nova meter, zero-move targeted Nova Pulse and cancel targeting are coded and headlessly tested. Android gameplay feel/energy balance remain unverified. See [M2 gameplay guide](M2_SPECIALS_NOVA.md).
- **Missing product systems:** asteroid blockers, five complete levels, star map, local saving, tutorials, production audio and release flows.

## Latest bug fix: M2 Star Beam failure

**Player feedback:** Four matching gems did not produce a visible Star Beam on the initial M2 Android preview.

**Root cause confirmed in the initial GitHub Actions logs:** `scripts/prototype.gd` failed to parse because two lines contained literal `\\t` sequences. Godot logged a script error but exited successfully; the old workflow incorrectly passed and exported an APK. [Bug #17](https://github.com/FoxyLight/Cosmic-Crystals/issues/17) and [PR #18](https://github.com/FoxyLight/Cosmic-Crystals/pull/18) track the corrective work.

The patch fixes indentation, adds a real gameplay-scene four-match regression test, makes Star Beam's icon/forging message more obvious, configures the missing provisional `assets/icon.svg` for Android export, and strengthens CI to fail on engine errors. Automated checks are required; **Android phone confirmation is still outstanding**. See [M2 guide](M2_SPECIALS_NOVA.md) and [QA plan](QA_TEST_PLAN.md). M2 remains open.

## M2 special-combination audit (2026-10-29)

The previous GDScript scene-load defect was shared across all power mechanics. A follow-up [combination audit (#19)](https://github.com/FoxyLight/Cosmic-Crystals/issues/19) now covers all 16 ordered special-pair types over six swap positions/orientations, plus an independently checked Nova chain. The new real-scene integration test also covers row/column Beam, Bomb and Supernova formation, Beam+Bomb swap, and Nova targeting/cancellation.

**Confirmed separate UI bug:** An unaffected special crystal temporarily lost its overlay while another group cleared. The rendering path now retains the correct power marker. Android visual verification is still needed. See [M2 mechanics](M2_SPECIALS_NOVA.md) and [QA plan](QA_TEST_PLAN.md). M2 is not closed.

## Board reset investigation and mitigation (2026-10-29)

A player reported repeated board resets after adding powerful M2 combos. The source reveals two distinct paths: **collecting 30 crystals triggers victory, and any subsequent tap used to restart the entire round**; separately, a deadlocked grid with no legal move was regenerated with brand-new random gems, which looks like a reset even when counters do not change.

[PR #22](https://github.com/FoxyLight/Cosmic-Crystals/pull/22) introduces an explicit **PLAY AGAIN** confirmation on the results overlay and a gem-inventory-preserving deadlock shuffle. [Issue #21](https://github.com/FoxyLight/Cosmic-Crystals/issues/21) tracks Android acceptance. The new seeded regression suite covers replay touch targeting and preserved colors/charge. **A human device retest is still pending.**

This does not change the temporary 30-crystal goal or add multi-level progression. If Android loses the application process completely, persistent progress remains an M3 feature rather than a solved reset cause.

## Android APK versioning safeguard (2026-10-29)

[PR #24](https://github.com/FoxyLight/Cosmic-Crystals/pull/24) implements automatic CI version stamping. Each APK gets a distinct numeric `versionCode`, human-readable `0.2.0-dev.<run>.<attempt>+g<sha>` version name and matching filename. Every artifact carries a Git commit/run build manifest and a SHA-256 checksum. Android `aapt` must confirm the values are truly inside the APK, and the version generator has unit tests.

The optional persistent debug keystore integration is **not enabled merely by merging code**: a maintainer must privately configure the `COSMIC_DEBUG_KEYSTORE_BASE64` repository secret. Until then, the build metadata explicitly says `ephemeral-ci` and the temporary signing key can prevent installing over older builds despite increasing version codes. M0/M6 release AAB signing and real device validation remain open. See [APK Versioning](ANDROID_VERSIONING.md).

## Milestone rollup

| Workstream | Tracking issue | Status |
| --- | --- | --- |
| Engine export/device validation (M0) | [#4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4) | In progress, blocking production sign-off |
| Animated core and resolution (M1) | [#3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3) | In progress |
| Special pieces, blockers and Nova (M2) | [#6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6) | In progress: core powers/Nova implemented; asteroid blockers and phone QA pending |
| Five levels, map and saves (M3) | [#7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7) | Not started |
| Mobile UX, art and audio (M4) | [#8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) | Contrast improvement in progress; full M4 still open |
| End-to-end QA and release candidate (M5) | [#9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) | Not started |
| Google Play release (M6) | [#10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10) | Not started |
| Expanded content and iOS exploration (M7) | [#11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11) | Deferred |

## Recommended next execution order

1. **M0:** Use the now repeatable CI APK/Web exports for actual device/browser playtests. Establish an AAB Gradle signing pipeline and record the Godot go/no-go.
2. **M1:** Event stream and basic animations are implemented in PR #13; test interaction timing on devices and add last-move/interruption regression coverage.
3. **M2:** Core powers, Nova and asteroid blockers are coded and tested; next verify this new slice on Android and tune balance. See [M2 Asteroids](M2_ASTEROIDS.md).
4. **M3–M4:** Build and polish the complete five-level Lyra journey.
5. **M5–M6:** Test, sign and distribute once exit gates are met.

For the exact changes and artifact instructions, see [M0/M1 implementation notes](M0_M1_IMPLEMENTATION.md).

## Open decisions and risks

- Physical Android and browser runtime compatibility remain **unknown**, despite successful automated exports. See [ENGINE_EVALUATION.md](ENGINE_EVALUATION.md).
- Commercial SDK needs (billing/ads/analytics) are **not decided**; validate before promising a release feature.
- The five-level initial release is the committed **scope target**; the 20-level concept belongs to M7.
- Performance goals are provisional until target hardware is selected. See [QA_TEST_PLAN.md](QA_TEST_PLAN.md).
- No real milestone delivery dates, staffing or costs have been committed.

## Updating this status

This is a snapshot, not a realtime dashboard. Whenever any milestone passes, a release gate changes, or an important decision is made, update this document in the same PR as the supporting evidence. GitHub issue checklists are the authoritative granular work tracker.

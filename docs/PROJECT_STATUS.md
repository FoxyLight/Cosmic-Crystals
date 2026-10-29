# Current Project Status

**Snapshot date:** 2026-10-29  
**Canonical repository:** https://github.com/FoxyLight/Cosmic-Crystals  
**Primary milestone register:** [MILESTONES.md](MILESTONES.md)  
**Status rule:** evidence before checkmarks; dates below are snapshot dates rather than delivery commitments.

## Executive summary

**Status: Godot M0/M1 implementation underway; headless rules tests and automated web/debug-APK exports pass, but device/browser QA and Android release distribution remain unproven.**

- **Engine direction:** Godot 4.7.2 standard edition, GDScript, Compatibility renderer. Accepted for continued development, subject to M0 platform sign-off.
- **Completed foundation:** source project, procedural board, deterministic initial boards, swap validation, horizontal/vertical matches, gravity/refill, cascades, basic objectives, and initial automated tests.
- **CI evidence:** [main branch passing workflow](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40935869782) imported Godot, ran `tests/test_board.gd`, and completed a 120-frame headless scene smoke test.
- **Verified in PR #13 CI:** Web and Android debug APK artifacts generated, expanded event replay tests and 120-frame scene smoke test passed ([workflow](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40939726043)).
- **Unverified:** device/browser runtime compatibility and measurements, AAB Gradle/release signing, Play distribution, physical-device input and thermal behavior.
- **M1 in progress:** ordered turn events and basic swap/clear/drop animations are coded; manual device playtesting, last-move/interruption tests and production UI are pending.
- **M4 visual accessibility patch (PR #14):** player feedback identified Solar Amber/white Lunar Opal confusion on Android. New warm/icy fills, dark per-kind outlines and unique geometric silhouettes are implemented with a separate headless visual regression test. The player subsequently tested the updated Android build and confirmed it **looks a lot better** (positive qualitative follow-up, 2026-10-29). Controlled brightness/grayscale checks, broader readability tests and M4 production visual/art/audio acceptance remain open; M4 is not complete. See [Visual Identity](VISUAL_PALETTE.md).
- **M2 first playable slice (PR #16):** Star Beams (row/column), Cosmic Bomb, Supernova, first-pass special combinations, chargeable Nova meter, zero-move targeted Nova Pulse and cancel targeting are coded and headlessly tested. Android gameplay feel/energy balance remain unverified. See [M2 gameplay guide](M2_SPECIALS_NOVA.md).
- **Missing product systems:** asteroid blockers, five complete levels, star map, local saving, tutorials, production audio and release flows.

## Latest bug fix: M2 Star Beam failure

**Player feedback:** Four matching gems did not produce a visible Star Beam on the initial M2 Android preview.

**Root cause confirmed in the initial GitHub Actions logs:** `scripts/prototype.gd` failed to parse because two lines contained literal `\\t` sequences. Godot logged a script error but exited successfully; the old workflow incorrectly passed and exported an APK. [Bug #17](https://github.com/FoxyLight/Cosmic-Crystals/issues/17) and [PR #18](https://github.com/FoxyLight/Cosmic-Crystals/pull/18) track the corrective work.

The patch fixes indentation, adds a real gameplay-scene four-match regression test, makes Star Beam's icon/forging message more obvious, and strengthens CI to fail on engine errors. Automated checks are required; **Android phone confirmation is still outstanding**. See [M2 guide](M2_SPECIALS_NOVA.md) and [QA plan](QA_TEST_PLAN.md). M2 remains open.

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
3. **M2:** The core special pieces and targeted Nova are coded with deterministic tests; next verify phone play and implement asteroid blockers, power balance and stronger chain regression.
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

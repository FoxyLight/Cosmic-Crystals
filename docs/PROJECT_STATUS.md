# Current Project Status

**Snapshot date:** 2026-10-29  
**Canonical repository:** https://github.com/FoxyLight/Cosmic-Crystals  
**Primary milestone register:** [MILESTONES.md](MILESTONES.md)  
**Status rule:** evidence before checkmarks; dates below are snapshot dates rather than delivery commitments.

## Executive summary

**Status: early Godot technology spike; core matching proven headlessly, Android distribution not proven.**

- **Engine direction:** Godot 4.7.2 standard edition, GDScript, Compatibility renderer. Accepted for continued development, subject to M0 platform sign-off.
- **Completed foundation:** source project, procedural board, deterministic initial boards, swap validation, horizontal/vertical matches, gravity/refill, cascades, basic objectives, and initial automated tests.
- **CI evidence:** [main branch passing workflow](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40935869782) imported Godot, ran `tests/test_board.gd`, and completed a 120-frame headless scene smoke test.
- **Unverified:** actual Android APK/AAB export, browser export, physical-device performance, safe area and touch, heavy particle stress, signed Google Play delivery.
- **Missing product systems:** polished turn animations, special pieces, asteroids, Nova Pulse, five complete levels, star map, local saving, tutorials, audio and release flows.

## Milestone rollup

| Workstream | Tracking issue | Status |
| --- | --- | --- |
| Engine export/device validation (M0) | [#4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4) | In progress, blocking production sign-off |
| Animated core and resolution (M1) | [#3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3) | In progress |
| Special pieces, blockers and Nova (M2) | [#6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6) | Not started |
| Five levels, map and saves (M3) | [#7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7) | Not started |
| Mobile UX, art and audio (M4) | [#8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) | Not started |
| End-to-end QA and release candidate (M5) | [#9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) | Not started |
| Google Play release (M6) | [#10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10) | Not started |
| Expanded content and iOS exploration (M7) | [#11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11) | Deferred |

## Recommended next execution order

1. **M0:** Establish a repeatable APK/web export and get real device/browser observations. Record the Godot go/no-go.
2. **M1:** Refactor synchronous board resolution into ordered domain events, animate the event stream and make input locking robust.
3. **M2:** Implement the Star Beam/Bomb/Supernova/Nova progression on that stable event pipeline.
4. **M3–M4:** Build and polish the complete five-level Lyra journey.
5. **M5–M6:** Test, sign and distribute once exit gates are met.

## Open decisions and risks

- Physical Android and browser compatibility are **unknown**. See [ENGINE_EVALUATION.md](ENGINE_EVALUATION.md).
- Commercial SDK needs (billing/ads/analytics) are **not decided**; validate before promising a release feature.
- The five-level initial release is the committed **scope target**; the 20-level concept belongs to M7.
- Performance goals are provisional until target hardware is selected. See [QA_TEST_PLAN.md](QA_TEST_PLAN.md).
- No real milestone delivery dates, staffing or costs have been committed.

## Updating this status

This is a snapshot, not a realtime dashboard. Whenever any milestone passes, a release gate changes, or an important decision is made, update this document in the same PR as the supporting evidence. GitHub issue checklists are the authoritative granular work tracker.

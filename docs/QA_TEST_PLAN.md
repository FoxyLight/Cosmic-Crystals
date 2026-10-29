# QA, Test and Device Validation Plan

**Status:** Test strategy and acceptance gates, not a report of tests already run.  
**Snapshot:** 2026-10-29

## 1. Current automated coverage

The repository runs Godot headless import, `tests/test_board.gd`, the new `tests/test_visuals.gd` style assertions and a 120-frame scene smoke test in GitHub Actions, plus Android debug APK and Web export jobs.

**Evidence:** [original main branch run](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40935869782), plus [M0/M1 CI run with debug APK and Web artifacts](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40939726043) on PR #13.

The expanded seeded board test covers 125 seeds, no starting matches, adjacent legal swaps, illegal nonadjacent/adjacent swaps, match intersections, stable cascades, unique clears, event-snapshot replay, crystal counts and scores. This is **not** a full Android compatibility, performance, save-state, or cross-platform acceptance test.

## 2. Rules-level regression matrix

| Area | Required test case | Status |
| --- | --- | --- |
| Initial generation | No pre-existing match; at least one move over many seeds | Initial automated coverage |
| Input validation | Adjacent legal and illegal swaps, wrapping across row boundaries, same-tile taps | Automated swap/edge checks; manual gesture testing open |
| Matching | Horizontal/vertical 3+, intersection union and simultaneous multi-group | Intersection/seeded checks; expand simultaneous cases |
| Resolution | Gravity stability, refill, chain reactions, event playback invariants | Expanded automated replay/invariant checks |
| Move budget | Illegal swap spends 0; legal spends 1; last-move win overrides loss | Basic logic implemented; last-move regression pending |
| Deadlocks | No legal move reshuffles without deleting blockers/specials | Prototype-only reset; production logic missing |
| Special pieces | 4/5/T/L creation precedence; combined triggers; no double-count | First M2 rules coded and tested; phone balancing pending |
| Blockers | Adjacent matches vs special and Nova damage; durability rules | Not implemented |
| Nova Pulse | Charge, cancel, row/column, zero-move activation, reset | M2 rules + touch targeting implemented; manual cancellation/charge feel QA open |
| Progression | 5-level unlocks, stars, replay, terminal screens and save load | Not implemented |
| Persistence | Version migration, malformed/truncated save, app restart | Not implemented |
| Interruptions | Restart, pause, background while animation resolves | Not implemented |

**M2:** The new `tests/test_powers.gd` suite validates first-pass Star Beam, Supernova, Cosmic Bomb and special+special effects; tests chargeable Nova cost/target and no overlap double-counting. See [M2 gameplay guide](M2_SPECIALS_NOVA.md). Human phone checks remain open.

All domain-level tests should be deterministic (fixed seed, fixed starting board, known expected events) and independent of visual tween timing.

## Star Beam gameplay regression and CI parser gate

The first M2 APK had a **hidden scene-script parse error** despite green GitHub Actions. [Bug #17](https://github.com/FoxyLight/Cosmic-Crystals/issues/17) tracks the defect and Android retest.

- Automated: `tests/test_game_scene.gd` must instantiate the real gameplay scene and trigger a straight four-match through the UI controller path; the resulting CosmicBoard must retain a row Beam. Existing `tests/test_powers.gd` also verifies formation in pure rules.
- CI: `scripts/ci/check_godot_log.sh` fails on any Godot `SCRIPT ERROR`, `Parse Error`, or `ERROR:` marker, even if the process exits zero. Guard self-tests must pass.
- Manual Android: visually identify the cyan-ring Beam left after matching four; verify `STAR BEAM FORGED!` text, persistence through falling/refilling and full-row activation when later swapped. Repeat for vertical four/column Beam when convenient.
- Acceptance: successful Android-device repro with a verifiable new APK, not merely a successful export job. **Pending player retest.**

## 3. Crystal distinction / visual accessibility check

Following Android playtest feedback (2026-10-29), Solar Amber and Lunar Opal need explicit readability coverage. [Crystal Visual Identity](VISUAL_PALETTE.md) records the six piece colors/outlines, distinctive sunburst versus ice-shard geometry and exact visual tokens.

- **Automated:** run `godot --headless --path . --script res://tests/test_visuals.gd`; ensure palette/index invariants, warm/cool component separation, dark outlines and six unique contours pass. This is not a substitute for perception tests.
- **Manual Android:** compare Amber and Opal at normal and dim screen brightness, during static board play and fast swapping/cascades. Check all six types are distinguishable by shape and fill, including on smaller displays.
- **Pass condition:** testers can identify warm golden sun versus frosty blue-white shard without relying exclusively on hue. Record device, OS, brightness, result and screenshot if needed in [M4 issue #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8). **Pending physical-device confirmation.**

## 4. Android test matrix

Record at least:
- **One modest Android device:** document model, Android version, display dimensions and refresh rate.
- **One recent Android device:** same information; include a device with a display cutout if possible.
- **Android export identifiers:** debug/release, application ID, Godot version and Git commit SHA.

Run:

1. Fresh install and launch; collect cold-start time and visible errors.
2. Repeated drag/swipe and tap-two moves, invalid swaps, fast successive gestures. **M2:** make row/column Beams, Cosmic Bombs and Supernovas; swap powers and check chain scores; charge Nova, select a target, cancel it without cost and verify the row/column clears without using a move.
3. Check HUD and board at portrait size and on short/small screens.
4. Suspend/resume (Home, lock screen, notification/call interruption), audio focus, process termination and restore.
5. 30-second heavy cascade / future particle-effects scenario, with recorded FPS, RAM and heat observations.
6. Verify retry, back navigation, mute, reduced motion, settings and saved progress when those systems exist.
7. Produce and install a debug APK; verify signed AAB generation separately. Do not claim Google Play acceptance until validated in a Play test track.

**Provisional performance goal:** smooth 60 FPS where the device supports it, with no hangs/input loss and acceptable sustained play on modest hardware. Before M5 acceptance, establish recorded numerical floors for the selected test device classes; current hardware baselines are **unknown**.

**M2 on-phone result log:** record whether the Nova button is reachable, powers are distinguishable over each gem silhouette, blast effects remain understandable during cascades, and matches/charge/move cost track actual behavior. These checks are **not** counted as passed by CI.

## 5. Browser and iOS test matrix

- Desktop Chrome and Firefox: first load, WebGL2/WASM support, aspect ratios, pointer swapping, resize and accessibility.
- Android Chrome: touch, first load, background/resume, audio activation and memory.
- iOS Safari (if available): touch, startup, orientation, WebGL support and limitations. A browser test does **not** prove iOS native export.
- Use a server (not `file://`) for Godot HTML5 distribution, and record the specific export settings/build.

Browser runtime tests are **pending** despite successful CI Web export. A generated `.wasm`/HTML5 bundle does not establish browser usability.

## 6. Release-level acceptance

- All critical flows demonstrated end-to-end for five levels and one constellation.
- No open critical or high-severity defects.
- No unverified production claims about APK/AAB, web, saved progress or app-store distribution.
- All required platform builds have exact file/build version and test environment recorded.
- New gameplay and persistence features have deterministic or reproducible automated tests.
- Accessibility controls (silhouette, contrast, reduced motion, basic screen size and sound settings) verified.
- No signing keys, credentials or unrelated user data checked into the repository.

## 7. Issue hygiene / bug severity

Use GitHub issues with a reproduction script, exact commit/build, device/OS/browser, expected vs actual, screenshot/log if appropriate, and a clear severity.

- **Critical:** crash/data loss/security defect, hard blocker across target devices.
- **High:** unwinnable or corrupted gameplay, common gestures fail, release blocker.
- **Medium:** noncritical visual, balance or device-specific interaction defect with a workaround.
- **Low:** cosmetic issues with minimal impact.

Critical/high defects must be resolved before M5 closure. Lower severity may be explicitly accepted with evidence and an owner once ownership is assigned.

## 8. Evidence log template

For each validation, record:

| Field | Value |
| --- | --- |
| Date / tester | TBD |
| Commit SHA / build ID | Example automated artifact: [PR #13 run 40939726043](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40939726043); fill exact build SHA per manual test |
| Godot version | 4.7.2 target |
| Device / Android or browser version | TBD |
| Test case and steps | TBD |
| Expected / actual | TBD |
| FPS / RAM / size / startup (where applicable) | Not yet measured |
| Pass / fail / blocker / issue link | TBD |

Save measurements in the relevant GitHub milestone issue or linked QA artifact. Do not convert this template into a fictitious successful test report.

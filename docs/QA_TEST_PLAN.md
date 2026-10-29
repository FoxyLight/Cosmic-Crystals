# QA, Test and Device Validation Plan

**Status:** Test strategy and acceptance gates, not a report of tests already run.  
**Snapshot:** 2026-10-29

## 1. Current automated coverage

The repository currently runs `godot --headless --path . --editor --quit` and `godot --headless --path . --script res://tests/test_board.gd` plus a 120-frame scene smoke test in GitHub Actions.

**Evidence:** [successful main branch run](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40935869782).

The seeded board test exercises initial legal board generation, no starting matches, adjacent legal swaps, illegal nonadjacent swaps, match intersections, stable boards after cascades, crystal clear counts and score. This is **not** a full Android compatibility, performance, save-state, or cross-platform acceptance test.

## 2. Rules-level regression matrix

| Area | Required test case | Status |
| --- | --- | --- |
| Initial generation | No pre-existing match; at least one move over many seeds | Initial automated coverage |
| Input validation | Adjacent legal and illegal swaps, wrapping across row boundaries, same-tile taps | Partial automated; expand |
| Matching | Horizontal/vertical 3+, intersection union and simultaneous multi-group | Partial automated; expand |
| Resolution | Gravity stability, refill, chain reactions, no infinite cascade | Partial automated; expand |
| Move budget | Illegal swap spends 0; legal spends 1; last-move win overrides loss | Partial automated; add last-move test |
| Deadlocks | No legal move reshuffles without deleting blockers/specials | Prototype-only reset; production logic missing |
| Special pieces | 4/5/T/L creation precedence; combined triggers; no double-count | Not implemented |
| Blockers | Adjacent matches vs special and Nova damage; durability rules | Not implemented |
| Nova Pulse | Charge, cancel, row/column, zero-move activation, reset | Not implemented |
| Progression | 5-level unlocks, stars, replay, terminal screens and save load | Not implemented |
| Persistence | Version migration, malformed/truncated save, app restart | Not implemented |
| Interruptions | Restart, pause, background while animation resolves | Not implemented |

All domain-level tests should be deterministic (fixed seed, fixed starting board, known expected events) and independent of visual tween timing.

## 3. Android test matrix

Record at least:
- **One modest Android device:** document model, Android version, display dimensions and refresh rate.
- **One recent Android device:** same information; include a device with a display cutout if possible.
- **Android export identifiers:** debug/release, application ID, Godot version and Git commit SHA.

Run:

1. Fresh install and launch; collect cold-start time and visible errors.
2. Repeated drag/swipe and tap-two moves, invalid swaps, fast successive gestures.
3. Check HUD and board at portrait size and on short/small screens.
4. Suspend/resume (Home, lock screen, notification/call interruption), audio focus, process termination and restore.
5. 30-second heavy cascade / future particle-effects scenario, with recorded FPS, RAM and heat observations.
6. Verify retry, back navigation, mute, reduced motion, settings and saved progress when those systems exist.
7. Produce and install a debug APK; verify signed AAB generation separately. Do not claim Google Play acceptance until validated in a Play test track.

**Provisional performance goal:** smooth 60 FPS where the device supports it, with no hangs/input loss and acceptable sustained play on modest hardware. Before M5 acceptance, establish recorded numerical floors for the selected test device classes; current hardware baselines are **unknown**.

## 4. Browser and iOS test matrix

- Desktop Chrome and Firefox: first load, WebGL2/WASM support, aspect ratios, pointer swapping, resize and accessibility.
- Android Chrome: touch, first load, background/resume, audio activation and memory.
- iOS Safari (if available): touch, startup, orientation, WebGL support and limitations. A browser test does **not** prove iOS native export.
- Use a server (not `file://`) for Godot HTML5 distribution, and record the specific export settings/build.

Browser tests are **pending**, not assumed successful based on the headless workflow.

## 5. Release-level acceptance

- All critical flows demonstrated end-to-end for five levels and one constellation.
- No open critical or high-severity defects.
- No unverified production claims about APK/AAB, web, saved progress or app-store distribution.
- All required platform builds have exact file/build version and test environment recorded.
- New gameplay and persistence features have deterministic or reproducible automated tests.
- Accessibility controls (silhouette, contrast, reduced motion, basic screen size and sound settings) verified.
- No signing keys, credentials or unrelated user data checked into the repository.

## 6. Issue hygiene / bug severity

Use GitHub issues with a reproduction script, exact commit/build, device/OS/browser, expected vs actual, screenshot/log if appropriate, and a clear severity.

- **Critical:** crash/data loss/security defect, hard blocker across target devices.
- **High:** unwinnable or corrupted gameplay, common gestures fail, release blocker.
- **Medium:** noncritical visual, balance or device-specific interaction defect with a workaround.
- **Low:** cosmetic issues with minimal impact.

Critical/high defects must be resolved before M5 closure. Lower severity may be explicitly accepted with evidence and an owner once ownership is assigned.

## 7. Evidence log template

For each validation, record:

| Field | Value |
| --- | --- |
| Date / tester | TBD |
| Commit SHA / build ID | TBD |
| Godot version | 4.7.2 target |
| Device / Android or browser version | TBD |
| Test case and steps | TBD |
| Expected / actual | TBD |
| FPS / RAM / size / startup (where applicable) | Not yet measured |
| Pass / fail / blocker / issue link | TBD |

Save measurements in the relevant GitHub milestone issue or linked QA artifact. Do not convert this template into a fictitious successful test report.

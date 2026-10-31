# M5 Android Release Candidate QA

Review: 2026-10-31. Starting main **77eb492c6b6f04b0ce548339b1ee45f7723518db**, source **0.5.3**; candidate base **0.5.4**. Tracker [#9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) remains **open**. Exact ending commit, successful main run and APK metadata are attached to the PR and #9 delivery receipt. No Google Play/AAB distribution is included.

## Accepted baseline and scope

M3 #7, M4 #8 and settings #37 are closed/accepted. PRs #40/#41 text sizes and **Larger Text** label were approved on installed/read-back 0.5.3 build **12901**. Main run [129](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41128947462) passed; physical compatible upgrades 12501 → 12701 → 12901 retained exact saved bytes. This is baseline evidence, not a new 0.5.4 device pass.

Preserve all five levels, movement-axis Beams, combo rules, authored budgets, audio assets/mix, standard and Larger Text sizes, schema 1, package ID and stable private debug key. No redesign or extra content. Historical reports retain their dated evidence with explicit superseded-status banners.

## Audit and reproducible defects

| Finding | Severity / reproduction | Correction |
| --- | --- | --- |
| Cancelled board release acts as a completed gesture | Medium: native ScreenTouch down at 27 then cancelled release at 19 on level 2 begins a turn; a cancelled charged-Nova release can spend charge | Ignore cancelled primary touch, clear press/selection, retain Nova targeting and charge |
| Cancelled Settings release mutates preferences | Medium: down on a switch then cancelled up toggles it; cancelled slider up at the track end jumps volume | Release captured finger without applying cancellation coordinates or switch action; retain volume already deliberately dragged before cancellation |
| Settings finger survives interruptions / extra fingers reach GUI | Medium: capture a switch, focus out, send a new touch; or tap a second finger while the first owns the switch | Cancel capture on focus/pause, consume background touch events and secondary captured-touch events before Godot GUI can also toggle |

The initial new suite run on unmodified production source reproduced six failed assertions (toggle, slider, capture, background and cancelled board in both motion modes). While isolating fixes, the multi-finger test exposed the additional GUI fallthrough. An initial invalid unlock fixture was corrected to contain an actual completed first-level record; fixture failures are not reported as product defects. Final suite: **123 checks, zero failures**.

Native **Done** already works using real ScreenTouch events with mouse emulation off; no production workaround was added. Back closes Settings and cancels its captured touch. No verified defect was found in the audited existing reshuffle, power, blocker, scoring or persistence contracts; this is bounded automated evidence, not proof that every possible board is bug-free.

## Coverage and observed local results

- **16 Godot suites pass**, strict import/parser/runtime-log checking plus scene smoke. Existing all-five-level touch progression, 96 ordered power/orientation/edge scenarios, asteroid damage/segmented physics/chains, Nova, event continuity, Beam direction, no-reset shuffle, last-move victory, duplicate/stale outcome protection, backup recovery and future-schema read-only protection remain passing.
- New `test_android_rc.gd`: native Done repeated eight times and cancelled Done resets without closing; cancelled toggle/slider/board/Nova; finger ownership; focus/pause ordering and stale releases; Back; 40 repeated primary/secondary gestures per motion mode; navigation/restart guards while resolving; background freezes animation/totals; resume commits one move and waits at pause; duplicate outcome inert; persisted audio/mute/Larger Text through scene recreation. Uses isolated `user://tests` save paths and cleans up its own files.
- Existing Android polish **949** checks cover native three-slider drags, caption percentages, saved preferences, audio dispatch/limits, standard→Larger Text→standard, all five map/game/help/results at **320x568, 376x746, 800x1280, 1280x720**, and cutout/touch geometry. Other layout checks include safe Android rectangles and 48-unit action controls. No Android system-scale or TalkBack PASS is inferred.
- **13 Python tests pass** (four added): emulator-only guard rejects phone/missing targets before writes; all commands after selection bind to the verified emulator serial; install failure or changed save cannot publish a successful probe; exact audio/mute/Larger Text fixture survives the mocked upgrade flow. Real Android package-manager execution occurs separately in CI.
- Local Windows headless CPU benchmark: **20 loads, 132 turns, 500 events in 155.48 ms**, maximum model load **1.728 ms**, median **0.807 ms**, observed static memory **25,530,724 bytes**. This single run is not physical Android FPS, loading, RAM/PSS, thermals or audio hardware evidence. Existing bounded 600-frame runtime diagnostics remain available; no speculative performance optimization was introduced.

CI includes the new suite under the existing strict log guard. Android export verifies actual manifest/version, apksigner certificate and public pin, checksum, original audio/catalog/font licenses, then two separately exported same-key APKs on an isolated API-35 emulator with exact saved bytes preserved. The fixture now includes `large_text: true` alongside all audio preferences and earned records. Only the intended first APK is published; the higher-code upgrade probe is not.

## Signing, privacy and update safety

Package remains **org.foxylight.cosmiccrystals.prototype**. Main must report `persistent-secret`, `stable_signing_verified: true`, passed compatible-update probe, and public certificate SHA-256 **bb524f7e0b31b29118043206b481505d940cf0ea635f0fc68b978e88fe1a62b2**. PR builds are ephemeral previews; never use them to update the accepted phone app. [Maintenance/private backup/recovery](ANDROID_VERSIONING.md).

No private keys/passwords are committed or printed. Existing provenance lists 17 original effects/five ambient loops, plus both font OFL notices. Local progress stays in the application sandbox; no accounts/cloud/advertising SDK was added. The debug APK is not a production security/release certification. Actual exported manifest permissions and asset checks belong to the final artifact receipt; Play disclosures/production signing remain M6.

Before any physical update, verify installed package/certificate/version, take a validated read-only private save backup, use only a newer matching-key APK with an in-place update, then compare saved bytes and read back installed version. Never uninstall, clear or restore over progress. No new physical installation or destructive device action was performed by this stabilization audit.

## Focused human Android checklist (pending for 0.5.4)

Record exact candidate versionName/code, commit, device/model/OS and font/display scale. Mark each result and attach reproduction/severity for any failure.

1. Launch → Home → map; finish/replay all five levels, defeat/retry and final ending. Verify stars, scores, tutorial history and unlocks after restart; worse replay cannot erase records. Active unfinished boards are intentionally not autosaved.
2. Make four-matches with swipes and two taps in all directions. Test Beam/Beam, Beam/Bomb, Bomb/Bomb, Supernova/normal, Supernova/Beam, Supernova/Bomb, Supernova/Supernova; trigger chained powers through 1/2-HP rocks and Nova. Blast glyph and direction must agree.
3. Rapid taps, long swipes, two fingers, touch interrupted by Back/background/lock during swap/fall/clear/rock effects; no double move, phantom setting change or stuck board. Return to deliberate pause, resume once, then play normally.
4. Settings: drag all three volumes across 0/50/100; touch Done repeatedly, use Android Back, start a drag then background; toggle mute and Larger Text, reopen/restart. Sound must stop appropriately in background; test calls/media/headphones and repeated resume cycles on hardware.
5. Inspect both text sizes and reduced motion on compact phone and tablet, supported Android font/display scaling, cutouts/system navigation, dim brightness and grayscale. Goals/help/results/settings fit one screen. Audio-off play remains clear. TalkBack/nonvisual board support is a known limitation requiring explicit review, not an accepted accessibility claim.
6. With a privately backed-up earned save, install a newer same-key APK in place. Confirm exact save retention/read-back version, then relaunch and play. Never uninstall to bypass a signature error.
7. On modest and recent Android devices, record cold launch and level loads, input latency, sustained FPS/p95 frame time, RAM/PSS and thermals during **10+ minutes** with audio, repeated navigation, heavy powers/asteroid chains and **30 seconds** heavy cascades; repeat in reduced motion. Capture `performance-last.json` after backgrounding as supporting observed data, not the entire session or PSS. No numerical PASS thresholds are waived by green headless tests.
8. Exercise process death/relaunch using a disposable test copy or after safe backup; earned progress/settings recover, with no claim that an unfinished board resumes. Record crashes/ANRs with exact build and steps.

## Remaining gate and next step

Physical candidate playtest and quantified modest/recent-device performance, real audio-focus/lock/call behavior, system scaling/accessibility and long-session/process-death evidence remain **pending**. No open critical/high regression is demonstrated in this changed scope after automated checks; this is not full release clearance. Complete and record the device matrix in #9 before considering M5 closure. M6 production/upload signing, release AAB and Play testing require separate work.

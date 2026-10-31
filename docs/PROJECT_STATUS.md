# Current Project Status

Snapshot 2026-10-31. Android only, source base **0.5.4**, Godot 4.7.2 Compatibility. M5 #9 stabilization is active; physical-device release-candidate acceptance remains open.

## Accepted baseline

- M3 #7: closed after the five-level campaign/relaunch playtest.
- M4 #8: closed after overall Android audio/comfort/visual/Beam-direction acceptance.
- Settings #37 / PR #38: closed after the player confirmed “That is working now” on installed/read-back 0.5.2 build 12501.
- PRs #40 and #41: promoted the readable default, increased the optional size, and named the switch **Larger Text**. Player confirmed “Tested and approved” after installed/read-back **0.5.3-dev.129.1+g77eb492c**, code **12901**. This is overall acceptance, not itemized quantitative accessibility evidence.

M5 starting main is `77eb492c6b6f04b0ce548339b1ee45f7723518db`; [main CI #129](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41128947462) passed both Android jobs (15 Godot suites, nine Python tests, manifest/signature/pin/checksum/assets and emulator upgrade). The physical phone updated **12501 → 12701 → 12901** in place with exact saved bytes retained at each update. This is the latest confirmed installation; the M5 candidate is a separate delivery, not an assumed phone test.

## M5 stabilization

[Audit, reproduced defects, coverage and human checklist](M5_ANDROID_RC_QA.md). Version 0.5.4 fixes cancelled board/settings gestures and settings finger ownership across focus loss and multi-touch. Accepted rules, font sizes, assets, package ID and schema 1 remain intact. CI adds a sixteenth Godot suite and four Python tests; the emulator fixture includes Larger Text and all audio preferences. Final candidate SHA/build/signing evidence is recorded in the M5 PR and issue #9 after main CI completes.

Private stable-debug key/password/pin secrets are configured. Verify each actual APK against the public pin before a compatible update. Never uninstall, clear or overwrite player progress. Historical ephemeral-key build 9801 could not update with this key; the owner personally removed it before the stable-key installation. No old-save recovery is claimed. [Signing and recovery](ANDROID_VERSIONING.md).

M0/M1/M2 broader device/balance gates, M5 measured performance/interruption/scaling/accessibility and M6 production signing/AAB/Play remain open. No Android device measurements or new human test are inferred from headless or emulator checks. Web/HTML5, iOS and desktop distribution are out of scope; historical reports remain records only.

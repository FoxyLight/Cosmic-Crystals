# Milestones and Delivery Gates

Snapshot 2026-10-31. Android-only, Godot 4.7.2, source **0.5.4**. Milestones require evidence; Android debug export is not production release approval.

| Milestone | State | Remaining gate |
| --- | --- | --- |
| Foundation | Complete | Deterministic rules retained |
| M0 #4 | Open | Android device/performance matrix, future AAB and engine decision |
| M1 #3 | Open | Extended physical-device timing and interruption evidence |
| M2 #6 | Open | Detailed special/Nova balance; asteroid smoke accepted |
| M3 #7 | Complete | Player accepted five-level campaign/relaunch scope on 2026-10-29 |
| M4 #8 | **Complete: implemented and player-reported Android playtest PASS** | Audio/comfort/visual/Beam-direction M4 usability accepted; quantified device performance and full accessibility moved to M5 #9 |
| Post-M4 #37 | Complete, player accepted | Native volume/text fix accepted on 12501; subsequent 0.5.3 refinement approved on 12901 |
| M5 #9 | Active, open | Automated stabilization and a new debug candidate; measured physical-device acceptance remains |
| M6 #10 | Future | Production signing/AAB and Play publication decision |
| M7 #11 | Deferred | Expanded Android content only; iOS excluded |

[Current M4 evidence/checklist](M4_ANDROID_POLISH.md). [Main Android CI #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426) passed both jobs at 0.5.1; a separately documented real-phone 10801 → 11001 in-place update preserved the save exactly. Web/browser and iOS acceptance items are removed from active gates; old reports remain historical. The player reported **M4 playtest PASS** on 2026-10-30. [M4 acceptance report](ANDROID_M4_PLAYTEST_2026_10_30.md). This satisfies M4's human acceptance gate, not the separate multi-device, accessibility or quantitative performance gates in M5/M0.


## M5 stabilization checkpoint, 2026-10-31

Source base **0.5.4** follows accepted 0.5.3 build 12901. [M5 audit and human checklist](M5_ANDROID_RC_QA.md) records verified cancellation fixes, 16 Godot suites and 13 Python tests, coverage boundaries and outstanding device measurements. M3 #7, M4 #8 and settings #37 are closed; M5 #9 remains open. Earlier numbered builds in this document are historical evidence, not the current APK. Read final candidate commit/version/signing in its main CI artifact and #9 delivery receipt.

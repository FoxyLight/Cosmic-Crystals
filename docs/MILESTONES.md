# Milestones and Delivery Gates

Snapshot 2026-10-30. Android-only, Godot 4.7.2, source **0.5.1**. Milestones require evidence; Android debug export is not production release approval.

| Milestone | State | Remaining gate |
| --- | --- | --- |
| Foundation | Complete | Deterministic rules retained |
| M0 #4 | Open | Android device/performance matrix, future AAB and engine decision |
| M1 #3 | Open | Extended physical-device timing and interruption evidence |
| M2 #6 | Open | Detailed special/Nova balance; asteroid smoke accepted |
| M3 #7 | Complete | Player accepted five-level campaign/relaunch scope on 2026-10-29 |
| M4 #8 | Implemented; new human acceptance pending | Audio/comfort and Beam-direction phone test; broader accessibility/device performance. Same-key debug APK update/save retention verified |
| M5 #9 | Future | Android release-candidate quality gate |
| M6 #10 | Future | Production signing/AAB and Play publication decision |
| M7 #11 | Deferred | Expanded Android content only; iOS excluded |

[Current M4 evidence/checklist](M4_ANDROID_POLISH.md). [Main Android CI #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426) passed both jobs at 0.5.1; a separately documented real-phone 10801 → 11001 in-place update preserved the save exactly. Web/browser and iOS acceptance items are removed from active gates; old reports remain historical. Do not close #8 until the player accepts the new Android build. M3's pass is not a new M4 audio/accessibility pass.

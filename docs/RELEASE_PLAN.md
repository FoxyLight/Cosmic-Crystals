# Android Release Plan

Android is the sole supported product. Sequence: accepted five-level M3 → M4 audio/accessibility/performance and safe updates → Android M5 release candidate → separately authorized M6 production signing/AAB/Play work. No Web, desktop distribution or iOS work is planned. [Historical release plan](history/PRE_M4_RELEASE_PLAN.md) is superseded.

Source **0.5.4** is the M5 stabilization candidate following accepted 0.5.3 build 12901. Settings #37 is fixed and accepted; PRs #40/#41 text sizing and Larger Text label are approved. Debug CI preserves unique run/attempt/commit versioning, manifest/certificate/pin/checksum/assets and emulator exact-save upgrade checks. The phone's 12501 → 12701 → 12901 updates retained its save byte-for-byte. No newer candidate installation or physical acceptance is assumed. Stable debug signing remains separate from M6 production/upload signing. [Current status](PROJECT_STATUS.md), [M5 audit/checklist](M5_ANDROID_RC_QA.md).

## M4 acceptance

**The player reported M4 Android playtest PASS on 2026-10-30.** The implemented audio/visual/comfort and Beam-direction M4 slice meets its *overall human acceptance* gate; see [M4 report](ANDROID_M4_PLAYTEST_2026_10_30.md). Keep [M5's fuller Android QA](QA_TEST_PLAN.md) open for measured physical-device performance, scaling, audio interruptions and accessibility. M3 was already accepted. No Play Store/release AAB readiness is inferred.

## M5 Android quality gate

- Exact candidate source and all deterministic/scene/save/audio/signing/export tests green.
- Phone/tablet, compact/large displays, interruptions, long sessions, performance, readable visuals and usable audio/comfort settings accepted.
- No critical/high bugs without a documented decision; provenance and permissions reviewed.
- Stable updates preserve earned progress; recovery instructions tested on a disposable environment.
- Known limitations and ship/hold decision recorded.

## Future M6, not this assignment

Privately provision distinct production/upload credentials; validate Gradle release AAB and Play testing. Recheck current Play policies/target API and declarations at submission time. Prepare listing/privacy/data-safety disclosures matching actual features, then test updates on the chosen track. No ad/account/cloud SDKs are introduced by M4. Publication requires a separate authorized decision and evidence of availability.


## M5 stabilization checkpoint, 2026-10-31

Source base **0.5.4** follows accepted 0.5.3 build 12901. [M5 audit and human checklist](M5_ANDROID_RC_QA.md) records verified cancellation fixes, 16 Godot suites and 13 Python tests, coverage boundaries and outstanding device measurements. M3 #7, M4 #8 and settings #37 are closed; M5 #9 remains open. Earlier numbered builds in this document are historical evidence, not the current APK. Read final candidate commit/version/signing in its main CI artifact and #9 delivery receipt.

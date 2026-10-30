# Android Release Plan

Android is the sole supported product. Sequence: accepted five-level M3 → M4 audio/accessibility/performance and safe updates → Android M5 release candidate → separately authorized M6 production signing/AAB/Play work. No Web, desktop distribution or iOS work is planned. [Historical release plan](history/PRE_M4_RELEASE_PLAN.md) is superseded.

0.5.2 is the current Android source patch. It fixes native volume touch dragging and visible larger reading text after the already-accepted M4 and 0.5.1 Beam-direction changes. Issue #37 awaits a new phone retest. Debug CI derives unique code/name/filename from run/attempt/commit; validates manifest, signature, pin, checksum and assets; includes build-info. Stable debug identity is private Actions-secret material, not a Play release/upload key. The phone's 10801 → 11001 update was verified with its save byte-identical; this **does not** prove compatibility with a different-certificate legacy installation. A differently signed old app requires an explicitly approved save-safe migration; never erase progress for convenience. [Run #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426).

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

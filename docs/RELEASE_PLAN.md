# Android Release Plan

Android is the sole supported product. Sequence: accepted five-level M3 → M4 audio/accessibility/performance and safe updates → Android M5 release candidate → separately authorized M6 production signing/AAB/Play work. No Web, desktop distribution or iOS work is planned. [Historical release plan](history/PRE_M4_RELEASE_PLAN.md) is superseded.

0.5.0 is the M4 source base. Debug CI derives unique code/name/filename from run/attempt/commit; validates manifest, signature, pin, checksum and assets; includes build-info. Stable debug identity is private Actions-secret material, not a Play release/upload key. A differently signed old app requires an explicit save-safe migration; never erase progress for convenience.

## M4 acceptance

Keep #8 open until the player confirms the new Android audio/visual/comfort build. Complete [QA checklist](QA_TEST_PLAN.md), record exact build and preserve saves. M3 has already passed its own scope. No store readiness is inferred.

## M5 Android quality gate

- Exact candidate source and all deterministic/scene/save/audio/signing/export tests green.
- Phone/tablet, compact/large displays, interruptions, long sessions, performance, readable visuals and usable audio/comfort settings accepted.
- No critical/high bugs without a documented decision; provenance and permissions reviewed.
- Stable updates preserve earned progress; recovery instructions tested on a disposable environment.
- Known limitations and ship/hold decision recorded.

## Future M6, not this assignment

Privately provision distinct production/upload credentials; validate Gradle release AAB and Play testing. Recheck current Play policies/target API and declarations at submission time. Prepare listing/privacy/data-safety disclosures matching actual features, then test updates on the chosen track. No ad/account/cloud SDKs are introduced by M4. Publication requires a separate authorized decision and evidence of availability.

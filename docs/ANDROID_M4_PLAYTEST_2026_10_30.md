> **Historical milestone/build evidence.** For current source, accepted 0.5.3 build 12901, closed M3/M4/settings gates and active M5, see [PROJECT_STATUS](PROJECT_STATUS.md) and [M5 audit](M5_ANDROID_RC_QA.md). Status/next-step statements inside this earlier report apply to its recorded checkpoint.

# M4 Android Production Polish: Human Playtest Accepted

**Player report date:** 2026-10-30  
**Reported result:** **PASS**  
**Exact feedback:** “M4 playtest passes”  
**Scope:** Android-only M4 audio, visual/comfort and Beam-direction gameplay **overall human acceptance**.

## Source and build traceability

The test feedback follows delivery of M4 audio/settings, Android-only production polish, private stable debug signing, and the move-axis Beam correction.

- **Latest known physically installed/read-back M4 gameplay APK:** `0.5.1-dev.110.1+g7864c820` (Android `versionCode=11001`), source commit `7864c82007bf379de232156323328e887afdcf0c`.
- **Main verified build:** [Android CI #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426), [versioned APK artifact](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426/artifacts/12988237867).
- **Signer:** `persistent-secret`; CI checked actual signer and public certificate pin.
- **Data-protection evidence:** [M4 #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) previously documented a private validated backup and a **real-phone 10801 → 11001 in-place update**, with exact save-file bytes unchanged and no uninstall or data clearing. CI separately confirms same-key update retention on an isolated Android emulator.
- **Later documentation-only main:** [#113](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41090558472), commit `0fbe9b99cb4256b5e946321ad6866430f31fca1d`, passed both Android-only jobs. The player did **not** report installing its `versionCode=11301` APK. It has no gameplay changes from the 11001 source.

**Evidence boundary:** The player's reply supplies an **overall pass**, not an individually logged matrix of each sound cue, brightness setting, scaling profile, Beam direction/gesture, pause-interruption scenario, device/OS, or performance measurement. Do not claim the installed APK was independently re-read during this specific playtest response, or invent audio mix ratings, FPS, RAM/PSS, startup, frame times, thermals, TalkBack results or multi-device coverage.

## M4 acceptance decision

M4's implemented Android gameplay, audio/comfort, visual presentation, and safer signing workflow now have **automated verification plus the owner's general Android playtest acceptance**. This satisfies the scoped M4 **human usability/playtest gate**. The M4 milestone [#8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) can be closed as the *implemented and player-accepted production-polish slice*, provided unfinished extended QA below remains tracked explicitly.

The acceptance is **not** a full Android release-candidate, accessibility certification, performance benchmark or Play Store release decision.

## Deferred QA, retained as active work

Track in [M5 Android release-candidate/device QA #9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9), with separate M0/M1/M2 and M6 gates:

- Measured physical-device FPS/p95 frame time, PSS/RAM, startup/loading, battery and sustained thermal behavior; more than one Android device class.
- System font/display scaling, display cutouts/short screens, dim-brightness/grayscale/color distinctions, Android accessibility/TalkBack limitations.
- Hardware audio focus: calls, external media, headphones, screen locks, multi-hour interruption and resume, and sustained real-speaker mix loudness.
- Prolonged gameplay and high-load special/asteroid chains, Nova energy rates, level difficulty and defect severity.
- Process-death save integrity and stable signer retention for future in-place updates.
- Production release AAB/Google Play track signing, policy, listing and store availability (M6).

**Next priority:** M5 Android quality/release-candidate validation rather than Web/iOS work or new constellation content. Continue protecting local star records and avoiding unnecessary APK reinstall/uninstall.

# Development Roadmap

**Snapshot:** 2026-10-29. Product base **0.4.0**. No committed dates, staffing
or release promise. [Milestones](MILESTONES.md) are evidence-gated.

## Current status: M3 accepted; next priority protect progress and polish

The five-level Lyra campaign has passed source/scene/progression CI, an exported-browser persistence smoke test and the player's **2026-10-29 Android human playtest**. See the [M3 acceptance report](ANDROID_M3_PLAYTEST_2026_10_29.md) and [M3 #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7). The player provided an overall pass, not a per-case record or benchmark, so full Android device matrix and broader QA still apply.

**Immediate infrastructure prerequisite:** Configure persistent private debug signing (or a carefully planned save-preservation migration) **before installing another APK over a device containing newly earned campaign progress**. Ephemeral signing changes can force uninstall and delete saves.

**Next implementation focus:** M4 quality work, including audio, accessibility and mobile feedback. M5 performance/device/browser validation follows as a separate release-candidate phase. M0/M1/M2 balance and device acceptance requirements remain individually tracked.

## Completed slice: M3 Lyra

Implemented and accepted: five authored levels, sessions, stage mechanics, objectives/moves/ratings, Home/map/next/replay, local records/settings/recovery and nonblocking cues. All 13 Godot suites, five version tests and Android/Web exports passed; the player reports M3 Android campaign acceptance passed. [Campaign](M3_LYRA_CAMPAIGN.md), [#7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7).

Completed M3: PR #29 implementation, PR #30 delivery documentation, verified merged-main CI and player-reported Android acceptance. Next: preserve debug saves with stable signing, then M4 audio/accessibility and M5 measured regression/device/browser QA.

## Remaining gates

- **M0 #4:** Android/browser device matrix, FPS/RAM/startup/interruption data,
  signed Gradle AAB route and production engine decision.
- **M1 #3:** last-move/transition guards are tested; extended real-device timing,
  long-play and interruption acceptance remain.
- **M2 #6:** powers/rocks implemented and automated; asteroid build 9101 passed
  player smoke. Detailed power/Nova balance and broader acceptance remain.
- **M4 #8:** responsive visual slice and bundled type/icons exist; basic reduced
  motion now persists. New campaign/visual review, audio and accessibility remain.
- **M5 #9:** multi-device/browser release candidate and resolved critical bugs.
- **M6 #10:** production signing, Play testing/disclosures/listing and explicit
  publication decision. Debug exports are not store releases.
- **M7 #11:** levels 6-20, extra constellations and optional iOS remain deferred.

The five-level game does not import the separate earlier 20-level web concept's
progress/source. Do not count future systems as implemented.

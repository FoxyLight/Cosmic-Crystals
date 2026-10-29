# Development Roadmap

**Snapshot:** 2026-10-29. Product base **0.4.0**. No committed dates, staffing
or release promise. [Milestones](MILESTONES.md) are evidence-gated.

## Current slice: M3 Lyra

Implemented: five authored levels, sessions, stage mechanics, objectives/moves/
ratings, Home/map/next/replay, local records/settings/recovery and nonblocking
cues. All 13 Godot suites and five version tests pass locally. CI/Android/Web
and new human acceptance gates remain. [Campaign](M3_LYRA_CAMPAIGN.md), [#7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7).

1. Pass feature PR checks and Android/Web exports; merge only green changes.
2. Verify merged-main artifacts/catalog/manifest/version/checksum. Test the new
   APK on Android, including closing/reopening with identical earned records.
3. Tune from feedback. Keep M3 open until the human journey/restart gate passes.

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

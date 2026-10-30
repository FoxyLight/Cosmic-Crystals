# Milestones and Delivery Gates

**Snapshot:** 2026-10-29. Godot 4.7.2 / GDScript / Compatibility, Android first.
Trackers are GitHub issues, not native Milestone objects. Dates/owners/budgets
are uncommitted. Close a milestone only with all its acceptance evidence.

| ID | Milestone | Current state | Tracker / remaining gate |
| --- | --- | --- | --- |
| Foundation | Seeded rules + CI | Complete | #1 / #2 / merged #5 |
| M0 | Platform viability | In progress | [#4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4): full matrix, metrics, AAB, engine sign-off |
| M1 | Animated loop | In progress | [#3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3): extended hardware/interruption acceptance |
| M2 | Powers/Nova/rocks | Implemented; tuning open | [#6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6): automated, asteroid smoke accepted on 9101 |
| M3 | Five-level Lyra | **Complete: automated + user-reported Android acceptance** | [#7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7): five levels/map/saves/ratings delivered and human sign-off recorded |
| M4 | Art/audio/accessibility | In progress | [#8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8): visual slice/basic reduced motion; full gates open |
| M5 | Release candidate | Not started | [#9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) |
| M6 | Play distribution | Not started | [#10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10) |
| M7 | Expansion/iOS | Deferred | [#11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11) |

## Current game and evidence

Exactly five data-driven Lyra levels, connected map, stage goals/moves, seeded
sessions, tested powers/rocks, ratings, next/replay/map, best local records/
unlocks/tutorials/settings and recovery. [M3 evidence](M3_LYRA_CAMPAIGN.md).

Asteroid build 9101 was installed/read back and accepted by the player. The M3 campaign APK 9801 was installed/read back, and the player has now reported the requested **five-level Android playtest passes**. The later visual build is covered by the M3 gameplay smoke at a broad level, not a complete accessibility/contrast assessment. [M3 report](ANDROID_M3_PLAYTEST_2026_10_29.md). Full hardware/browser QA, detailed balance, accessibility and production signing remain open.

## Exit gates

- **M3:** a new player plays all five levels, understands goals/powers, earns
  stars/unlocks and retains the same records after closing/reopening Android.
  Replay/defeat cannot erase or improperly grant progress.
- **M4:** readable, usable core screens on representative phones; verified
  audio/motion/accessibility settings and asset provenance.
- **M5-M6:** full release QA and actual signed Play-track acceptance, not debug
  exports. Check current platform requirements at submission time.

Unique CI versions, manifest/checksum/build metadata and optional persistent
debug signing remain. Local defaults are not a distribution route.
[Version policy](ANDROID_VERSIONING.md).

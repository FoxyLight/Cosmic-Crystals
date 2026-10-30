# Current Project Status

**Snapshot:** 2026-10-29. Product base **0.4.0**, Godot 4.7.2 / GDScript,
Compatibility renderer. Canonical source: FoxyLight/Cosmic-Crystals.

## M3 Android acceptance: player-reported PASS (2026-10-29)

The player confirmed **“Human android play test passes”** in direct response to the M3 Android journey/close-and-reopen acceptance request. Five-level Lyra gameplay, progression and saved best records are therefore accepted at **human playtest level** following the already passing automated and Web smoke tests. See the [bounded M3 Android playtest report](ANDROID_M3_PLAYTEST_2026_10_29.md). The known installed-and-read-back M3 APK is `0.4.0-dev.98.1+ge14ef9e9` (code 9801); no additional device-install verification is inferred for documentation-only main builds.

The M3 milestone may be recorded as **complete at its defined implementation and player-playtest gate**. Separate M0/M1/M2/M4 and release gates remain open, especially persistent debug signing to protect new saves, human balancing, audio/accessibility, performance and signed AAB.

## Current implementation

M3's five-level Lyra campaign is implemented and verified in local and main CI, ready for
a new Android human acceptance test. Home/map/selection/play/
results/next/replay are connected; authored goals, budgets, scores, stars,
unlocks, local progression and nonblocking tutorials are in place. The map
has exactly five nodes and keeps prior best records on replay. Reduced motion
is a persistent setting. [M3 specification/evidence](M3_LYRA_CAMPAIGN.md).

Core M1/M2 behavior is retained: valid/invalid swaps, immutable animated events,
Beams/Bombs/Supernovas, unioned combinations, zero-move Nova, 1/2-HP asteroids,
segmented gravity and inventory-preserving deadlock recovery. Small configuration
hooks allow per-level kinds/reward types/Nova; defaults retain original behavior.
All ten existing suites pass. Three new suites cover sessions/balance,
persistence/recovery and a complete touch-driven scene campaign with reload.

## Evidence boundaries

- **Player Android asteroid pass:** `0.3.0-dev.91.1+g71c389ec`, code 9101,
  installed/read back over ADB, then player reported "Playtest passes". See #6.
- **Visual build:** `0.3.1-dev.96.1+g0937ff68`, code 9601, installed/read back;
  no subsequent separate human visual pass. #8 remains open.
- **Pre-M3 CI baseline:** [main run 96](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40967375848)
  passed tests and Android/Web exports. M3 uses the same guarded pipeline plus
  new tests and exported-catalog checks. PR run 97 and main run 98 passed all
  three jobs; delivery APK 9801 was installed and read back on the phone.
- Local M3 disk reload/scene checks are automated evidence, not a physical
  Android close/reopen test or a human campaign pass.
- Desktop renders/prior Chromium smoke do not establish a full device/browser,
  hardware/accessibility matrix or release readiness.

## Milestone state

| Milestone | Current state |
| --- | --- |
| Foundation | Complete |
| M0 | Debug exports/basic smoke; AAB/metrics/device matrix open |
| M1 | Automated correctness/scene checks; extended hardware/interruption QA open |
| M2 | Powers/rocks implemented, automated, asteroid smoke accepted; tuning open |
| M3 | Implementation and main CI verified; APK 9801 installed; human gate pending |
| M4 | Visual slice/basic reduced motion; broader acceptance/audio open |
| M5-M6 | Not started |
| M7 | Expansion/iOS deferred |

Next: run the installed M3 APK's
[M3 Android checklist](M3_LYRA_CAMPAIGN.md), record the player's result in #7,
and fix findings. Do not close M3 merely because an APK exports.

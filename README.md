# Cosmic Crystals: A Starweaver's Journey

An **Android-only** five-level match-3 game. Godot 4.7.2, GDScript, Compatibility renderer. Product base **0.5.3** (readable default and extra-large text). Package stays `org.foxylight.cosmiccrystals.prototype`.

Home → Lyra constellation → five authored levels → earned stars → next/replay/map. Beams, Bombs, Supernovas, Nova and fixed 1/2-HP asteroids have deterministic rules and immutable animation events. M3 passed the player's Android campaign/relaunch test; [report](docs/ANDROID_M3_PLAYTEST_2026_10_29.md), closed #7.

M4 adds 17 original effects, five ambient loops, bounded sound layering, crossfades, master/music/SFX controls, mute, remembered comfort settings, focus/background suspension, larger reading text, reduced effects, power feedback and bounded performance diagnostics. [M4 specification and evidence](docs/M4_ANDROID_POLISH.md).

## M4 Android player acceptance: PASS

On **2026-10-30**, the player reported **“M4 playtest passes”** for the current Android-only audio, visual/comfort and Beam-direction build. This is an overall human acceptance result, not a measured performance/accessibility or exhaustive interruption matrix. The last physically installed/read-back gameplay APK was `0.5.1-dev.110.1+g7864c820` (code 11001); subsequent main build #113 changed documentation only. [M4 playtest report](docs/ANDROID_M4_PLAYTEST_2026_10_30.md). **M4 #8 is accepted at its implementation/human-smoke gate; M5 device/release-candidate QA remains open.**

## Android settings follow-up (0.5.2)

After the overall M4 playtest PASS, the player found that the volume sliders would not drag and the Larger reading text switch was not visually clear. [PR #38](https://github.com/FoxyLight/Cosmic-Crystals/pull/38) fixes **native Android slider/switch touches**, makes larger text obvious in Settings, Home, map, gameplay guidance and dialogs, and adds real touch-drag/font-toggle regression tests. The player confirmed **“That is working now”** after installing/read-back of 0.5.2 build 12501. [Issue #37](https://github.com/FoxyLight/Cosmic-Crystals/issues/37) is accepted for those two defects; the new 0.5.3 size refinement has its own retest. [Fix details and safe install checklist](docs/ANDROID_SETTINGS_TOUCH_FIX_2026_10_30.md).

## Development and verification

Desktop/headless Godot is a development/testing environment only. Run Godot headless import, each `tests/test_*.gd`, `tests/benchmark_android.gd`, and `python -m unittest discover -s tests -p "test_android*.py" -v`. Check parser/runtime logs even when Godot exits zero. Android CI runs validation, 15 regression suites, CPU benchmark, version/signature/manifest checks, APK asset packaging and an isolated-emulator same-key upgrade/save test. No Web artifacts or browser QA.

## Android delivery and save safety

Download the exact versioned artifact from [Actions](https://github.com/FoxyLight/Cosmic-Crystals/actions/workflows/godot-checks.yml). Keep `build-info.json` and `SHA256SUMS.txt`. PR builds are temporary-key previews; main uses the private stable debug key when configured and validates its certificate pin. Read the actual signing fields before installation.

**Do not uninstall a progress-bearing installation.** A new stable certificate cannot update old ephemeral-key build 9801. [Signing and safe backup/migration](docs/ANDROID_VERSIONING.md), [export guide](docs/ANDROID_EXPORT.md). M4 user Android playtest is **accepted**; see [the M4 report](docs/ANDROID_M4_PLAYTEST_2026_10_30.md). Detailed M5 device/accessibility benchmarks remain open.

[Design](docs/GAME_DESIGN.md) · [Architecture](docs/TECHNICAL_ARCHITECTURE.md) · [QA](docs/QA_TEST_PLAN.md) · [Roadmap](docs/ROADMAP.md) · [Milestones](docs/MILESTONES.md) · [Status](docs/PROJECT_STATUS.md) · [Release plan](docs/RELEASE_PLAN.md).

Web/HTML5, desktop distribution, iOS, levels 6–20, extra constellations, monetization, accounts/cloud saves and Play publishing are outside M4. Earlier Web work remains in historical reports/Git history and has no active acceptance gate.

Four-match Beams follow the gem movement: left/right creates a horizontal Beam; up/down creates a vertical Beam. [PR #34](https://github.com/FoxyLight/Cosmic-Crystals/pull/34) and [Android-only main CI #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426) verified this change. The stable-signer 10801 → 11001 phone update retained its save byte for byte; the player subsequently reported an **overall M4 Android playtest PASS**. No device performance/audio-focus measurements are inferred.

[Current Android-only repository and documentation audit](docs/ANDROID_DOCS_AUDIT_2026_10_30.md) records exactly which gates are complete and which device/release measurements are still missing.

Reading text now uses the previous larger size as the standard. **Extra-large text** increases it further, with reflowed captions and panels. [Sizes, layout checks and acceptance](docs/ANDROID_READING_TEXT_2026_10_30.md).

# Cosmic Crystals: A Starweaver's Journey

An **Android-only** five-level match-3 game. Godot 4.7.2, GDScript, Compatibility renderer. Product base **0.5.1** (M4 polish). Package stays `org.foxylight.cosmiccrystals.prototype`.

Home → Lyra constellation → five authored levels → earned stars → next/replay/map. Beams, Bombs, Supernovas, Nova and fixed 1/2-HP asteroids have deterministic rules and immutable animation events. M3 passed the player's Android campaign/relaunch test; [report](docs/ANDROID_M3_PLAYTEST_2026_10_29.md), closed #7.

M4 adds 17 original effects, five ambient loops, bounded sound layering, crossfades, master/music/SFX controls, mute, remembered comfort settings, focus/background suspension, larger reading text, reduced effects, power feedback and bounded performance diagnostics. [M4 specification and evidence](docs/M4_ANDROID_POLISH.md).

## Development and verification

Desktop/headless Godot is a development/testing environment only. Run Godot headless import, each `tests/test_*.gd`, `tests/benchmark_android.gd`, and `python -m unittest discover -s tests -p "test_android*.py" -v`. Check parser/runtime logs even when Godot exits zero. Android CI runs validation, 15 regression suites, CPU benchmark, version/signature/manifest checks, APK asset packaging and an isolated-emulator same-key upgrade/save test. No Web artifacts or browser QA.

## Android delivery and save safety

Download the exact versioned artifact from [Actions](https://github.com/FoxyLight/Cosmic-Crystals/actions/workflows/godot-checks.yml). Keep `build-info.json` and `SHA256SUMS.txt`. PR builds are temporary-key previews; main uses the private stable debug key when configured and validates its certificate pin. Read the actual signing fields before installation.

**Do not uninstall a progress-bearing installation.** A new stable certificate cannot update old ephemeral-key build 9801. [Signing and safe backup/migration](docs/ANDROID_VERSIONING.md), [export guide](docs/ANDROID_EXPORT.md). M4 human Android acceptance stays pending in [#8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8).

[Design](docs/GAME_DESIGN.md) · [Architecture](docs/TECHNICAL_ARCHITECTURE.md) · [QA](docs/QA_TEST_PLAN.md) · [Roadmap](docs/ROADMAP.md) · [Milestones](docs/MILESTONES.md) · [Status](docs/PROJECT_STATUS.md) · [Release plan](docs/RELEASE_PLAN.md).

Web/HTML5, desktop distribution, iOS, levels 6–20, extra constellations, monetization, accounts/cloud saves and Play publishing are outside M4. Earlier Web work remains in historical reports/Git history and has no active acceptance gate.

Four-match Beams follow the gem movement: left/right creates a horizontal Beam; up/down creates a vertical Beam. [PR #34](https://github.com/FoxyLight/Cosmic-Crystals/pull/34) and [Android-only main CI #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426) verified this change. The stable-signer 10801 → 11001 phone update retained its save byte for byte, but the new M4 human audio/Beam-direction playtest is still pending.

[Current Android-only repository and documentation audit](docs/ANDROID_DOCS_AUDIT_2026_10_30.md) records exactly which gates are complete and which device/release measurements are still missing.

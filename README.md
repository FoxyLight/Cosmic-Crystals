# Cosmic Crystals: A Starweaver's Journey

An **Android-only**, five-level match-3 game in Godot 4.7.2/GDScript, Compatibility renderer. Source base **0.5.4**: M5 cancellation/input stabilization. Package remains `org.foxylight.cosmiccrystals.prototype`.

Home → Lyra map → five authored puzzles → stars, unlocks and replay. Movement-axis Star Beams, Cosmic Bombs, Supernovas, Nova Pulse and fixed asteroids use deterministic rules and immutable animation events. Original music/effects, remembered audio controls, reduced motion and **Larger Text** support the cosmic presentation.

## Accepted Android baseline

M3 #7 and M4 #8 are accepted and closed. Settings #37 was fixed and accepted on 0.5.2 build 12501. The readable baseline, bigger optional font and final **Larger Text** label were approved on **0.5.3-dev.129.1+g77eb492c** / **12901**. [Current status and exact evidence](docs/PROJECT_STATUS.md). These player reports do not establish measured multi-device performance or exhaustive accessibility/audio-focus coverage.

## M5 release candidate QA

Version 0.5.4 prevents cancelled Android touches from making moves or changing settings, cancels settings capture on backgrounding, and keeps a second finger from bypassing capture. Gameplay rules and saved progression remain unchanged. [Audit, regression coverage and focused human checklist](docs/M5_ANDROID_RC_QA.md). **M5 #9 remains open for physical-device acceptance and measurements.**

Desktop/headless Godot is only an Android development/test host. Run headless import, every `tests/test_*.gd`, `tests/benchmark_android.gd`, and `python -m unittest discover -s tests -p "test_android*.py" -v`. Strict parser/runtime-log checks apply even if Godot exits zero. CI runs 16 Godot suites, 13 Python tests, the CPU benchmark, Android export, manifest/certificate/checksum/assets and isolated-emulator save-preserving updates. No Web artifacts or browser QA.

## Android delivery and save safety

Use the successful **main** artifact from [Actions](https://github.com/FoxyLight/Cosmic-Crystals/actions/workflows/godot-checks.yml); retain `build-info.json` and `SHA256SUMS.txt` for the exact source/build. Verify the actual stable signer/pin before installing. PR builds use temporary keys and are unsuitable for updating the accepted phone installation.

Never uninstall or clear a progress-bearing game. The latest confirmed **12701 → 12901** phone upgrade retained exact save bytes. A different-certificate legacy copy requires a separately approved safe migration; a higher versionCode does not solve a signature mismatch. [Signing/versioning](docs/ANDROID_VERSIONING.md), [export](docs/ANDROID_EXPORT.md).

[Design](docs/GAME_DESIGN.md) · [Architecture](docs/TECHNICAL_ARCHITECTURE.md) · [QA](docs/QA_TEST_PLAN.md) · [Roadmap](docs/ROADMAP.md) · [Milestones](docs/MILESTONES.md) · [Status](docs/PROJECT_STATUS.md) · [Release plan](docs/RELEASE_PLAN.md).

No Web/HTML5, desktop distribution, iOS, levels 6–20, new constellations, monetization, cloud accounts/saves or Google Play publishing are included. Production signing/AAB belongs to M6.

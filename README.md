# Cosmic Crystals: A Starweaver's Journey

**Restore the stars. Awaken the universe.**

An Android-first cosmic match-3 puzzle adventure for Android and web, with iOS a later option. As a Starweaver, players match luminous crystals, awaken **Nova Pulse**, and restore constellations extinguished by **The Great Eclipse**.

## Project status

**Snapshot: 2026-10-29.** Godot 4.7.2 (GDScript, Compatibility renderer) is the working engine candidate. The foundational prototype and automated rules checks are on `main`; [PR #5](https://github.com/FoxyLight/Cosmic-Crystals/pull/5) was merged and the [Godot headless workflow passed](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40935869782).

**Implemented and headlessly tested:** seeded 8×8 boards with six crystal types, valid/invalid swap logic, match detection, gravity, refill, cascades and legal move checks. The one-screen prototype has procedural crystal visuals, mouse/touch controls, a move/score HUD and a basic collection win/lose loop.

**M0/M1 work merged in PR #13:** event-driven swap/clear/fall/rollback animations and 125-seed regression checks now pass headless CI. GitHub Actions has built a debug Android APK and Web export ([successful CI run](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40939726043)). **Android player-reported gameplay smoke passed** (2026-10-29); browser compatibility, detailed device FPS/RAM/interruption tests and release AAB signing remain unverified. **New M2 prototype slice (PR #16):** Star Beams, Cosmic Bombs, Supernovas, first-pass special combinations and a chargeable, cancelable, zero-move Nova Pulse are implemented with seeded headless tests. **Still missing:** asteroid blockers, full power balancing, five designed levels, galaxy map, saves, production art/audio and store distribution. The baseline M2 gameplay has positive Android smoke feedback; detailed combo balancing and asteroid blockers remain open.

The [separately published concept page](https://cosmic-crystals-starweaver-jneal.fxylght.chatgpt.site) references 20 levels and four constellations. Its source is not imported here, and those features are **future vision**, not claims about this repository.

## Milestones and current priorities

| Milestone | Objective | Status | Tracking |
| --- | --- | --- | --- |
| Foundation | Godot spike, rules and CI | Complete | [PR #5](https://github.com/FoxyLight/Cosmic-Crystals/pull/5) |
| M0 | Android APK/AAB and web export validation | In progress | [#4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4) |
| M1 | Reliable animated match-3 turns | In progress | [#3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3) |
| M2 | Special crystals, asteroids and Nova | In progress | [#6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6) |
| M3 | Five-level Lyra slice, map and saves | Not started | [#7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7) |
| M4 | Cosmic art, audio and accessible UX | Not started | [#8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) |
| M5 | Android/web release-candidate QA | Not started | [#9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) |
| M6 | Google Play test/release preparation | Not started | [#10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10) |
| M7 | 20 levels, four constellations, optional iOS | Deferred | [#11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11) |

**Mobile visual readability:** After the first Android playtest, the pale yellow and ice-white gems were difficult to distinguish. The [visual contrast patch (PR #14)](https://github.com/FoxyLight/Cosmic-Crystals/pull/14) gives Solar Amber a saturated golden sunburst and Lunar Opal a blue-white elongated shard, plus distinct outlines and facets for all six gem types. See [Crystal Visual Identity](docs/VISUAL_PALETTE.md). The next Android APK needs human visual confirmation; this is not a claim that all M4 visuals are finished.

The [M2 Powers and Nova guide](docs/M2_SPECIALS_NOVA.md) records the implemented power interactions, Nova meter, deterministic tests and remaining blocker work. The [M0/M1 implementation notes](docs/M0_M1_IMPLEMENTATION.md) describe the new event stream, test coverage and build artifacts. The detailed [milestone register](docs/MILESTONES.md) defines dependencies, exit gates and evidence. Tracking is implemented with **GitHub Issues as milestone trackers**, not native GitHub Milestone objects. No dates or owners have been committed.

## M2 Star Beam regression fix

A physical Android playtest revealed that matching four gems did not visibly produce a Star Beam. Investigation found a GDScript **parse error hidden by the previous CI workflow** in the first M2 preview, not a verified error in the four-match rules themselves. [PR #18](https://github.com/FoxyLight/Cosmic-Crystals/pull/18) corrects the syntax and adds real-scene four-match smoke coverage plus an engine-log guard so APK exports cannot silently pass with failed gameplay-script loading. Beam icons and the `STAR BEAM FORGED!` message are also clearer. A fresh Android retest is required before this defect is closed. See [M2 mechanics](docs/M2_SPECIALS_NOVA.md) and [bug #17](https://github.com/FoxyLight/Cosmic-Crystals/issues/17).

**M2 combination audit:** [PR #20](https://github.com/FoxyLight/Cosmic-Crystals/pull/20) adds exhaustive checks for 96 ordered special-combo and edge-orientation scenarios, a real-scene test for Beam/Bomb/Supernova formation and Nova HUD controls, and fixes power icons disappearing during nearby crystal-clearing animations. Follow [issue #19](https://github.com/FoxyLight/Cosmic-Crystals/issues/19); Android confirmation is still required.

## Why a board could appear to reset

The single-round prototype has a short **30-crystal target and 18-move budget**. Star Beams, Bombs and Nova can reach that target quickly. Previously any touch after the win/loss state immediately restarted the game. [PR #22](https://github.com/FoxyLight/Cosmic-Crystals/pull/22) adds a visible result overlay requiring an intentional **PLAY AGAIN** tap; ordinary taps are ignored. A separate deadlock recovery that previously regenerated the grid now reshuffles the **same gem inventory**, retaining moves, score and Nova charge. See [issue #21](https://github.com/FoxyLight/Cosmic-Crystals/issues/21) and [QA](docs/QA_TEST_PLAN.md). Android retest of these fixes is outstanding.

## Versioned Android preview APKs

**From PR #24 onward**, each CI Android APK has a unique `versionCode`, a readable `versionName` containing the product version/build number/commit, and a matching versioned APK filename. The artifact includes `build-info.json` (exact SHA/version/run/signing mode) and a SHA-256 checksum. CI verifies the **version embedded in the APK manifest**; renaming a file cannot make it pass.

The source [VERSION](VERSION) is `0.2.0`. See [Android APK Versioning](docs/ANDROID_VERSIONING.md) for the full policy, downloads, wireless ADB installation and optional private persistent debug keystore. **Version numbers alone do not fix a changed signing certificate**, and future signed Google Play AABs remain a separate release process.

**Android gameplay smoke (2026-10-29):** The player reports that the human playtest **passes** after the latest gameplay fixes and versioned build workflow. This is a positive practical checkpoint, while full device metrics, interruption tests, browser QA, Google Play signing and asteroid blockers are unfinished. See the [Android Playtest Report](docs/ANDROID_PLAYTEST_2026_10_29.md). The next development focus is **asteroid blockers** (M2 #6).

## Run the prototype

1. Install [Godot 4.7.2 standard edition](https://godotengine.org/download/archive/4.7.2-stable/).
2. Clone the repo, import/open `project.godot` in Godot and press **F5**.
3. Drag from one crystal to an orthogonally adjacent crystal, or tap two adjacent crystals. Four, five or T/L matches can forge special pieces; swap a special to activate it. Matches charge Nova to 20. Tap the NOVA control, then a tile to blast its row/column without using a move; tap NOVA again to cancel. Collect 30 crystals within 18 moves. After a win/loss, press the explicit **PLAY AGAIN** button; press **R** on desktop.

Headless checks:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_board.gd
godot --headless --path . --quit-after 120
```

These checks run in [GitHub Actions](.github/workflows/godot-checks.yml), which also exports a **versioned Android debug APK** and a Web artifact. Automated exports do **not** prove physical device/browser usability.

## Documentation index

| What you need | Reference |
| --- | --- |
| Current achievement vs missing work | [Project Status](docs/PROJECT_STATUS.md) |
| Milestone owners/criteria and issue links | [Milestone Register](docs/MILESTONES.md) |
| M0/M1 animated prototype and CI build results | [Implementation Notes](docs/M0_M1_IMPLEMENTATION.md) |
| M2 Star Beams, Bombs, Supernova and Nova targeting | [M2 Gameplay Guide](docs/M2_SPECIALS_NOVA.md) |
| Execution order and scope | [Roadmap](docs/ROADMAP.md) |
| Concept, gameplay and visuals | [Game Design](docs/GAME_DESIGN.md) |
| Gem colors, silhouettes and mobile readability QA | [Crystal Visual Identity](docs/VISUAL_PALETTE.md) |
| Implementation and domain architecture | [Technical Architecture](docs/TECHNICAL_ARCHITECTURE.md) |
| Coding-agent instructions | [Build Prompt](docs/BUILD_PROMPT.md) |
| Godot engine decision/evidence gate | [Engine Evaluation](docs/ENGINE_EVALUATION.md) |
| Why key technical/product choices were made | [Decisions](docs/DECISIONS.md) |
| Acceptance and device/browser tests | [QA Test Plan](docs/QA_TEST_PLAN.md) |
| Android APK/AAB and web export setup | [Android and Web Export](docs/ANDROID_EXPORT.md) |
| Unique Android APK versions, artifacts and optional stable debug signing | [Android APK Versioning](docs/ANDROID_VERSIONING.md) |
| Android release and Play process | [Release Plan](docs/RELEASE_PLAN.md) |
| Known project risks/dependencies | [Risk Register](docs/RISKS.md) |
| Branch, test and PR process | [Contributing](CONTRIBUTING.md) |

## Working agreement

This GitHub repository is the canonical source of truth. Use scoped issues and PRs, keep the [Milestone Register](docs/MILESTONES.md) and [Project Status](docs/PROJECT_STATUS.md) synchronized with real evidence, and do not mark untested product features or platform exports as complete.

**Immediate focus:** download and playtest the M2 powers/Nova APK on Android, finish remaining M0/M1 device and interruption checks, and implement asteroid blockers in M2 #6. M3–M7 follow their milestone gates.

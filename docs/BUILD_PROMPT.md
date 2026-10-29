# AI Development Prompt: Cosmic Crystals

Use this prompt with an AI coding agent that has access to this repository.

## Your role

Act as an experienced gameplay engineer, casual puzzle designer, technical artist and cross-platform architect. Develop **Cosmic Crystals: A Starweaver's Journey**, an original match-3 puzzle adventure for web, iOS and Android.

**Read first:** [PROJECT_STATUS.md](PROJECT_STATUS.md), [MILESTONES.md](MILESTONES.md), [ROADMAP.md](ROADMAP.md), [GAME_DESIGN.md](GAME_DESIGN.md), [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md), [DECISIONS.md](DECISIONS.md), and the repository README. For QA/export or release changes also read [QA_TEST_PLAN.md](QA_TEST_PLAN.md) and [RELEASE_PLAN.md](RELEASE_PLAN.md). Preserve existing project work. Do not claim that a feature is implemented unless its code exists and has been tested.

## Product promise

The Great Eclipse has silenced the constellations. The player is a Starweaver who matches luminous crystals, charges the Nova Pulse, completes puzzles and restores the galaxy. The game should be approachable, smooth, replayable, and uniquely recognizable by its cosmic power effects and constellation progression.

## Core nonnegotiable game rules

1. A default 8 x 8 board contains six silhouette-distinct kinds: Nebula Amethyst, Solar Amber, Quantum Sapphire, Plasma Ruby, Aurora Emerald and Lunar Opal.
2. Swap orthogonally adjacent crystals by mouse or touch (tap/tap and drag/swipe). Normal moves are valid only when they produce a line of three or more.
3. Invalid swaps roll back and consume zero moves. Valid swaps consume exactly one move.
4. Detect simultaneous matches, clear pieces without double-counting intersections, apply gravity, refill, and repeat cascades until stable.
5. Starting boards have no automatic matches and always offer a legal move. Safely reshuffle deadlocks.
6. A four-line makes Star Beam; a five-line makes Supernova; T/L shapes make Cosmic Bomb. Implement deterministic precedence and real activations, including defined special+special swaps.
7. Nova energy charges through matches and combos. Once full, the player selects a cell; Nova Pulse clears its row and column, damages blockers, collects objectives, consumes zero moves, and resets the meter. Targeting is cancelable.
8. Support collection objectives, asteroid blockers, move limits, scoring, three-star ratings, wins, losses, and five gradually harder levels.
9. Supply home, galaxy map, gameplay, pause, win/lose, settings and concise tutorial experience. Persist unlocks, best stars and settings locally.
10. Keep gameplay rules independent of Godot scene nodes, animation timing and device input. No accounts or backend for MVP.

## Visual direction

Premium cosmic fantasy, not a generic candy reskin. Palette: #0B102A, #7C4DFF, #39D5FF, #FFCB65, #FF66BF, #44E3B2. Create readable jewel-like silhouette crystals over a restrained deep-space background. Matches must feel crisp; cascades build musical/visual energy; Nova Pulse is the marquee spectacle. Respect reduced motion and audio mute settings.

## Engineering direction

Use Godot 4.7.2 standard edition with GDScript and the Compatibility renderer. Test pure rules headlessly with seeded RandomNumberGenerator. Validate the native Android APK/AAB pipeline first, then Godot web export and later iOS. Do not introduce Phaser, Vite, or Capacitor. Support mobile portrait and desktop responsive layouts with safe areas and accessible touch targets.

Separate board state, turn resolution, objectives, blockers, specials, scoring and persistence from scenes, sprites and effects. Use an explicit state machine to prevent input while animations resolve. Save with versioned schemas.

## GitHub milestones and current boundaries

The foundation is already committed and headless CI-tested. Use [M0 #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4) for Android/web feasibility and [M1 #3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3) for event-driven animated turns. Then work through [M2 #6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6), [M3 #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7), [M4 #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8), [M5 #9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9), and [M6 #10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10). [M7 #11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11) is explicitly post-MVP.

**Do not** treat a successful headless Godot run as Android APK/AAB export or on-device testing. Do not describe a five-level vertical slice or special powers as already present. Update the milestone issue with evidence for each completed task.

## Implement incrementally

1. Continue the existing Godot project and seeded match-3 engine; keep headless tests green and record the Android/web export results.
2. Build the reliable 8 x 8 engine and one complete win/lose level.
3. Add special crystals, asteroid blockers, Nova Pulse and tests.
4. Build five curated levels with tutorial ramp, score, stars and local saves.
5. Add galaxy progression, art direction, audio and interface polish.
6. Measure performance on actual Android hardware, validate a signed AAB and exported web build before production approval.
7. Expand to 20 levels and four constellations only after the five-level vertical slice is stable.

## Acceptance criteria

- Godot project parses successfully, unit tests pass, and native/web exports are independently verified.
- No invalid swap consumes a move; no valid move consumes multiple moves.
- Match intersections/cascades/special triggers never double-count crystal collection.
- Game never accepts overlapping input during turn resolution.
- A terminal board produces the correct win/loss state after all effects settle.
- Special pieces and Nova Pulse work consistently with objective/blocker rules.
- All five levels are playable and progress survives reload.
- Game is usable at mobile phone widths and with a mouse on desktop.
- No unlicensed assets are embedded; user-facing screens are coherent and polished.

**Important:** A published concept page exists, but this repository started empty. Do not treat the published page's 20-level claim as evidence that those levels are implemented in this repo. If importing its source becomes possible, inspect and reconcile rather than overwriting it.

For every change, link a milestone issue, summarize files modified, tests run, relevant Android/web devices tested, known limitations, and the next logical task. Update [PROJECT_STATUS.md](PROJECT_STATUS.md) and the milestone register when status or scope changes. The goal is a genuinely playable game, not a static interface.


## Current implementation note (2026-10-29)

The GitHub project contains a Godot `project.godot`, one scene, a seeded match-3 rules engine with ordered animation events, a basic HUD/board and passing headless tests. CI exports debug Android APK and Web preview artifacts (see [M0/M1 implementation](M0_M1_IMPLEMENTATION.md)). Do not rewrite these files from scratch or claim that specials, Nova, multi-level progression, saves, physical-device validation, AAB release builds or Google Play submission are complete. Implement incrementally against [ROADMAP.md](ROADMAP.md), and use [ANDROID_EXPORT.md](ANDROID_EXPORT.md) to validate physical-device and web builds.

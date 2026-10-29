# Cosmic Crystals: A Starweaver's Journey

**Restore the stars. Awaken the universe.**

Cosmic Crystals is an Android-first match-3 puzzle adventure for Android, web and later iOS. Players match luminous crystals, charge the Nova Pulse, complete puzzle objectives, and gradually restore constellations extinguished by **The Great Eclipse**.

## Development status (2026-10-29)

A **Godot 4.7.2 + GDScript** gameplay technology spike has been merged into `main` in [PR #5](https://github.com/FoxyLight/Cosmic-Crystals/pull/5). Its initial CI run passes Godot project parsing and deterministic board tests. **Android APK/AAB, web export and real-device performance are not yet verified.**

This code is a small playable match-3 prototype, **not** a finished 5-level game: it supports an 8×8 seeded board, six crystal types, touch/mouse swaps, match detection, gravity/refill, cascades, a simple score/move counter and a single collection objective. Swap and fall animations, blockers, special pieces, Nova Pulse, galaxy map, saves and polished visuals are planned, not present.

A [separately published Cosmic Crystals concept](https://cosmic-crystals-starweaver-jneal.fxylght.chatgpt.site) advertises 20 levels and 4 constellations, but that site's source is not imported into this repository.

## Run the prototype

1. Install [Godot 4.7.2 standard edition](https://godotengine.org/download/archive/4.7.2-stable/).
2. Open/import `project.godot` in Godot.
3. Press **F5** to run the scene.
4. Drag from one crystal to an adjacent crystal, or tap two adjacent ones. Make matches and collect 30 crystals in 18 moves. After a win or loss, tap to restart; press **R** on desktop to restart.

Run automated rule checks with:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_board.gd
```

GitHub Actions repeats these commands on branch pushes and pull requests.

## Project documents

- [Game Design Document](docs/GAME_DESIGN.md): themes, crystal types, special pieces, Nova Pulse, goals, and galaxy progression.
- [Technical Architecture](docs/TECHNICAL_ARCHITECTURE.md): Godot-first architecture, deterministic domain, testing and save-state strategy.
- [Roadmap](docs/ROADMAP.md): milestones and exit criteria.
- [Build Prompt](docs/BUILD_PROMPT.md): implementation brief for coding agents.
- [Engine Evaluation](docs/ENGINE_EVALUATION.md): Android engine tradeoffs and still-open go/no-go gates.
- [Android/Web Export Guide](docs/ANDROID_EXPORT.md): environment setup and device validation instructions.

## Direction

**Godot 4.7.2 standard edition + GDScript + Compatibility renderer** is the current development candidate for native Android and shared web export, replacing our earlier Phaser/Vite/Capacitor coding direction. Production selection will be finalized only after Android and web export/device benchmarks.

The first release target remains **five polished levels in one constellation**. Expand to the 20-level, four-constellation vision after the core experience is tested and stable.

## Next milestone

Complete the Android APK/AAB and Web export proof of concept, then add an ordered animation-event pipeline and on-device particle stress test. Track the engine decision in [Issue #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4).

This repository is our source of truth going forward. Keep code and documentation aligned, write tests for new gameplay rules, and do not mark a feature complete without verification.

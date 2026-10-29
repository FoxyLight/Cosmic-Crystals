# Technical Architecture

**Direction:** Android-first **Godot 4.7.2 (GDScript)**, with a shared web and future iOS project. This supersedes the earlier Phaser/Vite/Capacitor proposal. Production sign-off is conditional on APK/AAB, browser export, and physical-device tests.

## Working Godot prototype

- `project.godot`: Compatibility renderer and portrait-oriented baseline.
- `scenes/Prototype.tscn`: one-screen test scene.
- `scripts/board.gd`: seedable 8×8 board generation, adjacency, match scan, legal moves, validated swaps, clear/gravity/refill/cascade resolution and deadlock fallback.
- `scripts/prototype.gd`: procedural starfield and crystals, HUD, touch/mouse selection and drag, move counter, simple collection goal and win/loss.
- `tests/test_board.gd`: seeded pure-rule tests, intersection counting and stable-board checks.
- `.github/workflows/godot-checks.yml`: downloads Godot 4.7.2, parses/imports project and runs headless tests.

**Verified:** Initial GitHub Actions run completed successfully. **Not yet verified:** APK, AAB, web export, actual phone touch/UX, graphics stress test, iOS export.

## Production architecture

Keep the rules independent of Godot Nodes and animation timing. Target structure:

```text
scenes/
  Home.tscn
  GalaxyMap.tscn
  Puzzle.tscn
  puzzle/BoardView.tscn
  ui/GameplayHUD.tscn
scripts/
  domain/
    board.gd
    match_finder.gd
    turn_resolver.gd
    gravity.gd
    special_pieces.gd
    objectives.gd
    nova.gd
  gameplay/
    session.gd
    input_controller.gd
  persistence/
    progress_store.gd
data/levels/
assets/
tests/
```

These directories are architectural targets, not promises that they exist today.

### State and turn resolution

The current prototype computes the final board state immediately and flashes a result. Before adding polished gameplay animations, refactor its resolver to produce ordered immutable effects. Let the scene animate those events with an explicit input-lock state machine:

```text
IDLE -> SWAPPING -> VALIDATING
  invalid -> RETURNING -> IDLE
  valid -> RESOLVING -> CASCADING -> CHECK_GOALS -> IDLE / WON / LOST
IDLE -> NOVA_TARGETING -> RESOLVING -> CHECK_GOALS
       cancel -> IDLE
```

A tile must be collected/damaged only once per match resolution step; intersections must not double-count. Evaluate victory after every special or cascade finishes. Maintain deterministic seeded randomness and a guard against infinite cascades.

### Domain data

Move from the current integer-only crystal representation to an explicit data model: crystal kind, optional special piece, cell occupancy, blocker durability, score/goal deltas, level move budget, Nova energy and an ordered event log. Prefer typed GDScript classes and Resources/validated JSON for level data.

Keep progress storage under Godot `user://`, version save schemas, and persist only completed, stable progress. Do not save a half-resolved turn.

### Input and visuals

The prototype supports drag/swipe and tap-two-adjacent input through `_input`, then locks input for brief result feedback. Production code must avoid duplicate synthesized touch/mouse events; animate swaps, clears, drops and spawns asynchronously from domain events; and support safe areas, motion reduction, feedback and touch accessibility.

### Tests and quality gates

Headless tests should cover board generation, legal swaps, match intersections, gravity/cascades, reshuffle and eventual special interactions. New code should add tests for specials, Nova, blockers, last-move victory, pause/restart during animations, and save schema migration.

CI runs:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_board.gd
```

CI parser/tests do **not** substitute for Android export or physical-device testing.

## Platform notes

- Native Android APK for device QA, signed AAB for Play release, using Android SDK, OpenJDK 17 and matching Godot export templates.
- Godot web export uses Compatibility renderer, WebGL 2 and WebAssembly. Start with single-threaded export.
- Use GDScript, not Godot 4 C#, so web export remains possible.
- Prefer real-device measurements before introducing ads, in-app billing and analytics plugins.
- Package iOS only after Android/web gameplay is stable.

See [Android/Web Export Guide](ANDROID_EXPORT.md), [Engine Evaluation](ENGINE_EVALUATION.md) and [Roadmap](ROADMAP.md).

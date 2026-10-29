# Technical Architecture

**Direction:** Android-first **Godot 4.7.2 (GDScript)**, with a shared web and future iOS project. This supersedes the earlier Phaser/Vite/Capacitor proposal. Production sign-off is conditional on APK/AAB, browser export, and physical-device tests.

## Working Godot prototype

- `project.godot`: Compatibility renderer and portrait-oriented baseline.
- `scenes/Prototype.tscn`: one-screen test scene.
- `scripts/board.gd`: seedable 8×8 board generation, match scanning, legal swaps, gravity/refill/cascades, deadlock fallback, and immutable ordered `swap`, `swap_back`, `clear`, `fall` and `reshuffle` event snapshots.
- `scripts/prototype.gd`: procedural starfield/crystals, HUD, touch and swipe/tap input, animated event playback with `phase` locking, score/move/collection goal, win/loss, and a synthetic draw/FPS stress test.
- `tests/test_board.gd`: 125-seed rules tests, rejected adjacent swaps, intersection deduplication, stable-board checks, complete event replay and scoring invariants.
- `.github/workflows/godot-checks.yml`: downloads Godot 4.7.2, parses/imports and smoke-tests the scene, runs headless seeded tests, and exports a debug Android APK plus HTML5 artifacts.

**Verified automatically:** Android debug APK and Web artifacts generated, parsing/tests/scenes pass. **Not yet verified:** actual APK install, browser runtime, touch/UX, measured graphics performance, AAB or iOS export.

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

The rules engine still calculates the final board state synchronously, but now returns ordered, immutable `before`/`after` frames. The scene animates each frame sequentially without affecting model outcomes, with an explicit `idle` / `resolving` / `finished` input lock. A production state machine will eventually distinguish swap, clear, fall, objective checks and Nova targeting:

```text
IDLE -> SWAPPING -> VALIDATING
  invalid -> RETURNING -> IDLE
  valid -> RESOLVING -> CASCADING -> CHECK_GOALS -> IDLE / WON / LOST
IDLE -> NOVA_TARGETING -> RESOLVING -> CHECK_GOALS
       cancel -> IDLE
```

A tile must be collected/damaged only once per match resolution step; intersections must not double-count. Evaluate victory after every special or cascade finishes. Maintain deterministic seeded randomness and a guard against infinite cascades.

### Domain data

The **event log** is implemented for current blocker-free swaps, clearing and gravity. Next, move from the integer-only crystal representation to explicit crystal/special kind, cell occupancy, blocker durability, objective/goal deltas, level move budget and Nova energy. Prefer typed GDScript classes and Resources/validated JSON for level data.

Keep progress storage under Godot `user://`, version save schemas, and persist only completed, stable progress. Do not save a half-resolved turn.

### Input and visuals

The prototype supports drag/swipe and tap-two-adjacent input through `_input`, selecting one orthogonal neighbor even for longer drags. It locks input while playing the ordered swap, rollback, clear, fall and refill effects. Future work: manual Android gesture QA, pause/restart interruption handling, safe areas, reduced motion and accessibility.

### Tests and quality gates

Headless tests now cover generation over 125 seeds, legal/invalid neighboring swaps, match intersections, gravity/cascades, event continuity, collection/score consistency and stable output boards. New tests are still required for specials, Nova, blockers, last-move victory, pause/restart during animations and save migrations.

CI runs:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_board.gd
godot --headless --path . --quit-after 120
```

CI parser/tests and **successful debug APK/Web exports** do **not** substitute for physical-device/browser testing, AAB signing or store acceptance.

## Platform notes

- Native Android APK for device QA, signed AAB for Play release, using Android SDK, OpenJDK 17 and matching Godot export templates.
- Godot web export uses Compatibility renderer, WebGL 2 and WebAssembly. Start with single-threaded export.
- Use GDScript, not Godot 4 C#, so web export remains possible.
- Prefer real-device measurements before introducing ads, in-app billing and analytics plugins.
- Package iOS only after Android/web gameplay is stable.

See [M0/M1 Implementation](M0_M1_IMPLEMENTATION.md) for the event protocol and successful CI artifact run, [Android/Web Export Guide](ANDROID_EXPORT.md), [Engine Evaluation](ENGINE_EVALUATION.md) and [Roadmap](ROADMAP.md).

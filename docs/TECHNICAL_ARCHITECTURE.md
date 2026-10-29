# Technical Architecture

**Direction:** Android-first **Godot 4.7.2 (GDScript)**, with a shared web and future iOS project. This supersedes the earlier Phaser/Vite/Capacitor proposal. Production sign-off is conditional on APK/AAB, browser export, and physical-device tests.

## Working Godot prototype

**M2 asteroid extension:** `CosmicBoard.asteroids` is a separate 64-entry 0–2
durability array; blocked cells have no gem or special. All events carry
`asteroids_before/after`. A clear wave unions direct/adjacent hits, emits
`asteroid_hit` after crystal clear/reward and before fall, then resolves cascades.
Fixed rocks divide columns into independently refilled regions (`segment_top`
on spawns); destruction reconnects regions. The shuffle permutes only movable
gem/power pairs, preserving rock positions/HP and exact inventory. The renderer
uses event snapshots for hits/cracks/destruction and locks input until playback
ends. Both crystal and rock goals are checked after resolution. See
[M2 Asteroids](M2_ASTEROIDS.md) for damage semantics, bounded recovery limitations,
862,246 rules assertions and 46 real-scene assertions. All original suites and
strict CI error-log validation remain active; physical Android QA is pending.

- `project.godot`: Compatibility renderer and portrait-oriented baseline.
- `scenes/Prototype.tscn`: one-screen test scene.
- `scripts/board.gd`: stable seeded 8×8 generation/matching and M1 turn/event behavior.
- `scripts/cosmic_board.gd`: M2 subclass with a parallel 64-entry special array, deterministic Star Beam/Bomb/Supernova creation/trigger chains, capped Nova energy, zero-move row/column target action and dual gem/special event snapshots.
- `scripts/prototype.gd`: procedural starfield/crystals, readable power icons, HUD with Nova meter and cancelable targeting, touch/swipe input, animated gem+power events with phase locking, collection goal and synthetic draw/FPS stress test.
- `tests/test_board.gd`: original 125-seed M1 rules and animation event invariants.
- `tests/test_powers.gd`: seeded M2 special formation/activation, combos, Nova zero-cost/charge, event replay and overlap deduplication.
- `tests/test_power_matrix.gd`: 96 ordered two-power combinations across center/edge and horizontal/vertical positions, independently expected blast union and exact gem/power/gravity/score invariants.
- `tests/test_power_scene.gd`: real scene-controller creation of both Beam orientations, Bomb and Supernova, a Beam+Bomb swap and NOVA target/cancel controls.
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

The **event log** now includes separate gem and special snapshots, including falling power locations. M2 implemented a separate special-type array and Nova charge. Blocker durability and the two prototype goals are now implemented; next introduce configurable multi-goal levels, move budgets and versioned progression. Prefer typed GDScript classes and Resources/validated JSON for level data.

Keep progress storage under Godot `user://`, version save schemas, and persist only completed, stable progress. Do not save a half-resolved turn.

### Replay and deadlock protection

The result phase must never interpret an ordinary board tap as “restart”. A visible overlay provides a dedicated PLAY AGAIN rectangle that requires both press and release inside it. The HUD, score, Nova charge and final board remain available until deliberate replay. Domain deadlock recovery now permutes the current gem and special inventories instead of calling `super.generate()`. It preserves color counts, produces a match-free board with a legal swap, emits an ordered `reshuffle` event, and leaves objective counters unaffected. See [QA](QA_TEST_PLAN.md) and [issue #21](https://github.com/FoxyLight/Cosmic-Crystals/issues/21).

The inventory shuffle now excludes fixed blockers and preserves durability. It
restores the original board and reports failure if its bounded search cannot
recover an unsupported layout. No full-board regeneration is used. The
30-crystal plus six-rock round remains provisional for M3 level design.

### Input and visuals

The prototype supports drag/swipe and tap-two-adjacent input through `_input`, selecting one orthogonal neighbor even for longer drags. It locks input while playing the ordered swap, rollback, clear, fall and refill effects. Future work: manual Android gesture QA, pause/restart interruption handling, safe areas, reduced motion and accessibility.

### Tests and quality gates

Headless tests cover M1 generation, invalid swaps, intersections/cascades/event continuity, plus M2 power formation, swap activation, combinations, Nova Pulse and gem/special event replay. Blockers, last-move outcomes and seeded replay stress are now covered in the asteroid suites. Pause/restart and save migrations remain later work.

CI runs:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_board.gd
godot --headless --path . --script res://tests/test_powers.gd
godot --headless --path . --script res://tests/test_power_matrix.gd
godot --headless --path . --script res://tests/test_power_scene.gd
godot --headless --path . --quit-after 120
```

CI parser/tests and **successful debug APK/Web exports** do **not** substitute for physical-device/browser testing, AAB signing or store acceptance.

## Platform notes

- Native Android APK for device QA, signed AAB for Play release, using Android SDK, OpenJDK 17 and matching Godot export templates.
- Godot web export uses Compatibility renderer, WebGL 2 and WebAssembly. Start with single-threaded export.
- Use GDScript, not Godot 4 C#, so web export remains possible.
- Prefer real-device measurements before introducing ads, in-app billing and analytics plugins.
- Package iOS only after Android/web gameplay is stable.

See [M2 Gameplay Guide](M2_SPECIALS_NOVA.md), [M0/M1 Implementation](M0_M1_IMPLEMENTATION.md) for the event protocol and successful CI artifact run, [Android/Web Export Guide](ANDROID_EXPORT.md), [Engine Evaluation](ENGINE_EVALUATION.md) and [Roadmap](ROADMAP.md).

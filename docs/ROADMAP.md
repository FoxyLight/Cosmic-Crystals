# Development Roadmap

**Baseline:** repository initialized with design documents on 2026-10-29. The Godot spike merged in PR #5 now passes headless CI, but device and browser exports are not yet verified. Published concept page: https://cosmic-crystals-starweaver-jneal.fxylght.chatgpt.site.

## Guiding priority

**Make the puzzle reliable and satisfying before expanding content.** The first delivery is a functional Android-first Godot vertical slice with a web build, not a mockup and not an immediate app-store release.

## P0 — Phase 0: Android-first engine validation (in progress)

- [x] Approve Godot 4.7.2/GDScript for a technology spike.
- [x] Commit native-capable Godot project, basic touch board and seeded rules tests.
- [x] Parse/import the project and run tests in GitHub Actions.
- [ ] Animate swaps, invalid rollback, gravity, refill and cascades through visual events.
- [ ] Build and install a debug Android APK; record low/midrange device responsiveness.
- [ ] Verify a release AAB export/signing path without committing credentials.
- [ ] Export/test Web (desktop Chrome/Firefox, Android Chrome, iOS Safari where available).
- [ ] Run a 30-second particle stress test, gather FPS and memory measurements.
- [ ] Close engine decision only after results are recorded in [ENGINE_EVALUATION.md](ENGINE_EVALUATION.md).

**Gate:** no serious Android/browser blockers, reproducible exports, responsive touch and acceptable device performance.

## P0 — Phase 1: Match-3 engine (first implementation)

**Deliverable:** a real, mouse-and-touch-playable 8 x 8 board using placeholder/generated geometric crystals.

- [ ] Initialize Godot 4.7.2 + GDScript and a GitHub Actions headless test workflow.
- [ ] Define board, crystal, action, match and objective models.
- [x] Generate a board with no starting matches and at least one legal swap.
- [x] Implement orthogonal touch/mouse swaps and invalid move rejection.\n- [ ] Animate swap/rollback with clear visual feedback.
- [x] Consume one move for a valid swap and zero for invalid swaps.
- [x] Detect 3+ horizontal/vertical runs and intersections.
- [x] Resolve clears, gravity, refill and repeated cascades in the pure rules engine.
- [x] Temporarily lock input while basic result feedback plays.\n- [ ] Add ordered domain events and proper multi-stage animation locking.
- [x] Detect deadlocks and generate a fresh legal board (blocker-free prototype only).
- [x] Add one total-collection target and basic win/loss.
- [x] Add seeded rules tests; expand edge-case and device coverage.

**Exit gate:** five minutes of continuous play without incorrect counts, frozen board, duplicate actions, or crashes; tests green; at least one playable level reaches both win and loss outcomes.

## P1 — Phase 2: Gameplay depth (not started)

**Deliverable:** the original Cosmic Crystals mechanic set.

- [ ] Four-match Star Beam (row/column).
- [ ] Five-match Supernova.
- [ ] T/L Cosmic Bomb and precedence handling.
- [ ] Defined special + special combinations.
- [ ] Asteroid blockers with health and adjacent-clear damage.
- [ ] Nova energy accumulation, ready state and cancelable targeting.
- [ ] Nova Pulse row + column effect, objective damage, zero-move use.
- [ ] Score and three-star rating.
- [ ] Five complete level configurations with tutorial ramps.
- [ ] Regression tests for chained effects, blocked cells and level-end edges.

**Exit gate:** special pieces behave deterministically, Nova resolves correctly, and all five levels can be won legitimately with the intended mechanics.

## P1 — Phase 3: Core user journey (not started)

**Deliverable:** persistent progression and interface.

- [ ] Home, puzzle, pause, victory and defeat screens.
- [ ] Basic Lyra galaxy map with five connected level nodes.
- [ ] Locked/unlocked/completed nodes and best-stars display.
- [ ] Save settings and progression locally with schema version.
- [ ] Contextual tutorial for swaps, beams, blockers, and Nova.
- [ ] Settings for sound/music and reduced motion.
- [ ] Clear readable objective, moves, score, star and Nova HUD.

**Exit gate:** a new player can start, learn, win level 1, unlock level 2, reload and resume progression without developer intervention.

## P2 — Phase 4: Visual identity and UX

- [ ] Replace placeholder tiles with the six unique silhouette-based crystals.
- [ ] Implement a polished dark cosmic color system and contrast audit.
- [ ] Add restrained swap, clear, fall, cascade and special effects.
- [ ] Add original or properly licensed music and sound, user-mutable.
- [ ] Add constellation illumination and victory celebrations.
- [ ] Polish onboarding, errors, focus/touch affordances and accessibility.

**Exit gate:** UI is readable and responsive on small phones, animations don't interfere with rules, and reduced-motion mode is respected.

## P2 — Phase 5: Cross-platform validation

- [ ] Test recent desktop browsers and mobile Safari/Chrome.
- [ ] Check portrait phone safe areas, short-screen layout and scaling.
- [ ] Profile long cascades and special combinations on representative devices.
- [ ] Export native Godot Android APK and signed AAB, then verify the install and signing workflow. Test web export and later iOS export separately.
- [ ] Validate pause/resume, audio unlocking, touch and save behavior on devices.
- [ ] Document development, build and release steps.

**Exit gate:** reproducible browser build and device-tested packaged builds; no blocker bugs.

## P3 — After MVP

- [ ] Expand from 5 to 20 curated levels.
- [ ] Expand from 1 to 4 constellations.
- [ ] Add additional blockers/goals, then explore Gravity Flux.
- [ ] Add analytics and playtest-informed difficulty tuning only with appropriate privacy design.
- [ ] Consider daily challenges, cloud saves and other ongoing content later.

## Definition of done for each gameplay feature

- Works from both mouse and touch.
- Domain code is separated from visual animation.
- Correct behavior is covered by a deterministic test.
- New feature doesn't break existing save data.
- Clear user feedback and accessible affordances exist.
- Godot project import/parser and automated tests pass; export and device validation must pass before platform claims.

## Suggested first three engineering changes

1. **Project bootstrapping:** Godot 4.7.2/GDScript prototype, basic scene and passing headless CI; Android/web export remains open.
2. **Pure board engine:** seeded generation, swap validation and match/cascade tests already present; expand for specials and blockers.
3. **Turn resolver:** existing synchronous gravity/refill/cascades and basic HUD; refactor to event-driven animation and broaden tests.

No implementation task should be marked finished based solely on this document; verify it in source and tests.

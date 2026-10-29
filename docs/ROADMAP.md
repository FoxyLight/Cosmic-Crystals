# Development Roadmap

**Status snapshot:** 2026-10-29  
**Goal:** Android-first Godot game, one polished five-level Lyra constellation, then verified Google Play distribution.  
**Source of truth for acceptance:** [Milestone register](MILESTONES.md) and the linked GitHub issues. This roadmap summarizes execution order, not a promise of release dates.

## Verified foundation (complete)

- [x] Godot 4.7.2 GDScript + Compatibility renderer project committed to `main`.
- [x] Procedural 8×8 board with six crystal kinds and mouse/touch swap input.
- [x] Seeded starting boards with legal moves and no pre-existing matches.
- [x] 3+ match scanning, intersection deduplication, valid/invalid swaps, gravity, refill and cascades.
- [x] Basic total-crystal objective, move counter, score and win/loss flow.
- [x] Headless import/test and 120-frame smoke-check workflow passed.

**Evidence:** [PR #5](https://github.com/FoxyLight/Cosmic-Crystals/pull/5), [GitHub Actions success](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40935869782).

**Important limitations:** The board currently resolves synchronously with a simple result flash. The above evidence is **not** a verified Android APK, signed AAB, browser export, particle benchmark or five-level game.

## Priority 0: Engine feasibility and robust interaction (M0 + M1 in parallel)

### M0: Android / web proof of concept | [Issue #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4)

- [ ] Export a debug APK and perform at least one real Android device test.
- [ ] Prove release AAB signing/export without exposing credentials.
- [ ] Export Godot web build and test desktop/mobile browsers.
- [ ] Record FPS, RAM, load time, gestures, safe areas and pause/resume behavior.
- [ ] Add effects stress benchmark and document engine go/no-go.
- [ ] Review required native SDK capabilities before final engine approval.

**Exit gate:** documented Android+web export paths, physical-device evidence and explicit production engine sign-off. See [Engine Evaluation](ENGINE_EVALUATION.md), [QA Plan](QA_TEST_PLAN.md) and [Export Guide](ANDROID_EXPORT.md).

### M1: Reliable, animated match-3 loop | [Issue #3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3)

- [ ] Return ordered swap/match/clear/drop/spawn/cascade events from deterministic rules.
- [ ] Animate valid swaps and invalid-swap rollback.
- [ ] Animate gravity, refill, cascades and deadlock recovery; enforce input lock.
- [ ] Verify exact move costs, score and objective collection through chained events.
- [ ] Add regression tests for last-move victory, restart/pause during effects and deadlocks.
- [ ] Do extended manual mouse/touch playthroughs and fix stuck-board problems.

**Exit gate:** reliable, readable gameplay on a stable board, tested with both input modalities. No double moves, frozen cascades or wrong win/loss counts.

## Priority 1: Distinctive cosmic gameplay and a complete player journey

### M2: Cosmic mechanics | [Issue #6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6)

- [ ] Straight four-match Star Beam.
- [ ] Straight five-match Supernova; T/L Cosmic Bomb and explicit creation precedence.
- [ ] Deterministic special+special interactions, with chain-reaction regression tests.
- [ ] Asteroid blockers and correct adjacent/special-effect damage.
- [ ] Nova energy meter, cancelable targeting, row+column blast and zero-move activation.
- [ ] Balance specials and Nova energy through repeated playtests.

### M3: Five-level Lyra vertical slice | [Issue #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7)

- [ ] Data-driven levels 1–5, gradually introducing collections, specials, blockers and Nova.
- [ ] Three-star thresholds, scored wins and losses, moves and collection objectives.
- [ ] Home screen, galaxy map, pause, results and tutorial flow.
- [ ] Best-stars and unlock tracking, saved locally using a validated versioned schema.
- [ ] End-to-end tests for progression, replay, restart, and corrupted/old saves.

**Exit gate:** a first-time player can finish five levels, relight Lyra nodes, close/reopen the game and retain valid progress. The separately published 20-level/four-constellation vision is *not* counted as implemented here.

## Priority 2: Quality and publication

### M4: Visual/audio/mobile UX | [Issue #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8)

- [ ] Six uniquely shaped jewel-like crystals with clear selected/special states.
- [ ] Polished nebula backdrop, low-cost particle effects, feedback and constellations.
- [ ] Responsive HUD and safe-area-aware portrait layouts.
- [ ] Original/properly licensed music and sound with separate controls.
- [ ] Reduced motion, visual clarity, contrast and smaller-device checks.

### M5: Cross-platform release candidate and QA | [Issue #9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9)

- [ ] Run full five-level regression tests on modest and recent Android hardware.
- [ ] Test supported web browsers and interaction/resume edge cases.
- [ ] Measure sustained performance, memory and startup on chosen device classes.
- [ ] Verify signed build process and app data/permission compliance.
- [ ] Resolve critical/high issues and record QA evidence.

### M6: Google Play release readiness | [Issue #10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10)

- [ ] Confirm package identifier, release versioning, signing ownership and Play requirements.
- [ ] Prepare original listing, store graphics, support details, and accurate privacy/data disclosures.
- [ ] Test a signed AAB in an internal/closed track, capture feedback and fix blockers.
- [ ] Record publication decision, tag release and document exact build/commit.
- [ ] Distinguish Play test distribution from **public production availability**.

**Exit gate:** the first five-level build is actually verified through the selected Play release process. See [Release Plan](RELEASE_PLAN.md).

## Priority 3: Post-MVP (not blocking initial Android launch)

### M7: Larger galaxy and optional iOS | [Issue #11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11)

- [ ] Design and test levels 6–20, with four constellations.
- [ ] Consider Gravity Flux, extra blockers and daily content only after balancing.
- [ ] Prove native iOS export, signing and device compatibility as a separate project gate.
- [ ] Reevaluate cloud saves, analytics, monetization and account systems based on explicit requirements.

## Work sequencing

M0 and M1 can progress in parallel. M2 relies on M1's event/state foundations. M3 relies on M2 for intended tutorial content. M4 can prototype visuals concurrently but cannot close until M3 is integrated. M5 requires M0–M4 evidence; M6 requires M5. M7 is out of scope for the first release.

**Change-control rule:** update the milestone issue first, update [PROJECT_STATUS.md](PROJECT_STATUS.md) whenever state changes, and revise this roadmap if critical path/scope changes. Do not turn unchecked tasks into checkmarks without verification. There are no committed delivery dates or assigned team owners.

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

**Important limitations:** The original foundation used a simple result flash. PR #13 adds event-driven playback and successful automated Android **debug APK** and web export artifacts; these are **not** physical-device/browser tests, a signed Play AAB or a five-level game. See [M0/M1 implementation notes](M0_M1_IMPLEMENTATION.md).

## Priority 0: Engine feasibility and robust interaction (M0 + M1 in parallel)

### M0: Android / web proof of concept | [Issue #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4)

- [x] Generate a debug Android APK using pinned Godot 4.7.2 templates in CI.
- [ ] Install the APK and complete a physical Android touch/performance test.
- [ ] Prove release AAB signing/export without exposing credentials.
- [x] Export the Godot HTML5 build and upload a web artifact in CI.
- [ ] Serve and test the build on desktop/mobile browsers.
- [ ] Record FPS, RAM, load time, gestures, safe areas and pause/resume behavior.
- [x] Add a selectable 30-second synthetic draw/FPS stress mode.
- [ ] Gather real-device measurements and document production engine go/no-go.
- [ ] Review required native SDK capabilities before final engine approval.

**Exit gate:** documented Android+web export paths, physical-device evidence and explicit production engine sign-off. See [Engine Evaluation](ENGINE_EVALUATION.md), [QA Plan](QA_TEST_PLAN.md) and [Export Guide](ANDROID_EXPORT.md).

**Replay/deadlock usability fix:** [PR #22](https://github.com/FoxyLight/Cosmic-Crystals/pull/22) corrects a reset-like behavior: after quickly reaching the 30-crystal goal via specials, any touch previously restarted the board. The result screen now requires **PLAY AGAIN**, and deadlock recovery rearranges the original gem inventory instead of generating a new distribution. [Issue #21](https://github.com/FoxyLight/Cosmic-Crystals/issues/21) tracks phone verification.

### M1: Reliable, animated match-3 loop | [Issue #3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3)

- [x] Return ordered immutable swap/clear/fall/refill/reshuffle events from seeded board rules.
- [x] Animate valid swaps and adjacent invalid-swap rollback.
- [x] Animate gravity, refill and cascades with a locked input phase; reshuffle has a simple fade transition.
- [ ] Validate animation and input on physical Android.
- [x] Expand deterministic tests to validate event replay, cleared totals and score consistency.
- [ ] Add regression tests for last-move victory, restart/pause during effects and deadlocks.
- [ ] Do extended manual mouse/touch playthroughs and fix stuck-board problems.

**Exit gate:** reliable, readable gameplay on a stable board, tested with both input modalities. No double moves, frozen cascades or wrong win/loss counts.

**Gameplay playtest gate:** On 2026-10-29, the player reported **human Android playtest PASS** following the Star Beam/combo/Nova fixes, explicit replay and deadlock shuffle patch, and automatic APK versioning. See [Android Playtest Report](ANDROID_PLAYTEST_2026_10_29.md). The basic Android gameplay experience now has positive feedback; systematic device metrics, browser checks, AAB and other M0/M1 tasks remain open. **New M2 slice:** asteroid blockers and damage/interaction/gravity/deadlock tests are implemented; new Android acceptance is pending.

## Priority 1: Distinctive cosmic gameplay and a complete player journey

**M2 reliability fix:** After the first special-piece phone playtest, the player reported missing Star Beam creation. [Bug #17](https://github.com/FoxyLight/Cosmic-Crystals/issues/17) identified a gameplay-scene parse error suppressed by green CI. [PR #18](https://github.com/FoxyLight/Cosmic-Crystals/pull/18) corrects the scene and adds a real-scene four-match smoke test with fail-on-Godot-errors CI. Retesting on a phone is pending; M2 stays open.

**Special combo audit:** After the global scene-loader fix, we added [issue #19](https://github.com/FoxyLight/Cosmic-Crystals/issues/19) to verify all 16 ordered special combinations across six layouts, including Nova chains and real-scene gameplay. A power-overlay disappearance during unrelated clear animations was fixed. Automated compatibility passed on the feature branch; Android retesting is pending. See [M2 Gameplay Guide](M2_SPECIALS_NOVA.md).

### M2: Cosmic mechanics | [Issue #6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6)

**Playable M2 mechanics:** specials, combo unions, targetable Nova and the
[asteroid slice](M2_ASTEROIDS.md) are implemented. Fixed HP, one hit per wave,
power damage, segmented refill, blocked deadlocks and real-scene final-move
outcomes are automated. New Android blocker acceptance and balance remain open.

- [x] Straight four-match Star Beam, horizontal/vertical orientations and line clear.
- [x] Straight five-match Supernova, T/L Cosmic Bomb and deterministic five > T/L > four precedence.
- [x] Implement first-pass Beam+Beam, Beam+Bomb, Bomb+Bomb and Supernova combos with no double-counting.
- [ ] Android playtest and tune special combinations and long-chain behavior.
- [x] Asteroid blockers, adjacent/special/Nova damage, segmented physics and deterministic tests.
- [ ] Physical Android acceptance of the new asteroid slice; tune the six-rock test round.
- [x] Add 20-charge Nova meter, cancelable targeting, row+column blast and zero-move activation.
- [ ] Balance specials and Nova energy on physical Android, and add edge-case chain tests.

### M3: Five-level Lyra vertical slice | [Issue #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7)

- [ ] Data-driven levels 1–5, gradually introducing collections, specials, blockers and Nova.
- [ ] Three-star thresholds, scored wins and losses, moves and collection objectives.
- [ ] Home screen, galaxy map, pause, results and tutorial flow.
- [ ] Best-stars and unlock tracking, saved locally using a validated versioned schema.
- [ ] End-to-end tests for progression, replay, restart, and corrupted/old saves.

**Exit gate:** a first-time player can finish five levels, relight Lyra nodes, close/reopen the game and retain valid progress. The separately published 20-level/four-constellation vision is *not* counted as implemented here.

## Priority 2: Quality and publication

### M4: Visual/audio/mobile UX | [Issue #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8)

**Presentation implementation (`0.3.1`):** gameplay and results now follow the
earlier browser/Android look, with responsive/safe-area geometry, native readable
HUD, goal art, local fonts, improved facets, blue/green separation and help/pause.
The 1,459-check UI suite passes; physical Android visual and exported-browser
acceptance remain open. This is a bounded M4 slice before M3, not a campaign or
complete accessibility/audio milestone. See [Visual Pass](VISUAL_PASS.md).


**Device feedback:** Warm amber and white/ice opal were initially hard to distinguish. The procedural contrast fix is specified in [Crystal Visual Identity](VISUAL_PALETTE.md); only automated verification is available until the updated APK is playtested.

- [x] Differentiate the six **prototype** crystal types by contour and dark per-kind outlines; add regression tests for warm Solar Amber vs icy Lunar Opal (PR #14).
- [ ] Create production-quality jewel assets and distinct selected/special states.
- [ ] Polished nebula backdrop, low-cost particle effects, feedback and constellations.
- [ ] Responsive HUD and safe-area-aware portrait layouts.
- [ ] Original/properly licensed music and sound with separate controls.
- [ ] Obtain a physical Android re-test of Amber/Opal readability and document screen/device conditions.
- [ ] Complete broader reduced-motion, visual clarity, contrast and smaller-device checks.

### M5: Cross-platform release candidate and QA | [Issue #9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9)

- [ ] Run full five-level regression tests on modest and recent Android hardware.
- [ ] Test supported web browsers and interaction/resume edge cases.
- [ ] Measure sustained performance, memory and startup on chosen device classes.
- [ ] Verify signed build process and app data/permission compliance.
- [ ] Resolve critical/high issues and record QA evidence.

**Build identification:** The Android debug preview pipeline now automatically stamps versionCode/versionName based on run number, attempt and git SHA, validates the APK manifest, and packages checksum/build metadata. See [Android APK Versioning](ANDROID_VERSIONING.md) and [issue #23](https://github.com/FoxyLight/Cosmic-Crystals/issues/23). Production AAB signing/versioning remains a separate acceptance gate.

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

# Milestones and Delivery Gates

**As of:** 2026-10-29  
**Project:** Cosmic Crystals: A Starweaver's Journey  
**Plan:** Android-first Godot 4.7.2 + GDScript, with a web build and iOS as a later option  
**Delivery model:** Outcome-based checkpoints. Dates, budgets, and assignees are intentionally **uncommitted**, not estimates.

## How to track

Each milestone is represented by a **dedicated GitHub tracking issue** with checkboxes and measurable acceptance criteria. These are **issue-based milestone trackers**, not GitHub's native Milestones objects. The connected GitHub tools cannot create or edit native Milestone objects. If native objects are later created manually, link the same M0–M7 codes and issues; do not maintain two contradictory status sources.

- **Primary progress truth:** checked/unchecked tasks and evidence in the linked GitHub issue. The current [M0/M1 implementation](M0_M1_IMPLEMENTATION.md) records a verified CI APK/Web export; these do not close either milestone.
- **Overview:** this register and [PROJECT_STATUS.md](PROJECT_STATUS.md).
- **Acceptance criteria and test environments:** [QA_TEST_PLAN.md](QA_TEST_PLAN.md).
- **Product requirements:** [GAME_DESIGN.md](GAME_DESIGN.md).
- **Architecture decision:** [DECISIONS.md](DECISIONS.md).
- **Release readiness:** [RELEASE_PLAN.md](RELEASE_PLAN.md).

A milestone is **Done** only if all its exit criteria have demonstrable evidence (test run, tagged build, device/browser test notes or approved sign-off). An unchecked item is not complete merely because a plan describes it.

**Latest Android test evidence (2026-10-29):** The player reports the latest gameplay smoke test **passed**. See [Android Playtest Report](ANDROID_PLAYTEST_2026_10_29.md). This partially satisfies M0's physical APK playability and M1/M2's human feedback, **not** comprehensive hardware QA, browser, AAB or asteroid-blocker acceptance.

## Milestone register

| ID | Milestone | Status at baseline | Depends on | Exit / acceptance evidence | GitHub |
| --- | --- | --- | --- | --- | --- |
| Foundation | Godot spike, seeded rules and headless CI | **Done** | None | [Merged PR #5](https://github.com/FoxyLight/Cosmic-Crystals/pull/5), [CI pass](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40935869782) | [#1](https://github.com/FoxyLight/Cosmic-Crystals/issues/1), [#2](https://github.com/FoxyLight/Cosmic-Crystals/issues/2) |
| **M0** | Android/web engine viability | **In progress** | Foundation | Debug APK on physical Android, signed AAB pipeline, tested web export, recorded performance and explicit engine go/no-go | [#4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4) |
| **M1** | Stable animated match-3 loop | **In progress** | Foundation | Ordered event-driven swaps/rollback/cascades, correct game-state transitions, deterministic edge-case tests and touch-playthrough | [#3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3) |
| **M2** | Cosmic powers and blockers | **In progress** | M1 | Star Beam, Bomb, Supernova, combinations, asteroids and Nova Pulse all working/tested | [#6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6) |
| **M3** | Five-level Lyra vertical slice | **Not started** | M1 + M2 | Five tunable/winnable levels, galaxy map, tutorials, star rankings and versioned local saves | [#7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7) |
| **M4** | Art, sound, accessibility and mobile UX | **Not started** | M1; integrates with M3 | Readable cosmic art, effects, audio settings, reduced motion and phone-safe UI | [#8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) |
| **M5** | Android and web release candidate | **Not started** | M0–M4 | Device/browser matrix green, no critical/high bugs, signed release candidate and recorded QA evidence | [#9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) |
| **M6** | First Google Play distribution | **Not started** | M5 | Play testing track accepted, required listing/compliance complete, release tagged, publication decision recorded | [#10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10) |
| **M7** | Post-MVP expansion and optional iOS | **Not started / deferred** | M5; post-M6 feedback preferred | Levels 6–20, four constellations, balance/regression coverage; separate iOS feasibility gate | [#11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11) |

**Critical path:** Foundation → M1 → M2 → M3 → M4 integration → M5 → M6.  
**Parallel gate:** M0 can run alongside M1; its device/export outcome is a blocker to M5.  
**After first release:** M7 is not required for a five-level MVP.

## What is in the current game

**M2 progress:** PR #16 implemented Star Beam, Cosmic Bomb, Supernova and Nova Pulse; PR #18 repaired the shared gameplay-script loading bug. [Compatibility audit #19](https://github.com/FoxyLight/Cosmic-Crystals/issues/19) now tests all 96 ordered special-pair/position scenarios plus real scene creation/targeting. A separate overlay regression for surviving special pieces has been fixed. See the [M2 guide](M2_SPECIALS_NOVA.md) for confirmed automated coverage. **M2 remains open** for asteroid blockers, balance, device acceptance and broader gameplay QA.


The repository's one-scene prototype provides an 8×8 board with six crystal kinds, touch/mouse selection, match scanning, seeded legal board generation, gravity/refill/cascades, a total collection target, moves and a basic win/loss. The rules compute a turn synchronously but now return an ordered event sequence for animated swap/clear/drop/refill playback (PR #13); the production special-piece/level state model is still missing. It is **not** a five-level game and does **not** yet include specials, Nova, asteroid blockers, persistent progression, platform binaries or commercial SDKs.

The separately published concept advertises 20 levels and four constellations. Treat that as a **vision**, not a repository acceptance claim.

## Phase gates

### M0 — Evidence needed before production engine sign-off

1. Android **debug APK artifact generated in CI** (achieved); APK installed on a real phone with touch flows checked and results recorded (outstanding).
2. Release AAB signing/export demonstrated without committing credentials.
3. Godot **Web export generated in CI** (achieved); hosted and tested in desktop and Android browsers, with iOS Safari checked where available (outstanding).
4. FPS, memory, loading and touch responsiveness observations recorded with device model/OS/build.
5. Engine go/no-go published in [ENGINE_EVALUATION.md](ENGINE_EVALUATION.md). A green headless CI run alone **does not** satisfy M0.

### M1–M2 — Gameplay correctness

The model must distinguish valid/invalid swaps and serialize resolution, prevent double collection through intersections and chain effects, preserve rules during shuffle, and adjudicate the last move only after cascades settle. Every new rule gets a deterministic regression test.

### M3–M4 — First player journey

A player can finish five Lyra levels, retain stars and unlocked progress after restart, understand objectives and powers, and navigate every screen with readable, usable touch targets on representative phone sizes.

**Android build traceability:** CI preview APKs are now uniquely numbered and include verified embedded versionCode/versionName, commit SHA and SHA-256 manifest. See [APK Versioning](ANDROID_VERSIONING.md). Optional stable debug signing must be configured privately, and release AAB signing is still an M6 gate. Do not equate versioned debug APKs with signed releases.

### M5–M6 — Distribution readiness

Test both Android and web release candidates, sign and validate builds, check permissions/privacy/asset licenses and confirm applicable Google Play requirements **at submission time**. A Play submission is not the same as a public release.

## Change control

- Update the milestone issue as a task moves forward. Link merged PRs and test evidence.
- Update this register and [PROJECT_STATUS.md](PROJECT_STATUS.md) whenever a milestone changes status, the critical path changes, or scope is renegotiated.
- Add new work under an existing milestone unless it changes a release gate.
- Do **not** invent sprint deadlines or assign owners without agreement.
- Keep technical implementation changes and milestone updates together in one PR when practical.

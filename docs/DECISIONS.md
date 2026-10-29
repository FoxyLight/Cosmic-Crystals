# Architecture and Product Decisions

A compact decision log. New substantial decisions should be recorded here with date, status, alternatives, rationale and reversal conditions. **Accepted for a prototype** is not the same as production-tested.

## ADR-001: Android-first native-capable Godot project

- **Date:** 2026-10-29
- **Status:** **Adopted for development spike; production confirmation pending M0**
- **Decision:** Use **Godot 4.7.2 standard edition, GDScript and Compatibility renderer** in one project for Android and web; iOS may follow.
- **Why:** Integrated 2D tools, native Android packaging path, no engine royalties, an editor-friendly visual pipeline, and a shared GDScript project with a web export route.
- **Alternatives:** Phaser 3 + TypeScript + Capacitor (web-first, Android WebView); Defold (lean Lua engine); Cocos Creator (TypeScript native/web); Unity (commercial ecosystem, heavier).
- **Consequences:** Need real APK, AAB, browser and device measurements. Godot web relies on WebGL2/WASM and may be less friendly to certain mobile browsers; mobile ad/billing SDKs require validation.
- **Revisit when:** Engine cannot meet chosen target-device/browser experience or a mandatory SDK is unsupported.
- **Evidence:** [Engine Evaluation](ENGINE_EVALUATION.md), [M0 #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4), [PR #5](https://github.com/FoxyLight/Cosmic-Crystals/pull/5).

## ADR-002: Stable, deterministic game rules are separate from presentation

- **Date:** 2026-10-29
- **Status:** Accepted; initial implementation partly complete
- **Decision:** Keep board rules in GDScript domain classes independent of scene Nodes. Use a seedable RNG and an ordered event stream for future animations.
- **Why:** Reproducible bug reports, testability, reliable cascades, input-lock correctness and clean handling of power-up chains.
- **Consequences:** A small architectural investment is needed before elaborate animations and combos. The current prototype resolves the board synchronously; event-driven animations are **M1 work**.
- **Evidence:** `scripts/board.gd`, `tests/test_board.gd`, [M1 #3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3).

## ADR-003: Five polished levels before 20-level expansion

- **Date:** 2026-10-29
- **Status:** Accepted target scope
- **Decision:** First demonstrable MVP is five distinct levels in one Lyra constellation, with stars, unlocks, goal/move constraints and saved progression.
- **Why:** Prove a genuinely fun and reliable core before adding content at scale.
- **Deferred:** Published concept's 20 levels / four constellations, Gravity Flux, daily challenges, cloud saves and monetization.
- **Evidence:** [Game Design](GAME_DESIGN.md), [M3 #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7), [M7 #11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11).

## ADR-004: Offline-first progress and no backend for MVP

- **Date:** 2026-10-29
- **Status:** Planned, not implemented
- **Decision:** Store validated, versioned player progression and audio/motion settings locally using Godot's `user://` data, without user accounts or server dependencies.
- **Why:** Keep first release simpler, resilient and playable without connectivity.
- **Consequences:** Cloud syncing, cross-device transfer and account recovery are out of scope until explicitly prioritized.
- **Evidence:** [Technical Architecture](TECHNICAL_ARCHITECTURE.md), [M3 #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7).

## ADR-005: Automated, traceable Android debug APK versions

- **Date:** 2026-10-29
- **Status:** Accepted for debug preview builds; release AAB policy remains M6 work
- **Decision:** Keep the SemVer base in `VERSION`, derive preview `versionCode` from GitHub Actions run number and run attempt, and derive `versionName`/artifact name from base version, run and short Git SHA. Verify **embedded APK manifest metadata** with Android `aapt` before uploading the artifact.
- **Why:** The original test APKs all used versionCode `1` and a generic filename, making it difficult to tell builds apart and preventing normal Android version ordering.
- **Consequences:** Artifacts include source SHA, code/name, checksum and signing mode. CI run numbers increase across newly triggered builds. Rerunning an older workflow can still have a lower code than an already-installed newer build; users must install the latest build. A versionCode change does **not** resolve different signing keys.
- **Signing policy:** Optional repository Actions secret `COSMIC_DEBUG_KEYSTORE_BASE64` supplies a reusable **debug-only** signing identity for **main-branch builds**; otherwise CI intentionally uses disposable debug signing and declares `ephemeral-ci`. Never commit signing keys or use the debug identity for production.
- **Revisit when:** Creating the M5/M6 signed AAB pipeline; allocate Play release version codes independently, preserving Google Play monotonicity and secure release signing.
- **Evidence:** [Android APK Versioning](ANDROID_VERSIONING.md), [issue #23](https://github.com/FoxyLight/Cosmic-Crystals/issues/23), [PR #24](https://github.com/FoxyLight/Cosmic-Crystals/pull/24).

## Pending decisions

| Decision | Default until decided | Trigger | Tracker |
| --- | --- | --- | --- |
| Go/no-go for Godot production | Godot continues as development candidate | M0 APK/AAB/Web/device evidence | [#4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4) |
| In-app purchases / ads / analytics | No monetization SDK or account requirement | Explicit product/business decision, SDK feasibility | [#10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10) |
| Numerical device performance budgets | 60 FPS aspirational, hardware floors TBD | Real test-device selection and measurements | [#9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) |
| iOS native delivery date/scope | Deferred | Stable Android/web, verified build tooling | [#11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11) |
| Special crystal interactions | Initial behaviors in design; exact matrix needs testing | M2 implementation and balancing | [#6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6) |

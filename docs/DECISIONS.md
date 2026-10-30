# Current decision precedence

**2026-10-30 ADR-006 supersedes earlier platform plans.** Android-only; Web/HTML5, browser QA, desktop distribution and iOS development/feasibility are out of scope. Prior ADR text below is historical rationale, not active platform scope.

# Architecture and Product Decisions

A compact decision log. New substantial decisions should be recorded here with date, status, alternatives, rationale and reversal conditions. **Accepted for a prototype** is not the same as production-tested.

## ADR-001: Android-first native-capable Godot project (historical platform scope; superseded by ADR-006)

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
- **Status:** Implemented and protected by deterministic tests. M1 extended hardware acceptance remains separately open.
- **Decision:** Keep board rules in GDScript domain classes independent of scene Nodes. Use a seedable RNG and an ordered event stream for future animations.
- **Why:** Reproducible bug reports, testability, reliable cascades, input-lock correctness and clean handling of power-up chains.
- **Consequences:** The deterministic board resolves turns into ordered snapshots while the UI animates them with an input lock and commits results only after playback. The five-level campaign uses a separate GameSession. Long-session hardware acceptance remains in M1; this architecture is implemented.
- **Evidence:** `scripts/board.gd`, `tests/test_board.gd`, [M1 #3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3).

## ADR-003: Five polished levels before 20-level expansion

- **Date:** 2026-10-29
- **Status:** Implemented and user Android playtest-accepted at M3; expanded content deferred.
- **Decision:** First demonstrable MVP is five distinct levels in one Lyra constellation, with stars, unlocks, goal/move constraints and saved progression.
- **Why:** Prove a genuinely fun and reliable core before adding content at scale.
- **Deferred:** Published concept's 20 levels / four constellations, Gravity Flux, daily challenges, cloud saves and monetization.
- **Evidence:** [Game Design](GAME_DESIGN.md), [M3 #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7), [M7 #11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11).

## ADR-004: Offline-first progress and no backend for MVP

- **Date:** 2026-10-29
- **Status:** Implemented (schema 1); save integrity and upgrades tested; unfinished boards intentionally not persisted.
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
- **Signing policy:** Main builds now have a configured private reusable **debug-only** signing identity, separately protected password and public certificate pin. CI verifies the actual signature; PR builds remain `ephemeral-ci`. Main #110 reports `persistent-secret` and `stable_signing_verified=true`, and a real-phone 10801 → 11001 update retained the saved file byte for byte. Legacy builds signed with another key cannot update in place. Never commit keys or use debug signing for a production AAB.
- **Revisit when:** Creating the M5/M6 signed AAB pipeline; allocate Play release version codes independently, preserving Google Play monotonicity and secure release signing.
- **Evidence:** [Android APK Versioning](ANDROID_VERSIONING.md), [issue #23](https://github.com/FoxyLight/Cosmic-Crystals/issues/23), [PR #24](https://github.com/FoxyLight/Cosmic-Crystals/pull/24).

## Pending decisions

| Decision | Default until decided | Trigger | Tracker |
| --- | --- | --- | --- |
| Go/no-go for Godot production | Godot continues as development candidate | Android device metrics, AAB route and M0 evidence | [#4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4) |
| In-app purchases / ads / analytics | No monetization SDK or account requirement | Explicit product/business decision, SDK feasibility | [#10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10) |
| Numerical device performance budgets | 60 FPS aspirational, hardware floors TBD | Real test-device selection and measurements | [#9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) |
| Special crystal interactions | Defined matrix and blocker interactions are automated and phone-smoked; detailed feel/balance remains open | M2 player tuning | [#6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6) |


## ADR-006: Android-only M4 and save-safe stable debug updates

Date: 2026-10-30. Accepted by explicit owner assignment. Android is the sole supported product; keep shared rules/assets/tests, remove Web exports/checks, no iOS or desktop distribution. Desktop/headless Godot remains a development environment. Supersedes cross-platform scope in ADR-001 and older roadmap/release/QA documents. Revisit only on a new owner decision.

Use a reusable private debug keystore and pinned certificate in main Actions secrets; PRs receive no key. Keep package ID and schema-1 earned records. Never uninstall/clear a player installation without explicit approval. Old ephemeral-key installations require a verified backup and separately approved migration; new-key compatibility cannot be manufactured. Debug identity is separate from future production/upload signing.

M4 uses original deterministic synthesized audio with source/provenance, bounded mixing and independent music/SFX/master preferences. Reduced motion is presentation-only. No new gameplay systems/cloud/ads/store work. #8 remains open until new human Android acceptance.


## ADR-007: Match-gem movement defines four-match Star Beam direction

- **Date:** 2026-10-30
- **Status:** Implemented in product 0.5.1 and verified in merged [PR #34](https://github.com/FoxyLight/Cosmic-Crystals/pull/34).
- **Decision:** Left/right movement creates a horizontal row Beam; up/down movement creates a vertical column Beam, including a completed match that runs in the other axis. Match-four creates one reward subject to existing Bomb/Supernova precedence and the level's allowed power types.
- **Rationale:** The player explicitly requested the Beam to follow the gem's movement rather than the matched line's axis.
- **Evidence:** [Main run #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426) passed 53 directional gesture/scene assertions and all other tests; later blast direction and saved-power identities remain unchanged.
- **Pending:** Human Android confirmation of the new 0.5.1 gameplay/visual behavior, tracked in M4 #8. This is not a reason to reset or migrate saves.

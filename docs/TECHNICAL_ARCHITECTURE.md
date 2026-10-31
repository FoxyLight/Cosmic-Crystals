# Technical Architecture

Godot 4.7.2 standard, GDScript, Compatibility renderer. Android-only product and export. Desktop/headless execution is development only; Web/HTML5 and iOS are out of scope. Production AAB/store work remains separate.

**Current checkpoint:** Source **0.5.4**, M5 stabilization. Accepted baseline: main `77eb492c`, 0.5.3 build 12901; M3 #7, M4 #8 and settings #37 closed. The player approved the promoted baseline and **Larger Text** sizing/label. Android-only main #129 passed 15 Godot suites, nine Python tests, APK and emulator same-key update checks. M5 adds a sixteenth Godot suite, four Python probe tests and cancellation fixes; final merged build receipt is tracked in #9. [Current status](PROJECT_STATUS.md), [M5 implementation/evidence](M5_ANDROID_RC_QA.md). Quantitative physical-device/audio/scaling QA and M6 production AAB remain outstanding.

## Implemented layers

| File | Responsibility |
| --- | --- |
| `scripts/board.gd` | Seeded matching, swaps, legal moves, physics; kind list defaults to six |
| `scripts/cosmic_board.gd` | Specials/Nova/asteroids, union damage, segmented gravity, inventory shuffle; default mechanics unchanged |
| `data/lyra_levels.json` | Five authored seeds/openings, mechanics, goals, budgets, ratings, tutorials |
| `scripts/level_catalog.gd` | Validate/catalog/copy definitions; reject invalid or disabled-mechanic goals |
| `scripts/game_session.gd` | Level board/counters, pending-turn token, commit boundary, objectives/result/rating |
| `scripts/progress_store.gd` | Schema-1 records, unlocks, tutorials/settings, safe writes/backup/recovery |
| `scripts/prototype.gd` | Campaign controller and existing animated board view; historical filename retained |
| `scripts/game_layout.gd` | Shared safe-area geometry; portrait phone stack / wide Android tablet layout |
| `scripts/game_hud.gd` | Native goals/stats/modals, focus, confirmations, results/earned stars |
| `scripts/campaign_view.gd` | Home, five-node map, selected-level preview, state display/settings |

There is no backend/account/cloud dependency. No additional constellation is
created. Original code-native art and bundled SIL OFL fonts work offline.

## Turn contract

`GameSession.begin_swap/begin_nova` invokes deterministic rules and returns
immutable events. Board resolution remains synchronous; score, moves, objectives
and results are **not committed yet**. A pending-turn token locks a second
action. The scene plays every swap/rollback, clear, reward, rock hit and fall/
cascade event, then calls `commit_outcome` once. Duplicate/stale callbacks cannot
grant twice. Victory takes priority on the last move and requires all goals.
Nova retains zero-move/reset/no-self-charge behavior.

UI navigation/restart is rejected during effects; Android Back queues pause
until settlement. Restart/leave confirmations act only while idle. Results use
explicit GUI buttons; extra touches cannot leak into a fresh board. Board input
uses `_unhandled_input`, after GUI controls consume their own pointer events.

## Level configuration

The catalog validates five ordered IDs, seeds/budgets, 3-6 distinct kind IDs,
power IDs, Nova flag, 1/2-HP rocks, max three supported goals, ordered thresholds
and starter-power occupancy. Session setup resets seeded RNG after kind setup;
level 2 has an authored four-match opening. Powers travel with their crystals.

Only small board hooks changed: generation/refill select from `kinds`, reward
creation checks `enabled_powers`, and `can_use_nova` checks the stage flag. With
default fields, every original suite retains its prior behavior. Match scanning,
scoring, unioned footprints, damage and shuffle algorithms are not rewritten.
See [powers](M2_SPECIALS_NOVA.md) and [rocks](M2_ASTEROIDS.md).

## Progress and persistence

`user://lyra-progress.json`, schema 1: five completed flags, five best rating
scores/stars, derived highest-unlocked, seen tutorial IDs, reduced motion. Wins
record only after stable terminal commit. No unfinished board is persisted.
Replay independently maximizes best score/stars.

Writes validate, flush and verify `.tmp`, back up only a valid prior primary,
and rename the temporary over the primary. Loading tries supported primary,
backup, then defaults with a notice. Future schemas remain read-only. Android private user storage is the sole supported save backend. [Full policy](M3_LYRA_CAMPAIGN.md).

## Presentation and quality gates

400x760 canvas expands to the viewport. Native safe-area pixels convert to canvas
units. Campaign captions reserve two readable lines. Bundled vector icons avoid
system-glyph fallback; reduced motion shortens events without changing outcomes.

Ten pre-M3 suites stay active through explicit legacy-practice fixtures. Three
new suites cover authored sessions, 120 balance runs, recovery and actual scene
touch play through all five levels/reload. CI imports assets first and retains
the strict Godot log guard. Version/manifest/checksum/signing checks remain;
new checks inspect the exported catalog/licenses in actual Android APK packages.

[QA](QA_TEST_PLAN.md) and [M3 acceptance](M3_LYRA_CAMPAIGN.md) distinguish code
execution/exports from new human acceptance and platform measurements.


## M4 Android presentation/services

`game_audio.gd`: 22 cached original PCM resources, six SFX voices with per-cue cooldown and drop-on-cap layering, two 0.8-second crossfading music voices. Context refresh never restarts an unchanged track. Focus and application-pause blockers are independent; mute/zero master prevents new effects, music resumes its saved position. Headless uses silent contract dispatch to avoid audio-device dependence; native speaker acceptance is separate.

`settings_view.gd`: blocking Android-safe sheet from Home/pause, 48-unit sliders/toggles/buttons, master/music/SFX, mute, reduced motion and larger reading text. `progress_store.gd` schema remains 1 with additive validated defaults: old campaign records are unchanged. No partial board is serialized.

`performance_monitor.gd`: at most 600 observed frame samples, mean/p95, engine FPS/static memory, session loads, turns/event counts. Android writes `user://performance-last.json` on backgrounding. This is observed runtime data, not a claim of physical-device testing. UI refresh is state-keyed, layout is cached by size/insets, clear membership cached per event; decorative board redraw is capped at 15 Hz while active animations retain frame updates. Reduced-motion idle redraw stops. No board scoring/RNG changes.

CI is Android-only: strict Godot logs, all old tests plus M4, unique versioning/actual signature+pin checks, audio/catalog/license packing and isolated-emulator same-key update proof. Private main debug key is excluded from PRs and deleted from runner after use. See ANDROID_VERSIONING.md. No installation or migration of the user's old different-certificate game is automatic.


## M5 stabilization checkpoint, 2026-10-31

Source base **0.5.4** follows accepted 0.5.3 build 12901. [M5 audit and human checklist](M5_ANDROID_RC_QA.md) records verified cancellation fixes, 16 Godot suites and 13 Python tests, coverage boundaries and outstanding device measurements. M3 #7, M4 #8 and settings #37 are closed; M5 #9 remains open. Earlier numbered builds in this document are historical evidence, not the current APK. Read final candidate commit/version/signing in its main CI artifact and #9 delivery receipt.

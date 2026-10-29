# M2 First Playable Slice: Special Crystals and Nova Pulse

**Snapshot:** 2026-10-29  
**Implementation:** [scripts/cosmic_board.gd](../scripts/cosmic_board.gd), [scripts/prototype.gd](../scripts/prototype.gd)  
**Tests:** [tests/test_powers.gd](../tests/test_powers.gd)  
**Milestone:** [M2 issue #6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6)  
**Status:** Code and automated tests implemented; Android/web exports are automated. Physical-phone gameplay and balancing have **not** been verified for this patch.

## What is implemented

This incremental extension inherits the previous [CrystalBoard](../scripts/board.gd) matching/generation behavior, leaving the proven M1 rules/tests intact. It adds a second **64-cell special-type array** alongside the six crystal kinds:

| Type ID | Name | Created by | Activated by | Effect |
| --- | --- | --- | --- | --- |
| 0 | Normal | Default state | 3+ matching | Normal crystal clear |
| 1 | **Star Beam (row)** | Four-in-a-row, horizontally | Swap or clear matching tile | Clears all 8 tiles in its row |
| 2 | **Star Beam (column)** | Four-in-a-row, vertically | Swap or clear matching tile | Clears all 8 tiles in its column |
| 3 | **Cosmic Bomb** | A T/L intersection | Swap or clear matching tile | Clears up to 9 tiles around its center |
| 4 | **Supernova** | Straight match of five or more | Swap or clear matching tile | Clears all tiles of a chosen color |

**Creation precedence:** Straight five or longer > T/L intersection > straight four. Only the initial **player-created normal match** may forge one new power per move. The swap destination is preferred when part of the highest-priority pattern; otherwise choose the source/first match candidate deterministically. Gravity/cascades currently do not mint further specials.

**Activation:** Swapping a special with an adjacent normal or special is a valid move even if the new positions don't form three matching colors. It consumes one move and activates the swapped special. If a special is caught in a normal match, another special's area, or Nova Pulse, it also activates. Every affected tile is unioned before clearing so overlaps cannot increase score/collection counts twice. Effects can trigger other specials.

**Supernova targeting:** When actively swapped, the other piece's color is its target. When passively activated by a match or area blast, it targets its own color. Two adjacent Supernovas clear the full board. These are **first-pass balancing rules**, not permanent production balance decisions.

## Special + special first-pass combos

- **Beam + Beam:** both fire; row/column unions are collected once per tile.
- **Beam + Bomb:** line clear plus 3×3 bomb blast; any newly hit specials also trigger.
- **Bomb + Bomb:** two 3×3 blasts, with overlap counted once.
- **Supernova + Beam/Bomb:** Supernova removes the partner's color across the board, while the partner fires its normal area effect.
- **Supernova + Supernova:** all currently occupied cells clear; cascading refills settle deterministically.

These interactions currently rely on the union of both pieces' effects, not spectacular bespoke transformation effects. Production animation and balance refinement remain in M2/M4.

## Signature power: Nova Pulse

- The prototype starts with **zero charge**. Each cleared crystal adds one Nova energy; every activated special adds a provisional bonus of four. Charge is capped at **20**.
- The HUD shows **NOVA X/20**. At 20, tap **NOVA** and choose any board tile.
- Its target row and column clear as a union of **up to 15 tiles**, plus any chain-triggered powers. It collects crystals and scores from resulting cascades.
- Nova consumes **zero regular moves** and **resets the meter to zero**. Nova's own clears do not immediately recharge Nova.
- Tap the NOVA control again, or cancel by tapping outside the board, to leave targeting with full charge intact.
- Input is locked while the resulting clear, gravity, refill and cascade animations play.
- The Nova threshold and special-activation bonuses are currently named constants; later level tuning should move these into validated level data.

## Rules and event architecture

New [CosmicBoard](../scripts/cosmic_board.gd) extends the proven M1 seeded board instead of modifying its baseline `play_swap` tests. Its `play_swap(a,b)` and `use_nova(index)` result dictionaries include:

- `valid`, `used_nova`, `cleared`, `score`, `collected`, `cascades`, `reshuffled`
- `created` (special type), `activated` (trigger count), `nova_gain`
- `events`, ordered snapshots of gems **and** specials with `before`, `after`, `specials_before`, `specials_after`.

Events are `swap`, `swap_back`, `clear`, `special_create`, `fall`, and `reshuffle`. The renderer only animates these results; it does not manipulate model state or calculate scoring.

Each falling event also carries the special type with the moving gem, preventing special rewards from becoming detached from their underlying crystal during gravity. Basic overlay icons distinguish horizontal and vertical beams, bombs and Supernovas, and the prior six-color/six-shape accessibility improvements remain in use.

## Android regression: four-match Star Beam (2026-10-29)

**Reported:** A player who tested the first M2 Android APK observed that matching four crystals did not create a Star Beam.

**Confirmed engineering cause:** The initial M2 `scripts/prototype.gd` contained two literal backslash-`t` tokens in the Nova HUD instead of indentation. Godot logged `SCRIPT ERROR: Parse Error` and `Failed to load script` when importing/launching the gameplay scene, yet returned process exit code 0. Our original CI incorrectly called this a passing gameplay build. A downloadable APK alone did not prove the playable scene loaded. See [bug #17](https://github.com/FoxyLight/Cosmic-Crystals/issues/17).

**Fix:** Correct the GDScript indentation, strengthen Star Beam's persistent cyan ring and line icon, and show the exact power name (`STAR BEAM FORGED!`) in result feedback.

**Preventing recurrence:** CI now wraps every Godot parsing, test, scene launch and export command in a log-error guard that fails if Godot reports script/parser/runtime errors, even with a zero exit code. The guard has self-tests. `tests/test_game_scene.gd` loads the real `Prototype.tscn`, verifies the gameplay script is attached and initialized, performs a four-gem swap through its `_take_turn()` entry point, and asserts that a row Star Beam is forged.

**Phone acceptance pending:** Install the new debug APK, make an intentional four-gem straight match (not just a cascade), and confirm that a bright cyan-ringed stripe gem survives the fall, that the `STAR BEAM FORGED!` message appears, and that swapping the new Beam later clears a row. Document device result in [#17](https://github.com/FoxyLight/Cosmic-Crystals/issues/17). **Do not assume this is fixed on the user's device until retested.**

## Validation

The existing CI workflow still runs the M1 seeded tests, M4 gem-contrast tests, and a 120-frame headless scene smoke, with Godot 4.7.2 Web/Android-debug exports. It additionally runs:

```bash
godot --headless --path . --script res://tests/test_powers.gd
```

The M2 tests cover reward creation (four horizontal, four vertical, five straight, T intersection), precedence, special activation, Beam+Beam/Beam+Bomb/Bomb+Bomb/Supernova combos, Nova charge/cost/row-column union, special/gem event-frame continuity, overlap deduplication and seeded normal swaps.

**CI success proves code execution and APK/web artifact creation, not that complex special animations are readable or responsive on an actual Android phone.** The next field test should check target selection and cancellation and validate charge rate.

## Next unresolved work

- **Asteroid blockers** and their adjacent-match, special-area and Nova damage. A blocker cannot safely be added as just a gem kind; model blocker durability/occupancy separately and test gravity and deadlock behavior.
- Human testing of all power combinations on a physical Android device; adjust HUD/target areas, animations and balance based on evidence.
- More stress/property tests for long power-trigger chains, limiting cascade iterations without deleting previously earned specials, and last-move outcomes.
- Data-driven Nova energy and per-level rules; additional polished effects and accessibility controls.
- Five-level Lyra progression, saved progress and constellation map in **M3**, not this patch.

**Keep M2 open** until blockers, balance and physical-device acceptance are complete. Record outcomes in [Project Status](PROJECT_STATUS.md), [Roadmap](ROADMAP.md) and [QA Plan](QA_TEST_PLAN.md).

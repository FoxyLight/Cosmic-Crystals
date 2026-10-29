# M2 Asteroid Blockers

**Implemented:** 2026-10-29. Product version `0.3.0`; CI adds the unique run,
attempt and commit to every APK. **Physical Android acceptance: pending.**
The earlier player-reported Android pass covers the pre-blocker baseline only.

## Rules

- `CosmicBoard.asteroids` is a separate 64-integer durability array: `0` means
  no blocker, `2` is armored, `1` is cracked. An occupied blocker cell has
  `cells[index] == EMPTY` and `specials[index] == NONE`. It has no gem color.
- `place_asteroids(layout)` is an explicit setup operation. It validates the
  complete layout before applying it, supports durability 1–2, and refuses to
  overwrite an existing blocker or earned special. Turns never call it.
- Asteroids cannot swap, match, fall, or be selected as ordinary gems. Matches
  stop at their empty crystal slot. Nova may target any tile, including a rock.
- A rock takes **one durability damage per resolution wave** if directly hit by
  a special/Nova footprint or orthogonally beside a cleared crystal. Adjacency
  applies to ordinary matches and special-cleared crystals alike. The retained
  gem that forges a reward still counts as part of its matching group.
- All simultaneous direct hits, adjacent clears and chained powers are unioned.
  Multiple beams/bombs and Nova's row/column intersection never damage the same
  rock twice in that wave. A later cascade/wave can hit it again. Diagonals and
  row wrapping do not count. Rocks do not relay damage to neighboring rocks.
- Beams and Nova continue through rocks. Bombs use their normal 3×3 footprint.
  A Supernova has no rock color to select: its cleared target-color crystals
  damage neighboring rocks. Two Supernovas directly hit the entire board.
- At zero durability the cell becomes playable and fills during the next fall.
  Destruction does not itself explode or trigger neighboring powers.

## Physics and recovery

Fixed rocks split each column into independent vertical regions. Gems fall
straight down inside their region; there is no lateral sliding or tunneling.
Each region refills independently. For a region below a rock, the renderer
fades new gems in at its top (`segment_top`) rather than drawing them falling
through the rock. Removing a rock reconnects the column on the following fall.
Powers travel with their own crystal through falls and inventory shuffles.

Legal-move detection excludes rocks/empty cells, even when the neighboring gem
is special. Deadlocks shuffle only occupied movable crystal/power pairs,
retaining exact inventory, rock positions/durability, score, moves and charge.
The existing bounded 2,048-attempt search accepts only a match-free board with a
legal swap. If an unsupported/impossible custom layout cannot be recovered,
it restores the original inventory and reports an engine error; it never
regenerates the board. Future level data must validate topology/playability.
The authored six-rock prototype layout is checked across 125 seeds.

## Prototype objective and presentation

The single-round test remains **18 moves and 30 collected crystals**, now also
requiring **all six asteroids destroyed**. Four start armored and two cracked.
The HUD shows remaining rocks; results show remaining rocks and crystals.
Both goals are checked only after all events finish; completing both on the
last move wins. Nova still spends no move, resets charge and cannot recharge
itself. Only cleared crystals score (`10 × cascade depth`) and charge Nova;
asteroid hits/destruction grant no extra points, collection or energy. Turn
results separately expose `asteroids_hit` and `asteroids_destroyed`.

Original procedural bronze/slate rocks have irregular contours, craters,
one/two bright durability pips, and a glowing fracture in the damaged state.
An impact ring, short local shake and fading fragments distinguish hits from
destruction. The six gem silhouettes/colors are unchanged. There is no new
camera shake, external art dependency, campaign, save system or monetization.

## Event contract

Every event includes immutable `asteroids_before` and `asteroids_after`, beside
the existing gem and special snapshots. A wave plays:

`clear → optional special_create → optional asteroid_hit → fall`

The `asteroid_hit` event has sorted unique `indices`, sorted `destroyed`, and
`chain`. It updates only durability. Crystal-only score lives in `clear`.
The scene renders the current event's durability snapshot, never a future final
model state. Inputs remain locked until the entire sequence settles. Existing
swap/rollback, power creation, reshuffle and explicit PLAY AGAIN remain intact.

## Automated evidence

Godot **4.7.2 stable**, local Windows headless checks:

- `tests/test_asteroids.gd`: **862,246 assertions, zero failures**. Covers setup,
  atomic rejection, damage/destruction, real match damage, row/column reach,
  all four powers, all 16 ordered power pairs with blockers, Nova chains,
  overlap deduplication, a 58-power dense chain, segmented refill, blocked deadlocks, isolated earned
  power recovery and 125 seeds × 12 paired turns with full event replay.
- `tests/test_asteroid_scene.gd`: **46 assertions, zero failures**. Real scene
  setup, three-state snapshot playback, input locking, impact-before-fall,
  invalid/valid move costs, zero-move Nova, both goals and last-move win/loss.
  Also executed with the desktop Compatibility renderer without engine errors.
- All seven existing Godot test scripts remain active and pass, including the
  original 96-case special matrix. Android version-policy tests remain active.
- CI wraps both new scripts with the existing strict Godot error-log guard.
  Android/Web exports and manifest verification remain separate jobs. Use the
  PR and merged-main Actions runs for artifact evidence, not these local tests.

These tests do not measure Android FPS, prove small-screen readability or
establish final balance. The six-rock, 18-move round is a mechanics playtest,
not an authored M3 level or a promise of a particular win rate.

## Android acceptance checklist

Record exact APK versionName/versionCode, commit, checksum, signing mode,
device and Android version from the versioned artifact and installation.

1. Identify solid two-pip and cracked one-pip rocks; all six gems remain clear.
2. Try dragging/tapping a rock: it stays put and consumes no move. Make an
   adjacent match: two pips become one and a crack appears; hit again to break.
3. Fire row/column Beams through multiple rocks and trigger a Bomb nearby.
   Confirm each rock loses one durability per wave and beams reach past it.
4. Trigger Supernova color clears near rocks, then Beam+Bomb and other combos.
   Simultaneous overlap gives one hit; a subsequent cascade can give another.
5. Charge Nova, cancel without cost, then target a rock. Its row and column
   fire, surrounding powers chain, and moves remain unchanged.
6. Watch falls/refills above and below rocks; no crystal crosses a solid rock.
   After destruction the gap reconnects and fills without a board reset.
7. Finish both goals: final result waits for cascades and stays until PLAY AGAIN.
   Exhaust moves with rocks remaining: defeat shows the incomplete goal.
8. Try quick gestures during impacts/cascades and a longer play session; report
   stuck inputs, incorrect counters, unreadable effects or performance changes.

**M2 issue #6 stays open** for this new Android playtest, power/Nova balance and
broader device/performance/interruption acceptance. Five-level Lyra, map and
progress saves remain M3. AAB/store release remains later work.

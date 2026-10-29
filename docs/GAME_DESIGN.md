# Game Design Document

**Project:** Cosmic Crystals: A Starweaver's Journey  
**Status:** Design specification; not evidence of implemented code  
**Last updated:** 2026-10-29

## 1. Vision

**Tagline:** Restore the stars. Awaken the universe.

A premium-feeling, accessible match-3 puzzle adventure with short sessions (target 2–5 minutes), reliable tactile feedback, original cosmic-fantasy art, and a meaningful meta-progression loop: complete puzzles to rekindle constellations.

The Great Eclipse has silenced the galaxy. As a **Starweaver**, the player collects energy from cosmic crystals, unlocks Nova Pulse powers, and restores forgotten star systems. The story establishes an emotional reward but never interrupts puzzle readability.

**Design pillars**

1. **Instantly understandable:** swap adjacent pieces; match at least three.
2. **Every move feels good:** accurate response, smooth falls, crisp match feedback.
3. **Skillful combos:** special-piece creation and cascades reward forward planning.
4. **Visible restoration:** winning levels relights the galaxy map.
5. **Accessible and portable:** readable at phone size; playable with touch or mouse.

## 2. Primary gameplay loop

1. Choose an available star node on the galaxy map.
2. Read the target crystals/blockers and move budget.
3. Swap adjacent crystals to create lines of at least three.
4. Clear, score, apply objective progress and Nova energy, then resolve gravity and all cascades.
5. Create and trigger special crystals; activate Nova Pulse when charged.
6. Win when all goals are complete, or lose when moves are exhausted after the board resolves.
7. Award 1–3 stars, save progress, unlock the next star node, and illuminate the map.

### Board and swaps

- Default board: **8 columns x 8 rows**.
- Six normal crystal types.
- A swap involves orthogonally adjacent, swappable crystals only.
- A normal swap must create a match to be valid; otherwise animate back and consume **zero** moves.
- A valid swap consumes **exactly one** move.
- A swap of two adjacent special pieces can be valid even without a normal three-match if it produces a defined combination.
- Disable input throughout swap animation, match resolution, gravity, refill, and cascades.
- New ordinary boards start without spontaneous matches and contain at least one legal move.
- If no legal move remains after resolution, reshuffle movable normal pieces while preserving special/locked/blocker constraints; retry until a valid non-matching board exists, or use a documented fallback.

### Match resolution

- Detect all horizontal and vertical runs of at least three.
- Merge intersecting runs into groups before clearing so pieces are not counted twice.
- Determine special creation **from player-caused matches** using documented precedence; cascades can still trigger existing special pieces.
- Apply all resulting clears, blocker damage, collection and scores once per tile.
- Fill holes by gravity and spawn new crystals from above; repeat until stable.
- Resolve victory/defeat only after all cascades and special effects have completed.
- Avoid an endless cascade by guarding iterations and exposing deterministic debug seeds.

## 3. Normal crystals

| Crystal | Visual identity | Palette |
| --- | --- | --- |
| Nebula Amethyst | Faceted diamond | Nebula violet `#7C4DFF` |
| Solar Amber | Six-ray sunburst with warm nucleus | Rich orange-gold `#ED9B18`, dark-brown edge `#733907` |
| Quantum Sapphire | Pointed hexagon | Starlight cyan / blue `#39D5FF` |
| Plasma Ruby | Angular star | Plasma pink `#FF66BF` |
| Aurora Emerald | Teardrop | Aurora mint `#44E3B2` |
| Lunar Opal | Tall fractured ice shard (prototype silhouette) | Frosted blue-white `#D0EDFF`, navy edge `#2F5C88` |

Color **and** silhouette must identify each type. Highlight, selected, special, and disabled states need distinct treatment. **Mobile feedback (2026-10-29):** the first yellow and white pieces were too similar. The procedural prototype now uses a stronger warm Solar Amber, icy blue-white Lunar Opal, six unique crystal contours, dark per-kind outlines, and hue-matched facets. See [Crystal Visual Identity](VISUAL_PALETTE.md) for exact fill/edge/facet tokens, automated assertions and remaining Android device acceptance checks. Do not treat these prototype shapes as finalized art.

## 4. Special pieces

| Trigger | Created piece | Behavior |
| --- | --- | --- |
| Straight four-match | **Star Beam** | Clear one full row or column on activation, orientation based on formation |
| Straight five-match | **Supernova** | Clear all crystals of the type it is swapped/activated against |
| T or L match | **Cosmic Bomb** | Clear a 3 x 3 area centered on activation |
| Swap of two specials | **Special combination** | Larger, explicitly defined combined effect |

Design decision for implementation: prioritize straight-five detection over T/L over straight-four when a player move generates overlapping candidate patterns; create only one special piece per eligible match group (prefer swapped destination if it belongs to the group). Document and test alternate patterns and tie cases. Create special pieces after clearing matched originals so they remain on the board. Do not let special-creation logic unexpectedly erase a reward.

**Combination behavior** is a balancing item. Initially implement and test at least Beam+Beam, Bomb+Bomb, and Beam+Bomb, then define Supernova combinations explicitly before shipping. Never silently treat an unsupported special combination as a normal swap.

**Implementation status (M2 prototype, 2026-10-29):** The first playable Star Beam, Cosmic Bomb, Supernova and Nova Pulse rules are now in [CosmicBoard](../scripts/cosmic_board.gd) and documented with first-pass combo behavior in [M2 Gameplay Guide](M2_SPECIALS_NOVA.md). This prototype supports swap activation without a 3-match, one initial special creation per move, and chain-triggered blast unions. Exact balancing, asteroid blockers and human Android acceptance remain outstanding; see M2 issue #6.

## 5. Signature power: Nova Pulse

- Successful matches generate Nova energy; cascades and special combinations award configurable bonuses.
- A visible Nova Meter fills and communicates the charged state.
- When full, tapping/clicking the Nova control enters **targeting mode**.
- Selecting a board tile clears its entire row and column, damaging blockers per standard rules and counting cleared crystals toward objectives.
- Nova Pulse consumes **zero** regular moves, then resets the meter to empty.
- The player can cancel targeting without using the charge.
- Targeting is unavailable while a board animation is in flight.
- Prototype values: charge threshold 20, +1 per cleared crystal, +4 per triggered special, capped at 20. These are **currently constants**, not yet per-level data. Move threshold and bonuses to level data before M3 balancing is finalized.

Balance goal: powerful enough to rescue a tough board, but infrequent enough that planning matters.

## 6. Objectives and blockers

**MVP objectives**

- Collect N crystals of specified types.
- Destroy N asteroid blockers (damage via adjacent match, special effect, or Nova Pulse).

**Later:** star-node activation, chained obstacles, locked tiles, Gravity Flux (direction-altering gravity).

Each level is a data file: id, board or generation seed, available types, moves, goal set, obstacles, star thresholds, tutorial cues. Level rules should be configurable without engine edits.

## 7. Progression

**MVP:** five distinct, tested levels in the Lyra constellation.

1. Introduction: single-type collection and swap tutorial.
2. Two-type collection and limited moves.
3. Create and trigger Star Beam.
4. Clear asteroid blockers.
5. Combine collection, blockers, and Nova Pulse.

**Expanded vision:** 20 levels across four constellations, as advertised by the separately published site. Not yet verified in this repository. Build after the five-level vertical slice is stable.

Complete a level to unlock the next node. Three-star ranking should use per-level score thresholds and/or remaining-move bonuses; choose one consistent method and tune via playtesting. Save earned stars as the best performance, not just last attempt.

## 8. Screens

- **Home:** title, concise story invitation, Play, Settings, accessible mute.
- **Galaxy map:** current constellation, connected nodes, clearly locked/unlocked/completed states, earned stars and next available level.
- **Gameplay:** level, goals/progress, moves, score/star thresholds, Nova Meter, board, pause.
- **Pause:** resume, restart, return to map, settings.
- **Victory:** stars, score, recovered star animation, next level.
- **Defeat:** unmet objective(s), retry, return to map.
- **Settings:** music, sound, reduced motion and accessibility preferences.
- **Tutorial:** short contextual instruction, never blocking advanced players repeatedly.

## 9. Art, interaction and audio

**Palette:** Deep Space `#0B102A`, Nebula Violet `#7C4DFF`, Starlight Cyan `#39D5FF`, Solar Gold `#FFCB65`, Plasma Pink `#FF66BF`, Aurora Mint `#44E3B2`.

Use layers of distant stars/nebulae around a visually high-contrast board. Crystals should look jewel-like and luminous without excessive bloom. Ensure puzzle goals and remaining moves read clearly above the board.

Feedback hierarchy: swap confirmation -> crisp clearing -> short sparkle -> cascade accent -> rare spectacular special/Nova celebration. Avoid overly long animations that make fast play feel sluggish.

Audio: optional background ambience; unobtrusive selection/match sounds; escalating cascade chimes; distinct special and Nova impacts; victory cue. Settings must mute immediately. Reduced-motion mode should shorten/remove strong camera shake, flashes and prolonged particles. Prefer original or properly licensed assets.

## 10. Target platforms and accessibility

- Primary design: portrait mobile with thumb-friendly targets and safe-area support.
- Desktop: centered puzzle area with adaptive HUD around it.
- Input: drag/swipe and tap-two-to-swap plus mouse.
- Independent readable silhouettes; scalable text and strong contrast.
- Aim for smooth 60 FPS on capable devices, with performance degradation gracefully handled.
- Android-first: Godot native debug APK builds and Web export are automated in CI; real Android/browser test coverage and a signed release AAB remain separate validation gates.

## 11. Non-goals for first playable release

Accounts, backend, monetization, cloud saves, daily events, leaderboards, Gravity Flux, dozens of extra levels, and advanced cinematic scenes should **not** block the MVP.

## 12. Open balancing questions

- Exact move counts, collection targets, star scores, and Nova charge rate.
- Special + special interaction matrix.
- Whether Nova charge persists between levels (proposed: no).
- How asteroid adjacency damage behaves for intersecting clears.
- How many new special pieces cascades may create (proposed: only match-created specials from player swaps at first).
- Animation timing on low-end mobile devices.

All of the above need empirical playtesting before being treated as finalized design.

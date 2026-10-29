# Technical Architecture

**Status:** Proposed implementation architecture; no engine source code is present yet (2026-10-29).

## Stack and delivery

- **TypeScript**: domain model, board logic, data types, strict typing.
- **Phaser 3**: board presentation, tweens, particles, audio, input and game scenes.
- **Vite**: local dev server, production web builds.
- **Vitest** (proposed): pure logic tests and reproducible seeded scenarios.
- **Capacitor** (later): wrap the proven web app for Android and iOS. Do not start native builds until web gameplay is stable.

Use one gameplay model for desktop web, mobile web, and mobile app. Keep the rules platform-agnostic and rendering-independent.

## Suggested file structure

```text
src/
  main.ts
  game/
    domain/
      types.ts
      board.ts
      matches.ts
      swaps.ts
      gravity.ts
      refill.ts
      specialPieces.ts
      blockers.ts
      objectives.ts
      scoring.ts
      nova.ts
      legalMoves.ts
      resolveTurn.ts
    data/
      crystals.ts
      levels/
        001.ts ... 005.ts
    state/
      GameSession.ts
      ProgressStore.ts
    scenes/
      BootScene.ts
      HomeScene.ts
      GalaxyMapScene.ts
      PuzzleScene.ts
      ResultsScene.ts
    ui/
      BoardView.ts
      HudView.ts
      TutorialOverlay.ts
    input/
      swapGestures.ts
    audio/
      AudioManager.ts
    visuals/
      effects.ts
  tests/
    matches.test.ts
    swaps.test.ts
    gravity.test.ts
    resolveTurn.test.ts
    specials.test.ts
    legalMoves.test.ts
    objectives.test.ts
    nova.test.ts
    progress.test.ts
docs/
```

This structure is a guide, not an assertion that those files already exist. Adjust folder depth for the eventual implementation size.

## Pure domain model

Represent the board as a rectangular grid of cells. A cell may hold a movable piece, a blocker, or no occupant during resolution.

Avoid putting Phaser sprites, global scene objects or direct UI effects in the domain model.

Illustrative types:

```ts
type CrystalKind =
  | 'amethyst' | 'amber' | 'sapphire'
  | 'ruby' | 'emerald' | 'opal';

type SpecialKind = 'beam-row' | 'beam-column' | 'bomb' | 'supernova';

interface Crystal {
  id: string;
  kind: CrystalKind;
  special?: SpecialKind;
}

interface Position { row: number; col: number; }

interface BoardCell {
  crystal: Crystal | null;
  blocker?: { type: 'asteroid'; health: number };
}

interface LevelConfig {
  id: number;
  width: number;
  height: number;
  moves: number;
  objectives: Array<
    | { type: 'collect'; crystal: CrystalKind; count: number }
    | { type: 'destroy-asteroids'; count: number }
  >;
  starThresholds: [number, number, number];
}
```

Treat the above as an initial schema sketch; refine cell occupancy and blocker layering based on actual gameplay needs.

## Resolution state machine

A move should pass through a controlled state machine:

```text
IDLE -> SWAPPING -> VALIDATING
  invalid -> SWAP_BACK -> IDLE
  valid   -> RESOLVING
RESOLVING -> APPLY_EFFECTS -> COLLAPSE -> REFILL -> SCAN
  matches found -> RESOLVING
  stable -> CHECK_GOALS
CHECK_GOALS -> WON | LOST | IDLE
```

Nova targeting is a separate state reached from IDLE:

```text
IDLE -> NOVA_TARGETING -> RESOLVING -> ... -> CHECK_GOALS
           | cancel
           v
          IDLE
```

Implement an explicit input lock for every non-IDLE state. Asynchronous tweens should **render** an already computed set of domain events, not determine rule outcomes by timing side-effects.

## Determinism and testing

Inject a seedable random-number generator into initial board generation, refill and reshuffling. Avoid `Math.random()` inside domain functions.

`resolveTurn(board, action, level, rng)` should return a new state and an event sequence such as:

- `SwapStarted`, `SwapRejected`, `SwapAccepted`
- `MatchesFound`, `SpecialCreated`, `CrystalsCleared`
- `BlockerDamaged`, `CrystalsDropped`, `CrystalsSpawned`
- `ObjectiveAdvanced`, `NovaCharged`
- `BoardReshuffled`, `LevelWon`, `LevelLost`

The view can animate these in order without re-calculating game rules. All damage/counting should be idempotent within one resolution step to avoid double-collecting intersecting matches.

## High-risk edge cases

1. Horizontal and vertical matches intersect; count each tile once.
2. A five-match and T-match appear in one swap; deterministic special precedence.
3. Special effects trigger other specials; no recursive duplication or infinite loop.
4. A match clears the final objective while moves reach zero; victory wins after resolution.
5. Refill leaves no legal move; reshuffle without destroying objective/blocker state.
6. Tutorial overlays or pause are opened while animations are running; prevent illegal input and preserve pending state.
7. Restart during a cascade; cancel or isolate in-flight visuals.
8. Nova activates without using a move; cancel should preserve charge.
9. Direct touch drag and tap-to-swap inputs generate exactly one domain action per gesture.
10. Save data from an older version loads safely via schema versioning.

## Persisted data

For MVP, save only durable player progress and settings, not a half-resolved turn:

```ts
interface SaveData {
  schemaVersion: number;
  highestUnlockedLevel: number;
  bestStarsByLevel: Record<number, 0 | 1 | 2 | 3>;
  settings: {
    musicEnabled: boolean;
    soundEnabled: boolean;
    reducedMotion: boolean;
  };
}
```

On startup, validate/migrate data and fall back safely if it is malformed. Persist when a level is completed or a setting changes. Make progress independent of renderer/game scene lifecycle.

## Platform notes

- Calculate cell size from available viewport; avoid a board that clips on short phones.
- Respect CSS/env safe areas (or equivalent) for navigation/cutouts.
- Use device-pixel-ratio limits, pooled effects, and small texture atlases to reduce GPU overhead.
- Define pointer handling centrally and avoid duplicate touch/click listeners.
- Don't assume mobile browsers autoplay audio; unlock audio on user gesture.
- Support reduced motion in animation timelines.
- Test Android and iOS wrappers only after web release gates pass.

## CI and quality gates

Recommended scripts when implementation begins:

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc --noEmit && vite build",
    "test": "vitest run",
    "typecheck": "tsc --noEmit"
  }
}
```

Add automated CI to run type checking, tests and production build on pull requests. These commands are targets, not executable today because the repository does not yet contain package files.

# Cosmic Crystals: A Starweaver's Journey

**Restore the stars. Awaken the universe.**

Cosmic Crystals is a planned cross-platform match-3 puzzle adventure for the web, iOS, and Android. Players swap luminous crystals, charge the **Nova Pulse**, complete puzzle goals, and restore a galaxy extinguished by **The Great Eclipse**.

> **Repository status (2026-10-29):** This repository has been initialized with the concept and development specifications from the project planning conversations. **No gameplay source code has been committed yet.** A separately published concept/prototype exists at [Cosmic Crystals](https://cosmic-crystals-starweaver-jneal.fxylght.chatgpt.site), but its underlying source code has **not** been imported or verified here. The published page advertises 20 levels and four constellations; these are **not** claims about this repository's implementation.

## Start here

- [Game Design Document](docs/GAME_DESIGN.md): player fantasy, mechanics, special pieces, Nova Pulse, goals, progression, and art direction.
- [Technical Architecture](docs/TECHNICAL_ARCHITECTURE.md): cross-platform stack, game-state design, deterministic resolution, persistence, and testing.
- [Development Roadmap](docs/ROADMAP.md): prioritized implementation milestones and measurable acceptance criteria.
- [AI Build Prompt](docs/BUILD_PROMPT.md): consolidated agent-ready implementation brief.

## Intended first playable slice

- An 8 x 8 board with six differently shaped crystal types.
- Touch, tap, drag, and mouse swapping.
- Match detection; invalid-swap rollback; gravity, refill, and cascading.
- Objective collection, limited moves, score, win/loss conditions.
- Three special-piece types and an interactive Nova Pulse.
- Five designed, tested levels with three-star ratings and local progress.
- A basic galaxy map, victory/defeat screens, sound preferences, and responsive layouts.

The initial **five-level MVP** is intentionally smaller than the **20-level / four-constellation** vision advertised on the published site. Expand to 20 levels only after the core puzzle is proven reliable and fun.

## Technical direction

Proposed stack: **TypeScript + Phaser 3 + Vite**, with **Capacitor** for later iOS/Android packaging. Start with a browser-playable vertical slice and keep core board logic independent of rendering, input, and animation. No backend is required for the MVP.

## Working agreement

This repository, **[FoxyLight/Cosmic-Crystals](https://github.com/FoxyLight/Cosmic-Crystals)**, is the project's source-of-truth for future work. Record meaningful decisions and changes in the corresponding documentation, and develop features through reviewed, testable changes.

## Next action

Implement the Phase 1 match-3 game engine and automated tests from [ROADMAP.md](docs/ROADMAP.md). Do not mark features complete until they are implemented and verified in code.

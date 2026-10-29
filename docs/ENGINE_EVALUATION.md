# Engine Evaluation: Android-first Cosmic Crystals

**Date:** 2026-10-29  
**Status:** PROPOSED — requires a tested device/browser spike before replacing the current technical stack  
**Context:** The project aims for Android first, with web and iOS targets. The repository currently contains planning documents but no gameplay engine code.

## Decision question

Should Cosmic Crystals remain a Phaser 3 + TypeScript + Capacitor browser-first game, or switch to a native-capable engine before implementation?

## Constraints

- Casual, portrait-oriented 2D match-3 with an 8 x 8 board and six crystals.
- Smooth swaps, cascades, particles, shaders, special attacks, Nova Pulse and responsive UI.
- Android distribution via Google Play (AAB), with an installable APK for testing.
- A web-playable edition and potential iOS release without rewriting the core puzzle.
- Local progress, safe resume after backgrounding, and optional native services in the future.
- Low maintenance burden, small development team, reliable tests, no engine royalty lock-in where possible.

## Candidates

| Engine | Main language | Android delivery | Web delivery | Assessment |
| --- | --- | --- | --- | --- |
| **Godot 4.7.2** | GDScript | Native APK/AAB | HTML5/WebAssembly/WebGL2 | Best Android-first general choice |
| **Defold** | Lua | Native APK/AAB | HTML5 | Lean 2D option and strong fallback |
| **Cocos Creator 3.8 LTS** | TypeScript | Native Android | Web | Most attractive if retaining TypeScript and web parity matters |
| **Unity 6** | C# | Native APK/AAB | Web | Mature SDK integration and commercial tooling; heavier workflow |
| **Phaser 3 + Capacitor** | TypeScript | Android WebView container | Browser-first | Easiest browser-first workflow; Android depends on WebView and native packaging layer |

These are design assessments, not measured benchmark results.

## Provisional recommendation: Godot 4.7.2 with GDScript

Reasons:

1. Native Android game build and Play Store AAB distribution without wrapping an HTML5 game inside Android WebView.
2. Strong integrated 2D scene/editor workflows, particles, tweens, UI and touch handling suited to a polished puzzle game.
3. MIT license with no per-seat or royalty fees for using Godot.
4. Web and iOS exports preserve one game project, provided the team uses GDScript rather than C# for Godot 4 web support.
5. Android Java/Kotlin plugin APIs available for optional services.

**Web caveat:** Godot 4's web export requires WebGL 2 and WebAssembly, runs with Compatibility rendering, and may be less efficient than native builds on mobile browsers. We should specifically test Chrome Android, Safari iOS and the intended hosting environment. Default single-thread web export minimizes hosting complexities.

**Native service caveat:** Godot's mobile ad, attribution, purchase and analytics integration ecosystem is generally less turnkey than Unity's; each needed SDK must be validated, not assumed available.

**Scope caveat:** If browser reach, browser startup size and web advertising become the top business priorities, reconsider Cocos Creator or keep Phaser. If very small native game size and minimal overhead matter most, benchmark Defold.

## Proposed game architecture for Godot

```text
project.godot
scenes/
  app/Home.tscn
  app/GalaxyMap.tscn
  puzzle/PuzzleScreen.tscn
  puzzle/BoardView.tscn
  puzzle/CrystalView.tscn
  ui/GameplayHUD.tscn
scripts/
  domain/
    board.gd
    match_finder.gd
    turn_resolver.gd
    gravity.gd
    objectives.gd
    specials.gd
    nova.gd
    random_source.gd
  gameplay/
    game_session.gd
    input_controller.gd
  persistence/
    progress_store.gd
data/levels/
tests/
assets/
docs/
```

- Keep board rules and random generation separate from Godot Nodes, animations, sounds and inputs.
- Use seedable RNG and deterministic headless tests for matches, swaps, gravity, cascades, special combos, deadlocks and last-move victory.
- Animate domain events in view nodes after rules have been resolved.
- Use a controlled IDLE/SWAPPING/RESOLVING/NOVA_TARGETING/WON/LOST state machine.
- Version save data and validate locally stored progression and settings.

## Required decision spike

**Before changing the architecture roadmap or starting a full game implementation:**

1. **Godot:** Build one 8 x 8 touch-enabled board, swipe/tap swap, valid/invalid swap, one cascade, a 30-second particle stress test, and a basic HUD. Export APK, AAB and web.
2. **Cocos or Defold:** Build a comparable thin prototype if the Godot spike exposes serious limitations, prioritizing the most important competing constraint.
3. **Real-device QA:** Test at least one modest Android device plus a recent device. Check input latency, sustained frame rate, RAM usage, pause/resume, resolution/safe areas, cold start and APK/AAB size.
4. **Web QA:** Run the exported web build on desktop Chrome/Firefox and mobile Chrome/Safari; check loading, animation smoothness and touch behavior.
5. **Service risk:** If ads/IAP/analytics are planned, create a minimal integration proof-of-concept before locking the engine.

**Success:** Stable full match resolution, no duplicate input while resolving, no major device/browser blockers, reasonable build/download size, and clear implementation path for required platform services.

## Proposed changes after approval

- Replace Phaser+Vite+Capacitor references in README, TECHNICAL_ARCHITECTURE.md, ROADMAP.md and BUILD_PROMPT.md with Godot+GDScript.
- Replace the existing Phase 1 bootstrap issue with a Godot-specific implementation plan while preserving historical context.
- Create the actual Godot project and deterministic test harness.
- Keep the game design and UX requirements unchanged.

## Source material

- Godot Android export: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html
- Godot web export: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html
- Godot Android plugins: https://docs.godotengine.org/en/4.7/tutorials/platform/android/android_plugin.html
- Godot license: https://godotengine.org/license/
- Godot stable releases: https://godotengine.org/download/archive/
- Defold Android: https://defold.com/manuals/android/
- Cocos Creator native/web: https://docs.cocos.com/creator/3.8/manual/en/editor/publish/index.html
- Phaser: https://docs.phaser.io/
- Capacitor: https://capacitorjs.com/docs
- Unity pricing: https://unity.com/products/pricing-updates

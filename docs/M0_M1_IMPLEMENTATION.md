> **Historical milestone/build evidence.** For current source, accepted 0.5.3 build 12901, closed M3/M4/settings gates and active M5, see [PROJECT_STATUS](PROJECT_STATUS.md) and [M5 audit](M5_ANDROID_RC_QA.md). Status/next-step statements inside this earlier report apply to its recorded checkpoint.

# M0/M1 Implementation Notes: First Native/Web Build Artifacts

**Source branch / PR:** [#13](https://github.com/FoxyLight/Cosmic-Crystals/pull/13)  
**Build evidence:** [GitHub Actions run 40939726043](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40939726043)  
**Status:** Automated engine spike verified; physical Android install, real browser compatibility and production signing are **not** verified.

## What changed

1. `scripts/board.gd` now emits an ordered `events` array for each legal turn, with copies of `before`/`after` board state:
   - `swap`: swap indices and frames.
   - `swap_back`: rejected adjacent move returns without changing the final board or using a move.
   - `clear`: matched unique positions, chain and score delta.
   - `fall`: each surviving crystal's source/destination and newly spawned crystals' positions above the board.
   - `reshuffle`: deadlock recovery for the **blocker-free** prototype.
2. `scripts/prototype.gd` animates this event stream in order with an explicit `phase` lock. The authoritative board and scoring remain independent of animation.
3. Touch input handles swipe direction even if a finger crosses several tiles, chooses only an orthogonally adjacent target, and supports two-tap selection. Mouse and touch share the resolver; Godot's touch-emulates-mouse setting is disabled.
4. The HUD includes a **STRESS 30S** button that draws 260 synthetic animated glows and records a local average/minimum FPS. It is a rough drawing stress aid, **not** a production particle, battery, thermal or low-end Android benchmark.
5. `tests/test_board.gd` checks 125 deterministic seeds, invalid adjacent swaps with rollback events, complete event-frame continuity and stable outcomes, no double-counting, and a T-intersection.
6. `export_presets.cfg` includes the Web and Android **debug** export presets. `project.godot` enables Android ETC2/ASTC texture import.
7. GitHub Actions now builds Godot 4.7.2, runs headless checks, exports HTML5 and an ephemeral-key-signed Android debug APK, then uploads both as 7-day artifacts.

## Verified automated run

The workflow [run 40939726043](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40939726043) finished with all three jobs passing:

- `check`: Godot import/parser, seeded rules test and 120-frame headless scene smoke.
- `web-export`: generated nonempty `index.html`, `index.wasm` and `index.pck` and uploaded `cosmic-crystals-web`.
- `android-debug-export`: configured Java 17 and Android SDK, generated an ephemeral debug keystore, exported nonempty arm64 APK and uploaded `cosmic-crystals-android-debug`.

**Not proven by this workflow:** web playback in a real browser, touch handling on a phone, device FPS/memory/thermal behavior, release signing/AAB export or Google Play acceptance.

## Download and test artifacts

1. Open the GitHub Actions run above while signed into GitHub.
2. Under **Artifacts**, download `cosmic-crystals-android-debug` or `cosmic-crystals-web`.
3. Extract the ZIP locally.
4. Android: connect a compatible arm64 Android phone with USB debugging and run `adb install -r cosmic-crystals-debug.apk`. A previous build signed with a different ephemeral CI key may require **uninstalling** the old test app first; uninstall may erase prototype app data. Do not use this debug key for production.
5. Web: serve the extracted files via an HTTP server, e.g. `python -m http.server 8000` from the web directory. Open `http://localhost:8000` on desktop; for another device on the local network, use the development machine's reachable address and ensure firewall permissions. Do not open `index.html` using `file://`.
6. Record device/browser, build/commit, input reliability, baseline and stress FPS, startup and resume behavior in [QA_TEST_PLAN.md](QA_TEST_PLAN.md) and [M0 #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4).

GitHub Actions artifacts expire and are not stable release URLs. For reproducibility, the workflow and tagged commit are more important than the artifact archive.

## What remains open

### M0

- Android physical-device install, touch/pausing, FPS/RAM and cutout checks.
- Desktop and Android browser compatibility, plus iOS Safari if available.
- Release AAB **Gradle** export pipeline using privately owned release credentials. Godot requires a Gradle template for AAB; the debug APK uses a pre-built export template. This is not the same task.
- Repeatable results on modest and modern Android hardware, then production engine go/no-go.

### M1

- Human gameplay check of animation timings, interaction and visible gravity.
- Tests for last-move victory and restart/pause during animation.
- Full production state model, blockers/specials-aware reshuffle and later animated special chains.
- Integration of goals and UI into structured level/session data.

**Important:** Do not close M0/M1 on CI alone. See [MILESTONES.md](MILESTONES.md) for the exit gates.

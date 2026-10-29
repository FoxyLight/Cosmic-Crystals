# Android and Web Validation Guide (Godot 4.7.2)

**Status:** Instructions only. No device-based Android APK/AAB or web export has yet been verified.

## 1. Open and run the prototype

Install [Godot 4.7.2 standard edition](https://godotengine.org/download/archive/4.7.2-stable/) (not the .NET edition). Clone this repository and import `project.godot` in the Godot Project Manager.

Press **F6** on `scenes/Prototype.tscn` or **F5** to run the main scene. In the prototype:

- Drag from one crystal to an orthogonally adjacent crystal, or tap two adjacent crystals.
- A valid three-or-more match consumes a move. Invalid swaps keep the original board.
- Clears resolve gravity/refill and cascades.
- Collect 30 crystals within 18 moves; tap after winning or losing to restart. Press R on desktop to restart.

This is an early engine spike with instant board resolution and visual highlight feedback, not fully animated swap/fall sequences.

## 2. Run automated rules tests

With the Godot executable on `PATH`:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_board.gd
```

The first command imports/parses the project. The second runs deterministic board rules checks and exits nonzero if any test fails.

GitHub Actions runs these commands on pushes and pull requests.

## 3. Export an Android APK for testing

Follow the [Godot 4.7 Android export guide](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html).

1. Install **OpenJDK 17**, Android Studio/SDK, Android SDK Platform Tools, and the version-matched Godot export templates.
2. In Godot **Editor Settings**, set Java SDK and Android SDK paths.
3. Open **Project > Export**, add an **Android** preset and configure a unique package ID (replace any `com.example.*` placeholder).
4. Export a **debug APK** to a location outside Git and install on a connected Android device with `adb install -r <path-to-apk>`.
5. Verify swipes, two-tap swaps, board legibility, back/pause/resume, restart, screen cutouts, battery drain, and 30-second effects stress behavior.

Never commit keystores or export credentials. `.gitignore` excludes common signing formats.

## 4. Export an AAB for Google Play

Android App Bundles are the expected Play Store upload format. Install/configure Android SDK and appropriate Godot Android/Gradle build templates, generate a release signing keystore outside the repository, configure release signing and disable debug export before generating AAB.

Reference: [Android Developers' Godot export guide](https://developer.android.com/games/engines/godot/godot-export).

**Do not claim Play Console acceptance until a signed AAB has been uploaded/tested.**

## 5. Export to Web

Follow the [Godot 4.7 web export guide](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html).

1. Install matching export templates.
2. Add a **Web** export preset and keep the Compatibility renderer.
3. Prefer the default **single-threaded** web export initially.
4. Export `index.html` with its associated support files to a `dist/` directory.
5. Serve the output from a local HTTP server (do not rely on opening it with a `file://` URL).
6. Verify touch and input in desktop Chromium/Firefox, Android Chrome, and iOS Safari if available.

Web export requires WebAssembly and WebGL 2.0. Godot 4 C# projects cannot export to web; this is a GDScript project intentionally.

## 6. Record the real measurements

Use [Engine Evaluation](ENGINE_EVALUATION.md) to record these separately for each tested device:

| Metric | How to capture |
| --- | --- |
| Hardware + Android version | Device model and OS |
| Game start and warm resume | Stopwatch/profile timestamps |
| Average/minimum FPS | Godot profiler or Android profiling tool |
| Touch latency and missed gestures | Repeated drag/tap test |
| RAM and battery | Android Studio profiler |
| APK / AAB size | Generated export file size |
| Web compatibility | Browser/OS/device, errors, first load time |
| Interruptions | Home, lock, orientation, incoming calls |

A successful headless GitHub Actions run proves that scripts parse and deterministic rules tests run, **not** that the game has been performance-tested or that APK/AAB export succeeds.

## 7. Immediate next prototype improvements

- Animate crystal swaps, clear, gravity and refill through events instead of instant board replacement.
- Add an optional 30-second high-particle stress test scene with an FPS indicator.
- Add orientation and safe-area tests across portrait Android devices.
- Track Android and web export results in GitHub Issue #4.

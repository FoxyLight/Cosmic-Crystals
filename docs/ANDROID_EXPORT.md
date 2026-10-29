# Android and Web Validation Guide (Godot 4.7.2)

**Status (2026-10-29):** GitHub Actions now **successfully generates** an Android debug APK and Godot HTML5/Web artifact ([CI run](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40939726043)). No Android *device installation*, browser runtime check, or release-signed AAB has been verified.

## 1. Open and run the prototype

Install [Godot 4.7.2 standard edition](https://godotengine.org/download/archive/4.7.2-stable/) (not the .NET edition). Clone this repository and import `project.godot` in the Godot Project Manager.

Press **F6** on `scenes/Prototype.tscn` or **F5** to run the main scene. In the prototype:

- Drag from one crystal to an orthogonally adjacent crystal, or tap two adjacent crystals.
- A valid three-or-more match consumes a move. Invalid swaps keep the original board.
- Clears resolve gravity/refill and cascades.
- Collect 30 crystals within 18 moves; tap after winning or losing to restart. Press R on desktop to restart.
- **M2 gameplay:** form 4/5/T/L matches to forge Star Beams/Supernovas/Bombs, then swap them to trigger their effects. Matches charge a NOVA X/20 control; when full, tap NOVA and then a board tile to blast the row and column **without spending a move**. Tap NOVA again to cancel targeting and keep the charge. See [M2 Gameplay Guide](M2_SPECIALS_NOVA.md).

The M1 prototype now plays ordered swap/rollback, clear, drop and refill animations with input locked during resolution. The **STRESS 30S** button is a synthetic drawing workload that displays FPS; it does not simulate the final game's particles.

## Android preview APK versioning (automatic in CI)

From [PR #24](https://github.com/FoxyLight/Cosmic-Crystals/pull/24), the Android CI job builds a uniquely numbered APK instead of always writing `cosmic-crystals-debug.apk` with versionCode 1. Download the **latest main-branch** artifact under [Actions](https://github.com/FoxyLight/Cosmic-Crystals/actions/workflows/godot-checks.yml), named `cosmic-crystals-android-v...`. The ZIP contains `cosmic-crystals-v...-debug.apk`, `build-info.json` and `SHA256SUMS.txt`. Use the **actual filename** in `adb install -r`, and inspect `build-info.json` for `versionCode`, `versionName`, Git commit and signing mode.

The workflow sets `versionCode` and `versionName` in the Godot export preset at build time, then reads the embedded Android APK manifest back using `aapt` and fails on a mismatch. A privately configured stable debug key can make subsequent main-branch APK upgrades compatible; without that secret, CI's temporary signing certificates still change and a one-time uninstall may be required. Complete procedure and future release distinction: [Android APK Versioning](ANDROID_VERSIONING.md).

## 2. CI artifacts and automated rules tests

Open the [successful GitHub Actions run](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40939726043). In **Artifacts**, download `cosmic-crystals-android-debug` (APK) or `cosmic-crystals-web` (HTML/JS/WASM/PCK). Extract the ZIP on your computer. These are **seven-day artifacts** signed for development only, not long-lived release links. See [M0/M1 Implementation](M0_M1_IMPLEMENTATION.md) for details.


With the Godot executable on `PATH`:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_board.gd
godot --headless --path . --script res://tests/test_powers.gd
```

The first command imports/parses the project. The second runs deterministic board rules checks and exits nonzero if any test fails.

GitHub Actions runs these commands on pushes and pull requests.

## 3. Export an Android APK for testing

Follow the [Godot 4.7 Android export guide](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html).

1. Install **OpenJDK 17**, Android Studio/SDK, Android SDK Platform Tools, and the version-matched Godot export templates.
2. In Godot **Editor Settings**, set Java SDK and Android SDK paths.
3. Open **Project > Export**, add an **Android** preset and configure a unique package ID (replace any `com.example.*` placeholder).
4. Use either the uploaded CI APK or locally export a **debug APK** outside Git, then install on an ARM64 Android phone with `adb install -r <path-to-apk>`. CI generates a new temporary debug signing key each run; if an earlier debug build has a different signer, you may need to uninstall first, which may clear saved app data.
5. Verify swipes, two-tap swaps, board legibility, back/pause/resume, restart, screen cutouts, battery drain, and 30-second effects stress behavior.

Never commit keystores or export credentials. `.gitignore` excludes common signing formats. The project now sets `config/icon="res://assets/icon.svg"` to a **provisional** original Cosmic Crystals icon; the strengthened CI guard detected the previously absent icon as an Android export error, even though older builds appeared successful. Replace this prototype icon with production-approved store artwork during M4/M6.

## 4. Export an AAB for Google Play

Android App Bundles are the expected Play Store upload format. This project's current CI only builds an **APK using pre-built export templates**. To produce an **AAB**, install/configure Android SDK and Godot's **Gradle Android Build template**, enable `gradle_build/use_gradle_build`, select AAB export format, generate a release signing keystore **outside** the repository, configure release signing and disable debug export. The CI ephemeral debug key is not a Play release signing identity.

Reference: [Android Developers' Godot export guide](https://developer.android.com/games/engines/godot/godot-export).

**Do not claim Play Console acceptance until a signed AAB has been uploaded/tested.**

## 5. Export to Web

Follow the [Godot 4.7 web export guide](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html).

1. Install matching export templates.
2. Add a **Web** export preset and keep the Compatibility renderer.
3. Prefer the default **single-threaded** web export initially.
4. Export `index.html` with its associated support files to a `dist/` directory.
5. Serve the output from a local HTTP server (do not rely on opening it with a `file://` URL).
6. Verify touch and input in desktop Chromium/Firefox, Android Chrome, and iOS Safari if available. The fact that CI produced a Web artifact does **not** prove browser compatibility.

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

The documented [successful GitHub Actions run](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40939726043) proves deterministic checks and **web/debug APK file generation**, but not real-device/browser performance, Android installation, a Gradle AAB, release signing or Play acceptance.

## 7. Immediate next prototype improvements

- [x] Introduce ordered swap, rollback, clear, gravity and refill visual events in the prototype.
- [ ] Manually verify animations, input locking and responsiveness on a real Android phone.
- [x] Add a 30-second **synthetic draw** stress mode and FPS readout.
- [ ] Record real Android FPS/RAM/thermal results; later benchmark production particle art.
- Add orientation and safe-area tests across portrait Android devices.
- [x] Record successful automated Android debug APK and Web export artifacts.
- [ ] Track physical-device and browser validation in GitHub Issue #4.

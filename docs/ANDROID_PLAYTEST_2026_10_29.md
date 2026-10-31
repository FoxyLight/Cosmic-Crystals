> **Historical milestone/build evidence.** For current source, accepted 0.5.3 build 12901, closed M3/M4/settings gates and active M5, see [PROJECT_STATUS](PROJECT_STATUS.md) and [M5 audit](M5_ANDROID_RC_QA.md). Status/next-step statements inside this earlier report apply to its recorded checkpoint.

# Android Player Playtest: Passed

**Date reported:** 2026-10-29  
**Platform:** Physical Android phone (user-reported)  
**Outcome:** **PASS, player-reported overall gameplay smoke test**  
**Source:** Player response in project conversation: “Human playtest passes.”

## Build traceability

The immediately preceding test request pointed to the latest versioned **main** debug APK:

- **Recommended build:** `0.2.0-dev.82.1+gb5e1737d` (Android `versionCode=8201`)
- **Source commit:** `b5e1737d52e024f437db5b55d1e02d4bb29cf160`
- **GitHub Actions:** [successful workflow #40958771036](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40958771036)
- **Artifact name:** `cosmic-crystals-android-v0.2.0-dev.82.1-gb5e1737d`
- **APK signing:** ephemeral CI debug certificate

**Caveat:** The exact binary/version installed on the phone was **not read back by ADB** in this chat. The build above is the one most recently recommended, **not an independently confirmed installed-build identifier**.

## What this sign-off supports

The user reports the human playtest passed following fixes to Star Beam creation, special combinations, Nova Pulse, result-screen replay and deadlock reshuffling. This is evidence of a **successful practical Android gameplay smoke test** and supports moving forward with the next gameplay slice.

The immediately preceding requested checks were: four- and five-gem special creation; special combinations/Nova Pulse; unexpected resets; PLAY AGAIN; and deadlock reshuffling. The user's pass is an **overall result**. The tester did not supply an item-by-item matrix, and this report does **not** claim every ordered power pair or rare deadlock was deliberately reproduced by hand. Deterministic CI covers edge cases separately.

## Still missing before M0/M1/M2 closure

- Device make/model, Android version and physical screen characteristics.
- Measured sustained/min FPS, RAM, thermals, startup and touch latency.
- Pause/resume, orientation/safe-area and interruption tests.
- Exhaustive manual power-combo matrix, power/Nova charge balance and long-session stability.
- Browser runtime testing (Web artifacts have been generated but not exercised here).
- Production signed AAB export, Play testing and formal Godot engine production sign-off.
- Asteroid blockers, required for the remaining M2 milestone.

## Tracking and next step

- [M0 Android/web/device gate #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4): record Android gameplay smoke as passed, keep measurements/browser/AAB tasks open.
- [M1 gameplay #3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3): record human Android gameplay as passed, keep interruption/edge regression tasks open.
- [M2 special powers #6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6): record human gameplay smoke as passed; asteroids and balancing remain.
- [Reset bug #21](https://github.com/FoxyLight/Cosmic-Crystals/issues/21): device smoke supports bug-fix acceptance, with the caveat above.
- [Combo audit #19](https://github.com/FoxyLight/Cosmic-Crystals/issues/19): automated exhaustive tests and human smoke support completing the audit; full QA matrix remains in M2.

**Recommended next implementation:** asteroid blocker durability, adjacent-match damage, Star Beam/Bomb/Supernova/Nova interaction, blocker-safe gravity and shuffle, and corresponding deterministic tests.

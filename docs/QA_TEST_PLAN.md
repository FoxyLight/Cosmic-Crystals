# Android QA and Acceptance Plan

Current plan: 2026-10-30, Android-only 0.5.0. This supersedes the [historical pre-M4 QA matrix](history/PRE_M4_QA_TEST_PLAN.md). No Web/browser/iOS acceptance applies. Desktop/headless execution is an Android development environment only.

## Automated gate

Retain all 13 M3 Godot suites (rules, powers/combinations, asteroids, visuals, replay/shuffle, layout, sessions, saves and actual five-level touch progression). Add `test_android_polish.gd`: additive old-save preferences, volume/mute/reduced-motion, audio assets/crossfade/no restart/layering limits, focus+pause ordering, settings input interception and target/cutout geometry. Headless audio is deliberately silent: contract tests do not claim a speaker/audio-driver test.

Nine Python tests cover Android versions/preset selection, source drift, signature parsing, Android-only workflow and all 22 PCM assets (headers, duration, headroom and loop seam). APK checks require all imported audio samples, provenance, font notices and authored catalog. Actual `aapt` and `apksigner` validate manifest and signing certificate; main stable-key APK must match the configured pin.

Use the **strict Godot parser/runtime-log guard** on every import/test/export. Exit zero with SCRIPT ERROR/ERROR is still failure. CI also runs a CPU settlement benchmark and two separately exported same-key versions on an isolated Android emulator, verifying exact saved bytes after `adb install -r`. That is not proof of updating the player's differently signed build 9801.

## New human Android M4 checklist

Record exact versionName/code, source SHA, public certificate fingerprint, signing mode, device/Android version and display/font scaling. Preserve the old installation unless an explicit backup/migration approval has been given.

1. Fresh/compatible launch, Home/map/all five levels; all goals and special/rock markers readable. Check compact phone and tablet portrait, system navigation/cutouts; no clipping or accidental activation.
2. Master/music/SFX at 0/50/100, mute/unmute; navigate/restart without unnecessary track restarts. Match/cascade/Beam/Bomb/Supernova/Nova/rock hit+break/victory/defeat/star/unlock/menu cues audible and restrained. Heavy chains do not become excessively loud.
3. Close/reopen with changed audio, motion and reading-text settings; keep earned stars, best scores, completed levels and unlocks. A worse replay/loss cannot remove records.
4. Background/foreground, screen lock, phone call/media interruption: no unexpected background audio; return to intentional pause with no stuck touch/cascade. Hardware audio-focus behavior needs this test.
5. Reduced motion suppresses star twinkle, splash/rings/shards, screen flashes and slow award/fade effects; same seeded actions score identically. Muted play still has complete visual/text feedback.
6. Larger reading text plus Android font/display scaling at supported settings. Field guide, goals, map, results/settings must stay readable. This is not a claim of full TalkBack/nonvisual board support.
7. Exercise swipe/two taps, fast repeats, Nova cancel, confirmation/cancel, Back during effects, defeat/retry and final-level replay/map. Exactly five stages.
8. Run normal/reduced-motion sessions, repeated navigation and heavy chains with audio for at least 10 minutes. Record actual FPS, p95 frame time, RAM/PSS, startup/load and thermals; compare phone classes. `performance-last.json` captures a rolling observed report on Android backgrounding, not a synthetic benchmark score.

M3's player pass is recorded in [its report](ANDROID_M3_PLAYTEST_2026_10_29.md). M4 remains open until a new pass. Full device/performance and production accessibility acceptance cannot be inferred from CI.


## 0.5.1 Beam direction regression

A four-match Beam follows the initiating swap axis, not the completed line's
orientation: left/right movement creates a horizontal row Beam; up/down creates
a vertical column Beam. Test all four directions with swipes and two-tap swaps,
including movement perpendicular to the matched line. The visible forged marker
and its later full-line blast must agree. Existing saved Beams/records are not
rewritten; Bomb/Supernova precedence and available mechanics remain unchanged.

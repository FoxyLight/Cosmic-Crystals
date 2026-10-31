# Android QA and Acceptance Plan

Current plan: 2026-10-31, Android-only **0.5.4**. This supersedes the [historical pre-M4 QA matrix](history/PRE_M4_QA_TEST_PLAN.md). No Web/browser/iOS acceptance applies. Desktop/headless execution is an Android development environment only.

## Automated gate

Retain the 13 M3 Godot suites (rules, powers/combinations, asteroids, visuals, replay/shuffle, layout, sessions, saves and actual five-level touch progression). Add `test_android_polish.gd`: additive old-save preferences, volume/mute/reduced-motion, audio assets/crossfade/no restart/layering limits, focus+pause ordering, settings input interception and target/cutout geometry. Headless audio is deliberately silent: contract tests do not claim a speaker/audio-driver test.

Thirteen Python tests cover Android versions/preset selection, source drift, signature parsing, Android-only workflow and all 22 PCM assets (headers, duration, headroom and loop seam). APK checks require all imported audio samples, provenance, font notices and authored catalog. Actual `aapt` and `apksigner` validate manifest and signing certificate; main stable-key APK must match the configured pin.

Use the **strict Godot parser/runtime-log guard** on every import/test/export. Exit zero with SCRIPT ERROR/ERROR is still failure. CI also runs a CPU settlement benchmark and two separately exported same-key versions on an isolated Android emulator, verifying exact saved bytes after `adb install -r`. That is not proof of updating the player's differently signed build 9801.

## Player-reported M4 Android playtest: PASS

**2026-10-30:** The player states **“M4 playtest passes”** after the version 0.5.1 audio/comfort/Beam-direction delivery. This records **overall M4 human usability acceptance** without inventing per-item scores, device specifications, system font-scale configurations, audio-mix measurements, hardware interruption tests, FPS/p95, RAM/PSS or thermals. [Evidence and exact known installed-build boundary](ANDROID_M4_PLAYTEST_2026_10_30.md).

The detailed checklist below is retained as a **M5 release-candidate testing matrix**. Its individual measurements and multi-device conditions are *not automatically checked off* by the general player pass. M4 #8 is closed at the scoped implementation/player-acceptance gate while [M5 #9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) remains open for these objective measurements.

## Post-M4 0.5.2 Android settings regression

The player reported that volume sliders could not be moved and that Larger reading text had no obvious effect. [PR #38](https://github.com/FoxyLight/Cosmic-Crystals/pull/38) adds native `InputEventScreenTouch`/`InputEventScreenDrag` handling and a visible font-size preview; the extended M4 test suite verifies all three slider gestures, percentages, persistence, switch touches and font sizes. **The player accepted the fix on installed/read-back build 12501; [#37](https://github.com/FoxyLight/Cosmic-Crystals/issues/37) is closed**. [Retest checklist](ANDROID_SETTINGS_TOUCH_FIX_2026_10_30.md). Do not infer a new 0.5.2 playtest from the prior M4 overall PASS.

## M5 physical Android checklist

Record exact versionName/code, source SHA, public certificate fingerprint, signing mode, device/Android version and display/font scaling. Preserve the old installation unless an explicit backup/migration approval has been given.

1. Fresh/compatible launch, Home/map/all five levels; all goals and special/rock markers readable. Check compact phone and tablet portrait, system navigation/cutouts; no clipping or accidental activation.
2. Master/music/SFX at 0/50/100, mute/unmute; navigate/restart without unnecessary track restarts. Match/cascade/Beam/Bomb/Supernova/Nova/rock hit+break/victory/defeat/star/unlock/menu cues audible and restrained. Heavy chains do not become excessively loud.
3. Close/reopen with changed audio, motion and reading-text settings; keep earned stars, best scores, completed levels and unlocks. A worse replay/loss cannot remove records.
4. Background/foreground, screen lock, phone call/media interruption: no unexpected background audio; return to intentional pause with no stuck touch/cascade. Hardware audio-focus behavior needs this test.
5. Reduced motion suppresses star twinkle, splash/rings/shards, screen flashes and slow award/fade effects; same seeded actions score identically. Muted play still has complete visual/text feedback.
6. Larger reading text plus Android font/display scaling at supported settings. Field guide, goals, map, results/settings must stay readable. This is not a claim of full TalkBack/nonvisual board support.
7. Exercise swipe/two taps, fast repeats, Nova cancel, confirmation/cancel, Back during effects, defeat/retry and final-level replay/map. Exactly five stages.
8. Run normal/reduced-motion sessions, repeated navigation and heavy chains with audio for at least 10 minutes. Record actual FPS, p95 frame time, RAM/PSS, startup/load and thermals; compare phone classes. `performance-last.json` captures a rolling observed report on Android backgrounding, not a synthetic benchmark score.

M3's player pass is recorded in [its report](ANDROID_M3_PLAYTEST_2026_10_29.md). The player subsequently reported **M4 Android playtest PASS**; see [M4 acceptance](ANDROID_M4_PLAYTEST_2026_10_30.md). Full measured device/performance and production accessibility acceptance cannot be inferred from CI or the general playtest pass; those remain in M5.


## 0.5.1 Beam direction regression

[PR #34](https://github.com/FoxyLight/Cosmic-Crystals/pull/34) merged with 53 additional real-scene Beam-direction checks. At [main CI #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426), **all 15 Godot suites and nine Python tests passed**, as did Android APK manifest, signer-pin, packaged-assets and same-key emulator upgrade checks. The phone's 10801 → 11001 in-place update retained a validated save byte-for-byte. **The player's overall M4 Android playtest subsequently passed**; individual quantitative device/audio/accessibility checks remain M5 work.

A four-match Beam follows the initiating swap axis, not the completed line's
orientation: left/right movement creates a horizontal row Beam; up/down creates
a vertical column Beam. Test all four directions with swipes and two-tap swaps,
including movement perpendicular to the matched line. The visible forged marker
and its later full-line blast must agree. Existing saved Beams/records are not
rewritten; Bomb/Supernova precedence and available mechanics remain unchanged.

## 0.5.3 readable baseline and extra-large option

The 0.5.2 larger font sizes are now standard without changing the stored boolean. The **Larger Text** switch raises these again. Verify both sizes at 320x568, 376x746, 800x1280 and 1280x720: settings preview/percent labels/toggles/status, Home text and button separation, every level preview/goal, gameplay caption, field guide and win summary. All text must fit without ellipsis, clipping, scroll or overlap. Check false → true → false restores the promoted default; native sliders remain draggable. Short gameplay captions supplement full map/help tutorials. The player separately approved this refinement and the final **Larger Text** label on installed/read-back 0.5.3 build 12901. System scaling and multi-device measurements remain pending in M5.


## M5 stabilization checkpoint, 2026-10-31

Source base **0.5.4** follows accepted 0.5.3 build 12901. [M5 audit and human checklist](M5_ANDROID_RC_QA.md) records verified cancellation fixes, 16 Godot suites and 13 Python tests, coverage boundaries and outstanding device measurements. M3 #7, M4 #8 and settings #37 are closed; M5 #9 remains open. Earlier numbered builds in this document are historical evidence, not the current APK. Read final candidate commit/version/signing in its main CI artifact and #9 delivery receipt.

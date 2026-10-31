# Android Settings Follow-up: Volume Drag and Larger Reading Text

**Date:** 2026-10-30  
**Version:** `0.5.2` (Android-only debug preview)  
**User report:** “the sound volume controls are not able to be moved” and “I can't tell if the larger text option actually makes the text larger or not.”  
**Tracker:** [#37](https://github.com/FoxyLight/Cosmic-Crystals/issues/37)  
**Implemented:** [PR #38](https://github.com/FoxyLight/Cosmic-Crystals/pull/38), main commit `1dc1810b3f89dd914273bc906c1f40b615aca442`.

## Root causes

- `project.godot` intentionally sets `pointing/emulate_mouse_from_touch=false` to avoid duplicate Android puzzle gestures. The settings `HSlider` controls had no native `InputEventScreenTouch` / `InputEventScreenDrag` bridge; earlier tests checked touch-target geometry rather than real drag interactions.
- The Larger reading text setting only changed some secondary Map/HUD labels. In `game_hud.gd`, an enlarged caption size was overwritten in the same refresh. On the settings page, the option did not visibly enlarge any of its own text.
- The newly added automated toggle test initially reported false failures because an older save-persistence fixture had deliberately **pre-enabled** `large_text`; the test now explicitly starts in normal-size mode. Do not confuse test-fixture errors with user device results.

## Implemented behavior

- A native Android finger press+drag moves Master, Music and Sound Effects sliders, updating the displayed percentage and saved `user://` settings; values clamp to 0–100% in 5% increments.
- Touch ownership is restricted to the settings sheet, avoiding board swaps. Normal mouse/keyboard slider interaction is preserved; global touch-to-mouse emulation stays **off**.
- Mute, reduced-motion and larger-text switches respond to native touch.
- The settings sheet offers a live **reading-text preview**. Toggling larger text immediately enlarges labels in Settings, the Home description, constellation Map instructions, gameplay feedback, and game dialogs. Toggling it back restores standard sizes instead of leaving stale font overrides.
- Five-level gameplay rules, app ID, save **schema 1**, stable debug certificate, star ratings and earned progression remain unchanged.

## Automated verification

[PR #38](https://github.com/FoxyLight/Cosmic-Crystals/pull/38) passed the `check` and `android-debug-export` jobs including **190 Android polish checks** (native press/drag/release, visible percentages, three sliders, disk reload, CheckButton touch/toggle, reversible font sizing), other Godot suites, version tests, signed Android APK packaging and an emulator same-key save-preserving update. [Merged-main Android CI #123](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41109742730) **passed both Android-only jobs**, including 15 Godot suites, nine Python version/polish checks, strict Godot log checks, manifest/signature/certificate-pin verification, checksum and the disposable-emulator same-key save update. Subsequently, the player confirmed **“That is working now”** on installed/read-back build 12501; #37 is closed. The #123 artifact below records the earlier export, not the latest installation.

- **APK artifact:** [cosmic-crystals-android-v0.5.2-dev.123.1-g1dc1810b](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41109742730/artifacts/13002038436)
- **APK filename:** `cosmic-crystals-v0.5.2-dev.123.1-g1dc1810b-debug.apk`
- **Embedded versionName:** `0.5.2-dev.123.1+g1dc1810b`; **versionCode:** `12301`
- **SHA-256:** `17162cdbba7dae3b21408bbd776fa56135f0ffb2c612dd730057ef176ce7a331`
- **Signing:** `persistent-secret`, same verified pinned debug certificate identity as the pre-existing stable-key M4 builds.

**No new human Android playtest of this 0.5.2 fix is yet reported.** The earlier overall M4 acceptance preceded discovery of these two settings defects. Keep #37 **open** for user retest even after CI is green; M5 #9 remains open for quantified multi-device accessibility/performance.

## Android retest checklist

1. Download the **latest successfully verified main** 0.5.2 APK and confirm its package, embedded versionCode, `build-info.json`, SHA-256 and **stable** signing certificate match the installed app. Do not uninstall or clear player data; use in-place update only with the matching key and higher code.
2. Open **Home → Settings → Sound & comfort**. Drag each of Master, Music and Sound Effects from near zero to around 75–90% and back. Confirm the thumb tracks the finger, percentages update, and music/SFX loudness changes. Test tapping a new position as well.
3. Change a volume, press Done, close/reopen the app, and confirm the same value. Change Mute and confirm that sliders still retain their values.
4. Toggle **Larger reading text** while remaining in Settings. The live preview, label sizes and controls must visibly enlarge. Toggle it off; they must shrink back.
5. With large text on, inspect the **Home description**, **Lyra map level tutorial**, **gameplay feedback caption**, **How to play dialog**, and **results**. Toggle off and repeat. Watch for overlap, truncation, and unreachable controls on your actual phone.
6. Try rapid swipes/multiple fingers while Settings is open and while closing it. Confirm puzzle crystals do not move. Retest saved stars/unlocks after reopening.
7. Record exact Android versionName/versionCode, phone/OS and qualitative result. Leave FPS/PSS, font scaling, TalkBack and multi-device accessibility audits to M5 rather than inventing them.

**Sign-off required:** The user must confirm this specific patch's slider drag and visible text-size behavior on Android before issue #37 closes.

## Player retest confirmation, 2026-10-30

After the latest successful main APK `0.5.2-dev.125.1+gbe6733f0` (12501) was installed in place and its real save verified unchanged, the user was asked to test all three sliders and the visible Larger reading text toggle. The user replied **“That is working now.”** This accepts those reported defects at an overall player-test level; it does not invent itemized measurements or a device/accessibility matrix. #37 can close for this fix. The user then requested a larger default and a still larger option, implemented separately in [0.5.3](ANDROID_READING_TEXT_2026_10_30.md); the new sizes require their own retest.

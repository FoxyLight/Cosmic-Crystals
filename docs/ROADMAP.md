# Android Development Roadmap

Snapshot 2026-10-30, product **0.5.2**. Android is the sole supported product. Desktop/headless execution is development only. Web/HTML5/browser work and iOS development/feasibility are out of scope, superseding previous roadmap entries.

M3's five-level Lyra campaign is accepted by the player and #7 is closed. Preserve all earned campaign records. [Acceptance](ANDROID_M3_PLAYTEST_2026_10_29.md).

M4 implements audio, comfort/accessibility, clear restrained effects, render/UI work reduction, performance instrumentation, Android-only CI and pinned private debug signing. **PR #34 / version 0.5.1** also corrects new four-match Beams to follow the swap axis. The player phone's 10801 → 11001 same-key update retained the validated save byte for byte. **The player subsequently reported M4 Android playtest PASS on 2026-10-30**; M4's implementation/human acceptance gate is complete. [Human report](ANDROID_M4_PLAYTEST_2026_10_30.md). Full quantified device/performance/accessibility QA remains in M5 #9. [M4](M4_ANDROID_POLISH.md), [main CI #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426).

**Post-M4 usability repair:** Android 0.5.2 source ([PR #38](https://github.com/FoxyLight/Cosmic-Crystals/pull/38)) adds native drag/touch control for Master, Music and Effects sliders, a visible Larger reading text preview, and readable guidance across screens. The player's reported defects are tracked under [#37](https://github.com/FoxyLight/Cosmic-Crystals/issues/37), **open pending a new physical Android retest**. [Exact checklist](ANDROID_SETTINGS_TOUCH_FIX_2026_10_30.md). M4's earlier broad acceptance still stands as historical feedback, not acceptance of this later patch.

Remaining gates:
- M0 #4: actual Android device matrix, FPS/frame-time/RAM/startup/thermal/interruption evidence, future AAB and engine decision.
- M1 #3: extended device timing/long-play/interruption testing; deterministic last-move/navigation guards are covered.
- M2 #6: detailed special/Nova balance and device acceptance; asteroid build 9101 previously passed player smoke.
- M4 #8: implemented and accepted by the player on 2026-10-30. Stable debug signer and 10801 → 11001 save-preserving phone update verified; **deeper font/display scaling, screen-reader and performance/device matrices remain in M5**. Any other differently signed legacy APK still requires an approved save-safe migration.
- M5 #9: Android release-candidate regression and multiple device classes; no browser matrix.
- M6 #10: future production signing/AAB, Play preparation and explicit publication decision; not part of M4.
- M7 #11: levels 6–20 and additional constellations deferred. iOS is out of scope, not a promised later target.

No committed dates, staffing or release promises. Historic Web exports and the separate concept site are records only.

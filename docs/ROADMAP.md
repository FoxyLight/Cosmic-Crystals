# Android Development Roadmap

Snapshot 2026-10-30, product **0.5.1**. Android is the sole supported product. Desktop/headless execution is development only. Web/HTML5/browser work and iOS development/feasibility are out of scope, superseding previous roadmap entries.

M3's five-level Lyra campaign is accepted by the player and #7 is closed. Preserve all earned campaign records. [Acceptance](ANDROID_M3_PLAYTEST_2026_10_29.md).

M4 implements audio, comfort/accessibility, clear restrained effects, render/UI work reduction, performance instrumentation, Android-only CI and pinned private debug signing. **PR #34 / version 0.5.1** also corrects new four-match Beams to follow the swap axis. The player phone's 10801 → 11001 same-key update retained the validated save byte for byte. New human M4/Beam-direction acceptance is still required, so #8 remains open. [M4](M4_ANDROID_POLISH.md), [main CI #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426).

Remaining gates:
- M0 #4: actual Android device matrix, FPS/frame-time/RAM/startup/thermal/interruption evidence, future AAB and engine decision.
- M1 #3: extended device timing/long-play/interruption testing; deterministic last-move/navigation guards are covered.
- M2 #6: detailed special/Nova balance and device acceptance; asteroid build 9101 previously passed player smoke.
- M4 #8: new audio/comfort/visual/Beam-direction human acceptance, devices and system font/display scaling. Stable debug signer and the 10801 → 11001 save-preserving phone update are verified; any *other* device still holding a differently signed legacy APK needs a separately authorized, safe migration.
- M5 #9: Android release-candidate regression and multiple device classes; no browser matrix.
- M6 #10: future production signing/AAB, Play preparation and explicit publication decision; not part of M4.
- M7 #11: levels 6–20 and additional constellations deferred. iOS is out of scope, not a promised later target.

No committed dates, staffing or release promises. Historic Web exports and the separate concept site are records only.

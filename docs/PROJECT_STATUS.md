# Current Project Status

Snapshot 2026-10-30. **Android-only**, product base **0.5.1**, Godot 4.7.2 Compatibility. Same package and schema-1 earned progression; additive settings default safely for older saves.

M3 #7 is closed following the player's human Android five-level/relaunch pass. Last independently verified player installation was build 9801, signed with a temporary CI key. Do not uninstall it or infer compatibility with the new stable key.

M4 implements original audio, smooth context music, bounded effects, saved volume/mute/comfort preferences, Android focus/background gating, restrained power effects and results, larger reading text, safe settings controls, cached view/layout updates and bounded frame/load/event diagnostics. CI has no Web job or artifact and validates Android packaging and same-key emulator upgrades. [M4 specification, evidence and limits](M4_ANDROID_POLISH.md).

Private stable-debug key, generated private password and public-pin Actions secrets are configured. Main run 106 verified the real APK certificate pin, metadata and exact save retention through a same-key emulator update. Fresh M4 10601 was installed/read back on the Pixel 7a after the owner confirmed personally removing the older copy. No M4 uninstall/data clear or old-save recovery is claimed. The later private-password hardening preserves this certificate, so the next build supports in-place updates. See [versioning/signing](ANDROID_VERSIONING.md) and #8 for exact final delivery.

M4 #8 remains open for new human Android acceptance. No new phone FPS/RAM, perceived mix quality, thermal, full font/display scaling, screen reader or multi-device result is claimed. The initial read-only backup attempt found no installed package, so no old campaign save was captured. Progress earned in the new stable-key build must be preserved during updates. PR and main pipelines validate only Android; no Web artifact is produced.

M0/M1/M2 broader device/balance gates, M5 quality and M6 release signing/Play remain open. Web/HTML5, iOS and desktop distribution are out of scope. Historical Web evidence is retained without current deliverables.

**Latest main checkpoint:** [PR #34](https://github.com/FoxyLight/Cosmic-Crystals/pull/34) merged as `7864c82007bf379de232156323328e887afdcf0c`. [Main run #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426) passed **check** and **android-debug-export**, including 15 Godot suites, nine Python tests, version/manifest/asset checks, real cryptographic signing/pin verification and an isolated emulator's saved-file update test. APK: `0.5.1-dev.110.1+g7864c820`, code **11001**, stable signing mode `persistent-secret` ([artifact](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426/artifacts/12988237867)).

0.5.1 changes newly created four-match Beams to follow the initiating swap axis. Existing saved progress, audio/settings and previously stored power orientations are retained. Four-direction swipe/two-tap regressions and later blast footprints are covered. GitHub issue #8 records an **on-phone same-signature update from 10801 to 11001** with a private validated backup and **byte-identical save after installation**. This is update/data-preservation evidence, **not** the pending human M4 audiovisual and Beam-orientation playtest. No Web job/artifact or release AAB.

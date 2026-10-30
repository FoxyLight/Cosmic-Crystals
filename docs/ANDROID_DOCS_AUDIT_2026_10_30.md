# Android-Only Repository & Documentation Audit

**Review date:** 2026-10-30
**Inspected baseline:** [main commit `7864c82007bf379de232156323328e887afdcf0c`](https://github.com/FoxyLight/Cosmic-Crystals/commit/7864c82007bf379de232156323328e887afdcf0c), product `0.5.1`
**Evidence:** [merged PR #34](https://github.com/FoxyLight/Cosmic-Crystals/pull/34), [main CI run #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426), [M4 #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8).
**Audit scope:** GitHub source tree, workflow, `VERSION` and export preset, issues and current Markdown documentation. This is a **documentation-only** change; no new Android device session or independent gameplay execution was performed by this audit.

## Source-verified current state

| Dimension | Evidence-backed result | Important limit |
| --- | --- | --- |
| Platform | Android sole product. CI runs `check` and `android-debug-export`; no Web job or export artifact | Historical Web files/links remain historical records, not delivery requirements |
| Godot | 4.7.2 GDScript Compatibility, five JSON-authored Lyra levels, M1/M2 mechanics, 1/2-HP asteroids, schema-1 local progression | No Play-track production AAB or signed release verification |
| M3 | The player accepted the five-level Android campaign; [#7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7) is completed | M3 user report does not prove full performance/audio/accessibility matrix |
| M4 | Original PCM sound effects/ambient tracks, saved master/music/effects/mute, reduced motion/larger text, Android focus handling, bounded effects/performance diagnostics | New M4 *human audiovisual/accessibility* acceptance pending; [#8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) stays open |
| Beam semantics | Product 0.5.1: initiating gem movement left/right → horizontal Beam; up/down → vertical Beam | New human Beam-direction confirmation pending |
| Automated tests | Main #110 passed **15 Godot regression suites** and **nine Python tests**, plus headless benchmark; strict error-log guard applies | Headless/CPU tests do not establish Android sustained FPS or audible mix |
| Android APK | `0.5.1-dev.110.1+g7864c820` code **11001**; filename `cosmic-crystals-v0.5.1-dev.110.1-g7864c820-debug.apk`; [artifact](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426/artifacts/12988237867) | CI artifact is retained temporarily; not a production Play release |
| SHA-256 | `a2d15f5efe9f26958e8c1ab77ea43e1ff5ac899793bc946cfa62eef37e7a7249` | Verify downloaded bytes against provided `SHA256SUMS.txt` |
| Signing | Main private persistent debug signer is configured and cryptographically/pin verified (`persistent-secret`); PR previews have ephemeral signatures | Different-key legacy APKs, such as 9801, cannot upgrade with the stable key |
| Progress-safe updates | Isolated emulator same-key update retains exact save; [issue #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) reports Pixel 7a **10801 → 11001** in-place update with a validated private backup and **byte-identical save** | Do not infer all legacy-device migrations, autosaved unfinished rounds, or human M4 pass |

## Documentation corrections in this audit

- Update current status, roadmap, milestone register, release plan, QA, Android versioning/export and M4 delivery report to `0.5.1`, PR #34/main #110 and the verified save-preserving phone update.
- Clarify the **historical build 9801** versus the **currently recorded stable-key 11001** installation; remove unsafe instructions to keep the already-uninstalled 9801 on the same test phone, but retain the warning for *other* devices.
- Refresh the game design and ADRs to distinguish implemented M2/M3 logic, move-axis Beam behavior and current private debug signing from earlier prototype plans.
- Replace the obsolete prototype-era **risk register** with an active Android-only risk matrix including save safety, audio/accessibility, device performance and Play signing.
- Replace the stale cross-platform **AI development prompt** with an Android-only handoff brief grounded in working source and explicit acceptance gates.
- Add historical/superseded scope banners to earlier M0/M1, M2, M3, early contrast, visual and playtest reports. Preserve original historical test evidence while distinguishing those previous states from the present.
- Retain the original history documents and previous Web results as provenance, not current release obligations.

## Remaining work (not marked complete)

- **M0 #4:** representative Android device performance/thermal/latency measurements and a formal production engine decision; future signed AAB path.
- **M1 #3:** extended session/interruption timing on Android.
- **M2 #6:** special/Nova difficulty and power balance, beyond automated matrix and previous gameplay smoke.
- **M4 #8:** player-approved 0.5.1 Beam-direction/audio/comfort usability, sound quality, Android audio-focus/interruptions, screen-reader/full accessibility and font-scaling measurements.
- **M5 #9:** multi-device Android release candidate, real PSS/FPS/startup/thermals, long-session regression and issue severity review.
- **M6 #10:** separately authorized production/upload signing, signed AAB, Play internal track, declarations and publication decision.
- **M7 #11:** optional post-MVP Android content only; iOS/Web are out of scope.

## Audit rule going forward

When a feature, scope, version, signing identity, Android test or GitHub milestone changes, update **README**, [status](PROJECT_STATUS.md), [roadmap](ROADMAP.md), [milestones](MILESTONES.md), [QA](QA_TEST_PLAN.md), [M4](M4_ANDROID_POLISH.md), [Android signing](ANDROID_VERSIONING.md) and affected design/ADR documents together. Cite exact CI run, APK filename, embedded version, installed-device evidence, and separate **automated vs emulator vs human** outcomes. Never silently equate a passing APK export or byte-preserving device update with a user-approved gameplay release.

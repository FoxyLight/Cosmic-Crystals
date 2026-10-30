# Current Android Risks and Dependencies

**Reviewed:** 2026-10-30, source version **0.5.1**, Godot 4.7.2 Compatibility. **Android is the sole supported product.** The previous 2026-10-29 matrix described not-yet-implemented M2/M3 and planned browser/iOS work and has been superseded. Historical decisions/exports remain traceable in Git history and [ADR-006](DECISIONS.md).

Risk impact is qualitative; it is not an empirical probability or measured Android performance report.

| ID | Active risk | Impact | Current evidence / boundary | Mitigation and remaining gate | Tracker |
| --- | --- | --- | --- | --- | --- |
| R01 | Android experience varies across screen sizes, device speed and OS versions | High | M3 five-level pass and new user-reported **M4 0.5.1 Android playtest PASS**; 11001 same-key update/save was verified, but no quantified multi-device evidence | Phone/tablet matrix with safe insets, system font/display scaling, touch, audio interruptions, p95 frame time, memory/PSS, startup and thermals | [M0 #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4), [M4 #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8), [M5 #9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) |
| R02 | A differently signed debug APK can destroy earned progress during a forced reinstall | High | Main debug keystore/pin verified in CI; phone **10801 → 11001** save was byte-for-byte identical; an old ephemeral-key app cannot update with the new certificate | Protect key/password outside Git, maintain encrypted offline backup, check installed certificate and version before update; require explicit approval and validated private save backup for *legacy* key migration | [Signing guide](ANDROID_VERSIONING.md), [M4 #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) |
| R03 | Corrupt/unwritable saves or process interruption cause loss of stars/unlocks | High | Schema-1 validation/atomic temporary writes, backup/future-schema safeguards and tests exist; no unfinished board is saved | Android process-death/storage-failure tests, verify save path and notices; never claim autosave of an active round | [M5 #9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) |
| R04 | Special-power chains or asteroid topology produce incorrect counts, no moves or input deadlock | High | M2 deterministic combo/blocker matrix and M4 15-suite CI green, with 0.5.1 movement-direction regression; extended player balance evidence missing | Keep seeded replay, event continuity and blocked deadlock tests; collect real-device long-session and edge-case reports | [M2 #6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6), [M1 #3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3) |
| R05 | Five authored levels are too easy/hard, Nova charge or star thresholds feel unfair | Medium | All five M3 levels automated/Android human smoke accepted; objective-aware simulated win rates do **not** measure human difficulty | Record player difficulty, failed attempts, moves left and feedback; adjust budgets with repeatable tests | [M2 #6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6), [M5 #9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) |
| R06 | Audio mix, interruptions and accessibility are inadequate for actual Android players | High | Original SFX/music, saved sliders/mute/reduced motion/larger text and focus handling exist; headless audio tests are not listening tests | M4 overall player smoke accepted; transfer objective mix, focus/call/background, contrast/scaling, TalkBack and accessibility validation to M5 | [M4 #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) |
| R07 | Render/effects stress overloads modest Android devices | High | Bounded pools and diagnostic logger implemented; CPU/headless benchmarks are not Android FPS/RAM/PSS/thermal evidence | 10+ minute device load test; startup, p95 frame time, memory and throttling checks; record exact device/build | [M4 #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8), [M5 #9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) |
| R08 | Google Play API/policy, privacy disclosures, release signing or AAB path block distribution | High | Debug APK CI succeeds; **no production signed AAB/Play track** is verified | Separately authorize M6, establish production/upload signing, build signed Gradle AAB, internal test, review current policies and real data-handling declarations | [M0 #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4), [M6 #10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10) |
| R09 | Scope creep before Android quality gate | Medium | M3 complete; M4 overall human playtest passed; M5/M6 quality/release gates future | Defer levels 6–20 and other constellations until quality/release gates; no active Web/iOS development | [M7 #11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11) |

## Verified checkpoint

[PR #34](https://github.com/FoxyLight/Cosmic-Crystals/pull/34) and [main run #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426) passed both Android CI jobs (15 Godot suites, nine Python tests, manifest/signature/pin/assets/checksum, isolated-emulator same-key save upgrade). The run's **0.5.1 build 11001** is `persistent-secret` signed. [M4 #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) separately documents a real-phone in-place update from 10801 to 11001 with the same saved data. The user subsequently reported **M4 Android playtest PASS** (overall acceptance); separate M5 device/performance/accessibility and M6 Play release gates remain unmet.

## Current external dependencies

- Pinned Godot 4.7.2 editor and matching **Android** export templates; Android SDK/JDK and reproducible CI runners.
- Secure, restorable private debug keystore/password and pinned public certificate. No signing secret in source, logs or public artifacts.
- Representative physical Android phones/tablets, audio output devices, font scaling and interruption scenarios.
- Original reproducible PCM audio assets and bundled SIL OFL font licenses; see [audio provenance](../assets/audio/PROVENANCE.txt).
- Separately authorized Google Play Console and private production/upload credentials **only for M6**.

## Review cadence

Review risks after each gameplay/signing change and before M4/M5/M6 acceptance. Convert risks to closed items only with appropriate source tests or human/device evidence. Historical browser/iOS risks are retired from the active matrix, not treated as unfinished Android work.

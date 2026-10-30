> **Historical M3 acceptance evidence (0.4.0).** The report below remains the evidence for closed issue #7. Active product scope is **Android-only 0.5.1**; browser QA is excluded. The device's subsequent stable-key M4 **10801 → 11001 update** preserved saved data, but the new M4 audiovisual/Beam-direction human test is pending. See [M4](M4_ANDROID_POLISH.md), [status](PROJECT_STATUS.md).

# M3 Lyra Android Playtest: Player-Reported PASS

**Reported:** 2026-10-29
**Platform:** Physical Android phone (user-provided playtest)
**Verdict:** **PASS, human-reported M3 campaign acceptance**
**Player's exact feedback:** “Human android play test passes”

## Test scope and evidence

The feedback follows the requested M3 human acceptance review, specifically: play the complete **five-level Lyra campaign**, inspect its new Home/map/result visuals and touch navigation, close and reopen Android, and verify that earned best scores, stars, unlocks, tutorial history and applicable settings persist.

This response is recorded as the player's **overall pass for that requested checklist**. The player did not provide individual screenshot/video evidence, per-level outcomes, device model/OS, scores, FPS, memory, or performance figures. Do not present these as independently verified measurements or claim a new device instrumentation run. Automated CI and the earlier Chromium check provide separate evidence for the defined functional behaviors.

## Build identity

- **Known installed/read-back campaign APK:** `0.4.0-dev.98.1+ge14ef9e9`, Android `versionCode=9801`, commit `e14ef9e959b679346880b3d2adf6d94be145b581`.
- **Installation verification:** The device's package version was read back over wireless ADB after the run-98 installation, as documented in [M3 #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7) and the [M3 delivery report](M3_LYRA_CAMPAIGN.md).
- **Successful delivery workflow:** [main #98](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40973718330).
- **Most recent verified pre-feedback main workflow:** [#100](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40974920062) at `942e865399acfb26097bf91162b581d62a49a8eb`. This followed with **documentation-only** changes; no installation of its versionCode 10001 was evidenced.
- **Exact build used for the player's test:** The user has not restated the installed version in this message. The previously confirmed installation was 9801, so link the pass to the M3 gameplay code and **known installed candidate**, not a newly claimed installation of #100 or any future docs-only APK.

## M3 exit gate

The feature set and CI were delivered in [PR #29](https://github.com/FoxyLight/Cosmic-Crystals/pull/29) and [PR #30](https://github.com/FoxyLight/Cosmic-Crystals/pull/30), retaining all previously verified M1/M2 game rules. The user's passing human acceptance report now satisfies the **player-sign-off portion** of the M3 five-level campaign, so [M3 #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7) can be closed with this bounded acceptance evidence.

Keep the following **separate** gates open:

- **M0 (#4):** broader Android device matrix, measurable FPS/RAM/latency/thermals, full browser platform testing, signed Gradle AAB and explicit engine production go/no-go.
- **M1 (#3):** long-duration device/interruption/timing checks, desktop modality QA.
- **M2 (#6):** detailed power, Nova and asteroid balance rather than only gameplay smoke.
- **M4 (#8):** audio and user settings, reduced-motion/accessibility checks, bright/dim readability and production visual acceptance. An overall M3 pass is not a complete M4 hardware accessibility audit.
- **M5/M6 (#9/#10):** release candidate and real signed Google Play testing.

## Highest priority after this pass

**Protect saves before distributing another routine APK.** The latest main debug builds are still `ephemeral-ci` signed. An APK signed with a different key may require uninstall/reinstall, deleting `user://lyra-progress.json` and earned campaign progress. Configure a **private, persistent debug signing keystore** (already supported by CI), verify a real update over a same-key build, and explicitly assess/handle any one-time migration/uninstall. Never commit keystores or passwords. Then proceed with M4 audio/UX/accessibility and M5 device QA.

For a future installation, read `build-info.json`, record versionCode/versionName and signing mode, and confirm installed version via ADB. A successful GitHub Actions export is not a substitute for a physical-device test.

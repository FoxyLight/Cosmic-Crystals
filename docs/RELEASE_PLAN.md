# Release and Distribution Plan

**Status:** Forward-looking checklist, not a completed release report.  
**Delivery order:** Android proof of concept → five-level vertical slice → Android/web release candidate → Google Play testing/publication → optional iOS and extended content.

## Version and scope

- **Technology spike:** Godot 4.7.2, procedural 8×8 board, basic move loop. No platform binaries verified.
- **MVP goal:** Five playable Lyra levels, distinctive special pieces and Nova Pulse, galaxy progression, local saves, accessible and polished UI/audio.
- **Later content:** 20 levels/four constellations and iOS. Do not count future content toward first Android acceptance.

**Android debug preview versioning is implemented:** [Android APK Versioning](ANDROID_VERSIONING.md). The source [VERSION](../VERSION) holds the base SemVer (`0.2.0`), CI derives a unique `versionCode` from GitHub run number/attempt and a `versionName` that includes the short Git SHA, exports a versioned APK and validates the embedded manifest with Android `aapt`. The artifact contains a checksum and a JSON build manifest. Optional persistent **debug-only** signing requires a private repository secret; until configured, CI's temporary debug certificates can require uninstall/reinstall on phones.

**Still undecided for Play releases:** Gradle AAB export, secure **release** signing identity, production versionCode allocation and upload/test-track readiness. A debug APK version code scheme is not proof of a production release. The release code must increase with each uploaded app version and stay within Google Play's limit. Record exact commit SHA/package ID for every release candidate.

## Android debug/test preparation (M0)

1. Install matching Godot export templates, Android SDK/platform tools and required Java environment.
2. Define an application package ID and Android preset in the Godot editor.
3. Export a debug APK, install on at least one physical Android device, and exercise touch/board/resume functions.
4. Validate a signed AAB pipeline with a keystore held **outside Git**.
5. Record build artifact size, Android OS, device model, render performance and all known failures in [QA_TEST_PLAN.md](QA_TEST_PLAN.md) and [M0 issue #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4).

The current repository does **not** yet contain proven signed release binaries or Play Console evidence.

## Release candidate and quality gate (M5)

- [ ] Headless rules/test workflow passes on exact release candidate SHA.
- [ ] Five-level gameplay and unlock/save flow pass on Android devices and desktop.
- [ ] Required Android and web test matrix pass with evidence.
- [ ] No critical or high-severity open bugs; exceptions documented.
- [ ] No leaked signing keys/tokens; permissions and included SDKs inspected.
- [ ] Asset licensing/attributions documented and approved.
- [ ] Release notes include known limitations and build identifier.
- [ ] App icons, portrait layout, accessibility and audio controls verified.

## Google Play distribution (M6)

- [ ] Confirm Play Console ownership and app package identifier.
- [ ] Confirm latest Play policies, target API requirements and testing-track eligibility at time of submission. **Do not hardcode a policy/API target from the planning phase.**
- [ ] Store Android signing material in a protected location; do not commit it or put production secrets in publicly logged CI output.
- [ ] Produce and verify signed AAB with release mode configuration.
- [ ] Configure listing: title, screenshots, feature art if required, original description and support details.
- [ ] Prepare privacy policy / Data safety disclosures reflecting **actual** data collection, permissions and integrated SDKs (not assumptions).
- [ ] Complete applicable age/content, ads and content declarations honestly.
- [ ] Upload to an internal/closed test track and verify install, launch, pause/resume, saved progression, crashes and updates.
- [ ] Decide release readiness after feedback and approval requirements are satisfied.
- [ ] Tag the exact final source commit, record AAB version/build and publish changelog.
- [ ] Record public production release only after it is actually approved and available.

Store publication and review links in [M6 issue #10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10).

## Web distribution

Godot's web export requires WebAssembly and WebGL2. Use a served HTTP(S) origin and test desktop and mobile browsers before advertising web availability. Establish hosting, release directory, caching and versioning only after successful export; the separate ChatGPT published concept page is **not** assumed to serve the repo's Godot web build.

## iOS (post-MVP)

Native iOS builds require a separately validated export/signing pipeline and an appropriate Apple development environment. Do not promise iOS release alongside Android without tested builds and their own review requirements.

## Release documentation bundle

For each actual release record: version name/code, commit SHA, engine version, signing/export mode, deployment track/url, environments tested, test evidence, known limitations, data/permission disclosures, and the final ship/hold decision.

**Never** mark a milestone complete on documentation alone; link the real exported artifact/test evidence or store verification.

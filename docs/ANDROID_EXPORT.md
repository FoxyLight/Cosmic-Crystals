# Android Debug Export and Data Safety

Godot 4.7.2 / Compatibility, Android-only. Web presets/jobs/artifacts were removed in M4. [Historical export record](history/PRE_M4_ANDROID_EXPORT.md) is not current setup guidance.

## CI deliverable

`godot-checks.yml` validates/imports the project with strict error-log guards, runs all Android-relevant suites and CPU benchmark, stamps unique versions and exports Android. `aapt` verifies the actual package/version; SHA-256 and `build-info.json` identify the binary; `apksigner` verifies its public certificate. Catalog/audio/license packaging is checked. The isolated emulator installs two independently exported versions signed by the same loaded key and checks a schema-1 save survives an in-place update byte for byte.

The arm64 player APK also includes x86_64 for the emulator. Minimum/target SDK are recorded from the actual manifest. No release AAB or Google Play publication is claimed. Main uses the private debug secret and public-certificate pin; PRs never receive signing secrets and use temporary keys. A missing key is explicitly labeled ephemeral, never stable.

Download the exact versioned Android artifact from [Actions](https://github.com/FoxyLight/Cosmic-Crystals/actions/workflows/godot-checks.yml). It contains APK, build-info and SHA256SUMS. Seven-day artifact retention is not permanent release hosting. Keep an approved binary and metadata privately for reproducibility.

## Local development

Use matching cached Godot editor/templates, JDK and Android SDK. The committed local version is a placeholder, not a distributable unique build. For a numbered local debug build, run `scripts/ci/version_android.py prepare` with deliberately allocated run/attempt and exact commit before export; avoid collisions with CI. Signing paths/passwords must stay outside Git.

## Installation gate

Compare the installed and downloaded certificate, package and versionCode **before** installation. Identical package/key and higher code permit `adb install -r`; never clear data. Do not use uninstall/clear-data/clear-previous-install to bypass incompatibility.

**Legacy-device caveat:** Build 9801 used a different ephemeral signing certificate; a stable-key APK cannot update an installation of 9801. On the test Pixel 7a, the owner had already uninstalled the older package, then a fresh stable-key build 10601 was installed; no old-save recovery was performed. **For any other progress-bearing legacy installation**, do not uninstall it. Close normally, take a verified read-only backup using [the backup tool](../scripts/android_save_backup.py), inspect/validate it and keep two private copies. Only after explicit approval for a one-time replacement: uninstall the old-key app, install the verified stable-key APK, restore the schema-1 JSON via debug `run-as`, verify exact bytes and launch/reopen. If backup access fails, stop and keep the old app.

**Current stable-key evidence:** [main run #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426) passed signature/pin, manifest, checksum, packaging and same-key emulator update tests. GitHub [M4 issue #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) records the Pixel 7a's **10801 → 11001** compatible update and byte-identical save after a private validated backup, without uninstall or clear-data. [Artifact 0.5.1 build 11001](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426/artifacts/12988237867). The new Beam-direction/audio M4 human playtest remains pending.

See [debug signing maintenance/recovery](ANDROID_VERSIONING.md) and [M4 phone checklist](M4_ANDROID_POLISH.md).

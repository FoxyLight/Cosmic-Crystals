# Android APK Versioning and Debug Signing

**Effective:** from the first merged versioned build onward (2026-10-29)
**Owner/source of truth:** [VERSION](../VERSION), [version generator](../scripts/ci/version_android.py), [Godot checks workflow](../.github/workflows/godot-checks.yml).
**Scope:** Android **debug APK previews** in GitHub Actions, not an AAB production signing pipeline.

## Version numbering rules

- `VERSION` is the product's source-controlled SemVer base, currently **`0.4.0`** (M3 Lyra). Bump it intentionally for a meaningful product iteration, not every CI run.
- Each GitHub Actions workflow run receives a unique `GITHUB_RUN_NUMBER`. The run attempt increments when that same run is rerun.
- Android `versionCode = run_number × 100 + run_attempt` (attempts 1–99). Codes increase across **new** workflow runs; rerunning an older workflow can produce an older code than a newer already-installed build. Do not install an older version expecting an upgrade. The generator rejects zero/invalid inputs and a code exceeding **2,100,000,000** (Play limit).
- Android `versionName = <VERSION>-dev.<run_number>.<run_attempt>+g<first8GitSHA>`, for example `0.4.0-dev.74.1+gabc12345`.
- Actual APK filename: `cosmic-crystals-v0.4.0-dev.74.1-gabc12345-debug.apk`.
- GitHub Actions artifact name: `cosmic-crystals-android-v0.4.0-dev.74.1-gabc12345`.
- The export uses the **same** `package/unique_name` as before: `org.foxylight.cosmiccrystals.prototype`.

The CI generator edits Android `version/code` and `version/name` **in the ephemeral checkout**, not in the repository with each commit. The committed `export_presets.cfg` has `versionCode=2` and `versionName=0.4.0-local` for manual editor builds; those baseline values are **not** unique across local exports. To create a uniquely numbered local APK, deliberately set a code above the device's installed version and verify it.

## What GitHub Actions guarantees

The Android job first runs `python3 scripts/ci/version_android.py prepare` with GitHub run number, attempt, full commit SHA, repository and run ID. After Godot exports the versioned APK, it runs `verify`, which invokes the installed Android SDK **`aapt dump badging`** and fails the build unless the *APK's real embedded* package ID, `versionCode` and `versionName` match the intended metadata. Simply renaming an APK is **not** sufficient.

The downloaded ZIP contains:

| File | Purpose |
| --- | --- |
| `cosmic-crystals-v...-debug.apk` | Versioned APK to install |
| `build-info.json` | SemVer base, versionCode, versionName, complete commit SHA, run number/attempt, run link, package ID, signing mode, APK size and SHA-256 |
| `SHA256SUMS.txt` | SHA-256 checksum so transferred APK bytes can be checked |

The check job also runs `python3 -m unittest discover -s tests -p test_android_version.py -v` for invalid SemVer, invalid/overflowing codes, reruns, preview naming, precise preset patching and bad manifest rejection. Debug artifacts are retained for seven days, not published as a public Google Play release. Refer to the specific completed run and Git commit when reporting QA.

## Installing or checking a preview

1. Open the latest successful **main-branch** run under [GitHub Actions](https://github.com/FoxyLight/Cosmic-Crystals/actions/workflows/godot-checks.yml). In **Artifacts**, download the ZIP with the `cosmic-crystals-android-v...` name, then extract it.
2. Read `build-info.json` to confirm exactly which commit, `versionCode` and signing mode you received.
3. With wireless ADB connected, run `adb devices -l` and then install the **actual versioned filename**:

```bash
adb install -r cosmic-crystals-v0.4.0-dev.74.1-gabc12345-debug.apk
```

The above filename is **illustrative**, not a link to a particular real build. Copy the filename from your downloaded ZIP.

To inspect the installed version:

```bash
adb shell dumpsys package org.foxylight.cosmiccrystals.prototype | grep versionCode
```

On a computer with Android build tools, inspect the downloaded APK itself:

```bash
aapt dump badging cosmic-crystals-v0.4.0-dev.74.1-gabc12345-debug.apk | grep '^package:'
```

To verify the downloaded APK has not changed, run `sha256sum -c SHA256SUMS.txt` in the extracted directory.

**Important:** A higher versionCode alone does **not** let Android upgrade an APK signed with a different certificate. If you see `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, read the signing section below. Don't interpret that error as a failure of version numbering.

## Optional stable DEBUG signing for future seamless upgrades

Previously every CI run generated a fresh random debug signing key. This means `adb install -r` can reject a later build even with an increasing versionCode, requiring an uninstall that may delete local data.

The workflow now supports a **private GitHub Actions secret** named `COSMIC_DEBUG_KEYSTORE_BASE64`. If it is configured, **main-branch push builds only** will use the same signing keystore on subsequent runs; PR builds continue to use ephemeral signing. The secret is **not configured by this source change** and must be added securely by a repository maintainer.

To create a reusable **debug-only** signing keystore locally (do not commit it):

```bash
keytool -genkeypair -noprompt -keystore cosmic-debug.keystore \
  -storepass android -keypass android -alias androiddebugkey -keyalg RSA \
  -keysize 2048 -validity 10000 -dname "CN=Cosmic Crystals CI Debug,OU=Development,O=FoxyLight,C=US"
```

Then encode the **file contents** as one line and configure a *repository-level* GitHub Actions secret named `COSMIC_DEBUG_KEYSTORE_BASE64` under **Settings → Secrets and variables → Actions**. Example on Linux or macOS with the GitHub CLI (configured with access to the repository):

```bash
base64 < cosmic-debug.keystore | tr -d '\n' | gh secret set COSMIC_DEBUG_KEYSTORE_BASE64 --repo FoxyLight/Cosmic-Crystals
```

Protect the original keystore, do not expose its base64 in chat/PR logs, and do not store it inside Git. The workflow validates the expected alias `androiddebugkey` and known **debug** password `android`. A debug certificate is **not** a production signing identity.

Once this optional secret is configured, future **main** build metadata reports `"signing_mode": "persistent-secret"`. Without it, the job still passes but reports `"signing_mode": "ephemeral-ci"`. The transition from an older ephemeral-signed APK to the new persistent-signed one generally requires a **one-time uninstall** (which can erase local app data); subsequent upgrades signed by the same secret can use `adb install -r`, provided the versionCode is higher.

## Future release AAB policy

The current pipeline is **debug-only**, with no Google Play submission, production keystore or release AAB. Before an AAB release, establish a separate signed Gradle export job, release-version SemVer policy and Android `versionCode` allocation higher than any version **already uploaded** to Play. Never reuse a versionCode for two different Play uploads of the same package, never put release keys in Git, and independently check release AAB package/version/signature before uploading. Reference [Release Plan](RELEASE_PLAN.md) and [M6 issue #10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10).

## M3 save safety

Campaign progress is private user storage. A signature-mismatch uninstall deletes it. Prefer the existing persistent-debug-secret support before future progress-bearing upgrades, or back up before deliberately reinstalling. This change does not create or commit signing credentials. A source-policy test now rejects local version/name drift from VERSION.

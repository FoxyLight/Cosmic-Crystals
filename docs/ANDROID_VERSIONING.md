# Android APK Versioning and Debug Signing

**Effective:** from the first merged versioned build onward (2026-10-29)
**Owner/source of truth:** [VERSION](../VERSION), [version generator](../scripts/ci/version_android.py), [Godot checks workflow](../.github/workflows/godot-checks.yml).
**Scope:** Android **debug APK previews** in GitHub Actions, not an AAB production signing pipeline.

## Version numbering rules

- `VERSION` is the product's source-controlled SemVer base, currently **`0.5.1`** (Beam movement-direction fix). Bump it intentionally for a meaningful product iteration, not every CI run.
- Each GitHub Actions workflow run receives a unique `GITHUB_RUN_NUMBER`. The run attempt increments when that same run is rerun.
- Android `versionCode = run_number × 100 + run_attempt` (attempts 1–99). Codes increase across **new** workflow runs; rerunning an older workflow can produce an older code than a newer already-installed build. Do not install an older version expecting an upgrade. The generator rejects zero/invalid inputs and a code exceeding **2,100,000,000** (Play limit).
- Android `versionName = <VERSION>-dev.<run_number>.<run_attempt>+g<first8GitSHA>`, for example `0.5.0-dev.74.1+gabc12345`.
- Actual APK filename: `cosmic-crystals-v0.5.0-dev.74.1-gabc12345-debug.apk`.
- GitHub Actions artifact name: `cosmic-crystals-android-v0.5.0-dev.74.1-gabc12345`.
- The export uses the **same** `package/unique_name` as before: `org.foxylight.cosmiccrystals.prototype`.

The CI generator edits Android `version/code` and `version/name` **in the ephemeral checkout**, not in the repository with each commit. The committed `export_presets.cfg` has `versionCode=2` and `versionName=0.5.1-local` for manual editor builds; those baseline values are **not** unique across local exports. To create a uniquely numbered local APK, deliberately set a code above the device's installed version and verify it.

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
3. Compare the actual installed/downloaded signing certificate first. Only if compatible, with wireless ADB connected, run `adb devices -l` and then install the **actual versioned filename**:

```bash
adb install -r cosmic-crystals-v0.5.0-dev.74.1-gabc12345-debug.apk
```

The above filename is **illustrative**, not a link to a particular real build. Copy the filename from your downloaded ZIP.

To inspect the installed version:

```bash
adb shell dumpsys package org.foxylight.cosmiccrystals.prototype | grep versionCode
```

On a computer with Android build tools, inspect the downloaded APK itself:

```bash
aapt dump badging cosmic-crystals-v0.5.0-dev.74.1-gabc12345-debug.apk | grep '^package:'
```

To verify the downloaded APK has not changed, run `sha256sum -c SHA256SUMS.txt` in the extracted directory.

**Important:** A higher versionCode alone does **not** let Android upgrade an APK signed with a different certificate. If you see `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, read the signing section below. Don't interpret that error as a failure of version numbering.

## M4 stable debug signing, maintenance and recovery

Owner setup on 2026-10-30 created private Actions secrets `COSMIC_DEBUG_KEYSTORE_BASE64`, `COSMIC_DEBUG_KEYSTORE_PASSWORD` and `COSMIC_DEBUG_CERT_SHA256`. This is configuration evidence only until a main APK passes the actual cryptographic verification/pin check. Main builds use `persistent-secret`; PRs use explicit `ephemeral-ci` and never access the key. Metadata includes `signing_certificate_sha256`, `stable_signing_verified` and emulator upgrade results. Read these fields rather than assuming a stable label means compatible with an old app.

Public certificate pin: `bb524f7e0b31b29118043206b481505d940cf0ea635f0fc68b978e88fe1a62b2`. Private keystore and local public-pin file reside outside the checkout at `%USERPROFILE%\.codex\private\cosmic-crystals-debug`, with inheritance removed and access limited to the owner/SYSTEM. Keep an encrypted offline backup of this directory in an owner-controlled secure location. Do not put it in Git, APK artifacts, chat or public logs. Debug alias is `androiddebugkey`; the reusable keystore now uses a generated private password in Actions secrets and an ACL-protected local password file. No private password value is committed or printed. The password-protection conversion preserved the exact certificate/private-key identity. A private pre-conversion recovery copy remains in the same protected directory; prefer the current protected keystore/password pair for backups. This is NEVER a production/upload signing key.

To recreate the two secret entries from the SAME existing private key:

```powershell
gh auth login
# Ensure JDK keytool is on PATH.
python scripts/ci/setup_debug_signing.py --private-dir "$env:USERPROFILE\.codex\private\cosmic-crystals-debug"
```

The script reuses an existing key, uploads through stdin, prints only the public certificate, and refuses paths inside the checkout. Initial owner setup was performed in an ACL-restricted directory. On another machine secure that directory's permissions before copying the backup. Re-run main CI and verify the exact pin. Never generate a replacement key merely because a secret was lost: restore the existing key from private backup first. GitHub secrets cannot be read back as a recovery strategy. If all private copies are lost, previous signatures cannot be recreated; explicit backup/migration is necessary.

### Existing player save is protected

Build 9801 used an ephemeral key; its private key is unavailable. New stable signing cannot update it automatically. No M4 development command uninstalls/clears the player app. Close the game normally and, while connected/authorized for ADB, take a new read-only backup:

```powershell
python scripts/android_save_backup.py --adb "PATH_TO_ADB" --serial "EXACT_PHONE_SERIAL" --output "PRIVATE_BACKUP_DIR\lyra-progress-before-m4.json"
```

The script uses debug `run-as`, validates schema/record array sizes, saves exact bytes/checksum and refuses overwrite; it never installs/restores/deletes. Inspect records, validate with `ProgressStore.normalize`, and keep two private backup copies. If run-as is unavailable or the file cannot be validated, keep the old installation and stop. Restore onto a disposable emulator first if needed. Any real-phone uninstall/one-time migration requires new explicit approval, then exact-byte restore verification and a manual launch/relaunch check. The old M2 disposable-app approval is not permission to erase earned M3 saves.

CI's emulator upgrade test uses two separately exported APKs with the same loaded key and an incremented probe code. It installs the first on a disposable emulator, writes a schema-1 earned save, updates with `install -r`, and compares exact bytes. The second probe APK is never published. This validates compatible Android update mechanics, not old-key compatibility or human gameplay. Every distributed APK still uses unique run-based versioning.


### Verified M4 delivery checkpoint

[Main run 106](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41069911792)
verified the stable certificate pin and same-key two-export upgrade/save test.
Build 10601 was independently verified after download and installed fresh on the
Pixel 7a; versionName/code were read back. The owner confirmed they had already
uninstalled the prior copy; no prior app was removed or old save recovered by
M4. The subsequent private-password hardening preserves that same certificate,
so it is eligible for an in-place update, not another uninstall. Exact latest
acceptance artifact and follow-up validation are recorded in #8.

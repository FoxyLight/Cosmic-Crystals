#!/usr/bin/env python3
"""Reproducible versioning of Android debug exports in GitHub Actions.

The source VERSION is the product SemVer base. CI reserves 100 versionCodes per
GitHub workflow run (attempt numbers 1-99) and embeds the resulting code/name
into the Godot Android export preset *in the CI checkout only*. Later builds
from newer run numbers get larger codes. Android still requires identical APK
signing certificates to allow adb install -r.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

PLAY_MAX_VERSION_CODE = 2_100_000_000
RUN_STRIDE = 100
APP_SLUG = "cosmic-crystals"
VERSION_PATTERN = re.compile(r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
GIT_SHA_PATTERN = re.compile(r"^[a-fA-F0-9]{40}$")
PACKAGE_BADGING_PATTERN = re.compile(
    r"^package: name='([^']+)' versionCode='([^']+)' versionName='([^']+)'",
    re.MULTILINE,
)


def calculate_version(base: str, run_number: int, run_attempt: int, git_sha: str) -> dict:
    base = base.strip()
    if not VERSION_PATTERN.fullmatch(base):
        raise ValueError("VERSION must contain three numeric SemVer parts, e.g. 0.2.0")
    if run_number < 1:
        raise ValueError("GitHub run_number must be >= 1")
    if not 1 <= run_attempt < RUN_STRIDE:
        raise ValueError("GitHub run_attempt must be between 1 and 99")
    if not GIT_SHA_PATTERN.fullmatch(git_sha):
        raise ValueError("Git commit must be a full 40-digit hexadecimal SHA")

    version_code = run_number * RUN_STRIDE + run_attempt
    if version_code > PLAY_MAX_VERSION_CODE:
        raise ValueError("versionCode exceeds Google Play's 2,100,000,000 limit")

    short_sha = git_sha[:8].lower()
    version_name = f"{base}-dev.{run_number}.{run_attempt}+g{short_sha}"
    filename = f"{APP_SLUG}-v{base}-dev.{run_number}.{run_attempt}-g{short_sha}-debug.apk"
    return {
        "base_version": base,
        "version_code": version_code,
        "version_name": version_name,
        "apk_filename": filename,
        "git_sha": git_sha.lower(),
        "github_run_number": run_number,
        "github_run_attempt": run_attempt,
    }


def patch_android_preset(text: str, version_code: int, version_name: str) -> tuple[str, str]:
    # Explicit Android section only: don't edit a web preset or a future
    # second platform's version fields.
    heading = "[preset.1.options]"
    if text.count(heading) != 1 or 'platform="Android"' not in text:
        raise ValueError("Expected one Android preset with [preset.1.options]")
    before, options = text.split(heading, 1)
    if "\n[preset." in options:
        options, after = options.split("\n[preset.", 1)
        suffix = "\n[preset." + after
    else:
        suffix = ""

    fields = {
        "version/code": str(version_code),
        "version/name": f'"{version_name}"',
    }
    for field, value in fields.items():
        pattern = rf"(?m)^{re.escape(field)}=.*$"
        options, count = re.subn(pattern, lambda _: f"{field}={value}", options)
        if count != 1:
            raise ValueError(f"Expected exactly one Android {field} setting, got {count}")

    package_match = re.search(r'(?m)^package/unique_name="([^"]+)"$', options)
    if not package_match:
        raise ValueError("Android package/unique_name setting not found")
    package_name = package_match.group(1)
    if not re.fullmatch(r"[a-zA-Z_]\w*(?:\.[a-zA-Z_]\w*)+", package_name):
        raise ValueError(f"Unexpected Android package identifier: {package_name}")
    return before + heading + options + suffix, package_name


def prepare(args: argparse.Namespace) -> None:
    version = calculate_version(
        Path(args.version_file).read_text(encoding="utf-8"),
        args.run_number,
        args.run_attempt,
        args.git_sha,
    )
    path = Path(args.preset)
    preset_text, package_name = patch_android_preset(
        path.read_text(encoding="utf-8"), version["version_code"], version["version_name"]
    )
    path.write_text(preset_text, encoding="utf-8")
    version["package_name"] = package_name
    version["github_run_url"] = (
        f"https://github.com/{args.repository}/actions/runs/{args.run_id}"
    )
    version["build_type"] = "Android debug APK"
    version["signing_mode"] = "pending"
    version["apk_sha256"] = None
    version["apk_bytes"] = None
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / "build-info.json").write_text(
        json.dumps(version, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    apk_path = output_dir / version["apk_filename"]
    artifact = (
        f"{APP_SLUG}-android-v{version['base_version']}-"
        f"dev.{args.run_number}.{args.run_attempt}-g{args.git_sha[:8].lower()}"
    )
    if args.github_output:
        with Path(args.github_output).open("a", encoding="utf-8") as stream:
            stream.write(f"apk_path={apk_path}\n")
            stream.write(f"apk_filename={version['apk_filename']}\n")
            stream.write(f"artifact_name={artifact}\n")
            stream.write(f"version_code={version['version_code']}\n")
            stream.write(f"version_name={version['version_name']}\n")
    print(
        f"Prepared {version['apk_filename']}: "
        f"versionCode={version['version_code']}, "
        f"versionName={version['version_name']}, package={package_name}"
    )


def verify(args: argparse.Namespace) -> None:
    metadata_path = Path(args.metadata)
    info = json.loads(metadata_path.read_text(encoding="utf-8"))
    apk_path = Path(args.apk)
    if apk_path.name != info["apk_filename"] or not apk_path.is_file():
        raise ValueError("APK is missing or its filename differs from build-info.json")

    completed = subprocess.run(
        [args.aapt, "dump", "badging", str(apk_path)],
        capture_output=True, text=True, check=True
    )
    match = PACKAGE_BADGING_PATTERN.search(completed.stdout)
    if not match:
        raise ValueError("Could not read Android package/version metadata from APK using aapt")

    actual_package, actual_code, actual_name = match.groups()
    if actual_package != info["package_name"]:
        raise ValueError(f"APK package mismatch: {actual_package} vs {info['package_name']}")
    if actual_code != str(info["version_code"]):
        raise ValueError(f"APK versionCode mismatch: {actual_code} vs {info['version_code']}")
    if actual_name != info["version_name"]:
        raise ValueError(f"APK versionName mismatch: {actual_name} vs {info['version_name']}")

    if args.signing_mode not in ("ephemeral-ci", "persistent-secret"):
        raise ValueError("Invalid signing mode")
    digest = hashlib.sha256(apk_path.read_bytes()).hexdigest()
    info["apk_sha256"] = digest
    info["apk_bytes"] = apk_path.stat().st_size
    info["signing_mode"] = args.signing_mode
    metadata_path.write_text(json.dumps(info, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    (metadata_path.parent / "SHA256SUMS.txt").write_text(
        f"{digest}  {apk_path.name}\n", encoding="utf-8"
    )
    print(
        f"Verified embedded Android metadata: {actual_package} "
        f"versionCode={actual_code} versionName={actual_name} "
        f"sha256={digest} signing={args.signing_mode}"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    prep = commands.add_parser("prepare", help="Stamp version before Godot export")
    prep.add_argument("--version-file", default="VERSION")
    prep.add_argument("--preset", default="export_presets.cfg")
    prep.add_argument("--run-number", required=True, type=int)
    prep.add_argument("--run-attempt", required=True, type=int)
    prep.add_argument("--git-sha", required=True)
    prep.add_argument("--run-id", required=True, type=int)
    prep.add_argument("--repository", required=True)
    prep.add_argument("--output-dir", default="build/android")
    prep.add_argument("--github-output")
    check = commands.add_parser("verify", help="Validate embedded APK version and write checksum")
    check.add_argument("--metadata", required=True)
    check.add_argument("--apk", required=True)
    check.add_argument("--aapt", required=True)
    check.add_argument("--signing-mode", required=True)
    args = parser.parse_args()
    if args.command == "prepare":
        prepare(args)
    else:
        verify(args)


if __name__ == "__main__":
    main()

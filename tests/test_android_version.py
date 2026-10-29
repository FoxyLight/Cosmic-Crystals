"""CI-only Android versioning contract and manifest verification tests.

python3 -m unittest discover -s tests -p test_android_version.py -v
"""
import argparse
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts.ci.version_android import (
    calculate_version,
    patch_android_preset,
    prepare,
    verify,
)

SHA = "abcdef1234567890abcdef1234567890abcdef12"
PRESET = """[preset.0]
name="Web"
platform="Web"
[preset.0.options]
some/key=1
[preset.1]
name="Android"
platform="Android"
[preset.1.options]
package/unique_name="org.foxylight.cosmiccrystals.prototype"
version/code=1
version/name="0.1.0-spike"
"""


class AndroidVersionTests(unittest.TestCase):
    def test_sequential_runs_and_reruns_are_distinct(self):
        a = calculate_version("0.2.0", 73, 1, SHA)
        b = calculate_version("0.2.0", 74, 1, SHA)
        rerun = calculate_version("0.2.0", 73, 2, SHA)
        self.assertEqual(a["version_code"], 7301)
        self.assertEqual(b["version_code"], 7401)
        self.assertEqual(rerun["version_code"], 7302)
        self.assertLess(a["version_code"], rerun["version_code"])
        self.assertLess(rerun["version_code"], b["version_code"])
        self.assertEqual(a["version_name"], "0.2.0-dev.73.1+gabcdef12")
        self.assertEqual(
            a["apk_filename"], "cosmic-crystals-v0.2.0-dev.73.1-gabcdef12-debug.apk"
        )

    def test_versions_and_builds_are_validated(self):
        for base in ["0.2", "release", "v0.2.0", "01.2.3", "0.2.0-dev"]:
            with self.subTest(base=base), self.assertRaises(ValueError):
                calculate_version(base, 1, 1, SHA)
        for number, attempt in [(0, 1), (-1, 1), (1, 0), (1, 100), (21_000_001, 1)]:
            with self.subTest(number=number, attempt=attempt), self.assertRaises(ValueError):
                calculate_version("0.2.0", number, attempt, SHA)
        with self.assertRaises(ValueError):
            calculate_version("0.2.0", 73, 1, "not-a-full-git-sha")

    def test_android_only_preset_patch(self):
        result, package = patch_android_preset(PRESET, 7301, "0.2.0-dev.73.1+gabcdef12")
        self.assertEqual(package, "org.foxylight.cosmiccrystals.prototype")
        self.assertIn('platform="Web"', result)
        self.assertIn("some/key=1", result)
        self.assertIn("version/code=7301", result)
        self.assertIn('version/name="0.2.0-dev.73.1+gabcdef12"', result)
        self.assertNotIn("version/code=1\n", result)
        with self.assertRaises(ValueError):
            patch_android_preset(PRESET.replace("version/code=1\n", ""), 4, "x")

    def test_prepare_and_manifest_verification(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "VERSION").write_text("0.2.0\n", encoding="utf-8")
            (root / "export_presets.cfg").write_text(PRESET, encoding="utf-8")
            output_file = root / "outputs"
            prepare(argparse.Namespace(
                version_file=str(root / "VERSION"),
                preset=str(root / "export_presets.cfg"),
                run_number=73, run_attempt=1, git_sha=SHA,
                repository="FoxyLight/Cosmic-Crystals", run_id=12345,
                output_dir=str(output_file), github_output=str(root / "github_output"),
            ))
            info_path = output_file / "build-info.json"
            info = json.loads(info_path.read_text(encoding="utf-8"))
            self.assertEqual(info["version_code"], 7301)
            self.assertEqual(info["github_run_url"],
                             "https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/12345")
            self.assertIn("artifact_name=cosmic-crystals-android-v0.2.0-dev.73.1-gabcdef12",
                          (root / "github_output").read_text(encoding="utf-8"))
            apk = output_file / info["apk_filename"]
            apk.write_bytes(b"not a real APK, mocked aapt validates the contract")
            mocked = argparse.Namespace(
                metadata=str(info_path), apk=str(apk), aapt="aapt",
                signing_mode="ephemeral-ci",
            )
            class Result:
                stdout = ("package: name='org.foxylight.cosmiccrystals.prototype' "
                          "versionCode='7301' versionName='0.2.0-dev.73.1+gabcdef12'\n")
            with patch("scripts.ci.version_android.subprocess.run", return_value=Result()):
                verify(mocked)
            verified = json.loads(info_path.read_text(encoding="utf-8"))
            self.assertEqual(verified["apk_bytes"], apk.stat().st_size)
            self.assertEqual(verified["signing_mode"], "ephemeral-ci")
            self.assertEqual(len(verified["apk_sha256"]), 64)
            self.assertIn(apk.name, (output_file / "SHA256SUMS.txt").read_text())

            class WrongVersion:
                stdout = ("package: name='org.foxylight.cosmiccrystals.prototype' "
                          "versionCode='1' versionName='0.1.0-spike'\n")
            with patch("scripts.ci.version_android.subprocess.run", return_value=WrongVersion()):
                with self.assertRaisesRegex(ValueError, "versionCode mismatch"):
                    verify(mocked)


if __name__ == "__main__":
    unittest.main()

"""Exercise the emulator-only probe without ever connecting to a real device."""
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from scripts.ci import check_upgrade


class UpgradeTests(unittest.TestCase):
    def run_probe(self, serial="emulator-5554", changed=False, failed_install=False):
        calls = []
        saved = b""
        reads = 0

        def adb(command, *, input, check, capture_output):
            nonlocal saved, reads
            calls.append(command)
            self.assertTrue(check and capture_output)
            if command == ["adb", "get-serialno"]:
                return subprocess.CompletedProcess(command, 0, serial.encode())
            self.assertEqual(command[:3], ["adb", "-s", serial])
            if "install" in command and failed_install:
                raise subprocess.CalledProcessError(1, command)
            if input is not None:
                saved = input
            if "exec-out" in command:
                reads += 1
                return subprocess.CompletedProcess(command, 0, saved + (b"changed" if changed and reads == 2 else b""))
            return subprocess.CompletedProcess(command, 0, b"Success")

        with tempfile.TemporaryDirectory() as folder:
            metadata = Path(folder) / "build-info.json"
            metadata.write_text('{"git_sha":"fixture"}', encoding="utf-8")
            args = ["probe", "--first", "first.apk", "--second", "second.apk", "--metadata", str(metadata)]
            with patch.object(sys, "argv", args), patch.object(check_upgrade.subprocess, "run", side_effect=adb):
                if not serial.startswith("emulator-") or changed:
                    with self.assertRaises(ValueError):
                        check_upgrade.main()
                    self.assertNotIn("compatible_update_probe", json.loads(metadata.read_text()))
                elif failed_install:
                    with self.assertRaises(subprocess.CalledProcessError):
                        check_upgrade.main()
                    self.assertNotIn("compatible_update_probe", json.loads(metadata.read_text()))
                else:
                    check_upgrade.main()
                    info = json.loads(metadata.read_text())
                    self.assertTrue(info["compatible_update_probe"]["passed"])
                    self.assertEqual(info["git_sha"], "fixture")
                    preferences = json.loads(saved)["settings"]
                    self.assertTrue(preferences["large_text"] and preferences["muted"])
                    self.assertEqual(preferences["music_volume"], .3)
                    self.assertIn(["adb", "-s", serial, "install", "-r", "second.apk"], calls)
            if not serial.startswith("emulator-"):
                self.assertEqual(len(calls), 1)

    def test_same_key_upgrade_includes_reading_and_audio_preferences(self):
        self.run_probe()

    def test_physical_or_missing_target_refused_before_any_write(self):
        for serial in ["phone-123", "adb-wireless._tcp", "unknown", ""]:
            with self.subTest(serial=serial):
                self.run_probe(serial=serial)

    def test_changed_save_cannot_report_success(self):
        self.run_probe(changed=True)

    def test_install_failure_cannot_report_success(self):
        self.run_probe(failed_install=True)


if __name__ == "__main__":
    unittest.main()

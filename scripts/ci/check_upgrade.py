"""Emulator-only proof that separately exported same-key APKs retain app data."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

PACKAGE = "org.foxylight.cosmiccrystals.prototype"


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--first", required=True)
    p.add_argument("--second", required=True)
    p.add_argument("--metadata", required=True)
    a = p.parse_args()
    def adb(*args, data=None):
        return subprocess.run(["adb", *args], input=data, check=True, capture_output=True).stdout
    # Safeguard: this helper must NEVER target the player's real device.
    serial = adb("get-serialno").decode().strip()
    if not serial.startswith("emulator-"):
        raise ValueError("Upgrade probe is restricted to an isolated emulator")
    adb("install", a.first)
    save = json.dumps({"schema_version": 1, "highest_unlocked": 3,
                      "completed": [True, True, False, False, False],
                      "best_scores": [835, 1100, 0, 0, 0], "best_stars": [3, 3, 0, 0, 0],
                      "tutorials_seen": [1, 2], "settings": {"reduced_motion": True, "muted": True,
                      "master_volume": .65, "music_volume": .3, "sfx_volume": .6}}).encode()
    adb("shell", "run-as", PACKAGE, "mkdir", "-p", "files")
    adb("shell", "run-as", PACKAGE, "sh", "-c", "'cat > files/lyra-progress.json'", data=save)
    before = adb("exec-out", "run-as", PACKAGE, "cat", "files/lyra-progress.json")
    if before != save: raise ValueError("Probe save did not reach the app sandbox intact")
    adb("install", "-r", a.second)
    after = adb("exec-out", "run-as", PACKAGE, "cat", "files/lyra-progress.json")
    if after != before: raise ValueError("In-place update changed app data")
    info = json.loads(Path(a.metadata).read_text())
    info["compatible_update_probe"] = {"passed": True, "environment": "isolated Android emulator",
                                        "save_sha256": hashlib.sha256(after).hexdigest(),
                                        "scope": "two consecutive same-key exports; not compatibility with the player's old certificate"}
    Path(a.metadata).write_text(json.dumps(info, indent=2, sort_keys=True) + "\n")
    print("Two separately exported same-key APKs: in-place update and exact save bytes PASS")


if __name__ == "__main__":
    main()

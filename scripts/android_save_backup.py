"""Read-only backup of this debuggable game's save via an explicitly named phone.

Never uninstalls, force-stops, installs, restores or deletes. Close the game
normally first. A restore/migration requires separate explicit human approval.
"""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

PACKAGE = "org.foxylight.cosmiccrystals.prototype"


def validate_save(payload):
    if not payload.lstrip().startswith(b"{"):
        raise ValueError("No readable campaign save. Verify package/device and debug access. Original installation untouched.")
    raw = json.loads(payload)
    if raw.get("schema_version") != 1 or any(not isinstance(raw.get(k), list) or len(raw[k]) != 5
                                           for k in ["completed", "best_scores", "best_stars"]):
        raise ValueError("Save schema/records could not be verified; original installation untouched")
    for completed, score, stars in zip(raw["completed"], raw["best_scores"], raw["best_stars"]):
        if type(completed) is not bool or type(score) is not int or type(stars) is not int:
            raise ValueError("Invalid save record types; original installation untouched")
        if not 0 <= score <= 1_000_000_000 or not 0 <= stars <= 3 or completed and stars < 1:
            raise ValueError("Invalid save record range; original installation untouched")
    return raw


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--adb", default="adb")
    p.add_argument("--serial", required=True)
    p.add_argument("--output", type=Path, required=True)
    a = p.parse_args()
    if a.output.exists():
        raise ValueError("Choose a new backup path; existing backups are never overwritten")
    result = subprocess.run([a.adb, "-s", a.serial, "exec-out", "run-as", PACKAGE,
                             "cat", "files/lyra-progress.json"], check=True, capture_output=True)
    validate_save(result.stdout)
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_bytes(result.stdout)
    digest = hashlib.sha256(result.stdout).hexdigest()
    a.output.with_suffix(a.output.suffix + ".sha256").write_text(digest + "\n")
    print("Read-only save backup verified. SHA-256:", digest)
    print("No app data changed. Keep the original installation until migration is approved and verified.")


if __name__ == "__main__":
    main()

"""Verify actual APK certificate (not a label), optionally pin stable identity."""
import argparse
import json
import re
import subprocess
from pathlib import Path


def fingerprint(output):
    matches = re.findall(r"Signer #\d+ certificate SHA-256 digest: ([a-fA-F0-9]{64})", output)
    if len(matches) != 1:
        raise ValueError("Expected exactly one verified signing certificate")
    return matches[0].lower()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--apksigner", required=True)
    p.add_argument("--apk", required=True)
    p.add_argument("--metadata", required=True)
    p.add_argument("--expected", default="")
    args = p.parse_args()
    info = json.loads(Path(args.metadata).read_text())
    result = subprocess.run([args.apksigner, "verify", "--verbose", "--print-certs", args.apk],
                            check=True, capture_output=True, text=True)
    actual = fingerprint(result.stdout)
    expected = args.expected.replace(":", "").strip().lower()
    if info["signing_mode"] == "persistent-secret" and not re.fullmatch(r"[a-f0-9]{64}", expected):
        raise ValueError("Stable signing requires the owner-configured certificate pin")
    if expected and actual != expected:
        raise ValueError("APK signing certificate does not match configured pin")
    info["signing_certificate_sha256"] = actual
    info["stable_signing_verified"] = info["signing_mode"] == "persistent-secret" and actual == expected
    Path(args.metadata).write_text(json.dumps(info, indent=2, sort_keys=True) + "\n")
    print("APK cryptographic signature verified; stable identity:", info["stable_signing_verified"])
    print("Public certificate SHA-256:", actual)


if __name__ == "__main__":
    main()

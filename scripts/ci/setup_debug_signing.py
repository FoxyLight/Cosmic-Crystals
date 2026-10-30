"""Owner-run one-time stable debug setup; never prints private signing values.

Requires gh authenticated with repository-secret write permission and JDK keytool.
Output is outside the checkout. Back up this private directory securely.
"""
import argparse
import base64
import hashlib
import subprocess
from pathlib import Path


def run(*args, data=None):
    return subprocess.run(args, input=data, check=True, capture_output=True).stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--private-dir", type=Path, required=True)
    args = parser.parse_args()
    directory = args.private_dir.resolve()
    repo = Path(__file__).resolve().parents[2]
    if directory == repo or repo in directory.parents:
        raise ValueError("Private backup directory must be outside the checkout")
    run("gh", "auth", "status")
    directory.mkdir(parents=True, exist_ok=True)
    key = directory / "cosmic-debug.keystore"
    if not key.exists():
        run("keytool", "-genkeypair", "-noprompt", "-keystore", str(key), "-storepass", "android",
            "-keypass", "android", "-alias", "androiddebugkey", "-keyalg", "RSA", "-keysize", "3072",
            "-validity", "10000", "-dname", "CN=Cosmic Crystals Private Debug,O=FoxyLight,C=US")
    # Debug passwords are the standard Android defaults; private key access,
    # not the well-known password, is the security boundary. Never a Play key.
    cert = run("keytool", "-exportcert", "-keystore", str(key), "-storepass", "android", "-alias", "androiddebugkey")
    digest = hashlib.sha256(cert).hexdigest()
    run("gh", "secret", "set", "COSMIC_DEBUG_KEYSTORE_BASE64", "--repo", "FoxyLight/Cosmic-Crystals",
        data=base64.b64encode(key.read_bytes()))
    run("gh", "secret", "set", "COSMIC_DEBUG_CERT_SHA256", "--repo", "FoxyLight/Cosmic-Crystals", data=digest.encode())
    (directory / "certificate-sha256.txt").write_text(digest + "\n")
    print("Private Actions secrets configured. Back up the private directory securely.")
    print("Public certificate SHA-256:", digest)
    print("Not enabled/verified until a main CI APK passes certificate-pin validation.")


if __name__ == "__main__":
    main()

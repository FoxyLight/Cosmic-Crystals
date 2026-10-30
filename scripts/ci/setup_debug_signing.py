"""Owner-run one-time stable debug setup; never prints private signing values.

Requires gh authenticated with repository-secret write permission and JDK keytool.
Output is outside the checkout. Back up this private directory securely.
"""
import argparse
import base64
import hashlib
import os
import secrets
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
    password_file = directory / "debug-keystore-password.txt"
    password = password_file.read_text().strip() if password_file.exists() else secrets.token_urlsafe(36)
    os.environ["COSMIC_SETUP_PASSWORD"] = password
    if not key.exists():
        run("keytool", "-genkeypair", "-noprompt", "-keystore", str(key), "-storepass:env", "COSMIC_SETUP_PASSWORD",
            "-keypass:env", "COSMIC_SETUP_PASSWORD", "-alias", "androiddebugkey", "-keyalg", "RSA", "-keysize", "3072",
            "-validity", "10000", "-dname", "CN=Cosmic Crystals Private Debug,O=FoxyLight,C=US")
    elif not password_file.exists():
        # Upgrade this setup tool's original default-password container while
        # retaining exactly the same private key/certificate. Never rotate key.
        original_cert = run("keytool", "-exportcert", "-keystore", str(key), "-storepass", "android", "-alias", "androiddebugkey")
        converted = directory / "cosmic-debug-protected.keystore"
        if converted.exists(): raise ValueError("Unfinished conversion exists; inspect private backups first")
        run("keytool", "-importkeystore", "-noprompt", "-srckeystore", str(key), "-srcstorepass", "android",
            "-srcalias", "androiddebugkey", "-destkeystore", str(converted), "-deststoretype", "PKCS12",
            "-deststorepass:env", "COSMIC_SETUP_PASSWORD", "-destkeypass:env", "COSMIC_SETUP_PASSWORD")
        converted_cert = run("keytool", "-exportcert", "-keystore", str(converted),
                             "-storepass:env", "COSMIC_SETUP_PASSWORD", "-alias", "androiddebugkey")
        if original_cert != converted_cert: raise ValueError("Certificate changed; original key is untouched")
        # Preserve a private recovery copy. Both files remain outside Git.
        key.rename(directory / "cosmic-debug-original-private-backup.keystore")
        converted.rename(key)
    password_file.write_text(password + "\n")
    cert = run("keytool", "-exportcert", "-keystore", str(key), "-storepass:env", "COSMIC_SETUP_PASSWORD", "-alias", "androiddebugkey")
    digest = hashlib.sha256(cert).hexdigest()
    run("gh", "secret", "set", "COSMIC_DEBUG_KEYSTORE_BASE64", "--repo", "FoxyLight/Cosmic-Crystals",
        data=base64.b64encode(key.read_bytes()))
    run("gh", "secret", "set", "COSMIC_DEBUG_CERT_SHA256", "--repo", "FoxyLight/Cosmic-Crystals", data=digest.encode())
    run("gh", "secret", "set", "COSMIC_DEBUG_KEYSTORE_PASSWORD", "--repo", "FoxyLight/Cosmic-Crystals", data=password.encode())
    (directory / "certificate-sha256.txt").write_text(digest + "\n")
    print("Private Actions secrets configured. Back up the private directory securely.")
    print("Public certificate SHA-256:", digest)
    print("Not enabled/verified until a main CI APK passes certificate-pin validation.")


if __name__ == "__main__":
    main()

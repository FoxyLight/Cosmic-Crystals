"""Fail export CI if the authored level catalog or font notices are absent."""
import json
import sys
import zipfile
from pathlib import Path

REQUIRED = (
    "data/lyra_levels.json",
    "assets/fonts/DM-Sans-OFL.txt",
    "assets/fonts/Outfit-OFL.txt",
)


def main(path: Path) -> None:
    if path.suffix == ".apk":
        with zipfile.ZipFile(path) as archive:
            for name in REQUIRED:
                assert f"assets/{name}" in archive.namelist(), f"Missing Android asset: {name}"
            data = json.loads(archive.read("assets/data/lyra_levels.json"))
            assert data["schema_version"] == 1
            assert [level["id"] for level in data["levels"]] == [1, 2, 3, 4, 5]
    elif path.suffix == ".pck":
        # Godot's unencrypted PCK directory contains resource path strings.
        # Runtime/contents are separately exercised in scene/browser tests.
        packed = path.read_bytes()
        for name in REQUIRED:
            assert name.encode("utf-8") in packed, f"Missing Web pack path: {name}"
    else:
        raise ValueError("Expected an APK or Web PCK")
    print("Verified exported Lyra catalog and both font-license assets")


if __name__ == "__main__":
    main(Path(sys.argv[1]))

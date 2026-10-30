"""Fail export CI if the authored level catalog or font notices are absent."""
import json
import sys
import zipfile
from pathlib import Path

REQUIRED = (
    "data/lyra_levels.json",
    "assets/fonts/DM-Sans-OFL.txt",
    "assets/fonts/Outfit-OFL.txt",
    "assets/audio/PROVENANCE.txt",
)


def main(path: Path) -> None:
    if path.suffix == ".apk":
        with zipfile.ZipFile(path) as archive:
            for name in REQUIRED:
                assert f"assets/{name}" in archive.namelist(), f"Missing Android asset: {name}"
            for name in ("select swap invalid match cascade beam bomb supernova nova rock_hit rock_break victory defeat star unlock menu confirm music_home music_map music_game music_win music_lose").split():
                # Godot packs audio as imported sample resources with remap files.
                assert any(("/" + name + ".wav-") in item and item.endswith(".sample") for item in archive.namelist()), f"Missing audio: {name}"
            data = json.loads(archive.read("assets/data/lyra_levels.json"))
            assert data["schema_version"] == 1
            assert [level["id"] for level in data["levels"]] == [1, 2, 3, 4, 5]
    else:
        raise ValueError("Expected an Android APK")
    print("Verified exported Lyra catalog and both font-license assets")


if __name__ == "__main__":
    main(Path(sys.argv[1]))

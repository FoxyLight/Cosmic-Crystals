import math
import unittest
import wave
from pathlib import Path
from scripts.ci.verify_signing import fingerprint

ROOT = Path(__file__).resolve().parents[1]


class AndroidPolishTests(unittest.TestCase):
    def test_certificate_output_is_strict(self):
        digest = "a1" * 32
        self.assertEqual(fingerprint("Signer #1 certificate SHA-256 digest: " + digest), digest)
        for text in ["not verified", "SHA-256: " + digest,
                     "Signer #1 certificate SHA-256 digest: " + digest + "\nSigner #2 certificate SHA-256 digest: " + digest]:
            with self.assertRaises(ValueError): fingerprint(text)

    def test_audio_is_valid_original_pcm_with_headroom(self):
        import array
        files = list((ROOT / "assets/audio").glob("*.wav"))
        self.assertEqual(len(files), 22)
        for path in files:
            with self.subTest(asset=path.name), wave.open(str(path)) as source:
                self.assertEqual(source.getnchannels(), 1)
                self.assertEqual(source.getsampwidth(), 2)
                self.assertEqual(source.getframerate(), 22050)
                values = array.array("h", source.readframes(source.getnframes()))
                self.assertLess(max(abs(x) for x in values), 27000)
                self.assertGreater(max(abs(x) for x in values), 1000)
                if path.stem.startswith("music_"):
                    self.assertEqual(len(values), 16 * 22050)
                    self.assertLess(abs(values[0] - values[-1]), 1000)
                else:
                    self.assertLess(abs(values[0]), 5)
                    self.assertLess(abs(values[-1]), 5)

    def test_android_only_workflow_and_preserved_identity(self):
        workflow = (ROOT / ".github/workflows/godot-checks.yml").read_text()
        presets = (ROOT / "export_presets.cfg").read_text()
        self.assertNotIn("web-export:", workflow)
        self.assertNotIn('platform="Web"', presets)
        self.assertIn('package/unique_name="org.foxylight.cosmiccrystals.prototype"', presets)
        self.assertIn("verify_signing.py", workflow)
        self.assertIn("check_upgrade.py", workflow)
        self.assertIn("COSMIC_DEBUG_CERT_SHA256", workflow)
        self.assertIn("strict", (ROOT / "docs/QA_TEST_PLAN.md").read_text().lower())


if __name__ == "__main__": unittest.main()

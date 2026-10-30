"""Original Cosmic Crystals synthesis, no samples or third-party compositions.

Reproducible 22.05 kHz PCM. Music is an original four-chord suspended pentatonic
pad/motif; SFX use short tuned envelopes. Regenerate with Python stdlib only.
"""
import math
import wave
import struct
from pathlib import Path

RATE = 22050
ROOT = Path(__file__).resolve().parents[2] / "assets/audio"
SFX = {
    "select": ([880], .09), "swap": ([440, 660], .15),
    "invalid": ([220, 196], .23), "match": ([523.25, 659.25, 783.99], .28),
    "cascade": ([659.25, 783.99, 1046.5], .35),
    "beam": ([330, 660, 1320], .40), "bomb": ([110, 165, 220], .45),
    "supernova": ([261.63, 523.25, 1046.5, 1568], .55),
    "nova": ([130.81, 261.63, 392, 523.25, 784], .65),
    "rock_hit": ([147, 233], .15), "rock_break": ([98, 147, 294], .32),
    "victory": ([523.25, 659.25, 783.99, 1046.5], .85),
    "defeat": ([392, 329.63, 293.66], .75),
    "star": ([1046.5, 1318.5], .30), "unlock": ([659.25, 880, 1046.5], .48),
    "menu": ([587.33, 783.99], .12), "confirm": ([659.25, 987.77], .18),
}


def write(name, samples):
    with wave.open(str(ROOT / (name + ".wav")), "wb") as out:
        out.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        out.writeframes(b"".join(struct.pack("<h", round(max(-.8, min(.8, s)) * 32767)) for s in samples))


def main():
    ROOT.mkdir(parents=True, exist_ok=True)
    for name, (notes, duration) in SFX.items():
        samples = []
        for i in range(round(duration * RATE)):
            t = i / RATE
            step = min(len(notes) - 1, int(t / duration * len(notes)))
            frequency = notes[step]
            envelope = min(1, t / .008) * (1 - t / duration) ** 1.6
            tone = math.sin(math.tau * frequency * t) + .18 * math.sin(math.tau * frequency * 2 * t)
            samples.append(.25 * envelope * tone)
        write(name, samples)
    # All frequencies are integer cycles per 16-second loop. Cosine voices
    # and the 4-second pulse have identical values/derivatives at the seam.
    for index, name in enumerate(["home", "map", "game", "win", "lose"]):
        notes = [130.8125, 196, 261.625, 329.625, 392, 523.25]
        samples = []
        for i in range(RATE * 16):
            t = i / RATE
            value = 0.0
            for voice, frequency in enumerate(notes):
                phase = math.tau * (t / 16 + voice / 6 + index / 9)
                envelope = .035 + .018 * math.cos(phase)
                value += envelope * math.cos(math.tau * frequency * t)
            # A quiet original ascending/descending pentatonic motif.
            beat = int(t / 2)
            sequence = [0, 2, 3, 4, 3, 2, 4, 1]
            local = t % 2
            frequency = notes[sequence[(beat + index) % 8]] * 2
            value += .065 * math.sin(math.pi * local / 2) ** 2 * math.cos(math.tau * frequency * local)
            samples.append(value * (.8 if name == "lose" else 1))
        write("music_" + name, samples)
    print("Generated 17 original effects and 5 seamless ambient loops")


if __name__ == "__main__":
    main()

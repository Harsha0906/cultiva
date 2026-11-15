"""Generates Cultiva's retro sound effects (16-bit mono 22.05 kHz WAV).

Everything is synthesised here, so the sounds are Cultiva's own.
Run:  python tools/audio/make_sfx.py   -> app/assets/sfx/*.wav
"""
import math
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parents[2] / "app" / "assets" / "sfx"


def note(name):
    names = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}
    base, octave = names[name[0]], int(name[-1])
    sharp = 1 if "#" in name else 0
    return 440.0 * 2 ** ((base + sharp + (octave - 4) * 12) / 12)


def square(phase, duty=0.5):
    return 1.0 if (phase % 1.0) < duty else -1.0


def triangle(phase):
    p = phase % 1.0
    return 4 * p - 1 if p < 0.5 else 3 - 4 * p


def tone(freq_fn, dur, wave_fn=square, vol=0.35, attack=0.004, decay=None):
    """freq_fn(t) -> Hz. Exponential decay envelope plus short fades (no clicks)."""
    n = int(dur * RATE)
    out, phase = [], 0.0
    decay = decay or dur / 3
    for i in range(n):
        t = i / RATE
        phase += freq_fn(t) / RATE
        env = min(1.0, t / attack) * math.exp(-t / decay)
        env *= min(1.0, (dur - t) / 0.008)  # fade-out
        out.append(wave_fn(phase) * env * vol)
    return out


def seq(*parts, gap=0.0):
    out = []
    for p in parts:
        out += p + [0.0] * int(gap * RATE)
    return out


def mix(a, b):
    n = max(len(a), len(b))
    a, b = a + [0.0] * (n - len(a)), b + [0.0] * (n - len(b))
    return [x + y for x, y in zip(a, b)]


def write(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = min(1.0, 0.9 / peak)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(
            struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767 * 0.8))
            for s in samples))
    print(f"{name}.wav  {len(samples) / RATE * 1000:.0f} ms")


def const(f):
    return lambda t: f


# plant: low square pop, pitch falling 330 -> 140 Hz
write("plant", tone(lambda t: 330 - 1600 * t, 0.12, vol=0.4, decay=0.05))
# ripen: two rising notes
write("ripen", seq(tone(const(note("E5")), 0.08, decay=0.05),
                   tone(const(note("A5")), 0.10, decay=0.06)))
# harvest: plucked triangle + bright square chime an octave up
write("harvest", mix(tone(const(note("G4")), 0.30, triangle, vol=0.6, decay=0.10),
                     seq([0.0] * int(0.04 * RATE),
                         tone(const(note("D6")), 0.26, square, vol=0.18, decay=0.08))))
# coin: classic two-tone ding B5 -> E6
write("coin", seq(tone(const(note("B5")), 0.06, square, vol=0.3, decay=0.2),
                  tone(const(note("E6")), 0.16, square, vol=0.3, decay=0.07)))
# done: rising C-E-G-C arpeggio
write("done", seq(*[tone(const(note(n)), 0.1 if n != "C6" else 0.15, square,
                         vol=0.3, decay=0.07, attack=0.003)
                    for n in ("C5", "E5", "G5", "C6")]))
# buy: soft register blip - quick high blip then a lower thunk
write("buy", seq(tone(const(note("A6")), 0.05, square, vol=0.22, decay=0.03),
                 tone(const(note("E5")), 0.15, triangle, vol=0.5, decay=0.05)))

"""Cultiva app icon: a pixel-art sprout in a soil mound on brand teal.

Writes Android launcher icons (legacy + adaptive + monochrome), the splash
icon, a white notification silhouette, and a 512 px Play Store icon.
Run: python tools/art/draw_icon.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
RES = ROOT / "app" / "android" / "app" / "src" / "main" / "res"
STORE = ROOT / "docs" / "design" / "store"

TEAL, TEAL_DARK, TEAL_LIGHT = "#2a6f70", "#173f43", "#358a85"

# 16x16 sprout. Legend: . empty, o outline, g/G/l leaf shades, s stem,
# d/D/b soil shades, h soil highlight.
SPROUT = [
    "................",
    "...ooo....ooo...",
    "..oGGGo..oGGGo..",
    ".oGgglGooGlggGo.",
    ".oGgglllolllgGo.",
    "..oGgggsogggGo..",
    "...oGGgsoGGGo...",
    "....ooosoooo....",
    ".......so.......",
    ".......so.......",
    "....oooooooo....",
    "..oohhbbbbbhoo..",
    ".ohbbbdbbbbdbbo.",
    ".obbdbbbbdbbbDo.",
    "..oDDDDDDDDDDo..",
    "...oooooooooo...",
]
PAL = {
    "o": "#1f1a14",
    "G": "#3f8a3a",
    "g": "#6db356",
    "l": "#a6d86e",
    "s": "#4f7d2c",
    "b": "#8a5a34",
    "d": "#6b4426",
    "D": "#4e3019",
    "h": "#b07a4c",
}


def sprout(scale, mono=None):
    img = Image.new("RGBA", (16 * scale, 16 * scale), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for y, row in enumerate(SPROUT):
        for x, ch in enumerate(row):
            if ch == ".":
                continue
            c = mono or PAL[ch]
            d.rectangle(
                [x * scale, y * scale, (x + 1) * scale - 1, (y + 1) * scale - 1],
                fill=c,
            )
    return img


def teal_tile(grid, rounded=True):
    """Teal background on a `grid`-art-px canvas with a 1px lighter top edge."""
    img = Image.new("RGBA", (grid, grid), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = grid // 6 if rounded else 0
    if rounded:
        d.rounded_rectangle([0, 0, grid - 1, grid - 1], r, fill=TEAL_DARK)
        d.rounded_rectangle([1, 1, grid - 2, grid - 2], r - 1, fill=TEAL)
    else:
        d.rectangle([0, 0, grid - 1, grid - 1], fill=TEAL)
    # A few soft "grass" pixels for texture.
    for x, y in [(3, grid - 5), (grid - 6, 4), (5, 6), (grid - 4, grid - 7)]:
        d.point((x, y), fill=TEAL_LIGHT)
    return img


def up(img, k):
    return img.resize((img.width * k, img.height * k), Image.NEAREST)


def compose(grid, art_scale, background=True, rounded=True, mono=None):
    canvas = teal_tile(grid, rounded) if background else Image.new(
        "RGBA", (grid, grid), (0, 0, 0, 0))
    s = sprout(art_scale, mono)
    off = (grid - s.width) // 2
    canvas.alpha_composite(s, (off, off))
    return canvas


DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def main():
    # Legacy square icon: 48dp = 24 art px x 2 per dp.
    legacy = compose(24, 1)
    # Adaptive layers: 108dp = 54 art px x 2 per dp; sprout at 2x (32 px)
    # stays inside the 66dp (33 px) safe zone.
    fg = compose(54, 2, background=False)
    bg = teal_tile(54, rounded=False)
    mono = compose(54, 2, background=False, mono="#ffffff")
    # Notification small icon: 24dp, white silhouette.
    stat = compose(24, 1, background=False, mono="#ffffff")
    for name, k in DENSITIES.items():
        folder = RES / f"mipmap-{name}"
        folder.mkdir(parents=True, exist_ok=True)
        f = int(2 * k)
        up(legacy, f).save(folder / "ic_launcher.png") if f == 2 * k else (
            legacy.resize((int(48 * k),) * 2, Image.NEAREST).save(
                folder / "ic_launcher.png"))
        size = int(108 * k)
        for img, fname in [(fg, "ic_launcher_foreground.png"),
                           (bg, "ic_launcher_background.png"),
                           (mono, "ic_launcher_monochrome.png")]:
            img.resize((size, size), Image.NEAREST).save(folder / fname)
        dfolder = RES / f"drawable-{name}"
        dfolder.mkdir(parents=True, exist_ok=True)
        stat.resize((int(24 * k),) * 2, Image.NEAREST).save(
            dfolder / "ic_stat_sprout.png")
    # Splash icon: extra padding so the round splash mask never clips the soil.
    splash = compose(76, 2, background=False)
    for name, k in DENSITIES.items():
        splash.resize((int(108 * k),) * 2, Image.NEAREST).save(
            RES / f"drawable-{name}" / "splash_icon.png")
    adaptive = RES / "mipmap-anydpi-v26"
    adaptive.mkdir(exist_ok=True)
    (adaptive / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@mipmap/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />\n'
        '</adaptive-icon>\n', encoding="utf-8")
    STORE.mkdir(parents=True, exist_ok=True)
    up(compose(32, 1, rounded=False), 16).save(STORE / "play_icon_512.png")
    up(compose(24, 1), 16).save(STORE / "icon_preview.png")
    print("icons written to", RES)


if __name__ == "__main__":
    main()

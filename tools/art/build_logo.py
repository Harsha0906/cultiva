"""Builds Cultiva's launcher/splash/store icons from the capybara logo.

Source: docs/design/brand/logo_source.webp (user's design).
Run: python tools/art/build_logo.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
RES = ROOT / "app" / "android" / "app" / "src" / "main" / "res"
STORE = ROOT / "docs" / "design" / "store"
CREAM = (254, 244, 191, 255)
TEAL = (53, 96, 105, 255)

src = Image.open(ROOT / "docs/design/brand/logo_source.webp").convert("RGB")
# Mark = the dark teal shape (sprout + head); everything else is background.
alpha = src.convert("L").point(lambda v: 255 if v < 160 else 0)
box = alpha.getbbox()
mark = Image.new("RGBA", src.size, TEAL)
mark.putalpha(alpha)
mark = mark.crop(box)
white = Image.new("RGBA", mark.size, (255, 255, 255, 255))
white.putalpha(mark.getchannel("A"))


def fit(img, size, fill):
    """Centre img inside a size x size canvas at `fill` of its width/height."""
    s = fill * size / max(img.size)
    r = img.resize((round(img.width * s), round(img.height * s)), Image.LANCZOS)
    c = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    c.alpha_composite(r, ((size - r.width) // 2, (size - r.height) // 2))
    return c


def on_cream(img, size, fill, rounded=False):
    bg = Image.new("RGBA", (size, size), CREAM)
    bg.alpha_composite(fit(img, size, fill))
    if rounded:
        m = Image.new("L", (size, size), 0)
        from PIL import ImageDraw
        ImageDraw.Draw(m).rounded_rectangle([0, 0, size - 1, size - 1], size // 6, fill=255)
        bg.putalpha(m)
    return bg


DENS = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
for name, k in DENS.items():
    mip = RES / f"mipmap-{name}"
    on_cream(mark, int(48 * k), 0.72, rounded=True).save(mip / "ic_launcher.png")
    n = int(108 * k)
    fit(mark, n, 0.56).save(mip / "ic_launcher_foreground.png")  # inside 66dp safe zone
    Image.new("RGBA", (n, n), CREAM).save(mip / "ic_launcher_background.png")
    fit(white, n, 0.56).save(mip / "ic_launcher_monochrome.png")
    dr = RES / f"drawable-{name}"
    fit(white, int(24 * k), 0.9).save(dr / "ic_stat_sprout.png")
    fit(mark, n, 0.5).save(dr / "splash_icon.png")
STORE.mkdir(parents=True, exist_ok=True)
on_cream(mark, 512, 0.72).save(STORE / "play_icon_512.png")
on_cream(mark, 384, 0.72, rounded=True).save(STORE / "icon_preview.png")
print("logo icons written")

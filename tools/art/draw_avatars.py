"""8 animal avatars x 3 colour variants, 16x16 front portraits (never the capybara).

Run:  python tools/art/draw_avatars.py
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from draw_cultiva16 import H, R, Spr, blob, outline  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "app", "assets", "sprites", "cultiva", "avatars")
EYE = H("#1a0f08")
PINKN = H("#e58aa0")
WHITE_R = R("#5e5a63", "#a9a6b0", "#cfcdd6", "#e6e4ec", "#f4f2f8", "#ffffff")

# fur ramps (outline, dark, mid-dark, mid, light, highlight)
FUR = {
    "fox": [R("#4a1f12", "#8a3a18", "#b5551e", "#d8742a", "#ec9a4a", "#f7c07a"),
            R("#5a5560", "#a6a3ae", "#c9c7d0", "#e2e0e8", "#f2f0f6", "#ffffff"),
            R("#2c2b33", "#4f4e5a", "#6b6b78", "#8a8a98", "#a9a9b6", "#cfcfd8")],
    "rabbit": [R("#3e3a40", "#6a6670", "#8c8892", "#aaa6b0", "#c6c2cc", "#e2dee6"),
               WHITE_R,
               R("#3b2416", "#6a4428", "#8a5c38", "#a8784c", "#c49468", "#dcb48c")],
    "cat": [R("#4a2410", "#9a4a1a", "#c46a28", "#e08a3c", "#f0aa5c", "#f8cc8c"),
            R("#2e2e36", "#55555f", "#6f6f7a", "#8c8c98", "#aaaab4", "#c8c8d2"),
            R("#121018", "#22202a", "#33303d", "#45414f", "#5a5566", "#77718a")],
    "dog": [R("#4a3010", "#8a5a1e", "#b07a2c", "#d09a44", "#e6b866", "#f4d494"),
            R("#2e1a10", "#5a3420", "#77472b", "#93603a", "#ad7a50", "#c89870"),
            WHITE_R],
    "frog": [R("#1d3a18", "#2f5e24", "#3e7a2e", "#56963c", "#78b450", "#a4d070"),
             R("#123a3a", "#1d5a58", "#2a7774", "#3a948e", "#5cb2a8", "#8ed0c4"),
             R("#4a3a0e", "#8a6a12", "#b08a1c", "#d0aa2c", "#e6c64e", "#f4e08a")],
    "bear": [R("#2e1a10", "#5a3420", "#77472b", "#8f5c38", "#a8744c", "#c4946c"),
             R("#0e0c12", "#1e1b24", "#2c2934", "#3b3744", "#4e4a58", "#6a6578"),
             WHITE_R],
    "duck": [R("#5a4410", "#a8861a", "#d0a828", "#f0cc3c", "#f8e070", "#fff2b0"),
             WHITE_R,
             R("#3b2416", "#6a4a2c", "#8a6440", "#a88058", "#c49e76", "#dcbc98")],
    "owl": [R("#3b2416", "#6a4428", "#8e6236", "#b0824c", "#cca46c", "#e4c894"),
            R("#2e2e36", "#55555f", "#6f6f7a", "#8c8c98", "#aaaab4", "#c8c8d2"),
            WHITE_R],
}
ANIMALS = list(FUR.keys())
ORANGE = R("#5a2a10", "#a8501a", "#d06a1e", "#ee8a2a", "#f8aa50", "#ffd08a")


def eyes(s, y=8, x0=6, x1=10, tall=True):
    for x in (x0, x1):
        s.put(x, y, EYE)
        if tall:
            s.put(x, y + 1, EYE)


def head(s, fur, cx=8, cy=9.5, rx=5.6, ry=4.8):
    blob(s, cx, cy, rx, ry, fur, lo=2, hi=5)


def muzzle(s, ramp, cx=8, cy=11.3, rx=2.8, ry=1.9):
    blob(s, cx, cy, rx, ry, ramp, lo=3, hi=5)


def draw(animal, v):
    fur = FUR[animal][v]
    s = Spr(16, 16)
    if animal == "fox":
        for i in range(4):  # pointed ears
            s.rect(2 + i // 2, 2 + i, 6 - i // 3, 3 + i, fur[3], fur)
            s.rect(10 + i // 3, 2 + i, 14 - i // 2, 3 + i, fur[2], fur)
        s.put(4, 4, fur[1]), s.put(11, 4, fur[1])
        head(s, fur)
        muzzle(s, WHITE_R if v != 1 else R(*["#5a5560", "#c9c7d0", "#e2e0e8", "#f2f0f6", "#ffffff", "#ffffff"]))
        eyes(s)
        s.put(8, 11, EYE)
    elif animal == "rabbit":
        for x0 in (5, 9):
            s.rect(x0, 0, x0 + 2, 6, fur[3], fur)
            s.put(x0 + (1 if x0 == 5 else 0), 1, PINKN)
            s.put(x0 + (1 if x0 == 5 else 0), 2, PINKN)
            s.put(x0 + (1 if x0 == 5 else 0), 3, PINKN)
        head(s, fur, cy=10)
        muzzle(s, WHITE_R, cy=12, rx=2.4, ry=1.6)
        eyes(s, y=9)
        s.put(8, 11, PINKN)
    elif animal == "cat":
        for i in range(3):
            s.rect(3, 3 + i, 4 + i, 4 + i, fur[3], fur)
            s.rect(12 - i, 3 + i, 13, 4 + i, fur[2], fur)
        head(s, fur)
        if v == 0:
            for x in (6, 8, 10):
                s.put(x, 5, fur[1])  # tabby stripes
        eyes(s, tall=False)
        s.put(6, 9, H("#8ac04a")), s.put(10, 9, H("#8ac04a"))
        s.put(8, 11, PINKN)
        for x in (3, 13):
            s.put(x, 11, fur[5])
    elif animal == "dog":
        head(s, fur, cy=9)
        ear = FUR["dog"][1][2] if v != 1 else FUR["dog"][0][1]
        for x0 in (1, 13):
            s.rect(x0, 5, x0 + 2, 11, ear, fur)
        muzzle(s, WHITE_R if v != 2 else FUR["dog"][0], cy=11.5)
        if v == 2:
            for x, y in ((5, 6), (10, 7), (11, 5)):
                s.put(x, y, EYE)
        eyes(s)
        s.rect(7, 10, 10, 11, EYE)
        s.put(8, 13, PINKN)
    elif animal == "frog":
        for cx in (5, 11):
            blob(s, cx, 5, 2.4, 2.2, fur, lo=3, hi=5)
        head(s, fur, cy=10, rx=6.4, ry=4.2)
        for cx in (5, 11):
            s.put(cx, 5, H("#ffffff")), s.put(cx - 1, 5, EYE), s.put(cx - 1, 4, EYE)
        s.rect(4, 11, 13, 12, fur[1], fur)
        s.put(3, 10, fur[1]), s.put(13, 10, fur[1])
        s.put(5, 9, PINKN), s.put(11, 9, PINKN)
    elif animal == "bear":
        for cx in (4, 12):
            blob(s, cx, 4.5, 2.2, 2.0, fur, lo=2, hi=4)
        head(s, fur)
        muzzle(s, FUR["bear"][0] if v == 1 else (WHITE_R if v == 0 else FUR["bear"][2]), cy=11.5)
        if v == 0:
            muzzle(s, R("#3b2416", "#9c7450", "#b8906a", "#d0aa84", "#e4c6a2", "#f0dcc0"), cy=11.5)
        eyes(s)
        s.rect(7, 10, 10, 11, EYE)
    elif animal == "duck":
        head(s, fur, cy=8.5, rx=5.2, ry=5.2)
        s.put(8, 3, fur[3]), s.put(9, 2, fur[4]), s.put(7, 2, fur[3])  # tuft
        if v == 2:
            for x in range(4, 13):
                s.put(x, 5, H("#2f6a3a"))  # mallard green cap
                s.put(x, 6, H("#3e8a4a"))
        blob(s, 8, 11.5, 3.4, 1.6, ORANGE, lo=2, hi=5)  # bill
        s.rect(5, 11, 12, 12, ORANGE[3], ORANGE)
        s.put(7, 11, ORANGE[1]), s.put(9, 11, ORANGE[1])
        eyes(s, y=7)
    elif animal == "owl":
        s.rect(3, 2, 5, 5, fur[2], fur)  # ear tufts
        s.rect(11, 2, 13, 5, fur[2], fur)
        head(s, fur, cy=9.5, rx=6.0, ry=5.0)
        for cx in (5.5, 10.5):
            blob(s, cx, 8.5, 2.3, 2.3, WHITE_R if v != 2 else FUR["owl"][0], lo=3, hi=5)
        s.put(5, 8, EYE), s.put(5, 9, EYE), s.put(10, 8, EYE), s.put(10, 9, EYE)
        s.put(6, 8, H("#f0c040")), s.put(11, 8, H("#f0c040"))
        s.rect(7, 10, 9, 12, ORANGE[3], ORANGE)
        s.put(7, 12, ORANGE[1]), s.put(8, 12, ORANGE[2])
    outline(s)
    return s.image()


def main():
    os.makedirs(OUT, exist_ok=True)
    for a in ANIMALS:
        for v in range(3):
            draw(a, v).save(os.path.join(OUT, f"{a}_{v}.png"))
    # preview: 8 rows x 3 variants on paper squares
    cell = 20
    sheet = Image.new("RGBA", (3 * cell + 60, len(ANIMALS) * cell + 4), H("#f3e6c8"))
    d = ImageDraw.Draw(sheet)
    try:
        fnt = ImageFont.load_default(size=8)
    except TypeError:
        fnt = ImageFont.load_default()
    for r, a in enumerate(ANIMALS):
        d.text((2, r * cell + 7), a, fill=(59, 42, 30, 255), font=fnt)
        for v in range(3):
            sheet.alpha_composite(Image.open(os.path.join(OUT, f"{a}_{v}.png")), (60 + v * cell, 2 + r * cell))
    out = os.path.join(ROOT, "docs", "design", "art", "avatars.png")
    sheet.resize((sheet.width * 6, sheet.height * 6), Image.NEAREST).save(out)
    print("24 avatars written")


if __name__ == "__main__":
    main()

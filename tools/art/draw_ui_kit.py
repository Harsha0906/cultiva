"""Cultiva pixel UI kit: 9-slice panels/buttons and 16x16 tintable icons.

Run:  python tools/art/draw_ui_kit.py   ->  app/assets/ui/
"""
import math
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from draw_cultiva16 import CREAM, H, RED, TEAL, WOOD, Spr  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "app", "assets", "ui")
PAPER = [H("#46332a"), H("#9c6b3f"), H("#c9b58e"), H("#e8d9b5"), H("#f3e6c8"), H("#f8eed6")]
WHITE = (255, 255, 255, 255)


def panel(fill_ramp, outline_col, stitch_col, plank=False):
    s = Spr(24, 24)
    for y in range(24):
        for x in range(24):
            corner = (x in (0, 23) and y in (0, 23))
            if corner:
                continue
            edge = min(x, y, 23 - x, 23 - y)
            if edge == 0:
                c = outline_col
            elif edge == 1:
                c = fill_ramp[2] if (y > 1 and x > 1) else fill_ramp[4]
                if y == 22 or x == 22:
                    c = fill_ramp[1]
            else:
                # Flutter stretches the 9-slice middle, so keep it pattern-free:
                # a solid inset line reads as a stitch at any size.
                c = fill_ramp[4]
                if edge == 3 and not plank:
                    c = stitch_col
                if plank and edge == 2:
                    c = fill_ramp[5]
            s.put(x, y, c)
    return s.image()


def button(face, pressed=False):
    """face ramp: [outline, lip, ..., face, highlight]. 3px lip at rest, 1px when pressed."""
    s = Spr(24, 24)
    lip = 1 if pressed else 3
    top = 2 if pressed else 0
    bottom = 23
    face_bottom = bottom - lip
    for y in range(top, bottom + 1):
        for x in range(24):
            if (x in (0, 23)) and (y in (top, bottom)):
                continue
            if x in (0, 23) or y in (top, bottom):
                c = face[0]
            elif y > face_bottom:
                c = face[1]
            elif y == top + 1:
                c = face[5]
            elif x == 1:
                c = face[4]
            elif x == 22 or y == face_bottom:
                c = face[2]
            else:
                c = face[3]
            s.put(x, y, c)
    return s.image()


# ---------------------------------------------------------------- icons (white silhouettes)
def icon(draw):
    s = Spr(16, 16)
    draw(lambda x, y: s.put(x, y, WHITE), lambda x0, y0, x1, y1: s.rect(x0, y0, x1, y1, WHITE))
    return s.image()


FARM_MAP = [
    "................",
    "..........####..",
    ".........######.",
    "..##....#######.",
    ".####...######..",
    ".#####..#####...",
    "..#####.###.....",
    "...#####.#......",
    ".....####.......",
    ".......##.......",
    ".......##.......",
    ".......##.......",
    "....########....",
    "..############..",
    ".##############.",
    "................",
]


def ic_farm(p, r):
    for y, row in enumerate(FARM_MAP):
        for x, ch in enumerate(row):
            if ch == "#":
                p(x, y)


def ic_tasks(p, r):
    for y in (2, 7, 12):
        r(1, y, 5, y + 3)
        r(7, y + 1, 15, y + 2)
    for y in (2, 7):  # ticks inside first two boxes (cut out)
        pass


def ic_shop(p, r):
    r(1, 2, 15, 6)  # awning
    for x in range(1, 15, 3):
        p(x + 1, 6)
    r(2, 7, 4, 14)
    r(12, 7, 14, 14)
    r(5, 10, 11, 12)  # counter
    r(1, 14, 15, 15)


def ic_progress(p, r):
    r(2, 10, 5, 14)
    r(6, 7, 9, 14)
    r(10, 3, 13, 14)
    r(1, 14, 15, 15)


def ic_calendar(p, r):
    r(1, 3, 15, 15)
    r(4, 1, 6, 4)
    r(10, 1, 12, 4)
    for y in (7, 10):
        for x in (3, 6, 9, 12):
            pass


def ic_plus(p, r):
    r(6, 2, 10, 14)
    r(2, 6, 14, 10)


def ic_play(p, r):
    for y in range(2, 14):
        w = 6 - abs(y - 7.5)
        r(4, y, 4 + int(w * 1.6) + 2, y + 1)


def ic_check(p, r):
    pts = [(2, 8), (3, 9), (4, 10), (5, 11), (6, 12), (7, 11), (8, 10), (9, 9), (10, 8), (11, 7), (12, 6), (13, 5), (14, 4)]
    for x, y in pts:
        r(x, y - 1, x + 1, y + 2)


def ic_timer(p, r):
    for y in range(16):
        for x in range(16):
            d = math.hypot(x + 0.5 - 8, y + 0.5 - 9)
            if 4.6 <= d <= 6.6:
                p(x, y)
    r(6, 1, 10, 2)
    r(7, 2, 9, 4)
    r(7, 6, 9, 10)
    r(8, 9, 11, 11)


def ic_gear(p, r):
    for y in range(16):
        for x in range(16):
            d = math.hypot(x + 0.5 - 8, y + 0.5 - 8)
            a = math.atan2(y + 0.5 - 8, x + 0.5 - 8)
            tooth = math.cos(a * 8) > 0.2
            if (2.2 <= d <= 5.0) or (5.0 < d <= 7.4 and tooth):
                p(x, y)


def ic_lock(p, r):
    r(3, 7, 13, 15)
    r(4, 2, 6, 7)
    r(10, 2, 12, 7)
    r(5, 1, 11, 3)


def ic_close(p, r):
    for i in range(12):
        r(2 + i, 2 + i, 4 + i, 3 + i)
        r(12 - i, 2 + i, 14 - i, 3 + i)


def ic_back(p, r):
    r(4, 7, 14, 9)
    for i in range(5):
        r(2 + i, 8 - i - 1, 4 + i, 8 - i + 1)
        r(2 + i, 8 + i - 1, 4 + i, 8 + i + 1)


ICONS = {
    "farm": ic_farm, "tasks": ic_tasks, "shop": ic_shop, "progress": ic_progress, "calendar": ic_calendar,
    "plus": ic_plus, "play": ic_play, "check": ic_check, "timer": ic_timer, "gear": ic_gear,
    "lock": ic_lock, "close": ic_close, "back": ic_back,
}


def cutouts(name, im):
    """Knock out interior details (e.g. calendar grid, task ticks) so silhouettes read."""
    px = im.load()
    clear = (0, 0, 0, 0)
    if name == "calendar":
        for x in range(2, 14):
            for y in range(6, 14):
                px[x, y] = clear
        for y in (7, 10):
            for x in (3, 6, 9, 12):
                px[x, y] = WHITE
                px[x, y + 1] = WHITE
        for x in range(2, 14):
            px[x, 14] = WHITE
    if name == "tasks":
        for y in (2, 7):
            px[2, y + 1] = clear
            px[3, y + 2] = clear
            px[4, y + 1] = clear
        for (x, y) in ((2, 13), (3, 13)):
            px[x, y] = clear
    return im


def main():
    os.makedirs(os.path.join(OUT, "icons"), exist_ok=True)
    panel(PAPER, PAPER[0], PAPER[1]).save(os.path.join(OUT, "panel_paper.png"))
    panel(WOOD, WOOD[0], WOOD[4], plank=True).save(os.path.join(OUT, "panel_wood.png"))
    faces = {
        # Faces darkened in step 10.3 so white labels reach WCAG 4.5:1.
        "primary": [H("#4a1d14"), H("#7a3019"), H("#9c4426"), H("#b5502e"), H("#d0673f"), H("#e58a62")],
        "teal": [TEAL[0], H("#173f43"), H("#1f5759"), TEAL[2], TEAL[3], TEAL[4]],
        "wood": [WOOD[0], H("#5a3527"), WOOD[2], WOOD[3], WOOD[4], WOOD[5]],
        "paper": [PAPER[0], H("#a8946c"), PAPER[2], PAPER[4], PAPER[5], H("#fffaf0")],
    }
    for name, face in faces.items():
        button(face).save(os.path.join(OUT, f"btn_{name}.png"))
        button(face, pressed=True).save(os.path.join(OUT, f"btn_{name}_pressed.png"))
    for name, fn in ICONS.items():
        cutouts(name, icon(fn)).save(os.path.join(OUT, "icons", name + ".png"))
    preview(faces)
    print("ui kit written to", OUT)


def preview(faces):
    sheet = Image.new("RGBA", (16 * 13 + 4 * 14, 16 + 8 + 24 * 2 + 16), H("#6b4426"))
    for i, n in enumerate(ICONS):
        sheet.alpha_composite(Image.open(os.path.join(OUT, "icons", n + ".png")), (4 + i * 20, 4))
    for i, n in enumerate(faces):
        sheet.alpha_composite(Image.open(os.path.join(OUT, f"btn_{n}.png")), (4 + i * 28, 28))
        sheet.alpha_composite(Image.open(os.path.join(OUT, f"btn_{n}_pressed.png")), (4 + i * 28, 56))
    sheet.alpha_composite(Image.open(os.path.join(OUT, "panel_paper.png")), (130, 28))
    sheet.alpha_composite(Image.open(os.path.join(OUT, "panel_wood.png")), (160, 28))
    out = os.path.join(ROOT, "docs", "design", "art")
    sheet.resize((sheet.width * 4, sheet.height * 4), Image.NEAREST).save(os.path.join(out, "ui-kit-preview.png"))


if __name__ == "__main__":
    main()

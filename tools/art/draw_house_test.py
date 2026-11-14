"""Cultiva house test: 96x104 teal-roof cottage drawn procedurally.

Run:  python tools/art/draw_house_test.py [reference.webp]
"""
import os
import random
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from draw_art_test import (  # noqa: E402
    GRASS, H, LEAF, ROOT, SEED, STONE, WOOD, Spr, blob, font, outline, ramp, shadow,
    soil_patch, stage_ripe, stage_young, stage_sprout, tile_cobble, tile_fill, tile_grass, tile_soil,
)

ROOF = ramp("#14303a", "#1b4650", "#215f63", "#2a7c79", "#3a9890", "#5bb5a5", "#94d6c2")
TERRA = ramp("#4a1f16", "#7a3420", "#a8482a", "#d0673f", "#e58a62", "#f3b48f")
WALL = ramp("#5e4a3a", "#8c7559", "#b8a07d", "#d9c49e", "#ecdcb8", "#f9eed3")
GLASS = ramp("#22394d", "#3f6a85", "#6b9fb8", "#9cc9da", "#e3f4f8")
GOLD = ramp("#7a4a12", "#b87a1e", "#e8b13a", "#ffd86a", "#fff3b8")
IRON = ramp("#262433", "#3b3a4f")
PINK, YELLOW, WHITE = H("#f29bb5"), H("#f6e27a"), H("#fbf6ea")

CAPY_SIGN = [
    "......##..",
    ".########.",
    ".#########",
    "..#.#..#.#",
]


def rect(s, x0, y0, x1, y1, col, rm):
    for y in range(y0, y1):
        for x in range(x0, x1):
            s.put(x, y, col, rm)


def house():
    random.seed(42)
    s = Spr(96, 104)
    shadow(s, 48, 99, 47, 4.5)

    # --- back roof slope (narrow, between the hip ends)
    for y in range(9, 16):
        for x in range(16 - (y - 9), 80 + (y - 9)):
            idx = 3 if y == 9 else (1 if (y - 9) % 3 == 0 else 2)
            s.put(x, y, ROOF[idx], ROOF)

    # --- chimney (sits on back slope)
    for y in range(3, 16):
        row = (y - 3) // 3
        off = (row % 2) * 3
        for x in range(68, 80):
            mortar = (y - 3) % 3 == 2 or (x - 68 + off) % 6 == 5
            idx = 1 if mortar else (4 if x < 70 else 3 if x < 77 else 2)
            if not mortar and random.random() < 0.1:
                idx += random.choice((-1, 1))
            s.put(x, y, TERRA[idx], TERRA)
    for x in range(66, 82):
        s.put(x, 0, STONE[4], STONE)
        s.put(x, 1, STONE[3], STONE)
        s.put(x, 2, STONE[1], STONE)

    # --- hip roof: front slope (trapezoid) + lit left facet + shaded right facet
    def xl(y):
        return round(18 - (y - 16) * 18 / 40)

    def xr(y):
        return 95 - xl(y)

    tone = {}
    for y in range(16, 56):
        r = (y - 16) % 5
        row = (y - 16) // 5
        off = (row % 2) * 3
        grad = 1 if y < 26 else (-1 if y > 46 else 0)
        for x in range(0, 96):
            key = (row, (x + off) // 6)
            if key not in tone:
                tone[key] = random.choice((0, 0, 0, 1, -1))
            sx = (x + off) % 6
            # rounded scalloped shingle
            if r == 4:
                idx = 2 if sx in (2, 3) else 1
            elif r == 3 and sx in (0, 5):
                idx = 2
            elif r == 0:
                idx = 4
            else:
                idx = 3 + tone[key]
            idx += grad
            if x < xl(y):
                idx += 1          # left facet faces the light
            elif x > xr(y):
                idx -= 2          # right facet in shade
            if x == xl(y):
                idx = 5
            elif x == xr(y):
                idx = 1
            s.put(x, y, ROOF[max(0, min(6, idx))], ROOF)
    # ridge
    for x in range(18, 78):
        s.put(x, 15, ROOF[6] if x % 8 == 0 else ROOF[5], ROOF)
        s.put(x, 16, ROOF[4], ROOF)
        s.put(x, 17, ROOF[1], ROOF)
    # trim the top corners outside the hips so the silhouette slopes
    for y in range(16, 56):
        for x in range(0, 96):
            if x < xl(y) - 9 or x > xr(y) + 9:
                s.c[y][x] = None
                s.r[y][x] = None
    for x in range(0, 96):
        s.put(x, 56, WOOD[4], WOOD)
        s.put(x, 57, WOOD[3], WOOD)
        s.put(x, 58, WOOD[1], WOOD)

    # --- dormer
    for x in range(37, 60):
        s.put(x, 47, ROOF[0], ROOF)  # shadow cast on roof
    for y in range(31, 47):
        for x in range(39, 58):
            idx = 4 if x < 41 else 3
            if y < 33:
                idx = 1 if y == 31 else 2
            if x == 57:
                idx = 2
            s.put(x, y, WALL[idx], WALL)
    for y in range(20, 32):
        half = int((y - 20) * 1.05) + 1
        for x in range(48 - half - 1, 48 + half + 2):
            edge = x <= 48 - half or x >= 48 + half
            if edge:
                col = WOOD[4] if x < 48 else WOOD[2]
            else:
                col = ROOF[5] if x < 48 else ROOF[2]
                if (y - 20) % 3 == 2:
                    col = ROOF[3] if x < 48 else ROOF[1]
                if x == 48:
                    col = ROOF[6]
            s.put(x, y, col, ROOF)
    # round window
    for y in range(33, 45):
        for x in range(42, 55):
            d = (x + 0.5 - 48.5) ** 2 + (y + 0.5 - 39) ** 2
            if d <= 30:
                if d > 18:
                    s.put(x, y, WOOD[2] if (x > 48 or y > 39) else WOOD[4], WOOD)
                else:
                    g = GLASS[3] if y < 38 else GLASS[2]
                    if x == 48 or y == 39:
                        g = WOOD[3]
                    s.put(x, y, g, GLASS)
    s.put(45, 36, GLASS[4], GLASS)
    s.put(46, 35, GLASS[4], GLASS)

    # --- walls
    for y in range(59, 96):
        for x in range(6, 90):
            idx = 3
            if x < 9:
                idx = 4
            if random.random() < 0.08:
                idx += random.choice((-1, 1))
            if y in (59, 60):
                idx = 1
            elif y == 61:
                idx = 2
            s.put(x, y, WALL[idx], WALL)
    # timber posts
    for x0 in (6, 36, 58, 88):
        for y in range(61, 92):
            s.put(x0, y, WOOD[4], WOOD)
            s.put(x0 + 1, y, WOOD[3], WOOD)
            s.put(x0 + 2, y, WOOD[1], WOOD)
    for x in range(6, 90):
        s.put(x, 61, WOOD[3], WOOD)
        s.put(x, 62, WOOD[2], WOOD)
        s.put(x, 88, WOOD[4], WOOD)
        s.put(x, 89, WOOD[2], WOOD)

    # windows with shutters and flower boxes
    def window(x0):
        y0 = 66
        rect(s, x0, y0, x0 + 16, y0 + 14, WOOD[2], WOOD)
        for y in range(y0 + 1, y0 + 13):
            for x in range(x0 + 1, x0 + 15):
                g = GLASS[3] if y < y0 + 5 else GLASS[2] if y < y0 + 10 else GLASS[1]
                s.put(x, y, g, GLASS)
        for y in range(y0 + 1, y0 + 13):
            s.put(x0 + 8, y, WOOD[3], WOOD)
        for x in range(x0 + 1, x0 + 15):
            s.put(x, y0 + 7, WOOD[3], WOOD)
        for k in range(3):
            s.put(x0 + 3 + k, y0 + 5 - k, GLASS[4], GLASS)
            s.put(x0 + 11 + k, y0 + 5 - k, GLASS[4], GLASS)
        # warm interior glow in lower panes
        s.put(x0 + 4, y0 + 11, GOLD[2], GOLD)
        s.put(x0 + 12, y0 + 11, GOLD[2], GOLD)
        for sx in (x0 - 4, x0 + 16):
            for y in range(y0, y0 + 14):
                for x in range(sx, sx + 4):
                    idx = 3
                    if x == sx:
                        idx = 4
                    if x == sx + 3:
                        idx = 2
                    if y in (y0 + 3, y0 + 10):
                        idx = 1
                    s.put(x, y, TERRA[idx], TERRA)
        # flower box
        for x in range(x0 - 2, x0 + 18):
            s.put(x, y0 + 15, WOOD[4], WOOD)
            s.put(x, y0 + 16, WOOD[3], WOOD)
            s.put(x, y0 + 17, WOOD[1], WOOD)
        for i, x in enumerate(range(x0 - 1, x0 + 17)):
            s.put(x, y0 + 14, LEAF[3] if i % 2 else LEAF[4], LEAF)
            if i % 3 == 0:
                s.put(x, y0 + 13, LEAF[4], LEAF)
            if i % 4 == 1:
                s.put(x, y0 + 13, (PINK, YELLOW, WHITE)[(i // 4) % 3], LEAF)
                s.put(x + 1, y0 + 12, (PINK, YELLOW, WHITE)[(i // 4) % 3], LEAF)

    window(14)
    window(66)

    # door (arched planks)
    for y in range(66, 92):
        inset = {66: 4, 67: 2, 68: 1}.get(y, 0)
        for x in range(40 + inset, 56 - inset):
            if x == 40 + inset or x == 55 - inset or y == 66 + (1 if inset else 0) and inset:
                s.put(x, y, WOOD[1], WOOD)
                continue
            idx = 3 if (x - 40) % 4 else 1
            if x < 44 and idx == 3:
                idx = 4
            if y in (72, 84):
                idx = 2
            if y > 89:
                idx = 2
            s.put(x, y, WOOD[idx], WOOD)
    for y in (72, 84):
        s.put(41, y, IRON[0], IRON)
        s.put(42, y, IRON[1], IRON)
        s.put(43, y, IRON[1], IRON)
    s.put(52, 79, GOLD[3], GOLD)
    s.put(52, 80, GOLD[1], GOLD)
    # capybara sign
    rect(s, 41, 63, 55, 66, WOOD[4], WOOD)
    for y in range(62, 68):
        s.put(40, y, WOOD[1], WOOD)
        s.put(55, y, WOOD[1], WOOD)
    for x in range(40, 56):
        s.put(x, 62, WOOD[2], WOOD)
        s.put(x, 68, WOOD[1], WOOD)
    rect(s, 41, 63, 55, 68, WOOD[4], WOOD)
    for j, row in enumerate(CAPY_SIGN):
        for i, ch in enumerate(row):
            if ch == "#":
                s.put(43 + i, 63 + j, WOOD[1], WOOD)
    # lantern
    s.put(61, 69, IRON[0], IRON)
    s.put(62, 69, IRON[0], IRON)
    for y in range(70, 77):
        for x in range(61, 66):
            edge = x in (61, 65) or y in (70, 76)
            s.put(x, y, IRON[1] if edge else (GOLD[4] if y in (72, 73) and x == 63 else GOLD[3] if y < 74 else GOLD[2]), GOLD)

    # foundation stones
    for y in range(90, 97):
        r = (y - 90) // 3
        off = (r % 2) * 4
        for x in range(5, 91):
            mortar = (y - 90) % 3 == 2 or (x + off) % 8 == 0
            idx = 1 if mortar else (4 if (y - 90) % 3 == 0 else 3)
            if not mortar and (x + off) % 8 == 7:
                idx = 2
            s.put(x, y, STONE[idx], STONE)
    # doorstep
    for y in range(92, 100):
        for x in range(37, 59):
            idx = 4 if y == 92 else 3 if y < 96 else 2 if y < 99 else 1
            if x in (37, 58):
                idx = 2
            s.put(x, y, STONE[idx], STONE)

    # ivy on left corner + potted plant
    # ivy: a winding vine with small leaves on alternating sides
    vine = [(8 + round(1.5 * __import__("math").sin(y / 3.5)), y) for y in range(95, 57, -1)]
    for i, (x, y) in enumerate(vine):
        s.put(x, y, LEAF[1], LEAF)
        if i % 3 == 0:
            side = 1 if (i // 3) % 2 else -1
            s.put(x + side, y, LEAF[4], LEAF)
            s.put(x + 2 * side, y, LEAF[5] if side < 0 else LEAF[3], LEAF)
            s.put(x + side, y - 1, LEAF[3], LEAF)
    blob(s, 7, 58, 3, 2, LEAF, lo=2, hi=5, noise=0.1)
    blob(s, 11, 92, 2.6, 2, LEAF, lo=2, hi=5, noise=0.1)
    for y in range(92, 99):
        for x in range(64, 71):
            idx = 4 if x == 64 else 3 if x < 69 else 2
            if y == 92:
                idx = 4
            s.put(x, y, TERRA[idx], TERRA)
    blob(s, 67.5, 89, 4, 3, LEAF, lo=2, hi=5, noise=0.1)
    s.put(66, 87, PINK, LEAF)
    s.put(69, 89, PINK, LEAF)

    outline(s)
    return s


def main(ref_path=None):
    bdir = os.path.join(ROOT, "assets", "sprites", "buildings")
    out = os.path.join(ROOT, "docs", "design", "art-test")
    os.makedirs(bdir, exist_ok=True)
    os.makedirs(out, exist_ok=True)

    h = house().image()
    h.save(os.path.join(bdir, "house_cottage.png"))
    close = Image.new("RGBA", (112, 120), H("#5a9e4b"))
    close.alpha_composite(h, (8, 8))
    close.resize((112 * 6, 120 * 6), Image.NEAREST).save(os.path.join(out, "house-6x.png"))

    grass, cobble, soil = tile_grass(), tile_cobble(), tile_soil()
    W, Hh = 256, 192
    scene = Image.new("RGBA", (W, Hh))
    tile_fill(scene, grass, 0, 0, W, Hh)
    tile_fill(scene, cobble, 112, 100, 144, Hh)
    soil_patch(scene, soil, 10, 118, 96, 182)
    scene.alpha_composite(h, (80, 4))
    young, ripe, sprout = stage_young().image(), stage_ripe().image(), stage_sprout().image()
    for i, f in enumerate((ripe, young, ripe)):
        scene.alpha_composite(f, (14 + i * 26, 150 - 40))
    for i, f in enumerate((sprout, ripe, young)):
        scene.alpha_composite(f, (14 + i * 26, 178 - 40))
    s4 = scene.resize((W * 4, Hh * 4), Image.NEAREST)
    s4.save(os.path.join(out, "house-scene-4x.png"))

    if ref_path and os.path.exists(ref_path):
        ref = Image.open(ref_path).convert("RGBA")
        rw, rh = ref.size
        crop = ref.crop((int(rw * 0.70), int(rh * 0.14), int(rw * 0.96), int(rh * 0.60)))
        crop = crop.resize((round(crop.width * s4.height / crop.height), s4.height), Image.LANCZOS)
        top = 56
        comp = Image.new("RGBA", (s4.width + crop.width + 24, s4.height + top), H("#f3e6c8"))
        comp.alpha_composite(s4, (0, top))
        comp.alpha_composite(crop, (s4.width + 24, top))
        d = ImageDraw.Draw(comp)
        d.text((8, 12), "Cultiva cottage (drawn in code) - 4x", fill=H("#3b2a1e"), font=font(28))
        d.text((s4.width + 32, 12), "Reference house (mood only)", fill=H("#3b2a1e"), font=font(28))
        comp.save(os.path.join(out, "house-comparison.png"))
    print("done")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else None)

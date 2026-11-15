"""Cultiva custom sprites at 16px density, styled to match the CraftPix packs.

Run:  python tools/art/draw_cultiva16.py
Writes app/assets/sprites/cultiva/ and docs/design/art/cultiva-sprites.png (preview).
"""
import math
import os
import random

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "app", "assets", "sprites", "cultiva")
PACK_OUT = os.path.join(ROOT, "app", "assets", "sprites", "pack")


def H(h):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


def R(*hs):
    return [H(h) for h in hs]


# ramps: [outline, dark, mid-dark, mid, light, highlight]
TEAL = R("#173036", "#22545a", "#2a6f70", "#358a85", "#4aa59a", "#76c2b0")
RED = R("#482a2a", "#6d1924", "#8a2a2a", "#9e3931", "#bf5a3f", "#d97e5a")
CREAM = R("#46332a", "#917d72", "#c1ab93", "#e2d5b9", "#e7dcc4", "#f4eedd")
SLATE = R("#2c2a33", "#443f4c", "#565a65", "#646e79", "#7d8a97", "#92a9b6")
STONE = R("#443734", "#565a65", "#646e79", "#7d8a97", "#92a9b6", "#b9c8d0")
WOOD = R("#46332a", "#6d423a", "#94614a", "#a8775a", "#b4997d", "#cfb595")
GLASS = R("#2b2f5c", "#3d4a8c", "#5266b8", "#6f86d6", "#a9b8f0", "#e4ebff")
GREEN = R("#1d442d", "#275f3e", "#3a7b40", "#568c4d", "#7aad55", "#96c55f")
SOIL = R("#3d2420", "#5a3328", "#73432f", "#8c5638", "#a56c45", "#bd8656")
WATER = R("#1f3550", "#2b5683", "#3a74aa", "#4f93c8", "#7fbde3", "#d4f0fb")
SAND = R("#5e4a33", "#8a7354", "#b09a72", "#c9b48a", "#ddcba3", "#efe2c2")
CAPY = R("#3b2416", "#5e3b22", "#7e5332", "#9c6b42", "#b98a5c", "#d2a97c")
GOLD = R("#5a3a0e", "#9a6512", "#d19a26", "#f2c14e", "#ffe08a", "#fff6d0")
PINK, YELLOW, WHITE = H("#f29bb5"), H("#f6e27a"), H("#fbf6ea")
SHADOW = (40, 20, 30, 70)


class Spr:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.c = [[None] * w for _ in range(h)]
        self.r = [[None] * w for _ in range(h)]

    def put(self, x, y, col, rm=None):
        x, y = int(math.floor(x)), int(math.floor(y))
        if 0 <= x < self.w and 0 <= y < self.h:
            self.c[y][x] = col
            self.r[y][x] = rm

    def rect(self, x0, y0, x1, y1, col, rm=None):
        for y in range(y0, y1):
            for x in range(x0, x1):
                self.put(x, y, col, rm)

    def solid(self, x, y):
        return 0 <= x < self.w and 0 <= y < self.h and self.r[y][x] is not None

    def image(self):
        im = Image.new("RGBA", (self.w, self.h))
        for y in range(self.h):
            for x in range(self.w):
                if self.c[y][x]:
                    im.putpixel((x, y), self.c[y][x])
        return im


def blob(s, cx, cy, rx, ry, rm, lo=1, hi=None, noise=0.0):
    hi = len(rm) - 1 if hi is None else hi
    L = (-0.55, -0.65, 0.52)
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            nx, ny = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            d = nx * nx + ny * ny
            if d > 1:
                continue
            nz = math.sqrt(max(0, 1 - d))
            i = (nx * L[0] + ny * L[1] + nz * L[2]) / 1.0
            t = min(1, max(0, (i + 0.15) / 1.1))
            idx = lo + round(t * (hi - lo))
            if noise and random.random() < noise:
                idx += random.choice((-1, 1))
            s.put(x, y, rm[max(1, min(len(rm) - 1, idx))], rm)


def outline(s, col=None):
    """Uniform warm outline around every solid shape (pack style)."""
    adds = []
    for y in range(s.h):
        for x in range(s.w):
            if s.solid(x, y):
                continue
            for dx, dy in ((0, 1), (1, 0), (0, -1), (-1, 0)):
                if s.solid(x + dx, y + dy):
                    rm = s.r[y + dy][x + dx]
                    adds.append((x, y, col or rm[0]))
                    break
    for x, y, c in adds:
        s.put(x, y, c, None)


def shadow(s, cx, cy, rx, ry):
    for y in range(int(cy - ry), int(cy + ry) + 1):
        for x in range(int(cx - rx), int(cx + rx) + 1):
            if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1 and not s.solid(x, y):
                s.c[y][x] = SHADOW


# ---------------------------------------------------------------- cottage 80x80
def cottage():
    random.seed(7)
    s = Spr(80, 80)
    # chimney (behind roof)
    for y in range(1, 16):
        for x in range(55, 63):
            mortar = (y % 3 == 0) or ((x + (y // 3) % 2 * 2) % 4 == 0)
            s.put(x, y, RED[1] if mortar else (RED[4] if x < 57 else RED[3]), RED)
    s.rect(54, 0, 64, 2, STONE[4], STONE)
    # hip roof: ridge x18..62 at y6, eaves x2..78 at y44
    def xl(y):
        return round(18 - (y - 6) * 16 / 38)

    def xr(y):
        return 79 - xl(y)

    for y in range(6, 45):
        row = (y - 6) // 4
        r = (y - 6) % 4
        off = (row % 2) * 2
        for x in range(xl(y), xr(y) + 1):
            sx = (x + off) % 4
            if r == 3:
                idx = 1 if sx in (0, 3) else 2
            elif r == 0:
                idx = 4
            else:
                idx = 3
            if x < xl(y) + (44 - y) // 3 + 3:
                idx += 1  # lit left hip
            elif x > xr(y) - (44 - y) // 3 - 3:
                idx -= 1  # shaded right hip
            if y > 38:
                idx -= 1
            s.put(x, y, TEAL[max(1, min(5, idx))], TEAL)
    for x in range(18, 62):
        s.put(x, 6, TEAL[5], TEAL)
    # fascia
    s.rect(2, 44, 78, 45, WOOD[4], WOOD)
    s.rect(2, 45, 78, 46, WOOD[2], WOOD)
    # dormer
    s.rect(33, 23, 47, 37, CREAM[3], CREAM)
    s.rect(33, 23, 35, 37, CREAM[4], CREAM)
    s.rect(45, 23, 47, 37, CREAM[2], CREAM)
    s.rect(32, 37, 48, 38, TEAL[1], TEAL)
    for y in range(13, 24):
        half = (y - 13) * 0.85 + 1
        for x in range(round(40 - half) - 1, round(40 + half) + 1):
            col = TEAL[5] if x < 40 else TEAL[2]
            if x in (round(40 - half) - 1, round(40 + half)):
                col = WOOD[3]
            s.put(x, y, col, TEAL)
    for y in range(26, 35):
        for x in range(36, 45):
            d = (x + 0.5 - 40.5) ** 2 + (y + 0.5 - 30.5) ** 2
            if d <= 17:
                if d > 9:
                    s.put(x, y, WOOD[2], WOOD)
                else:
                    s.put(x, y, WOOD[3] if (x == 40 or y == 30) else (GLASS[4] if y < 30 else GLASS[3]), GLASS)
    # walls
    for y in range(46, 72):
        for x in range(6, 74):
            idx = 4 if x < 9 else 3
            if y < 48:
                idx = 1
            elif y == 48:
                idx = 2
            if random.random() < 0.05:
                idx -= 1
            s.put(x, y, CREAM[idx], CREAM)
    for x0 in (6, 28, 50, 72):
        s.rect(x0, 48, x0 + 1, 70, WOOD[3], WOOD)
        s.rect(x0 + 1, 48, x0 + 2, 70, WOOD[1], WOOD)
    s.rect(6, 48, 74, 49, WOOD[2], WOOD)
    s.rect(6, 68, 74, 69, WOOD[3], WOOD)
    s.rect(6, 69, 74, 70, WOOD[1], WOOD)

    def window(x0):
        s.rect(x0, 52, x0 + 12, 62, WOOD[2], WOOD)
        s.rect(x0 + 1, 53, x0 + 11, 61, GLASS[3], GLASS)
        s.rect(x0 + 1, 53, x0 + 11, 56, GLASS[4], GLASS)
        s.rect(x0 + 6, 53, x0 + 7, 61, WOOD[3], WOOD)
        s.rect(x0 + 1, 57, x0 + 11, 58, WOOD[3], WOOD)
        s.put(x0 + 2, 54, GLASS[5], GLASS)
        s.put(x0 + 8, 54, GLASS[5], GLASS)
        s.rect(x0 - 3, 52, x0, 62, RED[4], RED)  # terracotta shutters
        s.rect(x0 - 3, 56, x0, 57, RED[2], RED)
        s.rect(x0 + 12, 52, x0 + 15, 62, RED[3], RED)
        s.rect(x0 + 12, 56, x0 + 15, 57, RED[2], RED)
        s.rect(x0 - 1, 62, x0 + 13, 63, WOOD[4], WOOD)
        s.rect(x0 - 1, 63, x0 + 13, 65, WOOD[2], WOOD)
        for i in range(0, 13, 2):
            s.put(x0 + i, 61, GREEN[4], GREEN)
            s.put(x0 + i, 60, (PINK, YELLOW, WHITE)[i // 2 % 3], GREEN)

    window(12)
    window(56)
    # door + capybara sign
    for y in range(52, 70):
        inset = {52: 3, 53: 1}.get(y, 0)
        for x in range(34 + inset, 46 - inset):
            idx = 3 if (x - 34) % 3 else 1
            if x < 37 and idx == 3:
                idx = 4
            s.put(x, y, WOOD[idx], WOOD)
    s.put(43, 62, GOLD[3], GOLD)
    s.rect(35, 49, 45, 52, WOOD[4], WOOD)
    for x, y in ((36, 50), (37, 50), (38, 50), (39, 50), (40, 50), (41, 49), (42, 49), (42, 50), (43, 50), (37, 51), (42, 51)):
        s.put(x, y, WOOD[0], WOOD)
    # foundation + step
    for y in range(70, 75):
        for x in range(5, 75):
            mortar = (y == 72) or ((x + (y > 72) * 3) % 6 == 0)
            s.put(x, y, STONE[1] if mortar else (STONE[4] if y < 72 else STONE[3]), STONE)
    s.rect(32, 72, 48, 75, STONE[4], STONE)
    s.rect(32, 75, 48, 76, STONE[2], STONE)
    outline(s)
    shadow(s, 40, 76, 38, 3)
    return s.image()


# ---------------------------------------------------------------- barn 72x72
def barn():
    random.seed(8)
    s = Spr(72, 72)
    # gambrel roof
    for y in range(4, 34):
        if y < 14:
            half = 14 + (y - 4) * 1.6
        else:
            half = 30 + (y - 14) * 0.25
        x0, x1 = round(36 - half), round(36 + half)
        for x in range(x0, x1):
            idx = 3 if (y - 4) % 3 else 1
            if x < x0 + 6:
                idx += 1
            elif x > x1 - 6:
                idx -= 1
            if y == 14:
                idx = 1
            s.put(x, y, SLATE[max(1, min(5, idx))], SLATE)
    s.rect(2, 33, 70, 35, CREAM[4], CREAM)
    # walls
    for y in range(35, 66):
        for x in range(6, 66):
            if (x - 6) % 4 == 0:
                idx = 1
            elif x < 9:
                idx = 4
            else:
                idx = 3 if (x - 6) % 4 != 3 else 2
            if y < 37:
                idx = 1
            s.put(x, y, RED[idx], RED)
    s.rect(6, 35, 8, 66, CREAM[4], CREAM)
    s.rect(64, 35, 66, 66, CREAM[2], CREAM)
    # hayloft
    s.rect(29, 37, 43, 45, CREAM[4], CREAM)
    s.rect(31, 38, 41, 44, WOOD[0], WOOD)
    s.rect(31, 42, 41, 44, GOLD[3], GOLD)
    s.rect(31, 41, 41, 42, GOLD[4], GOLD)
    # doors with X
    s.rect(20, 47, 52, 66, CREAM[4], CREAM)
    s.rect(22, 49, 50, 66, WOOD[2], WOOD)
    s.rect(35, 49, 37, 66, CREAM[4], CREAM)
    for k in range(17):
        for (ax, bx) in ((22, 35), (37, 50)):
            t = k / 16
            xa = round(ax + (bx - ax - 1) * t)
            xb = round(bx - 1 - (bx - ax - 1) * t)
            y = 49 + k
            s.put(xa, y, CREAM[4], CREAM)
            s.put(xb, y, CREAM[4], CREAM)
    for y in range(66, 70):
        for x in range(5, 67):
            s.put(x, y, STONE[1] if (x % 6 == 0 or y == 68) else (STONE[4] if y < 68 else STONE[3]), STONE)
    outline(s)
    shadow(s, 36, 70, 34, 2)
    return s.image()


# ---------------------------------------------------------------- capybara 6 x 20x16
CAPY_W = 22


def capy_frame(leg_phase, bob=0, blink=False):
    s = Spr(CAPY_W, 16)
    oy = bob
    # legs (behind body)
    offs = {0: (0, 0, 0, 0), 1: (1, -1, -1, 1), 2: (0, 0, 0, 0), 3: (-1, 1, 1, -1)}[leg_phase]
    for lx, o in zip((3, 6, 11, 13), offs):
        s.rect(lx + o, 11 + oy, lx + o + 2, 14, CAPY[1], CAPY)
    blob(s, 8.5, 8.6 + oy, 7.0, 4.3, CAPY, lo=2, hi=4)
    # head: lighter so it reads separately, with a shaded neck seam
    blob(s, 15.5, 7.0 + oy, 3.8, 3.4, CAPY, lo=3, hi=5)
    s.rect(17, 5 + oy, 21, 10 + oy, CAPY[4], CAPY)  # blocky snout
    s.rect(17, 9 + oy, 21, 10 + oy, CAPY[3], CAPY)
    s.rect(21, 6 + oy, 22, 9 + oy, CAPY[3], CAPY)
    for y in range(6, 11):
        s.put(12, y + oy, CAPY[2], CAPY)
    s.put(13, 3 + oy, CAPY[2], CAPY)  # ear
    s.put(14, 3 + oy, CAPY[3], CAPY)
    # eye (closed = line)
    if blink:
        s.put(16, 6 + oy, CAPY[1], CAPY)
        s.put(17, 6 + oy, CAPY[1], CAPY)
    else:
        s.put(16, 5 + oy, H("#1a0f08"), CAPY)
        s.put(16, 6 + oy, H("#1a0f08"), CAPY)
    s.put(21, 6 + oy, H("#1a0f08"), CAPY)  # nose
    s.put(19, 9 + oy, CAPY[1], CAPY)  # smile
    s.put(20, 9 + oy, CAPY[1], CAPY)
    s.put(14, 7 + oy, PINK, CAPY)  # blush
    # mascot leaf sprout
    s.put(15, 3 + oy, GREEN[2], GREEN)
    s.put(15, 2 + oy, GREEN[3], GREEN)
    s.put(16, 1 + oy, GREEN[5], GREEN)
    s.put(14, 1 + oy, GREEN[4], GREEN)
    outline(s)
    return s.image()


def capybara():
    frames = [capy_frame(0), capy_frame(0, bob=1, blink=True)] + [capy_frame(p, bob=(p % 2)) for p in range(4)]
    sheet = Image.new("RGBA", (CAPY_W * 6, 16))
    for i, f in enumerate(frames):
        sheet.alpha_composite(f, (CAPY_W * i, 0))
    return sheet


# ---------------------------------------------------------------- small props / tiles / fx
def stake():
    s = Spr(6, 10)
    s.rect(2, 3, 4, 10, WOOD[2], WOOD)
    s.rect(2, 3, 3, 10, WOOD[3], WOOD)
    s.rect(1, 1, 5, 4, CREAM[4], CREAM)
    s.rect(1, 3, 5, 4, CREAM[2], CREAM)
    outline(s)
    return s.image()


def soil_bed():
    random.seed(3)
    s = Spr(48, 48)
    for y in range(48):
        for x in range(48):
            edge = min(x, y, 47 - x, 47 - y)
            if edge < 2:
                idx = 1 if (x == 0 or y == 47 or x == 47) else 2
            else:
                r = y % 8
                idx = {0: 2, 1: 3, 2: 4, 3: 4, 4: 3, 5: 3, 6: 2, 7: 1}[r]
                if random.random() < 0.06:
                    idx += random.choice((-1, 1))
            s.put(x, y, SOIL[max(0, min(5, idx))], SOIL)
    for x in range(48):  # grass lip on top
        if x % 3 != 1:
            s.put(x, 0, GREEN[3], GREEN)
    return s.image()


def pond():
    random.seed(4)
    s = Spr(48, 48)
    for y in range(48):
        for x in range(48):
            edge = min(x, y, 47 - x, 47 - y)
            if edge < 3:
                idx = 4 if edge == 2 else (3 if edge == 1 else 1)
                s.put(x, y, SAND[idx], SAND)
            else:
                idx = 3 if y > 8 else 4
                if y in (3, 4) or x in (3,):
                    idx = 1  # inner shade under rim
                s.put(x, y, WATER[idx], WATER)
    for x0, y0, n in ((10, 14, 6), (26, 22, 5), (14, 34, 7), (32, 38, 4)):
        for i in range(n):
            s.put(x0 + i, y0, WATER[5] if i in (0, n - 1) else WATER[4], WATER)
    return s.image()


PATHSTONE = R("#6e5b4b", "#a8907a", "#c7a896", "#d8c4ac", "#e7dcc4", "#f4eedd")


def cobble16():
    """Seamless 16x16 cobble in the packs' beige path stone."""
    random.seed(21)
    seeds = [(1.5, 2.0), (8.5, 1.0), (13.0, 5.5), (4.0, 8.5), (10.5, 10.0), (2.0, 14.0), (14.5, 14.5)]
    seeds = [(sx + random.uniform(-0.6, 0.6), sy + random.uniform(-0.6, 0.6), random.choice((2, 3, 3, 4)))
             for sx, sy in seeds]

    def near(x, y):
        def dist(sx, sy):
            dx = abs(x + 0.5 - sx)
            dy = abs(y + 0.5 - sy)
            return math.hypot(min(dx, 16 - dx), min(dy, 16 - dy) * 1.15)
        ds = sorted((dist(sx, sy), i) for i, (sx, sy, _) in enumerate(seeds))
        return ds[0], ds[1]
    gap = [[False] * 16 for _ in range(16)]
    tone = [[0] * 16 for _ in range(16)]
    for y in range(16):
        for x in range(16):
            (d1, i1), (d2, _) = near(x, y)
            gap[y][x] = d2 - d1 < 1.3
            tone[y][x] = seeds[i1][2]
    s = Spr(16, 16)
    g = lambda x, y: gap[y % 16][x % 16]
    for y in range(16):
        for x in range(16):
            if g(x, y):
                s.put(x, y, PATHSTONE[1] if not g(x, y - 1) else PATHSTONE[2], PATHSTONE)
                continue
            idx = tone[y][x]
            if g(x, y - 1) or g(x - 1, y):
                idx += 1
            if g(x, y + 1) or g(x + 1, y):
                idx = 1
            s.put(x, y, PATHSTONE[max(1, min(5, idx))], PATHSTONE)
    return s.image()


def fx_sparkle():
    sheet = Image.new("RGBA", (9 * 4, 9))
    for f, r in enumerate((1, 2, 4, 2)):
        s = Spr(9, 9)
        for i in range(-r, r + 1):
            c = GOLD[5] if abs(i) < r else GOLD[3]
            s.put(4 + i, 4, c)
            s.put(4, 4 + i, c)
        if r >= 2:
            for d in (-1, 1):
                s.put(4 + d, 4 + d, GOLD[4])
                s.put(4 + d, 4 - d, GOLD[4])
        s.put(4, 4, WHITE)
        sheet.alpha_composite(s.image(), (9 * f, 0))
    return sheet


def fx_coin():
    sheet = Image.new("RGBA", (10 * 4, 10))
    for f, w in enumerate((4.2, 2.8, 1.0, 2.8)):
        s = Spr(10, 10)
        blob(s, 5, 5, max(w, 0.9), 4.2, GOLD, lo=2, hi=5)
        if w > 3:
            s.rect(4, 3, 6, 7, GOLD[2], GOLD)
            s.put(4, 3, GOLD[4], GOLD)
        outline(s)
        sheet.alpha_composite(s.image(), (10 * f, 0))
    return sheet


def fx_dust():
    sheet = Image.new("RGBA", (10 * 3, 8))
    for f, (r, n) in enumerate(((1.6, 3), (2.4, 3), (2.0, 2))):
        s = Spr(10, 8)
        for k in range(n):
            blob(s, 2.5 + k * 2.6, 5 - (k % 2), r, r * 0.8, SAND, lo=3, hi=5)
        sheet.alpha_composite(s.image(), (10 * f, 0))
    return sheet


def fx_leaf():
    sheet = Image.new("RGBA", (10, 5))
    for f in range(2):
        s = Spr(5, 5)
        pts = ((1, 3), (2, 2), (3, 1), (2, 3), (3, 2)) if f == 0 else ((1, 1), (2, 2), (3, 3), (1, 2), (2, 3))
        for i, (x, y) in enumerate(pts):
            s.put(x, y, GREEN[4] if i < 3 else GREEN[2], GREEN)
        sheet.alpha_composite(s.image(), (5 * f, 0))
    return sheet


def nine_slice_check(img, scale=3):
    """Stretch a 48x48 9-slice (16px corners) to 144x96 to eyeball seams."""
    W, Hh = 144, 96
    out = Image.new("RGBA", (W, Hh))
    c = 16
    src = img
    xs = [(0, c, 0, c), (c, 48 - c, c, W - c), (48 - c, 48, W - c, W)]
    ys = [(0, c, 0, c), (c, 48 - c, c, Hh - c), (48 - c, 48, Hh - c, Hh)]
    for sx0, sx1, dx0, dx1 in xs:
        for sy0, sy1, dy0, dy1 in ys:
            part = src.crop((sx0, sy0, sx1, sy1))
            # tile (not stretch) the middle so pixels stay crisp
            for ty in range(dy0, dy1, sy1 - sy0):
                for tx in range(dx0, dx1, sx1 - sx0):
                    out.alpha_composite(part.crop((0, 0, min(sx1 - sx0, dx1 - tx), min(sy1 - sy0, dy1 - ty))), (tx, ty))
    return out


def main():
    items = {
        "buildings/cottage_teal": cottage(),
        "buildings/barn_red": barn(),
        "npc/capybara": capybara(),
        "props/stake": stake(),
        "tiles/soil_bed": soil_bed(),
        "tiles/pond": pond(),
        "tiles/cobble": cobble16(),
        "fx/sparkle": fx_sparkle(),
        "fx/coin": fx_coin(),
        "fx/dust": fx_dust(),
        "fx/leaf": fx_leaf(),
    }
    for name, im in items.items():
        p = os.path.join(OUT, name + ".png")
        os.makedirs(os.path.dirname(p), exist_ok=True)
        im.save(p)
    preview(items)
    print("wrote", len(items), "sprites")


def preview(items):
    """Cottage + barn + plots + pond next to pack art on grass (pack art only if present locally)."""
    W, Hh = 192, 200
    scene = Image.new("RGBA", (W, Hh), H("#96c55f"))
    have_pack = os.path.exists(os.path.join(PACK_OUT, "manifest.json"))
    if have_pack:
        for i, n in enumerate(["ground/grass_03", "ground/grass_10", "ground/grass_21", "ground/grass_30",
                               "ground/grass_44", "ground/grass_52", "ground/grass_61", "ground/grass_70"]):
            p = os.path.join(PACK_OUT, n + ".png")
            if os.path.exists(p):
                g = Image.open(p)
                for k in range(3):
                    scene.alpha_composite(g, ((i * 47 + k * 61) % (W - 16), (i * 29 + k * 67) % (Hh - 16)))
    scene.alpha_composite(items["buildings/barn_red"], (6, 6))
    scene.alpha_composite(items["buildings/cottage_teal"], (104, 2))
    bed = nine_slice_check(items["tiles/soil_bed"]).crop((0, 0, 144, 48))
    scene.alpha_composite(bed, (8, 100))
    scene.alpha_composite(nine_slice_check(items["tiles/pond"]).crop((0, 0, 56, 36)), (8, 156))
    if have_pack:
        for i, crop in enumerate(["pepper", "pumpkin", "grape", "wheat", "squash", "cauliflower"]):
            strip = Image.open(os.path.join(PACK_OUT, "crops", crop + ".png"))
            fh = strip.height
            stage = [3, 2, 3, 1, 4, 0][i]
            f = strip.crop((32 * stage, 0, 32 * stage + 32, fh))
            scene.alpha_composite(f, (8 + i * 24 - 4, 140 - fh))
            scene.alpha_composite(items["props/stake"], (8 + i * 24 + 16, 132))
        tree = Image.open(os.path.join(PACK_OUT, "trees", "apple_med.png"))
        scene.alpha_composite(tree, (W - tree.width + 10, Hh - tree.height))
    capy = items["npc/capybara"].crop((0, 0, CAPY_W, 16))
    scene.alpha_composite(capy, (160, 120))
    scene.alpha_composite(items["fx/sparkle"].crop((18, 0, 27, 9)), (60, 104))
    scene.alpha_composite(items["fx/coin"].crop((0, 0, 10, 10)), (100, 160))
    out = os.path.join(ROOT, "docs", "design", "art")
    os.makedirs(out, exist_ok=True)
    scene.resize((W * 4, Hh * 4), Image.NEAREST).save(os.path.join(out, "cultiva-sprites-preview.png"))
    strip = Image.new("RGBA", (CAPY_W * 6 + 8, 16 + 8), H("#e7dcc4"))
    strip.alpha_composite(items["npc/capybara"], (4, 4))
    strip.resize((strip.width * 8, strip.height * 8), Image.NEAREST).save(os.path.join(out, "capybara-frames.png"))


if __name__ == "__main__":
    main()

"""Cultiva art test: 32x32 tiles + tomato growth stages, drawn procedurally.

Run:  python tools/art/draw_art_test.py
Outputs PNGs to assets/sprites/ and a comparison sheet to docs/design/art-test/.
"""
import math
import os
import random
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


# ---------------------------------------------------------------- palette
def H(h):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


def ramp(*hs):
    return [H(h) for h in hs]


GRASS = ramp("#24473a", "#2f6340", "#3e7d45", "#4f964b", "#68ad55", "#8cc663", "#b4dc7a")
SOIL = ramp("#33201f", "#4a2d25", "#633c2c", "#7b4d35", "#93613f", "#ab784c", "#c4915e")
STONE = ramp("#3b3a4f", "#55566b", "#717489", "#8f94a8", "#adb3c4", "#cdd3df")
LEAF = ramp("#183c2e", "#235536", "#2f703c", "#428c41", "#5ca848", "#80c454", "#a9db6b")
WOOD = ramp("#3d2419", "#5a3522", "#7a4b2d", "#98653a", "#b5804b", "#cf9d62")
RED = ramp("#4a1023", "#7c1a2c", "#b02a30", "#d8432f", "#ef6a3f", "#ff9d6a", "#ffe0c4")
ORANGE = ramp("#5a2a14", "#8c4318", "#c2641e", "#e88a2a", "#f8b046", "#ffd88a", "#fff0c8")
DORM = ramp("#3a3322", "#58502c", "#776e3a", "#978c4c", "#b5a864", "#d0c482")
SEED = ramp("#6b5332", "#a88a52", "#dcc283", "#f4e2ab")
SHADOW = (24, 10, 24, 80)

_l = (-0.55, -0.65, 0.52)
_n = math.sqrt(sum(v * v for v in _l))
LIGHT = tuple(v / _n for v in _l)


# ---------------------------------------------------------------- sprite buffer
class Spr:
    def __init__(self, w, h, wrap=False):
        self.w, self.h, self.wrap = w, h, wrap
        self.c = [[None] * w for _ in range(h)]  # RGBA
        self.r = [[None] * w for _ in range(h)]  # ramp (for outline); None = no outline

    def _pos(self, x, y):
        x, y = int(math.floor(x)), int(math.floor(y))
        if self.wrap:
            return x % self.w, y % self.h
        if 0 <= x < self.w and 0 <= y < self.h:
            return x, y
        return None

    def put(self, x, y, col, rmp=None):
        p = self._pos(x, y)
        if p:
            self.c[p[1]][p[0]] = col
            self.r[p[1]][p[0]] = rmp

    def solid(self, x, y):
        p = self._pos(x, y)
        return p is not None and self.r[p[1]][p[0]] is not None

    def ramp_at(self, x, y):
        p = self._pos(x, y)
        return self.r[p[1]][p[0]] if p else None

    def image(self):
        im = Image.new("RGBA", (self.w, self.h), (0, 0, 0, 0))
        for y in range(self.h):
            for x in range(self.w):
                if self.c[y][x]:
                    im.putpixel((x, y), self.c[y][x])
        return im


# ---------------------------------------------------------------- primitives
def blob(s, cx, cy, rx, ry, rm, lo=1, hi=None, spec=False, rim=True, noise=0.0):
    """Shaded ellipse lit from top-left, mapped onto ramp[lo..hi]."""
    hi = len(rm) - 2 if hi is None else hi
    pts = []
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            nx = (x + 0.5 - cx) / rx
            ny = (y + 0.5 - cy) / ry
            d = nx * nx + ny * ny
            if d <= 1.0:
                pts.append((x, y, nx, ny, d))
    inside = {(p[0], p[1]) for p in pts}
    for x, y, nx, ny, d in pts:
        nz = math.sqrt(max(0.0, 1 - d))
        i = nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2]
        t = min(1.0, max(0.0, (i + 0.15) / 1.1))
        idx = lo + round(t * (hi - lo))
        if noise and random.random() < noise:
            idx += random.choice((-1, 1))
        if spec and i > 0.9:
            idx = len(rm) - 1
        if rim and (((x + 1, y) not in inside and nx > 0) or ((x, y + 1) not in inside and ny > 0)):
            idx = max(0, lo - 1)
        idx = max(0, min(len(rm) - 1, idx))
        s.put(x, y, rm[idx], rm)


def shadow(s, cx, cy, rx, ry):
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            nx = (x + 0.5 - cx) / rx
            ny = (y + 0.5 - cy) / ry
            if nx * nx + ny * ny <= 1:
                s.put(x, y, SHADOW, None)


def line(s, pts, rm, idx, hl=None):
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for k in range(int(n) + 1):
            x = round(x0 + (x1 - x0) * k / n)
            y = round(y0 + (y1 - y0) * k / n)
            s.put(x, y, rm[idx], rm)
            if hl is not None:
                s.put(x - 1, y, rm[hl], rm) if False else None


def outline(s):
    """Selective outline: lighter on top/left, darker on bottom/right."""
    adds = []
    for y in range(s.h):
        for x in range(s.w):
            if s.solid(x, y):
                continue
            pick = None
            for dx, dy, dark in ((0, 1, False), (1, 0, False), (0, -1, True), (-1, 0, True)):
                rm = s.ramp_at(x + dx, y + dy)
                if rm is not None:
                    col = rm[0] if dark else rm[1]
                    if pick is None or dark:
                        pick = (col, rm)
            if pick:
                adds.append((x, y, pick))
    for x, y, (col, rm) in adds:
        s.put(x, y, col, None)


def sinwave(x, y, fx, fy, ph, size=32):
    return math.sin(2 * math.pi * (fx * x + fy * y) / size + ph)


# ---------------------------------------------------------------- tiles
def tile_grass(seed=3):
    random.seed(seed)
    s = Spr(32, 32, wrap=True)
    for y in range(32):
        for x in range(32):
            n = 0.5 + 0.22 * sinwave(x, y, 1, 2, 1.3) + 0.16 * sinwave(x, y, 3, -1, 0.4) + 0.1 * sinwave(x, y, 2, 3, 2.1)
            idx = 3
            if n < 0.22:
                idx = 2
            elif n > 0.8:
                idx = 4
            if random.random() < 0.035:
                idx += random.choice((-1, 1))
            s.put(x, y, GRASS[idx], GRASS)
    for _ in range(11):
        x, y = random.randrange(32), random.randrange(32)
        s.put(x - 1, y + 1, GRASS[2], GRASS)
        s.put(x, y + 1, GRASS[1], GRASS)
        s.put(x + 1, y + 1, GRASS[2], GRASS)
        for bx, lean in ((x - 1, -1), (x, 0), (x + 1, 1)):
            if random.random() < 0.25 and lean != 0:
                continue
            L = random.choice((2, 3, 3))
            for i in range(L):
                px = bx + (lean if i == L - 1 else 0)
                col = GRASS[3] if i == 0 else GRASS[5] if i == L - 1 else GRASS[4]
                if i == L - 1 and random.random() < 0.3:
                    col = GRASS[6]
                s.put(px, y - i, col, GRASS)
    return s.image()


def tile_soil(seed=5):
    random.seed(seed)
    s = Spr(32, 32, wrap=True)
    prof = {0: 1, 1: 2, 2: 4, 3: 5, 4: 4, 5: 3, 6: 3, 7: 2}
    phases = [random.uniform(0, 6.28) for _ in range(4)]
    for y in range(32):
        for x in range(32):
            k = (y // 8) % 4
            wob = round(0.7 * math.sin(2 * math.pi * 2 * x / 32 + phases[k]))
            r = (y - wob) % 8
            idx = prof[r]
            if random.random() < 0.1:
                idx += random.choice((-1, 1))
            if r == 0 and random.random() < 0.2:
                idx = 0
            s.put(x, y, SOIL[max(0, min(6, idx))], SOIL)
    # clods
    for _ in range(14):
        x = random.randrange(32)
        ridge = random.randrange(4) * 8
        y = ridge + random.choice((2, 3))
        s.put(x, y, SOIL[6], SOIL)
        s.put(x + 1, y, SOIL[5], SOIL)
        s.put(x, y + 1, SOIL[2], SOIL)
        s.put(x + 1, y + 1, SOIL[2], SOIL)
    return s.image()


def tile_cobble(seed=9):
    random.seed(seed)
    seeds = []
    for cy in range(4):
        for cx in range(4):
            seeds.append((cx * 8 + 4 + random.uniform(-1.8, 1.8), cy * 8 + 4 + random.uniform(-1.8, 1.8),
                          random.choice((2, 3, 3, 3, 4))))
    ids = [[0] * 32 for _ in range(32)]
    gap = [[False] * 32 for _ in range(32)]
    for y in range(32):
        for x in range(32):
            ds = []
            for i, (sx, sy, _) in enumerate(seeds):
                dx = abs(x + 0.5 - sx)
                dy = abs(y + 0.5 - sy)
                dx = min(dx, 32 - dx)
                dy = min(dy, 32 - dy)
                ds.append((math.sqrt(dx * dx + dy * dy * 1.15), i))
            ds.sort()
            ids[y][x] = ds[0][1]
            gap[y][x] = ds[1][0] - ds[0][0] < 1.5
    s = Spr(32, 32, wrap=True)
    g = lambda x, y: gap[y % 32][x % 32]
    for y in range(32):
        for x in range(32):
            if g(x, y):
                idx = 1 if not g(x, y - 1) else (2 if random.random() < 0.8 else 3)
                s.put(x, y, SOIL[idx], SOIL)
                continue
            base = seeds[ids[y][x]][2]
            idx = base
            if g(x, y - 1) or g(x - 1, y):
                idx = base + 1
                if g(x, y - 1) and g(x - 1, y):
                    idx = base + 2
            if g(x, y + 1) or g(x + 1, y):
                idx = 1
                if g(x, y + 1) and g(x + 1, y):
                    idx = 0
            if idx == base and random.random() < 0.08:
                idx += random.choice((-1, 1))
            s.put(x, y, STONE[max(0, min(5, idx))], STONE)
    return s.image()


# ---------------------------------------------------------------- tomato stages (32x48, base at y=40)
def mound(s, w=5.5):
    blob(s, 16, 40, w, 2.4, SOIL, lo=2, hi=5)


def stage_seed():
    s = Spr(32, 48)
    shadow(s, 16, 42, 7.5, 1.8)
    blob(s, 16, 39.5, 7, 3.2, SOIL, lo=3, hi=6)
    # planting hole
    for x in range(14, 19):
        s.put(x, 38, SOIL[1], SOIL)
    s.put(15, 37, SOIL[2], SOIL)
    s.put(16, 37, SOIL[2], SOIL)
    s.put(17, 37, SOIL[2], SOIL)
    # seeds
    s.put(15, 37, SEED[3], SEED)
    s.put(16, 37, SEED[2], SEED)
    s.put(17, 38, SEED[2], SEED)
    s.put(16, 38, SEED[1], SEED)
    # tiny sparkle so an unstarted task still catches the eye
    s.put(21, 33, SEED[3], SEED)
    s.put(21, 32, SEED[2], SEED)
    s.put(21, 34, SEED[2], SEED)
    s.put(20, 33, SEED[2], SEED)
    s.put(22, 33, SEED[2], SEED)
    outline(s)
    return s


def stage_sprout():
    random.seed(21)
    s = Spr(32, 48)
    shadow(s, 16, 41.5, 4.5, 1.5)
    mound(s, 4.5)
    line(s, [(16, 39), (16, 35)], LEAF, 3)
    blob(s, 13.0, 34.2, 2.8, 1.7, LEAF, lo=2, hi=5)
    blob(s, 19.0, 33.4, 2.8, 1.7, LEAF, lo=2, hi=5)
    outline(s)
    return s


def stage_young():
    random.seed(22)
    s = Spr(32, 48)
    shadow(s, 16, 41.5, 6.5, 2)
    mound(s, 4.5)
    stem = [(16 + round(0.8 * math.sin(y / 3)), y) for y in range(40, 22, -1)]
    line(s, stem, LEAF, 2)
    for cx, cy, rx, ry in ((11.5, 35, 3.4, 2.2), (20.5, 32, 3.4, 2.2), (12, 28, 3.2, 2.1),
                           (20, 25.5, 3, 2), (16, 21.5, 2.8, 2.3)):
        blob(s, cx, cy, rx, ry, LEAF, lo=2, hi=5, noise=0.08)
    outline(s)
    return s


def fruit(s, fx, fy, rm, r=2.9):
    blob(s, fx, fy, r, r * 0.92, rm, lo=1, hi=5, spec=True)
    s.put(fx - 0.5, fy - r + 0.2, LEAF[4], LEAF)
    s.put(fx + 0.5, fy - r + 0.2, LEAF[2], LEAF)
    s.put(fx - 1.5, fy - r + 0.8, LEAF[3], LEAF)


def stage_ripe():
    random.seed(23)
    s = Spr(32, 48)
    shadow(s, 16, 42, 10, 2.6)
    # stake
    for y in range(6, 42):
        s.put(23, y, WOOD[4] if y > 6 else WOOD[5], WOOD)
        s.put(24, y, WOOD[2], WOOD)
    # back foliage
    for cx, cy, rx, ry in ((10, 30, 4.8, 3.6), (21, 22, 4.6, 3.6), (12, 16, 4.2, 3.4),
                           (20, 35, 4.6, 3.1), (16, 10, 3.8, 3.1), (16, 24, 5, 4)):
        blob(s, cx, cy, rx, ry, LEAF, lo=1, hi=3, noise=0.1)
    stem = [(16 + round(1.2 * math.sin(y / 4)), y) for y in range(41, 9, -1)]
    line(s, stem, LEAF, 2)
    # front foliage
    for cx, cy, rx, ry in ((9, 36, 4, 2.8), (22.5, 30, 4, 3), (10, 24, 4, 3), (21, 15, 3.8, 3),
                           (13, 11, 3.4, 2.7), (17, 29, 3.5, 3), (15, 19, 3.5, 2.8)):
        blob(s, cx, cy, rx, ry, LEAF, lo=2, hi=5, noise=0.1)
    # twine on stake
    for y in (14, 27):
        s.put(22, y, SEED[2], SEED)
        s.put(23, y, SEED[3], SEED)
        s.put(24, y, SEED[1], SEED)
    for fx, fy in ((12.5, 33.5), (19.5, 37), (20.5, 25), (11, 20), (18, 17.5), (14.5, 27.5)):
        fruit(s, fx, fy, RED)
    fruit(s, 23.5, 19.5, ORANGE, r=2.4)
    outline(s)
    return s


def stage_dormant():
    random.seed(24)
    s = Spr(32, 48)
    shadow(s, 16, 41.5, 6, 2)
    mound(s, 4.5)
    # bent stem
    line(s, [(16, 40), (16, 30), (17, 27), (19, 25), (21, 25), (22, 26)], DORM, 3)
    # drooping leaves: thin, hanging down from the stem
    for pts in (((15, 37), (13, 37), (11, 38), (10, 40)),
                ((17, 35), (19, 35), (21, 36), (22, 38)),
                ((15, 32), (13, 32), (12, 33), (11, 35)),
                ((17, 29), (19, 29), (20, 30), (21, 32)),
                ((22, 26), (23, 27), (23, 29))):
        for i, (x, y) in enumerate(pts):
            s.put(x, y, DORM[4] if i < 2 else DORM[3], DORM)
            s.put(x, y + 1, DORM[2], DORM)
    # one tired leaf blob near the top
    blob(s, 20, 24.5, 2.4, 1.6, DORM, lo=2, hi=4)
    outline(s)
    return s


STAGES = [("seed", stage_seed), ("sprout", stage_sprout), ("young", stage_young),
          ("ripe", stage_ripe), ("dormant", stage_dormant)]


# ---------------------------------------------------------------- composition
def tile_fill(dst, tile, x0, y0, x1, y1):
    for y in range(y0, y1):
        for x in range(x0, x1):
            dst.putpixel((x, y), tile.getpixel((x % 32, y % 32)))


def soil_patch(dst, soil, x0, y0, x1, y1):
    tile_fill(dst, soil, x0, y0, x1, y1)
    for x in range(x0, x1):
        dst.putpixel((x, y0), SOIL[1])
        dst.putpixel((x, y1 - 1), SOIL[0])
        dst.putpixel((x, y1 - 2), SOIL[1])
        if (x * 7) % 5 == 0:
            dst.putpixel((x, y0), GRASS[3])
            dst.putpixel((x, y0 + 1), GRASS[2])
    for y in range(y0, y1):
        dst.putpixel((x0, y), SOIL[1])
        dst.putpixel((x1 - 1, y), SOIL[0])


def font(sz):
    try:
        return ImageFont.load_default(size=sz)
    except TypeError:
        return ImageFont.load_default()


def main(ref_path=None):
    tiles_dir = os.path.join(ROOT, "assets", "sprites", "tiles")
    crops_dir = os.path.join(ROOT, "assets", "sprites", "crops")
    out_dir = os.path.join(ROOT, "docs", "design", "art-test")
    for d in (tiles_dir, crops_dir, out_dir):
        os.makedirs(d, exist_ok=True)

    grass, soil, cobble = tile_grass(), tile_soil(), tile_cobble()
    grass.save(os.path.join(tiles_dir, "tile_grass.png"))
    soil.save(os.path.join(tiles_dir, "tile_soil.png"))
    cobble.save(os.path.join(tiles_dir, "tile_cobble.png"))

    frames = [fn().image() for _, fn in STAGES]
    sheet = Image.new("RGBA", (32 * len(frames), 48), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        sheet.alpha_composite(f, (32 * i, 0))
    sheet.save(os.path.join(crops_dir, "crop_tomato.png"))

    # --- stage close-up (6x) over soil
    pad = 8
    strip = Image.new("RGBA", (len(frames) * (32 + pad) + pad, 48 + pad * 2), H("#f3e6c8"))
    for i, f in enumerate(frames):
        cell = Image.new("RGBA", (32, 48), (0, 0, 0, 0))
        tile_fill(cell, soil, 0, 16, 32, 48)
        cell.alpha_composite(f)
        strip.alpha_composite(cell, (pad + i * (32 + pad), pad))
    strip = strip.resize((strip.width * 6, strip.height * 6), Image.NEAREST)
    d = ImageDraw.Draw(strip)
    for i, (name, _) in enumerate(STAGES):
        d.text(((pad + i * (32 + pad)) * 6 + 4, 6), name, fill=H("#3b2a1e"), font=font(26))
    strip.save(os.path.join(out_dir, "tomato-stages-6x.png"))

    # --- mini farm scene 8x5 tiles
    W, Hh = 256, 160
    scene = Image.new("RGBA", (W, Hh))
    tile_fill(scene, grass, 0, 0, W, Hh)
    tile_fill(scene, cobble, 0, 32, W, 64)
    tile_fill(scene, cobble, 160, 64, 192, Hh)
    soil_patch(scene, soil, 6, 72, 154, 156)
    rows = [(110, ["seed", "sprout", "young", "ripe", "dormant"]),
            (148, ["ripe", "young", "ripe", "sprout", "ripe"])]
    byname = dict(zip([n for n, _ in STAGES], frames))
    for base_y, names in rows:
        for i, n in enumerate(names):
            cx = 6 + 15 + round(29.6 * i)
            scene.alpha_composite(byname[n], (cx - 16, base_y - 40))
    # tiles row on the right as raw swatches
    scene.alpha_composite(grass, (208, 72))
    scene.alpha_composite(soil, (208, 106))
    s4 = scene.resize((W * 4, Hh * 4), Image.NEAREST)
    s4.save(os.path.join(out_dir, "scene-4x.png"))

    # --- side-by-side with reference
    top = 56
    if ref_path and os.path.exists(ref_path):
        ref = Image.open(ref_path).convert("RGBA")
        ref = ref.resize((round(ref.width * s4.height / ref.height), s4.height), Image.LANCZOS)
        comp = Image.new("RGBA", (s4.width + ref.width + 24, s4.height + top), H("#f3e6c8"))
        comp.alpha_composite(s4, (0, top))
        comp.alpha_composite(ref, (s4.width + 24, top))
        dd = ImageDraw.Draw(comp)
        dd.text((8, 12), "Cultiva art test (32x32, drawn in code) - 4x", fill=H("#3b2a1e"), font=font(28))
        dd.text((s4.width + 32, 12), "Reference (mood only)", fill=H("#3b2a1e"), font=font(28))
        comp.save(os.path.join(out_dir, "comparison.png"))
    print("done")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else None)

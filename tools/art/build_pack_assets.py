"""Build game-ready sprites from the two CraftPix packs (see docs/steps/2.1-import-craftpix.md).

Run:  python tools/art/build_pack_assets.py
Reads packs from E:\\ (override with CULTIVA_PACK1 / CULTIVA_PACK2 env vars) and writes
app/assets/sprites/pack/ (git-ignored: CraftPix licence forbids redistributing source files).
"""
import colorsys
import json
import os
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from slice_packs import components  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PACK1 = os.environ.get("CULTIVA_PACK1", r"E:\free-pixel-art-plants-for-farm\PNG")
PACK2 = os.environ.get(
    "CULTIVA_PACK2", r"E:\craftpix-net-654184-main-characters-home-free-top-down-pixel-art-asset\PNG"
)
OUT = os.path.join(ROOT, "app", "assets", "sprites", "pack")

# ---------------------------------------------------------------- crops
# (row top, row bottom) in Plants.png; columns are 32px cells: 0 sprout, 1 young, 2 ripe.
CROP_ROWS = {
    "grape": (8, 47),
    "bean": (56, 95),
    "pepper": (95, 127),
    "cauliflower": (137, 156),
    "peas": (171, 207),
    "lettuce": (216, 234),
    "squash": (239, 270),
    "pumpkin": (287, 316),
    "wheat": (352, 382),
}
SEED_ITEM = (228, 422, 8, 6)  # dirt mound with a seed
STAGES = ["seed", "sprout", "young", "ripe", "dormant"]

# ---------------------------------------------------------------- props (approx regions, tightened later)
PROPS = {  # name: (sheet, x, y, w, h)
    "buildings/house_red": ("exterior", 8, 0, 138, 128),
    "props/fence_square": ("exterior", 160, 16, 48, 48),
    "props/fence_posts": ("exterior", 208, 0, 32, 64),
    "props/rocks_small": ("exterior", 144, 106, 96, 22),
    "props/apple_bush": ("exterior", 200, 128, 40, 48),
    "trees/oak_small": ("exterior", 156, 176, 68, 80),
    "props/bush_round": ("exterior", 208, 232, 32, 36),
    "trees/apple_big": ("exterior", 0, 312, 66, 96),
    "trees/oak_big": ("exterior", 64, 312, 64, 96),
    "trees/apple_med": ("exterior", 128, 316, 64, 88),
    "trees/pine_dark_a": ("exterior", 192, 312, 48, 48),
    "trees/pine_dark_b": ("exterior", 192, 360, 48, 44),
    "props/rock_mossy": ("exterior", 0, 404, 48, 44),
    "props/fern": ("exterior", 0, 456, 48, 40),
    "props/mushroom_small": ("exterior", 48, 464, 32, 32),
    "props/log_short": ("exterior", 80, 464, 32, 32),
    "props/crates": ("exterior", 112, 464, 40, 48),
    "props/well": ("exterior", 0, 488, 48, 56),
    "props/scarecrow": ("exterior", 0, 544, 64, 72),
    "props/mushroom_big": ("exterior", 64, 544, 48, 48),
    "props/mushrooms": ("exterior", 64, 592, 32, 32),
    "props/stump": ("exterior", 96, 592, 32, 32),
    "props/bush_dark": ("exterior", 0, 616, 48, 48),
    "props/bush_dark_small": ("exterior", 48, 624, 32, 40),
    "props/boulder": ("exterior", 0, 656, 56, 96),
    "props/stones_grey": ("exterior", 176, 722, 64, 30),
}
WHOLE = {  # kept as sheets for animation later
    "fx/smoke_sheet": ("Smoke_animation.png", {"frameW": 48, "frameH": 48, "frames": 6}),
    "animals/cat_sheet": ("cat_animation.png", {"frameW": 32, "frameH": 32, "cols": 3, "rows": 18}),
}


def tight(img, x, y, w, h):
    """Crop to the sprite(s) in a region, dropping small bits of neighbours cut by the region edge."""
    region = img.crop((x, y, x + w, y + h))
    boxes = components(region, gap=2)
    if not boxes:
        raise ValueError(f"empty region {x},{y},{w},{h}")
    biggest = max(b[2] * b[3] for b in boxes)

    def touches_edge(b):
        return b[0] == 0 or b[1] == 0 or b[0] + b[2] >= w or b[1] + b[3] >= h

    keep = [b for b in boxes if b[2] * b[3] >= biggest * 0.25 or not touches_edge(b)]
    keep = [b for b in keep if b[2] * b[3] >= 6]
    # mask out everything not kept
    clean = Image.new("RGBA", region.size)
    for bx, by, bw, bh in keep:
        clean.alpha_composite(region.crop((bx, by, bx + bw, by + bh)), (bx, by))
    bb = clean.getchannel("A").getbbox()
    return clean.crop(bb)


def wilt(img):
    """Recolour greens to a dry olive/tan for the dormant stage."""
    out = img.copy()
    px = out.load()
    for yy in range(out.height):
        for xx in range(out.width):
            r, g, b, a = px[xx, yy]
            if a == 0:
                continue
            h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            if 0.12 < h < 0.5 and s > 0.15:  # foliage
                h = 0.11 + (h - 0.12) * 0.15
                s *= 0.5
                v = min(1.0, v * 0.92 + 0.04)
            elif s > 0.25 and not (0.0 <= h < 0.1 and v < 0.55):  # fruit/flowers (keep soil)
                s *= 0.35
                v *= 0.85
            r, g, b = (round(c * 255) for c in colorsys.hsv_to_rgb(h, s, v))
            px[xx, yy] = (r, g, b, a)
    return out


def build():
    plants = Image.open(os.path.join(PACK1, "Plants.png")).convert("RGBA")
    sheets = {"exterior": Image.open(os.path.join(PACK2, "exterior.png")).convert("RGBA")}
    os.makedirs(OUT, exist_ok=True)
    manifest = {"source": "CraftPix freebies (see docs/03-asset-sources.md)", "crops": {}, "sprites": {}}

    # crops
    sx, sy, sw, sh = SEED_ITEM
    seed = plants.crop((sx, sy, sx + sw, sy + sh))
    for name, (top, bottom) in CROP_ROWS.items():
        fh = bottom - top
        frames = [plants.crop((c * 32, top, c * 32 + 32, bottom)) for c in range(3)]
        sprout_bb = frames[0].getchannel("A").getbbox()
        base = sprout_bb[3] if sprout_bb else fh
        seed_frame = Image.new("RGBA", (32, fh))
        seed_frame.alpha_composite(seed, ((32 - sw) // 2, base - sh))
        strip = Image.new("RGBA", (32 * 5, fh))
        for i, f in enumerate([seed_frame, frames[0], frames[1], frames[2], wilt(frames[1])]):
            strip.alpha_composite(f, (32 * i, 0))
        os.makedirs(os.path.join(OUT, "crops"), exist_ok=True)
        strip.save(os.path.join(OUT, "crops", name + ".png"))
        manifest["crops"][name] = {"file": f"crops/{name}.png", "frameW": 32, "frameH": fh, "stages": STAGES}

    # props
    for name, (sheet, x, y, w, h) in PROPS.items():
        spr = tight(sheets[sheet], x, y, w, h)
        path = os.path.join(OUT, name + ".png")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        spr.save(path)
        manifest["sprites"][name] = {"file": name + ".png", "w": spr.width, "h": spr.height}

    # ground details: split into single sprites
    gg = Image.open(os.path.join(PACK2, "ground_grass_details.png")).convert("RGBA")
    for kind, (y0, y1) in {"grass": (128, 288), "dirt": (0, 128)}.items():
        region = gg.crop((0, y0, gg.width, y1))
        boxes = components(region, gap=1)
        os.makedirs(os.path.join(OUT, "ground"), exist_ok=True)
        names = []
        for i, (x, y, w, h) in enumerate(b for b in boxes if b[2] * b[3] >= 12):
            n = f"ground/{kind}_{i:02d}"
            region.crop((x, y, x + w, y + h)).save(os.path.join(OUT, n + ".png"))
            names.append(n + ".png")
        manifest[f"{kind}_details"] = names

    for name, (fname, meta) in WHOLE.items():
        path = os.path.join(OUT, name + ".png")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        Image.open(os.path.join(PACK2, fname)).convert("RGBA").save(path)
        manifest["sprites"][name] = {"file": name + ".png", **meta}

    # grass base colour = solid centre of the grass autotile
    manifest["grass_base"] = "#%02x%02x%02x" % sheets["exterior"].getpixel((56, 184))[:3]

    with open(os.path.join(OUT, "manifest.json"), "w") as f:
        json.dump(manifest, f, indent=1)
    contact(manifest)
    print(f"crops={len(manifest['crops'])} sprites={len(manifest['sprites'])} "
          f"grass_details={len(manifest['grass_details'])} dirt_details={len(manifest['dirt_details'])} "
          f"grass_base={manifest['grass_base']}")


def contact(manifest):
    items = [(k, v["file"]) for k, v in manifest["crops"].items()] + [
        (k, v["file"]) for k, v in manifest["sprites"].items() if "sheet" not in k
    ]
    imgs = [(k, Image.open(os.path.join(OUT, f))) for k, f in items]
    pad, col_w = 6, 170
    cols = 6
    rows = (len(imgs) + cols - 1) // cols
    row_h = [max(im.height for _, im in imgs[r * cols:(r + 1) * cols]) + 14 for r in range(rows)]
    sheet = Image.new("RGBA", (cols * col_w, sum(row_h) + pad * rows), (235, 228, 210, 255))
    d = ImageDraw.Draw(sheet)
    try:
        fnt = ImageFont.load_default(size=10)
    except TypeError:
        fnt = ImageFont.load_default()
    y = pad
    for r in range(rows):
        for c, (k, im) in enumerate(imgs[r * cols:(r + 1) * cols]):
            x = c * col_w + pad
            d.text((x, y), k.split("/")[-1], fill=(40, 30, 20, 255), font=fnt)
            sheet.alpha_composite(im, (x, y + 12))
        y += row_h[r] + pad
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST).save(os.path.join(OUT, "_contact.png"))


if __name__ == "__main__":
    build()

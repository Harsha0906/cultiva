"""Slice CraftPix sheets into named sprites.

detect <sheet.png> <out_prefix> [gap]
    Finds sprite islands (alpha components, merged when within `gap` px),
    writes <out_prefix>.json (boxes) and <out_prefix>-sheet.png (numbered contact sheet, 3x).

export <manifest.json> <out_dir>
    Manifest: {"sheets": {"plants": "E:/.../Plants.png"},
               "sprites": {"crops/tomato_0": ["plants", x, y, w, h], ...}}
    Writes <out_dir>/<name>.png for every entry.

Raw packs are never copied wholesale; only the named crops the app uses are exported,
into a git-ignored folder (CraftPix licence: no redistribution of source files).
"""
import json
import os
import sys

from PIL import Image, ImageDraw, ImageFont


def components(im, gap=1):
    a = im.getchannel("A")
    w, h = im.size
    px = a.load()
    solid = [[px[x, y] > 8 for x in range(w)] for y in range(h)]
    seen = [[False] * w for _ in range(h)]
    boxes = []
    for y0 in range(h):
        for x0 in range(w):
            if not solid[y0][x0] or seen[y0][x0]:
                continue
            stack = [(x0, y0)]
            seen[y0][x0] = True
            x1 = x2 = x0
            y1 = y2 = y0
            while stack:
                x, y = stack.pop()
                x1, x2, y1, y2 = min(x1, x), max(x2, x), min(y1, y), max(y2, y)
                for dy in range(-gap - 1, gap + 2):
                    for dx in range(-gap - 1, gap + 2):
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < w and 0 <= ny < h and solid[ny][nx] and not seen[ny][nx]:
                            seen[ny][nx] = True
                            stack.append((nx, ny))
            if (x2 - x1 + 1) * (y2 - y1 + 1) >= 4:
                boxes.append([x1, y1, x2 - x1 + 1, y2 - y1 + 1])
    boxes.sort(key=lambda b: (b[1] // 16, b[0]))
    return boxes


def detect(sheet, prefix, gap=1):
    im = Image.open(sheet).convert("RGBA")
    boxes = components(im, gap)
    with open(prefix + ".json", "w") as f:
        json.dump(boxes, f)
    s = 3
    bg = Image.new("RGBA", im.size, (235, 228, 210, 255))
    bg.alpha_composite(im)
    big = bg.resize((im.width * s, im.height * s), Image.NEAREST)
    d = ImageDraw.Draw(big)
    try:
        fnt = ImageFont.load_default(size=11)
    except TypeError:
        fnt = ImageFont.load_default()
    for i, (x, y, w, h) in enumerate(boxes):
        d.rectangle([x * s, y * s, (x + w) * s - 1, (y + h) * s - 1], outline=(220, 30, 60, 255))
        d.text((x * s + 1, y * s), str(i), fill=(20, 20, 160, 255), font=fnt)
    big.save(prefix + "-sheet.png")
    print(f"{len(boxes)} boxes -> {prefix}.json")


def export(manifest, out_dir):
    with open(manifest) as f:
        m = json.load(f)
    sheets = {k: Image.open(v).convert("RGBA") for k, v in m["sheets"].items()}
    for name, (sheet, x, y, w, h) in m["sprites"].items():
        path = os.path.join(out_dir, name + ".png")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        sheets[sheet].crop((x, y, x + w, y + h)).save(path)
    print(f"exported {len(m['sprites'])} sprites to {out_dir}")


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "detect":
        detect(sys.argv[2], sys.argv[3], int(sys.argv[4]) if len(sys.argv) > 4 else 1)
    elif cmd == "export":
        export(sys.argv[2], sys.argv[3])

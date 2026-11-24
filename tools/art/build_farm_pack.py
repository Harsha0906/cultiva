"""Copies the user's Fantasy Farm art into app/assets/sprites/farm/.

House and tree are shown at half size (they are drawn for a much bigger
world); everything else keeps its native pixels. No art is drawn here.
Run: python tools/art/build_farm_pack.py "E:/Fantasy Farm Asset Pack Free version v1.0/Fantasy Farm Asset Pack Free version v1.0"
"""
import sys
from pathlib import Path

from PIL import Image

SRC = Path(sys.argv[1])
OUT = Path(__file__).resolve().parents[2] / "app" / "assets" / "sprites" / "farm"


def load(rel):
    return Image.open(SRC / rel).convert("RGBA")


def half(img):
    """2x box downscale with hard alpha, so edges stay crisp."""
    img = img.crop(img.getbbox())
    h = img.resize((img.width // 2, img.height // 2), Image.BOX)
    px = h.load()
    for y in range(h.height):
        for x in range(h.width):
            r, g, b, a = px[x, y]
            px[x, y] = (r, g, b, 255 if a >= 128 else 0)
    return h


def half_keep(cell):
    """Half size without cropping, so animation frames stay aligned."""
    h = cell.resize((cell.width // 2, cell.height // 2), Image.BOX)
    px = h.load()
    for y in range(h.height):
        for x in range(h.width):
            r, g, b, a = px[x, y]
            px[x, y] = (r, g, b, 255 if a >= 128 else 0)
    return h


def save(img, name):
    img.save(OUT / f"{name}.png")
    print(f"{name}.png {img.size}")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    save(half(load("Buldings/farm_house.png")), "house")
    save(half(load("Tree/tree1.png").crop((44, 0, 148, 160))), "tree")
    save(half(load("Objects/bushes.png").crop((3, 19, 58, 64))), "bush")
    save(load("Tiles/grass.png").crop((64, 64, 96, 96)), "grass")
    save(load("Tiles/hill.png").crop((48, 48, 80, 80)), "path")
    save(load("Tiles/water.png").crop((32, 160, 64, 192)), "water")
    save(load("Tiles/farm_tile.png").crop((32, 0, 128, 96)), "soil")
    details = [
        ("Objects/flowers.png", [(44, 15, 54, 32), (7, 18, 22, 32), (76, 20, 84, 32), (109, 23, 116, 32)]),
        ("Objects/stones.png", [(41, 20, 54, 32), (74, 20, 86, 32), (108, 24, 117, 32)]),
        ("Objects/decor_plants.png", [(9, 24, 22, 32), (44, 26, 54, 32)]),
    ]
    # User's house kit, trees and fence (tools/art/src/user_kit), native size.
    kit = Path(__file__).resolve().parent / "src" / "user_kit"
    save(Image.open(kit / "house_kit.png").convert("RGBA").crop((148, 3, 220, 98)), "house2")
    save(Image.open(kit / "fence.png").convert("RGBA").crop((12, 3, 86, 96)), "pen")
    trees = Image.open(kit / "plants_trees.png").convert("RGBA")
    save(trees.crop((588, 96, 623, 143)), "tree_mid")
    save(trees.crop((709, 14, 761, 80)), "tree_fruit")
    stones = load("Objects/stones.png")
    for i, box in enumerate([(1, 9, 29, 32), (41, 20, 54, 32), (74, 20, 86, 32), (108, 24, 117, 32)]):
        save(stones.crop(box), f"stone_{i}")
    # Animals: 4-frame idle row (80px cells), shown at half size.
    for name in ("chicken", "cow", "goat"):
        sheet = load(f"Animals/{name}.png")
        frames = [half_keep(sheet.crop((i * 80, 80, i * 80 + 80, 160))) for i in range(4)]
        strip = Image.new("RGBA", (40 * 4, 40))
        for i, f in enumerate(frames):
            strip.alpha_composite(f, (i * 40, 0))
        save(strip, f"animal_{name}_strip")
        save(frames[0].crop(frames[0].getbbox()), f"animal_{name}")
    n = 0
    for rel, boxes in details:
        sheet = load(rel)
        for box in boxes:
            save(sheet.crop(box), f"detail_{n}")
            n += 1


if __name__ == "__main__":
    main()

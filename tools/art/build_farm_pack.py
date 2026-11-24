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
    n = 0
    for rel, boxes in details:
        sheet = load(rel)
        for box in boxes:
            save(sheet.crop(box), f"detail_{n}")
            n += 1


if __name__ == "__main__":
    main()

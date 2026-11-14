# Step 2a — Art Test (32×32)

> **Superseded (2026-11-14):** v1 now uses a 16×16 grid with CraftPix packs (see [03-asset-sources.md](../03-asset-sources.md)). This 32×32 test proved that code-drawn art works, and the same helpers will be reused at 16px.

## Goal
Find out whether sprites drawn in code can reach the quality of the founder's reference image (a professional top-down farm pack). The result decides how all v1 art gets made:
- **Pass:** Claude draws every asset this way (option A).
- **Fail:** use a licensed pack or SpriteCook, with Claude drawing only the Cultiva-specific pieces (options B or C).

## Design
- **Grid:** 32×32 tiles. Crop frames are 32×48 (bottom-aligned, so tall plants overhang the tile above).
- **Light:** comes from the top-left. Each material has a 4–6 colour ramp, and shadows shift toward purple-blue.
- **Outlines:** "selective" outlines, darker on the bottom-right and lighter on the top-left. No pure black.
- **Assets in this test:**
  1. `tile_grass.png`: seamless, with grass tufts and colour variation.
  2. `tile_soil.png`: seamless tilled soil with furrow ridges.
  3. `tile_cobble.png`: seamless cobblestones with shaded stones and gaps.
  4. `crop_tomato.png`: sprite sheet of 5 frames × 32×48 (seed, sprout, young, ripe, dormant).
- **Comparison sheet:** a small farm patch built from these tiles, shown at 4× next to the reference image.

## Implementation plan
1. A Python script `tools/art/draw_art_test.py` (Pillow) with helpers:
   - palette ramps
   - shaded blobs (sphere lighting mapped to the ramp)
   - an automatic outline pass
   - seeded noise
   - seamless (wrap-around) drawing for tiles
2. Draw the tiles procedurally (grass tufts, furrows, cobbles laid out as a tiling pattern).
3. Build the tomato from stems, leaf clusters and fruit spheres, with highlights.
4. Export the PNGs to `assets/sprites/` and the comparison sheet to `docs/design/art-test/`.

## Files to create
- `tools/art/draw_art_test.py`
- `assets/sprites/tiles/tile_grass.png`, `tile_soil.png`, `tile_cobble.png`
- `assets/sprites/crops/crop_tomato.png`
- `docs/design/art-test/comparison.png`

## How we verify it
- Tiles repeat across a 4×3 area with no visible seams.
- Each plant stage reads clearly at 1×, at the size it will be on screen.
- The founder looks at the comparison side by side with the reference and decides pass or fail.

## What was built
2026-11-14:
- `tools/art/draw_art_test.py` draws everything procedurally. Run it with `python tools/art/draw_art_test.py <reference.webp>`.
- Tiles: `tile_grass.png`, `tile_soil.png`, `tile_cobble.png`, all seamless.
- `crop_tomato.png`: 5 frames of 32×48.
- `docs/design/art-test/`: `scene-4x.png`, `tomato-stages-6x.png`, `comparison.png`.
- Fixes after the first pass: dormant stage redrawn as a wilted plant (it looked like rocks), seed mound made more visible with a sparkle, grass made less blotchy.

**Self-assessment:**
- Crops and the soil tile are close to the reference's quality.
- The cobbles are too regular, and the grass has no edge transitions yet (grass meeting soil or path).
- Buildings, animals and the capybara are untested. They're the hardest assets to draw in code.

**Decision:** pending the founder's review.

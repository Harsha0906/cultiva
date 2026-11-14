# Step 2b: House Test

> **Superseded (2026-11-14):** the grid moved to 16×16. The teal cottage design (hip roof, dormer, capybara sign, shutters) is kept and will be redrawn at 16px density to match the CraftPix packs.

## Goal
Buildings are the hardest assets to draw in code. Before deciding how all the art gets made, check that a farmhouse drawn in code can reach the reference's quality.

## Design
- **Size:** 96×104 px (3 tiles wide, about 3¼ tall), in the same 3/4 top-down view as the tiles.
- **Original Cultiva cottage.** It must not copy the reference.
  - **Roof:** teal shingles (the signature colour) with side gables, a centre dormer with a round window, and a terracotta brick chimney.
  - **Walls:** cream plaster with a wooden timber frame and a stone foundation.
  - **Front:** an arched plank door with a **carved capybara sign** above it, two windows with terracotta shutters and flower boxes, a wall lantern, and a stone doorstep.
  - **Small ivy cluster** on one corner.
- **Lighting and outlines:** the same rules as step 2a (light from the top-left, colour ramps, selective outline).

## Implementation plan
1. `tools/art/draw_house_test.py` reuses the helpers from `draw_art_test.py` and adds rectangle, shingle-row and brick helpers.
2. Draw it back to front: roof back slope and chimney → front roof slope with shingles → dormer → walls and timber frame → windows, door, sign, lantern → foundation and step → ivy → outline pass.
3. Build a test scene: the house on grass, with a cobble path to the door and a small tomato patch beside it.
4. Build a comparison against the house in the reference image.

## Files
- `tools/art/draw_house_test.py`
- `assets/sprites/buildings/house_cottage.png`
- `docs/design/art-test/house-scene-4x.png`, `house-comparison.png`

## How we verify it
- The house reads clearly at 1× and its details hold up at 4×.
- It doesn't look like a copy of the reference house.
- The founder decides between: draw everything in code, buy a licensed pack, or a mix.

## What was built
2026-11-14:
- `tools/art/draw_house_test.py` draws a 96×104 teal hip-roof cottage. Output: `assets/sprites/buildings/house_cottage.png`.
- Preview images: `house-6x.png`, `house-scene-4x.png`, `house-comparison.png`.
- **The second pass fixed:**
  - The roof looked flat and brick-like. It's now a hip roof with a lit left side, a shaded right side, rounded shingles, a light-to-dark gradient down the slope, and sloped top corners.
  - The ivy looked like beads. It's now a winding vine with leaves.

**Self-assessment:** it holds up as a building with a clear identity: teal roof, terracotta shutters and chimney, and a capybara sign over the door.
- **Weaker than the reference:** wall texture (plain plaster, no siding detail), only a front view (no porch or side depth), and the dormer is simple.
- **Fixable in step 2** with more passes.

**Decision:** pending the founder's review.

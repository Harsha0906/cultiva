# Cultiva: Art Sources (v1)

The decision (2026-11-14) is to **mix** two free CraftPix packs with art Claude draws in code for the Cultiva-specific pieces.

## Pack 1: Free Pixel Art Plants for Farm
- **Location:** `E:\free-pixel-art-plants-for-farm`
- **Files:** `PNG/Plants.png` (768×432), `PNG/Supplies.png` (288×224), and the PSD sources.
- **Contents:**
  - About 11 crops, each with 4 growth stages: grapes, tomato-like vine, pepper, flower bush, beans, squash, pumpkin, agave, wheat/grass, sunflower and others.
  - Fruit trees and palms with growth stages.
  - Seed and sprout props.
  - Each sprite comes in two versions, with and without a soil base.
  - `Supplies.png` holds farm tools and supplies (not reviewed in detail yet).

## Pack 2: Main Characters Home (free top-down)
- **Location:** `E:\craftpix-net-654184-main-characters-home-free-top-down-pixel-art-asset`
- **Grid:** 16×16 tiles (confirmed from `Tiled_files/Exterior.tmx`).
- **Contents:**
  - **Exterior:** a red-roof house, cobble path pieces, grass edge tiles, dirt patches, fences, rocks, stumps, mushrooms, bushes, fruit trees, a scarecrow and a well.
  - **Other sheets:** house details, an animated door and windows, chimney smoke animation, animated trees, ground and grass details, and a full interior tileset.
  - **Animals:** a cat (animated) and a bird (fly and jump animations).

## License (CraftPix freebies, https://craftpix.net/file-licenses/, read 2026-11-14)
| Question | Answer |
|---|---|
| Commercial use in a mobile app | ✅ Allowed, in any number of projects |
| Modifying the art | ✅ Allowed |
| Credit required | ❌ No, though appreciated (we will credit CraftPix in the About screen anyway) |
| Reselling or redistributing the raw files | ❌ Not allowed |
| Letting users **save or export the artwork itself** | ❌ Not allowed. ⚠️ This could affect the future "share your farm" image. A composed screenshot of your farm is probably fine, but check with CraftPix before building that feature |
| Using the assets for AI training, fine-tuning or testing | ❌ Not allowed. **Never upload these packs to SpriteCook or any AI generator** |

Each freebie's own download page may add terms. Keep the original zip files and download receipts.

## Grid size: 16×16 (decided 2026-11-14)
Both packs are drawn on a 16×16 grid, so v1 switches from 32×32 to 16×16. The packs are used at their native size, and every Claude-drawn sprite is drawn at 16px density to match their style: soft coloured outlines, the same palette range and shading.

## Who makes what
| Asset | Source |
|---|---|
| Crops and growth stages | Pack 1, plus Claude-drawn **dormant** variants (packs have none) |
| Trees, bushes, rocks, fences, scarecrow, well, mushrooms | Pack 2 |
| Grass, path and dirt tiles | Pack 2 |
| Main house | **Claude: the Cultiva teal cottage**, redrawn to match the pack style. The pack's red-roof house could serve as a shop or neighbour building |
| Capybara | Founder's design, with a Claude placeholder until then |
| Name stakes, sparkle/harvest effects, coins, UI icons and panels | Claude |
| Cat and bird ambient animals | Pack 2 |

# Cultiva — Design Spec (v1)

Visual reference: [design/blueprint.html](design/blueprint.html)

## 1. Navigation
*Updated 2026-11-14 from the founder's home-page sketch.*
- **Bottom nav, 4 tabs, each with an icon and a label:** **Farm · Tasks · Shop · Progress**. The icons are pixel-art, not emoji.
- **Header shortcuts:**
  - The **profile avatar** (top-left) opens Profile.
  - The **calendar button** (top-right) opens Progress scrolled to the calendar and today's journal.
- Focus Mode is a full-screen view opened from a Plot A plant. It is not a tab.
- Every tappable thing is at least 44×44pt, and the header and nav stay inside the safe areas.

## 2. Screens

### 2.1 Farm (home): founder's sketch plus additions ✅ approved 2026-11-14
Layout, top to bottom:
1. **Header bar:**
   - **Avatar** (top-left): capybara face with a small level ring.
   - **Centre pill:** coins and today's progress (e.g. `5/9`).
   - **Calendar button** (top-right): shows today's date number.
2. **Buildings row:**
   - **Barn** (left) is the **Storage**: today's harvested crops plus the decorations you own. Tap it to see what you've harvested and to place decorations. A badge dot appears when there's a new harvest.
   - **Home** (right) is the teal cottage. Tap it to see a greeting and today's summary.
3. **Path:** a cobble path runs from the home's door down the right side, alongside both plots.
4. **Plot A, "Daily":** a wide soil bed with **6 plants in one row**, each in a ~64pt-wide cell so it's easy to tap. A wooden sign shows the plot name and count (`Daily 2/6`).
5. **Plot B, "To-Do & Habits":** same layout, directly below Plot A.
6. **Bottom strip:** a pond plus decoration spots where items bought in the Shop appear.
7. **"Next up" button** just above the nav, within thumb reach, e.g. `▶ Read · 30 min`. It's the screen's one primary action: tap to start the next unfinished task.
8. **Bottom nav.**

Interactions:
- Tap empty soil → "Plant a task" sheet.
- Tap a Plot A plant → Focus Mode.
- Tap a Plot B plant → complete it (it grows to ripe) → tap again to harvest.
- The **capybara** wanders the path. Tap it for a short encouraging line or a tip ("2 crops are ripe, go harvest!").
- **Day/night tint:** the scene tints morning, day, evening or night to match the real time (one colour overlay, no extra art).
- The full list of tasks lives in the **Tasks** tab, for quick check-off without the farm.

### 2.1b Tasks (tab)
- A list of today's tasks grouped by plot, each with a progress bar, a check button and a timer button.
- Swipe actions also have visible buttons, so nothing depends on swiping.

### 2.2 Plant a task (sheet)
- Name, plot (A/B), crop type (cosmetic), for Plot A: duration (5/15/30/45/60 min or custom) and repeat days; for Plot B: to-do (one-off) or habit (repeats).

### 2.3 Focus Mode
- Large plant in centre growing through stages as time passes, countdown, progress bar, Pause / Give up / "I already did it" (reduced reward).
- Ends with harvest animation + coins.

### 2.4 Progress (tab; the calendar button lands here too)
- Today card: auto-log (harvested tasks, focus minutes, coins), mood (5 faces), one-line note.
- Week strip: bar chart of tasks done per day.
- History: calendar of past days as "farm postcards"; tap to open that day.

### 2.5 Shop
- Grid of decorations with coin price (fence, lamp, bench, flower pot, scarecrow, signpost, bush, rock path, birdbath, beehive-deco).
- Buy → place on farm in a decoration slot.

### 2.6 Profile (opened from the header avatar)
- Capybara avatar, farmer name, stats (days active, tasks harvested, focus hours, best week), settings: daily reset time (default 4:00), reminder time, sound, haptics.

## 3. Plant states
| Stage | Meaning |
|---|---|
| 0 Seed | Planted, not started |
| 1 Sprout | Started / ≥ 1% |
| 2 Young | ≥ 50% |
| 3 Ripe (sparkle) | Done — tap to harvest |
| Dormant | Missed yesterday — revives when done |

Daily plants replant themselves as seeds each morning after the reset time.

## 4. Rewards (v1)
| Action | Coins |
|---|---|
| Plot A task < 15 min | 5 |
| Plot A task 15–60 min | 12 |
| Plot A task > 60 min | 25 |
| Plot B to-do / habit | 8 |
| All Plot A harvested today | +20 bonus |
| "I already did it" | 50% |
| Daily cap | 150 |

## 5. Visual system
- **Grid:** **16×16 px tiles** (final, 2026-11-14), matching the CraftPix packs. Crops use the pack frames (about 16×32 for tall plants). Capybara about 16×16 to 24×24. The logical canvas is 192 px wide (12 tiles), drawn at 6× on a ~1170 px phone. Always scale by whole numbers with nearest-neighbour filtering.
- **Tap targets:** a plant tile at 6× is about 32pt, so plot cells are spaced so each tap area is at least 44pt.
- **Asset workflow:** see [03-asset-sources.md](03-asset-sources.md). The packs supply crops, terrain and props. Claude draws the Cultiva-specific sprites in code at 16px to match the packs' style and exports PNGs to `assets/sprites/`. The founder can touch any of them up in Pixelorama.
- **Signature colours:** terracotta `#d0673f` + teal `#2f8f8a`.
- **Palette:** grass `#6db356/#5a9e4b`, soil `#8a5a3b`, path `#c9b48a`, water `#4a90b8`, wood `#9c6b3f`, paper `#f3e6c8`, ink `#3b2a1e`.
- **Fonts:** pixel font (Pixelify Sans) for headings/numbers only; readable font (Nunito) for task text.
- **UI panels:** kraft-paper 9-slice panels with stitched border; wooden buttons.
- **Mascot:** capybara (founder-designed; placeholder until delivered).
- **Juice:** squash/stretch on growth, coin fly-to-HUD, light haptic on complete, soft pluck sound. Respect Reduce Motion.

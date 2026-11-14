# Cultiva — Project Overview

> Your to-do list is a pixel farm. Finish tasks, watch it grow.

## What it is
A cozy productivity + daily-habit mobile app. You play a **capybara farmer** with a home and **2 plots**. Each plot holds **6 plants**; each plant is a task. Completing tasks grows and harvests plants, earns coins, and records your day in a journal.

## Core loop
**Plant** a task → **tend** it (run its timer or tick it off) → **harvest** for coins → **spend** coins decorating the farm → the day is written into your **journal**.

## Principles
1. **Plants never die.** A missed day makes a plant *dormant* (droopy, greyed). Doing the task revives it. No shame.
2. **Small farm, focused day.** The 6-per-plot cap is a feature: it forces prioritisation.
3. **Reward commitment, not volume.** Daily coin cap; fixed rewards per task.
4. **First harvest in 60 seconds.** Onboarding grows and harvests one plant before anything else.

## Version 1 (MVP) scope
| In v1 | Deferred |
|---|---|
| Farm screen: house, capybara, Plot A + Plot B (6 each) | Home-screen widget |
| Plot A **Daily**: recurring, timed → plant grows with the timer | Seasons, animals, crop-dex |
| Plot B **To-Do & Habits**: tap to complete | Seed Bag backlog, Plot 3, levels |
| 4 growth stages + dormant state + harvest animation | Weekly share card, time-lapse |
| Coins + simple Shop (~10 decorations) | Streak shields (scarecrow / rain day) |
| Journal: auto daily log, mood, note, weekly chart | Friends, gifting |
| Profile: name, stats, reminder time | Accounts, cloud sync |
| One daily reminder + "timer done" notification | Monetisation (decided after v1) |

## Tech stack (v1)
| Layer | Choice |
|---|---|
| Framework | Flutter (Dart) |
| Farm rendering | Flame |
| State | Riverpod |
| Navigation | go_router |
| Storage | Drift (SQLite), offline-only |
| Notifications | flutter_local_notifications |
| Charts | fl_chart |
| Art | **16×16 grid.** Free CraftPix packs (crops, terrain, props) plus Cultiva-specific sprites drawn in code by Claude, all editable in Pixelorama. See [03-asset-sources.md](03-asset-sources.md) |
| Backend | None in v1 |
| Builds | Android Studio (Windows); Codemagic for iOS later |

## Documents
- [01-design-spec.md](01-design-spec.md) — screens, layout, visual system
- [design/blueprint.html](design/blueprint.html) — visual mockup of every v1 screen
- [02-roadmap.md](02-roadmap.md) — build steps; each step gets its own doc in `steps/` **before** work starts

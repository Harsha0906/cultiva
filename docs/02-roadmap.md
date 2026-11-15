# Cultiva — v1 Roadmap (phases & steps)

**Rules for every step**
1. Write `docs/steps/<phase>.<step>-<name>.md` **before** starting: goal, design, implementation plan, files, how we verify it, skills used.
2. Build it, using the listed skills.
3. Verify with tests and/or by running the app on the emulator or device.
4. Fill in **"What was built"** in the step doc, update this table, and commit.

**Avatar rule:** the capybara is Cultiva's mascot and is **never** a player avatar. Players choose their own avatar (see Phase 9).

Status key: ✅ done · ⏳ next · ⬜ pending

## Phase 0: Design (✅)
| Step | What | Status |
|---|---|---|
| 0.1 | Overview, v1 scope, stack ([00](00-overview.md)) | ✅ |
| 0.2 | Design spec and blueprint ([01](01-design-spec.md), [blueprint](design/blueprint.html)), home layout approved | ✅ |
| 0.3 | Art tests (32px, superseded) and asset sources ([03](03-asset-sources.md)), 16×16 grid | ✅ |

## Phase 1: Setup (✅ 2026-11-15)
| Step | What | Skills | Status |
|---|---|---|---|
| 1.1 | Install the Flutter SDK, connect the Android SDK, accept licenses, create an emulator, `flutter doctor` all green | flutter-device-testing | ✅ |
| 1.2 | Create the Flutter project, add packages (flame, riverpod, go_router, drift, flutter_local_notifications, fl_chart), set up folder structure and lint rules, `git init` | flutter-architecture, flutter-state-management | ✅ |
| 1.3 | App shell: 4-tab nav (Farm, Tasks, Shop, Progress) plus header routes, running on the emulator | flutter-navigation, flutter-device-testing | ✅ |

## Phase 2: Art & UI kit (✅ 2026-11-15)
| Step | What | Skills | Status |
|---|---|---|---|
| 2.1 | Import the CraftPix packs: slice the sheets into named sprites, add an asset manifest, check licenses | spritecook-workflow-essentials (manifest conventions only, **no AI upload**) | ✅ |
| 2.2 | Custom 16px sprites: teal cottage, red barn, capybara NPC (placeholder), name stakes, dormant crop variants, sparkle/harvest/coin effects | ui-ux-pro-max | ✅ |
| 2.3 | UI kit: 9-slice panels, wood/teal/paper buttons, pixel nav and header icons, fonts (Pixelify Sans + Nunito), theme tokens | flutter-ui-design, design-system | ✅ |
| 2.4 | Player avatar set (style decided by the founder) | flutter-ui-design | ✅ |

## Phase 3: Data & core logic (✅ 2026-11-15)
| Step | What | Skills | Status |
|---|---|---|---|
| 3.1 | Drift database: Task, CompletionLog, FocusSession, JournalEntry, Inventory, CoinLedger, Settings, plus repositories | flutter-persistence | ✅ |
| 3.2 | Day engine: 4 AM reset, repeat days, daily replant, dormant/revive, plot capacity of 6 (unit-tested) | dart-language, flutter-testing, test-driven-development | ✅ |
| 3.3 | Reward engine: coins per task type, daily cap, half reward for "I already did it", all-Daily bonus (unit-tested) | flutter-testing, test-driven-development | ✅ |

## Phase 4: Farm screen (✅ 2026-11-15)
| Step | What | Skills | Status |
|---|---|---|---|
| 4.1 | Flame scene: tiles, barn, home, path, two plots, pond/decoration strip, pixel-perfect scaling | flutter-performance, flutter-responsive-layout | ✅ |
| 4.2 | Plants on the farm: growth stage from data, tap targets, highlight, plot signs and counts | flutter-ui-patterns | ✅ |
| 4.3 | Header (avatar, coins/progress pill, calendar), "Next up" button, barn badge | flutter-ui-design | ✅ |
| 4.4 | Capybara NPC walking the path with tip bubbles, day/night tint | flutter-animation | ✅ |

## Phase 5: Tasks (✅ 2026-11-15)
| Step | What | Skills | Status |
|---|---|---|---|
| 5.1 | "Plant a task" sheet: name, plot, duration, repeat days, to-do or habit, crop choice | flutter-ui-patterns | ✅ |
| 5.2 | Tasks tab: list grouped by plot, check and timer buttons, edit and delete | flutter-ui-patterns, flutter-accessibility | ✅ |
| 5.3 | Complete → ripe → harvest flow with coin fly-to-HUD and haptics | flutter-animation | ✅ |

## Phase 6: Focus Mode (✅ 2026-11-15)
| Step | What | Skills | Status |
|---|---|---|---|
| 6.1 | Timer screen: timestamp-based countdown, growth in real time, pause, give up, "I already did it" | dart-concurrency, flutter-animation | ✅ |
| 6.2 | Keeps running in the background: timestamp timer + ongoing countdown notification (no foreground service needed; see step doc) and a "done" notification, clock-change guard | flutter-background-execution, flutter-notifications | ✅ |

## Phase 7: Shop & Barn
| Step | What | Skills | Status |
|---|---|---|---|
| 7.1 | Shop: decoration catalogue, buy with coins (ledger) | flutter-ui-patterns | ⬜ |
| 7.2 | Barn storage: today's harvest, owned decorations, place items in decoration spots | flutter-ui-patterns | ⬜ |

## Phase 8: Progress
| Step | What | Skills | Status |
|---|---|---|---|
| 8.1 | Today card: auto-log, mood, note | flutter-ui-patterns | ⬜ |
| 8.2 | Weekly chart and calendar of daily "farm postcards", open any past day | flutter-ui-design | ⬜ |

## Phase 9: Profile, settings, notifications
| Step | What | Skills | Status |
|---|---|---|---|
| 9.1 | Profile: name, avatar picker (no capybara), stats | flutter-ui-patterns | ⬜ |
| 9.2 | Settings: reset time, reminder time, sound, haptics, reduced motion; daily reminder notification | flutter-notifications | ⬜ |

## Phase 10: Onboarding & polish
| Step | What | Skills | Status |
|---|---|---|---|
| 10.1 | Onboarding: "Grandma's farm" intro, pick name and avatar, first habit, 1-minute guided harvest, notification permission | flutter-ui-design, ux-writing | ⬜ |
| 10.2 | Sound effects, haptics, empty states, About screen with CraftPix credits | flutter-ui-design | ⬜ |
| 10.3 | Accessibility pass (text scaling, screen reader, 44pt targets, reduced motion) | flutter-accessibility, accessibility-audit | ⬜ |

## Phase 11: QA & release
| Step | What | Skills | Status |
|---|---|---|---|
| 11.1 | Test sweep: unit, widget and integration tests on the main flows | flutter-testing, flutter-device-testing | ⬜ |
| 11.2 | Code review and performance pass (frame times, app size) | flutter-code-review, flutter-performance | ⬜ |
| 11.3 | Release build: app icon, splash, versioning, signed AAB/APK | flutter-build-release | ⬜ |

# Gameplay visual pass · 0.3.1

The player asked to align Godot with the earlier browser/Android design after
passing the asteroid test. This pass covers gameplay, results and their controls.
It does not import the previous web engine or start the M3 campaign/map/saves.

## What changed

- Navy space, restrained violet planet glow and stars, softly bordered rounded
  panels and board cells, and the earlier cosmic typography and hierarchy.
- Clear crystal and asteroid icons with progress, score and moves cards, and a
  full-width Nova panel. Phones keep all essentials on one screen. Wide desktops
  put goals/stats/Nova next to the board, using the available width.
- Royal-blue sapphire (`#3D65F5`) and vibrant emerald (`#24EE78`) match the user's
  earlier color direction. All six existing contours, cool Opal/warm Amber
  separation, rock cracks/pips and power markers remain. Gems gain colored facets.
- Real native labels/buttons replace small manually drawn HUD text. Local font
  variations provide consistent weights and work offline. Focus borders and
  stable modal focus support keyboard operation of UI controls.
- Nova is disabled while charging/resolving, supports cancel-with-charge, and
  consumes a pointer event only once. Help describes matches, powers and rocks.
  Pause/help block board gestures; returning preserves exact state.
- Distinct victory/defeat cards retain final score and deliberate Play again.
  Defeat reports crystals collected and rocks left. No invented star ratings.
- Synthetic stress drawing is available through desktop **F9**, away from the
  player HUD. It remains a development workload, not a device benchmark claim.

## Implementation boundaries

`board.gd` and `cosmic_board.gd` are unchanged. Score, move budget, objectives,
special formation/combos, Nova costs, blocker damage, physics and deadlocks keep
their accepted behavior. The scene still renders immutable event snapshots.

`game_layout.gd` shares square-board/panel/button/dialog geometry across drawing,
hit tests and HUD controls. The 400×760 base viewport expands to the actual
aspect. Safe-area pixels are converted to canvas coordinates on Android/iOS;
desktop browser/window geometry remains independent of phone insets. Panels
reserve space first, then the board fits the remaining region without scrolling.

`game_hud.gd` owns labels, buttons, meters, modal presentation and focus. Board
pointer handling uses `_unhandled_input`, so GUI controls do not also trigger a
board gesture. Imported fonts and goal SVGs require the CI import step before
real-scene tests; all Godot calls still use the strict parse/runtime log guard.

## Assets and rights

The goal SVGs and all procedural scene/crystal/asteroid artwork are original
code-native assets. No generated bitmap art or outside game art was imported.

Fonts are [Outfit](https://github.com/google/fonts/tree/main/ofl/outfit) and
[DM Sans](https://github.com/google/fonts/tree/main/ofl/dmsans), matching the
earlier web design. Their SIL Open Font License notices are in `assets/fonts/`.
Both export presets include text license files alongside the bundled fonts.
The source fonts were downloaded from the Google Fonts repository on 2026-10-29.

## Verification

- All **ten** GDScript suites pass locally under Godot 4.7.2; all nine previous
  suites are retained. The new UI suite reports **1,459 checks, zero failures**.
- Geometry checks cover 320×568, 360×640, 376×746, 400×760, 430×932, 768×1024,
  1280×720, 1440×900 and 900×480, each with three safe-area configurations.
- Real UI controls are checked at narrow phone, standard phone and desktop
  sizes for viewport containment and full help text. Actual mouse and touchscreen
  events exercise help, pause/resume and Nova targeting/cancellation. Result
  controls verify deliberate replay and retained final score.
- Desktop Compatibility renders were inspected at 320×568, 376×746 and 1280×800,
  including gameplay, a short-phone help card and victory. These are desktop
  renders at phone dimensions, not screenshots of an Android device.
- Four Android version-policy tests pass. CI keeps unique APK version/name,
  checksum, signing-mode metadata and actual manifest validation. The visual
  product base advances to `0.3.1`; obtain exact run/SHA from the new artifact.

The preceding build `0.3.0-dev.91.1+g71c389ec` (9101) was installed over wireless
ADB, its version read back, and the player reported **“Playtest passes”**. That
accepts the asteroid baseline. **The new visual build needs its own Android
acceptance.** No new physical-device FPS, Android font-scale, brightness,
screen-reader or exported-browser compatibility result is claimed here.

## Phone/browser visual checklist

1. All goals, the full square board, score, moves and Nova fit without scrolling
   or touching a cutout/navigation bar. Text stays readable at the phone's scale.
2. Identify every gem quickly, especially blue/green and golden Amber/icy Opal.
   Rock pips/cracks and all power markers stay clear during falling/clearing.
3. Open help and pause, return, and confirm board/score/moves/charge are intact.
   Charge Nova, cancel, activate, and check that a tap only performs one action.
4. Complete and lose a round. The correct result stays until Play again is
   intentionally pressed; final score and remaining goals are readable.
5. Check a longer session for clipped labels, missed taps or animation regressions.
   Exported web still needs mouse/touch, resize and background/resume review.

M4 remains open for these checks plus later audio/settings, reduced-motion,
broader accessibility, production art and platform acceptance.

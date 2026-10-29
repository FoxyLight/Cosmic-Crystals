# Crystal Visual Identity and Mobile Contrast

**Status:** Rendering implementation for M4 accessibility/visual clarity; **physical-device acceptance pending**.  
**Player feedback:** The original Solar Amber (pale yellow) and Lunar Opal (white) looked too similar on an Android phone, especially during cascades.  
**Source of truth:** [scripts/crystal_visuals.gd](../scripts/crystal_visuals.gd) controls colors and silhouettes; [scripts/prototype.gd](../scripts/prototype.gd) draws them.

## Updated crystal style specification

| Board ID | Crystal | Primary fill | Deep outline | Colored facet | Silhouette |
| --- | --- | --- | --- | --- | --- |
| 0 | Nebula Amethyst | `#824CF1` | `#371570` | `#C09BFF` | Four-point tall diamond |
| 1 | **Solar Amber** | **`#ED9B18`** | **`#733907`** | **`#FFD26A`** | **12-vertex, six-ray golden sunburst** |
| 2 | Quantum Sapphire | `#13B5EB` | `#075176` | `#70E6FF` | Wide six-sided sapphire |
| 3 | Plasma Ruby | `#F849A9` | `#792354` | `#FFA0D4` | Pink five-point star |
| 4 | Aurora Emerald | `#24CF87` | `#075B3C` | `#93FFD1` | Seven-point tapered emerald |
| 5 | **Lunar Opal** | **`#D0EDFF`** | **`#2F5C88`** | **`#83C9F6`** | **Tall eight-point ice shard with icy fracture** |

**Why the contrast now works better in principle:** Solar Amber has a saturated orange/gold fill, dark-brown border, warm central nucleus, and six outward rays. Lunar Opal is near-white with a distinct blue tint, navy-blue border, cool cyan facets, and an elongated pointed shard silhouette. Other gems have their own outlines and unique contour vertex counts. Sparkle colors vary by crystal rather than all defaulting to bright white.

The broad UI accent palette in [GAME_DESIGN.md](GAME_DESIGN.md) can still use pale gold `#FFCB65` for score text; the **Solar Amber game piece** uses the richer `#ED9B18` to preserve distinction from pale Opal.

## Implementation scope

- Keeps all existing board IDs, match logic, cascade events, scores and move budgets unchanged.
- Updates the same `_draw_crystal` path used by stable boards, swap animations, clears, falling and spawns.
- Uses solid opaque gem fills with a darker outer polygon and a lower-opacity colored facet.
- Keeps soft glows deliberately faint so light pieces do not merge visually.
- Centralizes tokens and shape definitions in one pure, testable GDScript class, without texture downloads or licensed art.

This is a **procedural prototype-art improvement**, not a final asset pipeline or completed M4 milestone.

## Automated checks

Run:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_visuals.gd
godot --headless --path . --script res://tests/test_board.gd
godot --headless --path . --quit-after 120
```

GitHub Actions additionally produces Android debug APK and Web artifacts. `tests/test_visuals.gd` validates that the palette has six entries, amber and opal have intentionally different warm/cool color components, every gem outline is darker than its fill, and all six crystal shapes have distinct vertex counts. These checks **cannot** prove human perceptual distinction on a physical screen.

## Android follow-up feedback (2026-10-29)

After testing the updated build on their Android phone, the player responded: **"Ok that looks a lot better."** This confirms a **positive subjective improvement** over the prior difficult-to-distinguish gold/white gems. No phone model, brightness setting, controlled side-by-side result, color-vision test, or measured performance was supplied with that feedback. We must not claim those checks passed.

The warm Solar Amber vs icy Lunar Opal palette and distinct outlines/silhouettes are retained as our provisional visual baseline. Complete the detailed acceptance checklist below as part of M4 visual accessibility testing.

## Android visual acceptance checklist

To validate the next APK using the [export guide](ANDROID_EXPORT.md) and [QA plan](QA_TEST_PLAN.md):

1. Install the new debug APK (CI debug signatures may differ; an uninstall might be needed before reinstalling, and that can erase app data).
2. View Amber and Opal side by side on the real 8×8 board under normal phone brightness and again with brightness reduced.
3. Verify that **Amber reads as gold/orange sun** and **Opal reads as frosty blue-white shard** during static play, swapping, falling and clears.
4. Check each of the six types is recognizable at a glance without comparing only hue, preferably on a small phone and a larger Android screen.
5. Check for dark-outline aliasing or disappearing glow details on a low-density device and during fast cascades.
6. Capture a screenshot or short device observation for the [M4 tracking issue](https://github.com/FoxyLight/Cosmic-Crystals/issues/8); record model, OS, screen brightness and any further confusing pairs.
7. Confirm the already available synthetic 30-second drawing stress test remains smooth; record FPS rather than assuming the new shapes are free.

**Exit criteria for this patch:** Automated checks and Android/Web preview builds pass, and a human Android playthrough confirms Amber/Opal are clearly distinct. If the device test fails, tune values and silhouettes again rather than declaring the full visual system finished.

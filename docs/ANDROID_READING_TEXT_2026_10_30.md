# Android reading text: larger default and extra-large option

2026-10-30, source base **0.5.3**. The player confirmed the 0.5.2 native slider and visible-text fix works, then requested: “make the larger font the default then increase the large font size.” This is a new presentation refinement, not a gameplay or save migration.

## Sizes

| Reading element | Previous standard | New standard (previous larger) | Extra-large |
| --- | ---: | ---: | ---: |
| Settings volume labels | 14 | 17 | 20 |
| Settings switches | 15 | 18 | 21 |
| Live settings preview | 14 | 20 | 26 |
| Home description | 15 | 19 | 23 |
| Map tutorial | 12 | 16 | 19 |
| Map goals | 12 | 15 | 18 |
| Gameplay feedback | 12 | 16 | 20 |
| Campaign help/confirmation text | 14 | 17 | 20 |

Sizes are logical Godot units, not a claim about Android system font scaling. Existing score/move numerals, brand headings and crystal silhouettes retain their roles. Settings labels the option **Larger Text** (PR #41) so the player can distinguish it from the already enlarged baseline. Turning it off restores the new readable standard, not the former small text.

## One-screen layout

Home description has room to wrap, with its journey button and progress moved down safely. Map previews reserve more room for wrapped goals/tutorials; constellation nodes can flatten into a single row on the shortest extra-large layout. Settings keeps 48-unit touch rows, a larger preview and status text. Gameplay captions reserve 64/84 units at standard/extra-large; the same geometry drives drawing and touch. Wide tablet layouts also reserve the extra caption height.

Each level now has an optional short `caption` string for the first-play HUD, keeping its full tutorial in the map/help. The full game instructions and goals remain available; no smaller font is substituted to force long text into the board. Help and result text/panels are spaced to prevent overlap; no scrolling is added.

## Saved settings and safety

Schema 1 and `large_text` remain unchanged: false selects the newly readable standard; true selects extra-large. Explicit saved choices, stars, best scores, unlocks, tutorials, volumes and motion remain intact. No migration forces a preference on or off. Package ID and private signing identity are unchanged, allowing compatible in-place updates. Back up/validate the current save before installation; never uninstall or clear player data.

## Verification and acceptance

The Android polish suite now includes 949 checks, including both sizes and a return to standard at 320x568, 376x746, 800x1280 and 1280x720; actual Label line metrics, no-ellipsis single-line widths, safe control bounds, Home button separation, all five map/game/help/result layouts and native volume drags. Existing gameplay, campaign, save, direction, version/signing and APK export suites remain active with strict Godot log guards. Compact native development renders of the settings sheet were inspected at both sizes. These are development checks, not a new physical phone pass.

Retest on Android: with Larger Text off, confirm the former larger sizing is now default. Turn it on and observe a clear increase, then turn it off to check reversal. Drag all volumes, inspect Home/map/all five levels/help/results, and close/reopen to retain your choice and earned records. Keep the new size's human acceptance separate from the player's confirmed 0.5.2 settings fix. Final CI/build/install evidence is recorded in the linked PR/issue tracking and delivery reply.


## Subsequent physical acceptance

The player confirmed **“Tested and approved”** after delivery/read-back of `0.5.3-dev.129.1+g77eb492c` / **12901**. This separately accepts the promoted default, increased optional size and final **Larger Text** label (PRs #40/#41). The prior instructions above are retained as the original checklist; no itemized scaling or quantitative device results are inferred.

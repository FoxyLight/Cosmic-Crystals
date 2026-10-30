# M3: The Five-Level Lyra Campaign

**Product base:** 0.4.0. **Implementation/automated verification:** present.
**M3 human Android acceptance:** player-reported PASS on 2026-10-29. No 6-20 expansion, other
constellations, accounts, cloud storage, monetization or store publishing.

## Levels and progression

| ID / theme | Seed / opening | Kinds / powers / Nova | Moves | Required goals | 2 / 3-star score |
| --- | --- | --- | ---: | --- | --- |
| 1 First Starlight | 1701 | 0-4 / ordinary matches / off | 18 | 24 crystals | 500 / 700 |
| 2 Starweaver's Spark | 1702 / four-match, pair 27 -> 19 | 0-5 / Beams / off | 22 | 36 crystals, forge 1 Beam | 700 / 1000 |
| 3 Asteroid Passage | 1703 / rocks 27:1, 36:1, 42:2 | 0-5 / Beams / off | 18 | 40 crystals, clear 3 rocks | 1000 / 1400 |
| 4 Cosmic Convergence | 1704 / Bomb 27, Supernova 28 | 0-5 / all powers / off | 20 | 50 crystals, activate 2 powers | 1100 / 1600 |
| 5 Lyra's Awakening | 1705 / column Beam 27; rocks 18:2, 21:1, 42:1, 45:2 | 0-5 / all powers / on | 22 | 60 crystals, clear 4 rocks, use Nova | 1500 / 2100 |

Indices are zero-based row-major on the 8x8 board. Starter powers are teaching
pieces, not objective credit until activated. Level 2's highlighted pair forms
a real four-match. Earlier stages cannot create unintroduced powers; a longer
line can still award a Beam when only Beams are enabled. Nova rests until level
5. Original mechanics remain enabled in legacy regression practice mode.

`data/lyra_levels.json` schema 1 defines `id`, `name`, `seed`, `kinds`, `powers`,
`nova`, `moves`, `asteroids`, `starter_powers`, optional `opening`/`hint`, `goals`,
`star_scores` and `tutorial`. Catalog validation rejects invalid indices,
durability, kinds, thresholds and disabled-mechanic goals. Definitions are
copied, so a run cannot mutate the catalog.

Goals: `collect` (kind -1 = any, or one kind ID), `asteroids` (all authored
rocks), `beams` (forge), `powers` (activations), `nova` (uses). At most three
goals display. All must be met after full resolution; last-move victory takes
priority. Invalid swaps cost zero; valid swaps one; Nova zero with no self-charge.

## Scoring and stars

Existing crystal scoring stays 10 x cascade depth per unique cleared crystal.
Rock damage gives no extra points/energy. On victory, **rating total = match
score + 25 x remaining moves**. Thresholds are `[0, two-star, three-star]`.
A win earns 1-3 stars, defeat zero. Results show match score, move bonus, total
and earned stars. Replay preserves independent maxima for best score/stars.

## Navigation and tutorials

Home -> connected five-node map -> selected level -> result. Locked nodes are
disabled and controller-guarded. Selected/current, next, completed and best-star
states are distinct. Victory offers Next (except level 5), Replay and Map;
defeat offers Try again and Map. The final map celebrates restored Lyra.

Pause offers resume/help/restart/map. Restart/leave requires confirmation for an
unfinished round; earned records stay safe. Navigation/restart/input are blocked
during effects. Android Back queues pause until settlement, cancels Nova, closes
a modal, returns results to map, and map to Home. Home Back exits normally.

First-time tutorial text appears in the map preview and a nonblocking two-line
game caption. After the first successful action its ID is remembered. Replay
has no forced tutorial; stage help remains. First Starlight covers matching,
goals and stars, then stages teach Beams, rocks, combinations and Nova. Reduced
motion is a persistent Home setting.

## Save schema and recovery

Android uses private `user://lyra-progress.json`; Web uses the browser's persistent
user filesystem where available. No cloud/account link. Example schema 1:

```json
{"schema_version":1,"highest_unlocked":2,
 "completed":[true,false,false,false,false],
 "best_scores":[600,0,0,0,0],"best_stars":[2,0,0,0,0],
 "tutorials_seen":[1],"settings":{"reduced_motion":false}}
```

The unlock counter derives from contiguous completions, not a trusted raw field.
Records/settings are validated; score/stars are bounded. Only stable committed
wins record progress. Tutorial history can save after a successful action even
on a later lost run. **No unfinished board is saved**: retry/abandon/process death
starts the authored board again, while earned progression remains on disk.

Writes validate/flush/read back `.tmp`, copy only a valid prior primary to `.bak`,
then atomically rename the temporary over the primary. Failed writes leave prior
data intact and show a notice. Loading tries supported primary, valid backup,
then safe defaults with a notice. Backup can be one checkpoint older. Orphan
temporary files are not promoted. No previous Godot schema existed to migrate:
unsupported old data uses backup or defaults. **Future schemas stay read-only**
with a warning; this build will not overwrite them. Browser persistence unavailable
produces a visible session-only warning, not a false saved-progress claim.

The earlier web game's localStorage is separate and is not migrated. Ephemeral
CI signatures may force an uninstall, which deletes Android private saves. Use
the existing persistent-debug-secret support for future seamless upgrades; back
up records before a required uninstall. No key/credential is committed here.

## Automated evidence

All ten pre-M3 suites are retained. Scene fixtures explicitly opt into the same
30-crystal/18-move/six-rock practice round; no old assertions were removed.
New Godot 4.7.2 suites locally report:

- `test_campaign.gd`: **10,325 checks**, zero failures. Catalog, objectives,
  turn commits, last move, star boundaries, typed collection, disabled mechanics,
  invalid swaps, Nova, stability and 120 deterministic balance rounds.
- `test_progress_store.gd`: **86 checks**, zero failures. Genuine five-level
  model playthrough with reload after each win, best records/no defeat credit,
  settings/tutorials, backup/corrupt/future/partial recovery and write failures.
- `test_campaign_scene.gd`: **966 checks**, zero failures. Real touch play through
  all five levels, results/next/map/replay, defeat, scene/disk restart,
  confirmations, queued Android Back, transition locks and actual Control bounds
  at 320x568, 376x746 and 1280x720.
- Five Python version-policy tests, including source/local-default drift.
- Export checks inspect the APK catalog contents and Web PCK resource/license
  paths. Every engine CI command retains the strict error-log guard.

Balance: 12 deterministic refill-seed variants per level per policy. Random-legal
wins are **12/12, 11/12, 11/12, 12/12, 12/12**; objective-aware one-ply wins are
**12/12 for every stage**. Both know legal moves and use charged Nova promptly.
This supports technical achievability, not human win-rate/time estimates or final
tuning. The introductory five levels are generous; stars reward efficient play.

Desktop Compatibility renders were inspected for Home, map, level 2, the
three-goal level 5 and actual earned-star victory at phone size. These use local
test saves, not a physical Android pass. Asteroid build 9101 passed the player;
visual build 9601 was installed but has no separate reported human acceptance.
**The new M3 APK requires its own test.**

## Verified delivery checkpoint, 2026-10-29

[PR #29](https://github.com/FoxyLight/Cosmic-Crystals/pull/29) merged as
`e14ef9e959b679346880b3d2adf6d94be145b581`. PR run 97 and
[merged-main run 98](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40973718330)
passed gameplay checks, Web export and Android export. All 13 Godot suites and
five Python tests pass; actual exported catalog/font-license checks pass.

[Android artifact](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40973718330/artifacts/12941532251):
`cosmic-crystals-v0.4.0-dev.98.1-ge14ef9e9-debug.apk`, embedded versionName
`0.4.0-dev.98.1+ge14ef9e9`, versionCode **9801**. Downloaded APK manifest/hash
match build-info; SHA-256 is
`061f22a3107d1a67cb0d5aa24b35a53db9a9d8670e7eb36498b2b4f28b97e706`.
Wireless ADB installation succeeded and both installed versions were read back.
The previously approved disposable pre-campaign build 9601 was replaced after
ephemeral-CI signature mismatch. Preserve newly earned M3 records before any
future uninstall; persistent debug signing support remains available.

The served PR-run-97 Web export was played at 376x746 in in-app Chromium to a
genuine level-1 victory: 460 match score + 375 move bonus = 835, three stars.
Reload retained 3/15 stars, 1/5 restored and level 2 unlocked. No captured
warning/error console logs. This is a bounded browser runtime/persistence smoke,
not a full browser/device matrix. The main Web artifact is available in run 98.

**Historical delivery status before user feedback:** the campaign had been installed and passed automated tests, but player acceptance was then pending. The 2026-10-29 human acceptance report below supersedes that pending state.

## Player Android acceptance: PASS (2026-10-29)

Following the M3 campaign delivery and the request to play all five levels, test results/level unlocks and close/reopen to verify progress, the player reported **“Human android play test passes.”** This is accepted as the user's overall M3 campaign sign-off. The report does **not** contain per-level screenshots, scores, device/OS specifications or measured hardware performance, and it is not a claim of separately instrumented checks.

The known installed-and-ADB-read-back M3 gameplay build is `0.4.0-dev.98.1+ge14ef9e9` (versionCode **9801**, commit `e14ef9e9`). The newer [main run #100](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/40974920062) differed only in documentation and was not confirmed as newly installed. Full evidence and remaining gates: [M3 Android Playtest Report](ANDROID_M3_PLAYTEST_2026_10_29.md).

The five-level campaign implementation has passed both automated and player sign-off, allowing [M3 #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7) to be completed. This does **not** close M0/M1/M2/M4/M5/M6 release, accessibility, audio, balance or device-performance requirements. **Before another routine build is installed**, protect the new on-device progression against ephemeral CI signing changes (see [Android Versioning](ANDROID_VERSIONING.md)).

## Android acceptance checklist

Record exact versionName/code, source SHA, signing mode, device/Android version.

1. Fresh launch -> Home -> Lyra. Only level 1 is selectable. Goals/moves/cues
   are readable; full board/HUD fit and controls avoid system cutouts.
2. Finish level 1; check score + move bonus, stars, Next/Replay/Map and level 2
   unlock. A worse replay must retain prior best score/stars.
3. Forge/activate the highlighted four-match Beam in level 2. In level 3, crack
   and destroy all required rocks and watch segmented refills.
4. Combine Bomb/Supernova in level 4. In level 5 charge/cancel/target Nova:
   activation costs no move and all three goals must finish.
5. Lose: no new node/star unlock. Retry/return to Map intentionally. Try quick
   touches and Android Back during a cascade; no overlap/reset should occur.
6. Close/reopen after wins and a defeat. Completed nodes, best scores/stars,
   unlocks, seen cues and reduced motion must persist.
7. Finish all five: no final Next, restored map, replayable completed nodes,
   exactly five authored stages.
8. Check blue/green separation, rock/power markers, dialogs, small-screen text
   and reduced motion. Record performance/interruption issues. Browser reload/
   resize needs its own supported-browser acceptance matrix.

The player has now confirmed the requested Android campaign test passes; close #7 with the [M3 playtest evidence](ANDROID_M3_PLAYTEST_2026_10_29.md). Unfinished board resume, audio, full accessibility/performance QA, production AAB/store work and expansion remain outside this M3 delivery.

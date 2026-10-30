# Cosmic Crystals: A Starweaver's Journey

Restore the stars. Awaken the universe.

An Android-first Godot 4.7.2 / GDScript match-3 game with a Web export. Product
base: **0.4.0**. This repository now implements the **five-level Lyra campaign**.
No levels 6-20, extra constellations, monetization, accounts or cloud saving.

## The playable journey

Home -> Lyra map -> Level -> Victory/Defeat -> Next/Replay/Map. Five connected
nodes show locked, next, selected and completed states, with best earned stars.
Each authored level has its own seed, mechanics, goals, moves, tutorial and
three-star thresholds. Complete every goal before moves run out. Wins unlock
the next star; losses never unlock anything. Ranking uses match score plus
**25 per unused move**; a completed level always earns at least one star.

| Level | Name | Moves | Required goals |
| --- | --- | ---: | --- |
| 1 | First Starlight | 18 | Collect 24 crystals |
| 2 | Starweaver's Spark | 22 | Collect 36; forge a Beam |
| 3 | Asteroid Passage | 18 | Collect 40; clear 3 rocks |
| 4 | Cosmic Convergence | 20 | Collect 50; activate 2 powers |
| 5 | Lyra's Awakening | 22 | Collect 60; clear 4 rocks; use Nova |

Tap two neighbors or swipe one cell to match. Four forms a Beam; a T/L forms a
Bomb; five forms a Supernova as each mechanic is introduced. Nova appears in
level 5: charge, tap Nova, then a tile; cancel retains charge and activation
spends no move. Stars/scores, completions, unlocks, tutorial history and reduced
motion are stored locally. Pause offers resume/help/restart/map; unfinished
round discard requires confirmation. Results require an intentional button.

**Save scope:** completed progression/settings persist, not an unfinished board.
A restarted or abandoned round starts from its authored seed. See the full
[schema, recovery policy and Android checklist](docs/M3_LYRA_CAMPAIGN.md).

## Latest Android gameplay acceptance

**M3 human playtest: PASS (2026-10-29).** After the five-level campaign/playback/persistence acceptance request, the player reported a successful Android playtest. This, along with the full CI suite, supports completing M3's five-level player-journey gate. See the [M3 Android Playtest Report](docs/ANDROID_M3_PLAYTEST_2026_10_29.md). The known installed campaign build is `0.4.0-dev.98.1+ge14ef9e9` (code 9801); newer documentation-only CI exports are not claimed as independently installed.

**Protect saved progress:** Android debug APKs currently use disposable CI signing keys unless a private persistent debug key is configured. Reinstalling a differently signed APK may delete earned local saves. [Versioning and signing guidance](docs/ANDROID_VERSIONING.md).

M0 platform sign-off, M1 extended stability, M2 balance, M4 audio/accessibility, and M5/M6 distribution work remain open.

## Evidence and acceptance

All ten pre-existing Godot suites are retained. Three new suites cover sessions,
120 deterministic balance runs, save recovery and an actual touch-driven
five-level scene journey with disk reload. Five Python version-policy tests
cover unique CI versions, manifest verification and local-default drift.
CI also checks that actual APK/Web packs contain the level catalog/licenses.
Use the PR and merged-main Actions run for final artifact evidence.

The player accepted **asteroid build 9101** on Android. Campaign build **9801** was installed/read back, and the player now reports the requested **M3 Android playtest PASSES**. The automated suites remain green. This is not measured FPS, full browser matrix, sound/accessibility acceptance or signed AAB validation. See [M3 report](docs/ANDROID_M3_PLAYTEST_2026_10_29.md) and [issue #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7).

## Run and build

Open `project.godot` in **Godot 4.7.2 standard**, Compatibility renderer, and F5.
Import once before running scene tests because fonts/SVGs require imports:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_campaign.gd
godot --headless --path . --script res://tests/test_progress_store.gd
godot --headless --path . --script res://tests/test_campaign_scene.gd
python3 -m unittest discover -s tests -p test_android_version.py -v
```

The workflow runs **all 13 Godot suites** through the strict error-log guard,
then produces versioned Android debug APK and Web artifacts. [APK versioning](docs/ANDROID_VERSIONING.md)
explains metadata, checksum, manifest checks and signing identity. Local editor
defaults are `0.4.0-local` / code 2, **not a distributable versioned build**.
CI stamps the unique code/name. Never commit keys/credentials.

F9 opens desktop effects diagnostics. UI controls support mouse/touch and
keyboard focus; puzzle play uses pointer gestures. Reduced motion is a persistent
Home setting. Audio/full settings remain M4 work.

## Documentation

- [M3 Lyra campaign and acceptance checklist](docs/M3_LYRA_CAMPAIGN.md)
- [Game design](docs/GAME_DESIGN.md), [architecture](docs/TECHNICAL_ARCHITECTURE.md)
- [Status](docs/PROJECT_STATUS.md), [roadmap](docs/ROADMAP.md), [milestones](docs/MILESTONES.md)
- [QA plan](docs/QA_TEST_PLAN.md), [Android versioning](docs/ANDROID_VERSIONING.md)
- [Powers/Nova](docs/M2_SPECIALS_NOVA.md), [asteroids](docs/M2_ASTEROIDS.md)
- [Visual pass](docs/VISUAL_PASS.md), [palette](docs/VISUAL_PALETTE.md), [contributing](CONTRIBUTING.md)

The separately hosted web concept has its own earlier source/progress and
advertises 20 levels. It is not this Godot campaign and is not updated by this PR.

# M4 Android Production Polish

2026-10-30, product **0.5.0**. Android is the sole supported target. M3's
five-level campaign is human-accepted and #7 is closed. **M4 #8 remains open
until the player accepts the new audio/accessibility build.** No Web artifact,
browser test, desktop distribution, iOS work, new constellation, monetization,
cloud/account system or Play publication is included.

## Audio and provenance

`scripts/game_audio.gd` owns cached streams, six SFX voices, two music voices,
0.8-second crossfades, 70ms per-cue suppression and drop-on-full layering.
No asset loads or extra player nodes are allocated during a cascade. A cue for
each kind of activated power is deduplicated per wave. Effects use conservative
gain; identical music context updates preserve playback position. Music is a
quiet original suspended/pentatonic pad and eight-note motif, not external music.

All 22 mono 22.05kHz PCM WAV assets were generated specifically for this game
by `scripts/ci/generate_audio.py`. No third-party samples/compositions. Source,
assets and usage terms are in `assets/audio/PROVENANCE.txt`. Font SIL OFL terms
remain separate. Re-run the Python generator to reproduce the assets.

| Assets | Trigger |
| --- | --- |
| select, swap, invalid | Selection, animated swap, rollback |
| match, cascade | First and subsequent clear waves |
| beam, bomb, supernova | Immutable clear snapshot's actual power markers |
| nova | Accepted targeted Nova activation |
| rock_hit, rock_break | Actual asteroid impact/destruction event |
| victory, defeat, star, unlock | Stable committed result, earned award, new node |
| menu, confirm | Menu buttons and confirmations |
| music_home, music_map, music_game, music_win, music_lose | Distinct 16-second looping contexts |

Headless tests use silent bounded dispatch rather than an audio device. Native
development rendering loaded/decoded the actual audio resources. Perceived
mix quality, speaker/headphone volume and hardware audio interruptions require
the new phone test; passing tests is not a listening-quality claim.

## Settings and progress

Home Settings and Pause → Sound & comfort open a blocking native sheet:
master, music and effects sliders; mute; reduced motion; larger reading text.
All interactive rows/buttons are at least 48 logical viewport units high.
Settings use the existing safe rectangle. Values have percentage labels;
sliders are keyboard-focusable for development/device input alternatives.

Schema remains **1**, with additive validated preferences. Old M3 records
default to master .8, music .45, effects .7, mute false, larger text false,
and retain their reduced-motion value. Volumes clamp 0–1; malformed values
default without rejecting valid earned progress. Save verification, prior
valid backup, future-schema read-only protection and best-record maxima remain.
No active round is saved. Do not confuse round restart with earned-record loss.

Application pause and focus loss independently suspend music and reject new
effects. Current gestures are discarded, earned preferences/progress are flushed,
and gameplay returns to intentional pause. A resolving turn waits while
backgrounded then completes and pauses; focus-in cannot override a still-paused
application. No backlog of missed sounds is replayed. Real phone call/media
audio-focus handling remains a hardware acceptance item.

## Visual, motion and touch improvements

Keep six distinct colors AND silhouettes, persistent power glyphs, asteroid
cracks/pips, named goals/numeric counters and score/move text. Sound is optional.
Power clear events add short bounded Beam lines, Bomb rings, Supernova rays and
a Nova cross, with at most eight power overlays per wave. No gameplay footprint
or score rule changed. Existing eased swap/fall/rollback and blocker segments
remain. Result stars reveal in sequence with award cues; campaign screens use
a restrained fade. Pause now offers settings while keeping confirmations and
Back/transition locks. Goals remain separate from decorative colors.

Reduced motion removes twinkle, screen flashes, expanding power/forge/rock
effects, rock shake/shards, slow fades and delayed star reveals. Animated event
duration is .01s while the entire immutable event chain/commit boundary remains.
Scores, goals and seeded outcomes are identical. Larger reading text enlarges
feedback, field guide and map descriptions; map preview gains room for wrapping.
Android system font/display scaling still needs actual device testing. This is
not full TalkBack/nonvisual board accessibility. Compact 8x8 board cells cannot
all be 48 units while preserving one-screen play; action controls are tested
separately from cells. No universal physical-dp/low-vision guarantee is claimed.

## Performance and diagnostics

State-keyed view refresh avoids reformatting/repositioning all controls each
frame. Layout is cached by size/safe insets, clear membership once per event.
Only decorative board redraw is capped at 15Hz; active event movement still
updates every rendered frame. Reduced-motion idle drawing stays static. Audio
resources/pools are bounded and reused. No rules engine rewrite.

`performance_monitor.gd` keeps at most 600 frame samples: mean/p95 frame time,
engine FPS, Godot static-memory bytes, engine-time startup marker, last authored
level load, turns and per-event counts. On Android backgrounding the app writes
`user://performance-last.json`, including screen/level, reduced motion and dropped
audio count. Retrieve privately with debug ADB `run-as ... cat
files/performance-last.json`. Static memory is not Android total PSS/RAM;
startup is engine elapsed time, not external tap-to-visible measurement.

`tests/benchmark_android.gd` reproducibly loads all five stages four times and
settles legal actions. One local **Windows/headless CPU** observation:
20 loads, 132 turns, 500 events, 152.792ms total; median load .802ms, max 1.541ms,
25,527,442 Godot static-memory bytes. This is neither a threshold nor Android
FPS/memory/thermal evidence. CI logs its own environment/result. Actual phone
FPS/p95, loading, PSS, long-session thermals and audio-under-load remain pending.

## Signing and installation safety

The authorized owner session configured `COSMIC_DEBUG_KEYSTORE_BASE64` and
`COSMIC_DEBUG_CERT_SHA256` privately. Main exports must pass `apksigner` and
the pin; actual `build-info.json` records the result. PRs use isolated temporary
keys and never receive the private key. The private local backup is outside Git
with owner/SYSTEM ACLs. No keystore/password is committed. Back it up encrypted
offline and reuse it; losing every private copy loses update compatibility.
See [maintenance/setup/recovery](ANDROID_VERSIONING.md).

Public debug certificate pin:
`bb524f7e0b31b29118043206b481505d940cf0ea635f0fc68b978e88fe1a62b2`.
Debug signing is distinct from a future Google Play upload/production identity.

CI exports a second, incremented probe APK using the same key, installs the
first on a disposable x86_64 Android emulator, injects a valid schema-1 earned
save, updates in place and checks exact bytes. The probe APK is never uploaded;
the delivered APK has its unique run-based version. This proves same-key update
mechanics only. It does not make old ephemeral-key build 9801 compatible.

**No real-phone uninstall, data clearing, migration or new M4 installation has
been performed.** At audit the phone was disconnected. Later the Pixel 7a reconnected but Android reported the expected package absent, so the read-only backup could not be captured. No backup is claimed. Keep the existing game.
The read-only backup helper refuses overwrite and validates before saving exact
bytes/checksum. After a validated backup, a one-time replacement/restore needs
separate explicit approval. If backing up fails, stop. [Safe procedure](ANDROID_EXPORT.md).

## Automated gate and delivery record

All 13 existing Godot suites retained; the five-level touch scene also covers
the new visible Home control. New M4 suite: 166 checks covering additive saves,
all streams, settings persistence, mute/independent interruption ordering,
crossfade/no restart, bounded concurrency, event dispatch, repeated navigation,
real Beam audio dispatch, safe controls and unchanged reduced-motion rules.
Nine Python tests cover versioning, actual preset selection, certificate
parsing, original PCM validation and Android-only configuration. All pass locally.
Strict parser/runtime-log guards remain mandatory. CI additionally validates
actual APK audio/catalog/font packaging, manifest, checksum, certificate and
same-key emulator upgrade; see the PR/main run and exact metadata linked in #8.

Native development renders of the compact 320x568 and 376x746 settings sheet
were inspected. This is Android UI development evidence, not desktop product
support or a new human Android pass. The acceptance artifact/version/checksum
and final CI evidence are recorded in [issue #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8).

## Android human playtest

First resolve signing compatibility safely; never uninstall merely to start
this checklist. Record exact build, cert, device/OS and settings.

1. Home/map/five levels/results: navigation, stars, unlocks and readable goals.
2. Listen to all cue families and music contexts; test loud/quiet/muted levels,
   heavy chains and transitions without unnecessary music restart.
3. Change all audio/comfort settings, close/reopen, retain settings AND prior
   earned best scores/stars/unlocks. Replay worse and lose without losing records.
4. Pause/Back/confirm/cancel, rapid taps/swipes, Nova targeting, background,
   lock, incoming call/media interruption and resume without surprise audio.
5. Reduced motion and larger text; small phone/tablet, cutouts/navigation,
   brightness and Android display/font scaling. Muted play remains clear.
6. Continuous normal/reduced sessions and repeated level changes with heavy
   effects/audio. Record actual FPS/p95, RAM/PSS, startup/load and thermals.

Keep M4 open until the player confirms this new build. Production AAB/store
signing, full screen-reader support, additional devices and extended balancing
are not automatically completed by an APK export or emulator result.

> **Historical milestone/build evidence.** For current source, accepted 0.5.3 build 12901, closed M3/M4/settings gates and active M5, see [PROJECT_STATUS](PROJECT_STATUS.md) and [M5 audit](M5_ANDROID_RC_QA.md). Status/next-step statements inside this earlier report apply to its recorded checkpoint.

# M4 Android Production Polish

2026-10-30, recorded product **0.5.1** (original M4 audio/polish slice 0.5.0; subsequent Beam-direction correction 0.5.1). Android is the sole supported target. M3's
five-level campaign is human-accepted and #7 is closed. **M4 #8 subsequently received a player-reported Android playtest PASS on 2026-10-30.** No Web artifact,
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
`COSMIC_DEBUG_CERT_SHA256` privately, plus a generated private
`COSMIC_DEBUG_KEYSTORE_PASSWORD` secret. Password protection retains the
exact certificate and private-key identity. No private password is committed. Main exports must pass `apksigner` and
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

**No real-phone uninstall, data clearing or migration was performed by M4.**
The phone was disconnected at audit, then the connected Pixel 7a reported the
expected package absent; the read-only backup attempt failed before a save
backup could be created. The owner confirmed **“I uninstalled the previous
version.”** No old-save recovery is claimed. After main verification, M4 build
10601 was installed fresh and its version read back. Future stable-key updates
must use `install -r`, preserving any newly earned data. The read-only backup
helper rejects unreadable data and never overwrites existing backups. A different
old-key installation elsewhere still requires the separately approved safe
procedure in [Android export](ANDROID_EXPORT.md).

### Verified main-106 checkpoint

[PR #32](https://github.com/FoxyLight/Cosmic-Crystals/pull/32) merged as
`8a0aa6fe04efb776f73653756e5bf35526edb20f` after both checks passed.
[Main run 106](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41069911792)
passed both Android-only jobs, including all regression suites, actual APK
signature/pin/manifest/asset checks and an emulator save retained byte for byte
through two separately exported same-key versions.

[Checkpoint artifact](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41069911792/artifacts/12984013523):
`cosmic-crystals-v0.5.0-dev.106.1-g8a0aa6fe-debug.apk`, versionName
`0.5.0-dev.106.1+g8a0aa6fe`, versionCode **10601**, signing mode
`persistent-secret`, `stable_signing_verified: true`. APK SHA-256:
`d9a46aede34676582822296f3717f74b0e46f0c54b7a15d06d622a24742ca2e1`.
Downloaded manifest/hash and actual signer pin were independently checked.
Installation and version read-back succeeded. This is not a new human pass or
an Android FPS/audio-quality result. The password-hardening follow-up retains
the exact signer; #8 records its final artifact and compatible update evidence.

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


## Current 0.5.1 delivery and real-phone update (2026-10-30)

[PR #34](https://github.com/FoxyLight/Cosmic-Crystals/pull/34) fixes the newly forged Star Beam's direction: horizontal swap → row Beam; vertical swap → column Beam, including two-tap input and perpendicular completed match lines. Bomb/Supernova priority, existing stored Beam orientation, level restrictions and schema-1 progression are preserved. The new [Beam-direction suite](../tests/test_beam_direction.gd) passed **53 assertions**. The earlier M4 audio/comfort suite still passed **166 assertions**.

[Main CI run #110](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426) for commit `7864c82007bf379de232156323328e887afdcf0c` passed both Android-only jobs, **15 Godot suites**, **nine Python tests**, actual APK manifest, signer pin, catalog/audio assets and checksum, plus an isolated-emulator same-key upgrade/save verification.

- **VersionName:** `0.5.1-dev.110.1+g7864c820`; **versionCode:** `11001`.
- **APK:** `cosmic-crystals-v0.5.1-dev.110.1-g7864c820-debug.apk` ([download through Actions](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41078423426/artifacts/12988237867)).
- **APK SHA-256:** `a2d15f5efe9f26958e8c1ab77ea43e1ff5ac899793bc946cfa62eef37e7a7249`.
- **Signing:** `persistent-secret`, stable-signing verification passed against the pinned certificate.
- **Device evidence:** GitHub [M4 #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8) records a private, validated read-only save backup, a **real-phone compatible in-place 10801 → 11001 update** and **byte-for-byte identical save afterward**, with no uninstall or data clearing. Separately, CI confirmed identical save bytes across a disposable emulator update.

This establishes compatible update mechanics and data retention **for the verified stable-key build**, not any differently signed legacy installation. **At the time of the build #110 checkpoint**, no M4 player acceptance was recorded. The player later reported **M4 playtest PASS on 2026-10-30**; see the report below. Detailed audio measurements, interruptions, system scaling, screen-reader usability and sustained FPS/RAM/thermals remain for M5. Google Play release AAB remains future M6 work.

## Human Android acceptance: PASS (2026-10-30)

The player reports **“M4 playtest passes”** following the M4 Android audio, settings/comfort, visuals and version 0.5.1 Beam-direction delivery. This is **overall human playtest acceptance** of the implemented M4 slice, not item-by-item evidence for every device/performance/accessibility/audio-focus scenario. See the [M4 Android playtest report](ANDROID_M4_PLAYTEST_2026_10_30.md) for exact version traceability and limitations.

The known device-installed/read-back gameplay build was `0.5.1-dev.110.1+g7864c820`, code **11001**, with stable debug signing; later [main #113](https://github.com/FoxyLight/Cosmic-Crystals/actions/runs/41090558472) introduced documentation only and has not been claimed installed for this test. A previously verified same-certificate 10801 → 11001 phone update retained saved progress byte-for-byte. **M4 can be completed at the defined implementation and human-playtest gate**, with unresolved quantitative hardware/audio-focus, system-scaling, full accessibility and multi-device requirements explicitly carried into M5 #9/M0/M1 rather than silently marked passed.

The following detailed test checklist remains useful for deeper **M5 Android release-candidate QA**; the reported overall M4 pass does not establish each listed measurement.

## Post-acceptance Android 0.5.2 settings repair

The player subsequently reported two settings defects: non-movable sound volume sliders and Larger reading text with little visible effect. [PR #38](https://github.com/FoxyLight/Cosmic-Crystals/pull/38) fixes native touch drag and switch handling without global mouse emulation, expands/reverses reading-text sizes, and adds 190-test M4 UI regression coverage. This is a **later patch after the overall M4 human PASS**, not retroactive evidence that the patch was human-tested. [Issue #37](https://github.com/FoxyLight/Cosmic-Crystals/issues/37) remains open for a new Android retest; [instructions](ANDROID_SETTINGS_TOUCH_FIX_2026_10_30.md).

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

The player subsequently confirmed an overall **M4 Android playtest PASS**. Close M4 at the implemented/human-accepted polish scope, but keep **M5 multi-device/quantitative QA**, production AAB/store signing, full screen-reader coverage, and M2 extended balancing open; these are not proven by an APK export, emulator result or unitemized human response.

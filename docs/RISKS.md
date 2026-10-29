# Project Risks and Dependencies

**Snapshot date:** 2026-10-29. Qualitative impact is an initial planning assessment, not a measured probability or financial forecast. Reassess risks at each milestone gate.

| ID | Risk | Impact | Evidence/state | Mitigation | Tracker |
| --- | --- | --- | --- | --- | --- |
| R01 | Android native export or device input behaves differently from headless prototype | High | No verified APK/device run | Test real APK on modest and recent Android phones before production sign-off | [M0 #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4) |
| R02 | Godot web export compatibility, loading size or WebGL2 requirements limit browser reach | High | Export unverified | Host/export early; test desktop/mobile browsers; reconsider Cocos/Phaser if product's browser target changes | [M0 #4](https://github.com/FoxyLight/Cosmic-Crystals/issues/4) |
| R03 | Synchronous turn resolver conflicts with animations or fast gestures | High | Current synchronous board resolution; limited flash feedback | Ordered event log and explicit state machine, deterministic tests | [M1 #3](https://github.com/FoxyLight/Cosmic-Crystals/issues/3) |
| R04 | Specials/blockers cascade into incorrect counts or stuck boards | High | Not implemented | One-event-per-tile bookkeeping, seeded edge-case tests, iteration guards | [M2 #6](https://github.com/FoxyLight/Cosmic-Crystals/issues/6) |
| R05 | Level difficulty fails playtesting or players are forced to reshuffle excessively | Medium | No authored levels/playtest dataset | Playtest 5 levels before expanding, seed capture, tune move budgets and star thresholds | [M3 #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7) |
| R06 | Save corruption or incompatible schema loses progress | High | Saves not implemented | Versioned `user://` format, validation and migration tests | [M3 #7](https://github.com/FoxyLight/Cosmic-Crystals/issues/7) |
| R07 | Particle effects and UI overload modest Android GPUs | High | No device stress measurements | 30-second effect stress, capped particles, pooling and reduced-motion fallback | [M4 #8](https://github.com/FoxyLight/Cosmic-Crystals/issues/8), [M5 #9](https://github.com/FoxyLight/Cosmic-Crystals/issues/9) |
| R08 | Play requirements, privacy declarations, signing or SDK conflicts delay release | High | Store submission not started | Verify current Play rules near submission; isolate secrets; test AAB in closed/internal track | [M6 #10](https://github.com/FoxyLight/Cosmic-Crystals/issues/10) |
| R09 | Scope expands before core gameplay is proven | High | 20-level vision exceeds 5-level MVP | Require M3/M5 exit gates before committing expanded content | [M7 #11](https://github.com/FoxyLight/Cosmic-Crystals/issues/11) |
| R10 | External published concept and GitHub source drift apart | Medium | Published page is separate from repository | Treat GitHub as source of truth; mark published site as reference and avoid importing unknown code without review | [Milestones](MILESTONES.md) |

## External dependencies

- Godot 4.7.2 editor and matching export templates for native/web builds.
- Android SDK, Java environment and accessible Android test devices for M0/M5.
- Secure, privately held release keystore and authorized Play Console access for M6.
- Web hosting with the necessary WebAssembly/WebGL compatibility for browser distribution.
- Licensed/original visual and audio assets for M4/M5.
- iOS signing and macOS/Xcode tooling only if native iOS scope is approved.

## Risk review cadence

At each milestone PR or major design change, verify whether any high-impact risk has new evidence, an owner, a mitigation result or an accepted exception. If a risk blocks a gate, keep the milestone issue open and document the blocker. Assign named owners only when the team agrees.

# Validation — v1.7.1 merged branch

Validated using Godot 4.7.2, Compatibility rendering, Mesa software OpenGL,
and isolated --test-mode saves. This release merges the pet update into the
uploaded v1.6.6 branch rather than replacing that branch with the earlier source.

## Gameplay and UI: 1,549 checks, zero failures

| Suite | Checks |
| --- | ---: |
| Core gameplay, curriculum, tutorial, rewards, Shop | 436 |
| Naming and identity | 23 |
| Save / load / delete slots | 36 |
| Offline name moderation | 190 |
| Feedback, beginner wording, teaching cooldown | 70 |
| Teaching-only colors and syntax formatting | 27 |
| Logic Lab | 115 |
| Snack Jam, including full real-time song | 70 |
| Scrolling game catalog | 46 |
| Ten-theme rendered Shop regression | 351 |
| Merged pet creator, saved looks, Ball Play, migration | 185 |

The new pet suite uses real pointer input for first-play choice, species buttons,
Apply/Cancel, saved-look controls, home/Shop/Settings entry points and Ball Play.
It verifies feature/color preview, draft isolation, owned-only outfit restore,
room-set preservation, the three activity actors, Space with a focused button,
focus pause/resume, exactly one return reward, interrupted throws, the full
Knowledge quote, old/new JSON slots, Reset, and branch balance constants.
Creator and preset text fit at 1280x800 and 960x600. Native captures were inspected.

## Source and art preservation

All 229 existing files under assets (excluding regenerated import sidecars)
were preserved byte for byte; only the new ball assets were added there.
The Shop catalog, room renderer, teaching formatter, shared learning-label/UI
code, Web shell and export builder match the uploaded branch byte for byte.
All sixty purchase IDs, prices, themes and slots are retained.

Five applicable static validators passed: PNG art, cosmetic fit, room-decor
centering, expanded Decor Sets, and current Shop guides.

Three older validators also fail on the untouched uploaded branch. They have
not been used to overwrite the team's current art or delete historical files:

- validate_shop_rebuild.py treats room-set overlays and older retained PNGs as
  unreferenced catalog art. The runtime's current catalog and all room sets
  pass their rendered and dedicated validation suites.
- validate_knight_fit.py expects previous exact opaque bounding boxes. Current
  Knight sprites are unchanged; the current shared fit/guide checks pass.
- validate_shop_wording.py requires version 1.6.5 literally, and therefore also
  rejects the uploaded version 1.6.6. The current release is 1.7.1.

## Browser export and packaging

A fresh single-thread Godot Web export completed successfully. Its exported
PCK passed 12 additional checks when loaded independently of the source project:
release ID, first-play choice, six species, sixty Shop items, creator colors,
saved look, three activity actors, Ball Play reward, save format and name filter.
This is a packed-resource check in the native runtime, not a browser playthrough.

Both ZIPs are checked for complete archive integrity. The source's embedded
builds/CritterCare-itchio.zip matches the standalone browser ZIP byte for byte.
index.html, engine/game companions and all nine license notices are included.
The source ZIP includes matching Web templates, source, PNGs, guides, tools and
tests; it excludes editor caches, local saves, Git metadata and stale Web copies.

## Remaining browser check

An actual hosted itch.io browser playthrough has not been performed for this
merged build. Browser persistence, autoplay/audio, embedding/fullscreen and
mobile input still need the preview checks in ITCH_IO.md. Native and browser
saves remain separate. The existing offline name filter cannot guarantee every
possible bypass; its design and update instructions remain in NAME_FILTER.md.

# Validation — v1.6.3

This release uses the teammate's uploaded consolidated image-based project as its base. It targets **Godot 4.7.2 stable** (`4.7.2.stable.official.ed1daf0bf`), standard GDScript, and Compatibility rendering. One source tree powers native/F5 and the itch.io export.

## Native checks

Rendered Linux tests use an X11 display with software OpenGL. Test mode isolates progress from normal player saves.

| Suite | Passing checks |
| --- | ---: |
| Core gameplay, Shop, tutorial, progression, and persistence | 375 |
| Logic Lab | 115 |
| Highlighting | 20 |
| Snack Jam, including a complete real-time song | 70 |
| Feedback, audience wording, and teaching cooldown | 69 |
| Scrollable game menu | 46 |
| Naming and teaching-only scope | 23 |
| Manual save/load/delete slots | 36 |
| **Total** | **754** |

The new slot suite exercises real pointer clicks at 1280 × 800 and 960 × 600. It checks independent named snapshots, timestamps, overwrite/cancel, load/cancel, delete/cancel, reuse, exact quotes, saved names, inventory, gold, PNG equipment, badges, game records, preferences, current-autosave replacement, reset retention, unreadable files, and failed writes that must leave active progress intact.

Naming checks cover Keep Pip, a custom name, Enter submission, Settings rename, names containing Pip, Unicode and blank names, longest allowed names, save/reload, old-save migration, and reset before the tutorial. Exact earlier Knowledge quotes survive renaming. Screenshots of naming, the tutorial, clean feedback, slot selection, and deletion were inspected; layout checks cover both supported sizes.

Teaching checks confirm ordinary menus, greetings, game rules, controls, quiz questions/choices, and Lab blocks stay plain. Actual lesson speech, Knowledge explanations/code, answer explanations, and educational hints opt into the shared vocabulary highlight. Feedback uses cream/light panels, large bold green/red outcomes, and normal dark explanation text.

Existing regressions cover petting/carrying/landing/feeding; six activity destinations; rewards paid once; curriculum caps and unlocks; tutorial interaction targets; scrolling Shop and games catalog; full measured speech pagination; permanent purchases; care, reset, and migrations. Beginner text remains short and level-specific. Repeated automatic concepts wait 60 seconds; explicit reading and answer feedback remain immediate.

Snack Jam includes its full 52.8-second song test driven by the audio stream clock, with the Dummy audio output driver. This checks timing logic, pause/resume, records, and rewards; audible synchronization on physical audio hardware remains a device preview check.

## Image pipeline and optional importer

- The 192 original non-Markdown asset files in the uploaded base were compared byte-for-byte and are unchanged.
- `validate_png_art.py`: all 39 required runtime PNGs resolve; the designated UI, room, picnic, rhythm, and Lab scripts retain their image-based rendering.
- `validate_shop_rebuild.py`: six original themes, 36 catalog entries, 36 referenced PNGs, no orphan Shop images.
- Cosmetic-fit, room-decor-center, and knight-fit validators pass.
- The optional standard-library importer was checked in an isolated temporary catalog: dry-run leaves files untouched; registration copies identical PNG bytes; duplicate IDs/files and wrong dimensions are rejected; the original catalog backup is retained. Six helper checks passed.

The importer does not resize or generate artwork. New images must follow the existing shared canvas/alignment. The Shop can display extra items in additional rows within their chosen theme.

## Web export and packaging

The project bundles the official matching single-thread Web templates. `tools/export_web.gd` builds the browser files and `builds/CritterCare-itchio.zip` from the current source. The separate versioned browser download is the same ZIP included inside the editable project.

Release packaging checks verify ZIP integrity, `index.html` at the browser ZIP root, nonempty engine/game files, license notices, and source/browser version agreement. The exported PCK is checked independently with headless Godot for version 1.6.3 and the new naming, teaching scope, and save-slot controls. Editor caches, Git metadata, Python caches, temporary files, and the older duplicate `critter_care_web_version/` export are excluded from the source download.

**An actual browser playthrough is not verified for this release.** Native tests and a successful export do not establish browser persistence, audio timing, iframe focus, fullscreen, or mobile behavior. Use [ITCH_IO.md](ITCH_IO.md) to check the intended hosting page, especially saving/loading/deleting and reloading the browser. Native mouse/keyboard and injected touch checks do not replace testing on target touch devices.

## Scope

The retained UI/room/activity/Shop art uses PNG assets. Pip and the tutorial pointer retain their procedural animation/drawing. Room items are decorative and do not add collision; cosmetics do not alter rewards or puzzle difficulty. Lessons and questions are authored content.

Progress and manual slots are local to the device/browser profile. F5 and browser saves are separate. There are no accounts, analytics, cloud sync, or real-money purchases. Native tests ran on Linux; Windows/macOS standalone executables and a hosted itch.io page were not tested. Optional standalone desktop exports need their matching templates.

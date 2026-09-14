# Validation

Updated and tested with **Godot 4.7.2 stable** (`4.7.2.stable.official.ed1daf0bf`), standard GDScript, using the Compatibility renderer on Linux. The deliverables include the editable Godot project and a prebuilt itch.io Web ZIP. A standalone desktop executable and a published game page are not included.

The 4.7.2 rendered integration run completed **89 checks with 0 failures**. The headless run completed **82 checks with 0 failures**; the extra checks in the rendered run exercise real pointer coordinates and window resizing. A separate clean project import succeeded without a pre-existing editor cache. The earlier 4.5.2 release also passed these gameplay checks; this document describes the updated 4.7.2 release.

## What was checked

- A short mouse click on the head pets Pip; a body click does not accidentally pet him.
- A held mouse press picks him up. Pointer movement pulls him upward, emits the position discovery, and release produces a fall that settles on the floor.
- Ear tips and the tail are included in the grab area.
- Menus pause pet interactions; closing a mini game cancels its running loop animation.
- Feeding spends exactly one available treat, raises needs, starts eating, and refuses duplicate feeding during a snack.
- Feeding a full pet and feeding from an empty inventory do not spend treats.
- Repeated petting, two feeding events, completed chewing, and idle grooming trigger their corresponding discoveries.
- Queued but unseen lessons remain locked; displayed lessons unlock once.
- Quiz questions come only from the discovered pool, answers lock after submission, wins pay the calculated reward, and a result cannot pay twice.
- Losing a quiz does not grant a win reward.
- All 10 Berry Detective rule evaluations and its winning reward were exercised.
- Loop Garden was tested with an incorrect repeat count, a corrected count, all three successful gardens, a single completion reward, and early exit.
- Winning builds appetite for the new treats.
- Inventory, Knowledge, and ranked local top-three scores survive save/reload.
- Malformed JSON falls back to fresh defaults without a crash.
- All 12 journal bodies fit above their code examples. Every learning bubble's title and body fit their allocated space.

Screenshots were inspected for the home screen, carried hamster, empty and populated Knowledge book, treat pouch, game selection, quiz, result, Berry Detective, Loop Garden, and settings. The home screen was also inspected at the minimum supported **960 × 600** window size; the design canvas is **1280 × 800**.

## Browser export validation

- The official 4.7.2 editor archive was checked against its published SHA-512 checksum.
- Official matching single-thread Web debug and release templates are bundled; their ZIP integrity was checked.
- The project imports with its export plugin enabled and without script parse errors.
- The editor menu callback was invoked in a clean test copy of the project, including its background worker and completion handler. It successfully exported and packaged the browser ZIP.
- The command-line export wrapper was run against the delivered source, exercising replacement of the previous browser ZIP.
- The browser archive was checked for ZIP integrity, `index.html` at the root, nonempty engine/game files, and included license notices.
- The generated HTML contains resolved Godot placeholders, an automatically starting loader, canvas resizing, and disabled thread support/cross-origin isolation headers.

**Browser gameplay remains unverified in this environment.** The browser environment did not permit a local HTTP server, so no browser playthrough, iframe/fullscreen test, browser audio test, or browser save/reload test was completed. The successful Web export is not a substitute for those runtime checks. Use the short preview checklist in **[ITCH_IO.md](ITCH_IO.md)** on your itch.io page before publishing.

## Practical scope

The hamster uses a custom spring simulation with animated body, ears, and paws. It is a deliberately soft, bounded ragdoll animation rather than a collection of rigid bodies joined by physics joints. Artwork is procedural vector drawing and UI is assembled at runtime. The room's furniture is decorative; the interactive physics area is bounded by the room edges and the floor.

The quiz includes one authored question per discovery, with shuffled question order and answer placement. It is a finite beginner curriculum, not generated content. Progress is local to the current device and Godot user-data directory. There are no external services, analytics, online accounts, or downloaded runtime assets.

Native gameplay was tested on Linux. Windows/macOS executables and hosted Web deployment were not tested. The same standard source project is intended for F5 play in Godot 4.7.2 on those desktop systems. Matching Web templates are included; templates for optional standalone desktop exports must be installed separately.

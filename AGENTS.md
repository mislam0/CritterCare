# CritterCare maintenance

## Current artwork baseline

The user requires front-facing flat 2D accessories, simple colors, no angled
body garments or dimensional top/side planes, and NO SWORDS. The Pixel Knight
side hanging is a star shield. Do not reintroduce weapon artwork. Current
source atlases, garment corrections and prompts are in `tools/shop_art_v1_6_24/`;
`tools/prepare_shop_art.cjs` fits them to the unchanged slot canvases.
See `docs/SHOP_ART.md` and the original TRUE_FIT guides in `docs/shop_guides/`.
Do not rerun historical generators/importers over the current art.
Complete furnished bundles replace the base-furniture layer while equipped;
the unchanged base PNG returns on unequip and remains the fallback for partial
custom bundles. Run the core integration suite and
`tests/verify_shop_art.gd -- --test-mode` for shop work, including real-renderer
captures when changing art. Shared slot geometry, purchase IDs and prices
remain stable.

This repository is one source of truth for both normal Godot/F5 play and the itch.io browser game. The user requires all future game changes to ship in both versions.

After a change, validate the affected game behavior, run the integration suite with `--test-mode` (which isolates test saves), and rebuild `builds/CritterCare-itchio.zip` using `res://tools/export_web.gd` or the existing editor export menu. Package the updated editable project and a separate copy of the generated browser ZIP together. Never distribute an older browser build beside newer source.

Game levels describe how far a beginner-friendly curriculum can progress. All new learners start with First steps; definitions and examples must appear before a new concept is tested. Keep Kindergarten at its original gentle difficulty. Preserve previous achievements when levels change.

Shop purchases are permanent in the local save. Equipping is free, slots enforce appearance conflicts, and Reset progress clears coins, ownership, equipment, and stage badges while preserving level/comfort settings. The Shop is theme-first: 10 sets (Nature, Study, Smart Casual, Halloween, Christmas, Pixel Knight, Easter, Brainrot, Thanksgiving, Bear Spirit), each with three Pet and three Room cards; optional imported items can add rows within a theme. Preserve all 60 stable purchase IDs when changing visible names or PNG files. Pet slots are head/face/neck; Room slots are wall/decor/rug. Keep prices, theme membership, and slots in `data/shop.gd`.

Picnic Catch is an optional bonus activity, not a curriculum badge. Keep its rewards guarded against duplicate completion; unfinished rounds pay nothing. The header shows gold only; the home Shop stays in the bottom bar. Publish download links with a fresh versioned local filename for each release so previous attachments cannot be mistaken for the latest build.

The name-choice screen precedes the first-play tutorial for fresh saves and after Reset progress. Default name is Pip; Settings offers Rename. Use `{pet_name}` / `{PET_NAME}` in authored visible text, never change stable IDs or node paths. Existing captured quotes remain verbatim. Run `tests/verify_identity.gd`. Completion persists; replay is in Settings. Keep arrows aligned with real targets, advance interaction steps from actual events, and allow skipping without purchases or lost progress. Normal needs and queued speech wait while the tour is active.

Logic Lab uses authored block IDs and bounded execution; never evaluate player-entered GDScript. Preserve first-solution-only rewards (25 coins and 2 berries), ordered challenge unlocks, and Game level caps. Practice actions use separate state; leaving an unfinished program pays nothing. Save lab completion and complete spoken walkthroughs, preserve old saves, and clear lab records on Reset progress. Run `tests/verify_lab.gd -- --test-mode` as well as the main integration suite after changes.

Teaching text uses the shared `scripts/teaching_terms.gd` vocabulary and `scripts/learning_text.gd` renderer. Keep dialogue/data and saved quotes plain; assign `words` on teaching labels, never rendered BBCode. All shared controls are plain by default. Opt in with `UI.teach(label)` or `label.teaching = true` only for the pet's teaching, explanations, hints, and Knowledge examples. Menus, ordinary greetings, game rules, quiz questions/choices, instruction blocks, and outcome titles must remain unhighlighted. Code font alone does not enable highlighting. Measure actual rich-text height when paginating; do not split formatting tags or infer fit from character counts. Keep whole-word matching, literal bracket escaping, and passive text children that allow mouse/touch/keyboard actions. Run `tests/verify_highlights.gd -- --test-mode` after teaching UI changes.

Snack Jam is an optional rhythm activity available at every Game level. Keep Chill/Standard/Lively separate from curriculum difficulty, with separate personal bests. Use the audio playback clock for live note timing; pause music and judgement together, auto-pause on focus loss, and consume key releases as well as presses. No lesson interrupts the song. Store the complete post-song explanation in Knowledge. Only a completed current round may pay its rewards once; unfinished/restarted rounds pay nothing. Reset clears rhythm records and retains comfort/timing preferences. The original music source is tools/generate_snack_jam.py; BPM, count-in, duration, and authored chart in data/snack_jam.gd must remain aligned with the audio. Run tests/verify_jam.gd -- --test-mode after rhythm changes, including its full real-time song check.

All Game levels assume zero programming experience. Select wording from the chosen Game level, not the unlocked stage. Kindergarten text is short and playful, with plain-word examples and defined vocabulary. Preserve complete saved quotes and manual reading. Every correct/incorrect attempt needs immediate large bold green/red feedback plus a symbol and label. Use the shared UI helpers with light/cream backgrounds, bold colored outcome words, and ordinary dark explanation text. Never reintroduce black feedback panels. Repeated automatic teaching is deduplicated and limited to once per concept per 60 seconds using monotonic session time; never throttle answer feedback, explicit hints, or manual Knowledge reading. Run tests/verify_feedback.gd with --test-mode after changing these behaviors.

The Games / Quizzes catalog uses data/game_menu.gd for all six cards and level-specific descriptions. Keep titles, how-to-play goals, and rewards complete inside the vertical ScrollContainer. Controls must remain reachable by mouse wheel, scrollbar, and Tab; the tutorial must reveal the actual Picnic Catch button before targeting it. Run tests/verify_game_menu.gd after menu changes.
Art pipeline: in the consolidated v1.6.2 release, UI icons, the base room, Picnic Catch artwork, Snack Jam artwork, the Logic Lab seed jar, and all Shop cosmetics are PNG-backed. Do not reintroduce `_draw()`/`draw_*()` in those systems; replace or add PNG assets and use normal Godot nodes for movement/tint/visibility. Pip and the tutorial pointer remain the intentional procedural-drawing exceptions.

Manual Save / Load lives in Settings. Keep its three slots independent from the current autosave. Confirm replacement, load, and deletion; deletion affects only that slot. Reset clears the current game but retains explicit slots, as explained on screen. Validate and persist a slot before swapping active progress; failures must leave active progress intact. Derive slot paths from the active save path so tests remain isolated. Run `tests/verify_save_slots.gd` with `--test-mode` after persistence changes.

Name moderation: validate original input AND the final displayed form in first play, rename, reset naming, and save-slot titles. Keep button and submission-handler checks, including Enter. Never echo a rejected name in a greeting or validation message. Loaded blocked names become Pip and request renaming without resetting progress; repair their exact old-name references in captured quotes, preserving other quotes. No player-facing disable switch. Keep bounded offline matching, whole-name friendly exceptions, and no network/logging of names. Update `data/moderation/policy.json`, regenerate with `tools/build_name_filter.py`, and run `tests/verify_name_filter.gd`, identity, save-slot, and core regressions. Preserve third-party attribution in both source and Web packages. Do not claim a blacklist guarantees all possible words or bypasses.

Shop art policy: simple original flat fills and outlines, no gradients/shadows or stray bear motifs outside Bear Spirit; Pixel Knight art stays pixelated. The historical asset importer `tools/import_approved_designs.py` and its reference sheets are retained for provenance only; they must not overwrite current artwork. The previous `tools/generate_approved_shop_redesign.py`, Easter/Brainrot, and other historical generators must not overwrite the approved sprites. Preserve the true pixel-art Pixel Knight and current Bear Spirit sprites.

Current fit guides: see `docs/SHOP_FIT_GUIDES.md`, `docs/shop_guides/`, and `tools/validate_shop_guides.py`. New art MUST maintain current shared canvas geometry; do not apply the historical per-item offsets from pre-standardization guides. Re-running historical importers will overwrite the current fitted proportions.


## Decor Set slots
- Decor Sets support optional themed overlays for `window`, `right_plant`, `food_bowl`, and `floor_cushion` in addition to the existing `left_shelf`, `side_hanging`, and `right_surface`.
- Maintain decor-set templates and placement guides under `docs/decor_set_templates/`.
- Save compatibility preserved: existing `room:decor` purchases still equip the full coordinated set.

Pet customization: `data/pet_looks.gd` defines six species, valid feature IDs, and validated RGB colors. `hamster.gd` is now the shared procedural pet renderer/physics rig; preserve Shop PNG anchors. All three activity actors must receive the current pet appearance. The first naming screen offers the creator; Style pet also lives in home, Settings, and Shop. Creator changes are drafts until applied, including the three saved outfit looks. Save format 10 retains version-9 manual slot compatibility. Species changes are free and never reset progression. Only owned pet cosmetics may be restored from a look. Test `tests/verify_pets.gd` after changes.

Ball Play is a relaxed room toy with one active throw, no currency reward, and +2 happiness only after a completed return. Pause on focus loss, resume explicitly, stop on opening menus/Reset, and keep it out of the guided tour. Space is handled before focused buttons so it throws rather than toggling the toy off. Use the PNG ball asset. Teaching waits until the toy is put away, then uses the `ball_play` lesson, full Knowledge quote, level-specific wording, and normal cooldown.

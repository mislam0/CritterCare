# Editing CritterCare text in VS Code

Open the extracted **CritterCare** folder in VS Code. Use Ctrl+Shift+F to search an exact sentence. Open the same folder's `project.godot` in Godot 4.7.2 and press F5 to check your edits.

| What to edit | File and location |
| --- | --- |
| Short Pip dialogue, explanations, quiz questions, choices, and plain-word examples | `data/lesson_language.gd` → `KIDS`, then the lesson ID |
| Extra College explanations | `data/lesson_language.gd` → `COLLEGE` |
| Middle-level questions and worked examples; lesson tags, triggers, code | `data/lessons.gd` → `DATA` |
| How levels combine text | `data/lessons.gd` → `entry()` |
| Game-selection titles, descriptions by Game level, reward notes, and button labels | `data/game_menu.gd` → `CARDS` (description order: Kindergarten, Middle, College) |
| Game instructions and beginner tutorial | `data/game_text.gd` → `COPY` and `TOUR_KIDS` |
| Other menu, reward, Shop, speech, and mini-game messages | `scripts/main.gd` → the named screen/function; `_by_level(kid, middle, college)` selects wording |
| Higher-level tutorial text and arrow targets | `scripts/tutorial.gd` → `STEPS` |
| Sorting rules | `data/curriculum.gd` → `sort_rule()` and `_sort_rule()` |
| Lab goals, hints, instruction names, errors, and walkthrough | `data/logic_lab.gd` → `CHALLENGES`, `BLOCKS`, `present_mission()`, `present_report()`, and runner functions |
| Lab editor messages | `scripts/logic_lab_screen.gd` |
| Rhythm and picnic labels | `scripts/snack_jam.gd`, `scripts/picnic.gd`, and `data/game_text.gd` |
| Highlighted vocabulary | `scripts/teaching_terms.gd` |
| Bright feedback style | `scripts/ui.gd` → `CORRECT`, `INCORRECT`, `feedback_text()`, `show_feedback()`, `outcome_label()` |
| Name prompt and Save / Load menu | `scripts/main.gd` → `open_name_prompt()`, `open_save_slots()`, and their handlers |
| Name tokens and limits | `scripts/pet_name.gd` |
| Manual save slots and persistence | `scripts/save_slots.gd`, `scripts/save_data.gd` |
| PNG Shop importer | `tools/add_shop_item.py`; instructions in `docs/SHOP_IMAGES.md` |
| Automatic popup delay | `scripts/teaching_cooldown.gd` → `DELAY_MS` (60000 milliseconds = 1 minute) |

Each lesson has a stable ID, such as `boolean` or `lab_sequence`. Keep IDs stable so old discoveries and saved quotes continue to work. `bubble` is spoken; `body` explains; `code` shows an example; `question`, `choices`, `answer`, and `why` define a quiz. Answer indexes start at zero. Beginner questions currently put the correct answer first in the source; the game shuffles the choices when displaying them.

Write plain strings, without BBCode. Use `\n` inside a string to start a new thought or line. The shared renderer highlights vocabulary only on controls explicitly marked as teaching (`UI.teach(label)` or `label.teaching = true`). Keep quiz questions/choices, rules, blocks, menus, and ordinary greetings plain. Young learners' speech is split at those thought boundaries; Knowledge keeps complete text. Longer explanations can scroll.

Treat every player as a new programmer. Introduce terms before testing them. Kindergarten bubbles should stay under 40 words and explanations under 70, using several tiny thoughts. Higher levels add worked examples and define their added vocabulary. Do not change puzzle solutions just to shorten instructions.

The automatic cooldown uses elapsed session time, including time in menus. Each concept has its own timer; repeated events do not stack duplicate bubbles. Explicit reading, hints, tutorial steps, and attempt feedback bypass the popup delay. Existing captured quotes stay verbatim until that lesson is presented again.

For catalog text or layout changes, also run `tests/verify_game_menu.gd`. Run `tests/verify_feedback.gd` and the affected existing suites with `--test-mode`. Then choose **Project → Tools → Export CritterCare for itch.io**. Upload the newly rebuilt ZIP in `builds/`; editing the source does not update an older itch.io upload by itself.

Use `{pet_name}` for the chosen name and `{PET_NAME}` for uppercase headings inside new authored strings. Do not replace the node name `$Pip`, resource paths, or stable data IDs. Saved Knowledge quotes remain verbatim after a rename.

See [SAVE_LOAD.md](SAVE_LOAD.md) for save-slot behavior. Run `tests/verify_identity.gd` and `tests/verify_save_slots.gd` with `--test-mode` after changing names or persistence.

Name moderation wording is in `scripts/main.gd` → `_refresh_name_preview()` and `_refresh_slot_name()`. Edit the actual policy in `data/moderation/policy.json` and regenerate it as described in [NAME_FILTER.md](NAME_FILTER.md). Do not use the name filter on teaching content.

## Pet creator and Ball Play

- `data/pet_looks.gd`: pet names, feature labels, palettes, and species defaults.
- `scripts/pet_creator.gd`: creator buttons, saved-look notices, and labels.
- `scripts/main.gd`: first-play choice, home buttons, Ball Play status messages.
- `data/lessons.gd` and `data/lesson_language.gd`: `ball_play` lessons and quiz.

Keep all saved text plain. Teaching-only colors remain in the shared renderer;
normal creator/Shop controls stay plain. Rebuild the Web export after editing.

# Editing dialogue and highlighted terms

Open the whole extracted `CritterCare` folder in VS Code. Continue writing dialogue as ordinary GDScript strings; you do not need to add color tags.

| What to edit | File |
| --- | --- |
| Pip's lesson bubbles, explanations, code, quiz questions and answers | `data/lessons.gd` |
| Stage descriptions and sorting rules | `data/curriculum.gd` |
| Logic Lab challenges, block titles, hints, and execution explanations | `data/logic_lab.gd` |
| Live Logic Lab editor messages and controls | `scripts/logic_lab_screen.gd` |
| Green-arrow tutorial text | `scripts/tutorial.gd`, in `STEPS` |
| General menus, care messages, game feedback and results | `scripts/main.gd` |
| Picnic Catch's live feedback | `scripts/picnic.gd` |
| Shop names, descriptions and prices | `data/shop.gd` |
| Which terms are highlighted, and highlight colors | `scripts/teaching_terms.gd` |
| Shared rich-text rendering and sizing | `scripts/learning_text.gd` and `scripts/ui.gd` |

## Vocabulary and appearance

`CONCEPTS` contains case-insensitive, whole-word regular-expression alternatives separated by `|`. For example, `variables?` matches both `variable` and `variables`. `EXPLICIT` contains uppercase words such as AND/OR/NOT; ordinary lowercase conjunctions in prose stay plain. `CODE_WORDS` also highlights lowercase GDScript keywords inside code examples.

The palette uses `PAPER` for the soft yellow background and `INK` for the dark text. Terms also use the bundled ExtraBold font, so emphasis does not depend on color alone. Monospaced code keeps its fixed-width font and gains the same background and ink. Formatting is applied uniformly to every quiz choice; it never consults the answer key.

The formatter escapes literal square brackets before adding its own markup. Keep examples such as `[1, 3, 2]`, `steps[index]`, indentation, and line breaks exactly as you want players to read them. Quotes saved in progress stay plain; old saves receive the highlighting when displayed.

## Adding a new teaching control

Use `UI.label` for a short fixed area, `UI.paragraph` inside a container, or `UI.scroll_text` for a longer explanation. Set the returned control's **`words`** property to change its message. Use `UI.code` for an example, or `UI.use_code_font` on an existing paragraph. `UI.teaching_button` puts passive highlighted text inside a normal keyboard/mouse/touch button.

Do not assign preformatted BBCode to dialogue fields or saved quotes. The renderer builds presentation markup separately. Speech pagination uses the rendered content height, including emphasized text, and keeps exact plain source slices for Next/Back.

## Check and rebuild both versions

From the project directory:

```sh
godot --headless --editor --import --quit --path .
godot --headless --path . --script res://tests/verify.gd -- --test-mode
godot --headless --path . --script res://tests/verify_lab.gd -- --test-mode
godot --headless --path . --script res://tests/verify_highlights.gd -- --test-mode
godot --headless --path . --script res://tools/export_web.gd
```

Use Godot 4.7.2 for the bundled export templates. For a visual check, run the tests without `--headless` on a computer with a display. F5 always uses the current source; update itch.io by uploading the newly rebuilt `builds/CritterCare-itchio.zip`.

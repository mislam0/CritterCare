# Teaching-only vocabulary highlights

Keep dialogue as ordinary GDScript strings. The shared renderer escapes literal brackets and adds category text colors without backgrounds or added bold only to teaching controls.

## Where highlighting belongs

| Highlight | Keep plain |
| --- | --- |
| The pet's programming lesson bubbles | Ordinary greetings and menus |
| Knowledge quotes, explanations, and code examples | Quiz questions and answer choices |
| Guided lesson introductions | Game rules, controls, scores, and rewards |
| Explanations of a submitted answer | Correct/Incorrect outcome headings |
| Logic Lab educational hints and execution explanations | Logic Lab instruction blocks |
| Teaching steps in the tutorial | Navigation-only tutorial instructions |
| The post-song programming explanation | Live rhythm judgements |

The default for `UI.label`, `UI.paragraph`, `UI.scroll_text`, `UI.code`, and `UI.teaching_button` is **plain text**. Opt in on an actual teaching explanation:

```gdscript
var explanation = UI.paragraph(parent, "IF {pet_name} is hungry THEN feed him.")
UI.teach(explanation)
# Equivalent: explanation.teaching = true
```

Set the control's `words` property to update its content. `UI.code` / `UI.use_code_font` choose a monospaced font; they do not opt into highlights by themselves. `UI.show_feedback` marks the answer explanation as the pet's teaching, while keeping its outcome heading plain and brightly colored.

For home speech, `_say()` highlights only when a lesson key or its explicit `teaching` argument is provided. Do not mark an ordinary message as teaching just because it contains IF or another term.

## Vocabulary and rendering

- `scripts/teaching_terms.gd`: the internal `VOCABULARY` word bank, category colors, and code syntax formatter. `EXPLICIT_WORDS` recognizes uppercase logic/rule words while everyday lowercase conjunctions stay plain in prose. Code is colored by syntax role; strings and comments are kept intact. The word bank is not a player-facing screen. See [TEXT_COLORS.md](TEXT_COLORS.md) for the palette.
- `scripts/learning_text.gd`: plain source, optional rendering, name expansion, and measured sizing.
- `scripts/ui.gd`: shared controls, clean answer feedback, and a bundled `Code.ttf` fallback for the Nunito fonts so arrows and outcome symbols work without system fonts in Web exports.
- `data/lesson_language.gd`, `data/lessons.gd`: level-specific lesson text. See [EDITING_TEXT.md](EDITING_TEXT.md) for other sources.

Do not store BBCode in dialogue or saves. Literal brackets, code indentation, and line breaks must survive. Speech pagination measures rich-text height and preserves every plain character. Knowledge retains the complete quote.

Use `{pet_name}` / `{PET_NAME}` in authored messages. Those tokens expand once to the chosen display name. Existing saved quotes retain their original wording when the pet is renamed.

## Check and ship

Use Godot 4.7.2. Run `tests/verify_highlights.gd`, `tests/verify_identity.gd`, and the affected game suites with `--test-mode`. Visually check a teaching bubble, Knowledge, a quiz question, all answer choices, game controls, and both answer outcomes. Then rebuild `builds/CritterCare-itchio.zip` using **Project → Tools → Export CritterCare for itch.io** so F5 and Web match.

# Teaching text colors

Version 1.6.6 uses colored text only. The formatter adds no backgrounds or bold.
Only teaching labels opt in: pet lessons, explanations, hints, teaching feedback,
and saved Knowledge examples. Ordinary menus and quiz questions/choices stay plain.
Existing large correct/incorrect outcome titles keep their green/red styling.

## Vocabulary categories

| Category | Color | Vocabulary (includes supported plural forms) |
| --- | --- | --- |
| Control flow and repetition | #7040A0 | IF, THEN, ELSE, ELIF, FOR, EACH, WHILE, loop, nested loop, repeat, repeated, repeating |
| Logic and comparisons | #2459A6 | boolean, bool, true, false, condition, conditional, AND, OR, NOT, comparison, operator, logical operator, boolean logic, grouped checks, grouping |
| Variables and collections | #176B63 | variable, accumulator, running total, list, array, index, indexes, indices, indexing |
| Functions | #963C78 | function, parameter, argument, DEFINE, definition, CALL, RETURN, return value |
| Program structure | #92501C | program, programming, instruction, sequence, sequencing |
| Events and timing | #806115 | input, output, event, signal, timer |
| Movement and quantities | #4D5797 | vector, velocity, gravity, step size |
| Limits and boundaries | #52652E | boundary, boundaries, boundary check, limit, clamp, clamping |
| Debugging | #5E5968 | debug, debugging, bug |
| Comparisons in prose | #53616B | <, >, <=, >=, ==, != |

Whole words and complete phrases receive one category color. Everyday lowercase
and/or/not/for/in remain plain in prose. Stored quotes remain exact plain text.

## Code syntax colors

| Syntax role | Color |
| --- | --- |
| Keywords (including uppercase starter rule keywords) | #7040A0 |
| Variables, members, parameters | #2459A6 |
| Function definitions and calls | #92501C |
| Built-in types and constructors | #176B63 |
| Strings | #326B38 |
| Numbers, boolean values, null and numeric constants | #2459A6 |
| Comments | #657065 |
| Operators and punctuation | #53616B |

Code coloring is a small lexical formatter for the game's authored examples,
not a compiler or a language server. Strings and comments are colored as complete
tokens, protecting words inside them. Literal brackets and authored markup are
escaped; indentation, line breaks and saved dialogue are preserved.

The source of truth is the internal VOCABULARY dictionary in
scripts/teaching_terms.gd. This word bank is a developer configuration, not a
player-facing glossary or legend. Players see the resulting text colors in
the existing lessons. Red is reserved for incorrect outcome feedback.

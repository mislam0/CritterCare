# Friendly names — v1.6.4

Pet names are checked before first-play confirmation, Settings rename, and the
name choice after Reset. Save-slot titles use the same check. It runs entirely
offline in both the Godot/F5 project and the itch.io build; names are not sent to
a service or recorded in moderation logs.

## What players see

For a rejected entry, the preview says **Let's pick a different friendly name.**
in red, and **Use this name** is disabled. Enter and the save handler also check
the input. The blocked text is never repeated in the greeting or applied to the
pet; it remains editable in the input field. **Keep Pip** remains available.
An accepted new entry restores the preview and button immediately.

The previous 12-character pet-name limit, Unicode letters, numbers, spaces,
apostrophes, and hyphens remain. Unsupported symbols, control characters,
zero-width formatting, and variation-selector tricks are rejected. A blank
entry still chooses Pip. Save-slot titles keep their 24-character limit.

## Checks

- 3,246 compiled entries from the LDNOOBW 28 language lists, the
  better_profanity English word list, and project additions.
- Case, compatibility characters, accents/combining marks, and selected Unicode
  look-alikes share a matching form; the displayed friendly name is preserved.
- Number-to-letter substitutions include ambiguous alternatives such as 1 for
  either i or l. Trie matching avoids generating exponentially many strings.
- Joined spacing/hyphens/apostrophes, repeated letters, reversed forms, common
  phonetic variants, selected one-edit misspellings, and combinations of
  blacklisted words are checked. Decorative x/number padding is checked too.
- Severe roots are matched inside longer names. Short ambiguous terms use
  whole-word/whole-combination checks where appropriate.
- A reviewed list of exact, whole friendly names prevents common false
  positives such as Cassie, Buttercup, and Penelope. It does not permit those
  names as prefixes or suffixes attached to a blocked term.

The input check and stored/displayed form are both checked. Filtering applies
to user-created names, not ordinary game instructions or teaching content.

## Existing progress

A blocked name in an older automatic save or loaded manual slot becomes Pip,
and the player gets a new name choice. Inventory, gold, purchases, equipment,
lessons, records, and tutorial completion are retained. References to that
blocked old name in its recorded teaching quotes are replaced with Pip; other
quotes stay verbatim. An old blocked slot title displays as My story.

Deleting and replacing slots still require the existing confirmations. An
invalid new slot title is rejected without overwriting the previous saved story.

## Maintaining the list

| Edit | File |
| --- | --- |
| Add blocked terms, severe roots, or exact friendly-name exceptions | `data/moderation/policy.json` |
| Vendored source lists and Unicode mapping | `data/moderation/source/` |
| Source URLs and pinned revisions | `data/moderation/sources.json` |
| Offline compiler | `tools/build_name_filter.py` |
| Generated runtime data; do not hand-edit | `data/moderation/lexicon.gd` |
| Matching behavior | `scripts/name_filter.gd` |
| Pet name limits, normalization, quote repair | `scripts/pet_name.gd` |
| Name and slot feedback screens | `scripts/main.gd` |
| Regression fixtures | `tests/verify_name_filter.gd` |
| Licenses and attribution | `third_party/name_filter/` |

After editing policy or updating the retained source lists, run:

```sh
python tools/build_name_filter.py
godot --headless --editor --import --quit --path .
godot --headless --path . --script res://tests/verify_name_filter.gd -- --test-mode
```

Use Godot 4.7.2. Also run the core, identity, and save-slot suites, then rebuild
through **Project → Tools → Export CritterCare for itch.io**. The compiler needs
only Python's standard library and makes no network requests. Commit both the
policy/source changes and regenerated lexicon/manifest together. License notices
must accompany source and browser releases.

## Practical limits

No blacklist can guarantee detection of every language, new slang, arbitrary
misspelling, hidden meaning, or future bypass. Coverage differs between the
source languages. This deliberately strict filter can also reject an innocent
name; keep Pip or choose another, and add reviewed exceptions when appropriate.
If absolute control over all available names becomes a requirement, use a
fixed, reviewed selection of names instead of free-text entry.

This is a local game feature, not protection against someone modifying the
game's source or runtime. The included browser package uses the same rules,
but testing in an actual hosted browser remains a separate release check.

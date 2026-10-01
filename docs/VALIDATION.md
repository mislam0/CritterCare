# Validation

Release **1.5.0 · Pip’s Snack Jam** uses **Godot 4.7.2 stable** (`4.7.2.stable.official.ed1daf0bf`), standard GDScript, and the Compatibility renderer. The editable project and itch.io build share one source tree.

## Current checks

The Linux integration suite passed **333 rendered checks**, Logic Lab passed **115**, term highlighting passed **20**, and Snack Jam passed **70**: **538 rendered checks, zero failures**. The main suite also passed **320 headless checks**. Rhythm testing includes a whole 52.8-second run driven by the actual audio stream rather than a forced clock; audio output used Godot’s Dummy driver in the test environment. These runs include actual mouse input, dragging, gameplay, rewards, save/reload, reset, tutorial behavior, every lesson's speech pagination, and layouts at 1280 × 800 and 960 × 600. Speech pagination now measures the rich text's actual shaped height, including bold term widths, before choosing each exact source slice.

## Snack Jam

- The exact bundled song length matches the chart’s 52.8 seconds. Chill, Standard, and Lively contain 40, 80, and 120 ordered notes, with no chords and progressively tighter windows. Full perfect and all-missed rounds finish correctly for each mode.
- Boundary timing, late misses, wrong lanes, duplicate hits, extra taps, count-in practice, and clock jitter are checked against expected results. Completed scores cannot be modified.
- The real Games button opens setup directly, without a lesson interruption. Rhythm settings stay independent of all three Game levels, and the timing offset clamps and persists.
- Actual A/S/D key events, pointer clicks, and screen touches catch the correct notes. Repeated key echoes do not create hits; one touch does not generate a duplicate hit.
- Pause freezes the active music stream, judgement, score, and chart. Resume keeps the same note position and releases audio only after its three-beat lead-in. Focus loss pauses the round. Leaving and restarting stop playback without paying unfinished rewards.
- A perfect Chill performance pays exactly 40 gold, 2 berries, and 1 seed; an untouched completed chart pays 20 gold only. Thresholds at 70% and 90% are checked. Early and duplicate finish callbacks cannot pay. Rhythm play grants no curriculum badges.
- Personal bests are independent by mode and cannot regress. Full result dialogue, records, and round counts survive save/reload. Version-7 saves retain older achievements and receive default rhythm preferences. Reset clears records and restarts the tutorial while keeping timing/mode preferences.
- The dancing Pip wears equipped accessories. Gentler movement suppresses twirls and large bounces. Screenshots were inspected for the Games menu, setup, live notes, pause, results, Knowledge, and a 960 × 600 window; labels fit and long result dialogue scrolls.
- The full original synthesized song and its reproducible generator are included. Native audio-clock timing was exercised; audible timing on real audio hardware and in browsers remains a device-level preview check.

## Term highlighting

- A shared whole-word vocabulary covers the tutorial, speech, Knowledge quotes/explanations/code, guided lessons, quiz questions/answers/feedback, mini-game rules and results, and live Logic Lab blocks/hints/trace messages.
- Core terms work in all letter cases. Prose conjunctions remain plain unless explicitly capitalized as logic words. Code mode recognizes lowercase GDScript keywords and comparison/assignment operators.
- Every lesson field and quiz answer preserves its exact plain source at all three Game levels. Literal BBCode, list/index brackets, indentation, Unicode, and line breaks remain visible. Saved quotes contain no presentation markup.
- Every authored quiz question and choice was checked for fit across all Game levels. Real pointer input still activates answers through passive rich text. Existing Lab tests still cover actual dragging and row reordering.
- The same bold dark lettering and soft yellow background identify terms; colors do not encode correct answers. Long code panels can scroll. Screenshots were inspected for speech, Knowledge, quiz, tutorial, Lab, and a small window.

## Gameplay regression

- Original petting, carrying, releasing, soft landings, feeding, needs, and lesson discovery still work.
- All three game levels start at First steps. Kindergarten stays there, Middle–Highschool caps at Little recipes, and College reaches Code explorer.
- Every new stage was played through its lesson pages, sorting activity, all three loop rounds, quiz, and result. Incorrect repeat counts remain retryable.
- OR, NOT, ELIF, freshness checks, and the exact fullness boundary were checked against independently specified expected answers.
- Changed starting values, step sizes, running totals, and nested-loop totals were checked. Nested loops animate inner steps before completing each outer group.
- Three distinct activity badges are required before a stage unlocks. Repeating one activity cannot substitute for another; a quiz with fewer than three questions cannot grant its stage badge.
- Later quizzes use only their own stage's displayed lessons. Earlier stages remain available for practice.
- Completion pays coins; unsuccessful completed attempts receive practice coins; unfinished activities pay nothing. Duplicate result events cannot pay twice.
- Shop transactions charge the catalog price once, refuse insufficient funds and unknown/unowned gear, and never charge for equipping.
- Equipment in different slots combines. Equipment in the same slot replaces only the active appearance; prior purchases remain owned.
- Equipped accessories follow Pip's pose. An equipped hat can be grabbed. Room purchases change the actual rug and wallpaper.
- Wallet, purchases, equipment, badges, selected practice stage, care progress, and local scores survive save/reload.
- Reset clears the wallet, purchases, equipment, badges, and learning/care progress, updates the visible art immediately, and persists the fresh state. Comfort settings and game level remain.
- Previous version-2 saves retain inventory and lessons, begin the new progression at First steps, and default to an empty wallet/wardrobe. Unknown items, duplicate ownership, invalid slots, and out-of-range practice selections are sanitized.
- Corrupt JSON falls back safely to defaults.
- The visual pass caught and fixed disappearing short labels and the blank Knowledge body. Longer journal text now scrolls.

## Shop access and dialogue regression checks

- The header is a noninteractive GOLD balance; clicking it does not open Shop. The bottom Shop button remains visible and clickable at 1280 × 800 and 960 × 600, including with zero gold. Native tests use actual pointer input at both sizes.
- Every one of the 34 authored lessons is checked at all three explanation levels. Every displayed line fits at font size 18, and concatenating all pages reproduces the original text exactly.
- A much longer explanation also preserves its final sentence. Next and Back work, waiting does not dismiss an unfinished page, and Done advances the queued lesson.
- Speech controls stay inside the room when Pip is moved to its corners or middle.
- Knowledge displays the exact captured explanation under Pip says. It remains available after a game-level change and a save/reload. Read with Pip replays the saved text.
- The full Knowledge page, including its code example, is reachable by scrolling. Guided lesson and mini-game feedback areas also scroll instead of clipping long content.
- Reset clears saved dialogue. Existing discoveries from saves without recorded dialogue receive a full fallback explanation, without requiring a reset.
- The visible home-screen version marker identifies this release as v1.5.0.

## Picnic Catch

- A visible Games / Quizzes entry opens the input/output lesson before a round. The garden waits for Start; all fresh game levels start with slow berries.
- Mouse and injected touch input reach the right basket location at 1280 × 800 and 960 × 600. Arrow keys and held on-screen buttons move Pip; the basket stays within both edges.
- Pause / Resume and Space freeze/continue the same round. Losing application focus pauses it. Closing an unfinished round stops processing and grants no rewards.
- Swept catch-line collision detects a snack crossing the basket even over a large time step, removes it, and counts it only once. Missing a snack preserves collected snacks and the best streak while resetting the current streak.
- Later stages introduce seeds and leaves. A golden seed adds one snack and two bonus gold; a leaf adds no snack or gold. First steps remains berry-only. Equipped hats appear on the picnic Pip.
- Ten consecutive catches, including one seed, pay exactly 42 gold and the specified treats. Duplicate finish events cannot pay again. Bonus play does not award curriculum badges.
- Gold, best streak, completed-picnic count, and the complete recorded explanation survive saving; Reset clears the new records.
- The visual pass covers the games menu, ready/playing/paused gardens, small window, rewards, and Knowledge entry. Control instructions fit fully. Closely spaced catch messages stack rather than overlap.

## First-play tutorial

- Fresh games automatically open a 15-step tour. Reset progress restarts it immediately and preserves Game level and comfort settings.
- Real mouse clicks pet Pip, open the highlighted menus, feed exactly one treat, and read the full speech lesson. Real dragging moves Pip and the tour waits for his landing.
- Arrows and green outlines track the live controls, including after Game level changes or Shop category switches. Input outside the highlighted target is blocked, and the tutorial card does not cover that target.
- All tutorial text, cards, and targets fit at 1280 × 800 and 960 × 600. Tutorial paragraphs grow inside their scroll area, so longer guidance stays reachable. Screenshots cover first launch, petting, dragging, needs, feeding, speech, Knowledge, Shop, settings, and games.
- The final highlighted Picnic Catch entry ends the tutorial and starts the actual activity. Finishing or skipping saves completion; unfinished tours remain pending. Returning pre-tutorial saves retain their progress and can use Replay tutorial.
- Replay does not reset care or inventory. A full pet, ongoing chewing, or empty pouch gives the feeding step a Next option. Shop browsing requires no purchases. Reset clears completion again.
- Needs and ordinary queued dialogue wait during the tour. Normal keyboard focus is restored afterward. A test caught a focus-restoration hang caused by freed menu nodes; stable instance IDs and weak references now handle rebuilt menus safely.

## Logic Lab acceptance checks

The separate Logic Lab suite passed **115 rendered checks**, with zero failures. The rendered run exercises real pointer clicks and dragging, captures the editor and completed puzzles, and checks a 960 × 600 window.

- All nine challenge solutions and each authored starting visit execute successfully. Wrong instruction order, incorrect repeat counts, reversed branches, OR instead of AND, undefined function calls, skipped function calls, and incorrect nested groups produce specific retryable feedback.
- Different valid solutions are accepted for movement, repeated addition, and parameter calls. The list puzzle requires visiting its values as well as reaching the target.
- Empty programs, unknown blocks, blocks outside the challenge tray, and more than five blocks are rejected. Execution is bounded and starting situations are not mutated.
- Clicking or dragging adds blocks; arrows and row dragging reorder them; removing a block closes the gap. Run locks editing; Pause freezes execution; Step runs one action; Stop preserves the editable program. Closing the activity stops playback.
- First completions pay exactly 25 gold and 2 berries. All nine completions pay 225 gold total. Replays and duplicate completion calls cannot pay again. Practice failures do not spend real inventory or money. Lab completion does not substitute for curriculum badges.
- Encountered lesson text and the complete last successful walkthrough appear in Knowledge. The new questions join only the corresponding stage's discovered quiz pool.
- Lab completion, gold, and dialogue survive save/reload. Version-6 saves retain their coins and purchases and start with no lab records. Reset clears the lab with other progress and restarts the tutorial while preserving the selected Game level.
- All levels start with the same first card. Kindergarten is capped at three lab cards, Middle at seven, and College at nine. Later cards also require the prior lab card and the matching curriculum stage.
- Visual testing caught clipped two-line block labels; adjusted card height and line spacing now display them completely. Both 1280 × 800 and 960 × 600 layouts were inspected.

## Web export

The bundled official matching single-thread Web templates are used by the existing export helper. The updated game was exported successfully with the command-line wrapper. The final browser ZIP was checked for archive integrity, `index.html` at its root, nonempty engine/game files, and license notices. Snack Jam’s controller, original song, chart, save changes, rewards, and lesson are included in the same export as the rest of the game. The separate browser ZIP is byte-identical to the copy inside the editable project package.

**Browser gameplay is not verified for this update.** A fresh Chrome 154 binary reported its version correctly, but the browser test launcher exited with SIGSEGV before opening a page in this execution environment. Native rendering and a successful export do not establish browser save/reload, audio, iframe, or fullscreen behavior. Use the preview checklist in [ITCH_IO.md](ITCH_IO.md) on your itch.io page before publishing.

## Scope

Artwork uses editable vector drawing. Pip uses a bounded spring simulation with animated paws and ears. Room items are decorative and do not add furniture collision. Cosmetics do not alter puzzle difficulty or rewards. Lessons and quizzes are authored content, with shuffled questions and answer choices.

Progress is local to this device/browser profile. The F5 and browser saves are separate. There are no accounts, analytics, real-money purchases, or online services. Clearing browser storage can remove its save just as deleting the local save can on desktop.

Native gameplay was tested on Linux. Windows/macOS executables and an actual hosted itch.io page were not tested. F5 play uses the same project; optional standalone desktop exports require their matching templates.

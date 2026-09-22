# Validation

Release **1.3.0 · Guided first play** uses **Godot 4.7.2 stable** (`4.7.2.stable.official.ed1daf0bf`), standard GDScript, and the Compatibility renderer. The editable project and itch.io build share one source tree.

## Current checks

The Linux integration suite passed **290 headless checks** and **303 rendered checks**, with **zero failures**. The rendered run includes actual mouse input and captures the home screen, Shop categories, customized room and Pip, stage selection, new lessons, all added sorting/loop stages, quiz/results, Knowledge, and settings. A 960 × 600 window was also captured. The games menu includes the new Picnic Catch entry and retains the best-score display. Speech fit checks use the actual visible-line count, including Godot theme line spacing. The previous font-height-only check missed a clipped final line; this release fixes that calculation and paginates the complete text.

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
- Every one of the 24 authored lessons is checked at all three explanation levels. Every displayed line fits at font size 18, and concatenating all pages reproduces the original text exactly.
- A much longer explanation also preserves its final sentence. Next and Back work, waiting does not dismiss an unfinished page, and Done advances the queued lesson.
- Speech controls stay inside the room when Pip is moved to its corners or middle.
- Knowledge displays the exact captured explanation under Pip says. It remains available after a game-level change and a save/reload. Read with Pip replays the saved text.
- The full Knowledge page, including its code example, is reachable by scrolling. Guided lesson and mini-game feedback areas also scroll instead of clipping long content.
- Reset clears saved dialogue. Existing discoveries from saves without recorded dialogue receive a full fallback explanation, without requiring a reset.
- The visible home-screen version marker identifies this release as v1.3.0.

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
- All tutorial text, cards, and targets fit at 1280 × 800 and 960 × 600. All tutorial text fits without scrolling. Screenshots cover first launch, petting, dragging, needs, feeding, speech, Knowledge, Shop, settings, and games.
- The final highlighted Picnic Catch entry ends the tutorial and starts the actual activity. Finishing or skipping saves completion; unfinished tours remain pending. Returning pre-tutorial saves retain their progress and can use Replay tutorial.
- Replay does not reset care or inventory. A full pet, ongoing chewing, or empty pouch gives the feeding step a Next option. Shop browsing requires no purchases. Reset clears completion again.
- Needs and ordinary queued dialogue wait during the tour. Normal keyboard focus is restored afterward. A test caught a focus-restoration hang caused by freed menu nodes; stable instance IDs and weak references now handle rebuilt menus safely.

## Web export

The bundled official matching single-thread Web templates are used by the existing export helper. The updated game was exported successfully with the command-line wrapper. The final browser ZIP was checked for archive integrity, `index.html` at its root, nonempty engine/game files, and license notices. New curriculum and customization scripts are included in the same export as the rest of the game.

**Browser gameplay is not verified for this update.** Native rendering and a successful export do not establish browser save/reload, audio, iframe, or fullscreen behavior. Use the preview checklist in [ITCH_IO.md](ITCH_IO.md) on your itch.io page before publishing.

## Scope

Artwork uses editable vector drawing. Pip uses a bounded spring simulation with animated paws and ears. Room items are decorative and do not add furniture collision. Cosmetics do not alter puzzle difficulty or rewards. Lessons and quizzes are authored content, with shuffled questions and answer choices.

Progress is local to this device/browser profile. The F5 and browser saves are separate. There are no accounts, analytics, real-money purchases, or online services. Clearing browser storage can remove its save just as deleting the local save can on desktop.

Native gameplay was tested on Linux. Windows/macOS executables and an actual hosted itch.io page were not tested. F5 play uses the same project; optional standalone desktop exports require their matching templates.

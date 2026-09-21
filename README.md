# CritterCare

A complete, offline 2D pet-care game that teaches beginner programming through play. Meet Pip, a little hamster with a lot of curiosity.

![CritterCare home screen](docs/preview.png)

## Project abstract

CritterCare is developed with the free, open-source Godot Engine. It uses 2D graphics, GDScript game logic, animated pet interactions, short programming lessons, quizzes and mini-games, pet statistics such as fullness and happiness, menus, HUD elements, a local save system, and a browser export that can be uploaded to itch.io. The game teaches programming by connecting each player action to the logic behind it.

The teaching focus is variables, boolean logic, if-then-else conditionals, loops, and input/output. Pip explains these ideas through interactions: fullness and happiness act as variables, held/not-held state is a boolean, feeding uses conditions, chewing and Loop Garden show repetition, and clicks or button presses demonstrate input and output. The settings menu includes a **Game level** dropdown for **Kindergarten - Elementary level**, **Middle - Highschool**, and **College**, changing how slowly Pip explains ideas, how much terminology he uses, and how much detail appears in bubbles, Knowledge entries, quizzes, and mini-game feedback.

## Play immediately

1. **Extract the entire `CritterCare` folder** from the ZIP. Do not run it inside the ZIP preview.
2. Open **Godot 4.7.2**, choose **Import**, and select `CritterCare/project.godot`.
3. Choose **Import & Edit**. Let Godot finish importing the bundled fonts and sounds, then press **F5** (Run Project).

This is a standard GDScript project. You do not need .NET, additional downloads, an account, or an internet connection to play locally. The main scene is already configured. This release targets **Godot 4.7.2**, using the Compatibility renderer. Godot 3 is not supported.

An “older Godot version” message on the previous project described its saved engine version; it did not by itself mean the game was broken. This project now records **4.7**, which is how Godot stores the major/minor project compatibility marker. The bundled Web export templates are specifically **4.7.2**. Import this updated folder instead of the previous download.

On Windows, you can also drag `project.godot` into Godot's Project Manager. Open the complete extracted folder, since the scene needs its `scripts`, `data`, and `assets` folders.

## Meet Pip

| Control | What happens |
| --- | --- |
| Short click on Pip's head | Pet him; hearts appear and happiness rises |
| Hold left click anywhere on Pip for about a quarter second | Pick him up |
| Drag while holding | Carry him around; his body sways and his paws dangle |
| Release the mouse | Drop or put him down; gravity, a soft bounce, and a settling animation take over |
| Feed Critter | Choose a berry, seed, or carrot from your inventory |
| Mini Games / Quizzes | Earn more treats by solving little programming challenges |
| Knowledge | Revisit only the lessons you have already encountered |
| Click a learning bubble | Open that discovery in the Knowledge book |
| Hover over a learning bubble | Keep it visible while you read |
| `P`, `F`, `M`, `K` | Pet, Feed, Mini Games, Knowledge keyboard shortcuts |
| `Esc` | Return home from a menu or game |
| `Tab`, `Enter` | Move through and activate UI buttons |

Pip breathes, blinks, looks toward the pointer, washes his face, reacts happily, chews snacks, dangles, leans in all four movement directions, falls, and settles after a landing. The animations are built from vector shapes and damped springs, so there is no sprite-sheet dependency. This is an animated spring-based ragdoll, implemented in GDScript; it does not require a physics-joint rig.

The `···` button opens sound, gentler-movement, game-level, and reset settings. Gentler movement reduces swaying and breathing and removes landing bounce. **Reset progress** starts from zero by clearing discoveries, treats, scores, and care counts while keeping comfort settings and the selected game level.

## Care, rewards, and learning

You start with **6 berries, 3 sunflower seeds, and 2 carrot nibbles**. Fullness and happiness gently decrease while the home screen is active. Petting adds 8 happiness, capped at 100. Feeding checks fullness and your inventory before spending a treat. A mini-game win builds appetite by lowering fullness by 12, so you can bring the new snacks back to Pip.

There is no death, no game-over state, no real-money store, and no offline deterioration. Needs and animations pause in menus. A game result can change needs and inventory when you finish it.

| Adventure | How to play | Winning reward |
| --- | --- | --- |
| Berry Detective | Sort 10 finds using `if / else`; the last five also require `AND`. Get at least 7 correct. | 5 berries + 2 seeds |
| Loop Garden | Choose how many times a step repeats. Reach a star in each of 3 gardens. Wrong counts can be corrected and retried. | 4 berries + 3 seeds + 1 carrot |
| Pip's Pop Quiz | Answer up to 5 shuffled questions drawn **only from discovered lessons**. Get at least 60% correct. | 2 berries per correct answer + 1 seed |

Quizzes explain mistakes, identify the correct answer, and lock each choice after it is submitted. Rewards are applied once per completed win. The game keeps your top three winning scores on this device; there is no online leaderboard. Loop Garden scores start at 100 and decrease by 5 per extra attempt, with a minimum winning score of 60. Other game scores are the percentage of correct answers.

**12 discoveries** cover if/else, events, variables, booleans, 2D positions, gravity, conditions, functions, loops, timers, AND logic, and repeat counts/debugging. Lessons appear in readable bubbles after related interactions. Kindergarten/Elementary mode starts with plain `IF ___ THEN ___` sentences, such as “IF my quiet timer reaches its target THEN I clean my face,” before naming the programming idea. Middle/Highschool mode connects that sentence to code structure. College mode adds more precise implementation notes. New bubbles wait their turn. An entry unlocks when its bubble is actually displayed or the relevant mini-game explanation appears. The book does not reveal unseen entries. Repeated interactions can offer reminders.

GDScript snippets in the book are deliberately simplified teaching examples of the implemented logic. They are not standalone scripts to paste directly into a scene.

## Saved progress

The game automatically saves inventory, needs, discoveries, care counts, wins, local scores, sound, gentler movement, and the selected game level. Saves happen after important actions, every 30 seconds, and on focus loss/close. Live animation poses and unfinished mini-game rounds are not saved; Pip returns to his resting place when the game starts again.

The save is `user://crittercare_save.json`. On Windows, this is normally:

```text
%APPDATA%\Godot\app_userdata\CritterCare\crittercare_save.json
```

To start a fresh classroom demo, close the game and move or delete that save file. This does not change the project itself. A missing or malformed save falls back to a fresh game.

The browser build saves in that browser's storage for the game page. Browser and F5 progress are separate. Private browsing, blocked site storage, or clearing browser data can prevent or remove saved progress; the game still runs if saving is unavailable. Keep the same itch.io project for future uploads to give existing browser saves the best chance of remaining available.

## Project map

| File | Purpose |
| --- | --- |
| `project.godot` | Resolution, renderer, icon, and startup scene |
| `scenes/main.tscn` | Home scene: coordinator, room, Pip, and interface layer |
| `scripts/main.gd` | Home UI, learning bubbles, feeding, mini games, quizzes, and rewards |
| `scripts/hamster.gd` | Mouse input, spring motion, animation states, and hamster vector artwork |
| `scripts/room.gd` | Editable room, window, furniture, mat, plants, and colors |
| `scripts/ui.gd` | Shared UI styles, typography, and layout helpers |
| `scripts/icon.gd` | Original vector icons and mini-game objects |
| `scripts/save_data.gd` | Persistence, needs, inventory validation, and scoring |
| `data/lessons.gd` | Every lesson, level-specific explanation, quiz question, and feedback style |
| `assets/` | Included fonts, licenses, app icon, and original sound effects |
| `tests/verify.gd` | Repeatable integration checks |
| `docs/WORKSHOP.md` | A short workshop flow and concept discovery guide |
| `docs/VALIDATION.md` | Tested behaviors and practical limits |
| `docs/ITCH_IO.md` | Browser upload and future export instructions |
| `export_presets.cfg` | Configured single-thread Web export preset |
| `export_templates/4.7.2/` | Bundled official Web templates and engine notices |
| `addons/crittercare_export/` | Enabled editor menu for exporting an itch.io ZIP |
| `tools/web_builder.gd` | Export and ZIP logic shared by the editor menu and CLI |
| `tools/web_shell.html` | Browser loading screen, canvas focus, and error display |
| `builds/CritterCare-itchio.zip` | Ready-to-upload browser build |

The room, Pip, and most controls are drawn or created when the game runs. It is normal for the editor's 2D preview to show only the scene nodes before you press Play. The source is organized and commented so you can change the artwork, lessons, colors, reward amounts, or game rules.

## Play on itch.io

The included **`builds/CritterCare-itchio.zip`** is already exported. A separate copy of that ZIP is also supplied with this release. Upload the browser ZIP to an itch.io **HTML Game** project and mark the upload **This file will be played in the browser**. Choose **Embed in page**, set the viewport to **960 × 600**, and enable the fullscreen button. To start loading as soon as someone opens the page, turn off itch.io's **Click to Play** option. These are settings on your itch.io page, so they cannot be switched on by a downloaded Godot project.

Upload the browser ZIP intact: its `index.html` is at the ZIP root with all required companion files. The game begins at Pip's room after its initial download; no install or player account is required. Sound may wait for a player's first click. See **[docs/ITCH_IO.md](docs/ITCH_IO.md)** for the full checklist and a local browser-preview command.

After editing the game in **Godot 4.7.2**, choose **Project → Tools → Export CritterCare for itch.io**. The enabled plugin saves open scenes, exports in the background, and rebuilds `builds/CritterCare-itchio.zip`. It uses the official matching Web templates bundled with this project. Local **F5** play continues to work normally and does not require an export.

The **itch.io Web** preset is also available under **Project → Export**. It uses Compatibility rendering, single-thread mode, and the included loading screen. Extensions and PWA are disabled; this build does not require cross-origin isolation headers. If you change Godot versions later, use Web templates matching that version and update the export helper's version guard.

## Optional desktop executable

F5 already runs the game locally through Godot. A standalone Windows, Linux, or macOS executable is a separate optional export: install the matching desktop templates through **Editor → Manage Export Templates**, then add your desktop platform under **Project → Export**. Desktop templates and executables are not included.

## Run the checks

From the project folder, with Godot available as `godot`:

```sh
godot --headless --editor --import --quit --path .
godot --headless --path . --script res://tests/verify.gd -- --test-mode
```

For rendered screenshots and actual pointer tests, run the second command without `--headless`, on a computer with a graphical display. You can add `--capture=/absolute/path/to/screenshots` after `--test-mode`. Always keep `--test-mode` when running the test script: it uses separate temporary save files. The tests do not modify a player's normal save.

To build the itch.io ZIP from the command line, using **Godot 4.7.2**:

```sh
godot --headless --path . --script res://tools/export_web.gd
```

## Credits and references

Code, illustrations, icons, and sound effects are original for this project and provided under the included MIT license. Nunito is distributed under the SIL Open Font License; DejaVu Sans Mono uses its included license. Copies are in `assets/fonts/`.

The bundled Web templates are official Godot 4.7.2 builds. Their MIT license and third-party copyright notices are in `export_templates/4.7.2/`; copies are included in each browser ZIP under `licenses/`.

- [Godot 4.7 command-line documentation](https://docs.godotengine.org/en/4.7/tutorials/editor/command_line_tutorial.html)
- [Godot 4.7 Web export documentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html)
- [Godot 4.7.2 release download](https://godotengine.org/download/archive/4.7.2-stable/)
- [itch.io HTML5 game documentation](https://itch.io/docs/creators/html5)
- [Nunito font source and license](https://github.com/google/fonts/tree/main/ofl/nunito)

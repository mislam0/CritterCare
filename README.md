# CritterCare

**Release v1.7.1 · Your latest branch + customizable pets**

Open `project.godot` in Godot 4.7.2 and press F5, or upload the included
`builds/CritterCare-itchio.zip` as an HTML game.

## Update v1.7.1

The pet update is merged into your uploaded v1.6.6 branch. All ten Shop themes,
60 purchase IDs and prices, room Decor Sets, care/reward balancing, teaching
syntax colors, and browser text fixes are retained.

- Choose **Hamster, Kitten, Bunny, Puppy, Fox, or Panda** before naming your
  friend, or use **Style pet** in the room, Settings, or Shop. Pip is the default.
- Customize eyes, nose, mouth, ears, markings, and six color areas with a live
  preview. Species designs are remembered; changes stay drafts until applied.
- **Saved looks** keeps three favorite pet designs with their owned accessories.
  These are separate from the three full-story save slots.
- **Ball Play** is a relaxed fetch toy. Tap the floor or press Space to throw;
  a completed return earns 2 happiness. B opens the toy; C opens the creator.
- The customized pet also appears in Picnic Catch, Logic Lab, and Snack Jam.
  Existing version-9 stories remain loadable; new saves use version 10.

![Pet creator](docs/pet-creator-preview.png)

See [the pet guide](docs/PET_CREATOR.md) for controls and editing files, and
[merge notes](docs/MERGE_NOTES.md) for the preserved branch changes.

## Previous update v1.6.6

Added syntax highlighting and fixed text for the web.

### Previous artwork and gameplay updates

- Expanded the shop to 10 matching themes with 60 items, including Easter, Brainrot, Thanksgiving, and Bear Spirit.
- Updated pet accessories and room decorations to match the supplied art and fitting guides: flat, front-facing designs, simple colors, and no swords.
- Added matching furnished Decor Sets, clearer shop labels, better thumbnails, and improved accessory and room placement.
- Balanced care and rewards: both needs drain at 5 points per minute, petting rewards have a 30-second cooldown, and Picnic Catch and Loop Garden give fewer coins.
- Preserved purchases, prices, and saved progress. Included matching Godot and browser builds.

See [CHANGELOG.md](CHANGELOG.md) for earlier updates and
[the shop art guide](docs/SHOP_ART.md) for artwork sources and fitting details.

## Project abstract

CritterCare is developed with the free, open-source Godot Engine. It uses 2D graphics, GDScript game logic, animated pet interactions, short programming lessons, quizzes and mini-games, pet statistics such as fullness and happiness, menus, HUD elements, a local save system, and a browser export that can be uploaded to itch.io. The game teaches programming by connecting each player action to the logic behind it.

The teaching focus is variables, boolean logic, if-then-else conditionals, loops, and input/output. Pip explains these ideas through interactions: fullness and happiness act as variables, held/not-held state is a boolean, feeding uses conditions, chewing and Loop Garden show repetition, and clicks or button presses demonstrate input and output. The settings menu includes a **Game level** dropdown for **Kindergarten - Elementary level**, **Middle - Highschool**, and **College**, setting how far the learning path can grow. Everyone starts with the same beginner challenges and plain IF/THEN explanations. As players complete activities, higher levels unlock new rules, guided lessons, and more complex applications. No level assumes prior coding knowledge. Players earn coins through completed activities and spend them in a permanent-unlock Shop for pet accessories and room decorations.

## Play immediately

1. **Extract the entire `CritterCare` folder** from the ZIP. Do not run it inside the ZIP preview.
2. Open **Godot 4.7.2**, choose **Import**, and select `CritterCare/project.godot`.
3. Choose **Import & Edit**. Let Godot finish importing the bundled fonts and sounds, then press **F5** (Run Project).

This is a standard GDScript project. You do not need .NET, additional downloads, an account, or an internet connection to play locally. The main scene is already configured. This release targets **Godot 4.7.2**, using the Compatibility renderer. Godot 3 is not supported.

An “older Godot version” message on the previous project described its saved engine version; it did not by itself mean the game was broken. This project now records **4.7**, which is how Godot stores the major/minor project compatibility marker. The bundled Web export templates are specifically **4.7.2**. Import this updated folder instead of the previous download.

On Windows, you can also drag `project.godot` into Godot's Project Manager. Open the complete extracted folder, since the scene needs its `scripts`, `data`, and `assets` folders.

## Confirm you opened the update

The bottom-right footer should show **v1.7.1**, followed by your pet's name. If it does not, that is an older copy of the game. Extract this download into a fresh folder and import the `project.godot` from that folder rather than launching a previous Project Manager entry. New saves and Reset progress ask for a name, then start the guided tour. With an existing save, choose Settings → Replay tutorial to see it without losing progress.

The matching browser build is included as `builds/CritterCare-itchio.zip`. After future edits, use **Project → Tools → Export CritterCare for itch.io** to rebuild it. Generated browser files live in `builds/web/`; the older duplicate `critter_care_web_version/` export is not shipped.

## New: Pip’s Snack Jam

Open **Games / Quizzes**, scroll down, and choose **Play Snack Jam** for a musical play break. Tap **A / S / D**, click, or touch the three snack pads as falling snacks reach their rings. Pip claps, bounces, and twirls in your equipped accessories. **Berry Bounce** is an original 53-second tune with a four-beat count-in and a gentle ending.

Choose **Chill** (40 snacks and generous timing), **Standard** (80 snacks, one each beat), or **Lively** (120 snacks with extra offbeats). These settings are separate from Game level and available to everyone immediately. Each has its own saved best accuracy and longest combo. Misses reset the combo; there are no lost lives. The optional timing adjustment helps line up notes and music.

Finish the song for **20–40 gold**. Reach **70% accuracy** for **2 berries**, or **90%** for the berries plus **1 seed**. Leaving or restarting an unfinished round gives no reward. Pause with **Space** or the on-screen button; resuming gives a three-beat visual lead-in, and switching away pauses automatically. Music can be muted and Gentler movement removes big bouncing and twirls.

There are no lesson interruptions during the song. Afterward, Pip explains the input, output, IF/THEN rule, and combo variable, with highlighted vocabulary. Knowledge saves the complete explanation and your round’s catch/combo figures. Rhythm rounds do not grant curriculum badges. Existing saves keep their progress; Reset progress clears rhythm records along with coins and other achievements.

See **[Snack Jam guide](docs/SNACK_JAM.md)** for controls, scoring, timing settings, and the exact files to edit.

## Easier-to-notice teaching terms

Programming terms use **category colors on the normal light teaching panels** only when the pet is teaching: lesson bubbles, Knowledge quotes/explanations/code, guided lessons, educational hints, and answer explanations. Ordinary greetings, menus, game rules, quiz questions and choices, Logic Lab blocks, scores, and buttons stay plain.

This applies at every Game level. Dialogue and saved quotes remain plain strings; the UI decides whether a particular message is teaching. Long teaching speech is measured before pagination, and Knowledge and feedback remain scrollable. See [TEXT_HIGHLIGHTING.md](docs/TEXT_HIGHLIGHTING.md) for the explicit `UI.teach()` opt-in.

## Pip's Logic Lab

Open **Games / Quizzes**, scroll down, and choose **Open Logic Lab** to build a program from instruction blocks and watch Pip follow it. There are **nine guided challenges** covering sequencing, repeats, IF/ELSE, AND/OR, variables, functions, parameters, lists, and nested loops. Everyone starts with the same easy first challenge. Kindergarten has three cards; higher levels unlock more through the existing learning path.

Click/tap to add a block, drag or use arrows to reorder, then choose **Run** or **Step**. Pause and Stop / edit let you read and revise at your own pace. The highlighted instruction matches the animated practice Pip and changing numbers. Two- and three-visit challenges check that one program handles different starting situations. Hints explain mistakes; there are no retry penalties.

Each first solution earns **25 gold + 2 berries**. Completions save permanently until Reset progress. Replays are free practice without repeat rewards. Practice actions do not spend real treats. Knowledge includes each new lesson and Pip's last successful walkthrough. See **[Logic Lab guide](docs/LOGIC_LAB.md)** for controls, challenge progression, and editing locations.

![Pip's Logic Lab](docs/logic-lab-preview.png)

## Save, load, and name your pet

![Manual save slots](docs/save-slots-preview.png)

Open **Settings (···) → Save / Load** for three manual save slots. Choose **Save here**, enter a title, and confirm. Each slot keeps the pet name, treats, gold, purchases, equipment, discoveries, full quotes, game records, tutorial state, and settings from that moment. **Load** returns to that saved point and makes it the current automatic save. Save the current game in another slot first if you want to keep both.

**Delete** empties only the selected slot after confirmation. It does not reset the current game. Reset progress starts the current game over, while saved slots remain available to restore or delete. Slots are local to this device/browser; native and Web saves are separate. See [SAVE_LOAD.md](docs/SAVE_LOAD.md).

First play offers **Choose pet + look**, **Keep Pip**, or **Use this name**. Names can contain up to 12 letters/numbers, spaces, apostrophes, and hyphens. **Settings → Rename pet** changes the name later. New dialogue and labels use it; previously captured Knowledge quotes keep their exact original wording.

## A first-play tutorial

![Green arrows guide the first-play tutorial](docs/tutorial-preview.png)

After choosing a pet name, a new save starts a **15-step guided tour**. A **green arrow and outline** point to the real control or part of Pip to use, and short instructions explain what it does. Players pet Pip, hold and drag him, let him land, offer a treat, and read a complete speech lesson. The tour then introduces needs and gold, Knowledge, the pet/room Shop tabs, Game level settings, and Games / Quizzes including Picnic Catch.

The tour waits for the actual action on interaction steps. Informational steps have **Next**; **Skip step** can bypass a difficult gesture. **Skip tutorial** or **Esc** ends the tour. Normal needs do not drain while the tour is open, and other lesson bubbles wait their turn. Green arrow movement stops when Gentler movement is enabled. Mouse/touch guidance and keyboard focus use the same targets; Tab cycles between the highlighted control and tutorial controls.

Completing or skipping the tour saves that choice. It does not repeat on ordinary launches. If you close the game before finishing or skipping, the tour starts from the welcome next time. **Reset progress** clears completion, asks for a pet name, and starts the tour again, while retaining the selected Game level and comfort settings. **Settings → Replay tutorial** starts it without resetting your save. The practice pet/feed actions affect care and inventory normally; no gold or purchases are required. If Pip is full, still chewing, or the pouch is empty during a replay, the feeding step offers a way to continue.

Existing saves retain their progress and receive a one-time name choice. Their tutorial completion stays intact; use Replay tutorial to take the tour again.

## Meet Pip

| Control | What happens |
| --- | --- |
| Short click on Pip's head | Pet him; hearts appear and happiness rises |
| Hold left click anywhere on Pip for about a quarter second | Pick him up |
| Drag while holding | Carry him around; his body sways and his paws dangle |
| Release the mouse | Drop or put him down; gravity, a soft bounce, and a settling animation take over |
| Feed Critter | Choose a berry, seed, or carrot from your inventory |
| Games / Quizzes | Follow the learning path, practice earlier stages, and earn treats and coins |
| Settings → Save / Load | Save a named story, load it, or delete its slot |
| Settings → Rename pet | Change the name without resetting progress |
| Settings → Replay tutorial | Follow the green arrows through the basics again |
| Games / Quizzes → Play Snack Jam | Tap three rhythm lanes, dance with Pip, and earn gold |
| Games / Quizzes → Open Logic Lab | Build and run a program with Pip |
| Games / Quizzes → Play Picnic Catch | Move Pip’s basket, catch snacks, and build streaks for gold |
| Shop | Buy, equip, or unequip pet accessories and Room sets (Wallpaper, Decor Set, Rug) |
| Knowledge | Revisit only the lessons you have already encountered |
| Click a learning bubble | Open that discovery in the Knowledge book |
| Next / Back / Done in a bubble | Read every page at your own pace; there is no reading timer |
| Knowledge button in a bubble | Open the full spoken explanation and lesson |
| Read with Pip in Knowledge | Replay the saved explanation in readable pages |
| `P`, `F`, `M`, `K`, `S` | Pet, Feed, Games, Knowledge, Shop keyboard shortcuts |
| `Esc` | Return home from a menu or game |
| `Tab`, `Enter` | Move through and activate UI buttons |

Pip breathes, blinks, looks toward the pointer, washes his face, reacts happily, chews snacks, dangles, leans in all four movement directions, falls, and settles after a landing. Pip's base body animations are built from vector shapes and damped springs, while purchasable accessories are transparent PNG layers. This is an animated spring-based ragdoll implemented in GDScript; it does not require a physics-joint rig or a separate animation set for each hat.

The `···` button opens Save / Load, Rename pet, sound, gentler-movement, game-level, and reset settings. Gentler movement reduces swaying and breathing and removes landing bounce. **Reset progress** asks for confirmation, then clears discoveries, coins, purchases, equipped items, stage badges, scores, picnic records, Snack Jam records, Logic Lab completions, wins, and care counts. It restores the starter treats and default room/Pip appearance, asks for a name and restarts the tutorial, and keeps comfort settings and the selected game level. Manual save slots remain available until you delete them in Save / Load.

## Care, rewards, and learning

You start with **6 berries, 3 sunflower seeds, and 2 carrot nibbles**. Fullness and happiness gently decrease while the home screen is active. Petting can add 4 happiness once every 30 seconds, capped at 100; reactions and lessons still work for every pet. Feeding adds 3 happiness and checks fullness and inventory before spending a treat. Successful games restore 6 happiness (2 for lower-accuracy Snack Jam). A mini-game win builds appetite by lowering fullness by 12, so you can bring the new snacks back to Pip.

There is no death, no game-over state, no real-money store, and no offline deterioration. Needs and animations pause in menus. A game result can change needs and inventory when you finish it.

| Adventure | How to play | Winning reward |
| --- | --- | --- |
| Berry Detective | Sort 10 finds using `if / else`; the last five also require `AND`. Get at least 7 correct. | 5 berries + 2 seeds |
| Loop Garden | Choose how many times a step repeats. Reach a star in each of 3 gardens. Wrong counts can be corrected and retried. | 15–23 gold; 4 berries + 3 seeds + 1 carrot |
| Pip's Pop Quiz | Answer up to 5 shuffled questions drawn **only from discovered lessons**. Get at least 60% correct. | 2 berries per correct answer + 1 seed |
| Snack Jam | Tap A/S/D or three pads in time with the original song; choose Chill, Standard, or Lively. | 20–40 gold; 2 berries at 70% accuracy; +1 seed at 90% |
| Logic Lab | Solve guided block-programming challenges. Run, step, and debug at your own pace. | 25 gold + 2 berries per first solution |
| Picnic Catch | Move Pip’s basket to catch 10 snacks. No countdown or lost lives. | 12 gold + streak/seed bonuses; 3 berries + 1 seed |

Quizzes explain mistakes, identify the correct answer, and lock each choice after it is submitted. Treats are awarded for wins. Coins are awarded once per completed activity, including attempts below the winning score. Leaving an unfinished activity grants no rewards. The games menu shows stage badges and your top three winning scores. Loop Garden scores start at 100 and decrease by 5 per extra attempt, with a minimum winning score of 60. Quiz and sorting scores are the percentage of correct answers. Picnic Catch records the best catch streak as a percentage of ten.

**34 authored discoveries** include the original 12 care/game lessons, 11 concepts introduced along the learning path, the Picnic Catch input/output lesson, 9 Logic Lab lessons, and Snack Jam’s rhythm/input lesson. Home bubbles and new guided pages explain ideas in ordinary words before showing code. Quiz pools contain only lessons actually displayed, and later-stage quizzes focus on that stage's concepts. Every Knowledge entry starts with **Pip says**, containing the complete explanation Pip last gave for that lesson. Those words stay saved even if the learner changes game levels. The explanation and code follow in the same scrollable page. Older saves receive a complete fallback quote for discoveries made before dialogue recording was added.

Speech uses a readable fixed font and **Next**, **Back**, and **Done** controls. Long explanations split across pages, with no lost words or automatic timeout. Press Done to let the next queued lesson appear. Mini-game feedback and guided explanations also scroll when needed.

### New: Pip’s Picnic Catch

![Pip’s Picnic Catch](docs/picnic-preview.png)

Choose **Games / Quizzes → Play Picnic Catch**. Pip explains the rules first; nothing falls until you press **Start picnic**. Move the mouse inside the garden, touch/drag, hold the on-screen direction buttons, or use **Left / Right** or **A / D** to move the basket. Your equipped pet accessories come with Pip.

Catch **10 snacks** to finish. There is no countdown or lost life. Missing a snack restarts only the current streak; previously collected snacks and the best streak remain. **Pause / Resume** freezes the round; Space also toggles pause while the garden has keyboard focus. Switching away from the application pauses it automatically. Unfinished rounds are not saved and give no rewards.

Every learner starts with slow berries. At Stage 2, golden seeds join the berries and give one extra gold each. At Stages 3–4, leaves also fall: let them pass, because catching a leaf resets the current streak without taking away snacks or gold. The relevant OR and IF/ELIF/ELSE lessons appear before these rules. Gentler movement keeps the slower falling speed at every stage.

A completed picnic pays **12 + best streak + golden-seed bonuses** gold and **3 berries + 1 seed**. It increases Pip’s happiness like other wins. A perfect berry-only picnic gives 22 gold. The personal best and completed-picnic count save automatically and clear with Reset progress. Pip’s full explanation and the last round’s streak are saved under **Catch a snack with Pip** in Knowledge.

This is an optional play break. It does not replace any of the three badges needed to unlock a curriculum stage.

### A learning path that starts easy

| Stage | What changes in gameplay | Available levels |
| --- | --- | --- |
| 1. First steps | Original berry/AND sorting and one-step repeat puzzles; IF/ELSE, booleans, and basic variables | All three levels |
| 2. More ways to decide | OR and NOT sorting; comparisons; loops with a starting value and steps of 2 or 3 | Middle–Highschool and College |
| 3. Little recipes | Three-way IF/ELIF/ELSE sorting; function parameters and running totals | Middle–Highschool and College |
| 4. Code explorer | Grouped food/freshness rules, exact fullness limits, lists starting at index 0, and animated inner/outer loops | College |

Kindergarten–Elementary always stays at Stage 1. Higher levels start there too. Earn a badge in **each of the three activities** to unlock the next stage: win Berry Detective, finish all three Loop Gardens, and win a quiz of **at least three questions**. A one- or two-question quiz still awards normal rewards, but does not satisfy the stage badge. New stages are selected automatically when unlocked; use the stage dropdown to replay any earlier stage. Switching Game level changes the available range without erasing previously earned badges or purchases. Existing saves begin the new path at Stage 1 while retaining their earlier care progress.

### Coins and customization

Each completed curriculum activity awards **12 + floor(score / 10) + 5 × stage index** coins, plus **8 extra coins for a win**. Stage indexes are 0–3. A perfect beginner activity therefore gives 30 coins; even a completed 0% attempt gives 12 practice coins. Coins are earned through play only.

The top **GOLD** display shows only your balance. Open Shop with the **gold Shop button at the bottom right**. **S** also opens it from the home screen. Shop is available immediately, even with zero coins. The Shop has **Pet accessories** and **Room sets** tabs. Buy an item once, then use its **Equip** and **Unequip** buttons at no further cost. Ownership and the current look save automatically. Equipping another item for the same slot replaces only the active appearance; both items remain owned. Pet slots are Head, Face, and Neck. Room slots are Wallpaper, Decor Set, and Rug. A Decor Set may include center wall art, a shelf accent, hanging pieces, a window, a plant, a bowl, and a floor cushion; optional props appear only when their transparent PNGs are supplied.

The catalog contains **10 complete themes and 60 items**, with one 3-card row for each theme in each tab: Nature, Study, Smart Casual, Halloween, Christmas, Pixel Knight, Easter, Brainrot, Thanksgiving, and Bear Spirit. Every theme offers three pet accessories plus Wallpaper, a Decor Set, and a Rug.

Accessories follow Pip's swaying, carrying, and landing motion. Decorations update the actual home room. These are cosmetic purchases and do not change learning requirements or game rewards. Reset progress clears all purchases; ordinary unequipping, switching levels, or reopening the game does not.

GDScript snippets in the book are deliberately simplified teaching examples of the implemented logic. They are not standalone scripts to paste directly into a scene.

## Saved progress

The game automatically saves inventory, needs, discoveries, care counts, wins, local scores, sound, gentler movement, the selected game level, coins, permanent purchases, equipped items, stage badges, the chosen practice stage, picnic best streak and completed rounds, Logic Lab completions, Snack Jam bests by rhythm mode, completed songs, rhythm/timing preferences, tutorial completion, and the full encountered explanation for each lesson. Saves happen after important actions, every 30 seconds, and on focus loss/close. Live animation poses and unfinished mini-game rounds are not saved; Pip returns to his resting place when the game starts again.

The current automatic save is `user://crittercare_save.json`. Manual snapshots live beside it in `.slot_1.json` through `.slot_3.json` files. See [Save / Load](docs/SAVE_LOAD.md). On Windows, this is normally:

```text
%APPDATA%\Godot\app_userdata\CritterCare\crittercare_save.json
```

To start a fresh classroom demo, use **Settings → Reset progress**. Resetting removes that save's purchases and coins too. A missing or malformed save falls back to a fresh game.

The browser build saves in that browser's storage for the game page. Browser and F5 progress are separate. Private browsing, blocked site storage, or clearing browser data can prevent or remove saved progress; the game still runs if saving is unavailable. Keep the same itch.io project for future uploads to give existing browser saves the best chance of remaining available.

## Project map

| File | Purpose |
| --- | --- |
| `project.godot` | Resolution, renderer, icon, and startup scene |
| `scenes/main.tscn` | Home scene: coordinator, room, Pip, and interface layer |
| `scripts/main.gd` | Home UI, learning bubbles, feeding, mini games, quizzes, and rewards |
| `scripts/hamster.gd` | Mouse input, spring motion, and all six customizable pet bodies |
| `scripts/room.gd` | Layered PNG base room plus PNG decoration layers from the Shop catalog |
| `scripts/ui.gd` | Shared UI styles, typography, and layout helpers |
| `scripts/icon.gd` | PNG-backed UI and mini-game icon loader |
| `scripts/save_data.gd` | Persistence, needs, inventory validation, and scoring |
| `scripts/save_slots.gd` | Manual save-slot metadata, validation, save, and delete |
| `scripts/pet_name.gd` | Chosen display name and authored text tokens |
| `docs/SAVE_LOAD.md` | Save/load/delete behavior and editing locations |
| `docs/SHOP_IMAGES.md` | PNG accessory/decoration import guide |
| `tools/add_shop_item.py` | Optional interactive PNG catalog importer |
| `data/curriculum.gd` | Stage availability, prerequisites, rules, and deterministic sort outcomes |
| `data/shop.gd` | One catalog for prices, PNG textures, categories, equipment slots, and placement |
| `assets/shop/` | PNG artwork for every purchasable pet accessory and room decoration, plus the asset-adding guide |
| `assets/ui/icons/`, `assets/room/base/`, `assets/minigames/` | PNG-backed runtime art; sizes and replacement notes are in `assets/ART_ASSETS.md` |
| `data/lessons.gd` | Lesson identities, middle-level worked examples/questions, and level selection |
| `data/lesson_language.gd` | Short beginner lessons, quiz questions, and College explanation extensions |
| `data/game_text.gd` | Tutorial and game instructions for each Game level |
| `scripts/teaching_cooldown.gd` | One-minute automatic lesson cooldown |
| `tests/verify_feedback.gd` | Feedback colors, cooldowns, beginner wording, and layout checks |
| `assets/` | Included fonts, licenses, app icon, and original sound effects |
| `scripts/tutorial.gd` | First-play/reset tour, green arrows, highlighted controls, and keyboard guidance |
| `data/logic_lab.gd` | Block catalog, lab challenges, hints, and deterministic instruction execution |
| `scripts/logic_lab_screen.gd` | Lab editor, drag/drop, visual playback, and practice Pip |
| `tests/verify_lab.gd` | Logic Lab acceptance checks |
| `data/snack_jam.gd` | Rhythm modes, note charts, timing judgement, scoring, and rewards |
| `scripts/snack_jam.gd` | Falling lanes, pads, music clock, dancing stage, and pause/resume |
| `assets/audio/snack_jam.ogg` | Original Berry Bounce music |
| `tools/generate_snack_jam.py` | Reproducible music source; optional editing tool |
| `tests/verify_jam.gd` | Rhythm controls, rewards, save/reset, and full-song acceptance checks |
| `docs/SNACK_JAM.md` | Rhythm game guide and editing locations |
| `scripts/picnic.gd` | Picnic Catch movement, falling snacks, collisions, and round state |
| `data/pet_looks.gd` | Species, features, palettes, and color validation |
| `scripts/pet_creator.gd` | Live creator and three draft outfit presets |
| `scripts/ball_play.gd` | Fetch toy movement and pause/return states |
| `tests/verify_pets.gd` | Merged pet, preset, toy, and save compatibility checks |
| `tests/verify.gd` | Repeatable integration checks |
| `docs/WORKSHOP.md` | A short workshop flow and concept discovery guide |
| `docs/VALIDATION.md` | Tested behaviors and practical limits |
| `docs/ITCH_IO.md` | Browser upload and future export instructions |
| `export_presets.cfg` | Configured single-thread Web export preset |
| `export_templates/4.7.2/` | Bundled official Web templates and engine notices |
| `addons/crittercare_export/` | Enabled editor menu for exporting an itch.io ZIP |
| `tools/web_builder.gd` | Export and ZIP logic shared by the editor menu and CLI |
| `tools/web_shell.html` | Browser loading screen, canvas focus, and error display |
| `builds/CritterCare-itchio.zip` | Matching browser build, ready for upload |

The room, Pip, and most controls are drawn or created when the game runs. It is normal for the editor's 2D preview to show only the scene nodes before you press Play. The source is organized and commented so you can change the artwork, lessons, colors, reward amounts, or game rules.

## Play on itch.io

Upload the included **`builds/CritterCare-itchio.zip`** to an itch.io **HTML Game** project and mark the upload **This file will be played in the browser**. Choose **Embed in page**, set the viewport to **960 × 600**, and enable the fullscreen button. To start loading as soon as someone opens the page, turn off itch.io's **Click to Play** option. These are settings on your itch.io page, so they cannot be switched on by a downloaded Godot project.

Upload the browser ZIP intact: its `index.html` is at the ZIP root with all required companion files. On a fresh save, the game asks for a pet name before the tutorial; no install or player account is required. Sound may wait for a player's first click. See **[docs/ITCH_IO.md](docs/ITCH_IO.md)** for the full checklist and a local browser-preview command.

**This release includes both the editable Godot project and its matching browser ZIP.** Rebuild the browser ZIP after future edits.

After editing the game in **Godot 4.7.2**, choose **Project → Tools → Export CritterCare for itch.io**. The enabled plugin saves open scenes, exports in the background, and rebuilds `builds/CritterCare-itchio.zip`. It uses the official matching Web templates bundled with this project. Local **F5** play continues to work normally and does not require an export.

The **itch.io Web** preset is also available under **Project → Export**. It uses Compatibility rendering, single-thread mode, and the included loading screen. Extensions and PWA are disabled; this build does not require cross-origin isolation headers. If you change Godot versions later, use Web templates matching that version and update the export helper's version guard.

## Optional desktop executable

F5 already runs the game locally through Godot. A standalone Windows, Linux, or macOS executable is a separate optional export: install the matching desktop templates through **Editor → Manage Export Templates**, then add your desktop platform under **Project → Export**. Desktop templates and executables are not included.

## Run the checks

From the project folder, with Godot available as `godot`:

```sh
godot --headless --editor --import --quit --path .
godot --headless --path . --script res://tests/verify.gd -- --test-mode
godot --headless --path . --script res://tests/verify_lab.gd -- --test-mode
godot --headless --path . --script res://tests/verify_highlights.gd -- --test-mode
godot --headless --path . --script res://tests/verify_jam.gd -- --test-mode
godot --headless --path . --script res://tests/verify_feedback.gd -- --test-mode
godot --headless --path . --script res://tests/verify_game_menu.gd -- --test-mode
godot --headless --path . --script res://tests/verify_identity.gd -- --test-mode
godot --headless --path . --script res://tests/verify_save_slots.gd -- --test-mode
godot --headless --path . --script res://tests/verify_name_filter.gd -- --test-mode
```

For rendered screenshots and actual pointer tests, run a test command without `--headless`, on a computer with a graphical display. You can add `--capture=/absolute/path/to/screenshots` after `--test-mode`. Always keep `--test-mode` when running the test script: it uses separate temporary save files. The tests do not modify a player's normal save.

To build the itch.io ZIP from the command line, using **Godot 4.7.2**:

```sh
godot --headless --path . --script res://tools/export_web.gd
```

## Name-filter data

The offline lists and Unicode data have separate licenses and attribution in [third_party/name_filter/NOTICE.md](third_party/name_filter/NOTICE.md). Copies accompany the browser ZIP. See [the filtering guide](docs/NAME_FILTER.md) for coverage, maintenance, saved-name repair, and limits.

## Credits and references

Code, illustrations, icons, sound effects, and the Berry Bounce music composition/recording are original for this project and provided under the included MIT license. Nunito is distributed under the SIL Open Font License; DejaVu Sans Mono uses its included license. Copies are in `assets/fonts/`. The bundled song uses synthesized instruments and no third-party samples; its editable generator is `tools/generate_snack_jam.py`.

The bundled Web templates are official Godot 4.7.2 builds. Their MIT license and third-party copyright notices are in `export_templates/4.7.2/`; copies are included in each browser ZIP under `licenses/`.

- [Godot 4.7 command-line documentation](https://docs.godotengine.org/en/4.7/tutorials/editor/command_line_tutorial.html)
- [Godot 4.7 Web export documentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html)
- [Godot 4.7.2 release download](https://godotengine.org/download/archive/4.7.2-stable/)
- [itch.io HTML5 game documentation](https://itch.io/docs/creators/html5)
- [Nunito font source and license](https://github.com/google/fonts/tree/main/ofl/nunito)

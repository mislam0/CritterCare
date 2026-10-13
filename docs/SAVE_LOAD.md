# Save, load, and delete slots

Open **Settings (···) → Save / Load**. There are three manual slots in addition to the current automatic save.

1. Choose **Save here** on an empty slot, give it a title, and confirm. A blank title becomes **My story**. The slot shows the pet's name, Game level, gold, and save time.
2. Choose **Save** on an occupied slot to replace it with your current progress. The confirmation says that the old copy will be replaced.
3. Choose **Load** to return to that saved point. Confirm before the current game is replaced. Save the current game in another slot first if you want to keep both stories.
4. Choose **Delete** and confirm to empty just that slot. The current game and the other slots stay intact. A deleted slot can be used again.

Automatic saving still runs during play and when closing menus or leaving the application. Loading a slot makes it the active automatic save, so the next launch resumes the loaded story and any play after it. Manual slots do not update until you explicitly save over them.

## What each slot keeps

Pet name, treats, fullness, happiness, gold, purchases, equipped PNG items, discovered lessons, exact recorded teaching quotes, curriculum badges, practice stage, quiz scores, Logic Lab completions, Picnic Catch records, Snack Jam records, tutorial completion, Game level, sound, gentler movement, and rhythm preferences.

A slot stores persistent progress. An unfinished minigame, song, or drag is not resumed midway. Open Save / Load from Settings between activities.

Reset progress clears the **current game** and returns to naming/tutorial. Explicit manual slots stay until you delete them. You can load one afterward to restore that saved story. Delete each slot too if you want to remove every saved story.

## Local storage

F5/desktop and Web use the same save logic but have separate storage. Slots stay on that device or browser profile; they do not sync to accounts or other devices. Clearing the game's browser storage removes its automatic save and slots. Save/load and persistence in an actual hosted browser still need the preview checks in [ITCH_IO.md](ITCH_IO.md).

The current automatic save is `user://crittercare_save.json`. Manual files are `crittercare_save.json.slot_1.json` through `.slot_3.json` in the same Godot user-data folder. You do not need to edit these files. Tests use separate paths with `--test-mode`.

Unreadable slots remain visible so you can replace or delete them. Load is disabled for those slots. Failed writes show an error and do not switch the active story. Files are written to a temporary file first, then renamed into place.

## Editing locations

- `scripts/save_data.gd`: progress fields, migration, snapshot, and atomic write.
- `scripts/save_slots.gd`: three slot paths, names, metadata, validation, save, and delete.
- `scripts/main.gd`: `open_save_slots()`, confirmation screens, and applying a loaded story to the current UI.
- `tests/verify_save_slots.gd`: pointer-driven save/load/delete, cancellation, persistence, failed writes, reset retention, and both supported window sizes.

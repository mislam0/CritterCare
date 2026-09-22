# CritterCare maintenance

This repository is one source of truth for both normal Godot/F5 play and the itch.io browser game. The user requires all future game changes to ship in both versions.

After a change, validate the affected game behavior, run the integration suite with `--test-mode` (which isolates test saves), and rebuild `builds/CritterCare-itchio.zip` using `res://tools/export_web.gd` or the existing editor export menu. Package the updated editable project and a separate copy of the generated browser ZIP together. Never distribute an older browser build beside newer source.

Game levels describe how far a beginner-friendly curriculum can progress. All new learners start with First steps; definitions and examples must appear before a new concept is tested. Keep Kindergarten at its original gentle difficulty. Preserve previous achievements when levels change.

Shop purchases are permanent in the local save. Equipping is free, slots enforce appearance conflicts, and Reset progress clears coins, ownership, equipment, and stage badges while preserving level/comfort settings. Keep prices and slots in `data/shop.gd`.

Picnic Catch is an optional bonus activity, not a curriculum badge. Keep its rewards guarded against duplicate completion; unfinished rounds pay nothing. The header shows gold only; the home Shop stays in the bottom bar. Publish download links with a fresh versioned local filename for each release so previous attachments cannot be mistaken for the latest build.

The first-play tutorial starts for fresh saves and after Reset progress. Completion persists; replay is in Settings. Keep arrows aligned with real targets, advance interaction steps from actual events, and allow skipping without purchases or lost progress. Normal needs and queued speech wait while the tour is active.

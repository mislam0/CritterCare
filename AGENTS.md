# CritterCare maintenance

This repository is one source of truth for both normal Godot/F5 play and the itch.io browser game. The user requires all future game changes to ship in both versions.

After a change, validate the affected game behavior, run the integration suite with `--test-mode` (which isolates test saves), and rebuild `builds/CritterCare-itchio.zip` using `res://tools/export_web.gd` or the existing editor export menu. Package the updated editable project and a separate copy of the generated browser ZIP together. Never distribute an older browser build beside newer source.

Game levels describe how far a beginner-friendly curriculum can progress. All new learners start with First steps; definitions and examples must appear before a new concept is tested. Keep Kindergarten at its original gentle difficulty. Preserve previous achievements when levels change.

Shop purchases are permanent in the local save. Equipping is free, slots enforce appearance conflicts, and Reset progress clears coins, ownership, equipment, and stage badges while preserving level/comfort settings. Keep prices and slots in `data/shop.gd`.

Picnic Catch is an optional bonus activity, not a curriculum badge. Keep its rewards guarded against duplicate completion; unfinished rounds pay nothing. The header shows gold only; the home Shop stays in the bottom bar. Publish download links with a fresh versioned local filename for each release so previous attachments cannot be mistaken for the latest build.

The first-play tutorial starts for fresh saves and after Reset progress. Completion persists; replay is in Settings. Keep arrows aligned with real targets, advance interaction steps from actual events, and allow skipping without purchases or lost progress. Normal needs and queued speech wait while the tour is active.

Logic Lab uses authored block IDs and bounded execution; never evaluate player-entered GDScript. Preserve first-solution-only rewards (25 coins and 2 berries), ordered challenge unlocks, and Game level caps. Practice actions use separate state; leaving an unfinished program pays nothing. Save lab completion and complete spoken walkthroughs, preserve old saves, and clear lab records on Reset progress. Run `tests/verify_lab.gd -- --test-mode` as well as the main integration suite after changes.

Teaching text uses the shared `scripts/teaching_terms.gd` vocabulary and `scripts/learning_text.gd` renderer. Keep dialogue/data and saved quotes plain; assign `words` on teaching labels, never rendered BBCode. Use `UI.label`, `UI.paragraph`, `UI.scroll_text`, `UI.code`, and `UI.teaching_button` for educational content. Measure actual rich-text height when paginating; do not split formatting tags or infer fit from character counts. Keep whole-word matching, literal bracket escaping, and passive text children that allow mouse/touch/keyboard actions. Run `tests/verify_highlights.gd -- --test-mode` after teaching UI changes.

Snack Jam is an optional rhythm activity available at every Game level. Keep Chill/Standard/Lively separate from curriculum difficulty, with separate personal bests. Use the audio playback clock for live note timing; pause music and judgement together, auto-pause on focus loss, and consume key releases as well as presses. No lesson interrupts the song. Store the complete post-song explanation in Knowledge. Only a completed current round may pay its rewards once; unfinished/restarted rounds pay nothing. Reset clears rhythm records and retains comfort/timing preferences. The original music source is tools/generate_snack_jam.py; BPM, count-in, duration, and authored chart in data/snack_jam.gd must remain aligned with the audio. Run tests/verify_jam.gd -- --test-mode after rhythm changes, including its full real-time song check.

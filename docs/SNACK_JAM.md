# Pip’s Snack Jam

Open **Games / Quizzes → Play Snack Jam**. This is an optional musical play break, available from the beginning at every Game level. The original song **Berry Bounce** lasts 52.8 seconds at 100 beats per minute, including four count-in beats and a short ending. No coding question interrupts it.

## Play

1. Choose Chill, Standard, or Lively. Try the pads before starting to make Pip dance.
2. Press Start song and listen to the count-in.
3. Let each falling snack reach its colored ring. Tap **A** for the berry lane, **S** for the seed lane, or **D** for the carrot lane. Mouse clicks and touch on the matching pads work too. Shapes and letters identify lanes as well as colors.
4. Tap once per snack. Perfect and Nice hits build a combo; a miss or an extra tap resets it. Keep going after mistakes—there are no lost lives or early failure.
5. Finish the song to receive gold and see Pip’s explanation. Play again, browse the Shop, or read the complete saved quote in Knowledge.

| Rhythm mode | Notes | Pattern | Accepted timing | Perfect timing |
| --- | ---: | --- | --- | --- |
| Chill | 40 | One snack every two beats | Within 240 ms | Within 120 ms |
| Standard | 80 | One snack each beat | Within 160 ms | Within 80 ms |
| Lively | 120 | Beats plus extra offbeats | Within 110 ms | Within 55 ms |

Timing windows apply before and after the note. There are no simultaneous chords. Rhythm mode changes the song’s challenge, independently of the curriculum Game level. You may select any rhythm mode immediately; songs do not unlock curriculum stages.

## Scores and rewards

Accuracy is calculated after the song: Perfect earns 100 points toward a note, Nice earns 70, a miss earns 0, and each extra tap subtracts 25. Divide the total by the number of chart notes and round to a whole percent, capped at 0–100%. Holding a key does not repeatedly hit notes. Practice taps before the first note’s timing window and after the last note’s window do not lower accuracy.

- Every finished song earns **20 gold**, plus **2 gold per complete 10% accuracy**, up to **40 gold** total.
- **70% accuracy** earns **2 berries**.
- **90% accuracy** earns those berries and **1 seed**.
- Restarting or leaving before the song ends pays nothing. Each completed round pays once.

Best accuracy and longest combo are saved separately for each mode; they can come from different attempts. Replays can earn another round’s rewards. Reset progress clears records, completion counts, gold, and discoveries, while retaining the selected rhythm mode and timing adjustment with other comfort settings.

## Pause, music, and comfort

**Space** or **Pause** stops both music and note judgement. **Resume** gives a three-beat visual lead-in before continuing the same position. Switching away from the application pauses it automatically. **Restart** returns to setup; **Close** or **Esc** returns home.

**Music on/off** shares the main sound preference. Muted play still uses the music clock and falling notes. **Settings → Gentler movement** removes big bouncing and twirls; scoring and note timing stay the same. Pip wears your equipped pet accessories on stage.

If notes consistently lag behind music on your device, increase **Timing** before starting; if they arrive ahead, decrease it. Each step is 20 ms, from −200 to +200 ms. The preference saves automatically. It cannot be changed during a song.

## Where to edit in Visual Studio Code

Open the extracted **CritterCare** folder in VS Code and use **Ctrl+Shift+F** to search these names or exact displayed phrases.

| File | What to edit |
| --- | --- |
| `data/snack_jam.gd` | Song title/BPM/duration, modes, lane pattern, chart generation, hit windows, accuracy, and prize thresholds |
| `scripts/snack_jam.gd` | Setup instructions, pad labels, hit messages, music clock, pause/resume, timing control, stage drawing, and dance triggers |
| `scripts/main.gd` | Search `start_snack_jam` and `_finish_snack_jam` for menu integration, permanent rewards, result text, and captured Knowledge dialogue |
| `data/lessons.gd` | Search `snack_jam` for Pip’s lesson, IF/THEN wording, simpler explanation, College note, code example, and quiz |
| `scripts/hamster.gd` | Search `dance_pose`, `dance_phase`, and `stage_actor` for Pip’s stage poses |
| `scripts/save_data.gd` | Search `jam_` for records, preference migration, saving, and reset |
| `assets/audio/snack_jam.ogg` | The bundled original recording |
| `tools/generate_snack_jam.py` | The song’s synthesized instruments, melody, rhythm, and arrangement |
| `tests/verify_jam.gd` | Timing, controls, completion, rewards, save/reset, layouts, and full-song playback checks |

Pip’s teaching text stays plain text; the shared highlighting renderer marks vocabulary automatically. Longer result explanations scroll and are saved in full, so do not shorten a lesson just to fit one panel. Keep lessons after the song.

Normal play and export need only Godot. Regenerating the recording is optional and requires Python 3, NumPy, and FFmpeg: run `python tools/generate_snack_jam.py` from the project folder. If you change the tempo, count-in, song length, or note pattern, update the chart and recording together and reimport the OGG in Godot. The music contains no third-party samples and shares the project’s MIT license.

After editing, test with F5 and run `tests/verify_jam.gd` with `--test-mode`. Then use **Project → Tools → Export CritterCare for itch.io** and replace the browser upload too. Both versions use these same files.

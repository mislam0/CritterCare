# Pip's Logic Lab · v1.4.1

Open **Games / Quizzes → Open Logic Lab**. Everyone begins with **A snack for Pip**.

## Build, predict, run

1. Read Pip's short lesson and the challenge goal.
2. Click or tap a tray block to add it, or drag it into your program.
3. Arrange up to five blocks. Drag existing blocks to reorder them, or use the up/down arrows. The cross removes one block; Clear removes the program.
4. Predict what Pip will do. Run plays the instructions with a highlighted block and an animated practice Pip. Step follows one small action at a time.
5. Pause to read, or Stop / edit to change your blocks and start again. Hint offers a clue followed by a more complete example.

The lab uses a separate practice scene. Test runs do not spend your treats, change the real pet's needs, or charge gold. Leaving an unfinished attempt grants no reward. First-time successful completion awards **25 gold and 2 berries**, and applies the normal mini-game win happiness/appetite changes. That reward is saved immediately and cannot be collected again by replaying or reopening the challenge.

Your solved cards, rewards, and encountered lessons save automatically. A completed card reopens directly in the editor; its lesson stays in Knowledge. The last successful spoken walkthrough also appears in that lesson's **Pip says** section. New lesson questions can appear in quizzes for the same learning stage, after their explanations have been shown.

There is no time limit, loss of lives, speed bonus, or penalty for using hints. Run advances at a reading pace; Pause and Step provide manual control. Switching away pauses automatic playback. Click/tap controls and keyboard-focused buttons provide an alternative to dragging. Gentler movement applies to the lab's Pip as well.

## Nine challenges

| Stage | Challenge | What the player practices |
| --- | --- | --- |
| 1 | A snack for Pip | Move, then feed: instruction order matters |
| 1 | Three tiny steps | Repeated steps, followed by feeding |
| 1 | Hungry or happy? | One IF/ELSE program tested with hungry and already-fed Pip |
| 2 | Two little checks | AND versus OR, including a missing-berry visit |
| 2 | Fill the seed jar | A changing variable; several different programs can reach 6 |
| 3 | A reusable recipe | Define a function before calling it in the right situation |
| 3 | A recipe with an input | Call the same function with different numeric inputs |
| 4 | Read the whole list | Visit [1, 3, 2] in order and see indexes 0, 1, 2 |
| 4 | Groups inside groups | Complete an inner loop for each outer group |

Solve the preceding lab card to open the next. Later cards also require their normal learning stage to be unlocked through Berry Detective, Loop Garden, and Pop Quiz. The lab is an optional activity and does not substitute for those stage badges.

Kindergarten–Elementary can play the first three cards. Middle–Highschool can reach the first seven; College can reach all nine. Changing the Game level preserves solved cards and rewards, while limiting the accessible range. Reset progress clears lab completion with the rest of the save and restarts the first-play tutorial.

## Editing and extending

- `data/logic_lab.gd`: block labels, challenge goals, hints, starting visits, availability, and the bounded instruction runner.
- `data/lessons.gd`: entries beginning `lab_` contain the introductory speech, full explanation, displayed code, quiz questions, and answer feedback.
- `scripts/logic_lab_screen.gd`: editor controls, drag/drop, playback, practice Pip, seed jar, and feedback presentation.
- `scripts/main.gd`: Games entry, challenge menu, lesson flow, and reward/Knowledge integration.
- `scripts/save_data.gd`: permanent completions and one-time rewards. Save version 7 accepts older saves with an empty lab record.
- `tests/verify_lab.gd`: checks solutions, incorrect programs, alternate solutions, UI controls, level caps, persistence, migration, and reset. Always run with `--test-mode` to isolate test saves.

The lab runs only the authored block IDs. It does not evaluate typed GDScript. The five-block limit and bounded repeats prevent endless player programs. Individual puzzles may require a concept as well as an outcome—for example, the list challenge must actually visit the list.

Both normal F5 play and the itch.io export use these same files. After editing, use **Project → Tools → Export CritterCare for itch.io** to regenerate the browser ZIP.

# CritterCare on itch.io

## Build the current browser version first

The editable project is currently **consolidated v1.6.2 · Learn with Pip**. This source package intentionally omits the older v1.6.1 browser ZIP so it cannot be mistaken for the updated game. Generate a fresh browser build from this project before uploading it.

1. Open `project.godot` in **Godot 4.7.2** and wait for asset import to finish.
2. Press **F5** and verify the footer reads **v1.6.2 · Learn with Pip**.
3. Check both Shop tabs: each should scroll vertically, and every purchasable pet accessory / room decoration should be image-backed.
4. Choose **Project → Tools → Export CritterCare for itch.io**.
5. Upload the generated **`builds/CritterCare-itchio.zip`** to itch.io as an **HTML Game** and mark it **This file will be played in the browser**.
6. Use **Embed in page**, a **960 × 600** viewport, and enable fullscreen. The game also fits its 1280 × 800 canvas.

Upload the generated ZIP intact. It should contain `index.html` at its root alongside the Godot Web files. Do not upload the larger editable project ZIP as the browser-play file.

itch.io page settings are separate from the game files. This project prepares the game and export preset; it cannot change an itch.io account's project settings or publish a page.

## Make a new browser build after editing

1. Open `project.godot` in **Godot 4.7.2** and wait for the initial asset import to finish.
2. Press **F5** to check the game locally. Stop the running game before exporting.
3. Choose **Project → Tools → Export CritterCare for itch.io**.
4. Wait for the completion dialog. The new upload is **`builds/CritterCare-itchio.zip`**.
5. Replace the previous browser upload on the same itch.io project with this ZIP.

The export menu and **itch.io Web** preset are already enabled. The project bundles the official 4.7.2 single-thread Web debug and release templates. No export-template installation or Python is required to create the ZIP through Godot. Export errors are written to `builds/web-export.log`.

The export command saves open scenes. Save script changes in any external code editor before running it. Use Godot 4.7.2 for this preset: newer engine versions need their own matching templates. The helper checks the engine version and explains a mismatch instead of silently using the wrong templates.

## Preview the browser files on your computer

Browser exports need an HTTP server. Double-clicking `index.html` will not run the game correctly. If Python 3 is installed, open a terminal in the extracted `CritterCare` folder and run:

```sh
python -m http.server 8000 --bind 127.0.0.1 --directory builds/web
```

Open **http://127.0.0.1:8000/** in a browser. Press **Ctrl+C** in the terminal to stop the server. If `builds/web` is absent, run the export menu first or unzip `builds/CritterCare-itchio.zip` into that folder. Python is only one optional way to serve these files; itch.io supplies hosting after upload.

## What is configured

| Setting | Included value |
| --- | --- |
| Godot target | 4.7.2 stable, standard GDScript |
| Native play | Main scene set; F5 runs locally |
| Web renderer | Compatibility / WebGL 2 |
| Web threading | Off |
| GDExtensions | Off |
| PWA / service worker | Off |
| Cross-origin isolation headers | Not required for this single-thread build |
| Canvas | Fills the embed and keeps the game's aspect ratio |
| Browser start | Loads directly into Pip's room after downloading |
| Export templates | Matching debug and release templates bundled |
| Loading screen | Included, with progress and a readable failure message |
| Pointer | Click to focus; held pointer capture; touch-to-mouse emulation |

## Browser notes

- Browsers can wait for a first click before allowing sound. The game can still load automatically.
- Progress is stored locally for the game's browser page. It is separate from F5 progress and does not sync between browsers or devices. Clearing browser data removes it. Some private-browsing or storage settings can block persistence.
- A current browser with WebGL 2 is required. A missing-feature message appears when the engine detects an unsupported browser.
- Mouse play at 960 × 600 or larger is the intended layout. Touch emulation is enabled, but phone layouts and mobile browser gameplay have not been validated.
- Desktop gameplay and the Web export are validated as described in **[VALIDATION.md](VALIDATION.md)**. The exported build still needs a browser playthrough on your intended hosting page.

## Quick check on the itch.io preview

On a fresh save, follow the green-arrow tutorial: pet Pip, hold and drag him, drop him, feed one treat, and visit the highlighted menus. On an existing save, use Settings → Replay tutorial. Complete or skip the tour, reload, and confirm it stays completed. Use Reset progress on a disposable test save to verify that the tour restarts. Then complete a mini game. Open Knowledge, reload the page, and check that the discovered lesson and inventory persist. Play Picnic Catch with mouse and arrow keys, test Pause / Resume and switching tabs, complete a round, then reload to check the gold and personal best. Try the fullscreen button and return to the embedded view. Sound should begin after interacting.

References: [itch.io HTML5 games](https://itch.io/docs/creators/html5) · [Godot 4.7 Web exports](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html)

## Updating an existing page

Replace the previous browser upload with this release's `CritterCare-itchio.zip` and save the itch.io page. Reload the embedded game. The home-screen footer should read **v1.6.2 · Learn with Pip**; if a different version appears, check that the new upload is the one selected for browser play and refresh the page. The top display is only your gold balance; Shop is at the bottom right. New saves open the green-arrow tutorial; existing players can choose Settings → Replay tutorial. The normal Godot project ZIP is for editing/F5 and is not the file to upload as a browser game.

No progress reset is needed for this update. Keep the same itch.io project so existing browser saves remain associated with the same game page.

Logic Lab is under **Games / Quizzes → Open Logic Lab** in both builds. Confirm the browser shows v1.6.2 before testing the consolidated build.

## Highlighting check (v1.4.1)

Open a teaching bubble and confirm terms such as IF, THEN, Boolean, and true/false have bold dark text on a pale yellow background. Visit Knowledge, scroll to the code, and try a quiz and a Logic Lab block. Check the same styling in their explanations and answers. Use Next/Back to read a long speech lesson and verify its last sentence is present. Existing saves should retain their progress and complete quotes.

## Snack Jam check (v1.6.1)

Open Games / Quizzes → Play Snack Jam. Choose Chill and press Start song with a real click/tap so the browser can activate audio. Verify the four count-in beats, then catch snacks with A/S/D and with the pads. Test Music off/on, Space pause, three-beat resume, and switching tabs. Finish a whole song, check the gold/treat result and full Knowledge quote, then reload and confirm the selected mode, timing preference, and personal best remain. Try Standard and Lively as well, including in the 960 × 600 embed and fullscreen.

The rhythm player uses streamed audio and the measured music clock to keep notes aligned. If your device’s notes consistently arrive behind the music, raise Timing before starting; if ahead, lower it. The adjustment changes by 20 ms and is saved. Bluetooth/audio hardware and browser performance can affect perceived timing; the preview check should include the devices you intend to use. Gentler movement limits Pip’s dancing without changing note timing.

## Feedback and beginner wording check (v1.6.1)

Confirm the footer says **v1.6.2 · Learn with Pip**. Try a wrong and a correct quiz answer, sort, loop count, and Lab program. Check for large bold red/green outcomes, plus words and symbols. In Picnic Catch, miss a snack and catch one; in Snack Jam, miss, tap early, and hit a note. Select Kindergarten–Elementary to see short instructions and thought-sized speech pages. Pick Pip up repeatedly: the same lesson should stay quiet for 60 seconds after it is shown. Knowledge → Read with Pip should still work during that delay. Change Game level to check explanation depth without resetting progress.

## PNG runtime-art check

On the home screen, verify the HUD/navigation icons are crisp images and the base room still layers Shop wallpaper, rugs, garlands, and lights correctly. Play Picnic Catch and confirm the PNG basket moves with Pip and collisions still happen on the same catch line. In Snack Jam, check all three lane/note images, the stage/glow, hit feedback, and the beat pulse while testing Chill/Standard/Lively timing. In Logic Lab, run a seed-count challenge and confirm individual PNG seeds appear/disappear in the jar as the state changes.

## Scrollable PNG Shop check (v1.6.2)

Open Shop and switch between **Pet accessories** and **Room decorations**. Each tab should show a vertical scrollbar and allow mouse-wheel scrolling; Tab should move through item buttons and reveal the focused card. Scroll one tab, switch away, and return to confirm its scroll position is remembered separately. Buy and equip a pet accessory, then verify the same image appears on Pip and in minigames. Buy and equip a room decoration and verify the image appears in Pip's room. Ownership, prices, slot conflicts, Equip/Unequip, saving, and Reset behavior should match previous releases.

## Scrolling games menu check (v1.6.1)

Open Games / Quizzes. The first three cards appear at the top. Scroll down with the mouse wheel or green scrollbar to reach Picnic Catch, Logic Lab, and Snack Jam. Each card includes its title, instructions, goal, rewards, and a Play button. Try each button, Tab between games, then return to the menu; it should remember where you were. Change Game level to check the different descriptions. Replay tutorial to confirm the green arrow reveals the Picnic Catch button. Also check scrolling on your target touch devices; native injected raw touch events did not verify swipe scrolling in the desktop test environment.

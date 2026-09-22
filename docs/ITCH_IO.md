# CritterCare on itch.io

## Upload the included browser build

1. Create or edit your game project on itch.io.
2. Set **Kind of project** to **HTML Game**.
3. Upload **CritterCare-itchio-v1.3.0.zip** (the versioned download) or **CritterCare-itchio.zip** from this project’s `builds/` folder. Use the standalone download or the identical copy in the Godot project's `builds/` folder.
4. Mark that upload **This file will be played in the browser**.
5. Choose **Embed in page**, with a **960 × 600** viewport, and enable the fullscreen button. The game also fits a 1280 × 800 canvas.
6. Turn off **Click to Play** if you want the game to begin loading immediately when the page opens. Leave it on if you prefer an explicit launch button.
7. Save your itch.io page and preview it. Publish when you are ready for visitors.

Upload the ZIP intact. It has `index.html` at its root, alongside `index.js`, `index.wasm`, `index.pck`, audio worklets, icons, and license notices. Do not upload the larger editable **CritterCare.zip** as the browser-play file. You can offer it as a separate source download if desired.

itch.io page settings are separate from the game files. This download prepares the game and export preset; it cannot change an itch.io account's project settings or publish a page.

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

Replace the previous browser upload with this release's `CritterCare-itchio.zip` and save the itch.io page. Reload the embedded game. The home-screen footer should read **v1.3.0 · Guided first play**; if a different version appears, check that the new upload is the one selected for browser play and refresh the page. The top display is only your gold balance; Shop is at the bottom right. New saves open the green-arrow tutorial; existing players can choose Settings → Replay tutorial. The normal Godot project ZIP is for editing/F5 and is not the file to upload as a browser game.

No progress reset is needed for this update. Keep the same itch.io project so existing browser saves remain associated with the same game page.

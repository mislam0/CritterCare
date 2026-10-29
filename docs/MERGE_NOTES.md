# v1.7.1 — pet update merged into the uploaded branch

The base is the supplied CritterCare.rar: v1.6.6, Git HEAD aaae9e7.
The archive's working tree was used, including its line endings and any files
outside Git. No remote repository or branch was changed.

## Added from the pet update

Six species with editable eyes, nose, mouth, ears, patterns and six colors;
first-play choice; live preview; remembered per-species designs; three saved
looks with owned outfits; Ball Play; its level-specific lesson and quiz; and
customized actors in Picnic Catch, Logic Lab and Snack Jam. New saves use
version 10 and retain version-9 manual-slot compatibility.

## Preserved from the supplied branch

- Ten themes / sixty Shop items, stable IDs, prices, and category ordering.
- Every existing artwork asset, including the current fitted accessories,
  expanded furnished room sets, templates, art source files, and fit guides.
- Room composition, clipped wallpaper, complete-set furniture behavior,
  cropped Shop previews, and pixel filtering for Pixel Knight.
- Five-point per-minute need drain; four-point petting reward with a
  thirty-second cooldown; feeding/win changes; reduced Picnic/Loop rewards.
- Updated teaching-only syntax colors, web text fixes, and export shell.
- Naming filter, save slots, tutorial, curriculum, and all six activity cards.

## Resolved overlaps

The compact home help panel retains its placement and adds the new controls.
The Shop keeps Room sets and adds Style pet. Pip's wider hamster muzzle is
preserved inside the six-species renderer. Save changes combine appearance
fields with the branch's balance constants and legacy Shop-ID migration.

The prior v1.7.0 source archive was incomplete. Its surviving source/data/docs
and intact browser build supplied the pet implementation; unchanged functions
were restored from the common source and the new functions were checked in
Godot. Tests and validation results in this release describe this merged source.

## Deliverables

CritterCare-v1.7.1.zip contains the editable CritterCare project and the current
builds/CritterCare-itchio.zip. CritterCare-itchio-v1.7.1.zip is the same browser
ZIP as a separate upload. Old duplicate browser folders, editor caches, local
saves, temporary files, and the uploaded .git history are not bundled.
The original history was used only to compare and merge changes.

To update your own checkout, copy the extracted project files over the existing
working tree while preserving your .git folder; review your diff before commit.
See VALIDATION.md for checks and browser-testing limits.

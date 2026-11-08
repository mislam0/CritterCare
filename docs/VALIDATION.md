# Validation — v1.7.2

This release makes the existing creator entry on the opening name-choice screen
an explicit green **Style pet** button. Its preview and name-draft return flow
are retained. The screen also appears after Reset and during Rename pet.

## Checks on this release

Godot 4.7.2, Compatibility renderer, a real rendered window, isolated test saves:

- Core gameplay integration: **436 checks, zero failures**.
- Naming / identity: **23 checks, zero failures**.
- Pet customization, saved looks, Ball Play and save compatibility:
  **185 checks, zero failures**.
- Total: **644 checks, zero failures**.

The name-choice screen was visually checked at 1280x800 and 960x600. Real clicks
open the creator, and applying/cancelling returns to the name field while
preserving the typed name. The existing suite also checks Reset and renaming.
Only scripts/main.gd changes gameplay UI code; the save schema, pet designs,
Shop catalog, artwork and teaching behavior are unchanged.

The browser build is freshly exported with the bundled matching single-thread
Web templates. Both final ZIPs are checked for complete archive integrity and
matching embedded/standalone browser bytes. A hosted itch.io browser playthrough
was not performed; see ITCH_IO.md for host-specific preview checks.

The broader v1.7.1 merge checks and three inherited historical artwork-validator
warnings are recorded in history/VALIDATION_v1.7.1.md. They are historical results,
not additional tests rerun for this small UI update.

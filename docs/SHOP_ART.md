# Shop artwork and fitting

The 60 main shop textures and 60 room accents are fitted against the supplied CritterCare concept
boards. Each of the ten themes now includes six additional room accents:
`left_shelf`, `side_hanging`, `window`, `right_plant`, `food_bowl`, and
`floor_cushion`. The seventh optional slot, `right_surface`, is intentionally
unused because it overlaps the plant. The purchased center wall art plus the
six accents equip together through the original `room:decor` save key.

All 60 purchase IDs, prices, theme assignments and slots remain unchanged.
Wallpaper and rugs still equip independently. No new currency or purchases are
required to use the matching room accents on a previously owned Decor Set.

## Current art direction

Use flat, front-facing accessories with simple colors. No swords, angled body garments, or dimensional top/side planes.

- Revised all ten accessory/furnishing atlases using Pip's original resting
  reference as the flat illustration guide. Scarves have level neck bands and
  balanced tails; ties and bows face straight forward. The Easter bow and the
  knight chestplate have dedicated corrected source images.
- Replaced the sword wall plaque with a navy/gold star shield and updated its
  Decor Set description. The castle wallpaper now uses plain gray blocks.
- Widened hats inside the existing 640x640 source canvas and shared transforms.
- Moved visible center-art pixels into the upper part of their unchanged
  410x396 canvas, above Pip's head, while retaining the existing room anchor.
- Shortened the home instruction card so it clears the left-shelf template.
- Clipped the wallpaper with a rounded Panel mask. The intermediate origin
  retains the native room coordinates used by every equipped texture.
- Shop thumbnails use the visible image bounds, improving small-item previews
  without changing equipped art size or position.
- Pixel Knight uses nearest-neighbor sampling and pixel grids sized for the
  displayed pet and room artwork.


## Fit and rendering

- Pet exports: 640 × 640 RGBA; shared head `(0,-115)/120`, face `(0,-46)/183`,
  neck `(0,26)/110` transforms are unchanged.
- Eyewear is fitted around Pip's actual resting eyes at local `(±32,-46)`.
  Lens openings remain transparent; sunglasses intentionally have tinted lenses.
- Wallpaper: opaque 1200 × 525. Center art: transparent 410 × 396. Rug:
  transparent 640 × 130. All six accent canvases match the room templates.
- The approved original TRUE_FIT head/face/neck guides from the supplied builder
  pack replace the later generic guides in `docs/shop_guides/`.
- Pixel Knight uses a crisp pixel grid and nearest-neighbor sampling.
- Complete room bundles hide the original base-furniture layer to prevent
  duplicate windows, bowls, pots and cushions. Unequipping restores it. Partial
  custom bundles retain the base-furniture fallback. The original base PNG is
  unchanged.

## Art sources and production

Artwork was generated with the built-in ImageGen tool using the user's three
set concept boards and decorated Bear Spirit room as visual references. Current
source atlases, retained wallpaper images, and corrected garments are in
`tools/shop_art_v1_6_24/`. The complete prompt set is `prompts.json` there.

`tools/prepare_shop_art.cjs` performs mechanical atlas separation, alpha-residue
cleanup, and sizing/positioning onto the fixed canvases. It requires Node.js
and `sharp` only when rebuilding the art; playing/editing the Godot project
does not require Node or Python. `fit-report.json` records the source regions
and destinations for all 120 final PNGs.

The historical asset importer and older art generators must not be rerun on
this revision: they would replace these fitted, revised assets with older art.

## Validation

Run the existing integration suite with isolated test saves:

```
godot --headless --path . --script res://tests/verify.gd -- --test-mode
godot --path . --script res://tests/verify_shop_art.gd -- --test-mode --capture=/absolute/folder
```

The second test purchases/equips every theme, verifies all room layers and
anchors, checks accessory animation transforms and pixel filtering, and
captures every theme plus the shop tabs. It also checks that unequipping
restores the base room. Never use a player's normal save for testing.

Browser export: run `res://tools/export_web.gd` with Godot 4.7.2 or use the
existing editor export menu. The source release includes the matching fresh
`builds/CritterCare-itchio.zip`.

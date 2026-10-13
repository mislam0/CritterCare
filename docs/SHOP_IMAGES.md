# Add image accessories and decorations

All 36 existing themed items and their PNGs are preserved. No vector drawing is needed for new Shop items.

## Quick method: the image helper

Open a terminal in the extracted CritterCare folder. With Python installed, run:

```sh
python tools/add_shop_item.py
```

Answer the prompts for the PNG path, item name, category, slot, theme, gold price, and a short description. The helper copies the image unchanged into the correct folder and adds the catalog entry automatically. Existing IDs and images cannot be overwritten. It keeps the original catalog in `data/shop.gd.before_image_import` the first time it runs.

Or provide everything in one command:

```sh
python tools/add_shop_item.py --image "C:/Users/YourName/Pictures/sparkle_hat.png" --name "Sparkle Hat" --category pet --slot head --theme nature --price 80 --description "A cheerful hat with little stars."
```

Add `--dry-run` to check your input without writing anything. Use `--id sparkle_hat` if you want to choose the permanent save ID. Keep that ID stable after players buy the item.

## Use the shared canvases

| Category | Slot | PNG canvas | Placement |
| --- | --- | --- | --- |
| pet | head | 640 × 640 | Hat/head position |
| pet | face | 640 × 640 | Glasses/mask position |
| pet | neck | 640 × 640 | Bow/collar position |
| room | wall | 1200 × 525 | Wallpaper |
| room | decor | 410 × 396 | Center room decoration |
| room | rug | 640 × 130 | Floor rug |

Use transparent backgrounds for accessories, room decorations, and rugs. Paint within the same canvas and alignment as an existing item in the matching slot; the helper checks canvas size but cannot decide whether artwork covers Pip's eyes or sits at the right height. It does not resize, crop, or generate images. See [the Paint.NET guide](PAINTNET_ASSET_GUIDE.md) for art alignment.

Themes: `nature`, `study`, `smart_casual`, `halloween`, `christmas`, `pixel_knight`. Extra items appear in additional rows inside that theme. The original six sets remain intact.

After adding an item, let Godot finish importing, press **F5**, and check Shop → Pet accessories or Room decorations. Buy and equip it to check its real placement. Run `python tools/validate_shop_rebuild.py` to check catalog/image consistency. Then use **Project → Tools → Export CritterCare for itch.io** and replace your itch.io upload with the new ZIP.

You can still edit `data/shop.gd` directly. The helper is optional and is not needed to play or export the game.

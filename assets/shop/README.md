# Critter Care themed Shop assets


## Folder organization

Artwork is grouped by **where it is equipped or placed**, not by theme. Every existing
theme remains in `data/shop.gd`, so the in-game Shop layout is unchanged.

```text
assets/shop/
├── pet/
│   ├── head/      Hats, caps, and the knight plume (10 PNGs)
│   ├── face/      Glasses, masks, and the knight helmet (10 PNGs)
│   └── neck/      Scarves, bows, ties, and the chestplate (10 PNGs)
└── room/
    ├── wall/      Wallpapers (10 PNGs)
    ├── decor/     Main artwork for the 10 Decor Sets
    ├── decor_sets/ Optional themed PNG overlays for Decor Sets
    └── rug/       Rugs (10 PNGs)
```

Each PNG stays alongside its Godot `.png.import` metadata. Item IDs, themes,
prices, save keys, art dimensions, and placement offsets remain unchanged.
When adding an item, run `python tools/add_shop_item.py` to place its image in
the correct slot folder and register its texture path in the Shop catalog.

The Shop is rebuilt around ten complete themes:

1. Nature
2. Study
3. Smart Casual
4. Halloween
5. Christmas
6. Pixel Knight
7. Easter
8. Brainrot
9. Thanksgiving
10. Bear Spirit

The original items contribute one 3-card row per theme to each Shop tab. New items can add more rows:

- **Pet Accessories:** Head · Face · Neck
- **Room sets:** Wallpaper · Decor Set · Rug

All Shop artwork is PNG-backed and catalogued in `data/shop.gd`. Pet PNGs should be large transparent source images and are downscaled by `hamster.gd`. Room art uses one standardized template for each slot: wallpaper **1200×525**, main Decor Set wall art **410×396**, rug **640×130**. Pet art is always **640×640** with shared slot scales/positions; no per-item render offsets or room rectangles are used.

`Shop.THEME_ORDER` controls row order. `Shop.THEMES` controls the visible set title/tagline. Every item has a `theme`, `category`, and `slot`, allowing the UI to build the rows automatically.

To add an existing PNG without editing GDScript by hand, run `python tools/add_shop_item.py`. It copies the image unchanged and registers category, slot, theme, price, and description. See [the image helper guide](../../docs/SHOP_IMAGES.md).

## Current artwork

Use flat, front-facing shapes, simple colors, and no swords. Keep Pixel Knight
pixelated. Each Decor Set includes six matching room accents.

See [the art guide](../../docs/SHOP_ART.md) for sources and production, and
[the fitting guides](../../docs/SHOP_FIT_GUIDES.md) for fixed canvases.
Historical generators must not overwrite the current artwork. Stable purchase
IDs can differ from visible item names; preserve them for saved purchases.

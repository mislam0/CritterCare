# Critter Care themed Shop assets

The Shop is rebuilt around six complete themes:

1. Nature
2. Study
3. Smart Casual
4. Halloween
5. Christmas
6. Pixel Knight

The original items contribute one 3-card row per theme to each Shop tab. New items can add more rows:

- **Pet Accessories:** Head · Face · Neck
- **Room Decorations:** Wallpaper · Room Decor · Rug

All Shop artwork is PNG-backed and catalogued in `data/shop.gd`. Pet PNGs should be large transparent source images and are downscaled by `hamster.gd`. Room art uses one standardized template for each slot: wallpaper **1200×525**, room decoration **410×396**, rug **640×130**. Pet art is always **640×640** with shared slot scales/positions; no per-item render offsets or room rectangles are used.

`Shop.THEME_ORDER` controls row order. `Shop.THEMES` controls the visible set title/tagline. Every item has a `theme`, `category`, and `slot`, allowing the UI to build the rows automatically.

To add an existing PNG without editing GDScript by hand, run `python tools/add_shop_item.py`. It copies the image unchanged and registers category, slot, theme, price, and description. See [the image helper guide](../../docs/SHOP_IMAGES.md).

# Critter Care themed Shop assets

The Shop is rebuilt around six complete themes:

1. Nature
2. Study
3. Smart Casual
4. Halloween
5. Christmas
6. Pixel Knight

Each theme contributes exactly one 3-card row to each Shop tab:

- **Pet Accessories:** Head · Face · Neck
- **Room Decorations:** Wallpaper · Room Decor · Rug

All Shop artwork is PNG-backed and catalogued in `data/shop.gd`. Pet PNGs should be large transparent source images and are downscaled by `hamster.gd`. Room art uses one standardized template for each slot: wallpaper **1200×525**, room decoration **410×396**, rug **640×130**. Pet art is always **640×640** with shared slot scales/positions; no per-item render offsets or room rectangles are used.

`Shop.THEME_ORDER` controls row order. `Shop.THEMES` controls the visible set title/tagline. Every item has a `theme`, `category`, and `slot`, allowing the UI to build the rows automatically.

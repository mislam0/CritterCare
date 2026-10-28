# Critter Care — Paint.NET-style shop art (consolidated v1.6.2)

The shop's entire six-theme wardrobe is now made for easy Paint.NET editing.
Smart Casual establishes the flat, shape-based style. Nature, Study, Halloween,
Christmas, and Pixel Knight complete the unified six-theme Shop.

## Art rules

- Flat, solid colours, bold outer outlines, simple circles/polygons/line details.
- No complex gradients, fabric texture, painterly shading, or tiny detail.
- Keep transparent alpha on accessories/decorations/rugs. Wallpaper is opaque.
- For the **Pixel Knight** theme alone, use nearest-neighbor resizing and a
  regular pixel grid. Godot now samples Knight sprites, shop previews and room
  items with nearest-neighbor filtering; all other themes remain linear.
- Avoid changing canvas size or shifting the entire asset within the canvas;
  source art position directly controls on-Pip placement.

## Correct sizes and positions

- Head / Face / Neck: **640x640 RGBA** each. Runtime layout is shared: head
  offset (0,-115), width 120; face offset (0,-46), width 183; neck offset
  (0,26), width 110. Do not add per-item offsets.
- Wallpaper: **1200x525 RGBA** (opaque content).
- Decor Set main wall art: **410x396 RGBA** (transparent background), artwork centered horizontally on the canvas. The shared slot begins at (435,164) on a 1280x800 room, placing the canvas center at room x=640.
- Rug: **640x130 RGBA** (transparent background).

## User-provided references and approved fitting

- `assets/shop/pet/head/red_cap.png`
- `assets/shop/pet/face/sunglasses.png`
- `assets/shop/pet/head/pumpkin_hat.png`
- `assets/shop/pet/face/pumpkin_mask.png` (existing `bat_mask` save ID, shown as Pumpkin Mask)
- `assets/shop/pet/head/pixel_knight_plume.png` (existing `pixel_visor` save ID, cleaned Pixel Knight Plume)
- `assets/shop/pet/face/pixel_knight_helmet.png` (existing `pixel_chestplate` save ID, cleaned and refitted)
- `assets/shop/pet/neck/pixel_knight_chest.png` (existing `pixel_chestplate` save ID, cleaned and refitted)

The approved Pixel Knight art is refitted to the tested visible bounds rather than
left byte-for-byte identical. Save IDs, shop row order, prices, slots, save handling,
and canonical slot positions are unchanged. Room artwork uses the original three room templates.

## Checking in Godot

Open `project.godot` in Godot 4.7.2, run F5, equip each complete pet outfit,
and apply each set's wallpaper / decor / rug. These preview templates are
static simulations; native runtime was unavailable in the packaging environment.

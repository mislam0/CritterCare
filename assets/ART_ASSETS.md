# Critter Care art assets

Critter Care's reusable interface/game artwork is PNG-backed. Runtime scripts move, scale, tint, show, and hide image nodes; they do not redraw these assets with `_draw()`.

## UI icons

`assets/ui/icons/` contains the images used by `scripts/icon.gd`. Existing callers still create `Icon.new()` and set `kind`, so replacing an icon does not require changing the screens that use it.

Recommended source size: **96 × 96**, transparent PNG. Keep the important artwork away from the outer 4 px so it remains readable at the 27–48 px sizes used by the game. `icon.gd` ignores the native texture minimum before any caller assigns its rectangle, so the PNG never forces a 96 px UI control.


## Pip Shop accessories

`assets/shop/pet/` contains high-resolution, tightly cropped transparent PNGs. They are deliberately larger than their final display size and are downscaled on Pip. Final width/placement comes from `data/shop.gd` (`render_width` / optional `render_offset`), not from assuming a particular source canvas size. This keeps thin art such as the glasses and bow tie crisp and makes future replacement art easier.

## Base room

`assets/room/base/` is layered so Shop room decorations still work:

- `room_backdrop.png` — 1280 × 800, outer background and base wall area.
- `default_wallpaper.png` — 1200 × 525, transparent default wall pattern.
- `room_floor.png` — 1280 × 800 transparent floor layer.
- `default_rug.png` — 640 × 140 transparent starter rug.
- `room_furniture.png` — 1280 × 800 transparent window, shelf, plants, cushion, and bowl.

Shop wallpapers, room decor, and rugs come from `assets/shop/room/` and are layered by `scripts/room.gd`. The themed Shop intentionally exposes only these three room slots.

## Picnic Catch

`assets/minigames/picnic/background.png` is **646 × 367**. `basket.png` is transparent and is moved by the existing catch logic. Falling snacks use the PNG icons from `assets/ui/icons/`.

## Snack Jam

`assets/minigames/snack_jam/` contains the three lane images, three falling-note images, the stage base/glow, hit-feedback ring, and beat dot. The rhythm controller still owns note timing and movement; changing the PNGs does not change the chart.

- `lane_0.png`, `lane_1.png`, `lane_2.png` — 188 × 340
- `note_0.png`, `note_1.png`, `note_2.png` — 74 × 42
- `stage_base.png`, `stage_glow.png` — 353 × 357
- `hit_feedback_ring.png` — 64 × 64
- `beat_dot.png` — 20 × 20

## Logic Lab

`assets/minigames/logic_lab/seed_jar.png` is **108 × 110** and `seed.png` is **16 × 16**. The Lab creates up to 20 seed image nodes and toggles them as the program state changes.

## Adding/replacing art

For a replacement, keep the same filename and canvas size; no GDScript change is needed. If a new gameplay item needs a new filename or category, add its texture to the relevant catalog/controller rather than adding drawing code.

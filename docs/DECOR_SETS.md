# CritterCare — Decor Sets

**All ten sets include finished art.** See [the shop art guide](SHOP_ART.md).
The game supports coordinated decor bundles in place of the former single wall-decoration layer. Base `assets/room/base/room_furniture.png` remains unchanged; complete furnished bundles replace its visible layer while equipped, and unequipping restores it. Partial custom bundles retain the original furniture fallback.

## Fixed positions (1280 × 800 room coordinates)

| Piece | Top-left (x, y) | PNG canvas | Where it appears |
|---|---|---|---|
| `main_wall` | (435, 164) | 410 × 396 | Central wall artwork, fitted above Pip for every theme. |
| `left_shelf` | (98, 315) | 200 × 155 | On and above the existing left shelf |
| `side_hanging` | (850, 302) | 95 × 150 | Small wall hanging near the right side |
| `right_surface` | (1014, 384) | 190 × 205 | Generic right-side accent / prop |
| `window` | (930, 174) | 242 × 222 | Window frame / scene overlay |
| `right_plant` | (1036, 378) | 154 × 224 | Potted plant on the right |
| `food_bowl` | (883, 510) | 114 × 64 | Little bowl beside the rug |
| `floor_cushion` | (86, 501) | 171 × 92 | Small floor cushion / floor prop |

Accent assets appear behind Pip. Complete furnished sets replace the visible base-furniture layer; partial custom sets retain the fallback. Background MUST be transparent, flat colored, and free of guide lines. Avoid drawing outside the designated bounds, and keep silhouettes uncluttered; leave the background room furniture visible when possible.

**To customize decorations**, copy any template PNG from `docs/decor_set_templates/` into `assets/shop/room/decor_sets/<theme>/` and paint your artwork on the same canvas, preserving its dimensions. Empty templates are invisible; you may leave pieces out until designed. Godot 4.7.2 imports the PNGs when you reopen the project. Each set uses its existing center wall PNG, so you do NOT need to recreate that asset unless you want to redesign it later.

The ten folder names are `nature`, `study`, `smart_casual`, `halloween`, `christmas`, `pixel_knight`, `easter`, `brainrot`, `thanksgiving`, and `bear_spirit`.

**Save compatibility:** all original `room:decor` save keys and catalog item IDs remain unchanged, so owning and equipping a previously purchased wall decoration equips its corresponding entire Decor Set; wallpaper and rug are independent. Prices are unchanged.

**Technical:** optional assets are loaded only when present at `res://assets/shop/room/decor_sets/<theme>/<piece>.png`; the center decoration retains its current Shop texture and 410 × 396 position. The set uses the existing image as its shop thumbnail. Pixel Knight overlays use nearest-neighbor sampling.

**Validation:** `python tools/validate_decor_sets.py`. Godot GUI and export must be tested in the editor, not inferred from the static validator.

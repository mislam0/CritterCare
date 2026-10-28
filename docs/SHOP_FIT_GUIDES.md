# Critter Care Shop fitting guides — current standardized layout

**These are reference guides, never layers to export into game textures.** Paint onto a new transparent layer, hide the guide, then export the FULL canvas (do not crop). Keep the existing shared offsets and dimensions in `data/shop.gd`.

| Slot | Canvas | In-game layout | Reference file |
| --- | --- | --- | --- |
| Head | 640 × 640 RGBA, transparent | offset `(0,-115)`, width `120` | `shop_guides/HEAD_REFERENCE_640.png` |
| Face | 640 × 640 RGBA, transparent | offset `(0,-46)`, width `183` | `shop_guides/FACE_REFERENCE_640.png` |
| Neck | 640 × 640 RGBA, transparent | offset `(0,26)`, width `110` | `shop_guides/NECK_REFERENCE_640.png` |
| Wallpaper | 1200 × 525, **opaque** | `Rect2(40,138,1200,525)` | `shop_guides/WALL_REFERENCE_1200x525.png` |
| Decor Set (center wall art) | 410 × 396 RGBA, transparent | `Rect2(435,164,410,396)` | `shop_guides/DECOR_REFERENCE_410x396.png` |
| Rug | 640 × 130 RGBA, transparent | `Rect2(320,500,640,130)` | `shop_guides/RUG_REFERENCE_640x130.png` |

### Important placement rules

- **Pip accessories:** all three slot PNGs use the same 640×640 source canvas but DIFFERENT display widths/offsets. Fit the artwork inside the full template, not at the top-left of a cropped image. Position artwork around Pip's actual body features, not only the alpha bounding box.
- **Decor Set center art:** center visible pixels at source x≈205; placing the canvas at room x=435 puts the center at room x=640.
- **Rugs:** center visible pixels at source x≈320; placing the canvas at room x=320 puts the center at x=640.
- **Wallpapers:** completely fill their template without transparency.
- **Pixel Knight:** retain pixel-grid drawing and nearest-neighbor sampling. Other sets use simple smooth outlines, flat colors, little or no shading, and transparent backgrounds where needed.
- Do not restore historical per-item widths or offsets. Use the original TRUE_FIT reference images bundled here with this project's shared transforms in `data/shop.gd`.
- In-game animations vary slightly; after updating an accessory, run the game and equip all three pieces together to check for overlap.

Run `python tools/validate_shop_guides.py` followed by the existing shop and fit validators to check canvases, alignment and visibility. Static checks do not substitute for Godot F5 playtesting.

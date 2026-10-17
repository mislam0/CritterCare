#!/usr/bin/env python3
"""Check decor-set positioning, stable save IDs, and optional artist PNGs."""
from pathlib import Path
from PIL import Image
import re
import sys

root = Path(__file__).resolve().parents[1]
shop = (root / 'data/shop.gd').read_text()
room = (root / 'scripts/room.gd').read_text()
save = (root / 'scripts/save_data.gd').read_text()
errors = []
expected = {
    'main_wall': (435, 164, 410, 396),
    'left_shelf': (98, 315, 200, 155),
    'side_hanging': (850, 302, 95, 150),
    'right_surface': (1014, 384, 190, 205),
    'window': (930, 174, 242, 222),
    'right_plant': (1036, 378, 154, 224),
    'food_bowl': (883, 510, 114, 64),
    'floor_cushion': (86, 501, 171, 92),
}

for name, rect in expected.items():
    literal = '"%s": {"rect":Rect2(%s)}' % (name, ','.join(map(str, rect)))
    if literal not in shop:
        errors.append('Incorrect decor anchor: ' + name)
    template = root / 'docs/decor_set_templates' / (name + '.png')
    if template.exists():
        im = Image.open(template)
        if im.size != rect[2:]:
            errors.append('Wrong doc template size: ' + name)
    elif name != 'main_wall':
        errors.append('Missing optional artist template: ' + name)
    if name != 'main_wall' and 'DecorSet_' not in room:
        errors.append('Decor set layers missing from room')

items = shop.count('\"category\":\"room\", \"slot\":\"decor\"')
if items != 10:
    errors.append('Expected ten existing decor IDs: %d' % items)

if 'Shop.decor_set_piece_path' not in room or 'ResourceLoader.exists' not in room:
    errors.append('No optional PNG loading')
if 'ROOM_FURNITURE' not in room:
    errors.append('Base furniture missing')
if '"room:decor"' not in save and '"room:decor"' not in (root / 'tests/verify.gd').read_text():
    errors.append('Missing saved decor slot evidence')

for theme in ('nature', 'study', 'smart_casual', 'halloween', 'christmas', 'pixel_knight', 'easter', 'brainrot', 'thanksgiving', 'bear_spirit'):
    folder = root / 'assets/shop/room/decor_sets' / theme
    if not folder.is_dir():
        errors.append('Missing themed bundle folder: ' + theme)
    for k, (_, _, w, h) in expected.items():
        if k == 'main_wall':
            continue
        p = folder / (k + '.png')
        if p.is_file() and Image.open(p).size != (w, h):
            errors.append('Bad optional artwork dimensions: ' + str(p))

if errors:
    print('Decor-set validation FAILED:')
    for error in errors:
        print(' - ' + error)
    sys.exit(1)
print('Decor-set validation passed: 10 purchased decor IDs, 8 stable anchors, optional PNG dimensions and furniture preserved.')

#!/usr/bin/env python3
"""Check that every themed Room Decoration art centers on the shared wall slot."""
from pathlib import Path
from PIL import Image
import re
import sys

root = Path(__file__).resolve().parents[1]
shop = (root / 'data/shop.gd').read_text()
room = (root / 'scripts/room.gd').read_text()
items = [
    'hanging_plant',
    'study_bookshelf',
    'wall_clock',
    'jack_o_lantern',
    'wreath',
    'pixel_castle_banner',
]
errors = []
if '"decor":{"rect":Rect2(435,164,410,396)}' not in shop:
    errors.append('Room decor rect must be x=435, width=410, centered at x=640')
if 'Shop.ROOM_SLOT_LAYOUT["decor"].rect' not in room:
    errors.append('Room decoration initial rect is not sourced from shared shop layout')
if 'node.position = layout.rect.position' not in room:
    errors.append('Equipped decorations do not use shared shop rectangle')
for name in items:
    path = root / 'assets/shop/room' / f'{name}.png'
    with Image.open(path) as src:
        im = src.convert('RGBA')
        if im.size != (410, 396):
            errors.append(f'{name}: incorrect size {im.size}')
        bbox = im.getchannel('A').getbbox()
        if bbox is None:
            errors.append(f'{name}: empty artwork')
            continue
        actual = 435 + (bbox[0] + bbox[2]) / 2
        if abs(actual - 640) > 0.5:
            errors.append(f'{name}: visual horizontal center {actual} != 640')
        print(f'{name:20s}: center x={actual:5.1f}; alpha bbox={bbox}')
if errors:
    print('Room decor center validation FAILED:')
    for message in errors:
        print(' -', message)
    sys.exit(1)
print('Room decor center validation passed: all six decorations visually centered on x=640.')

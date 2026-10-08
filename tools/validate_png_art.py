#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
import re, sys

ROOT = Path(__file__).resolve().parents[1]
NO_DRAW = [
    ROOT/'scripts/icon.gd',
    ROOT/'scripts/room.gd',
    ROOT/'scripts/picnic.gd',
    ROOT/'scripts/snack_jam.gd',
    ROOT/'scripts/logic_lab_screen.gd',
]
REQUIRED = {
    'assets/room/base/room_backdrop.png': (1280,800),
    'assets/room/base/default_wallpaper.png': (1200,525),
    'assets/room/base/room_floor.png': (1280,800),
    'assets/room/base/default_rug.png': (640,140),
    'assets/room/base/room_furniture.png': (1280,800),
    'assets/minigames/picnic/background.png': (646,367),
    'assets/minigames/picnic/basket.png': (116,46),
    'assets/minigames/logic_lab/seed_jar.png': (108,110),
    'assets/minigames/logic_lab/seed.png': (16,16),
    'assets/minigames/snack_jam/lane_0.png': (188,340),
    'assets/minigames/snack_jam/lane_1.png': (188,340),
    'assets/minigames/snack_jam/lane_2.png': (188,340),
    'assets/minigames/snack_jam/note_0.png': (74,42),
    'assets/minigames/snack_jam/note_1.png': (74,42),
    'assets/minigames/snack_jam/note_2.png': (74,42),
    'assets/minigames/snack_jam/stage_base.png': (353,357),
    'assets/minigames/snack_jam/stage_glow.png': (353,357),
    'assets/minigames/snack_jam/hit_feedback_ring.png': (64,64),
    'assets/minigames/snack_jam/beat_dot.png': (20,20),
}
for name in ['music','basket','leaf','golden_seed','berry','coin','shop','spoiled_berry','seed','carrot','book','code','game','heart','star','paw','stone','button','blueberry','default']:
    REQUIRED[f'assets/ui/icons/{name}.png'] = (96,96)


PET_ACCESSORIES = [
    'leaf_hat','flower_clip','vine_scarf',
    'scholar_cap','glasses','bow',
    'flat_cap','sunglasses','necktie',
    'pumpkin_hat','bat_mask','halloween_scarf',
    'santa_hat','red_nose','holiday_scarf',
    'pixel_knight_helmet','pixel_visor','pixel_chestplate',
]


errors=[]
for path in NO_DRAW:
    text=path.read_text(encoding='utf-8')
    if re.search(r'\bfunc\s+_draw\s*\(', text) or re.search(r'\bdraw_[A-Za-z0-9_]+\s*\(', text):
        errors.append(f'procedural draw call remains in {path.relative_to(ROOT)}')

for rel, expected in REQUIRED.items():
    path=ROOT/rel
    if not path.is_file():
        errors.append(f'missing {rel}')
        continue
    try:
        with Image.open(path) as im:
            im.verify()
        with Image.open(path) as im:
            if im.size != expected:
                errors.append(f'{rel}: expected {expected}, got {im.size}')
            if im.format != 'PNG':
                errors.append(f'{rel}: expected PNG, got {im.format}')
    except Exception as exc:
        errors.append(f'{rel}: cannot decode: {exc}')


# Pip accessories should be high-resolution, tightly cropped source art that is
# downscaled in-game. This prevents thin shapes from being blurred by enlargement.
for name in PET_ACCESSORIES:
    rel=f'assets/shop/pet/{name}.png'
    path=ROOT/rel
    if not path.is_file():
        errors.append(f'missing {rel}')
        continue
    try:
        with Image.open(path).convert('RGBA') as im:
            bbox=im.getbbox()
            if im.width < 300 or im.height < 180:
                errors.append(f'{rel}: source is too small for crisp downscaling: {im.size}')
            if not bbox:
                errors.append(f'{rel}: image is fully transparent')
    except Exception as exc:
        errors.append(f'{rel}: cannot decode: {exc}')

# Icon expand behavior must be configured before callers assign their 27-48 px rects.
icon_text=(ROOT/'scripts/icon.gd').read_text(encoding='utf-8')
init_pos=icon_text.find('func _init()')
expand_pos=icon_text.find('expand_mode = TextureRect.EXPAND_IGNORE_SIZE')
ready_pos=icon_text.find('func _ready()')
if init_pos < 0 or expand_pos < init_pos or (ready_pos >= 0 and expand_pos > ready_pos):
    errors.append('scripts/icon.gd must set EXPAND_IGNORE_SIZE in _init() before _ready()')

# Pip accessory runtime must derive scale from source width, not upscale a fixed canvas.
hamster_text=(ROOT/'scripts/hamster.gd').read_text(encoding='utf-8')
if 'sprite.texture.get_width()' not in hamster_text or 'layout.width' not in hamster_text:
    errors.append('scripts/hamster.gd must size pet PNGs from source texture width and catalog display width')

# Every res:// PNG preload in edited runtime files must point to a real file.
for path in NO_DRAW:
    text=path.read_text(encoding='utf-8')
    for rel in re.findall(r'preload\("res://([^\"]+\.png)"\)', text):
        if not (ROOT/rel).is_file():
            errors.append(f'{path.relative_to(ROOT)} references missing {rel}')

if errors:
    print('PNG art validation FAILED')
    for e in errors: print(' -',e)
    sys.exit(1)
print(f'PNG art validation passed: {len(REQUIRED)} required PNGs; requested runtime scripts contain no custom draw calls.')

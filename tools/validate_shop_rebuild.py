#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
import re, sys, collections

ROOT=Path(__file__).resolve().parents[1]
SHOP=ROOT/'data/shop.gd'
text=SHOP.read_text(encoding='utf-8')
errors=[]
pat=re.compile(r'^\s*"([^"]+)":\{"name":"([^"]+)", "theme":"([^"]+)", "category":"(pet|room)", "slot":"([^"]+)"',re.M)
entries=[m.groups() for m in pat.finditer(text)]
if len(entries)!=60: errors.append(f'expected exactly 60 Shop items, found {len(entries)}')
slot_counts=collections.Counter((x[3],x[4]) for x in entries)
expected={('pet','head'):10,('pet','face'):10,('pet','neck'):10,('room','wall'):10,('room','decor'):10,('room','rug'):10}
for key,count in expected.items():
    if slot_counts[key]<count: errors.append(f'{key}: expected {count}, got {slot_counts[key]}')
for theme in ['nature','study','smart_casual','halloween','christmas','pixel_knight','easter','brainrot','thanksgiving','bear_spirit']:
    for cat in ['pet','room']:
        got=sum(1 for x in entries if x[2]==theme and x[3]==cat)
        if got<3: errors.append(f'{theme}/{cat}: expected at least 3 items, got {got}')
paths=re.findall(r'preload\("res://(assets/shop/[^"\)]+)"\)',text)
if len(paths)!=len(entries): errors.append(f'expected {len(entries)} Shop PNG references, found {len(paths)}')
for item_id, name, theme, cat, slot in entries:
    line=next((l for l in text.splitlines() if l.lstrip().startswith('"'+item_id+'":')), '')
    texture=re.search(r'"texture":preload\("res://(assets/shop/[^"\)]+)"\)',line)
    if not texture or not texture.group(1).startswith(f'assets/shop/{cat}/{slot}/'):
        errors.append(f'{item_id}: PNG is not inside {cat}/{slot} category folder')

for rel in paths:
    importer=ROOT/(rel+'.import')
    if not importer.is_file():
        errors.append(f'missing Godot .import sidecar: {rel}.import')
    elif f'source_file="res://{rel}"' not in importer.read_text(encoding='utf-8'):
        errors.append(f'outdated Godot source path in .import: {rel}')
    path=ROOT/rel
    if not path.is_file():
        errors.append(f'missing {rel}'); continue
    try:
        with Image.open(path) as im:
            im.verify()
    except Exception as exc:
        errors.append(f'{rel}: cannot decode: {exc}')
shop_pngs=sorted(str(p.relative_to(ROOT)) for p in (ROOT/'assets/shop').rglob('*.png'))
if sorted(paths)!=shop_pngs:
    for rel in sorted(set(shop_pngs)-set(paths)): errors.append(f'orphan Shop PNG: {rel}')
    for rel in sorted(set(paths)-set(shop_pngs)): errors.append(f'catalog PNG missing from folder scan: {rel}')
main=(ROOT/'scripts/main.gd').read_text(encoding='utf-8')
if 'Shop.THEME_ORDER' not in main or 'ShopCards_' not in main: errors.append('Shop UI is not building theme rows')
room=(ROOT/'scripts/room.gd').read_text(encoding='utf-8')
for stale in ['"garland"','"light"']:
    if stale in room: errors.append(f'old room slot still active in room.gd: {stale}')
if '"decor"' not in room: errors.append('new room decor slot missing from room.gd')
if errors:
    print('Themed Shop validation FAILED')
    for e in errors: print(' -',e)
    sys.exit(1)
print(f'Themed Shop validation passed: 10 themes, {len(entries)} catalog items, {len(paths)} referenced PNGs, no orphan Shop PNGs.')

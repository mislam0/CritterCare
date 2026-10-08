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
if len(entries)!=36: errors.append(f'expected 36 Shop items, found {len(entries)}')
slot_counts=collections.Counter((x[3],x[4]) for x in entries)
expected={('pet','head'):6,('pet','face'):6,('pet','neck'):6,('room','wall'):6,('room','decor'):6,('room','rug'):6}
for key,count in expected.items():
    if slot_counts[key]!=count: errors.append(f'{key}: expected {count}, got {slot_counts[key]}')
for theme in ['nature','study','smart_casual','halloween','christmas','pixel_knight']:
    for cat in ['pet','room']:
        got=sum(1 for x in entries if x[2]==theme and x[3]==cat)
        if got!=3: errors.append(f'{theme}/{cat}: expected 3 items, got {got}')
paths=re.findall(r'preload\("res://(assets/shop/[^"\)]+)"\)',text)
if len(paths)!=36: errors.append(f'expected 36 Shop PNG references, found {len(paths)}')
for rel in paths:
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
print('Themed Shop validation passed: 6 themes, 36 catalog items, 36 referenced PNGs, no orphan Shop PNGs.')

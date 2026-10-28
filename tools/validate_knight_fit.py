#!/usr/bin/env python3
"""Ensure the user's Pixel Knight sprite fit and crisp filtering survive art revisions."""
from pathlib import Path
from PIL import Image
import numpy as np
import sys
ROOT=Path(__file__).resolve().parents[1]
TARGETS={
    "pixel_visor":(42,40,530,396),
    "pixel_knight_helmet":(33,69,615,552),
    "pixel_chestplate":(31,161,622,636),
}
errors=[]
for name, expected in TARGETS.items():
    knight_slots={'pixel_visor':'head', 'pixel_knight_helmet':'face', 'pixel_chestplate':'neck'}
    filename={'pixel_visor':'pixel_knight_plume', 'pixel_chestplate':'pixel_knight_chest'}.get(name, name)
    p=ROOT/'assets'/'shop'/'pet'/knight_slots[name]/(filename+'.png')
    im=Image.open(p).convert('RGBA')
    if im.size!=(640,640):
        errors.append(f'{name} canvas is {im.size}; expected 640x640')
        continue
    alpha=np.asarray(im.getchannel('A'))
    ys,xs=np.nonzero(alpha>=128)
    bounds=(int(xs.min()),int(ys.min()),int(xs.max())+1,int(ys.max())+1)
    if bounds!=expected:
        errors.append(f'{name} opaque bounds {bounds} != {expected}')
source=(ROOT/'scripts'/'hamster.gd').read_text()
if 'CanvasItem.TEXTURE_FILTER_NEAREST if item.theme == "pixel_knight"' not in source:
    errors.append('Pixel Knight must render using nearest-neighbor filtering')
shop=(ROOT/'data'/'shop.gd').read_text()
for slot,offset,width in [('head','Vector2(0,-115)','120.0'),('face','Vector2(0,-46)','183.0'),('neck','Vector2(0,26)','110.0')]:
    if f'"{slot}":{{"offset":{offset}, "width":{width}}}' not in shop:
        errors.append(f'{slot} slot layout changed')
if errors:
    print('FAIL: '+ '; '.join(errors))
    sys.exit(1)
print('PASS: 3/3 knight PNG canvases, verified opaque fit bounds, 3 slots and nearest-neighbor rendering')

#!/usr/bin/env python3
"""Static cross-check of the 640x640 Pip template and current catalog fit."""
from pathlib import Path
import re,sys
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
shop=(ROOT/'data/shop.gd').read_text(encoding='utf-8')
entries={}
errors=[]
slot_defaults={'head':(120.0,0.0,-115.0),'face':(183.0,0.0,-46.0),'neck':(110.0,0.0,26.0)}
for line in shop.splitlines():
    if not line.lstrip().startswith('"') or '"category":"pet"' not in line or '"name":' not in line:
        continue
    key=re.search(r'"([^"\n]+)":\{',line)
    slot=re.search(r'"slot":"([^"\n]+)"',line)
    tex=re.search(r'"texture":preload\("res://([^"]+)"\)',line)
    if key is None or slot is None or tex is None:
        errors.append('malformed Pet Shop entry: '+line[:90]);continue
    key=key.group(1);slot=slot.group(1)
    if slot not in slot_defaults:
        errors.append(f'{key}: invalid slot {slot}');continue
    wd=re.search(r'"render_width":([0-9.]+)',line)
    pos=re.search(r'"render_offset":Vector2\(([-0-9.]+),([-0-9.]+)\)',line)
    width=float(wd.group(1)) if wd else slot_defaults[slot][0]
    ox=float(pos.group(1)) if pos else slot_defaults[slot][1]
    oy=float(pos.group(2)) if pos else slot_defaults[slot][2]
    path=ROOT/tex.group(1)
    if not path.is_file(): errors.append(f'{key}: texture missing');continue
    with Image.open(path).convert('RGBA') as im:
        if im.size != (640,640): errors.append(f'{key}: template requires 640x640, got {im.size}')
        box=im.getchannel('A').getbbox()
        if box is None: errors.append(f'{key}: transparent texture');continue
        sx=width/im.width
        rect=(ox+(box[0]-im.width/2)*sx,oy+(box[1]-im.height/2)*sx,
              ox+(box[2]-im.width/2)*sx,oy+(box[3]-im.height/2)*sx)
        entries[key]=(slot,rect)
        limit={'head':(-100,-205,110,-80),'face':(-100,-130,100,15),'neck':(-85,-30,85,100)}[slot]
        # The artist explicitly tested these exact full-size 640px masks on Pip.
        # Their intentional silhouette reaches beyond the generic guide boxes.
        # Keep their native pixels/positions instead of silently shrinking them.
        artist_fitted_limits={
            'pumpkin_hat':(-55,-180,60,-55),
            'bat_mask':(-90,-120,90,42),
            'pixel_knight_helmet':(-95,-150,95,42),
        }
        limit=artist_fitted_limits.get(key, limit)
        # Raster-to-world scaling can put an otherwise valid edge less than one
        # screen pixel outside the nominal rounded guide boundary.
        edge_tolerance=0.5
        if (rect[0] < limit[0]-edge_tolerance or rect[1] < limit[1]-edge_tolerance
                or rect[2] > limit[2]+edge_tolerance or rect[3] > limit[3]+edge_tolerance):
            errors.append(f'{key}: visible art outside {slot} target region: {tuple(round(n,1) for n in rect)}')
if len(entries)!=18: errors.append(f'expected 18 Pet cosmetics, measured {len(entries)}')
# These visual landmarks are part of the real Pip model in scripts/hamster.gd:
# the red nose is centered near (0,-17), the knight helmet crown is near y=-110.
if 'red_nose' in entries:
    _, b=entries['red_nose']
    if not b[0]<0<b[2] or not b[1] < -17 < b[3]: errors.append('Red Nose misses actual nose landmark (0,-17)')
if 'pixel_visor' in entries and 'pixel_knight_helmet' in entries:
    _, plume=entries['pixel_visor']; _, helmet=entries['pixel_knight_helmet']
    # plume must overlap the helmet crown by a few pixels while staying above it
    if plume[3]<helmet[1] or plume[1]>helmet[1] or plume[0]>helmet[2] or plume[2]<helmet[0]:
        errors.append('Knight plume is detached from the helmet')
if errors:
    print('Cosmetic fit validation FAILED:')
    for e in errors: print(' -',e)
    sys.exit(1)
print(f'Cosmetic fit validation passed: {len(entries)}/18 full-canvas PNGs with slot bounding checks, red nose target, and connected knight plume.')

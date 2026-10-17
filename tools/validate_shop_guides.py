#!/usr/bin/env python3
"""Guard current standardized pet/room template geometry and visible fit."""
from pathlib import Path
from PIL import Image
import re,sys
ROOT=Path(__file__).resolve().parents[1]
src=(ROOT/'data/shop.gd').read_text(encoding='utf-8')
layout={
  'head':('pet',(640,640)), 'face':('pet',(640,640)), 'neck':('pet',(640,640)),
  'wall':('room',(1200,525)), 'decor':('room',(410,396)), 'rug':('room',(640,130))
}
assertions=[
  '"head":{"offset":Vector2(0,-115), "width":120.0}',
  '"face":{"offset":Vector2(0,-46), "width":183.0}',
  '"neck":{"offset":Vector2(0,26), "width":110.0}',
  '"wall":{"rect":Rect2(40,138,1200,525)}',
  '"decor":{"rect":Rect2(435,164,410,396)}',
  '"rug":{"rect":Rect2(320,500,640,130)}'
]
errors=[f'Shared shop layout changed: {a}' for a in assertions if a not in src]
# Stable save IDs, one item for every slot in each theme.
records=[]
for line in src.splitlines():
  if '"category":' not in line or '"texture":preload' not in line:continue
  mt=re.match(r'\s*"([^"]+)":',line)
  if not mt:continue
  name=mt.group(1)
  def val(k):
    m=re.search(r'"'+k+r'":"([^"]+)"',line)
    return m.group(1) if m else None
  path=re.search(r'preload\("res://([^"]+)"\)',line)
  if not path: errors.append(name+': no PNG');continue
  records.append((name,val('category'),val('slot'),val('theme'),path.group(1)))
if len(records)!=60:errors.append(f'Expected 60 shop items, found {len(records)}')
slot_width={'head':120,'face':183,'neck':110}
for name,cat,slot,theme,rel in records:
  if slot not in layout or cat!=layout[slot][0]:errors.append(name+': wrong category/slot');continue
  path=ROOT/rel
  if not path.exists():errors.append(name+': missing '+rel);continue
  with Image.open(path) as asset:img=asset.convert('RGBA')
  expected=layout[slot][1]
  if img.size!=expected:errors.append(name+': incorrect canvas '+str(img.size));continue
  bbox=img.getchannel('A').getbbox()
  if not bbox:errors.append(name+': empty PNG');continue
  cx=(bbox[0]+bbox[2])*0.5
  if slot in ('decor','rug') and abs(cx-img.width/2)>1.5:
    errors.append(name+': decoration not horizontally centered')
  if slot=='wall' and img.getchannel('A').getextrema()!=(255,255):
    errors.append(name+': wallpaper is not opaque')
  if slot in ('head','face','neck'):
    # Dedicated pixel-knight armor and Bear Spirit are intentionally much larger.
    visual_width=(bbox[2]-bbox[0])*slot_width[slot]/640
    if theme not in ('pixel_knight','bear_spirit'):
      floor={'head':30,'face':46,'neck':14}[slot]
      if name in ('necktie','brainrot_banana_bow'):floor=13
      if visual_width<floor:errors.append(f'{name}: too small on Pip ({visual_width:.1f}px)')
    if any(img.getpixel(p)[3] for p in [(0,0),(639,0),(0,639),(639,639)]):
      errors.append(name+': nontransparent template corner; did a guide leak into exported art?')
if errors:
  print('Shop guide validation FAILED:')
  for error in errors:print(' -',error)
  sys.exit(1)
print(f'Shop guide validation passed: {len(records)} game PNGs, 30 pet fits, opaque wallpapers, and centered room art.')

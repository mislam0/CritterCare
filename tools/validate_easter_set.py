#!/usr/bin/env python3
"""Check the six Easter Shop slots, icon transparency, and file registration."""
from pathlib import Path
from PIL import Image
import re, hashlib

ROOT = Path(__file__).resolve().parents[1]
SHOP=(ROOT/'data/shop.gd').read_text()
EXPECTED={
  'bunny_ears':('pet','head',(640,640)),
  'egg_cheek_sticker':('pet','face',(640,640)),
  'spring_bow_tie':('pet','neck',(640,640)),
  'easter_wallpaper':('room','wall',(1200,525)),
  'easter_egg_garland':('room','decor',(410,396)),
  'easter_egg_rug':('room','rug',(640,130)),
}
assert SHOP.count('"theme":"easter", "category":')==6
assert '"easter":{"name":"Easter"' in SHOP
assert '"pixel_knight", "easter", "brainrot", "thanksgiving", "bear_spirit"]' in SHOP
for id, (cat,slot,size) in EXPECTED.items():
    filename={'bunny_ears':'cracked_egg_head','egg_cheek_sticker':'carrot_glasses','easter_egg_garland':'easter_basket'}.get(id,id)
    rel=f'assets/shop/{cat}/{slot}/{filename}.png'
    p=ROOT/rel
    assert f'"{id}":{{' in SHOP and f'"theme":"easter", "category":"{cat}", "slot":"{slot}"' in next(x for x in SHOP.splitlines() if x.lstrip().startswith('"'+id+'":')),id
    assert f'preload("res://{rel}")' in SHOP
    with Image.open(p) as im:
        assert im.size == size and im.mode=='RGBA',(id,im.size,im.mode)
        b=im.getchannel('A').getbbox(); assert b is not None, id
        a=im.getchannel('A').getextrema()
        if cat=='pet' or slot!='wall':
            assert a[0]==0 and a[1]==255,id
        if slot=='decor':
            assert abs((b[0]+b[2])/2 - 205)<=.5,b
    importer=(ROOT/(rel+'.import')).read_text()
    expected_hash=hashlib.md5(('res://'+rel).encode()).hexdigest()
    assert f'source_file="res://{rel}"' in importer
    assert f'{filename}.png-{expected_hash}.ctex' in importer
print('Easter set passed: 6 unique entries, 3 pet + 3 room, correct template canvases, import paths and centered basket.')

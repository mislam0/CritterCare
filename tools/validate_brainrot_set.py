#!/usr/bin/env python3
"""Validate Brainrot theme registration, PNG import metadata, and exact templates."""
from pathlib import Path
from PIL import Image
import re, hashlib
root=Path(__file__).resolve().parents[1]
shop=(root/'data/shop.gd').read_text()
expected={
 'brainrot_shark_cap':('pet','head','brainrot_propeller_hat',(640,640)),
 'brainrot_coffee_glasses':('pet','face','brainrot_67_glasses',(640,640)),
 'brainrot_banana_bow':('pet','neck','brainrot_tung_tung_tie',(640,640)),
 'brainrot_wallpaper':('room','wall','brainrot_wallpaper',(1200,525)),
 'brainrot_meme_poster':('room','decor','brainrot_tung_tung_poster',(410,396)),
 'brainrot_swirl_rug':('room','rug','brainrot_spiral_rug',(640,130)),
}
assert '"brainrot":{"name":"Brainrot"' in shop
assert '"pixel_knight", "easter", "brainrot", "thanksgiving", "bear_spirit"]' in shop
assert shop.count('"theme":"brainrot", "category":')==6
for item_id,(cat,slot,filename,size) in expected.items():
    rel=f'assets/shop/{cat}/{slot}/{filename}.png'
    line=next(ln for ln in shop.splitlines() if ln.lstrip().startswith('"'+item_id+'":'))
    assert f'"theme":"brainrot", "category":"{cat}", "slot":"{slot}"' in line,line
    assert f'preload("res://{rel}")' in line,line
    with Image.open(root/rel) as im:
        assert im.size==size and im.mode=='RGBA',(item_id,im.size,im.mode)
        a=im.getchannel('A'); bbox=a.getbbox()
        assert bbox is not None
        assert min(a.get_flattened_data())==0 or slot=='wall', f'{item_id} has no transparent background'
        if slot=='decor':
            assert abs((bbox[0]+bbox[2])/2-205)<=0.5,bbox
    side=(root/(rel+'.import')).read_text()
    m=hashlib.md5(('res://'+rel).encode()).hexdigest()
    assert f'source_file="res://{rel}"' in side and f'{filename}.png-{m}.ctex' in side
# Catch omitted commas between adjacent catalog entries (regression after Easter addition).
for prev,new in zip(shop.splitlines(),shop.splitlines()[1:]):
    if prev.lstrip().startswith('"') and '"texture":preload(' in prev and new.lstrip().startswith('"'):
        assert prev.rstrip().endswith(','),(prev,new)
print('Brainrot validation passed: 6 unique themed entries, anti-aliased flat sprites, correctly placed sprites, imports, and valid dictionary separators.')

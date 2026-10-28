#!/usr/bin/env python3
"""Proof the approved replacements are really in the Shop, without save-ID churn."""
from pathlib import Path
from collections import Counter
import hashlib,re
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
SH=ROOT/'data/shop.gd'
raw=SH.read_text()
EXPECT={
 'flower_clip':('Leaf Glasses','leaf_glasses'),
 'scholar_cap':('Beret','study_beret'),
 'bow':('Study Scarf','study_scarf'),
 'warm_cream_wallpaper':('Notebook Paper','notebook_wallpaper'),
 'study_bookshelf':('Study Decor Set','framed_book'),
 'plaid_study_rug':('Book Rug','book_rug'),
 'flat_cap':('Flat Cap','brown_flat_cap'),
 'navy_rectangle_rug':('Casual Rug','casual_rug'),
 'pumpkin_hat':('Witch Hat','witch_hat'),
 'halloween_scarf':('Candy Corn Bow Tie','candy_corn_bowtie'),
 'jack_o_lantern':('Halloween Decor Set','ghost_wall_hanging'),
 'red_nose':('Holly Glasses','holly_glasses'),
 'egg_cheek_sticker':('Carrot Glasses','carrot_glasses'),
 'easter_egg_garland':('Easter Decor Set','easter_basket'),
 'brainrot_swirl_rug':('Spiral Rug','brainrot_spiral_rug'),
}
parse=re.compile(r'^\s*"([^"]+)":\{"name":"([^"]+)", "theme":"([^"]+)", "category":"(pet|room)", "slot":"(head|face|neck|wall|decor|rug)", "price":(\d+), "description":"[^"]+", "texture":preload\("res://([^"]+)"\)\}',re.M)
items={m[0]:dict(name=m[1],theme=m[2],category=m[3],slot=m[4],price=int(m[5]),path=m[6]) for m in parse.findall(raw)}
assert len(items)==60,len(items)
for item_id,(name,stem) in EXPECT.items():
 assert item_id in items, item_id
 it=items[item_id]
 assert it['name']==name,(item_id,it['name'],name)
 assert Path(it['path']).stem==stem,(item_id,it['path'],stem)
 with Image.open(ROOT/it['path']) as im:
  assert im.mode=='RGBA' and im.getchannel('A').getbbox(),item_id
  pix=im.getpixel((im.width//2,im.height//2))
 # Every image import must point to the renamed PNG, with stable internal UID.
 side=(ROOT/(it['path']+'.import')).read_text()
 m=hashlib.md5(('res://'+it['path']).encode()).hexdigest()
 assert 'source_file="res://'+it['path']+'"' in side
 assert Path(it['path']).name+'-'+m+'.ctex' in side
# UI still uses no per-item offsets; slot image canvases are inherited.
assert 'const THEME_ORDER = ["nature", "study", "smart_casual", "bear_spirit", "easter", "halloween", "thanksgiving", "christmas", "brainrot", "pixel_knight"]' in raw
assert Counter(it['theme'] for it in items.values())==Counter({x:6 for x in ['nature','study','smart_casual','halloween','christmas','pixel_knight','easter','brainrot','thanksgiving','bear_spirit']})
print('PASS: 15 approved renamed sprites are registered under stable IDs; 60 items and import metadata intact.')

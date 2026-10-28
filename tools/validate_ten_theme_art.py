#!/usr/bin/env python3
"""Theme/slot coverage and native-canvas checks; old save IDs stay valid."""
from pathlib import Path
from collections import Counter
import re
from PIL import Image
ROOT = Path(__file__).resolve().parents[1]
raw=(ROOT/'data/shop.gd').read_text()
order=re.search(r'const THEME_ORDER = \[(.*?)\]',raw).group(1)
themes=re.findall(r'"([^"\n]+)"',order)
assert themes==['nature','study','smart_casual','bear_spirit','easter','halloween','thanksgiving','christmas','brainrot','pixel_knight'], themes
p=re.compile(r'^\s*"([^"\n]+)":\{"name":"([^"\n]+)", "theme":"([^"\n]+)", "category":"(pet|room)", "slot":"([^"\n]+)".*?"texture":preload\("res://([^"\n]+)"\)',re.M)
items=p.findall(raw)
assert len(items)==60, len(items)
expected={'head':(640,640),'face':(640,640),'neck':(640,640),'wall':(1200,525),'decor':(410,396),'rug':(640,130)}
count=Counter();seen=set()
for id,name,theme,cat,slot,rel in items:
    assert id not in seen,id
    seen.add(id)
    assert theme in themes, theme
    assert (cat=='pet')==(slot in ('head','face','neck')),(id,cat,slot)
    assert rel.startswith(f'assets/shop/{cat}/{slot}/'), rel
    with Image.open(ROOT/rel) as i:
        assert i.mode=='RGBA' and i.size==expected[slot] and i.getchannel('A').getbbox(), (id,i.size)
    count[theme,slot]+=1
for theme in themes:
    assert [count[theme,x] for x in expected]==[1]*6, (theme,count)
for saved_id in ['leaf_hat','scholar_cap','flat_cap','bat_mask','halloween_scarf','pixel_visor','bunny_ears','brainrot_shark_cap','brainrot_coffee_glasses']:
    assert saved_id in seen, saved_id
# Bear iconography must stay exclusive to this new theme: no new filenames using bear elsewhere.
assert all('bear' not in x[0] or x[2]=='bear_spirit' for x in items)
print('PASS: 10 complete themes, 60 unique correctly sized PNGs, legacy IDs present and categories valid.')

#!/usr/bin/env python3
"""Import user-approved Critter Care design-board art into canonical Godot canvases.
Does not change shop IDs, base game code, saved purchases, or the Pixel Knight sprite art.
"""
from pathlib import Path
from collections import defaultdict
from PIL import Image,ImageOps,ImageFilter
import cv2,numpy as np,re,shutil,sys
ROOT=Path(__file__).resolve().parents[1]
SHEETS=[ROOT/'tools/reference_shop_designs'/f'approved_sheet_0{i}.png' for i in (1,2,3)]
images=[np.asarray(Image.open(p).convert('RGB')) for p in SHEETS]
import json
TARGET_BOUNDS=json.loads((ROOT/'tools/reference_shop_designs/target_bounds.json').read_text())
SHOP=ROOT/'data/shop.gd'
raw=SHOP.read_text()
p=re.compile(r'^\s*"([^"\n]+)":\{"name":"([^"\n]+)", "theme":"([^"\n]+)", "category":"(pet|room)", "slot":"([^"\n]+)".*?"texture":preload\("res://([^"]+)"\)',re.M)
entries=p.findall(raw)
assert len(entries)==60,len(entries)
order=['nature','study','smart_casual','halloween','christmas','pixel_knight','easter','brainrot','thanksgiving','bear_spirit']
per_theme=defaultdict(dict)
for id,name,theme,category,slot,rel in entries:
 per_theme[theme][slot] = (id,name,ROOT/rel)
X=[(25,250),(246,485),(496,718),(709,937),(933,1182),(1175,1434)]
# tighten to avoid colored card borders & captions
Y=[(251,404),(503,683),(752,929)]
slots=[('head','face'),('neck','wall'),('decor','rug')]
# bright transparent eyewear: keep center holes; for pumpkin mask fill the face.
GLASS_IDS={'flower_clip','glasses','sunglasses','red_nose','egg_cheek_sticker','brainrot_coffee_glasses','thanksgiving_leaf_glasses'}
# the two full opaque rectangle products use repeating tiles
WALLS={'sage_wallpaper','warm_cream_wallpaper','blue_gray_stripes','halloween_wallpaper','christmas_wallpaper','easter_wallpaper','brainrot_wallpaper','thanksgiving_wallpaper'}
# split item masks using edge colors, discard faint halo shadow and fill silhouettes

def extract(img,bbox,slot,id):
 x0,y0,x1,y1=bbox
 a=img[y0:y1,x0:x1].copy()
 h,w=a.shape[:2]
 # reference boards have pale consistent cream card interiors
 patches=np.concatenate([a[0:5,0:9].reshape(-1,3),a[0:5,-9:].reshape(-1,3),a[-5:,0:9].reshape(-1,3),a[-5:,-9:].reshape(-1,3)])
 bright=patches[(patches[:,0]>195)&(patches[:,1]>190)&(patches[:,2]>180)]
 bg=np.median(bright if len(bright)>10 else patches,axis=0)
 # Lab distance robust against small creamy background variation
 lab=cv2.cvtColor(a,cv2.COLOR_RGB2LAB).astype(np.float32)
 bg_lab=cv2.cvtColor(np.uint8(bg.reshape(1,1,3)),cv2.COLOR_RGB2LAB).astype(np.float32).reshape(3)
 delta=np.linalg.norm(lab-bg_lab,axis=2)
 border=(delta>40).astype(np.uint8)*255
 # suppress decorative card lines where the crop meets its boundary
 border[:3,:]=0;border[-3:,:]=0;border[:,:3]=0;border[:,-3:]=0
 # remove tall, pale UI-card borders that can occur near crop edges
 pale=(a[:,:,0]>177)&(a[:,:,1]>168)&(a[:,:,2]>155)&((a.max(axis=2).astype(int)-a.min(axis=2).astype(int))<65)
 edgezones=np.zeros((h,w),bool);edgezones[:,:10]=True;edgezones[:,-10:]=True
 border[pale & edgezones]=0
 border=cv2.morphologyEx(border,cv2.MORPH_CLOSE,np.ones((3,3),np.uint8))
 n,labels,stats,_=cv2.connectedComponentsWithStats(border)
 keep=np.zeros_like(border)
 for i in range(1,n):
  if stats[i,cv2.CC_STAT_AREA]>=28:
   keep[labels==i]=255
 if id in GLASS_IDS:
  mask=keep
 else:
  contours,_=cv2.findContours(keep,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
  mask=np.zeros_like(keep)
  cv2.drawContours(mask,[c for c in contours if cv2.contourArea(c)>16],-1,255,cv2.FILLED)
 # no hard raw pixel edges at 2x upsample -- use mild anti-aliased fringe
 mask=cv2.GaussianBlur(mask,(3,3),0.55)
 rgba=np.dstack((a,mask))
 im=Image.fromarray(rgba,'RGBA')
 bb=im.getchannel('A').getbbox()
 if bb is None: raise RuntimeError(f'failed to extract {id}')
 im=im.crop(bb)
 # flatten the source gradients to a restrained illustrated palette;
 # preserve anti-aliased silhouette independently from palette conversion.
 rgb=im.convert('RGB')
 palette=rgb.quantize(colors=20,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE).convert('RGB')
 palette.putalpha(im.getchannel('A'))
 return palette

def contain(icon,box,canvas_size,slot):
 canvas=Image.new('RGBA',canvas_size,(0,0,0,0))
 # use established per-item artist silhouette / fit region from previous build
 width=max(1,box[2]-box[0]);height=max(1,box[3]-box[1])
 if slot=='rug':
  icon=icon.resize((width,height),Image.Resampling.LANCZOS)
 else:
  icon.thumbnail((width,height),Image.Resampling.LANCZOS)
 if slot=='decor':
  cx=canvas_size[0]//2
  x=round(cx-icon.width/2)
  y=round((box[1]+box[3]-icon.height)/2)
 else:
  x=round((box[0]+box[2]-icon.width)/2)
  y=round((box[1]+box[3]-icon.height)/2)
 x=max(0,min(x,canvas_size[0]-icon.width));y=max(0,min(y,canvas_size[1]-icon.height))
 canvas.alpha_composite(icon,(x,y))
 return canvas

def wallpaper(img,bbox):
 x0,y0,x1,y1=bbox
 # Exclude the original preview card frame and label, retaining only the pattern.
 # Mirrored repeats give edge-continuous wallpaper without a visible tile border.
 tile=Image.fromarray(img[y0+10:y1-20,x0+13:x1-13].copy()).convert('RGBA')
 tile=tile.resize((300,263),Image.Resampling.LANCZOS)
 output=Image.new('RGBA',(1200,525))
 for row,y in enumerate((0,263)):
  base=ImageOps.flip(tile) if row else tile
  for col,x in enumerate((0,300,600,900)):
   cell=ImageOps.mirror(base) if col%2 else base
   output.alpha_composite(cell,(x,y))
 return output

changed=[]
for ti,theme in enumerate(order):
 if theme in ('pixel_knight','bear_spirit'): continue
 sheet_idx=ti//3
 group_col=(ti%3)*2
 for r,(sl, sr) in enumerate(slots):
  for j,slot in enumerate((sl,sr)):
   id,name,path=per_theme[theme][slot]
   x0,x1=X[group_col+j];y0,y1=Y[r]
   if id=='brainrot_swirl_rug':x0=700
   bbox=(x0,y0,x1,y1)
   original=Image.open(path).convert('RGBA')
   if id in WALLS:
    new=wallpaper(images[sheet_idx],bbox)
   else:
    bb=tuple(TARGET_BOUNDS[id])
    if bb is None: raise ValueError(f'original blank {id}')
    icon=extract(images[sheet_idx],bbox,slot,id)
    new=contain(icon,bb,original.size,slot)
   # The source sheets contain two tiny detached crop-edge marks; remove only those,
   # preserving intentional small accent components on all other sprites.
   if id in ('thanksgiving_leaf_glasses','brainrot_swirl_rug'):
    pix=np.asarray(new.getchannel('A')).copy()
    count,labels,stats,_=cv2.connectedComponentsWithStats((pix>4).astype('uint8'))
    biggest=1+np.argmax(stats[1:,cv2.CC_STAT_AREA])
    pix[(labels>0)&(labels!=biggest)]=0
    clean=new.copy();clean.putalpha(Image.fromarray(pix,'L'));new=clean
   assert new.size==original.size,(id,new.size,original.size)
   new.save(path,compress_level=9)
   changed.append((id,name,slot,path))
print('UPDATED',len(changed),'textures; Pixel Knight and Bear Spirit untouched')
for it in changed:print(it[0],it[2],it[3].relative_to(ROOT))

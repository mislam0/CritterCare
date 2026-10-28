#!/usr/bin/env python3
"""Code-drawn flat Critter Care Easter & Brainrot assets.

Original geometry drawn with SVG paths rendered to PNG by CairoSVG/Pillow.
Only solid colors + uniform outlines; no gradients, shadows or shading.
Requires: pip install cairosvg pillow numpy
Use: python tools/generate_flat_easter_brainrot.py
"""
from pathlib import Path
import io
import numpy as np
from PIL import Image
import cairosvg

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'assets' / 'shop'

# Fixed flat palettes; every pixel belongs to one of these colors.
CO = {
 'egg': '#FFF9E8', 'shell_outline':'#9D714E', 'pink':'#F4A0B9',
 'purple':'#B5A0D5', 'mint':'#A8D6B8', 'blue':'#8BC8EC',
 'yellow':'#F7D779', 'brown':'#825843', 'paper':'#FCF1DE',
 'dark':'#354A60','shark':'#78BED7','sharkdeep':'#417A96',
 'coffee':'#AC7853','coffeefill':'#E6BB90', 'cream':'#F9EFDA',
 'banana':'#F8D566','bananaedge':'#80602A','navy':'#2C4D8F',
 'swirl':'#6D9AE7','swirl_light':'#ECF5FF', 'poster':'#F0A2B8'
}
C=lambda n:CO[n]

def path(d,fill,stroke=None,sw=0,more=''):
 return f'<path d="{d}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}" stroke-linejoin="round" stroke-linecap="round"' if stroke else '')+f' {more}/>'
def ellipse(cx,cy,rx,ry,fill,stroke=None,sw=0):
 return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>'
def circle(cx,cy,r,fill,stroke=None,sw=0):
 return ellipse(cx,cy,r,r,fill,stroke,sw)
def rect(x,y,w,h,fill,stroke=None,sw=0,rad=0):
 return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rad}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>'
def line(d,color,width):
 return path(d,'none',color,width)
def svg(w,h,*children):
 return '<svg xmlns="http://www.w3.org/2000/svg" width="'+str(w)+'" height="'+str(h)+'" viewBox="0 0 '+str(w)+' '+str(h)+'">'+''.join(children)+'</svg>'

def egg(cx,cy,rx,ry,fill,stroke,width=5,decor=None):
 s=ellipse(cx,cy,rx,ry,fill,stroke,width)
 if decor:
  s+=line(f'M {cx-rx*0.63:.1f} {cy} Q {cx} {cy-ry*0.15:.1f} {cx+rx*.63:.1f} {cy}',decor,max(3,width*.6))
 return s

def flower(cx,cy,r=9):
 petals=''.join(circle(cx+dx*r*.8,cy+dy*r*.8,r*.6,'#FFFFFF') for dx,dy in [(1,0),(-1,0),(0,1),(0,-1)])
 return petals+circle(cx,cy,r*.52,C('yellow'))

def little_shark(x,y,scale=1.0):
 # A solid-color shark profile simplified into recognizable fins and one eye.
 return f'<g transform="translate({x} {y}) scale({scale})">'+\
    path('M 4 47 Q 27 13 74 20 L 87 0 L 111 24 Q 131 35 139 55 L 117 67 L 24 67 Z', C('shark'),C('sharkdeep'),5)+\
    path('M 19 51 Q 72 45 125 54 Q 119 64 111 67 L 24 67 Z', '#FFFFFF')+\
    circle(43,38,5,C('dark'))+'</g>'

def little_banana(x,y,s=1):
 return f'<g transform="translate({x} {y}) scale({s})">'+path('M 6 12 Q 28 39 62 8 Q 42 60 7 43 Q 0 31 6 12 Z',C('banana'),C('bananaedge'),5)+rect(59,4,8,12,C('bananaedge'),rad=2)+'</g>'

def little_cup(x,y,s=1):
 return f'<g transform="translate({x} {y}) scale({s})">'+ellipse(76,26,19,20,'none',C('brown'),7)+rect(7,18,64,49,C('cream'),C('brown'),6,9)+ellipse(39,19,31,9,C('coffee'),C('brown'),4)+'</g>'

def star(cx,cy,r,fill):
 points=[]
 import math
 for i in range(10):
  rad=r if i%2==0 else r*.48
  a=-math.pi/2 +i*math.pi/5
  points.append((cx+rad*math.cos(a),cy+rad*math.sin(a)))
 return path('M '+' L '.join(f'{x:.1f} {y:.1f}' for x,y in points)+' Z',fill)

# Easter: head remains attached to the existing save ID `bunny_ears` but uses
# a correctly named cracked_egg_head.png physical texture.
def cracked_egg():
 shell=path('M 131 353 C 132 228 208 128 315 121 C 424 125 498 227 506 350 L 477 327 L 450 349 L 412 321 L 380 350 L 348 318 L 316 347 L 283 320 L 251 350 L 218 320 L 189 350 L 160 328 Z',C('egg'),C('shell_outline'),17)
 dots=''.join(circle(x,y,r,color) for x,y,r,color in [(222,225,25,C('pink')),(364,197,24,C('blue')),(423,271,22,C('yellow')),(290,285,19,C('mint'))])
 return svg(640,640,shell,dots)

def cheek_sticker():
 return svg(640,640,
   egg(511,381,45,58,C('egg'),C('brown'),9),
   line('M 475 369 Q 489 350 502 370 T 527 370 T 545 368',C('pink'),12),
   line('M 483 402 Q 499 389 514 402 T 538 403',C('mint'),11),
   circle(514,345,8,C('yellow')))

def spring_bow():
 return svg(640,640,
 path('M 302 353 C 246 316 205 305 156 316 Q 143 352 155 399 C 215 408 260 398 304 370 Z',C('purple'),C('brown'),11),
 path('M 339 353 C 393 317 438 306 488 316 Q 500 357 484 399 C 428 407 387 400 339 370 Z',C('purple'),C('brown'),11),
 ellipse(320,362,33,39,C('yellow'),C('brown'),10))

def easter_wallpaper():
 parts=[rect(0,0,1200,525,C('paper'))]
 for x in range(72,1200,240):
  parts.append(rect(x,0,12,525,'#DDEBD7'))
 colors=[C('pink'),C('yellow'),C('blue'),C('purple'),C('mint')]
 for row,y in enumerate([97,264,430]):
  for col,x in enumerate([95,280,465,650,835,1020,1180]):
   if (row+col)%3==0:
    parts.append(flower(x,y,11))
   else:
    parts.append(egg(x,y,19,26,colors[(row*2+col)%5],C('brown'),4))
 return svg(1200,525,*parts)

def easter_garland():
 parts=[line('M 46 85 Q 205 183 364 85',C('brown'),7)]
 colors=[C('pink'),C('yellow'),C('mint'),C('purple'),C('pink')]
 positions=[(74,132),(139,169),(205,183),(271,169),(336,132)]
 for (x,y),color in zip(positions,colors):
  parts.append(line(f'M {x} {y-30} V {y-22}',C('brown'),5))
  parts.append(egg(x,y,20,28,color,C('brown'),5))
  parts.append(line(f'M {x-11} {y+3} Q {x} {y-3} {x+11} {y+3}','#FFFFFF',4))
 return svg(410,396,*parts)

def easter_rug():
 parts=[ellipse(320,65,301,59,C('mint'),C('brown'),8),ellipse(320,65,280,48,C('egg'))]
 for i,x in enumerate([195,320,445]):
  parts.append(egg(x,65,31,37,[C('pink'),C('yellow'),C('purple')][i],C('brown'),5,'#FFFFFF'))
 for x,y in [(101,55),(540,77)]:parts.append(flower(x,y,12))
 return svg(640,130,*parts)

def shark_cap():
 parts=[path('M 131 350 Q 147 245 249 196 L 284 126 Q 300 114 314 125 L 364 179 Q 457 184 508 311 L 519 349 L 488 370 L 169 373 Z',C('shark'),C('dark'),14),
 # shark fins, all single color and no bevel/shading
 path('M 155 310 L 122 333 Q 119 346 157 355 Z',C('shark'),C('dark'),10),
 path('M 488 309 L 522 326 Q 528 345 502 355 Z',C('shark'),C('dark'),10),
 path('M 164 336 Q 316 314 484 339 L 486 363 L 160 363 Z','#FFFFFF',C('dark'),8),
 circle(401,286,11,C('dark')),
 path('M 207 299 Q 233 285 259 302 L 259 322 L 207 322 Z',C('pink'),C('dark'),6),
 line('M 220 299 L 240 315 L 260 299','#FFFFFF',5)]
 return svg(640,640,*parts)

def coffee_glasses():
 parts=[line('M 117 315 L 151 328',C('brown'),13),line('M 488 328 L 526 315',C('brown'),13),
 line('M 300 332 Q 322 311 342 332',C('brown'),13)]
 for cx in [226,414]:
  parts.append(ellipse(cx,340,82,56,C('cream'),C('brown'),14))
  parts.append(ellipse(cx,344,52,34,C('coffee')))
  # solid cream coffee-bean motif, no reflective lens glint
  parts.append(path(f'M {cx-18} 347 Q {cx} 317 {cx+19} 347 Q {cx} 366 {cx-18} 347 Z',C('coffeefill')))
 return svg(640,640,*parts)

def brainrot_wallpaper():
 parts=[rect(0,0,1200,525,'#E9F6FA')]
 # A sparse, repeating set of icons; no gradients and no busy ornaments.
 for row,y in enumerate([43,217,393]):
  for col,x in enumerate([35,255,475,695,915,1135]):
   kind=(row+col)%4
   if kind==0:parts.append(little_shark(x,y,0.83))
   elif kind==1:parts.append(little_banana(x+20,y+18,1.25))
   elif kind==2:parts.append(little_cup(x+18,y+11,0.9))
   else: parts.append(star(x+66,y+54,21,C('pink')))
 return svg(1200,525,*parts)

def brainrot_poster():
 parts=[rect(68,29,274,332,'#F9EBDD',C('brown'),10,12),
 rect(86,48,238,294,C('poster')),
 # friendly center portrait: blue shark with dark eyes and white broad smiling mouth
 path('M 119 242 Q 122 158 180 135 L 199 88 Q 214 91 227 133 Q 298 155 308 246 Z',C('shark'),C('dark'),9),
 path('M 126 225 Q 210 210 300 225 L 298 247 L 125 247 Z','#FFFFFF',C('dark'),5),
 circle(167,190,8,C('dark')),circle(259,190,8,C('dark')),
 # cup at bottom, banana at corner
 little_cup(139,257,0.8), little_banana(255,275,0.65)]
 return svg(410,396,*parts)

def swirl_rug():
 return svg(640,130,
  ellipse(320,65,301,59,C('swirl'),C('navy'),9),
  path('M 94 71 C 116 30 247 16 366 32 C 478 47 486 110 357 106 C 253 105 211 61 307 51 C 366 45 396 74 349 81 C 313 87 296 69 322 62', 'none','#FFFFFF',18),
  path('M 105 81 Q 110 91 126 99', 'none',C('swirl_light'),6))

entries=[
 ('pet/head/cracked_egg_head.png',cracked_egg),
 ('pet/face/egg_cheek_sticker.png',cheek_sticker),
 ('pet/neck/spring_bow_tie.png',spring_bow),
 ('room/wall/easter_wallpaper.png',easter_wallpaper),
 ('room/decor/easter_egg_garland.png',easter_garland),
 ('room/rug/easter_egg_rug.png',easter_rug),
 ('room/wall/brainrot_wallpaper.png',brainrot_wallpaper),
]

def write_png(rel,make):
 svg_text=make()
 dst=ART/rel
 w,h=([1200,525] if '/wall/' in str(rel) else [410,396] if '/decor/' in str(rel) else [640,130] if '/rug/' in str(rel) else [640,640])
 raw=cairosvg.svg2png(bytestring=svg_text.encode(),output_width=w,output_height=h)
 im=Image.open(io.BytesIO(raw)).convert('RGBA')
 # Snap edge-antialiasing to a binary transparency mask; preserve solid shapes.
 a=np.asarray(im,dtype=np.uint8).copy()
 a[:,:,3]=np.where(a[:,:,3]>=128,255,0).astype(np.uint8)
 # Every visible RGB value is snapped to one of the explicit flat design
 # colors. This removes antialias-generated midtone fringes, not geometry.
 extra=['#FFFFFF','#DDEBD7','#E9F6FA','#F9EBDD','#F0A2B8']
 palette=list(dict.fromkeys([*CO.values(),*extra]))
 pcolors=np.array([[int(t[i:i+2],16) for i in (1,3,5)] for t in palette],dtype=np.int16)
 flat=a.reshape(-1,4)
 used=np.nonzero(flat[:,3]>0)[0]
 # Batched to bound memory for large wallpaper backgrounds.
 for j in range(0,len(used),40000):
  indices=used[j:j+40000]
  target=flat[indices,:3].astype(np.int16)
  errors=((target[:,None,:]-pcolors[None,:,:]).astype(np.int32)**2).sum(axis=2)
  flat[indices,:3]=pcolors[errors.argmin(axis=1)]
 if a[:,:,3].max()!=255: raise ValueError('No visible pixels '+str(rel))
 Image.fromarray(a,'RGBA').save(dst)
 print(rel, 'bbox',Image.fromarray(a,'RGBA').getbbox())

if __name__=='__main__':
 for rel,fn in entries: write_png(rel,fn)

#!/usr/bin/env python3
"""Create five flat, no-shading Brainrot cosmetic/room PNGs for Critter Care.

Written as vector geometry in Python, rendered via CairoSVG and Pillow.
All shapes use solid colors; there are no gradients, shadows or glows.
Existing catalog IDs are preserved in data/shop.gd for save compatibility.
Usage: python tools/generate_brainrot_168.py
"""
from pathlib import Path
from io import BytesIO
from PIL import Image
import numpy as np
import cairosvg

BASE = Path(__file__).resolve().parents[1] / 'assets/shop'

# Intentionally compact palette: solid, flat cartoon shapes and bold borders.
C = {
    'ink': '#26384D', 'blue':'#74B9E8', 'red':'#D94748',
    'yellow':'#F3D45A', 'cream':'#FFF7DC', 'brown':'#7D4930',
    'wood':'#BC8655', 'wall':'#BCE5DB', 'pink':'#F1A1B8',
    'navy':'#314F7D', 'white':'#FFFFFF', 'teal':'#5AC4C3',
    'rug':'#72B4DF', 'black':'#272D35', 'warm':'#F5EBCF',
}

def svg(w,h,*parts):
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %s %s" width="%s" height="%s">%s</svg>'%(w,h,w,h,''.join(parts))
def p(d,fill,stroke=None,sw=0):
    return '<path d="%s" fill="%s"%s/>'%(d,fill,(' stroke="%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"'%(stroke,sw) if stroke else ''))
def stroke(d,c,w): return p(d,'none',c,w)
def ell(x,y,rx,ry,f,s=None,w=0):
    return '<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="%s"%s/>'%(x,y,rx,ry,f,(' stroke="%s" stroke-width="%s"'%(s,w) if s else ''))
def rect(x,y,w,h,f,s=None,sw=0,r=0):
    return '<rect x="%s" y="%s" width="%s" height="%s" rx="%s" fill="%s"%s/>'%(x,y,w,h,r,f,(' stroke="%s" stroke-width="%s"'%(s,sw) if s else ''))


def hat():
    # Blue beanie with a single solid-color red-and-yellow propeller.
    # Hat brim occupies the established head-guide bounding box.
    return svg(640,640,
        # stem visible above the dome
        rect(305,147,30,80,C['yellow'],C['ink'],11,10),
        # propeller blades: no highlights, no shading
        p('M 320 158 C 287 145 244 139 215 156 C 202 166 208 188 226 192 C 263 199 293 185 320 177 Z', C['red'],C['ink'],11),
        p('M 320 158 C 351 142 394 140 426 157 C 439 166 435 186 416 193 C 384 202 345 186 320 177 Z',C['yellow'],C['ink'],11),
        ell(320,168,18,18,C['blue'],C['ink'],10),
        # solid dome and brim
        p('M 133 346 C 133 258 203 205 318 205 C 432 205 505 258 505 346 L 505 366 L 133 366 Z',C['blue'],C['ink'],16),
        p('M 116 354 Q 318 333 524 354 Q 535 365 520 380 Q 312 397 119 379 Q 104 371 116 354 Z',C['red'],C['ink'],15)
    )


def glasses():
    # Chunky round spectacles with big readable '6' and '7' marks.
    # Numbers are drawn as paths rather than font glyphs for consistent appearance.
    return svg(640,640,
        # temples
        stroke('M 118 320 L 63 303',C['ink'],17),
        stroke('M 522 320 L 579 303',C['ink'],17),
        # two lenses
        ell(216,343,111,74,C['cream'],C['ink'],17),
        ell(424,343,111,74,C['cream'],C['ink'],17),
        stroke('M 325 328 Q 319 316 313 328',C['ink'],17),
        # 6: descending curl and enclosed loop using a wide round stroke
        stroke('M 246 308 C 224 293 194 306 186 336 C 177 369 194 390 216 388 C 241 388 249 363 230 352 C 216 342 200 348 192 357',C['navy'],18),
        # 7: simple angular line
        stroke('M 386 311 L 457 311 L 423 385',C['navy'],19),
    )


def tung_tung_tie():
    # Long wooden necktie with a simple anthropomorphic Tung Tung-like face.
    return svg(640,640,
        # wooden knot / collar
        p('M 272 283 L 367 283 L 383 327 L 319 359 L 256 327 Z',C['wood'],C['brown'],14),
        # two broad eye dots and line smile
        ell(298,318,10,13,C['ink']),ell(340,318,10,13,C['ink']),
        stroke('M 303 339 Q 320 352 337 339',C['ink'],8),
        # tie trunk: simple wooden plank-point silhouette and two short seams
        p('M 290 354 L 350 354 L 384 486 L 319 524 L 255 486 Z',C['wood'],C['brown'],15),
        stroke('M 293 384 L 278 463',C['brown'],7),
        stroke('M 346 384 L 361 463',C['brown'],7),
    )


def tung_poster():
    # One recognizable character as a flat wall poster (no faux shadow).
    return svg(410,396,
        rect(63,24,284,348,C['cream'],C['brown'],12,10),
        rect(84,45,242,306,C['wall']),
        # tiny propeller hat on the poster figure
        rect(194,75,12,28,C['yellow'],C['ink'],3,3),
        p('M 199 81 Q 160 58 146 77 Q 155 99 199 92 Z',C['red'],C['ink'],5),
        p('M 202 81 Q 244 57 255 78 Q 249 97 202 92 Z',C['yellow'],C['ink'],5),
        ell(200,84,9,9,C['blue'],C['ink'],4),
        # wooden tung-tung character: straight trunk, round corners
        rect(143,109,115,191,C['wood'],C['brown'],11,26),
        # stick-like arms, feet, and club in same flat brown palette
        stroke('M 143 199 L 114 221',C['brown'],12),
        stroke('M 259 199 L 294 207',C['brown'],12),
        stroke('M 163 294 L 151 320',C['brown'],11),
        stroke('M 236 294 L 248 320',C['brown'],11),
        rect(284,137,20,137,C['brown'],None,0,7),
        # simple facial expression
        ell(170,177,11,14,C['white'],C['ink'],3),
        ell(227,177,11,14,C['white'],C['ink'],3),
        ell(174,179,5,8,C['ink']),ell(223,179,5,8,C['ink']),
        stroke('M 187 222 Q 201 236 215 222',C['ink'],7),
    )


def sixty_seven_rug():
    # Oval floor rug with two large numerals and no spiral/shading.
    return svg(640,130,
        ell(320,65,296,58,C['rug'],C['navy'],10),
        # '6' and '7' constructed as consistent rounded paths
        stroke('M 270 37 C 242 21 209 32 197 61 C 180 105 228 113 246 90 C 259 73 247 56 231 57 C 213 57 203 72 208 82',C['white'],20),
        stroke('M 332 40 L 429 40 L 374 100',C['white'],21),
    )

ENTRIES=[
    ('pet/head/brainrot_propeller_hat.png',hat),
    ('pet/face/brainrot_67_glasses.png',glasses),
    ('pet/neck/brainrot_tung_tung_tie.png',tung_tung_tie),
    ('room/decor/brainrot_tung_tung_poster.png',tung_poster),
    ('room/rug/brainrot_67_rug.png',sixty_seven_rug),
]

# Snap antialiasing-generated colors back to flat solid design colors;
# retain smooth outlines by rasterizing at native 640px resolution.
COLORS=np.array([[int(c[i:i+2],16) for i in (1,3,5)] for c in C.values()],dtype=np.int16)
def save_png(rel, fun):
    out=BASE / rel
    dims=(410,396) if '/decor/' in rel else (640,130) if '/rug/' in rel else (640,640)
    raster=cairosvg.svg2png(bytestring=fun().encode('utf-8'),output_width=dims[0],output_height=dims[1])
    arr=np.asarray(Image.open(BytesIO(raster)).convert('RGBA')).copy()
    a=arr.reshape(-1,4)
    # Hard alpha: transparent outside and solid-color pixels inside.
    a[:,3]=np.where(a[:,3]>=128,255,0).astype('uint8')
    used=np.flatnonzero(a[:,3]>0)
    for start in range(0,len(used),20000):
        inds=used[start:start+20000]
        rgb=a[inds,:3].astype(np.int16)
        nearest=((rgb[:,None,:]-COLORS[None,:,:]).astype(np.int32)**2).sum(2).argmin(1)
        a[inds,:3]=COLORS[nearest]
    im=Image.fromarray(arr,'RGBA')
    assert im.size==dims and im.getbbox()
    im.save(out)
    print(f'generated {rel}: {dims}, bounds={im.getbbox()}')

if __name__=='__main__':
    for rel,make in ENTRIES: save_png(rel,make)

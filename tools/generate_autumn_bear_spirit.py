#!/usr/bin/env python3
"""Regenerate only the 12 native-canvas Thanksgiving and Bear Spirit sprites.

Simple Pillow shapes; no AI redraws, gradients, shadows, bear motifs outside
Bear Spirit, or extra Godot offsets. Run from any working directory.

The existing eight themes have curated legacy graphics and are NOT overwritten.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
S = ROOT / 'assets/shop'
INK='#493329'; BROWN='#8F6046'; TAN='#D8AF86'; CREAM='#FFF5E6'; GREEN='#497659'; LEAF='#73956C'; GOLD='#E9B660'; GOLD2='#F8DB95'; ORANGE='#D77D35'; RUST='#A95337'; DARK_GREEN='#315946'; BEIGE='#F6E6CF'; SAND='#EBD2B6'
class Art:
 def __init__(self,w,h,bg=None):
  self.im=Image.new('RGBA',(w,h),(0,0,0,0) if bg is None else bg);self.d=ImageDraw.Draw(self.im);self.w=w;self.h=h
 def e(self,box,c,outline=INK,st=8): self.d.ellipse(tuple(map(int,box)),fill=c,outline=outline,width=st if outline else 0)
 def r(self,box,c,outline=INK,st=8,radius=0):self.d.rounded_rectangle(tuple(map(int,box)),radius=radius,fill=c,outline=outline,width=st if outline else 0)
 def p(self,xy,c,outline=INK,st=8):self.d.polygon(xy,fill=c);self.d.line(xy+[xy[0]],fill=outline,width=st,joint='curve') if outline else None
 def l(self,points,c,w=9):self.d.line(points,fill=c,width=w,joint='curve')
 def txt(self,at,s,size,color=INK):
  fp='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
  f=ImageFont.truetype(fp,size)
  self.d.text(at,s,font=f,fill=color,anchor='mm')
 def save(self,path):
  path.parent.mkdir(parents=True,exist_ok=True);self.im.save(path)

def leaf(a,cx,cy,col=LEAF,sc=1,angle=1):
 w=24*sc;h=37*sc;a.e((cx-w,cy-h,cx+w,cy+h),col,None,0);a.l([(cx,cy+10*sc),(cx+angle*18*sc,cy-18*sc)],DARK_GREEN,max(2,int(3*sc)))
def blossom(a,cx,cy,sc=1,col='#FFF5EC'):
 for dx,dy in [(-20,0),(20,0),(0,-20),(0,20)]:a.e((cx+(dx-15)*sc,cy+(dy-15)*sc,cx+(dx+15)*sc,cy+(dy+15)*sc),col,None,0)
 a.e((cx-12*sc,cy-12*sc,cx+12*sc,cy+12*sc),GOLD2,None,0)
def bearface(a,x,y,scale=1,color=BROWN):
 def b(xx,yy):return (x+xx*scale,y+yy*scale)
 for px in [-56,56]: a.e((x+(px-31)*scale,y-95*scale,x+(px+31)*scale,y-33*scale),color,INK,max(2,int(6*scale)))
 a.e((x-100*scale,y-75*scale,x+100*scale,y+85*scale),color,INK,max(2,int(7*scale)))
 a.e((x-47*scale,y+1*scale,x+47*scale,y+71*scale),CREAM,None,0)
 for px in [-43,43]: a.e((x+(px-7)*scale,y-7*scale,x+(px+7)*scale,y+7*scale),INK,None,0)
 a.e((x-12*scale,y+12*scale,x+12*scale,y+28*scale),INK,None,0)
 a.l([b(-14,43),b(0,55),b(14,43)],INK,max(2,int(5*scale)))

def glasses(a,color=GOLD):
 for x in [90,328]:a.e((x,250,x+222,411),None,color,14)
 a.l([(304,295),(336,295)],color,14);a.l([(90,299),(52,287)],color,12);a.l([(550,299),(588,287)],color,12)

def hat_bear():
 a=Art(640,640)
 a.e((125,80,272,231),BROWN,INK,10);a.e((369,80,516,231),BROWN,INK,10)
 a.e((145,98,247,202),'#C78F74',None,0);a.e((393,98,495,202),'#C78F74',None,0)
 a.e((140,143,504,342),BROWN,INK,12)
 a.e((240,184,402,318),TAN,INK,6)
 for x in (278,356):a.e((x-12,225,x+12,247),INK,None,0)
 a.e((310,246,330,261),INK,None,0)
 a.l([(306,277),(320,287),(335,277)],INK,7)
 leaf(a,320,131,GREEN,.65)
 return a

def bear_neck():
 a=Art(640,640)
 a.p([(100,257),(200,210),(430,210),(541,250),(506,351),(398,375),(245,370),(125,332)],GREEN,INK,12)
 a.p([(261,343),(319,374),(350,559),(282,553),(246,397)],DARK_GREEN,INK,9)
 a.p([(353,370),(410,376),(428,540),(361,545)],GREEN,INK,8)
 a.e((252,279,390,413),GOLD2,INK,11)
 bearface(a,322,349,.37,BROWN)
 return a

def thank_hat():
 a=Art(640,640)
 for x,y,col in [(191,211,RUST),(252,140,ORANGE),(320,107,RUST),(388,143,ORANGE),(457,207,GOLD)]:a.e((x-52,y-60,x+52,y+102),col,INK,10)
 a.e((165,225,480,374),BROWN,INK,12)
 a.e((273,233,372,329),TAN,INK,7)
 for x in (302,341):a.e((x-6,261,x+6,274),INK,None,0)
 a.p([(310,285),(336,285),(322,302)],GOLD,INK,3)
 return a

def thank_glasses():
 a=Art(640,640)
 glasses(a,RUST)
 for x,tilt in [(150,-1),(455,1)]:
  for offx,offy,clr in [(-66,-59,ORANGE),(63,-51,RUST),(0,-91,GOLD)]:
   a.p([(x+offx,276+offy),(x+offx-26,230+offy),(x+offx+21,216+offy)],clr,INK,5)
 return a

def bowtie():
 a=Art(640,640)
 a.p([(292,306),(125,229),(106,466),(293,398)],ORANGE,INK,14)
 a.p([(345,306),(515,229),(534,466),(346,398)],RUST,INK,14)
 a.l([(185,262),(190,443)],GOLD,13);a.l([(463,267),(461,443)],GOLD,13)
 a.e((281,299,358,403),GOLD,INK,11)
 return a

def wallpaper(theme):
 a=Art(1200,525,BEIGE if theme=='bear' else '#FBEACF')
 for row in range(4):
  y=43+row*134
  for col in range(8):
   x=54+col*166 + (65 if row%2 else 0)
   if x>1190:continue
   if theme=='bear':
    if (col+row)%3==0:bearface(a,x,y,.17,TAN)
    elif (col+row)%3==1:
     a.p([(x,y-33),(x-26,y+15),(x+26,y+15)],GREEN,None,0);a.r((x-5,y+11,x+5,y+34),DARK_GREEN,None,0,0)
    else:leaf(a,x,y,LEAF,.52)
   else:
    if (col+row)%3==0:leaf(a,x,y,RUST,.63)
    elif (col+row)%3==1:
     a.e((x-23,y-18,x+23,y+22),BROWN,None,0)
     a.e((x-22,y-26,x+22,y-3),ORANGE,None,0)
     a.l([(x,y-30),(x,y-42)],DARK_GREEN,6)
    else:
     a.e((x-27,y-27,x+27,y+27),ORANGE,None,0);a.l([(x,y-27),(x,y+27)],RUST,3)
 return a

def pennant():
 a=Art(410,396)
 a.l([(205,12),(78,47),(330,47),(205,12)],BROWN,7)
 a.r((73,41,337,336),CREAM,INK,10,10)
 a.r((87,53,322,319),BEIGE,GREEN,7,2)
 bearface(a,205,183,.69,BROWN)
 for x in (126,281):leaf(a,x,286,GREEN,.45)
 a.l([(100,63),(309,63)],GREEN,9)
 return a

def cornucopia():
 a=Art(410,396)
 # simple curled woven horn with single harvest cluster
 a.p([(93,198),(149,117),(285,90),(302,143),(238,209),(152,276)],TAN,INK,10)
 a.l([(160,127),(213,243)],BROWN,6);a.l([(212,107),(270,186)],BROWN,6)
 for x,y,c in [(245,253,RUST),(291,236,ORANGE),(330,249,GOLD),(261,291,GREEN),(324,296,LEAF)]:
  a.e((x-33,y-31,x+33,y+26),c,INK,6)
 leaf(a,280,204,GREEN,.65)
 # Center the cornucopia silhouette exactly on the shared wall decor slot.
 moved=Art(410,396)
 moved.im.paste(a.im,(-21,0))
 return moved

def rug_bear():
 a=Art(640,130)
 a.e((17,4,623,126),GREEN,INK,5)
 a.e((45,15,594,114),CREAM,None,0)
 bearface(a,318,70,.45,BROWN)
 for x in (145,497):leaf(a,x,67,GREEN,.55)
 return a

def rug_pie():
 a=Art(640,130)
 a.e((24,5,616,123),BROWN,INK,5);a.e((49,17,591,112),GOLD2,INK,3)
 # even, uncomplicated lattice inside the pie
 for i in range(6):
  x=175+i*56
  a.l([(x-35,35),(x+15,100)],RUST,5)
  a.l([(x+15,35),(x-35,100)],ORANGE,5)
 return a

assets={
 'pet/head/bear_spirit_hood.png':hat_bear(),
 'pet/face/bear_spirit_glasses.png':Art(640,640),
 'pet/neck/bear_spirit_scarf.png':bear_neck(),
 'room/wall/bear_spirit_wallpaper.png':wallpaper('bear'),
 'room/decor/bear_spirit_banner.png':pennant(),
 'room/rug/bear_spirit_rug.png':rug_bear(),
 'pet/head/thanksgiving_turkey_hat.png':thank_hat(),
 'pet/face/thanksgiving_leaf_glasses.png':thank_glasses(),
 'pet/neck/thanksgiving_harvest_bow.png':bowtie(),
 'room/wall/thanksgiving_wallpaper.png':wallpaper('thanksgiving'),
 'room/decor/thanksgiving_cornucopia.png':cornucopia(),
 'room/rug/thanksgiving_pie_rug.png':rug_pie(),
}
glasses(assets['pet/face/bear_spirit_glasses.png'])

if __name__ == '__main__':
    for rel, sprite in assets.items():
        sprite.save(S / rel)
    print(f'Regenerated {len(assets)} flat-theme PNGs without changing existing Shop art.')

# HISTORICAL ART GENERATOR (v1.6.14): superseded by tools/import_approved_designs.py.
# Running this file overwrites current v1.6.15 artwork. Do not use for new builds.
#!/usr/bin/env python3
"""Draw the approved 2026 flat, low-detail Critter Care set redesigns.

Only ordinary non-Pixel-Knight legacy assets are authored here. Every PNG is
rendered directly to its existing Pip/Room slot canvas; no positioning hacks.
Run with Python/Pillow, then launch all shop/fit validators in tools/.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import math
R=Path(__file__).resolve().parents[1]; AS=R/'assets/shop'
AA=3
C={
 'ink':'#44342F','leaf':'#4E8060','leaf2':'#86A879','leaf3':'#315C45',
 'cream':'#FFF7E8','ivory':'#FFF1DA','brown':'#90664B','tan':'#B78B69',
 'red':'#A84245','scarlet':'#D94E40','yellow':'#F3BB58','orange':'#F09337',
 'dark':'#40353F','navy':'#34556D','sky':'#91BED6','slate':'#738C9D',
 'purple':'#594168','lightpurple':'#9A78B2','pink':'#E7A8BA','white':'#FFFEF7',
 'holly':'#326549','mauve':'#D68C93','apricot':'#F3CDA7','gold':'#D4A453',
}
class A:
 def __init__(self,w,h,bg=None):
  self.w=w;self.h=h;self.im=Image.new('RGBA',(w*AA,h*AA),bg or (0,0,0,0));self.d=ImageDraw.Draw(self.im)
 def rect(self,b,fill,outline='ink',sw=7,r=0):
  box=tuple(round(x*AA) for x in b)
  self.d.rounded_rectangle(box,radius=round(r*AA),fill=C.get(fill,fill) if fill else None,outline=C.get(outline,outline) if outline else None,width=round(sw*AA) if outline else 0)
 def ellipse(self,b,fill,outline='ink',sw=7):
  self.d.ellipse(tuple(round(x*AA) for x in b),fill=C.get(fill,fill) if fill else None,outline=C.get(outline,outline) if outline else None,width=round(sw*AA) if outline else 0)
 def poly(self,xy,fill,outline='ink',sw=7):
  pts=[(round(x*AA),round(y*AA)) for x,y in xy];self.d.polygon(pts,fill=C.get(fill,fill) if fill else None)
  if outline:self.d.line(pts+[pts[0]],fill=C.get(outline,outline),width=round(sw*AA),joint='curve')
 def line(self,xy,col='ink',sw=7):
  self.d.line([(round(x*AA),round(y*AA)) for x,y in xy],fill=C.get(col,col),width=round(sw*AA),joint='curve')
 def arc(self,b,begin,end,color='ink',sw=8):
  self.d.arc(tuple(round(x*AA) for x in b),start=begin,end=end,fill=C.get(color,color),width=round(sw*AA))
 def text(self,center,s,size,color='ink'):
  f=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',size*AA)
  self.d.text(tuple(round(x*AA) for x in center),s,font=f,fill=C.get(color,color),anchor='mm',stroke_width=0)
 def out(self,rel):
  dest=AS/rel;dest.parent.mkdir(parents=True,exist_ok=True)
  im=self.im.resize((self.w,self.h),Image.Resampling.LANCZOS)
  if '/decor/' in rel:
   bb=im.getchannel('A').getbbox()
   if bb:
    dx=round(self.w/2-(bb[0]+bb[2])/2)
    if dx:
     centered=Image.new('RGBA',im.size)
     centered.paste(im,(dx,0))
     im=centered
  im.save(dest)
  return rel

def leaf(a,x,y,s=1,color='leaf',tilt=0):
 # one solid flat leaf with a restrained central stem
 a.poly([(x-32*s,y+11*s),(x-17*s,y-21*s),(x+18*s,y-32*s),(x+31*s,y-18*s),(x+18*s,y+20*s),(x-6*s,y+28*s)],color,'ink',max(2,round(5*s)))
 a.line([(x-18*s,y+19*s),(x+20*s,y-20*s)],'leaf3',max(2,round(3*s)))
def flower(a,x,y,s=1,color='white'):
 for dx,dy in [(-17,0),(17,0),(0,-17),(0,17)]:a.ellipse((x+(dx-13)*s,y+(dy-13)*s,x+(dx+13)*s,y+(dy+13)*s),color,None)
 a.ellipse((x-10*s,y-10*s,x+10*s,y+10*s),'yellow',None)
def lenses(a,color='leaf',fill=None):
 for x in (86,326):a.ellipse((x,260,x+222,414),fill,color,14)
 a.line([(306,300),(333,300)],color,13)
 a.line([(87,306),(54,298)],color,11);a.line([(550,306),(587,298)],color,11)
def leafy_glasses():
 a=A(640,640);lenses(a,'leaf3')
 for x in (118,525):
  leaf(a,x,253,.72,'leaf2')
  leaf(a,x+(-15 if x<300 else 15),310,.55,'leaf')
 return a

def leaf_cap():
 a=A(640,640)
 a.poly([(102,355),(155,266),(216,193),(325,157),(437,205),(507,289),(545,365),(455,396),(264,405),(129,392)],'leaf','ink',11)
 a.line([(154,366),(444,229)],'leaf3',7)
 a.line([(309,284),(265,248)],'leaf3',5);a.line([(373,256),(399,319)],'leaf3',5)
 a.line([(330,180),(342,130)],'brown',12)
 leaf(a,389,151,.55,'leaf2')
 flower(a,158,313,.73)
 return a

def vine_collar():
 a=A(640,640)
 a.arc((96,208,547,507),6,174,'leaf3',16)
 a.line([(139,332),(215,418),(323,442),(425,418),(507,331)],'leaf3',15)
 for x,y,s in [(161,354,.67),(217,403,.69),(306,432,.63),(404,405,.75),(470,353,.72)]:leaf(a,x,y,s,'leaf2' if x%2 else 'leaf')
 flower(a,323,443,.53)
 return a

def nature_wall():
 a=A(1200,525,'#D5E4C9')
 for ri in range(4):
  for ci in range(9):
   x=60+145*ci+(64 if ri%2 else 0);y=60+134*ri
   if x<1150:
    leaf(a,x,y,.63,'leaf2')
    if (ri+ci)%3==0:flower(a,x+44,y+18,.28)
 return a

def plant_decor():
 a=A(410,396)
 a.line([(205,31),(205,93)],'brown',8);a.line([(125,95),(205,44),(283,95)],'brown',7)
 a.ellipse((103,81,302,277),'cream','brown',10)
 a.rect((118,115,288,249),'ivory',None,r=10)
 for x,yy,s in [(118,183,.8),(153,231,.8),(281,187,.8),(241,236,.8),(205,171,.85),(170,142,.7),(264,142,.65)]:
  leaf(a,x,yy,s,'leaf2' if yy%2 else 'leaf')
 a.line([(205,101),(205,249)],'leaf3',7)
 return a

def leaf_rug():
 a=A(640,130);a.ellipse((16,5,624,125),'leaf','ink',5);a.ellipse((37,19,603,114),'cream',None)
 for x,s in [(187,.82),(322,1.06),(449,.82)]:leaf(a,x,65,s,'leaf2')
 return a

def beret():
 a=A(640,640)
 a.poly([(139,308),(168,232),(227,185),(331,165),(439,193),(502,240),(519,315),(464,342),(184,349)],'red','ink',10)
 a.ellipse((135,309,515,363),'red','ink',9);a.line([(317,180),(313,144)],'ink',9)
 return a

def study_glasses():
 a=A(640,640);lenses(a,'brown');return a

def study_scarf():
 a=A(640,640)
 a.poly([(130,270),(203,235),(437,238),(506,269),(485,351),(423,403),(239,409),(167,346)],'brown','ink',11)
 a.poly([(168,285),(220,270),(266,292),(262,368),(211,354)],'cream','ink',7)
 a.poly([(379,290),(430,267),(481,292),(452,357),(388,370)],'cream','ink',7)
 a.poly([(274,349),(347,352),(360,542),(295,530)],'leaf','ink',10)
 a.line([(301,393),(346,407)],'leaf2',8)
 return a

def ruled_wall():
 a=A(1200,525,'#FFF5E5')
 for y in range(39,525,52):a.line([(0,y),(1200,y)],'#B5D2E3',3)
 for x in (180,680):a.line([(x,0),(x,525)],'#DA888A',4)
 return a

def framed_book():
 a=A(410,396)
 a.line([(204,12),(116,59),(290,59),(204,12)],'brown',8)
 a.rect((72,54,338,339),'brown','ink',10,r=5)
 a.rect((95,75,317,317),'cream',None,r=4)
 a.poly([(202,148),(161,123),(122,129),(122,263),(158,254),(202,268)],'leaf3','ink',5)
 a.poly([(208,148),(246,125),(285,127),(285,260),(242,253),(208,268)],'leaf','ink',5)
 a.line([(205,148),(205,270)],'cream',6)
 return a

def book_rug():
 a=A(640,130);a.ellipse((18,4,622,126),'brown','ink',5);a.ellipse((38,17,602,112),'cream',None)
 a.poly([(320,45),(246,31),(210,47),(210,92),(265,82),(320,104)],'white','brown',5)
 a.poly([(325,45),(384,31),(425,47),(425,92),(380,82),(325,104)],'white','brown',5)
 a.line([(321,46),(322,104)],'brown',4)
 return a

def flat_cap():
 a=A(640,640)
 a.poly([(131,286),(168,202),(268,166),(381,171),(477,221),(500,322),(475,348),(167,351)],'tan','ink',11)
 a.poly([(132,339),(184,309),(340,306),(468,337),(469,359),(346,393),(150,386),(102,367)],'brown','ink',10)
 a.line([(203,227),(276,321)],'brown',5);a.line([(357,193),(342,307)],'brown',5)
 return a

def cool_shades():
 a=A(640,640)
 for x in (90,327):a.rect((x,253,x+221,400),'dark','ink',10,r=38)
 a.line([(311,289),(327,289)],'ink',15)
 a.line([(92,290),(57,276)],'ink',10);a.line([(550,290),(586,279)],'ink',10)
 return a

def smart_tie():
 a=A(640,640)
 a.poly([(147,249),(217,246),(280,318),(319,312),(351,318),(418,246),(498,251),(431,360),(359,385),(283,385),(213,357)],'cream','ink',9)
 a.poly([(298,337),(343,337),(358,374),(322,405),(285,373)],'navy','ink',7)
 a.poly([(303,402),(340,402),(383,516),(320,554),(269,518)],'navy','ink',9)
 a.line([(310,425),(351,442)],'sky',10);a.line([(285,487),(365,506)],'sky',10)
 return a

def stripe_wall():
 a=A(1200,525,'#FFF2DD')
 for x in range(0,1200,155):
  a.rect((x,0,x+79,525),'#88ADC5',None)
  a.rect((x+80,0,x+96,525),'#E1C7A5',None)
 return a

def clock_decor():
 a=A(410,396)
 a.ellipse((76,45,334,319),'brown','ink',11)
 a.ellipse((99,68,311,295),'cream',None)
 for i in range(12):
  th=2*math.pi*i/12
  cx,cy=205,182
  a.line([(cx+math.sin(th)*82,cy-math.cos(th)*82),(cx+math.sin(th)*94,cy-math.cos(th)*94)],'brown',5)
 a.line([(205,182),(205,106)],'ink',8);a.line([(205,182),(258,209)],'ink',8)
 a.ellipse((195,172,215,192),'ink',None)
 return a

def casual_rug():
 a=A(640,130);a.ellipse((15,5,625,125),'navy','ink',6);a.ellipse((36,17,604,113),'cream',None)
 for x in range(104,606,102):a.line([(x,22),(x,108)],'#A2BDCA',8)
 for y in (48,86):a.line([(56,y),(585,y)],'#A2BDCA',7)
 return a

def witch_hat():
 a=A(640,640)
 a.poly([(230,312),(300,101),(329,77),(354,117),(400,211),(458,273),(439,325)],'purple','ink',12)
 a.poly([(150,344),(236,306),(435,311),(519,342),(505,365),(427,390),(226,389),(119,368)],'purple','ink',11)
 a.poly([(214,287),(447,300),(444,324),(204,322)],'orange',None)
 a.rect((296,298,347,342),'yellow','ink',5,r=3)
 return a

def pumpkin_mask():
 a=A(640,640)
 # mask must leave cheeks and eyes readable: open goggles shaped like pumpkins
 for x in (89,331):
  a.ellipse((x,256,x+214,413),'orange','ink',11)
  a.ellipse((x+51,283,x+161,392),None,'ink',7)
  a.poly([(x+89,255),(x+103,239),(x+115,255)],'leaf',None)
 a.line([(303,317),(338,317)],'brown',10)
 return a

def candy_bow():
 a=A(640,640)
 a.poly([(293,315),(110,258),(105,454),(294,398)],'white','ink',10)
 a.poly([(344,315),(520,258),(533,454),(345,398)],'white','ink',10)
 a.poly([(127,275),(185,297),(183,431),(108,449)],'yellow',None)
 a.poly([(192,300),(281,323),(280,394),(192,423)],'orange',None)
 a.poly([(360,322),(456,292),(454,432),(365,394)],'orange',None)
 a.poly([(466,287),(515,269),(533,448),(469,433)],'yellow',None)
 a.rect((288,310,351,401),'yellow','ink',10,r=20)
 return a

def halloween_wall():
 a=A(1200,525,'#413458')
 for r in range(3):
  for c in range(8):
   x=85+c*155+(55 if r%2 else 0);y=68+r*168
   if c%3==0:
    a.ellipse((x-19,y-22,x+21,y+21),'yellow',None)
    a.ellipse((x-5,y-25,x+34,y+12),'#413458',None)
   elif c%3==1:
    a.ellipse((x-24,y-17,x+24,y+19),'orange',None)
    a.line([(x,y-17),(x+2,y-29)],'leaf3',6)
   else:
    a.poly([(x,y-17),(x+8,y-3),(x+23,y),(x+10,y+10),(x+7,y+22),(x,y+10),(x-8,y+22),(x-10,y+10),(x-24,y),(x-8,y-3)],'yellow',None)
 return a

def ghost_decor():
 a=A(410,396)
 a.line([(203,10),(115,76),(296,76),(203,10)],'brown',7)
 a.line([(86,74),(321,74)],'brown',14)
 a.poly([(127,279),(127,171),(143,121),(190,97),(234,101),(269,126),(283,176),(283,280),(253,263),(228,285),(205,265),(178,285),(155,264)],'white','ink',9)
 for x in (182,227):a.ellipse((x-11,174,x+11,203),'ink',None)
 return a

def pumpkin_rug():
 a=A(640,130);a.ellipse((28,12,610,120),'orange','ink',7)
 for x in (247,392):a.arc((x-114,17,x+114,118),75,105,'brown',5)
 a.poly([(225,55),(276,66),(237,90)],'ink',None);a.poly([(365,66),(417,55),(405,91)],'ink',None)
 a.poly([(320,96),(289,80),(351,80)],'ink',None)
 return a

def holly_glasses():
 a=A(640,640);lenses(a,'leaf3')
 for x in (143,499):
  leaf(a,x-17,243,.60,'leaf');leaf(a,x+14,244,.58,'leaf')
  a.ellipse((x-7,263,x+8,279),'red',None)
 return a

def holiday_scarf():
 a=A(640,640)
 a.poly([(117,270),(192,229),(438,229),(525,268),(484,359),(402,391),(232,390),(155,349)],'red','ink',12)
 a.poly([(269,350),(359,345),(396,540),(302,547)],'leaf','ink',10)
 a.poly([(361,353),(416,348),(458,520),(400,530)],'red','ink',8)
 a.line([(200,251),(229,375)],'cream',16);a.line([(399,253),(426,373)],'cream',16)
 a.line([(312,442),(372,440)],'cream',12)
 return a

def christmas_wall():
 a=A(1200,525,'#D7E7DE')
 for r in range(4):
  for c in range(9):
   x=70+143*c+(64 if r%2 else 0);y=48+133*r
   if c%2==0:
    # low-detail snowflake
    for dx,dy in [(-20,0),(20,0),(0,-20),(0,20)]:a.line([(x,y),(x+dx,y+dy)],'white',5)
   else:
    leaf(a,x,y,.42,'leaf');a.ellipse((x+15,y+16,x+31,y+31),'red',None)
 return a

def wreath_decor():
 a=A(410,396)
 for i in range(14):
  ang=i*2*math.pi/14
  x=205+120*math.sin(ang);y=195+108*math.cos(ang)
  a.ellipse((x-42,y-38,x+42,y+38),'leaf' if i%2 else 'leaf3',None)
  if i%3==0:a.ellipse((x-10,y-8,x+10,y+10),'red',None)
 a.ellipse((141,133,269,258),(0,0,0,0),None) # alpha hole needs explicit cut below
 # cut transparent hole safely only where inner wreath (not affecting nearby accents)
 a.d.ellipse(tuple(round(v*AA) for v in (146,140,263,253)),fill=(0,0,0,0))
 a.poly([(153,87),(205,110),(258,87),(250,137),(205,127),(162,138)],'red','ink',7)
 return a

def holiday_rug():
 a=A(640,130);a.ellipse((17,4,623,126),'leaf','ink',6);a.ellipse((36,16,604,114),'cream',None)
 a.ellipse((63,20,576,108),None,'red',6)
 for x in (205,316,428):
  a.poly([(x,35),(x+14,54),(x+38,56),(x+18,72),(x+26,97),(x,81),(x-26,97),(x-18,72),(x-38,56),(x-14,54)],'red' if x!=316 else 'leaf',None)
 return a

def carrot_glasses():
 a=A(640,640);lenses(a,'orange')
 for x in (189,435):
  leaf(a,x-11,239,.55,'leaf');leaf(a,x+14,238,.51,'leaf')
 return a

def egg_ribbon():
 a=A(640,640)
 a.arc((106,236,529,435),12,168,'leaf',17)
 a.poly([(276,352),(152,300),(147,443),(277,396)],'pink','ink',8)
 a.poly([(359,352),(483,300),(490,443),(359,396)],'pink','ink',8)
 a.ellipse((284,337,351,405),'cream','ink',8)
 flower(a,318,369,.50,'white')
 return a

def easter_wall():
 a=A(1200,525,'#FCE8EC')
 for r in range(4):
  for c in range(8):
   x=70+c*156+(70 if r%2 else 0);y=56+128*r
   col=['#A6CDEE','#F3D376','#EDA7C2'][c%3]
   a.ellipse((x-22,y-32,x+22,y+30),col,None)
   a.line([(x-17,y),(x+17,y)],'white',5)
   if c%3==2:flower(a,x+48,y-15,.36)
 return a

def basket_decor():
 a=A(410,396)
 a.arc((91,77,319,292),181,359,'brown',12)
 a.poly([(96,218),(314,218),(290,332),(126,332)],'tan','ink',9)
 for x,c in [(156,'pink'),(204,'sky'),(255,'yellow')]:
  a.ellipse((x-40,166,x+40,242),c,'ink',6)
 a.line([(116,256),(293,256)],'brown',6)
 flower(a,112,202,.50);flower(a,295,201,.50)
 return a

def egg_rug():
 a=A(640,130);a.ellipse((15,4,625,127),'leaf','ink',5);a.ellipse((33,17,607,114),'cream',None)
 for x,color in [(228,'pink'),(318,'yellow'),(410,'sky')]:
  a.ellipse((x-41,31,x+41,98),color,'ink',4)
  a.line([(x-31,68),(x+31,68)],'white',6)
 return a

def doodle_wall():
 a=A(1200,525,'#FFF0C4')
 for r in range(4):
  for c in range(9):
   x=61+c*139+(51 if r%2 else 0);y=59+136*r
   if (r+c)%4==0:a.ellipse((x-22,y-22,x+22,y+22),'sky',None)
   elif (r+c)%4==1:a.poly([(x,y-24),(x+12,y-7),(x+30,y),(x+12,y+10),(x+10,y+27),(x,y+13),(x-10,y+27),(x-12,y+10),(x-30,y),(x-12,y-7)],'yellow',None)
   elif (r+c)%4==2:a.ellipse((x-10,y-10,x+10,y+10),'mauve',None)
   else:leaf(a,x,y,.35,'leaf2')
 return a

def spiral_rug():
 a=A(640,130);a.ellipse((18,5,622,125),'#5585BD','ink',5);a.ellipse((35,16,605,114),'cream',None)
 # visually legible curved spiral using connected short segments
 coords=[]
 for i in range(61):
  t=i/60*math.pi*4.3;rad=8+i/60*185
  coords.append((320+math.cos(t)*rad,65+math.sin(t)*rad*.26))
 a.line(coords,'#5585BD',13)
 return a

DRAW={
 'pet/head/leaf_hat.png':leaf_cap, 'pet/face/leaf_glasses.png':leafy_glasses,'pet/neck/vine_collar.png':vine_collar,
 'room/wall/sage_wallpaper.png':nature_wall,'room/decor/hanging_plant.png':plant_decor,'room/rug/leaf_rug.png':leaf_rug,
 'pet/head/study_beret.png':beret,'pet/face/glasses.png':study_glasses,'pet/neck/study_scarf.png':study_scarf,
 'room/wall/notebook_wallpaper.png':ruled_wall,'room/decor/framed_book.png':framed_book,'room/rug/book_rug.png':book_rug,
 'pet/head/brown_flat_cap.png':flat_cap,'pet/face/sunglasses.png':cool_shades,'pet/neck/necktie.png':smart_tie,
 'room/wall/blue_gray_stripes.png':stripe_wall,'room/decor/wall_clock.png':clock_decor,'room/rug/casual_rug.png':casual_rug,
 'pet/head/witch_hat.png':witch_hat,'pet/face/pumpkin_mask.png':pumpkin_mask,'pet/neck/candy_corn_bowtie.png':candy_bow,
 'room/wall/halloween_wallpaper.png':halloween_wall,'room/decor/ghost_wall_hanging.png':ghost_decor,'room/rug/pumpkin_rug.png':pumpkin_rug,
 'pet/face/holly_glasses.png':holly_glasses,'pet/neck/holiday_scarf.png':holiday_scarf,
 'room/wall/christmas_wallpaper.png':christmas_wall,'room/decor/wreath.png':wreath_decor,'room/rug/holiday_rug.png':holiday_rug,
 'pet/face/carrot_glasses.png':carrot_glasses,'pet/neck/spring_bow_tie.png':egg_ribbon,
 'room/wall/easter_wallpaper.png':easter_wall,'room/decor/easter_basket.png':basket_decor,'room/rug/easter_egg_rug.png':egg_rug,
 'room/wall/brainrot_wallpaper.png':doodle_wall,'room/rug/brainrot_spiral_rug.png':spiral_rug,
}
if __name__=='__main__':
 for p,fun in DRAW.items():
  img=fun();img.out(p)
 print(f'Generated {len(DRAW)} native-canvas flat redesign PNGs, Pixel Knight/Thanksgiving/Bear Spirit unchanged.')

/* Production slicing/fitting for the ImageGen-authored v1.6.24 flat atlases.
 * Requires Node.js and sharp. No drawing or generative code: retain source art,
 * separate the atlas islands, and place them on the established game canvases.
 * Run: node tools/prepare_shop_art.cjs [theme ...]
 */
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const ROOT = path.resolve(__dirname, '..');
const SOURCE = path.join(__dirname, 'shop_art_v1_6_24');
const raw = fs.readFileSync(path.join(ROOT, 'data/shop.gd'), 'utf8');
const records = [...raw.matchAll(/^\s*"([^"\n]+)":\{"name":"([^"\n]+)", "theme":"([^"\n]+)", "category":"(pet|room)", "slot":"([^"\n]+)".*?"texture":preload\("res:\/\/([^"\n]+)"\)/gm)]
  .map(m => ({id:m[1], name:m[2], theme:m[3], category:m[4], slot:m[5], file:m[6]}));
const SLOTS = ['head','face','neck','decor','wall','rug','window','left_shelf','side_hanging','right_plant','food_bowl','floor_cushion'];
const SIZES = {head:[640,640],face:[640,640],neck:[640,640],decor:[410,396],wall:[1200,525],rug:[640,130],window:[242,222],left_shelf:[200,155],side_hanging:[95,150],right_plant:[154,224],food_bowl:[114,64],floor_cushion:[171,92]};
const themes = process.argv.slice(2).length ? process.argv.slice(2) : [...new Set(records.map(x=>x.theme))];
const transparent = (w,h) => sharp({create:{width:w,height:h,channels:4,background:'#00000000'}});

// Connected opaque support identifies each separate atlas sprite regardless of
// minor differences between generated cell margins. Preserve a two-pixel alpha
// fringe around that support, discarding detached transparent-background residue.
function components(data,w,h,threshold=220,inverted=false) {
  const seen = new Uint8Array(w*h), queue = new Int32Array(w*h), out=[];
  const active = n => inverted ? data[n*4+3]<threshold : data[n*4+3]>=threshold;
  for(let n=0;n<w*h;n++) {
    if(seen[n] || !active(n)) continue;
    let start=0,end=1;queue[0]=n;seen[n]=1;
    let x0=w,y0=h,x1=0,y1=0,sx=0,sy=0;
    while(start<end) {
      const i=queue[start++],x=i%w,y=Math.floor(i/w);
      x0=Math.min(x0,x);y0=Math.min(y0,y);x1=Math.max(x1,x+1);y1=Math.max(y1,y+1);sx+=x;sy+=y;
      const adjacent=[];
      if(x)adjacent.push(i-1);if(x+1<w)adjacent.push(i+1);if(y)adjacent.push(i-w);if(y+1<h)adjacent.push(i+w);
      for(const j of adjacent) if(!seen[j]&&active(j)){seen[j]=1;queue[end++]=j;}
    }
    if(end>50)out.push({x0,y0,x1,y1,area:end,cx:sx/end,cy:sy/end,pixels:Int32Array.from(queue.subarray(0,end))});
  }
  return out;
}
async function spriteAtlas(theme) {
  const {data,info}=await sharp(path.join(SOURCE,theme+'.png')).ensureAlpha().raw().toBuffer({resolveWithObject:true});
  const comps=components(data,info.width,info.height);
  const selected=new Map();
  for(const c of comps) {
    if(c.area<1800)continue;
    const col=Math.min(3,Math.floor(c.cx/info.width*4)),row=Math.min(2,Math.floor(c.cy/info.height*3));
    const idx=row*4+col;
    if(!selected.has(idx)||selected.get(idx).area<c.area)selected.set(idx,c);
  }
  const missing=SLOTS.filter((s,i)=>!selected.has(i)&&!fs.existsSync(path.join(SOURCE,theme+'_'+s+'.png')));
  if(missing.length)throw Error(theme+': missing atlas sprites '+missing.join(','));
  const sprites={};
  for(let idx=0;idx<12;idx++) {
    if(!selected.has(idx)){
      sprites[SLOTS[idx]]=await singleSprite(path.join(SOURCE,theme+'_'+SLOTS[idx]+'.png'));
      continue;
    }
    const c=selected.get(idx), mask=new Uint8Array(info.width*info.height);
    for(const n of c.pixels) {
      const x=n%info.width,y=Math.floor(n/info.width);
      for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++){
        if(x+dx>=0&&x+dx<info.width&&y+dy>=0&&y+dy<info.height)mask[(y+dy)*info.width+x+dx]=1;
      }
    }
    const x=Math.max(0,c.x0-2),y=Math.max(0,c.y0-2),w=Math.min(info.width,c.x1+2)-x,h=Math.min(info.height,c.y1+2)-y;
    const pixels=Buffer.alloc(w*h*4);
    for(let py=0;py<h;py++)for(let px=0;px<w;px++){
      const sn=(y+py)*info.width+x+px,dn=py*w+px;
      if(mask[sn])data.copy(pixels,dn*4,sn*4,sn*4+4);
    }
    sprites[SLOTS[idx]]={pixels,w,h,source:[x,y,w,h]};
  }
  return sprites;
}
function image(s){return sharp(s.pixels,{raw:{width:s.w,height:s.h,channels:4}});}
async function singleSprite(file){
  const {data,info}=await sharp(file).ensureAlpha().raw().toBuffer({resolveWithObject:true});
  const c=components(data,info.width,info.height,245).sort((a,b)=>b.area-a.area)[0];
  if(!c)throw Error('Empty sprite: '+file);
  const support=new Uint8Array(info.width*info.height);
  for(const n of c.pixels){const x=n%info.width,y=Math.floor(n/info.width);for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++){if(x+dx>=0&&x+dx<info.width&&y+dy>=0&&y+dy<info.height)support[(y+dy)*info.width+x+dx]=1;}}
  const x0=Math.max(0,c.x0-2),y0=Math.max(0,c.y0-2),w=Math.min(info.width,c.x1+2)-x0,h=Math.min(info.height,c.y1+2)-y0,pixels=Buffer.alloc(w*h*4);
  for(let y=0;y<h;y++)for(let x=0;x<w;x++){const sn=(y0+y)*info.width+x0+x;if(support[sn])data.copy(pixels,(y*w+x)*4,sn*4,sn*4+4);}
  return {pixels,w,h,source:[x0,y0,w,h]};
}
async function resized(s,w,h,pixel=false) {
  if(pixel){
    const stride=typeof pixel==='number'?pixel:2;
    const bw=Math.max(1,Math.round(w/stride)),bh=Math.max(1,Math.round(h/stride));
    // Do not threshold RGB: keep the source palette while enforcing a pixel grid.
    const small=await image(s).resize(bw,bh,{fit:'fill',kernel:'nearest'}).png().toBuffer();
    return sharp(small).resize(w,h,{kernel:'nearest',fit:'fill'}).png().toBuffer();
  }
  return image(s).resize(w,h,{kernel:'lanczos3',fit:'fill'}).png().toBuffer();
}
function containSize(s,w,h){const r=Math.min(w/s.w,h/s.h);return [Math.max(1,Math.round(s.w*r)),Math.max(1,Math.round(s.h*r))];}
async function fitted(s,canvas,box,pixel=false,stretch=false) {
  const [cw,ch]=canvas,[bx,by,bw,bh]=box;
  const [w,h]=stretch?[bw,bh]:containSize(s,bw,bh);
  const input=await resized(s,w,h,pixel);
  return transparent(cw,ch).composite([{input,left:Math.round(bx+(bw-w)/2),top:Math.round(by+(bh-h)/2)}]).png().toBuffer();
}
function lensHoles(s){
  return components(s.pixels,s.w,s.h,100,true).filter(c=>c.x0>0&&c.y0>0&&c.x1<s.w&&c.y1<s.h&&c.area>250).sort((a,b)=>b.area-a.area);
}
async function face(s,theme){
  if(theme==='pixel_knight')return fitted(s,[640,640],[25,62,590,490],7,true);
  const holes=lensHoles(s);
  let scale,left,top;
  if(theme==='brainrot'&&holes.length){
    scale=500/s.w;left=Math.round((320-32*640/183)-holes[0].cx*scale);top=Math.round(320-holes[0].cy*scale);
  }else if(holes.length>=2){
    const pair=holes.slice(0,2).sort((a,b)=>a.cx-b.cx);
    scale=(64*640/183)/(pair[1].cx-pair[0].cx);
    scale=Math.min(scale,610/s.w,570/s.h);
    left=Math.round(320-(pair[0].cx+pair[1].cx)/2*scale);
    top=Math.round(320-(pair[0].cy+pair[1].cy)/2*scale);
  }else{
    scale=520/s.w;left=60;top=Math.round(320-s.h*scale/2);
  }
  const w=Math.round(s.w*scale),h=Math.round(s.h*scale);
  left=Math.max(4,Math.min(636-w,left));top=Math.max(4,Math.min(636-h,top));
  return transparent(640,640).composite([{input:await resized(s,w,h),left,top}]).png().toBuffer();
}
async function wallpaper(s,pixel){
  // Crop inside the opaque swatch. Mirrored repeats keep joins continuous and
  // avoid stretching the little motifs into the room's wide rectangle.
  const inset=Math.round(Math.min(s.w,s.h)*0.08);
  const tile=await image(s).extract({left:inset,top:inset,width:s.w-2*inset,height:s.h-2*inset}).flatten({background:'#f5ead0'}).resize(300,263,{kernel:pixel?'nearest':'lanczos3'}).png().toBuffer();
  const layers=[];
  for(let row=0;row<2;row++)for(let col=0;col<4;col++){
    let cell=sharp(tile);if(row)cell=cell.flip();if(col%2)cell=cell.flop();
    layers.push({input:await cell.toBuffer(),left:col*300,top:row*263});
  }
  const large=await sharp({create:{width:1200,height:526,channels:4,background:'#f5ead0'}}).composite(layers).png().toBuffer();
  return sharp(large).extract({left:0,top:0,width:1200,height:525}).ensureAlpha().png().toBuffer();
}
async function build(theme){
  const sprites=await spriteAtlas(theme),pixel=theme==='pixel_knight',report={};
  for(const slot of SLOTS.filter(s=>s!=='wall')){
    const override=path.join(SOURCE,theme+'_'+slot+'.png');
    if(fs.existsSync(override))sprites[slot]=await singleSprite(override);
  }
  for(const slot of SLOTS){
    const s=sprites[slot];let png;
    if(slot==='face')png=await face(s,theme);
    else if(slot==='wall'){
      let source=sharp(path.join(SOURCE,theme+'_wall.png')).flatten({background:'#f5ead0'});
      if(pixel){const small=await source.resize(600,263,{fit:'fill',kernel:'nearest'}).png().toBuffer();source=sharp(small);}
      png=await source.resize(1200,525,{fit:'fill',kernel:pixel?'nearest':'lanczos3'}).ensureAlpha().png().toBuffer();
    }
    else if(slot==='head'){
      if(theme==='pixel_knight')png=await fitted(s,[640,640],[30,28,500,368],11,true);
      else {const w=632,h=Math.min(430,Math.round(s.h*632/s.w));png=await fitted(s,[640,640],[4,444-h,w,h],false,true);}
    }else if(slot==='neck'){
      let box;
      if(theme==='pixel_knight')box=[18,161,604,475];
      else if(['smart_casual','brainrot'].includes(theme))box=[140,125,360,500];
      else if(['halloween','thanksgiving'].includes(theme))box=[14,200,612,320];
      else if(theme==='nature')box=[14,170,612,380];
      else if(theme==='easter')box=[14,170,612,400];
      else box=[14,145,612,470];
      png=await fitted(s,[640,640],box,pixel?12:false,pixel);
    }else{
      const [w,h]=SIZES[slot];
      const boxes={decor:[85,4,240,176],rug:[8,4,624,122],window:[0,0,w,h],left_shelf:[1,6,w-2,h-7],side_hanging:[5,2,w-10,h-4],right_plant:[1,1,w-2,h-2],food_bowl:[1,1,w-2,h-2],floor_cushion:[1,1,w-2,h-2]};
      png=await fitted(s,[w,h],boxes[slot],pixel,['rug','window','left_shelf','food_bowl','floor_cushion'].includes(slot));
    }
    if(slot==='decor'||slot==='rug'){
      const {data,info}=await sharp(png).raw().toBuffer({resolveWithObject:true});
      let x0=info.width,x1=0;
      for(let y=0;y<info.height;y++)for(let x=0;x<info.width;x++)if(data[(y*info.width+x)*4+3]){x0=Math.min(x0,x);x1=Math.max(x1,x+1);}
      const content=await sharp(png).extract({left:x0,top:0,width:x1-x0,height:info.height}).png().toBuffer();
      png=await transparent(info.width,info.height).composite([{input:content,left:Math.floor((info.width-x1+x0)/2),top:0}]).png().toBuffer();
    }
    const record=records.find(x=>x.theme===theme&&x.slot===slot);
    const file=record?record.file:`assets/shop/room/decor_sets/${theme}/${slot}.png`;
    fs.mkdirSync(path.dirname(path.join(ROOT,file)),{recursive:true});fs.writeFileSync(path.join(ROOT,file),png);
    report[slot]={file,canvas:SIZES[slot],source:s.source};
  }
  console.log(theme+': 6 shop assets + 6 room accents fitted');return report;
}
(async()=>{const report={};for(const theme of themes)report[theme]=await build(theme);fs.writeFileSync(path.join(SOURCE,'fit-report.json'),JSON.stringify(report,null,2));})().catch(e=>{console.error(e);process.exit(1);});

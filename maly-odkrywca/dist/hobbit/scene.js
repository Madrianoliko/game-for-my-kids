/* Original low-poly scenery for Mały Odkrywca. Three.js is bundled locally. */
(() => {
  'use strict';
  const T = window.THREE;
  const route = z => 1.45 * Math.sin(z * 0.102) + 0.6 * Math.sin(z * 0.173);
  const stops = [4, -7, -18, -30];

  function randomGenerator(seed) {
    return () => {
      seed = (Math.imul(1664525, seed) + 1013904223) >>> 0;
      return seed / 4294967296;
    };
  }

  function buildTools(root) {
    const materials = new Map();
    const primitives = new Map();
    const geometries = new Set();
    const getGeometry = (key, create) => {
      if (!primitives.has(key)) primitives.set(key, create());
      return primitives.get(key);
    };
    function material(color) {
      if (!materials.has(color)) materials.set(color, new T.MeshStandardMaterial({
        color, flatShading: true, roughness: 0.91, metalness: 0.025
      }));
      return materials.get(color);
    }
    function mesh(parent, geometry, color, x = 0, y = 0, z = 0) {
      geometries.add(geometry);
      const m = new T.Mesh(geometry, material(color));
      m.position.set(x, y, z);
      m.castShadow = true;
      m.receiveShadow = true;
      if (parent) parent.add(m);
      return m;
    }
    function box(p,x,y,z,w,h,d,c,rot=0) {
      const m = mesh(p, getGeometry('box', () => new T.BoxGeometry()), c,x,y,z);
      m.scale.set(w,h,d);
      m.rotation.y = rot;
      return m;
    }
    function cyl(p,x,y,z,rt,rb,h,n,c) {
      const geo = getGeometry(['c',rt,rb,n].join(','), () => new T.CylinderGeometry(rt,rb,1,n));
      const m = mesh(p,geo,c,x,y,z);
      m.scale.y = h;
      return m;
    }
    function ball(p,x,y,z,rx,ry,rz,c,detail=0) {
      const m = mesh(p,getGeometry('ball'+detail, () => new T.IcosahedronGeometry(1,detail)),c,x,y,z);
      m.scale.set(rx,ry,rz);
      return m;
    }
    function group(parent,x=0,y=0,z=0) {
      const g = new T.Group();
      g.position.set(x,y,z);
      if (parent) parent.add(g);
      return g;
    }
    return {T,root,group,box,cyl,ball,mesh,path:route,geometries,materials};
  }

  // All stationary props share one draw call, including their per-face colours.
  function combineStationary(ctx) {
    const positions = [], colors = [], normals = [];
    const vertex = new T.Vector3(), normal = new T.Vector3(), normalMatrix = new T.Matrix3();
    ctx.root.updateMatrixWorld(true);
    ctx.root.traverse(obj => {
      if (!obj.isMesh) return;
      const geo = obj.geometry;
      const pos = geo.attributes.position, nor = geo.attributes.normal, tint = geo.attributes.color;
      const indices = geo.index;
      normalMatrix.getNormalMatrix(obj.matrixWorld);
      const color = obj.material.color;
      for (let k=0, len = indices ? indices.count : pos.count; k<len; k++) {
        const i = indices ? indices.getX(k) : k;
        vertex.fromBufferAttribute(pos,i).applyMatrix4(obj.matrixWorld);
        normal.fromBufferAttribute(nor,i).applyMatrix3(normalMatrix).normalize();
        positions.push(vertex.x,vertex.y,vertex.z);
        normals.push(normal.x,normal.y,normal.z);
        colors.push(color.r * (tint ? tint.getX(i) : 1),color.g * (tint ? tint.getY(i) : 1),color.b * (tint ? tint.getZ(i) : 1));
      }
    });
    ctx.root.clear();
    const geometry = new T.BufferGeometry();
    geometry.setAttribute('position',new T.Float32BufferAttribute(positions,3));
    geometry.setAttribute('color',new T.Float32BufferAttribute(colors,3));
    geometry.setAttribute('normal',new T.Float32BufferAttribute(normals,3));
    const material = new T.MeshStandardMaterial({vertexColors:true,flatShading:true,roughness:0.91,metalness:0.025});
    const model = new T.Mesh(geometry,material);
    model.castShadow = true;
    model.receiveShadow = true;
    ctx.root.add(model);
    ctx.geometries.add(geometry);
    ctx.materials.set('combined',material);
  }

  function ribbon(ctx, from, to, step, left, right, height, color) {
    const vertices = [];
    for (let z=from; z>to; z-=step) {
      const next = Math.max(to,z-step);
      vertices.push(left(z),height,z, right(z),height,z, left(next),height,next,
                    right(z),height,z, right(next),height,next, left(next),height,next);
    }
    const shape = new T.BufferGeometry();
    shape.setAttribute('position',new T.Float32BufferAttribute(vertices,3));
    shape.computeVertexNormals();
    return ctx.mesh(ctx.root,shape,color);
  }

  function pine(ctx,p,x,z,h,tone) {
    const g = ctx.group(p,x,0,z);
    g.rotation.y = x*0.52;
    ctx.cyl(g,0,h*0.21,0,h*.043,h*.072,h*.42,7,'#81553a');
    ctx.cyl(g,0,h*.46,0,0,h*.27,h*.63,7,tone);
    ctx.cyl(g,0,h*.65,0,0,h*.216,h*.52,7,tone);
    ctx.cyl(g,0,h*.815,0,0,h*.15,h*.38,7,tone);
  }

  function oak(ctx,p,x,z,h,tone) {
    const g = ctx.group(p,x,0,z);
    ctx.cyl(g,0,h*.32,0,h*.043,h*.088,h*.64,7,'#805038');
    const b = ctx.cyl(g,-h*.08,h*.49,0,h*.025,h*.045,h*.32,6,'#946340');
    b.rotation.z=0.6;
    const c = ctx.cyl(g,h*.08,h*.49,-h*.03,h*.027,h*.05,h*.30,6,'#805038');
    c.rotation.z=-0.61;
    ctx.ball(g,0,h*.80,0,h*.28,h*.27,h*.27,tone,1);
    ctx.ball(g,-h*.16,h*.68,h*.02,h*.22,h*.22,h*.24,tone,0);
    ctx.ball(g,h*.16,h*.70,-h*.03,h*.22,h*.19,h*.24,tone,1);
  }

  function hillHouse(ctx,x,z,scale,heading,door) {
    const {root,group,box,cyl,ball} = ctx;
    const g = group(root,x,0,z);
    g.scale.setScalar(scale);
    g.rotation.y=heading;
    ball(g,0,-0.36,-.56,3.3,2.6,2.45,'#72a33c',1);
    ball(g,0,-0.43,-.15,2.9,2.29,1.77,'#90b446',1);
    function disc(px,py,pz,r,d,color) {
      const m = cyl(g,px,py,pz,r,r,d,20,color);
      m.rotation.x=Math.PI/2;
      return m;
    }
    box(g,0,0.80,1.41,3.35,1.58,0.58,'#e6be77');
    box(g,0,1.59,1.46,3.62,0.18,0.73,'#82603a');
    disc(0,0.77,1.8,.91,.32,'#705034');
    disc(0,0.77,1.99,.78,.17,door);
    for (let i=-3;i<=3;i++) {
      const dx=i*.19, high=Math.sqrt(.75*.75-dx*dx);
      box(g,dx,0.77,2.081,0.015,high*1.92,.009,'#8a693a');
    }
    disc(.31,.77,2.13,.078,.09,'#eac451');
    for (const side of [-1,1]) {
      disc(side*1.24,.95,1.755,.35,.14,'#6b573c');
      disc(side*1.24,.95,1.835,.263,.05,'#f5dc92');
      box(g,side*1.24,.95,1.872,.048,.50,.035,'#8e6445');
      box(g,side*1.24,.95,1.872,.50,.048,.035,'#8e6445');
      box(g,side*1.24,.55,1.82,.83,.15,.30,'#a66e3b');
    }
    box(g,-1.31,1.95,-.16,.45,1.5,.48,'#ba764e');
    box(g,-1.31,2.71,-.16,.59,.16,.60,'#8c5037');
    for(let i=0;i<3;i++) {
      const tile=ball(g,Math.sin(i*.9)*.09,.025,2.23+i*.46,.43,.09,.28,'#b5ae90');
      tile.rotation.y=i*2;
    }
    for(let i=0;i<6;i++) {
      const side=i%2===0?1:-1;
      const px=side*(1.03+.32*Math.floor(i/2));
      ball(g,px,.15,1.96,.32,.24,.25,'#76a23e');
      ball(g,px+.03,.32,2,.1,.085,.095,i%3?'#e5a832':'#d77875');
    }
  }

  function bridge(ctx,centerZ) {
    const g = ctx.group(ctx.root,route(centerZ),0,centerZ);
    // The two fixed end boards stay in place above the banks. The missing
    // middle boards are animated individually once the child counts them.
    for (const edge of [-1,1]) {
      ctx.box(g,0,.21,edge*1.958,4.1,.20,.388,'#ba8752');
      ctx.box(g,edge*1.14,.117,0,.24,.15,4.26,'#986c42');
    }
    for(const sign of [-1,1]) {
      for(const dz of [-2.1,0,2.1]) {
        ctx.cyl(g,sign*2,.55,dz,.10,.15,1.15,7,'#825638');
        ctx.cyl(g,sign*2,1.12,dz,.145,.145,.12,7,'#d1a26c');
      }
      ctx.box(g,sign*2,.89,0,.12,.12,4.38,'#a57848');
    }
  }

  function valley(ctx,rand) {
    const {box,ball,root}=ctx;
    for (const args of [[-6.8,-4,1.1,.55,'#d89e38'],[8.4,-9,1.06,-.65,'#57946c'],[-7.5,-23,1.35,.55,'#c98134'],[8,-31,.92,-.60,'#617d4a'],[-6.3,-43,.90,.49,'#c98c32']]) hillHouse(ctx,...args);
    const waterVerts=[];
    for(let x=-53; x<53; x+=1.25) {
      const y=.065, z1=-2.0+.61*Math.sin(x*.21), z2=-2.0+.61*Math.sin((x+1.25)*.21);
      waterVerts.push(x,y,z1+1.35, x+1.25,y,z2+1.35, x,y,z1-1.35,
        x+1.25,y,z2+1.35,x+1.25,y,z2-1.35,x,y,z1-1.35);
    }
    const geo=new T.BufferGeometry();
    geo.setAttribute('position',new T.Float32BufferAttribute(waterVerts,3));
    geo.computeVertexNormals();
    ctx.mesh(root,geo,'#39abd0');
    for(let i=0;i<48;i++){
      const x=(rand()-.5)*70, z=-2+.61*Math.sin(x*.21);
      box(root,x,.083,z+(rand()-.5)*1.9,.30+rand()*.65,.013,.026+rand()*.05,'#88dce0');
      if (i%3===0 && Math.abs(x)>2.9) ball(root,x,.04,z+(i%2===0?1.38:-1.38),.28,.17,.2,'#a6b6a0');
    }
    bridge(ctx,-2);
    for(const [x,z,dir] of [[-5,-13,.15],[7,-19,-.3],[-6,-33,.09]]) {
      const f=ctx.group(root,x,0,z); f.rotation.y=dir;
      for(let i=0;i<6;i++) {
        box(f,0,.49,i*.83,.14,.97,.16,'#a9824f');
        const cap=ctx.cyl(f,0,1.04,i*.83,0,.13,.18,4,'#d6af73');
        cap.rotation.y=.785;
      }
      for(const h of [.35,.75])box(f,0,h,2.1,.10,.1,4.3,'#c29a63');
    }
  }
  // Textured sky, flat-lit models and a reciprocal-depth buffer keep the same
  // route playable on browsers which decline to create a WebGL context.
  function createSoftwareRenderer(canvas) {
    let ctx;
    try { ctx = canvas.getContext('2d', {alpha:false}); } catch (_) { return null; }
    if (!ctx) return null;

    let width=0, height=0, frame=null, pixels=null, depth=null, sky=null;
    let lastDraw=-Infinity;
    let records=new WeakMap();
    const matrix=new T.Matrix4();
    const normalMatrix=new T.Matrix3();
    const norm=new T.Vector3();
    const fillColor=new T.Color();
    const maxSize=590, maxPixels=172000;
    const nearPoly=new Float64Array(12);
    // Canvas ImageData stores RGBA bytes. Select the packed representation once.
    const little=new Uint8Array(new Uint32Array([1]).buffer)[0]===1;
    function pack(r,g,b) {
      return little ? ((255<<24)|(b<<16)|(g<<8)|r)>>>0 : ((r<<24)|(g<<16)|(b<<8)|255)>>>0;
    }
    const gamma=l=>Math.round(255*Math.max(0,Math.min(1,l<=.0031308 ? l*12.92 : 1.055*Math.pow(l,1/2.4)-.055)));
    const skyHigh=[103,185,220];
    const skyLow=[224,235,202];

    function setSize(w,h) {
      if (!(w>0 && h>0)) return;
      const s=Math.min(1,maxSize/Math.max(w,h),Math.sqrt(maxPixels/(w*h)));
      const nw=Math.max(1,Math.round(w*s)), nh=Math.max(1,Math.round(h*s));
      if(nw===width && nh===height) return;
      width=nw; height=nh;
      canvas.width=width; canvas.height=height;
      frame=ctx.createImageData(width,height);
      pixels=new Uint32Array(frame.data.buffer);
      depth=new Float32Array(width*height);
      sky=new Uint32Array(width*height);
      for(let y=0;y<height;y++){
        const t=Math.min(1,(y/height)*1.67);
        const c=pack(...skyHigh.map((v,k)=>Math.round(v+(skyLow[k]-v)*t)));
        sky.fill(c,y*width,(y+1)*width);
      }
      lastDraw=-Infinity;
    }

    const haze=[181,213,213];
    function atmospheric(color, distance) {
      if(distance < 24) return color;
      const t=Math.min(.85,(distance-24)/90);
      const r=little?color&255:color>>>24, g=little?(color>>>8)&255:(color>>>16)&255, b=little?(color>>>16)&255:(color>>>8)&255;
      return pack(Math.round(r+(haze[0]-r)*t),Math.round(g+(haze[1]-g)*t),Math.round(b+(haze[2]-b)*t));
    }

    function getRecord(obj) {
      if(records.has(obj)) return records.get(obj);
      const geo=obj.geometry, pos=geo && geo.attributes.position, tint=geo && geo.attributes.color;
      if(!pos) return null;
      const material=Array.isArray(obj.material) ? obj.material[0] : obj.material;
      if(!material || material.visible===false || material.opacity===0) return null;
      const vertices = new Float32Array(pos.count*3);
      for(let i=0;i<pos.count;i++){
        vertices[i*3]=pos.getX(i); vertices[i*3+1]=pos.getY(i); vertices[i*3+2]=pos.getZ(i);
      }
      const order=geo.index ? geo.index.array : null;
      const faceCount=Math.floor((order ? order.length : pos.count)/3);
      const palette=new Uint32Array(faceCount);
      const isBasic=material.isMeshBasicMaterial;
      normalMatrix.getNormalMatrix(obj.matrixWorld);
      for(let f=0;f<faceCount;f++){
        const a=order ? order[f*3] : f*3, b=order ? order[f*3+1] : f*3+1, c=order ? order[f*3+2] : f*3+2;
        const j=a*3,k=b*3,m=c*3;
        const ux=vertices[k]-vertices[j],uy=vertices[k+1]-vertices[j+1],uz=vertices[k+2]-vertices[j+2];
        const vx=vertices[m]-vertices[j],vy=vertices[m+1]-vertices[j+1],vz=vertices[m+2]-vertices[j+2];
        norm.set(uy*vz-uz*vy,uz*vx-ux*vz,ux*vy-uy*vx).applyNormalMatrix(normalMatrix);
        const sun=Math.max(0,-.48*norm.x+.77*norm.y+.42*norm.z);
        const light=isBasic ? 1 : .60+.16*Math.max(0,norm.y)+.52*sun;
        fillColor.copy(material.color || {r:1,g:1,b:1});
        if(material.vertexColors && tint){
          fillColor.r*=(tint.getX(a)+tint.getX(b)+tint.getX(c))/3;
          fillColor.g*=(tint.getY(a)+tint.getY(b)+tint.getY(c))/3;
          fillColor.b*=(tint.getZ(a)+tint.getZ(b)+tint.getZ(c))/3;
        }
        palette[f]=pack(gamma(fillColor.r*light),gamma(fillColor.g*light),gamma(fillColor.b*light*(1.02-.06*sun)));
      }
      const record={vertices,order,palette,
        clip:new Float32Array(vertices.length), scr:new Float32Array(vertices.length),
        twoSided:material.side===T.DoubleSide || material.side===T.BackSide};
      records.set(obj,record);
      return record;
    }

    // Fill in screen space. The reciprocal of camera-space depth is affine over
    // a projected triangle, including large ground faces crossing the near plane.
    function triangle(ax,ay,az,bx,by,bz,cx,cy,cz,ink,twoSided) {
      const area=(bx-ax)*(cy-ay)-(by-ay)*(cx-ax);
      if(Math.abs(area)<.035 || (!twoSided && area>0)) return;
      const minX=Math.max(0,Math.ceil(Math.min(ax,bx,cx)-.5));
      const maxX=Math.min(width-1,Math.floor(Math.max(ax,bx,cx)-.5));
      const minY=Math.max(0,Math.ceil(Math.min(ay,by,cy)-.5));
      const maxY=Math.min(height-1,Math.floor(Math.max(ay,by,cy)-.5));
      if(minX>maxX || minY>maxY) return;
      const bx0=bx-ax, by0=by-ay, cx0=cx-ax, cy0=cy-ay;
      const inv=1/area;
      const dzx=((bz-az)*cy0-(cz-az)*by0)*inv;
      const dzy=(bx0*(cz-az)-cx0*(bz-az))*inv;
      // Row spans avoid scanning most of the bounding rectangle of long rails.
      function crossing(x1,y1,x2,y2,row) {
        return x1 + (row-y1)*(x2-x1)/(y2-y1);
      }
      for(let y=minY;y<=maxY;y++){
        const yy=y+.5;
        let lo=Infinity, hi=-Infinity;
        if((ay<=yy && by>yy) || (by<=yy && ay>yy)) {
          const x=crossing(ax,ay,bx,by,yy); lo=x; hi=x;
        }
        if((by<=yy && cy>yy) || (cy<=yy && by>yy)) {
          const x=crossing(bx,by,cx,cy,yy); if(x<lo)lo=x;if(x>hi)hi=x;
        }
        if((cy<=yy && ay>yy) || (ay<=yy && cy>yy)) {
          const x=crossing(cx,cy,ax,ay,yy); if(x<lo)lo=x;if(x>hi)hi=x;
        }
        if(hi<lo) continue;
        const from=Math.max(minX,Math.ceil(lo-.5)),to=Math.min(maxX,Math.floor(hi-.5));
        let z=az+(from+.5-ax)*dzx+(yy-ay)*dzy;
        for(let k=y*width+from, stop=y*width+to;k<=stop;k++,z+=dzx) {
          if(z>depth[k]) {depth[k]=z; pixels[k]=ink;}
        }
      }
    }

    function clippedFace(clip,a,b,c,near,ink,twoSided,hw,hh) {
      let count=0;
      for(let edge=0;edge<3;edge++) {
        const p=edge===0 ? c : edge===1 ? a : b;
        const q=edge===0 ? a : edge===1 ? b : c;
        const pv=clip[p+2],qv=clip[q+2];
        if((pv>=near)!==(qv>=near)) {
          const t=(near-pv)/(qv-pv);
          nearPoly[count++]=hw*(1+(clip[p]+t*(clip[q]-clip[p]))/near);
          nearPoly[count++]=hh*(1-(clip[p+1]+t*(clip[q+1]-clip[p+1]))/near);
          nearPoly[count++]=1/near;
        }
        if(qv>=near) {
          nearPoly[count++]=hw*(1+clip[q]/qv);nearPoly[count++]=hh*(1-clip[q+1]/qv);nearPoly[count++]=1/qv;
        }
      }
      for(let i=3;i+3<count;i+=3) {
        triangle(nearPoly[0],nearPoly[1],nearPoly[2],nearPoly[i],nearPoly[i+1],nearPoly[i+2],
          nearPoly[i+3],nearPoly[i+4],nearPoly[i+5],ink,twoSided);
      }
    }

    function draw(obj,camera) {
      const rec=getRecord(obj); if(!rec)return;
      const v=rec.vertices, clip=rec.clip, scr=rec.scr, order=rec.order, cols=rec.palette;
      const hw=width*.5,hh=height*.5,near=Math.max(.06,camera.near),far=camera.far;
      matrix.multiplyMatrices(camera.matrixWorldInverse,obj.matrixWorld);
      const e=matrix.elements,p=camera.projectionMatrix.elements,fx=p[0],fy=p[5],sx=p[8],sy=p[9];
      for(let i=0;i<v.length;i+=3) {
        const x=v[i],y=v[i+1],z=v[i+2];
        const d=-(e[2]*x+e[6]*y+e[10]*z+e[14]);
        const px=(e[0]*x+e[4]*y+e[8]*z+e[12])*fx-d*sx;
        const py=(e[1]*x+e[5]*y+e[9]*z+e[13])*fy-d*sy;
        clip[i]=px;clip[i+1]=py;clip[i+2]=d;
        if(d<near)continue;
        const iz=1/d;
        scr[i]=hw*(1+px*iz);scr[i+1]=hh*(1-py*iz);scr[i+2]=iz;
      }
      for(let f=0;f<cols.length;f++){
        const a=order ? order[f*3]*3 : f*9;
        const b=order ? order[f*3+1]*3 : a+3;
        const c=order ? order[f*3+2]*3 : a+6;
        const z1=clip[a+2],z2=clip[b+2],z3=clip[c+2];
        if((z1<near && z2<near && z3<near) || (z1>far && z2>far && z3>far))continue;
        const x1=clip[a],x2=clip[b],x3=clip[c],y1=clip[a+1],y2=clip[b+1],y3=clip[c+1];
        if((x1<-z1 && x2<-z2 && x3<-z3)||(x1>z1 && x2>z2 && x3>z3)||
           (y1<-z1 && y2<-z2 && y3<-z3)||(y1>z1 && y2>z2 && y3>z3))continue;
        const shade=atmospheric(cols[f],(z1+z2+z3)/3);
        if(z1>=near && z2>=near && z3>=near) {
          triangle(scr[a],scr[a+1],scr[a+2],scr[b],scr[b+1],scr[b+2],scr[c],scr[c+1],scr[c+2],shade,rec.twoSided);
        } else clippedFace(clip,a,b,c,near,shade,rec.twoSided,hw,hh);
      }
    }

    function render(scene,camera) {
      if(!pixels || !ctx)return;
      const now=performance.now();
      if(now-lastDraw<1000/25) return;
      lastDraw=now;
      scene.updateMatrixWorld();
      camera.updateMatrixWorld();
      pixels.set(sky); depth.fill(0);
      scene.traverseVisible(obj=>{
        if(obj.isMesh && obj.material && !(obj.material.transparent && obj.material.opacity<.08)) draw(obj,camera);
      });
      ctx.putImageData(frame,0,0);
    }

    function dispose() {
      frame=pixels=depth=sky=ctx=null;
      records=new WeakMap();
    }
    return {setSize,render,dispose};
  }
  function landscape(ctx,rand) {
    const {root,box,ball,cyl}=ctx;
    box(root,0,-.34,-23,210,.61,240,'#8ab84e');
    const verge=2.18, width=1.98;
    const offset = d => z => route(z)+d;
    ribbon(ctx,22,-83,1.1,offset(-verge),offset(verge),.002,'#b5b564');
    ribbon(ctx,22,-83,1.1,offset(-width),offset(width),.018,'#d4ae78');
    for(let i=0;i<110;i++){
      const z=11-rand()*72, side=rand()<.5?-1:1;
      const x=route(z)+side*(.65+rand()*1.30);
      ball(root,x,.018,z,.035+rand()*.095,.028,.025+rand()*.09,i%3?'#ba985f':'#e2c391');
    }
    // Layered mountain slopes encircle the playable area and continue beyond the route.
    for(let row=0;row<2;row++) for(let j=0;j<18;j++){
      const a=(j+rand()*.35)/18*2*Math.PI;
      const r=57+row*27;
      const x=Math.cos(a)*r, z=-26+Math.sin(a)*r;
      const h=9+rand()*14+row*4;
      const tones=row?['#71999b','#86a6a1','#7ba3ad']:['#689585','#789d86','#83a68b'];
      cyl(root,x,h*.36,z,.28,12+rand()*6,h*.8,7,tones[j%3]).rotation.y=a;
      if(row===1 && j%3===0)cyl(root,x,h*.686,z,.08,3.1,h*.17,7,'#d2dcd1').rotation.y=a;
    }
    for(let i=0;i<105;i++) {
      const z=15-rand()*91,s=rand()<.5?-1:1;
      const x=route(z)+s*(12+rand()*30);
      if(Math.abs(z+2)<1.6) continue;
      const h=3.4+rand()*5.7;
      if(i%3!==1) oak(ctx,root,x,z,h,['#5c984e','#75a54a','#83ae53','#518858'][i%4]);
      else pine(ctx,root,x,z,h,['#497a52','#54855a','#5a9167','#6f9a54'][i%4]);
    }
    for(let i=0;i<65;i++){
      const z=11-rand()*69,s=rand()<.5?-1:1;
      const x=route(z)+s*(2.9+rand()*10);
      if(Math.abs(z+2)<1.9) continue;
      if(i%4===0) ball(root,x,.05,z,.39+rand()*.35,.22+rand()*.22,.34,'#98a58b');
      else {
        const tuft=cyl(root,x,.17,z,.012,.15,.39,4,i%2?'#6d9849':'#819e46');
        tuft.rotation.z=(rand()-.5)*.4;
        if(i%5===0) {
          ball(root,x+.15,.22,z,.12,.105,.12,'#f1cd60');
          ball(root,x+.27,.19,z+.13,.085,.085,.085,'#f6e2a3');
        }
      }
    }
    // Oversized soft clouds are built from opaque faceted ellipsoids.
    for (let i=0;i<17;i++) {
      const a=i/17*Math.PI*2, r=64+rand()*21;
      const x=Math.cos(a)*r,z=-22+Math.sin(a)*r,y=16+rand()*14;
      for(let n=0;n<3;n++)ball(root,x+n*2.3,y+(n===1?1.2:0),z+n*.24,3.5,1.5+n%2,2.65,'#f8f4dc',1);
    }
    valley(ctx,rand);
  }

  function explorer(ctx) {
    const {box,cyl,ball,group}=ctx, base=group(null), body=group(base,0,0,0);
    const pieces={body,legs:[],arms:[]};
    const legs=group(body,0,.67,0);
    for(const s of [-1,1]) {
      const leg=group(legs,s*.165,0,0);
      box(leg,0,-.18,0,.245,.42,.26,'#846347');
      const shoe=box(leg,0,-.52,-.04,.29,.24,.40,'#66442f');
      shoe.rotation.x=-.06;
      box(leg,0,-.62,-.05,.305,.07,.41,'#413633');
      pieces.legs.push(leg);
    }
    const coat=box(body,0,.99,0,.59,.70,.40,'#568966');
    coat.rotation.x=-.04;
    box(body,0,.71,.005,.625,.115,.42,'#855c36');
    box(body,.028,.71,-.218,.14,.09,.029,'#e2bb55');
    for(const s of [-1,1]){
      const arm=group(body,s*.34,1.19,0);
      ball(arm,s*.025,-.07,0,.156,.16,.15,'#729661',1);
      box(arm,s*.045,-.245,0,.19,.32,.22,'#c18e5f');
      ball(arm,s*.05,-.43,-.012,.11,.135,.117,'#e7ac7d',1);
      arm.rotation.z=s*.12;
      pieces.arms.push(arm);
    }
    // Leather pack, rolled blanket and two buckled straps.
    box(body,0,.975,.26,.47,.49,.235,'#a46c3e');
    box(body,0,1.11,.39,.49,.21,.08,'#c58b4e');
    for(const s of [-1,1]) {
      box(body,s*.143,.987,.408,.052,.35,.044,'#84592f');
      box(body,s*.143,.97,.44,.083,.077,.024,'#e2b65e');
      box(body,s*.227,1.08,-.212,.046,.42,.03,'#a77640');
    }
    const roll=cyl(body,0,.691,.33,.105,.105,.48,8,'#66816b');
    roll.rotation.z=Math.PI/2;
    const head=group(body,0,1.54,-.02);
    ball(head,0,0,-.02,.378,.374,.337,'#f1bb87',1);
    for(const s of [-1,1]){
      ball(head,s*.335,-.02,-.015,.085,.122,.085,'#e1a477',1);
      ball(head,s*.128,.013,-.319,.035,.05,.025,'#483d35',1);
      box(head,s*.135,.087,-.30,.10,.025,.039,'#69422d').rotation.z=s*.08;
    }
    ball(head,0,-.042,-.335,.076,.067,.067,'#e2a478',1);
    ball(head,0,.197,.031,.395,.249,.352,'#704629',1);
    ball(head,0,.08,.175,.378,.24,.223,'#784b2b',1);
    for(let i=0;i<5;i++){
      const a=(i-2)*.51;
      const t=ball(head,Math.sin(a)*.279,.208,-Math.cos(a)*.224,.153,.19,.128,i%2?'#815331':'#8e5c36');
      t.rotation.z=-.45;
    }
    for(const s of [-1,1])ball(head,s*.317,.069,.03,.094,.132,.13,'#704629');
    cyl(body,0,1.305,0,.276,.253,.14,8,'#248f86');
    const scarf=box(body,-.25,1.239,.295,.19,.13,.54,'#279a90');
    scarf.rotation.x=-.28; scarf.rotation.y=-.28;
    const tail=box(body,-.31,1.11,.55,.165,.28,.12,'#1f887c');
    tail.rotation.z=-.37;
    pieces.scarf=tail;
    base.userData.pose=pieces;
    return base;
  }

  function token(ctx) {
    const outline = new T.Shape();
    for(let i=0;i<10;i++){
      const angle=Math.PI*.5+i*Math.PI/5,r=i%2===0?.56:.275;
      const x=Math.cos(angle)*r,y=Math.sin(angle)*r;
      if(i===0)outline.moveTo(x,y);else outline.lineTo(x,y);
    }
    outline.closePath();
    const geo = new T.ExtrudeGeometry(outline,{depth:.145,bevelEnabled:true,bevelSize:.051,bevelThickness:.045,bevelSegments:1,steps:1});
    geo.translate(0,0,-.07);
    return ctx.mesh(null,geo,'#ffcc41');
  }

  function createSky() {
    const c=document.createElement('canvas');
    c.width=16;c.height=256;
    const brush=c.getContext('2d');
    if(!brush)return new T.Color('#a6dbe7');
    const gradient=brush.createLinearGradient(0,0,0,c.height);
    gradient.addColorStop(0,'#75baca');
    gradient.addColorStop(.58,'#c1e4db');
    gradient.addColorStop(1,'#d0e6ce');
    brush.fillStyle=gradient;brush.fillRect(0,0,c.width,c.height);
    const tex=new T.CanvasTexture(c);
    tex.colorSpace=T.SRGBColorSpace;
    return tex;
  }

  function progressBetween(value,start,end) {
    return Math.min(1,Math.max(0,(value-start)/(end-start)));
  }

  function smoothStep(t) {
    return t*t*(3-2*t);
  }

  function readPuzzleCounts(source) {
    const defaults=[5,6,10],parts=[];
    const counts=defaults.map((fallback,i)=>{
      const raw=source && source[i];
      const list=Array.isArray(raw) && raw.length && raw.every(n=>Number.isInteger(n)&&n>0) ? raw : null;
      const requested=list?list.reduce((a,b)=>a+b,0):raw;
      const count=Number.isInteger(requested)?Math.max(1,Math.min(15,requested)):fallback;
      parts[i]=list && requested===count ? list : i===1 ? [Math.floor(count/2),Math.ceil(count/2)] : [count];
      return count;
    });
    counts.parts=parts;
    return counts;
  }

  function valleyObstacles(ctx,parent,counts) {
    const {box,cyl,ball,group}=ctx;
    const bridgeZ=-2, bridgeX=route(bridgeZ), startEdge=1.76;
    const planks=Array.from({length:counts[0]},(_,i)=>{
      const depth=startEdge*2/counts[0];
      const board=group(parent);
      board.name='bridge-plank-'+(i+1);
      box(board,0,0,0,4.1,.20,depth*.96,i%3===0?'#b7804b':'#d6a465');
      for(const x of [-1.62,1.62]){
        cyl(board,x,.106,0,.045,.045,.024,7,'#795d46');
      }
      const endZ=bridgeZ+startEdge-(i+.5)*depth;
      const from=new T.Vector3(bridgeX-2.66,.15+.15*(i%4),bridgeZ+2.58+Math.floor(i/4)*.65+i%2*.06);
      const to=new T.Vector3(bridgeX,.2+.034*Math.cos((endZ-bridgeZ)*.65),endZ);
      return t=>{
        const f=smoothStep(progressBetween(t,i/counts[0]*.39,.60+i/counts[0]*.40));
        board.position.lerpVectors(from,to,f);
        board.position.y+=Math.sin(f*Math.PI)*.75;
        board.rotation.y=(1-f)*(.99+(i%2)*.035);
        board.rotation.z=(1-f)*(i%2?.018:-.028);
      };
    });

    // Two loose piles turn into a single line of stepping stones.
    const pondZ=-12.5, pondX=route(pondZ);
    const shore=cyl(parent,pondX,.032,pondZ,1,1,.045,16,'#92a88b');
    shore.scale.x=3.78;shore.scale.z=3.27;
    const pond=cyl(parent,pondX,.056,pondZ,1,1,.04,16,'#55afbf');
    pond.scale.x=3.51;pond.scale.z=3.12;
    for(let i=0;i<6;i++){
      const xx=(i%2?1:-1)*(1.29+(i%3)*.37);
      box(parent,pondX+xx,.079,pondZ+((i*13)%8-3)*.58,.43,.008,.035,'#92d5d1');
    }
    const stoneCount=counts[1], firstPile=counts.parts[1][0], spacing=6.0/stoneCount;
    const stones=Array.from({length:stoneCount},(_,i)=>{
      const side=i<firstPile?-1:1, rank=side<0?i:i-firstPile;
      const z=-9.5-spacing*(i+.5);
      const stone=ball(parent,0,0,0,.68,.21,Math.min(.72,spacing*.44),['#8d9f9f','#aabaa9','#91a7a8'][i%3],1);
      stone.name='stepping-stone-'+(i+1);
      const from=new T.Vector3(route(-8.8)+side*(1.66+(rank%2)*.41),.16+.19*Math.floor(rank/4),-8.80-.35*Math.floor(rank%4/2));
      const to=new T.Vector3(route(z)+.12*Math.sin(i*2),.147,z);
      return t=>{
        const f=smoothStep(progressBetween(t,i/stoneCount*.41,.58+i/stoneCount*.42));
        stone.position.lerpVectors(from,to,f);
        stone.position.y+=.71*Math.sin(f*Math.PI);
        stone.rotation.y=.35*Math.sin(i*.83)*(1-f);
      };
    });

    // Each lit lantern and both moving gate leaves remain in their completed pose.
    const gateZ=-24.25, gate=group(parent,route(gateZ),0,gateZ);
    gate.name='valley-gate';
    const leaves=[];
    for(const s of [-1,1]){
      box(gate,s*2.08,1.68,0,.36,3.42,.41,'#91613c');
      cyl(gate,s*2.08,3.58,0,.10,.36,.39,4,'#b78855').rotation.y=Math.PI*.25;
      const hinge=group(gate,s*1.95,.14,0);
      for(let i=0;i<5;i++) {
        const h=1.39+.15*Math.cos(i*.8);
        box(hinge,-s*(.21+i*.378),h/2,0,.285,h,.15,i%2?'#a97642':'#b58549');
        cyl(hinge,-s*(.21+i*.378),h+.075,0,0,.157,.16,4,'#c49b5d').rotation.y=Math.PI*.25;
      }
      for(const h of [.36,.99])box(hinge,-s*.96,h,.091,1.87,.13,.105,'#865835');
      box(hinge,-s*.96,.68,.151,1.83,.104,.054,'#8d603b').rotation.z=-s*.35;
      leaves.push(hinge);
    }
    box(gate,0,3.09,0,4.42,.29,.41,'#ab7d4b');
    const lamps=[];
    for(let i=0;i<counts[2];i++) {
      const overhead=i<Math.min(5,counts[2]);
      const nOver=Math.min(5,counts[2]);
      const s=i%2?1:-1;
      const z=overhead?gateZ+.12:gateZ+1.55+Math.floor((i-nOver)/2)*.93;
      const xx=overhead?route(gateZ)+(nOver===1?0:(i/(nOver-1)-.5)*3.14):route(z)+s*2.37;
      const height=overhead?2.55:1.05;
      if(!overhead) {
        cyl(parent,xx,1.035,z,.045,.078,2.1,7,'#825e3c');
        box(parent,xx-s*.13,1.81,z,.37,.094,.10,'#ab8752');
      }
      const g=group(parent,xx-(overhead?0:s*.24),height,z);
      g.name='lantern-'+(i+1);
      cyl(g,0,.29,0,.022,.03,.40,7,'#69593e');
      cyl(g,0,.16,0,.09,.24,.143,6,'#5b7560');
      cyl(g,0,-.18,0,.219,.14,.099,6,'#5d705c');
      const dim=cyl(g,0,-.013,0,.163,.158,.263,6,'#706b54');
      const lit=cyl(g,0,-.013,0,.172,.168,.27,6,'#ffe97a');
      if(!ctx.materials.has('lantern-glass')){
        const glass=lit.material.clone();
        glass.emissive.set('#ffc04e');glass.emissiveIntensity=.58;
        ctx.materials.set('lantern-glass',glass);
      }
      lit.material=ctx.materials.get('lantern-glass');
      lamps.push({lit,dim});
    }
    return [
      t=>{for(const update of planks)update(t);},
      t=>{for(const update of stones)update(t);},
      t=>{
        for(let i=0;i<lamps.length;i++){
          const lit=t>i/(lamps.length+1)*.69+.02;
          lamps[i].lit.visible=lit;lamps[i].dim.visible=!lit;
        }
        const opening=smoothStep(progressBetween(t,.28,.98))*1.51;
        leaves[0].rotation.y=opening;leaves[1].rotation.y=-opening;
      }
    ];
  }


  class AdventureScene {
    constructor(canvas,worldIndex,questionSets) {
      this.canvas=canvas;
      this.counts=readPuzzleCounts(questionSets);
      this.paused=false; this.dead=false; this.elapsed=0; this.leg=null;
      this.z=9; this.x=route(9); this.input=[0,0];this.lastTime=0;this.frame=0;
      this.scaleMotion=!!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
      this.originalBackground=canvas.style.background;
      this.tick=this.tick.bind(this);
      if (T) {
        const config = {canvas,alpha:false,antialias:true,powerPreference:'low-power',preserveDrawingBuffer:false};
        try { this.renderer=new T.WebGLRenderer(config); } catch (_) { /* Try the canvas renderer below. */ }
        if(!this.renderer) this.renderer=createSoftwareRenderer(canvas);
        if(this.renderer) {
          this.software=!this.renderer.isWebGLRenderer;
          if(!this.software) {
            this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1,1.55));
            this.renderer.shadowMap.enabled=true;
            this.renderer.shadowMap.type=T.PCFSoftShadowMap;
            this.renderer.outputColorSpace=T.SRGBColorSpace;
          }
          this.scene=new T.Scene();
          this.scene.background=createSky();
          this.scene.fog=new T.Fog('#badbd4',32,101);
          this.camera=new T.PerspectiveCamera(49,1,.15,165);
          this.scene.add(new T.HemisphereLight('#fff1d4','#839867',1.66));
          this.sun=new T.DirectionalLight('#fff2ce',2.05);
          this.sun.castShadow=true;
          this.sun.shadow.mapSize.set(1024,1024);
          Object.assign(this.sun.shadow.camera,{left:-15,right:15,top:15,bottom:-15,near:.2,far:65});
          this.sun.shadow.camera.updateProjectionMatrix();
          this.sun.shadow.bias=-.0005;
          this.sun.shadow.normalBias=.028;
          this.scene.add(this.sun,this.sun.target);
          const staticGroup=new T.Group();
          this.scene.add(staticGroup);
          const ctx=this.ctx=buildTools(staticGroup);
          landscape(ctx,randomGenerator(473));
          combineStationary(ctx);
          staticGroup.children[0].name='terrain';
          this.actor=explorer(ctx);
          this.scene.add(this.actor);
          const props=ctx.group(this.scene);
          props.name='puzzle-props';
          this.obstacles=valleyObstacles(ctx,props,this.counts);
          for (const update of this.obstacles)update(0);
          this.contactShadow=new T.Group();
          for(let i=0;i<2;i++){
            const shape=new T.CircleGeometry(1,18);
            const color=i?'#ab875a':'#c19b68';
            const mat=new T.MeshBasicMaterial({color});
            const disk=new T.Mesh(shape,mat);
            disk.rotation.x=-Math.PI/2;
            disk.scale.set(.48,.40,1).multiplyScalar(1-i*.25);
            disk.position.y=.031+i*.003;
            this.contactShadow.add(disk);
            ctx.geometries.add(shape);ctx.materials.set('contact'+i,mat);
          }
          this.scene.add(this.contactShadow);
          this.tokens=stops.slice(1).map(z=>{
            const star=token(ctx); star.position.set(route(z),1.85,z); this.scene.add(star); return star;
          });
          this.stage=0;
          this.cameraAim=new T.Vector3();
          this.draw(0);
        }
      }
      if(!this.renderer) {
        // Last resort for browsers that disable every canvas context.
        const url=new URL('assets/valley.webp',document.baseURI);
        canvas.style.background='center / cover no-repeat url("'+url.href+'")';
      }
      this.resize=this.resize.bind(this);
      if ('ResizeObserver' in window) {
        this.observer=new ResizeObserver(this.resize);this.observer.observe(canvas);
      } else window.addEventListener('resize',this.resize);
      this.resize();
      this.frame=requestAnimationFrame(this.tick);
    }

    resize() {
      if(this.dead||!this.renderer)return;
      const bounds=this.canvas.getBoundingClientRect();
      if(bounds.width<1||bounds.height<1)return;
      this.camera.aspect=bounds.width/bounds.height;
      this.camera.fov = this.camera.aspect<.88?54:47;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(Math.round(bounds.width),Math.round(bounds.height),false);
      this.draw(0);
    }

    setInput(x,y) { this.input=[x,y]; }
    approach(callback) { this.leg={from:this.z,to:4,stage:0,time:0,repairTime:0,callback}; }
    tracePath(callback) {
      this.advance(2,callback);
      this.leg.points=[];
      for(let i=1;i<=6;i++) {
        const z=-7-11*i/6, x=route(z)+1.35*Math.sin(i*Math.PI/3);
        this.leg.points.push({x,z});
      }
      if(this.scene) {
        const pts=[new T.Vector3(this.x,.42,this.z),...this.leg.points.map(p=>new T.Vector3(p.x,.42,p.z))];
        const line=new T.CatmullRomCurve3(pts);
        const tube=new T.TubeGeometry(line,50,.09,6,false);
        this.trace=this.ctx.mesh(null,tube,'#ffda55');this.scene.add(this.trace);
      }
    }

    advance(stage,onArrive) {
      if(this.dead)return;
      const index=Math.max(1,Math.min(stops.length-1,Math.round(stage)||1));
      this.leg={from:this.z,to:stops[index],stage:index,time:0,
        repairTime:this.scaleMotion?.14:1.04, duration:this.scaleMotion?.59:2.75,callback:typeof onArrive==='function'?onArrive:null};
    }

    setPaused(value) {
      this.paused=!!value;this.lastTime=0;
    }

    tick(time) {
      if(this.dead)return;
      this.frame=requestAnimationFrame(this.tick);
      if(this.paused||document.hidden){this.lastTime=0;return;}
      // Character and collectibles share one clock, which freezes on pause.
      const minFrame=this.software?1000/22:1000/45;
      if(this.lastTime && time-this.lastTime<minFrame)return;
      const dt=this.lastTime?Math.min((time-this.lastTime)/1000,.12):0;
      this.lastTime=time;
      this.elapsed+=dt;
      let callback=null;
      let speed=0;
      if(this.leg) {
        const leg=this.leg;
        leg.time+=dt;
        if(this.obstacles && leg.stage) this.obstacles[leg.stage-1](progressBetween(leg.time,0,leg.repairTime));
        const [dx,dy]=this.input;
        const next=leg.points?.[0] || {x:route(leg.to),z:leg.to};
        this.x=Math.max(route(this.z)-3.5,Math.min(route(this.z)+3.5,this.x+dx*dt*4));
        this.z=Math.max(next.z-.45,Math.min(leg.from+1,this.z+dy*dt*4));
        speed=Math.hypot(dx,dy);
        if(Math.hypot(this.x-next.x,this.z-next.z)<1.15) {
          if(leg.points?.length>1) { leg.points.shift(); }
          else {
          if(this.trace){this.scene.remove(this.trace);this.trace=null;}
          callback=leg.callback;
          this.stage=leg.stage;
          this.leg=null;
          }
        }
      }
      this.draw(speed);
      if(callback)callback();
    }

    draw(speed) {
      if(!this.renderer){
        if(this.leg)this.canvas.style.backgroundPosition=(49+this.leg.time/this.leg.duration*3)+'% center';
        return;
      }
      const z=this.z,x=this.x,t=this.elapsed;
      const slope=(route(z+.08)-route(z-.08))/.16;
      let floorHeight=0,air=0;
      if(Math.abs(z+2)<2.44)floorHeight=.27;
      const stones=this.counts[1];
      if(z<=-9.5 && z>=-15.5) {
        const step=(-9.5-z)*stones/6;
        floorHeight=.29*smoothStep(progressBetween(-9.5-z,0,.37))*smoothStep(progressBetween(z+15.5,0,.37));
        if(!this.scaleMotion)air=.24*Math.abs(Math.cos(step*Math.PI))*speed;
      }
      this.actor.position.set(x,.035+floorHeight+air,z);
      if(speed>.04)this.actor.rotation.y=Math.atan2(-this.input[0],-this.input[1]);
      this.contactShadow.position.set(x+.045,floorHeight,z-.03);
      this.contactShadow.rotation.y=this.actor.rotation.y;
      const pose=this.actor.userData.pose;
      const move=this.scaleMotion?0:speed;
      const stride=Math.sin(t*16.3);
      pose.body.position.y=move*.095*Math.abs(stride)+(this.scaleMotion?0:Math.sin(t*2.4)*.011);
      pose.body.rotation.x=-.075*move;
      pose.body.rotation.z=stride*move*.04;
      for(let i=0;i<2;i++){
        const side=i?1:-1;
        pose.legs[i].rotation.x=side*stride*.67*move;
        pose.arms[i].rotation.x=-side*stride*.61*move;
      }
      pose.scarf.rotation.z=-.35+Math.sin(t*6)*move*.21;
      this.tokens.forEach((star,i)=>{
        star.visible=i+1>this.stage;
        star.position.y=1.67+(this.scaleMotion?0:.12*Math.sin(t*2.7+i));
        star.rotation.y=.45+(this.scaleMotion?0:t*.95+i*.51);
        star.rotation.z=this.scaleMotion?0:.06*Math.sin(t*1.7+i);
      });
      const portrait=this.camera.aspect<.88;
      const offset=0;
      this.camera.position.set(x+offset,portrait?3.54:3.63,z+(portrait?6.05:7.20));
      this.cameraAim.set(x*.78+route(z-3)*.22,1.24,z-(portrait?1.32:1.95));
      this.camera.lookAt(this.cameraAim);
      this.sun.position.set(x-12,19,z+10);this.sun.target.position.set(x,0,z-5.6);
      this.renderer.render(this.scene,this.camera);
    }

    destroy() {
      if(this.dead)return;
      this.dead=true; this.leg=null; this.obstacles=null;
      cancelAnimationFrame(this.frame);
      if(this.observer)this.observer.disconnect();
      else window.removeEventListener('resize',this.resize);
      if(this.ctx) {
        for (const geometry of this.ctx.geometries)geometry.dispose();
        for (const material of this.ctx.materials.values())material.dispose();
        if(this.scene.background && this.scene.background.dispose)this.scene.background.dispose();
        if(this.sun.shadow.map)this.sun.shadow.map.dispose();
        this.scene.clear();
      }
      if(this.renderer)this.renderer.dispose();
      this.canvas.style.background=this.originalBackground;
    }
  }
  window.AdventureScene=AdventureScene;
})();

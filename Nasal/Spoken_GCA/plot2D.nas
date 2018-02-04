# Plot2D helper functions
#
# TODO:
# 		Consider Rotations.

#  (see http://wiki.flightgear.org/How_to_manipulate_Canvas_elements )
# -----------------------------------------


var plot2D = {

line: func(group, from, to, color="#0") { 
# Plots a line as <group>'s child.
# params:
# 	from		as [x,y] in pixels.
#	to			as [x,y] in pixels.
# 	color		optional as [r,g,b] or "#rrggbb", Black by default.
#~ printf('from=[%i, %i] to=[%i, %i] color= %s', from[0], from[1], to[0], to[1], color  );
 var line = group.createChild("path", id).moveTo(from).lineTo(to); 
 me._set(line,nil,color);
 return line;
},

hzLine: func(group, from, length, color="#0") { 
# Plots an horizontal line as <group>'s child.
# params:
# 	from		as [x,y] in pixels.
#	length		in pixels.
# 	color		optional as [r,g,b] or "#rrggbb", Black by default.
 var line = me.line(group, from, [from[0]+length,from[1]], color); 
 return line;
},

vtLine: func(group, from, length, color="#0") { 
# Plots an horizontal line as <group>'s child.
# params:
# 	from		as [x,y] in pixels.
#	length		in pixels.
# 	color		optional as [r,g,b] or "#rrggbb", Black by default.
 var line = me.line(group, from, [from[0],from[1]+length], color); 
 return line;
},

dashedLine: func(group, from, to, dash=8, color="#0") { 
# Plots a dashed line as <group>'s child.
# params:
# 	from		as [x,y] in pixels.
# 	to			as [x,y] in pixels.
#	dash		optional dash&space lengths in pixels, 8 pixels by default.
# 	color		optional as [r,g,b] or "#rrggbb", Black by default.
 var line = group.createChild("path", id).moveTo(from);
 var long = math.sqrt((to[0]-from[0])*(to[0]-from[0])+(to[1]-from[1])*(to[1]-from[1]));
 var a = math.atan2(to[1]-from[1],to[0]-from[0]);
 var (s,c) = [math.sin(a), math.cos(a)];
 for(var i=1; i*dash<= long; i+=2){
  var inc = i*dash> long ? long : i*dash;
  line.lineTo(from[0]+inc*c, from[1]+inc*s).moveTo(from[0]+(i+1)*dash*c, from[1]+(i+1)*dash*s);
  }
 me._set(line,nil,color);
 return line;
},

rectangle: func(group,size,origin=nil,color="#0",fill=nil, rounded=nil) { 
#~ rectangle: func(group,size,origin,color,fill, rounded) { 
# Plots a rectangle as <group>'s child.
# params:
# 	size		as [width,height] in pixels.
# 	origin		optional as [x,y] in pixels, [0,0] by default.
# 	color		optional border color as [r,g,b] or "#rrggbb" or nil (for no border). Black  by default.
#	fill		optional fill color as [r,g,b] or "#rrggbb", No filled by default.
#	rounded		optional corner radius in pixels, Not rounded by default.
 var rect = group.createChild("path", id);
 rect.rect(0,0, size[0], size[1], {"border-radius": rounded});
 if(fill != nil) rect.setColorFill(fill).set('fill',0);
 me._set(rect,origin,color);
 return rect;
},

grid: func(group,size,dx,dy, origin=nil, color="#0", border=1) {
# Plots a grid as <group>'s child.
# params:
# 	size		as [width,height] in pixels.
# 	dx			tiles width in pixels.
# 	dy			tiles height in pixels.
# 	color		optional grid color as [r,g,b] or "#rrggbb". Black  by default.
# 	origin		optional as [x,y] in pixels, [0,0] by default.
#	border		optional as boolean, True by default.
 var grid = group.createChild("path", id); 
 var (x0,y0) = border? [0,0] : [dx,dy];
 for(var x=x0; x<=size[0]; x+=dx) grid.moveTo(x, 0).vertTo(size[1]);
 for(var y=y0; y<=size[1]; y+=dy) grid.moveTo(0, y).horizTo(size[0]);
 if(border) grid.moveTo(size[0], 0).vertTo(size[1]).horizTo(0);
 me._set(grid,origin,color);
 return grid;
},

polyline: func(group, xSet, ySet, color="#0", symmetrical='') {
# Plots a polyLine as <group>'s child.
# params:
# 	xSet		as [x0,...,xn] in pixels.
# 	ySet		as [y0,...,yn] in pixels.
# 	color		optional grid color as [r,g,b] or "#rrggbb". Black  by default.
# 	symmetrical	optional string, may be 'x', 'y', 'xy' or 'yx'.
 var _appn = func(set1, set2) {
 var a = set2[-1];
 for(var i=size(set1)-2;i>=0;i-=1) {
		append(set2,2*a-set2[i]);
		append(set1,set1[i]);
		}
 }
 if(symmetrical and symmetrical[0]==121)  _appn(xSet,ySet);
 if(symmetrical and symmetrical[0]==120)  _appn(ySet,xSet);
 if(size(symmetrical)==2 and symmetrical[0]==121)  _appn(ySet,xSet);
 if(size(symmetrical)==2 and symmetrical[0]==120)  _appn(xSet,ySet);

 var poly = group.createChild("path", id);
 poly.moveTo(xSet[0], ySet[0]);
 for(var i=1; i<size(xSet); i+=1) poly.lineTo(xSet[i],ySet[i]); 
 me._set(poly,nil,color);
 return poly;
},

graphic: func(group, ySet, dx=nil, origin=nil, color="#0") {
# Plots the curve sampled in <ySet> with a resolution of <dx>.
# params:
# 	ySet		as [y0,...,yn] in pixels.
# 	dx			curve resolution in pixels. 1 px by default.
# 	origin		optional as [x,y] in pixels, [0,0] by default.
# 	color		optional grid color as [r,g,b] or "#rrggbb". Black  by default.
 if(dx==nil) dx = 1;
 var g = group.createChild("path", id); 
 var xValues = [];
 for(var i=0; i<size(ySet);i+=1) append(xValues, i*dx);
 g = me.polyline(group,xValues,ySet,color);
 me._set(g,origin,color);
 return g;
},

text: func(group,text, origin=nil, size=nil, color="#0",align="left-baseline") {
# Plots a text as <group>'s child.
# params:
# 	text		the text itself as string.
# 	origin		optional as [x,y] in pixels, ([0,0] by default).
# 	size		optional font size and aspect as [<size-px>,<height/width>]. ([11,1] by default)
# 	color		optional font color as [r,g,b] or "#rrggbb". (Black  by default).
# 	align		optional origin reference. ("left-baseline" by default).
 if(size==nil) size = [11,1];
 var Text = group.createChild("text", id);
 Text.setFontSize(size[0],size[1]).setAlignment(align);
 Text.setText(text);
 Text.setColor(color);
 Text.setTranslation(origin);
 #~ me._set(Text,origin,color);
 return Text;
}, # text

#-------------
# Polar arguments:
arc: func(group, center, radius, from=nil, to=nil, color="#0") { 
# Plots an arc as <group>'s child.
# params:
# 	center		as [x,y] in pixels.
# 	radius		as integer (for circle) or [rx,ry] (for ellipse) in pixels.
# 	from		angle in deg. All the 360 deg by default.
#	to			angle in deg.
# 	color		optional as [r,g,b] or "#rrggbb", Black by default.
var (rx,ry) = typeof(radius)=='vector' ? [radius[0],radius[1]] : [radius,radius];
 if(from==nil) return group.createChild("path", id).moveTo(center[0]+rx,center[1])
		.arcLargeCW(rx, ry, 0,  0, -1).setColor('#0000dd');
 var (fs,fc) = [math.sin(from*D2R), math.cos(from*D2R)];
 var (ts,tc) = [math.sin(to*D2R), math.cos(to*D2R)];
 if((to-from) >180) var arc = group.createChild("path", id).moveTo(center[0]+rx*fs,center[1]-ry*fc)
		.arcLargeCW(rx, ry, 0,  rx*(ts-fs), -ry*(tc-fc));
 else var arc = group.createChild("path", id).moveTo(center[0]+rx*fs,center[1]-ry*fc)
		.arcSmallCW(rx, ry, 0,  rx*(ts-fs), ry*(fc-tc));
 return arc.setColor(color);
},

polarLine: func(group, from, angle, length, color="#0") { 
# Plots an arc as <group>'s child.
# params:
# 	from		as [x,y] in pixels.
# 	angle		in degrees.
# 	length		in pixels.
# 	color		optional as [r,g,b] or "#rrggbb", Black by default.
 var to = [from[0]+length*math.cos(angle*D2R), from[1]-length*math.sin(angle*D2R)];
 return me.line(group,from,to,color);
},

polarText: func(group,text, center, radius,angle, size=nil, color="#0",align="center-baseline") {
# Plots a text as <group>'s child.
# params:
# 	text		the text itself as string.
# 	center		as [x,y] in pixels.
# 	radius		in pixels.
# 	angle		in degrees.
# 	size		optional font size and aspect as [<size-px>,<height/width>]. ([11,1] by default)
# 	color		optional font color as [r,g,b] or "#rrggbb". (Black  by default).
# 	align		optional origin reference. ("left-baseline" by default).
 var origin = [center[0]+radius*math.cos(angle*D2R), center[1]-radius*math.sin(angle*D2R)];
 return me.text(group,text, origin, size, color,align).setRotation((90-angle)*D2R);
},

move: func(elem, dx,dy){
# Moves the element <dx,dy> pixels from his position.
 var (Tx,Ty) =  elem.getTranslation();
 elem.setTranslation(Tx+dx, Ty+dy);
},

rotate: func(elem, deg,center){
# rotates the element <deg> degrees around <center>.
 var C = me.xy(elem,center);
 elem.setCenter(C).setRotation(-deg*D2R);
},

flipX: func(elem, Xaxis=0) {
# Flips (horizontal) the element,
# params:
# 	elem		element to be flipped.
# 	Xaxis	abscissa of the symmetry axis . If 0 (default) element flips onplace.
 if(contains(elem,'getScale')) var (sx,sy) = elem.getScale();
 else var sx = var sy =1;
  if(contains(elem,'getTranslation'))var (tx,ty) = elem.getTranslation();
 else var tx = var ty =1;
 var (Xmin,Ymin,Xmax,Ymax) = elem.getBoundingBox();
 if(Xaxis==0) Xaxis= tx+sx*(Xmax+Xmin)/2;
 elem.setScale(-sx,sy);
 elem.setTranslation(2*Xaxis-tx, ty);
 return elem;
},
 
flipY: func(elem, Yaxis=0) {
# Flips (vertical) the element,
# params:
# 	elem		element to be flipped.
# 	Yaxis	ordinate of the symmetry axis . If 0 (default) element flips onplace.
 var (sx,sy) = elem.getScale();
 var (tx,ty) = elem.getTranslation();
 var (Xmin,Ymin,Xmax,Ymax) = elem.getBoundingBox();
 if(Yaxis==0) Yaxis= ty+sy*(Ymax+Ymin)/2;
 elem.setScale(sx,-sy);
 elem.setTranslation(tx, 2*Yaxis-ty);
 return elem;
},
 
alignX: func(elem, ref, alignment) {
# Aligns the element, moving it horizontaly to ref.
# params:
# 	elem		element to be moved.
# 	ref			reference may be an integer or another element.
# 	alignment	as string: may be 'left-left', 'left-center', 'left-right',
#								  'center-left', 'center-center', 'center-right',
#								  'right-left', 'right-center', 'right-right'.
#				If ref is a single number, the 2nd word is ignored.
 var (sx,sy) = elem.getScale();
 var (tx,ty) = elem.getTranslation();
 var (Xmin,Ymin,Xmax,Ymax) = elem.getBoundingBox();
 var a = split('-',alignment)[0];
 var x = a=='left' ? Xmin : a=='right' ? Xmax : (Xmin+Xmax)/2;
 if(typeof(ref)=='scalar') var uRef=ref;
 else {
 var (sRx,sRy) = ref.getScale();
 var (tRx,tRy) = ref.getTranslation();
 var (Xmin,Ymin,Xmax,Ymax) = ref.getBoundingBox();
  var aR = split('-',alignment)[1];
   var uRef = aR=='left' ? tRx+sRx*Xmin : aR=='right' ? tRx+sRx*Xmax : tRx+sRx*(Xmin+Xmax)/2;
 }
 elem.setTranslation(uRef-x*sx, ty);
 return elem;
},

alignY: func(elem, ref, alignment) {
# Aligns the element, moving it vertically to ref.
# params:
# 	elem		element to be moved.
# 	ref			reference may be an integer or another element.
# 	alignment	as string: may be 'top-top', 'top-center', 'top-bottom',
#								  'center-top', 'center-center', 'center-bottom',
#								  'bottom-top', 'bottom-center', 'bottom-bottom'.
#				text elements also accept	  'baseline' as reference.
#				If ref is a single number, the 2nd word is ignored.
 var (sx,sy) = elem.getScale();
 var (tx,ty) = elem.getTranslation();
 var (Xmin,Ymin,Xmax,Ymax) = elem.getBoundingBox();
 var a = split('-',alignment)[0];
 var y = a=='top' ? Ymin : a=='bottom' ? Ymax : (Ymin+Ymax)/2;
 if(typeof(ref)=='scalar') var vRef=ref;
 else {
 var (sRx,sRy) = ref.getScale();
 var (tRx,tRy) = ref.getTranslation();
 var (Xmin,Ymin,Xmax,Ymax) = ref.getBoundingBox();
  var aR = split('-',alignment)[1];
   var vRef = aR=='top' ? tRy+sRy*Ymin : aR=='bottom' ? tRy+sRy*Ymax : tRy+sRy*(Ymin+Ymax)/2;
	}
 elem.setTranslation(tx, vRef-y*sy);
 return elem;
}, 

rotate180: func(elem, center=nil) {
# Rotates the element 180 deg around <center>.
# params:
# 	elem		element to be rotated.
# 	center		as [Cx,Cy] in pixels. Rotates onplace by default.
 if(center==nil){
	me.flipX(elem);
	me.flipY(elem);
 } else {
	me.flipX(elem, center[0]);
	me.flipY(elem, center[1]);
 }
 return elem;
}, 

stretchX: func(elem,factor,ref='left') {
# Stretchs horizontally the element .
# params:
# 	elem		element to be stretched.
# 	factor		the <new-width>/<old-width> ratio.
# 	ref			the relative point to keep inplace. May be 'left','center' or 'right'.
 var (sx,sy) = elem.getScale();
 var (tx,ty) = elem.getTranslation();
 var (Xmin,Ymin,Xmax,Ymax) = elem.getBoundingBox();
 var x = ref=='left' ? Xmin : ref=='right' ? Xmax : (Xmin+Xmax)/2;
 var u = tx+x*sx ;
 elem.setScale(sx*factor,sy);
 elem.setTranslation(u-x*sx*factor, ty);
 return elem;
},

stretchY: func(elem,factor,ref='top') {
 # Strechs vertically the element .
# params:
# 	elem		element to be stretched.
# 	factor		the <new-height>/<old-height> ratio.
# 	ref			the relative point to keep inplace. May be 'top','center' or 'bottom'.
var (sx,sy) = elem.getScale();
 var (tx,ty) = elem.getTranslation();
 var (Xmin,Ymin,Xmax,Ymax) = elem.getBoundingBox();
 var y = ref=='top' ? Ymin : ref=='bottom' ? Ymax : (Ymin+Ymax)/2;
 var v = ty+y*sy ;
 elem.setScale(sx, sy*factor);
 elem.setTranslation(tx, v-y*sy*factor);
 return elem;
},

resize: func(elem,factors,ref='left-top') {
 # Redimentions the element .
# params:
# 	elem		element to be redimentioned.
# 	factors		as [Xfactor, Yfactor] .
# 	ref			the relative point to keep inplace:
#							may be 'left-top', 'left-center', 'left-bottom',
#								  'center-top', 'center-center', 'center-bottom',
#								  'right-top', 'right-center', 'right-bottom'.
 me.stretchX(elem,factors[0],split('-',ref)[0]);
 me.stretchY(elem,factors[1],split('-',ref)[1]);
 return elem;
},

# internal:
_set: func(object, origin, color) {
 if(origin != nil) object.setTranslation(origin);
 if(color != nil) object.setColor(color);
 return object;
 },
 
xy: func(elem,uv){
# returns [x,y]: intrinsec coords of the absolute(u,v)

var (Tx,Ty)=elem.getTranslation();
var (Sx,Sy)=elem.getScale();
return [(uv[0]-Tx)/Sx, (uv[1]-Ty)/Sy];
},

};  


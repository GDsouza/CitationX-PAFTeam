# Graph class
#
var graph = {
# constructor
new: func(group, view=nil) { 
# view as [xOrigin, yOrigin, xScale, yScale], x/yOrigin as absolue coords, x/yScale as <pixels-per-localUnit>.
#	 Default: [0,0,1,-1]
 var m = {parents:[graph,axis,arc] };
 m.version = 0.2;
 m.group = group;
 m.Xaxis = nil;
 m.Yaxis = nil;
 if(view==nil) view = [0,0,1,-1];
 m.view = view;
 m.origin = [view[0],view[1]];
 #~ m.plotted = nil;
 m.elements = []; # other than axis ones.
return m;
 }, # new()

# destructor (no really yet)
del: func() {
}, # del()

##### Setters: 
# All coordinates and lengths must be in local units (according view),
# exept for setArcDial and font sizes (which works in absolute units) !!!!.

setDigital: func(origin, frame=1, color="#0",fontSize=nil, title=nil){
# origin as [x,y] in local units (according view).
# fontSize as [size, aspect].
 if(fontSize==nil) fontSize = [13,0.7];
 var d = digital.new(me.group,me.view,origin,frame,color,fontSize,title);
 return d;
},


 
setPlotProperty: func(propNode, maxTime, maxValue, dt, color="#0"){
# propNode as valid string.
# maxTime plot time in secs.
# maxValue plot top bound in local units.
# dt sampling resolution time in secs.
 var plot = plotProperty.new(me.group,me.view,propNode,maxTime,maxValue,dt,color);


},

setArcDial: func(center, radius, from=nil, to=nil, color="#0", tics=nil, labels=nil ,title=nil){
# center as [x,y] in absolute units.
# radius in pixels.
# from as angle.
# to as angle.
# tics as [start=nil, end=nil, each=15, length=5].
# labels  <each-n-tics> as integer
 var arc = arc.new(me.group,center,radius,from,to,color,title);
 if(tics!=nil) arc.setTics(tics[0],tics[1],tics[2],tics[3]);
 return arc;
},

setXaxis: func(start,length, color='#0', title=nil) {
# start as [x,y] in local units (according view).
# length  in local units (according view).
# title  optional as string.
 if(me.Xaxis!=nil) me.Xaxis.del();
 me.Xaxis = axis.new(me.group,me.view,start,length,color,title);
},

setYaxis: func(start,length, color='#0',title=nil) {
# start as [x,y] in local units (according view).
# length  in local units (according view).
# title  optional as string.
 if(me.Yaxis!=nil) me.Yaxis.del();
 me.Yaxis = axis.new(me.group,me.view,start,length,color,title,1);
 },
 
line: func(from, to, color="#0") { 
 var l = plot2D.line(me.group, me.xy(from),me.xy(to),color);
 append(me.elements, l );
 return l;
},

rectangle: func(size, origin, color="#0", fill=nil, rounded=nil) { 
 var l = plot2D.rectangle(me.group, [me.view[2]*size[0],me.view[3]*size[1]],me.xy(origin),color,fill,rounded);
 append(me.elements, l );
 return l;
},

graph2D:  func(function, from,to,resolution,color="#0"){
 var vals = [];
 #~ for(var i=from;i<=to;i+=resolution) append(vals, me.origin[1]+me.view[3]*function(i));
 for(var i=from;i<=to;i+=resolution) append(vals, me.y(function(i)));
 #~ var orig = me.xy([0, function(0)]);
 var orig = [me.x(from), 0];
 append(me.elements, plot2D.graphic(me.group, vals,me.view[2]*resolution,orig,color));
},


rotateAll: func(deg) {
 var center = me.origin;
 var elems = [];
 foreach(axis; [me.Xaxis,me.Yaxis]) {
	plot2D.rotate(axis.line,deg,center);
	foreach(e; axis.tic_e) append(elems,e);
	foreach(e; axis.labels) append(elems,e);
	}
 foreach(e; elems) plot2D.rotate(e,deg,center);
},

moveAll: func(dx,dy) {
 var elems = me.group.getChildren();
 foreach(e; elems) plot2D.move(e,dx,dy);
},

polyline: func(xSet, ySet, color="#0", symmetrical='') {
var (U,V) = [[],[]];
 foreach(x; xSet) append(U,me.x(x));
 foreach(y; ySet) append(V,me.y(y));
 var poly = plot2D.polyline(me.group, U,V,color,symmetrical);
 append(me.elements, poly); 
 return poly;
},

#~ TODO: 
#~ setView: func(view) {
   #~ me.view = view;
   #~ if(me.Xaxis !=nil) {
   #~ var old = {start:me.Xaxis.start, length:me.Xaxis.length, title:me.Xaxis.title,  tics:me.Xaxis.tics,  labels:me.Xaxis.labels,  vertical:me.Xaxis.vertical,  };
   #~ me.setXaxis(old.start, old.length, old.title, old.tics, old.labels);
 #~ }
   #~ if(me.Yaxis !=nil) {
   #~ var old = {start:me.Yaxis.start, length:me.Yaxis.length, title:me.Yaxis.title,  tics:me.Yaxis.tics,  labels:me.Yaxis.labels,  vertical:me.Yaxis.vertical,  };
   #~ me.setYaxis(old.start, old.length, old.title, old.tics, old.labels);
 #~ }
#~ }, 

# Getting absolute coords:
x: func(local){ return me.view[0]+me.view[2]*local;},
y: func(local){ return me.view[1]+me.view[3]*local;},
xy: func(locals){ return [me.x(locals[0]), me.y(locals[1])];},
# Getting local coords:
u: func(absolute){ return (absolute-me.view[0])/me.view[2];},
v: func(absolute){ return (absolute-me.view[1])/me.view[3];},
uv: func(absolutes){ return [me.u(absolutes[0]), me.v(absolutes[1])];},
# Empty elements from vector:
void: func(v){ foreach(e; v) e.del(); 	v = []; },

}; # graph class

############################################################
 ###   PlotProperty class  ###
 #########################
var plotProperty = {
# constructor
# propNode as valid string.
# max plot time in secs.
# dt sampling resolution time in secs.
new: func(group,view,propNode, maxT, maxV,dt, color) {
 var m = {parents:[plotProperty,graph,plot2D] };
 m.group = group;
 m.view = view;
 m.propNode = propNode;
 m.dt = dt;
 m.color = color;
 m.init(view,propNode,maxT,maxV,dt, color);
 return m;
 }, # new()

init: func(view,propNode,maxT,maxV,dt, color){
 me.Xaxis = axis.new(me.group,view,[-maxT,0],maxT,'#0','secs');
 me.Xaxis.setTics(length:50, first:-maxT, each:1).setLabels(first:-maxT, each:5);
 me.Yaxis = axis.new(me.group,view,[-maxT,0],maxV-1,'#0','y',1);
 me.Yaxis.setTics(length:.2, first:0, each:maxV/10).setLabels(first:maxV/5,each:maxV/5);

 me.path =  me.group.createChild("path", id);
 me.path.moveTo(me.x(0), me.y(getprop(propNode))).setColor(color);
 me.frame = plot2D.rectangle(me.group, [view[2]*maxT,view[3]*maxV], me.xy([-maxT,0]) );
 me.t = 0;
 var timer = maketimer(dt,func {me.update(maxT,maxV);});
 timer.stop();
 timer.simulatedTime=1;
 timer.start();
 return me;
},

update: func(maxT,maxV){
	me.t += me.dt;
	var v = math.clamp(getprop(me.propNode), 0, maxV);
	plot2D.move(me.path,-me.dt*me.view[2],0);
	me.path.lineTo(me.x(me.t),me.y(v));
	if(me.t> maxT){
		 me.path.pop_front();
		me.path._node.getChildren('cmd')[0].setValue(2);
	}
 return me;
},
}; # plotProperty class
############################################################
 ###   AXIS class  ###
 #########################
var axis = {
# constructor
# start as [x,y] in local units (according view).
# length as [length,color] in local units (according view).
# title  optional as string.
# vertical  optional as boolean.
new: func(group,view,start,length, color, title=nil, vertical=0 ) {
 var m = {parents:[axis,graph,plot2D] };
 m.group = group;
 m.view = view;
 m.start = start;
 m.length = length;
 m.title = nil;
 m.line = nil;
 m.vertical = vertical;
 m.tic_e = [];
 m.label_e = [];
 m.init(view,start,length, color, vertical, title);
 return m;
 }, # new()
 
del: func() {
 me.line.del();
 me.title.del();
 foreach(lbl;me.label_e) lbl.del();
 foreach(tic;me.tic_e) tic.del();
}, # del()
 
init: func(view,start,length,color, vertical, title) {
 me.view = view;
 me.line = vertical? plot2D.line(me.group,me.xy(start),me.xy([start[0],start[1]+length]),color)
			: plot2D.line(me.group,me.xy(start),me.xy([start[0]+length,start[1]]),color);
 if(title!=nil) me.setTitle(title,[12,0.6],color);
},

setTitle: func(text=nil, fontSize=nil, color=nil, align=nil) {
 if(me.title!=nil){
    if(text!=nil) me.title.setText(text);
    if(color!=nil)  me.title.setColor(color);
    if(fontSize!=nil) me.title.setFontSize(fontSize[0],fontSize[1]);
    if(align!=nil) me.title.setAlignment(align);
 } else {   
 var xy = !me.vertical? [me.x(me.start[0]+me.length),me.y(me.start[1])+15]
				: [me.x(me.start[0])-15,me.y(me.start[1]+me.length)];
 me.title =  plot2D.text(me.group, text, xy	,fontSize, color, 'right-top');
 }
 return me;
  },
  
setTics: func(length, first, each, last=nil, color=nil ) {
# length in local units.
# first absice in local units.
# each step in local units.
# last optional absice in local units. Line's end by default.
# color optional.  Line's color by default.
 if(last==nil) last = me.vertical? me.start[1]+me.length : me.start[0]+me.length ;
 if(color==nil) color = me.line.getColor();
 if(me.tic_e != []) me.void(me.tic_e);
 for(var h =first; h <=last; h +=each) {
	if(!me.vertical) append(me.tic_e, plot2D.vtLine(me.group,
				me.xy([h, me.start[1]]), me.view[3]*length, color));
	else append(me.tic_e, plot2D.hzLine(me.group,
				[me.x(me.start[0]), me.y(h)],me.view[2]*length,color));
 } 
 return me;
},

setLabels: func(first, each, last=nil, color=nil ) {
# first absice in local units.
# each step in local units.
# last optional absice in local units. Line's end by default.
# color optional.  Line's color by default.
 if(last==nil) last = me.vertical? me.start[1]+me.length : me.start[0]+me.length ;
 if(color==nil) color = me.line.getColor();
 if(me.label_e != []) me.void(me.label_e);
 
 for(var h =first; h <=last; h +=each) {
	if(!me.vertical) append(me.label_e, plot2D.text(me.group, sprintf(h),
						[me.x(h),me.y(me.start[1])+3],, color, 'center-top'));
	else append(me.label_e, plot2D.text(me.group, sprintf(h),[me.x(me.start[0])-3,me.y(h)],, color,'rigth-center'));
	}
	# TODO: alignments work fine for Xaxis, but not for Yaxis !!! why?
 if(me.vertical) foreach(lbl; me.label_e) lbl.setAlignment('right-center'); # Should not be necessary !
return me;
},




#~ TODO:
#~ customizeLabel: func(idx, text=nil, font=nil, color=nil ) {
#~ # idx as as integer .
	 #~ if(text!=nil) me.label_e[idx].setText(sprintf(text));
	 #~ if(font!=nil) me.label_e[idx].setFontSize(font[0],font[1]);
	 #~ if(color!=nil) me.label_e[idx].setColor(color);
#~ },

#~ setTitle: func(text=nil, fontSize=nil, color=nil ) {
 #~ if(me.Y){
   #~ if(me.title==nil)	me.title = plot2D.text(me.group, '', [me.end[0]-14,me.end[1]],,'#0','right-top');
 #~ } else {
 	#~ if(me.title==nil)	me.title = plot2D.text(me.group, me.title, [me.end[0],me.end[1]+14],,'#0','right-top');
#~ }
 #~ if(text!=nil) me.title.setText(sprintf(text));
 #~ if(fontSize!=nil) me.title.setFontSize(fontSize[0],fontSize[1]);
 #~ if(color!=nil) me.title.setColor(color);
 #~ return me;
#~ },


 
#~ customizeLabels: func(idx=nil, texts=nil, font=nil, color=nil ) {
#~ # idx as vector. All labels by default.
#~ # texts as vector of strings.
 #~ if(idx==nil) {
  #~ idx = [];
  #~ for(var i=1;i<size(me.label_e);i+=1) append(idx,i);
  #~ }
 #~ if(texts==nil) {
  #~ texts = [nil];
  #~ for(var i=1;i<size(me.label_e);i+=1) append(texts,nil);
  #~ }
 #~ foreach(i; idx) me.setLabel(i,texts[i],font,color);,me.xy([start[0]+length,start[1]])
#~ },
 
 
}; # axis

############################################################
 ###   Digital class  ###
 #########################
var digital = { 
# constructor
# origin as [x,y] in local units (according view).
# fontSize as [size, aspect].
# title as string.
new: func(group, view, origin, frame, color, fontSize,title ) {
 var m = {parents:[digital,graph,plot2D] };
 m.group = group;
 m.view = view;
 m.origin = origin;
 m.color = color;
 m.frame = frame;
 m.fontSize = fontSize;
 m.title = title;
 m.init(title);
return m;
 }, # new()
 
init: func(title) {
   me.text = plot2D.text(me.group,'000',me.xy(me.origin),me.fontSize,me.color,'center-center');
 if(me.frame) {
 var size = [me.fontSize[0]/me.fontSize[1]*7/me.view[2], me.fontSize[0]*2/me.view[3]];
 var origin = [me.x(me.origin[0])-size[0]/2, me.y(me.origin[1])-size[1]/2.2 ];
	me.frame = plot2D.rectangle(me.group, size, origin,me.color);
 }
 if(me.title!=nil) me.setTitle(title, [13,0.7], me.color);
}, # init()
 
del: func() {
}, # del()

setTitle: func(text=nil, fontSize=nil, color=nil, align=nil) {
  if(typeof(me.title) == 'hash')   me.title.del();
   
    if(color==nil)  color = me.color;
    if(fontSize==nil) fontSize = [13,0.7];
 var xy = [me.x(me.origin[0]), me.y(me.origin[1])+  me.fontSize[0]/2 ]; # by def.
 var al = 'center-top';
 if(align =='top'){
	xy = [me.x(me.origin[0]), me.y(me.origin[1])-me.fontSize[0]/2 ];
	al = 'center-bottom';
	}
 if(align =='left'){
	xy = [me.x(me.origin[0])-me.fontSize[0]/me.fontSize[1]*3.5/me.view[2]-3, me.y(me.origin[1]) ];
	al = 'right-center';
	}
 if(align =='right'){
	xy = [me.x(me.origin[0])+me.fontSize[0]/me.fontSize[1]*3.5/me.view[2]+3, me.y(me.origin[1]) ];
	al = 'left-center';
 }
 me.title =  plot2D.text(me.group, text, xy	,fontSize, color, al);
 return me;
  },
 
update: func(propNode, factor=1, offset=0){
# propNode as valid string.
var value = getprop(propNode)* factor+ offset;
 me.text.setText(sprintf('%i',value)).setAlignment('center-center');
},

}; # digital

############################################################
 ###   Arc class  ###
 #########################
var arc = { 
# constructor
# center as [x,y] in absolute units.
# radius in pixels
# from and to as angles in degrees.
# title  as string.
new: func(group, center, radius, from=nil, to=nil, color="#0", title=nil ) {
 var m = {parents:[arc,graph,plot2D] };
 m.group = group;
 m.center = center;
 m.radius = radius;
 m.from = from;
 m.to = to;
 m.color = color;
 m.title = title;
 m.tic_e = [];
 m.label_e = [nil];
 m.init(title);
return m;
 }, # new()
 
init: func(title) {
  me.line = plot2D.arc(me.group,me.center,me.radius,me.from,me.to,me.color);
 if(title!=nil) me.setTitle(title);
},

del: func() {
 me.line.del();
 foreach(lbl;me.label_e) lbl.del();
 foreach(tic;me.tic_e) tic.del();
}, # del()
 
setTitle: func(text=nil, fontSize=nil, color=nil, align=nil) {
  if(typeof(me.title) == 'hash')   me.title.del();
    if(color==nil)  color = me.color;
    if(fontSize==nil) fontSize = [13,0.7];
 var xy = [me.center[0], me.center[1]+me.radius/2]; # by def.

 me.title =  plot2D.text(me.group, text, xy	,fontSize, color, 'center-center');
return me;
},

setTics: func(from=nil, to=nil, each=10, length=-5){
# from as angle in deg. (arc's origin by default). 
# to as angle in deg (arc's end by default). 
# each as angle in deg (15 deg by default). 
# length in pixels (externals if positive, internals otherwise). 
 me.ticsLength = length;
 if(from==nil) from = me.from;
 if(to==nil) to = me.to;
 for(var a=from;a<=to;a+=each){
	var xy = [me.center[0]+me.radius*math.sin(a*D2R), me.center[1]-me.radius*math.cos(a*D2R)];
	plot2D.polarLine(me.group, xy, 90-a, length, color=me.line.getColor());
	}
 return me;
},

setLabels: func(from=nil, to=nil, each=30, factor=1, offset=0, span=4){
# from as angle in deg. (arc's origin by default). 
# to as angle in deg (arc's end by default). 
# each as angle in deg (15 deg by default). 
# span in pixels (from arc's radius to label's baseline). 
 me.factor = factor;
 me.offset = offset;
 if(from==nil) from = me.from;
 if(to==nil) to = me.to;
 for(var a=from;a<=to;a+=each){
	plot2D.polarText(me.group, sprintf((a-from)*factor+offset),me.center,me.radius+span, 90-a, , color=me.line.getColor());
	}
 return me;
},

setNeedle: func(length=nil, color=nil, lineWidth=3, response=nil){
 if(length==nil) length = me.radius - 5;
 if(color==nil) color = me.line.getColor();
 me.needle = plot2D.polarLine(me.group, me.center, 90-me.from, length, color).setStrokeLineWidth(lineWidth);
 me.needle.setCenter(me.center);
return me;
},

updateNeedle: func(propNode){
# propNode as valid string.
var value = math.clamp(getprop(propNode),me.offset, (me.to-me.from)*me.factor+me.offset)/me.factor;
 me.needle.setRotation(value*D2R);
},

} # Arc class

setprop("/gca/par-version",1.2);
var PAR = func(width=444,height=300,icao='',rwy='', final=10) {
	var obj = ParScreen.new(width,height,icao,rwy);
   	obj.setOffset(500);
   	obj.setFinalApproach(final);
   	obj.setGrid(1,1000);
	obj.setZoom(16,4500);
	obj.rwyText = obj.createText(obj.texts,"rwyText",obj.airport.name ~"\nRunway "~ obj.rwyObj.id,[11,1],"left-top")
	.setTranslation(4,3);
	obj.compass = obj.createText(obj.texts,"compass","Z>",[15,1],"center-center")
	.setTranslation(obj.size.width/2,obj.size.height*0.4+15).setRotation((180-obj.rwyObj.heading)*D2R);
	obj.compass.setColor(1,1,0);
	obj.trafficText = obj.createText(obj.texts,"trafficText", '',[11,1],"left-bottom")
	.setTranslation(4, obj.size.height-3);
	obj.trackingText = obj.createText(obj.texts,"trackingText", 'Tracking: '~obj.callsign,[11,1],"left-bottom")
	.setTranslation(100, obj.size.height-3);
	var fg_color = canvas.style.getColor("fg_color");
	var bttns = obj.graph.createChild("path", "bttns").moveTo(0,obj.size.height+20 )
     .lineTo(0,obj.size.height).lineTo(obj.size.width,obj.size.height)
     .lineTo(obj.size.width,obj.size.height+20)
     .setColor(fg_color).setStrokeLineWidth(1);
   bttns.close().setColorFill(fg_color).set('fill',0);
	var xRwy = obj.createButton("RWY", func {obj.changeRwy();});
	var zout = obj.createButton("-", func {if(obj.zoom < 60) obj.setZoom(obj.zoom*2, obj.Vzoom*2);});
	var zin = obj.createButton("+",func {if(obj.zoom>7.5) obj.setZoom(obj.zoom/2, obj.Vzoom/2);});
#	var flip = obj.createButton("FLIP",func {obj.flipX();});
	var track = obj.createButton("Track",func {obj.track();});
	
	obj.buttons_bar.addSpacing(10);
	obj.buttons_bar.addItem(xRwy);
#	obj.buttons_bar.addItem(flip);
	obj.buttons_bar.addSpacing(10);
	obj.buttons_bar.addItem(track);
	obj.buttons_bar.addStretch(1);
	obj.buttons_bar.addItem(zout);
	obj.buttons_bar.addItem(zin);
	
	var div = obj.graph.createChild("path", "div")
		.moveTo(0, obj.size.height*0.4)
	.lineTo(obj.size.width, obj.size.height*0.4)
		.setColor(fg_color).setStrokeLineWidth(3);
	obj.Track1 = obj.graph.createChild("path", "Track1")
		.setColor(.3,.3,.8).setStrokeLineWidth(1);
	
	obj.Track2 = obj.graph.createChild("path", "Track2")
		.setColor(.3,.3,.8).setStrokeLineWidth(1);

return obj;
	 }

var ParScreen = {
# constructor
new: func(width=444,height=300,icao='',rwy='') {
 var m = {parents:[ParScreen] };
 m.size = {width:width, height:height};
 m.wndow = canvas.Window.new([m.size.width,m.size.height+20],"dialog").set("title","P A R screen"  );
 m.myCanvas = m.wndow.createCanvas().set("background", "#0c3003");
 m.root = m.myCanvas.createGroup();
 m.graph = m.root.createChild("group");
 m.marks = m.root.createChild("group");
 m.texts = m.root.createChild("group");
 m.myLayout = canvas.VBoxLayout.new();
 m.myCanvas.setLayout(m.myLayout);
 m.myLayout.addStretch(1);
 m.buttons_bar = canvas.HBoxLayout.new();
 m.myLayout.addItem(m.buttons_bar);
 m.airport = airportinfo(icao);
 m.runways = keys(m.airport.runways);
 m.rwyObj = airportinfo(icao).runways[rwy];
 m.rwy_elev = airportinfo(icao).elevation;
 #~ m.threshold = m.rwyObj.threshold *M2NM;
 m.TerrainResolution = 0.25;
 m.positionNode = props.getNode("/position");
 m.callsign = getprop("/sim/multiplay/callsign");
 m.tracked = getprop("/sim/multiplay/callsign");
 m.rhoText = m.createText(m.texts,"rhoText","rho=0.0 nm\ndelta=0 deg",[11,1],"right-bottom")
	.setTranslation(m.size.width-1, m.size.height-3);
 m.altText = m.createText(m.texts,"altText","alt=0 ft",[11,1],"right-bottom")
	.setTranslation(m.size.width-1, m.size.height*0.4-4);
 m.gridText = m.createText(m.texts,"gridText","Hdiv=",[11,1],"right-top")
	.setTranslation(m.size.width-1,3);
 m.cs2Text = m.createText(m.texts,"cs2Text","o\n\n"~ m.callsign,[8,0.8],"left-top").setTranslation(0,m.size.height+1);
 m.cs1Text = m.createText(m.texts,"cs1Text","o\n\n"~ m.callsign,[8,0.8],"left-top").setTranslation(0,m.size.height+1);
 #~ (group,text,origin=nil, size=[11,1], color="#0",align="left-baseline") {
 #~ m.cs1Text = canvas.plot2D.text(m.texts,"o\n\n"~ m.callsign,[0,m.size.height-20],[8,0.8],nil,"left-top");
 m.Hgrid = nil;
 m.label = nil;
 m.slope = 3;
 m.Track1 = nil;
 m.zoom = 30;
 m.flip = 1;
return m;
 }, # new()

# destructor
del: func() {
}, # del()

##### Setters: 
setPositionNode: func(path) { # path as string
 me.positionNode = props.getNode(path);
 me.callsign = path =='/position' ? getprop("/sim/multiplay/callsign") : me.positionNode.getParent().getValue("callsign");
 }, # setPositionNode()

setFinalApproach: func(nm) {
 me.final = nm;
 me.profile = gca.getVertProfile(me.touchObj,me.rwyObj.heading+180, me.TerrainResolution);
 me.safety_slope =  math.max(0, minSlope(me.profile, me.TerrainResolution, nm ));
 }, # setFinalApproach()

setSafetySlope: func(slope) {
 me.safety_slope = slope;
 }, # setSlope()

setOffset: func(m) {
 me.touchObj = geo.Coord.new().set_latlon(me.rwyObj.lat, me.rwyObj.lon, me.airport.elevation)
  .apply_course_distance(me.rwyObj.heading, m);
 }, # setSlope()

setTerrainResolution: func(nm) {
 me.TerrainResolution = nm;
 }, # setTerrainResolution

setSlope: func(slope) {
 me.slope = slope;
 }, # setSlope()

setGrid: func(hz, vt) {
 me.vtGrid = vt;
 me.hzGrid = hz;
 me.texts.setColor([.7,.7,0]);
 me.gridText.setText(sprintf("Hdiv=%i nm\nVdiv=%i ft",hz,vt));
 }, # setGrid()

setZoom: func(nmH, ftV) { # view up to <nmH>mn, <ftV>feet
 me.zoom = nmH;
 me.Vzoom = ftV;

if(me.Hgrid !=nil) {
  var el = [me.Hgrid,me.Vgrid,me.Hcenter,me.Vcenter,me.Hcone,me.Vcone,me.asph,me.terrain];
  foreach(e;el) e.del();
   me.Track1.reset();
   me.Track2.reset();
   } else {
	me.wndow.move(5,60);
 }

 me.XYscale = (me.size.width-10)/nmH; # px/nm
 me.Zscale = (me.size.height*.4-10)/ftV; # px/ft
(me.x0,me.y0,me.z0) = (10,me.size.height*0.7,me.size.height*0.4-10);
 var gridColor = [0.25,0.25,0.25];
  var red = [0.4,0,0];
  var terrain = [0.4,0.2,0.0];
  var lightGrey = [.5,.5,.5];
 var t = me.y0-0.5*me.hzGrid*me.XYscale*int(me.size.height*0.6/me.hzGrid/me.XYscale);
 me.Hgrid = canvas.plot2D.grid(me.graph, [me.size.width, me.size.height*0.6],
		me.hzGrid*me.XYscale, me.hzGrid*me.XYscale, [me.x0, t],gridColor, 0);
 
 t = me.z0- me.vtGrid*me.Zscale*int(me.size.height*0.4/me.vtGrid/me.Zscale);
 me.Vgrid = canvas.plot2D.grid(me.graph, [me.size.width, me.size.height*0.4],
		me.hzGrid*me.XYscale, me.vtGrid*me.Zscale, [me.x0, t],gridColor, 0);
    
 me.asph = canvas.plot2D.rectangle(me.graph, [me.x0+.35*me.XYscale, 0.4*me.XYscale],[0,me.y0-0.2*me.XYscale],nil, [.3,.3,.3]);
  me.Hcenter = canvas.plot2D.hzLine(me.graph, [me.x0,me.y0], 10*me.XYscale, red);
  me.Vcenter = canvas.plot2D.line(me.graph, [me.x0,me.z0], [me.x0+10*me.XYscale,me.z0-10*math.tan(me.slope*D2R)*NM2FT*me.Zscale], red);
  
# get terrain profil (each <TerrainResolution> nm)
 var h = [];
 # convert feet to pixels;
 for(var i=0;i<size(me.profile);i+=1) {
	var aux = (me.profile[i]==nil or me.profile[i]*me.Zscale<(-10))? 10 : me.profile[i]*(-me.Zscale);
	append(h,aux) ;
	}
me.terrain = canvas.plot2D.graphic(me.graph, h, me.TerrainResolution*me.XYscale, [me.x0,me.z0], terrain); 
 me.terrain.setStrokeLineWidth(2);

 var xvec = [me.x0+10*me.XYscale,me.x0,me.x0+10*me.XYscale];
 var yvec = [me.z0-10*math.tan(me.safety_slope*D2R)*NM2FT*me.Zscale, me.z0,me.z0-10*math.tan((2+me.slope)*D2R)*NM2FT*me.Zscale];
 me.Vcone = canvas.plot2D.polyline(me.graph, xvec, yvec, lightGrey);
 yvec = [me.y0-10*math.tan(6*D2R)*me.XYscale, me.y0, me.y0+10*math.tan(6*D2R)*me.XYscale];
 me.Hcone = canvas.plot2D.polyline(me.graph, xvec, yvec, lightGrey);
 
# if(me.flip == -1) me.flipX(toogle:0);
 me.wndow.clearFocus();
 me.timer = maketimer(2,func {me.update();});
 me.timer.stop();
 me.timer.simulatedTime=1;
 me.timer.start();
}, # setZoom

##### end of Setters ################


########################################
## Helpers:
###
update: func() { # called by me.timer
 var nodes = me.validNodes();
 me.marks.removeAllChildren();
 for(var i=0; i<size(nodes); i+=1){
  if(nodes[i]!=me.positionNode)	me.updateMark(nodes[i],i);
  }
 me.updateTrack(me.positionNode); 

 me.trafficText.setText(sprintf("Traffic: %i",size(nodes)-1));
if(size(nodes) ==0) me.trafficText.setText("");
}, # update 

rhoDeltaAlt: func(node) { # 
 var lat = node.getValue('latitude-deg');
 var lon = node.getValue('longitude-deg');
 var plane = {lat: lat, lon: lon};
 var (delta, rho) = courseAndDistance(me.touchObj, plane); # to touch
 delta = 180 + me.rwyObj.heading - delta;
 var alt = node.getValue('altitude-ft');
 return [rho,delta,alt];
}, # rhoDeltaAlt

updateMark: func(node,i) { # 
 var (rho,delta,alt) = me.rhoDeltaAlt(node);
 var (x,y,z) =  me.xyz(rho,delta,alt);
 var cs = i==0? me.callsign : node.getParent().getValue("callsign");
 if(me.tracked !=cs and y>me.size.height*0.4 and y<me.size.height-20) {
	 var markText = me.createText(me.marks, sprintf(i),sprintf("o\n%s",right(cs,3)),[10,1],"left-top")
	 .setTranslation(x-4,y-5);}
 if(me.tracked !=cs and z<me.size.height*0.4) {
	 var markText = me.createText(me.marks, sprintf(i),sprintf("o\n%s",right(cs,3)),[10,1],"left-top")
	 .setTranslation(x-4,z-5);
	 }
}, # updateMark

xyz: func(dist,delta,altitude) { # 
 var x = int(me.x0+(dist*math.cos(delta*D2R))*me.XYscale*me.flip);
 var y = int(me.y0-(dist*math.sin(delta*D2R))*me.XYscale*me.flip);
 var z = int(me.z0 - (altitude - me.airport.elevation*M2FT) * me.Zscale);
 return [x,y,z];
}, # xyz

updateTrack: func(node) { 
 if(node == nil) return;
 var (rho,delta,alt) = me.rhoDeltaAlt(node);
 me.rhoText.setText(sprintf("rho=%.1f nm\ndelta=%i deg", rho, delta));
 me.altText.setText(sprintf("alt=%i ft", alt));
 me.appendTrack(rho, delta, alt, me.airport.elevation*M2FT);
}, # updateTrack

appendTrack: func(dist,delta,altitude,rwyAlt) { # dist in nm, delta in deg, altitude in ft, rwyAlt in ft.
  var (x,y,z) =  me.xyz(dist,delta,altitude);
  if(me.Track1.getNumCoords() == 0) {
	me.Track1.moveTo(x, z);
	me.Track2.moveTo(x, y);
 } else {
	me.Track1.lineTo(x, z);
	me.cs1Text.setTranslation(x-4,z-5);
	 if(y>me.size.height*0.4 and y<me.size.height-20) {
		 me.cs2Text.setTranslation(x-4,y-5);
		 me.cs2Text.show();
	     me.Track2.lineTo(x, y);
	     } else {
		 me.cs2Text.hide();
	     me.Track2.moveTo(x, y);
	 }
  }
}, # appendTrack


#~ autoZoom: func(x,y) {
	#~ if(me.zoom !=7 and (x-me.x0)/me.XYscale <7 and abs(me.y0-y)/me.XYscale <1.5 ) {
		#~ me.setZoom(7,3000);
		#~ return 7;}
	#~ if(me.zoom !=30 and ((x-me.x0)/me.XYscale >=15 or abs(me.y0-y)/me.XYscale >=3)) {
		#~ me.setZoom(30,8000);
		#~ return 30;}
	#~ if( me.zoom !=15 and (x-me.x0)/me.XYscale >=7 and (x-me.x0)/me.XYscale <15) {
	#print("Zoom=",me.zoom);
		#~ me.setZoom(15,4000);
		#~ return 15;}
	#~ return 0;
#~ },
createButton: func(text,function){
 var butt = canvas.gui.widgets.Button.new(me.root, canvas.style, {}).setText(text);
 butt.setFixedSize(32+size(text)*2, 18);
 butt.listen("clicked", function);
 return butt;
}, # createButton

createText: func(layer,name,text,size,align) {
 var Text = layer.createChild("text", name);
 Text.setText(text)
  .setFontSize(size[0],size[1]).setAlignment(align);
 return Text;
}, # createText

flipX: func(toogle=1) {
 if(toogle) me.flip *= -1;
 me.x0 = me.size.width - me.x0;
 var elements = [me.Hgrid, me.Vcone,me.Vgrid, me.Hcone, me.Hcenter, me.Vcenter, me.terrain, me.asph, me.compass];
 foreach(elem;elements) {
	canvas.plot2D.flipX(elem,me.size.width/2);
 #~ me.cs1Text.setTranslation(t,0);
 #~ me.cs2Text.setTranslation(t,0);
  }
me.wndow.clearFocus();
}, # flipX

changeRwy: func() {
 for(var i=0; i<size(me.runways);i+=1) if(me.runways[i] == me.rwyObj.id) break;
 if(i == size(me.runways)-1) i = -1;
 me.rwyObj = me.airport.runways[me.runways[i+1]];
 me.rwyText.setText(me.airport.name ~"\nRunway "~ me.rwyObj.id);
 me.compass.setRotation((180-me.rwyObj.heading)*D2R);
 me.profile = gca.getVertProfile(me.touchObj,me.rwyObj.heading+180,me.TerrainResolution);
 me.safety_slope =  math.max(0, minSlope(me.profile, me.TerrainResolution, me.final));
 me.setZoom(me.zoom,me.Vzoom); # redraw
 me.wndow.clearFocus();
}, # changeRwy

track: func() {
 var nodes = me.validNodes(100);
 if(size(nodes)==1) return;
var callsigns = [me.callsign];
 for(var i=1; i<size(nodes);i+=1) append(callsigns, nodes[i].getParent().getNode("callsign",1).getValue());
 for(var i=0; i<size(callsigns);i+=1) if(callsigns[i] == me.callsign) break;
 if(i == size(callsigns)-1) i = -1;
 me.tracked = callsigns[i+1];
 me.positionNode = nodes[i+1];
 me.trackingText.setText(sprintf("Tracking: %s",me.tracked));
   me.Track1.reset();
   me.Track2.reset();
 me.cs1Text.setText("o\n"~ me.tracked);
 me.cs2Text.setText("o\n"~ me.tracked);
 me.wndow.clearFocus();
}, # track

validNodes: func(range=100) { # for me and AI traffic (if flying, dist < range)
 var v = [props.globals.getNode("/position")];
 var AIList = props.globals.getNode("/ai/models").getChildren( 'aircraft' );
 for(var i=0; i<size(AIList); i+=1) {
    var (rho,delta,alt) = me.rhoDeltaAlt(AIList[i].getNode("position"));
	var tas = AIList[i].getNode('velocities',1).getNode('true-airspeed-kt',1).getValue();
	if(rho <range and tas > 1) append(v, AIList[i].getNode("position")); # ignore not flying and far ones.
 }
 return v;
}, # AIcallsigns

}; # ParScreen

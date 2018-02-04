var home = getprop("/sim/fg-aircraft")~"/CitationX";
io.load_nasal( home ~ '/Nasal/Spoken_GCA/plot2D.nas', "canvas" );
io.load_nasal( home ~ '/Nasal/Spoken_GCA/graph.nas', "canvas" );
var show = func {
var window = canvas.Window.new([400,200],"dialog").set("title","Graph test"  ).clearFocus().move(0,150);
var myCanvas = window.createCanvas().set("background", "#222222");
var root = myCanvas.createGroup();
var static = root.createChild("group");
var myGroup = root.createChild("group");
var (white,grey,red,green,blue,yellow) = ['#eeeeee','#777777','#ee0000','#00ee00','#0000ee','#00eeee'];
canvas.plot2D.rectangle(static,[40,160],,,grey);
canvas.plot2D.rectangle(static,[400,40],[0,160],,grey);
canvas.plot2D.rectangle(static,[400,200],,white).setStrokeLineWidth(3);

var view = [65,157,43,-0.06];
var Graph = canvas.graph.new(myGroup,view);
Graph.setXaxis(start:[-1,3/view[3]], length:[8.5,white], title:'nm', tics:[0.5,2/view[3]], labels:2);
Graph.setYaxis(start:[-.62,00], length:[2520,white], title:'ft', tics:[250,-2/view[2]], labels:2);
canvas.plot2D.move(Graph.Yaxis.label_e[0],0,7);

var plane = Graph.polyline([-0.3,-0.3,0.3], [1100,1000,1000], white).close().setStrokeLineWidth(2);
#----------
var timer = maketimer(.5,func {update();});
timer.stop();
timer.simulatedTime=1;
timer.start();
var bearing = nil;
var terrain = nil;

var update = func(){
var v= getprop('/position/altitude-ft');
var y = Graph.y(v);
 canvas.plot2D.alignY(plane, y,'bottom-center');
 var tg = getprop('/velocities/speed-down-fps')*3600/ getprop('/velocities/groundspeed-kt');
if(bearing!=nil) bearing.del();
 var end = ((v-7*tg)>0 or tg==0)? [7, v-7*tg] : [v/tg,0];
 if(getprop('/velocities/airspeed-kt')>50) bearing = Graph.line([0,v],end,white);
if(terrain!=nil) terrain.del();
var ac_pos = geo.aircraft_position().set_alt(0);
var resol = 0.25;
var h = getVertProfile(ac_pos,getprop('/orientation/track-deg'),resol,7) ;
var xSet = [];
for(var i=0; i<size(h); i+=1) append(xSet, i*resol);
 terrain = Graph.polyline(xSet,h,green);
terrain.setStrokeLineWidth(2);
}

# **** getVertProfile func. returns h[ <terrain elevation(feet)> ...] (each <resolution> nm).
var getVertProfile = func(geoObj,direction,resolution,dist=32) {
#  direction in deg, resolution in nm, optional dist in nm.
# if agl=1 (default) returns elevations relative to geoObj.
 var x0 = geo.Coord.new().set_latlon(geoObj.lat(), geoObj.lon()).latlon();
 var x1 = geo.Coord.new().set_latlon(geoObj.lat(), geoObj.lon())
  .apply_course_distance(direction, dist*NM2M).latlon();
 var dlat = (x1[0]-x0[0])/(dist/resolution);
 var dlon = (x1[1]-x0[1])/(dist/resolution);
 var h = [];
 for(var i=0; i<=(dist/resolution); i+=1) append(h, geo.elevation(x0[0]+i*dlat, x0[1]+i*dlon));
 # got h with elevations (m)
 var from = 999;
 var to=999;
 for(var i=0;i<size(h);i+=1){
 if(h[i]==nil and from==999) from=i;
 if(h[i]==nil and from!=999) to=i;
 }
 if(from !=999){
   printf("Warning: found nils between %.2fnm and %.2fnm from rwy.",from*0.1,to*0.1);
 }
 for(var i=0; i<=(dist/resolution); i+=1) if(h[i]!=nil) h[i]=(h[i]-geoObj.alt())*M2FT;
 return h;
}
}

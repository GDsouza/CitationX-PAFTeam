#print("GCA control 0.5 loaded");
var demo = nil;
var Par = nil;
var window = nil;
var bye = 0;
var prev_phrase = '';

var Control=func() {
# 0) Check dependencies
var needConf = 0.2;
var needPhras = 2.1;
var needGca = 0.3;
var needPar = 1.2;
var needGui = 0.2;
if(CheckVersion("gca_class.nas", "/gca/gca-version", needGca)) return;
if(CheckVersion("phraseology.xml", "/gca/phrases/version", needPhras)) return;
if(CheckVersion("config.xml", "/gca/config-version", needConf)) return;
if(CheckVersion("par_class.nas", "/gca/par-version", needPar)) return;
if(CheckVersion("gca_gui.nas", "/gca/gui-version", needGui)) return;

if(getprop("/gca/callsign-fmt") ==nil) setprop("/gca/callsign-fmt",'');


if( isa(demo, GCAController) ){
   demo = nil; # Abort, end GCA service
   var abort = join("abort");
   setprop("/sim/sound/voices/atc", abort);
   write(abort);
   cleanAll();
   return;
   }
   
# Choose destination from comm freq
var icao = getprop("/instrumentation/comm/airport-id");   
### Exceptions ####
if (icao == "LFPB") icao = "LFPG";

###################
var info = airportinfo(icao);   
if(getprop("/instrumentation/comm/volume")<0.1) {
    gui.popupTip("Turn Comm1 on. Set volume",3);
    return ;
} elsif(info.name==nil or getprop("/instrumentation/comm/signal-quality-norm")<0.01) {
  # if invalid freq or out of range
    gui.popupTip("Check comm freq.!",3);
    return ;}
var aux1 = getprop("/instrumentation/comm/station-name");
var aux =(string.match(aux1,"* *"))? capit(aux1) : string.replace(info.name,"Intl","International") ;
setprop("/gca/station-name", aux);

# Choose best rwy
var best = chooseRwy(info.runways);
var rwy_object = airportinfo(icao).runways[best];
var test = geo.Coord.new().set_latlon(rwy_object.lat,rwy_object.lon)
			  .apply_course_distance(rwy_object.heading,rwy_object.threshold);
var latlon = test.latlon();
if (geo.elevation(latlon[0],latlon[1]) == nil) {
  gui.popupTip("Destination too far, tile not loaded",3);
  return;
}

# Instance GCAController 
demo = gca.GCAController.new();
demo.setAirport(icao);
demo.setRunway(best);
demo.setFinalApproach(10);

prev_phrase = '';

# 5) Check current position
var rwy = info.runways[best];
var elev = geo.elevation(demo.destination.rwy_object.lat
						, demo.destination.rwy_object.lon); # (m)

var tick =nil;

# this callback will be invoked by the GCA controller when it has a new instruction
var receiver = func(instruction) {
	if(demo==nil) return "bye";
	tick = tick==nil ? 0: tick+1;
	var from = {lat:demo.aircraft_state.latitude_deg, lon:demo.aircraft_state.longitude_deg};
	var (crse, dist) = courseAndDistance(from, demo.destination.rwy_object); # to rwy
	var delta = demo.destination.rwy_object.heading - demo.rwyCrse;
	
	if(demo.phrase=="oncourse" 
		and dist*NM2M < 100 
		and (prev_phrase=="oncourse" or left(prev_phrase,6)=="slight")) {
	      instruction = join("bye");
	      demo.phrase = "bye";
	      bye = 1;
	      }
	       	
	if(tick==demo.maxsecs or demo.phrase!=prev_phrase ){
	  setprop("/sim/sound/voices/atc", instruction);
	  tick = 0;
	  instruction = delayed(instruction);
	  write(instruction);
	  prev_phrase = demo.phrase;
	  }
	if(bye) {
	      demo = nil;
	      cleanAll();
	  }
} # receiver func

if(receiver=="bye") return; # quit Control func
demo.registerReceiver( receiver );

# calling UI
demo.openDialog();

} # Control func

var delayed = func(instruction){
 var appnd = "";
if((left(demo.phrase,4) =="left" or left(demo.phrase,5) =="right") and string.match(prev_phrase,"to?bas*")){
  appnd = join("dont");
  settimer(func(){if(demo!=nil) setprop("/sim/sound/voices/atc", appnd)},12);
  }
if(left(demo.phrase,6)=="turn90") {
  appnd = join("glide");
  settimer(func(){if(demo!=nil) setprop("/sim/sound/voices/atc", appnd)},40);
  settimer(func(){if(demo!=nil) setprop("/gca/near", 1)},60);
 }

if((demo.phrase =="oncourse" or left(demo.phrase,6) =="slight") and demo.rwyDist <=demo.destination.final) {
  appnd = join("pathalt");
  settimer(func(){if(demo!=nil) setprop("/sim/sound/voices/atc", appnd);},1);
 }
 return instruction ~ appnd;
} # delayed

var cleanAll = func(){
 bye = 0;
 prev_phrase = '';
 setprop("/gca/near",0);
 setprop("/gca/controlled",0);
 setprop("/gca/prev-msg",'');
 setprop("/gca/prev-apt-name",'');
} # cleanAll

var write = func(str){
 if(window==nil) window = screen.window.new(nil,-50,10,8);
 window.write(str,1,1,1);
} # write

var CheckVersion = func(file,prop,need) {
 var have = getprop(prop);
 if(have < need) {
    gui.popupTip("Error:\n"~file~" Must be version " ~sprintf("%.2f", need)
         ~" or later.\n(You have " ~sprintf("%.2f", have)~").", 20);
    return 1;  
	} 
 return 0;
}


# GCAController class
#

# methods:
#	.stop()
#	.setCallsign(string)
#	.setRoot(positionNodePath)
#	.setTransmissionInterval(secs)
#	.setAirport(icao)
#	.setRunway(rwy)
#	.setFinalApproach(nm)
#	.setGlidepath(deg)
#	.setTerrainResolution(nm)
#	.setDecisionHeight(ft)
#	.setTouchdownOffset(ft)
#	.setTransmissionChannel(node)
#	.restart(seconds)
#	.setAircraft(root)
#	.computeRequiredHeading()
#	.computeRequiredAltitude()


setprop("/gca/gca-version",0.3);
var GCAController = {
# constructor
new: func() {
 var m = {parents:[GCAController] };
 m.version = 0.2;
 m.aircraft_properties = {altitude_ft: "altitude-ft", latitude_deg: "latitude-deg", longitude_deg: "longitude-deg"};
 m.aircraft_state = {latitude_deg:0.00, longitude_deg:0.00, altitude_ft:0.00, heading_deg:0.00 }; 
 m.aircraft_object = geo.Coord.new();
 m.destination = {airport:'', runway:'', elevation:0.00, glidepath:0.00, 
                  safety_slope:0.00, decision_height:0.00, offset:0.00, 
                  rwy_object:'', final:0.00 };
 m.receivers = []; # callbacks to receive instructions from the GCA controller
 m.timer = maketimer(5, func m.update() );
 m.timer.simulatedTime = 1;
 m.phrase = '';
 m.root = '';
 return m;
 }, # new()

# destructor (no really)
del: func() {
me.timer.stop();
}, # del()

##### Setters: 
setCallsign: func(text) {
me.callsign = text;
setprop("/gca/callsign-fmt", alpha(me.callsign));
},

setRoot: func(root) {
me.root = root;
},

setTransmissionInterval: func(secs) {
if(secs < 0) 
	me.pError("setTransmissionInterval",secs);
me.phrase = 'prolog';
me.maxsecs = '5';
me.notifyReceivers(join("this"));
me.timer.restart(num(secs));
},

setAirport: func(airport) {
var match = airportinfo(airport);
if (match == nil or typeof(match) != 'ghost') 
	me.pError("setAirport",airport);
me.destination.airport = airport;
setprop("/gca/apt-name", airportinfo(airport).name);
me.destination.elevation = airportinfo(airport).elevation; # (m)
 if(myDbg) printf("setAirport(%s)", airport);
},

setRunway: func(rwy) {
  var match = airportinfo(me.destination.airport).runways;
  if (typeof(match)!="hash" or !size(keys(match)) or match[rwy] == nil)
	  me.pError("setRunway",rwy);
  me.destination.runway = rwy;
  me.destination.rwy_object = airportinfo(me.destination.airport).runways[rwy];
  setprop("/gca/rwy-in-use", spell(rwy, 0));
  me.touch = geo.Coord.new().set_latlon(me.destination.rwy_object.lat, me.destination.rwy_object.lon)
			  .apply_course_distance(me.destination.rwy_object.heading, me.destination.rwy_object.threshold);
  var latlon = me.touch.latlon();
  me.touch.set_alt(1+geo.elevation(latlon[0],latlon[1]));
  if(myDbg) printf("setRunway(%s) ",rwy);
 },

setFinalApproach: func(final) {
if(final < 3 or final > 20) 
	me.pError("setFinalApproach",final);
me.destination.final = final;
 if(myDbg) printf("setFinalApproach(%i nm)", final);
},

setGlidepath: func(slope) {
if(slope < 1 or slope > 180) 
	me.pError("setGlidepath",slope);
me.destination.glidepath = slope;
var gateAlt = me.destination.elevation*M2FT+ me.destination.final *math.tan( me.destination.glidepath*D2R)*NM2M *M2FT;
me.geoGate = geo.Coord.new().set_latlon(me.destination.rwy_object.lat
			, me.destination.rwy_object.lon)
			.apply_course_distance(me.destination.rwy_object.heading + 180
			, me.destination.final*NM2M-me.destination.rwy_object.threshold)
			.set_alt(gateAlt*FT2M);
setprop("/gca/appgate-alt-fmt", sprintf("%i",math.round(gateAlt,100)));
 if(myDbg) printf("setGlidepath(%i deg), gateAlt=%i ft.", slope,gateAlt);
},

setSafetySlope: func(slope) {
# not used;
},

setTerrainResolution: func(nm) {
if(nm < 0 or nm > 10) 
	me.pError("setTerrainResolution",nm);
me.TerrainResolution = nm;
},

setDecisionHeight: func(height) {
if(height < 0 ) 
	me.pError("setDecisionHeight",height);
me.destination.decision_height = height;
},

setTouchdownOffset: func(offset) {
if(offset < 0 ) 
	me.pError("setTouchdownOffset",offset);
me.destination.offset = offset;
},

setTransmissionChannel: func(node) {
if (getprop(node) == nil)
	me.pError("setTransmissionChannel",node);
me.TransmissionChannel = node;
},

setVertGrid: func(ft) {
if(ft < 100 or ft > 4000) 
	me.pError("setVertGrid",ft);
me.VertGrid = ft;
},

setHzGrid: func(nm) {
if(nm < 0.1 or nm > 10) 
	me.pError("setHzGrid",nm);
me.HzGrid = nm;
},

restart: func(s) {
me.timer.restart(num(s));
}, # restart()

# stop/interrupt the GCA
stop: func() {
 me.timer.stop();
}, # stop()

##### end of Setters ################


########################################
## Helpers:
###
# this will be called by our timer
update: func() {
	if(me.root != '/position') return; # if is other plane, noting to do!
	me.updatePosition();
	me.updateStage();
	me.computeRequiredHeading();
	me.computeRequiredAltitude();
	
	var instruction = me.buildInstruction();
	# now that we have an instruction, pass it to registered callbacks 
	me.notifyReceivers(instruction);
	#~ var t1 = systime(); # record new time
	#~ print("Controller_class() took ", (t1 - t0)*1000, " ms"); # print result
}, # update()


updatePosition: func() {
foreach(var p; keys(me.aircraft_properties)) me.aircraft_state[p] = getprop(me.root ~'/'~ me.aircraft_properties[p]);
var orientation = string.replace(me.root, '/position', '/orientation');
var latlon = [me.aircraft_state.latitude_deg, me.aircraft_state.longitude_deg];
var heading = me.root == '/position'? getprop('/orientation/heading-deg') : getprop(orientation~'/true-heading-deg') ;
me.aircraft_state["heading_deg"] = heading;# - magvar(latlon[0],latlon[1]);

me.aircraft_object.set_latlon(me.aircraft_state.latitude_deg,
							  me.aircraft_state.longitude_deg 
							 , me.aircraft_state.altitude_ft   );

var gndElev = geo.elevation(latlon[0],latlon[1]);
if(gndElev == nil) gndElev = 0; # tile not loaded yet.
setprop("/gca/altitude-agl-ft",  me.aircraft_state.altitude_ft - gndElev*M2FT);
}, # updatePosition()

updateStage: func() {
	var rwy = me.destination.rwy_object;
	var (crse, dist) = courseAndDistance(me.aircraft_object, me.touch); # to rwy touchdown
	var (rwyCrse, rwyDist) = courseAndDistance(me.aircraft_object, rwy); # to rwy
	me.rwyDist = rwyDist;
	me.rwyCrse = rwyCrse;
	var (gateCrse, gateDist) = courseAndDistance(me.aircraft_object, me.geoGate); # to App gate
	var geoLbase = geo.Coord.new().set_latlon(rwy.lat, rwy.lon)
			.apply_course_distance(rwy.heading + 180, 1+me.destination.final*NM2M-rwy.threshold)
			.apply_course_distance(rwy.heading - 90, 3*NM2M);
	var (lBaseCrse, lBaseDist) = courseAndDistance(me.aircraft_object, geoLbase); # to left base
	var geoRbase = geo.Coord.new().set_latlon(rwy.lat, rwy.lon)
			.apply_course_distance(rwy.heading + 180, 1+me.destination.final*NM2M-rwy.threshold)
			.apply_course_distance(rwy.heading + 90, 3*NM2M);
	var (rBaseCrse, rBaseDist) = courseAndDistance(me.aircraft_object, geoRbase); # to right base
		
	# -  props
	var hand =(geo.normdeg(lBaseCrse-me.aircraft_state.heading_deg)<180)? "right " : "left ";
	setprop("/gca/lbase-hand", hand);
	hand =(geo.normdeg(rBaseCrse-me.aircraft_state.heading_deg)<180)? "right " : "left ";
	setprop("/gca/rbase-hand", hand);
	var aux = abs(gateDist *math.sin(D2R*(gateCrse-rwy.heading-180)));
	setprop("/gca/dist-to-rwy", sprintf("%.1f",me.rwyDist));
	setprop("/gca/gate-delta", geo.normdeg180(180+gateCrse-rwy.heading));
	setprop("/gca/rwy-delta", geo.normdeg180(180+rwyCrse-rwy.heading));
	setprop("/gca/dist-to-app-crse", aux);
	setprop("/gca/dist-to-app-crse-fmt", sprintf("%.1f",aux));
	var vector = aux>2 ? gateCrse : (rwy.heading-90)*math.sgn(geo.normdeg180(rwy.heading-rwyCrse)) ;
	vector = geo.normdeg(vector);
	hand =(geo.normdeg(vector-me.aircraft_state.heading_deg)<180)? "right " : "left ";
	setprop("/gca/turn-hand", hand);
	setprop("/gca/vector", spell(sprintf("%03.0f",vector),3));
	setprop("/gca/course-to-rwy", spell(sprintf("%03.0f",rwyCrse),3));
	setprop("/gca/course-to-lbase", spell(sprintf("%03.0f",lBaseCrse),3));
	setprop("/gca/course-to-rbase", spell(sprintf("%03.0f",rBaseCrse),3));
	if(abs(geo.normdeg180(lBaseCrse-me.aircraft_state.heading_deg))<4 
	    or abs(geo.normdeg180(rBaseCrse-me.aircraft_state.heading_deg))<4){
		setprop("/gca/heading-ok", 1);
	} else {
		setprop("/gca/heading-ok", 0);
	}
	
	if(getprop("/gca/prev-apt-name")!=airportinfo(me.destination.airport).name ) 
	     setprop("/gca/prev-msg-type", ""); 
	     
},# updateStage()

computeRequiredHeading: func() {
	# phrase structure is: [ phrase-type , max-secs ]
	var phrases= [["turn90l",60],["turn90r",60],["oncourse",10],["slightleft",8],["wellleft",10]
	             ,["left",10],["tolbaseok",30],["tolbase",20],["torbaseok",30]
	             ,["torbase",20],["right",10],["slightright",8],["wellright",10],["none",8]];
	forindex(var i; phrases) { 
	    if(props.condition(sprintf("/gca/logic/condition[%i]",i))) break;
	}
	if(i<6 or i>9) setprop("/gca/controlled",1); # if yet on CTR
	if((i>1 and i<5) or i==11 or i==12)  setprop("/gca/near",1); # if near
	setprop("/gca/prev-msg-type", me.phrase);
	me.phrase = phrases[i][0];
	me.maxsecs = phrases[i][1] ;
}, # computeRequiredHeading()

computeRequiredAltitude: func() {
	var condition = me.phrase!="oncourse" and left(me.phrase,3)!="well" and left(me.phrase,6)!="slight";
	var dif = me.aircraft_state.altitude_ft - me.geoGate.alt()*M2FT;
	setprop("/gca/climb", dif>200 and condition ? "Descend " : dif<-200 and condition ? "Climb " : "");
	
	var difSlope = (me.aircraft_state.altitude_ft*FT2M-me.destination.elevation) 
	                /  me.rwyDist /NM2M - math.tan(me.destination.glidepath*D2R);
	setprop("/gca/over-glidepath", difSlope>0.012 ? "Above " : difSlope<-0.005 ? "Below " : "On ");
}, # computeRequiredAltitude()


buildInstruction: func() {
	var sources = [];
	var destinations = ["/gca/value[0]","/gca/value[1]","/gca/value[2]"];
	if(me.phrase=="oncourse" or left(me.phrase,3)=="well" ) {
	   append(sources,"/gca/course-to-rwy","/gca/dist-to-rwy");
	} elsif(me.phrase=="left" or me.phrase=="right") {
	   append(sources,"/gca/turn-hand","/gca/vector","/gca/dist-to-app-crse-fmt" );
	} elsif(left(me.phrase,7)=="tolbase") {
	   append(sources,"/gca/lbase-hand","/gca/course-to-lbase" );
	} elsif(left(me.phrase,7)=="torbase") {
	   append(sources,"/gca/rbase-hand","/gca/course-to-rbase" );
	} elsif(left(me.phrase,6)=="turn90") {
	    append(sources,"/gca/course-to-rwy" );
	}
	for(var i=0; i<size(sources); i+=1)
	   setprop(destinations[i],getprop(sources[i]));
	
	if(getprop("/gca/climb") !='') return join(me.phrase) ~join("climb");

	return join(me.phrase); 
}, # buildInstruction

registerReceiver: func(receiver) {
append(me.receivers, receiver);
}, #registerReceiver()


notifyReceivers: func(instruction) {
foreach(var r; me.receivers) {
  r(instruction);
 }
},

openDialog: func() {
 fgcommand("pause");
 #~ var min = minSlope(me.touch, me.destination.rwy_object.heading+180, me.destination.final *NM2M);
 #~ if(myDbg) printf("SafeSlop(%.2f)",min);
 var defValues = {icao:me.destination.airport, rwy:me.destination.runway
			, safety_slope:0
			, channel:'/sim/sound/voices/atc', interval:1.00};
 var mask = {"Decision Height":'', 'Transmission channel':'' };
	configureGCA(demo, defValues, mask);
},

pError: func(caller, value) {
printf("Wrong arg value in %s(%s) !", caller,value);
}
}; # end of GCAController class


# GCA Controller class
#

var Controller = {
# constructor
new: func(receiver) {
 var m = {parents:[Controller] };
 m.version = 0.2;
 m.aircraft_object = geo.Coord.new();
 m.receiver = receiver; # callback
 m.phrase = '';
 m.root = '';
 m.window = nil;
 m.tick = nil;
 m.maxsecs = 5;
 m.prev_phrase = '';
 return m;
 }, # new()

del: func() {
call(me.receiver.actuate['toggleGCA'],nil,me.receiver);
}, # del()

##### Setters: 
setDestination: func(icao='', rwy='', final=10, minSlope=0,glidepath=3) {
 me.destination = {airport:icao, runway:rwy, glidepath:glidepath, 
                  safety_slope:minSlope, decision_height:0.00, offset:0.00, 
                  rwy_object:airportinfo(icao).runways[rwy], final:final };
                  
 var RWY = me.destination.rwy_object; # shortcut
 me.touchObj = geo.Coord.new().set_latlon(RWY.lat, RWY.lon).apply_course_distance(RWY.heading, 250);
  me.touchObj.set_alt(geo.elevation(me.touchObj.lat(), me.touchObj.lon()));
  me.destination['elevation'] = me.touchObj.alt();
 var gateAlt = me.destination.elevation*M2FT+ me.destination.final *math.tan( me.destination.glidepath*D2R)*NM2M *M2FT;
 me.geoGate = geo.Coord.new().set_latlon(RWY.lat, RWY.lon)
	.apply_course_distance(RWY.heading + 180, me.destination.final*NM2M-RWY.threshold).set_alt(gateAlt*FT2M);
 me.geoLbase = geo.Coord.new().set_latlon(RWY.lat, RWY.lon)
			.apply_course_distance(RWY.heading + 180, 1+me.destination.final*NM2M-RWY.threshold)
			.apply_course_distance(RWY.heading - 90, 3*NM2M);
 me.geoRbase = geo.Coord.new().set_latlon(RWY.lat, RWY.lon)
			.apply_course_distance(RWY.heading + 180, 1+me.destination.final*NM2M-RWY.threshold)
			.apply_course_distance(RWY.heading + 90, 3*NM2M);
setprop("/gca/appgate-alt-fmt", sprintf("%i",math.round(gateAlt,100)));
setprop("/gca/rwy-in-use", spell(rwy, 0));
setprop("/gca/apt-name", airportinfo(icao).name);
},

setPositionNode: func(node) {
me.positionNode = node;
me.root = '/'~node.getName();
me.callsign = getprop("/sim/multiplay/callsign");
setprop("/gca/callsign-fmt", alpha(me.callsign));
me.phrase = 'prolog';
me.maxsecs = '5';
me.notify(join("this"));
},

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
 if(me.root=='/position') var hdg = '/orientation/heading-deg';
 else var hdg = string.replace(me.root, '/position', '/orientation')~'/true-heading-deg';
			
 me.aircraft_hdg = getprop(hdg) ; 
 me.aircraft_object.set_latlon(me.positionNode.getValue('latitude-deg'),
								me.positionNode.getValue('longitude-deg'),
								me.positionNode.getValue('altitude-ft')*FT2M);
#~ var gndElev = geo.elevation(latlon[0],latlon[1]);
#~ if(gndElev == nil) gndElev = 0; # tile not loaded yet.
setprop("/gca/altitude-agl-ft",  me.positionNode.getValue('altitude-ft') - me.touchObj.alt()*M2FT);
}, # updatePosition()

updateStage: func() {
	var rwy = me.destination.rwy_object;
	var (crse, dist) = courseAndDistance(me.aircraft_object, me.touchObj); # to rwy touchdown
	var (rwyCrse, rwyDist) = courseAndDistance(me.aircraft_object, rwy); # to rwy
	me.rwyDist = rwyDist;
	me.rwyCrse = rwyCrse;
	var (gateCrse, gateDist) = courseAndDistance(me.aircraft_object, me.geoGate); # to App gate
	var (lBaseCrse, lBaseDist) = courseAndDistance(me.aircraft_object, me.geoLbase); # to left base
	var (rBaseCrse, rBaseDist) = courseAndDistance(me.aircraft_object, me.geoRbase); # to right base
		
	# -  props
	var hand =(geo.normdeg(lBaseCrse-me.aircraft_hdg)<180)? "right " : "left ";
	setprop("/gca/lbase-hand", hand);
	hand =(geo.normdeg(rBaseCrse-me.aircraft_hdg)<180)? "right " : "left ";
	setprop("/gca/rbase-hand", hand);
	var aux = abs(gateDist *math.sin(D2R*(gateCrse-rwy.heading-180)));
	setprop("/gca/dist-to-rwy", sprintf("%.1f",me.rwyDist));
	setprop("/gca/gate-delta", geo.normdeg180(180+gateCrse-rwy.heading));
	setprop("/gca/rwy-delta", geo.normdeg180(180+rwyCrse-rwy.heading));
	setprop("/gca/dist-to-app-crse", aux);
	setprop("/gca/dist-to-app-crse-fmt", sprintf("%.1f",aux));
	var vector = aux>2 ? gateCrse : (rwy.heading-90)*math.sgn(geo.normdeg180(rwy.heading-rwyCrse)) ;
	vector = geo.normdeg(vector);
	hand =(geo.normdeg(vector-me.aircraft_hdg)<180)? "right " : "left ";
	setprop("/gca/turn-hand", hand);
	setprop("/gca/vector", spell(sprintf("%03.0f",vector),3));
	setprop("/gca/course-to-rwy", spell(sprintf("%03.0f",rwyCrse),3));
	setprop("/gca/course-to-lbase", spell(sprintf("%03.0f",lBaseCrse),3));
	setprop("/gca/course-to-rbase", spell(sprintf("%03.0f",rBaseCrse),3));
	if(abs(geo.normdeg180(lBaseCrse-me.aircraft_hdg))<4 
	    or abs(geo.normdeg180(rBaseCrse-me.aircraft_hdg))<4){
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
	var dif = (me.aircraft_object.alt() - me.geoGate.alt()) *M2FT;
	setprop("/gca/climb", dif>200 and condition ? "Descend " : dif<-200 and condition ? "Climb " : "");
	
	var difSlope = (me.aircraft_object.alt()-me.destination.elevation) 
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

#  invoked each new instruction
notify: func(instruction) {
	if(gcaCtrl==nil) return "bye";
	if(me.phrase != 'prolog') {
	me.tick = me.tick==nil ? 0: me.tick+1;
	var (crse, dist) = courseAndDistance(me.aircraft_object, me.destination.rwy_object); # to rwy
	var delta = me.destination.rwy_object.heading - me.rwyCrse;
	}
	if(me.phrase=="oncourse" 
		and dist*NM2M < 100 
		and (me.prev_phrase=="oncourse" or left(me.prev_phrase,6)=="slight")) {
	      instruction = join("bye");
	      me.phrase = "bye";
	      me.del();
	      }
	       	
	if(me.tick==me.maxsecs or me.phrase!=me.prev_phrase ){
	  setprop("/sim/sound/voices/atc", instruction);
	  me.tick = 0;
	  instruction = me.delayed(instruction);
	  me.write(instruction);
	  me.prev_phrase = me.phrase;
	  }
}, # receiver func

delayed: func(instruction){
 var appnd = "";
 if((left(me.phrase,4) =="left" or left(me.phrase,5) =="right") and string.match(me.prev_phrase,"to?bas*")){
  appnd = join("dont");
  settimer(func(){ setprop("/sim/sound/voices/atc", appnd)},12);
  }
 if(left(me.phrase,6)=="turn90") {
  appnd = join("glide");
  settimer(func(){ setprop("/sim/sound/voices/atc", appnd)},40);
  settimer(func(){ setprop("/gca/near", 1)},60);
 }

if((me.phrase =="oncourse" or left(me.phrase,6) =="slight") and me.rwyDist <=me.destination.final) {
  appnd = join("pathalt");
  settimer(func(){ setprop("/sim/sound/voices/atc", appnd);},1);
 }
 return instruction ~ appnd;
}, # delayed

write: func(str){
 if(me.window==nil) me.window = screen.window.new(nil,-50,10,8);
 me.window.write(str);
}, # write

openDialog: func() {
 fgcommand("pause");
 var defValues = {icao:me.destination.airport, rwy:me.destination.runway
			, safety_slope:0
			, channel:'/sim/sound/voices/atc', interval:1.00};
 var mask = {"Decision Height":'', 'Transmission channel':'' };
	configureGCA(demo, defValues, mask);
},

}; # end of Controller class


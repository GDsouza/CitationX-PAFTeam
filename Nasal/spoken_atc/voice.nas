# **  voice.nas.cod (save in $FG_ROOT/Nasal/spoken_atc)    **
# **                     v.: 1.1                           **
# ***********************************************************
# **             by Rodolfo Leibner (rleibner@gmail.com)   **
# **               Comments & enheacements are wellcome    **

#print("voice.nas loaded.");
 
	var speak = func(secs=0) {

		# ** XXXvoice functions returns msg=[type, voice]
		# **** DEARTURE voice  ***************************
		var DEPvoice = func() {
			if(prev== "takeoff clearance" and getprop("velocities/vertical-speed-fps") >15) {
				 var climb_desc =(getprop("/position/altitude-ft")<int(depalt))? "climb" : "descend" ;
				 return ["report leaving", phrase(climb_desc, arg)]; 
			} elsif(prev=="report leaving"){
				 return ["bye",phrase("bye", arg)]; 
			} else {return ["start",phrase("start", arg)];}
	}

	# **** APPROACH voice *****************************
	var APPvoice = func() {
		if(station=="tower") {
			return  ["app clearance", phrase("app", arg)] ;
		} else {
			return  ["app clearance", phrase("apptwr", arg)] ;}
	}  

	# **** TOWER voice  *****************************
	var TWRvoice = func() {
		var rwh=info.runways[best].heading;
		if(relpos=="onground" and prev=="land clearance") {
			if(freqs["GND"]==nil) {
				return ["exit rwy",  phrase("exitrwy", arg)] ;
			} else { 
			 	return ["exit rwy",  phrase("exrwygnd", arg)] ;} 
		}   
		if(relpos=="hold") {
			return ["takeoff clearance",  phrase("takeoff", arg)] ;
		}
		if(rwh-20<crse and rwh+20>crse) { 
			 if(dist>4) {
				  return ["direct final", phrase("makefinal", arg)] ;
			 } else { 
				 return ["land clearance", phrase("land", arg)] ;

			 }  
		} else {
			if(dist>4 and right(best,1)=="R") { 
				 return ["join pattern", phrase("rpttn", arg)] ;
			} else if(dist>4){
				 return ["join pattern", phrase("lpttn", arg)] ;
			} else {
				 return  ["land clearance", phrase("land", arg)] ;
			}
		return  ["unknown", phrase("unknown", arg)];
		}
	}
		# **** GROUND voice  *****************************
	var GNDvoice = func() {
		if(relpos=="onground" and dist<2) {   # Request for Taxi
			if(prev=="exit rwy") return  ["taxi clearance", phrase("taxiplat", arg)] ;
			if(station=="tower") {
				 return  ["taxi clearance", phrase("taxi", arg)] ;
			} else {
				 return  ["taxi clearance", phrase("taxitwr", arg)] ;
			}   
		} else {return  ["unknown", phrase("unknown", arg)];}
	}
# **** Redirection voice func. *****************************
	var REDvoice = func(type) {
     if(type=="TWR") {
       return ["redir",  phrase("gotwr", arg)];
     } elsif(type=="GND") { 
       return ["redir",  phrase("gognd", arg)];
     } else {
       return ["redir",  phrase("goapp", arg)];
     }  
	}

# *** ICAO exceptions ****************************************
  var ICAOexc = func(arg) {   
		var station_name = getprop("/instrumentation/comm/station-name"); 
		if (arg == "LFPB" and left(station_name,9) == "DE GAULLE") icao = "LFPG";
		return icao;
	}

# *** Main ****************************************

	# 1) Get properties
	var cs = getprop("/sim/multiplay/callsign");
	cs = string.replace(cs,"-","");
	var icao = getprop("/instrumentation/comm/airport-id");   
	ICAOexc(icao);
	var info = airportinfo(icao);
	var freqs = getfreqs(info);
	var prev =(getprop("/instrumentation/comm/atc/prev-apt-name")==info.name)? 
		    getprop("/instrumentation/comm/atc/prev-msg-type") : "" ;

	# 2) Check comm frequency
	var station = getprop("/instrumentation/comm/station-type"); 
	var tunned = getprop("/instrumentation/comm/frequencies/selected-mhz");

	if(getprop("/instrumentation/comm/volume")<0.1) {
		  gui.popupTip("Turn Comm1 on. Set volume",3);
		  return ;
	} else if(info.name==nil or getprop("/instrumentation/comm/signal-quality-norm")<0.01) { # if invalid freq or out of range
		  gui.popupTip("Check comm freq.!",3);
		  return ;}

	# 3) Get env. values
	var q_ =  getprop("/environment/metar/pressure-sea-level-inhg");
	var q =  pnt(sprintf("%.2f",q_));
	var qnh = sprintf("%d",q_/0.02953);
	var rws = info.runways;

	# 4) choose best rwy
	var best = "";
	var ang = 180.0;
	var dest_rwy = nil;
	if (getprop("/autopilot/route-manager/active")) {
		dest_rwy = getprop("/autopilot/route-manager/destination/runway");
	}

	foreach(var rw; keys(rws)){
		if (dest_rwy != nil and dest_rwy == rw) {
		  best = rw;
		  break;
		} else {
			if (rw == getprop("sim/atc/runway")) {
				best = rw;
				break;
			}	else {
				var a = abs(info.runways[rw].heading - getprop("/environment/metar/base-wind-dir-deg"));
				if(a<ang) {
					 ang = a;
					 best = rw;
				}
			}
		}
	}

	# 5) Check current position
	var headg =  getprop("/orientation/heading-magnetic-deg");
	var (crse, dist) = courseAndDistance(info.runways[best]);
	if(getprop("/position/altitude-agl-ft")>30) {
		 var relpos =(dist<10)? "onCTR" : "cruising";
	} else {
		 var relpos =(dist*NM2M>100)? "onground" : "hold";
	}
	var elev = info.elevation * M2FT ;
	var e = int(elev/1000);
	var a =(isEven(e))? 2500+e*1000 : 3500+e*1000 ;
	var depalt =(headg<180)? sprintf(a+1000) : sprintf(a) ;
		    
	# 6) Construct msg
	var msg = ["",""];

	var arg = {ac:alpha(cs), apt:info, qnh:qnh, q:q, depalt:depalt,
		         torwy:crse, headg:headg, rwy:spell(best, 0)
		          };

	if(getprop("/instrumentation/comm/atc/freq")==tunned) {
		 var voice = phrase("short", arg);
	} else {var voice = phrase("start", arg);}

	if(!(left(station,8)=="approach" or right(station,9)=="departure"
		    or getprop("/instrumentation/comm/atc/freq")==tunned)){
		         voice ~= phrase("qnh", arg) ;}

	# 7) Choose pertinent instruction
	if(relpos=="cruising"){ 
		if(left(station,8)=="approach" or (station=="tower" and freqs["APP"]==nil) ) {
		     msg = APPvoice();
		} else {
				msg = (freqs["APP"]==nil)? REDvoice("TWR") : REDvoice("APP");
		}
	} else if(relpos=="onCTR"){ 
     if(station=="tower") {
		   if(prev=="takeoff clearance" or prev=="report leaving") {
		         msg = DEPvoice();
		   } else {
		        msg = TWRvoice();
		   }
     } else if(station=="approach-departure") { 
		   if(prev=="takeoff clearance" or prev=="report leaving") {
		         msg = DEPvoice();
		   } else {
		        msg = REDvoice("TWR");
		   }
		 } else if(right(station,9)=="departure") { 
		     msg = DEPvoice();
		 } else if(left(station,8)=="approach") { 
		     msg = REDvoice("TWR");
		 } 	 
	} else if(relpos=="onground"){
		  if(station=="tower" and prev=="land clearance"){
		     msg = TWRvoice();
			} else if(station=="ground" or (station=="tower" and freqs["GND"]==nil)) {
		   		msg = GNDvoice();
		 } 
	} else if(relpos=="hold"){
		 if(station=="tower") {
		   msg = TWRvoice();
		 } else {
		   msg = REDvoice("TWR");
		 }
	} 
		 
	# 8) Speach instruction and save previous

	voice ~= msg[1];
	tip = string.replace(voice,"Runwaid","Runway");
	if(secs) {gui.popupTip(string.replace(tip,".",".\n"),secs);}
	#~ print(tip);

	setprop("/sim/sound/voices/atc", voice);
	setprop("/instrumentation/comm/atc/freq", tunned);
	setprop("/instrumentation/comm/atc/prev-msg-type", msg[0]);
	setprop("/instrumentation/comm/atc/prev-apt-name", info.name);
	};


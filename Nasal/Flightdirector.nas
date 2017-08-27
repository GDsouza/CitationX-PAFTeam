##########################################
# Flight Director/Autopilot controller.
# Syd Adams
# C. Le Moigne - 2015 - rev 2017
##########################################

###  Initialization ###
var Lateral = "autopilot/locks/heading";
var Lateral_arm = "autopilot/locks/heading-arm";
var Vertical = "autopilot/locks/altitude";
var Vertical_arm = "autopilot/locks/altitude-arm";
var AP = "autopilot/locks/AP-status";
var NAVprop="autopilot/settings/nav-source";
var NAVSRC= getprop(NAVprop);
var AutoCoord="controls/flight/auto-coordination";
var count=0;
var Coord = 0;
var minimums=props.globals.getNode("autopilot/settings/minimums");
var rd_speed = props.globals.initNode("instrumentation/airspeed-indicator/round-speed-kt",0,"DOUBLE");
var alt = "instrumentation/altimeter/indicated-altitude-ft";
var v_speed = "autopilot/internal/vert-speed-fpm";
var tg_spd_mc = "autopilot/settings/target-speed-mach";
var ind_mc = "instrumentation/airspeed-indicator/indicated-mach";
var tg_spd_kt = "autopilot/settings/target-speed-kt";
var ind_kt = "instrumentation/airspeed-indicator/indicated-speed-kt";
var app_wp = "autopilot/route-manager/route/wp[";
props.globals.initNode("autopilot/settings/fms",0,"BOOL");
props.globals.initNode("autopilot/locks/alm-tod",0,"BOOL");
props.globals.initNode("autopilot/locks/alm-wp",0,"BOOL");
props.globals.initNode("autopilot/internal/ap-crs",0,"DOUBLE");
props.globals.initNode("autopilot/internal/cdi",0,"DOUBLE");
setprop("instrumentation/nav/radials/sel-deg-corr",getprop("instrumentation/nav/radials/selected-deg")-4);
setprop("instrumentation/nav[1]/radials/sel-deg-corr",getprop("instrumentation/nav[1]/radials/selected-deg")-4);
var alm_wp = props.globals.getNode("autopilot/locks/alm-wp",1);
var active = props.globals.getNode("autopilot/route-manager/active",1);
var btn = nil;
var wp = 0;
var wp_curr = 0;
var flag_wp = 0;
var dist_wp = 10;
var sgnl = nil;
var ind = nil;
var nb = nil;
var dst = nil;
var fp = nil;
var dist_rem = nil;
var tot_dist = nil;
var wp_dist = nil;
var geocoord = nil;
var refCourse = nil;
var courseCoord = nil;
var CourseError = nil;
var heading = nil;
var change_wp = nil;
var crs_offset = nil;
var crs_set = nil;
var targetCourse = nil;
var gspd = nil;
var diff_crs = nil;
var courseDist = nil;
var wpCoord = nil;
var ind_speed = nil;
var nav_dst= nil;
var Varm = nil;
var myalt = nil;
var asel = nil;
var alterr = nil;
var gs_err = nil;
var gs_dst = nil;
var ttw = nil;
var min_et = nil;
var hr_et = nil;
var tmphr = nil;
var tmpmin = nil;
var min_mode = nil;
var agl_alt = nil;
var ind_alt = nil;
var rlimit = nil;
var plimit = nil;
var Lmode = nil;
var LAmode = nil;
var Vmode = nil;
var VAmode = nil;
var curr_bearing = nil ;
var next_bearing = nil;

### LISTENERS ###

setlistener(minimums, func(mn) {
		min_mode = getprop("autopilot/settings/minimums-mode");
		if (min_mode == "RA") {setprop("instrumentation/pfd/minimums-radio",mn.getValue())}
		if (min_mode == "BA") {setprop("instrumentation/pfd/minimums-baro",mn.getValue())}
},0,0);

setlistener(NAVprop, func(Nv) {
    NAVSRC=Nv.getValue();
#		if (left(NAVSRC,3) == "FMS") set_nav_mode();
},0,0);

setlistener("instrumentation/nav/radials/selected-deg",func(Sd) {
		setprop("instrumentation/nav/radials/sel-deg-corr",Sd.getValue()-4);
},0,0);

setlistener("instrumentation/nav[1]/radials/selected-deg",func(Sd) {
		setprop("instrumentation/nav[1]/radials/sel-deg-corr",Sd.getValue()-4);
},0,0);


### AP /FD BUTTONS ###

var FD_set_mode = func(btn){
    Lmode=getprop(Lateral);
    LAmode=getprop(Lateral_arm);
    Vmode=getprop(Vertical);
    VAmode=getprop(Vertical_arm);
		min_mode = getprop("autopilot/settings/minimums-mode");
		agl_alt = getprop("position/altitude-agl-ft");
		ind_alt = getprop(alt);
		asel = getprop("autopilot/settings/asel");

		if(btn=="ap"){
			Coord = getprop(AutoCoord);
			if(getprop(AP)!="AP"){
				setprop(Lateral_arm,"");
				setprop(Vertical_arm,"");
				setprop("autopilot/locks/disengage",0);
        if(Vmode=="PTCH")set_pitch();
        if(Lmode=="ROLL")set_roll(); 
				if (min_mode = "RA") {
					if(agl_alt > minimums.getValue()) {
						setprop(AP,"AP");
						setprop(AutoCoord,0);
					}
				}
				if (min_mode = "BA") {
					if(ind_alt > minimums.getValue()){
						setprop(AP,"AP");
						setprop(AutoCoord,0);
					}					
				}
			}	else {kill_Ap("");setprop("autopilot/locks/disengage",1)}

    }elsif(btn=="hdg") {
			if(Lmode!="HDG") {setprop(Lateral,"HDG")}
			else {
				set_roll();
      	setprop(Lateral_arm,"");setprop(Vertical_arm,"");
			}

    }elsif(btn=="alt"){
			setprop(Lateral_arm,"");
			setprop(Vertical_arm,"");
			if(Vmode!="ALT"){
        setprop(Vertical,"ALT");
      } else {set_pitch()}

    }elsif(btn=="flc"){
			var flcmode = "FLC";
			var asel = "ASEL";
			if(left(NAVSRC,3)=="FMS"){flcmode="VFLC";asel = "VASEL";}
			if(Vmode!=flcmode){
				var mc =getprop(ind_mc);
				var kt=int(getprop(ind_kt));
				if(!getprop("autopilot/settings/changeover")){
					if(kt > 80 and kt <340){
						setprop(Vertical,flcmode);
						setprop(Vertical_arm,asel);
						setprop(tg_spd_kt,kt);
						setprop(tg_spd_mc,mc);
          }
				}else{
					if(mc > 0.40 and mc <0.92){
						setprop(Vertical,flcmode);
						setprop(Vertical_arm,asel);
						setprop(tg_spd_kt,kt);
						setprop(tg_spd_mc,mc);
					}
        }
			} else {set_pitch()}

		}elsif(btn=="nav"){
			set_nav_mode();
			setprop("autopilot/settings/low-bank",0);

		}elsif(btn=="vnav"){
			if(Vmode!="VALT" and asel > 0){
				if(left(NAVSRC,3)=="FMS" and active.getValue()){
					setprop(Vertical,"VALT");
					setprop(Lateral,"LNAV");
				} else {set_pitch()}
      }else if (Vmode!="ALT"){set_pitch()}

    }elsif(btn=="app"){
			if (Vmode!="GS") {
				setprop(Lateral_arm,"");
				setprop(Vertical_arm,"");
				set_apr();
				setprop("autopilot/settings/low-bank",0);
			} else {
				setprop(Vertical,"ALT");
				setprop(Vertical_arm,"");
			}
				
    }elsif(btn=="vs"){
			setprop(Lateral_arm,"");
			setprop(Vertical_arm,"");
			if(Vmode!="VS"){
				var tgt_vs = (int(getprop(v_speed) * 0.01)) * 100;
				setprop(Vertical,"VS");setprop("autopilot/settings/vertical-speed-fpm",tgt_vs);
			} else {set_pitch()}

    }elsif(btn=="stby"){
			setprop(Lateral_arm,"");
			setprop(Vertical_arm,"");
			set_pitch();
			set_roll();
			setprop("autopilot/settings/low-bank",0);

    }elsif(btn=="bank"){
			var Bnk="autopilot/settings/low-bank";
			if(Lmode=="HDG")setprop(Bnk,1-getprop(Bnk));

    }elsif(btn=="co"){
			var Co= 1- getprop("autopilot/settings/changeover");
			if(Vmode!="FLC") Co=0;
			setprop("autopilot/settings/changeover",Co);
    }
}

###  FMS/NAV BUTTONS  ###

var nav_src_set=func(src){
    setprop(Lateral_arm,"");
		setprop(Vertical_arm,"");
    if(src=="fms"){
			setprop("autopilot/settings/fms",1);
			if (active.getValue()) {
#			if(getprop("autopilot/route-manager/route/num")>0) {
        if (NAVSRC!="FMS1")setprop(NAVprop,"FMS1")else setprop(NAVprop,"FMS2");
				btn = "nav";
				FD_set_mode(btn);
			}
    }else{
			setprop("autopilot/settings/fms",0);
			if (getprop(Vertical) == "VALT") {setprop(Vertical,"PTCH")}
      if (NAVSRC!="NAV1")setprop(NAVprop,"NAV1") else setprop(NAVprop,"NAV2");
			if (getprop(AP)=="AP") {btn = "nav";FD_set_mode(btn)}
    }
}

### ARM VALID NAV MODE ####

var set_nav_mode=func{
    setprop(Lateral_arm,"");
		setprop(Vertical_arm,"");
    if(NAVSRC=="NAV1"){
			if(getprop("instrumentation/nav/data-is-valid")){
				if(getprop("instrumentation/nav/nav-loc")) {
					setprop(Lateral_arm,"LOC");
				} else {
					setprop(Lateral_arm,"VOR");
          setprop(Lateral,"HDG");
        }
			}
    } else if(NAVSRC=="NAV2"){
       if(getprop("instrumentation/nav[1]/data-is-valid")){
          if(getprop("instrumentation/nav[1]/nav-loc")) {
						setprop(Lateral_arm,"LOC");
					} else { 
						setprop(Lateral_arm,"VOR");
            setprop(Lateral,"HDG");
					}
        }
    } else if(left(NAVSRC,3)=="FMS"){
        if (active.getValue()) {
					btn = "vnav";
					FD_set_mode(btn);
		    }
		}
}

###  PITCH WHEEL ACTIONS ###

var pitch_wheel=func(dir) {
    var Vmode=getprop(Vertical);
    var CO = getprop("autopilot/settings/changeover");
		var SP = getprop("autopilot/locks/speed");
    var amt=0;
    if(Vmode=="VS"){
        amt = int(getprop("autopilot/settings/vertical-speed-fpm")) + (dir* 100);
        amt = (amt < -8000 ? -8000 : amt > 6000 ? 6000 : amt);
        setprop("autopilot/settings/vertical-speed-fpm",amt);
    } else if(Vmode=="FLC" or Vmode=="VFLC"){
        if(!CO){
					if (getprop("autopilot/locks/alt-mach")) {
	          amt=getprop(tg_spd_mc) + (dir*0.01);
            amt = (amt < 0.40 ? 0.40 : amt > 0.91 ? 0.91 : amt);
            setprop(tg_spd_mc,amt);
					}	else {
			        amt=getprop(tg_spd_kt) + dir;
		          amt = (amt < 80 ? 80 : amt > 340 ? 340 : amt);
		          setprop(tg_spd_kt,amt);
	        }
				}
    } else if(Vmode=="PTCH" and !SP){
        amt=getprop("autopilot/settings/target-pitch-deg") + (dir*0.1);
        amt = (amt < -20 ? -20 : amt > 20 ? 20 : amt);
        setprop("autopilot/settings/target-pitch-deg",amt);
    } else if (SP and left(NAVSRC,3)!="FMS") {
				if (getprop("autopilot/locks/alt-mach")) {
          amt=getprop(tg_spd_mc) + (dir*0.01);
          amt = (amt < 0.40 ? 0.40 : amt > 0.91 ? 0.91 : amt);
          setprop(tg_spd_mc,amt);
				}	else {
		        amt=getprop(tg_spd_kt) + dir*5;
	          amt = (amt < 80 ? 80 : amt > 340 ? 340 : amt);
	          setprop(tg_spd_kt,amt);
        }
		}								
}

### FD INTERNAL ACTIONS  ###

var set_pitch = func{
    setprop(Vertical,"PTCH");
		setprop("autopilot/settings/target-pitch-deg",getprop("orientation/pitch-deg"));
}

var set_roll = func{
    setprop(Lateral,"ROLL");
		setprop("autopilot/settings/target-roll-deg",0.0);
}

var set_alt = func {
		var n=(getprop("instrumentation/altimeter/mode-c-alt-ft"))*0.01;
		var m=int(n/10);
		var p=(n/10)-m;
		if (p>0 and p<0.5) {p=0.5;m=m+p}
		else if(p>=0.5 and p<1) {m=m+1}
		else {p=0}
		setprop("autopilot/settings/asel",m*10);
}

var monitor_L_armed = func{
    if(getprop(Lateral_arm)!=""){
      if(getprop("autopilot/internal/in-range")){
				var cd = getprop("autopilot/internal/course-deflection");
        if(cd < 10 and cd > -10){
          setprop(Lateral,getprop(Lateral_arm));
          setprop(Lateral_arm,"");
        }
      }
    }
}

var monitor_V_armed = func{
    Varm = getprop(Vertical_arm);
    myalt = getprop(alt);
    asel = getprop("autopilot/settings/asel")*100;
    alterr = myalt-asel;
    if(Varm=="ASEL"){
      if(alterr >-250 and alterr <250){
        setprop(Vertical,"ALT");
        setprop(Vertical_arm,"");
      }
    }else if(Varm=="VASEL"){
      if(alterr >-250 and alterr <250 and asel > 0){
        setprop(Vertical,"VALT");
        setprop("instrumentation/gps/wp/wp[1]/altitude-ft",asel);
        setprop(Vertical_arm,"");
      }
    }else if(Varm=="GS"){
      if(getprop(Lateral)=="LOC"){
        if(getprop("autopilot/internal/gs-in-range")){
          gs_err=getprop("autopilot/internal/gs-deflection");
          gs_dst=getprop("autopilot/internal/nav-distance");
          if(gs_dst <= 15.0){ ### old = 7.0 ###
            if(gs_err >-0.25 and gs_err < 0.25){
              setprop(Vertical,"GS");
              setprop(Vertical_arm,"");
						}
          }
        } 
			}
    }
}

var monitor_AP_errors= func{
		if (getprop(AP)!="AP") {return}
		min_mode = getprop("autopilot/settings/minimums-mode");
		agl_alt = getprop("position/altitude-agl-ft");
		ind_alt = getprop(alt);
		if (min_mode == "RA") {if(agl_alt<minimums.getValue())kill_Ap("")};
		if (min_mode == "BA") {if(ind_alt<minimums.getValue())kill_Ap("")};
    rlimit=getprop("orientation/roll-deg");
    if(rlimit > 45 or rlimit< -45)kill_Ap("AP-FAIL");
    plimit=getprop("orientation/pitch-deg");
    if(plimit > 30 or plimit< -30)kill_Ap("AP-FAIL");
}

var kill_Ap = func(msg){
    setprop(AP,msg);
    setprop(AutoCoord,Coord);
		setprop("autopilot/locks/disengage",1);
		setprop("autopilot/locks/speed",0);
}

### Elapsed time ###

var get_ETE = func{
    ttw = "--:--";
    min_et = 0;
    hr_et = 0;
    if(NAVSRC == "NAV1"){et_ind = 0}
    if(NAVSRC == "NAV2"){et_ind = 1}
    if(left(NAVSRC,3) == "FMS"){
			min_et = getprop("autopilot/route-manager/ete");
		}	else {
      setprop("instrumentation/dme/frequencies/source","instrumentation/nav["~et_ind~"]/frequencies/selected-mhz");
      min_et = int(getprop("instrumentation/dme/indicated-time-min"));
		}
    if(min_et>60){
      tmphr = (min_et*0.016666);
      hr_et = int(tmphr);
      tmpmin = (tmphr-hr_et)*100;
      min_et = int(tmpmin);
    }
    ttw=sprintf("ETE %i:%02i",hr_et,min_et);
    setprop("autopilot/internal/nav-ttw",ttw);
}

### Speed Round ###

var speed_round = func {
	ind_speed = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
	rd_speed.setValue(math.round(ind_speed));
}

var alt_mach = func {
	if (getprop(alt) >= 30650) {
		setprop("autopilot/locks/alt-mach",1);
#			setprop(tg_spd_kt,getprop(ind_kt));
	}	else {
		setprop("autopilot/locks/alt-mach",0);
#			setprop(tg_spd_mc,getprop(ind_mc));
	}
}

### Approach ###

var set_apr = func{
		var ind = 0;
    if(NAVSRC == "NAV1" or NAVSRC == "FMS1"){ind = 0}
		if(NAVSRC == "NAV2" or NAVSRC == "FMS2"){ind = 1}
		if (!getprop("instrumentation/nav["~ind~"]/gs-in-range")) {
			setprop(Lateral_arm,"");
			setprop(Vertical_arm,"");
			setprop(Lateral,"HDG");
			setprop(Vertical,"PTCH"); 
			setprop("autopilot/settings/target-pitch-deg",3.0);
		} else if(getprop("instrumentation/nav["~ind~"]/nav-loc") and getprop("instrumentation/nav["~ind~"]/has-gs")){
			setprop(Lateral_arm,"LOC");
			setprop(Vertical_arm,"GS");
			setprop(Lateral,"HDG");
			setprop(Vertical,"GS"); 
		}		
}

### UPDATE ###

var update_nav = func {
    sgnl = "- - -";
		ind = 0;
		nb = "";
    if(left(NAVSRC,3) == "NAV"){
			if (NAVSRC == "NAV1") {ind = 0;nb = "1"}
			if (NAVSRC == "NAV2") {ind = 1;nb = "2"}
      setprop("autopilot/internal/in-range",getprop("instrumentation/nav["~ind~"]/in-range"));
      setprop("autopilot/internal/gs-in-range",getprop("instrumentation/nav["~ind~"]/gs-in-range"));
      dst = getprop("instrumentation/nav["~ind~"]/nav-distance") or 0;
      dst*=0.000539;
      setprop("autopilot/internal/nav-distance",dst);
      setprop("autopilot/internal/nav-id",getprop("instrumentation/nav["~ind~"]/nav-id"));
      if(getprop("instrumentation/nav["~ind~"]/data-is-valid"))sgnl="VOR"~nb;
      if(getprop("instrumentation/nav["~ind~"]/nav-loc"))sgnl="LOC"~nb;
      if(getprop("instrumentation/nav["~ind~"]/has-gs"))sgnl="ILS"~nb;
      setprop("autopilot/internal/nav-type",sgnl);
			crs_set = getprop("instrumentation/nav["~ind~"]/radials/sel-deg-corr");
#			crs_set = getprop("instrumentation/nav["~ind~"]/radials/selected-deg");
			crs_offset = crs_set - getprop("orientation/heading-magnetic-deg");
			if(crs_offset>180)crs_offset-=360;
			if(crs_offset<-180)crs_offset+=360;
	    setprop("autopilot/internal/course-offset",crs_offset);
	    crs_offset+=getprop("autopilot/internal/cdi");
			if(crs_offset>180)crs_offset-=360;
			if(crs_offset<-180)crs_offset+=360;
			setprop("autopilot/internal/ap-crs",crs_offset);
			setprop("autopilot/internal/selected-crs",math.round(crs_set));
      setprop("autopilot/internal/to-flag",getprop("instrumentation/nav["~ind~"]/to-flag"));
      setprop("autopilot/internal/from-flag",getprop("instrumentation/nav["~ind~"]/from-flag"));

    } else if(left(NAVSRC,3) == "FMS"){
			if (NAVSRC == "FMS1") {ind = 0} else {ind = 1}
      setprop("autopilot/internal/nav-type","FMS"~(ind+1));
      setprop("autopilot/internal/in-range",1);
      setprop("autopilot/internal/gs-in-range",0);
      setprop("autopilot/internal/nav-distance",getprop("instrumentation/gps/wp/wp[1]/distance-nm"));
      setprop("autopilot/internal/nav-id",getprop("instrumentation/gps/wp/wp[1]/ID"));
      setprop("autopilot/internal/to-flag",getprop("instrumentation/gps/wp/wp[1]/to-flag"));
      setprop("autopilot/internal/from-flag",getprop("instrumentation/gps/wp/wp[1]/from-flag"));

			#### Turn Anticipation ###
			fp = flightplan();
			dist_rem = getprop("autopilot/route-manager/distance-remaining-nm");
			tot_dist = getprop("autopilot/route-manager/total-distance");
			wp_dist = getprop("instrumentation/gps/wp/wp[1]/distance-nm");
			geocoord = geo.aircraft_position();
			refCourse = fp.pathGeod(fp.indexOfWP(fp.destination_runway), -dist_rem);
      courseCoord = geo.Coord.new().set_latlon(refCourse.lat, refCourse.lon);
      CourseError = (geocoord.distance_to(courseCoord) / 1852) + 1;
			heading = getprop("orientation/heading-magnetic-deg");
#			crs_set = getprop("instrumentation/gps/wp/leg-mag-course-deg");
			crs_set = getprop("instrumentation/gps/wp/wp[1]/bearing-mag-deg");
      change_wp = abs(crs_set - heading);
      if(change_wp > 180) change_wp = (360 - change_wp);
      CourseError += (change_wp / 20);
      targetCourse = fp.pathGeod(fp.indexOfWP(fp.destination_runway), (-getprop("autopilot/route-manager/distance-remaining-nm") + CourseError));
      courseCoord = geo.Coord.new().set_latlon(targetCourse.lat, targetCourse.lon);
      CourseError = geocoord.course_to(courseCoord) - heading;
      if(CourseError < -180) CourseError += 360;
      else if(CourseError > 180) CourseError -= 360;
			crs_set = geocoord.course_to(courseCoord);
			if (fp.current < 1) { # On ground and takeoff
				crs_offset= crs_set - getprop("orientation/heading-magnetic-deg");
				if(crs_offset>180)crs_offset-=360;
				if(crs_offset<-180)crs_offset+=360;
			} else { # in flight
				crs_offset = CourseError;
				gspd = getprop("velocities/groundspeed-kt")/8000; # old 10000
				curr_bearing = fp.getWP(fp.current).leg_bearing;
				if (fp.current < fp.getPlanSize()-1) {
					next_bearing = fp.getWP(fp.current+1).leg_bearing;
				} else {next_bearing = curr_bearing}
#				if (curr_bearing > 180) {curr_bearing -= 180}
#				if (next_bearing > 180) {next_bearing -= 180}
				if (abs(curr_bearing - next_bearing) > 150) {diff_crs = 0}
				else {diff_crs = abs(curr_bearing - next_bearing)*gspd}
				if (wp_dist <= diff_crs) {
					setprop("autopilot/route-manager/current-wp",fp.current +1);
				}
			}
			setprop("autopilot/internal/course-offset",crs_offset);
			setprop("autopilot/internal/selected-crs",int(crs_set));
			setprop("autopilot/internal/ap-crs",getprop("autopilot/internal/course-offset"));
			setprop("autopilot/internal/cdi",0);

			if (fp.current > 0) {
				if (!flag_wp) {
					wp_curr = fp.current;
					flag_wp = 1;
				}
				### Maintain alarm wp ###
				wpCoord = geo.Coord.new().set_latlon(fp.getWP(wp_curr).wp_lat, fp.getWP(wp_curr).wp_lon);
				courseDist = geocoord.distance_to(wpCoord)/1852;
				if (courseDist < dist_wp) {
					dist_wp = courseDist;
				} else {
					alm_wp.setValue(1);
					if (courseDist > dist_wp +0.2) {
						alm_wp.setValue(0);
						dist_wp = courseDist;
						flag_wp = 0;
					}
				}
			}

    } else if (NAVSRC == "") {setprop("autopilot/internal/nav-type","")}
}


###  Main loop ###

var fd_stl = setlistener("sim/signals/fdm-initialized", func {
   print("Flight Director ... Ok");
	settimer(update_fd,6);
	removelistener(fd_stl);
},0,0);

var update_fd = func {
    update_nav();
		speed_round();
		alt_mach();
		setprop("autopilot/settings/altitude-setting-ft",getprop("autopilot/settings/asel")*100);
		setprop("instrumentation/altimeter/mode-s-alt-ft",getprop("instrumentation/altimeter/mode-c-alt-ft"));
    if(count==0)monitor_AP_errors();
    if(count==1)monitor_L_armed();
    if(count==2)monitor_V_armed();
    if(count==3)get_ETE();
    count+=1;
    if(count>3)count=0;
    settimer(update_fd, 0);
}

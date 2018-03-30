##########################################
# Flight Director/Autopilot controller.
# Syd Adams
# C. Le Moigne - 2015 - rev 2017
##########################################

###  Initialization ###
props.globals.initNode("instrumentation/airspeed-indicator/round-speed-kt",0,"DOUBLE");
props.globals.initNode("autopilot/settings/fms",0,"BOOL");
props.globals.initNode("autopilot/locks/alm-tod",0,"BOOL");
props.globals.initNode("autopilot/locks/alm-wp",0,"BOOL");
var alt = "instrumentation/altimeter/indicated-altitude-ft";
var AP = "autopilot/locks/AP-status";
var AutoCoord = "controls/flight/auto-coordination";
var gs_in_range = "autopilot/internal/gs-in-range";
var ind_kt = "instrumentation/airspeed-indicator/indicated-speed-kt";
var ind_mc = "instrumentation/airspeed-indicator/indicated-mach";
var Lateral = "autopilot/locks/heading";
var Lateral_arm = "autopilot/locks/heading-arm";
var minimums = "autopilot/settings/minimums";
var NAVprop="autopilot/settings/nav-source";
var rd_speed = "instrumentation/airspeed-indicator/round-speed-kt";
var tg_spd_kt = "autopilot/settings/target-speed-kt";
var tg_spd_mc = "autopilot/settings/target-speed-mc";
var Vertical = "autopilot/locks/altitude";
var Vertical_arm = "autopilot/locks/altitude-arm";
var v_speed = "autopilot/internal/vert-speed-fpm";
setprop("instrumentation/nav/radials/sel-deg-corr",getprop("instrumentation/nav/radials/selected-deg")-4);
setprop("instrumentation/nav[1]/radials/sel-deg-corr",getprop("instrumentation/nav[1]/radials/selected-deg")-4);
var alm_wp = "autopilot/locks/alm-wp";
var Fms = "autopilot/settings/fms";
var cdi = "autopilot/internal/course-deflection";
var agl_alt = nil;
var alterr = nil;
var asel = nil;
var count=0;
var Coord = 0;
var courseCoord = nil;
var courseDist = nil;
var CourseError = nil;
var crs_offset = nil;
var crs_set = nil;
var curr_bearing = nil ;
var diff_crs = nil;
var dist_rem = nil;
var dist_wp = 10;
var dst = nil;
var flag_wp = 0;
var fp = nil;
var geocoord = nil;
var gs_err = nil;
var gspd = nil;
var heading = nil;
var hr_et = nil;
var in_range = 0;
var ind = nil;
var ind_alt = nil;
var ind_speed = nil;
var Lmode = nil;
var min_et = nil;
var min_mode = nil;
var next_bearing = nil;
var plimit = nil;
var refCourse = nil;
var rlimit = nil;
var sgnl = nil;
var targetCourse = nil;
var tmphr = nil;
var tmpmin = nil;
var ttw = nil;
var Varm = nil;
var Vmode = nil;
var wp = 0;
var wpCoord = nil;
var wp_curr = 0;
var wp_dist = nil;
var mem_nav = getprop(Lateral);
var mem_nav_arm = getprop(Lateral_arm);
var mem_fms_l = getprop(Lateral);
var mem_fms_v = getprop(Vertical);
var NAVSRC = getprop(NAVprop);

### LISTENERS ###

setlistener(minimums, func(mn) {
		min_mode = getprop("autopilot/settings/minimums-mode");
		if (min_mode == "RA") {setprop("instrumentation/pfd/minimums-radio",mn.getValue())}
		if (min_mode == "BA") {setprop("instrumentation/pfd/minimums-baro",mn.getValue())}
},0,0);

setlistener(NAVprop, func(Nv) {
    NAVSRC = Nv.getValue();
},0,0);

setlistener("instrumentation/nav/radials/selected-deg",func(Sd) {
		setprop("instrumentation/nav/radials/sel-deg-corr",Sd.getValue()-4);
},0,0);

setlistener("instrumentation/nav[1]/radials/selected-deg",func(Sd) {
		setprop("instrumentation/nav[1]/radials/sel-deg-corr",Sd.getValue()-4);
},0,0);

setlistener("autopilot/locks/heading",func(hd) {
    if (hd.getValue() != "VOR") setprop("autopilot/locks/back-course",0);
},0,0);

### AP /FD BUTTONS ###

var FD_set_mode = func(btn){
    Lmode=getprop(Lateral);
    Vmode=getprop(Vertical);
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
					if(agl_alt > getprop(minimums)) {
						setprop(AP,"AP");
						setprop(AutoCoord,0);
					}
				}
				if (min_mode = "BA") {
					if(ind_alt > getprop(minimums)){
						setprop(AP,"AP");
						setprop(AutoCoord,0);
					}					
				}
			}	else {kill_Ap("");setprop("autopilot/locks/disengage",1)}

    }elsif(btn=="hdg") {
			if(Lmode!="HDG") {setprop(Lateral,"HDG")}
			else {
        set_roll();
        setprop(Lateral_arm,"");
        setprop(Vertical_arm,"");
      }

    }elsif(btn=="alt"){
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
      if (left(NAVSRC,3) == "NAV") {
        mem_nav = getprop(Lateral);      
        mem_nav_arm = getprop(Lateral_arm);      
      }

		}elsif(btn=="vnav"){
			if(Vmode!="VALT" and asel > 0 and getprop("autopilot/route-manager/active")){
				if(left(NAVSRC,3)=="FMS"){
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
				setprop(Vertical,"VS");
				var tgt_vs = (int(getprop(v_speed) * 0.01)) * 100;
        setprop("autopilot/settings/vertical-speed-fpm",tgt_vs);
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
		setprop(Vertical_arm,"");
    if(src=="fms"){
			if(getprop("autopilot/route-manager/active")) {
        if (!getprop(Fms)) {
          setprop(Lateral,mem_fms_l);     
          setprop(Lateral_arm,"");
          setprop(Vertical,mem_fms_v);
    			setprop(Fms,1);
        } else {
          mem_fms_l = getprop(Lateral);
          mem_fms_v = getprop(Vertical);
        }
        if (NAVSRC!="FMS1")setprop(NAVprop,"FMS1") else setprop(NAVprop,"FMS2");
			}
    }else{
      if (getprop(Fms)) {
        mem_fms_l = getprop(Lateral);
        mem_fms_v = getprop(Vertical);
        setprop(Lateral,mem_nav);
        setprop(Lateral_arm,mem_nav_arm);      
        setprop(Fms,0);
      } else {
        mem_nav = getprop(Lateral);
        mem_nav_arm = getprop(Lateral_arm);
      }
			if (getprop(Vertical) == "VALT") {setprop(Vertical,"PTCH")}
      if (NAVSRC!="NAV1")setprop(NAVprop,"NAV1") else setprop(NAVprop,"NAV2");
    }
}

### ARM VALID NAV MODE ####

var set_nav_mode=func {
    setprop(Lateral_arm,"");
		setprop(Vertical_arm,"");
    var ind_nav = nil;
    if(left(NAVSRC,3)=="NAV"){
      if(NAVSRC=="NAV1") ind_nav = 0;
      if(NAVSRC=="NAV2") ind_nav = 1;
			  if(getprop("instrumentation/nav["~ind_nav~"]/data-is-valid")){
				  if(getprop("instrumentation/nav["~ind_nav~"]/nav-loc")) {
					  setprop(Lateral_arm,"LOC");
				  } else {
					  setprop(Lateral_arm,"VOR");
            setprop(Lateral,"HDG");
          }
			  }
    } 
    if(left(NAVSRC,3)=="FMS"){
      if (getprop("autopilot/route-manager/active")) {
        setprop(Lateral,"LNAV");
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
            amt = (amt < 0.40 ? 0.40 : amt > 0.92 ? 0.92 : amt);
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
          amt = (amt < 0.40 ? 0.40 : amt > 0.92 ? 0.92 : amt);
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
      if(in_range){
        if(getprop(cdi) < 40 and getprop(cdi) > -40){
          setprop(Lateral,getprop(Lateral_arm));
          setprop(Lateral_arm,"");
        }
      }
    }
}

var monitor_V_armed = func{
    Varm = getprop(Vertical_arm);
    asel = getprop("autopilot/settings/asel")*100;
    alterr = getprop(alt)-asel;
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
        if(getprop(gs_in_range)){
          gs_err=getprop("autopilot/internal/gs-deflection");
          if(gs_err >-0.25 and gs_err < 0.25){
            setprop(Vertical,"GS");
            setprop(Vertical_arm,"");
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
		if (min_mode == "RA") {if(agl_alt<getprop(minimums))kill_Ap("")};
		if (min_mode == "BA") {if(ind_alt<getprop(minimums))kill_Ap("")};
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
	setprop(rd_speed,math.round(ind_speed));
}

var alt_mach = func {
	if (getprop(alt) >= 30650) {
		setprop("autopilot/locks/alt-mach",1);
	}	else {
		setprop("autopilot/locks/alt-mach",0);
	}
}

### Approach ###

var set_apr = func{
		var ind_apr = 0;
    if(NAVSRC == "NAV1" or NAVSRC == "FMS1"){ind_apr = 0}
		if(NAVSRC == "NAV2" or NAVSRC == "FMS2"){ind_apr = 1}
		if (!getprop("instrumentation/nav["~ind_apr~"]/gs-in-range")) {
			setprop(Lateral_arm,"");
			setprop(Vertical_arm,"");
			setprop(Lateral,"HDG");
			setprop(Vertical,"PTCH"); 
			setprop("autopilot/settings/target-pitch-deg",3.0);
		} else if(getprop("instrumentation/nav["~ind_apr~"]/nav-loc") and getprop("instrumentation/nav["~ind_apr~"]/has-gs")){
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
    if(left(NAVSRC,3) == "NAV"){
      ind = (NAVSRC == "NAV1" ? 0 : 1);
        if(getprop("instrumentation/nav["~ind~"]/data-is-valid"))sgnl="VOR"~(ind+1);
        in_range = getprop("instrumentation/nav["~ind~"]/in-range");
        setprop(gs_in_range,getprop("instrumentation/nav["~ind~"]/gs-in-range"));
        dst = getprop("instrumentation/nav["~ind~"]/nav-distance") or 0;
        dst*=0.000539;
        setprop("autopilot/internal/nav-distance",dst);
        setprop("autopilot/internal/nav-id",getprop("instrumentation/nav["~ind~"]/nav-id"));
        if(getprop("instrumentation/nav["~ind~"]/nav-loc"))sgnl="LOC"~(ind+1);
        if(getprop("instrumentation/nav["~ind~"]/has-gs"))sgnl="ILS"~(ind+1);
        setprop("autopilot/internal/nav-type",sgnl);
				crs_set = getprop("instrumentation/nav["~ind~"]/radials/sel-deg-corr");
				setprop("autopilot/internal/selected-crs",math.round(crs_set));
        setprop("autopilot/internal/to-flag",getprop("instrumentation/nav["~ind~"]/to-flag"));
        setprop("autopilot/internal/from-flag",getprop("instrumentation/nav["~ind~"]/from-flag"));

    } else if(left(NAVSRC,3) == "FMS"){
      ind = (NAVSRC == "FMS1" ? 0 : 1);
      setprop("autopilot/internal/nav-type","FMS"~(ind+1));
      setprop(gs_in_range,getprop("instrumentation/nav["~ind~"]/gs-in-range"));
      setprop("autopilot/internal/nav-distance",getprop("instrumentation/gps/wp/wp[1]/distance-nm"));
      setprop("autopilot/internal/nav-id",getprop("instrumentation/gps/wp/wp[1]/ID"));
      setprop("autopilot/internal/to-flag",getprop("instrumentation/gps/wp/wp[1]/to-flag"));
      setprop("autopilot/internal/from-flag",getprop("instrumentation/gps/wp/wp[1]/from-flag"));
      setprop("autopilot/internal/course-deflection",getprop("instrumentation/gps/cdi-deflection"));

			#### Turn Anticipation ###
			fp = flightplan();
			dist_rem = getprop("autopilot/route-manager/distance-remaining-nm");
			wp_dist = getprop("instrumentation/gps/wp/wp[1]/distance-nm");
			geocoord = geo.aircraft_position();
			refCourse = fp.pathGeod(fp.indexOfWP(fp.destination_runway), -dist_rem);
      courseCoord = geo.Coord.new().set_latlon(refCourse.lat, refCourse.lon);
      CourseError = (geocoord.distance_to(courseCoord) / 1852) + 1;
			heading = getprop("orientation/heading-deg");
      targetCourse = fp.pathGeod(fp.indexOfWP(fp.destination_runway), (-dist_rem + CourseError));
      courseCoord = geo.Coord.new().set_latlon(targetCourse.lat, targetCourse.lon);
      CourseError = geocoord.course_to(courseCoord) - heading;
      if(CourseError < -180) CourseError += 360;
      else if(CourseError > 180) CourseError -= 360;
			crs_set = geocoord.course_to(courseCoord);
			if (fp.current < 1) { # On ground and takeoff
				crs_offset= crs_set - getprop("orientation/heading-deg");
				if(crs_offset>180)crs_offset-=180;
				if(crs_offset<-180)crs_offset+=180;
			} else { # in flight
				crs_offset = CourseError;
				gspd = getprop("velocities/groundspeed-kt")/8000; # old 10000
				curr_bearing = fp.getWP(fp.current).leg_bearing;
				if (fp.current < fp.getPlanSize()-1) {
					next_bearing = fp.getWP(fp.current+1).leg_bearing;
				} else {next_bearing = curr_bearing}
				if (abs(curr_bearing - next_bearing) > 150) {diff_crs = 0}
				else {diff_crs = abs(curr_bearing - next_bearing)*gspd}
				if (wp_dist <= diff_crs) {
					setprop("autopilot/route-manager/current-wp",fp.current +1);
				}
			}
        ### GS anticipation ###
      if (dist_rem <= 10) {
        setprop("autopilot/internal/course-offset",getprop("autopilot/internal/nav-heading-error-deg"));
      } else {
			  setprop("autopilot/internal/course-offset",crs_offset);
			  setprop("autopilot/internal/selected-crs",int(crs_set));
      }
        #############

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
					setprop(alm_wp,1);
					if (courseDist > dist_wp +0.2) {
						setprop(alm_wp,0);
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

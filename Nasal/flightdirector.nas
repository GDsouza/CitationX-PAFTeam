##########################################
# Flight Director/Autopilot controller.
# Syd Adams
# C. Le Moigne - 2015 - release 2020
##########################################

###  Initialization ###
var alm_wp = "autopilot/locks/alm-wp";
var alt = "instrumentation/altimeter/indicated-altitude-ft";
var AP = "autopilot/locks/AP-status";
var ap_dist = "autopilot/internal/nav-distance";
var AutoCoord = "controls/flight/auto-coordination";
var back_crs = "autopilot/locks/back-course";
var cdi = "autopilot/internal/course-deflection";
#var dme_dist = "instrumentation/dme/indicated-distance-nm";
var el_fgc = "autopilot/settings/fgc";
var el_sec = "sim/time/elapsed-sec";
var flyover = ["instrumentation/cdu/flyover",
               "instrumentation/cdu[1]/flyover"];
var Fms = "autopilot/settings/fms";
var fp_active = "autopilot/route-manager/active";
var gs_in_range = "autopilot/internal/gs-in-range";
var head = "autopilot/locks/heading";
var ind_kt = "velocities/airspeed-kt";
var ind_mc = "instrumentation/airspeed-indicator/indicated-mach";
var Lateral = "autopilot/locks/heading";
var Lateral_arm = "autopilot/locks/heading-arm";
var mag_var = "environment/magnetic-variation-deg";
var minimums = "autopilot/settings/minimums";
var nav_source = "autopilot/settings/nav-source";
var nav_tgHdg = ["instrumentation/nav/radials/target-auto-hdg-deg",
                 "instrumentation/nav[1]/radials/target-auto-hdg-deg"];
var nav_type = "autopilot/settings/nav-type";
var orient = "orientation/heading-deg";
var pcdr_active = "autopilot/locks/pcdr-turn-active";
var pitch = "orientation/pitch-deg";
var throttle = ["controls/engines/engine/throttle",
                "controls/engines/engine[1]/throttle"];
var tg_climb = "autopilot/settings/target-climb-rate-fps";
var tg_pitch = "autopilot/settings/target-pitch-deg";
var tg_radial = ["instrumentation/nav/radials/target-radial-deg",
                 "instrumentation/nav[1]/radials/target-radial-deg"];
var tg_spd_kt = "autopilot/settings/target-speed-kt";
var tg_spd_mc = "autopilot/settings/target-speed-mach";
var to_ga = ["controls/engines/engine/to-ga",
             "controls/engines/engine[1]/to-ga"];
var toga = "autopilot/locks/to-ga";
var Vertical = "autopilot/locks/altitude";
var Vertical_arm = "autopilot/locks/altitude-arm";
var _wow = ["gear/gear[1]/wow","gear/gear[2]/wow"];
var yd = "autopilot/locks/yaw-damper";

var agl_alt = nil;
var alm_timer = nil;
var alterr = nil;
var asel = nil;
var count = 0;
var Coord = 0;
var courseCoord = nil;
var courseDist = nil;
var CourseError = nil;
var crs_offset = nil;
var crs_set = nil;
var dist_rem = nil;
var dme_flag = 0;
var dst = nil;
var dstCoeff = 1;
var et_ind = 0;
var fp = nil;
var geocoord = nil;
var geo_coord = nil;
var gs_err = nil;
var heading = nil;
var hr_et = nil;
var in_range = 0;
var ind = nil;
var ind_alt = nil;
var Lmode = nil;
var min_et = nil;
var min_mode = nil;
var nav_id = nil;
var plimit = nil;
var pw = nil;
var refAlt = nil;
var refCourse = nil;
var rlimit = nil;
var sec = nil;
var sec_flag = 0;
var sgnl = nil;
var targetCourse = nil;
var tmphr = nil;
var tmpmin = nil;
var ttw = nil;
var Varm = nil;
var Vmode = nil;
var wp_curr = 0;
var wp_dist0 = nil;
var wp_dist1 = nil;
var mem_nav = getprop(Lateral);
var mem_nav_arm = getprop(Lateral_arm);
var mem_fms_l = getprop(Lateral);
var mem_fms_v = getprop(Vertical);
var navsrc = nil;

### Listeners ###
setlistener(nav_source, func(n) {
    navsrc = n.getValue();
},1,0);

setlistener("autopilot/settings/btn/bc", func(n) {
  if (n.getValue()) {
    if (getprop(head) == 'VOR' or getprop(head) == 'LOC') 
      setprop("autopilot/locks/back-course",1);
    else setprop("autopilot/locks/back-course",0);
  }
},0,0);

setlistener("autopilot/locks/alt-mach",func(n) {
    if (n.getValue() and getprop("autopilot/locks/speed-ctrl") and left(navsrc,3)!="FMS")
      setprop(tg_spd_mc,0.60);
},0,0);

setlistener(fp_active, func(n) {
	if (n.getValue()) fp = flightplan();
},0,0);

setlistener(alm_wp,func(n) {
    alm_timer = maketimer(2,func() {setprop(alm_wp,0)});
    if (n.getValue()) {
      alm_timer.singleShot = 1;
      alm_timer.start();
    }
},0,0);

setlistener(to_ga[0],func(n) {
    if (n.getValue()) controls.ToGa_set_mode();
},1,0);

setlistener(to_ga[1],func(n) {
    if (n.getValue()) controls.ToGa_set_mode();
},0,0);

### AP /FD Buttons ###
var FD_set_mode = func(btn){
    Lmode = getprop(Lateral);
    Vmode = getprop(Vertical);
		min_mode = getprop("autopilot/settings/minimums-mode");
		agl_alt = getprop("position/altitude-agl-ft");
		ind_alt = getprop(alt);
		asel = getprop("autopilot/settings/asel");
		if(btn == "ap"){
			Coord = getprop(AutoCoord);
			if(getprop(AP) != "AP") {
        if (Vmode == 'TO' or Vmode == 'GA') {
          setprop(Vertical,getprop(Vertical_arm));
				  setprop(Vertical_arm,"");
        }
				setprop("autopilot/locks/disengage",0);
        if(Vmode=="PTCH") set_pitch("PTCH");
        if(Vmode=="VS") setprop(tg_climb,50);
        if(Lmode=="ROLL") set_roll(); 
        refAlt = min_mode == "RA" ? agl_alt : ind_alt;
				if(refAlt > getprop(minimums)) {
					setprop(AP,"AP");
					setprop(AutoCoord,0);
          setprop(toga,0);
				}
			}	else {kill_Ap("");setprop("autopilot/locks/disengage",1)}
    }
    if (btn == "yd") setprop(yd,1);
    if(btn == "hdg") {
			if(Lmode!="HDG") {setprop(Lateral,"HDG")}
			else {
        set_roll();
        setprop(Lateral_arm,"");
        setprop(Vertical_arm,"");
      }
    }
    if(btn=="alt"){
			if(Vmode!="ALT"){
        if (Vmode == 'TO' or Vmode == 'GA') {
          if (getprop(Vertical_arm) != "ALT") setprop(Vertical_arm,"ALT");
          else setprop(Vertical_arm,"");
        } else setprop(Vertical,"ALT");
      } else set_pitch("PTCH");
    }
    if(btn == "flc"){
			var flcmode = "FLC";
			var asel = "ASEL";
			if(left(navsrc,3)=="FMS"){flcmode="VFLC";asel = "VASEL";}
			if(Vmode!=flcmode){
				var mc = getprop(ind_mc);
				var kt = int(getprop(ind_kt));
				if(!getprop("autopilot/settings/changeover")){
					if(kt > 80 and kt <340){
						setprop(Vertical,flcmode);
						setprop(Vertical_arm,asel);
						setprop(tg_spd_kt,250);
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
			} else set_pitch("PTCH");
		}
    if(btn == "nav"){
			set_nav_mode();
      if (left(navsrc,3) == "NAV") {
        mem_nav = getprop(Lateral);      
        mem_nav_arm = getprop(Lateral_arm);      
      }
		}
    if(btn == "vnav"){
			if(Vmode!="VALT" and asel > 0 and getprop(fp_active)) {
				if(left(navsrc,3)=="FMS"){
          if (Vmode == 'TO' or Vmode == 'GA') {
            if (getprop(Vertical_arm) != "VALT") setprop(Vertical_arm,"VALT");
            else setprop(Vertical_arm,"");
          } else setprop(Vertical,"VALT");
					setprop(Lateral,"LNAV");
				} else set_pitch("PTCH");
      } else if (Vmode!="ALT") set_pitch("PTCH");
    }
    if(btn == "app"){
			if (Vmode!="GS") {
				setprop(Lateral_arm,"");
				setprop(Vertical_arm,"");
				set_apr();
			} else {
				setprop(Vertical,"ALT");
				setprop(Vertical_arm,"");
			}
    }
    if(btn == "vs"){
			setprop(Lateral_arm,"");
			setprop(Vertical_arm,"");
			if(Vmode!="VS"){
				setprop(Vertical,"VS");
			} else set_pitch("PTCH");
    }
    if(btn == "stby"){
			setprop(Lateral_arm,"");
			setprop(Vertical_arm,"");
			set_pitch("PTCH");
			set_roll();
    }
    if(btn == "co"){
			var Co= 1- getprop("autopilot/settings/changeover");
			if(Vmode!="FLC") Co=0;
			setprop("autopilot/settings/changeover",Co);
    }
}

###  TO-GA Buttons  ###
controls.ToGa_set_mode = func {
    setprop(toga,1);
    if (getprop(Vertical) == "ALT") setprop(Vertical_arm,"ALT");
    if (getprop(Vertical) == "VALT") setprop(Vertical_arm,"VALT");
    if (!getprop(_wow[0]) and !getprop(_wow[1])) {
      kill_Ap("");
      set_pitch("GA");
    } else set_pitch("TO");
    setprop("autopilot/settings/target-speed-kt",250);
};

###  FMS/NAV Buttons  ###
var nav_src_set = func(src){
		setprop(Vertical_arm,"");
    if(left(src,3) == "FMS"){
			if(getprop(fp_active)) {
        if (!getprop(Fms)) {
          setprop(Lateral,mem_fms_l);     
          setprop(Lateral_arm,"");
          setprop(Vertical,mem_fms_v);
    			setprop(Fms,1);
        } else {
          mem_fms_l = getprop(Lateral);
          mem_fms_v = getprop(Vertical);
        }
        setprop(nav_source,src);
			}
    } else {
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
			if (getprop(Vertical) == "VALT") setprop(Vertical,"PTCH");
      setprop(nav_source,src);
    }
}

var set_nav_mode = func {
    setprop(Lateral_arm,"");
		setprop(Vertical_arm,"");
    var ind_nav = nil;
    if(left(navsrc,3)=="NAV"){
      ind_nav = navsrc=="NAV1" ? 0 : 1;
#      if(navsrc=="NAV1") ind_nav = 0;
#      if(navsrc=="NAV2") ind_nav = 1;
		  if(getprop("instrumentation/nav["~ind_nav~"]/data-is-valid")){
			  if(getprop("instrumentation/nav["~ind_nav~"]/nav-loc")) {
				  setprop(Lateral_arm,"LOC");
			  } else {
				  setprop(Lateral_arm,"VOR");
          setprop(Lateral,"HDG");
        }
		  }
    } 
    if(left(navsrc,3)=="FMS"){
      if (getprop(fp_active)) {
        setprop(Lateral,"LNAV");
	    }
		}
}

### Pitch Actions ###
var pitch_wheel = func(pw) {
    var Vmode = getprop(Vertical);
    var CO = getprop("autopilot/settings/changeover");
		var SP = getprop("autopilot/locks/speed-ctrl");
    var amt = 0;
    if(Vmode=="VS"){
      amt = math.clamp(getprop(tg_climb) + pw,-75,75);
      setprop(tg_climb,amt);
    } else if(Vmode=="FLC" or Vmode=="VFLC"){
        if(!CO){
					if (getprop("autopilot/locks/alt-mach")) {
	          amt=getprop(tg_spd_mc) + (pw*0.01);
            amt = (amt < 0.40 ? 0.40 : amt > 0.92 ? 0.92 : amt);
            setprop(tg_spd_mc,amt);
					}	else {
			        amt=getprop(tg_spd_kt) + pw*5;
		          amt = (amt < 80 ? 80 : amt > 340 ? 340 : amt);
		          setprop(tg_spd_kt,amt);
	        }
				}
    } else if(Vmode=="PTCH" and !SP){
        amt = getprop(tg_pitch) + (pw*0.1);
        amt = (amt < -15 ? -15 : amt > 19 ? 19 : amt);
        setprop(tg_pitch,amt);
    } else if (SP) {
				if (getprop("autopilot/locks/alt-mach")) {
          amt = getprop(tg_spd_mc) + (pw*0.01);
          amt = (amt < 0.60 ? 0.60 : amt > 0.92 ? 0.92 : amt);
          setprop(tg_spd_mc,amt);
				}	else {
		        amt=getprop(tg_spd_kt) + pw*5;
	          amt = (amt < 80 ? 80 : amt > 340 ? 340 : amt);
	          setprop(tg_spd_kt,amt);
        }
		}								
}

var set_pitch = func (ptch_mode) {
    setprop(Vertical,ptch_mode);
		setprop(tg_pitch,getprop(toga) ? 10 : getprop(pitch));
}

### Roll Action ###
var set_roll = func{
    setprop(Lateral,"ROLL");
		setprop("autopilot/settings/target-roll-deg",0.0);
}

### Alt Action ###
#var set_alt = func {
#		var n=getprop("instrumentation/altimeter/mode-c-alt-ft")*0.01;
#		var m=int(n/10);
#		var p=(n/10)-m;
#		if (p>0 and p<0.5) {p=0.5;m=m+p}
#		else if(p>=0.5 and p<1) {m=m+1}
#		else {p=0}
#		setprop("autopilot/settings/asel",m*10);
#}

### Lateral Armed ###
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

### Vertical Armed ###
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
          gs_err = getprop("autopilot/internal/gs-deflection");
          if(gs_err >-3 and gs_err < 3){
            setprop(Vertical,"GS");
            setprop(Vertical_arm,"");
					}
        } 
			}
    }
}

### Kill AP ###
var monitor_AP_errors = func{
		if (getprop(AP)!="AP") return;
		min_mode = getprop("autopilot/settings/minimums-mode");
		agl_alt = getprop("position/altitude-agl-ft");
		ind_alt = getprop(alt);
    refAlt = min_mode == "RA" ? agl_alt : ind_alt;
		if(refAlt < getprop(minimums)) kill_Ap("");
    rlimit = getprop("orientation/roll-deg");
    plimit = getprop("orientation/pitch-deg");
    if(rlimit > 45 or rlimit< -45 or plimit > 30 or plimit< -30
        or getprop(el_fgc) == "N") kill_Ap("AP-FAIL");
}

var kill_Ap = func(msg){
    setprop(AP,msg);
    setprop(AutoCoord,Coord);
		setprop("autopilot/locks/disengage",1);
		setprop("autopilot/locks/speed-ctrl",getprop(toga) ? 1 : 0);
}

### Elapsed time ###
var get_ETE = func{
    ttw = "--:--";
    min_et = 0;
    hr_et = 0;
    if(navsrc == "NAV1") et_ind = 0;
    if(navsrc == "NAV2") et_ind = 1;
    if(left(navsrc,3) == "FMS"){
			min_et = getprop("autopilot/route-manager/ete");
		}	else {
      min_et = int(getprop("instrumentation/dme["~et_ind~"]/indicated-time-min"));
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

var alt_mach = func {
		setprop("autopilot/locks/alt-mach", getprop(alt) >= 30650 ? 1 : 0);
}

### Approach ###
var set_apr = func{
		var ind_apr = 0;
    if(navsrc == "NAV1" or navsrc == "FMS1"){ind_apr = 0}
		if(navsrc == "NAV2" or navsrc == "FMS2"){ind_apr = 1}
		if (!getprop("instrumentation/nav["~ind_apr~"]/gs-in-range")) {
			setprop(Lateral_arm,"");
			setprop(Vertical_arm,"");
			setprop(Lateral,"HDG");
			setprop(Vertical,"PTCH"); 
		} else if(getprop("instrumentation/nav["~ind_apr~"]/nav-loc") and getprop("instrumentation/nav["~ind_apr~"]/has-gs")){
			setprop(Lateral_arm,"LOC");
			setprop(Vertical_arm,"GS");
			setprop(Vertical,"GS"); 
      setprop(Lateral,"HDG");
      setprop("autopilot/internal/in-range",1);
		}		
}

### Update ###
var update_nav = func {
    sgnl = "- - -";
		ind = 0;
    if (navsrc == "") setprop(nav_type,"");
    else if(left(navsrc,3) == "NAV") {
      ind = (navsrc == "NAV1" ? 0 : 1);
      in_range = getprop("instrumentation/nav["~ind~"]/in-range");
      if (getprop("instrumentation/nav/gs-in-range") 
        or getprop("instrumentation/nav[1]/gs-in-range")) setprop(gs_in_range,1);
      else setprop(gs_in_range,0);
      nav_id = getprop("instrumentation/nav["~ind~"]/nav-id");
      dst = nav_id ? getprop("instrumentation/nav["~ind~"]/nav-distance")*0.000539 :0;
      if (getprop(gs_in_range) and dst <= 20) setprop("autopilot/internal/in-range",1);
      ### Back Course ###
      if(left(getprop(nav_type),3) == "ILS" and getprop(back_crs)) {
        if (getprop(ap_dist) > 10) {
          setprop(back_crs,0);
          dme_flag = 0;
          return;
        }
        crs_offset = geo.normdeg(getprop(tg_radial[ind]) - 180)- getprop(orient);
        if (getprop(ap_dist) < 2) dme_flag = 1;
        if (dme_flag and getprop(ap_dist) > 5) crs_offset = crs_offset - 45;
      } else crs_offset = (getprop(nav_tgHdg[ind]) or 0) - getprop(orient);

      ###################

    } else if(left(navsrc,3) == "FMS"){
      ind = (navsrc == "FMS1" ? 0 : 1);
      in_range = getprop("instrumentation/nav["~ind~"]/in-range");
      if (getprop("instrumentation/nav/gs-in-range") 
        or getprop("instrumentation/nav[1]/gs-in-range")) setprop(gs_in_range,1);
      else setprop(gs_in_range,0);
      dst = getprop("instrumentation/gps/wp/wp[1]/distance-nm");
      nav_id = getprop("instrumentation/gps/wp/wp[1]/ID");
      if (getprop(Fms)) {
        setprop("autopilot/internal/course-deflection",getprop("instrumentation/gps/cdi-deflection"));
			  dist_rem = getprop("autopilot/route-manager/distance-remaining-nm");
			  heading = getprop(orient);
			  geocoord = geo.aircraft_position();

        if (fp.getWP(fp.current).wp_name == "*int03")
          setprop("autopilot/settings/bank-limit",20);
        else setprop("autopilot/settings/bank-limit",35);

            ### Fly over (no turn anticipation) ###
        if (getprop(flyover[ind]) > 0 and getprop(flyover[ind]) < fp.current) 
          setprop(flyover[ind],0);
        if (getprop(flyover[ind]) > 0 and 
          (getprop(flyover[ind]) == fp.current or
          fp.getWP(fp.current).wp_name == "*int03")) {
            crs_set = getprop("instrumentation/gps/wp/wp[1]/bearing-true-deg");
            crs_offset = geo.normdeg180(crs_set - heading);
        } else { ### Turn anticipation ###
          if (dist_rem <= 10 and !getprop(pcdr_active)) {
            dstCoeff -= 0.001;
            if (dstCoeff <= 0.20) dstCoeff = 0.20;
            targetCourse = fp.pathGeod(-1, -dist_rem + dstCoeff);
            courseCoord = geo_coord.set_latlon(targetCourse.lat, targetCourse.lon);
            crs_offset = geo.normdeg180(geocoord.course_to(courseCoord) - heading);
	          crs_set = geocoord.course_to(courseCoord);
          } else {
			      refCourse = fp.pathGeod(-1, -dist_rem);
            courseCoord = geo_coord.set_latlon(refCourse.lat, refCourse.lon);
            CourseError = (geocoord.distance_to(courseCoord) / 1852) + 0.7;
            targetCourse = fp.pathGeod(-1, -dist_rem + CourseError);
            courseCoord = geo_coord.set_latlon(targetCourse.lat, targetCourse.lon);
            crs_offset = geo.normdeg180(geocoord.course_to(courseCoord) - heading);
			      crs_set = geocoord.course_to(courseCoord);
          }
        }
        setprop("autopilot/internal/course-offset",crs_offset);
		    setprop("autopilot/settings/selected-crs",int(crs_set));

        ### Wp change ###
        if (sec_flag == 0) {
          wp_dist0 = getprop("autopilot/internal/nav-distance");
          if (wp_dist0 <= 2) {
            sec = getprop(el_sec);
            sec_flag = 1;
          }
        }
        if (sec_flag == 1 and getprop(el_sec) >= sec + 3) {
          wp_dist1 = getprop("autopilot/internal/nav-distance");
          if (wp_dist1-wp_dist0 >= 0.1 and fp.current == wp_curr and fp.current > 0) {
            setprop("autopilot/route-manager/current-wp",fp.current +1);
            setprop(alm_wp,1);
          } else if (fp.current > wp_curr) setprop(alm_wp,1);
          wp_curr = fp.current;
          sec_flag = 0;
        } 
      }
      setprop("autopilot/settings/nav-id",nav_id);
      setprop("autopilot/internal/nav-distance",dst);
    }
} # end of update

    ### TOGA throttles limit ###
var toga_throttles = func {
    if (getprop(toga)) {
      setprop(throttle[0],math.clamp(getprop(throttle[0]),0,0.9));
      setprop(throttle[1],math.clamp(getprop(throttle[1]),0,0.9));
    }
} 

###  Main ###
var fd_stl = setlistener("sim/signals/fdm-initialized", func {
  geo_coord = geo.Coord.new();
  print("Flight Director ... Ok");
	settimer(update_fd,6);
	removelistener(fd_stl);
},0,0);

var update_fd = func {
    update_nav();
		alt_mach();
    toga_throttles();
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

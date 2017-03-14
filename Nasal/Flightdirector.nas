##########################################
# Flight Director/Autopilot controller.
# Syd Adams
# C. Le Moigne - 2015 - rev 2017
# Ctesc356 - rev function "course_offset" - fev 2017
##########################################

###  Initialization #######
var Lateral = "autopilot/locks/heading";
var Lateral_arm = "autopilot/locks/heading-arm";
var Vertical = "autopilot/locks/altitude";
var Vertical_arm = "autopilot/locks/altitude-arm";
var AP = "autopilot/locks/AP-status";
var NAVprop="autopilot/settings/nav-source";
var AutoCoord="controls/flight/auto-coordination";
var NAVSRC= getprop(NAVprop);
var count=0;
var Coord = 0;
var minimums=getprop("autopilot/settings/minimums");
var rd_speed = props.globals.initNode("instrumentation/airspeed-indicator/round-speed-kt",0,"DOUBLE");
var alt = "instrumentation/altimeter/indicated-altitude-ft";
var v_speed = "autopilot/internal/vert-speed-fpm";
var tg_spd_mc = "autopilot/settings/target-speed-mach";
var ind_mc = "instrumentation/airspeed-indicator/indicated-mach";
var tg_spd_kt = "autopilot/settings/target-speed-kt";
var ind_kt = "instrumentation/airspeed-indicator/indicated-speed-kt";
var app_wp = "autopilot/route-manager/route/wp[";
props.globals.initNode("autopilot/locks/TOD",0,"BOOL");
props.globals.initNode("autopilot/settings/fms",0,"BOOL");
props.globals.initNode("autopilot/locks/alm-tod",0,"BOOL");
var NDSymbols = props.globals.getNode("autopilot/route-manager/vnav", 1);
var int_crs = 0;
var wp = 0;


### AP /FD BUTTONS ####

var FD_set_mode = func(btn){
    var Lmode=getprop(Lateral);
    var LAmode=getprop(Lateral_arm);
    var Vmode=getprop(Vertical);
    var VAmode=getprop(Vertical_arm);
		var min_mode = getprop("autopilot/settings/minimums-mode");
		var agl_alt = getprop("position/altitude-agl-ft");
		var ind_alt = getprop(alt);

		if(btn=="ap"){
			Coord = getprop(AutoCoord);
			if(getprop(AP)!="AP"){
				setprop(Lateral_arm,"");
				setprop(Vertical_arm,"");
				setprop("autopilot/locks/disengage",0);
        if(Vmode=="PTCH")set_pitch();
        if(Lmode=="ROLL")set_roll(); 
				if (min_mode = "RA") {
					if(agl_alt > minimums) {
						setprop(AP,"AP");
						setprop(AutoCoord,0);
					}
				}
				if (min_mode = "BA") {
					if(ind_alt > minimums){
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
			if(Vmode!="VALT"){
				if(left(NAVSRC,3)=="FMS"){
					setprop(Vertical,"VALT");
					setprop(Lateral,"LNAV");
         }
      }else {set_pitch()}

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

########  FMS/NAV BUTTONS  ############
var nav_src_set=func(src){
    setprop(Lateral_arm,"");
		setprop(Vertical_arm,"");
    if(src=="fms"){
			setprop("autopilot/settings/fms",1);
			if(getprop("autopilot/route-manager/route/num")>0) {
        if (NAVSRC!="FMS1")setprop(NAVprop,"FMS1") else setprop(NAVprop,"FMS2");
			}
    }else{
			setprop("autopilot/settings/fms",0);
      if (NAVSRC!="NAV1")setprop(NAVprop,"NAV1") else setprop(NAVprop,"NAV2");
    }
}

########### ARM VALID NAV MODE ################

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
        if (getprop("autopilot/route-manager/active")) {
					setprop(Lateral,"LNAV");
		    }
		}
}

#######  PITCH WHEEL ACTIONS #############

var pitch_wheel=func(dir) {
    var Vmode=getprop(Vertical);
    var CO = getprop("autopilot/settings/changeover");
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
    } else if(Vmode=="PTCH"){
        amt=getprop("autopilot/settings/target-pitch-deg") + (dir*0.1);
        amt = (amt < -20 ? -20 : amt > 20 ? 20 : amt);
        setprop("autopilot/settings/target-pitch-deg",amt)
    }
}

########    FD INTERNAL ACTIONS  #############

var set_pitch = func{
    setprop(Vertical,"PTCH");
		setprop("autopilot/settings/target-pitch-deg",getprop("orientation/pitch-deg"));
}

var set_roll = func{
    setprop(Lateral,"ROLL");
		setprop("autopilot/settings/target-roll-deg",0.0);
}

var set_apr = func{
    if(NAVSRC == "NAV1" or NAVSRC == "FMS1"){
			if(getprop("instrumentation/nav/nav-loc") and getprop("instrumentation/nav/has-gs")){
				setprop(Lateral_arm,"LOC");
				setprop(Vertical_arm,"GS");
				setprop(Lateral,"HDG");
				setprop(Vertical,"GS"); 
			}
		}else if(NAVSRC == "NAV2" or NAVSRC == "FMS2"){
			if(getprop("instrumentation/nav[1]/nav-loc") and getprop("instrumentation/nav[1]/has-gs")){
				setprop(Lateral_arm,"LOC");
				setprop(Vertical_arm,"GS");
				setprop(Lateral,"HDG");
				setprop(Vertical,"GS");
      }
		}
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

setlistener("autopilot/settings/minimums", func(mn) {
    minimums=mn.getValue();
		var min_mode = getprop("autopilot/settings/minimums-mode");
		if (min_mode == "RA") {setprop("instrumentation/pfd/minimums-radio",minimums)}
		if (min_mode == "BA") {setprop("instrumentation/pfd/minimums-baro",minimums)}
},1,0);


setlistener(NAVprop, func(Nv) {
    NAVSRC=Nv.getValue();
},0,0);

var update_nav = func {
    var sgnl = "- - -";
		var ind = 0;
		var nb = "";
    if(NAVSRC == "NAV1" or NAVSRC == "NAV2"){
			if (NAVSRC == "NAV1") {ind = 0;nb = "1"}
			if (NAVSRC == "NAV2") {ind = 1;nb = "2"}
        if(getprop("instrumentation/nav["~ind~"]/data-is-valid"))sgnl="VOR"~nb;
        setprop("autopilot/internal/in-range",getprop("instrumentation/nav["~ind~"]/in-range"));
        setprop("autopilot/internal/gs-in-range",getprop("instrumentation/nav["~ind~"]/gs-in-range"));
        var dst=getprop("instrumentation/nav["~ind~"]/nav-distance") or 0;
        dst*=0.000539;
        setprop("autopilot/internal/nav-distance",dst);
        setprop("autopilot/internal/nav-id",getprop("instrumentation/nav["~ind~"]/nav-id"));
        if(getprop("instrumentation/nav["~ind~"]/nav-loc"))sgnl="LOC"~nb;
        if(getprop("instrumentation/nav["~ind~"]/has-gs"))sgnl="ILS"~nb;
        setprop("autopilot/internal/nav-type",sgnl);
        course_offset("instrumentation/nav["~ind~"]/radials/selected-deg");
        setprop("autopilot/internal/to-flag",getprop("instrumentation/nav["~ind~"]/to-flag"));
        setprop("autopilot/internal/from-flag",getprop("instrumentation/nav["~ind~"]/from-flag"));

    }else if(NAVSRC == "FMS1" or NAVSRC == "FMS2"){
				if (NAVSRC == "FMS1") {ind = 1} else {ind = 2}
        setprop("autopilot/internal/nav-type","FMS"~ind);
        setprop("autopilot/internal/in-range",1);
        setprop("autopilot/internal/gs-in-range",0);
        setprop("autopilot/internal/nav-distance",getprop("instrumentation/gps/wp/wp[1]/distance-nm"));
        setprop("autopilot/internal/nav-id",getprop("instrumentation/gps/wp/wp[1]/ID"));
        course_offset("instrumentation/gps/wp/wp[1]/bearing-mag-deg");
        setprop("autopilot/internal/to-flag",getprop("instrumentation/gps/wp/wp[1]/to-flag"));
        setprop("autopilot/internal/from-flag",getprop("instrumentation/gps/wp/wp[1]/from-flag"));
    } else if (NAVSRC == "") {setprop("autopilot/internal/nav-type","")}

} # end of update_nav

var course_offset = func(src){
    var crs_set=getprop(src);
		var nav_dst= getprop("autopilot/internal/nav-distance");
    var crs_offset= crs_set - getprop("orientation/heading-magnetic-deg");
    if(crs_offset>180)crs_offset-=360;
    if(crs_offset<-180)crs_offset+=360;
    setprop("autopilot/internal/course-offset",crs_offset);
    crs_offset+=getprop("autopilot/internal/cdi");
    if(crs_offset>180)crs_offset-=360;
    if(crs_offset<-180)crs_offset+=360;
		if (nav_dst<0.5) {
			if (wp == 0) {int_crs = crs_offset;wp=1}			
			setprop("autopilot/internal/ap_crs",int_crs);
		} else {setprop("autopilot/internal/ap_crs",crs_offset);wp=0}
    setprop("autopilot/internal/selected-crs",crs_set);
}

var monitor_L_armed = func{
    if(getprop(Lateral_arm)!=""){
      if(getprop("autopilot/internal/in-range")){
        var cdi=getprop("autopilot/internal/cdi");
        if(cdi < 40 and cdi > -40){
          setprop(Lateral,getprop(Lateral_arm));
          setprop(Lateral_arm,"");
        }
      }
    }
}

var monitor_V_armed = func{
    var Varm=getprop(Vertical_arm);
    var myalt=getprop(alt);
    var asel=getprop("autopilot/settings/asel") * 100;
    var alterr=myalt-asel;
    if(Varm=="ASEL"){
      if(alterr >-250 and alterr <250){
        setprop(Vertical,"ALT");
        setprop(Vertical_arm,"");
      }
    }elsif(Varm=="VASEL"){
      if(alterr >-250 and alterr <250){
        setprop(Vertical,"VALT");
        setprop("instrumentation/gps/wp/wp[1]/altitude-ft",asel);
        setprop(Vertical_arm,"");
      }
    }elsif(Varm=="GS"){
      if(getprop(Lateral)=="LOC"){
        if(getprop("autopilot/internal/gs-in-range")){
          var gs_err=getprop("autopilot/internal/gs-deflection");
          var gs_dst=getprop("autopilot/internal/nav-distance");
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
		var min_mode = getprop("autopilot/settings/minimums-mode");
		var agl_alt = getprop("position/altitude-agl-ft");
		var ind_alt = getprop(alt);
		if (min_mode == "RA") {if(agl_alt<minimums)kill_Ap("")};
		if (min_mode == "BA") {if(ind_alt<minimums)kill_Ap("")};
    var rlimit=getprop("orientation/roll-deg");
    if(rlimit > 45 or rlimit< -45)kill_Ap("AP-FAIL");
    var plimit=getprop("orientation/pitch-deg");
    if(plimit > 30 or plimit< -30)kill_Ap("AP-FAIL");
}

var kill_Ap = func(msg){
    setprop(AP,msg);
    setprop(AutoCoord,Coord);
		setprop("autopilot/locks/disengage",1);
}

var get_ETE= func{
    var ttw = "--:--";
    var min =0;
    var hr=0;
    if(NAVSRC == "NAV1"){
      setprop("instrumentation/dme/frequencies/source","instrumentation/nav/frequencies/selected-mhz");
      min = int(getprop("instrumentation/dme/indicated-time-min"));
      if(min>60){
        var tmphr=(min*0.016666);
        hr=int(tmphr);
        var tmpmin=(tmphr-hr)*100;
        min=int(tmpmin);
      }
      ttw=sprintf("ETE %i:%02i",hr,min);
    }elsif(NAVSRC == "NAV2"){
      setprop("instrumentation/dme/frequencies/source","instrumentation/nav[1]/frequencies/selected-mhz");
      min = int(getprop("instrumentation/dme/indicated-time-min"));
      if(min>60){
          var tmphr=(min*0.016666);
          hr=int(tmphr);
          var tmpmin=(tmphr-hr)*100;
          min=int(tmpmin);
      }
      ttw=sprintf("ETE %s:%02i",hr,min);
    }elsif(left(NAVSRC,3) == "FMS"){
      min = getprop("autopilot/route-manager/ete");
      min=int(min * 0.016666);
      if(min>60){
          var tmphr=(min*0.016666);
          hr=int(tmphr);
          var tmpmin=(tmphr-hr)*100;
          min=int(tmpmin);
      }
       ttw=sprintf("ETE %s:%02i",hr,min);
    }
    setprop("autopilot/internal/nav-ttw",ttw);
}


var speed_round = func {
	var ind_speed = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
	rd_speed.setDoubleValue(math.round(ind_speed));
}

var alt_mach = func {
	if (getprop(alt) >= 30650) {
		setprop("autopilot/locks/alt-mach",1);
			setprop(tg_spd_kt,getprop(ind_kt));
	}	else {
		setprop("autopilot/locks/alt-mach",0);
			setprop(tg_spd_mc,getprop(ind_mc));
	}
}

###  Main loop ###

setlistener("sim/signals/fdm-initialized", func {
   print("Flight Director ...Checked");
	settimer(update_fd,6);
});

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

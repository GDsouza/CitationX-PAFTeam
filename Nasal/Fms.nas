##########################################
# FMS CLASS - Speed & Altitude Controls
# C. Le Moigne (clm76) - 2017
##########################################

var v_tod = []; # for tod distances and altitudes
var v_ind = 0; # index for v_tod vector
var v_alt = std.Vector.new(); # for wp altitudes
var dist_b_tod = 4; # alarm distance before TOD
var alm_tod = 0;
var ind = 0;
var cruise_kt = 0;
var cruise_mc = 0;
var curr_wp = nil;
var geoCoord = nil;
var wpCoord = nil;
var courseDist = nil;

var FMS = {
	new : func () {
		var m = {parents:[FMS]};

		m.vmo = 0;
		m.mmo = 0.92;
		m.set_tgAlt = 0;
		m.fp = nil; # flightplan
		m.lastWp_alt = 0;
		m.lastWp_dist = 0;
		m.lastWp_ind = 0;
		m.prevWp_alt = 0;
		m.prevWp_dist = 0;
		m.prevWp_ind = 0;
		m.tod = 0;
		m.spd_dist = 0;
		m.flag_alt = 0;
    m.dist = nil; # for fps limit function
    m.desc_flag = 0;

		m.active = props.globals.getNode("autopilot/route-manager/active",1);
		m.alm_tod = props.globals.getNode("autopilot/locks/alm-tod",1);
		m.alt_ind = props.globals.getNode("instrumentation/altimeter/indicated-altitude-ft",1);
		m.alt_mc = props.globals.getNode("autopilot/locks/alt-mach",1);
		m.ap_stat = props.globals.getNode("autopilot/locks/AP-status",1);
		m.app_spd = props.globals.getNode("autopilot/settings/app-speed-kt",1); 
		m.app5_spd = props.globals.getNode("autopilot/settings/app5-speed-kt",1);
		m.app15_spd = props.globals.getNode("autopilot/settings/app15-speed-kt",1);
		m.app35_spd = props.globals.getNode("autopilot/settings/app35-speed-kt",1);
		m.asel = props.globals.getNode("autopilot/settings/asel",1);
		m.climb_kt = props.globals.getNode("autopilot/settings/climb-speed-kt",1);
		m.climb_mc = props.globals.getNode("autopilot/settings/climb-speed-mc",1);
		m.cruise_alt = props.globals.getNode("autopilot/route-manager/cruise/altitude-ft",1);
		m.cruise_kt = props.globals.getNode("autopilot/settings/cruise-speed-kt",1);
		m.cruise_mc = props.globals.getNode("autopilot/settings/cruise-speed-mc",1);
		m.dep_agl = props.globals.getNode("autopilot/settings/dep-agl-limit-ft",1);
		m.dep_lim = props.globals.getNode("autopilot/settings/dep-limit-nm",1);
		m.dep_spd = props.globals.getNode("autopilot/settings/dep-speed-kt",1);
		m.desc_angle = props.globals.getNode("autopilot/settings/descent-angle",1);
		m.desc_kt = props.globals.getNode("autopilot/settings/descent-speed-kt",1);
		m.desc_mc = props.globals.getNode("autopilot/settings/descent-speed-mc",1);
		m.dest_alt = props.globals.getNode("autopilot/route-manager/destination/field-elevation-ft",1);
		m.dist_rem = props.globals.getNode("autopilot/route-manager/distance-remaining-nm",1);
		m.fms = props.globals.getNode("autopilot/settings/fms",1);
    m.gspd = props.globals.getNode("velocities/groundspeed-kt",1);
		m.ind_spd = props.globals.getNode("instrumentation/airspeed-indicator/indicated-speed-kt",1);
		m.lock_alt = props.globals.getNode("autopilot/locks/altitude",1);
		m.nav_dist = props.globals.getNode("autopilot/internal/nav-distance",1);
		m.NAVSRC = props.globals.getNode("autopilot/settings/nav-source",1);
		m.NDSymbols = props.globals.getNode("autopilot/route-manager/vnav", 1);
		m.num = props.globals.getNode("autopilot/route-manager/route/num",1);
    m.tas = props.globals.getNode("instrumentation/airspeed-indicator/true-speed-kt",1);
		m.tg_alt = props.globals.getNode("autopilot/settings/tg-alt-ft",1);
		m.tg_spd_kt = props.globals.getNode("autopilot/settings/target-speed-kt",1);
		m.tg_spd_mc = props.globals.getNode("autopilot/settings/target-speed-mc",1);
		m.tot_dist = props.globals.getNode("autopilot/route-manager/total-distance",1);

    props.globals.initNode("autopilot/settings/fps-limit",-5);

		return m;
	}, # end of new

	listen : func { 

		setlistener(me.active, func(n) {
			if (n.getValue()) {
				me.fp = flightplan();
				me.highest_alt = 0;
				me.update();
				for (var i=0;i<me.fp.getPlanSize();i+=1) {
					if (me.fp.getWP(i).alt_cstr > me.highest_alt){
						me.highest_alt = me.fp.getWP(i).alt_cstr;
					}
				}
				if (me.highest_alt > me.asel.getValue()*100) {
					me.asel.setValue(me.highest_alt/100);
				}
				me.fp.clearWPType('pseudo');
				v_alt.clear();
				me.fpCalc();
			}	else {
				me.fms.setValue(0);
			}
		},0,0);

		setlistener(me.asel, func {
			if (getprop("/instrumentation/efis/cruise-alt") != me.asel.getValue()) {
				setprop("/instrumentation/efis/cruise-alt",me.asel.getValue());
			}
      me.fpChange();
		},0,0);

		setlistener(me.desc_angle, func {
 			if (me.active.getValue()){
				me.fpChange();
      }
		},0,0);     

	}, # end of listen

  fpChange : func {
			if (me.active.getValue()){
				curr_wp = me.fp.current;
				me.fp.clearWPType('pseudo'); # reset TOD
#				for (var i=0;i<me.fp.getPlanSize()-1;i+=1) {
#					var alt = me.fp.getWP(i).alt_cstr;
#					me.fp.getWP(i).setAltitude(alt,'at');
#        }
				v_tod = [];
				v_ind = 0;
				v_alt.clear();
				me.fpCalc();

        ### Aircraft pos ###
  			me.dist_dep = me.tot_dist.getValue()-me.dist_rem.getValue();
        ### Search Current Wp ###
				for (var i=0;i<me.fp.getPlanSize()-1;i+=1) {
          if (me.dist_dep < me.fp.getWP(i).distance_along_route) {
             curr_wp = i;
             break;
          }
        }
				setprop("autopilot/route-manager/current-wp",curr_wp);
			}
  }, # end of fpChange

	fpCalc : func {
		var asel = me.asel.getValue()*100;
		var wp_alt = asel;
		var altWP_curr = 0;
		var altWP_dist = 0;
		var altWP_next = 0;
		var wp_dist = 0;
		var f_dist = 0;
		var leg_dist = 0;
		var tot_dist = me.tot_dist.getValue();
		var tod_dist = tot_dist;
		var tod = 0;
		var flag_tod = 0;
		var flag_wp = 0;
		var topDescent = 0;
		var wp = nil;
		var top_of_descent = 0;
		var desc_spd_kt = getprop("autopilot/settings/descent-speed-kt");
		var desc_spd_mc = getprop("autopilot/settings/descent-speed-mc");
		v_alt.append(0);

		### Calculate altitudes and insert in a vector ###

		for (var i=1;i<me.fp.getPlanSize()-1;i+=1) {
				### Departure ###
			if (me.fp.getWP(i).wp_type == 'basic' and me.fp.getWP(i).distance_along_route < tot_dist/2) {
				if (me.fp.getWP(i).alt_cstr <= 0) {wp_alt = asel}
				else if (me.fp.getWP(i).alt_cstr > 0 and me.fp.getWP(i+1).distance_along_route > tot_dist/2) {wp_alt = asel}
				else {wp_alt = me.fp.getWP(i).alt_cstr}
			} 
				### Navaids ###
			if (me.fp.getWP(i).wp_type == 'navaid') {
				if (me.fp.getWP(i).alt_cstr > 0) { 
					wp_alt = me.fp.getWP(i).alt_cstr;
				}
				else if (me.fp.getWP(i).alt_cstr <= 0 and me.fp.getWP(i-1).wp_type == 'basic') {
					wp_alt = asel;
				} 
			}
				### Approach ###
			if (me.fp.getWP(i).wp_type == 'basic' and me.fp.getWP(i).distance_along_route > tot_dist/2) { 
				if (me.fp.getWP(i).alt_cstr <= 0) {wp_alt = v_alt.vector[i-1]} 
				else {wp_alt = me.fp.getWP(i).alt_cstr}
			} 

			 ### Store Altitudes in a vector ###
			v_alt.append(wp_alt);
		}
		v_alt.append(0); # last for destination

		### TOD Calc ###

		for (var i=1;i<me.fp.getPlanSize()-1;i+=1) {
			if (asel < me.highest_alt) {
				if (v_alt.vector[i] <= 0) {
					for (var j=i;j<me.fp.getPlanSize()-1;j+=1) {
						if (v_alt.vector[j] > 0) {
							v_alt.vector[i] = v_alt.vector[j];					
							break;
						}
					}
				}
			}
			else {
				altWP_curr = v_alt.vector[i];
				f_dist = 	me.fp.getWP(i).distance_along_route;			
				### Search for tod ###
				for (var j=i+1;j<me.fp.getPlanSize()-1;j+=1) {
					if (v_alt.vector[j] < altWP_curr) {
						altWP_next = v_alt.vector[j];
						wp_dist = me.fp.getWP(j).distance_along_route;
						leg_dist = wp_dist - f_dist;
            tod = (altWP_curr-altWP_next)/(math.sin(me.desc_angle.getValue()*D2R)*6074.56);
						### Create tod ###
						if (leg_dist > tod*1.15 and leg_dist > 5) {
							flag_tod = 0;
							top_of_descent = tot_dist-wp_dist+tod;
							tod_dist = wp_dist-tod;
							topdescent = me.fp.pathGeod(me.fp.indexOfWP(me.fp.destination_runway), - top_of_descent);
							wp = createWP(topdescent.lat,topdescent.lon,"TOD",'pseudo');
						}
						break;
					} 					
				}
				### Insert tod in the flightplan ###
						# parabolic functions to calculate TOD position versus ASEL #		
				if (asel <= 420000) {
					var x = 1.5/100000000*math.pow(asel,2)+0.00163*asel + 9.24;
				} else { 
					var x = 6.25/10000000*math.pow(asel,2)+0.039225*asel + 647;
				}
				if (tod_dist < me.fp.getWP(i+1).distance_along_route and flag_tod == 0 and tod_dist > x) {
					me.fp.insertWP(wp,i+1);
					v_alt.insert(i+1,altWP_curr);
					flag_tod = 1;
				}														

				if (me.fp.getWP(i).wp_name == 'TOD') {
					me.prevWp_dist = tot_dist-me.fp.getWP(i).distance_along_route;
					me.prevWp_alt = v_alt.vector[i];
					for (var j=i+1;j<me.fp.getPlanSize()-1;j+=1) {
						if (v_alt.vector[j] < v_alt.vector[i]) {
							me.lastWp_dist = tot_dist-me.fp.getWP(j).distance_along_route;
							me.lastWp_alt = v_alt.vector[j];
							break;
						}
					}
					append(v_tod,me.prevWp_dist);
					append(v_tod,me.lastWp_dist);
					append(v_tod,me.lastWp_alt);
				}
				
				### Calculate intermediates altitudes for VSD ###
				me.altCalc(tot_dist,i);
			}
		}
	}, # end of fpCalc

	altCalc : func (tot_dist,i) {
			var dist_wp = tot_dist - me.fp.getWP(i).distance_along_route;
			if (dist_wp < me.prevWp_dist and dist_wp > me.lastWp_dist) {
				var l = dist_wp-me.lastWp_dist;
				var L = me.prevWp_dist - me.lastWp_dist;
				var h = me.prevWp_alt - me.lastWp_alt;
				alt = l*h/L + me.lastWp_alt;
				v_alt.vector[i] = int(alt);
			}
	}, # end of altCalc

	update : func {
		if (me.fms.getValue()) {
			me.dist_dep = me.tot_dist.getValue()-me.dist_rem.getValue();
			curr_wp = me.fp.current;
			if (curr_wp < 1) {curr_wp=1}
 
				### Takeoff ###
			if (me.lock_alt.getValue() == "VALT" and me.ap_stat.getValue() != "AP") {
				if (me.dist_dep < me.dep_lim.getValue() and me.alt_ind.getValue() < me.dep_agl.getValue()) {
					me.tg_spd_kt.setValue(me.dep_spd.getValue());
				}				
				if (v_alt.vector[curr_wp] > 0) {
					me.set_tgAlt = math.round(v_alt.vector[curr_wp],100);
				} 				
			}

				### En route ###
			if (me.ap_stat.getValue() == "AP") {
				if (left(me.NAVSRC.getValue(),3) == "FMS" and me.lock_alt.getValue() == "VALT") {
					me.cruise_alt.setValue(me.asel.getValue()*100);

          ### Descent Flag ###
          if (v_alt.vector[curr_wp] < v_alt.vector[curr_wp-1] or (v_alt.vector[curr_wp+1] < v_alt.vector[curr_wp] and me.fp.getWP(curr_wp).leg_distance <= 5)) {
          me.desc_flag = 1;
          } else {me.desc_flag = 0}

					### Alarm before TOD ###
					if (me.fp.getWP(curr_wp).wp_name == 'TOD' and me.nav_dist.getValue() >= 0 and me.nav_dist.getValue() < dist_b_tod) {
						alm_tod = 1;
					} else if (size(v_tod) > 0 and me.dist_rem.getValue() <= v_tod[v_ind]+dist_b_tod and  me.dist_rem.getValue() > v_tod[v_ind]){
						alm_tod = 1;
					} else {alm_tod = 0;me.flag_alt = 0}
					if (alm_tod != me.alm_tod.getValue()) {
						me.alm_tod.setValue(alm_tod);
					}

					### Between TOD and last reference Wp ###
					if (size(v_tod) > 0 and me.dist_rem.getValue() <= v_tod[v_ind] and me.dist_rem.getValue() >= v_tod[v_ind+1]) {
						me.tod = 1;
					}
					else {me.tod = 0}

					### Approach
					if (me.dist_rem.getValue() <= 7) {
						me.set_tgAlt = math.round(me.dest_alt.getValue(),100);
						if (me.NAVSRC.getValue() == "FMS1") {
							ind = 0;
							me.NAVSRC.setValue("NAV1");
						}
						if (me.NAVSRC.getValue() == "FMS2") {
							ind = 1;
							me.NAVSRC.setValue("NAV2");
						}

						setprop("instrumentation/nav["~ind~"]/radials/selected-deg",getprop("autopilot/internal/selected-crs")+4);
						citation.set_apr();
					} else {

						### Last Wp reference ###
						if (size(v_tod) > 0 and int(me.dist_rem.getValue()) == int(v_tod[v_ind+1])-1) {
							me.tod = 0;
							me.spd_dist = 0;
							if (v_ind < size(v_tod)-3) {
								v_ind+=3;
							}
						}

						### Setting target altitude ###
						if (!me.tod){
							if (me.dist_rem.getValue() < me.prevWp_dist and me.dist_rem.getValue() > me.lastWp_dist) {
								me.set_tgAlt = math.round(me.lastWp_alt,100);
							} else {
								me.set_tgAlt = math.round(v_alt.vector[curr_wp],100);
							}
						} else {
							me.set_tgAlt = math.round(v_tod[v_ind+2],100);
						}
					}

					### Speed ###

									### Departure ###
					if (me.dist_dep < me.dep_lim.getValue() and me.alt_ind.getValue() < me.dep_agl.getValue()) {
						me.tg_spd_kt.setValue(me.dep_spd.getValue());
					} else if (me.dist_dep < 10) {
							me.tg_spd_kt.setValue(me.climb_kt.getValue());
					} else {
									### Near before TOD ###
						if (me.alm_tod.getValue()) {
							me.tg_spd_mc.setValue(me.desc_mc.getValue());
							me.tg_spd_kt.setValue(me.desc_kt.getValue());
						} else {
									### After tod ###
              if (me.tod) {
                me.tg_spd_mc.setValue(me.desc_mc.getValue());
                me.tg_spd_kt.setValue(me.desc_kt.getValue());
                me.fps_lim();
							} else {
								### Climb ###
								if (me.alt_ind.getValue() < me.tg_alt.getValue()-100) {
									me.tg_spd_mc.setValue(me.climb_mc.getValue());
								  me.tg_spd_kt.setValue(me.climb_kt.getValue());
									### Descent ###
								} else if (me.dist_rem.getValue() <= 20) {
										me.tg_spd_kt.setValue(200);
                    me.fps_lim();
								}	else if (me.desc_flag){
										me.tg_spd_mc.setValue(me.desc_mc.getValue());
										me.tg_spd_kt.setValue(me.desc_kt.getValue());
                    me.fps_lim();
								} else if (me.fp.getWP(curr_wp).wp_name == 'TOD' and me.fp.getWP(curr_wp).leg_distance < 8) {
                    me.tg_spd_mc.setValue(me.tg_spd_mc.getValue());
										me.tg_spd_kt.setValue(me.tg_spd_kt.getValue());
								}	else {
										### Cruise ###
									if (me.cruise_kt.getValue() != 0) {
										if (me.fp.getWP(curr_wp).speed_cstr) {me.cruise_kt.setValue(me.fp.getWP(curr_wp).speed_cstr)}
										else {me.cruise_spd()}
									}
								}	
							}
						}
					}
				}
				if (getprop("controls/flight/flaps")==0.142) {
					me.tg_spd_kt.setValue(me.app5_spd.getValue());
				} else if (getprop("controls/flight/flaps")==0.428) {
					me.tg_spd_kt.setValue(me.app15_spd.getValue());
				} else if (getprop("controls/flight/flaps")==1) {
					me.tg_spd_kt.setValue(me.app35_spd.getValue());
				}
			} # end of AP

			if (me.tg_alt.getValue() != me.set_tgAlt) {
				me.tg_alt.setValue(me.set_tgAlt);
			}
			if (getprop("autopilot/settings/target-altitude-ft") != me.tg_alt.getValue()) {
				setprop("autopilot/settings/target-altitude-ft",me.tg_alt.getValue());
			}
		}
		settimer(func me.update(),0);
	}, # end of update

	cruise_spd : func {
		cruise_kt = me.cruise_kt.getValue();
		cruise_mc = me.cruise_mc.getValue();
		if (me.alt_ind.getValue() <= 7800) {me.vmo = 270}
		if (me.alt_ind.getValue() > 7800 and me.alt_ind.getValue() < 30650) {me.vmo=350}
		if (me.cruise_kt.getValue() >= me.vmo) {cruise_kt = me.vmo}
		if (me.cruise_mc.getValue() > me.mmo) {cruise_mc = me.mmo}
    me.tg_spd_mc.setValue(cruise_mc);
    me.tg_spd_kt.setValue(cruise_kt);
	}, # end of cruise_spd

  fps_lim : func {  ### Descent fps limit ###
    if (me.tod) {me.dist = me.dist_rem.getValue()-v_tod[v_ind+1]}
    else {me.dist = getprop("autopilot/internal/nav-distance")}
    me.fps_limit = -(me.alt_ind.getValue()-me.tg_alt.getValue())/((me.dist)/me.tas.getValue()*3600);
    if (me.fps_limit > 0) me.fps_limit = -5;
    setprop("autopilot/settings/fps-limit",me.fps_limit);
  },# end of fps_lim

}; # end of FMS

var vsd_alt = func { # for VSD
	return (v_alt);
}
###  START ###

var fms_stl = setlistener("sim/signals/fdm-initialized", func {
	var fms = FMS.new();
	fms.listen();
	print("FMS ... Ok");
	removelistener(fms_stl);
},0,0);


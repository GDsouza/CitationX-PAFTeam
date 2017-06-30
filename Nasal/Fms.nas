##########################################
# FMS CLASS - Speed & Altitude Controls
# C. Le Moigne (clm76) - 2017
##########################################

var v_tod = []; # for tod distances and altitudes
var v_ind = 0; # index for v_tod vector
var v_alt = std.Vector.new(); # for wp altitudes

var FMS = {
	new : func {
		var m = {parents:[FMS]};

		m.vmo = 0;
		m.mmo = 0;
		m.tod_constant = 3.0;
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
		m.climb_mc = props.globals.getNode("autopilot/settings/climb-speed-mach",1);
		m.cruise_alt = props.globals.getNode("autopilot/route-manager/cruise/altitude-ft",1);
		m.cruise_kt = props.globals.getNode("autopilot/settings/cruise-speed-kt",1);
		m.cruise_mc = props.globals.getNode("autopilot/settings/cruise-speed-mach",1);
		m.descent_kt = props.globals.getNode("autopilot/settings/descent-speed-kt",1);
		m.descent_mc = props.globals.getNode("autopilot/settings/descent-speed-mach",1);
		m.dep_agl = props.globals.getNode("autopilot/settings/dep-agl-limit-ft",1);
		m.dep_lim = props.globals.getNode("autopilot/settings/dep-limit-nm",1);
		m.dep_spd = props.globals.getNode("autopilot/settings/dep-speed-kt",1);
		m.dest_alt = props.globals.getNode("autopilot/route-manager/destination/field-elevation-ft",1);
		m.dist_rem = props.globals.getNode("autopilot/route-manager/distance-remaining-nm",1);
		m.fms1 = props.globals.getNode("instrumentation/primus2000/sc840/nav1ptr",1);
		m.fms2 = props.globals.getNode("instrumentation/primus2000/sc840/nav1ptr",1);
		m.ind_spd = props.globals.getNode("instrumentation/airspeed-indicator/indicated-speed-kt",1);
		m.lock_alt = props.globals.getNode("autopilot/locks/altitude",1);
		m.nav_dist = props.globals.getNode("autopilot/internal/nav-distance",1);
		m.NAVprop = props.globals.getNode("autopilot/settings/nav-source",1);
		m.num = props.globals.getNode("autopilot/route-manager/route/num",1);
		m.NAVSRC = props.globals.getNode("autopilot/settings/nav-source",1);
		m.NDSymbols = props.globals.getNode("autopilot/route-manager/vnav", 1);
		m.tg_alt = props.globals.getNode("autopilot/settings/tg-alt-ft",1);
		m.tg_spd_kt = props.globals.getNode("autopilot/settings/target-speed-kt",1);
		m.tg_spd_mc = props.globals.getNode("autopilot/settings/target-speed-mach",1);
		m.tot_dist = props.globals.getNode("autopilot/route-manager/total-distance",1);

		return m;
	}, # end of new

	listen : func { 

		setlistener("autopilot/route-manager/active", func(n) {
			if (n.getValue()) {
				me.fp = flightplan();
				me.highest_alt = 0;

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
			}
		});

		setlistener("autopilot/settings/asel", func {
			if (getprop("/instrumentation/efis/cruise-alt") != me.asel.getValue()) {
				setprop("/instrumentation/efis/cruise-alt",me.asel.getValue());
			}
			if (getprop("autopilot/route-manager/active")){
				me.fp.clearWPType('pseudo');
				for (var i=0;i<me.fp.getPlanSize()-1;i+=1) {
					var alt = me.fp.getWP(i).alt_cstr;
					me.fp.getWP(i).setAltitude(alt,'at');
				}
				v_tod = [];
				v_ind = 0;
				v_alt.clear();
				me.fpCalc();
			}
		});

	}, # end of listen

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

		if (asel > 30650) {me.tod_constant = 3.6}
		if (asel <= 30650) {me.tod_constant = 3.0 + desc_spd_kt/1000}
		if (asel <25000) {me.tod_constant = 2.8 + desc_spd_kt/1000}
		if (asel <15000) {me.tod_constant = 2.6 + desc_spd_kt/1000}

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
						tod = (altWP_curr-altWP_next)/1000*me.tod_constant;
						leg_dist = wp_dist - f_dist;
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
			var alm_tod = 0;
			var alt_ind = me.alt_ind.getValue();
			var alt_mc = me.alt_mc.getValue();
			var ap_stat = me.ap_stat.getValue();
			var app_spd = me.app_spd.getValue();
			var app5_spd = me.app5_spd.getValue();
			var app15_spd = me.app15_spd.getValue(); 
			var app35_spd = me.app35_spd.getValue();
			var asel = me.asel.getValue()*100;
			var climb_kt = me.climb_kt.getValue();
			var climb_mc = me.climb_mc.getValue();
			var cruise_kt = me.cruise_kt.getValue();
			var cruise_mc = me.cruise_mc.getValue();
			var curr_wp = me.fp.current;
				if (curr_wp <1) {curr_wp=1}	
			var curr_wp_alt = v_alt.vector[curr_wp];
			var curr_wp_dist = me.fp.getWP(curr_wp).distance_along_route;
			var curr_wp_leg = me.fp.getWP(curr_wp).leg_distance;
			var curr_wp_name = me.fp.getWP(curr_wp).wp_name;
			var curr_wp_spd = me.fp.getWP(curr_wp).speed_cstr;
			var curr_wp_type = me.fp.getWP(curr_wp).wp_type;
			var dep_agl = me.dep_agl.getValue();
			var dep_lim = me.dep_lim.getValue();
			var dep_spd = me.dep_spd.getValue();
			var descent_kt = me.descent_kt.getValue();
			var descent_mc = me.descent_mc.getValue();
			var dest_alt = me.dest_alt.getValue();
			var dist_rem = me.dist_rem.getValue();
			var last_wp_name = me.fp.getWP(curr_wp-1).wp_name;
			var lock_alt = me.lock_alt.getValue();
			var NAVSRC = me.NAVSRC.getValue();
			var num = me.num.getValue();
			var tot_dist = me.tot_dist.getValue();
			var dist_dep = tot_dist-dist_rem;
			var ind_spd = me.ind_spd.getValue();
			var dist_b_tod = 4; # alarm distance before TOD

				### Takeoff ###

			if (lock_alt == "VALT" and ap_stat != "AP") {
				if (dist_dep < dep_lim and alt_ind < dep_agl) {
					me.tg_spd_kt.setValue(dep_spd);
				}				
				if (curr_wp_alt > 0) {
					me.set_tgAlt = math.round(curr_wp_alt,100);
				} 				
			}

				### En route ###
			if (ap_stat == "AP") {
				if (left(NAVSRC,3) == "FMS" and lock_alt == "VALT") {
					me.cruise_alt.setValue(asel);
				
					### Alarm before TOD ###
					if (curr_wp_name == 'TOD' and me.nav_dist.getValue() >= 0 and me.nav_dist.getValue() < dist_b_tod) {
						alm_tod = 1;
					} else if (size(v_tod) > 0 and dist_rem <= v_tod[v_ind]+dist_b_tod and dist_rem > v_tod[v_ind]){
						alm_tod = 1;
					} else {alm_tod = 0;me.flag_alt = 0}
					if (alm_tod != me.alm_tod.getValue()) {
						me.alm_tod.setValue(alm_tod);
					}

					### Between TOD and last reference Wp ###
					if (size(v_tod) > 0 and dist_rem <= v_tod[v_ind] and dist_rem >= v_tod[v_ind+1]) {
						me.tod = 1;
					}
					else {me.tod = 0}

					### Approach
					if (dist_rem <= 7) {
						me.set_tgAlt = math.round(dest_alt,100);
						if (NAVSRC == "FMS1") {
							var ind = 0;
							me.NAVprop.setValue("NAV1");
						}
						if (NAVSRC == "FMS2") {
							var ind = 1;
							me.NAVprop.setValue("NAV2");
						}
						setprop("instrumentation/nav["~ind~"]/radials/selected-deg",int(getprop("autopilot/route-manager/route/wp["~(num-1)~"]/leg-bearing-true-deg")));
						citation.set_apr();
					} else {

						### Last Wp reference ###
						if (size(v_tod) > 0 and int(dist_rem) == int(v_tod[v_ind+1])-1) {
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
							} else {me.set_tgAlt = math.round(curr_wp_alt,100)}
						} else {
							me.set_tgAlt = math.round(v_tod[v_ind+2],100);
						}
					}

					### Speed ###

									### Departure ###
					if (dist_dep < dep_lim and alt_ind < dep_agl) {
						me.tg_spd_kt.setValue(dep_spd);
					} else if (dist_dep < 10) {
							me.tg_spd_kt.setValue(climb_kt);
					} else {
									### Near before TOD ###
						if (me.alm_tod.getValue()) {
								if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
								if (!alt_mc) {me.tg_spd_kt.setValue(descent_kt)}
						} else {
									### After tod ###
							if (size(v_tod) > 0 and dist_rem <= v_tod[v_ind] and dist_rem >= v_tod[v_ind+1]-0.1) {
								if (int(alt_ind) <= me.tg_alt.getValue()+101 and int(alt_ind) > me.tg_alt.getValue()+98) {
									me.spd_dist = dist_rem-v_tod[v_ind+1];
								}
								if (me.spd_dist > 0 and me.spd_dist <= 5 or dist_rem <= 20) {
									if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
									if (!alt_mc) {me.tg_spd_kt.setValue(descent_kt)}
								} else if (me.spd_dist > 5 and dist_rem > 20) {me.cruise_spd()}
							} else {

								### Climb ###
								if (alt_ind < me.tg_alt.getValue()-100) {
									var my_spd = climb_kt;
									if (alt_mc) {
										my_spd = climb_mc;
										me.tg_spd_mc.setValue(my_spd);
									} else {me.tg_spd_kt.setValue(my_spd)}

									### Descent ###
								} else if (dist_rem <= 20) {
										me.tg_spd_kt.setValue(200);
								}	else if (alt_ind > me.tg_alt.getValue()+100){
										if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
										if (!alt_mc) {me.tg_spd_kt.setValue(descent_kt)}
#								} else if (curr_wp_name != 'TOD' and curr_wp_type == 'basic' and curr_wp_dist > tot_dist/2 and curr_wp_leg < 8) {
#										if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
#										if (!alt_mc) {me.tg_spd_kt.setValue(descent_kt)}
								} else if (curr_wp_name == 'TOD' and curr_wp_leg < 8) {
										if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
										if (!alt_mc) {
											var tg_spd = me.tg_spd_kt.getValue();
											me.tg_spd_kt.setValue(tg_spd);
										}
								}	else {

										### Cruise ###
									if (cruise_kt != 0) {
										if (curr_wp_spd) {me.cruise_kt.setValue(curr_wp_spd)}
										else {me.cruise_spd()}
									}
								}	
							}
						}
					}
				}
				if (getprop("controls/flight/flaps")==0.142) {
					me.tg_spd_kt.setValue(app5_spd);
				} else if (getprop("controls/flight/flaps")==0.428) {
					me.tg_spd_kt.setValue(app15_spd);
				} else if (getprop("controls/flight/flaps")==1) {
					me.tg_spd_kt.setValue(app35_spd);
				}
			} # end of AP

			if (me.tg_alt.getValue() != me.set_tgAlt) {
				me.tg_alt.setValue(me.set_tgAlt);
			}
			if (getprop("autopilot/settings/target-altitude-ft") != me.tg_alt.getValue()) {
				setprop("autopilot/settings/target-altitude-ft",me.tg_alt.getValue());
			}

	}, # end of update
	
	cruise_spd : func {
		var cruise_kt = me.cruise_kt.getValue();
		var cruise_mc = me.cruise_mc.getValue();
		if (me.alt_ind.getValue() <= 7800) {me.vmo = 270}
		if (me.alt_ind.getValue() > 7800 and me.alt_ind.getValue() < 30650) {me.vmo=350}
		if (me.cruise_kt.getValue() >= me.vmo) {cruise_kt = me.vmo-10}
		if (me.cruise_mc.getValue() >= me.mmo) {cruise_mc = me.mmo-6}
		if (me.alt_mc.getValue()) {
			me.mmo = 0.92;
			me.tg_spd_mc.setValue(cruise_mc);
		}
		if (!me.alt_mc.getValue()) {me.tg_spd_kt.setValue(cruise_kt)}
	}, # end of cruise_spd

}; # end of FMS

var vsd_alt = func { # for VSD
	return (v_alt);
}
###  START ###

var fms = FMS.new();

var fms_stl = setlistener("sim/signals/fdm-initialized", func {
	settimer(update_fms,0);
	fms.listen();
	removelistener(fms_stl);
});

var update_fms = func {
		if (getprop("autopilot/route-manager/active") and getprop("autopilot/settings/fms")){
			fms.update();
		}
    settimer(update_fms,0);
}

##########################################
# FMS CLASS - Speed & Altitude Controls
# C. Le Moigne (clm76) - 2017
##########################################

var v_tod = []; # for tod distances and altitudes
var v_ind = 0; # index for v_tod vector

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

		m.spd_dist = 0;
		m.tod = 0;
		m.flag_alt = 0;

		return m;
	}, # end of new

	listen : func { 

		setlistener("autopilot/route-manager/active", func(n) {
			if (n.getValue()) {
				me.fp = flightplan();
				me.fp_clone = me.fp.clone();
				me.nvd = 0;
				me.highest_alt = 0;

				for (var i=0;i<me.fp.getPlanSize();i+=1) {
					if (me.fp.getWP(i).wp_type == "navaid") {
						if (!me.nvd) {me.nvd = 1}
					}
					if (me.fp.getWP(i).alt_cstr > me.highest_alt){
						me.highest_alt = me.fp.getWP(i).alt_cstr;
					}
				}
				if (me.highest_alt > me.asel.getValue()*100) {
					me.asel.setValue(me.highest_alt/100);
				}
				me.fp.clearWPType('pseudo');
				me.fpCalc();
			}
		});

		setlistener("autopilot/settings/asel", func {
			if (getprop("/instrumentation/efis/cruise-alt") != me.asel.getValue()) {
				setprop("/instrumentation/efis/cruise-alt",me.asel.getValue());
			}
			if (me.fp != nil){
				me.fp.clearWPType('pseudo');
				for (var i=0;i<me.fp_clone.getPlanSize()-1;i+=1) {
					var alt = me.fp_clone.getWP(i).alt_cstr;
					me.fp.getWP(i).setAltitude(alt,'at');
				}
				v_tod = [];
				v_ind = 0;
				me.fpCalc();
				me.flag_alt = 0;
			}
		});

	}, # end of listen

	fpCalc : func {
		var asel = me.asel.getValue()*100;
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
		var flag_alt = 0; # flag for approach wp
		var topDescent = 0;
		var wp = nil;
		var top_of_descent = 0;

		if (asel <35000) me.tod_constant = 3.3; 
		if (asel <25000) me.tod_constant = 3.2; 
		if (asel <15000) me.tod_constant = 2.8;

		for (var i=1;i<me.fp.getPlanSize()-1;i+=1) {
				### Wp departure without altitude constraint
			if (me.fp_clone.getWP(i).alt_cstr <= 0 and me.fp.getWP(i).wp_type == 'basic' and me.fp.getWP(i).distance_along_route < tot_dist/2) { 
				me.fp.getWP(i).setAltitude(asel,'at');
			}
				### Navaids without altitude constraint
			if (me.fp_clone.getWP(i).alt_cstr <= 0 and me.fp.getWP(i).wp_type != 'basic') { 
				me.fp.getWP(i).setAltitude(asel,'at');
			}
		}

		for (var i=1;i<me.fp.getPlanSize()-1;i+=1) {
			if (asel < me.highest_alt) {break}
			else {

 				### Plan with navaids ###
				if (me.nvd) {
					if (me.fp.getWP(i).wp_type == 'navaid'or me.fp.getWP(i+1).wp_type == 'navaid') {
						if (me.fp.getWP(i).alt_cstr == asel ) {
							altWP_curr = asel;
							f_dist = 	me.fp.getWP(i).distance_along_route;			
							for (var j=i;j<me.fp.getPlanSize()-1;j+=1) {

									### Search for tod ###
								if (me.fp.getWP(j).alt_cstr < asel and me.fp.getWP(j).alt_cstr > 0) {
									altWP_next = me.fp.getWP(j).alt_cstr;
									wp_dist = me.fp.getWP(j).distance_along_route;
									tod = (altWP_curr-altWP_next)/1000*me.tod_constant;
									leg_dist = wp_dist - f_dist;

									### Create tod ###
									if (leg_dist > tod*1.25) {
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
							if (tod_dist < me.fp.getWP(i+1).distance_along_route and flag_tod == 0) {
								me.fp.insertWP(wp,i+1);
								me.fp.getWP(i+1).setAltitude(altWP_curr,'at');
								flag_tod = 1;
							}														

						} else if (me.fp.getWP(i+1).alt_cstr < me.fp.getWP(i).alt_cstr) {
							altWP_next = me.fp.getWP(i+1).alt_cstr;
							altWP_curr = me.fp.getWP(i).alt_cstr;
							tod = (altWP_curr-altWP_next)/1000*me.tod_constant;
							wp_dist = me.fp.getWP(i+1).distance_along_route;
							leg_dist = me.fp.getWP(i+1).leg_distance;
							if (leg_dist > tod*1.25) {
								top_of_descent = tot_dist-wp_dist+tod;
								topdescent = me.fp.pathGeod(me.fp.indexOfWP(me.fp.destination_runway), - top_of_descent);
								wp = createWP(topdescent.lat,topdescent.lon,"TOD",'pseudo');
								me.fp.insertWP(wp,i+1);
								me.fp.getWP(i+1).setAltitude(altWP_curr,'at');
								i+=1;
							}
						}
						if (me.fp.getWP(i).wp_name == 'TOD') {
							me.prevWp_dist = tot_dist-me.fp.getWP(i).distance_along_route;
							me.prevWp_alt = me.fp.getWP(i).alt_cstr;
							for (var j=i;j<me.fp.getPlanSize()-1;j+=1) {
								if (me.fp.getWP(j+1).alt_cstr < me.fp.getWP(i).alt_cstr) {
									me.lastWp_dist = tot_dist-me.fp.getWP(j+1).distance_along_route;
									me.lastWp_alt = me.fp.getWP(j+1).alt_cstr;
									break;
								}
							}
							append(v_tod,me.prevWp_dist);
							append(v_tod,me.lastWp_dist);
							append(v_tod,me.lastWp_alt);
						}

								### Intermediates altitudes calc ###
						me.altCalc(tot_dist,i);
					}	

				} else {

				### Plan without navaids ###
					if (me.fp.getWP(i+1).alt_cstr < me.fp.getWP(i).alt_cstr) {
						if (asel < me.highest_alt) {
							var altWP_curr = me.highest_alt;
						} else {
							var altWP_curr = asel;
						}
						if (me.fp.getWP(i).wp_type == 'basic' 
							and me.fp.getWP(i+1).alt_cstr <= 0 
							and me.fp.getWP(i+1).distance_along_route > tot_dist/2) {
							for (var j=i+1;j<me.fp.getPlanSize()-1;j+=1) {
								altWP_next = me.fp.getWP(j).alt_cstr;
								if (altWP_next > 0) {
									wp_dist = me.fp.getWP(j).distance_along_route;
									break;
								}
							}
						} else {
							var altWP_next = me.fp.getWP(i+1).alt_cstr;
							var wp_dist = me.fp.getWP(i+1).distance_along_route;
						}
						var tod = (altWP_curr-altWP_next)/1000*me.tod_constant;
						if (me.fp.getWP(i+1).leg_distance > tod*1.25) {
							top_of_descent = tot_dist-wp_dist+tod;
							var topdescent = me.fp.pathGeod(me.fp.indexOfWP(me.fp.destination_runway), - top_of_descent);
							var wp = createWP(topdescent.lat,topdescent.lon,"TOD",'pseudo');
							me.fp.insertWP(wp,i+1);
							me.fp.getWP(i+1).setAltitude(altWP_curr,'at');
						}
					}
				}

				### Approach ###
				if (me.fp.getWP(i).alt_cstr > 0 and me.fp.getWP(i+1).alt_cstr <= 0 and me.flag_alt == 0) { 
					me.prevWp_dist = tot_dist-me.fp.getWP(i).distance_along_route;
					me.prevWp_alt = me.fp.getWP(i).alt_cstr;
					me.prevWp_ind = i;
					for (var j=i+1;j<me.fp.getPlanSize()-1;j+=1) {
						if (me.fp.getWP(j).alt_cstr > 0) {
							wp_dist = me.fp.getWP(j).distance_along_route;
							me.lastWp_dist = tot_dist-wp_dist;
							me.lastWp_alt = me.fp.getWP(j).alt_cstr;
							me.lastWp_ind = j;
							break;
						}
					}
					for (var n = me.prevWp_ind+1;n<me.lastWp_ind;n+=1) {
						me.altCalc(tot_dist,n);
					}
					me.flag_alt = 1; # only ounce
				}
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
				me.fp.getWP(i).setAltitude(alt,'at');
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
				if (curr_wp <1) {curr_wp=1};		
			var curr_wp_alt = me.fp.getWP(curr_wp).alt_cstr;
				if (curr_wp_alt < 0) {curr_wp_alt = 0}
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
				
					### 5 nm before TOD ###
					if (curr_wp_name == 'TOD' and me.nav_dist.getValue() >= 0 and me.nav_dist.getValue() < 5) {
						alm_tod = 1;
					} else if (size(v_tod) > 0 and dist_rem <= v_tod[v_ind]+5 and dist_rem > v_tod[v_ind]){
						alm_tod = 1;
					} else {alm_tod = 0}
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
						if (curr_wp_alt > 0) {
							if (!me.tod){
								if (me.dist_rem.getValue() < me.prevWp_dist and me.dist_rem.getValue() > me.lastWp_dist) {
									me.set_tgAlt = math.round(me.lastWp_alt,100);
								} else {me.set_tgAlt = math.round(curr_wp_alt,100)}
							} else {
								me.set_tgAlt = v_tod[v_ind+2];
							}
						} else {
							for (var i=curr_wp;i<num;i+=1) {
								if (me.fp.getWP(i).alt_cstr > 0) {
									me.set_tgAlt = math.round(me.fp.getWP(i).alt_cstr,100);
									break;
								} else {me.set_tgAlt = math.round(dest_alt,100)}
							}
						}
					}

					### Speed ###

									### Departure ###
					if (dist_dep < dep_lim and alt_ind < dep_agl) {
						me.tg_spd_kt.setValue(dep_spd);
					} else if (dist_dep < 10) {
							me.tg_spd_kt.setValue(climb_kt);
					} else {
									### 5 nm before TOD ###
						if (me.alm_tod.getValue()) {
								if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
								if (!alt_mc) {me.tg_spd_kt.setValue(descent_kt)}
						} else {
									### after tod ###
							if (size(v_tod) > 0 and dist_rem <= v_tod[v_ind] and dist_rem >= v_tod[v_ind+1]-1) {
								if (int(alt_ind) <= me.tg_alt.getValue()+501 and int(alt_ind) > me.tg_alt.getValue()+498) {
									me.spd_dist = dist_rem-v_tod[v_ind+1];
								}
								if (me.spd_dist > 0 and me.spd_dist <= 5) {
									if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
									if (!alt_mc) {me.tg_spd_kt.setValue(descent_kt)}
								} else if (me.spd_dist > 5) {
									me.cruise_spd();
								}
							} else {

								### Climb ###
								if (me.tg_alt.getValue() > alt_ind+1000) {
									var my_spd = climb_kt;
									if (alt_mc) {
										my_spd = climb_mc;
										me.tg_spd_mc.setValue(my_spd);
									} else {
											me.tg_spd_kt.setValue(my_spd);
									}
									### Descent ###
								} else if (me.tg_alt.getValue() < alt_ind-1000) {
										if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
										if (!alt_mc) {me.tg_spd_kt.setValue(descent_kt)}
								} else if (curr_wp_name != 'TOD' and curr_wp_type == 'basic' and curr_wp_dist > tot_dist/2) {
										if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
										if (!alt_mc) {me.tg_spd_kt.setValue(descent_kt)}
								}	else {
										### Cruise ###
									if (cruise_kt != 0) {
										if (curr_wp_spd) {
											me.cruise_kt.setValue(curr_wp_spd);
										} else {
											me.cruise_spd()
										}
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

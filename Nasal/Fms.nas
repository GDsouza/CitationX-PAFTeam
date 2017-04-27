##########################################
# FMS CLASS - Speed & Altitude Controls
# C. Le Moigne (clm76) - 2017
##########################################

var FMS = {
	new : func {
		var m = {parents:[FMS]};

		m.top_of_descent = 0;
		m.vmo = 0;
		m.mmo = 0;
		m.tod_constant = 3.4;
		m.set_tgAlt = 0;
		m.fp = nil; # flightplan

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

		m.tod_ind = 0;

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
				me.fpCalc();
			}
		});

	}, # end of listen

	fpCalc : func {
		var asel = me.asel.getValue()*100;
		var altWP_curr = 0;
		var altWP_dist = 0;
		var altWP_next = 0;
		var wp_dist = 0;

		if (asel <35000) me.tod_constant = 3.3;
		if (asel <25000) me.tod_constant = 3.2;
		if (asel <15000) me.tod_constant = 3.1;

		for (var i=1;i<me.fp.getPlanSize()-1;i+=1) {
				### Wp departure without altitude constraint
			if (me.fp_clone.getWP(i).alt_cstr <= 0 and me.fp.getWP(i).distance_along_route < me.tot_dist.getValue()/2) { 
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
				if (me.nvd) {var type_wp = "navaid"}
				else {var type_wp = "basic"}
				if (me.fp.getWP(i+1).alt_cstr < me.fp.getWP(i).alt_cstr) {
					if (asel < me.highest_alt) {
						altWP_curr = me.highest_alt;
					} else {
						if (me.nvd) {
							altWP_curr = me.fp.getWP(i).alt_cstr; #fp with navaid
						} 
						else {altWP_curr = asel} # fp without navaid
					}
					if (me.fp.getWP(i).wp_type == type_wp and me.fp.getWP(i+1).alt_cstr <= 0 
						and me.fp.getWP(i+1).distance_along_route > me.tot_dist.getValue()/2) {
						for (var j=i+1;j<me.fp.getPlanSize()-1;j+=1) {
							altWP_next = me.fp.getWP(j).alt_cstr;
							if (altWP_next > 0) {
								wp_dist = me.fp.getWP(j).distance_along_route;
								break;
							}
						}
					} else {
						altWP_next = me.fp.getWP(i+1).alt_cstr;
						wp_dist = me.fp.getWP(i+1).distance_along_route;
					}
					var tod = (altWP_curr-altWP_next)/1000*me.tod_constant;
					if (me.fp.getWP(i+1).leg_distance > tod*1.25) {
						me.top_of_descent = me.tot_dist.getValue()-wp_dist+tod;
						var topdescent = me.fp.pathGeod(me.fp.indexOfWP(me.fp.destination_runway), - me.top_of_descent);
						var wp = createWP(topdescent.lat,topdescent.lon,"TOD",'pseudo');
						me.fp.insertWP(wp,i+1);
						me.fp.getWP(i+1).setAltitude(altWP_curr,'at');
						if (me.nvd) {i+=1}
					}
					if (!me.nvd) {break}
				}
			}
		}
	}, #end of fpCalc

	update : func {
			var alm_tod =0;
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
					if (curr_wp_name == 'TOD' and int(me.nav_dist.getValue()) < 5) {
						alm_tod = 1;
					} else {alm_tod = 0}
					if (alm_tod != me.alm_tod.getValue()) {
						me.alm_tod.setValue(alm_tod);
					}

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
						if (curr_wp_alt > 0){
							me.set_tgAlt = math.round(curr_wp_alt,100);
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
								else {me.tg_spd_kt.setValue(descent_kt)}
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
							}	else {
									### Cruise ###
								if (cruise_kt != 0) {
									if (curr_wp_spd) {
										me.cruise_kt.setValue(curr_wp_spd);
									}	
									if (curr_wp_name != 'TOD' and curr_wp_type == 'basic' and curr_wp_dist > tot_dist/2) {
										me.tg_spd_kt.setValue(descent_kt);
									} else {
										if (alt_ind <= 7800) {me.vmo = 270}
										if (alt_ind > 7800 and alt_ind < 30650) {me.vmo=350}
										if (alt_mc) {me.mmo = 0.92}
										if (cruise_kt >= me.vmo) {cruise_kt = me.vmo-5}
										if (cruise_mc >= me.mmo) {cruise_mc = me.mmo-6}
										me.tg_spd_kt.setValue(cruise_kt);			
										me.tg_spd_mc.setValue(cruise_mc);	
									}
								}
							}	
						}
					}
				}
				if (NAVSRC == "NAV1" or NAVSRC == "NAV2") {
					if (getprop("controls/flight/flaps")==0.142) {
						me.tg_spd_kt.setValue(app5_spd);
					} else if (getprop("controls/flight/flaps")==0.428) {
						me.tg_spd_kt.setValue(app15_spd);
					} else if (getprop("controls/flight/flaps")==1) {
						me.tg_spd_kt.setValue(app35_spd);
					}	else {me.tg_spd_kt.setValue(app_spd)}
				}			
			} # end of AP

			if (me.tg_alt.getValue() != me.set_tgAlt) {
				me.tg_alt.setValue(me.set_tgAlt);
			}
			if (getprop("autopilot/settings/target-altitude-ft") != me.tg_alt.getValue()) {
				setprop("autopilot/settings/target-altitude-ft",me.tg_alt.getValue());
			}

	}, # end of update

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

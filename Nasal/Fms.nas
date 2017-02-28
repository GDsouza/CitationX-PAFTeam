##########################################
# FMS CLASS - Speed & Altitude Controls
# C. Le Moigne (clm76) - 2017
##########################################

var FMS = {
	new : func {
		var m = {parents:[FMS]};

		m.set_tgAlt = 0;
		m.top_of_descent = 0;
		m.flag_kt = 0;
		m.flag_mc = 0;
		m.flag_navaid = 0;
		m.vmo = 0;
		m.mmo = 0;
		m.tod_constant = 3.3;
		m.app_wp = "autopilot/route-manager/route/wp[";

		m.lock_alt = props.globals.getNode("autopilot/locks/altitude",1);
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
		m.NAVprop = props.globals.getNode("autopilot/settings/nav-source",1);
		m.num = props.globals.getNode("autopilot/route-manager/route/num",1);
		m.NAVSRC = props.globals.getNode("autopilot/settings/nav-source",1);
		m.NDSymbols = props.globals.getNode("autopilot/route-manager/vnav", 1);
		m.tg_alt = props.globals.getNode("autopilot/settings/target-altitude-ft",1);
		m.tg_spd_kt = props.globals.getNode("autopilot/settings/target-speed-kt",1);
		m.tg_spd_mc = props.globals.getNode("autopilot/settings/target-speed-mach",1);
		m.TOD = props.globals.getNode("autopilot/locks/TOD",1);
		m.tot_dist = props.globals.getNode("autopilot/route-manager/total-distance",1);

		return m;
	}, # end of new

	listen : func { # search for the highest Navaid if exist
		setlistener("autopilot/route-manager/active", func(n) {
			var fp_activ = n.getValue();
			if (fp_activ) {
				me.fp = flightplan();
				me.highest_alt = 0;
				me.highest_ind = 0;
				for (var i=0;i<me.fp.getPlanSize();i+=1) {
					if (me.fp.getWP(i).wp_type == "navaid") {
						if (me.fp.getWP(i).alt_cstr > me.highest_alt){
							me.highest_alt = me.fp.getWP(i).alt_cstr;
							me.highest_ind = i;
						}
					}
				}
			}
		});
	}, # end of listen

	update : func {
			var alt_ind = me.alt_ind.getValue();
			var alt_mc = me.alt_mc.getValue();
			var alt_tod = me.alt_ind.getValue()/100;
			var ap_stat = me.ap_stat.getValue();
			var app_spd = me.app_spd.getValue();
			var app5_spd = me.app5_spd.getValue();
			var app15_spd = me.app15_spd.getValue();
			var app35_spd = me.app35_spd.getValue();
			var asel = me.asel.getValue();
			var climb_kt = me.climb_kt.getValue();
			var climb_mc = me.climb_mc.getValue();
			var cruise_kt = me.cruise_kt.getValue();
			var cruise_mc = me.cruise_mc.getValue();
			var curr_wp = me.fp.current;
				if (curr_wp <1) {curr_wp=1};		
			var curr_wp_alt = me.fp.getWP(curr_wp).alt_cstr;
			var curr_wp_dist = me.fp.getWP(curr_wp).distance_along_route;
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
			var tg_alt = me.tg_alt.getValue();
			var TOD = me.TOD.getValue();
			var tot_dist = me.tot_dist.getValue();
			var dist_dep = tot_dist-dist_rem;
			var top_of_descent = me.top_of_descent;

			### TOD init ###
			if (alt_tod <350) me.tod_constant = 3.2;
			if (alt_tod <250) me.tod_constant = 3.1;
			if (alt_tod <150) me.tod_constant = 3.0;

			if (me.highest_ind == 0) { 	# no Navaids
				top_of_descent = (asel*100-dest_alt)/1000*me.tod_constant;
			} else { 										# with Navaids
				if (asel*100 < me.highest_alt) {
					me.asel.setValue(me.highest_alt/100);
				}
				me.alt_cstr = me.highest_alt;
				me.wp_dist = me.fp.getWP(me.highest_ind).distance_along_route;
				top_of_descent = tot_dist-me.wp_dist+(asel*100- me.alt_cstr)/1000*me.tod_constant;
			}

			setprop("autopilot/locks/TOD-dist",top_of_descent);
			var topDescent = me.fp.pathGeod(me.fp.indexOfWP(me.fp.destination_runway), - top_of_descent);
			var tdNode = me.NDSymbols.getNode("td", 1);
			tdNode.getNode("longitude-deg", 1).setValue(topDescent.lon);
			tdNode.getNode("latitude-deg", 1).setValue(topDescent.lat);

				### Takeoff ###
			if (lock_alt == "VALT") {
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
					me.cruise_alt.setValue(asel*100);

						### Before TOD ###
					if (!TOD) {						
						if (dist_rem <= top_of_descent) {
							TOD = 1;
							setprop("autopilot/locks/TOD",TOD);
						}
						if (curr_wp_alt > 0) {
							if (curr_wp_dist < tot_dist-top_of_descent) {
								me.set_tgAlt = math.round(curr_wp_alt,100);
							} else {me.set_tgAlt = asel*100}
						}
						else {me.set_tgAlt = asel*100}
		
						### After TOD ###
					} else {				
						if (curr_wp_alt > 0){
						me.set_tgAlt = math.round(curr_wp_alt,100);
						} else {
							if (curr_wp_type == "navaid") {
								me.set_tgAlt = me.fp.getWP(curr_wp -1).alt_cstr;
							} else {
								for (var i=curr_wp;i<=(num-1);i+=1) {
									if (getprop(me.app_wp~i~"]/altitude-ft") > 0) {
										me.set_tgAlt = math.round(getprop(me.app_wp~i~"]/altitude-ft"),100);
										break;
									} else {me.set_tgAlt = math.round(dest_alt,100)}
								}
							}
						}
					}
					if (dist_rem <= 7) {
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
					}

					### Speed ###

									### Departure ###
					if (dist_dep < dep_lim and alt_ind < dep_agl) {
						me.tg_spd_kt.setValue(dep_spd);
					} else {		


									### After TOD ###
						if (TOD) {
							if (getprop("autopilot/locks/alm-tod")) {
								setprop("autopilot/locks/alm-tod",0);
							}
							if (curr_wp_type == "navaid" and curr_wp_alt <= 0) {
								if (alt_mc) {me.tg_spd_mc.setValue(cruise_mc)}
								else {me.tg_spd_kt.setValue(cruise_kt)}
							} else {
								if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
								else {
									if (getprop("controls/flight/flaps")==0.0428) {
										me.tg_spd_kt.setValue(app_spd);
									} else if (getprop("controls/flight/flaps")==0.142) {
										me.tg_spd_kt.setValue(app5_spd);
									} else if (getprop("controls/flight/flaps")==0.428) {
										me.tg_spd_kt.setValue(app15_spd);
									} else if (getprop("controls/flight/flaps")==1) {
										me.tg_spd_kt.setValue(app35_spd);
									}	else {me.tg_spd_kt.setValue(descent_kt)}
								}
							}
						} else {

								### Climb ###
							if (tg_alt > alt_ind+1000) {
								var my_spd = climb_kt;
								if (alt_mc) {
									my_spd = climb_mc;
									me.tg_spd_mc.setValue(my_spd);
								} else {
										me.tg_spd_kt.setValue(my_spd);
								}

								### Descent ###
							} else if (tg_alt < alt_ind-1000) {
									if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
									if (!alt_mc) {me.tg_spd_kt.setValue(descent_kt)}
							}	else {

								### 5 nm before TOD ###
								if (dist_rem <= top_of_descent + 5) {
									if (!getprop("autopilot/locks/alm-tod")) {
										setprop("autopilot/locks/alm-tod",1);
									}
									if (alt_mc) {me.tg_spd_mc.setValue(descent_mc)}
									else {me.tg_spd_kt.setValue(descent_kt)}
								} else {

									### Cruise ###
									if (cruise_kt != 0) {
										if (curr_wp_spd) {
											me.cruise_kt.setValue(curr_wp_spd);
										}	
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
			if (tg_alt != me.set_tgAlt) {me.tg_alt.setValue(me.set_tgAlt)}
			setprop("/instrumentation/efis/cruise-alt",asel);

	}, # end of update

}; # end of FMS


###  START ###

var fms = FMS.new();

setlistener("sim/signals/fdm-initialized", func {
	settimer(update_fms,0);
	fms.listen();
});

var update_fms = func {
		if (getprop("autopilot/route-manager/active") and getprop("autopilot/settings/fms")){
			fms.update();
		}
    settimer(update_fms,0);
}

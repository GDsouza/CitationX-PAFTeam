##########################################
# FMS CLASS - Speed & Altitude Controls
# C. Le Moigne (clm76) - 2017
##########################################

var FMS = {
	new : func {
		var m = {parents:[FMS]};

		m.top_of_descent = 0;
		m.flag_almTod = 0;
		m.flag_navaid = 0;
		m.vmo = 0;
		m.mmo = 0;
		m.tod_constant = 3.4;
		m.current_wp = 0;
		m.set_tgAlt = 0;

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
		m.NAVprop = props.globals.getNode("autopilot/settings/nav-source",1);
		m.num = props.globals.getNode("autopilot/route-manager/route/num",1);
		m.NAVSRC = props.globals.getNode("autopilot/settings/nav-source",1);
		m.NDSymbols = props.globals.getNode("autopilot/route-manager/vnav", 1);
		m.tg_alt = props.globals.getNode("autopilot/settings/tg-alt-ft",1);
		m.tg_spd_kt = props.globals.getNode("autopilot/settings/target-speed-kt",1);
		m.tg_spd_mc = props.globals.getNode("autopilot/settings/target-speed-mach",1);
		m.TOD = props.globals.getNode("autopilot/locks/TOD",1);
		m.TOD_dist = props.globals.getNode("autopilot/locks/TOD-dist",1);
		m.TOD_dist.setValue(0);
		m.tot_dist = props.globals.getNode("autopilot/route-manager/total-distance",1);

		m.tod_ind = 0;

		return m;
	}, # end of new

	listen : func { # search for the highest navaid

		setlistener("autopilot/route-manager/active", func(n) {
			if (n.getValue()) {
				me.fp = flightplan();
				me.first_nvd = 0;
				var highest_alt = 0;
				var first_app = 0;
				for (var i=0;i<me.fp.getPlanSize();i+=1) {
					if (me.fp.getWP(i).wp_type == "navaid") {
						if (me.first_nvd == 0) {
							me.first_navaid = i;
							me.first_nvd = 1;
						}
						if (me.fp.getWP(i).alt_cstr > highest_alt){
							highest_alt = me.fp.getWP(i).alt_cstr;
						}
					} else if (me.fp.getWP(i).wp_type == "basic" and me.fp.getWP(i).distance_along_route > me.tot_dist.getValue()/2) {
				 		if(first_app == 0) {
							me.first_app = i;
							first_app = 1;
						}
					}
				}
				if (highest_alt > me.asel.getValue()*100) {
					me.asel.setValue(highest_alt/100);
				}
			}
		});

		setlistener("autopilot/settings/asel", func {
			if (getprop("/instrumentation/efis/cruise-alt") != me.asel.getValue()) {
				setprop("/instrumentation/efis/cruise-alt",me.asel.getValue());
			}
		});

	}, # end of listen

	update : func {
			var alm_tod = me.alm_tod.getValue();
			var alt_ind = me.alt_ind.getValue();
			var alt_mc = me.alt_mc.getValue();
			var alt_tod = me.alt_ind.getValue()/100;
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
			var TOD = me.TOD.getValue();
			var tot_dist = me.tot_dist.getValue();
			var dist_dep = tot_dist-dist_rem;

			### TOD init ###
			if (alt_tod <350) me.tod_constant = 3.3;
			if (alt_tod <250) me.tod_constant = 3.2;
			if (alt_tod <150) me.tod_constant = 3.1;
		
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

				if (TOD and me.flag_navaid == 0) {
					me.current_wp = curr_wp;
					me.flag_navaid = 1;
				}

				if (TOD and me.current_wp != curr_wp) {# reinit TOD
					if (me.dist_rem.getValue() > 50 ) {
						me.TOD.setValue(0);
						TOD = 0;
						me.flag_navaid = 0;
						me.current_wp = 0;
					} 
				}

						### Before TOD ###
					if (!TOD) {						
						if (int(dist_rem) == int(me.top_of_descent)) {
							me.TOD.setValue(1);
						}
						if (curr_wp_type == "navaid") { # Fp with navaids
							if (curr_wp_alt > 0) {
										# First navaid
								if (curr_wp == me.first_navaid) {
									if (curr_wp_alt < asel) {																		
										var alt_cstr = me.fp.getWP(curr_wp).alt_cstr;
										var tod = (asel- alt_cstr)/1000*me.tod_constant;
										if (me.fp.getWP(curr_wp).leg_distance < tod*2) {
											me.set_tgAlt = math.round(curr_wp_alt,100);
										} else {
											me.set_tgAlt = asel;
											me.todCalc(curr_wp,tot_dist,me.set_tgAlt);
										}
									} else {
										me.set_tgAlt = math.round(curr_wp_alt,100);
									}
										# Other navaids
								} else {
									if (curr_wp_alt < me.set_tgAlt) { # descent
										var alt_cstr = me.fp.getWP(curr_wp).alt_cstr;
										var tod = (me.set_tgAlt- alt_cstr)/1000*me.tod_constant;
										if (me.fp.getWP(curr_wp).leg_distance < tod*2) {
											me.set_tgAlt = math.round(curr_wp_alt,100);
										} else {
											me.todCalc(curr_wp,tot_dist,me.set_tgAlt);
										}
									} else {
										me.set_tgAlt = math.round(curr_wp_alt,100);
									}
								}

										# Navaids without altitude constraint
							}	else { 
							 	if (me.fp.getWP(curr_wp+1).alt_cstr > 0) {
									me.set_tgAlt = asel;
									me.todNew(curr_wp+1);
								} else {
									me.set_tgAlt = asel;
								}
							}
									 # Out of navaids
						} else {
								### Take off ###
							if (me.fp.getWP(curr_wp).distance_along_route < tot_dist/2) {
								if (curr_wp_alt > 0) {
									me.set_tgAlt = math.round(curr_wp_alt,100);
								} else {me.set_tgAlt = asel}
							} else {
								### Descent ###
								if (curr_wp_alt > 0) {
									if (me.first_app and !me.first_nvd) {
										me.todNew(curr_wp);
									} else {
										me.set_tgAlt = math.round(curr_wp_alt,100);
										me.TOD.setValue(1);
									}								
								} else {
									me.set_tgAlt = asel;
									me.todNew(curr_wp);
								}
							}
						}
									# Advertising TOD
						if (alm_tod) {
							if (alt_ind < me.tg_alt.getValue() and !me.flag_almTod) {
								me.set_tgAlt = math.round(me.tg_alt.getValue(),100);
								me.flag_almTod = 1;
							}
						}
		
						### After TOD ###
					} else {				
						me.flag_almTod = 0;
						me.alm_tod.setValue(0);
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
					}

					### Speed ###

									### Departure ###
					if (dist_dep < dep_lim and alt_ind < dep_agl) {
						me.tg_spd_kt.setValue(dep_spd);
					} else if (dist_dep < 10) {
								me.tg_spd_kt.setValue(climb_kt);
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

							### 5 nm before TOD ###
							if (me.top_of_descent != 0 and int(dist_rem) == int(me.top_of_descent) + 5) {
								if (!alm_tod) {
									me.alm_tod.setValue(1);
								}
							}
							if (alm_tod) {
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

	todCalc : func (curr_wp,tot_dist,tg_alt) {
			var alt_cstr = me.fp.getWP(curr_wp).alt_cstr;
			var tod = (tg_alt- alt_cstr)/1000*me.tod_constant;
#			if (tod == 0) {
#				me.top_of_descent = 0;				
#				setprop("autopilot/locks/TOD-dist",me.top_of_descent);
#				return;
#			} 
			me.wp_dist = me.fp.getWP(curr_wp).distance_along_route;
			me.top_of_descent = tot_dist-me.wp_dist+tod;
			me.todCoord();
	}, # end of todCalc

	todCoord : func {
		if (math.round(me.TOD_dist.getValue(),1) != math.round(me.top_of_descent,1)) {
			var topDescent = me.fp.pathGeod(me.fp.indexOfWP(me.fp.destination_runway), - me.top_of_descent);
			var tdNode = me.NDSymbols.getNode("td", 1);
			tdNode.getNode("longitude-deg", 1).setValue(topDescent.lon);
			tdNode.getNode("latitude-deg", 1).setValue(topDescent.lat);
			me.TOD_dist.setValue(me.top_of_descent);
		} else {return}
	}, # end of todCoord

	todNew : func(curr_wp) {
		var tod_asel = (me.asel.getValue()*100-me.dest_alt.getValue())/1000*me.tod_constant;
		if (tod_asel > me.fp.getWP(curr_wp).leg_distance) {
			me.set_tgAlt = math.round((me.fp.getWP(curr_wp).leg_distance)/me.tod_constant*1000-me.dest_alt.getValue(),500);
		}
		me.top_of_descent = (me.set_tgAlt-me.dest_alt.getValue())/1000*me.tod_constant;
		me.todCoord();
	}, # end of todNew

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

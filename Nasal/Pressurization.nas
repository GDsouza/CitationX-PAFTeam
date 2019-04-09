### Citation X ####
# A Cabin Pressure System - by John Williams (tikibar) 3/2015 ###
# Developed for the 747-8 
# adapted by C. Le Moigne (clm76) - 2016 rev. 2018 ###

props.globals.initNode("controls/pressurization/press-man",0,"BOOL");
props.globals.initNode("controls/pressurization/man-rate-fpm",500,"DOUBLE");
props.globals.initNode("controls/pressurization/man-alt-ft",-1000,"DOUBLE");
props.globals.initNode("systems/pressurization/cabin-alt-ft",0,"DOUBLE");
props.globals.initNode("systems/pressurization/cabin-rate-fpm",0,"INT");
props.globals.initNode("systems/pressurization/mode",0,"INT");
props.globals.initNode("systems/pressurization/target-cabin-alt-ft",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/valve-state",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/valve-max",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/valve-offset",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/manual",0,"BOOL");
props.globals.initNode("systems/pressurization/internal/inflow-rate",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/atten-m",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/atten-b",0,"DOUBLE");

var alt_ft = "position/altitude-agl-ft";
var atten_b = "systems/pressurization/internal/atten-b";
var atten_m = "systems/pressurization/internal/atten-m";
var cabin_alt = "systems/pressurization/cabin-alt-ft";
var cabin_target = "systems/pressurization/target-cabin-alt-ft";
var inflow = "systems/pressurization/internal/inflow-rate";
var pressure_alt = "instrumentation/altimeter/pressure-alt-ft";
var man_rate = "controls/pressurization/man-rate-fpm";
var manual_mode = "systems/pressurization/internal/manual";
var mode = "systems/pressurization/mode";
var valve_max = "systems/pressurization/internal/valve-max";
var valve_offset = "systems/pressurization/internal/valve-offset";
var valve_state = "systems/pressurization/internal/valve-state";

var alt_set = nil;
var b_val = nil;
var cabin = nil;
var climbtime = nil;
var count = 0;
var diff = nil;
var infl = nil;
var landing_alt = 2000;
var last_alt = 0;
var of_valve = 0;
var relief = 0;
var targ_rate = getprop(man_rate);
var valve = nil;
var valve_man = 0;
var voffset = 0;
var VS = nil;

var Pressur = {
  new : func () {
    var m = {parents:[Pressur]};
    return m
  }, # end of new

  listen : func {
    setlistener("gear/gear[2]/wow", func (wow) {
        #### Automatic Mode selectors - Mode 0 and 1 ####
		    if (wow.getBoolValue()) {setprop(mode,0)}
		    else {setprop(mode,1)}
    },0,0);

    setlistener("controls/pressurization/press-man", func(man) {
		    if (!man.getBoolValue()) {
			    setprop("controls/pressurization/test",1);
			    settimer(func {setprop("controls/pressurization/test",0)},10);
		    } else {setprop("controls/pressurization/test",0)}
    },0,0);

    setlistener(mode,func(n) {
      me.update_mode(n.getValue());
    },1,0);
  }, # end of listen

  update_mode : func(mod) {
    		# On the ground
		if (mod == 0) {
		  if (!valve_man) of_valve = 1;	    
			else {
			  if (getprop("autopilot/route-manager/active") and getprop("autopilot/route-manager/destination/airport") != "") {
					landing_alt = getprop("autopilot/route-manager/destination/field-elevation-ft");
			  } else {
					landing_alt = 2000;
			  }
			}
		}
    		# Climb and Cruise
		if (mod == 1) {
			  var target = 8000;
			  if (landing_alt > 4000) target = 8200;
			  setprop(cabin_target,target);
		}
    		# Descent
		if (mod == 2) {
			  if (getprop("position/altitude-agl-ft") > 2000)
				setprop(cabin_target,landing_alt - 100);
		}
    		# Manual
		if (valve_man) {
			  setprop(manual_mode,1);
			  setprop(valve_state,0);
		} else {
			  setprop(manual_mode,0);
			  setprop(valve_max,1);
		}
    		# Inflow
		infl = 650 * ((getprop("systems/pneumatic/pack[0]") == 1) + (getprop("systems/pneumatic/pack[1]") == 1));
		setprop(inflow,infl);

  }, # end of update_mode

  update_alt : func {
    ### Mainly cabin alt and pressure differential ###
		VS = getprop("/velocities/vertical-speed-fps") * 60;
		cabin = getprop(cabin_alt) + (targ_rate * VS*0.000000175);
		diff = getprop(pressure_alt) - cabin;
		setprop(cabin_alt,cabin);

		if (getprop("controls/pressurization/alt-sel")) {
			setprop(cabin_alt,man_rate.getValue());
		} else {
			setprop(cabin_alt,cabin);
		}

		# Attenuation Factor
		if (abs(diff) <= 1750) {
		  setprop(atten_m,437.5);
      b_val = 0;
		}
		if (abs(diff) > 1750 and abs(diff) <= 3500) {
		  setprop(atten_m,1750);
		  b_val = 0.3;
		}
		if (abs(diff) > 3500 and abs(diff) <= 7000) {
		  setprop(atten_m,3500);
		  b_val = 0.4;
		}
		if (abs(diff) > 7000 and abs(diff) <= 14000) {
		  setprop(atten_m,7000);
		  b_val = 0.5;
		}
		if (abs(diff) > 14000 and abs(diff) <= 28000) {
		  setprop(atten_m,14000);
		  b_val = 0.6;
		}
		if (abs(diff) > 28000 and abs(diff) <= 38000) {
		  setprop(atten_m,28000);
		  b_val = 0.52;
		}
		if (abs(diff) > 38000) {
		  setprop(atten_m,38000);
		  b_val = 0.14;
		}
		if (diff < 0) b_val = -1 * b_val;
		  setprop(atten_b,b_val);
		if (getprop(mode) == 1) {
		  if (getprop("autopilot/settings/altitude-setting-ft") < 11000) {
				alt_set = getprop("autopilot/settings/altitude-setting-ft");
		  } else {
				alt_set = 41000;
		  }
			if (VS != 0) {
			  climbtime = (alt_set - getprop(pressure_alt)) / VS;
			  if (climbtime == 0) climbtime = 0.25;
			  targ_rate = (getprop(cabin_target) - cabin) / climbtime;
			}
			if (getprop(cabin_alt) > getprop(cabin_target)) {
				setprop(cabin_alt,getprop(cabin_target));
			}
		}
		if (getprop(mode) == 2) {
		  if (getprop(pressure_alt) > landing_alt + 2000) {
				if (VS != 0) {
				  climbtime = (getprop(pressure_alt)-getprop(cabin_target))/VS;
				  if (climbtime == 0) climbtime = 0.25;
				  targ_rate = (cabin - getprop(cabin_target)) / climbtime;
			}
			  } else targ_rate = 300;
		}
		targ_rate = abs(targ_rate);
		if (targ_rate > 500) targ_rate = 500;

		    # Valve States
		valve = getprop(valve_state);
		if (!valve_man) {
			  of_valve = valve;
			  if (getprop(mode) == 0) setprop(valve_state,1);
		}	    
		if (valve_man) voffset = voffset + of_valve;
		if (getprop(mode) == 0) voffset = voffset + 2.25;

		    # Relief Valve
		if (diff > 35550 or diff < -550) {
			  relief = 1;
			  voffset = voffset + 0.6;
		} else {relief = 0}

		setprop(valve_offset,voffset);

		    # Final Descent Mode
		if (getprop(mode) == 2 and getprop(alt_ft) < 2000) {
		  setprop(cabin_target,getprop(pressure_alt)-getprop(alt_ft) - 100);
		}
    settimer(func me.update_alt(),1);

  }, # end of update_alt

  desc_detector : func {
	        #   Mode 2
		if (getprop(mode) == 1) {
		  if (last_alt - getprop(pressure_alt) > 150) count += 1;
			else if (count > 0) count -= 1;
		  if (count == 4) {
		    setprop(mode,2);
		    count = 0;
		  }
		}
		if (getprop(mode) == 2) {
		  if (getprop(pressure_alt) - last_alt > 150)	count += 1;
		  else if (count > 0) count -= 1;
		  if (count == 6) {
			  setprop(mode,1);
			  count = 0;
		  }
		}
		last_alt = getprop(pressure_alt);
		settimer(func me.desc_detector(), 30);
  }, # end of descend_detector

}; # end of Pressur

var press_stl = setlistener("/sim/signals/fdm-initialized", func {
  var press = Pressur.new();
  press.listen();
  press.update_mode(0);
	press.update_alt();
	press.desc_detector();
	removelistener(press_stl);
},0,0);


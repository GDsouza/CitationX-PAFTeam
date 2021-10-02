### Citation X ####
# A Cabin Pressure System - by John Williams (tikibar) 3/2015 ###
# Developed for the 747-8 
# adapted by C. Le Moigne (clm76) - 2016 rev. 2018 ###

# Tasks:
# 1. Create and initialize properties
# 2. Calculate cabin altitude
# 3. Calculate differential
# 4. Handle automatic mode switching
# 5. Handle auto mode variables
# 6. Operate relief valve
# 7. Handle manual modes

var alt_sel = "controls/pressurization/alt-sel";
var ap_alt = "autopilot/settings/altitude-setting-ft";
var atten_m = "systems/pressurization/internal/atten-m";
var atten_b = "systems/pressurization/internal/atten-b";
var auto_rate = "controls/pressurization/auto-rate-fpm";
var bleed_air = "controls/APU/bleed-air";
var cabin_alt = "systems/pressurization/cabin-alt-ft";
var cabin_alt_dsp = "controls/pressurization/cabin-alt-dsp";
var cabin_dump = "controls/pressurization/cabin-dump";
var cabin_rate = "systems/pressurization/cabin-rate-fpm";
var cabin_target = "systems/pressurization/target-cabin-alt-ft";
var climb_rate = "controls/pressurization/climb-rate-fpm";
var diff_p = "systems/pressurization/internal/diff-p";
var high_altitude = "controls/pressurization/high-altitude";
var inflow_rate = "systems/pressurization/internal/inflow-rate";
var landing_alt = "controls/pressurization/landing-alt-ft";
var man_alt = "controls/pressurization/man-alt-ft";
var manual_rate = "controls/pressurization/man-rate-fpm";
var manual_mode = "controls/pressurization/manual";
var max_cabin_rate = "systems/pressurization/max-cabin-rate-fpm";
var max_cool = "controls/APU/max-cool";
var max_out = "systems/pressurization/internal/max-outflow-rate";
var mode = "controls/pressurization/mode";
var outflow_rate = "systems/pressurization/internal/outflow-rate";
var pack0 = "controls/pressurization/pack[0]/pack-on";
var pack1 = "controls/pressurization/pack[1]/pack-on";
var pack2 = "controls/pressurization/pack[2]/pack-on";
var pack3 = "controls/pressurization/pack[3]/pack-on";
var pressure_alt = "instrumentation/altimeter/pressure-alt-ft";
var rm_active = "autopilot/route-manager/active";
var valve0 = "controls/pressurization/outflow-valve-pos[0]";
var valve1 ="controls/pressurization/outflow-valve-pos[1]";
var valve_max = "systems/pressurization/internal/valve-max";
var valve_offset = "systems/pressurization/internal/valve-offset";
var valve_state = "systems/pressurization/internal/valve-state";

var adjd = nil;
var alt_dsp = nil;
var b_val = nil;
var cabin = nil;
var cab_dump = 0;
var climbtime = nil;
var diff = nil;
var dt = 0.0;
var infl = nil;
var last_alt = 0.0;
var rate = 0.0;
var rate_last = 0.0;
var targ_rate = 500;
var target = nil;
#var time = getprop("sim/time/elapsed-sec");
var time = 0.0;
var time_last = 0.0; 
var valve = nil;
var v_offset = nil;

var Pressur = {
  new : func () {
    var m = {parents:[Pressur]};
    return m
  }, # end of new

  init : func {
    if (getprop("gear/gear[2]/wow")) setprop(mode,0);
    else setprop(mode,1);
    if (getprop(pressure_alt) < 7750) setprop(cabin_alt,getprop(pressure_alt));
    else setprop(cabin_alt,7750);
    setprop(pack0,0);
    setprop(pack1,0);
    setprop(pack2,0);
    setprop(pack3,0);
  }, # end of init

  listen : func {
    setlistener("gear/gear[2]/wow", func (n) {
		    if (n.getValue()) setprop(mode,0);
		    else setprop(mode,1);
    },0,0);

    setlistener(ap_alt, func(n) {
      me.cabin_tgt(n.getValue());
   },0,0);

    setlistener(bleed_air, func(n) {
      if (n.getValue()) setprop(pack2,n.getValue());
   },0,0);

    setlistener(max_cool, func(n) {
      if (n.getValue()) setprop(pack3,n.getValue());
   },0,0);

    setlistener(alt_sel, func(n) {
      alt_dsp = n.getValue();
   },1,0);

    setlistener(cabin_dump, func(n) {
      cab_dump = n.getValue();
      if (n.getValue()) setprop(outflow_rate,getprop(max_out));
   },0,0);

    setlistener(rm_active, func(n) {
	    setprop(landing_alt,getprop("autopilot/route-manager/destination/field-elevation-ft") > 8000 ? 8000 : 0);
    },0,0);

  }, # end of listen


  update_alt : func {
	  time = getprop("sim/time/elapsed-sec");
	  dt = (time - time_last) / 60;
	  time_last = time;

	  rate = getprop(cabin_rate);
	  cabin = getprop(cabin_alt) + (((rate + rate_last) / 2) * dt);
	  diff = getprop(pressure_alt) - cabin;
	  rate_last = rate;

	  setprop(cabin_alt,cabin);
    setprop(cabin_alt_dsp,alt_dsp ? getprop(man_alt) : cabin);

	  # Attenuation Factor
    b_val = 0;
	  if (abs(diff) <= 1750) setprop(atten_m,437.5);
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

	  # Calculate target cabin rate
    if (!getprop(manual_mode)) {
	    if (getprop(mode) == 1) targ_rate = getprop(auto_rate);
	    if (getprop(mode) == 2) {
        if (getprop(pressure_alt) > getprop(landing_alt) + 2000) {
          if (getprop(auto_rate) == 500) targ_rate = 300;
          else targ_rate = getprop(auto_rate);
        }
      }
    } else targ_rate = getprop(manual_rate);
	  setprop(max_cabin_rate,targ_rate);

	  # Valve States
	  valve = getprop(valve_state);
    setprop(valve0,valve);
    setprop(valve1,valve);
	  v_offset = 0;
    if (getprop(mode) == 0) {
      setprop(valve_state,1);
      v_offset = v_offset + 2.25;
    } else {
      if (getprop(manual_mode)) v_offset = v_offset + (0.5 * getprop(valve0));
    }

	  # Final Descent Mode
	  if (getprop(mode) == 2 and getprop("position/altitude-agl-ft") < 2000) {
	      setprop(cabin_target,getprop(pressure_alt) - getprop("position/altitude-agl-ft") - 100);
	  }
  }, # end of update_alt

  update_mode : func {
	  # On the ground
	  if (getprop(mode) == 0) {
        setprop(valve0,1);
        setprop(valve1,1);
        setprop(high_altitude,getprop(cabin_alt) >= 8000 ? 1 : 0);
        if (getprop(cabin_alt) >= 8000) setprop(cabin_target,8000);
	  }
    if (getprop(mode) == 1) setprop(auto_rate,getprop(climb_rate));
    if (getprop(mode) == 2) setprop(auto_rate,getprop(climb_rate)*0.6);

	  # Manual
	  if (getprop(manual_mode) and getprop(cabin_alt) > 11000) {
        setprop(valve0,0);setprop(valve1,0);
    }

	  # Inflow
	  infl = 500 * (getprop("controls/pressurization/pack[0]/pack-on") + getprop("controls/pressurization/pack[1]/pack-on") + getprop("controls/pressurization/pack[2]/pack-on") + (0.25 * getprop("controls/pressurization/pack[3]/pack-on")));
	  setprop(inflow_rate,infl);

    # Outflow
    if (cab_dump and (getprop(cabin_alt) > 14500 
        or (getprop(diff_p) > -0.01 and getprop(diff_p) < 0.01))) {
      setprop(outflow_rate,getprop(inflow_rate));
    }
  }, # end of update_mode

  descend_detector : func {
	  if (getprop(mode) == 1) {
      if (last_alt - getprop(pressure_alt) > 150) setprop(mode,2);
	  }
	  if (getprop(mode) == 2) {
      if (getprop(pressure_alt) - last_alt > 150) setprop(mode,1);
	  }
	  last_alt = getprop(pressure_alt);
  }, # end of descend_detector

  cabin_tgt : func(value) {
      if (value <= 20000) 
        # function y=ax+b
        target = math.clamp(0.105*value-450,-100,2000); 
      if (value > 20000 and value <= 40000) 
        # parabolic function y=ax2+bx+c
        target = 0.00000425*math.pow(value,2)-0.0775*value+1500;
      if (value > 40000 and value <= 51000)
         # parabolic function y=ax2+bx+c
        target = -0.00000424*math.pow(value,2) +0.6406*value-13636;
      setprop(cabin_target,target);
  }, # end of cabin_tgt

  fast_update : func {
	  me.update_alt();
	  settimer(func me.fast_update(), 0);
  },

  slow_update : func {
	 me.update_mode();
	  settimer(func me.slow_update(), 10);
  },

  climb_desc : func {
	  me.descend_detector();
    settimer(func me.climb_desc(), 20);
  },
}; # end of Pressur

var man_rate_control = func(upd) { # from panel.xml : pressur man.rate
  if (upd == 1) setprop(cabin_target,getprop(cabin_target)+500);
  if (upd == -1) setprop(cabin_target,getprop(cabin_target)-500);
}

var press_stl = setlistener("/sim/signals/fdm-initialized", func {
  settimer(func {
    var press = Pressur.new();
    press.init();
    press.listen();
    press.fast_update();
    press.slow_update();
    press.climb_desc();
    removelistener(press_stl);
  },2);
},0,0);


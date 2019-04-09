### Citation X ###
### Christian Le Moigne (clm76) - 2015 rev 2018 mod 2019 ###
###														                    ###
###        MESSAGES                               ###
### level 0 = white 					                    ###
### level 1 = cyan 						                    ###
### level 2 = caution = amber                     ###
### level 3 = alert = red 		                    ###

### ANNUNCIATORS ###
props.globals.initNode("instrumentation/annunciators/test-select",0,"INT");
props.globals.initNode("instrumentation/eicas/warn",0,"BOOL");
var MstrWarning = "instrumentation/annunciators/master-warning";
var WarningAck = "instrumentation/annunciators/ack-warning";
var MstrCaution = "instrumentation/annunciators/master-caution";
var Warn = "instrumentation/annunciators/warning";
var Caution = "instrumentation/annunciators/caution";
var CautionAck = "instrumentation/annunciators/ack-caution";
var FlagWarn = "instrumentation/eicas/warn";
var Test_sel = "instrumentation/annunciators/test-select";
var no_takeoff_l3 = nil;
var msg = [];
var alert = nil;
var kias = nil;
var wow1 = nil;
var wow2 = nil;
var stall_warn = nil;
var grdn = nil;
var flap = nil;
var x = 0;

aircraft.light.new("instrumentation/annunciators", [0.5, 0.5], MstrCaution);
aircraft.light.new("instrumentation/annunciators", [0.5, 0.5], MstrWarning);

var annun_init = func {
	  setprop(MstrWarning,0);
    setprop(MstrCaution,0);
		setprop(WarningAck,0);
		setprop(CautionAck,0);
		setprop(Caution,0);
		setprop(Warn,0);
};
	
var ann_stl = setlistener("/sim/signals/fdm-initialized", func {
    annun_init();
    removelistener(ann_stl);
},0,0);

setlistener("/sim/signals/reinit", func {
    annun_init();
},0,0);

var Warnings = {
  new : func {
    var m = {parents : [Warnings]};
	return m
	},

	init : func {	
		me.my_caution = 0;
		me.my_warning = 0;
	},

  listen : func {
    setlistener(Test_sel, func(n) {me.test = n.getValue()},1,0);
  },

	update : func {
		me.eng0_shutdown = getprop("controls/engines/engine[0]/cutoff");
		me.eng1_shutdown = getprop("controls/engines/engine[1]/cutoff");
		me.parkbrake = getprop("controls/gear/brake-parking");
		me.emerbrake = getprop("controls/gear/emer-brake");
		me.apu_running = getprop("controls/electric/APU-generator");
		me.ext_pwr = getprop("controls/electric/external-power");
		me.cabin_door = getprop("controls/cabin-door/open");
		me.cabin_alt = getprop("systems/pressurization/cabin-alt-ft");
		me.boost_pump_L = getprop("controls/fuel/tank[0]/boost_pump");
		me.boost_pump_R = getprop("controls/fuel/tank[1]/boost_pump");
		me.level_tank_L = getprop("consumables/fuel/tank[0]/level-lbs");
		me.level_tank_R = getprop("consumables/fuel/tank[1]/level-lbs");
		me.total_fuel = getprop("consumables/fuel/total-ctrtk-lbs");
		me.grav_xflow = getprop("controls/fuel/gravity-xflow");
		me.xfeed_L = getprop("controls/engines/engine[0]/feed-tank");
		me.xfeed_R = getprop("controls/engines/engine[1]/feed-tank");
		me.xfer_L = getprop("controls/fuel/xfer-L");
		me.xfer_R = getprop("controls/fuel/xfer-R");
		me.gen_L = getprop("controls/electric/engine[0]/generator");
		me.gen_R = getprop("controls/electric/engine[1]/generator");
		me.oil_L = getprop("systems/hydraulics/psi-norm[0]");
		me.oil_R = getprop("systems/hydraulics/psi-norm[1]");
		me.speedbrake = getprop("controls/flight/speedbrake");
		me.flaps = getprop("controls/flight/flaps");
    me.flaps_sel = getprop("controls/flight/flaps-select");
		me.wow = getprop("gear/gear[0]/wow");
		me.vmo = getprop("instrumentation/pfd/vmo-diff");
		me.stall = getprop("sim/sound/stall-horn");
		me.state = getprop("instrumentation/annunciators/state");
    me.agl = getprop("position/altitude-agl-ft");
    me.gear0 = getprop("gear/gear[0]/position-norm");
    me.gear1 = getprop("gear/gear[1]/position-norm");
    me.gear2 = getprop("gear/gear[2]/position-norm");
    if (getprop("systems/electrical/outputs/efis") > 12) me.enabled = 1;
    else me.enabled = 0;

    me.msg_l0 = [];
		me.msg_l1 = [];
		me.msg_l2 = [];
		me.msg_l3 = [];
		me.nb_warning = 0;
		me.nb_caution = 0;
		me.nb_l1 = 0;
		me.nb_l0 = 0;
		no_takeoff_l3 = 0;

		if (me.enabled) {
      if (me.test == 0) {		
				  ### lEVEL 3 ###
			  if (me.cabin_alt > 10000) {
          append(me.msg_l3,"CABIN ALTITUDE");
			  }
			  if (!me.gen_L and !me.gen_R) {			
         	append(me.msg_l3,"GEN OFF L-R");
			  }
			  if (me.oil_L < 0.080 and me.oil_R < 0.080) {
          append(me.msg_l3,"OIL PRESS LOW L-R");
			  }	else if(me.oil_L < 0.4) {
          append(me.msg_l3,"OIL PRESS LOW L");
			  }	else if(me.oil_R < 0.4) {
          append(me.msg_l3,"OIL PRESS LOW R");
			  }
			  if(me.wow and !me.eng0_shutdown and !me.eng1_shutdown and (
					  me.ext_pwr
					  or me.parkbrake 
					  or me.emerbrake 
					  or me.speedbrake
					  or me.total_fuel <= 500)) {
				  append(me.msg_l3,"NO TAKEOFF");
				  no_takeoff_l3 = 1;
			  }			
			  if(me.vmo >= -59) {
				  append(me.msg_l3,"OVERSPEED");
				  setprop("sim/alarms/overspeed-alarm",1);
			  } else {
				  setprop("sim/alarms/overspeed-alarm",0);
			  }
			  if(me.stall and me.cabin_alt > 35000) {
				  append(me.msg_l3,"MINIMUM SPEED");
			  }

				  ### LEVEL 2 ###
			  if(!me.gen_L and me.gen_R) {
         	append(me.msg_l2,"GEN OFF L");
			  }	else if(!me.gen_R and me.gen_L) {
          append(me.msg_l2,"GEN OFF R");;
			  }
			  if (me.cabin_door) {
          append(me.msg_l2,"CABIN DOOR OPEN");
			  }
			  if (me.cabin_alt > 8500) {
          append(me.msg_l2,"CABIN ALTITUDE");
				  me.nb_caution +=1;
			  }
			  if (me.level_tank_L < 100 and me.level_tank_R < 100) {
          append(me.msg_l2,"FUEL LEVEL L-R");
			  }	else if( me.level_tank_L < 100) {
          append(me.msg_l2,"FUEL LEVEL L");
			  }	else if( me.level_tank_R < 100) {
          append(me.msg_l2,"FUEL LEVEL R");
			  }
			  if (me.speedbrake and me.cabin_alt < 500) {
          append(me.msg_l2,"SPEEDBRAKES");
			  }

				  ### LEVEL 1 ###
			  if (me.eng0_shutdown and me.eng1_shutdown){
				  append(me.msg_l1,"ENG SHUTDWN L-R");
			  } else if (me.eng0_shutdown) {
					  append(me.msg_l1,"ENG SHUTDWN L");
			  }	else if (me.eng1_shutdown) {
					  append(me.msg_l1,"ENG SHUTDWN R");
			  }
			  if (me.parkbrake) {
				  append(me.msg_l1,"PARK BRK SET");
			  }
			  if (me.emerbrake) {
				  append(me.msg_l1,"EMERGENCY BRAKE");
			  }
			  if(me.wow and (me.flaps < 0.140	or me.flaps > 0.430)and !no_takeoff_l3) {
				  append(me.msg_l1,"NO TAKEOFF");
			  }			

				  ### LEVEL 0 ###
			  if (me.apu_running) {
          append(me.msg_l0,"APU RUNNING");
			  }
			  if (me.boost_pump_L and me.boost_pump_R) {
          	append(me.msg_l0,"BOOST PUMP L-R");
			  }	else if (me.boost_pump_L) {
          	append(me.msg_l0,"BOOST PUMP L");
			  }	else if (me.boost_pump_R) {
          	append(me.msg_l0,"BOOST PUMP R");
			  }
			  if (me.xfer_L and me.xfer_R) {
          	append(me.msg_l0,"CTR XFER XSIT L-R");
			  }	else if (me.xfer_L) {
          	append(me.msg_l0,"CTR XFER XSIT L");
			  }	else if (me.xfer_R) {
          	append(me.msg_l0,"CTR XFER XSIT R");
			  }
			  if (me.xfeed_L or me.xfeed_R) {
          	append(me.msg_l0,"FUEL XFEED OPEN");
					  me.nb_l0 +=1;
			  }
			  if (me.grav_xflow) {
          	append(me.msg_l0,"FUEL XFLOW OPEN");
			  }
			  if (me.ext_pwr) {
					  append(me.msg_l0,"EXT POWER ON");
			  }
        msg = [];
        append(msg,me.msg_l3);
        append(msg,me.msg_l2);
        append(msg,me.msg_l1);
        append(msg,me.msg_l0);
        if (!size(me.msg_l3) and !size(me.msg_l2) and !size(me.msg_l1) and !size(me.msg_l0)) setprop(FlagWarn,0); # for listener Eicas
        else setprop(FlagWarn,1);
		    me.AnnunOutput();
	    } else me.Tests();
	    me.EicasOutput();			
    }

    ### Stall ###
		stall_speed();

    ### Gear oversight ###
    if ((me.flaps_sel == 4 or me.agl < 500) and !me.gear0 and !me.gear1 and !me.gear2 and getprop("velocities/vertical-speed-fps") <= 0) {
      setprop("instrumentation/alerts/gear-horn",1);
    } else setprop("instrumentation/alerts/gear-horn",0);
    
    #######
		settimer(func {me.update();},0.5);

	}, # end of update

  Tests : func {
    	me.msg_l0 = [];
			me.msg_l1 = [];
			me.msg_l2 = [];
			me.msg_l3 = [];
			setprop(WarningAck,0);
			setprop(CautionAck,0);
			append(me.msg_l3,"   ### TESTS ###");
			append(me.msg_l3," ");
			if (me.test == 1) {
				append(me.msg_l3,"BAGGAGE SMOKE");
				setprop(MstrWarning,1);
				setprop(Warn,me.state);
				setprop(MstrCaution,0);
				setprop(Caution,0);
			}
			if (me.test == 2) {
				append(me.msg_l0,"LANDING GEARS");
				setprop(MstrWarning,0);
				setprop(Warn,0);
			}
			if (me.test == 3) {
				append(me.msg_l3,"ENGINE FIRE L-R");
				setprop(MstrWarning,1);
				setprop(Warn,me.state);
			}
			if (me.test == 4) {
				append(me.msg_l3,"THRUST REVERSER");
				setprop(MstrWarning,1);
				setprop(Warn,me.state);
			}
			if (me.test == 5) {
				append(me.msg_l2,"FLAPS FAIL");
				setprop(MstrWarning,0);
				setprop(MstrCaution,1);								
				setprop(Warn,0);
				setprop(Caution,me.state);
			}
			if (me.test == 6) {
				append(me.msg_l2,"WSHLD HEAT L");
				append(me.msg_l2,"WSHLD HEAT R");
				append(me.msg_l2,"WSHLD TEMP L-R");
				setprop(MstrCaution,1);
				setprop(Caution,me.state);
			}
			if (me.test == 7) {
				append(me.msg_l0,"OVERSPEED");
				setprop(MstrCaution,0);
				setprop(Caution,0);
			}
			if (me.test == 8) {
				append(me.msg_l1,"AOA PROBE FAIL");
				append(me.msg_l1,"AUTO SLATS FAIL");
				append(me.msg_l1,"STALL WARN L-R");
				setprop(MstrCaution,0);
			}
			if (me.test == 9) {
				append(me.msg_l1,"OIL PRESS L-R");
				append(me.msg_l1,"FUEL PRESS L-R");
				append(me.msg_l1,"HYD PUMPS FAIL");
				setprop(MstrWarning,1);
				setprop(Warn,me.state);
				setprop(MstrCaution,1);
				setprop(Caution,me.state);
			}
      msg = [];
      append(msg,me.msg_l3);
      append(msg,me.msg_l2);
      append(msg,me.msg_l1);
      append(msg,me.msg_l0);
  }, # end of Tests

	EicasOutput : func {	### MSG TO EICAS ###
    return msg;
  }, # end of EicasOutput

	AnnunOutput : func {	### ANNUNCIATORS ###

				### WARNING ###
			if (me.nb_warning == 0) {
				setprop(MstrWarning,0);
				setprop(Warn,0);
				setprop(WarningAck,0);
			} 
			else if (me.nb_warning > me.my_warning) {
				setprop(MstrWarning,1);
				setprop(Warn,me.state);
				setprop(WarningAck,0);
			} else {
				setprop(MstrWarning,1);
				setprop(Warn,me.state);
				if (getprop(WarningAck)) setprop(Warn,1);
			}
			me.my_warning = me.nb_warning;		

				### CAUTION ###
			if (me.nb_caution == 0) {
				setprop(MstrCaution,0);
				setprop(Caution,0);										
				setprop(CautionAck,0);
			} 
			else if (me.nb_caution > me.my_caution) {
				setprop(MstrCaution,1);
				setprop(Caution,me.state);
				setprop(CautionAck,0);
			} else {
				setprop(MstrCaution,1);
				setprop(Caution,me.state);														
				if (getprop(CautionAck)) setprop(Caution,1);
			}
			me.my_caution = me.nb_caution;

	}, # end of AnnunOutput
}; # end of Warnings

var	stall_speed = func {
    alert = 0;
    kias = getprop("velocities/airspeed-kt");
    wow1 = getprop("gear/gear[1]/wow");
    wow2 = getprop("gear/gear[2]/wow");;
		stall_warn = getprop("instrumentation/pfd/stall-warning");
    grdn = getprop("controls/gear/gear-down");
    flap = getprop("controls/flight/flaps");

		### Activation Stall System ###
		if (getprop("position/altitude-agl-ft") > 400) {
			setprop("instrumentation/pfd/stall-warning",1);
		} else if (wow1 or wow2){
				setprop("instrumentation/pfd/stall-warning",0);		
		}
		### Set Stall Speed Alarm / Flaps ###
    if(stall_warn and (!wow1 or !wow2)){
			if (flap == 0.0){
				setprop("instrumentation/pfd/stall-speed",145);			
      	if(kias<=145){
					alert=1;
					setprop("controls/flight/flaps",0.0428); ### Extension Slats ###
				}
			}
			if (flap == 0.0428){
				setprop("instrumentation/pfd/stall-speed",135);
				if (kias<=135){alert=1}
			}
			if (flap == 0.142){
				setprop("instrumentation/pfd/stall-speed",130);
				if (kias<=130){alert=1}
			}
			if (flap == 0.428){
				setprop("instrumentation/pfd/stall-speed",125);
				if (kias<=125){alert=1}
			}
			if (flap == 1){
				setprop("instrumentation/pfd/stall-speed",115);
				if (kias<=115){alert=1}
			}
    }
   setprop("sim/sound/stall-horn",alert);
} # end of stall_speed

### MAIN ###
var warn_stl = setlistener("/sim/signals/fdm-initialized", func {
  var alarms = Warnings.new();
	alarms.init();
  alarms.listen();
	alarms.update();	
	removelistener(warn_stl);
});

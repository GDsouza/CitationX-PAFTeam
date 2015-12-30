### Citation X ###
### Christian Le Moigne - 2015 ###
###														 ###
###        MESSAGES            ###
### level 0 = white 					 ###
### level 1 = cyan 						 ###
### level 2 = caution = amber  ###
### level 3 = alert = red 		 ###

### ANNUNCIATORS ###
var Test_annun = props.globals.initNode("instrumentation/annunciators/test-select",0,"INT");
var Annun = props.globals.getNode("instrumentation/annunciators",1);
var MstrWarning = Annun.getNode("master-warning",1);
var WarningAck = Annun.getNode("ack-warning",1);
var MstrCaution = Annun.getNode("master-caution",1);
var Warn = Annun.getNode("warning",1);
var Caution = Annun.getNode("caution",1);
var CautionAck = Annun.getNode("ack-caution",1);
aircraft.light.new("instrumentation/annunciators", [0.5, 0.5], MstrCaution);
aircraft.light.new("instrumentation/annunciators", [0.5, 0.5], MstrWarning);

var annun_init = func {
	  MstrWarning.setBoolValue(0);
    MstrCaution.setBoolValue(0);
		WarningAck.setBoolValue(0);
		CautionAck.setBoolValue(0);
		Caution.setBoolValue(0);
		Warn.setBoolValue(0);
};
	
setlistener("/sim/signals/fdm-initialized", func {
    annun_init();
});

setlistener("/sim/signals/reinit", func {
    annun_init();
},0,0);

var EICAS = {
    new : func {
         m = { parents : [EICAS]};
 
			m.eicas = props.globals.initNode("instrumentation/eicas/");
			m.serviceable = m.eicas.initNode("serviceable", 1,"BOOL");
			m.warn_l0 = m.eicas.initNode("level-0"," ","STRING");
			m.warn_l1 = m.eicas.initNode("level-1"," ","STRING");
			m.warn_l2 = m.eicas.initNode("level-2"," ","STRING");			
			m.warn_l3 = m.eicas.initNode("level-3"," ","STRING");

		return m
		},

		init : func {	
			### SET LISTENERS ###
			setlistener("controls/engines/engine[0]/cutoff", func {
					EICAS.update_listeners()},1,0);
			setlistener("controls/engines/engine[1]/cutoff", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/gear/brake-parking", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/electric/APU-generator", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/electric/external-power", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/cabin-door/open", func {
				EICAS.update_listeners()},1,0);
			setlistener("position/altitude-ft", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/fuel/tank[0]/boost_pump", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/fuel/tank[1]/boost_pump", func {
				EICAS.update_listeners()},1,0);
			setlistener("consumables/fuel/tank[0]/level-lbs", func {
				EICAS.update_listeners()},1,0);
			setlistener("consumables/fuel/tank[1]/level-lbs", func {
				EICAS.update_listeners()},1,0);
			setlistener("consumables/fuel/total-ctrtk-lbs", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/fuel/gravity-xflow", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/engines/engine[0]/feed_tank", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/engines/engine[1]/feed_tank", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/fuel/xfer-L", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/fuel/xfer-R", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/electric/engine[0]/generator", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/electric/engine[1]/generator", func {
				EICAS.update_listeners()},1,0);
			setlistener("systems/hydraulics/psi-norm[0]", func {
				EICAS.update_listeners()},1,0);
			setlistener("systems/hydraulics/psi-norm[1]", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/flight/speedbrake", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/electric/APU-generator", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/flight/flaps", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/engines/engine[0]/throttle", func {
				EICAS.update_listeners()},1,0);
			setlistener("controls/engines/engine[1]/throttle", func {
				EICAS.update_listeners()},1,0);
			setlistener("gear/gear[0]/wow", func {
				EICAS.update_listeners()},1,0);
			setlistener("instrumentation/annunciators/test-select", func {
				EICAS.update_listeners()},1,0);

			me.my_caution = 0;
			me.my_warning = 0;
		},

		update_listeners : func {
				me.eng0_shutdown = getprop("controls/engines/engine[0]/cutoff");
				me.eng1_shutdown = getprop("controls/engines/engine[1]/cutoff");
				me.parkbrake = getprop("controls/gear/brake-parking");
				me.apu_running = getprop("controls/electric/APU-generator");
				me.ext_pwr = getprop("controls/electric/external-power");
				me.cabin_door = getprop("controls/cabin-door/open");
				me.altitude = getprop("position/altitude-ft");
				me.boost_pump_L = getprop("controls/fuel/tank[0]/boost_pump");
				me.boost_pump_R = getprop("controls/fuel/tank[1]/boost_pump");
				me.level_tank_L = getprop("consumables/fuel/tank[0]/level-lbs");
				me.level_tank_R = getprop("consumables/fuel/tank[1]/level-lbs");
				me.total_fuel = getprop("consumables/fuel/total-ctrtk-lbs");
				me.grav_xflow = getprop("controls/fuel/gravity-xflow");
				me.xfeed_L = getprop("controls/engines/engine[0]/feed_tank");
				me.xfeed_R = getprop("controls/engines/engine[1]/feed_tank");
				me.xfer_L = getprop("controls/fuel/xfer-L");
				me.xfer_R = getprop("controls/fuel/xfer-R");
				me.gen_L = getprop("controls/electric/engine[0]/generator");
				me.gen_R = getprop("controls/electric/engine[1]/generator");
				me.oil_L = getprop("systems/hydraulics/psi-norm[0]");
				me.oil_R = getprop("systems/hydraulics/psi-norm[1]");
				me.speedbrake = getprop("controls/flight/speedbrake");
				me.flaps = getprop("controls/flight/flaps");
				me.throttle_L = getprop("controls/engines/engine[0]/throttle");
				me.throttle_R = getprop("controls/engines/engine[1]/throttle");
				me.wow = getprop("gear/gear[0]/wow");
				me.test = getprop("instrumentation/annunciators/test-select");
		},

		update : func {
	    me.enabled = getprop("systems/electrical/outputs/efis") and
                            (getprop("sim/freeze/replay-state")!=1) and
                            me.serviceable.getValue();
			me.state = getprop("instrumentation/annunciators/state");
      me.msg_l0 = [];
			me.msg_l1 = [];
			me.msg_l2 = [];
			me.msg_l3 = [];
			me.nb_warning = 0;
			me.nb_caution = 0;

			if (me.enabled and me.test == 0) {		

					### lEVEL 3 ###
				if (me.altitude > 51000) {
          append(me.msg_l3,"CABIN ALTITUDE");
					me.nb_warning +=1;
				}
				if (!me.gen_L and !me.gen_R) {			
         	append(me.msg_l3,"GEN OFF L-R");
					me.nb_warning +=1;
				}
				if (me.oil_L < 0.080 and me.oil_R < 0.080) {
          append(me.msg_l3,"OIL PRESS LOW L-R");
					me.nb_warning +=2;
				}	else if(me.oil_L < 0.4) {
          append(me.msg_l3,"OIL PRESS LOW L");
					me.nb_warning +=1;
				}	else if(me.oil_R < 0.4) {
          append(me.msg_l3,"OIL PRESS LOW R");
					me.nb_warning +=1;
				}
				if(me.wow and !me.eng0_shutdown and !me.eng1_shutdown and (
						me.ext_pwr
						or me.parkbrake 
						or me.speedbrake
						or me.total_fuel <= 500)) {
					append(me.msg_l3,"NO TAKEOFF");
					me.nb_warning +=1;
				}			

					### LEVEL 2 ###
				if(!me.gen_L and me.gen_R) {
         	append(me.msg_l2,"GEN OFF L");
					me.nb_caution +=1;
				}	else if(!me.gen_R and me.gen_L) {
          append(me.msg_l2,"GEN OFF R");;
					me.nb_caution +=1;
				}
				if (me.cabin_door) {
          append(me.msg_l2,"CABIN DOOR OPEN");
					me.nb_caution +=1;
				}
				if (me.altitude > 50000) {
          append(me.msg_l2,"CABIN ALTITUDE");
					me.nb_caution +=1;
				}
				if (me.level_tank_L < 100 and me.level_tank_R < 100) {
          append(me.msg_l2,"FUEL LEVEL L-R");
					me.nb_caution +=2;
				}	else if( me.level_tank_L < 100) {
          append(me.msg_l2,"FUEL LEVEL L");
					me.nb_caution +=1;
				}	else if( me.level_tank_R < 100) {
          append(me.msg_l2,"FUEL LEVEL R");
					me.nb_caution +=1;
				}
				if (me.speedbrake and me.altitude < 500) {
          append(me.msg_l2,"SPEEDBRAKES");
					me.nb_caution +=1;
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
				if(me.wow and (me.flaps < 0.140	or me.flaps > 0.430)) {
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
				}
				if (me.grav_xflow) {
          	append(me.msg_l0,"FUEL XFLOW OPEN");
				}
				if (me.ext_pwr) {
						append(me.msg_l0,"EXT POWER ON");
				}

			me.AnnunOutput();

			### TESTS ###

			} else if (me.enabled and me.test > 0) {		
      	me.msg_l0 = [];
				me.msg_l1 = [];
				me.msg_l2 = [];
				me.msg_l3 = [];
				WarningAck.setBoolValue(0);
				CautionAck.setBoolValue(0);
				me.warn_l3.setValue("");
				me.warn_l2.setValue("");
				me.warn_l1.setValue("");
				me.warn_l0.setValue("");
				append(me.msg_l3,"   ### TESTS ###");
				append(me.msg_l3," ");
				if (me.test == 1) {
					append(me.msg_l3,"BAGGAGE SMOKE");
					MstrWarning.setBoolValue(1);
					Warn.setBoolValue(me.state);
					MstrCaution.setBoolValue(0);
					Caution.setBoolValue(0);
				}
				if (me.test == 2) {
					append(me.msg_l0,"LANDING GEARS");
					MstrWarning.setBoolValue(0);					
					Warn.setBoolValue(0);
				}
				if (me.test == 3) {
					append(me.msg_l3,"ENGINE FIRE L-R");
					MstrWarning.setBoolValue(1);					
					Warn.setBoolValue(me.state);
				}
				if (me.test == 4) {
					append(me.msg_l3,"THRUST REVERSER");
					MstrWarning.setBoolValue(1);					
					Warn.setBoolValue(me.state);
				}
				if (me.test == 5) {
					append(me.msg_l2,"FLAPS FAIL");
					MstrWarning.setBoolValue(0);
					MstrCaution.setBoolValue(1);								
					Warn.setBoolValue(0);
					Caution.setBoolValue(me.state);
				}
				if (me.test == 6) {
					append(me.msg_l2,"WSHLD HEAT L");
					append(me.msg_l2,"WSHLD HEAT R");
					append(me.msg_l2,"WSHLD TEMP L-R");
					MstrCaution.setBoolValue(1);
					Caution.setBoolValue(me.state);
				}
				if (me.test == 7) {
					append(me.msg_l0,"OVERSPEED");
					MstrCaution.setBoolValue(0);
					Caution.setBoolValue(0);
				}
				if (me.test == 8) {
					append(me.msg_l1,"AOA PROBE FAIL");
					append(me.msg_l1,"AUTO SLATS FAIL");
					append(me.msg_l1,"STALL WARN L-R");
					MstrCaution.setBoolValue(0);
				}
				if (me.test == 9) {
					append(me.msg_l1,"OIL PRESS L-R");
					append(me.msg_l1,"FUEL PRESS L-R");
					append(me.msg_l1,"HYD PUMPS FAIL");
					MstrWarning.setBoolValue(1);					
					Warn.setBoolValue(me.state);
					MstrCaution.setBoolValue(1);
					Caution.setBoolValue(me.state);
				}
			}
			me.EicasOutput();			
			settimer(func {me.update();},0);
		},

		EicasOutput : func {	### MSG TO EICAS ###
				var msg = "";
				var msg0 = "               \n";
				var msg_tmp = "";
				
					### LEVEL 3 - RED ###
        for(var i=0; i<size(me.msg_l3); i+=1) {
            msg = msg ~ me.msg_l3[i] ~ "\n";
						msg_tmp = msg_tmp~msg0;				
        }
        me.warn_l3.setValue(msg);

					### LEVEL 2 - AMBER ###
				msg = msg_tmp;
        for(var i=0; i<size(me.msg_l2); i+=1) {
            msg = msg ~ me.msg_l2[i] ~ "\n";
						msg_tmp = msg_tmp~msg0;			
        }
				me.warn_l2.setValue(msg);

					### LEVEL 1 - CYAN ###
				msg = msg_tmp;
        for(var i=0; i<size(me.msg_l1); i+=1) {
            msg = msg ~ me.msg_l1[i] ~ "\n";
						msg_tmp = msg_tmp~msg0;	
        }
				me.warn_l1.setValue(msg);

					### LEVEL 0 - WHITE ###
				msg = msg_tmp;
        for(var i=0; i<size(me.msg_l0); i+=1) {
            msg = msg ~ me.msg_l0[i] ~ "\n";
						msg_tmp = msg_tmp~msg0;	 
       	}
        me.warn_l0.setValue(msg);
		},

		AnnunOutput : func {	### ANNUNCIATORS ###

					### WARNING ###
				if (me.nb_warning == 0) {
					MstrWarning.setBoolValue(0);										
					Warn.setBoolValue(0);
					WarningAck.setBoolValue(0);
				} 
				else if (me.nb_warning > me.my_warning) {
					MstrWarning.setBoolValue(1);
					Warn.setBoolValue(me.state);
					WarningAck.setBoolValue(0);
				} else {
					MstrWarning.setBoolValue(1);														
					Warn.setBoolValue(me.state);
					if (WarningAck.getBoolValue() == 1) {
					Warn.setBoolValue(1);
					}
				}
				me.my_warning = me.nb_warning;		

					### CAUTION ###
				if (me.nb_caution == 0) {
					MstrCaution.setBoolValue(0);
					Caution.setBoolValue(0);										
					CautionAck.setBoolValue(0);
				} 
				else if (me.nb_caution > me.my_caution) {
					MstrCaution.setBoolValue(1);
					Caution.setBoolValue(me.state);
					CautionAck.setBoolValue(0);
				} else {
					MstrCaution.setBoolValue(1);;
					Caution.setBoolValue(me.state);														
					if (CautionAck.getBoolValue() == 1) {
						Caution.setBoolValue(1);
					}
				}
				me.my_caution = me.nb_caution;
		},
};

var annun_timer = func {
	settimer(func {
		setprop("instrumentation/annunciators/ack-warning",1);
		setprop("instrumentation/annunciators/warning",1);
	},3);
}

var stall_horn = func {
    var alert=0;
    var kias=getprop("velocities/airspeed-kt");
    if(kias>150){setprop("sim/sound/stall-horn",alert);return;};
    var wow1=getprop("gear/gear[1]/wow");
    var wow2=getprop("gear/gear[2]/wow");
    if(!wow1 or !wow2){
        var grdn=getprop("controls/gear/gear-down");
        var flap=getprop("controls/flight/flaps");
        if(kias<100){
            alert=1;
        }elsif(kias<120){
            if(!grdn )alert=1;
        }else{
            if(flap==0)alert=1;
        }
    }
    setprop("sim/sound/stall-horn",alert);
		settimer(stall_horn,0);
}

### MAIN ###
var alarms = EICAS.new();
	setlistener("/sim/signals/fdm-initialized", func {
		alarms.init();
		alarms.update();	
    stall_horn();
	},0,0);

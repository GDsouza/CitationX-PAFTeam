### Citation X ###
### Christian Le Moigne (clm76) - 2015 rev1:2018 rev2:2019 ###
###

### ANNUNCIATORS ###
var MstrWarning = "instrumentation/annunciators/master-warning";
var WarningAck = "instrumentation/annunciators/ack-warning";
var MstrCaution = "instrumentation/annunciators/master-caution";
var Warn = "instrumentation/annunciators/warning";
var Caution = "instrumentation/annunciators/caution";
var CautionAck = "instrumentation/annunciators/ack-caution";
var FlagWarn = "instrumentation/eicas/warn";
var Test_sel = "instrumentation/annunciators/test-select";
var flaps_sel = "controls/flight/flaps-select";
var no_takeoff_l3 = nil;
var msg = [];
var msg_str0 = "";
var msg_str1 = "";
var alert = nil;
var kias = nil;
var wow1 = nil;
var wow2 = nil;
var stall_warn = nil;
var grdn = nil;
var dau_msg = [];
var rudder_limit_fail = nil;

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
		me.old_caution = 0;
		me.old_warning = 0;
	},

  listen : func {
    setlistener(Test_sel, func(n) {me.test = n.getValue()},1,0);
  },

	update : func {
    me.agl = getprop("position/altitude-agl-ft");
		me.apu_running = getprop("controls/APU/generator");
    me.avnCooling = getprop("systems/electrical/outputs/avn-cooling");
		me.boost_pump_L = getprop("controls/fuel/tank[0]/boost-pump");
		me.boost_pump_R = getprop("controls/fuel/tank[1]/boost-pump");
		me.cabin_alt = getprop("systems/pressurization/cabin-alt-ft");
		me.cabin_door = getprop("controls/cabin-door/open");
    me.cbn_pac = getprop("controls/air-conditioning/cabin/pac");
    me.ckpt_pac = getprop("controls/air-conditioning/cockpit/pac");
    me.dau1A = getprop("systems/electrical/outputs/dau1A");
    me.dau1B = getprop("systems/electrical/outputs/dau1B");
    me.dau2A = getprop("systems/electrical/outputs/dau2A");
    me.dau2B = getprop("systems/electrical/outputs/dau2B");
    me.dl = getprop("systems/electrical/outputs/data-loader");
		me.emerbrake = getprop("controls/gear/emer-brake");
		me.eng0_shutdown = getprop("controls/engines/engine[0]/cutoff");
		me.eng1_shutdown = getprop("controls/engines/engine[1]/cutoff");
		me.ext_pwr = getprop("controls/electric/external-power");
    me.fdr = getprop("systems/electrical/outputs/fdr");
    me.fgcA = getprop("systems/electrical/outputs/fgc-cont-A");
    me.fgcB = getprop("systems/electrical/outputs/fgc-cont-B");
		me.flaps = getprop("controls/flight/flaps-select");
    me.fuel_xfer_L = getprop("systems/electrical/outputs/lh-fuel-transfer");
    me.fuel_xfer_R = getprop("systems/electrical/outputs/rh-fuel-transfer");
    me.fwc1 = getprop("systems/electrical/outputs/annun1");
    me.fwc2 = getprop("systems/electrical/outputs/annun2");
    me.gear0 = getprop("gear/gear[0]/position-norm");
    me.gear1 = getprop("gear/gear[1]/position-norm");
    me.gear2 = getprop("gear/gear[2]/position-norm");
		me.gen_L = getprop("controls/electric/engine[0]/generator");
		me.gen_R = getprop("controls/electric/engine[1]/generator");
    me.gps1 = getprop("systems/electrical/outputs/gps1");
    me.gps2 = getprop("systems/electrical/outputs/gps2");
		me.grav_xflow = getprop("controls/fuel/gravity-xflow");
    me.high_alt = getprop("controls/pressurization/high-altitude");
    me.iac1 = getprop("systems/electrical/outputs/iac1");
    me.iac2 = getprop("systems/electrical/outputs/iac2");
		me.level_tank_L = getprop("consumables/fuel/tank[0]/level-lbs");
		me.level_tank_R = getprop("consumables/fuel/tank[1]/level-lbs");
    me.madc1 = getprop("systems/electrical/outputs/madc1");
    me.madc2 = getprop("systems/electrical/outputs/madc2");
    me.mtrim = getprop("autopilot/locks/m-trim");
		me.oil_L = getprop("systems/hydraulics/psi-norm[0]");
		me.oil_R = getprop("systems/hydraulics/psi-norm[1]");
		me.parkbrake = getprop("controls/gear/brake-parking");
    me.rudder_limit = getprop("controls/flight/rudder-limit-deg");
    me.rudder_limit_A = getprop("systems/electrical/outputs/rudder-limit-A");
    me.rudder_limit_B = getprop("systems/electrical/outputs/rudder-limit-B");
    me.selcal = getprop("systems/electrical/outputs/selcal");
		me.slats = getprop("controls/flight/slats");
		me.speedbrake = getprop("controls/flight/spoilers");
		me.stall = getprop("sim/sound/stall-horn");
		me.state = getprop("instrumentation/annunciators/state");
		me.total_fuel = getprop("consumables/fuel/total-ctrtk-lbs");
    me.up_rudderA = getprop("systems/electrical/outputs/upper-rudder-A");
    me.up_rudderB = getprop("systems/electrical/outputs/upper-rudder-B");
		me.vmo = getprop("instrumentation/pfd/vmo-diff");
		me.wow = getprop("gear/gear[0]/wow");
		me.xfeed_L = getprop("controls/engines/engine[0]/feed-tank");
		me.xfeed_R = getprop("controls/engines/engine[1]/feed-tank");
		me.xfer_L = getprop("controls/fuel/xfer-L");
		me.xfer_R = getprop("controls/fuel/xfer-R");
    me.ydA = getprop("systems/electrical/outputs/fgc-yd-A");
    me.ydB = getprop("systems/electrical/outputs/fgc-yd-B");
    if (getprop("systems/electrical/outputs/eicas")) me.enabled = 1;
    else me.enabled = 0;
      ### Anti-ice ###
    if (getprop("controls/engines/engine/throttle") <= 0.1
        and !getprop("controls/engines/engine/cutoff")) me.throttle0 = 1;
    else me.throttle0 = 0;
    if (getprop("controls/engines/engine[1]/throttle") <= 0.1
        and !getprop("controls/engines/engine[1]/cutoff")) me.throttle1 = 1;
    else me.throttle1 = 0;
    if (getprop("controls/engines/engine/throttle") > 0.1) me.throttle0 = 2;
    if (getprop("controls/engines/engine[1]/throttle") > 0.1) me.throttle1 = 2;
    me.aoa_L_output = getprop("systems/electrical/outputs/lh-aoa-heater");
    me.aoa_R_output = getprop("systems/electrical/outputs/rh-aoa-heater");
    me.pitot_L = getprop("controls/anti-ice/lh-pitot");
    me.pitot_L_output = getprop("systems/electrical/outputs/lh-ps-heater");
    me.pitot_R = getprop("controls/anti-ice/rh-pitot");
    me.pitot_R_output = getprop("systems/electrical/outputs/rh-ps-heater");
    me.rat_L_output =  getprop("systems/electrical/outputs/lh-rat-heater");
    me.rat_R_output =  getprop("systems/electrical/outputs/rh-rat-heater");
    me.slat_ice = getprop("controls/anti-ice/slat");
    me.stab_L = getprop("controls/anti-ice/lh-stab");
    me.stab_R = getprop("controls/anti-ice/rh-stab");
    me.slat_stab_L_output = getprop("systems/electrical/outputs/lh-slat-stab");
    me.slat_stab_R_output = getprop("systems/electrical/outputs/rh-slat-stab");
    me.eng_L = getprop("controls/anti-ice/lh-engine");
    me.eng_L_output = getprop("systems/electrical/outputs/lh-eng-wing");
    me.eng_R = getprop("controls/anti-ice/rh-engine");
    me.eng_R_output = getprop("systems/electrical/outputs/rh-eng-wing");
    me.ws_L = getprop("systems/electrical/outputs/lh-ws");
    me.ws_R = getprop("systems/electrical/outputs/rh-ws");
      ### Fire ###
    me.eng_L_fire = getprop("controls/fire/left-eng-fire-detect");
    me.eng_R_fire = getprop("controls/fire/right-eng-fire-detect");
    me.bottle1_low = getprop("controls/fire/bottle1-low");
    me.bottle2_low = getprop("controls/fire/bottle2-low");
    me.fireApu = getprop("systems/electrical/outputs/apu-fire-detect");

    me.msg_l0 = [];
		me.msg_l1 = [];
		me.msg_l2 = [];
		me.msg_l3 = [];
		me.nb_warning = 0;
		me.nb_caution = 0;
		me.nb_l1 = 0;
		me.nb_l0 = 0;
		no_takeoff_l3 = 0;
    me.dauMsg = "2DAU";

		if (me.enabled) {
      if (me.test == 0) {
				  ### lEVEL 3 - Red  - Alert ###
			  if ((!me.high_alt and me.cabin_alt > 10000)
          or (me.high_alt and me.cabin_alt >= 14500))
          append(me.msg_l3,"3CABIN ALTITUDE");

			  if (!me.gen_L and !me.gen_R) append(me.msg_l3,"3GEN OFF L-R");

			  if (me.oil_L < 0.4 and me.oil_R < 0.4)
          append(me.msg_l3,"3OIL PRESS LOW L-R");
			  else if(me.oil_L < 0.4) append(me.msg_l3,"3OIL PRESS LOW L");
			  else if(me.oil_R < 0.4) append(me.msg_l3,"3OIL PRESS LOW R");

			  if(me.wow and !me.eng0_shutdown and !me.eng1_shutdown and (
					  me.ext_pwr
					  or me.parkbrake
					  or me.emerbrake
					  or me.speedbrake
					  or me.total_fuel <= 500)) {
				  append(me.msg_l3,"3NO TAKEOFF");
				  no_takeoff_l3 = 1;
			  }
			  if(me.vmo >= -59) {
				  append(me.msg_l3,"3OVERSPEED");
				  setprop("sim/alarms/overspeed-alarm",me.fwc1 ? 1 : 0);
			  } else setprop("sim/alarms/overspeed-alarm",0);

			  if(me.stall and me.cabin_alt > 35000)
          append(me.msg_l3,"3MINIMUM SPEED");

			  if(!me.rudder_limit_A and !me.rudder_limit_B) {
				  append(me.msg_l3,"3RUDDER LIMIT FAIL");
          rudder_limit_fail = 1;
			  } else rudder_limit_fail = 0;

			  if(me.eng_L_fire and me.eng_R_fire) append(me.msg_l3,"3ENGINE FIRE L-R");
        else if (me.eng_L_fire) append(me.msg_l3,"3ENGINE FIRE L");
        else if (me.eng_R_fire) append(me.msg_l3,"3ENGINE FIRE R");


				  ### LEVEL 2 - Amber - Caution ###
			  if(!me.gen_L and me.gen_R) append(me.msg_l2,"2GEN OFF L");
			  else if(!me.gen_R and me.gen_L) append(me.msg_l2,"2GEN OFF R");;

			  if(!me.fgcA and me.fgcB) append(me.msg_l2,"2FGC A FAIL");
			  else if(!me.fgcB and me.fgcA) append(me.msg_l2,"2FGC B FAIL");
			  else if (!me.fgcA and !me.fgcB) append(me.msg_l2,"2FGC A-B FAIL");;

			  if (!me.ydA and !me.ydB) {
         	append(me.msg_l2,"2YD FAIL UPPER A-B");
         	append(me.msg_l2,"2YD FAIL LOWER A-B");
        } else if (!me.up_rudderA and !me.up_rudderB)
         	append(me.msg_l2,"2YD FAIL UPPER A-B");

        if (!me.mtrim) append(me.msg_l2,"2MACH TRIM OFF");

			  if (me.cabin_door and (me.dau1A or me.dau1B))
          append(me.msg_l2,"2CABIN DOOR OPEN");

			  if (!me.high_alt and me.cabin_alt > 8500 and me.cabin_alt < 10000)
          append(me.msg_l2,"2CABIN ALTITUDE");

		    if (me.level_tank_L < 100 and me.level_tank_R < 100)
          append(me.msg_l2,"2FUEL LEVEL LOW L-R");
			  else if( me.level_tank_L < 100) append(me.msg_l2,"2FUEL LEVEL LOW L");
			  else if( me.level_tank_R < 100) append(me.msg_l2,"2FUEL LEVEL LOW R");

			  if (!me.fuel_xfer_L and !me.fuel_xfer_R)
          append(me.msg_l2,"2FUEL PRESS LOW L-R");
			  else if (!me.fuel_xfer_L)	append(me.msg_l2,"2FUEL PRESS LOW L");
			  else if (!me.fuel_xfer_R) append(me.msg_l2,"2FUEL PRESS LOW R");

			  if (!me.xfer_L == 2 and !me.xfer_R == 2)
          append(me.msg_l2,"2CTR XFER OFF L-R");
			  else if (me.xfer_L == 2)	append(me.msg_l2,"2CTR XFER OFF L");
			  else if (me.xfer_R == 2) append(me.msg_l2,"2CTR XFER OFF R");

			  if (me.speedbrake and me.agl < 500) append(me.msg_l2,"2SPEEDBRAKES");

        if (!me.madc1 and !me.madc2) append(me.msg_l2,"2RAT PROB FAIL L-R");

        if (!me.iac1) append(me.msg_l2,"2IAC 1 FAIL");
        else if (!me.iac2) append(me.msg_l2,"2IAC 2 FAIL");

        if (!me.fwc1 and !me.fwc2) append(me.msg_l2,"2FWC 1-2 FAIL");
        else if (!me.fwc1) append(me.msg_l2,"2FWC 1 FAIL");
        else if (!me.fwc2) append(me.msg_l2,"2FWC 2 FAIL");

        if (!me.dau1A and !me.dau1B and !me.dau2A and !me.dau2B)
          append(me.msg_l2,"2DAU ALL FAIL");
        else {
          if (!me.dau1A or !me.dau1B or !me.dau2A or !me.dau2B) {
            dau_msg = [];
            if (!me.dau1A) append(dau_msg," 1A");
            if (!me.dau1B) append(dau_msg," 1B");
            if (!me.dau2A) append(dau_msg," 2A");
            if (!me.dau2B) append(dau_msg," 2B");
            for (var n=0;n<size(dau_msg);n+=1) me.dauMsg = me.dauMsg~dau_msg[n];
            append(me.msg_l2,me.dauMsg~" FAIL");
          }
        }
        if (!me.avnCooling)
          append(me.msg_l2,"2AVN HOT BAG - NOSE");

        if (!me.fireApu)
          append(me.msg_l2,"2FIRE DETECT FAIL A");

        if (!rudder_limit_fail and (!me.rudder_limit_A or !me.rudder_limit_B))
          append(me.msg_l2,"2RUDDER LIMIT FAIL");

        if (me.throttle0 == 2 or me.throttle1 == 2) {
          if (!me.pitot_L and !me.pitot_R)
            append(me.msg_l2,"2P/S-RAT HEAT OFF L-R");
          else if (!me.pitot_L)
            append(me.msg_l2,"2P/S-RAT HEAT OFF L");
          else if (!me.pitot_R)
            append(me.msg_l2,"2P/S-RAT HEAT OFF R");
        }

        if (me.pitot_L and me.pitot_R and !me.aoa_L_output
          and !me.aoa_R_output) {
          append(me.msg_l2,"2AOA HEAT FAIL L-R");
          me.nb_caution +=1;
        } else if (me.pitot_L and !me.aoa_L_output) {
          append(me.msg_l2,"2AOA HEAT FAIL L");
          me.nb_caution +=1;
        } else if (me.pitot_R and !me.aoa_R_output) {
          append(me.msg_l2,"2AOA HEAT FAIL R");
          me.nb_caution +=1;
        }
        if (me.pitot_L and me.pitot_R and !me.pitot_L_output
          and !me.pitot_R_output)
          append(me.msg_l2,"2PITOT HTR FAIL L-R");
        else if (me.pitot_L and !me.pitot_L_output)
          append(me.msg_l2,"2PITOT HTR FAIL L");
        else if (me.pitot_R and !me.pitot_R_output)
          append(me.msg_l2,"2PITOT HTR FAIL R");

        if (me.pitot_L and me.pitot_R and !me.rat_L_output
          and !me.rat_R_output)
          append(me.msg_l2,"2RAT HEAT FAIL L-R");
        else if (me.pitot_L and !me.rat_L_output)
          append(me.msg_l2,"2RAT HEAT FAIL L");
        else if (me.pitot_R and !me.rat_R_output)
          append(me.msg_l2,"2RAT HEAT FAIL R");

        if (me.slat_ice and !me.slat_stab_L_output and !me.slat_stab_R_output)
          append(me.msg_l2,"2SLAT A/I COLD L-R");
        else if (me.slat_ice and !me.slat_stab_L_output)
          append(me.msg_l2,"2SLAT A/I COLD L");
        else if (me.slat_ice and !me.slat_stab_R_output)
          append(me.msg_l2,"2SLAT A/I COLD R");

        if (me.stab_L and me.stab_R and !me.slat_stab_L_output
          and !me.slat_stab_R_output)
          append(me.msg_l2,"2STAB A/I COLD L-R");
        else if (me.stab_L and !me.slat_stab_L_output)
          append(me.msg_l2,"2STAB A/I COLD L");
        else if (me.stab_R and !me.slat_stab_R_output)
          append(me.msg_l2,"2STAB A/I COLD R");

        if (me.eng_L and !me.eng_L_output and me.eng_R and !me.eng_R_output) {
          append(me.msg_l2,"2ENG A/I COLD L-R");
          append(me.msg_l2,"2WING A/I COLD L-R");
          append(me.msg_l2,"2WING CUFF COLD L-R");
        } else if (me.eng_L and !me.eng_L_output) {
          append(me.msg_l2,"2ENG A/I COLD L");
          append(me.msg_l2,"2WING A/I COLD L");
          append(me.msg_l2,"2WING CUFF COLD L");
        } else if (me.eng_R and !me.eng_R_output) {
          append(me.msg_l2,"2ENG A/I COLD R");
          append(me.msg_l2,"2WING A/I COLD R");
          append(me.msg_l2,"2WING CUFF COLD R");
        }
        if (!me.ws_L) append(me.msg_l2,"2WSHLD HEAT INOP L");
        if (!me.ws_R) append(me.msg_l2,"2WSHLD HEAT INOP R");

				  ### LEVEL 1  - Cyan ###
			  if (me.eng0_shutdown and me.eng1_shutdown) {
				  append(me.msg_l1,"1ENG SHUTDWN L-R");
			  }
        else if (me.eng0_shutdown) append(me.msg_l1,"1ENG SHUTDWN L");
      	else if (me.eng1_shutdown) append(me.msg_l1,"1ENG SHUTDWN R");
			  if (me.parkbrake) append(me.msg_l1,"1PARK BRK SET");
			  if (me.emerbrake) append(me.msg_l1,"1EMERGENCY BRAKE");
			  if (me.wow and me.flaps < 1 and !no_takeoff_l3)
				  append(me.msg_l1,"1NO TAKEOFF");
        if (!me.madc1 and me.madc2) append(me.msg_l1,"1RAT PROB FAIL L");
        if (!me.madc2 and me.madc1) append(me.msg_l1,"1RAT PROB FAIL R");
			  if (!me.ydB and me.ydA) {
         	append(me.msg_l1,"1YD FAIL UPPER B");
         	append(me.msg_l1,"1YD FAIL LOWER B");
			  } else if (!me.ydA and me.ydB) {
         	append(me.msg_l1,"1YD FAIL UPPER A");
         	append(me.msg_l1,"1YD FAIL LOWER A");
        } else if (!me.up_rudderA and me.up_rudderB) {
          append(me.msg_l1,"1YD FAIL UPPER A")
        } else if (!me.up_rudderB and me.up_rudderA) {
          append(me.msg_l1,"1YD FAIL UPPER B");
        }
        if (!me.fdr) append(me.msg_l1,"1FDR FAIL");
        if (me.wow and (me.throttle0 == 1 or me.throttle1 == 1)) {
          if (!me.pitot_L and !me.pitot_R)
            append(me.msg_l1,"1P/S-RAT HEAT OFF L-R");
          else if (!me.pitot_L) append(me.msg_l1,"1P/S-RAT HEAT OFF L");
          else if (!me.pitot_R) append(me.msg_l1,"1P/S-RAT HEAT OFF R");
        }
        if (me.bottle1_low and me.bottle2_low)
          append(me.msg_l1,"1FIRE BOTTL LOW L-R");
        else if (me.bottle1_low) append(me.msg_l1,"1FIRE BOTTL LOW L");
        else if (me.bottle2_low) append(me.msg_l1,"1FIRE BOTTL LOW R");

				  ### LEVEL 0 - White ###
			  if (me.apu_running) append(me.msg_l0,"0APU RUNNING");
			  if (me.boost_pump_L and me.boost_pump_R) append(me.msg_l0,"0BOOST PUMP L-R");
			  else if (me.boost_pump_L)	append(me.msg_l0,"0BOOST PUMP L");
			  else if (me.boost_pump_R) append(me.msg_l0,"0BOOST PUMP R");
			  if (me.xfeed_L or me.xfeed_R) append(me.msg_l0,"0FUEL XFEED OPEN");
			  if (me.grav_xflow) append(me.msg_l0,"0FUEL GRV XFLOW OPEN");
			  if (me.ext_pwr) append(me.msg_l0,"0EXT POWER ON");
			  if (me.speedbrake and me.agl >= 500) append(me.msg_l0,"0SPEEDBRAKES");
        if (me.ckpt_pac == 1 and me.cbn_pac == 1) append(me.msg_l0,"0PAC HI CKPT-CBN");
        else if (me.ckpt_pac == 1) append(me.msg_l0,"0PAC HI CKPT");
        else if (me.cbn_pac == 1) append(me.msg_l0,"0PAC HI CBN");
        if (!me.selcal) {
          append(me.msg_l0,"0SELCAL HF 1-2 UHF");
          append(me.msg_l0,"0SELCAL VHF 1-2-3");
        }
	    } else me.Tests();

      msg = [];
      append(msg,me.msg_l3);
      append(msg,me.msg_l2);
      append(msg,me.msg_l1);
      append(msg,me.msg_l0);
      me.nb_warning = size(me.msg_l3);
      me.nb_caution = size(me.msg_l2);

      ### Msg change detection for activation messages display on Eicas ###
      msg_str0 = "";
      for(var i=0;i<4;i+=1) {
        for (var j=0;j<size(msg[i]);j+=1) msg_str0 = msg_str0~msg[i][j];
      }
      setprop(FlagWarn,msg_str0 != msg_str1 ? 1 : 0);
      msg_str1 = msg_str0;

      me.EicasOutput();
      ###
    }
    me.AnnunOutput();
    if (me.fwc1) me.stall_speed();

    ### CDU ALARMS ###
    if (!me.dl)	me.nb_caution +=1;
    if (!me.gps1)	me.nb_caution +=1;
    if (!me.gps2)	me.nb_caution +=1;

    ### Gear oversight ###
    if ((me.flaps == 3 or me.agl < 500) and !me.gear0 and !me.gear1 and !me.gear2 and getprop("velocities/vertical-speed-fps") <= 0) {
      setprop("instrumentation/alerts/gear-horn",1);
    } else setprop("instrumentation/alerts/gear-horn",0);

    ### Timer ###
		settimer(func {me.update();},0.1);

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
				append(me.msg_l3,"3BAGGAGE SMOKE");
        me.nb_warning += 1;
			}
			if (me.test == 2) {
				append(me.msg_l0,"0LANDING GEARS");
			}
			if (me.test == 3) {
				append(me.msg_l3,"0ENGINE FIRE L-R");
        me.nb_warning += 1;
			}
			if (me.test == 4) {
				append(me.msg_l3,"3THRUST REVERSER");
        me.nb_warning += 1;
			}
			if (me.test == 5) {
				append(me.msg_l2,"2FLAPS FAIL");
        me.nb_caution += 1;
			}
			if (me.test == 6) {
				append(me.msg_l2,"2WSHLD HEAT L");
				append(me.msg_l2,"2WSHLD HEAT R");
				append(me.msg_l2,"2WSHLD TEMP L-R");
        me.nb_caution += 1;
			}
			if (me.test == 7) {
				append(me.msg_l0,"0OVERSPEED");
			}
			if (me.test == 8) {
				append(me.msg_l1,"1AOA PROBE FAIL");
				append(me.msg_l1,"1AUTO SLATS FAIL");
				append(me.msg_l1,"1STALL WARN L-R");
			}
			if (me.test == 9) {
				append(me.msg_l3,"3OIL PRESS L-R");
				append(me.msg_l3,"3FUEL PRESS L-R");
				append(me.msg_l3,"3HYD PUMPS FAIL");
        me.nb_warning += 3;
			}
      msg = [];
      append(msg,me.msg_l3);
      append(msg,me.msg_l2);
      append(msg,me.msg_l1);
      append(msg,me.msg_l0);
  }, # end of Tests

	EicasOutput : func() {	### MSG TO EICAS ###
    return msg;
  }, # end of EicasOutput

	AnnunOutput : func {	### ANNUNCIATORS ###
				### WARNING ###
			if (me.nb_warning == 0) {
				setprop(MstrWarning,0);
				setprop(Warn,0);
				setprop(WarningAck,0);
			} else if (me.nb_warning > me.old_warning) {
				setprop(MstrWarning,1);
				setprop(Warn,me.state);
				setprop(WarningAck,0);
			} else {
				setprop(MstrWarning,1);
				setprop(Warn,me.state);
				if (getprop(WarningAck)) setprop(Warn,1);
			}
			me.old_warning = me.nb_warning;

				### CAUTION ###
			if (me.nb_caution == 0) {
				setprop(MstrCaution,0);
				setprop(Caution,0);
				setprop(CautionAck,0);
			}
			else if (me.nb_caution > me.old_caution) {
				setprop(MstrCaution,1);
				setprop(Caution,me.state);
				setprop(CautionAck,0);
			} else {
				setprop(MstrCaution,1);
				setprop(Caution,me.state);
				if (getprop(CautionAck)) setprop(Caution,1);
			}
			me.old_caution = me.nb_caution;

	}, # end of AnnunOutput

  stall_speed :  func {
    alert = 0;
    kias = getprop("velocities/airspeed-kt");
    wow1 = getprop("gear/gear[1]/wow");
    wow2 = getprop("gear/gear[2]/wow");;
		stall_warn = getprop("instrumentation/pfd/stall-warning");
    grdn = getprop("controls/gear/gear-down");

		### Activation Stall System ###
		if (getprop("position/altitude-agl-ft") > 400)
			setprop("instrumentation/pfd/stall-warning",1);
    else setprop("instrumentation/pfd/stall-warning",0);

		### Set Stall Speed Alarm / Flaps ###
    if(stall_warn){
			if (me.flaps == 0){
				setprop("instrumentation/pfd/stall-speed",145);
      	if(kias<=145){
					alert=1;
					setprop("controls/flight/slats",1); ### Extension Slats ###
				}
			}
			if (me.slats == 1){
				setprop("instrumentation/pfd/stall-speed",135);
				if (kias<=135) alert=1;
			}
			if (me.flaps == 1){
				setprop("instrumentation/pfd/stall-speed",130);
				if (kias<=130) alert=1;
			}
			if (me.flaps == 2){
				setprop("instrumentation/pfd/stall-speed",125);
				if (kias<=125) alert=1;
			}
			if (me.flaps == 3){
				setprop("instrumentation/pfd/stall-speed",115);
				if (kias<=115) alert=1;
			}
    }
    setprop("sim/sound/stall-horn",alert);
  } # end of stall_speed
}; # end of Warnings

### MAIN ###
var warn_stl = setlistener("/sim/signals/fdm-initialized", func {
  var alarms = Warnings.new();
	alarms.init();
  alarms.listen();
	alarms.update();
	removelistener(warn_stl);
});

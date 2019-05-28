### Citation X ####
### Révision C. Le Moigne (clm76) - 2015,2016,2019  ###

### Check FG version ###
var checkVersion = func {
  var version = split(".",getprop("sim/version/flightgear"));
  if (version[0] < 2018) {
    var window = screen.window.new(nil, -200, 5, 10);
    var alert = ["Citation X is only supported in Flightgear version 2018 and upwards.", "Sorry !...",""];
    window.bg = [1,1,0,1];
    window.fg = [1,0,0,1];
    window.font = "HELVETICA_18";
    window.write("WRONG FLIGHTGEAR VERSION");
    window.write(alert[0]);
    window.write(alert[1]);
    window.write(alert[2]);
  }
};

### Properties Init ###
props.globals.initNode("controls/engines/grnd-idle",1,"BOOL");
props.globals.initNode("controls/flight/flaps-select",0,"INT");
props.globals.initNode("controls/fuel/tank[0]/boost_pump",0,"INT");
props.globals.initNode("controls/fuel/tank[1]/boost_pump",0,"INT");
props.globals.initNode("sim/model/show-pilot",1,"BOOL");
props.globals.initNode("sim/model/show-copilot",1,"BOOL");
props.globals.initNode("sim/model/show-yoke_L",1,"BOOL");
props.globals.initNode("sim/model/show-yoke_R",1,"BOOL");
props.globals.initNode("sim/model/mem-yoke_L",1,"BOOL");
props.globals.initNode("sim/model/mem-yoke_R",1,"BOOL");
props.globals.initNode("controls/flight/vref",131,"DOUBLE");
props.globals.initNode("controls/flight/va",200,"DOUBLE");
props.globals.initNode("controls/separation-door/open",1,"DOUBLE");
props.globals.initNode("controls/toilet-door/open",0,"DOUBLE");
props.globals.initNode("controls/bar/bar-door-1",0,"DOUBLE");
props.globals.initNode("controls/bar/bar-door-2",0,"DOUBLE");
props.globals.initNode("controls/bar/bar-door-3",0,"DOUBLE");
props.globals.initNode("controls/bar/bar-door-4",0,"DOUBLE");
props.globals.initNode("controls/bar/bar-door-5",0,"DOUBLE");
props.globals.initNode("controls/bar/bar-door-6",0,"DOUBLE");
props.globals.initNode("controls/bar/bar-door-7",0,"DOUBLE");
props.globals.initNode("controls/bar/bar-door-8",0,"DOUBLE");
props.globals.initNode("controls/tables/table1/extend",0,"BOOL");
props.globals.initNode("controls/tables/table2/extend",0,"BOOL");
props.globals.initNode("controls/tables/table3/extend",0,"BOOL");
props.globals.initNode("controls/tables/table4/extend",0,"BOOL");
props.globals.initNode("controls/engines/disengage",0,"BOOL");
props.globals.initNode("sim/model/pilot-seat",0,"DOUBLE");
props.globals.initNode("sim/model/copilot-seat",0,"DOUBLE");
props.globals.initNode("sim/alarms/overspeed-alarm",0,"BOOL");
props.globals.initNode("sim/alarms/stall-warning",0,"BOOL");
props.globals.initNode("instrumentation/clock/flight-meter-hour",0,"DOUBLE");
props.globals.initNode("instrumentation/rcu/selected","COM","STRING");
props.globals.initNode("instrumentation/rcu/mode",0,"BOOL");
props.globals.initNode("instrumentation/rcu/squelch",0,"BOOL");
props.globals.initNode("autopilot/locks/alt-mach",0,"BOOL");
props.globals.initNode("autopilot/settings/nav-btn",0,"BOOL");
props.globals.initNode("autopilot/settings/fms-btn",0,"BOOL");
props.globals.initNode("sim/sound/startup",0,"INT");
props.globals.initNode("instrumentation/cdu/init",0,"BOOL");
props.globals.initNode("instrumentation/eicas/xfr",0,"INT");
props.globals.initNode("instrumentation/eicas/sg-rev",0,"INT");
props.globals.initNode("instrumentation/eicas/dau1",0,"BOOL");
props.globals.initNode("instrumentation/eicas/dau2",0,"BOOL");

for(n=0;n<2;n+=1) {
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/dim",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-com",0,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-nav",0,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/more",0,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-dsp",-1,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-freq",0,"DOUBLE");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/insert",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/test",0,"BOOL");
  props.globals.initNode("instrumentation/mfd["~n~"]/etx",0,"INT");
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/id-code",7777,"INT");
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/id-code[1]",77,"INT");
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/id-code[2]",77,"INT");
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/display-mode","STANDBY");
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/knob-mode",1,"INT");
  props.globals.initNode("controls/fuel/tank["~n~"]/boost_pump",0,"INT");
}

aircraft.livery.init("Aircraft/CitationX/Models/Liveries");
var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 1,1); 
var Chrono = [aircraft.timer.new("/instrumentation/mfd/chrono", 1,1),
             aircraft.timer.new("/instrumentation/mfd[1]/chrono", 1,1)];
var elt = [0,0];
var fl_tot = nil;
var fl_calc = nil;
var fcalc = nil;
var fhour = nil;
var fmeter = nil;

### tire rotation per minute by circumference ####
var TireSpeed = {
  new : func(number){
    m = { parents : [TireSpeed] };
    m.num = number;
    m.circumference = [];
    m.tire = [];
    m.rpm = [];
    m.speed = nil;
    m.wow = nil;
    for(var i=0; i<m.num; i+=1) {
      props.globals.initNode("gear/gear["~i~"]/tire-rpm",0,"DOUBLE");
      m.diam = arg[i];
      m.circ = m.diam * math.pi;
      append(m.circumference,m.circ);
      append(m.tire,"gear/gear["~i~"]/tire-rpm");
      append(m.rpm,0);
    }
    m.count = 0;
    return m;
  },
  #### calculate and write rpm ###########
  get_rotation: func (fdm1){
    me.speed = 0;
    if(fdm1 == "yasim"){
      me.speed = getprop("gear/gear["~me.count~"]/rollspeed-ms") or 0;
      me.speed = me.speed*60;
    }else if(fdm1=="jsb"){
      me.speed = getprop("fdm/jsbsim/gear/unit["~me.count~"]/wheel-speed-fps") or 0;
      me.speed = me.speed*18.288;
    }
    me.wow = getprop("gear/gear["~me.count~"]/wow");
    if(me.wow){
        me.rpm[me.count] = me.speed / me.circumference[me.count];
    }else{
        if(me.rpm[me.count] > 0) me.rpm[me.count] = me.rpm[me.count]*0.95;
    }
    setprop(me.tire[me.count],me.rpm[me.count]);
    me.count += 1;
    if(me.count >= me.num) me.count=0;
  },
}; # end of TireSpeed

#Jet Engine Helper class 
var JetEngine = {
  new : func(eng_num){
    m = { parents : [JetEngine]};
    props.globals.initNode("engines/engine["~eng_num~"]/cycle-up",0,"BOOL");
    props.globals.initNode("engines/engine["~eng_num~"]/fan",0,"DOUBLE");
    props.globals.initNode("engines/engine["~eng_num~"]/turbine",0,"DOUBLE");
    props.globals.initNode("engines/engine["~eng_num~"]/fuel-flow-pph",0,"DOUBLE");
    props.globals.initNode("engines/engine["~eng_num~"]/out-of-fuel",0,"BOOL");
    props.globals.initNode("controls/engines/engine["~eng_num~"]/throttle-lever",0,"DOUBLE");
    props.globals.initNode("controls/engines/engine["~eng_num~"]/throttle",0,"DOUBLE");
    props.globals.initNode("controls/engines/engine["~eng_num~"]/cutoff",1,"BOOL");
    props.globals.initNode("controls/engines/engine["~eng_num~"]/starter",0,"BOOL");
    props.globals.initNode("controls/engines/synchro",0,"DOUBLE");
    props.globals.initNode("surface-positions/reverser-norm["~eng_num~"]",0,"DOUBLE");
    props.globals.initNode("controls/engines/N1-limit",95.0,"DOUBLE");

    m.cycle_up = "engines/engine["~eng_num~"]/cycle-up";
    m.n1 = "engines/engine["~eng_num~"]/n1";
    m.n2 = "engines/engine["~eng_num~"]/n2";
    m.fan = "engines/engine["~eng_num~"]/fan";
    m.turbine = "engines/engine["~eng_num~"]/turbine";
    m.throttle_lever = "controls/engines/engine["~eng_num~"]/throttle-lever";
    m.throttle = "controls/engines/engine["~eng_num~"]/throttle";
    m.ignition = "controls/engines/engine["~eng_num~"]/ignition";
    m.cutoff = "controls/engines/engine["~eng_num~"]/cutoff";
    m.reverser = "controls/engines/engine["~eng_num~"]/reverser";
    m.surf_pos = "surface-positions/reverser-norm["~eng_num~"]";
    m.fuel_out = "engines/engine["~eng_num~"]/out-of-fuel";
    m.starter = "controls/engines/engine["~eng_num~"]/starter";
    m.fuel_pph = "engines/engine["~eng_num~"]/fuel-flow-pph";
    m.fuel_gph = "engines/engine["~eng_num~"]/fuel-flow-gph";
    m.oilp = "engines/engine["~eng_num~"]/oil-pressure-psi";
    m.oilp_norm = "engines/engine["~eng_num~"]/oilp-norm";
    m.sysoil = "systems/hydraulics/psi-norm["~eng_num~"]"; 
    m.diseng = "controls/engines/disengage";
    m.synchro = "controls/engines/synchro";
    m.fdensity = getprop("consumables/fuel/tank/density-ppg") or 6.72;
    m.ign = nil;
    m.thr = nil;
    m.tmprpm1 = nil;
    m.tmprpm2 = nil;
    m.n1factor = nil;
    m.n2factor = nil;
    m.engine_on = 0;
    m.revers = 0;
    ##### Reinit Chrono #####
    setprop("instrumentation/mfd/chrono",0);
    setprop("instrumentation/mfd[1]/chrono",0);
    return m;
  },

  listen : func {
    setlistener(me.reverser, func(n) {
      me.revers = n.getValue();
      if(!me.revers) setprop(me.surf_pos,0);
    },0,0);

    setlistener(me.starter, func(n) {
      if (n.getValue() and !getprop(me.cutoff)) setprop(me.cycle_up,1);     
    },0,0);

    setlistener(me.cutoff, func(n) {
      if(n.getValue()) {me.engine_on = 0;setprop(me.cycle_up,0)}
    },0,0);

    setlistener(me.diseng, func(n){
	    if(n.getValue()) setprop(me.cycle_up,0);
    },0,0);

    setlistener(me.synchro, func(n){
	    if(n.getValue() != 0) setprop("controls/engines/engine[1]/throttle",getprop("controls/engines/engine/throttle"));
    },0,0);

    setlistener(me.fuel_out, func me.shutdown(getprop(me.fuel_out)),0,0);
  },

  update : func {
    me.thr = getprop(me.throttle);
    if(me.engine_on){
      setprop(me.fan,getprop(me.n1));
      setprop(me.turbine,getprop(me.n2));
      if(getprop("controls/engines/grnd_idle")) me.thr *= 0.92;
      setprop(me.throttle_lever,me.thr);
    } else {
      setprop(me.throttle_lever,0);
      if(getprop(me.cycle_up)) me.spool_up(15);
      else {
        me.tmprpm = getprop(me.fan);
        if(me.tmprpm > 0.0){
            me.tmprpm -= getprop("sim/time/delta-sec") * 2;
            setprop(me.fan,me.tmprpm);
            setprop(me.turbine,me.tmprpm);
        }
      }
    }
    if(me.revers) setprop(me.surf_pos,getprop(me.throttle));

    ### Fuel ###
    setprop(me.fuel_pph,getprop(me.fuel_gph) * me.fdensity);

    #### Engines Oil Pressure Display ####
    if (getprop(me.sysoil) >= 0.1 ) {
        if (getprop(me.oilp_norm) < 0.1) setprop(me.oilp,getprop(me.sysoil)*50);
        else setprop(me.oilp,getprop(me.oilp_norm)*44.4 +45.6);
    } else setprop(me.oilp,0);
  }, # end of update

  spool_up : func(scnds){
      me.n1factor = getprop(me.n1)/scnds;
      me.n2factor = getprop(me.n2)/scnds;
      me.tmprpm1 = getprop(me.fan);
      me.tmprpm1 += getprop("sim/time/delta-sec") * me.n1factor;
      me.tmprpm2 = getprop(me.turbine);
      me.tmprpm2 += getprop("sim/time/delta-sec") * me.n2factor;
      setprop(me.fan,me.tmprpm1);
      setprop(me.turbine,me.tmprpm2);
      if(me.tmprpm1 >= 40){
        setprop(me.cycle_up,0);
        me.engine_on = 1;
      }
  }, # end of spool_up

  shutdown : func(b){
      if(b) setprop(me.cutoff,1);
  }, # end of shutdown

}; # end of JetEngine


### Listeners ###

setlistener("/sim/crashed", func(n){
    if(n.getValue()){
    }
},0,0);

setlistener("sim/model/autostart", func(n){
    if(n.getValue()){
        Startup();
    }else{
        Shutdown();
    }
},0,0);

setlistener("instrumentation/altimeter/setting-inhg", func(n){
    setprop("instrumentation/altimeter/setting-kpa",n.getValue()*3.386389);
},0,0);

setlistener("/sim/current-view/internal", func(n) {
		if (n.getValue()) {
			setprop("sim/model/show-yoke_L",getprop("sim/model/mem-yoke_L"));
			setprop("sim/model/show-pilot",getprop("sim/model/mem-yoke_L"));
			setprop("sim/model/show-yoke_R",getprop("sim/model/mem-yoke_R"));
			setprop("sim/model/show-copilot",getprop("sim/model/mem-yoke_R"));
		} 
		else {
			setprop("sim/model/show-yoke_L",1);
			setprop("sim/model/show-yoke_R",1);
			setprop("sim/model/show-pilot",1);
			setprop("sim/model/show-copilot",1);
		}
},0,0);

setlistener("/gear/gear[0]/wow", func(ww){
    if(ww.getValue()){
        FHmeter.stop();
        setprop("controls/engines/grnd-idle",1);			
				FH_write();
        setprop("autopilot/locks/fms-gs",0);
    }else{
        setprop("controls/engines/grnd-idle",0);			
        FHmeter.start();
				### raz clock to prevent restart on bounce ###
				setprop("/instrumentation/clock/flight-meter-sec",0);
    }
},0,0);

### Chrono ###
setlistener("instrumentation/mfd/et", func(n){
  el_time(0,n.getValue());
},0,0);

setlistener("instrumentation/mfd[1]/et", func(n){
  el_time(1,n.getValue());
},0,0);

var el_time = func(x,n) {
  if(getprop("systems/electrical/right-bus-norm") and getprop("controls/electric/avionics-switch")==2) {
	  if(n){
	    if(elt[x] <= 2) elt[x] += 1;
	    else elt[x] = 0 ;
	    setprop("instrumentation/mfd["~x~"]/etx",elt[x]);
	    if(elt[x] == 1) Chrono[x].start();
	    if(elt[x] == 2) Chrono[x].stop();
	    if(elt[x] == 3) Chrono[x].reset();		
	  }
  }
}

### Flight Meter ###
var FHupdate = func {
    fmeter = getprop("/instrumentation/clock/flight-meter-sec");
    fhour = fmeter/3600;
    fl_calc = fl_tot + fhour;
    fcalc = int((fl_calc-int(fl_calc))*10);
    fdsp = int(fl_calc)+fcalc/10;
    setprop("instrumentation/clock/flight-meter-dsp",fdsp);
}

var FH_load = func{
    ### Create CitationX Path if not exists ### 
		var path = os.path.new(getprop("/sim/fg-home")~"/Export/CitationX/create.txt");
    if (!path.exists()) {
      path.create_dir();
    }
    ######
    var FH_path  = getprop("/sim/fg-home")~"/Export/CitationX/";
		var name = FH_path~"FHmeter.xml";
		var xfile = subvec(directory(FH_path),2);
		var v = std.Vector.new(xfile);
		if (!v.contains("FHmeter.xml")) {
			var data = props.Node.new({
					TotalFlight : 0
			});		
			io.write_properties(name,data);
		} 
		var data = io.read_properties(name);
		fl_tot = data.getValue("TotalFlight");
}

var FH_write = func {
    if (fl_calc != nil) {
		  var FH_path = getprop("/sim/fg-home")~"/Export/CitationX/FHmeter.xml";
		  var data = io.read_properties(FH_path);
		  var name = data.getChild("TotalFlight");
      fl_tot = fl_calc;
      name.setValue(fl_calc);
		  io.write_properties(FH_path,data);
      setprop("/instrumentation/clock/flight-meter-sec",0);
    }
}

######################
controls.stepSpoilers = func(v) {
    if (v < 0) {setprop("/controls/flight/speedbrake", 0)}
		else if (v > 0) {setprop("/controls/flight/speedbrake", 1)}
}

controls.synchro = func {
  var synchro = "controls/engines/synchro";
    if (getprop(synchro) == -1) ud = 1;
    if (getprop(synchro) == 1) ud = -1;
      setprop(synchro,getprop(synchro) + ud);
}

controls.pilots = func() {
	if (getprop("sim/model/show-yoke_L") == 0) {
		setprop("sim/model/show-pilot",0);
		setprop("sim/model/mem-yoke_L",0);
	} else {			
		setprop("sim/model/show-pilot",1);
		setprop("sim/model/mem-yoke_L",1);
	}
	if (getprop("sim/model/show-yoke_R") == 0) {
		setprop("sim/model/show-copilot",0);
		setprop("sim/model/mem-yoke_R",0);
	} else {			
		setprop("sim/model/show-copilot",1);
		setprop("sim/model/mem-yoke_R",1);
	}
}

controls.flapsDown = func(step) {
		var flaps_pos = getprop("controls/flight/flaps");
		var flaps_path = "controls/flight/flaps";
		var flaps_select = "controls/flight/flaps-select";
		if (step == 1) {
			if (flaps_pos == 0) {
				setprop(flaps_path, 0.0428);
				setprop(flaps_select,1);
			}
			if (flaps_pos == 0.0428) {
				setprop(flaps_path, 0.142);
				setprop(flaps_select,2);
			}
			if (flaps_pos == 0.142) {
				setprop(flaps_path, 0.428);
				setprop(flaps_select,3);
			}
			if (flaps_pos == 0.428) {
				setprop(flaps_path,1);
				setprop(flaps_select,4);
			}
		}
		if (step == -1) {
			if (flaps_pos == 1) {
				setprop(flaps_path, 0.428);
				setprop(flaps_select,3);
			}
			if (flaps_pos == 0.428) {
				setprop(flaps_path, 0.142);
				setprop(flaps_select,2);
			}
			if (flaps_pos == 0.142) {
				setprop(flaps_path, 0.0428);
				setprop(flaps_select,1);
			}
			if (flaps_pos == 0.0428) {
				setprop(flaps_path,0);
				setprop(flaps_select,0);
			}
    }
    if (step == 2) {
				setprop(flaps_path, 0);
				setprop(flaps_select,0);
		}
}

var Startup = func{
    setprop("controls/electric/external-power",1);
    setprop("controls/electric/engine[0]/generator",1);
    setprop("controls/electric/engine[1]/generator",1);
    setprop("controls/electric/battery-switch",1);
    setprop("controls/electric/battery-switch[1]",1);
    setprop("controls/electric/inverter-switch",1);
    setprop("controls/electric/std-by-pwr",1);
    setprop("controls/electric/avionics-switch",2);
    setprop("controls/lighting/nav-lights",1);
    setprop("controls/lighting/beacon",1);
    setprop("controls/lighting/strobe",1);
    setprop("controls/lighting/recog-lights",1);
    setprop("controls/lighting/anti-coll",2);
    setprop("controls/engines/engine[0]/cutoff",0);
    setprop("controls/engines/engine[1]/cutoff",0);
    setprop("controls/engines/engine[0]/ignition",0);
    setprop("controls/engines/engine[1]/ignition",0);
		setprop("controls/engines/engine[0]/starter",1);
		setprop("controls/engines/engine[1]/starter",1);
		setprop("controls/engines/engine[0]/starter",0);
		setprop("controls/engines/engine[1]/starter",0);
		setprop("controls/flight/flaps",0.428);
		setprop("controls/flight/flaps-select",3);
		setprop("controls/anti-ice/pitot-heat",1);
		setprop("controls/anti-ice/pitot-heat[1]",1);
		setprop("controls/anti-ice/window-heat",1);
		setprop("controls/anti-ice/window-heat[1]",1);
 		var startup_stl = setlistener("systems/electrical/right-bus",func {
			if (getprop("systems/electrical/right-bus") > 27) {
				setprop("controls/electric/external-power",0);
				removelistener(startup_stl);
			}
		},0,0);
}

var Shutdown = func{
    setprop("controls/electric/engine[0]/generator",0);
    setprop("controls/electric/engine[1]/generator",0);
    setprop("controls/electric/avionics-switch",0);
    setprop("controls/electric/battery-switch",0);
    setprop("controls/electric/battery-switch[1]",0);
    setprop("controls/electric/inverter-switch",0);
    setprop("controls/electric/std-by-pwr",0);
    setprop("controls/lighting/nav-lights",0);
    setprop("controls/lighting/beacon",0);
    setprop("controls/lighting/strobe",0);
    setprop("controls/lighting/recog-lights",0);
    setprop("controls/lighting/anti-coll",0);
    setprop("controls/engines/engine[0]/cutoff",1);
    setprop("controls/engines/engine[1]/cutoff",1);
    setprop("controls/engines/engine[0]/ignition",1);
    setprop("controls/engines/engine[1]/ignition",1);
		setprop("instrumentation/annunciators/ack-caution",1);
		setprop("instrumentation/annunciators/ack-warning",1);
		setprop("controls/electric/external-power",0);
		setprop("controls/flight/flaps",0);
		setprop("controls/flight/flaps-select",0);
		setprop("controls/anti-ice/pitot-heat",0);
		setprop("controls/anti-ice/pitot-heat[1]",0);
		setprop("controls/anti-ice/window-heat",0);
		setprop("controls/anti-ice/window-heat[1]",0);
}

var Vref_update = func {
	var Wtot = getprop("yasim/gross-weight-lbs");
	if (Wtot >=23000 and Wtot <24000) {vref=108}
	if (Wtot >=24000 and Wtot <25000) {vref=110}
	if (Wtot >=25000 and Wtot <26000) {vref=113}
	if (Wtot >=26000 and Wtot <28000) {vref=115}
	if (Wtot >=28000 and Wtot <30000) {vref=121}
	if (Wtot >=30000 and Wtot <31000) {vref=125}
	if (Wtot >=31000 and Wtot <31800) {vref=129}
	if (Wtot >=31800) {vref=131}
	setprop("controls/flight/vref",vref);
  settimer(Vref_update,60);
}

### Tables animation ###

var tables_anim = func(i) {
	props.globals.initNode("controls/tables/table"~i~"/cache/open",0,"BOOL");
	var Table_0 = aircraft.door.new("controls/tables/table"~i~"/tab0",2);
	var Table_1 = aircraft.door.new("controls/tables/table"~i~"/tab1",2);
	var Table_2 = aircraft.door.new("controls/tables/table"~i~"/tab2",2);
	var Cache = aircraft.door.new("controls/tables/table"~i~"/cache",1);
	var cc = "controls/tables/table"~i~"/cache/open";

	var timer_open = maketimer(0.1,func {
		if (getprop("controls/tables/table"~i~"/cache/position-norm")==1.0) {
			Table_0.open();
			if (getprop("controls/tables/table"~i~"/tab0/position-norm")==1.0) {
				Table_1.open();
				if (getprop("controls/tables/table"~i~"/tab1/position-norm")==1.0) {
					Table_2.open();
					if (getprop("controls/tables/table"~i~"/tab2/position-norm")==1.0) {
						setprop(cc,1);
						Cache.close();
						timer_open.stop();
					}
				}				
			}			
		}
	});
	if (getprop("controls/tables/table"~i~"/extend") and !getprop(cc)) {
		Cache.open();			
		timer_open.start();
	}

	var timer_close = maketimer(0.1,func {
		if (getprop("controls/tables/table"~i~"/cache/position-norm")==1.0) {
			Table_2.close();
			if (getprop("controls/tables/table"~i~"/tab2/position-norm")==0.0) {
				Table_1.close();
				if (getprop("controls/tables/table"~i~"/tab1/position-norm")==0.0) {
					Table_0.close();
					if (getprop("controls/tables/table"~i~"/tab0/position-norm")==0.0) {
						setprop(cc,0);
						Cache.close();
						timer_close.stop();
					}
				}
			}
		}
	});
	if (!getprop("controls/tables/table"~i~"/extend") and getprop(cc)) {
		Cache.open();
		timer_close.start();
	}
}

########## MAIN ##############
var grspd = nil;
var wspd = nil;
var rudder_pos = nil;
var Leng = Reng = nil;
var tire = nil;
var ud = 1; # for engines synchro

var citation_stl = setlistener("/sim/signals/fdm-initialized", func {
    checkVersion();
    tire = TireSpeed.new(3,0.430,0.615,0.615);
    Leng = JetEngine.new(0);
    Reng = JetEngine.new(1);
    Leng.listen();
    Reng.listen();
    settimer(update_systems,2);
		setprop("instrumentation/altimeter/setting-inhg",29.92001);
		setprop("instrumentation/clock/flight-meter-sec",0);
#		setprop("sim/sound/startup",int(10*rand()));
    setprop("controls/engines/engine/ignition",1);
    setprop("controls/engines/engine[1]/ignition",1);
		FH_load();
		var v_ref = func() {Vref_update();}
		var timer = maketimer(10,v_ref);
		timer.singleShot = 1;
		timer.start();
    removelistener(citation_stl);
},0,0);

var update_systems = func{
    Leng.update();
    Reng.update();
    FHupdate();
    tire.get_rotation("yasim");
    grspd = getprop("velocities/groundspeed-kt");
    if (grspd > 40) setprop("controls/cabin-door/open",0);
    wspd = (120-grspd) * 0.01;
    if(wspd>1.0) wspd = 1.0;
    if(wspd<0.001) wspd = 0.001;
    rudder_pos = getprop("controls/flight/rudder") or 0;
    setprop("/controls/gear/steering",-rudder_pos*wspd);
    settimer(update_systems,0);
}


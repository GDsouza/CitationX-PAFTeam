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
    props.globals.initNode("engines/engine["~eng_num~"]/cycle_up",0,"BOOL");
    props.globals.initNode("engines/engine["~eng_num~"]/running",0,"BOOL");
    props.globals.initNode("engines/engine["~eng_num~"]/fan",0,"DOUBLE");
    props.globals.initNode("engines/engine["~eng_num~"]/turbine",0,"DOUBLE");
    props.globals.initNode("engines/engine["~eng_num~"]/fuel-flow_pph",0,"DOUBLE");
    props.globals.initNode("engines/engine["~eng_num~"]/fuel-flow_gph",0,"DOUBLE");
    props.globals.initNode("engines/engine["~eng_num~"]/out-of-fuel",0,"BOOL");
    props.globals.initNode("controls/engines/engine["~eng_num~"]/throttle-lever",0,"DOUBLE");
    props.globals.initNode("controls/engines/engine["~eng_num~"]/throttle",0,"DOUBLE");
    props.globals.initNode("controls/engines/engine["~eng_num~"]/ignit",0,"INT");
    props.globals.initNode("controls/engines/engine["~eng_num~"]/cutoff",1,"BOOL");
    props.globals.initNode("controls/engines/engine["~eng_num~"]/starter",0,"BOOL");
    props.globals.initNode("controls/engines/N1-limit",95.0,"DOUBLE");
    m.fdensity = getprop("consumables/fuel/tank/density-ppg") or 6.72;
    m.cycle_up = "engines/engine["~eng_num~"]/cycle_up";
    m.running = "engines/engine["~eng_num~"]/running";
    m.n1 = "engines/engine["~eng_num~"]/n1";
    m.n2 = "engines/engine["~eng_num~"]/n2";
    m.fan = "engines/engine["~eng_num~"]/fan";
    m.turbine = "engines/engine["~eng_num~"]/turbine";
    m.throttle_lever = "controls/engines/engine["~eng_num~"]/throttle-lever";
    m.throttle = "controls/engines/engine["~eng_num~"]/throttle";
    m.ignition = "controls/engines/engine["~eng_num~"]/ignit";
    m.cutoff = "controls/engines/engine["~eng_num~"]/cutoff";
    m.fuel_out = "engines/engine["~eng_num~"]/out-of-fuel";
    m.starter = "controls/engines/engine["~eng_num~"]/starter";
    m.fuel_pph = "engines/engine["~eng_num~"]/fuel-flow_pph";
    m.fuel_gph = "engines/engine["~eng_num~"]/fuel-flow_gph";
    m.Lfuel = setlistener(m.fuel_out, func m.shutdown(getprop(m.fuel_out)),0,0);
    m.CutOff = setlistener(m.cutoff, func (ct){m.engine_off=ct.getValue()},0,0);
    m.engine_off = 1;
    m.oilp_norm = "engines/engine/oilp-norm";
    m.oilp = "engines/engine/oil-pressure-psi";
    m.oilp1_norm = "engines/engine[1]/oilp-norm";
    m.oilp1 = "engines/engine[1]/oil-pressure-psi";
    m.sysoil = "systems/hydraulics/psi-norm"; 
    m.sysoil1 = "systems/hydraulics/psi-norm[1]"; 
    m.ign = nil;
    m.thr = nil;
    m.tmprpm1 = nil;
    m.tmprpm2 = nil;
    m.n1factor = nil;
    m.n2factor = nil;
    return m;
  },

  update : func{
    me.thr = getprop(me.throttle);
    if(!me.engine_off){
      setprop(me.fan,getprop(me.n1));
      setprop(me.turbine,getprop(me.n2));
      if(getprop("controls/engines/grnd_idle")) me.thr *= 0.92;
      setprop(me.throttle_lever,me.thr);
    } else {
      setprop(me.throttle_lever,0);
      if(getprop(me.starter)){
        if(!getprop(me.cycle_up)) setprop(me.cycle_up,1);
      }
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
    setprop(me.fuel_pph,getprop(me.fuel_gph) * me.fdensity);

    #### For Engines Oil Pressure Display ####
    if (getprop(me.sysoil) >= 0.1 ) {
        if (getprop(me.oilp_norm) < 0.1) setprop(me.oilp,getprop(me.sysoil)*50);
        else setprop(me.oilp,getprop(me.oilp_norm)*44.4 +45.6);
    } else setprop(me.oilp,0);
    if (getprop(me.sysoil1) >= 0.1 ) {
        if (getprop(me.oilp1_norm) < 0.1) setprop(me.oilp1,getprop(me.sysoil1)*50);
        else setprop(me.oilp1,getprop(me.oilp1_norm)*44.4 +45.6);
    } else setprop(me.oilp1,0);
  },

  spool_up : func(scnds){
    if(me.engine_off){
      me.n1factor = getprop(me.n1)/scnds;
      me.n2factor = getprop(me.n2)/scnds;
      me.tmprpm1 = getprop(me.fan);
      me.tmprpm1 += getprop("sim/time/delta-sec") * me.n1factor;
      me.tmprpm2 = getprop(me.turbine);
      me.tmprpm2 += getprop("sim/time/delta-sec") * me.n2factor;
      setprop(me.fan,me.tmprpm1);
      setprop(me.turbine,me.tmprpm2);
      if(me.tmprpm1 >= getprop(me.n1)){
				if (getprop(me.ignition) == -1) {
					me.ign = 1 + getprop(me.ignition);
				} else me.ign = 1 - getprop(me.ignition);
        setprop(me.cutoff,me.ign);
        setprop(me.cycle_up,0);
      }
    }
  },

  shutdown : func(b){
      if(b) setprop(me.cutoff,1);
  }
}; # end of JetEngine

var fl_tot = 0;
var FDM="";
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
props.globals.initNode("instrumentation/mfd/etx",0,"INT");
props.globals.initNode("instrumentation/mfd[1]/etx",0,"INT");
props.globals.initNode("instrumentation/transponder/unit/id-code",7777,"INT");
props.globals.initNode("instrumentation/transponder/unit/id-code[1]",77,"INT");
props.globals.initNode("instrumentation/transponder/unit/id-code[2]",77,"INT");
props.globals.initNode("instrumentation/transponder/unit/display-mode","STANDBY");
props.globals.initNode("instrumentation/transponder/unit/knob-mode",1,"INT");
props.globals.initNode("instrumentation/transponder/unit[1]/id-code",7777,"INT");
props.globals.initNode("instrumentation/transponder/unit[1]/id-code[1]",77,"INT");
props.globals.initNode("instrumentation/transponder/unit[1]/id-code[2]",77,"INT");
props.globals.initNode("instrumentation/transponder/unit[1]/display-mode","STANDBY");
props.globals.initNode("instrumentation/transponder/unit[1]/knob-mode",1,"INT");
props.globals.initNode("instrumentation/rmu/unit/dim",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/dim",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/mem-com",0,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/mem-com",0,"INT");
props.globals.initNode("instrumentation/rmu/unit/mem-nav",0,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/mem-nav",0,"INT");
props.globals.initNode("instrumentation/rmu/unit/more",0,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/more",0,"INT");
props.globals.initNode("instrumentation/rmu/unit/mem-dsp",-1,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/mem-dsp",-1,"INT");
props.globals.initNode("instrumentation/rmu/unit/mem-freq",0,"DOUBLE");
props.globals.initNode("instrumentation/rmu/unit[1]/mem-freq",0,"DOUBLE");
props.globals.initNode("instrumentation/rmu/unit/insert",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/insert",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/test",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/test",0,"BOOL");
props.globals.initNode("instrumentation/rcu/selected","COM","STRING");
props.globals.initNode("instrumentation/rcu/mode",0,"BOOL");
props.globals.initNode("instrumentation/rcu/squelch",0,"BOOL");
props.globals.initNode("autopilot/locks/alt-mach",0,"BOOL");
props.globals.initNode("autopilot/settings/nav-btn",0,"BOOL");
props.globals.initNode("autopilot/settings/fms-btn",0,"BOOL");
props.globals.initNode("sim/sound/startup",0,"INT");
props.globals.initNode("instrumentation/cdu/init",0,"BOOL");

aircraft.livery.init("Aircraft/CitationX/Models/Liveries");
var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 1,1); 
var Chrono = [aircraft.timer.new("/instrumentation/mfd/chrono", 1,1),
             aircraft.timer.new("/instrumentation/mfd[1]/chrono", 1,1)];
var LHeng = JetEngine.new(0);
var RHeng = JetEngine.new(1);
var tire=TireSpeed.new(3,0.430,0.615,0.615);
var elt = [0,0];

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

var turb0_stl = setlistener("/engines/engine[0]/turbine",func(n) {
		if(n.getValue() >20) {
			setprop("/controls/engines/engine[0]/starter",0);
			removelistener(turb0_stl);
		}
},0,0);

var turb1_stl = setlistener("/engines/engine[1]/turbine",func(n) {
		if(n.getValue() >20) {
			setprop("/controls/engines/engine[1]/starter",0);
			removelistener(turb1_stl);
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

setlistener("controls/flight/elevator-trim",func (n) {
    setprop("controls/flight/elevator-trim-calc",n.getValue()*6.6 - 5.4);
},1,0);

setlistener("controls/engines/disengage", func(n){
	if(n.getBoolValue()){
		if(LHeng.cycle_up.getBoolValue())	{
			LHeng.cycle_up.setBoolValue(0);
			LHeng.cutoff.setBoolValue(1);
		}
		if(RHeng.cycle_up.getBoolValue())	{
			RHeng.cycle_up.setBoolValue(0);
			RHeng.cutoff.setBoolValue(1);
		}
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
### Flight Meter ###

var FHupdate = func(tenths){
    var fmeter = getprop("/instrumentation/clock/flight-meter-sec");
    var fhour = fmeter/3600;
    setprop("instrumentation/clock/flight-meter-hour",fhour);
    var fmin = fhour - int(fhour);
    if(tenths !=0){
        fmin *=100;
    }else{
        fmin *=60;
    }
    setprop("instrumentation/clock/flight-meter-min",int(fmin));
		setprop("instrumentation/clock/flight-meter-tot",fl_tot+fhour);
}

var FH_load = func{
		var FH_path = getprop("/sim/fg-home")~"/aircraft-data/";
		var name = FH_path~"CitationX-FHmeter.xml";
		var xfile = subvec(directory(FH_path),2);
		var v = std.Vector.new(xfile);
		if (!v.contains("CitationX-FHmeter.xml")) {
			var data = props.Node.new({
					TotalFlight : 0
			});		
			io.write_properties(name,data);
		} 
		var data = io.read_properties(name);
		fl_tot = data.getValue("TotalFlight");
		setprop("/instrumentation/clock/flight-meter-tot",fl_tot);
}

var FH_write = func {
		var FH_path = getprop("/sim/fg-home")~"/aircraft-data/CitationX-FHmeter.xml";
		fl_tot = getprop("instrumentation/clock/flight-meter-tot");
		var data = io.read_properties(FH_path);
		var name = data.getChild("TotalFlight");
		name.setValue(fl_tot);
		io.write_properties(FH_path,data);
}

######################

controls.pilots = func(){
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

controls.gearDown = func(v) {
    if (v < 0) {
        if(!getprop("gear/gear[1]/wow"))setprop("/controls/gear/gear-down", 0);
    } elsif (v > 0) {
      setprop("/controls/gear/gear-down", 1);
    }
}

controls.stepSpoilers = func(v) {
    if (v < 0) {setprop("/controls/flight/speedbrake", 0)}
		else if (v > 0) {setprop("/controls/flight/speedbrake", 1)}
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
    setprop("controls/engines/engine[0]/cutoff",1);
    setprop("controls/engines/engine[1]/cutoff",1);
    setprop("controls/engines/engine[0]/ignit",-1);
    setprop("controls/engines/engine[1]/ignit",-1);
    setprop("engines/engine[0]/running",1);
    setprop("engines/engine[1]/running",1);
		setprop("controls/engines/engine[0]/starter",1);
		setprop("controls/engines/engine[1]/starter",1);
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
    setprop("controls/engines/engine[0]/ignit",0);
    setprop("controls/engines/engine[1]/ignit",0);
    setprop("engines/engine[0]/running",0);
    setprop("engines/engine[1]/running",0);
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

########## MAIN ##############
var grspd = nil;
var wspd = nil;
var rudder_pos = nil;

var citation_stl = setlistener("/sim/signals/fdm-initialized", func {
    checkVersion();
    settimer(update_systems,2);
		setprop("instrumentation/altimeter/setting-inhg",29.92001);
		setprop("instrumentation/clock/flight-meter-sec",0);
#		setprop("sim/sound/startup",int(10*rand()));
		FH_load();
		var v_ref = func() {		
			Vref_update();
		}
		var timer = maketimer(10,v_ref);
		timer.singleShot = 1;
		timer.start();
    removelistener(citation_stl);
},0,0);

var update_systems = func{
    LHeng.update();
    RHeng.update();
    FHupdate(0);
    tire.get_rotation("yasim");
    if(getprop("velocities/airspeed-kt")>40)setprop("controls/cabin-door/open",0);
    grspd = getprop("velocities/groundspeed-kt");
    wspd = (120-grspd) * 0.01;
#    wspd = (120-grspd) * 0.002;
#    wspd = (45-grspd) * 0.022222;
    if(wspd>1.0) wspd = 1.0;
    if(wspd<0.001) wspd = 0.001;
    rudder_pos = getprop("controls/flight/rudder") or 0;
    setprop("/controls/gear/steering",-rudder_pos*wspd);
    settimer(update_systems,0);
}

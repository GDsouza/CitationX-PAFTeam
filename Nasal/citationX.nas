### Citation X ####
### Révision C. Le Moigne (clm76) - 2015,2016,2019,2021  ###

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

aircraft.livery.init("Models/Liveries");
var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec",60,0);
var Chrono = [aircraft.timer.new("/instrumentation/mfd/chrono", 1,1),
             aircraft.timer.new("/instrumentation/mfd[1]/chrono", 1,1)];
var flaps = "controls/flight/flaps";
var slats = "controls/flight/slats";
var fh_tot = "instrumentation/clock/flight-hour-tot";
var fh_sec = "instrumentation/clock/flight-meter-sec";
var fh_get = 0;
var fh_path  = getprop("/sim/fg-home")~"/Export/CitationX/FHmeter.xml";
var flaps_pos = nil;
var flaps_sel = nil;
var elt = [0,0];
var fhour = nil;
var et = 0;
var elec = 1;
var data = nil;

### tire rotation per minute by circumference ####
#var TireSpeed = {
#  new : func(number){
#    m = { parents : [TireSpeed] };
#    m.num = number;
#    m.circumference = [];
#    m.tire = [];
#    m.rpm = [];
#    m.speed = nil;
#    m.wow = nil;
#    for(var i=0; i<m.num; i+=1) {
#      m.diam = arg[i];
#      m.circ = m.diam * math.pi;
#      append(m.circumference,m.circ);
#      append(m.tire,"gear/gear["~i~"]/tire-rpm");
#      append(m.rpm,0);
#    }
#    m.count = 0;
#    return m;
#  },
  #### calculate and write rpm ###########
#  get_rotation: func (fdm1){
#    me.speed = 0;
#    if(fdm1 == "yasim"){
#      me.speed = getprop("gear/gear["~me.count~"]/rollspeed-ms") or 0;
#      me.speed = me.speed*60;
#    }else if(fdm1=="jsb"){
#      me.speed = getprop("fdm/jsbsim/gear/unit["~me.count~"]/wheel-speed-fps") or 0;
#      me.speed = me.speed*18.288;
#    }
#    me.wow = getprop("gear/gear["~me.count~"]/wow");
#    if(me.wow){
#        me.rpm[me.count] = me.speed / me.circumference[me.count];
#    }else{
#        if(me.rpm[me.count] > 0) me.rpm[me.count] = me.rpm[me.count]*0.95;
#    }
#    setprop(me.tire[me.count],me.rpm[me.count]);
#    me.count += 1;
#    if(me.count >= me.num) me.count=0;
#  },
#}; # end of TireSpeed

#Jet Engine Helper class
var JetEngine = {
  new : func(eng_num){
    m = { parents : [JetEngine]};

    m.cycle_up = "engines/engine["~eng_num~"]/cycle-up";
    m.fan = "engines/engine["~eng_num~"]/fan";
    m.turbine = "engines/engine["~eng_num~"]/turbine";
    m.fadec = "controls/engines/engine["~eng_num~"]/fadec";
    m.fadec_btn = "controls/engines/engine["~eng_num~"]/fadec-btn";
    m.throttle = "controls/engines/engine["~eng_num~"]/throttle";
    m.ignition = "controls/engines/engine["~eng_num~"]/ignition";
    m.cutoff = "controls/engines/engine["~eng_num~"]/cutoff";
    m.reverser = "controls/engines/engine["~eng_num~"]/reverser";
    m.surf_pos = "surface-positions/reverser-norm["~eng_num~"]";
    m.fuel_out = "engines/engine["~eng_num~"]/out-of-fuel";
    m.starter = "controls/engines/engine["~eng_num~"]/starter";
    m.fuel_pph = "engines/engine["~eng_num~"]/fuel-flow-pph";
    m.fuel_gph = "engines/engine["~eng_num~"]/fuel-flow-gph";
    m.n1 = "engines/engine["~eng_num~"]/n1";
    m.n2 = "engines/engine["~eng_num~"]/n2";
    m.oilp = "engines/engine["~eng_num~"]/oil-pressure-psi";
    m.running = "controls/engines/engine["~eng_num~"]/running";
    m.pack = "controls/pressurization/pack["~eng_num~"]/pack-on";
    m.sysoil = "systems/hydraulics/psi-norm["~eng_num~"]";
    m.boost_p = "controls/fuel/tank["~eng_num~"]/boost-pump";
    m.diseng = "controls/engines/disengage";
    m.synchro = "controls/engines/synchro";
    if (eng_num == 0) m.el_start = "systems/electrical/outputs/lh-start";
    else m.el_start = "systems/electrical/outputs/rh-start";

    m.fdensity = getprop("consumables/fuel/tank/density-ppg") or 6.72;
    m.ign = nil;
    m.thr = nil;
    m.tmprpm1 = nil;
    m.tmprpm2 = nil;
    m.n1factor = nil;
    m.n2factor = nil;
    m.engine_on = 0;
    m.revers = 0;
    m.fuel = 0;

    ##### Reinit Chrono #####
    setprop("instrumentation/mfd/chrono",0);
    setprop("instrumentation/mfd[1]/chrono",0);
    ##### Init Fadecs #####
    setprop(m.fadec,rand() < 0.5 ? "A" : "B");
    return m;
  },

  listen : func {

    setlistener(me.diseng, func(n){
	    if(n.getValue()) setprop(me.cycle_up,0);
    },0,0);

    setlistener(me.synchro, func(n){
	    if(n.getValue() != 0) setprop("controls/engines/engine[1]/throttle",getprop("controls/engines/engine/throttle"));
    },0,0);

    setlistener(me.fuel_out, func me.shutdown(getprop(me.fuel_out)),0,0);

    setlistener(me.fadec_btn, func(n){
	    if(n.getValue() == -1) {
        if (getprop(me.fadec) == "A") setprop(me.fadec,"B");
        else setprop(me.fadec,"A");
      }
    },0,0);
  }, # end of listen

  update : func {
    if (getprop(me.cutoff)) {
      me.engine_on = 0;
      setprop(me.cycle_up,0);
      setprop(me.pack,0);
    }
    if (getprop(me.starter) and !getprop(me.cutoff) and getprop (me.el_start))
      setprop(me.cycle_up,1);

    me.thr = getprop(me.throttle);
    if(me.engine_on){
      if (getprop(me.fan) < getprop(me.n1)) me.spool_up(10);
      if (getprop(me.fan) > getprop(me.n1)) me.spool_dwn(10);
      setprop(me.turbine,getprop(me.n2));
      if(getprop("controls/engines/grnd_idle")) me.thr *= 0.92;
    } else {
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

    ### Engine running ###
    setprop(me.running,me.engine_on);

    ### Reverser ###
    me.revers = getprop(me.reverser);
    if(!me.revers) setprop(me.surf_pos,0);
    else setprop(me.surf_pos,getprop(me.throttle));

    ### Fuel ###
    if (getprop(me.turbine) <= 58) me.fuel = getprop(me.turbine);
    else me.fuel = getprop(me.fuel_gph)*me.fdensity;
    setprop(me.fuel_pph,getprop(me.boost_p) ? me.fuel*1.1 : me.fuel);

    ### Engines Oil Pressure Display ###
     setprop(me.oilp,getprop(me.sysoil)*56); # nominal press = 56 psi

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
        setprop(me.pack,1);
      }
  }, # end of spool_up

  spool_dwn : func(scnds){
      me.n1factor = getprop(me.n1)/scnds;
      me.n2factor = getprop(me.n2)/scnds;
      me.tmprpm1 = getprop(me.fan);
      me.tmprpm1 -= getprop("sim/time/delta-sec") * me.n1factor;
      me.tmprpm2 = getprop(me.turbine);
      me.tmprpm2 -= getprop("sim/time/delta-sec") * me.n2factor;
      setprop(me.fan,me.tmprpm1);
      setprop(me.turbine,me.tmprpm2);
  }, # end of spool_dwn

  shutdown : func(b){
      if(b) setprop(me.cutoff,1);
  }, # end of shutdown
}; # end of JetEngine


### Listeners ###

setlistener("/sim/crashed", func(n){
    if(n.getValue()){
      screen.log.write("Crashhhh!", 1.0, 0.0, 0.0);
      # Instantaneous silence...
      Shutdown();
      setprop("engines/engine[1]/fan", 0);
      setprop("engines/engine[1]/turbine", 0);
      setprop("engines/engine[0]/fan", 0);
      setprop("engines/engine[0]/turbine", 0);
   }
},1,0);

setlistener("accelerations/limit-exceeded-alert", func(n) {
   if (n.getBoolValue()) {
     screen.log.write("Aircraft structural limits exceeded.",1.0, 0.5, 0.0);
   }
},1,0);

setlistener("sim/model/autostart", func(n){
    if(n.getValue()){
      setprop("controls/electric/external-power",1);
      Startup();
    } else Shutdown();
},0,0);

setlistener("/sim/current-view/internal", func(n) {
		if (n.getValue()) {
			setprop("sim/model/show-yoke-L",getprop("sim/model/mem-yoke-L"));
			setprop("sim/model/show-pilot",getprop("sim/model/mem-yoke-L"));
			setprop("sim/model/show-yoke-R",getprop("sim/model/mem-yoke-R"));
			setprop("sim/model/show-copilot",getprop("sim/model/mem-yoke-R"));
		}
		else {
			setprop("sim/model/show-yoke-L",1);
			setprop("sim/model/show-yoke-R",1);
			setprop("sim/model/show-pilot",1);
			setprop("sim/model/show-copilot",1);
		}
},0,0);

setlistener("/gear/gear[0]/wow", func(n){
    if (n.getValue()){
        FHmeter.stop();
        setprop("controls/engines/grnd-idle",1);
        setprop("autopilot/locks/fms-gs",0);
        FH_write();
    } else {
        setprop("controls/engines/grnd-idle",0);
        FHmeter.start();
        fh_get = getprop(fh_tot);
				### raz clock to prevent restart on bounce ###
				setprop("/instrumentation/clock/flight-meter-sec",0);
    }
},0,0);

### Flight Meter ###
setlistener(fh_sec, func {
    fhour = getprop(fh_sec)/3600;
    setprop(fh_tot,fh_get + fhour);
},0,0);

### Flaps ###
setlistener("controls/flight/flaps-select", func(n) {
  if (n.getValue() == 0) setprop(flaps,0);
  if (n.getValue() == 1) setprop(flaps,0.142);
  if (n.getValue() == 2) setprop(flaps,0.428);
  if (n.getValue() == 3) setprop(flaps,1);
  if (n.getValue() > 0) setprop(slats,1);
},0,0);

### Chrono ###
setlistener("instrumentation/mfd/et", func(n){
  et = n.getValue();
  el_time(0,elec,et);
},0,0);

setlistener("instrumentation/mfd[1]/et", func(n){
  et = n.getValue();
  el_time(1,elec,et);
},0,0);

setlistener("systems/electrical/outputs/disp-cont1", func(n) {
  elec = n.getValue();
  el_time(0,elec,et);
},0,0);

setlistener("systems/electrical/outputs/disp-cont2", func(n) {
  elec = n.getValue();
  el_time(1,elec,et);
},0,0);

var el_time = func(x,elec,et) {
  if(elec) {
	  if(et){
	    if(elt[x] <= 2) elt[x] += 1;
	    else elt[x] = 0 ;
	    setprop("instrumentation/mfd["~x~"]/etx",elt[x]);
	    if(elt[x] == 1) Chrono[x].start();
	    if(elt[x] == 2) Chrono[x].stop();
	    if(elt[x] == 3) Chrono[x].reset();
	  }
  } else {
      Chrono[x].stop();
      Chrono[x].reset();
      elt[x] = 0;
	    setprop("instrumentation/mfd["~x~"]/etx",0);
  }
}

var FH_load = func{
    ### Create FH Path if not exists ###
		var path = os.path.new(getprop("/sim/fg-home")~"/Export/CitationX/create.txt");
    if (!path.exists()) path.create_dir();

    data = io.read_properties(fh_path);
    if (data == nil) {
      data = props.Node.new();
      data.initNode('TotalFlight',0,'DOUBLE');
      io.write_properties(fh_path,data);
    } else setprop(fh_tot,data.getValue("TotalFlight"));
}

var FH_write = func {
	  data = io.read_properties(fh_path);
	  data.getChild("TotalFlight").setDoubleValue(getprop(fh_tot));
	  io.write_properties(fh_path,data);
}

controls.synchro = func {
  var synchro = "controls/engines/synchro";
  if (getprop(synchro) == -1) ud = 1;
  if (getprop(synchro) == 1) ud = -1;
  setprop(synchro,getprop(synchro) + ud);
}

controls.stepSpoilers = func (step) {
    var val = 0.1 * step + getprop("/controls/flight/spoilers");
    setprop("/controls/flight/spoilers", val > 1 ? 1 : val < 0 ? 0 : val);
}

controls.pilots = func() {
	if (getprop("sim/model/show-yoke-L") == 0) {
		setprop("sim/model/show-pilot",0);
		setprop("sim/model/mem-yoke-L",0);
	} else {
		setprop("sim/model/show-pilot",1);
		setprop("sim/model/mem-yoke-L",1);
	}
	if (getprop("sim/model/show-yoke-R") == 0) {
		setprop("sim/model/show-copilot",0);
		setprop("sim/model/mem-yoke-R",0);
	} else {
		setprop("sim/model/show-copilot",1);
		setprop("sim/model/mem-yoke-R",1);
	}
}

controls.flapsDown = func(step) {
		flaps_pos = getprop("controls/flight/flaps-select");
		flaps_sel = "controls/flight/flaps-select";
    if (step == 2) setprop(flaps_sel,0);
    else {
      if (flaps_pos + step > 3 or flaps_pos+step < 0) return;
		  setprop(flaps_sel,flaps_pos+step);
    }
}

controls.gearDown = func(pos) {
    if (pos == -1 and !getprop("/gear/gear[0]/wow")
                  and !getprop("/gear/gear[1]/wow")
                  and !getprop("/gear/gear[2]/wow"))
      setprop("controls/gear/gear-down",0);
    else if (pos == 1) setprop("controls/gear/gear-down",1);
}

var Startup = func{
    setprop("controls/electric/engine[0]/generator",1);
    setprop("controls/electric/engine[1]/generator",1);
    setprop("controls/electric/batt1-switch",1);
    setprop("controls/electric/batt2-switch",1);
    setprop("controls/electric/stby-pwr",1);
    setprop("controls/electric/avionics-switch",2);
    setprop("controls/lighting/nav-lights",1);
    setprop("controls/lighting/beacons",1);
    setprop("controls/lighting/strobes",1);
    setprop("controls/lighting/recog-lights",1);
    setprop("controls/lighting/anti-coll",2);
    setprop("controls/lighting/emer-lights",2);
    setprop("controls/lighting/seat-belts",1);
		setprop("controls/flight/flaps-select",2);
		setprop("controls/anti-ice/lh-pitot",1);
		setprop("controls/anti-ice/rh-pitot",1);
		setprop("controls/anti-ice/lh-ws",1);
		setprop("controls/anti-ice/rh-ws",1);
		setprop("controls/oxygen/pass-oxy",1);
    setprop("controls/engines/engine[0]/cutoff",0);
    setprop("controls/engines/engine[1]/cutoff",0);
    setprop("controls/engines/engine[1]/ignition",0);
    setprop("controls/engines/engine[0]/ignition",0);
		setprop("engines/engine[1]/cycle-up",1);
    settimer(func() {
		  setprop("engines/engine[0]/cycle-up",1);
      setprop("controls/electric/external-power",0);
      setprop("services/ext-pwr",0);
    },12);
}

var Shutdown = func{
    setprop("controls/electric/engine[0]/generator",0);
    setprop("controls/electric/engine[1]/generator",0);
    setprop("controls/electric/avionics-switch",0);
    setprop("controls/electric/batt1-switch",0);
    setprop("controls/electric/batt2-switch",0);
    setprop("controls/electric/stby-pwr",0);
    setprop("controls/lighting/nav-lights",0);
    setprop("controls/lighting/beacons",0);
    setprop("controls/lighting/strobes",0);
    setprop("controls/lighting/recog-lights",0);
    setprop("controls/lighting/anti-coll",0);
    setprop("controls/lighting/emer-lights",0);
    setprop("controls/lighting/seat-belts",0);
    setprop("controls/engines/engine[0]/cutoff",1);
    setprop("controls/engines/engine[1]/cutoff",1);
    setprop("controls/engines/engine[0]/ignition",1);
    setprop("controls/engines/engine[1]/ignition",1);
		setprop("controls/engines/engine[0]/running",0);
		setprop("controls/engines/engine[1]/running",0);
		setprop("instrumentation/annunciators/ack-caution",1);
		setprop("instrumentation/annunciators/ack-warning",1);
		setprop("controls/flight/flaps-select",0);
		setprop("controls/anti-ice/lh-pitot",0);
		setprop("controls/anti-ice/rh-pitot",0);
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
  ### Stby-batt control ###
    if (getprop("systems/electrical/stby-batt-volts") < 21) {
      setprop("controls/electric/stby-batt-fail",1);
    } else setprop("controls/electric/stby-batt-fail",0);

  settimer(Vref_update,60);
}

### Tables animation ###

var tables_anim = func(i) {
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
#    tire = TireSpeed.new(3,0.430,0.615,0.615);
    Leng = JetEngine.new(0);
    Reng = JetEngine.new(1);
    Leng.listen();
    Reng.listen();
    settimer(update_systems,2);
    settimer(Vref_update,10);
		setprop("instrumentation/clock/flight-meter-sec",0);
#		setprop("sim/sound/startup",int(10*rand()));
    setprop("controls/engines/engine/ignition",1);
    setprop("controls/engines/engine[1]/ignition",1);
#    setprop("sim/model/shadow-2d",1);
#    setprop("sim/rendering/shaders/model",1);
    setprop("services/ext-pwr",1);
		FH_load();
    removelistener(citation_stl);
},0,0);

var update_systems = func{
    Leng.update();
    Reng.update();
#    FHupdate();
#    tire.get_rotation("yasim");
    grspd = getprop("velocities/groundspeed-kt");
    if (grspd > 40 and getprop("systems/electrical/outputs/cabin-door-monitor"))
     setprop("controls/cabin-door/open",0);
    ### Gear Steering ###
    wspd = (120-grspd) * 0.01;
    if(wspd>1.0) wspd = 1.0;
    if(wspd<0.001) wspd = 0.001;
    rudder_pos = getprop("controls/flight/rudder") or 0;
    if (getprop("systems/electrical/outputs/nose-whl-steering"))
      setprop("/controls/gear/steering",-rudder_pos*wspd);
    else setprop("/controls/gear/steering",0);

    settimer(update_systems,0);
}

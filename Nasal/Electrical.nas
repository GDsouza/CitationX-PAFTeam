####    jet engine electrical system    ####
####    Syd Adams - C.Le Moigne(clm76) 2019    ####

props.globals.initNode("/systems/electrical/left-bus",0,"DOUBLE");
props.globals.initNode("/systems/electrical/right-bus",0,"DOUBLE");
props.globals.initNode("/systems/electrical/xtie",0,"BOOL");
props.globals.initNode("controls/electric/avionics-switch",0,"INT");
props.globals.initNode("controls/electric/avionics-power",0,"BOOL");
props.globals.initNode("controls/lighting/anti-coll",0,"INT");
props.globals.initNode("controls/lighting/pfd-norm",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/pfd-norm[1]",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/mfd-norm",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/mfd-norm[1]",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/eicas-norm",0.8,"DOUBLE");

var AVswitch = "controls/electric/avionics-switch";
var Lbus = "systems/electrical/left-bus";
var Rbus= "systems/electrical/right-bus";
var XTie  = "systems/electrical/xtie";
var AvPwr = "controls/electric/avionics-power";
var l_emer = "systems/electrical/left-emer-bus";
var	l_norm = "systems/electrical/left-bus-norm";
var	r_emer = "systems/electrical/right-emer-bus";
var	r_norm = "systems/electrical/right-bus-norm";
var	apu_gen = "controls/electric/APU-generator";
var	ext_pwr = "controls/electric/external-power";
var	l_gen = "engines/engine[0]/amp-v";
var	r_gen = "engines/engine[1]/amp-v";
var lbus_volts = 0.0;
var rbus_volts = 0.0;
var count = 0;
var battery1_volts = nil;
var battery2_volts = nil;
var alternator1_volts = nil;
var alternator2_volts = nil;

var lbus_input=[];
var lbus_output=[];
var lbus_load=[];

var rbus_input=[];
var rbus_output=[];
var rbus_load=[];

var lights_input=[];
var lights_output=[];
var lights_load=[];

var scnd = nil;
var bat1_sw = nil;
var bat2_sw = nil;
var avionics = nil;
var PWR = nil;
var apu_volts = nil;
var xtie = nil;
var load = nil;;
var bus_volts = nil;
var srvc = nil;

var strobe_switch = "controls/lighting/strobe";
aircraft.light.new("controls/lighting/strobe-state", [0.05, 1.30], strobe_switch);
var beacon_switch = "controls/lighting/beacon";
aircraft.light.new("controls/lighting/beacon-state", [1.0, 1.0], beacon_switch);
setprop("/controls/electric/external-power",0);
setprop("/systems/electrical/left-emer-bus",0);
setprop("/systems/electrical/left-bus-norm",0);
setprop("/systems/electrical/right-emer-bus",0);
setprop("/systems/electrical/right-bus-norm",0);

var Battery = {
  new : func(switch,vlt,amp,hr,chp,cha){
  m = { parents : [Battery] };
  m.switch = switch;
  setprop(m.switch,0);
  m.ideal_volts = vlt;
  m.ideal_amps = amp;
  m.amp_hours = hr;
  m.charge_percent = chp;
  m.charge_amps = cha;
  m.amphrs_used = nil;
  m.percent_used = nil;
  m.output = nil;
  m.x = nil;
  m.tmp = nil;
  m.factor = nil;
  return m;
  },

  get_output_volts : func {
    if(getprop(me.switch)){
      me.x = 1.0 - me.charge_percent;
      me.tmp = -(3.0 * me.x - 1.0);
      me.factor = (me.tmp*me.tmp*me.tmp*me.tmp*me.tmp + 32) / 32;
      me.output = me.ideal_volts * me.factor;
      return me.output;
    } else return 0;
  },
}; # end of Battery

var Alternator = {
  new : func (num,switch,src,thr,vlt,amp){
    m = { parents : [Alternator] };
    m.switch =  switch;
    setprop(m.switch,0);
    m.meter =  "systems/electrical/gen-load["~num~"]";
    setprop(m.meter,0);
    m.gen_output =  "engines/engine["~num~"]/amp-v";
    setprop(m.gen_output,0);
    m.rpm_source =  src;
    m.rpm_threshold = thr;
    m.ideal_volts = vlt;
    m.ideal_amps = amp;
    m.cur_volt = nil;
    m.cur_amp = nil;
    m.factor = nil;
    m.gout = nil;
    m.out = nil;
    return m;
  },

  apply_load : func(load) {
    me.cur_volt = getprop(me.gen_output);
    if(me.cur_volt > 1){
      me.factor = 1/me.cur_volt;
      me.gout = (load * me.factor);
      if(me.gout > 1) me.gout = 1;
    } else  me.gout = 0;
    setprop(me.meter,me.gout);
  },

  get_output_volts : func {
    me.out = 0;
    if(getprop(me.switch)){
      me.factor = getprop(me.rpm_source) / me.rpm_threshold or 0;
      if (me.factor > 1.0 ) me.factor = 1.0;
      me.out = (me.ideal_volts * me.factor);
    }
    setprop(me.gen_output,me.out);
    return me.out;
  },
}; # end of Alternator

var battery1 = Battery.new("/controls/electric/battery-switch",24,30,34,1.0,7.0);
var battery2 = Battery.new("/controls/electric/battery-switch[1]",24,30,34,1.0,7.0);
var alternator1 = Alternator.new(0,"controls/electric/engine[0]/generator","/engines/engine[0]/fan",20.0,28.0,60.0);
var alternator2 = Alternator.new(1,"controls/electric/engine[1]/generator","/engines/engine[1]/fan",20.0,28.0,60.0);

#############
var init_switches = func{
  props.globals.initNode("controls/electric/ammeter-switch",0,"BOOL");
  props.globals.initNode("controls/electric/seat-belts-switch",0,"INT");
  props.globals.initNode("systems/electrical/serviceable",0,"BOOL");
  props.globals.initNode("controls/electric/external-power",0,"BOOL");
  props.globals.initNode("controls/electric/std-by-pwr",0,"INT");
  setprop("controls/lighting/instruments-norm",0.0);
  setprop("controls/lighting/engines-norm",0.8);
  setprop("controls/lighting/efis-norm",0.8);
  setprop("controls/lighting/cdu",0.8);
  setprop("controls/lighting/cdu[1]",0.8);
  setprop("controls/lighting/nav-lights",0);
  setprop("controls/lighting/rmu",0.3);
  setprop("controls/lighting/rmu[1]",0.3);

  append(lights_input,props.globals.initNode("controls/lighting/landing-light[0]",0,"BOOL"));
  append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light[0]",0,"DOUBLE"));
  append(lights_load,1);
  append(lights_input,props.globals.initNode("controls/lighting/landing-light[1]",0,"BOOL"));
  append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light[1]",0,"DOUBLE"));
  append(lights_load,1);
  append(lights_input,props.globals.initNode("controls/lighting/nav-lights",0,"BOOL"));
  append(lights_output,props.globals.initNode("systems/electrical/outputs/nav-lights",0,"DOUBLE"));
  append(lights_load,1);
  append(lights_input,props.globals.initNode("controls/lighting/cabin-lights",0,"BOOL"));
  append(lights_output,props.globals.initNode("systems/electrical/outputs/cabin-lights",0,"DOUBLE"));
  append(lights_load,1);
  append(lights_input,props.globals.initNode("controls/lighting/wing-lights",0,"BOOL"));
  append(lights_output,props.globals.initNode("systems/electrical/outputs/wing-lights",0,"DOUBLE"));
  append(lights_load,1);
  append(lights_input,props.globals.initNode("controls/lighting/recog-lights",0,"BOOL"));
  append(lights_output,props.globals.initNode("systems/electrical/outputs/recog-lights",0,"DOUBLE"));
  append(lights_load,1);
  append(lights_input,props.globals.initNode("controls/lighting/logo-lights",0,"BOOL"));
  append(lights_output,props.globals.initNode("systems/electrical/outputs/logo-lights",0,"DOUBLE"));
  append(lights_load,1);
  append(lights_input,props.globals.initNode("controls/lighting/taxi-lights",0,"BOOL"));
  append(lights_output,props.globals.initNode("systems/electrical/outputs/taxi-lights",0,"DOUBLE"));
  append(lights_load,1);
  append(lights_input,props.globals.initNode("controls/lighting/beacon-state/state",0,"BOOL"));
  append(lights_output,props.globals.initNode("systems/electrical/outputs/beacon",0,"DOUBLE"));
  append(lights_load,1);
  append(lights_input,props.globals.initNode("controls/lighting/strobe-state/state",0,"BOOL"));
  append(lights_output,props.globals.initNode("systems/electrical/outputs/strobe",0,"DOUBLE"));
  append(lights_load,1);

  append(rbus_input,props.globals.initNode("controls/electric/wiper-switch",0,"BOOL"));
  append(rbus_output,props.globals.initNode("systems/electrical/outputs/wiper",0,"DOUBLE"));
  append(rbus_load,1);
  append(rbus_input,props.globals.initNode("controls/engines/engine[0]/fuel-pump",0,"BOOL"));
  append(rbus_output,props.globals.initNode("systems/electrical/outputs/fuel-pump[0]",0,"DOUBLE"));
  append(rbus_load,1);
  append(rbus_input,props.globals.initNode("controls/engines/engine[1]/fuel-pump",0,"BOOL"));
  append(rbus_output,props.globals.initNode("systems/electrical/outputs/fuel-pump[1]",0,"DOUBLE"));
  append(rbus_load,1);
  append(rbus_input,props.globals.initNode("controls/engines/engine[0]/starter",0,"BOOL"));
  append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter",0,"DOUBLE"));
  append(rbus_load,1);
  append(rbus_input,props.globals.initNode("controls/engines/engine[1]/starter",0,"BOOL"));
  append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter[1]",0,"DOUBLE"));
  append(rbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/KNS80",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/efis",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/adf",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/dme",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/gps",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/DG",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/transponder",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/mk-viii",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/turn-coordinator",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/comm",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/comm[1]",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/nav",0,"DOUBLE"));
  append(lbus_load,1);
  append(lbus_input,AVswitch);
  append(lbus_output,props.globals.initNode("systems/electrical/outputs/nav[1]",0,"DOUBLE"));
  append(lbus_load,1);
}


update_virtual_bus = func(dt) {
  PWR = getprop("systems/electrical/serviceable");
	apu_volts = getprop("controls/APU/battery");
  xtie = 0;
  load = 0.0;
  if(!count) {
    battery1_volts = battery1.get_output_volts();
		if (apu_volts > battery1_volts) lbus_volts = apu_volts;
		else lbus_volts = battery1_volts;
    alternator1_volts = alternator1.get_output_volts();
    if (alternator1_volts > lbus_volts) {
      lbus_volts = alternator1_volts;
    }
    lbus_volts *= PWR;
    setprop(Lbus,lbus_volts);
    load += lh_bus(lbus_volts);
  } else {
    battery2_volts = battery2.get_output_volts();
		if (apu_volts > battery2_volts) rbus_volts = apu_volts;
		else rbus_volts = battery2_volts;
    var alternator2_volts = alternator2.get_output_volts();
    if (alternator2_volts > rbus_volts) {
      rbus_volts = alternator2_volts;
    }
    rbus_volts *= PWR;
    setprop(Rbus,rbus_volts);
    load += rh_bus(rbus_volts);
  }
    count = 1-count;
    if(rbus_volts > 5 and  lbus_volts>5) xtie=1;
    setprop(XTie,xtie);
    if(rbus_volts > 5 or  lbus_volts>5) load += lighting(24);
    alternator1.apply_load(load);
    alternator2.apply_load(load);

  return load;
}

lighting = func(bv) {
  load = 0.0;
  for(var i=0; i<size(lights_input); i+=1) {
    srvc = lights_input[i].getValue();
    load += lights_load[i] * srvc;
    lights_output[i].setValue(bv * srvc);
  }
	return load;
}

lh_bus = func(bv) {
  load = 0.0;
  for(var i=0; i<size(lbus_input); i+=1) {
    srvc = getprop(lbus_input[i]);
		if (srvc == 2) srvc = 1; ## switch avionics ##
    load += lbus_load[i] * srvc;
    lbus_output[i].setValue(bv * srvc);
  }
  setprop("systems/electrical/outputs/flaps",bv);
  return load;
}

rh_bus = func(bv) {
  load = 0.0;
  for(var i=0; i<size(rbus_input); i+=1) {
    srvc = rbus_input[i].getValue();
		if (srvc == 2) srvc = 1; ## switch avionics ##
    load += rbus_load[i] * srvc;
    rbus_output[i].setValue(bv * srvc);
  }
  return load;
}

########## Switches ###########

setlistener("controls/electric/battery-switch[0]",func(n) {
  if (n.getValue()) {
		if (getprop(ext_pwr) or getprop(apu_gen) or getprop(l_gen) >24 or getprop(r_gen) >24) {
			setprop(l_norm,1);
			setprop(l_emer,0);
		} else {
 			setprop(l_norm,0);
			setprop(l_emer,1);
		}
    if (getprop(AVswitch)== 2) setprop(AvPwr,1);
	} else {
			setprop(l_norm,0);
			setprop(l_emer,0);
      setprop(AvPwr,0);
	}			
},0,0);

setlistener("controls/electric/battery-switch[1]",func(n) {
  if (n.getValue()) {
		if (getprop(ext_pwr) or getprop(apu_gen) or getprop(l_gen) > 24 or getprop(r_gen) > 24) {
			setprop(r_norm,1);
			setprop(r_emer,0);
		} else {
 			setprop(r_norm,0);
			setprop(r_emer,1);
		}
	} else {
			setprop(r_norm,0);
			setprop(r_emer,0);
	}			
},0,0);

setlistener("controls/electric/avionics-switch",func(n) {
  if (n.getValue() == 2 and getprop(l_norm)) {
		if(!getprop(AvPwr)) {
      setprop(AvPwr,1);
      setprop("instrumentation/cdu/init",0);
      setprop("instrumentation/dme/frequencies/selected-mhz",getprop("instrumentation/nav/frequencies/selected-mhz")); # for dme display
      setprop("instrumentation/dme[1]/frequencies/selected-mhz",getprop("instrumentation/nav[1]/frequencies/selected-mhz")); # for dme display
    }
	} else {
		if(getprop(AvPwr)) {
      setprop(AvPwr,0);
      setprop("instrumentation/cdu/init",1);
    }
	}
},1,1);

setlistener("controls/lighting/anti-coll",func(n) {
	if (n.getValue()==1) {
		setprop("controls/lighting/beacon",1);
		setprop("controls/lighting/strobe",0);
	} else if (n.getValue()==2) {
		setprop("controls/lighting/beacon",0);
		setprop("controls/lighting/strobe",1);
	} else {
		setprop("controls/lighting/beacon",0);
		setprop("controls/lighting/strobe",0);
	}
},0,0);

 ######## Main ##########
var elec_stl = setlistener("/sim/signals/fdm-initialized", func {
    init_switches();
    settimer(update_electrical,5);
    print("Electrical System ... Ok");
    removelistener(elec_stl);
},0,0);

update_electrical = func {
    scnd = getprop("sim/time/delta-sec");
    update_virtual_bus(scnd);
settimer(update_electrical, 0.1);
}

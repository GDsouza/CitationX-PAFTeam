
###  Citation X Split Bus Electrical System    ####
###   C. Le Moigne (clm76) 2020      ###

### External-power : volts  : 28 V - 400 A
### Eng & APU Generators    : 28 V - 400 A
### Batt 1 & 2              : 24 V - 44 A/H
### Standby Batt            : 28 V - 2.5 A/H

props.globals.initNode("systems/electrical/batt1-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/batt2-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/left-main-bus-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/left-main-bus-amps",0,"DOUBLE");
props.globals.initNode("systems/electrical/right-main-bus-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/right-main-bus-amps",0,"DOUBLE");
props.globals.initNode("systems/electrical/left-emer-bus-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/left-emer-bus-amps",0,"DOUBLE");
props.globals.initNode("systems/electrical/right-emer-bus-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/right-emer-bus-amps",0,"DOUBLE");
props.globals.initNode("systems/electrical/batt1-charge-norm",1,"DOUBLE");
props.globals.initNode("systems/electrical/batt2-charge-norm",1,"DOUBLE");
props.globals.initNode("systems/electrical/stby-batt-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/batt-stby-charge-norm",1,"DOUBLE");
props.globals.initNode("systems/electrical/stby-bus-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/stby-bus-amps",0,"DOUBLE");
props.globals.initNode("systems/electrical/left-gen-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/right-gen-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/apu-gen-volts",0,"DOUBLE");
props.globals.initNode("systems/electrical/apu-gen-amps",0,"DOUBLE");

var adf = ["systems/electrical/outputs/adf1",
           "systems/electrical/outputs/adf2"];
var apu_gen = "controls/APU/generator";
var apu_rpm = "controls/APU/rpm";
var avionics  = "controls/electric/avionics-switch";
var batt_bus = ["systems/electrical/batt1-volts",
                "systems/electrical/batt2-volts"];
var batt_sw = ["controls/electric/batt1-switch",
               "controls/electric/batt2-switch"];
var charge_norm = ["systems/electrical/batt1-charge-norm",
              "systems/electrical/batt2-charge-norm",
              "systems/electrical/batt-stby-charge-norm"];
var emer_volts = ["systems/electrical/left-emer-bus-volts",
                "systems/electrical/right-emer-bus-volts"];
var emer_sw = ["controls/electric/lh-emer",
               "controls/electric/rh-emer"];
var eng_gen = ["engines/engine/generator",
               "engines/engine[1]/generator"];
var eng_gen_sw = ["controls/electric/engine[0]/generator",
                  "controls/electric/engine[1]/generator"];
var eng_run = ["controls/engines/engine/running",
               "controls/engines/engine[1]/running"];
var ext_pwr = "controls/electric/external-power";
var gen_volts = ["systems/electrical/left-gen-volts",
                 "systems/electrical/right-gen-volts"];
var gps = ["systems/electrical/outputs/gps1",
           "systems/electrical/outputs/gps2"];
var main_volts = ["systems/electrical/left-main-bus-volts",
                "systems/electrical/right-main-bus-volts"];
var nav = ["systems/electrical/outputs/nav1",
           "systems/electrical/outputs/nav2"];
var right_main_bus = "systems/electrical/right-main-bus";
var stby_batt = "systems/electrical/stby-batt-volts";
var stby_bus = "systems/electrical/stby-bus-volts";
var stby_switch = "controls/electric/stby-pwr";
var xpdr = ["systems/electrical/outputs/xpdr1",
           "systems/electrical/outputs/xpdr2"];
var xtie_open = "controls/electric/xtie-open";

var cb_path = "systems/electrical/cb/";
var outputs_path = "systems/electrical/outputs/";
var sys_elec = "systems/electrical/";

var batt = nil;
var batt_ah = nil;
var charge = nil;
var charging_intensity = nil;
var dt = nil;
var input_intensity = nil;
var potential = nil;
var switch = nil;
var x =  nil;

var strobe_switch = "controls/lighting/strobes";
aircraft.light.new("controls/lighting/strobe-state", [0.05, 1.30], strobe_switch);
var beacon_switch = "controls/lighting/beacons";
aircraft.light.new("controls/lighting/beacon-state", [1.0, 1.0], beacon_switch);
var recog_pulse = "controls/lighting/recog-pulse";
aircraft.light.new("controls/lighting/recog-state", [0.5, 0.5], recog_pulse);

var Electrical = {
  apu_volts   : 28.5,
  batt_volts  : 24,
  batt_amp_h  : 44,
  charge_cst  : 0.2,
  feed_volts  : 28.5, # apu or external power
  gen_volts   : 28.5,
  low_batt    : 19.2, # batt_volts*0.8
  low_charge  : 0.1,
  low_volts   : 11,   # buses volts
  stby_volts  : 28,
  stby_amp_h  : 2.5,

  new : func(x){
    m = { parents : [Electrical] };
    m.apu_gen = 0;
    m.emer_amps = [0,0];
    m.emer_volts = [0,0];
    m.main_amps =[0,0];
    m.main_volts = [0,0];
    m.main_pwr = [0,0];
    m.stby_bus = 0;
    m.stby_amps = 0;
    m.feed = nil;
    setprop("systems/electrical/batt"~x~"-volts",me.batt_volts);
    setprop("systems/electrical/stby-batt-volts",me.stby_volts);
    setprop("controls/lighting/taxi-light",0);
    setprop("controls/lighting/nav-lights",0);

    return m;
  },

  listen : func {
        ### For Fg internal instruments working ###
    setlistener(adf[0], func(n) {
      setprop("systems/electrical/outputs/adf",n.getValue()*me.main_volts[0]);
    },0,0);

    setlistener(adf[1], func(n) {
      setprop("systems/electrical/outputs/adf[1]",n.getValue()*me.main_volts[1]);
    },0,0);

    setlistener(nav[0], func(n) {
      setprop("systems/electrical/outputs/nav",n.getValue()*me.main_volts[0]);
    },0,0);

    setlistener(nav[1], func(n) {
      setprop("systems/electrical/outputs/nav[1]",n.getValue()*me.main_volts[1]);
    },0,0);

#    setlistener(gps[0], func(n) {
#      setprop("systems/electrical/outputs/gps",n.getValue()*me.main_volts[0]);
#    },0,0);

#    setlistener(gps[1], func(n) {
#      setprop("systems/electrical/outputs/gps",n.getValue()*me.main_volts[1]);
#    },0,0);

    setlistener(main_volts[1], func(n) {
      setprop("systems/electrical/outputs/dme",n.getValue());
      setprop("systems/electrical/outputs/mk-viii",n.getValue());
      setprop("systems/electrical/outputs/transponder",n.getValue());
      setprop("systems/electrical/outputs/turn-coordinator",n.getValue());
    },0,0);

  }, # end of listen

  load_components : func {
    var file = getprop("/sim/aircraft-dir")~"/Nasal/System_init/elec_components.nas";
    io.load_nasal(file,"Elec");
    Elec.components();
  }, # end of load_components

  update_elec : func {
    dt = getprop("sim/time/delta-sec");

        ### APU Generator ###
    if (getprop(apu_gen) and getprop(apu_rpm) > 0.99) {
      me.apu_gen = 1;
      setprop("systems/electrical/apu-gen-volts",me.apu_volts);
      setprop("systems/electrical/apu-gen-amps",me.emer_amps[1] + me.main_amps[1] + me.stby_amps);
    } else {
      me.apu_gen = 0;
      setprop("systems/electrical/apu-gen-volts",0);
      setprop("systems/electrical/apu-gen-amps",0);
    }

        ### Engines Generators ###
    for (n=0;n<2;n+=1) {
      if (getprop(eng_gen_sw[n]) and getprop(eng_run[n])) {
        setprop(gen_volts[n],me.gen_volts);
        setprop(eng_gen[n],1);
      } else {setprop(gen_volts[n],0);setprop(eng_gen[n],0)}
    }
    if (getprop(ext_pwr) or me.apu_gen or getprop(eng_gen[1]))
      me.main_pwr[1] = 1;
    else me.main_pwr[1] = 0;

    me.main_pwr[0] = getprop(eng_gen[0]);
    me.buses_power();

        ### Xtie ###
    if (!getprop(xtie_open)) {
      if (me.main_volts[1] > me.main_volts[0]) {
        me.main_volts[0] = me.main_volts[1];
        if (!getprop(emer_sw[0])) me.emer_volts[0] = me.main_volts[0];
        else me.emer_volts[0] = 0;
      } else if (me.main_volts[0] > me.main_volts[1]){
        me.main_volts[1] = me.main_volts[0];
        if (!getprop(emer_sw[1])) me.emer_volts[1] = me.main_volts[1];
        else me.emer_volts[1] = 0;
      } else me.buses_power();
    }

        ### Buses management ###
    me.main_amps[0] = 0; # left main bus + eicas
    me.outputs_main(0,0,Elec.left_gen,"lh-gen");
    me.outputs_main(1,0,Elec.left_avi,"lh-avi");
    me.outputs_main(2,0,Elec.eicas,"eicas");

    me.main_amps[1] = 0; # right main bus
    me.outputs_main(0,1,Elec.right_gen,"rh-gen");
    me.outputs_main(1,1,Elec.right_avi,"rh-avi");

    me.outputs_emer(0,Elec.left_emer); # left emer bus
    me.outputs_emer(1,Elec.right_emer); # right emer bus

    me.outputs_stby(); # stby bus

        ### Charging - discharging ###
              ### main batt ###
    for (x=0;x<2;x+=1) {
     # potential
      me.charging_pot(x,me.batt_volts);
      setprop(batt_bus[x],potential);

      # intensity
      if (!getprop(emer_sw[x]) and getprop(batt_sw[x])) {
        if (me.main_volts[x] > potential) {
          me.charging_int(x,me.batt_amp_h);
        } else { # discharging
          input_intensity = me.main_amps[x] + me.emer_amps[x];
          me.discharging(x,input_intensity,me.batt_amp_h);
        }
      } else if (getprop(emer_sw[x]) and getprop(batt_sw[x])) {
          input_intensity = me.emer_amps[x];
          me.discharging(x,input_intensity,me.batt_amp_h);
      } else {
        input_intensity = 0;
        me.discharging(x,input_intensity,me.batt_amp_h);
      }
    };
              ### stby batt ###
    if (getprop(stby_switch)) {
      me.charging_pot(2,me.stby_volts);
      me.stby_bus = potential;
      if (me.main_volts[1] > potential) {
        me.charging_int(2,me.stby_amp_h);
      } else { # discharging
        input_intensity = me.stby_amps;
        me.discharging(2,input_intensity,me.stby_amp_h);
      }
    } else me.stby_bus = me.main_volts[1];

        ### Lighting ###
    me.main_amps[0] += getprop("controls/lighting/taxi-light")*5;
    me.main_amps[0] += getprop("controls/lighting/beacon-state/state")*2.5;
    me.main_amps[0] += getprop("controls/lighting/strobe-state/state")*2.5;

                ### Remote CB (in the J-Box) ###
    me.main_amps[0] += getprop("controls/lighting/landing-light")*5;
    me.main_amps[1] += getprop("controls/lighting/landing-light[1]")*5;

        ### Update Properties ###
                ### Amps ###
    setprop(sys_elec~"left-emer-bus-amps",me.emer_amps[0]);
    setprop(sys_elec~"left-main-bus-amps",me.main_amps[0]);
    setprop(sys_elec~"right-emer-bus-amps",me.emer_amps[1]);
    setprop(sys_elec~"right-main-bus-amps",me.main_amps[1]+me.stby_amps);
    setprop(sys_elec~"stby-bus-amps",me.stby_amps);
                ### Volts ###
    setprop(stby_bus,me.stby_bus);
    if (getprop(stby_switch)) setprop(stby_batt,me.stby_bus);
    for (x=0;x<2;x+=1) {
      setprop(main_volts[x],me.main_volts[x]);
      setprop(emer_volts[x],me.emer_volts[x]);
    }

        ### Timer ###
    settimer(func me.update_elec(),0);
  }, # end of update_elec

  buses_power : func {
    for (x=0;x<2;x+=1) {
      if (me.main_pwr[x]) {
        me.main_volts[x] = me.feed_volts;
        if (!getprop(emer_sw[x])) me.emer_volts[x] = getprop(main_volts[x]);
        else {
          if (getprop(batt_sw[x])) me.emer_volts[x] = getprop(batt_bus[x]);
          else me.emer_volts[x] = 0;
        }
      } else {
        if (getprop(batt_sw[x])) {
          me.emer_volts[x] = getprop(batt_bus[x]);
          if (!getprop(emer_sw[x])) me.main_volts[x] = me.emer_volts[x];
          else me.main_volts[x] = 0;
        } else me.main_volts[x] = me.emer_volts[x] = 0;
      }
    }
  }, # end of buses_power

  charging_pot : func(x,batt) {
    charge = getprop(charge_norm[x]);
    potential = charge < me.low_charge ?
      (me.low_batt * charge / me.low_charge) :
      (me.low_batt + (charge - me.low_charge)
        / (1 - me.low_charge)
        * (batt - me.low_batt));
  }, # end of charging_potential

  charging_int : func(x,batt_ah) {
    if (charge < 0.9999) {
      charging_intensity = batt_ah*me.charge_cst;
      charge += charging_intensity * dt / (batt_ah*3600);
      setprop(charge_norm[x],charge);
    }

  }, # end of charging_int

  discharging : func (x,input_intensity,batt_ah) {
    charge -= input_intensity * dt / (batt_ah*3600);
    setprop(charge_norm[x],charge);
  }, # end of discharging

  outputs_main : func(x,ind,bus_name,fuse) {
    for(var i=0;i<size(bus_name);i+=1) {
      if (x < 2 ) fuse_tripped = cb_path~fuse~bus_name[i].feed~"-fuse-tripped";
      if (getprop(cb_path~bus_name[i].name~"-fuse-tripped")
        or me.main_volts[ind] < me.low_volts
        or x == 0 and getprop(fuse_tripped)
        or x == 1 and (getprop(fuse_tripped) or getprop(avionics) < 2)
        or x == 2 and getprop(avionics) < 1)
        switch = 0;
      else {
        switch = me.nonnil(bus_name[i].sw,1);
        if (switch == 2) switch = 1;
      }
      me.main_amps[ind] += bus_name[i].amps*switch;
      setprop(outputs_path~bus_name[i].name,1*switch);
    }
  }, # end of outputs main

  outputs_emer : func(x,bus_name) {
    me.emer_amps[x] = 0;
    for(var i=0;i<size(bus_name);i+=1) {
      if (getprop(cb_path~bus_name[i].name~"-fuse-tripped")
        or me.emer_volts[x] <= me.low_volts) switch = 0;
      else {
        switch = me.nonnil(bus_name[i].sw,1);
        if (switch == 2) switch = 1;
      }
      me.emer_amps[x] += bus_name[i].amps*switch;
      setprop(outputs_path~bus_name[i].name,1*switch);
    }
  }, # end of outputs emer

  outputs_stby : func {
    me.stby_amps = 0;
    for(var i=0;i<size(Elec.stby);i+=1) {
      if (getprop(cb_path~Elec.stby[i].name~"-fuse-tripped")
          or (me.stby_bus <= me.low_volts and !getprop(right_main_bus))) switch = 0;
      else {
        switch = me.nonnil(Elec.stby[i].sw,1);
        if (switch == 2) switch = 1;
      }
      me.stby_amps += Elec.stby[i].amps*switch;
      setprop(outputs_path~Elec.stby[i].name,1*switch);
    }
  }, # end of outputs_stby

  nonnil : func (sw,arg) {
    if (sw != nil) return getprop(sw);
    else return arg;
  }, # end of nonnil

}; # end of Electrical

var elec_stl = setlistener("/sim/signals/fdm-initialized", func {
  for (var x=1;x<3;x+=1) var elec = Electrical.new(x);
  elec.listen();
  elec.load_components();
  elec.update_elec();
  print("Elec System      ... Ok");
	removelistener(elec_stl);
});

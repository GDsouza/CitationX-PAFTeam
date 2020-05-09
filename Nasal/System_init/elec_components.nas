### Electrical Components Initialization   ###
### C. Le Moigne (clm76) - 2020 ###

var eicas = nil;
var left_emer = nil;
var right_emer = nil;
var left_gen = nil;
var left_avi = nil;
var right_gen = nil;
var right_avi = nil;
var stby = nil;
var feed = nil;
var bus = [];

var anti_skid = "controls/gear/antiskid";
var cabin_temp = "controls/air-conditioning/cabin/auto";
var caution = "instrumentation/annunciators/caution";
var ckpt_temp = "controls/air-conditioning/cockpit/auto";
var ctr_light = "controls/lighting/ctr";
var el_panel = "controls/lighting/el-norm";
var emer_lights = "controls/lighting/emer-lights";
var flood = "controls/lighting/flood-norm";
var lh_bld_air = "controls/air-conditioning/bleed-air/left-engine";
var lh_boost_pump = "controls/fuel/tank/boost-pump";
var lh_engine = "controls/anti-ice/lh-engine";
var lh_light = "controls/lighting/lh";
var lh_rat_heater = "controls/anti-ice/lh-pitot";
var lh_stab = "controls/anti-ice/lh-stab";
var lh_ws = "controls/anti-ice/lh-ws";
var nav_light = "controls/lighting/nav-lights";
var rh_bld_air = "controls/air-conditioning/bleed-air/right-engine";
var rh_boost_pump = "controls/fuel/tank[1]/boost-pump";
var rh_engine = "controls/anti-ice/rh-engine";
var rh_light = "controls/lighting/rh-norm";
var rh_rat_heater = "controls/anti-ice/rh-pitot";
var rh_stab = "controls/anti-ice/rh-stab";
var rh_ws = "controls/anti-ice/rh-ws";
var oxy = "controls/oxygen/pass-oxy";
var spdbrake = "controls/flight/speedbrake";
var warning = "instrumentation/annunciators/warning";
var wing_insp = "controls/anti-ice/wing-insp";
var ws_air = "controls/anti-ice/ws-air";

var components = func {

  left_gen = [ # left cb
    {name: 'anti-coll',           amps: 0,    sw : nil,           feed : 1}, 
    {name: 'wing-insp',           amps: 3,    sw : wing_insp,     feed : 1},
    {name: 'lh-panel',            amps: 3,    sw : lh_light,      feed : 1},
    {name: 'el-panel',            amps: 0.5,  sw : el_panel,      feed : 1},
    {name: 'cockpit-flood',       amps: 3,    sw : flood,         feed : 1},
    {name: 'lh-rat-heater',       amps: 10,   sw : lh_rat_heater, feed : 2},
    {name: 'lh-aoa-heater',       amps: 5,    sw : lh_rat_heater, feed : 2},
    {name: 'lh-eng-wing',         amps: 3,    sw : lh_engine,     feed : 2},
    {name: 'lh-slat-stab',        amps: 3,    sw : lh_stab,       feed : 2},
    {name: 'lh-ps-heater',        amps: 5,    sw : lh_rat_heater, feed : 2},
    {name: 'pri-stab-trim-pwr',   amps: 0.3,  sw : nil,           feed : 2},
    {name: 'lh-fuel-cont',        amps: 1.5,  sw : nil,           feed : 1},
    {name: 'lh-fuel-transfer',    amps: 1.5,  sw : nil,           feed : 1},
    {name: 'lh-fuel-quantity',    amps: 3,    sw : nil,           feed : 1},
    {name: 'ctr-fuel-quantity',   amps: 3,    sw : nil,           feed : 1},
    {name: 'bag-smoke-detect',    amps: 3,    sw : nil,           feed : 1},
    {name: 'cockpit-temp',        amps: 3,    sw : ckpt_temp,     feed : 2},
    {name: 'press',               amps: 3,    sw : nil,           feed : 2},
    {name: 'lh-eng-bld-air',      amps: 3,    sw : lh_bld_air,    feed : 2},
    {name: 'oxygen',              amps: 3,    sw : oxy,           feed : 3},
    {name: 'lh-wow',              amps: 3,    sw : nil,           feed : 3},
    {name: 'anti-skid',           amps: 3,    sw : nil,           feed : 3},
    {name: 'hydr-A-cont',         amps: 3,    sw : nil,           feed : 3},
    {name: 'flap-control',        amps: 3,    sw : nil,           feed : 3},
    {name: 'aileron-pcu-mon',     amps: 3,    sw : nil,           feed : 3},
    {name: 'lh-tla-discretes',    amps: 3,    sw : nil,           feed : 3},
    {name: 'lh-stall-warn',       amps: 3,    sw : nil,           feed : 3},
    {name: 'lh-tr-deploy',        amps: 3,    sw : nil,           feed : 3},
    {name: 'lh-tr-stow',          amps: 3,    sw : nil,           feed : 3},
    {name: 'slat-A-control',      amps: 3,    sw : nil,           feed : 3},
    {name: 'cabin-door-monitor',  amps: 3,    sw : nil,           feed : 3},
    ];

  left_avi = [ # right cb
    {name: 'public-addr',     amps: 3,  sw : nil, feed : 1},  
    {name: 'adf1',            amps: 3,  sw : nil, feed : 1},  
    {name: 'dme1',            amps: 3,  sw : nil, feed : 1},  
    {name: 'radio-alt1',      amps: 3,  sw : nil, feed : 1},  
    {name: 'data-loader',     amps: 3,  sw : nil, feed : 1},  
    {name: 'gps1',            amps: 3,  sw : nil, feed : 1},  
    {name: 'fms1',            amps: 3,  sw : nil, feed : 1},  
    {name: 'att-hdg1',        amps: 3,  sw : nil, feed : 2},  
    {name: 'fgc-yd-A',        amps: 3,  sw : nil, feed : 2},  
    {name: 'fgc-cont-A',      amps: 3,  sw : nil, feed : 2},  
    {name: 'dau1B',           amps: 3,  sw : nil, feed : 2},  
    {name: 'fdr',             amps: 3,  sw : nil, feed : 2},  
    {name: 'gpws',            amps: 3,  sw : nil, feed : 2},  
    {name: 'tcas',            amps: 3,  sw : nil, feed : 2},  
    {name: 'lighting-detect', amps: 3,  sw : nil, feed : 2},  
    {name: 'rad-tel',         amps: 3,  sw : nil, feed : 3},  
    {name: 'ap-A',            amps: 5,  sw : nil, feed : 3},  
    {name: 'pfd1',            amps: 7,  sw : nil, feed : 3},  
    {name: 'radar',           amps: 5,  sw : nil, feed : 3},  
    {name: 'radar-cont',      amps: 3,  sw : nil, feed : 2},  
  ];

  left_emer = [
    {name: 'lh-emer',             amps: 5,    sw: nil}, # left cb
    {name: 'aux-panel',           amps: 3,    sw: nil},
    {name: 'lh-ws',               amps: 3,    sw: lh_ws},
    {name: 'aileron-trim',        amps: 1.5,  sw: nil}, 
    {name: 'pitch-feel',          amps: 1.5,  sw: nil},
    {name: 'lh-boost-pump',       amps: 0.3,  sw: lh_boost_pump},
    {name: 'lh-start',            amps: 1.5,  sw: nil},
    {name: 'lh-fuel-fw-vlv',      amps: 3,    sw: nil},
    {name: 'lh-hydr-fw-shutoff',  amps: 3,    sw: nil},
    {name: 'lh-fire-detect',      amps: 1,    sw: nil},
    {name: 'lh-fadec-A',          amps: 5,    sw: nil},
    {name: 'rh-fadec-A',          amps: 5,    sw: nil},
    {name: 'rudder-limit-A',      amps: 3,    sw: nil},
    {name: 'emer1-batt-ind',      amps: 3,    sw: nil},
    {name: 'warning-cont-1',      amps: 3,    sw: nil},
    {name: 'audio1',              amps: 3,    sw: nil},# right cb
    {name: 'warn-audio1',         amps: 3,    sw: nil},
    {name: 'comm1',               amps: 7.5,  sw: nil},
    {name: 'nav1',                amps: 3,    sw: nil},
    {name: 'rmu1',                amps: 3,    sw: nil},
    {name: 'stby-nav-com',        amps: 3,    sw: nil},
    {name: 'xpdr1',               amps: 3,    sw: nil},
    {name: 'stby-hsi',            amps: 0.7,  sw: nil},
    {name: 'att-hdg-aux1',        amps: 3,    sw: nil},
    {name: 'madc1',               amps: 3,    sw: nil},
    {name: 'upper-rudder-A',      amps: 3,    sw: nil},
    ];

  right_gen = [ # left cb
    {name: 'nav-lights',          amps: 5,    sw  : nav_light,     feed : 1},
    {name: 'rh-panel',            amps: 3,    sw  : rh_light,      feed : 1},
    {name: 'ctr-panel',           amps: 3,    sw  : ctr_light,     feed : 1},
    {name: 'map',                 amps: 3,    sw  : nil,           feed : 1},
    {name: 'rh-ws',               amps: 3,    sw  : rh_ws,         feed : 2},
    {name: 'rh-rat-heater',       amps: 10,   sw  : rh_rat_heater, feed : 2},
    {name: 'rh-aoa-heater',       amps: 5,    sw  : rh_rat_heater, feed : 2},
    {name: 'rh-eng-wing',         amps: 3,    sw  : rh_engine,     feed : 2},
    {name: 'rh-slat-stab',        amps: 3,    sw  : rh_stab,       feed : 2},
    {name: 'rh-ps-heater',        amps: 5,    sw  : rh_rat_heater, feed : 2},
    {name: 'pri-stab-trim-cont',  amps: 0.3,  sw  : nil,           feed : 1},
    {name: 'rh-boost-pump',       amps: 0.3,  sw  : rh_boost_pump, feed : 2},
    {name: 'rh-fuel-cont',        amps: 1.5,  sw  : nil,           feed : 2},
    {name: 'rh-fuel-transfer',    amps: 1.5,  sw  : nil,           feed : 2},
    {name: 'rh-fuel-quantity',    amps: 3,    sw  : nil,           feed : 2},
    {name: 'ws-air',              amps: 10,   sw  : ws_air,        feed : 1},
    {name: 'cabin-temp',          amps: 3,    sw  : cabin_temp,    feed : 1},
    {name: 'manual-cab-temp',     amps: 3,    sw  : nil,           feed : 1},
    {name: 'rh-eng-bld-air',      amps: 3,    sw  : rh_bld_air,    feed : 1},
    {name: 'rudder-stby',         amps: 0.2,  sw  : nil,           feed : 3},
    {name: 'flt-hr-meter',        amps: 1.5,  sw  : nil,           feed : 3},
    {name: 'rh-wow',              amps: 3,    sw  : nil,           feed : 3},
    {name: 'nose-whl-steering',   amps: 3,    sw  : nil,           feed : 3},
    {name: 'hydr-B-ptu-cont',     amps: 3,    sw  : nil,           feed : 3},
    {name: 'spd-brake-monitor',   amps: 1,    sw  : spdbrake,      feed : 3},
    {name: 'warning-cont-2',      amps: 3,    sw  : nil,           feed : 3},
    {name: 'pcu-monitor',         amps: 3,    sw  : nil,           feed : 3},
    {name: 'rh-tla-discretes',    amps: 3,    sw  : nil,           feed : 3},
    {name: 'rh-stall-warn',       amps: 3,    sw  : nil,           feed : 3},
    {name: 'rh-tr-deploy',        amps: 3,    sw  : nil,           feed : 3},
    {name: 'rh-tr-stow',          amps: 3,    sw  : nil,           feed : 3},
    {name: 'slat-B-control',      amps: 3,    sw  : nil,           feed : 3},
    ];

  right_avi = [ # right cb
    {name: 'nav2',        amps: 3,    sw : nil, feed : 1},
    {name: 'rmu2',        amps: 3,    sw : nil, feed : 1},
    {name: 'xpdr2',       amps: 3,    sw : nil, feed : 1},
    {name: 'adf2',        amps: 3,    sw : nil, feed : 1},
    {name: 'dme2',        amps: 3,    sw : nil, feed : 1},
    {name: 'hf2',         amps: 3,    sw : nil, feed : 1},
    {name: 'hf2-reset',   amps: 0.2,  sw : nil, feed : 1},
    {name: 'selcal',      amps: 3,    sw : nil, feed : 1},
    {name: 'gps2',        amps: 3,    sw : nil, feed : 1},
    {name: 'fms2',        amps: 3,    sw : nil, feed : 1},
    {name: 'comm2',       amps: 7,    sw : nil, feed : 2},
    {name: 'att-hdg2',    amps: 3,    sw : nil, feed : 2},
    {name: 'ap-B',        amps: 5,    sw : nil, feed : 2},
    {name: 'pfd2',        amps: 7,    sw : nil, feed : 2},
    {name: 'mfd2',        amps: 7,    sw : nil, feed : 2},
    {name: 'fgc-yd-B',    amps: 3,    sw : nil, feed : 3},
    {name: 'fgc-cont-B',  amps: 3,    sw : nil, feed : 3},
    {name: 'iac2',        amps: 5,    sw : nil, feed : 3},
    {name: 'disp-cont2',  amps: 3,    sw : nil, feed : 3},
    {name: 'dau2B',       amps: 3,    sw : nil, feed : 3},
    {name: 'cvr',         amps: 3,    sw : nil, feed : 3},
    {name: 'avn-cooling', amps: 3,    sw : nil, feed : 3},
    {name: 'afis',        amps: 5,    sw : nil, feed : 3},
    {name: 'afis-satcom', amps: 5,    sw : nil, feed : 3},

  ];

  right_emer = [
    {name: 'rh-emer',             amps: 5,    sw: nil}, # left cb
    {name: 'rh-start',            amps: 1.5,  sw: nil},
    {name: 'lh-fadec-B',          amps: 5,    sw: nil},
    {name: 'rh-fadec-B',          amps: 5,    sw: nil},
    {name: 'rh-fuel-fw-vlv',      amps: 3,    sw: nil},
    {name: 'rh-hydr-fw-shutoff',  amps: 3,    sw: nil},
    {name: 'rh-fire-detect',      amps: 1,    sw: nil},
    {name: 'stby-ps-heat',        amps: 5,    sw: nil},
    {name: 'sec-stab-trim-cont',  amps: 0.5,  sw: nil},
    {name: 'rudder-trim',         amps: 1.5,  sw: nil},
    {name: 'lh-gear',             amps: 3,    sw: nil},
    {name: 'rh-gear',             amps: 3,    sw: nil},
    {name: 'rudder-limit-B',      amps: 3,    sw: nil},
    {name: 'A-aux-hydr-pump',     amps: 0.2,  sw: nil},
    {name: 'emer2-batt-ind',      amps: 3,    sw: nil},
    {name: 'audio2',              amps: 3,    sw: nil}, # right cb
    {name: 'warn-audio2',         amps: 3,    sw: nil},
    {name: 'hf1',                 amps: 3,    sw: nil},
    {name: 'hf1-reset',           amps: 0.2,  sw: nil},
    {name: 'att-hdg-aux2',        amps: 3,    sw: nil},
    {name: 'madc2',               amps: 3,    sw: nil},
    {name: 'upper-rudder-B',      amps: 3,    sw: nil},
    {name: 'apu-master',          amps: 3,    sw: nil},
    {name: 'apu-ecu',             amps: 7,    sw: nil},
    {name: 'apu-fire-detect',     amps: 3,    sw: nil},
    ];

  eicas = [
    {name: 'eicas',      amps: 7.5,   sw : nil}, # right cb
    {name: 'mfd1',       amps: 7.5,   sw : nil},
    {name: 'iac1',       amps: 5,     sw : nil},
    {name: 'disp-cont1', amps: 3,     sw : nil},
    {name: 'annun1',     amps: 3,     sw : nil},
    {name: 'annun2',     amps: 3,     sw : nil},
    {name: 'dau1A',      amps: 3,     sw : nil},
    {name: 'dau2A',      amps: 3,     sw : nil}
    ];

  stby = [
    {name: 'as-alt-vib',        amps: 1, sw : nil}, # left cb
    {name: 'stby-gyro',         amps: 3, sw : nil},
    {name: 'stby-lh-eng-instr', amps: 3, sw : nil},
    {name: 'stby-rh-eng-instr', amps: 3, sw : nil}
    ];

  feed = [
    {name: 'lh-gen1', amps: 0,  sw: nil},
    {name: 'lh-gen2', amps: 0,  sw: nil},
    {name: 'lh-gen3', amps: 0,  sw: nil},
    {name: 'rh-gen1', amps: 0,  sw: nil},
    {name: 'rh-gen2', amps: 0,  sw: nil},
    {name: 'rh-gen3', amps: 0,  sw: nil},
    {name: 'lh-avi1', amps: 0,  sw: nil},
    {name: 'lh-avi2', amps: 0,  sw: nil},
    {name: 'lh-avi3', amps: 0,  sw: nil},
    {name: 'rh-avi1', amps: 0,  sw: nil},
    {name: 'rh-avi2', amps: 0,  sw: nil},
    {name: 'rh-avi3', amps: 0,  sw: nil},
    ];

    bus = [left_gen,left_avi,left_emer,right_gen,
            right_avi,right_emer,eicas,stby,feed];

    for(var i=0;i<size(bus);i+=1) {
      for (var j=0;j<size(bus[i]);j+=1) {
        props.globals.initNode("systems/electrical/outputs/"~bus[i][j].name,0,"BOOL");
        props.globals.initNode("systems/electrical/cb/"~bus[i][j].name~"-fuse-tripped",0,"BOOL");
      }
    }

}; # end of components


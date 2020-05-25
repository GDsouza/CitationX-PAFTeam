### Properties Initialization   ###
### C. Le Moigne (clm76) - 2019 ###

### Air Conditioning ###
props.globals.initNode("/controls/air-conditioning/cabin/degC", 0, "DOUBLE");	
props.globals.initNode("/controls/air-conditioning/cabin/temp-sel", 21, "DOUBLE");	
props.globals.initNode("/controls/air-conditioning/cabin/rotation", 315, "DOUBLE");	
props.globals.initNode("/controls/air-conditioning/cabin/pac",0, "INT");	
props.globals.initNode("/controls/air-conditioning/cabin/auto",1, "BOOL");	
props.globals.initNode("/controls/air-conditioning/cabin/inflow",0, "BOOL");	
props.globals.initNode("/controls/air-conditioning/cabin/remote",0, "BOOL");	
props.globals.initNode("/controls/air-conditioning/cockpit/degC", 0, "DOUBLE");	
props.globals.initNode("/controls/air-conditioning/cockpit/temp-sel", 21, "DOUBLE");	
props.globals.initNode("/controls/air-conditioning/cockpit/rotation", 315, "DOUBLE");	
props.globals.initNode("/controls/air-conditioning/cockpit/auto",1, "BOOL");	
props.globals.initNode("/controls/air-conditioning/cockpit/pac", 0, "INT");	
props.globals.initNode("/controls/air-conditioning/cockpit/inflow", 0, "BOOL");	
props.globals.initNode("/controls/air-conditioning/select", 2, "INT");	
props.globals.initNode("/controls/air-conditioning/isol-valve", 0, "BOOL");	
props.globals.initNode("/controls/air-conditioning/bleed-air/left-engine", 1, "INT");	
props.globals.initNode("/controls/air-conditioning/bleed-air/right-engine", 1, "INT");	

### Airspeed ###
props.globals.initNode("instrumentation/airspeed-indicator/round-speed-kt",0,"DOUBLE");

### Alarms ###
props.globals.initNode("sim/alarms/overspeed-alarm",0,"BOOL");
props.globals.initNode("sim/alarms/stall-warning",0,"BOOL");
props.globals.initNode("instrumentation/annunciators/test-select",0,"INT");

### Anti-ice ###
props.globals.initNode("controls/anti-ice/lh-engine",0,"BOOL");
props.globals.initNode("controls/anti-ice/rh-engine",0,"BOOL");
props.globals.initNode("controls/anti-ice/lh-pitot",0,"BOOL");
props.globals.initNode("controls/anti-ice/rh-pitot",0,"BOOL");
props.globals.initNode("controls/anti-ice/lh-ws",0,"BOOL");
props.globals.initNode("controls/anti-ice/rh-ws",0,"BOOL");
props.globals.initNode("controls/anti-ice/lh-stab",0,"BOOL");
props.globals.initNode("controls/anti-ice/rh-stab",0,"BOOL");
props.globals.initNode("controls/anti-ice/slat",0,"BOOL");
props.globals.initNode("controls/anti-ice/wing-insp",0,"BOOL");
props.globals.initNode("controls/anti-ice/ws-air",0,"BOOL");

### APU ###
props.globals.initNode("controls/APU/battery",0,"DOUBLE");
props.globals.initNode("controls/APU/bleed",0,"INT");
props.globals.initNode("controls/APU/bleed-air",0,"BOOL");
props.globals.initNode("controls/APU/gen-switch",0,"INT");
props.globals.initNode("controls/APU/generator",0,"BOOL");
props.globals.initNode("controls/APU/max-cool",0,"BOOL");
props.globals.initNode("controls/APU/master",0,"BOOL");
props.globals.initNode("controls/APU/running",0,"BOOL");
props.globals.initNode("controls/APU/start-stop",0,"DOUBLE");
props.globals.initNode("controls/APU/test",0,"BOOL");

### Audio ###
props.globals.initNode("instrumentation/audio/id-voice",0.5,"DOUBLE");
props.globals.initNode("instrumentation/audio/id",1,"BOOL");
props.globals.initNode("instrumentation/audio/voice",1,"BOOL");
props.globals.initNode("instrumentation/audio/nav1",0,"BOOL");
props.globals.initNode("instrumentation/audio/nav1-knob",0,"DOUBLE");
props.globals.initNode("instrumentation/audio/nav2",0,"BOOL");
props.globals.initNode("instrumentation/audio/nav2-knob",0,"DOUBLE");
props.globals.initNode("instrumentation/audio/adf1",0,"BOOL");
props.globals.initNode("instrumentation/audio/adf1-knob",0,"DOUBLE");
props.globals.initNode("instrumentation/audio/adf2",0,"BOOL");
props.globals.initNode("instrumentation/audio/adf2-knob",0,"DOUBLE");
props.globals.initNode("instrumentation/audio/dme1",0,"BOOL");
props.globals.initNode("instrumentation/audio/dme1-knob",0,"DOUBLE");
props.globals.initNode("instrumentation/audio/dme2",0,"BOOL");
props.globals.initNode("instrumentation/audio/dme2-knob",0,"DOUBLE");
props.globals.initNode("instrumentation/audio/mls1",0,"BOOL");
props.globals.initNode("instrumentation/audio/mls1-knob",0,"DOUBLE");
props.globals.initNode("instrumentation/audio/mls2",0,"BOOL");
props.globals.initNode("instrumentation/audio/mls2-knob",0,"DOUBLE");
props.globals.initNode("instrumentation/audio/mkr",0,"BOOL");
props.globals.initNode("instrumentation/audio/mkr-knob",0.5,"DOUBLE");
props.globals.initNode("instrumentation/audio/mute",0,"BOOL");
props.globals.initNode("instrumentation/audio/com1",0,"BOOL");
props.globals.initNode("instrumentation/audio/com1-knob",1,"DOUBLE");
props.globals.initNode("instrumentation/audio/com2",0,"BOOL");
props.globals.initNode("instrumentation/audio/com2-knob",1,"DOUBLE");
props.globals.initNode("instrumentation/audio/hf",0,"BOOL");
props.globals.initNode("instrumentation/audio/hf-knob",1,"DOUBLE");
props.globals.initNode("instrumentation/audio/speaker",0.7,"DOUBLE");

### Autopilot ###
props.globals.initNode("autopilot/route-manager/alternate/set-flag",0,"BOOL");
props.globals.initNode("autopilot/route-manager/alternate/closed",0,"BOOL");
props.globals.initNode("/autopilot/route-manager/alternate[1]/airport","");
props.globals.initNode("/autopilot/route-manager/alternate[1]/closed",0,"BOOL");
props.globals.initNode("/autopilot/route-manager/alternate[1]/runway","");
props.globals.initNode("/autopilot/route-manager/alternate[1]/set-flag",0,"BOOL");
props.globals.initNode("autopilot/settings/nav-btn",0,"BOOL");
props.globals.initNode("autopilot/settings/fms-btn",0,"BOOL");
props.globals.initNode("autopilot/settings/fgc","A","STRING");
props.globals.initNode("autopilot/settings/fms",0,"BOOL");
props.globals.initNode("autopilot/locks/alt-mach",0,"BOOL");
props.globals.initNode("autopilot/locks/alm-tod",0,"BOOL");
props.globals.initNode("autopilot/locks/alm-wp",0,"BOOL");
props.globals.initNode("autopilot/locks/from-flag",0,"BOOL");
props.globals.initNode("autopilot/locks/fms-gs",0,"BOOL");
props.globals.initNode("autopilot/locks/fms-app",0,"BOOL");
props.globals.initNode("autopilot/internal/fms-climb-rate-fps",0,"DOUBLE");
props.globals.initNode("autopilot/internal/nav-ete","ETE 0+00","STRING");

### Cabin ###
props.globals.initNode("controls/separation-door/open",1,"DOUBLE");
props.globals.initNode("controls/toilet-door/open",0,"DOUBLE");
props.globals.initNode("controls/cabin-door/open",0,"BOOL");
for(var n=0;n<4;n+=1) {
  props.globals.initNode("controls/tables/table"~n~"/cache/open",0,"BOOL");
  props.globals.initNode("controls/tables/table"~n~"/extend",0,"BOOL");
}
for(var n=1;n<9;n+=1) {
  props.globals.initNode("controls/bar/bar-door-"~n,0,"DOUBLE");
}

### CDU ###
for(var n=0;n<2;n+=1) {
  props.globals.initNode("instrumentation/cdu["~n~"]/init",0,"BOOL");
  props.globals.initNode("instrumentation/cdu["~n~"]/pos-init",0,"BOOL");
  props.globals.initNode("instrumentation/cdu["~n~"]/direct",0,"BOOL");
  props.globals.initNode("instrumentation/cdu["~n~"]/direct-to",-1,"INT");
  props.globals.initNode("/instrumentation/cdu["~n~"]/nbpage",1,"INT");
  props.globals.initNode("/instrumentation/cdu["~n~"]/alarms",0,"INT");
  props.globals.initNode("/instrumentation/cdu["~n~"]/fltplan",0,"BOOL");
}

### Checklists ###
props.globals.initNode("instrumentation/checklists/chklst-pilot",0,"BOOL");
props.globals.initNode("instrumentation/checklists/chklst-copilot",0,"BOOL");
props.globals.initNode("instrumentation/checklists/nr-page",0,"INT");
props.globals.initNode("instrumentation/checklists/nr-page[1]",0,"INT");
props.globals.initNode("instrumentation/checklists/nr-voice",0,"INT");
props.globals.initNode("instrumentation/checklists/page",0,"INT");

### Clock ###
props.globals.initNode("instrumentation/clock/flight-meter-hour",0,"DOUBLE");

### EFIS ###
props.globals.initNode("instrumentation/efis/baro-hpa",0,"BOOL");
props.globals.initNode("instrumentation/efis/vsd",0,"BOOL");
props.globals.initNode("instrumentation/efis/vsd[1]",0,"BOOL");

### EICAS ###
props.globals.initNode("instrumentation/eicas/xfr",0,"INT");
props.globals.initNode("instrumentation/eicas/sg-rev",0,"INT");
props.globals.initNode("instrumentation/eicas/dau1",0,"BOOL");
props.globals.initNode("instrumentation/eicas/dau2",0,"BOOL");
props.globals.initNode("instrumentation/eicas/warn",0,"BOOL");
props.globals.initNode("instrumentation/eicas/knob",0,"INT");
#props.globals.initNode("instrumentation/eicas/hidden-lines",0,"INT");
props.globals.initNode("instrumentation/eicas/messages",0,"INT");

### Electrical ###
props.globals.initNode("controls/electric/batt1-switch",0,"BOOL");
props.globals.initNode("controls/electric/batt2-switch",0,"BOOL");
props.globals.initNode("controls/electric/avionics-switch",0,"INT");
props.globals.initNode("controls/electric/xtie-open",0,"BOOL");
props.globals.initNode("controls/electric/lh-emer",0,"BOOL");
props.globals.initNode("controls/electric/rh-emer",0,"BOOL");
props.globals.initNode("controls/electric/stby-pwr",0,"INT");
props.globals.initNode("controls/electric/stby-batt-fail",0,"BOOL");

### Engines ###
props.globals.initNode("controls/engines/grnd-idle",1,"BOOL");
props.globals.initNode("controls/engines/disengage",0,"BOOL");
props.globals.initNode("controls/engines/synchro",0,"DOUBLE");
for(var n=0;n<2;n+=1) {
  props.globals.initNode("controls/engines/engine["~n~"]/fuel-pump",0,"BOOL");
  props.globals.initNode("controls/engines/engine["~n~"]/feed-tank",0,"INT");
  props.globals.initNode("controls/engines/engine["~n~"]/running",0,"BOOL");
  props.globals.initNode("engines/engine["~n~"]/cycle-up",0,"BOOL");
  props.globals.initNode("engines/engine["~n~"]/fan",0,"DOUBLE");
  props.globals.initNode("engines/engine["~n~"]/turbine",0,"DOUBLE");
  props.globals.initNode("engines/engine["~n~"]/fuel-flow-pph",0,"DOUBLE");
  props.globals.initNode("engines/engine["~n~"]/out-of-fuel",0,"BOOL");
  props.globals.initNode("engines/engine["~n~"]/generator",0,"BOOL");
  props.globals.initNode("surface-positions/reverser-norm["~n~"]",0,"DOUBLE");
}

### Fire ###
props.globals.initNode("controls/fire/engines-fire",0,"BOOL");
props.globals.initNode("controls/fire/left-eng-fire-detect",0,"BOOL");
props.globals.initNode("controls/fire/right-eng-fire-detect",0,"BOOL");
props.globals.initNode("controls/fire/left-eng-pushed",0,"BOOL");
props.globals.initNode("controls/fire/right-eng-pushed",0,"BOOL");
props.globals.initNode("controls/fire/bottles",0,"BOOL");
props.globals.initNode("controls/fire/bottle1-pushed",0,"BOOL");
props.globals.initNode("controls/fire/bottle2-pushed",0,"BOOL");
props.globals.initNode("controls/fire/bottle1-low",0,"BOOL");
props.globals.initNode("controls/fire/bottle2-low",0,"BOOL");

### Flight ###
props.globals.initNode("controls/flight/flaps-select",0,"INT");
props.globals.initNode("controls/flight/yd","A","STRING");
props.globals.initNode("controls/flight/vref",131,"DOUBLE");
props.globals.initNode("controls/flight/va",200,"DOUBLE");

### Fuel ###
for(var n=0;n<2;n+=1) {
  props.globals.initNode("controls/fuel/tank["~n~"]/boost-pump",0,"INT");
  props.globals.initNode("controls/fuel/tank["~n~"]/boost-pump",0,"INT");
}
props.globals.initNode("controls/fuel/xfer-L",0,"INT");
props.globals.initNode("controls/fuel/xfer-R",0,"INT");

### Gears ###
for(var n=0;n<3;n+=1) {
  props.globals.initNode("gear/gear["~n~"]/tire-rpm",0,"DOUBLE");
}

### HF ###
props.globals.initNode("instrumentation/kfs-594/mode",0,"INT");
props.globals.initNode("instrumentation/kfs-594/store",0,"BOOL");
props.globals.initNode("instrumentation/kfs-594/vol-knob",0.7,"DOUBLE");
props.globals.initNode("instrumentation/kfs-594/squelch",0.4,"DOUBLE");
props.globals.initNode("instrumentation/kfs-594/freq-nb",0,"INT");
props.globals.initNode("instrumentation/kfs-594/prog",0,"INT");
props.globals.initNode("instrumentation/kfs-594/channel-nb",1,"INT");
props.globals.initNode("instrumentation/kfs-594/xfer",0,"BOOL");
props.globals.initNode("instrumentation/kfs-594/reset",0,"BOOL");

### Hydraulic ###
props.globals.initNode("controls/hydraulic/aux-pump",0,"BOOL");
props.globals.initNode("controls/hydraulic/pumpA",1,"BOOL");
props.globals.initNode("controls/hydraulic/pumpB",1,"BOOL");

### IRS ###
for(var n=0;n<2;n+=1) {
  props.globals.initNode("instrumentation/irs["~n~"]/positionned",0,"BOOL");
  props.globals.initNode("instrumentation/irs["~n~"]/align",0,"BOOL");
  props.globals.initNode("instrumentation/irs["~n~"]/test",0,"BOOL");
  props.globals.initNode("instrumentation/irs["~n~"]/selected",0,"INT");
  props.globals.initNode("instrumentation/irs["~n~"]/failure",0,"BOOL");
}

### Lighting ###
props.globals.initNode("controls/lighting/landing-light[0]",0,"BOOL");
props.globals.initNode("controls/lighting/landing-light[1]",0,"BOOL");
props.globals.initNode("controls/lighting/cabin-lights",0,"BOOL");
props.globals.initNode("controls/lighting/wing-lights",0,"BOOL");
props.globals.initNode("controls/lighting/recog-lights",0,"INT");
props.globals.initNode("controls/lighting/recog-state",0,"BOOL");
props.globals.initNode("controls/lighting/recog-pulse",0,"BOOL");
props.globals.initNode("controls/lighting/logo-lights",0,"BOOL");
props.globals.initNode("controls/lighting/anti-coll",0,"INT");
props.globals.initNode("controls/lighting/beacon-state/state",0,"BOOL");
props.globals.initNode("controls/lighting/strobe-state/state",0,"BOOL");
props.globals.initNode("controls/lighting/cdu",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/cdu[1]",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/rmu",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/rmu[1]",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/eicas",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/pfd",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/pfd[1]",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/mfd",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/mfd[1]",0.8,"DOUBLE");
props.globals.initNode("controls/lighting/emer-lights",0,"INT");
props.globals.initNode("controls/lighting/lh",0.001,"DOUBLE");
props.globals.initNode("controls/lighting/lh-norm",0.001,"DOUBLE");
props.globals.initNode("controls/lighting/rh",0.001,"DOUBLE");
props.globals.initNode("controls/lighting/rh-norm",0.001,"DOUBLE");
props.globals.initNode("controls/lighting/ctr",0.001,"DOUBLE");
props.globals.initNode("controls/lighting/ctr-norm",0.001,"DOUBLE");
props.globals.initNode("controls/lighting/ctr-instr",0.40,"DOUBLE");
props.globals.initNode("controls/lighting/flood",0.001,"DOUBLE");
props.globals.initNode("controls/lighting/flood-norm",0.0001,"DOUBLE");
props.globals.initNode("controls/lighting/el",0.001,"DOUBLE");
props.globals.initNode("controls/lighting/el-norm",0.001,"DOUBLE");
props.globals.initNode("controls/lighting/day-night",0,"BOOL");
props.globals.initNode("controls/lighting/lh-map",0,"DOUBLE");
props.globals.initNode("controls/lighting/rh-map",0,"DOUBLE");
props.globals.initNode("controls/lighting/seat-belts",0,"INT");

### MFD ###
for(var n=0;n<2;n+=1) {
  props.globals.initNode("instrumentation/mfd["~n~"]/menu2",0,"BOOL");
  props.globals.initNode("instrumentation/mfd["~n~"]/s-menu",0,"INT");
  props.globals.initNode("instrumentation/mfd["~n~"]/cdr-tot",0,"INT");
  props.globals.initNode("instrumentation/mfd["~n~"]/map",0,"BOOL");
  props.globals.initNode("instrumentation/mfd["~n~"]/outputs/apt",0,"BOOL");
  props.globals.initNode("instrumentation/mfd["~n~"]/outputs/vor",0,"BOOL");
  props.globals.initNode("instrumentation/mfd["~n~"]/outputs/fix",0,"BOOL");
  props.globals.initNode("instrumentation/mfd["~n~"]/outputs/fms",0,"BOOL");
  props.globals.initNode("instrumentation/mfd["~n~"]/outputs/src",0,"BOOL");
  props.globals.initNode("instrumentation/mfd["~n~"]/etx",0,"INT");
}
for (var n=0;n<9;n+=1) {
	props.globals.initNode("instrumentation/mfd/cdr"~n,0,"BOOL");
	props.globals.initNode("instrumentation/mfd[1]/cdr"~n,0,"BOOL");
}
for (var n=0;n<6;n+=1) {
	props.globals.initNode("instrumentation/mfd/btn"~n,0,"BOOL");
	props.globals.initNode("instrumentation/mfd[1]/btn"~n,0,"BOOL");
}

### Model ###
props.globals.initNode("sim/model/show-pilot",1,"BOOL");
props.globals.initNode("sim/model/show-copilot",1,"BOOL");
props.globals.initNode("sim/model/show-yoke-L",1,"BOOL");
props.globals.initNode("sim/model/show-yoke-R",1,"BOOL");
props.globals.initNode("sim/model/mem-yoke-L",1,"BOOL");
props.globals.initNode("sim/model/mem-yoke-R",1,"BOOL");
props.globals.initNode("sim/model/pilot-seat",0,"DOUBLE");
props.globals.initNode("sim/model/copilot-seat",0,"DOUBLE");
props.globals.initNode("sim/sound/startup",0,"INT");

### Oxygene ###
props.globals.initNode("controls/oxygen/oxygen-psi",0,"DOUBLE");
props.globals.initNode("controls/oxygen/mic-select-pilot",0,"BOOL");
props.globals.initNode("controls/oxygen/mic-select-copilot",0,"BOOL");
props.globals.initNode("controls/oxygen/pass-oxy",0,"INT");

### PFD ###
props.globals.initNode("instrumentation/pfd/madc",0,"BOOL");
props.globals.initNode("instrumentation/pfd/madc-btn",0,"BOOL");

### Pressurization ###
props.globals.initNode("systems/pressurization/cabin-alt-ft",0,"DOUBLE");
props.globals.initNode("systems/pressurization/cabin-rate-fpm",0,"DOUBLE");
props.globals.initNode("systems/pressurization/max-cabin-rate-fpm",500,"DOUBLE");
props.globals.initNode("systems/pressurization/target-cabin-alt-ft",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/diff-p",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/valve-state",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/valve-max",1,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/valve-offset",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/inflow-rate",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/atten-m",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/atten-b",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/outflow-rate",0,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/max-outflow-rate",3000,"DOUBLE");
props.globals.initNode("systems/pressurization/internal/target-rate",0,"DOUBLE");
props.globals.initNode("controls/pressurization/outflow-valve-pos[0]",0,"DOUBLE");
props.globals.initNode("controls/pressurization/outflow-valve-pos[1]",0,"DOUBLE");
props.globals.initNode("controls/pressurization/landing-alt-ft",0,"DOUBLE");
props.globals.initNode("controls/pressurization/manual",0,"BOOL");
props.globals.initNode("controls/pressurization/auto-rate-fpm",0,"DOUBLE");
props.globals.initNode("controls/pressurization/man-rate-fpm",1300,"DOUBLE");
props.globals.initNode("controls/pressurization/man-alt-ft",-1000,"DOUBLE");
props.globals.initNode("controls/pressurization/climb-rate-fpm",500,"DOUBLE");
props.globals.initNode("controls/pressurization/man-rate-lever",0,"INT");
props.globals.initNode("controls/pressurization/cabin-dump",0,"BOOL");
props.globals.initNode("controls/pressurization/baggage-isol",0,"BOOL");
props.globals.initNode("controls/pressurization/cabin-alt-dsp",0,"DOUBLE");
props.globals.initNode("controls/pressurization/high-altitude",0,"BOOL");

### RCU ###
props.globals.initNode("instrumentation/rcu/selected","COM","STRING");
props.globals.initNode("instrumentation/rcu/mode",0,"BOOL");
props.globals.initNode("instrumentation/rcu/squelch",0,"BOOL");

### Reversionary ###
props.globals.initNode("instrumentation/reversionary/sg-test",0,"BOOL");
props.globals.initNode("instrumentation/reversionary/sg-test[1]",0,"BOOL");

### RMU ###
props.globals.initNode("instrumentation/rmu/trsp-num",1,"INT");
for(var n=0;n<2;n+=1) {
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/dim",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-com",0,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-nav",0,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/more",0,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-dsp",-1,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-freq",0,"DOUBLE");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/insert",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/test",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/delete",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/insert",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-dsp",-1,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-freq",0,"DOUBLE");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/mem-nav",0,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/pge",0,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/selected",0,"INT");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/sto",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/swp1",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/swp2",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/test",0,"BOOL");
  props.globals.initNode("instrumentation/rmu/unit["~n~"]/dme-selected",0,"INT");
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/ident",0,"BOOL");
  props.globals.initNode("instrumentation/dme["~n~"]/dme-id","","STRING");
  props.globals.initNode("instrumentation/tacan["~n~"]/frequencies/selected-channel","","STRING");
  props.globals.initNode("instrumentation/tacan["~n~"]/frequencies/selected-mhz",0,"DOUBLE");
  props.globals.initNode("instrumentation/tacan["~n~"]/id","","STRING");
}

### Rudders ###
props.globals.initNode("controls/flight/rudder-shutoff",0,"BOOL");
props.globals.initNode("controls/flight/rudder-fail",0,"BOOL");

### Services ###
props.globals.initNode("/services/chokes", 0, "BOOL");	
props.globals.initNode("/services/ext-pwr/enable", 0, "BOOL");
props.globals.initNode("/services/fuel-truck/enable", 0, "BOOL");
props.globals.initNode("/services/fuel-truck/connect", 0, "BOOL");
props.globals.initNode("/services/fuel-truck/transfer", 0, "BOOL");
props.globals.initNode("/services/fuel-truck/clean", 0, "BOOL");
props.globals.initNode("/services/fuel-truck/request-lbs", 0, "DOUBLE");

### Transponder ###
for(var n=0;n<2;n+=1) {
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/id-code",7777,"INT");
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/id-code[1]",77,"INT");
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/id-code[2]",77,"INT");
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/display-mode","STANDBY");
  props.globals.initNode("instrumentation/transponder/unit["~n~"]/knob-mode",1,"INT");
}

### Voice Recorder ###
props.globals.initNode("instrumentation/cvr/light",0,"BOOL");



### Citation X ####
### Révision C. Le Moigne (clm76) - 2015-2016  ###


### tire rotation per minute by circumference ####
#var tire=TireSpeed.new(# of gear,diam[0],diam[1],diam[2], ...);
var TireSpeed = {
    new : func(number){
        m = { parents : [TireSpeed] };
            m.num=number;
            m.circumference=[];
            m.tire=[];
            m.rpm=[];
            for(var i=0; i<m.num; i+=1) {
                var diam =arg[i];
                var circ=diam * math.pi;
                append(m.circumference,circ);
                append(m.tire,props.globals.initNode("gear/gear["~i~"]/tire-rpm",0,"DOUBLE"));
                append(m.rpm,0);
            }
        m.count = 0;
        return m;
    },
    #### calculate and write rpm ###########
    get_rotation: func (fdm1){
        var speed=0;
        if(fdm1=="yasim"){
            speed =getprop("gear/gear["~me.count~"]/rollspeed-ms") or 0;
            speed=speed*60;
            }elsif(fdm1=="jsb"){
                speed =getprop("fdm/jsbsim/gear/unit["~me.count~"]/wheel-speed-fps") or 0;
                speed=speed*18.288;
            }
        var wow = getprop("gear/gear["~me.count~"]/wow");
        if(wow){
            me.rpm[me.count] = speed / me.circumference[me.count];
        }else{
            if(me.rpm[me.count] > 0) me.rpm[me.count]=me.rpm[me.count]*0.95;
        }
        me.tire[me.count].setValue(me.rpm[me.count]);
        me.count+=1;
        if(me.count>=me.num)me.count=0;
    },
};


#Jet Engine Helper class 
# ie: var Eng = JetEngine.new(engine number);

var JetEngine = {
    new : func(eng_num){
        m = { parents : [JetEngine]};
        m.fdensity = getprop("consumables/fuel/tank/density-ppg") or 6.72;
        m.eng = props.globals.getNode("engines/engine["~eng_num~"]",1);
        m.running = m.eng.initNode("running",0,"BOOL");
        m.n1 = m.eng.getNode("n1",1);
        m.n2 = m.eng.getNode("n2",1);
        m.fan = m.eng.initNode("fan",0,"DOUBLE");
        m.cycle_up = 0;
        m.engine_off=1;
        m.turbine = m.eng.initNode("turbine",0,"DOUBLE");
        m.throttle_lever = props.globals.initNode("controls/engines/engine["~eng_num~"]/throttle-lever",0,"DOUBLE");
        m.throttle = props.globals.initNode("controls/engines/engine["~eng_num~"]/throttle",0,"DOUBLE");
        m.ignition = props.globals.initNode("controls/engines/engine["~eng_num~"]/ignit",0,"INT");
        m.cutoff = props.globals.initNode("controls/engines/engine["~eng_num~"]/cutoff",1,"BOOL");
        m.fuel_out = props.globals.initNode("engines/engine["~eng_num~"]/out-of-fuel",0,"BOOL");
        m.starter = props.globals.initNode("controls/engines/engine["~eng_num~"]/starter",0,"BOOL");
        m.fuel_pph=m.eng.initNode("fuel-flow_pph",0,"DOUBLE");
        m.fuel_gph=m.eng.initNode("fuel-flow-gph");
        m.Lfuel = setlistener(m.fuel_out, func m.shutdown(m.fuel_out.getValue()),0,0);
        m.CutOff = setlistener(m.cutoff, func (ct){m.engine_off=ct.getValue()},1,0);
    return m;
    },


#### update ####
    update : func{
        var thr = me.throttle.getValue();
        if(!me.engine_off){
            me.fan.setValue(me.n1.getValue());
            me.turbine.setValue(me.n2.getValue());
            if(getprop("controls/engines/grnd_idle"))thr *=0.92;
            me.throttle_lever.setValue(thr);
        }else{
            me.throttle_lever.setValue(0);
            if(me.starter.getBoolValue()){
                if(me.cycle_up == 0)me.cycle_up=1;
            }
            if(me.cycle_up>0){
                me.spool_up(15);
            }else{
                var tmprpm = me.fan.getValue();
                if(tmprpm > 0.0){
                    tmprpm -= getprop("sim/time/delta-sec") * 2;
                    me.fan.setValue(tmprpm);
                    me.turbine.setValue(tmprpm);
                }
            }
        }
        me.fuel_pph.setValue(me.fuel_gph.getValue()*me.fdensity);
    },

    spool_up : func(scnds){
        if(me.engine_off){
        var n1=me.n1.getValue() ;
        var n1factor = n1/scnds;
        var n2=me.n2.getValue() ;
        var n2factor = n2/scnds;
        var tmprpm = me.fan.getValue();
            tmprpm += getprop("sim/time/delta-sec") * n1factor;
            var tmprpm2 = me.turbine.getValue();
            tmprpm2 += getprop("sim/time/delta-sec") * n2factor;
            me.fan.setValue(tmprpm);
            me.turbine.setValue(tmprpm2);
            if(tmprpm >= me.n1.getValue()){
							if (me.ignition.getValue()==-1) {
								var ign = 1+me.ignition.getValue();
							} else {var ign=1-me.ignition.getValue()}
              me.cutoff.setBoolValue(ign);
              me.cycle_up=0;
            }
        }
    },

    shutdown : func(b){
        if(b!=0){
            me.cutoff.setBoolValue(1);
        }
    }

};

var fl_tot = 0;
var FDM="";
var Grd_Idle=props.globals.initNode("controls/engines/grnd-idle",1,"BOOL");
var Annun = props.globals.getNode("instrumentation/annunciators",1);
props.globals.initNode("controls/flight/flaps-select",0,"INT");
props.globals.initNode("controls/fuel/tank[0]/boost_pump",0,"INT");
props.globals.initNode("controls/fuel/tank[1]/boost_pump",0,"INT");
props.globals.initNode("sim/model/show-pilot",1,"BOOL");
props.globals.initNode("sim/model/show-copilot",1,"BOOL");
props.globals.initNode("sim/model/show-yoke_L",1,"BOOL");
props.globals.initNode("sim/model/show-yoke_R",1,"BOOL");
props.globals.initNode("sim/model/mem-yoke_L",1,"BOOL");
props.globals.initNode("sim/model/mem-yoke_R",1,"BOOL");
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
props.globals.initNode("sim/model/pilot-seat",0,"DOUBLE");
props.globals.initNode("sim/model/copilot-seat",0,"DOUBLE");
props.globals.initNode("sim/alarms/overspeed-alarm",0,"BOOL");
props.globals.initNode("sim/alarms/stall-warning",0,"BOOL");
props.globals.initNode("instrumentation/clock/flight-meter-hour",0,"DOUBLE");
props.globals.initNode("instrumentation/primus2000/dc840/etx",0,"INT");
props.globals.initNode("instrumentation/checklists/norm",0,"BOOL");
props.globals.initNode("instrumentation/checklists/nr-page",0,"INT");
props.globals.initNode("instrumentation/checklists/nr-voice",0,"INT");
props.globals.initNode("instrumentation/transponder/id-code",7777,"DOUBLE");
props.globals.initNode("instrumentation/transponder/id-code[1]",77,"INT");
props.globals.initNode("instrumentation/transponder/id-code[2]",77,"INT");
props.globals.initNode("instrumentation/transponder/inputs/display-mode","STANDBY");
props.globals.initNode("instrumentation/transponder/inputs/knob-mode",1,"INT");
props.globals.initNode("autopilot/locks/alt-mach",0,"BOOL");
props.globals.initNode("autopilot/locks/fms-status",0,"BOOL");
props.globals.initNode("autopilot/settings/nav-btn",0,"BOOL");
props.globals.initNode("autopilot/settings/fms-btn",0,"BOOL");
props.globals.initNode("sim/sound/startup",0,"INT");

var PWR2 =0;
aircraft.livery.init("Aircraft/CitationX/Models/Liveries");
var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 1,1); 
var Chrono = aircraft.timer.new("/instrumentation/clock/chrono", 1,1);
var LHeng= JetEngine.new(0);
var RHeng= JetEngine.new(1);
var tire=TireSpeed.new(3,0.430,0.615,0.615);
var et = 0;

### Initialisation FDM ###

var fdm_init = func(){
    FDM=getprop("/sim/flight-model");
    setprop("controls/engines/N1-limit",95.0);
}

### Listeners ###

setlistener("/sim/signals/fdm-initialized", func {
    fdm_init();
    settimer(update_systems,2);
		setprop("instrumentation/altimeter/setting-inhg",29.92001);
		setprop("instrumentation/clock/flight-meter-sec",0);
#		setprop("sim/sound/startup",int(10*rand()));
		FH_load();
});

setlistener("/sim/signals/reinit", func {
    fdm_init();
},0,0);

setlistener("/sim/crashed", func(cr){
    if(cr.getBoolValue()){
    }
},1,0);

setlistener("sim/model/autostart", func(strt){
    if(strt.getBoolValue()){
        Startup();
    }else{
        Shutdown();
    }
},0,0);

setlistener("/engines/engine[0]/turbine",func(turb) {
		if(turb.getValue() >20) {setprop("/controls/engines/engine[0]/starter",0)}
},0,0);

setlistener("/engines/engine[1]/turbine",func(turb) {
		if(turb.getValue() >20) {setprop("/controls/engines/engine[1]/starter",0)}
},0,0);

setlistener("/controls/gear/antiskid", func(as){
	print(as);
    var test=as.getBoolValue();
    if(!test){
    MstrCaution.setBoolValue(1 * PWR2);
    Annun.getNode("antiskid").setBoolValue(1 * PWR2);
    }else{
    Annun.getNode("antiskid").setBoolValue(0);
    }
},0,0);

setlistener("instrumentation/altimeter/setting-inhg", func(inhg){
    setprop("instrumentation/altimeter/setting-kpa",inhg.getValue()*3.386389)
},1,0);

setlistener("/sim/freeze/fuel", func(ffr){
    var test=ffr.getBoolValue();
    if(test){
    MstrCaution.setBoolValue(1 * PWR2);
    Annun.getNode("fuel-gauge").setBoolValue(1 * PWR2);
    }else{
    Annun.getNode("fuel-gauge").setBoolValue(0);
    }
},0,0);

setlistener("/sim/current-view/internal", func {
		var mem_yokeL = getprop("sim/model/mem-yoke_L");
		var mem_yokeR = getprop("sim/model/mem-yoke_R");
		if (getprop("/sim/current-view/internal") == 0) {
			setprop("sim/model/show-yoke_L",1);
			setprop("sim/model/show-yoke_R",1);
			setprop("sim/model/show-pilot",1);
			setprop("sim/model/show-copilot",1);
		} 
		else {
			setprop("sim/model/show-yoke_L",mem_yokeL);
			setprop("sim/model/show-pilot",mem_yokeL);
			setprop("sim/model/show-yoke_R",mem_yokeR);
			setprop("sim/model/show-copilot",mem_yokeR);
		}
},0,0);

### Tables animation ###

var tables_anim = func(i) {
		var cc = props.globals.initNode("controls/tables/table"~i~"/cache/open",0,"BOOL");
		var Table_0 = aircraft.door.new("controls/tables/table"~i~"/tab0",2);
		var Table_1 = aircraft.door.new("controls/tables/table"~i~"/tab1",2);
		var Table_2 = aircraft.door.new("controls/tables/table"~i~"/tab2",2);
		var Cache = aircraft.door.new("controls/tables/table"~i~"/cache",1);

		var timer_open = maketimer(0.1,func {
			if (getprop("controls/tables/table"~i~"/cache/position-norm")==1.0) {
				Table_0.open();
				if (getprop("controls/tables/table"~i~"/tab0/position-norm")==1.0) {
					Table_1.open();
					if (getprop("controls/tables/table"~i~"/tab1/position-norm")==1.0) {
						Table_2.open();
						if (getprop("controls/tables/table"~i~"/tab2/position-norm")==1.0) {
							cc.setBoolValue(1);
							Cache.close();
							timer_open.stop();
						}
					}				
				}			
			}
		});
		if (getprop("controls/tables/table"~i~"/extend") and !cc.getBoolValue()) {
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
							cc.setBoolValue(0);
							Cache.close();
							timer_close.stop();
						}
					}
				}
			}
		});
		if (!getprop("controls/tables/table"~i~"/extend") and cc.getBoolValue()) {
			Cache.open();
			timer_close.start();
		}
}

### Flight Meter and ET ###

setlistener("instrumentation/primus2000/dc840/et", func(xx){
	if(getprop("systems/electrical/right-bus-norm") and getprop("controls/electric/avionics-switch")==2) {
		if(xx.getBoolValue()){
			if(et <= 2){et +=1}
			else{et = 0}
			setprop("instrumentation/primus2000/dc840/etx",et);
			if(et == 1){Chrono.start()}
			if(et == 2){Chrono.stop()}
			if(et == 3){Chrono.reset()}			
			chrono_update();
		}
	}
});

setlistener("/gear/gear[1]/wow", func(ww){
    if(ww.getBoolValue()){
        FHmeter.stop();
        Grd_Idle.setBoolValue(1);			
				FH_write();
    }else{
        Grd_Idle.setBoolValue(0);
        FHmeter.start();
				### raz clock to prevent restart on bounce ###
				setprop("/instrumentation/clock/flight-meter-sec",0);
    }
},0,0);

var chrono_update = func {
	if(!getprop("systems/electrical/right-bus-norm") or getprop("controls/electric/avionics-switch")< 2) {
		Chrono.stop();
		Chrono.reset();
		et=0;
		setprop("instrumentation/primus2000/dc840/etx",0)
		}
		var chrono_hour = 0;
		var chrono_min = 0;
		var chrono = int(getprop("instrumentation/clock/chrono"));
		var chrono_sec = math.fmod(chrono,60);
		chrono_hour = chrono/3600;
		chrono_min = (chrono_hour - int(chrono_hour))*60;
		setprop("instrumentation/clock/chrono-sec",chrono_sec);
		setprop("instrumentation/clock/chrono-min",int(chrono_min)); 
		setprop("instrumentation/clock/chrono-hour",int(chrono_hour));
}

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
		name.setDoubleValue(fl_tot);
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
    setprop("controls/electric/avionics-switch",2);
    setprop("controls/electric/battery-switch",1);
    setprop("controls/electric/battery-switch[1]",1);
    setprop("controls/electric/inverter-switch",1);
    setprop("controls/electric/std-by-pwr",1);
    setprop("controls/lighting/nav-lights",1);
    setprop("controls/lighting/beacon",1);
    setprop("controls/lighting/strobe",1);
    setprop("controls/lighting/recog-lights",1);
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
		setlistener("systems/electrical/right-bus",func {
			if (getprop("systems/electrical/right-bus") > 27) {
				setprop("controls/electric/external-power",0);
			}
		});
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

var speed_ref = func {
		var Wtot = getprop("yasim/gross-weight-lbs");
		var Flaps = getprop("controls/flight/flaps");
		var v1=0;
		var vr=0;
		var v2=0;
		var vref=0;

		setprop("controls/flight/va",200);
		setprop("controls/flight/vf5",180);
		setprop("controls/flight/vf15",160);
		setprop("controls/flight/vf35",140);

		if (getprop("velocities/airspeed-kt")> 20) {
			if (Flaps <= 0.142) {
				if (Wtot <27000) {v1=122;vr=126;v2=139}
				if (Wtot >=27000 and Wtot <29000) {v1=123;vr=126;v2=139}
				if (Wtot >=29000 and Wtot <31000) {v1=125;vr=126;v2=138}
				if (Wtot >=31000 and Wtot <33000) {v1=126;vr=126;v2=138}
				if (Wtot >=33000 and Wtot <34000) {v1=127;vr=127;v2=138}
				if (Wtot >=34000 and Wtot <35000) {v1=130;vr=130;v2=140}
				if (Wtot >=35000 and Wtot <36100) {v1=132;vr=132;v2=143}
				if (Wtot >=36100) {v1=134;vr=134;v2=144}
			} else if (Flaps > 0.142) {
				if (Wtot <31000) {v1=115;vr=118;v2=129}
				if (Wtot >=31000 and Wtot <33000) {v1=116;vr=120;v2=128}
				if (Wtot >=33000 and Wtot <34000) {v1=121;vr=126;v2=131}
				if (Wtot >=34000 and Wtot <35000) {v1=124;vr=128;v2=133}
				if (Wtot >=35000 and Wtot <36100) {v1=126;vr=131;v2=135}
				if (Wtot >=36100) {v1=129;vr=133;v2=137}
			}
			setprop("controls/flight/v1",v1);
			setprop("controls/flight/vr",vr);
			setprop("controls/flight/v2",v2);
		}
		if (!getprop("gear/gear[1]/wow")) {
			if (Wtot >=23000 and Wtot <24000) {vref=108}
			if (Wtot >=24000 and Wtot <25000) {vref=110}
			if (Wtot >=25000 and Wtot <26000) {vref=113}
			if (Wtot >=26000 and Wtot <28000) {vref=115}
			if (Wtot >=28000 and Wtot <30000) {vref=121}
			if (Wtot >=30000 and Wtot <31000) {vref=125}
			if (Wtot >=31000 and Wtot <31800) {vref=129}
			if (Wtot >=31800) {vref=131}
			setprop("controls/flight/vref",vref);
		}
}

var atc_id = func {
	var diz = getprop("instrumentation/transponder/id-code[1]");
	var cent = getprop("instrumentation/transponder/id-code[2]");
	var dwn_1 = getprop("instrumentation/transponder/down-1");
	var dwn_2 = getprop("instrumentation/transponder/down-2");
	var dg_1 = diz-int(diz/10)*10;
	var dg_2 = int(diz/10);
	var dg_3 = cent-int(cent/10)*10;
	var dg_4 = int(cent/10);	
	var dg = [dg_1,dg_2,dg_3,dg_4];
	for (var i=0;i<4;i+=1) {
		if (i<2 and !dwn_1 and dg[i] >7) {dg[i]=0;dg[i+1]+=1}
		if (i<2 and dwn_1 and dg[i] >7) {dg[i]=7}
		if (i>1 and !dwn_2 and dg[i] >7) {dg[i]=0;dg[i+1]+=1}
		if (i>1 and dwn_2 and dg[i] >7) {dg[i]=7}
	}	
	diz = dg[0]+dg[1]*10;
	cent = dg[2]+dg[3]*10;
	setprop("instrumentation/transponder/id-code[1]",diz);
	setprop("instrumentation/transponder/id-code[2]",cent);
	setprop("instrumentation/transponder/id-code",diz + (cent*100));
}

setlistener("instrumentation/transponder/inputs/knob-mode", func {
	var knob_mode = getprop("instrumentation/transponder/inputs/knob-mode");
	var mode_display = "";
	if (knob_mode == 0) {mode_display = ""}
	if (knob_mode == 1) {mode_display = "STANDBY"}
	if (knob_mode == 2) {mode_display = "TEST"}
	if (knob_mode == 3) {mode_display = "GROUND"}
	if (knob_mode == 4) {mode_display = "ON"}
	if (knob_mode == 5) {mode_display = "ALT"}
	setprop("instrumentation/transponder/inputs/display-mode",mode_display);
});

var mfd_wx = func {
	var wx_set = getprop("instrumentation/primus2000/dc840/mfd-wx-set");
	if (wx_set == "APT") {
		setprop("instrumentation/efis/inputs/arpt",1);
		setprop("instrumentation/efis/inputs/lh-vor-adf",0);
	}
	if (wx_set == "VOR") {
		setprop("instrumentation/efis/inputs/arpt",0);
		setprop("instrumentation/efis/inputs/lh-vor-adf",1);
	}
	if (wx_set == "BOTH") {
		setprop("instrumentation/nd/display/arpt",1);
		setprop("instrumentation/nd/display/vor",1);
	}
}

var freq_limits = func {
	var com_freq = "instrumentation/comm/frequencies/standby-mhz";
	var nav_freq = "instrumentation/nav/frequencies/standby-mhz";
	if (getprop(com_freq)<117.975) {setprop(com_freq,117.975)}
	if (getprop(com_freq)>137.000) {setprop(com_freq,137.000)}
	if (getprop(nav_freq)>117.950) {setprop(nav_freq,117.950)}
}
########## MAIN ##############

var update_systems = func{
    LHeng.update();
    RHeng.update();
		chrono_update();
		mfd_wx();
		atc_id();
		freq_limits();
    FHupdate(0);
    tire.get_rotation("yasim");
		speed_ref();
    if(getprop("velocities/airspeed-kt")>40)setprop("controls/cabin-door/open",0);
    var grspd =getprop("velocities/groundspeed-kt");
    var wspd = (45-grspd) * 0.022222;
    if(wspd>1.0)wspd=1.0;
    if(wspd<0.001)wspd=0.001;
    var rudder_pos=getprop("controls/flight/rudder") or 0;
    var str=-(rudder_pos*wspd);
    setprop("/controls/gear/steering",str);
settimer(update_systems,0);
}

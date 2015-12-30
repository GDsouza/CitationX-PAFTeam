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
        m.ignition = props.globals.initNode("controls/engines/engine["~eng_num~"]/ignition",0,"DOUBLE");
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
                var ign=1-me.ignition.getValue();
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
props.globals.initNode("sim/model/pilot-seat",0,"DOUBLE");
var PWR2 =0;
aircraft.livery.init("Aircraft/CitationX/Models/Liveries");
var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 10,1);
var LHeng= JetEngine.new(0);
var RHeng= JetEngine.new(1);
var tire=TireSpeed.new(3,0.430,0.615,0.615);

#######################################

var fdm_init = func(){
    FDM=getprop("/sim/flight-model");
    setprop("controls/engines/N1-limit",95.0);
}

setlistener("/sim/signals/fdm-initialized", func {
    fdm_init();
    settimer(update_systems,2);
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

setlistener("/gear/gear[1]/wow", func(ww){
    if(ww.getBoolValue()){
        FHmeter.stop();
        Grd_Idle.setBoolValue(1);
    }else{
        FHmeter.start();
        Grd_Idle.setBoolValue(0);
    }
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

controls.gear = func {
  if(getprop("gear/gear[1]/wow")) {
			setprop("/controls/gear/gear-down", 1);
	} else if (getprop("/controls/gear/gear-down")== 1) {
			setprop("/controls/gear/gear-down",0);
	}	else {setprop("/controls/gear/gear-down",1)}
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
			if (flaps_pos == 1) {setprop(flaps_path, 0.428)}
			if (flaps_pos == 0.428) {setprop(flaps_path, 0.142)}
			if (flaps_pos == 0.142) {setprop(flaps_path, 0.0428)}
			if (flaps_pos == 0.0428) {setprop(flaps_path,0)}
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
    setprop("controls/lighting/instrument-lights",1);
    setprop("controls/lighting/nav-lights",1);
    setprop("controls/lighting/beacon",1);
    setprop("controls/lighting/strobe",1);
    setprop("controls/engines/engine[0]/cutoff",1);
    setprop("controls/engines/engine[1]/cutoff",1);
    setprop("controls/engines/engine[0]/ignition",1);
    setprop("controls/engines/engine[1]/ignition",1);
    setprop("engines/engine[0]/running",1);
    setprop("engines/engine[1]/running",1);
    setprop("controls/engines/throttle_idle",1);
		setprop("controls/engines/engine[0]/starter",1);
		setprop("controls/engines/engine[1]/starter",1);
}

var Shutdown = func{
    setprop("controls/electric/engine[0]/generator",0);
    setprop("controls/electric/engine[1]/generator",0);
    setprop("controls/electric/avionics-switch",0);
    setprop("controls/electric/battery-switch",0);
    setprop("controls/electric/battery-switch[1]",0);
    setprop("controls/electric/inverter-switch",0);
    setprop("controls/lighting/instrument-lights",1);
    setprop("controls/lighting/nav-lights",0);
    setprop("controls/lighting/beacon",0);
    setprop("controls/lighting/strobe",0);
    setprop("controls/engines/engine[0]/cutoff",1);
    setprop("controls/engines/engine[1]/cutoff",1);
    setprop("controls/engines/engine[0]/ignition",0);
    setprop("controls/engines/engine[1]/ignition",0);
    setprop("engines/engine[0]/running",0);
    setprop("engines/engine[1]/running",0);
		setprop("instrumentation/annunciators/ack-caution",1);
		setprop("instrumentation/annunciators/ack-warning",1);
		setprop("controls/electric/external-power",0);
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
    }


var v_sound = func{
		var Wtot = getprop("yasim/gross-weight-lbs");
		var Flaps = getprop("controls/flight/flaps");

		if (getprop("velocities/airspeed-kt")> 20) {
			if (Flaps <= 0.142) {
				if (Wtot <27000) {v1=122}
				if (Wtot >=27000 and Wtot <29000) {v1=123}
				if (Wtot >=29000 and Wtot <31000) {v1=125}
				if (Wtot >=31000 and Wtot <33000) {v1=126}
				if (Wtot >=33000 and Wtot <34000) {v1=127}
				if (Wtot >=34000 and Wtot <35000) {v1=130}
				if (Wtot >=35000 and Wtot <36100) {v1=132}
				if (Wtot >=36100) {v1=134}
			} else if (Flaps > 0.142) {
				if (Wtot <31000) {v1=115}
				if (Wtot >=31000 and Wtot <33000) {v1=116}
				if (Wtot >=33000 and Wtot <34000) {v1=121}
				if (Wtot >=34000 and Wtot <35000) {v1=124}
				if (Wtot >=35000 and Wtot <36100) {v1=126}
				if (Wtot >=36100) {v1=129}
			}
			setprop("controls/flight/v1",v1);
			setprop("controls/flight/vr",v1+20);
		}
}

########## MAIN ##############

var update_systems = func{
    LHeng.update();
    RHeng.update();
    FHupdate(0);
    tire.get_rotation("yasim");
		v_sound();
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

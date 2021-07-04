### Citation X ####
### C. Le Moigne (clm76) - 2016  ###

var menu2 = "instrumentation/mfd/menu2";
var path = "instrumentation/mfd/";
var s_menu = "instrumentation/mfd/s-menu";
var alt_m = "instrumentation/mfd/alt-meters";
var baro = "instrumentation/mfd/baro-hpa";
var apt = "instrumentation/mfd/outputs/apt";
var vor = "instrumentation/mfd/outputs/vor";
var fix ="instrumentation/mfd/outputs/fix";
var fms = "autopilot/settings/nav-source";
var fgc = "autopilot/settings/fgc";
var yd = "controls/flight/yd";
var traf = "instrumentation/tcas/tfc";
var tcas = "systems/electrical/outputs/tcas";
var vsd = "instrumentation/efis/vsd";
var cdr = ["cdr0","cdr1","cdr2","cdr3","cdr4","cdr5","cdr6","cdr7","cdr8"];
var wx_range = [10,20,40,80,160,320];
var wx_index = 1;
var spd_range = 0;
var n=0;
var btn_0 = btn_1 = btn_2 = btn_3 = btn_4 = btn_5 = nil;
var raz_c = nil;
var _fms = nil;

var mfd_stl = setlistener("/sim/signals/fdm-initialized", func {
  setprop("instrumentation/mfd/range-nm",wx_range[wx_index]);
  removelistener(mfd_stl);  
},0,0);

setlistener(fms, func {
    if (getprop(menu2)) {fms_control();cdr_control()}
},0,0);

setlistener(fgc, func {
    if (getprop(menu2)) {fgc_control();cdr_control()}
},0,0);

var set_range = func(inc){
	if (getprop(s_menu)<5 or (getprop(s_menu)==5 and getprop(path,"cdr-tot")==0)){ 
    wx_index += inc;
    if(wx_index>5) wx_index=5;
    if(wx_index<0) wx_index=0;
    setprop("instrumentation/mfd/range-nm",wx_range[wx_index]);
	}
	if (getprop(s_menu) == 5 ) {
		if (getprop(path,cdr[0])) {
			spd_range = getprop("controls/flight/v1");
			spd_range += inc;
      spd_range = math.clamp(100,200);
			setprop("controls/flight/v1",spd_range);
			if (getprop("controls/flight/vr") < spd_range) 
        setprop("controls/flight/vr",spd_range);
			if(getprop("controls/flight/v2") < getprop("controls/flight/vr")+3)
				setprop("controls/flight/v2",getprop("controls/flight/vr")+3);
		}
		if (getprop(path,cdr[1])) {		
			spd_range = getprop("controls/flight/vr");
			spd_range += inc;
      spd_range = math.clamp(100,200);
			setprop("controls/flight/vr",spd_range);
			if (getprop("controls/flight/v1") > spd_range)
				setprop("controls/flight/v1",spd_range);
			if(getprop("controls/flight/v2")< getprop("controls/flight/vr")+4)
				setprop("controls/flight/v2",getprop("controls/flight/vr")+4);
		}
		if (getprop(path,cdr[2])) {		
			spd_range = getprop("controls/flight/v2");
			spd_range += inc;
      spd_range = math.clamp(100,200);
			setprop("controls/flight/v2",spd_range);
			if (getprop("controls/flight/vr") > spd_range-4)
				setprop("controls/flight/vr",spd_range-4);
			if(getprop("controls/flight/vr")< getprop("controls/flight/v1"))
				setprop("controls/flight/v1",getprop("controls/flight/vr"));
		}
		if (getprop(path,cdr[3])) {		
			spd_range = getprop("controls/flight/vref");
			spd_range += inc;
      spd_range = math.clamp(100,250);
			setprop("controls/flight/vref",spd_range);
			if (getprop("controls/flight/va") < spd_range+4)
				setprop("controls/flight/va",spd_range+4);
		}
		if (getprop(path,cdr[4])) {		
			spd_range = getprop("controls/flight/va");
			spd_range += inc;
      spd_range = math.clamp(100,250);
			setprop("controls/flight/va",spd_range);
			if (getprop("controls/flight/vr") > spd_range-4)
				setprop("controls/flight/vr",spd_range-4);
		}
	}
}

var menu = func {
	btn_0 = getprop("instrumentation/mfd/btn0");
	btn_1 = getprop("instrumentation/mfd/btn1");
	btn_2 = getprop("instrumentation/mfd/btn2");
	btn_3 = getprop("instrumentation/mfd/btn3");
	btn_4 = getprop("instrumentation/mfd/btn4");
	btn_5 = getprop("instrumentation/mfd/btn5");
	raz_c = func {foreach (var i;cdr) setprop(path,i,0)}

	if (btn_0) {setprop(s_menu,0);raz_c()}
      ### Menu 1 ###
  if (!getprop(menu2)) { 
    if (btn_1 and getprop(s_menu) == 0) {
	    setprop(s_menu,1);
	    btn_1 = 0;
	    n = 0;
    }

    if (btn_2 and getprop(s_menu) == 0) {
	    setprop(s_menu,2);
	    btn_2 = 0;
	    n = 0;
    }
    if (btn_5 and getprop(s_menu) == 0) {
	    setprop(s_menu,5);
	    btn_5 = 0;
	    n = 0;
    }

    if (getprop(s_menu)==1) {
	    if (getprop(baro)) setprop(path,cdr[0],1);
	    else setprop(path,cdr[0],0);
	    if (getprop(alt_m)) setprop(path,cdr[1],1);
	    else setprop(path,cdr[1],0);

	    if (btn_1) {
		    if (getprop(baro)) {setprop(baro,0);setprop(path,cdr[0],0)}
		    else {setprop(baro,1);setprop(path,cdr[0],1)}				
	    }
	    if (btn_2){
		    if (getprop(alt_m)) {setprop(alt_m,0);setprop(path,cdr[1],0)}
		    else {setprop(alt_m,1);setprop(path,cdr[1],1)}				
	    }
    }

    if (getprop(s_menu)==2) {
	    if (getprop(vor)) setprop(path,cdr[0],1);
	    else setprop(path,cdr[0],0);
	    if (getprop(apt)) setprop(path,cdr[1],1);	
	    else setprop(path,cdr[1],0);
	    if (getprop(fix)) setprop(path,cdr[2],1);
	    else setprop(path,cdr[2],0);
	    if (getprop(traf)) setprop(path,cdr[3],1);
	    else setprop(path,cdr[3],0);

	    if (btn_1) {
			    if (getprop(vor)) {setprop(vor,0);setprop(path,cdr[0],0)}
			    else {setprop(vor,1);setprop(path,cdr[0],1)}				
	    }
	    if (btn_2){
			    if (getprop(apt)) {setprop(apt,0);setprop(path,cdr[1],0)}
			    else {setprop(apt,1);setprop(path,cdr[1],1)}				
	    }
	    if (btn_3){
			    if (getprop(fix)) {setprop(fix,0);setprop(path,cdr[2],0)}
			    else {setprop(fix,1);setprop(path,cdr[2],1)}				
	    }
	    if (btn_4){
		    if (getprop(traf)) {setprop(traf,0);setprop(path,cdr[3],0)}
		    else {
			    setprop(traf,getprop(tcas));
			    setprop(path,cdr[3],getprop(tcas));
		    }				
	    }
	    if (btn_5){
		    if (!getprop(vsd)) setprop(vsd,1);
		    else setprop(vsd,0);
	    }
    }

    if (getprop(s_menu)==5) {
	    if (btn_1) {
		    if (!getprop(path,cdr[0])) {
			    raz_c();
			    setprop(path,cdr[0],1);
		    } else setprop(path,cdr[0],0);
	    }
	    if (btn_2){
		    if (!getprop(path,cdr[1])) {
			    raz_c();
			    setprop(path,cdr[1],1);
		    } else setprop(path,cdr[1],0);
	    }
	    if (btn_3){
		    if (!getprop(path,cdr[2])) {
			    raz_c();
			    setprop(path,cdr[2],1);
		    } else setprop(path,cdr[2],0);
	    }
	    if (btn_4){
		    if (!getprop(path,cdr[3])) {
			    raz_c();
			    setprop(path,cdr[3],1);
		    } else setprop(path,cdr[3],0);
	    }
	    if (btn_5){
		    if (!getprop(path,cdr[4])) {
			    raz_c();
			    setprop(path,cdr[4],1);
		    } else setprop(path,cdr[4],0);
	    }
    }		
  } else {
      ### Menu 2 ###
    fms_control();
    fgc_control();
    if (btn_1) {
      if (left(getprop(fms),3) == "FMS")
        setprop(fms,getprop(fms) == "FMS1" ? "FMS2" : "FMS1");
    }
    if (btn_5) setprop(fgc,getprop(fgc) == "A" ? "B" : "A");
  }
  cdr_control();
} # end of menu

var fms_control = func {
    _fms = left(getprop(fms),3) == "FMS" ? getprop(fms) : nil;
    setprop(path,cdr[5],_fms == "FMS1" ? 1 : 0);
    setprop(path,cdr[6],_fms == "FMS2" ? 1 : 0);
} # end of fms_control

var fgc_control = func {
    setprop(path,cdr[7],getprop(fgc) == "A" ? 1 : 0);
    setprop(path,cdr[8],getprop(fgc) == "B" ? 1 : 0);
} # end of fms_control

var cdr_control = func {
	n = 0;
	foreach (var i;cdr) {
		if(getprop(path,i)) n+=1;
	}								
	if (n == 0) setprop(path,"cdr-tot",0);
	else setprop(path,"cdr-tot",n);
} # end of cdr_control

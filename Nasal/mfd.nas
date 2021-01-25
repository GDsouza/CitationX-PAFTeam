### Citation X ####
### C. Le Moigne (clm76) - 2016  ###

var menu2 = ["instrumentation/mfd/menu2",
            "instrumentation/mfd[1]/menu2"];
var path = ["instrumentation/mfd/",
            "instrumentation/mfd[1]/"];
var s_menu = ["instrumentation/mfd/s-menu",
              "instrumentation/mfd[1]/s-menu"];
var alt_m = ["instrumentation/mfd/alt-meters",
             "instrumentation/mfd[1]/alt-meters"];
var baro = ["instrumentation/mfd/baro-hpa",
           "instrumentation/mfd[1]/baro-hpa"];
var apt = ["instrumentation/mfd/outputs/apt",
           "instrumentation/mfd[1]/outputs/apt"];
var vor = ["instrumentation/mfd/outputs/vor",
           "instrumentation/mfd[1]/outputs/vor"];
var fix = ["instrumentation/mfd/outputs/fix",
           "instrumentation/mfd[1]/outputs/fix"];
var fms = "autopilot/settings/nav-source";
var fgc = "autopilot/settings/fgc";
var yd = "controls/flight/yd";
var traf = ["instrumentation/tcas/tfc",
            "instrumentation/tcas/tfc[1]"];
var tcas = "systems/electrical/outputs/tcas";
var vsd = ["instrumentation/efis/vsd",
           "instrumentation/efis/vsd[1]"];
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
  setprop("instrumentation/mfd[1]/range-nm",wx_range[wx_index]);
  removelistener(mfd_stl);  
},0,0);

setlistener(fms, func {
    if (getprop(menu2[0])) {fms_control(0);cdr_control(0)}
    if (getprop(menu2[1])) {fms_control(1);cdr_control(1)}
},0,0);

setlistener(fgc, func {
    if (getprop(menu2[0])) {fgc_control(0);cdr_control(0)}
    if (getprop(menu2[1])) {fgc_control(1);cdr_control(1)}
},0,0);

var set_range = func(inc,x){
	if (getprop(s_menu[x])<5 or (getprop(s_menu[x])==5 and getprop(path[x],"cdr-tot")==0)){ 
    wx_index += inc;
    if(wx_index>5) {wx_index=5}
    if(wx_index<0) {wx_index=0}
    setprop("instrumentation/mfd["~x~"]/range-nm",wx_range[wx_index]);
	}
	if (getprop(s_menu[x]) == 5 ) {
		if (getprop(path[x],cdr[0])) {
			spd_range = getprop("controls/flight/v1");
			spd_range += inc;
			if(spd_range<100) {spd_range=100}
			if(spd_range>200) {spd_range=200}
			setprop("controls/flight/v1",spd_range);
			if (getprop("controls/flight/vr") < spd_range) {
				setprop("controls/flight/vr",spd_range);
			}
			if(getprop("controls/flight/v2")< getprop("controls/flight/vr")+3) {
				setprop("controls/flight/v2",getprop("controls/flight/vr")+3);
			}
		}
		if (getprop(path[x],cdr[1])) {		
			spd_range = getprop("controls/flight/vr");
			spd_range += inc;
			if(spd_range<100) {spd_range=100}
			if(spd_range>200) {spd_range=200}
			setprop("controls/flight/vr",spd_range);
			if (getprop("controls/flight/v1") > spd_range) {
				setprop("controls/flight/v1",spd_range);
			}
			if(getprop("controls/flight/v2")< getprop("controls/flight/vr")+4) {
				setprop("controls/flight/v2",getprop("controls/flight/vr")+4);
			}
		}
		if (getprop(path[x],cdr[2])) {		
			spd_range = getprop("controls/flight/v2");
			spd_range += inc;
			if(spd_range<100) {spd_range=100}
			if(spd_range>200) {spd_range=200}
			setprop("controls/flight/v2",spd_range);
			if (getprop("controls/flight/vr") > spd_range-4) {
				setprop("controls/flight/vr",spd_range-4);
			}
			if(getprop("controls/flight/vr")< getprop("controls/flight/v1")) {
				setprop("controls/flight/v1",getprop("controls/flight/vr"));
			}
		}
		if (getprop(path[x],cdr[3])) {		
			spd_range = getprop("controls/flight/vref");
			spd_range += inc;
			if(spd_range<100) {spd_range=100}
			if(spd_range>250) {spd_range=250}
			setprop("controls/flight/vref",spd_range);
			if (getprop("controls/flight/va") < spd_range+4) {
				setprop("controls/flight/va",spd_range+4);
			}
		}
		if (getprop(path[x],cdr[4])) {		
			spd_range = getprop("controls/flight/va");
			spd_range += inc;
			if(spd_range<100) {spd_range=100}
			if(spd_range>250) {spd_range=250}
			setprop("controls/flight/va",spd_range);
			if (getprop("controls/flight/vr") > spd_range-4) {
				setprop("controls/flight/vr",spd_range-4);
			}
		}
	}
}

var menu = func(x) {
	btn_0 = getprop("instrumentation/mfd["~x~"]/btn0");
	btn_1 = getprop("instrumentation/mfd["~x~"]/btn1");
	btn_2 = getprop("instrumentation/mfd["~x~"]/btn2");
	btn_3 = getprop("instrumentation/mfd["~x~"]/btn3");
	btn_4 = getprop("instrumentation/mfd["~x~"]/btn4");
	btn_5 = getprop("instrumentation/mfd["~x~"]/btn5");
	raz_c = func {foreach (var i;cdr) setprop(path[x],i,0)}

	if (btn_0) {setprop(s_menu[x],0);raz_c()}
      ### Menu 1 ###
  if (!getprop(menu2[x])) { 
    if (btn_1 and getprop(s_menu[x]) == 0) {
	    setprop(s_menu[x],1);
	    btn_1 = 0;
	    n = 0;
    }

    if (btn_2 and getprop(s_menu[x]) == 0) {
	    setprop(s_menu[x],2);
	    btn_2 = 0;
	    n = 0;
    }
    if (btn_5 and getprop(s_menu[x]) == 0) {
	    setprop(s_menu[x],5);
	    btn_5 = 0;
	    n = 0;
    }

    if (getprop(s_menu[x])==1) {
	    if (getprop(baro[x])) setprop(path[x],cdr[0],1);
	    else setprop(path[x],cdr[0],0);
	    if (getprop(alt_m[x])) setprop(path[x],cdr[1],1);
	    else setprop(path[x],cdr[1],0);

	    if (btn_1) {
		    if (getprop(baro[x])) {setprop(baro[x],0);setprop(path[x],cdr[0],0)}
		    else {setprop(baro[x],1);setprop(path[x],cdr[0],1)}				
	    }
	    if (btn_2){
		    if (getprop(alt_m[x])) {setprop(alt_m[x],0);setprop(path[x],cdr[1],0)}
		    else {setprop(alt_m[x],1);setprop(path[x],cdr[1],1)}				
	    }
    }

    if (getprop(s_menu[x])==2) {
	    if (getprop(vor[x])) setprop(path[x],cdr[0],1);
	    else setprop(path[x],cdr[0],0);
	    if (getprop(apt[x])) setprop(path[x],cdr[1],1);	
	    else setprop(path[x],cdr[1],0);
	    if (getprop(fix[x])) setprop(path[x],cdr[2],1);
	    else setprop(path[x],cdr[2],0);
	    if (getprop(traf[x])) setprop(path[x],cdr[3],1);
	    else setprop(path[x],cdr[3],0);

	    if (btn_1) {
			    if (getprop(vor[x])) {setprop(vor[x],0);setprop(path[x],cdr[0],0)}
			    else {setprop(vor[x],1);setprop(path[x],cdr[0],1)}				
	    }
	    if (btn_2){
			    if (getprop(apt[x])) {setprop(apt[x],0);setprop(path[x],cdr[1],0)}
			    else {setprop(apt[x],1);setprop(path[x],cdr[1],1)}				
	    }
	    if (btn_3){
			    if (getprop(fix[x])) {setprop(fix[x],0);setprop(path[x],cdr[2],0)}
			    else {setprop(fix[x],1);setprop(path[x],cdr[2],1)}				
	    }
	    if (btn_4){
		    if (getprop(traf[x])) {setprop(traf[x],0);setprop(path[x],cdr[3],0)}
		    else {
			    setprop(traf[x],getprop(tcas));
			    setprop(path[x],cdr[3],getprop(tcas));
		    }				
	    }
	    if (btn_5){
		    if (!getprop(vsd[x])) {
			    setprop(vsd[x],1);
		    } else setprop(vsd[x],0);
	    }
    }

    if (getprop(s_menu[x])==5) {
	    if (btn_1) {
		    if (!getprop(path[x],cdr[0])) {
			    raz_c();
			    setprop(path[x],cdr[0],1);
		    } else setprop(path[x],cdr[0],0);
	    }
	    if (btn_2){
		    if (!getprop(path[x],cdr[1])) {
			    raz_c();
			    setprop(path[x],cdr[1],1);
		    } else {setprop(path[x],cdr[1],0)}
	    }
	    if (btn_3){
		    if (!getprop(path[x],cdr[2])) {
			    raz_c();
			    setprop(path[x],cdr[2],1);
		    } else setprop(path[x],cdr[2],0);
	    }
	    if (btn_4){
		    if (!getprop(path[x],cdr[3])) {
			    raz_c();
			    setprop(path[x],cdr[3],1);
		    } else setprop(path[x],cdr[3],0);
	    }
	    if (btn_5){
		    if (!getprop(path[x],cdr[4])) {
			    raz_c();
			    setprop(path[x],cdr[4],1);
		    } else setprop(path[x],cdr[4],0);
	    }
    }		
  } else {
      ### Menu 2 ###
    fms_control(x);
    fgc_control(x);
    if (btn_1) {
      if (left(getprop(fms),3) == "FMS") {
        setprop(fms,getprop(fms) == "FMS1" ? "FMS2" : "FMS1");
      }
    }
    if (btn_5) setprop(fgc,getprop(fgc) == "A" ? "B" : "A");
  }
  cdr_control(x);
} # end of menu

var fms_control = func(x) {
    _fms = left(getprop(fms),3) == "FMS" ? getprop(fms) : nil;
    setprop(path[x],cdr[5],_fms == "FMS1" ? 1 : 0);
    setprop(path[x],cdr[6],_fms == "FMS2" ? 1 : 0);
} # end of fms_control

var fgc_control = func(x) {
    setprop(path[x],cdr[7],getprop(fgc) == "A" ? 1 : 0);
    setprop(path[x],cdr[8],getprop(fgc) == "B" ? 1 : 0);
} # end of fms_control

var cdr_control = func(x) {
	n = 0;
	foreach (var i;cdr) {
		if(getprop(path[x],i)) n+=1;
	}								
	if (n == 0) setprop(path[x],"cdr-tot",0);
	else setprop(path[x],"cdr-tot",n);
} # end of cdr_control

### Citation X ####
### C. Le Moigne (clm76) - 2016  ###


var menu_num = "instrumentation/primus2000/mfd/menu_num";
var path = "instrumentation/primus2000/mfd/";
var s_menu = "instrumentation/primus2000/mfd/s-menu";
var cdr = ["cdr0","cdr1","cdr2","cdr3","cdr4"];
var wx_range=[10,20,40,80,160,320];
var wx_index=1;
var spd_range = 0;
var n=0;

setlistener("/sim/signals/fdm-initialized", func {
    setprop("instrumentation/efis/inputs/range-nm",wx_range[wx_index]);
},0,0);

var set_range = func(dir){
	if (getprop(s_menu)<5 or (getprop(s_menu)==5 and getprop(path,"cdr-tot")==0)){ 
    wx_index+=dir;
    if(wx_index>5) {wx_index=5}
    if(wx_index<0) {wx_index=0}
    setprop("instrumentation/efis/inputs/range-nm",wx_range[wx_index]);
	}
	if (getprop(s_menu) == 5 ) {
		if (getprop(path,cdr[0])) {
			spd_range = getprop("controls/flight/v1");
			spd_range+=dir;
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
		if (getprop(path,cdr[1])) {		
			spd_range = getprop("controls/flight/vr");
			spd_range+=dir;
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
		if (getprop(path,cdr[2])) {		
			spd_range = getprop("controls/flight/v2");
			spd_range+=dir;
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
		if (getprop(path,cdr[3])) {		
			spd_range = getprop("controls/flight/vref");
			spd_range+=dir;
			if(spd_range<100) {spd_range=100}
			if(spd_range>250) {spd_range=250}
			setprop("controls/flight/vref",spd_range);
			if (getprop("controls/flight/va") < spd_range+4) {
				setprop("controls/flight/va",spd_range+4);
			}
		}
		if (getprop(path,cdr[4])) {		
			spd_range = getprop("controls/flight/va");
			spd_range+=dir;
			if(spd_range<100) {spd_range=100}
			if(spd_range>250) {spd_range=250}
			setprop("controls/flight/va",spd_range);
			if (getprop("controls/flight/vr") > spd_range-4) {
				setprop("controls/flight/vr",spd_range-4);
			}
		}
	}
}

var menu = func {
	var apt = "instrumentation/efis/inputs/arpt";
	var vor = "instrumentation/efis/inputs/sta";
	var fix = "instrumentation/efis/inputs/wpt";
	var tcas = "instrumentation/primus2000/dc840/tcas";
	var tcas_mode = "instrumentation/tcas/inputs/mode";
	var vsd = 
	var btn_0 = getprop("instrumentation/primus2000/mfd/btn0");
	var btn_1 = getprop("instrumentation/primus2000/mfd/btn1");
	var btn_2 = getprop("instrumentation/primus2000/mfd/btn2");
	var btn_3 = getprop("instrumentation/primus2000/mfd/btn3");
	var btn_4 = getprop("instrumentation/primus2000/mfd/btn4");
	var btn_5 = getprop("instrumentation/primus2000/mfd/btn5");
	var raz_c = func{
		foreach (var i;cdr) {setprop(path,i,0)}
	}		

	if (!getprop(menu_num)) {
		if (btn_0) {setprop(s_menu,0);raz_c()}
		if (btn_2 and getprop(s_menu)==0) {
			setprop(s_menu,2);
			btn_2=0;
			n=0;
		}
		if (btn_5 and getprop(s_menu)==0) {
			setprop(s_menu,5);
			btn_5 = 0;
			n=0;
		}

		if (getprop(s_menu)==2) {
			if (getprop(vor)) {setprop(path,cdr[0],1)}	
			else {setprop(path,cdr[0],0)}
			if (getprop(apt)) {setprop(path,cdr[1],1)}	
			else {setprop(path,cdr[1],0)}
			if (getprop(fix)) {setprop(path,cdr[2],1)}	
			else {setprop(path,cdr[2],0)}
			if (getprop(tcas)) {setprop(path,cdr[3],1)}	
			else {setprop(path,cdr[3],0)}

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
				if (getprop(tcas)) {
					setprop(tcas,0);
					setprop(tcas_mode,0);
					setprop(path,cdr[3],0);
				}
				else {
					setprop(tcas,1);
					setprop(tcas_mode,3);
					setprop(path,cdr[3],1);
				}				
			}
			if (btn_5){
				if (!getprop("instrumentation/efis/inputs/vsd")) {
					setprop("instrumentation/efis/inputs/vsd",1);
				} else {setprop("instrumentation/efis/inputs/vsd",0)}
			}
		}

		if (getprop(s_menu)==5) {
			if (btn_1) {
				if (getprop(path,cdr[0])==0 ) {
					raz_c();
					setprop(path,cdr[0],1);
				} else {setprop(path,cdr[0],0)}
			}
			if (btn_2){
				if (getprop(path,cdr[1])==0 ) {
					raz_c();
					setprop(path,cdr[1],1);
				} else {setprop(path,cdr[1],0)}
			}
			if (btn_3){
				if (getprop(path,cdr[2])==0 ) {
					raz_c();
					setprop(path,cdr[2],1);
				} else {setprop(path,cdr[2],0)}
			}
			if (btn_4){
				if (getprop(path,cdr[3])==0 ) {
					raz_c();
					setprop(path,cdr[3],1);
				} else {setprop(path,cdr[3],0)}
			}
			if (btn_5){
				if (getprop(path,cdr[4])==0 ) {
					raz_c();
					setprop(path,cdr[4],1);
				} else {setprop(path,cdr[4],0)}
			}
		}		
		n=0;
		foreach (var i;cdr) {
			if(getprop(path,i)) {n+=1}
		}								
		if (n==0) {setprop(path,"cdr-tot",0)}
			else {setprop(path,"cdr-tot",n)}
	}
}


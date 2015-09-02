### Display CduStart ###
### C. LE MOIGNE (clm76) - 2015 ###

var navIdent = func {
	var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
	var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};

		page = "NAV IDENT     1/1";
		DspL.line1l = "DATE";
		DspL.line2l = getprop("instrumentation/cdu/date");
		DspL.line3l = "TIME";
		DspL.line4l = getprop("instrumentation/cdu/time");
		DspL.line5l = "SW";
		DspL.line6l = "NZ5.4";
		DspL.line7l = "< MAINTENANCE";
		DspR.line1r = "ACTIVE NDB";
		DspR.line2r = "01 JAN - 31 DEC";
		DspR.line3r = "";
		DspR.line4r = "01 JAN - 31 DEC";
		DspR.line5r = "NDB V4.00";
		DspR.line6r = "WORLD 2-01";
		DspR.line7r = "POS INIT >";
		setprop("instrumentation/cdu/nbpage",0);
	cdu.DspSet(page,DspL,DspR);
}

var posInit = func(my_lat,my_long,dep_airport,dep_rwy) {
	var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
	var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		page = "POSITION INIT    1/1";
		DspL.line1l = "LAST POS";
		DspR.line2r = "LOAD";
		DspR.line4r = "LOAD";
		DspR.line6r = "LOAD";
		if (getprop("instrumentation/cdu/load_pos1") == 1) {		
			DspL.line2l = my_lat~" "~my_long;
			DspR.line1r = "(LOADED)";
			DspR.line2r = "";
		} else {
				DspL.line2l = "";
			}
		if (getprop("instrumentation/cdu/load_pos2") == 1) {		
			DspL.line3l = dep_airport ~ "-" ~ dep_rwy ~ "   REF WPT";
			DspR.line3r = "(LOADED)";
			DspR.line4r = "";
		} else {
				DspL.line3l = "REF WPT";
			}
			DspL.line4l = "---*--.-  ---*--.-";
			DspL.line5l = "GPS 1 POS";
		if (getprop("instrumentation/cdu/load_pos3") == 1) {		
			DspL.line6l = my_lat~" "~my_long;
			DspR.line5r = "(LOADED)";
			DspR.line6r = "";
		} else {
				DspL.line6l = "";
			}
		DspL.line7l = "< POS SENSORS";
		if (getprop("instrumentation/cdu/load_pos1") == 1 and
			getprop("instrumentation/cdu/load_pos2") == 1 and
			getprop("instrumentation/cdu/load_pos3") == 1) {
			DspR.line7r = "FLT PLAN >";
			setprop("/instrumentation/cdu/pos-init",1);
		} else {	
		  DspR.line7r = "";
		}
	cdu.DspSet(page,DspL,DspR);
}


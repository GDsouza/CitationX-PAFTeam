### Display CduStart ###
### C. LE MOIGNE (clm76) - 2015 ###

var navIdent = func {
		page = "NAV IDENT     1/1";
		line1l = "DATE";
		line2l = getprop("instrumentation/cdu/date");
		line3l = "TIME";
		line4l = getprop("instrumentation/cdu/time");
		line5l = "SW";
		line6l = "NZ5.4";
		line7l = "< MAINTENANCE";
		line1r = "ACTIVE NDB";
		line2r = "01 JAN - 31 DEC";
		line3r = "";
		line4r = "01 JAN - 31 DEC";
		line5r = "NDB V4.00";
		line6r = "WORLD 2-01";
		line7r = "POS INIT >";
	setprop("instrumentation/cdu/page",page);
	setprop("instrumentation/cdu/L[0]",line1l);
	setprop("instrumentation/cdu/L[1]",line2l);
	setprop("instrumentation/cdu/L[2]",line3l);
	setprop("instrumentation/cdu/L[3]",line4l);
	setprop("instrumentation/cdu/L[4]",line5l);
	setprop("instrumentation/cdu/L[5]",line6l);
	setprop("instrumentation/cdu/L[6]",line7l);
	setprop("instrumentation/cdu/R[0]",line1r);
	setprop("instrumentation/cdu/R[1]",line2r);
	setprop("instrumentation/cdu/R[2]",line3r);
	setprop("instrumentation/cdu/R[3]",line4r);
	setprop("instrumentation/cdu/R[4]",line5r);
	setprop("instrumentation/cdu/R[5]",line6r);
	setprop("instrumentation/cdu/R[6]",line7r);
}

var posInit = func(my_lat,my_long,dep_airport,dep_rwy) {
		line1l=line2l=line3l=line4l=line5l=line6l=line7l=line8l="";
		line1r=line2r=line3r=line4r=line5r=line6r=line7r=line8r="";
		page = "POSITION INIT    1/1";
		line1l = "LAST POS";
		line2r = "LOAD";
		line4r = "LOAD";
		line6r = "LOAD";
		if (getprop("instrumentation/cdu/load_pos1") == 1) {		
			line2l = my_lat~" "~my_long;
			line1r = "(LOADED)";
			line2r = "";
		} else {
				line2l = "";
			}
		if (getprop("instrumentation/cdu/load_pos2") == 1) {		
			line3l = dep_airport ~ "-" ~ dep_rwy ~ "   REF WPT";
			line3r = "(LOADED)";
			line4r = "";
		} else {
				line3l = "REF WPT";
			}
			line4l = "---*--.-  ---*--.-";
			line5l = "GPS 1 POS";
		if (getprop("instrumentation/cdu/load_pos3") == 1) {		
			line6l = my_lat~" "~my_long;
			line5r = "(LOADED)";
			line6r = "";
		} else {
				line6l = "";
			}
		line7l = "< POS SENSORS";
		if (getprop("instrumentation/cdu/load_pos1") == 1 and
			getprop("instrumentation/cdu/load_pos2") == 1 and
			getprop("instrumentation/cdu/load_pos3") == 1) {
			line7r = "FLT PLAN >";
			setprop("/instrumentation/cdu/pos-init",1);
		} else {	
		  line7r = "";
		}
	setprop("instrumentation/cdu/page",page);
	setprop("instrumentation/cdu/L[0]",line1l);
	setprop("instrumentation/cdu/L[1]",line2l);
	setprop("instrumentation/cdu/L[2]",line3l);
	setprop("instrumentation/cdu/L[3]",line4l);
	setprop("instrumentation/cdu/L[4]",line5l);
	setprop("instrumentation/cdu/L[5]",line6l);
	setprop("instrumentation/cdu/L[6]",line7l);
	setprop("instrumentation/cdu/R[0]",line1r);
	setprop("instrumentation/cdu/R[1]",line2r);
	setprop("instrumentation/cdu/R[2]",line3r);
	setprop("instrumentation/cdu/R[3]",line4r);
	setprop("instrumentation/cdu/R[4]",line5r);
	setprop("instrumentation/cdu/R[5]",line6r);
	setprop("instrumentation/cdu/R[6]",line7r);
}


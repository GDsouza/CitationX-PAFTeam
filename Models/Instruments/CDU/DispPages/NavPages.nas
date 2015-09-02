### Display Nav Pages ###
### C. LE MOIGNE (clm76) - 2015 ###

var navPage_0 = func() {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
			page = "NAV INDEX     1 / 1";
			DspL.line1l = "< FPL LIST";
			DspL.line2l = "";
			DspL.line3l = "< WPT LIST";
			DspL.line4l = "";
			DspL.line5l = "< DEPARTURE";
			DspL.line6l = "";
			DspL.line7l = "< IDENT";
			DspR.line1r = "FPL SEL >";
			DspR.line2r = "";
			DspR.line3r = "DATA BASE >";
			DspR.line4r = "";
			DspR.line5r = "ARRIVAL >";
			DspR.line6r = "";
			DspR.line7r = "FLT-PLAN >";
	cdu.DspSet(page,DspL,DspR);
}

var navPage_Dept = func(dep_airport,dep_rwy,my_lat,my_long) {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
			page = "DEPARTURE   1 / 1";
			DspL.line1l = "WAYPOINT";
			DspL.line2l = dep_airport;
			DspL.line3l = "NAME";
			DspL.line4l = string.uc(getprop("autopilot/route-manager/departure/name"));
			DspL.line5l = "LAT - LON";
			DspL.line6l = my_lat~" - "~my_long;
			DspL.line7l = "< SIDS";
			DspR.line1r = "TYPE";
			DspR.line2r = "AIRPORT";
			DspR.line3r = "";
			DspR.line4r = "";
			DspR.line5r = "RUNWAY";
			DspR.line6r = dep_rwy;
			DspR.line7r = "";
	cdu.DspSet(page,DspL,DspR);
}

var navPage_Dest = func(dest_airport,dest_rwy,my_lat,my_long) {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
			page = "DESTINATION   1 / 1";
			DspL.line1l = "WAYPOINT";
			DspL.line2l = dest_airport;
			DspL.line3l = "NAME";
			DspL.line4l = string.uc(getprop("autopilot/route-manager/destination/name"));
			DspL.line5l = "LAT - LON";
			DspL.line6l = my_lat~" - "~my_long;
			DspL.line7l = "< STARS";
			DspR.line1r = "TYPE";
			DspR.line2r = "AIRPORT";
			DspR.line3r = "";
			DspR.line4r = "";
			DspR.line5r = "RUNWAY";
			DspR.line6r = dest_rwy;
			DspR.line7r = "APPROACH >";
	cdu.DspSet(page,DspL,DspR);
}


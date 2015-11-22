### Display Nav Pages ###
### C. LE MOIGNE (clm76) - 2015 ###

var navPage_0 = func() {
	var Dsp = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
			page = "NAV INDEX     1 / 1";
			Dsp.line1l = "< FPL LIST";
			Dsp.line2l = "";
			Dsp.line3l = "< WPT LIST";
			Dsp.line4l = "";
			Dsp.line5l = "< DEPARTURE";
			Dsp.line6l = "";
			Dsp.line7l = "< IDENT";
			Dsp.line1r = "FPL SEL >";
			Dsp.line2r = "";
			Dsp.line3r = "DATA BASE >";
			Dsp.line4r = "";
			Dsp.line5r = "ARRIVAL >";
			Dsp.line6r = "";
			Dsp.line7r = "FLT-PLAN >";
	cdu.DspSet(page,Dsp);
}

var navPage_Dept = func(dep_airport,dep_rwy,my_lat,my_long) {
	var Dsp = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
			page = "DEPARTURE   1 / 1";
			Dsp.line1l = "WAYPOINT";
			Dsp.line2l = dep_airport;
			Dsp.line3l = "NAME";
			Dsp.line4l = string.uc(getprop("autopilot/route-manager/departure/name"));
			Dsp.line5l = "LAT - LON";
			Dsp.line6l = my_lat~" - "~my_long;
			Dsp.line7l = "< SIDS";
			Dsp.line1r = "TYPE";
			Dsp.line2r = "AIRPORT";
			Dsp.line3r = "";
			Dsp.line4r = "";
			Dsp.line5r = "RUNWAY";
			Dsp.line6r = dep_rwy;
			Dsp.line7r = "";
	cdu.DspSet(page,Dsp);
}

var navPage_Dest = func(dest_airport,dest_rwy,my_lat,my_long) {
	var Dsp = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
			page = "DESTINATION   1 / 1";
			Dsp.line1l = "WAYPOINT";
			Dsp.line2l = dest_airport;
			Dsp.line3l = "NAME";
			Dsp.line4l = string.uc(getprop("autopilot/route-manager/destination/name"));
			Dsp.line5l = "LAT - LON";
			Dsp.line6l = my_lat~" - "~my_long;
			Dsp.line7l = "< STARS";
			Dsp.line1r = "TYPE";
			Dsp.line2r = "AIRPORT";
			Dsp.line3r = "";
			Dsp.line4r = "";
			Dsp.line5r = "RUNWAY";
			Dsp.line6r = dest_rwy;
			Dsp.line7r = "APPROACH >";
	cdu.DspSet(page,Dsp);
}


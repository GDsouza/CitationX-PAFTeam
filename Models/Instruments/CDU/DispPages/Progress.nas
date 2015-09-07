### Display Flightplan ###
### C. LE MOIGNE (clm76) - 2015 ###

var progPage_0 = func(dest_airport,marker) {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var ind = 0;
		var path = "autopilot/route-manager/route/wp[";
		var leg = "   "~sprintf("%3i",getprop(path~ind~"]/leg-distance-nm"));
			page = "PROGRESS     1 / 2";
			DspL.line1l = " TO          DIST";
			DspL.line2l = marker~leg;
			DspL.line3l = "DEST";
			DspL.line4l = dest_airport~sprintf("     %3i",getprop("autopilot/route-manager/distance-remaining-nm"));
			DspL.line5l = "";
			DspL.line6l = "";
			DspL.line7l = "< AIR DATA";
			DspR.line1r = " ETE         FUEL ";
			DspR.line2r = substr(getprop("/autopilot/internal/nav-ttw"),4)~"      "~sprintf("%3i",getprop("consumables/fuel/total-fuel-lbs"));
			DspR.line3r = ""; 
			DspR.line4r = "";
			DspR.line5r = " ";
			DspR.line6r = "";
			DspR.line7r = "FLT SUM >";
	cdu.DspSet(page,DspL,DspR);
}


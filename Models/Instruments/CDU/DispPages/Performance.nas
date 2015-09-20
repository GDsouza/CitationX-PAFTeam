### Display Performances Data ###
### C. LE MOIGNE (clm76) - 2015 ###

var perfPage_0 = func() {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
			page = "PERFORMANCE INIT  1 / 3";
			DspL.line1l = "";
			DspL.line2l = "";
			DspL.line3l = "  ACFT TYPE";
			DspL.line4l = string.uc(getprop("sim/description"));
			DspL.line5l = "";
			DspL.line6l = "";
			DspL.line7l = "< FLT PLAN";
			DspR.line1r = "";
			DspR.line2r = "";
			DspR.line3r = "TAIL #";
			DspR.line4r = string.uc(getprop("sim/multiplay/callsign"));
			DspR.line5r = "";
			DspR.line6r = "";
			DspR.line7r = "NEXT PAGE >";
	cdu.DspSet(page,DspL,DspR);
}

var perfPage_1 = func() {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var ClimbSpeed_kt = getprop("autopilot/settings/climb-speed-kt");
		var ClimbSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/climb-speed-kt")*0.0015);
		var DescSpeed_kt = getprop("autopilot/settings/descent-speed-kt");
		var DescSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/descent-speed-kt")*0.0015);
		var CruiseSpeed_kt = getprop("autopilot/route-manager/cruise/speed-kts");
		var CruiseSpeed_mc = sprintf("%.2f",getprop("autopilot/route-manager/cruise/speed-mach"));
		var Cruise_alt = getprop("autopilot/settings/asel");

			page = "PERFORMANCE INIT  2 / 3";
			DspL.line1l = " CLIMB";
			DspL.line2l = ClimbSpeed_kt~" / "~ClimbSpeed_mc;
			DspL.line3l = " CRUISE";
			DspL.line4l = CruiseSpeed_kt~" / "~CruiseSpeed_mc;
			DspL.line5l = " DESCENT";
			DspL.line6l = DescSpeed_kt~" / "~DescSpeed_mc;
			DspL.line7l = "< DEP/APP SPD";
			DspR.line1r = "";
			DspR.line2r = "";
			DspR.line3r = "<---------> ALTITUDE >";
			DspR.line4r = "FL "~Cruise_alt;
			DspR.line5r = "";
			DspR.line6r = "";
			DspR.line7r = "";
	cdu.DspSet(page,DspL,DspR);
}

var perfPage_2 = func() {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var DepSpeed = getprop("autopilot/settings/dep-speed-kt");
		var Agl = getprop("autopilot/settings/dep-agl-limit-ft");
		var Nm = sprintf("%.1f",getprop("autopilot/settings/dep-limit-nm"));
			page = "DEPARTURE SPEED  1 / 1";
			DspL.line1l = " SPEED LIMIT";
			DspL.line2l = DepSpeed~"";
			DspL.line3l = " AGL <-------- LIMIT --------> NM";
			DspL.line4l = Agl~"";
			DspL.line5l = "";
			DspL.line6l = "";
			DspL.line7l = "< APP SPD";
			DspR.line1r = "";
			DspR.line2r = "";
			DspR.line3r = "";
			DspR.line4r = Nm~"      ";
			DspR.line5r = "";
			DspR.line6r = "";
			DspR.line7r = "RETURN > ";
	cdu.DspSet(page,DspL,DspR);
}

var perfPage_3 = func() {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var AppSpeed = getprop("autopilot/settings/app-speed-kt");
		var DistToDest = getprop("autopilot/settings/dist-to-dest-nm");
			page = "APPROACH SPEED  1 / 2";
			DspL.line1l = " SPEED";
			DspL.line2l = AppSpeed~"";
			DspL.line3l = " DIST TO DESTINATION";
			DspL.line4l = DistToDest~"";
			DspL.line5l = " FIRST APP WPT";
			DspL.line6l = "YES";
			DspL.line7l = "< NEXT PAGE";
			DspR.line1r = "";
			DspR.line2r = "";
			DspR.line3r = "";
			DspR.line4r = "";
			DspR.line5r = "";
			DspR.line6r = "";
			DspR.line7r = "RETURN > ";
	cdu.DspSet(page,DspL,DspR);
}

var perfPage_4 = func() {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var AppSpeed5 = getprop("autopilot/settings/app5-speed-kt");
		var AppSpeed15 = getprop("autopilot/settings/app15-speed-kt");
		var AppSpeed39 = getprop("autopilot/settings/app39-speed-kt");
			page = "APPROACH SPEED  2 / 2";
			DspL.line1l = " FLAPS 5";
			DspL.line2l = AppSpeed5~"";
			DspL.line3l = " FLAPS 15";
			DspL.line4l = AppSpeed15~"";
			DspL.line5l = " FLAPS 39";
			DspL.line6l = AppSpeed39~"";
			DspL.line7l = "< NEXT PAGE";
			DspR.line1r = "";
			DspR.line2r = "";
			DspR.line3r = "";
			DspR.line4r = "";
			DspR.line5r = "";
			DspR.line6r = "";
			DspR.line7r = "RETURN > ";
	cdu.DspSet(page,DspL,DspR);
}

var perfPage_5 = func() {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var Wfuel = sprintf("%3i", math.ceil(getprop("consumables/fuel/total-fuel-lbs")));
		var Wcrew = getprop("sim/weight[0]/weight-lb");
		var Wpass = getprop("sim/weight[1]/weight-lb");
		var Wcarg = getprop("sim/weight[2]/weight-lb");
			page = "PERFORMANCE INIT  3 / 3";
			DspL.line1l = " BOW";
			DspL.line2l = "21700";
			DspL.line3l = " FUEL";
			DspL.line4l = Wfuel;
			DspL.line5l = " CARGO";
			DspL.line6l = Wcarg;
			DspL.line7l = "";
			DspR.line1r = "PASS/CREW LBS  ";
			DspR.line2r = int(Wpass/170) + int(Wcrew/170) ~" / 170";
			DspR.line3r = "PASS WT  ";
			DspR.line4r = sprintf("%3i",Wpass + Wcrew);
			DspR.line5r = "GROSS WT  ";
			DspR.line6r = sprintf("%3i",21700 + Wfuel + Wcrew + Wpass + Wcarg);
			DspR.line7r = "RETURN >";
	cdu.DspSet(page,DspL,DspR);
}


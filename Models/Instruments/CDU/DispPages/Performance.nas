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
		var CDspeed_kt = getprop("autopilot/settings/target-speed-kt");
		var CDspeed_mc = sprintf("%.2f",getprop("autopilot/settings/target-speed-mach"));
		var CRspeed_kt = getprop("autopilot/route-manager/cruise/speed-kts");
		var CRspeed_mc = sprintf("%.2f",getprop("autopilot/route-manager/cruise/speed-mach"));
			page = "PERFORMANCE INIT  2 / 3";
			DspL.line1l = " CLIMB";
			DspL.line2l = CDspeed_kt~" / "~CDspeed_mc;
			DspL.line3l = " CRUISE";
			DspL.line4l = CRspeed_kt~" / "~CRspeed_mc;
			DspL.line5l = " DESCENT";
			DspL.line6l = CDspeed_kt~" / "~CDspeed_mc;
			DspL.line7l = "";
			DspR.line1r = "";
			DspR.line2r = "";
			DspR.line3r = "";
			DspR.line4r = "";
			DspR.line5r = "";
			DspR.line6r = "";
			DspR.line7r = "NEXT >";
	cdu.DspSet(page,DspL,DspR);
}

var perfPage_2 = func() {
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
			DspR.line1r = "PASS/CREW LBS ";
			DspR.line2r = int(Wpass/170) + int(Wcrew/170) ~" / 170";
			DspR.line3r = "PASS WT ";
			DspR.line4r = sprintf("%3i",Wpass + Wcrew);
			DspR.line5r = "GROSS WT ";
			DspR.line6r = sprintf("%3i",21700 + Wfuel + Wcrew + Wpass + Wcarg);
			DspR.line7r = "RETURN >";
	cdu.DspSet(page,DspL,DspR);
}


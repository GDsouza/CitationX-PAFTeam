### Display Flightplan ###
### C. LE MOIGNE (clm76) - 2015 ###

var fltPlan_0 = func(dep_airport,dep_rwy,dest_airport,dest_rwy) {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
			page = "ACTIVE FLT PLAN     1 / 1";
			DspL.line1l = " ORIGIN / ETD";
			DspL.line2l = "----";
			if (dep_airport != "") {
				DspL.line2l = dep_airport ~" "~ dep_rwy;
			}
			DspL.line3l = "< LOAD FPL";
			DspL.line4l = "";
			DspL.line5l = "     RECALL OR CREATE";
			DspL.line6l = "       FPL NAMED";
			DspL.line7l = "< FPL LIST";
			DspR.line1r = "";
			DspR.line2r = "";
			DspR.line3r = "DEST  ";
			DspR.line4r = "----";
			if (dest_airport != "") {
				DspR.line4r = dest_airport ~" "~ dest_rwy;
			}
			DspR.line5r = "";
			DspR.line6r = "---------";
			DspR.line7r = "PERF INIT >";
	cdu.DspSet(page,DspL,DspR);
}

var fltPlan_1 = func(dep_airport,dep_rwy,dest_airport,dest_rwy,num,flt_closed,marker) {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var rep = "";
		var path = "autopilot/route-manager/route/wp[";
		var legb = "]/leg-bearing-true-deg";
		var legd = "]/leg-distance-nm";
		var spd_kt = getprop("/autopilot/settings/target-speed-kt");
		var spd_mc = sprintf("%.2f",getprop("/autopilot/settings/target-speed-mach"));		
			page = "ACTIVE FLT PLAN     1 / 5";
			DspL.line1l = " ORIGIN / ETD";
			DspL.line2l = "----";
			DspL.line3l = " VIA TO";
			DspL.line4l = "----";
			DspL.line5l = " VIA TO";
			DspL.line6l = "----";
			DspL.line7l = "< DEPARTURE";
			DspR.line1r = "SPD CMD  ";		
			DspR.line2r = spd_kt~" / "~spd_mc;			
			DspR.line5r = "DEST  ";
			DspR.line7r = "ARRIVAL >";
			if (dest_airport != "") {
				DspR.line6r = dest_airport~" "~ dest_rwy;
			}
			if (dep_airport != "") {
				var ind = 0;
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				DspL.line2l = dep_airport ~" "~ dep_rwy~rep;
			}
			if (num == 2 and flt_closed == 1) {
				var ind = 1;
				DspL.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				DspL.line4l = dest_airport~" "~ dest_rwy;
			}	else if (num >2) {
				var ind = 1;
				DspL.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
					if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
					else {rep=""}
				DspL.line4l = getprop(path~ind~"]/id")~rep;	
				DspR.line3r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					DspR.line3r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				DspR.line4r = spd_kt~" / "~spd_mc;
			}
			if (num == 3 and flt_closed == 1) {
				var ind = 2;
				DspL.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				DspL.line6l = dest_airport~" "~ dest_rwy;
			} else if (num > 3 or (num == 3 and dest_airport == "")) {
				var ind = 2;
				DspL.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				DspL.line6l = getprop(path~ind~"]/id")~rep;
				DspR.line5r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					DspR.line5r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				DspR.line6r = spd_kt~" / "~spd_mc;	
			}
	cdu.DspSet(page,DspL,DspR);
}

var fltPlan_2 = func(dest_airport,dest_rwy,num,flt_closed,marker) {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var rep = "";
		var path = "autopilot/route-manager/route/wp[";
		var legb = "]/leg-bearing-true-deg";
		var legd = "]/leg-distance-nm";
		var spd_kt = getprop("/autopilot/settings/target-speed-kt");
		var spd_mc = sprintf("%.2f",getprop("/autopilot/settings/target-speed-mach"));		
			page = "ACTIVE FLT PLAN     2 / 5";
			DspL.line1l = " VIA TO";
			DspL.line2l = "----";
			DspL.line3l = " VIA TO";
			DspL.line4l = "----";
			DspL.line5l = " VIA TO";
			DspL.line6l = "----";
			DspL.line7l = "< DEPARTURE";
			DspR.line5r = " DEST";
			DspR.line6r = dest_airport~" "~ dest_rwy;
			DspR.line7r = "ARRIVAL >";

			if (num == 4 and flt_closed == 1) {
				var ind = 3;
				DspL.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				DspL.line2l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 4 or (num == 4 and dest_airport == "")) {
				var ind = 3;
				DspL.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				DspL.line2l = getprop(path~ind~"]/id")~rep;
				DspR.line1r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					DspR.line1r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				DspR.line2r = spd_kt~" / "~spd_mc;	
			}
			if (num == 5 and flt_closed == 1) {
				var ind = 4;
				DspL.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				DspL.line4l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 5 or (num == 5 and dest_airport == "")) {
				var ind = 4;
				DspL.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				DspL.line4l = getprop(path~ind~"]/id")~rep;
				DspR.line3r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					DspR.line3r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				DspR.line4r = spd_kt~" / "~spd_mc;	
			}
			if (num == 6 and flt_closed == 1) {
				var ind = 5;
				DspL.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				DspL.line6l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 6 or (num == 6 and dest_airport == "")) {
				var ind = 5;
				DspL.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				DspL.line6l = getprop(path~ind~"]/id")~rep;
				DspR.line5r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					DspR.line5r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				DspR.line6r = spd_kt~" / "~spd_mc;	
			}
	cdu.DspSet(page,DspL,DspR);
}

var fltPlan_3 = func(dest_airport,dest_rwy,num,flt_closed,marker) {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var rep = "";
		var path = "autopilot/route-manager/route/wp[";
		var legb = "]/leg-bearing-true-deg";
		var legd = "]/leg-distance-nm";
		var spd_kt = getprop("/autopilot/settings/target-speed-kt");
		var spd_mc = sprintf("%.2f",getprop("/autopilot/settings/target-speed-mach"));		
			page = "ACTIVE FLT PLAN     3 / 5";
			DspL.line1l = "VIA TO";
			DspL.line2l = "----";
			DspL.line3l = " VIA TO";
			DspL.line4l = "----";
			DspL.line5l = " VIA TO";
			DspL.line6l = "----";
			DspL.line7l = "< DEPARTURE";
			DspR.line5r = " DEST";
			DspR.line6r = dest_airport~" "~ dest_rwy;
			DspR.line7r = "ARRIVAL >";
			if (num == 7 and flt_closed == 1) {
				var ind = 6;
				DspL.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				DspL.line2l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 7 or (num == 7 and dest_airport == "")) {
				var ind = 6;
				DspL.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				DspL.line2l = getprop(path~ind~"]/id")~rep;
				DspR.line1r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					DspR.line1r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				DspR.line2r = spd_kt~" / "~spd_mc;	
			}
			if (num == 8 and flt_closed == 1) {
				var ind = 7;
				DspL.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				DspL.line4l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 8 or (num == 8 and dest_airport == "")) {
				var ind = 7;
				DspL.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				DspL.line4l = getprop(path~ind~"]/id")~rep;
				DspR.line3r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					DspR.line3r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				DspR.line4r = spd_kt~" / "~spd_mc;	
			}
			if (num == 9 and flt_closed == 1) {
				var ind = 8;
				DspL.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				DspL.line6l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 9 or (num == 3 and dest_airport == "")) {
				var ind = 8;
				DspL.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				DspL.line6l = getprop(path~ind~"]/id")~rep;
				DspR.line5r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					DspR.line5r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				DspR.line6r = spd_kt~" / "~spd_mc;	
			}
	cdu.DspSet(page,DspL,DspR);
}

var fltPlan_4 = func(dest_airport,dest_rwy,num,flt_closed,marker) {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var rep = "";
		var path = "autopilot/route-manager/route/wp[";
		var legb = "]/leg-bearing-true-deg";
		var legd = "]/leg-distance-nm";
		var spd_kt = getprop("/autopilot/settings/target-speed-kt");
		var spd_mc = sprintf("%.2f",getprop("/autopilot/settings/target-speed-mach"));		
			page = "ACTIVE FLT PLAN     4 / 5";
			DspL.line1l = "VIA TO";
			DspL.line2l = "----";
			DspL.line3l = " VIA TO";
			DspL.line4l = "----";
			DspL.line5l = " VIA TO";
			DspL.line6l = "----";
			DspL.line7l = "< DEPARTURE";
			DspR.line5r = " DEST";
			DspR.line6r = dest_airport~" "~ dest_rwy;
			DspR.line7r = "ARRIVAL >";

			if (num == 10 and flt_closed == 1) {
				var ind = 9;
				DspL.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				DspL.line2l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 10 or (num == 10 and dest_airport == "")) {
				var ind = 9;
				DspL.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				DspL.line2l = getprop(path~ind~"]/id")~rep;
				DspR.line1r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					DspR.line1r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				DspR.line2r = spd_kt~" / "~spd_mc;	
			}
			if (num == 11 and flt_closed == 1) {
				var ind = 10;
				DspL.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				DspL.line4l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 11 or (num == 11 and dest_airport == "")) {
				var ind = 10;
				DspL.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				DspL.line4l = getprop(path~ind~"]/id")~rep;
				DspR.line3r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					DspR.line3r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				DspR.line4r = spd_kt~" / "~spd_mc;	
			}
			if (num == 12 and flt_closed == 1) {
				var ind = 11;
				DspL.line5l = sprintf("%3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				DspL.line6l = dest_airport~" "~ dest_rwy;
			}
	cdu.DspSet(page,DspL,DspR);
	}

var fltPlan_5 = func(dest_airport,dest_rwy,num,marker) {
		var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
		var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		if (num <= 1) {
			var i = 0;
			var j = 0;
		}	
		else {
			var i = num - 1;
			var j = num - 2;
		}
			page = "ACTIVE FLT PLAN     5 / 5";
			DspL.line1l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp["~j~"]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp["~j~"]/leg-distance-nm"));
			DspL.line2l = getprop("autopilot/route-manager/route/wp["~j~"]/id");
			DspL.line3l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp["~i~"]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp["~i~"]/leg-distance-nm"));
			DspL.line4l = dest_airport~" "~ dest_rwy;
			DspL.line5l = "       SAVE ACTIVE FLT";
			DspL.line6l = "          PLAN TO";
			DspL.line7l = "< DEPARTURE";
			DspR.line1r = "";
			DspR.line2r = "";
			DspR.line3r = "";
			DspR.line4r = "";
			DspR.line5r = "";
			DspR.line6r = "------------";
			if (getprop("autopilot/route-manager/input") == "@SAVE") {
				DspR.line5r = "*SAVED*";
				DspR.line6r = getprop("autopilot/route-manager/flight-plan");
			}
			if (getprop("autopilot/route-manager/active")) {
				DspR.line7r = "PERF INIT >";
			} else {DspR.line7r = ""}

	cdu.DspSet(page,DspL,DspR);
}


### Display CduStart ###
### C. LE MOIGNE (clm76) - 2015 ###

var fltPlan_0 = func(dep_airport,dest_airport) {
		line1l=line2l=line3l=line4l=line5l=line6l=line7l=line8l="";
		line1r=line2r=line3r=line4r=line5r=line6r=line7r=line8r="";
			page = "ACTIVE FLT PLAN     1 / 1";
			line1l = " ORIGIN / ETD";
			line2l = "----";
			if (dep_airport != "") {
				line2l = dep_airport;
			}
			line3l = "< LOAD FPL";
			line4l = "";
			line5l = "     RECALL OR CREATE";
			line6l = "       FPL NAMED";
			line7l = "< FPL LIST";
			line1r = "";
			line2r = "";
			line3r = "DEST";
			line4r = "----";
			if (dest_airport != "") {
				line4r = dest_airport;	
			}
			line5r = "";
			line6r = "---------";
			line7r = "PERF INIT >";
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

var fltPlan_1 = func(dep_airport,dest_airport,num) {
		line1l=line2l=line3l=line4l=line5l=line6l=line7l=line8l="";
		line1r=line2r=line3r=line4r=line5r=line6r=line7r=line8r="";
			page = "ACTIVE FLT PLAN     1 / 2";
			line1l = " ORIGIN / ETD";
			line2l = "----";
			if (dep_airport != "") {
				line2l = dep_airport;
			}
			line3l = " VIA TO";
			line4l = "----";
			if (num > 2) {
				line3l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[1]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[1]/leg-distance-nm"));
				line4l = getprop("autopilot/route-manager/route/wp[1]/id");
			}
			line5l = " VIA TO";
			line6l = "----";
			if (num > 3) {
				line5l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[2]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[2]/leg-distance-nm"));
				line6l = getprop("autopilot/route-manager/route/wp[2]/id");
			}
			line7l = "< DEPARTURE";
			line1r = "";
			line2r = "";
			line3r = " DEST";
			line4r = "----";
			if (dest_airport != "") {
				line4r = dest_airport;	
			}
			line5r = "";
			line6r = "";
			line7r = "ARRIVAL >";
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

var fltPlan_2 = func(dest_airport,num,flt_closed) {
		line1l=line2l=line3l=line4l=line5l=line6l=line7l=line8l="";
		line1r=line2r=line3r=line4r=line5r=line6r=line7r=line8r="";
			page = "ACTIVE FLT PLAN     2 / 3";
			line1l = " VIA TO";
			line2l = "----";
			if (num == 4 and flt_closed == 1) {
				line1l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[3]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[3]/leg-distance-nm"));
				line2l = dest_airport;
			}	
			else if (num > 4) {
				line1l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[3]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[3]/leg-distance-nm"));
				line2l = getprop("autopilot/route-manager/route/wp[3]/id");
			}
			line3l = " VIA TO";
			line4l = "----";
			if (num == 5 and flt_closed == 1) {
				line3l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[4]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[4]/leg-distance-nm"));
				line4l = dest_airport;
			}	
			else if (num > 5) {
				line3l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[4]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[4]/leg-distance-nm"));
				line4l = getprop("autopilot/route-manager/route/wp[4]/id");
			}
			line5l = " VIA TO";
			line6l = "----";
			if (num == 6 and flt_closed == 1) {
				line5l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[5]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[5]/leg-distance-nm"));
				line6l = dest_airport;
			}	
			else if (num > 6) {
				line5l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[5]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[5]/leg-distance-nm"));
				line6l = getprop("autopilot/route-manager/route/wp[5]/id");
			}
			line7l = "< DEPARTURE";
			line1r = "";
			line2r = "";
			line3r = " DEST";
			line4r = dest_airport;
			line5r = "";
			line6r = "";
			line7r = "PERF INIT >";
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

var fltPlan_3 = func(dest_airport,num,flt_closed) {
		line1l=line2l=line3l=line4l=line5l=line6l=line7l=line8l="";
		line1r=line2r=line3r=line4r=line5r=line6r=line7r=line8r="";
			page = "ACTIVE FLT PLAN     3 / 4";
			line1l = "VIA TO";
			line2l = "----";
			if (num == 7 and flt_closed == 1) {
				line1l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[6]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[6]/leg-distance-nm"));
				line2l = dest_airport;
			}	
			else if (num > 7) {
				line1l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[6]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[6]/leg-distance-nm"));
				line2l = getprop("autopilot/route-manager/route/wp[6]/id");
			}
			line3l = " VIA TO";
			line4l = "----";
			if (num == 8 and flt_closed == 1) {
				line3l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[7]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[7]/leg-distance-nm"));
				line4l = dest_airport;
			}	
			else if (num > 8) {
				line3l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[7]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[7]/leg-distance-nm"));
				line4l = getprop("autopilot/route-manager/route/wp[7]/id");
			}
			line5l = " VIA TO";
			line6l = "----";
			if (num == 9 and flt_closed == 1) {
				line5l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[8]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[8]/leg-distance-nm"));
				line6l = dest_airport;
			}	
			else if (num > 9) {
				line5l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[8]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[8]/leg-distance-nm"));
				line6l = getprop("autopilot/route-manager/route/wp[8]/id");
			}
			line7l = "< DEPARTURE";
			line1r = "";
			line2r = "";
			line3r = " DEST";
			line4r = dest_airport;
			line5r = "";
			line6r = "";
			line7r = "PERF INIT >";
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

var fltPlan_4 = func(dest_airport,num,flt_closed) {
		line1l=line2l=line3l=line4l=line5l=line6l=line7l=line8l="";
		line1r=line2r=line3r=line4r=line5r=line6r=line7r=line8r="";
			page = "ACTIVE FLT PLAN     4 / 5";
			line1l = "VIA TO";
			line2l = "----";
			if (num == 10 and flt_closed == 1) {
				line1l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[9]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[9]/leg-distance-nm"));
				line2l = dest_airport;
			}	
			else if (num > 10) {
				line1l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[9]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[9]/leg-distance-nm"));
				line2l = getprop("autopilot/route-manager/route/wp[9]/id");
			}
				line3l = " VIA TO";
				line4l = "----";
			if (num == 11 and flt_closed == 1) {
				line3l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[10]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[10]/leg-distance-nm"));
				line4l = dest_airport;
			}	
			else if (num > 11) {
				line3l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[10]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[10]/leg-distance-nm"));
				line4l = getprop("autopilot/route-manager/route/wp[10]/id");
			}
				line5l = " VIA TO - LAST WAYPOINT = DEST AIRPORT";
				line6l = "----";
			if (num == 12 and flt_closed == 1) {
				line5l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp[11]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp[11]/leg-distance-nm"));
				line6l = dest_airport;
			}
			line7l = "< DEPARTURE";
			line1r = "";
			line2r = "";
			line3r = " DEST";
			line4r = dest_airport;
			line5r = "";
			line6r = "";
			line7r = "PERF INIT >";
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

var fltPlan_5 = func(dest_airport) {
		line1l=line2l=line3l=line4l=line5l=line6l=line7l=line8l="";
		line1r=line2r=line3r=line4r=line5r=line6r=line7r=line8r="";
			page = "ACTIVE FLT PLAN     5 / 5";
			line1l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp["~j~"]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp["~j~"]/leg-distance-nm"));
			line2l = getprop("autopilot/route-manager/route/wp["~j~"]/id");
			line3l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp["~i~"]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp["~i~"]/leg-distance-nm"));
			line4l = dest_airport;
			line5l = "       SAVE ACTIVE FLT";
			line6l = "          PLAN TO";
			line7l = "< DEPARTURE";
			line1r = "";
			line2r = "";
			line3r = "";
			line4r = "";
			line5r = "";
			line6r = "------------";
			if (getprop("autopilot/route-manager/input") == "@SAVE") {
				line5r = "*SAVED*";
				line6r = getprop("autopilot/route-manager/flight-plan");
			}
			line7r = "PERF INIT >";
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


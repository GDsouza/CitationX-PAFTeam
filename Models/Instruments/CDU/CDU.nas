### Fmz2000 - CDU System ####
### C. Le Moigne (clm76) - 2015  ###
###

var init = func {
	setprop("autopilot/route-manager/flight-plan","");
	setprop("autopilot/route-manager/departure/airport",getprop("/sim/airport/closest-airport-id"));
	setprop("autopilot/route-manager/flp-path",getprop("sim/aircraft-dir") ~ "/Models/Instruments/CDU/FlightPlan/");
	setprop("autopilot/route-manager/departure/runway",getprop("sim/atc/runway"));
}

var input = func (v) {
		setprop("/instrumentation/cdu/input",getprop("/instrumentation/cdu/input")~v);
}

var key = func(v) {
	var cduDisplay = getprop("/instrumentation/cdu/display");
	var serviceable = getprop("/instrumentation/cdu/serviceable");
	var cduInput = getprop("/instrumentation/cdu/input");	
	var destAirport = getprop("autopilot/route-manager/destination/airport");
	var depAirport = getprop ("autopilot/route-manager/departure/airport");
	var currentPath = getprop("autopilot/route-manager/flp-path");
	var fltPath = "";
	var fltName = depAirport ~ "-" ~ destAirport;
	var i = substr(cduDisplay,9,1);
	var j = 0;

	if (serviceable == 1){	

		#### NAV-IDENT ####
		if (cduDisplay == "NAV IDENT" and v == "B4R"){
			cduDisplay = "POS INIT";
		}

		#### POS-INIT ####
		if (cduDisplay == "POS INIT") {
			if (v == "B1R") {				
				setprop("instrumentation/cdu/load_pos1",1);
			}
			if (v == "B2R") {
				setprop("instrumentation/cdu/load_pos2",1);
			}
			if (v == "B3R") {
				setprop("instrumentation/cdu/load_pos3",1);
			}
			if (v == "B4R") {
				if (getprop("instrumentation/cdu/pos-init") == 1) {
					v = "";
					cduDisplay = "FLT-PLAN[0]";
				}
			}		
		}

		#### FLT-LIST ####
		if (left(cduDisplay,8) == "FLT-LIST") {
			var ligne = "";
			if (v == "B4L") {
				v = "";
				cduDisplay = "FLT-PLAN[0]";
			} 
			else {
				if (v == "B1L") {ligne = "L[1]"}
				if (v == "B2L") {ligne = "L[3]"}
				if (v == "B3L") {ligne = "L[5]"}
				if (v == "B1R") {ligne = "R[1]"}
				if (v == "B2R") {ligne = "R[3]"}
				if (v == "B3R") {ligne = "R[5]"}
				if (getprop("instrumentation/cdu/"~ligne) !="") {
					fltName = getprop("instrumentation/cdu/"~ligne);
					fltPath = currentPath ~ fltName;
					setprop("autopilot/route-manager/file-path",fltPath);
					setprop("autopilot/route-manager/input","@LOAD");							
					setprop("autopilot/route-manager/flight-plan",fltName);
					setprop("autopilot/route-manager/active",1);
					cduDisplay = "FLT-PLAN[1]";
				}
			}
		}

		#### DEPARTURE ####
		if (left(cduDisplay,8) == "FLT-DEPT") {
			var ligne = "";
			if (v == "B4R") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-PLAN[1]";
			} else if (v == "B4L") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-SIDS[0]";
			}	else {
				if (v == "B1L") {ligne = "L[1]"}
				if (v == "B2L") {ligne = "L[3]"}
				if (v == "B3L") {ligne = "L[5]"}
				if (v == "B1R") {ligne = "R[1]"}
				if (v == "B2R") {ligne = "R[3]"}
				if (v == "B3R") {ligne = "R[5]"}
				if (getprop("instrumentation/cdu/"~ligne) !="") {
					setprop("autopilot/route-manager/departure/runway",getprop("instrumentation/cdu/"~ligne));
					cduInput = "RWY " ~ getprop("autopilot/route-manager/departure/runway") ~ " Loaded";
				}
			}
		}

		#### SIDS ####
		if (left(cduDisplay,8) == "FLT-SIDS") {
			var ligne = "";			
			if (v == "B4L") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-PLAN[1]";
			}
			else if (v != "") {
				if (v == "B1L") {ligne = "L[1]"}
				if (v == "B2L") {ligne = "L[3]"}
				if (v == "B3L") {ligne = "L[5]"}
				if (v == "B1R") {ligne = "R[1]"}
				if (v == "B2R") {ligne = "R[3]"}
				if (v == "B3R") {ligne = "R[5]"}
				if(getprop("autopilot/route-manager/departure/sid") != "") {
					flightplan().clearWPType('sid');
				}
				if (getprop("instrumentation/cdu/"~ligne) !="") {
					var SidName = getprop("instrumentation/cdu/"~ligne);
					flightplan().sid = SidName;
					cduInput = getprop("autopilot/route-manager/departure/sid") ~ " Loaded";
				}
			}
		}

		#### ARRIVAL ####
		if (left(cduDisplay,8) == "FLT-ARRV") {
#			if (v == "B4R") {
#				v = "";
#				cduInput = "";
#				cduDisplay = "FLT-LAND[0]";
#			}
#			else {
				if (v == "B1L") {v="";cduDisplay = "FLT-ARWY[0]"}
				if (v == "B2L") {v="";cduDisplay = "FLT-STAR[0]"}
				if (v == "B3L") {v="";cduDisplay = "FLT-APPR[0]"}
				if (v == "B4L") {v="";cduDisplay = "FLT-PLAN[1]"}
				if (v == "B4R") {v="";cduDisplay = "FLT-LAND[0]"}
#			}
		}

		if (left(cduDisplay,8) == "FLT-ARWY") {
			var ligne = "";
			if (v == "B4L") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-ARRV[0]";
			}
			else if (v != "") {
				if (v == "B1L") {ligne = "L[1]"}
				if (v == "B2L") {ligne = "L[3]"}
				if (v == "B3L") {ligne = "L[5]"}
				if (v == "B1R") {ligne = "R[1]"}
				if (v == "B2R") {ligne = "R[3]"}
				if (v == "B3R") {ligne = "R[5]"}
				if (getprop("instrumentation/cdu/"~ligne) !="") {
					setprop("autopilot/route-manager/destination/runway",getprop("instrumentation/cdu/"~ligne));
					cduInput = "RWY " ~ getprop("autopilot/route-manager/destination/runway") ~ " Loaded";
				}
			}
		}

		#### STARS ####
		if (left(cduDisplay,8) == "FLT-STAR") {
			var ligne = "";			
			if (v == "B4L") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-ARRV[0]";
			}
		if (v == "B4R") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-ARWY[0]";
			}

			else if (v != "") {
				if (v == "B1L") {ligne = "L[1]"}
				if (v == "B2L") {ligne = "L[3]"}
				if (v == "B3L") {ligne = "L[5]"}
				if (v == "B1R") {ligne = "R[1]"}
				if (v == "B2R") {ligne = "R[3]"}
				if (v == "B3R") {ligne = "R[5]"}
				if(getprop("autopilot/route-manager/destination/star") != "") {				
					flightplan().clearWPType('star');
				}				
				if (getprop("instrumentation/cdu/"~ligne) !="") {
					var StarName = getprop("instrumentation/cdu/"~ligne);
					flightplan().star = StarName;
					cduInput = getprop("autopilot/route-manager/destination/star") ~ " Loaded";
				}
			}
		}

		#### APPROACHES ####
		if (left(cduDisplay,8) == "FLT-APPR") {
			var ligne = "";			
		if (v == "B4L") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-ARRV[0]";
			}
		if (v == "B4R") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-ARWY[0]";
			}
			else if (v != "") {
				if (v == "B1L") {ligne = "L[1]"}
				if (v == "B2L") {ligne = "L[3]"}
				if (v == "B3L") {ligne = "L[5]"}
				if (v == "B1R") {ligne = "R[1]"}
				if (v == "B2R") {ligne = "R[3]"}
				if (v == "B3R") {ligne = "R[5]"}
				if(getprop("autopilot/route-manager/destination/approach") != 0) {				
					flightplan().clearWPType('approach');
				}
					var ApprName = getprop("instrumentation/cdu/"~ligne);
					flightplan().approach = ApprName;
				cduInput = getprop("autopilot/route-manager/destination/approach") ~ " Loaded";
			}
		}

		#### FLT-PLAN ####
		if (left(cduDisplay,8) == "FLT-PLAN") {
			if (v == "B1L" or v == "B2L" or v == "B3L") {
				if (cduDisplay == "FLT-PLAN[0]") {
					if (v == "B1L") {	j = 0 };
					if (v == "B2L") {	cduDisplay = "FLT-LIST[0]"}
				}						
				if (cduDisplay == "FLT-PLAN[1]") {
					if (v == "B1L") {	j = 0 };
					if (v == "B2L") {	j = 1 };
					if (v == "B3L") { j = 2 };
				}
				if (cduDisplay == "FLT-PLAN[2]") {
					if (v == "B1L") {	j = 3 };
					if (v == "B2L") { j = 4 };
					if (v == "B3L") { j = 5 };
				}
				if (cduDisplay == "FLT-PLAN[3]") {
					if (v == "B1L") {	j = 6 };
					if (v == "B2L") { j = 7 };
					if (v == "B3L") { j = 8 };
				}
				if (cduDisplay == "FLT-PLAN[4]") {
					if (v == "B1L") {	j = 9 };
					if (v == "B2L") {	j = 10 };
					if (v == "B3L") {	j = 11 };		
				} 
				if (destAirport == cduInput and cduInput !="") {
					setprop("autopilot/route-manager/input","@ACTIVATE");		
					setprop("instrumentation/cdu/display-prev",cduDisplay);
					cduDisplay = "FLT-PLAN[5]";
					cduInput = "";
				} 
				if (cduDisplay == "FLT-PLAN["~i~"]") {
					if (cduInput == "*DELETE*") {
						if (j == 0) {
							setprop("autopilot/route-manager/departure/airport","");
							setprop("autopilot/route-manager/destination/airport","");
							setprop("autopilot/route-manager/input","@CLEAR");
							cduDisplay = "FLT-PLAN[0]";
							cduInput = "";
						}
						else if (getprop("autopilot/route-manager/active") == 1) {
							setprop("autopilot/route-manager/active",0);
							cduInput = "*Flight Plan Dead*";
						}
						else {
							setprop("autopilot/route-manager/input","@DELETE"~j);
							cduInput = "";
						}
					} 
					else if (depAirport == "") {
						setprop("autopilot/route-manager/departure/airport", cduInput);
						cduInput = "";
					}
					else if (getprop("autopilot/route-manager/active") == 1) {									
						cduInput = "*Flight Plan Closed*";
					}
					else if (destAirport == ""){
						cduInput = "*Enter Dest. Airport*";
					}
					else {
						setprop("autopilot/route-manager/input","@INSERT"~j~":"~cduInput);
						cduInput = "";						
					}
				} 							
			}

			if (v == "B4L") {
				v = "";
				if (cduDisplay == "FLT-PLAN[0]") {cduDisplay = "FLT-LIST[0]"}
				else {cduDisplay = "FLT-DEPT[0]"}
			}

			if (v == "B2R") {
				if (depAirport == ""){
						cduInput = "*Enter Depart. Airport*";
				}
				else {
					if (cduInput == "") {
						cduInput = destAirport;
					} 
					else if (cduInput == "*DELETE*") {
						if(getprop("autopilot/route-manager/route/num") == 2) {
							setprop("autopilot/route-manager/destination/airport","@DELETE");
						}
						cduInput = "";
					}
					else {
						setprop("autopilot/route-manager/destination/airport",cduInput);
						cduInput = "";
						if (cduDisplay == "FLT-PLAN[0]") {
							cduDisplay = "FLT-PLAN[1]";
						}
					}
				}
			}

			if (v == "B3R") {
				if (cduDisplay == "FLT-PLAN[0]") {
					fltName = cduInput;
					fltPath = currentPath ~ fltName;
					setprop("autopilot/route-manager/file-path",fltPath);
					setprop("autopilot/route-manager/input","@LOAD");
#					setprop("autopilot/route-manager/input","@ACTIVATE");
					setprop("autopilot/route-manager/flight-plan",fltName);
					cduInput = "";
					cduDisplay = "FLT-PLAN[1]";
				}
				if (cduDisplay == "FLT-PLAN[5]") {
					if (getprop("autopilot/route-manager/departure/runway") == "") {
						cduInput = "*NO DEPT RUNWAY*";
					}
					else {										
						fltName = cduInput;
						fltPath = currentPath ~ fltName;
						setprop("autopilot/route-manager/file-path",fltPath);
						setprop("autopilot/route-manager/input","@SAVE");
						setprop("autopilot/route-manager/flight-plan",fltName);
						cduInput = "";
					}
				}
			}

			if (v == "B4R") {
				if (cduDisplay == "FLT-PLAN[0]") {cduDisplay = "PRF-INIT[0]"}
				if (cduDisplay == "FLT-PLAN[1]") {cduDisplay = "FLT-ARRV"}
				v = "";
			}						
		}		
		setprop("/instrumentation/cdu/display",cduDisplay);
#		setprop("instrumentation/cdu/display-short",left(cduDisplay,8));
		setprop("/instrumentation/cdu/input",cduInput);
	}
}

var delete = func {
		var length = size(getprop("instrumentation/cdu/input")) - 1;
		setprop("instrumentation/cdu/input",substr(getprop("/instrumentation/cdu/input"),0,length));
		if (length == -1 ) {
			setprop("instrumentation/cdu/input","*DELETE*");
		}
}

var plusminus = func {	
	var end = size(getprop("/instrumentation/cdu/input"));
	var start = end - 1;
	var lastchar = substr(getprop("/instrumentation/cdu/input"),start,end);
	if (lastchar == "+"){
		me.delete();
		me.input('-');
		}
	if (lastchar == "-"){
		me.delete();
		me.input('+');
		}
	if ((lastchar != "-") and (lastchar != "+")){
		me.input('-');
	}
}

var previous = func {
	var page = substr(getprop("/instrumentation/cdu/display"),9,1);
	var dspShort = left(getprop("instrumentation/cdu/display"),8);
	if (dspShort == "FLT-PLAN") {		
		if (page >= 1 and page <=4) {
			page -= 1;
		}
		else if (page == 5) {
			page = substr(getprop ("instrumentation/cdu/display-prev"),9,1);
		}			
		setprop("/instrumentation/cdu/display","FLT-PLAN["~page~"]");		
	} else {
			if (page > 0) {
				page -= 1;
				setprop("/instrumentation/cdu/display",dspShort ~ "["~page~"]");
				setprop("/instrumentation/cdu/nrpage",page);
			}
	}
}

var next = func {
	var page = substr(getprop("/instrumentation/cdu/display"),9,1);
	var nbPage = getprop("/instrumentation/cdu/nbpage");
	var dspShort = left(getprop("instrumentation/cdu/display"),8);
	if (dspShort == "FLT-PLAN") {	
		if (page <= 4 and getprop("autopilot/route-manager/route/num") > 0) {
			page += 1;			
			setprop("/instrumentation/cdu/display","FLT-PLAN["~page~"]");
		}		
	} else {
#	if ((dspShort == "FLT-LIST" or dspShort == "FLT-DEPT" or dspShort == "FLT-SIDS" or dspShort == "FLT-STAR" or dspShort == "FLT-APPR" or dspShort == "FLT-DEPT" or dspShort == "FLT-ARWY") and page < nbPage-1) {		
		if (page <  nbPage-1) {
			page += 1;
			setprop("/instrumentation/cdu/display",dspShort ~ "["~page~"]");
		}
	}
}

var dspPages = func (xfile,display) {
		var nbFiles = size(xfile);
		var nbPage = math.ceil(nbFiles/6);
		setprop("instrumentation/cdu/nbpage",nbPage);
}

var cdu = func{
	### Params Date-hour ###
	var my_day = getprop("sim/time/real/day");
	var my_month = getprop("sim/time/real/month");
	var my_year = getprop("sim/time/real/year");
	var my_hour = getprop("sim/time/real/hour");
	var my_minute = getprop("sim/time/real/minute");
	setprop("instrumentation/cdu[0]/date", sprintf("%.2i-%.2i-%i", my_day, my_month, my_year));
	setprop("instrumentation/cdu[0]/time", sprintf("%.2i:%.2i", my_hour, my_minute));

	### Params Latitude and Longitude ###
	var my_lat = getprop("position/latitude-string");
	var my_long = getprop("position/longitude-string");	

	if (size(my_lat)==11) {
	my_lat = (right(my_lat,1)~left(my_lat,5)~"."~substr(my_lat,6,1));
	}
	else {
	my_lat = (right(my_lat,1)~left(my_lat,4)~"."~substr(my_lat,5,1));
	}
	setprop("instrumentation/cdu[0]/latitude",my_lat);

	if (size(my_long)==11) {
	my_long = (right(my_long,1)~left(my_long,5)~"."~substr(my_long,6,1));
	}
	else {
	my_long = (right(my_long,1)~left(my_long,4)~"."~substr(my_long,5,1));
	}
	setprop("instrumentation/cdu[0]/longitude",my_lat);

	### Airport departure ###
	var dep_airport = getprop("autopilot/route-manager/departure/airport");
	var dep_rwy = getprop("autopilot/route-manager/departure/runway");

	### Airport arrival ###
	var dest_airport = getprop("autopilot/route-manager/destination/airport");
	var dest_rwy = getprop("autopilot/route-manager/destination/runway");	

	### Waypoints ###
	var num = getprop("autopilot/route-manager/route/num");
	var flt_closed = getprop("autopilot/route-manager/active");
	if (num <= 1) {
		var i = 0;
		var j = 0;
	}	
	else {
		var i = num - 1;
		var j = num - 2;
	}
	setprop("instrumentation/cdu/i",i);
	setprop("instrumentation/cdu/j",j);

	### Display ###
	var display = getprop("/instrumentation/cdu/display");
	var nbFiles = 0;
	var nbPage = 0;
	var nrPage = getprop("/instrumentation/cdu/nrpage");
	var displayPage = "";

	if (display == "NAV IDENT") {
		displaypages.navIdent();
	}

	if (display == "POS INIT") {
		displaypages.posInit(my_lat,my_long,dep_airport,dep_rwy);
	}

	if (left(display,8) == "FLT-LIST") {
		displaypages.fltList(display);
	}

	if (left(display,8) == "FLT-DEPT") {		
		displaypages.fltDep(dep_airport,dep_rwy,nrPage,display);
	}

	if (left(display,8) == "FLT-SIDS") {	
		displaypages.fltSids(dep_airport,dep_rwy,nrPage,display);		
	}

	if (left(display,8) == "FLT-ARRV") {	
			displaypages.fltArrv(dest_airport);
	}

	if (left(display,8) == "FLT-ARWY") {		
		displaypages.fltArwy(dest_airport,nrPage,display);
	}

	if (left(display,8) == "FLT-STAR") {	
		displaypages.fltStars(dest_airport,dest_rwy,display);
	}

	if (left(display,8) == "FLT-APPR") {	
		displaypages.fltAppr(dest_airport,dest_rwy,display);
	}
	
	if (display == "FLT-PLAN[0]") {
		displaypages.fltPlan_0(dep_airport,dest_airport);
	}

	if (display == "FLT-PLAN[1]") {
		displaypages.fltPlan_1(dep_airport,dest_airport,num);
	}

	if (display == "FLT-PLAN[2]") {
		displaypages.fltPlan_2(dest_airport,num,flt_closed);
	}

	if (display == "FLT-PLAN[3]") {
		displaypages.fltPlan_3(dest_airport,num,flt_closed);
	}

	if (display == "FLT-PLAN[4]") {
		displaypages.fltPlan_4(dest_airport,num,flt_closed);
	}

	if (display == "FLT-PLAN[5]" and num > 0) {
		displaypages.fltPlan_5(dest_airport);
	}

	if (display == "PRF-INIT[0]") {
			page = "PERFORMANCE INIT   1 / 4";
			line7l = "< FLT-PLAN";
	}
							
	settimer(cdu,0.2);
}

var DspSet = func(page,DspL,DspR) {
	setprop("instrumentation/cdu/page",page);
	setprop("instrumentation/cdu/L[0]",DspL.line1l);
	setprop("instrumentation/cdu/L[1]",DspL.line2l);
	setprop("instrumentation/cdu/L[2]",DspL.line3l);
	setprop("instrumentation/cdu/L[3]",DspL.line4l);
	setprop("instrumentation/cdu/L[4]",DspL.line5l);
	setprop("instrumentation/cdu/L[5]",DspL.line6l);
	setprop("instrumentation/cdu/L[6]",DspL.line7l);
	setprop("instrumentation/cdu/R[0]",DspR.line1r);
	setprop("instrumentation/cdu/R[1]",DspR.line2r);
	setprop("instrumentation/cdu/R[2]",DspR.line3r);
	setprop("instrumentation/cdu/R[3]",DspR.line4r);
	setprop("instrumentation/cdu/R[4]",DspR.line5r);
	setprop("instrumentation/cdu/R[5]",DspR.line6r);
	setprop("instrumentation/cdu/R[6]",DspR.line7r);
}

setlistener("/sim/signals/fdm-initialized", func {
	init();
	cdu();
});

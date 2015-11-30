### Fmz2000 - CDU System ####
### C. Le Moigne (clm76) - 2015  ###
###

var init = func {
	setprop("autopilot/route-manager/flight-plan","");
	setprop("autopilot/route-manager/departure/airport",getprop("/sim/airport/closest-airport-id"));
	setprop("autopilot/route-manager/departure/runway",getprop("sim/atc/runway"));
	setprop("autopilot/settings/cruise-speed-kt",515);
	setprop("autopilot/settings/cruise-speed-mach",0.78);
	setprop("autopilot/route-manager/cruise/altitude-ft",41000);
	setprop("autopilot/route-manager/cruise/flight-level",410);
	setprop("autopilot/settings/asel",getprop("autopilot/route-manager/cruise/flight-level"));
	setprop("autopilot/settings/climb-speed-kt",250);
	setprop("autopilot/settings/descent-speed-kt",200);
	setprop("autopilot/settings/dep-speed-kt",200);
	setprop("autopilot/settings/dep-agl-limit-ft",2500);
	setprop("autopilot/settings/dep-limit-nm",4);
	setprop("autopilot/settings/app-speed-kt",200);
	setprop("autopilot/settings/dist-to-dest-nm",15);
	setprop("autopilot/settings/app5-speed-kt",180);
	setprop("autopilot/settings/app15-speed-kt",160);
	setprop("autopilot/settings/app39-speed-kt",140);
	setprop("autopilot/route-manager/wp[]/altitude-ft",0);
}

var input = func (v) {
	var n = size(getprop("/instrumentation/cdu/input"));
		if (left(getprop("/instrumentation/cdu/input"),1) == "*") {
			setprop("/instrumentation/cdu/input",	"");
		}		
		if (n < 13) {
			setprop("/instrumentation/cdu/input",getprop("/instrumentation/cdu/input")~v);
		}
}

var key = func(v) {
	var cduDisplay = getprop("/instrumentation/cdu/display");
	var cduInput = getprop("/instrumentation/cdu/input");	
	var destAirport = getprop("autopilot/route-manager/destination/airport");
	var destRwy = getprop("autopilot/route-manager/destination/runway");
	var depAirport = getprop ("autopilot/route-manager/departure/airport");
	var num = getprop("autopilot/route-manager/route/num");
	var savePath = getprop("/sim/fg-home")~"/aircraft-data/FlightPlans/";
	var fltPath = "";
	var fltName = "";
	var i = substr(cduDisplay,9,1);
	var j = 0;

		#### NAV-IDENT ####
		if (cduDisplay == "NAVIDENT[0]" and (v == "B4R" or v == "FPL" or v == "NAV")){
			v = "";
			cduDisplay = "POS INIT[0]";
		}
		if (cduDisplay == "NAVIDENT[0]" and v == "PERF"){
			v = "";
			cduDisplay = "PRF-PAGE[0]";
		}

		#### POS-INIT ####
		if (cduDisplay == "POS INIT[0]") {
			if (v == "B1R" or v == "B2R" or v == "B3R") {	
				setprop("instrumentation/cdu/pos-init",1);
			}
			if (v == "B4R" or v == "FPL") {
				if (getprop("instrumentation/cdu/pos-init") == 1) {
					v = "";
					cduDisplay = "FLT-PLAN[0]";
				}
			}
			if (v == "NAV" and getprop("instrumentation/cdu/pos-init") == 1) {
					v = "";
					cduDisplay = "NAV-PAGE[0]";
			}		
			if (v == "PERF" and getprop("instrumentation/cdu/pos-init") == 1) {
					v = "";
					cduDisplay = "PRF-PAGE[0]";
			}		
			if (v == "PROG" and getprop("instrumentation/cdu/pos-init") == 1) {
					v = "";
					cduDisplay = "PRG-PAGE[0]";
			}		

		}

		#### FLT-LIST ####
		if (left(cduDisplay,8) == "FLT-LIST") {
			var ligne = "";
			if (v == "B4L" or v == "FPL") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-PLAN[0]";
			} 
			else if (v == "NAV") {
				v = "";
				cduInput = "";
				cduDisplay = "NAV-PAGE[0]";
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
					fltPath = savePath ~ fltName~".xml";
					setprop("autopilot/route-manager/file-path",fltPath);
					setprop("autopilot/route-manager/input","@LOAD");							
					setprop("autopilot/route-manager/input","@ACTIVATE");	
					v = "";	
				cduInput ="";
				cduDisplay = "FLT-PLAN[1]";
				}
			}
		}

		#### DEPARTURE ####
		if (left(cduDisplay,8) == "FLT-DEPT") {
			var ligne = "";
			if (v == "B4R" or v == "FPL") {
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
			if (v == "B4L" or v == "FPL") {
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
				if (getprop("instrumentation/cdu/"~ligne) !="") {
					var SidName = getprop("instrumentation/cdu/"~ligne);
					if (getprop("instrumentation/cdu/"~ligne)=="DEFAULT") {
						setprop("/autopilot/route-manager/departure/sid","DEFAULT");
					}
					else {
						flightplan().sid = SidName;
						setprop("/autopilot/route-manager/departure/sid",SidName);
					}
				}
				cduInput = getprop("autopilot/route-manager/departure/sid") ~ " Loaded";
			}
		}

		#### ARRIVAL ####
		if (left(cduDisplay,8) == "FLT-ARRV") {
				if (v == "B1L") {v="";cduDisplay = "FLT-ARWY[0]"}
				if (v == "B2L") {v="";cduDisplay = "FLT-STAR[0]"}
				if (v == "B3L") {v="";cduDisplay = "FLT-APPR[0]"}
				if (v == "B4L" or v == "FPL")	{v="";cduDisplay = "FLT-PLAN[1]"}
		}

		if (left(cduDisplay,8) == "FLT-ARWY") {
			var ligne = "";
			if (v == "B4L") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-ARRV[0]";
			}
			if (v == "NAV") {
				v = "";
				cduInput = "";
				cduDisplay = "NAV-PAGE[2]";
			}
			if (v == "FPL") {
				v = "";
				cduInput = "";
				if (destAirport != "" and destRwy == "") {cduInput = "*NO DEST RUNWAY*"}

				cduDisplay = "FLT-PLAN[1]";
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
			else if (v == "B4R") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-ARWY[0]";
			}
			else if (procedures.fmsDB.new(destAirport) == nil) {
				cduInput = "NO STARS FOUND";
			}
			else if (v != "") {
				if (v == "B1L") {ligne = "L[1]"}
				if (v == "B2L") {ligne = "L[3]"}
				if (v == "B3L") {ligne = "L[5]"}
				if (v == "B1R") {ligne = "R[1]"}
				if (v == "B2R") {ligne = "R[3]"}
				if (v == "B3R") {ligne = "R[5]"}
				if (getprop("instrumentation/cdu/"~ligne) !="") {
					var StarName = getprop("instrumentation/cdu/"~ligne);
					flightplan().star = StarName;
					setprop("/autopilot/route-manager/destination/star",StarName);
					cduInput = getprop("autopilot/route-manager/destination/star") ~ " Loaded";
				}			
			}
		}

		#### APPROACH ####
		if (left(cduDisplay,8) == "FLT-APPR") {
			var ligne = "";			
			if (v == "B4L") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-ARRV[0]";
			}
			else if (v == "B4R") {
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
				if (getprop("instrumentation/cdu/"~ligne) !="") {			
					var ApprName = getprop("instrumentation/cdu/"~ligne);
					if (getprop("instrumentation/cdu/"~ligne)=="DEFAULT") {
						setprop("autopilot/route-manager/destination/approach","DEFAULT");
					}
					else {
						flightplan().approach = ApprName;
						setprop("autopilot/route-managerdestination/approach",ApprName);
					}
				}
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
				if (cduDisplay == "FLT-PLAN[5]") {
					if (v == "B1L") {	j = 11 };
					if (v == "B2L") {	j = 12 };
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
						if (j == 12) {
							setprop("autopilot/route-manager/destination/airport","");
							setprop("autopilot/route-manager/active",0);
							cduInput = "";
							cduDisplay = "FLT-PLAN[0]";
						}
						else {
							if (find(destAirport,getprop("autopilot/route-manager/route/wp["~j~"]/id")) == -1) {
							setprop("autopilot/route-manager/input","@DELETE"~j);
							}
							setprop("autopilot/route-manager/active",0);
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
						if (getprop("autopilot/route-manager/route/num") != 12) {
							setprop("autopilot/route-manager/input", "@INSERT" ~j~ ":" ~cduInput);
							cduInput = "";						
						}
						if (getprop("autopilot/route-manager/route/num") == 12) {
							cduInput = "*LAST WAYPOINT*";
						}
					}
				} 							
			}

			if (v == "B4L") {
				v = "";
				if (cduDisplay == "FLT-PLAN[0]") {cduDisplay = "FLT-LIST[0]"}
				else {cduDisplay = "FLT-DEPT[0]"}
			}

			if (v == "B1R") {
				if (cduDisplay == "FLT-PLAN[2]" or cduDisplay == "FLT-PLAN[3]" or cduDisplay == "FLT-PLAN[4]") {
					if (cduDisplay == "FLT-PLAN[2]") {var ind = 3}
					if (cduDisplay == "FLT-PLAN[3]") {var ind = 6}					
					if (cduDisplay == "FLT-PLAN[4]") {var ind = 9}
					insertWayp(ind,cduInput);
					cduInput = "";
				}
			}

			if (v == "B2R") {
				if (cduDisplay == "FLT-PLAN[0]" and cduInput !="") {
						setprop("autopilot/route-manager/destination/airport",cduInput);
						cduInput = "";
						cduDisplay = "FLT-PLAN[1]";
				} else if (cduDisplay == "FLT-PLAN[1]" or cduDisplay == "FLT-PLAN[2]" or cduDisplay == "FLT-PLAN[3]" or cduDisplay == "FLT-PLAN[4]") {
					if (cduDisplay == "FLT-PLAN[1]") {var ind = 1}					
					if (cduDisplay == "FLT-PLAN[2]") {var ind = 4}
					if (cduDisplay == "FLT-PLAN[3]") {var ind = 7}					
					if (cduDisplay == "FLT-PLAN[4]") {var ind = 10}
					insertWayp(ind,cduInput);
					cduInput = "";
				}			}

			if (v == "B3R") {
				if (cduDisplay == "FLT-PLAN[0]") {
					fltName = cduInput;
					fltPath = savePath ~ fltName;
					setprop("autopilot/route-manager/file-path",fltPath);
					setprop("autopilot/route-manager/input","@LOAD");
					cduInput = "";
					cduDisplay = "FLT-PLAN[1]";
				}
				if (cduDisplay == "FLT-PLAN[1]"or cduDisplay == "FLT-PLAN[2]" or cduDisplay == "FLT-PLAN[3]" or cduDisplay == "FLT-PLAN[4]") {
					if (getprop("instrumentation/cdu/R[4]") == "DEST " and cduInput == "*DELETE*") {
							setprop("autopilot/route-manager/destination/airport","");
							cduInput = "";
							cduDisplay = "FLT-PLAN[0]";
					} else if (getprop("instrumentation/cdu/R[4]") == "DEST " or cduInput == "*LAST WAYPOINT*") {
							if (getprop("autopilot/route-manager/destination/runway")=="") {
								cduInput = "*NO DEST RUNWAY";
							} else {cduInput = destAirport}
					}	else {
							if (cduDisplay == "FLT-PLAN[1]") {var ind = 2}					
							if (cduDisplay == "FLT-PLAN[2]") {var ind = 5}
							if (cduDisplay == "FLT-PLAN[3]") {var ind = 8}					
							insertWayp(ind,cduInput);
					}
				}			
				if (cduDisplay == "FLT-PLAN[5]") {
					if (depAirport == ""){
						cduInput = "*NO DEPT AIRPORT*";
					}
					else if (getprop("autopilot/route-manager/departure/runway")=="") {
						cduInput = "*NO DEPT RUNWAY*";
					} 
					else if (getprop("autopilot/route-manager/destination/runway")=="") {
						cduInput = "*NO DEST RUNWAY*";
					}
					else if (!getprop("autopilot/route-manager/active")) {
						cduInput = "*PLAN NOT ACTIVATED*";
					}
					else {										
						fltName = cduInput~".xml";
						fltPath = savePath ~ fltName;
						setprop("autopilot/route-manager/file-path",fltPath);
						setprop("autopilot/route-manager/input","@SAVE");				
						correctFlp(fltName);  # correction flightplan (bug Fg)#
						setprop("autopilot/route-manager/flight-plan",cduInput);
						cduInput = "";
					}
				}
			}
			if (v == "B4R") {
				if (cduDisplay == "FLT-PLAN[0]" or (cduDisplay == "FLT-PLAN[5]" and getprop("autopilot/route-manager/active"))) {
					cduDisplay = "PRF-INIT[0]";
				}
				else {cduDisplay = "FLT-ARRV[0]"}
				v = "";
			}						
			if (v == "NAV") {
				v = "";
				cduDisplay = "NAV-PAGE[0]";
			}	
			if (v == "FPL") {
				v = "";
				if (destAirport != "" and destRwy == "") {cduInput = "*NO DEST RUNWAY*"}
				cduDisplay = "FLT-PLAN[1]";
			}	
			if (v == "PERF") {
				v = "";
				cduInput = "";
				cduDisplay = "PRF-PAGE[0]";
			}	
			if (v == "PROG") {
				v = "";
				cduInput = "";
				cduDisplay = "PRG-PAGE[0]";
			}	
		}		

		#### NAV PAGES ####
		if (cduDisplay == "NAV-PAGE[0]") {
			if (v == "PROG") {v = "";cduDisplay = "PRG-PAGE[0]"}			
			if (v == "B1L" or v == "B1R") {v = "";cduDisplay = "FLT-LIST[0]"}
			if (v == "B2L") {
				if (destAirport == "") {
					v = "";	
					cduInput = "*NO DEST AIRPORT*";
					cduDisplay = "FLT-PLAN[0]";
				}				
				else {v = "";cduDisplay = "FLT-PLAN[1]"}
			}
			if (v == "B3L") {v = "";cduDisplay = "NAV-PAGE[1]"}
			if (v == "B4L") {v = "";cduDisplay = "NAVIDENT[0]"}
			if (v == "B3R") {
				v = ""; 
				if (destAirport == "") {cduInput = "*NO DEST AIRPORT*"}
				if (destAirport != "" and destRwy == "") {cduInput = "*NO DEST RUNWAY*"}
				cduDisplay = "NAV-PAGE[2]";
			}
			if (v == "B4R") {
				if (destAirport == ""){
					v = "";
					cduInput = "*NO DEST AIRPORT*";
					cduDisplay = "FLT-PLAN[0]";
				}
				else {v = "";cduDisplay = "FLT-PLAN[1]"}
			}
			if (v == "PERF") {v = "";cduDisplay = "PRF-PAGE[0]"}
		}						
		if (cduDisplay == "NAV-PAGE[2]") {
			if (v == "B1L") {
				v = "";
				setprop("autopilot/route-manager/destination/airport",cduInput);
				cduInput = "";
				destAirport = getprop("autopilot/route-manager/destination/airport");
				if (destAirport != "" and destRwy == "") {cduInput = "*NO DEST RUNWAY*"}
			}
			if (v == "B3R") {
				v = "";
				cduInput = "";
				cduDisplay = "FLT-ARWY[0]";
			}
		}
		if (left(cduDisplay,8) == "NAV-PAGE") {
			if (v == "NAV") {v = "";cduDisplay = "NAV-PAGE[0]"}
		}

		#### PERF PAGES ####
		if (cduDisplay == "PRF-PAGE[0]") {
			setprop("instrumentation/cdu/nbpage",6);
			if (v == "B4R") {v = "";cduDisplay = "PRF-PAGE[1]"}
			if (v == "NAV") {v = "";cduDisplay = "NAV-PAGE[0]"}
			if (v == "PROG") {v = "";cduDisplay = "PRG-PAGE[0]"}			
			if (v == "FPL" or v == "B4L") {
				if (getprop("instrumentation/cdu/pos-init") == 0) {
					v = "";
					cduDisplay = "POS INIT[0]";				
				} else if (destAirport == ""){
						v = "";
						cduInput = "*NO DEST AIRPORT*";
						cduDisplay = "FLT-PLAN[0]";
				}
				else {v = "";cduDisplay = "FLT-PLAN[1]"}
			}
			if (v == "B2R"){
				v = "";
				setprop("sim/multiplay/callsign",cduInput);
				cduInput = "";
			}
		}

		if (cduDisplay == "PRF-PAGE[1]") {	
			if (v == "B1L") {
				v = "";
				if (cduInput != "") {
					if (left(cduInput,2) == "0.") {
						setprop("autopilot/settings/climb-speed-mach",cduInput);				
						setprop("autopilot/settings/climb-speed-kt",cduInput*661.47);
					} else {
							setprop("autopilot/settings/climb-speed-kt",cduInput);
							setprop("autopilot/settings/climb-speed-mach",cduInput*0.0015118);
					}					
				}
				cduInput = "";
			}
			if (v == "B2L") {
				v = "";
				if (cduInput != "") {
					if (left(cduInput,2) == "0.") {
						setprop("autopilot/settings/cruise-speed-mach",cduInput);
						setprop("autopilot/settings/cruise-speed-kt",cduInput*661.47);
					} else {
							setprop("autopilot/settings/cruise-speed-kt",cduInput);
							setprop("autopilot/settings/cruise-speed-mach",cduInput*0.0015118);
					}					
				}
				cduInput ="";
			}
			if (v == "B2R") {
				v = "";
				setprop("autopilot/settings/asel",cduInput);
				cduInput = "";
			}
			if (v == "B3L") {
				v = "";
				if (cduInput != "") {
					if (left(cduInput,2) == "0.") {
						setprop("autopilot/settings/descent-speed-mach",cduInput);
						setprop("autopilot/settings/descent-speed-kt",cduInput*661.47);
					} else {
							setprop("autopilot/settings/descent-speed-kt",cduInput);
							setprop("autopilot/settings/descent-speed-mach",cduInput*0.0015118);
					}					
				}
				cduInput = "";
			}
			if (v == "B4L"){v = "";cduDisplay = "PRF-PAGE[2]"}
		}

		if (cduDisplay == "PRF-PAGE[2]") {	
			if (v == "B1L") {
				v = "";
				if (cduInput != "") {
					setprop("autopilot/settings/dep-speed-kt",cduInput);	
				}
				cduInput = "";
			}
			if (v == "B2L") {
				v = "";
				if (cduInput != "") {
					setprop("autopilot/settings/dep-agl-limit-ft",cduInput);	
				}
				cduInput = "";
			}
			if (v == "B2R") {
				v = "";
				if (cduInput != "") {
					setprop("autopilot/settings/dep-limit-nm",cduInput);	
				}
				cduInput = "";
			}
			if (v == "B4L") {v = "";cduDisplay = "PRF-PAGE[3]"}
			if (v == "B4R") {v = "";cduDisplay = "PRF-PAGE[0]"}
		}

		if (cduDisplay == "PRF-PAGE[3]") {	
			if (v == "B1L") {
				v = "";
				if (cduInput != "") {
					setprop("autopilot/settings/app-speed-kt",cduInput);	
				}
				cduInput ="";
			}
			if (v == "B2L") {
				v = "";
				if (cduInput != "") {
					setprop("autopilot/settings/dist-to-dest-nm",cduInput);	
				}
				cduInput = "";
			}
			if (v == "B4L") {v = "";cduDisplay = "PRF-PAGE[4]"}
			if (v == "B4R") {v = "";cduDisplay = "PRF-PAGE[0]"}
		}

		if (cduDisplay == "PRF-PAGE[4]") {	
			if (v == "B1L") {
				v = "";
				if (cduInput != "") {
					setprop("autopilot/settings/app5-speed-kt",cduInput);	
				}
				cduInput = "";
			}
			if (v == "B2L") {
				v = "";
				if (cduInput != "") {
					setprop("autopilot/settings/app15-speed-kt",cduInput);	
				}
				cduInput = "";
			}
			if (v == "B3L") {
				v = "";
				if (cduInput != "") {
					setprop("autopilot/settings/app39-speed-kt",cduInput);	
				}
				cduInput = "";
			}
			if (v == "B4L") {v = "";cduDisplay = "PRF-PAGE[5]"}
			if (v == "B4R") {v = "";cduDisplay = "PRF-PAGE[0]"}
		}

		if (cduDisplay == "PRF-PAGE[5]") {	
			if (v == "B2L"){
				v = "";					
				if (cduInput != "") {
					if (cduInput > 13000) { cduInput = "*FUEL MAX = 13000*"}
					else {
						setprop("consumables/fuel/tank[0]/level-lbs",cduInput*0.27);
						setprop("consumables/fuel/tank[1]/level-lbs",cduInput*0.27);
						setprop("consumables/fuel/tank[2]/level-lbs",cduInput*0.46);
					}
				}
				cduInput = "";
			}			
			if (v == "B3L"){
				v = "";
				if (cduInput != "") {
					setprop("sim/weight[2]/weight-lb",cduInput);
				}
				cduInput = "";
			}
			if (v == "B1R"){
				v = "";
				if (cduInput != "") {
					if (cduInput > 12) { cduInput = "*PASSENGERS MAX = 12*"}
					else {
						setprop("sim/weight[1]/weight-lb",cduInput*170);
					}
				}
				cduInput = "";
			}
			if (v == "B4R"){
				v = "";
					if (getprop("yasim/gross-weight-lbs") > 36100) {
						cduInput = "*GROSS WT MAX = 36100*";
					}
					else {
						cduDisplay = "PRF-PAGE[0]";
					}
			}
		}

		#### PROG PAGES ####
		if (cduDisplay == "PRG-PAGE[0]") {
			setprop("instrumentation/cdu/nbpage",3);
			if (v == "B4L") {v = "";cduDisplay = "PRG-PAGE[3]"}
#			if (v == "B4R") {v = "";cduDisplay = "CHK-LIST[0]"}
			if (v == "NAV") {v = "";cduDisplay = "NAV-PAGE[0]"}
			if (v == "FPL") {
				if (getprop("instrumentation/cdu/pos-init") == 0) {
					v = "";
					cduDisplay = "POS INIT[0]";				
				} else if (destAirport == ""){
						v = "";
						cduInput = "*NO DEST AIRPORT*";
						cduDisplay = "FLT-PLAN[0]";
				}
				else {v = "";cduDisplay = "FLT-PLAN[1]"}
			}
		}

		### CHECKLIST PAGES ###
		if (cduDisplay == "CHK-LIST[0]") {
			setprop("instrumentation/cdu/nbpage",2);
		}
		###

		setprop("/instrumentation/cdu/display",cduDisplay);
		setprop("/instrumentation/cdu/input",cduInput);
}

var insertWayp = func(ind,cduInput) {
		var wpt = getprop("autopilot/route-manager/route/wp["~ind~"]/id");
#		if (alt ==1 and find("-",wpt) != -1) {
#			setprop("autopilot/route-manager/route/wp["~ind~"]/altitude-ft", cduInput);
#		}
#		else {
		setprop("autopilot/route-manager/input","@INSERT" ~ind~ ":" ~wpt~ "@" ~cduInput);
		setprop("autopilot/route-manager/input","@DELETE"~(ind+1));
#		}
}

var correctFlp = func(fltName) {
	var filename = getprop("/sim/fg-home")~"/aircraft-data/FlightPlans/"~fltName;
	var data = io.read_properties(filename);
	var wpt = data.getValues().route.wp;
	var wps = data.getChild("route").getChildren();
	for (var n=1;n<size(wpt)-1;n+=1) {
		foreach(var name;keys(wpt[n])) {
			if (name == "departure" or name =="approach") {
				wps[n].setBoolValue(name,0);
			}
		}
	}
	io.write_properties(filename,data);
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
	if (page > 0) {
		page -= 1;
		setprop("/instrumentation/cdu/display",dspShort ~ "["~page~"]");
	}
}

var next = func {
	var page = substr(getprop("/instrumentation/cdu/display"),9,1);
	var nbPage = getprop("/instrumentation/cdu/nbpage");
	var display = getprop("instrumentation/cdu/display");
	var dspShort = left(display,8);
	var destAirport = getprop("autopilot/route-manager/destination/airport");
	var destRwy = getprop("autopilot/route-manager/destination/runway");
	if (dspShort == "FLT-PLAN") {	
		if (display == "FLT-PLAN[0]" and destAirport == "") {
			setprop("/instrumentation/cdu/input", "*NO DEST AIRPORT*");
		}
		if (display == "FLT-PLAN[1]" and destAirport != "" and destRwy == "") {
			setprop("/instrumentation/cdu/input", "*NO DEST RUNWAY*");
		}
		if (page <= 4 and getprop("autopilot/route-manager/route/num") > 0) {
			page += 1;			
			setprop("/instrumentation/cdu/display","FLT-PLAN["~page~"]");
		}		
	} else {
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
	var marker = getprop("autopilot/internal/nav-id");

	### Display ###
	var display = getprop("/instrumentation/cdu/display");
	var nrPage = getprop("/instrumentation/cdu/nrpage");

	### Réinitialisation si extinction CDU ###
	if (getprop("systems/electrical/outputs/efis") < 15 or getprop("controls/lighting/cdu") <= 0.02) {
		setprop("autopilot/route-manager/input","@CLEAR");
		setprop("autopilot/route-manager/destination/airport","");
		setprop("autopilot/route-manager/departure/airport","");
		setprop("instrumentation/cdu/display","NAVIDENT[0]");
		setprop("instrumentation/cdu/pos-init",0);
		setprop("instrumentation/cdu/input","");
		init();		
	}	
			###
	else {	
		if (left(display,8) == "NAVIDENT") {
			displaypages.navIdent();
		}

		if (left(display,8) == "POS INIT") {
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
			displaypages.fltPlan_0(dep_airport,dep_rwy,dest_airport,dest_rwy);
		}
	
		if (display == "FLT-PLAN[1]") {
			displaypages.fltPlan_1(dep_airport, dep_rwy, dest_airport, dest_rwy, num, flt_closed, marker);
		}
		if (display == "FLT-PLAN[2]") {
			displaypages.fltPlan_2(dest_airport,dest_rwy,num,flt_closed,marker);
		}
		if (display == "FLT-PLAN[3]") {
			displaypages.fltPlan_3(dest_airport,dest_rwy,num,flt_closed,marker);
		}
		if (display == "FLT-PLAN[4]") {
			displaypages.fltPlan_4(dest_airport,dest_rwy,num,flt_closed,marker);
		}

		if (display == "FLT-PLAN[5]" and num > 0) {
			displaypages.fltPlan_5(dest_airport,dest_rwy,num,marker);
		}

		if (display == "NAV-PAGE[0]") {
			displaypages.navPage_0();
		}
		if (display == "NAV-PAGE[1]") {
			displaypages.navPage_Dept(dep_airport,dep_rwy,my_lat,my_long);
		}
		if (display == "NAV-PAGE[2]") {
			displaypages.navPage_Dest(dest_airport,dest_rwy,my_lat,my_long);
		}

		if (display == "PRF-PAGE[0]") {displaypages.perfPage_0()}
		if (display == "PRF-PAGE[1]") {displaypages.perfPage_1()}
		if (display == "PRF-PAGE[2]") {displaypages.perfPage_2()}
		if (display == "PRF-PAGE[3]") {displaypages.perfPage_3()}
		if (display == "PRF-PAGE[4]") {displaypages.perfPage_4()}
		if (display == "PRF-PAGE[5]") {displaypages.perfPage_5()}

		if (display == "PRG-PAGE[0]") {displaypages.progPage_0(dest_airport,marker)}

		if (display == "CHK-LIST[0]") {displaypages.checkList_0()}
	}							
	settimer(cdu,0.2);
}

var DspSet = func(page,Dsp) {
	setprop("instrumentation/cdu/page",page);
	setprop("instrumentation/cdu/L[0]",Dsp.line1l);
	setprop("instrumentation/cdu/L[1]",Dsp.line2l);
	setprop("instrumentation/cdu/L[2]",Dsp.line3l);
	setprop("instrumentation/cdu/L[3]",Dsp.line4l);
	setprop("instrumentation/cdu/L[4]",Dsp.line5l);
	setprop("instrumentation/cdu/L[5]",Dsp.line6l);
	setprop("instrumentation/cdu/L[6]",Dsp.line7l);
	setprop("instrumentation/cdu/R[0]",Dsp.line1r);
	setprop("instrumentation/cdu/R[1]",Dsp.line2r);
	setprop("instrumentation/cdu/R[2]",Dsp.line3r);
	setprop("instrumentation/cdu/R[3]",Dsp.line4r);
	setprop("instrumentation/cdu/R[4]",Dsp.line5r);
	setprop("instrumentation/cdu/R[5]",Dsp.line6r);
	setprop("instrumentation/cdu/R[6]",Dsp.line7r);
}

setlistener("/sim/signals/fdm-initialized", func {
	init();
	cdu();
});

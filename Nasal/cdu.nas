#####################################################
# Fmz2000 - CDU System
# C. Le Moigne (clm76) - 2015 -> Canvas : 2017
######################################################

var curr_wp = "autopilot/route-manager/current-wp";
var dataLoad = "systems/electrical/outputs/data-loader";
var depAirport = "autopilot/route-manager/departure/airport";
var depRwy = "autopilot/route-manager/departure/runway";
var destAirport = "autopilot/route-manager/destination/airport";
var destRwy = "autopilot/route-manager/destination/runway";
var fp_active = "autopilot/route-manager/active";
var navSrc = "autopilot/settings/nav-source";
var num = "autopilot/route-manager/route/num";
var path = getprop("/sim/fg-home")~"/Export/FlightPlans/";
var alarm = ["instrumentation/cdu/alarms",
             "instrumentation/cdu[1]/alarms"];
var cdu_input = ["instrumentation/cdu/input",
                "instrumentation/cdu[1]/input"];
var display = ["instrumentation/cdu/display",
               "instrumentation/cdu[1]/display"];
var irs_align = ["instrumentation/irs/align",
                 "instrumentation/irs[1]/align"];
var irs_pos = ["instrumentation/irs/positionned",
               "instrumentation/irs[1]/positionned"];
var nbpage = ["instrumentation/cdu/nbpage",
              "instrumentation/cdu[1]/nbpage"];
var pos_init = ["instrumentation/cdu/pos-init",
                "instrumentation/cdu[1]/pos-init"];

var alm = [[],[]];
alm[0] = std.Vector.new();
alm[1] = std.Vector.new();
var app_id = nil;
var cduDisplay = nil;
var cduInput = "";
var cduPos = 0;
var del_length = nil;
var dist = 0;
var flp_closed = 0;
var fltName = nil;
var fltPath = nil;
var g_speed = nil;
var ind = nil;
var irsPos = nil;
var navSel = nil;
var navWp = nil;
var navRwy = nil;
var nrPage = nil;
var sid_id = nil;
var select = nil;
var virtual_point = nil;
var wpt_name = nil;
var fp = nil; # Active Flight Plan
var altFp = nil; # Alternate Flight Plan

var cduMain = {
	new: func () {
		var m = {parents:[cduMain]};
    return m;
  }, # end of new

  init : func {
	  setprop("autopilot/route-manager/flight-plan","");
    setprop("autopilot/route-manager/alternate/set-flag",0);
    setprop("autopilot/route-manager/alternate[1]/set-flag",0);
	  setprop(depAirport,getprop("/sim/airport/closest-airport-id"));
	  setprop(depRwy,getprop("sim/atc/runway"));
	  setprop("autopilot/settings/cruise-speed-kt",330);
	  setprop("autopilot/settings/cruise-speed-mc",0.88);
	  setprop("autopilot/route-manager/cruise/altitude-ft",10000);
	  setprop("autopilot/route-manager/cruise/flight-level",100);
	  setprop("autopilot/settings/asel",getprop("autopilot/route-manager/cruise/flight-level"));
	  setprop("autopilot/settings/climb-speed-kt",250);
	  setprop("autopilot/settings/climb-speed-mc",0.65);
	  setprop("autopilot/settings/descent-speed-kt",200);
	  setprop("autopilot/settings/descent-speed-mc",0.60);
	  setprop("autopilot/settings/descent-angle",3.0);
	  setprop("autopilot/settings/dep-speed-kt",200);
	  setprop("autopilot/settings/dep-agl-limit-ft",2500);
	  setprop("autopilot/settings/dep-limit-nm",4);
	  setprop("autopilot/settings/app-speed-kt",200);
	  setprop("autopilot/settings/dist-to-dest-nm",30);
	  setprop("autopilot/settings/app5-speed-kt",180);
	  setprop("autopilot/settings/app15-speed-kt",160);
	  setprop("autopilot/settings/app35-speed-kt",140);
	  setprop("autopilot/route-manager/wp/altitude-ft",0);
    setprop(display[0],"NAVIDENT");
    setprop(display[1],"NAVIDENT");

        ### Create FlightPlans path if not exists ###
    var flt_dir = os.path.new(getprop("/sim/fg-home")~"/Export/FlightPlans/create.txt");
    if (!flt_dir.exists()) flt_dir.create_dir();
  }, # end of init

  listen : func (x) {
    setlistener("instrumentation/cdu["~x~"]/init",func(n) { #### Reinit CDU ###
	    if (n.getValue()) {
		    setprop("autopilot/route-manager/input","@CLEAR");
		    setprop(destAirport,"");
		    setprop(depAirport,"");
		    setprop("autopilot/route-manager/alternate["~x~"]/airport","");
		    setprop("autopilot/route-manager/alternate["~x~"]/runway","");
		    setprop("autopilot/route-manager/alternate["~x~"]/closed",0);
		    setprop("autopilot/route-manager/alternate["~x~"]/set-flag",0);
		    setprop(display[0],"NAVIDENT");
		    setprop(display[1],"NAVIDENT");
        setprop(nbpage[x],1);
		    setprop(pos_init[x],0);
		    setprop("instrumentation/cdu["~x~"]/direct",0);
		    setprop("instrumentation/cdu["~x~"]/direct-to",-1);
		    setprop(cdu_input[x],"");
		    setprop("autopilot/locks/TOD",0);
		    setprop(navSrc, "NAV1");
		    setprop("autopilot/locks/altitude","PTCH");
		    setprop("autopilot/locks/heading","ROLL");
	      setprop(depAirport,getprop("/sim/airport/closest-airport-id"));
	      setprop(depRwy,getprop("sim/atc/runway"));
        setprop(pos_init[x],0);
        setprop(irs_pos[x],0);
        irsPos = 0;
	    }	
    },0,0);

    ### Electrical Fuses ###
		setlistener(dataLoad, func(n) {
      if (!n.getValue()) me.set_alm(x,"DB TRANSFER ABORTED");
      else me.clear_alm(x,"DB TRANSFER ABORTED");
    },0,0);

		setlistener("systems/electrical/outputs/gps"~(x+1), func(n) {
      if (!n.getValue()) me.set_alm(x,"GPS"~(x+1)~" FAILED");
      else me.clear_alm(x,"GPS"~(x+1)~" FAILED");
    },0,0);

		setlistener("systems/electrical/outputs/att-hdg"~(x+1), func(n) {
      if (!n.getValue()) me.set_alm(x,"ATT/HDG"~(x+1)~" FAILED");
      else me.clear_alm(x,"ATT/HDG"~(x+1)~" FAILED");
    },0,0);

		setlistener("systems/electrical/outputs/att-hdg-aux"~(x+1), func(n) {
      if (!n.getValue()) me.set_alm(x,"ATT/HDG"~(x+1)~" FAILED");
      else me.clear_alm(x,"ATT/HDG"~(x+1)~" FAILED");
    },0,0);

		setlistener("systems/electrical/outputs/afis", func(n) {
      if (!n.getValue()) me.set_alm(x,"AFIS DMU FAILED");
      else me.clear_alm(x,"AFIS DMU FAILED");
    },0,0);

		setlistener("instrumentation/irs["~x~"]/failure", func(n) {
      if (n.getValue()) me.set_alm(x,"IRS"~(x+1)~" FAILED");
      else me.clear_alm(x,"IRS"~(x+1)~" FAILED");
    },0,0);

		setlistener("controls/electric/stby-batt-fail", func(n) {
      if (n.getValue()) me.set_alm(x,"IRS"~(x+1)~" FAILED");
      else me.clear_alm(x,"IRS"~(x+1)~" FAILED");
    },0,0);

		setlistener("systems/electrical/outputs/nav["~x~"]", func(n) {
      setprop("instrumentation/nav["~x~"]/serviceable",n.getValue());
    },0,0);

    ### Others ###
    setlistener(irs_align[x], func(n) { ### IRS Alignment ###
      if (n.getValue()) me.set_alm(x,"POSITIONNING");
      else me.clear_alm(x,"POSITIONNING");
    },0,0);

    setlistener(irs_pos[x], func(n) { ### End of Positionning ###
      if (!getprop(irs_pos[0]) or !getprop(irs_pos[1])) irsPos = 0;
      else irsPos = 1;
    },0,0);

    setlistener(pos_init[x], func(n) { ### CDU positionned ###
	    if (n.getValue()) cduPos = 1;
    },0,0);

    setlistener(display[x],func(n) {
      cduDisplay = n.getValue();
      nrPage = size(cduDisplay)<12 ? substr(cduDisplay,9,1) : substr(cduDisplay,9,2); 
      if (left(n.getValue(),8) == "FLT-PLAN") {
        me.nb_pages(getprop(num),3,x);
        if (getprop(fp_active)) setprop(nbpage[x],getprop(nbpage[x])+1);
        setprop("instrumentation/cdu["~x~"]/fltplan",1);
      } else setprop("instrumentation/cdu["~x~"]/fltplan",0);
      if (left(n.getValue(),8) == "ALT-PAGE" and altFp != nil)
        me.nb_pages(altFp.getPlanSize(),3,x);
    },0,0);

    setlistener(fp_active, func(n) {
      me.nb_pages(getprop(num),3,x);
      if (n.getValue()) setprop(nbpage[x],getprop(nbpage[x])+1);
    },0,0);

    setlistener(num, func(n) {
      me.nb_pages(n.getValue(),3,x);
      if (getprop(fp_active)) setprop(nbpage[x],getprop(nbpage[x])+1);
    },0,0);

  }, ### end of listen

  btn : func (v,x) { ### Alphanumeric Buttons treatment
	  var n = size(getprop("/instrumentation/cdu["~x~"]/input"));
		  if (n < 13) {
			  setprop(cdu_input[x],getprop(cdu_input[x])~v);
		  }
  }, # end of btn

  key : func(v,x) { ### Keys treatment
    cduInput = getprop("/instrumentation/cdu["~x~"]/input");	
    cduDisplay = getprop("/instrumentation/cdu["~x~"]/display");
    fp = getprop("autopilot/route-manager/alternate["~x~"]/set-flag") ? altFp : flightplan();

    if (v=="FPL") {
      setprop("autopilot/route-manager/alternate["~x~"]/set-flag",0);
      cduInput = "";
      if (cduDisplay == "POS-INIT") {
# 				if (getprop(pos_init[x]) and getprop(irs_pos[x])) {
        if (cduPos) {v = "";cduDisplay = "FLT-PLAN[0]"}
      } else if (cduDisplay != "NAVIDENT") {
          v="";
          if (getprop(destAirport)) {
              ### automatic page change ###
            var page = int(getprop(curr_wp)/3)+1;
            cduDisplay = "FLT-PLAN["~page~"]";
        		setprop("/instrumentation/cdu["~x~"]/display",cduDisplay);
            setprop(curr_wp,getprop(curr_wp));
              ###
          } else {cduDisplay = "FLT-PLAN[0]"}
      }
    }
		if (v=="NAV" and cduPos) {
				v = "";
        setprop(nbpage[x],1);
				cduDisplay = "NAV-PAGE[1]";
		}		
    if (v=="PERF" and cduPos) {v="";cduDisplay = "PRF-PAGE[1]"}
		if (v=="PROG" and cduPos) {v="";cduDisplay = "PRG-PAGE[1]"}

		#### NAV-IDENT ####
		if (cduDisplay == "NAVIDENT") {
      if (v == "B4R"){
        data_load = getprop(dataLoad); # Data Loader Fuse
        v="";
        for (var i=0;i<2;i+=1){
          setprop(display[i], data_load ? "POS-INIT" : "NAVIDENT");
        }
      }
		}

		#### POS-INIT ####
		if (cduDisplay == "POS-INIT") {
		  if (v == "B1R" or v == "B2R" or v == "B3R" and irsPos) {	
         setprop(pos_init[0],1);setprop(pos_init[1],1);cduPos = 1;
      }
		  if (v == "B4R" and cduPos) cduDisplay = "FLT-PLAN[0]";
      setprop(display[0],cduDisplay); setprop(display[1],cduDisplay);
		}

		#### FLT-LIST ####
		if (left(cduDisplay,8) == "FLT-LIST") {
			if (v=="B4L") {
        v="";cduInput=""; 
        me.clear_alm(0,"NO FILE");me.clear_alm(1,"NO FILE");    
        cduDisplay = getprop(destAirport) ? "FLT-PLAN[1]":"FLT-PLAN[0]";
			} else {
        me.lineSelect(v);
				if (getprop("instrumentation/cdu["~x~"]/"~select) !="") {
          navSel = getprop("instrumentation/cdu["~x~"]/"~select);
          setprop("autopilot/route-manager/flight-plan",navSel);
          me.load_flightplan();
					var data = io.read_properties(fltPath);
					sid_id = data.getChild("departure").getValue("sid");
					app_id = data.getChild("destination").getValue("approach");
					v = "";	
					cduDisplay = "FLT-PLAN[1]";
					cduInput ="";
				}
			}
      setprop(display[0],cduDisplay);setprop(display[1],cduDisplay);
		}

		#### DEPARTURE ####
		if (left(cduDisplay,8) == "FLT-DEPT") {
			if (v == "B4R") {v = "";cduInput = "";cduDisplay = "FLT-PLAN[1]"}
			else if (v == "B4L") {v = "";cduInput = "";cduDisplay = "FLT-SIDS[1]"}
			else {
        me.lineSelect(v);
				if (getprop("instrumentation/cdu["~x~"]/"~select) !="") {
					setprop(depRwy,getprop("instrumentation/cdu["~x~"]/"~select));
					cduInput = "RWY " ~ getprop(depRwy) ~ " Loaded";
				}
			}
		}

		#### SIDS ####
		if (left(cduDisplay,8) == "FLT-SIDS") {
			if (v == "B4L") {v = "";cduInput = "";cduDisplay = "FLT-PLAN[1]"}
			else if (v != "") {
        if (!getprop(fp_active)) {
          me.lineSelect(v);
				  if (getprop("instrumentation/cdu["~x~"]/"~select) !="") {
					  var SidName = getprop("instrumentation/cdu["~x~"]/"~select);
					  fp.sid = SidName;
					  setprop("/autopilot/route-manager/departure/sid",SidName);
    				cduInput = getprop("/autopilot/route-manager/departure/sid") ~ " Loaded";
          }
        } else {cduInput = "FLT PLAN CLOSED"}
			}
		}

		#### ARRIVAL ####
		if (left(cduDisplay,8) == "FLT-ARRV") {
				if (v == "B1L") {v="";cduDisplay = "FLT-ARWY[1]"}
				if (v == "B2L") {v="";cduDisplay = "FLT-STAR[1]"}
				if (v == "B3L") {v="";cduDisplay = "FLT-APPR[1]"}
				if (v == "B4L")	{v="";cduDisplay = "FLT-PLAN[1]"}
		}
		if (left(cduDisplay,8) == "FLT-ARWY") {
			if (v == "B4L") {
				cduInput = "";
        if (getprop("autopilot/route-manager/alternate["~x~"]/set-flag")) {v="";cduDisplay = "ALT-PAGE[1]"}
        else {v="";cduDisplay = "FLT-ARRV[1]"}
			}
			else if (v != "") {
        me.lineSelect(v);
				if (getprop("instrumentation/cdu["~x~"]/"~select) !="") {
          if (getprop("autopilot/route-manager/alternate["~x~"]/set-flag")) {
            setprop("autopilot/route-manager/alternate["~x~"]/runway",getprop("instrumentation/cdu["~x~"]/"~select));
          } else {
  					setprop(destRwy,getprop("instrumentation/cdu["~x~"]/"~select));
          }
					cduInput = "RWY "~getprop("instrumentation/cdu["~x~"]/"~select)~" Loaded";
				}
			}
		}

		#### STARS ####
		if (left(cduDisplay,8) == "FLT-STAR") {		
			if (v == "B4L") {v = "";cduInput = "";cduDisplay = "FLT-ARRV[1]"}
			else if (v == "B4R") {v = "";cduInput = "";cduDisplay = "FLT-ARWY[1]"}
			else if (procedures.fmsDB.new(getprop(destAirport)) == nil) {
				cduInput = "NO STARS FOUND";
			}
      else if (getprop("/autopilot/route-manager/destination/runway") == "") {
        cduInput = "NO DEST RUNWAY";
      }
			else if (v != "") {
        if (!getprop(fp_active)) {
          me.lineSelect(v);
				  if (getprop("instrumentation/cdu["~x~"]/"~select) !="") {
					  var StarName = getprop("instrumentation/cdu["~x~"]/"~select);
					  fp.star = StarName;
					  setprop("/autopilot/route-manager/destination/star",StarName);
					  cduInput = getprop("autopilot/route-manager/destination/star") ~ " Loaded";
				  }			
        } else {cduInput = "FLT PLAN CLOSED"}
			}
		}

		#### APPROACH ####
		if (left(cduDisplay,8) == "FLT-APPR") {	
			if (v == "B4L") {v = "";cduInput = "";cduDisplay = "FLT-ARRV[1]"}
			else if (v == "B4R") {v = "";cduInput = "";cduDisplay = "FLT-ARWY[1]"}
      else if (getprop("/autopilot/route-manager/destination/runway") == "") {
        cduInput = "NO DEST RUNWAY";
      }
			else if (v != "") {
        if (!getprop(fp_active)) {
          me.lineSelect(v);
				  if (getprop("instrumentation/cdu["~x~"]/"~select) !="") {			
					  var ApprName = getprop("instrumentation/cdu["~x~"]/"~select);
            var n = 99;
					  fp.approach = ApprName;

            #### Delete Wp after Dest Airport ####
            for (var i=1;i<fp.getPlanSize();i+=1) {
              if (left(fp.getWP(i).wp_name,4) == destAirport) {
                var n = fp.getWP(i).index;             
              }
              if (fp.getWP(i).index > n){
                setprop("autopilot/route-manager/input","@DELETE"~i);
                i-=1;
              }
            }
            ####

					  setprop("autopilot/route-manager/destination/approach",ApprName);
    				cduInput = getprop("autopilot/route-manager/destination/approach") ~ " Loaded";
          }
        } else {cduInput = "FLT PLAN CLOSED"}
			}
		}

		#### FLT-PLAN ####
    if (cduDisplay == "FLT-PLAN[0]") {
      if (v == "B2L" or v == "B4L") {v = "";cduDisplay = "FLT-LIST[1]"}
      if (getprop(destAirport)) cduDisplay = "FLT-PLAN[1]";
      else {
        if (v == "B2R" and cduInput) {
          var dest = findAirportsByICAO(cduInput);
          if (size(dest) == 1) {
            fp.destination = airportinfo(cduInput);
			      setprop(destAirport,cduInput);
			      cduInput = "";
			      cduDisplay = "FLT-PLAN[1]";
#            setprop(display[x],cduDisplay);
          } else {cduInput = "NOT AN AIRPORT"}
        }
      }
      setprop(display[0],cduDisplay); setprop(display[1],cduDisplay);      
    }
		else if (left(cduDisplay,8) == "FLT-PLAN") {
      nrPage = size(cduDisplay)<12 ? substr(cduDisplay,9,1) : substr(cduDisplay,9,2); 
			if (v == "B1L" or v == "B2L" or v == "B3L") {
        ind = nrPage*3-(3-substr(v,1,1))-1;
        if (ind == 0 and cduInput != getprop(depAirport)) cduInput = "";
				if (cduInput == getprop(destAirport) and cduInput) {
					setprop("autopilot/route-manager/input","@ACTIVATE");		
          setprop("autopilot/route-manager/flight-plan",getprop(depAirport)~"-"~getprop(destAirport));
          nrPage+=1;
					cduInput = "";
					cduDisplay = "FLT-PLAN["~(getprop(nbpage[x]))~"]";
				} 
				if (cduInput == "DELETE") {
					if (ind == 0 or ind == -3) {
						setprop(depAirport,"");
						setprop("autopilot/route-manager/input","@CLEAR");
						cduInput = "";
						cduDisplay = "FLT-PLAN[0]";
					}
          wpt_name = fp.getWP(ind).wp_name;
          virtual_point = 0;
          if (size(wpt_name) == 8 and (left(wpt_name,1) == "E"
              or left(wpt_name,1) == "W")
              and (substr(wpt_name,4,1) == "N"
              or substr(wpt_name,4,1) == "S")) {
              virtual_point = 1;
          }
          if (ind == getprop(num)-1) {
					  setprop(fp_active,0);
					  cduInput = "";
    			}	else if (getprop(fp_active)) {
              if (fp.getWP(ind).wp_type == "offset-navaid" or virtual_point) {
					      setprop("autopilot/route-manager/input","@DELETE"~ind);
					      cduInput = "";
    					  setprop(fp_active,1); # to recreate TOD
              } else {cduInput = "FLT PLAN CLOSED"}
  				} else {
					  setprop("autopilot/route-manager/input","@DELETE"~ind);
					  cduInput = "";
          }
				}
				else if (getprop(depAirport) == "") {
					setprop(depAirport, cduInput);
					cduInput = "";
				}
				else if (getprop(depRwy) == "") {
					cduInput = "ENTER DEP RWY";
				}
				else if (getprop(destAirport) == "") {
					cduInput = "ENTER DEST AIRPORT";
				}
				else if (getprop(destRwy) == "") {
					cduInput = "ENTER DEST RWY";
				}
				else if (!getprop(fp_active) or find("/",cduInput) != -1) {
          var spl = split("//",cduInput);
          if (size(spl) == 2) {
            if (spl[0] >= -180 and spl[0] <= 180 and spl[1] >= -90 and spl[1] <= 90)
            cduInput = spl[0]~","~spl[1];
          }
					setprop("autopilot/route-manager/input","@INSERT"~ind~":"~cduInput);
          if (getprop(fp_active)){setprop(fp_active,1)} # to recreate TOD
					cduInput = "";						
				}
				else if (getprop(fp_active)) {
          if (getprop("instrumentation/cdu["~x~"]/direct")) {
            if (fp.getWP(ind).wp_name != "TOD") {setprop("instrumentation/cdu["~x~"]/direct-to",ind)}
            else {setprop("instrumentation/cdu["~x~"]/direct-to",ind+1)}
            var dir_wp = fp.getWP(getprop("instrumentation/cdu["~x~"]/direct-to")).wp_name;
            var currWp = getprop(curr_wp);
            for (var i=currWp;i<fp.getPlanSize()-1;i+=1) {
              if (fp.getWP(i).wp_name == dir_wp) {break}
              else {fp.deleteWP(i);i-=1}
            }
            setprop(fp_active,1); # to recreate TOD
            setprop(curr_wp,currWp);
          } else if (cduDisplay != "FLT-PLAN["~getprop(nbpage[x])~"]") {
              cduInput = "FLT PLAN CLOSED";
          }
				}
			}

			if (v == "B4L") {
			  if (getprop(fp_active) and nrPage == getprop(nbpage[x])) {
          v="";
          cduDisplay = "PRF-PAGE[1]";
        }
        else {v="";cduDisplay = "FLT-DEPT[1]"}
      }

			if (v == "B1R") {
				if (left(cduDisplay,8) == "FLT-PLAN" and nrPage > 1) {
          ind = nrPage*3-(3-substr(v,1,1))-1;
          if (left(fp.getWP(ind).wp_name,4) != getprop(destAirport)) {
  					me.insertWayp(ind,cduInput,fp,x);
          }
					cduInput = "";
				}
			}

			if (v == "B2R") {
        ind = nrPage*3-(3-substr(v,1,1))-1;
			  if (nrPage == getprop(nbpage[x])) {
					if (!getprop(depAirport)){cduInput = "NO DEPT AIRPORT"}
				  else if (getprop(depRwy)=="") {cduInput = "NO DEPT RUNWAY"}
					else if (getprop(destRwy)=="") {cduInput = "NO DEST RUNWAY"}
          else if (getprop(fp_active)) {
					  if (size(cduInput) > 2) {cduInput = left(cduInput,2)}
					  fltName = getprop(depAirport)~"-"~getprop(destAirport)~cduInput;
					  fltPath = path~fltName~".xml";
					  setprop("autopilot/route-manager/file-path",fltPath);
					  me.save_flightplan(fltPath);
            setprop(fp_active,1); # to recreate tod after saving fp (Fms listen)
					  setprop("autopilot/route-manager/flight-plan",fltName);
					  cduInput = "";
          } else if (left(fp.getWP(ind).wp_name,4) != getprop(destAirport)) {
              me.insertWayp(ind,cduInput,fp,x);
          }
        } else if (left(fp.getWP(ind).wp_name,4) != getprop(destAirport)) {
				      me.insertWayp(ind,cduInput,fp,x);
				}
        cduInput = "";
			}

			if (v == "B3R") {
        ind = nrPage*3-(3-substr(v,1,1))-1;
				if (nrPage > 0 and nrPage <= getprop(nbpage[x])) {					if (ind == getprop(num)-1 and cduInput == "DELETE") {
							setprop(destAirport,"");
							cduInput = "";
							cduDisplay = "FLT-PLAN[0]";
          } else if (ind >= getprop(num)-1) {
							if (getprop(destRwy)== "") {
								cduInput = "NO DEST RUNWAY";
							} else {cduInput = getprop(destAirport)}
					}	else if (left(fp.getWP(ind).wp_name,4) != getprop(destAirport)) {
					      me.insertWayp(ind,cduInput,fp,x);
					}
				}			
			}

			if (v == "B4R") {
        if (nrPage == getprop(nbpage[x]) and getprop(fp_active)) {
          v = "";
          setprop(nbpage[x],1);
          if (getprop("autopilot/route-manager/alternate["~x~"]/airport") and getprop("autopilot/route-manager/alternate["~x~"]/runway")) {
				    cduDisplay = "ALT-PAGE[1]";
          } else {cduDisplay = "ALT-PAGE[0]"}
        } else {v="";cduInput="";cduDisplay = "FLT-ARRV[1]"}
			}
		}		
    #### ALTERNATE Flight Plan ####
    if (cduDisplay == "ALT-PAGE[0]") {	
      nrPage = 1;
      if (v == "B2R" and cduInput) {
        v = "";
        altFp = createFlightplan();       
        altFp.departure = airportinfo(getprop(depAirport));
        var dest = findAirportsByICAO(cduInput);
        if (size(dest) == 1) {
          altFp.destination = airportinfo(cduInput);
			    setprop("autopilot/route-manager/alternate["~x~"]/airport",cduInput);
          cduInput = "";
          cduDisplay = "ALT-PAGE[0]";
        } else {cduInput = "NOT AN AIRPORT"}
      }
      if (v == "B4R") {
        v="";
        cduInput="";
        if (getprop("autopilot/route-manager/alternate["~x~"]/airport")) {
					setprop("autopilot/route-manager/alternate["~x~"]/set-flag",1);
					cduDisplay = "FLT-ARWY[1]";
				}
      }
    }
    else if (left(cduDisplay,8) == "ALT-PAGE") {	
      nrPage = size(cduDisplay)<12 ? substr(cduDisplay,9,1) : substr(cduDisplay,9,2); 
			if (v == "B1L" or v == "B2L" or v == "B3L") {
        ind = nrPage*3-(3-substr(v,1,1))-1;
        var wpCurr = getprop(curr_wp);        
				if (cduInput == getprop("autopilot/route-manager/alternate["~x~"]/airport")) {
					setprop("autopilot/route-manager/alternate["~x~"]/closed",1);		
					cduInput = "";
					cduDisplay = "ALT-PAGE["~(getprop(nbpage[x]));
				} 
				if (cduInput == "DELETE") {
          if (ind == altFp.getPlanSize()-1) {
					  setprop("autopilot/route-manager/alternate["~x~"]/closed",0);
					  cduInput = "";
    			}	else if (getprop("autopilot/route-manager/alternate["~x~"]/closed")) {
            cduInput = "ALT FPL CLOSED";
  				} else {
					  altFp.deleteWP(ind);
					  cduInput = "";
          }
				}
				else if (!getprop("autopilot/route-manager/alternate["~x~"]/closed")) {
          var navaid = findNavaidsByID(cduInput);
          if (size(navaid) > 0) {
            navaid = navaid[0];
            var wp = createWPFrom(navaid);
            altFp.insertWP(wp,ind);
          } else {          
            var navaid = findFixesByID(cduInput);
            if (size(navaid) > 0) {
              navaid = navaid[0];
              var wp = createWPFrom(navaid);
              altFp.insertWP(wp,ind);
            }
          }
					cduInput = "";						
				}
				else if (getprop("autopilot/route-manager/alternate["~x~"]/closed")) {
          if (getprop("instrumentation/cdu["~x~"]/direct")) {
            setprop("instrumentation/cdu["~x~"]/direct-to",ind);
            fp = flightplan();
            while(fp.getPlanSize() != wpCurr) {
              fp.deleteWP(fp.getPlanSize()-1);
            }
            for (var i=ind;i<altFp.getPlanSize()-1;i+=1) {
              if (altFp.getWP(i).alt_cstr > 0) {
  		          setprop("autopilot/route-manager/input","@INSERT"~(wpCurr+i)~":"~altFp.getWP(i).wp_name~"@"~altFp.getWP(i).alt_cstr);
              } else {
  		          setprop("autopilot/route-manager/input","@INSERT"~(wpCurr+i)~":"~altFp.getWP(i).wp_name);
              }
#              fp.insertWP(altFp.getWP(i),wpCurr+i);
              call(func {fp.getWP(wpCurr).setSpeed(altFp.getWP(i).speed_cstr,'at')},nil,var err = []);
            }
            setprop(destAirport,getprop("autopilot/route-manager/alternate["~x~"]/airport"));
            setprop(destRwy,getprop("autopilot/route-manager/alternate["~x~"]/runway"));
            setprop("autopilot/route-manager/destination/approach","DEFAULT");
            setprop(fp_active,1); # to create new TOD
            setprop("autopilot/route-manager/alternate["~x~"]/set-flag",0);
            setprop("instrumentation/cdu["~x~"]/direct",0);
            setprop("instrumentation/cdu["~x~"]/direct-to",-1);
        		setprop(display[x],"FLT-PLAN[1]");
            setprop(curr_wp,wpCurr); # for automatic page change
          }
          else if (cduDisplay != "ALT-PAGE["~getprop(nbpage[x])) {
              cduInput = "ALT FPL CLOSED";
          }
				}
			}

			if (v == "B4L") {
        v = ""; cduInput = "";
        setprop("autopilot/route-manager/alternate["~x~"]/set-flag",0);
        cduDisplay = "FLT-PLAN[1]";
      }

			if (v == "B1R") {
        v = "";
				if (left(cduDisplay,8) == "ALT-PAGE" and nrPage > 1) {
          ind = nrPage*3-(3-substr(v,1,1))-1;
          if (left(altFp.getWP(ind).wp_name,4) != getprop("autopilot/route-manager/alternate["~x~"]/airport")) {
  					me.insertWayp(ind,cduInput,altFp,x);
          }
					cduInput = "";
				}
        cduDisplay = "ALT-PAGE["~nrpage~"]";
			}

			if (v == "B2R") {
        ind = nrPage*3-(3-substr(v,1,1))-1;
          if (left(altFp.getWP(ind).wp_name,4) != getprop("autopilot/route-manager/alternate["~x~"]/airport")) {
              me.insertWayp(ind,cduInput,altFp,x);
          }
        cduInput = "";
        cduDisplay = "ALT-PAGE["~nrPage~"]";
			}

			if (v == "B3R") {
        ind = nrPage*3-(3-substr(v,1,1))-1;
				if (nrPage > 0 and nrPage <= getprop(nbpage[x])) {
					if (ind == altFp.getPlanSize()-1 and cduInput == "DELETE") {
            altFp.cleanPlan();
            altFp.deleteWP(1);
						setprop("autopilot/route-manager/alternate["~x~"]/airport","");
            setprop("autopilot/route-manager/alternate["~x~"]/runway","");
            setprop("autopilot/route-manager/alternate["~x~"]/closed",0);
            v="";
						cduInput = "";
						cduDisplay = "ALT-PAGE[0]";
          } else if (ind >= altFp.getPlanSize()-1) {
							cduInput = getprop("autopilot/route-manager/alternate["~x~"]/airport");
              cduDisplay = "ALT-PAGE["~nrPage~"]";
					}	else if (left(altFp.getWP(ind).wp_name,4) != getprop("autopilot/route-manager/alternate["~x~"]/airport")) {
					      me.insertWayp(ind,cduInput,altFp,x);
                cduDisplay = "ALT-PAGE["~nrPage~"]";
					}
				}			
			}

			if (v == "B4R") {
        v = "";
        if (nrPage > 0 and nrPage < getprop(nbpage[x])) {
          cduDisplay = "ALT-PAGE["~(nrPage+1)~"]";
        }
      }
    } # end of alternate FP

		#### NAV PAGES ####
		if (cduDisplay == "NAV-PAGE[1]") {		
      cduInput = "";
			if (v == "B1L") {v = "";cduDisplay = "NAV-LIST[1]"}
#			if (v == "B2L") {v = "";cduDisplay = "NAV-WPTL[1]"}
#			if (v == "B3L") {v = "";cduDisplay = "NAV-DEPT[1]"}
#			if (v == "B4L" or v == "B4R") {v = "";cduDisplay = "NAV-PAGE[2]"}
#			if (v == "B1R") {v = "";cduDisplay = "NAV-FSEL[1]"}
#			if (v == "B2R") {v = "";cduDisplay = "NAV-DATB[1]"}
#			if (v == "B3R") {v = "";cduDisplay = "NAV-ARRV[1]"}
		}

		if (left(cduDisplay,8) == "NAV-LIST") {
      if (v) {
        select = nil;
			  me.lineSelect(v);
			  if (v == "B4R" and cduInput) {v="";cduDisplay = "NAV-SELT[1]"}
        if (select) {
			    if (getprop("instrumentation/cdu["~x~"]/"~select) !="") {
            cduInput = getprop("instrumentation/cdu["~x~"]/"~select);
            navSel = cduInput;
          }
        }
      }
		}

		if (cduDisplay == "NAV-SELT[1]") {
      cduInput = "";
			if (v == "B1L") {
        navWp = std.Vector.new();
        navRwy = std.Vector.new(["",""]);
        g_speed = 330;
		    flp_closed = 0;
		    var path = getprop("/sim/fg-home")~"/Export/FlightPlans/";
		    fltName = path~navSel~".xml";
		    var x_file = subvec(directory(path),2);
		    var v = std.Vector.new(x_file);
		    if (v.contains(navSel~".xml")) {
			    var data = io.read_properties(fltName);
			    var dep_rwy = data.getChild("departure").getValue("runway");
			    navWp.append(left(navSel,4));
			    navRwy.vector[0] = dep_rwy;
			    var wpt = data.getValues().route.wp;
			    var wps = data.getChild("route").getChildren();
			    for (var n=1;n<size(wpt)-1;n+=1) {
				    foreach (var name;keys(wpt[n])) {
					    if (wps[n].getValue("type") == "navaid" and name == "ident") {
						    navWp.append(wps[n].getValue(name));
					    }
				    }
			    }
			    var dest_rwy = data.getChild("destination").getValue("runway");
			    navWp.append(substr(navSel,5,4));
			    navRwy.vector[1] = dest_rwy;
		    } else {
			    navWp.append(left(navSel,4));
			    navWp.append(substr(navSel,5,4));
  		  }
  		  dist = me.calc_dist(navWp,dist);
        cduDisplay = "NAV-SELT[2]";
      }
      if (v == "B4R") {v = "";cduDisplay = "NAV-SELT[3]"}
		}

		if (cduDisplay == "NAV-SELT[2]") {
			if (v == "B4L") {v = "";cduDisplay = "NAV-LIST[1]"}
      if (v == "B4R") {v = "";cduDisplay = "NAV-SELT[3]"}
      cduInput = "";
		}

		if (cduDisplay == "NAV-SELT[3]") {
      fp = flightplan();
			if (v == "B4L") {v = "";cduInput = "";cduDisplay = "NAV-LIST[1]"}
      if (v == "B1R") {
        v = "";
				cduInput = "";
        if (getprop(fp_active)) {cduDisplay = "NAV-ACTV[1]"}
        else {me.load_flightplan()}
      }         
      if (v == "B2R") {
        v = "";
        if (getprop(fp_active)) {
          if (navSel == getprop("autopilot/route-manager/flight-plan")) {
						setprop(fp_active,0);
						cduInput = "FLT PLAN DEACTIVATED";
          } else {cduInput = "NOT THE ACTIVE FLT PLAN"}
        }
        else {cduInput = "NO FLT PLAN ACTIVATED"}
      }
      if (v == "B3R") {
        v = "";
        cduDisplay = "PRF-PAGE[1]";
      }
    }

 		if (cduDisplay == "NAV-ACTV[1]") {
      if (v == "B4L") {v = "";cduDisplay = "NAV-SELT[3]"}        
      if (v == "B4R") {v = "";me.load_flightplan();cduDisplay = "NAV-SELT[3]"}
    }

		#### PERF PAGES ####
		if (cduDisplay == "PRF-PAGE[1]") {
      cduInput = "";
			setprop(nbpage[x],5);
			if (v == "B4L") {
        v = "";
        cduDisplay = getprop(destAirport) ? "FLT-PLAN[1]" : "FLT-PLAN[0]";
      }
			if (v == "B2R"){
				v = "";
				setprop("sim/multiplay/callsign",cduInput);
        setprop("/instrumentation/cdu["~x~"]/display","PRF-PAGE[1]");
				cduInput = "";
			}
			if (v == "B4R") {v = "";cduDisplay = "PRF-PAGE[2]"}
    }
		if (cduDisplay == "PRF-PAGE[2]") {	
		  if (v == "B1L") {
			  v = "";
			  if (cduInput) {
				  if (left(cduInput,2) < 1) {
            cduInput = (cduInput < 0.40 ? 0.40 : cduInput > 0.92 ? 0.92 : cduInput);
					  setprop("autopilot/settings/climb-speed-mc",cduInput);				
				  } else if (cduInput > 100) {
						  setprop("autopilot/settings/climb-speed-kt",cduInput > 330 ? 330 : cduInput);
				  }					
			  }
			  cduInput = "";
		  }
		  if (v == "B2L") {
			  v = "";
			  if (cduInput) {
				  if (left(cduInput,2) < 1) {
            cduInput = (cduInput < 0.40 ? 0.40 : cduInput > 0.92 ? 0.92 : cduInput);
					  setprop("autopilot/settings/cruise-speed-mc",cduInput);
				  } else if(cduInput > 100) {
						  setprop("autopilot/settings/cruise-speed-kt",cduInput > 330 ? 330 : cduInput);
				  }					
			  }
			  cduInput ="";
		  }
		  if (v == "B2R") {
			  v = "";
        if (cduInput) {
          cduInput = (cduInput > 510 ? 510 : cduInput);
		      setprop("autopilot/settings/asel",cduInput);
		      cduInput = "";
        }
		  }
		  if (v == "B3L") {
			  v = "";
			  if (cduInput) {
				  if (cduInput < 1) {
            cduInput = (cduInput < 0.40 ? 0.40 : cduInput > 0.92 ? 0.92 : cduInput);
					  setprop("autopilot/settings/descent-speed-mc",cduInput);
          } else if (cduInput >= 3 and cduInput <= 5) {
					  setprop("autopilot/settings/descent-angle",cduInput);
				  } else if (cduInput > 100) {
						  setprop("autopilot/settings/descent-speed-kt",cduInput > 330 ? 330 : cduInput);
				  }					
			  }
			  cduInput = "";
		  }
      setprop("/instrumentation/cdu["~x~"]/display","PRF-PAGE[2]");      
		  if (v == "B4L"){v = "";cduDisplay = "PRF-PAGE[3]"}
    }

		if (cduDisplay == "PRF-PAGE[3]") {	
			if (v == "B1L") {
				v = "";
				if (cduInput) {
					setprop("autopilot/settings/dep-speed-kt",cduInput > 330 ? 330 : cduInput);	
				}
				cduInput = "";
			}
			if (v == "B2L") {
				v = "";
				if (cduInput) {
					setprop("autopilot/settings/dep-agl-limit-ft",cduInput);	
				}
				cduInput = "";
			}
			if (v == "B2R") {
				v = "";
				if (cduInput) {
					setprop("autopilot/settings/dep-limit-nm",cduInput);	
				}
				cduInput = "";
			}
      setprop("/instrumentation/cdu["~x~"]/display","PRF-PAGE[3]");      
			if (v == "B4L") {v = "";cduDisplay = "PRF-PAGE[4]"}
			if (v == "B4R") {v = "";cduDisplay = "PRF-PAGE[1]"}
		}

		if (cduDisplay == "PRF-PAGE[4]") {	
			if (v == "B1L") {
				v = "";
				if (cduInput) {
					setprop("autopilot/settings/app5-speed-kt",cduInput > 250 ? 250 : cduInput);	
				}
				cduInput = "";
			}
			if (v == "B2L") {
				v = "";
				if (cduInput) {
					setprop("autopilot/settings/app15-speed-kt",cduInput > 210 ? 210 : cduInput);	
				}
				cduInput = "";
			}
			if (v == "B3L") {
				v = "";
				if (cduInput) {
					setprop("autopilot/settings/app35-speed-kt",cduInput > 180 ? 180 : cduInput);	
				}
				cduInput = "";
			}
      setprop("/instrumentation/cdu["~x~"]/display","PRF-PAGE[4]");      
			if (v == "B4L") {v = "";cduDisplay = "PRF-PAGE[5]"}
			if (v == "B4R") {v = "";cduDisplay = "PRF-PAGE[1]"}
		}

		if (cduDisplay == "PRF-PAGE[5]") {	
			if (v == "B2L"){
				v = "";					
				if (cduInput) {
					if (cduInput > 13000) {cduInput = "FUEL MAX = 13000"}
					else {
						setprop("consumables/fuel/tank[0]/level-lbs",cduInput*0.27);
						setprop("consumables/fuel/tank[1]/level-lbs",cduInput*0.27);
						setprop("consumables/fuel/tank[2]/level-lbs",cduInput*0.23);
						setprop("consumables/fuel/tank[3]/level-lbs",cduInput*0.23);
					}
				}
				cduInput = "";
			}			
			if (v == "B3L"){
				v = "";
				if (cduInput) {
					setprop("sim/weight[2]/weight-lb",cduInput);
				}
				cduInput = "";
			}
			if (v == "B1R"){
				v = "";
				if (cduInput) {
					if (cduInput > 8) {cduInput = "PASSENGERS MAX = 8"}
					else {
						setprop("sim/weight[1]/weight-lb",cduInput*170);
            cduInput = "";
					}
				}
			}
      setprop("/instrumentation/cdu["~x~"]/display","PRF-PAGE[5]");      
			if (v == "B4R"){
				v = "";
					if (getprop("yasim/gross-weight-lbs") > 36100) {
						cduInput = "GROSS WT MAX = 36100";
					}
					else {
						cduDisplay = "PRF-PAGE[1]";
            cduInput = "";
					}
			}
		}

		#### PROG PAGES ####
		if (cduDisplay == "PRG-PAGE[1]") {
			setprop(nbpage[x],3);
			if (v == "B4L") {v = "";cduDisplay = "PRG-PAGE[2]"}
			if (v == "B4R") {v = "";cduDisplay = "PRG-PAGE[3]"}
    } else if (left(cduDisplay,8) == "PRG-PAGE") {
			if (v == "B4L") {v = "";cduInput = "";cduDisplay = "PRG-PAGE[1]"}
      else if (v != "B4R") {
        me.lineSelect(v);
			  if (getprop("instrumentation/cdu["~x~"]/"~select) !="") {
          var freq_sel = getprop("instrumentation/cdu["~x~"]/"~select);
          if (cduDisplay == "PRG-PAGE[2]") {
            setprop("instrumentation/nav/frequencies/selected-mhz",freq_sel);
          } 
          if (cduDisplay == "PRG-PAGE[3]") {
            setprop("instrumentation/nav[1]/frequencies/selected-mhz",freq_sel);
          }
          cduInput = sprintf("%.3f",freq_sel)~" LOADED";
        }
      }
    }

    #### FINAL ####
		setprop(display[x],cduDisplay);
		setprop("/instrumentation/cdu["~x~"]/input",cduInput);
  }, # end of key

  ####### Common Functions ######

  lineSelect : func(v) {
    for (var i = 1;i<4;i+=1) {
      if (v == "B"~i~"L"){select = "l"~i}
    }
    for (var i = 1;i<4;i+=1) {
      if (v == "B"~i~"R"){select = "l"~(i+3)}
    }
  }, # end of lineSelect

  nb_pages : func (nbFiles,nb,x) {
		setprop(nbpage[x],math.ceil(nbFiles/nb));
  }, # end of nb_pages

  insertWayp : func(ind,cduInput,fp,x) {
    cduInput = left(cduInput,2) == "FL" ? substr(cduInput,2,3)*100 : cduInput;
#    var wpt = fp.getWP(ind).wp_name;
    var wp_spd = fp.getWP(ind).speed_cstr;

	  if (cduInput and cduInput <= 400) { ### Speed
      call(func {fp.getWP(ind).setSpeed(cduInput,'at')},nil,var err = []);
      wp_spd = fp.getWP(ind).speed_cstr;
      setprop("instrumentation/cdu["~x~"]/speed",1);
    } else { ### Altitude
        if (getprop("autopilot/route-manager/alternate["~x~"]/set-flag")) {
          call(func {fp.getWP(ind).setAltitude(cduInput,'at')},nil,var err = []);
        } else {
            call(func {fp.getWP(ind).setAltitude(cduInput,'at')},nil,var err = []);
          if (fp.getWP(ind).alt_cstr > getprop("autopilot/settings/asel")/100 and getprop(fp_active)) {
            setprop("autopilot/settings/asel",fp.getWP(ind).alt_cstr/100);
          }
        }
      call(func {fp.getWP(ind).setSpeed(wp_spd,'at')},nil,var err = []);
      setprop("instrumentation/cdu["~x~"]/speed",1);
    }
  }, # end of insertWayp

  load_flightplan : func {
	  fltPath = path ~ navSel~".xml";
	  setprop("autopilot/route-manager/file-path",fltPath);
	  setprop("autopilot/route-manager/input","@LOAD");							
	  setprop("autopilot/route-manager/input","@ACTIVATE");	
  }, # end of load_flightplan

  save_flightplan : func(fltPath) {
	  fp = flightplan();
	  fp.clearWPType('pseudo');
	  var data = props.Node.new({
		  version : 2,
		  destination : {
			  airport : fp.destination.id,
			  runway : fp.destination_runway.id,
			  approach : app_id
		  },
		  departure : {
			  airport : fp.departure.id,
			  runway : fp.departure_runway.id,
			  sid : sid_id
		  },
		  route : {
			  wp : {
				  type : "runway",
				  departure : "true",
				  ident : fp.departure_runway.id,
				  icao : fp.departure.id
			  }
		  }
	  });
	  for (var i=1;i<fp.getPlanSize()-1;i+=1) {
		  var fp_data = {
			  type : fp.getWP(i).wp_type,
			  generated : "true",
			  'alt-restrict' : fp.getWP(i).alt_cstr_type,
			  'altitude-ft' : fp.getWP(i).alt_cstr,
			  ident : fp.getWP(i).wp_name,
			  lon : fp.getWP(i).wp_lon,
			  lat : fp.getWP(i).wp_lat
		  };
		  data.getChild("route").addChild("wp").setValues(fp_data);
	  }
	  var last_wp = {
		  type : "runway",
		  approach : "true",
		  ident : fp.destination_runway.id,
		  icao : fp.destination.id
	  };
	  data.getChild("route").addChild("wp").setValues(last_wp);
	  io.write_properties(fltPath,data);
  }, # end of save_flightplan

  calc_dist : func(navWp,dist) {
	  var apt_dep = airportinfo(left(navWp.vector[0],4));
	  var apt_dest = airportinfo(left(navWp.vector[size(navWp.vector)-1],4));
	  if (size(navWp.vector) == 2) {
		  var (course,dist) = courseAndDistance(apt_dep,apt_dest);	
	  }else if (size(navWp.vector) == 3){
		  var wp = findNavaidsByID(navWp.vector[1]);		
		  wp = wp[0];
		  var (course,dist1) = courseAndDistance(apt_dep,wp);
		  var (course,dist2) = courseAndDistance(apt_dest,wp);
		  dist = dist1+dist2;
	  } else {
			  dist = 0;
			  for (var i=1;i<size(navWp.vector)-2;i+=1) {
				  var wp1 = findNavaidsByID(navWp.vector[i]);
				  wp1 = wp1[0];
				  if (i == 1) {var wp_first = wp1}
				  var wp2 = findNavaidsByID(navWp.vector[i+1]);
				  wp2 = wp2[0];
				  var (course,dist1) = courseAndDistance(wp1,wp2);			
				  dist = dist + dist1;
			  }
			  var(course,dist_first) = courseAndDistance(apt_dep,wp_first);
			  var(course,dist_last) = courseAndDistance(wp2,apt_dest);
			  dist = dist + dist_first+dist_last;
	  }
	  return dist;
  }, # end of calc_dist

  delete_key : func(x) {
		del_length = size(getprop(cdu_input[x])) - 1;
		setprop(cdu_input[x],substr(getprop(cdu_input[x]),0,del_length));
		if (del_length == -1 ) {
			setprop(cdu_input[x],"DELETE");
		}
  }, # end of delete_key

  clear_key : func(x) {
    if (getprop(cdu_input[x]) != "") setprop(cdu_input[x],"");
    else if (alm[x].size() != 0) {
      alm[x].pop(alm[x].size()-1);
      setprop(alarm[x], alm[x].size());
    }
  }, # end of clear_key

  previous_key : func(x) {
	  cduDisplay = getprop(display[x]);
    nrPage = size(cduDisplay)<12 ? substr(cduDisplay,9,1) : substr(cduDisplay,9,2); 
	  if (nrPage > 1) {
		  nrPage -= 1;
		  setprop("/instrumentation/cdu["~x~"]/display",left(cduDisplay,8)~"["~nrPage~"]");
	  }
  }, # end of previous_key

  next_key : func(x) {
	  cduDisplay = getprop(display[x]);
    nrPage = size(cduDisplay)<12 ? substr(cduDisplay,9,1) : substr(cduDisplay,9,2); 
	  if (cduDisplay == "FLT-PLAN[0]") {
      if (getprop(depAirport) == "") {
   		  setprop("/instrumentation/cdu["~x~"]/input", "NO DEP AIRPORT");
      } else if (getprop(destAirport) == "") {
   		  setprop("/instrumentation/cdu["~x~"]/input", "NO DEST AIRPORT");
      }
    } else if (left(cduDisplay,8) == "FLT-PLAN" and nrPage < getprop(nbpage[x])) {
      if (getprop(destAirport) == "") {
	      setprop("/instrumentation/cdu["~x~"]/input", "NO DEST AIRPORT");
    	} else if (getprop(destRwy) == "") {
	      setprop("/instrumentation/cdu["~x~"]/input", "NO DEST RUNWAY");
      } else {
          nrPage += 1;
          setprop("/instrumentation/cdu["~x~"]/display",left(cduDisplay,8)~"["~nrPage~"]");
      }
    } else if (cduDisplay != "ALT-PAGE[0]") {
        if (nrPage < getprop(nbpage[x])) {
          nrPage += 1;
          setprop("/instrumentation/cdu["~x~"]/display",left(cduDisplay,8)~"["~nrPage~"]");
        }
    }
  }, # end of next_key

  set_alm : func (x,txt) {
    alm[x].append(txt);
    setprop(alarm[x],alm[x].size());
  }, 

  clear_alm :func(x,txt) {
    alm[x].contains(txt) ? alm[x].remove(txt) : return; # automatic clearance
    setprop(alarm[x],alm[x].size());
  }, 

  nav_var : func { ### for Nav Display
    return [navSel,navWp,navRwy,dist,g_speed];
  },

  alt_flp : func { ### For alternate Fp display
     return (altFp);
  },

  alarms_scrpad : func (x) { ### for CDUpages scrpad
    return (alm[x].vector);
  },

}; # end of cduMain

var setl = setlistener("/sim/signals/fdm-initialized", func () {
  var cdu = cduMain.new();
	cdu.init();
  cdu.listen(0);
  cdu.listen(1);
  print("CDU Canvas ... Ok");
	removelistener(setl);
},0,0);



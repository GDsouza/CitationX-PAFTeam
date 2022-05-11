#####################################################
# Fmz2000 - CDU System
# C. Le Moigne (clm76) - 2015 -> Canvas : 2017
######################################################

var alarm = ["instrumentation/cdu/alarms",
             "instrumentation/cdu[1]/alarms"];
var avionics = "controls/electric/avionics-switch";
var cdu_input = ["instrumentation/cdu/input",
                "instrumentation/cdu[1]/input"];
var curr_wp = "autopilot/route-manager/current-wp";
var dataLoad = "systems/electrical/outputs/data-loader";
var depAirport = "autopilot/route-manager/departure/airport";
var depRwy = "autopilot/route-manager/departure/runway";
var destAirport = "autopilot/route-manager/destination/airport";
var destAlt = "autopilot/route-manager/destination/field-elevation-ft";
var destRwy = "autopilot/route-manager/destination/runway";
var direct = ["instrumentation/cdu/direct",
              "instrumentation/cdu[1]/direct"];
var display = ["instrumentation/cdu/display",
               "instrumentation/cdu[1]/display"];
var fp_active = "autopilot/route-manager/active";
var flyover = ["instrumentation/cdu/flyover",
                 "instrumentation/cdu[1]/flyover"];
var hold_activ = ["instrumentation/cdu/hold/active",
                  "instrumentation/cdu[1]/hold/active"];
var hold_path = ["instrumentation/cdu/hold/",
                 "instrumentation/cdu[1]/hold/"];
var irs_align = ["instrumentation/irs/align",
                 "instrumentation/irs[1]/align"];
var irs_pos = ["instrumentation/irs/positioned",
               "instrumentation/irs[1]/positioned"];
var navSrc = "autopilot/settings/nav-source";
var nbpage = ["instrumentation/cdu/nbpage",
              "instrumentation/cdu[1]/nbpage"];
var num = "autopilot/route-manager/route/num";
var path = getprop("/sim/fg-home")~"/Export/FlightPlans/";
var pcdr_activ = ["instrumentation/cdu/pcdr/active",
                 "instrumentation/cdu[1]/pcdr/active"];
var pcdr_path = ["instrumentation/cdu/pcdr/",
                 "instrumentation/cdu[1]/pcdr/"];
var pos_init = ["instrumentation/cdu/pos-init",
                "instrumentation/cdu[1]/pos-init"];
var route_path = "autopilot/route-manager/route/wp[";
var trs_alt = ["instrumentation/cdu/trans-alt",
                "instrumentation/cdu[1]/trans-alt"];

var alm = [[],[]];
alm[0] = std.Vector.new();
alm[1] = std.Vector.new();
var cnv = [nil,nil];
cnv[0] =  cnv[1] = {FT:nil,M:nil,FL:nil,LB:nil,KG:nil,GAL:nil,L:nil,F:nil,C:nil,
                        KTS:nil,MS:nil,NM:nil,KM:nil,LBGAL:nil,KGL:nil,
                        ELEV:nil,QFE:nil,QNH:nil};

var app_id = nil;
var calc = nil;
var cduDisplay = nil;
var cduInput = "";
var cduPos = 0;
var del_length = nil;
var dest = nil;
var display_mem = nil;
var dist = 0;
var flp_closed = 0;
var fltName = nil;
var fltPath = nil;
var flyovr = nil;
var g_speed = nil;
var hold = 0;
var hold_alt = nil;
var hold_bearing = nil;
var hold_dist = nil;
var hold_inbound = nil;
var hold_spd = nil;
var hold_time = nil;
var hold_turn = nil;
var ind = nil;
var irsPos = [nil,nil];
var navSel = nil;
var navWp = nil;
var navRwy = nil;
var nrPage = nil;
var patt_ind = nil;
var pcdr = 0;
var pcdr_angle = 45;
var pcdr_bearing = nil;
var pcdr_dist = 3.5;
var pcdr_inbound = nil;
var pcdr_ind = nil;
var pcdr_spd = nil;
var pcdr_time = 1;
var pcdr_turn = "L";
var pos = nil;
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
	  setprop("autopilot/settings/asel",100);
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
        ### set Conversion Values ###
    cnv[0].LBGAL = cnv[1].LBGAL = sprintf("%.3f",6.667);
    cnv[0].KGL = cnv[1].KGL = sprintf("%.3f",0.799);

        ### Create FlightPlans path if not exists ###
    var flt_dir = os.path.new(getprop("/sim/fg-home")~"/Export/FlightPlans/create.txt");
    if (!flt_dir.exists()) flt_dir.create_dir();
  }, # end of init

  listen : func (x) {
    setlistener("instrumentation/cdu["~x~"]/init",func(n) { # Reinit CDU #
	    if (n.getValue()) {
		    setprop("autopilot/route-manager/input","@CLEAR");
		    setprop(destAirport,"");
		    setprop(depAirport,"");
		    setprop("autopilot/route-manager/alternate["~x~"]/airport","");
		    setprop("autopilot/route-manager/alternate["~x~"]/runway","");
		    setprop("autopilot/route-manager/alternate["~x~"]/closed",0);
		    setprop("autopilot/route-manager/alternate["~x~"]/set-flag",0);
		    setprop(display[x],"NAVIDENT");
        setprop(nbpage[x],1);
		    setprop(pos_init[x],0);
		    setprop(direct[x],0);
        setprop(hold_activ[x],0);
        setprop("autopilot/locks/hold/active",0);
        setprop("autopilot/locks/hold/enable-exit",0);
        setprop("autopilot/locks/hold/exit",0);
        setprop("autopilot/locks/hold/phase",0);
        setprop(pcdr_activ[x],0);
		    setprop("instrumentation/cdu["~x~"]/direct-to",-1);
		    setprop(cdu_input[x],"");
		    setprop("autopilot/locks/TOD",0);
		    setprop(navSrc, "NAV1");
		    setprop("autopilot/locks/altitude","PTCH");
		    setprop("autopilot/locks/heading","ROLL");
	      setprop(depAirport,getprop("/sim/airport/closest-airport-id"));
	      setprop(depRwy,getprop("sim/atc/runway"));
        me.fuel_wgt(8000);
        setprop("sim/weight[2]/weight-lb",4000);
				setprop("sim/weight[1]/weight-lb",8*170);
        setprop(display[x], irsPos[x] ? "POS-INIT" : "NAVIDENT");
        hold = 0;
        patt_ind = nil;
        pcdr = 0;
        pcdr_ind = nil;
        foreach(var i;keys(cnv[x])) {
          if (i == "LBGAL" or i == "KGL") continue;
          cnv[x][i] = nil;
        }
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
      if (n.getValue()) me.set_alm(x,"POSITIONING");
      else me.clear_alm(x,"POSITIONING");
    },0,0);

    setlistener(irs_pos[x], func(n) { ### End of Positioning ###
      irsPos[x] = n.getValue();
      setprop(display[x], irsPos[x] ? "POS-INIT" : "NAVIDENT");
    },0,0);

    setlistener(pos_init[x], func(n) { ### CDU positioned ###
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
      if (n.getValue()) {
        setprop(nbpage[x],getprop(nbpage[x])+1);
        cnv[0].ELEV = cnv[1].ELEV = getprop(destAlt); # for Conversion Page
      } else cnv[0].ELEV = cnv[1].ELEV = nil;
    },0,0);

    setlistener(num, func(n) {
      me.nb_pages(n.getValue(),3,x);
      if (getprop(fp_active)) setprop(nbpage[x],getprop(nbpage[x])+1);
    },0,0);

    setlistener(avionics, func(n) {
      setprop("instrumentation/cdu["~x~"]/init", n.getValue() < 2 ? 1 : 0);
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

    if (v == "FPL") {
      setprop("autopilot/route-manager/alternate["~x~"]/set-flag",0);
      cduInput = "";
      if (cduDisplay == "POS-INIT") {
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
#      setprop(hold_path[x]~"clear",0);
#      setprop(direct[x],0);
#      hold = 0;
    }
		if (v == "NAV" and cduPos) {
				v = "";
        setprop(nbpage[x],2);
				cduDisplay = "NAV-PAGE[1]";
		}		
    if (v == "PERF" and cduPos) {v="";cduDisplay = "PRF-PAGE[1]"}
		if (v =="PROG" and cduPos) {v="";cduDisplay = "PRG-PAGE[1]"}

		#### NAV-IDENT ####
		if (cduDisplay == "NAVIDENT") {
      if (v == "B4R"){
        data_load = getprop(dataLoad); # Data Loader Fuse
        v="";
        setprop(display[x], data_load ? "POS-INIT" : "NAVIDENT");
      }
		}

		#### POS-INIT ####
		if (cduDisplay == "POS-INIT") {
		  if (v == "B1R" or v == "B2R" or v == "B3R" and irsPos[x]) {	
         setprop(pos_init[x],1);cduPos = 1;
      }
		  if (v == "B4R" and cduPos) cduDisplay = "FLT-PLAN[0]";
      setprop(display[x],cduDisplay);
		}

		#### FLT-LIST ####
		if (left(cduDisplay,8) == "FLT-LIST") {
			if (v == "B4L") {
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
					  setprop("/autopilot/route-manager/departure/sid",SidName);
    				cduInput = getprop("/autopilot/route-manager/departure/sid") ~ " Loaded";
          }
        } else {cduInput = "*FLT PLAN CLOSED*"}
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
					  setprop("/autopilot/route-manager/destination/star",StarName);
					  cduInput = getprop("autopilot/route-manager/destination/star") ~ " Loaded";
				  }			
        } else {cduInput = "*FLT PLAN CLOSED*"}
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
        } else {cduInput = "*FLT PLAN CLOSED*"}
			}
		}

		#### FLT-PLAN ####
    if (cduDisplay == "FLT-PLAN[0]") {
      if (v == "B2L" or v == "B4L") {v = "";cduDisplay = "FLT-LIST[1]"}
      if (getprop(destAirport)) cduDisplay = "FLT-PLAN[1]";
      else {
        if (v == "B2R" and cduInput) {
          dest = findNavaidsByID(cduInput,"airport");
          if (size(dest) == 1) {
            fp.destination = airportinfo(cduInput);
			      setprop(destAirport,cduInput);
			      cduInput = "";
			      cduDisplay = "FLT-PLAN[1]";
          } else cduInput = "NOT AN AIRPORT";
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
        ### DEL Button ###
				if (cduInput == "*DELETE*") {
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
              } else if (getprop(flyover[x]) > 0) {
                setprop(flyover[x],0);
                cduInput = "";
              } else if (getprop(pcdr_activ[x])) {
                setprop(pcdr_activ[x],0);
                cduInput = "";
              } else if (getprop(hold_activ[x])) {
                if (!getprop('autopilot/locks/hold/enable-exit')) {
                  setprop(hold_activ[x],0);
                  cduInput = "";
                } else cduInput = "*INVALID DELETE*";
              } else cduInput = "*FLT PLAN CLOSED*";
  				} else {
					  setprop("autopilot/route-manager/input","@DELETE"~ind);
					  cduInput = "";
          }
				} # end of DEL button
        
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
          if (getprop(fp_active)) setprop(fp_active,1); # to recreate TOD
					cduInput = "";						
				}
				else if (getprop(fp_active)) {
          if (hold) {
            patt_ind = ind;
            me.clear_alm(x,"* HOLD *");
            setprop(direct[x],0);
            cduDisplay = "HLD-PATT[1]";
          } else if (flyovr) {
            setprop(flyover[x],ind);
            me.clear_alm(x,"* FLYOVER *");
            setprop(direct[x],0);
            flyovr = 0;
          } else if (pcdr) {
            pcdr_ind = ind;
            me.clear_alm(x,"* PCDR TURN *");
            setprop(direct[x],0);
            cduDisplay = "PCD-TURN[1]";
          } else if (getprop(direct[x])) {
            if (fp.getWP(ind).wp_name != "TOD") setprop("instrumentation/cdu["~x~"]/direct-to",ind);
            else setprop("instrumentation/cdu["~x~"]/direct-to",ind+1);
            var dir_wp = fp.getWP(getprop("instrumentation/cdu["~x~"]/direct-to")).wp_name;
            var currWp = getprop(curr_wp);
            for (var i=currWp;i<fp.getPlanSize()-1;i+=1) {
              if (fp.getWP(i).wp_name == dir_wp) break
              else {fp.deleteWP(i);i-=1}
            }
            setprop(fp_active,1); # to recreate TOD
            setprop(curr_wp,currWp);
            setprop(direct[x],0);
          } else if (cduDisplay != "FLT-PLAN["~getprop(nbpage[x])~"]")
              cduInput = "*FLT PLAN CLOSED*";
				}
        v="";
			}

			if (v == "B4L") {
			  if (getprop(fp_active)) { 
          if (nrPage == getprop(nbpage[x])) {
            v=""; cduDisplay = "PRF-PAGE[1]";  
          } else {
            v=""; 
            display_mem = cduDisplay;
            if (getprop("autopilot/locks/hold/enable-exit")) {
                setprop("autopilot/locks/hold/exit",1);
                hold = 0;
                cduDisplay = display_mem;
            } else if (getprop(direct[x])) cduDisplay = "PAT-PAGE[1]";
            else {v="";cduDisplay = "FLT-DEPT[1]"}
          }
        } else {v="";cduDisplay = "FLT-DEPT[1]"}
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
				if (nrPage > 0 and nrPage <= getprop(nbpage[x])) {
					if (ind == getprop(num)-1 and cduInput == "*DELETE*") {
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
        dest = findNavaidsByID(cduInput,"airport");
        if (size(dest) == 1) {
          altFp.destination = airportinfo(cduInput);
			    setprop("autopilot/route-manager/alternate["~x~"]/airport",cduInput);
          cduInput = "";
          cduDisplay = "ALT-PAGE[0]";
        } else cduInput = "NOT AN AIRPORT";
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
				if (cduInput == "*DELETE*") {
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
          if (getprop(direct[x])) {
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
            setprop(direct[x],0);
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
					if (ind == altFp.getPlanSize()-1 and cduInput == "*DELETE*") {
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

    #### PATTERN PAGES ####
    if (left(cduDisplay,8) == "PAT-PAGE") {
      setprop(nbpage[x],1);
      cduInput = "";
			if (v == "B1L") {
        v = "";
        cduDisplay = display_mem;
        hold = 1;
        me.set_alm(x,"* HOLD *");
      }
			if (v == "B2L") {
        v = "";
        cduDisplay = display_mem;
        flyovr = 1;
        me.set_alm(x,"* FLYOVER *");
      }
			if (v == "B4L") {
        v = "";
        cduDisplay = "HLD-PATT[1]";
      }
			if (v == "B1R") {
        v = "";
        cduDisplay = display_mem;
        pcdr = 1; 
        me.set_alm(x,"* PCDR TURN *");
      }
    }
    if (cduDisplay == "HLD-PATT[1]") {
      setprop(nbpage[x],1);
      if (patt_ind == nil) v = "B4L";
			if (v == "B3L") {
        v = "";
        if  (right(cduInput,1) == "L" or right(cduInput,1) =="R") {
          hold_turn = right(cduInput,1);
          if (size(cduInput) > 1) hold_inbound = left(cduInput,size(cduInput)-1);
        } else hold_inbound = cduInput;
        cduInput = "";
      }
			if (v == "B4L") {
        v = "";
        setprop(hold_path[x]~"clear",1);
        setprop(direct[x],0);
        hold = 0;
        cduInput = "";
      }
			if (v == "B1R") {
        v = "";
        if (cduInput != "*DELETE*") hold_spd = cduInput;
        else hold_spd = nil;
        cduInput = "";
      }
			if (v == "B2R") {
        v = "";
        hold_time = cduInput;
        cduInput = "";
      }
			if (v == "B3R") {
        v = "";
        hold_dist = cduInput;
        cduInput = "";
      }
			if (v == "B4R") {
        v = "";
        setprop(hold_activ[x],1);
        setprop("autopilot/locks/hold/active",1);
        setprop(direct[x],0);
        cduInput = "";
        cduDisplay = display_mem;
      }
      me.hold_save(x);
    }

    if (cduDisplay == "PCD-TURN[1]") {
      setprop(nbpage[x],1);
			if (v == "B2L") {
        v = "";
        if (left(cduInput,1) == "L" or left(cduInput,1) =="R")
          pcdr_turn = left(cduInput,1);
#          if (size(cduInput) > 1) pcdr_angle = right(cduInput,size(cduInput)-1);
#        } else pcdr_angle = cduInput;
#        pcdr_angle = math.clamp(pcdr_angle,20,90);
        cduInput = "";
      }
      if (v == "B2R") {
        v = "";
        pcdr_time = cduInput;
        pcdr_dist = pcdr_time * 210/60 ;
        cduInput = "";
      }
      if (v == "B3R") {
        v = "";
        pcdr_dist = cduInput;
        pcdr_time = pcdr_dist * 60/210;
        cduInput = "";
      }
			if (v == "B4R") {
        v = "";
        setprop(pcdr_activ[x],1);
        setprop(direct[x],0);
        cduInput = "";
        cduDisplay = display_mem;
      }
      me.pcdr_save(x);
    } # end of Pattern

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
#			if (v == "B4R") {v = "";cduDisplay = "NAV-PAGE[2]"}

		}
		if (cduDisplay == "NAV-PAGE[2]") {		
      cduInput = "";
			if (v == "B1L") {v = "";cduDisplay = "NAV-CONV[1]"}
			if (v == "B1R") {v = "";cduDisplay = "PAT-PAGE[1]"}
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

    if (left(cduDisplay,8) == "NAV-CONV") setprop(nbpage[x],4);
		if (cduDisplay == "NAV-CONV[1]") {
      if (size(cduInput) > 8) {cduInput = "";me.set_alm(x,"MAX 8 Car")}
      else {
		    if (v == "B1L") {
          cnv[x].FT = sprintf("%8.1f",cduInput);
          cnv[x].M = sprintf("%8.1f",cduInput/3.2808);
          cnv[x].FL = nil;
		      cduInput = "";
        }
		    if (v == "B1R") {
          cnv[x].M = sprintf("%8.1f",cduInput);
          cnv[x].FT = sprintf("%8.1f",cduInput*3.2808);
          cnv[x].FL = math.round(cduInput*0.0328,5);
    			cduInput = "";
        }
		    if (v == "B2L") {
          cnv[x].LB = sprintf("%8.1f",cduInput);
          cnv[x].KG = sprintf("%8.1f",cduInput/2.2046);
    			cduInput = "";
        }
		    if (v == "B2R") {
          cnv[x].KG = sprintf("%8.1f",cduInput);
          cnv[x].LB = sprintf("%8.1f",cduInput*2.2046);
    			cduInput = "";
        }
		    if (v == "B3L") {
          cnv[x].GAL = sprintf("%8.1f",cduInput);
          cnv[x].L = sprintf("%8.1f",cduInput/0.26417);
    			cduInput = "";
        }
		    if (v == "B3R") {
          cnv[x].L = sprintf("%8.1f",cduInput);
          cnv[x].GAL = sprintf("%8.1f",cduInput*0.26417);
    			cduInput = "";
        }
      }
#		  if (v == "B4L") {v = "";cduDisplay = "NAV-PAGE[2]"} 
#		  if (v == "B4R") {v = "";cduDisplay = "NAV-CONV[2]"} 
    }
		if (cduDisplay == "NAV-CONV[2]") {
      if (size(cduInput) > 8) {cduInput = "";me.set_alm(x,"MAX 8 Car")}
      else { 
        me.clear_alm(x,"MAX 8 Car");
			  if (v == "B1L") {
          if (cduInput < -112 or cduInput > 129) {
            cduInput = ""; me.set_alm(x,"range -112° to 129° F");
          } else {
            cnv[x].F = sprintf("%+.1f",cduInput);
            cnv[x].C = sprintf("%+.1f",(cduInput-32)/1.8);
          }
		      cduInput = "";
        }
			  if (v == "B1R") {
          if (cduInput < -80 or cduInput > 54) {
            cduInput = ""; me.set_alm(x,"range -80° to 54° C");
          } else {
            cnv[x].C = sprintf("%+.1f",cduInput);
            cnv[x].F = sprintf("%+.1f",(cduInput*1.8) + 32);
      			cduInput = "";
          }
        }
			  if (v == "B2L") {
          if (cduInput < 0 or cduInput > 999.9) {
            cduInput = ""; me.set_alm(x,"range 0 to 999.9 Kts");
          } else {
            cnv[x].KTS = sprintf("%.1f",cduInput);
            cnv[x].MS = sprintf("%.1f",cduInput*1852/3600);
      			cduInput = "";
          }
        }
			  if (v == "B2R") {
          if (cduInput < 0 or cduInput > 999.9) {
            cduInput = ""; me.set_alm(x,"range 0 to 999.9 M/S");
          } else {
            cnv[x].MS = sprintf("%.1f",cduInput);
            cnv[x].KTS = sprintf("%.1f",cduInput*3600/1852);
      			cduInput = "";
          }
        }
			  if (v == "B3L") {
          cnv[x].NM = sprintf("%.1f",cduInput);
          cnv[x].KM = sprintf("%.1f",cduInput*1.852);
    			cduInput = "";
        }
			  if (v == "B3R") {
          cnv[x].KM = sprintf("%.1f",cduInput);
          cnv[x].NM = sprintf("%.1f",cduInput/1.852);
    			cduInput = "";
        }
			  if (v == "B4L") {v = "";cduDisplay = "NAV-CONV[1]"} 
			  if (v == "B4R") {v = "";cduDisplay = "NAV-CONV[3]"} 
      }
		}
		if (cduDisplay == "NAV-CONV[3]") {
      if (size(cduInput) > 8) me.set_alm(x,"MAX 8 Car"); 
      else { 
        me.clear_alm(x,"MAX 8 Car");
			  if (v == "B1L") {
          cnv[x].LB = sprintf("%.1f",cduInput);
          cnv[x].KG = sprintf("%.1f",cduInput*0.453592);
          cnv[x].GAL = sprintf("%.1f",cduInput/cnv[x].LBGAL);
          cnv[x].L = sprintf("%.1f",cnv[x].KG/cnv[x].KGL);
			    cduInput = "";
        }
			  if (v == "B1R") {
          cnv[x].KG = cduInput;
          cnv[x].LB = sprintf("%.1f",cduInput*2.20462);
          cnv[x].L = sprintf("%.1f",cduInput/cnv[x].KGL);
          cnv[x].GAL = sprintf("%.1f",cnv[x].LB/cnv[x].LBGAL);
    			cduInput = "";
        }
			  if (v == "B2L") {
          cnv[x].GAL = sprintf("%.1f",cduInput);
          cnv[x].L = sprintf("%.1f",cduInput*3.78541);
          cnv[x].LB = sprintf("%.1f",cduInput*cnv[x].LBGAL);
          cnv[x].KG = sprintf("%.1f",cnv[x].L*cnv[x].KGL);
    			cduInput = "";
        }
			  if (v == "B2R") {
          cnv[x].L = sprintf("%.1f",cduInput);
          cnv[x].GAL = sprintf("%.1f",cnv[x].L*0.264172);
          cnv[x].KG = sprintf("%.1f",cduInput*cnv[x].KGL);
          cnv[x].LB = sprintf("%.1f",cnv[x].GAL*cnv[x].LBGAL);
    			cduInput = "";
        }
			  if (v == "B3L") {
          cnv[x].LBGAL = sprintf("%.3f",cduInput);
          cnv[x].KGL = sprintf("%.3f",cduInput*0.1198);
          if (cnv[x].GAL != nil) {
            cnv[x].L = sprintf("%.1f",cnv[x].KG/cnv[x].KGL);
            cnv[x].GAL = sprintf("%.1f",cnv[x].LB/cnv[x].LBGAL);
          }
    			cduInput = "";
        }
			  if (v == "B3R") {
          cnv[x].KGL = sprintf("%.3f",cduInput);
          cnv[x].LBGAL = sprintf("%.3f",cduInput*8.3454);
          if (cnv[x].L != nil) {
            cnv[x].L = sprintf("%.1f",cnv[x].KG/cnv[x].KGL);
            cnv[x].GAL = sprintf("%.1f",cnv[x].LB/cnv[x].LBGAL);
          }
    			cduInput = "";
        }
			  if (v == "B4L") {v = "";cduDisplay = "NAV-CONV[2]"} 
			  if (v == "B4R") {v = "";cduDisplay = "NAV-CONV[4]"} 
      }
		}

		if (cduDisplay == "NAV-CONV[4]") {
      if (size(cduInput) > 8) me.set_alm(x,"MAX 8 Car"); 
      else { 
        me.clear_alm(x,"MAX 8 Car");
			  if (v == "B1R") {
          if (cduInput == "*DELETE*") 
            cduInput = getprop(destAirport) ? getprop(destAlt) : ""; 
          if (cduInput != "") {
              if (cduInput < -1300 or cduInput > 60000) {
                me.set_alm(x,"range -1300 to 60000 Ft");
                cduInput = "";
              } else cnv[x].ELEV = sprintf("%.0f",cduInput);
          } else cnv[x].ELEV = nil;
          cduInput = "";
        }
			  if (v == "B2L") {
          if (cduInput == "*DELETE*") cnv[x].QFE = nil;
          else {
            if (cduInput != "") {
              if (cduInput < 16.00 or cduInput > 32.00) {
                me.set_alm(x,"range 16.00 to 32.00");cduInput = "";
              } else {
                cnv[x].QFE = sprintf("%.2f",cduInput);
                if (cnv[x].ELEV != nil) {
                  calc = 1-(0.0065*cnv[x].ELEV*0.3048/288.15);
                  cnv[x].QNH = sprintf("%.2f",cduInput*33.8639/math.pow(calc,5.255)*0.02953);
                }
              }
            }
          } 
 			  cduInput = "";
        }
			  if (v == "B2R") {
          if (cduInput == "*DELETE*") cnv[x].QNH = nil;
          else {
            if (cduInput != "") {
              if (cduInput < 16.00 or cduInput > 32.00) {
                me.set_alm(x,"range 16.00 to 32.00");cduInput = "";
              } else {
                cnv[x].QNH = sprintf("%.2f",cduInput);
                if (cnv[x].ELEV != nil) {
                  calc = 1-(0.0065*cnv[x].ELEV*0.3048/288.15);
                  cnv[x].QFE = sprintf("%.2f",cduInput*33.8639*math.pow(calc,5.255)*0.02953);
                }
              }
            }
          }
    			cduInput = "";
        }
			  if (v == "B3L") {
          if (cduInput == "*DELETE*") cnv[x].QFE = nil;
          else {
            if (cduInput != "") {
              if (cduInput < 542 or cduInput > 1084) {
                me.set_alm(x,"range 542 to 1084");cduInput = "";
              } else cnv[x].QFE = sprintf("%.2f",cduInput*0.02953);
            }
          }
          cduInput = "";
        }
			  if (v == "B3R") {
          if (cduInput == "*DELETE*") cnv[x].QNH = nil;
          else {
            if (cduInput != "") {
              if (cduInput < 542 or cduInput > 1084) {
                me.set_alm(x,"range 542 to 1084");cduInput = "";
              } else cnv[x].QNH = sprintf("%.2f",cduInput*0.02953);
            }
          }
    			cduInput = "";
        }
			  if (v == "B4L") {
          if (cduInput == "*DELETE*") cnv[x].QFE = nil;
          else {
            if (cduInput != "") {
              if (cduInput < 407 or cduInput > 813) {
                me.set_alm(x,"range 407 to 813");cduInput = "";
              } else cnv[x].QFE = sprintf("%.2f",cduInput*0.03937);
            }
          }
          cduInput = "";
        }
			  if (v == "B4R") {
          if (cduInput == "*DELETE*") cnv[x].QNH = nil;
          else {
            if (cduInput != "") {
              if (cduInput < 407 or cduInput > 813) {
                me.set_alm(x,"range 407 to 813");cduInput = "";
              } else cnv[x].QNH = sprintf("%.2f",cduInput*0.03937);
            }
          }
          cduInput = "";
        }
      }
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
    }

		if (cduDisplay == "PRF-PAGE[2]") {	
		  if (v == "B1L") {
			  v = "";
			  if (cduInput) {
				  if (left(cduInput,2) < 1) {
            cduInput = (cduInput < 0.40 ? 0.40 : cduInput > 0.92 ? 0.92 : cduInput);
					  setprop("autopilot/settings/climb-speed-mc",cduInput);				
				  } else if (cduInput > 100) {
						  setprop("autopilot/settings/climb-speed-kt",cduInput > 345 ? 345 : cduInput);
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
						  setprop("autopilot/settings/cruise-speed-kt",cduInput > 345 ? 345 : cduInput);
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
						  setprop("autopilot/settings/descent-speed-kt",cduInput > 345 ? 345 : cduInput);
				  }					
			  }
			  cduInput = "";
		  }
      setprop("/instrumentation/cdu["~x~"]/display","PRF-PAGE[2]");      
		  if (v == "B4L"){v = "";cduDisplay = "PRF-PAGE[6]"}
    }

		if (cduDisplay == "PRF-PAGE[3]") {	# No change permitted
    }

		if (cduDisplay == "PRF-PAGE[4]") {	
			if (v == "B1L") {
				v = "";					
				if (cduInput > 3499) setprop(trs_alt[x],cduInput);
				cduInput = "";
			}			
#      if (v == "B3L") { # Argh ! wind cannot be set here
#        v = "";
#        pos = find("/",cduInput);
#        if (pos == -1 and size(cduInput) < 4)
#          setprop("environment/wind-from-heading-deg",geo.normdeg(cduInput));
#        else {
#          if (pos == 0) 
#            setprop("environment/wind-speed-kt",right(cduInput,size(cduInput)-1));
#          else {
#            setprop("environment/wind-from-heading-deg",geo.normdeg(left(cduInput,pos)));
#            setprop("environment/wind-speed-kt",right(cduInput,size(cduInput)-pos-1));
#          }
#        }
#      }
      setprop("/instrumentation/cdu["~x~"]/display","PRF-PAGE[4]");      
    }
		if (cduDisplay == "PRF-PAGE[5]") {
			if (v == "B2L"){
				v = "";					
				if (cduInput) {
					if (cduInput > 13000) cduInput = "FUEL MAX = 13000";
					else me.fuel_wgt(cduInput);
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
      ### Additional pages ###
		if (cduDisplay == "PRF-PAGE[6]") {	
			if (v == "B1L") {
				v = "";
				if (cduInput) {
					setprop("autopilot/settings/dep-speed-kt",cduInput > 345 ? 345 : cduInput);	
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
      setprop("/instrumentation/cdu["~x~"]/display","PRF-PAGE[6]");      
			if (v == "B4L") {v = "";cduDisplay = "PRF-PAGE[7]"}
			if (v == "B4R") {v = "";cduDisplay = "PRF-PAGE[2]"}
		}

		if (cduDisplay == "PRF-PAGE[7]") {	
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
      setprop("/instrumentation/cdu["~x~"]/display","PRF-PAGE[7]");      
			if (v == "B4R") {v = "";cduDisplay = "PRF-PAGE[2]"}
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

    #### Save ####
		setprop(display[x],cduDisplay);
		setprop("/instrumentation/cdu["~x~"]/input",cduInput);

  }, # end of key

  ####### Common Functions ######
  fuel_wgt : func(weight) {
		setprop("consumables/fuel/tank[0]/level-lbs",weight*0.27);
		setprop("consumables/fuel/tank[1]/level-lbs",weight*0.27);
		setprop("consumables/fuel/tank[2]/level-lbs",weight*0.23);
		setprop("consumables/fuel/tank[3]/level-lbs",weight*0.23);
  },

  lineSelect : func(v) {
    for (var i = 1;i<4;i+=1) {
      if (v == "B"~i~"L") select = "l"~i;
    }
    for (var i = 1;i<4;i+=1) {
      if (v == "B"~i~"R") select = "l"~(i+3);
    }
  }, # end of lineSelect

  nb_pages : func (nbFiles,nb,x) {
		setprop(nbpage[x],math.ceil(nbFiles/nb));
  }, # end of nb_pages

  insertWayp : func(ind,cduInput,fp,x) {
    cduInput = left(cduInput,2) == "FL" ? substr(cduInput,2,3)*100 : cduInput;
    var wp_spd = fp.getWP(ind).speed_cstr;

	  if (cduInput and cduInput <= 400) { ### Speed
      call(func {fp.getWP(ind).setSpeed(cduInput,'at')},nil,var err = []);
      wp_spd = fp.getWP(ind).speed_cstr;
#      setprop("instrumentation/cdu["~x~"]/speed",1);
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
#      setprop("instrumentation/cdu["~x~"]/speed",1);
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
			setprop(cdu_input[x],"*DELETE*");
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
    } else if (cduDisplay != "ALT-PAGE[0]" and cduDisplay != "HLD-PATT[1]") {
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

  alarms_scrpad : func(x) { ### for CDUpages scrpad
    return (alm[x].vector);
  },

  conv_table : func(x) { ### for CDUpages conv
    return (cnv[x]);
  },

  hold_save : func(x) { 
    if (patt_ind != nil) {
      hold_bearing = getprop(route_path~patt_ind~"]/leg-bearing-true-deg");
      hold_alt = fp.getWP(patt_ind).alt_cstr or getprop("instrumentation/altimeter/indicated-altitude-ft");
      if (hold_spd == nil) hold_spd = fp.getWP(patt_ind).speed_cstr or 200;
      if (hold_time != nil and hold_dist == nil) hold_dist = hold_spd/60*hold_time;
      else if (hold_time == nil and hold_dist != nil) hold_time = hold_dist/hold_spd*60;
      else {
        hold_time = hold_alt >= 14000 ? 1.5 : 1;
        hold_dist = hold_spd/60*hold_time;
      }
      setprop(hold_path[x]~"wpt",patt_ind);
      setprop(hold_path[x]~"inbound",hold_inbound or hold_bearing);
      setprop(hold_path[x]~"turn",hold_turn == nil ? "R" : hold_turn);
      setprop(hold_path[x]~"time",hold_time);
      setprop(hold_path[x]~"leg-dist-nm",hold_dist);
      setprop(hold_path[x]~"altitude",hold_alt);
      setprop(hold_path[x]~"speed",hold_spd);
    }
  }, # end of hold_save

  pcdr_save : func(x) {
      pcdr_bearing = fp.destination_runway.heading;
      setprop(pcdr_path[x]~"wpt",pcdr_ind);
      setprop(pcdr_path[x]~"inbound",pcdr_bearing);
      setprop(pcdr_path[x]~"leg-dist-nm",10);
      setprop(pcdr_path[x]~"angle",pcdr_angle);
      setprop(pcdr_path[x]~"turn",pcdr_turn);
      setprop(pcdr_path[x]~"dist",pcdr_dist);
      setprop(pcdr_path[x]~"time",pcdr_time);
      setprop(pcdr_path[x]~"speed",200);
  }, # end of pcdr_save
}; # end of cduMain

var setl = setlistener("/sim/signals/fdm-initialized", func () {
  var cdu = cduMain.new();
	cdu.init();
  cdu.listen(0);
  cdu.listen(1);
  print("CDU Canvas ... Ok");
	removelistener(setl);
},0,0);



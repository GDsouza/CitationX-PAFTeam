###############################################
# Canvas CDU
# C. Le Moigne (clm76) - 2017 - Rev1 2018
###############################################

var currWp = "autopilot/route-manager/current-wp";
var dataLoad = "systems/electrical/outputs/data-loader";
var dep_apt = "autopilot/route-manager/departure/airport";
var dep_rwy = "autopilot/route-manager/departure/runway";
var dest_apt = "autopilot/route-manager/destination/airport";
var dest_rwy = "autopilot/route-manager/destination/runway";	
var direct = ["instrumentation/cdu/direct",
              "instrumentation/cdu[1]/direct"];
var dist_rem = "autopilot/route-manager/distance-remaining-nm";
var dsp = ["instrumentation/cdu/display",
           "instrumentation/cdu[1]/display"];
var enable_exit = "autopilot/locks/hold/enable-exit";
var exit = "autopilot/locks/hold/exit";
var flyover_path = ["instrumentation/cdu/flyover/",
                 "instrumentation/cdu[1]/flyover/"];
var fp_active = "autopilot/route-manager/active";
var fp_saved = "autopilot/route-manager/flight-plan";
var fuel_flow = ["engines/engine[0]/fuel-flow-pph",
                 "engines/engine[1]/fuel-flow-pph"];
var hld_activ = ["instrumentation/cdu/hold/active",
                 "instrumentation/cdu[1]/hold/active"];
var hld_path = ["instrumentation/cdu/hold/",
                 "instrumentation/cdu[1]/hold/"];
var irs_pos = ["instrumentation/irs/positionned",
               "instrumentation/irs[1]/positionned"];
var nav_dist = "autopilot/internal/nav-distance";
var nbpage = ["instrumentation/cdu/nbpage",
              "instrumentation/cdu[1]/nbpage"];
var num = "autopilot/route-manager/route/num";
var pcd_activ = ["instrumentation/cdu/pcdr/active",
                 "instrumentation/cdu[1]/pcdr/active"];
var pcd_path = ["instrumentation/cdu/pcdr/",
                 "instrumentation/cdu[1]/pcdr/"];
var perf_confd = ["instrumentation/cdu/perf-confirm",
                 "instrumentation/cdu[1]/perf-confirm"];
var pos_init = ["instrumentation/cdu/pos-init",
                "instrumentation/cdu[1]/pos-init"];
var route_path = "autopilot/route-manager/route/wp[";
var trs_alt = ["instrumentation/cdu/trans-alt",
                "instrumentation/cdu[1]/trans-alt"];
var velocity = "velocities/groundspeed-kt";

var _alm = nil;
var Agl = nil;
var AppSpeed5 = nil;
var AppSpeed15 = nil;
var AppSpeed35 = nil;
var ClimbSpeed_kt = nil;
var ClimbSpeed_mc = nil;
var cdu_ret = nil;
var conv = nil;
var Cruise_alt = nil;
var CruiseSpeed_kt = nil;
var CruiseSpeed_mc = nil;
var data_load = nil;
var dep_spd = nil;
var DescAngle = nil;
var DescSpeed_kt = nil;
var DescSpeed_mc = nil;
var destApt = nil;
var diff1 = nil;
var diff2 = nil;
var dist = nil;
var g_speed = nil;
var FuelEstWp = nil;
var FuelEstDest = nil;
var fuel_cons = nil;
var EstWp_time = nil;
var EstDest_time = nil;
var ETA = nil;
var ETE = nil;
var fp_size = nil;
var flpLine = nil;
var fly_over = nil;
var hld_id = nil;
var hld_ind = nil;
var hld_bearing = nil;
var hld_clear = 0;
var hld_dist = nil;
var hld_entry = nil;
var hld_inbound = nil;
var hld_time = nil;
var hld_turn = nil;
var hld_spd = nil;
var my_lat = nil;
var my_lon = nil;
var n = nil;
var navSel = nil;
var navWp = nil;
var navRwy = nil;
var Nav_type = nil;
var Nav1_id = nil;
var Nav1_freq = nil;
var Nav2_id = nil;
var Nav2_freq = nil;
var Nm = nil;
var p = nil;
var page = nil;
var pat_alt = nil;
var pcd_id = nil;
var pcd_ind = nil;
var pcd_bearing = nil;
var pcd_clear = 0;
var pcd_crs = nil;
var pcd_dist = nil;
var pcd_entry = nil;
var pcd_inbound = nil;
var pcd_leg = nil;
var pcd_time = nil;
var pcd_turn = nil;
var pcd_spd = nil;
var quad = nil;
var spd = nil;
var titl = nil;
var trans_alt = nil;
var Wcarg = nil;
var Wcrew = nil;
var wind_spd_hd = nil;
var wind_spd_kt = nil;
var Wfuel = nil;
var Wpass = nil;
var xfile = nil;


var cduDsp = {
	new: func (x) {
		var m = {parents:[cduDsp]};
    if (!x) {
		  m.cdu = canvas.new({
			  "name": "CDU-L", 
			  "size": [1024, 1024],
			  "view": [1024, 750],
			  "mipmapping": 1 
		  });
		  m.cdu.addPlacement({"node": "CDU.screenL"});
		  m.group = m.cdu.createGroup();   
  		canvas.parsesvg(m.group, "Aircraft/CitationX/Models/Instruments/CDU/cdu.svg");
    } else {
		  m.cdu = canvas.new({
			  "name": "CDU-R", 
			  "size": [1024, 1024],
			  "view": [1024, 750],
			  "mipmapping": 1 
		  });
		  m.cdu.addPlacement({"node": "CDU.screenR"});
		  m.group = m.cdu.createGroup();   
		  canvas.parsesvg(m.group, "Aircraft/CitationX/Models/Instruments/CDU/cdu.svg");
    }
		m.line = {};
		m.line_val = ["title","l1","l1m","l2","l2r","l3","l4","l4r","l5","l6","l7",
                  "r1","r2l","r2r","r3","r4l","r4r",
                  "r5","r6l","r6r","r7","r7m"];
		foreach(var i;m.line_val) {
			m.line[i] = m.group.getElementById(i);
		}    
    m.scrpad = m.group.getElementById("scrpad").hide();
    m.arrow = m.group.createChild("path")
      .moveTo(520,275)
      .horiz(-100)
      .line(40,15)
      .line(-20,-15)
      .moveTo(420,275)
      .line(40,-15)
      .line(-20,15)
      .setStrokeLineWidth(8)
      .setStrokeLineJoin("round");
   
    m.curr_wp = nil;
    return m;

  }, # end of new

  Listen : func(x) {
		setlistener(dataLoad, func(n) {
      data_load = n.getValue();
      if (getprop(dsp[x]) == "NAVIDENT")
        me.Nav_ident(x);
    },0,0);

		setlistener(dsp[x], func(n) {
      if (n.getValue() == "PRG-PAGE[1]") {
        if (!me.timer.isRunning) me.timer.start();
      } else me.timer.stop();
      me.Display(x);
		},0,1); # 1 pour maj depuis cdu.nas

    setlistener(pos_init[x], func(n) {
      if (n.getValue()) me.Pos_init(x);
    },0,0);

    setlistener("instrumentation/cdu["~x~"]/input", func(n) {  ### Scratchpad
      me.scrpad.setText(n.getValue()).show();
      if (n.getValue() == "") me.Scr_pad(x);
    },0,1);

    setlistener("instrumentation/cdu["~x~"]/alarms", func(n) {  ### Scratchpad
      me.Scr_pad(x);
    },0,0);

    setlistener("controls/lighting/cdu["~x~"]",func { ### Luminosity
      me.Base_colors(x);
      me.Display(x);
    },0,0);

		setlistener(irs_pos[x], func(n) {
      if (n.getValue()) me.Display(x);
    },0,0);

    setlistener(num, func(n) {
      if (n.getValue() > 1 and left(getprop(dsp[x]),8) == "FLT-PLAN") {
        me.Flp1(x);
      }
    },0,0);

#    setlistener(dep_apt, func {me.Flp0(x);},0,0);

    setlistener(fp_saved, func {me.Flp1(x);},0,0);

    setlistener(fp_active, func {me.Flp1(x);},0,0);

#    setlistener("instrumentation/cdu["~x~"]/speed", func(n) {
#      setprop("instrumentation/cdu["~x~"]/speed",n.getValue());
#      me.Flp1(x);
#    },0,0);

    setlistener(currWp, func(n) {
      if (left(getprop(dsp[x]),3) == "FLT") {
          ### automatic page change during flight ###
        page = int(n.getValue()/3)+1;
        setprop(dsp[x],"FLT-PLAN["~page~"]");
        me.Flp1(x);
      }
    },0,0);

    setlistener(direct[x],func(n) {
      if (n.getValue() and (left(getprop(dsp[x]),8) == "FLT-PLAN" or left(getprop(dsp[x]),8) == "ALT-PAGE")) {
        me.line.l1.setText("---- DIRECT").setColor(me.amber);
        me.line.l7.setText("< PATTERN");
#        me.line.r7.setText("INTERCEPT >");
      }
      else{
#        me.line.l7.setText("< DEPARTURE");
        me.line.r7.setText("ARRIVAL >");
      }
    },0,1);

  }, # end of listen

  Display : func(x) {
	  if (getprop(dsp[x]) == "NAVIDENT") me.Nav_ident(x);
		if (getprop(dsp[x]) == "POS-INIT") me.Pos_init(x);
		if (left(getprop(dsp[x]),8) == "FLT-LIST") me.Flp_list(x);
		if (getprop(dsp[x]) == "FLT-PLAN[0]") me.Flp0(x);
    else if(left(getprop(dsp[x]),8) == "FLT-PLAN") me.Flp1(x);
		if (left(getprop(dsp[x]),8) == "FLT-ARRV") me.Arrv(x);
		if (left(getprop(dsp[x]),8) == "FLT-ARWY") me.Arwy(x);
		if (left(getprop(dsp[x]),8) == "FLT-DEPT") me.Dept(x);
		if (left(getprop(dsp[x]),8) == "FLT-SIDS") me.Sid(x);
		if (left(getprop(dsp[x]),8) == "FLT-STAR") me.Star(x);
  	if (left(getprop(dsp[x]),8) == "FLT-APPR") me.Appr(x);
    if (left(getprop(dsp[x]),8) == "ALT-PAGE") me.Alternate(x);
  	if (left(getprop(dsp[x]),8) == "PRF-PAGE") me.Prf(x);
  	if (left(getprop(dsp[x]),8) == "NAV-PAGE") me.Nav(x);
  	if (left(getprop(dsp[x]),8) == "NAV-LIST") me.Nav_list(x);
  	if (left(getprop(dsp[x]),8) == "NAV-SELT") me.Nav_sel(x);
    if (left(getprop(dsp[x]),8) == "NAV-ACTV") me.Nav_activ(x);
    if (left(getprop(dsp[x]),8) == "NAV-CONV") me.Nav_conv(x);
    if (left(getprop(dsp[x]),8) == "PAT-PAGE") me.Patterns(x);
    if (left(getprop(dsp[x]),8) == "HLD-PATT") me.HoldPat(x);
    if (left(getprop(dsp[x]),8) == "PCD-TURN") me.PcdrTurn(x);
    if (left(getprop(dsp[x]),8) == "PRG-PAGE") me.Progress(x);
  },

  Nav_ident : func(x) {
	  var my_day = getprop("sim/time/real/day");
	  var my_month = getprop("sim/time/real/month");
	  var my_year = getprop("sim/time/real/year");
    var date = sprintf("%.2i-%.2i-%i", my_day, my_month, my_year);
	  var my_hour = getprop("sim/time/real/hour");
	  var my_minute = getprop("sim/time/real/minute");
    var time = sprintf("%.2i:%.2i", my_hour, my_minute);
    data_load = getprop(dataLoad);
    me.Raz_lines(x);
    me.line.title.setText("NAV IDENT  1/1");
    me.line.l1.setText("DATE");
    me.line.l2.setText(date);
    me.line.l3.setText("TIME");
    me.line.l4.setText(time);
    me.line.l5.setText(data_load ? "SW" : "-----");
    me.line.l6.setText(data_load ? "NZ5.4" : "-----");
    me.line.l7.setText("< MAINTENANCE");
    me.line.r1.setText("ACTIVE NDB").setColor(me.white);
    me.line.r2r.setText("01 JAN - 31 DEC").setColor(me.green);
    me.line.r3.setText("");
    me.line.r4r.setText("01 JAN - 31 DEC").setColor(me.green);
    me.line.r5.setText(data_load ? "NDB V4.00" : "-----")
              .setColor(me.white);
    me.line.r6r.setText(data_load ? "WORLD 2-01" : "-----")
              .setColor(me.green);
    me.line.r7.setText("POS INIT >");
  }, # end of Nav_ident

  Pos_init : func(x) {
	  my_lat = getprop("position/latitude-string");
	  my_lon = getprop("position/longitude-string");	
	  if (size(my_lat)==11) {
	    my_lat = right(my_lat,1)~left(my_lat,7);
	  }	else {
  	  my_lat = right(my_lat,1)~left(my_lat,8);
	  }
	  if (size(my_lon)==11) {
  	  my_lon = right(my_lon,1)~left(my_lon,7);
	  }	else {
  	  my_lon = right(my_lon,1)~left(my_lon,8);
	  }
    me.Raz_lines(x);
    me.line.title.setText("POSITION INIT    1/1");
    me.line.l1.setText("LAST POS");
    me.line.l3.setText(getprop(dep_apt)~"-"~getprop(dep_rwy)~"   REF WPT");
    me.line.l5.setText(x ? "GPS 2 POS" : "GPS 1 POS");
    me.line.r2r.setText("(LOAD)").setColor(me.white);
    me.line.r3.setText("");
    me.line.r4r.setText("(LOAD)").setColor(me.white);
    me.line.r5.setText("");
    me.line.r6r.setText("(LOAD)").setColor(me.white);
    me.line.r7.setText(getprop(pos_init[x]) ? "FLT PLAN >" : "");
    if (getprop(irs_pos[x])) {
      me.line.l2.setText(my_lat~"  "~my_lon);
      me.line.l4.setText(my_lat~"  "~my_lon);
      me.line.l6.setText(my_lat~"  "~my_lon);
    }
  }, # end of Pos_init

  Flp0 : func(x) {
    me.Raz_lines(x);
    me.line.title.setText("ACTIVE FLT PLAN 1/1");
    me.line.l1.setText("ORIGIN / ETD").setColor(me.white);
    me.apt = getprop(dep_apt) != "" ? getprop(dep_apt) : "----";
    me.rwy = getprop(dep_rwy) != "" ? "-"~getprop(dep_rwy) : "";
    me.line.l2.setText(me.apt~me.rwy);    
    me.line.l3.setText("< LOAD FPL");
    me.line.l7.setText("< FPL LIST");
    me.line.r3.setText("DEST").setColor(me.white);
    me.line.r4r.setText("----").setColor(me.green);
    me.line.r7.setText("PERF INIT >");
  }, # end of Flp0
   
  Flp_list : func(x) {
	  var path = getprop("/sim/fg-home")~"/Export/FlightPlans/";
    var airport = getprop(dep_apt);
	  var files = subvec(directory(path),2);
    xfile  = [];      
	  p = 0;
	  forindex(var ind;files) {		
		  if (left(files[ind],4) == airport) {
        append(xfile,(left(files[ind],size(files[ind])-4)));
      }
    }
	  cdu.cduMain.nb_pages(size(xfile),6,x);				
    me.nrPage = size(getprop(dsp[x]))<12 ? substr(getprop(dsp[x]),9,1) : substr(getprop(dsp[x]),9,2); 
	  if (size(xfile) == 0) {
      cdu.cduMain.set_alm(x,"NO FILE");
		  displayPage = 0;
	  }
    me.Raz_lines(x);
	  me.line.title.setText("FLIGHT PLAN LIST  "~me.nrPage~" / "~getprop(nbpage[x]));
    me.line.l7.setText("< FLT PLAN");
    me.Dsp_files(xfile,x);
  }, # end of Flp_list
  
  FlpMain : func(x) {
    me.nrPage = size(getprop(dsp[x])) < 12 ? substr(getprop(dsp[x]),9,1) : substr(getprop(dsp[x]),9,2);
    if (me.nrPage > getprop(nbpage[x])) me.nrPage = getprop(nbpage[x]);
    fp_size = me.fp.getPlanSize();
    p = 0;
	  for(var i=0;i<fp_size;i+=1) {		
			  n = p-(3*(me.nrPage-1));	
			  if(n==0) {
          me.line.l1.setText(sprintf(" %3i    %.1f",me.fp.getWP(i).leg_bearing,me.fp.getWP(i).leg_distance));
          flpLine = me.line.l2;
          me.Flp_offset(flpLine,i,x);
          me.line.r2l.setText(me.fp.getWP(i).speed_cstr ? sprintf("%i",me.fp.getWP(i).speed_cstr)~" /" : "--- /");
          if (me.fp.getWP(i).alt_cstr > 0 and me.fp.getWP(i).alt_cstr < 10000) {
            me.line.r2r.setText(sprintf("%i",me.fp.getWP(i).alt_cstr));
          } else if (me.fp.getWP(i).alt_cstr >= 10000){
            me.line.r2r.setText(sprintf("FL%i",me.fp.getWP(i).alt_cstr/100));
          } else if (i == fp_size-1 and me.fp_closed) {
             me.line.r2l.setText("");me.line.r2r.setText("");
             me.line.r4l.setText("");me.line.r4r.setText("");
             me.line.r6l.setText("");me.line.r6r.setText("");
          } else {me.line.r2r.setText("-----")}
          setprop(direct[x],getprop(direct[x])); #to wake up the listener
          me.Arrow(n,i,x);
        }

			  if(n==1) {
          me.line.l3.setText(sprintf(" %3i    %.1f",me.fp.getWP(i).leg_bearing,me.fp.getWP(i).leg_distance));
          flpLine = me.line.l4;
          me.Flp_offset(flpLine,i,x);
          me.line.r4l.setText(me.fp.getWP(i).speed_cstr ? sprintf("%i",me.fp.getWP(i).speed_cstr)~" /" : "--- /");
          if (me.fp.getWP(i).alt_cstr > 0 and me.fp.getWP(i).alt_cstr < 10000) {
            me.line.r4r.setText(sprintf("%i",me.fp.getWP(i).alt_cstr));
          } else if (me.fp.getWP(i).alt_cstr >= 10000){
            me.line.r4r.setText(sprintf("FL%i",me.fp.getWP(i).alt_cstr/100));
          } else if (i == fp_size-1 and me.fp_closed) {
             me.line.r4l.setText("");me.line.r4r.setText("");
             me.line.r6l.setText("");me.line.r6r.setText("");
          } else {me.line.r4r.setText("-----")}
          setprop(direct[x],getprop(direct[x])); #to wake up the listener
          me.Arrow(n,i,x);
       }

			  if(n==2) {
          me.line.l5.setText(sprintf(" %3i    %.1f",me.fp.getWP(i).leg_bearing,me.fp.getWP(i).leg_distance));
          flpLine = me.line.l6;
          me.Flp_offset(flpLine,i,x);
          me.line.r5.setText("");
          me.line.r6l.setText(me.fp.getWP(i).speed_cstr ? sprintf("%i",me.fp.getWP(i).speed_cstr)~" /" : "--- /");
          me.line.r6r.setColor(me.blue);
          if (me.fp.getWP(i).alt_cstr > 0 and me.fp.getWP(i).alt_cstr < 10000) {
            me.line.r6r.setText(sprintf("%i",me.fp.getWP(i).alt_cstr));
          } else if (me.fp.getWP(i).alt_cstr >= 10000){
            me.line.r6r.setText(sprintf("FL%i",me.fp.getWP(i).alt_cstr/100));
          } else if (i == fp_size-1 and me.fp_closed) {
             me.line.r6l.setText("");me.line.r6r.setText("");
          } else {me.line.r6r.setText("-----")}
          setprop(direct[x],getprop(direct[x])); #to wake up the listener
          me.Arrow(n,i,x);
        }
			  p+=1;
	  }
  }, ### end of FlpMain

  Flp_offset : func(flpLine,i,x) {
    hld_ind = getprop(hld_path[x]~"wpt");
    fly_over = getprop(flyover_path[x]);
    if (left(me.fp.getWP(i).wp_name,4) != me.dest_apt or me.fp_closed) {
      if (me.fp.getWP(i).wp_type == "offset-navaid"
          or (size(me.fp.getWP(i).wp_name) == 8 
            and left(me.fp.getWP(i).wp_name,4) != getprop(dep_apt)
              and left(me.fp.getWP(i).wp_name,4) != me.dest_apt))
        flpLine.setText("*"~me.fp.getWP(i).wp_name);
      else if (getprop(hld_activ[x]) and hld_ind == i and !getprop(exit))
        flpLine.setText(me.fp.getWP(i).wp_name~" H").setColor(me.amber);
      else if (fly_over > 0 and fly_over == i)
        flpLine.setText(me.fp.getWP(i).wp_name~" F").setColor(me.amber);
      else if (getprop(pcd_activ[x]) and pcd_ind == i)
        flpLine.setText(me.fp.getWP(i).wp_name~" P").setColor(me.amber);
      else flpLine.setText(me.fp.getWP(i).wp_name).setColor(me.green);
    } else if (i == 0 and left(me.fp.getWP(i).wp_name,4) == me.dest_apt)
      flpLine.setText(me.fp.getWP(i).wp_name);      
  }, ### end of Flp_offset

  Flp1 : func(x) {
    me.fp = flightplan();
    me.dest_apt = getprop(dest_apt);
    me.fp_closed = getprop(fp_active);
    me.Raz_lines(x);
		me.line.l1.setText("VIA TO");
		me.line.l2.setText("----");
		me.line.l3.setText("VIA TO");
		me.line.l4.setText("----");
		me.line.l5.setText("VIA TO");
		me.line.l6.setText("----");
    if (getprop(enable_exit) and !getprop(exit)) me.line.l7.setText("< EXIT");
    else me.line.l7.setText("< DEPARTURE");
    me.line.r2l.setText("--- /");
    me.line.r2r.setText("-----");
    me.line.r4l.setText("--- /");
    me.line.r4r.setText("-----");
    me.line.r6l.setText("--- /");
    me.line.r6r.setText("-----");
		me.line.r7.setText("ARRIVAL >");
    me.FlpMain(x);
    me.line.title.setText("ACTIVE FLT PLAN  "~me.nrPage~" / "~getprop(nbpage[x]));
    if (me.nrPage == 1) {
      me.line.l1.setText("ORIGIN / ETD");
      me.line.r1.setText("SPD  /  CMD ").setColor(me.white);
      me.line.r2l.setText("");
      me.line.r2r.setText("");
      setprop(direct[x],getprop(direct[x])); #to wake up the listener
    }
    if (me.nrPage <= getprop(nbpage[x])) {
       if (n != nil and n < 3 ) {
        me.line.r5.setText("DEST");me.line.r5.setColor(me.white);
        me.line.r6l.setText("");
        me.line.r6r.setText(getprop(dest_apt)~" "~getprop(dest_rwy))
                   .setColor(me.green);
      }
    }
    if (me.nrPage == getprop(nbpage[x]) and getprop(fp_active)) {
      me.Raz_lines(x);
      me.line.title.setText("ACTIVE FLT PLAN  "~me.nrPage~" / "~getprop(nbpage[x]));
      me.line.l4.setText("      SAVE FLP TO").setColor(me.amber);
      me.line.l7.setText("< PERF INIT");
      if (size(getprop(fp_saved)) > 9) {
		    me.line.l4.setText("        SAVED").setColor(me.amber);
        me.line.r4r.setText(getprop(fp_saved)~"  ");
      } else {me.line.r4r.setText(getprop(dep_apt)~"-"~getprop(dest_apt)~"--")}
      me.line.r4r.setColor(me.green);
			if (getprop(fp_active)) {
				me.line.r7.setText("ALTERNATE >");
			} else {me.line.r7.setText("")}
    }
  }, # end of Flp1

  Dept : func(x) {
		var dep_rwy = airportinfo(getprop(dep_apt)).runways;
	  cdu.cduMain.nb_pages(size(dep_rwy),6,0);				
    me.nrPage = size(getprop(dsp[x]))<12 ? substr(getprop(dsp[x]),9,1) : substr(getprop(dsp[x]),9,2); 
	  if (size(dep_rwy) == 0) {setprop("instrumentation/cdu["~x~"]/input","NO FILE")}
    me.Raz_lines(x);
	  me.line.title.setText(getprop(dep_apt)~" RUNWAYS "~me.nrPage~" / "~getprop(nbpage[x]));
    me.line.l7.setText("< SIDs");
    xfile = [];
	  foreach(var ind;keys(dep_rwy)) {append(xfile,ind)} # transfer hash->vector
    me.Dsp_files(xfile,x);
  }, # end of Dept

  Sid : func(x) {
		var depArpt = procedures.fmsDB.new(getprop(dep_apt));
		xfile = [];
		append(xfile,"DEFAULT");
		if (depArpt !=nil) {
		  if (getprop(dep_rwy) != "") {		
			  var Sidlist = depArpt.getSIDList(getprop(dep_rwy));
		  } else {
				  var Sidlist = depArpt.getAllSIDList();
		  }		
  		foreach(var sid; Sidlist) {append(xfile, sid.wp_name)}
    }
	  if (size(xfile) == 0) setprop("instrumentation/cdu["~x~"]/input","NO FILE");
    me.Raz_lines(x);
	  cdu.cduMain.nb_pages(size(xfile),6,0);				
    me.nrPage = size(getprop(dsp[x]))<12 ? substr(getprop(dsp[x]),9,1) : substr(getprop(dsp[x]),9,2); 
    me.line.title.setText(getprop(dep_apt)~" SID "~(me.nrPage)~" / "~getprop(nbpage[x]));
    me.line.l7.setText("< FLT PLAN");
    me.Dsp_files(xfile,x);
  }, # end of Sid

  Arrv : func(x) {
    me.Raz_lines(x);
    me.line.title.setText("ARRIVAL     1 / 1");
	  me.line.l1.setText("< RUNWAY");
	  me.line.l3.setText("< STAR");
	  me.line.l5.setText("< APPROACH");
	  me.line.l7.setText("< FLT-PLAN");
	  me.line.r1.setText("AIRPORT ");me.line.r1.setColor(me.white);
	  me.line.r2r.setText(getprop(dest_apt));me.line.r2r.setColor(me.green);
  }, # end of Arrv

  Arwy : func(x) {
    me.Raz_lines(x);
    if (getprop("autopilot/route-manager/alternate["~x~"]/set-flag")) {
		  var apt_rwy = airportinfo(getprop("autopilot/route-manager/alternate["~x~"]/airport")).runways;
      me.line.l7.setText("< ALTERNATE FPL");
      destApt = getprop("autopilot/route-manager/alternate["~x~"]/airport");      
    } else {
      var apt_rwy = airportinfo(getprop(dest_apt)).runways;
      destApt = getprop(dest_apt);      
      me.line.l7.setText("< ARRIVAL");
    }
	  cdu.cduMain.nb_pages(size(apt_rwy),6,0);				
    me.nrPage = size(getprop(dsp[x]))<12 ? substr(getprop(dsp[x]),9,1) : substr(getprop(dsp[x]),9,2); 
	  if (size(apt_rwy) == 0) setprop("instrumentation/cdu["~x~"]/input","NO FILE");
	  me.line.title.setText(destApt~" RUNWAYS "~me.nrPage~" / "~getprop(nbpage[x]));			
    xfile = [];
	  foreach(var ind;keys(apt_rwy)) {append(xfile,ind)} # transfer hash->vector
    me.Dsp_files(xfile,x);
  }, # end of Arwy

  Star : func(x) {
		xfile = [];
		var DestARPT = procedures.fmsDB.new(getprop(dest_apt));
		if (DestARPT !=nil) {
			if (getprop(dest_rwy) != "") {		
				var Starlist = DestARPT.getSTARList(getprop(dest_rwy));
			} else {
					var Starlist = DestARPT.getAllSTARList();
			}		
			foreach(var star; Starlist) {append(xfile, star.wp_name)}
		}
	  if (size(xfile) == 0) setprop("instrumentation/cdu["~x~"]/input","NO FILE");
    me.Raz_lines(x);
	  cdu.cduMain.nb_pages(size(xfile),6,0);				
    me.nrPage = size(getprop(dsp[x]))<12 ? substr(getprop(dsp[x]),9,1) : substr(getprop(dsp[x]),9,2); 
    me.line.title.setText(getprop(dest_apt)~" STAR "~(me.nrPage)~" / "~getprop(nbpage[x]));
    me.line.l7.setText("< ARRIVAL");
    me.line.r7.setText("RUNWAY >");
    me.Dsp_files(xfile,x);
  }, # end of Star

  Appr : func(x) {
		var DestARPT = procedures.fmsDB.new(getprop(dest_apt));
		xfile = [];
    append(xfile,"DEFAULT");
		if (DestARPT !=nil) {
			if (getprop(dest_rwy) != "") {		
				var Apprlist = DestARPT.getApproachList(getprop(dest_rwy));
			} else {
					var Apprlist = DestARPT.getAllApproachList();
			}		
			foreach(var appr; Apprlist) {append(xfile, appr.wp_name)}
		}
	  if (size(xfile) == 0) setprop("instrumentation/cdu["~x~"]/input","NO FILE");
    me.Raz_lines(x);
	  cdu.cduMain.nb_pages(size(xfile),6,0);				
    me.nrPage = size(getprop(dsp[x]))<12 ? substr(getprop(dsp[x]),9,1) : substr(getprop(dsp[x]),9,2); 
    me.line.title.setText(getprop(dest_apt)~" APPROACH "~me.nrPage~" / "~getprop(nbpage[x]));
    me.line.l7.setText("< ARRIVAL");
    me.line.r7.setText("RUNWAY >");
    me.Dsp_files(xfile,x);
  }, # end of Appr

  ### Alternate Flightplan ###
  Alternate : func(x) {
    me.nrPage = size(getprop(dsp[x])) < 12 ? substr(getprop(dsp[x]),9,1) : substr(getprop(dsp[x]),9,2);

    if (me.nrPage > getprop(nbpage[x])) {me.nrPage = getprop(nbpage[x])}
    me.dest_apt = getprop("autopilot/route-manager/alternate["~x~"]/airport");
    me.fp_closed = getprop("autopilot/route-manager/alternate["~x~"]/closed");

    if (me.nrPage == 0) {
      me.Raz_lines(x);
      me.line.title.setText("ALTERNATE FPL 1 / 1");
      me.line.l1.setText("ORIGIN");
      me.line.l2.setText(getprop(dep_apt)~"-"~getprop(dep_rwy));
		  me.line.r3.setText("ALTN ").setColor(me.white);
      if (getprop("autopilot/route-manager/alternate["~x~"]/airport")) {
    	  me.line.r4r
            .setText(getprop("autopilot/route-manager/alternate["~x~"]/airport"))
            .setColor(me.green);    
        me.line.r7.setText("RUNWAY >");
      } else {me.line.r4r.setText("----").setColor(me.green)}
      if (getprop("autopilot/route-manager/alternate["~x~"]/runway")) {
        me.line.l3.setText("VIA TO");
    		me.line.l4.setText("----");
    		me.line.r3.setText("");
    		me.line.r4r.setText("");
  		  me.line.r5.setText("ALTN ").setColor(me.white);
    	  me.line.r6r.setText(getprop("autopilot/route-manager/alternate["~x~"]/airport")~"-"~getprop("autopilot/route-manager/alternate["~x~"]/runway"))
               .setColor(me.green);    
        me.line.r7.setText("");
      }
    } else {
        me.Raz_lines(x);
		    me.line.l1.setText("VIA TO");
		    me.line.l2.setText("----");
        me.line.l3.setText("VIA TO");
	      me.line.l4.setText("----");
        me.line.l5.setText("VIA TO");
        me.line.l6.setText("----");
        me.line.r2l.setText("--- /");
        me.line.r2r.setText("-----");
        me.line.r4l.setText("--- /");
        me.line.r4r.setText("-----");
        me.line.r6l.setText("--- /");
        me.line.r6r.setText("-----");

        me.fp = cdu.cduMain.alt_flp(x);
        me.FlpMain(x);
        me.line.title.setText("ALTERNATE FPL "~me.nrPage~" / "~getprop(nbpage[x]));
      if (me.nrPage == 1) {
        me.line.l1.setText("ORIGIN / ETD");
        me.line.l2.setText(getprop(dep_apt)~"-"~getprop(dep_rwy));
        me.line.r1.setText("SPD  /  CMD ");me.line.r1.setColor(me.white);
        me.line.r2l.setText("");me.line.r2r.setText("");
      }
      if (me.nrPage <= getprop(nbpage[x])) {
         if (n != nil and n < 3 ) {
          me.line.r5.setText("ALTN");me.line.r5.setColor(me.white);
          me.line.r6l.setText("");
          me.line.r6r.setText(getprop("autopilot/route-manager/alternate["~x~"]/airport")~"-"~getprop("autopilot/route-manager/alternate["~x~"]/runway"))
                     .setColor(me.green);
        }
        if (n == 3) {me.line.r7.setText("NEXT PAGE >")}
        me.line.l7.setText("< FLT PLAN");
      }
    }
  }, # end of Alternate

  ##### Pattern Pages #####
  Patterns : func(x) {
    me.nrPage = substr(getprop(dsp[x]),9,1);
    me.Raz_lines(x);
    me.line.title.setText("PATTERNS 1 / 1").setColor(me.white);
    me.line.l1.setText("< HOLD");
    me.line.l3.setText("< FLYOVER");
#    me.line.l5.setText("< RADIAL");
    me.line.l7.setText("< REVIEW").setColor(me.white);
    me.line.r1.setText("PCDR TURN >").setColor(me.white);
#    me.line.r3.setText("ORBIT >").setColor(me.white);
  }, # end of Patterns

  HoldPat : func(x) {
    hld_ind = getprop(hold_path[x]~"wpt");
    hld_turn = getprop(hold_path[x]~"turn");
    hld_inbound = getprop(hold_path[x]~"inbound");
    hld_time = getprop(hold_path[x]~"time");
    hld_dist = getprop(hold_path[x]~"leg-dist-nm");
    hld_spd = getprop(hold_path[x]~"speed");
    hld_clear = getprop(hold_path[x]~"clear");
    hld_id = hld_clear ? "UNDEFINED" : getprop("autopilot/route-manager/route/wp["~hld_ind~"]/id");
    if (hld_inbound >= 0 and hld_inbound < 45) quad = "S";
    if (hld_inbound >= 45 and hld_inbound < 90) quad = "SW";
    if (hld_inbound >= 90 and hld_inbound < 135) quad = "W";
    if (hld_inbound >= 135 and hld_inbound < 180) quad = "NW";
    if (hld_inbound >= 180 and hld_inbound < 225) quad = "N";
    if (hld_inbound >= 225 and hld_inbound < 270) quad = "NE";
    if (hld_inbound >= 270 and hld_inbound < 315) quad = "E";
    if (hld_inbound >= 315 and hld_inbound < 360) quad = "SE";

    hld_bearing = getprop(route_path~hld_ind~"]/leg-bearing-true-deg");
    diff1 = geo.normdeg(hld_inbound - hld_bearing);
    diff2 = geo.normdeg(hld_bearing - hld_inbound);
    if (diff1 <= 110 or diff2 <= 70) hld_entry = "DIRECT";
    else if (diff1 > 110 and diff2 <= 180) hld_entry = "TEARDROP";
    else hld_entry = "PARALLEL";
    setprop(hld_path[x]~"entry",hld_entry);

    me.nrPage = substr(getprop(dsp[x]),9,1);
    me.Raz_lines(x);
    me.line.title.setText("HOLDING PATTERN 1 / 1").setColor(me.white);
    me.line.l1.setText("HOLD FIX");
    me.line.l2.setText(hld_id);
    if (!hld_clear) {
      me.line.l3.setText("QUAD  ENTRY");
      me.line.l5.setText("INBD CRS/DIR");
      me.line.l7.setText("< CLEAR").setColor(me.magenta);
      me.line.r1.setText("MAX END SPD").setColor(me.white);
      me.line.r3.setText("LEG TIME").setColor(me.white);
      me.line.r5.setText("LEG DIST").setColor(me.white);
      me.line.r7.setText("ACTIVATE >").setColor(me.magenta);
      me.line.l4.setText(quad~"  "~hld_entry);
      me.line.l6.setText(sprintf("%03.f",hld_inbound)~"° /"~hld_turn~" TURN");
      me.line.r2r.setText(sprintf("%.0f",hld_spd));
      me.line.r4r.setText(hld_time~" MIN");
      me.line.r6r.setText(sprintf("%.1f",hld_dist)~" NM");
    }
  }, # end of HoldPat

  PcdrTurn : func(x) {
    pcd_ind = getprop(pcd_path[x]~"wpt");
    pcd_angle = getprop(pcd_path[x]~"angle");
    pcd_turn = getprop(pcd_path[x]~"turn");
    pcd_inbound = getprop(pcd_path[x]~"inbound");
    pcd_time = getprop(pcd_path[x]~"time");
    pcd_leg = getprop(pcd_path[x]~"leg-dist-nm");
    pcd_dist = getprop(pcd_path[x]~"dist");
    pcd_spd = getprop(pcd_path[x]~"speed");
    pcd_clear = getprop(pcd_path[x]~"clear");
    pcd_id = pcd_clear ? "UNDEFINED" : getprop("autopilot/route-manager/route/wp["~pcd_ind~"]/id");
    pcd_crs = geo.normdeg(pcd_inbound + 180);
    if (pcd_turn == "L") pcd_crs = int(pcd_crs - pcd_angle);
    else pcd_crs = int(pcd_crs + pcd_angle);    
    me.Raz_lines(x);
    me.line.title.setText("PROCEDURE TURN 1 / 1").setColor(me.white);
    me.line.l1.setText("PT FIX");
    me.line.l2.setText(pcd_id);
    if (!pcd_clear) {
      me.line.l3.setText("PT ANG (CRS)");
      me.line.l5.setText("INBD CRS");
      me.line.r1.setText("BOUNDARY DIST").setColor(me.white);
      me.line.r3.setText("OUTBD TIME").setColor(me.white);
      me.line.r5.setText("OUTBD DIST").setColor(me.white);
      me.line.r7.setText("ACTIVATE >").setColor(me.magenta);
      me.line.l4.setText(pcd_turn~pcd_angle~"°"~" ("~pcd_crs~")");
      me.line.l6.setText(sprintf("%03.f",pcd_inbound)~" °");
      me.line.r2r.setText(sprintf("%.1f",pcd_leg)~" NM");
      me.line.r4r.setText(sprintf("%.1f",pcd_time)~" MIN");
      me.line.r6r.setText(sprintf("%.1f",pcd_dist)~" NM");
    }

  }, # end of PcdrTurn
  
  ### Performances Pages ###
  Prf : func(x) {
    me.addPage = me.nrPage = substr(getprop(dsp[x]),9,1);
    if (me.nrPage > getprop(nbpage[x])) me.nrPage = getprop(nbpage[x]);
    titl = getprop(perf_confd[x]) ? "DATA " : "INIT ";
    titl = me.nrPage~" / "~getprop(nbpage[x]);
    if (me.nrPage == 1) {
      me.Raz_lines(x);
      me.line.title.setText("PERFORMANCE INIT "~titl);
		  me.line.l3.setText("  ACFT TYPE");
		  me.line.l4.setText(string.uc(getprop("sim/description")));
		  me.line.l7.setText("< FLT PLAN");
      me.line.r3.setText("TAIL #").setColor(me.white);
      me.line.r4r.setText(string.uc(getprop("sim/multiplay/callsign")))
                 .setColor(me.green);
    }
    if (me.nrPage == 2) {
		  ClimbSpeed_kt = sprintf("%.0f",getprop("autopilot/settings/climb-speed-kt"));
		  ClimbSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/climb-speed-mc"));
		  DescSpeed_kt = getprop("autopilot/settings/descent-speed-kt");
		  DescSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/descent-speed-mc"));
		  DescAngle = sprintf("%.1f",getprop("autopilot/settings/descent-angle"));
		  CruiseSpeed_kt = getprop("autopilot/settings/cruise-speed-kt");
		  CruiseSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/cruise-speed-mc"));
		  Cruise_alt = getprop("autopilot/settings/asel");
      me.Raz_lines(x);
      me.line.title.setText("PERFORMANCE INIT "~titl);
      me.line.l1.setText(" CLIMB");
      me.line.l2.setText(ClimbSpeed_kt~" / "~ClimbSpeed_mc);
      me.line.l3.setText(" CRUISE");
      me.line.l4.setText(CruiseSpeed_kt~" / "~CruiseSpeed_mc);
      me.line.l5.setText(" DESCENT");
      me.line.l6.setText(DescSpeed_kt~" / "~DescSpeed_mc~" / "~DescAngle);
			me.line.l7.setText("< DEP/APP SPD");
			me.line.r3.setText("<------>  ALTITUDE").setColor(me.white);
			me.line.r4r.setText("FL "~Cruise_alt).setColor(me.green);
    }
    if (me.nrPage == 3) {
      me.Raz_lines(x);
      me.line.title.setText("PERFORMANCE INIT "~titl);
      me.line.l1.setText(" STEP INCREMENT");
      me.line.l2.setText("0");
      me.line.l3.setText(" FUEL RESERVE");
      me.line.l4.setText("NBAA");
      me.line.l5.setText(" TO / LDG FUEL");
      me.line.l6.setText("400 / 200 LB");
#      me.line.r4r.setText("OR >").setColor(me.green);
    }
    if (me.nrPage == 4) {
      me.Raz_lines(x);
      wind_spd_kt = sprintf("%.0f",getprop("environment/wind-speed-kt"));
      wind_spd_hd = sprintf(" %3i",getprop("environment/wind-from-heading-deg"));
      trans_alt = sprintf("% .0f",getprop(trs_alt[x]));
      me.line.title.setText("PERFORMANCE INIT "~titl);
      me.line.l1.setText(" TRANS ALT");
      me.line.l2.setText(trans_alt);
      me.line.l3.setText(" INIT CRZ ALT");
      me.line.l4.setText(" OPTIMUM");
      me.line.l5.setText(" CRZ WINDS AT ALTITUDE");
      me.line.l6.setText(wind_spd_hd~" / "~wind_spd_kt);
			me.line.r1.setText("SPD/ALT LIM").setColor(me.white);
      me.line.r2r.setText("260 / 7800 ").setColor(me.green);
      me.line.r3.setText("ISA DEV  ").setColor(me.white);
      me.line.r4r.setText("+0 °C ").setColor(me.green);
      me.line.r6r.setText("FL "~Cruise_alt~" ").setColor(me.green);
#		  me.line.r7.setText("NEXT PAGE >");
    }
    if (me.nrPage == 5) {
		  Wfuel = sprintf("%3i", math.ceil(getprop("consumables/fuel/total-fuel-lbs")));
		  Wcrew = getprop("sim/weight[0]/weight-lb");
		  Wpass = getprop("sim/weight[1]/weight-lb");
		  Wcarg = getprop("sim/weight[2]/weight-lb");
      me.Raz_lines(x);
      me.line.title.setText("PERFORMANCE INIT "~titl);
      me.line.l1.setText(" BOW");
      me.line.l2.setText("21700");
      me.line.l3.setText(" FUEL");
      me.line.l4.setText(Wfuel);
      me.line.l5.setText(" CARGO");
      me.line.l6.setText(sprintf("%.0f",Wcarg));
      me.line.r1.setText("PASS/CREW LBS  ").setColor(me.white);
      me.line.r2r.setText(" "~int(Wpass/170)~" / 2  "~" 170  ")
                 .setColor(me.green);
      me.line.r3.setText("PASS WT  ").setColor(me.white);
      me.line.r4r.setText(sprintf("%3i",Wpass + Wcrew)~"  ").setColor(me.green);
      me.line.r5.setText("GROSS WT  ").setColor(me.white);
      me.line.r6r.setText(sprintf("%3i",21700 + Wfuel + Wcrew + Wpass + Wcarg)~"  ")
                 .setColor(me.green);
#		  me.line.r7.setText(getprop(perf_confd[x]) ? "RETURN > ":"CONFIRM INIT >");
		  me.line.r7.setText("RETURN >");
    }
### Additional pages ###
    if (me.addPage == 6) {
		  dep_spd = sprintf("%i",getprop("autopilot/settings/dep-speed-kt"));
		  Agl = sprintf("%i",getprop("autopilot/settings/dep-agl-limit-ft"));
		  Nm = sprintf("%.1f",getprop("autopilot/settings/dep-limit-nm"));
      me.Raz_lines(x);
      me.line.title.setText("DEPARTURE SPEED 1 / 1");
      me.line.l1.setText(" SPEED LIMIT");
      me.line.l2.setText(dep_spd);
      me.line.l3.setText(" AGL  <------LIMIT ------> NM");
      me.line.l4.setText(Agl);
			me.line.l7.setText("< APP SPD");
			me.line.r4r.setText(Nm).setColor(me.green);
		  me.line.r7.setText("RETURN >");
    }
    if (me.addPage == 7) {
		  AppSpeed5 = sprintf("%i",getprop("autopilot/settings/app5-speed-kt"));
		  AppSpeed15 = sprintf("%i",getprop("autopilot/settings/app15-speed-kt"));
		  AppSpeed35 = sprintf("%i",getprop("autopilot/settings/app35-speed-kt"));
      me.Raz_lines(x);
      me.line.title.setText("APPROACH SPEED  1 / 1");
      me.line.l1.setText(" FLAPS 5");
      me.line.l2.setText(AppSpeed5);
      me.line.l3.setText(" FLAPS 15");
      me.line.l4.setText(AppSpeed15);
      me.line.l5.setText(" FLAPS 35");
      me.line.l6.setText(AppSpeed35);
		  me.line.r7.setText("RETURN >");
    }
  }, # end of Prf

  ##### Nav Pages #####
  Nav : func(x) {
    me.nrPage = substr(getprop(dsp[x]),9,1);
    if (me.nrPage > getprop(nbpage[x])) me.nrPage = getprop(nbpage[x]);
    me.Raz_lines(x);
    me.line.title.setText("NAV INDEX "~me.nrPage~" / "~getprop(nbpage[x]));
    if (me.nrPage == 1) me.line.l1.setText("< FPL LIST");
    if (me.nrPage == 2) {
      me.line.l1.setText("< CONVERSION");
      me.line.r1.setText("PATERNS >").setColor(me.white);
    }
  }, #end of Nav

  Nav_list : func(x) {
    me.Flp_list(x);
    me.line.l7.setText("");
	  me.line.r7.setText("FPL SEL >");
  }, # end of Nav_list

  Nav_sel : func(x) {
    me.nrPage = substr(getprop(dsp[x]),9,1);
    cdu_ret = cdu.cduMain.nav_var();
    navSel = cdu_ret[0];
    if (me.nrPage == 1 ) {
      me.Raz_lines(x);
	    var flp_sel = getprop("instrumentation/cdu["~x~"]/input");
      me.line.title.setText("FLT PLAN LIST 1 / 1");
		  me.line.l1.setText("< SHOW FPL");
		  me.line.l2.setText(navSel);
		  me.line.r1.setText("ORG / DEST ").setColor(me.white);
      if (flp_sel) {
        me.line.r2r.setText(left(flp_sel,4)~" / "~substr(flp_sel,5,4)).setColor(me.green);
      }
		  me.line.r7.setText("FPL SEL >");
    }
    if (me.nrPage == 2 ) {
      cdu_ret = cdu.cduMain.nav_var();
      navWp = cdu_ret[1];
      navRwy = cdu_ret[2];
      dist = cdu_ret[3];
      g_speed = cdu_ret[4];
      me.Raz_lines(x);
	    var ete_h = int(dist/g_speed);
	    var ete_mn = int((dist/g_speed-ete_h)*60);
      var line4 = line5 = line6 = "";
      me.line.title.setText(navSel~" 1 / 1");
      me.line.l1.setText(" ORGIN");
      me.line.l2.setText(navWp.vector[0]~" "~navRwy.vector[0]);
      me.line.r1.setText("DIST / ETE    GS ").setColor(me.white);
      me.line.r2r.setText(sprintf("%.0f",dist)~" / "~sprintf("%02d",ete_h)~"+"~sprintf("%02d",ete_mn)~" @ "~g_speed).setColor(me.green);
      me.line.l3.setText(" VIA TO").setColor(me.white);
      me.line.r3.setText("DEST  ").setColor(me.white);;
			for (var i=1;i<size(navWp.vector)-1;i+=1) {
				if (i < 6) {line4 = line4 != "" ? line4~" "~navWp.vector[i] : navWp.vector[i]}
				else if (i<11) {line5 = line5 != "" ? line5~" "~navWp.vector[i] : navWp.vector[i]}
				else if (i<16) {line6 = line6 != "" ? line6~" "~navWp.vector[i] : navWp.vector[i]}
			}
			me.line.l4.setText(line4);
		  me.line.l5.setText(line5);me.line.l5.setColor(me.green);
		  me.line.l6.setText(line6);
      me.line.l7.setText("< FPL LIST");
      me.line.r4r.setText(navWp.vector[size(navWp.vector)-1]~" "~navRwy.vector[1]).setColor(me.green);
      me.line.r7.setText("FPL SEL >");
    }
    if (me.nrPage == 3 ) {
      me.Raz_lines(x);
      me.line.title.setText("FLT PLAN SELECT 1 / 1");
		  me.line.l1.setText(" FLT PLAN");
		  me.line.l2.setText(navSel);
      me.line.l7.setText("< FPL LIST");
      me.line.r2r.setText("ACTIVATE >").setColor(me.white);
      me.line.r4r.setText("INVERT/ACTIVATE >").setColor(me.white);
      me.line.r6r.setText("STORED FPL PERF >").setColor(me.white);
    }
  }, # end of Nav_sel

  Nav_activ : func(x) {
    me.Raz_lines(x);
    me.line.title.setText("FLT PLAN SELECT 1 / 1");
    me.line.l4.setText("     CONFIRM  REPLACING").setColor(me.amber);
    me.line.l5.setText("     ACTIVE FLIGHT PLAN").setColor(me.amber);
    me.line.l7.setText("< NO");
    me.line.r7.setText("YES >");
  }, # end of Nav_activ

  Nav_conv : func(x) {
    me.nrPage = substr(getprop(dsp[x]),9,1);
    me.Raz_lines(x);
    conv = cdu.cduMain.conv_table(x);
    if (me.nrPage == 1 ) {
      me.line.title.setText("CONVERSION 1 / 4").setColor(me.white);
      me.line.l1.setText("   FT").setColor(me.white);
      me.line.l3.setText("   LB").setColor(me.white);
      me.line.l5.setText("   GAL").setColor(me.white);
      me.line.r1.setText("M    ").setColor(me.white);
      me.line.r3.setText("KG   ").setColor(me.white);
      me.line.r5.setText("L    ").setColor(me.white);
      me.line.l1m.setText(conv.FL != nil ? "FL" : "" )
                .setColor(me.white);
      me.line.l2.setText(conv.FT != nil ? " "~conv.FT : " ------.-" )
                .setColor(me.green);
      me.line.l2r.setText(conv.FL != nil ? "           "~conv.FL : "" )
                .setColor(me.green);
      me.line.r2r.setText(conv.M != nil ? conv.M~" " : " ------.-" )
                .setColor(me.green);
      me.line.l4.setText(conv.LB != nil ? " "~conv.LB : " ------.-" )
                .setColor(me.green);
      me.line.r4r.setText(conv.KG != nil ? conv.KG~" " : " ------.-" )
                .setColor(me.green);
      me.line.l6.setText(conv.GAL != nil ? " "~conv.GAL : " ------.-" )
                .setColor(me.green);
      me.line.r6r.setText(conv.L != nil ? conv.L~" " : " ------.-" )
                .setColor(me.green);
    } 
    if (me.nrPage == 2 ) {
      me.line.title.setText("CONVERSION 2 / 4").setColor(me.white);
      me.line.l1.setText("   F").setColor(me.white);
      me.line.l3.setText("   KTS").setColor(me.white);
      me.line.l5.setText("   NM").setColor(me.white);
      me.line.r1.setText("C    ").setColor(me.white);
      me.line.r3.setText("M/S  ").setColor(me.white);
      me.line.r5.setText("KM   ").setColor(me.white);
      me.line.l2.setText(conv.F != nil ? " "~conv.F : " ----.-" )
                .setColor(me.green);
      me.line.r2r.setText(conv.C != nil ? conv.C~" " : " ---.-" )
                .setColor(me.green);
      me.line.l4.setText(conv.KTS != nil ? " "~conv.KTS : " ---.-" )
                .setColor(me.green);
      me.line.r4r.setText(conv.MS != nil ? conv.MS~" " : " ------.-" )
                .setColor(me.green);
      me.line.l6.setText(conv.NM != nil ? " "~conv.NM : " ------.-" )
                .setColor(me.green);
      me.line.r6r.setText(conv.KM != nil ? conv.KM~" " : " ------.-" )
                .setColor(me.green);
    }
    if (me.nrPage == 3 ) {
      me.line.title.setText("CONVERSION 3 / 4").setColor(me.white);
      me.line.l1.setText("  LB").setColor(me.white);
      me.line.l3.setText("  GAL").setColor(me.white);
      me.line.l5.setText("  LB/GAL").setColor(me.white);
      me.line.r1.setText("WT-VOLUME     KG   ").setColor(me.white);
      me.line.r3.setText("L   ").setColor(me.white);
      me.line.r5.setText("<- SP WT ->   KG/L ").setColor(me.white);
      me.line.l2.setText(conv.LB != nil ? " "~conv.LB : " ------.-" )
                .setColor(me.green);
      me.line.r2r.setText(conv.KG != nil ? conv.KG~" " : " ------.-" )
                .setColor(me.green);
      me.line.l4.setText(conv.GAL != nil ? " "~conv.GAL : " ------.-" )
                .setColor(me.green);
      me.line.r4r.setText(conv.L != nil ? conv.L~" " : " ------.-" )
                .setColor(me.green);
      me.line.l6.setText(conv.LBGAL != nil ? " "~conv.LBGAL : " ------.-" )
                .setColor(me.green);
      me.line.r6r.setText(conv.KGL != nil ? conv.KGL~" " : " ------.-" )
                .setColor(me.green);
    }
    if (me.nrPage == 4 ) {
      me.line.title.setText("CONVERSION 4 / 4").setColor(me.white);
      me.line.l3.setText("  QFE").setColor(me.white);
      me.line.l4.setText(conv.QFE != nil ? " "~conv.QFE : " --.--" )
                .setColor(me.green);
      me.line.l6.setText(conv.QFE != nil ? " "~sprintf("%.0f",conv.QFE*33.8639) : " ---" ).setColor(me.green);
      me.line.l7.setText(conv.QFE != nil ? " "~sprintf("%.0f",conv.QFE*25.4) : " ---" ).setColor(me.green);
      me.line.r1.setText("QFE-QNH      ELEV ").setColor(me.white);
      me.line.r2r.setText(conv.ELEV != nil ? " "~conv.ELEV : " -----" )
                .setColor(me.green);
      me.line.r3.setText("QNH  ").setColor(me.white);
      me.line.r4l.setText("<-IN  HG->   ").setColor(me.white);
      me.line.r4r.setText(conv.QNH != nil ? conv.QNH : " --.--" )
                .setColor(me.green);
      me.line.r6l.setText("<--MB/HPA-->  ").setColor(me.white);
      me.line.r6r.setText(conv.QNH != nil ? sprintf("%.0f",conv.QNH*33.8639) : " ----" ).setColor(me.green);
      me.line.r7m.setText(" <----MM---->").setColor(me.white);
      me.line.r7.setText(conv.QNH != nil ? " "~sprintf("%.0f",conv.QNH*25.4) : " ---" ).setColor(me.green);
    }
  }, # end of Nav_conv

  ##### Prog Pages #####
  Progress : func(x) {
    me.nrPage = substr(getprop(dsp[x]),9,1);
    me.Raz_lines(x);
    if (me.nrPage == 1 ) {
      me.line.title.setText("PROGRESS     1 / 1");
      me.line.l1.setText(" TO     DIST");
      me.line.l3.setText("DEST");
      me.line.l7.setText("< NAV 1");
      me.line.r1.setText("ETE     FUEL ").setColor(me.white);
      me.line.r7.setText("NAV 2 >");
    } else {
        if (me.nrPage == 2) {me.line.title.setText("NAV 1")}
        if (me.nrPage == 3) {me.line.title.setText("NAV 2")}
        var navs = findNavaidsWithinRange(60,'ils');
        p = 0;
		    foreach(var ind;navs) {
			    if (ind != "") {		
		        if(p==0) {
              me.line.l1.setText(ind.name).setFontSize(44);
              me.line.l2.setText("< "~ind.id~" "~sprintf("%.2f",ind.frequency/100));
            }
		        if(p==1) {
              me.line.l3.setText(ind.name).setFontSize(44);
              me.line.l4.setText("< "~ind.id~" "~sprintf("%.2f",ind.frequency/100));
            }
		        if(p==2) {
              me.line.l5.setText(ind.name).setFontSize(44);
              me.line.l6.setText("< "~ind.id~" "~sprintf("%.2f",ind.frequency/100));
            }
		        if(p==3) {
              me.line.r1.setText(ind.name).setFontSize(44).setColor(me.white);
              me.line.r2r.setText(ind.id~" "~sprintf("%.2f",ind.frequency/100)~" >")
                         .setColor(me.green);
            }
		        if(p==4) {
              me.line.r3.setText(ind.name).setFontSize(44).setColor(me.white);
              me.line.r4r.setText(ind.id~" "~sprintf("%.2f",ind.frequency/100)~" >")
                         .setColor(me.green);
            }
		        if(p==5) {
              me.line.r5.setText(ind.name).setFontSize(44).setColor(me.white);
              me.line.r6r.setText(ind.id~" "~sprintf("%.2f",ind.frequency/100)~" >")
                         .setColor(me.green);
            }
            setprop("instrumentation/cdu["~x~"]/l"~(p+1),sprintf("%.2f",ind.frequency/100));
		        p+=1;
          }
	      }
      me.line.l7.setText("< PROGRESS");
    }
  }, # end of Progress

  Prog_timer : func {
		me.timer = maketimer(0.1,func() {
      fuel_cons = getprop(fuel_flow[0]) + getprop(fuel_flow[1]);
      EstWp_time = getprop(velocity) > 1 ? int(getprop(nav_dist))/int(getprop(velocity)) : 0;
		  FuelEstWp = int(EstWp_time * fuel_cons);
      EstDest_time = getprop(velocity) > 1 ? int(getprop(dist_rem))/int(getprop(velocity)) : 0;
		  FuelEstDest = int(EstDest_time * fuel_cons);
      nav_id = getprop("autopilot/internal/nav-id");
		  ETA = getprop("autopilot/route-manager/wp/eta");
		  if (!ETA) {ETA = "0+00"}
      else {
        me.vec_eta = split(":",ETA);
        me.h_eta = int(me.vec_eta[0]);
        me.mn_eta = me.vec_eta[1];
        ETA = me.h_eta~"+"~sprintf("%02i",me.mn_eta);
      } 
		  ETE = getprop("/autopilot/internal/nav-ete");
      me.vec_ete = split("ETE ",ETE);
      ETE = me.vec_ete[1];
		  Nav_type = getprop("/autopilot/internal/nav-type");
		  Nav1_id = getprop("/instrumentation/nav/nav-id") or "";
		  Nav1_freq = sprintf("%.3f",getprop("/instrumentation/nav/frequencies/selected-mhz"));
		  Nav2_id = getprop("/instrumentation/nav[1]/nav-id");
		  Nav2_freq = sprintf("%.3f",getprop("/instrumentation/nav[1]/frequencies/selected-mhz"));

		  me.line.l2.setText(nav_id);
      me.line.l2r.setText(sprintf("%3i",getprop("/autopilot/internal/nav-distance")));
      if (left(getprop("autopilot/settings/nav-source"),3) == "FMS") {
        me.line.l4.setText(getprop(dest_apt));
        me.line.l4r.setText(sprintf("%3i",getprop("autopilot/route-manager/distance-remaining-nm")));
        me.line.r4l.setText(ETE~"   ").setColor(me.green);
      } else {
        me.line.l4.setText(""); 
        me.line.l4r.setText(sprintf("%3i",0));
        me.line.r4l.setText(ETE~"   ").setColor(me.green);
      }
      me.line.l6.setText("   "~Nav1_id~" "~Nav1_freq);
      me.line.r2l.setText(ETA~"   ").setColor(me.green);
      me.line.r2r.setText(FuelEstWp~" ").setColor(me.green);
      me.line.r4r.setText(FuelEstDest~" ").setColor(me.green);

		  if (Nav_type == "VOR1" or Nav_type == "FMS1" or Nav_type == "ILS1") { 
			  me.line.l5.setText("     " ~Nav_type~" <---");
        me.line.r5.setText(left(Nav_type,3)~"2    ").setColor(me.white);
		  }	else {
			  me.line.l5.setText("     " ~Nav_type);
        me.line.r5.setText("---> "~Nav_type~"    ").setColor(me.white);
      }
      me.line.r6r.setText(Nav2_id~" "~Nav2_freq~" ").setColor(me.green);
    });
 }, # end of Prog_timer

  ###### Common Functions ######

  Dsp_files : func(xfile,x) {
    p = 0;
    for (i=1;i<7;i+=1) {setprop("instrumentation/cdu["~x~"]/l"~i,"")} # raz
		foreach(var file;xfile) {
			n = p-(6*(me.nrPage-1));		
	    if(n==0) {me.line.l2.setText(file)}
	    if(n==1) {me.line.l4.setText(file)}
	    if(n==2) {me.line.l6.setText(file)}
	    if(n==3) {me.line.r2r.setText(file).setColor(me.green)}
	    if(n==4) {me.line.r4r.setText(file).setColor(me.green)}
	    if(n==5) {me.line.r6r.setText(file).setColor(me.green)}
	    p+=1;
      if (n >= 0 and n < 6) {
        setprop("instrumentation/cdu["~x~"]/l"~(n+1),file)
      }
	  }
  }, # end of Dsp_files

  Raz_lines : func(x) {
    foreach(var element;me.line_val) me.line[element].setText("");
    me.arrow.hide();
    me.Base_colors(x);
  }, # end of Raz_lines

  Scr_pad : func (x) {
    me.scrpad.show();
    _alm = cdu.cduMain.alarms_scrpad(x);
    if (size(_alm) > 0) me.scrpad.setText(_alm[size(_alm)-1]);
    else me.scrpad.setText("");
  }, # end of Scr_pad

  Base_colors : func(x) {
    me.white = [1,1,1,getprop("controls/lighting/cdu["~x~"]")];
    me.yellow = [1,1,0,getprop("controls/lighting/cdu["~x~"]")];
    me.amber = [0.9,0.5,0,getprop("controls/lighting/cdu["~x~"]")];
    me.green = [0,1,0,getprop("controls/lighting/cdu["~x~"]")];
    me.blue = [0,0.8,1,getprop("controls/lighting/cdu["~x~"]")];
    me.magenta = [0.9,0,0.9,getprop("controls/lighting/cdu["~x~"]")];

    me.l_color = [me.white,me.white,me.white,me.green,me.green, # title,l1,l1m,l2,l2r
                  me.white,me.green,me.green,me.white,    # l3,l4,l4r,l5
                  me.green,me.magenta,me.green,me.blue,   # l6,l7,r1,r2l  
                  me.blue,me.green,me.blue,me.blue,       # r2r,r3,r4l,r4r
                  me.green,me.blue,me.blue,me.magenta,    # r5,r6l,r6r,r7
                  me.white];                              # r7m
    var ind = 0;
    foreach(var i;me.line_val) {    
      me.line[i].setColor(me.l_color[ind]);
      ind+=1;
    }
    me.scrpad.setColor(me.yellow);
    me.arrow.setColor(me.green);
    me.arrow.setColorFill(me.green);
  }, # end of Base_colors

  Arrow : func(n,i,x) {
    if (left(getprop(dsp[x]),8) == "FLT-PLAN") {
      if (i == getprop(currWp)) {
        me.arrow.show();
        me.arrow.setTranslation(0,145*n);
        if (i == getprop("instrumentation/cdu["~x~"]/direct-to")) {
          if (n == 0) {me.line.l2.setColor(me.amber)}
          if (n == 1) {me.line.l4.setColor(me.amber)}
          if (n == 2) {me.line.l6.setColor(me.amber)}
          me.arrow.setColor(me.amber);
        }
      }
    }
    else {
      me.line.l2.setColor(me.green);
      me.line.l4.setColor(me.green);
      me.line.l6.setColor(me.green);
    }
  }, # end of Arrow

}; # end of cduDsp
  
##### Main #####
var cdu_DspL = cduDsp.new(0);
var cdu_DspR = cduDsp.new(1);
var cdu_setl = setlistener("sim/signals/fdm-initialized", func {
  settimer(run_cdu_Dsp,2);
  removelistener(cdu_setl);
});

var run_cdu_Dsp = func {
  cdu_DspL.Listen(0);
  cdu_DspR.Listen(1);
  cdu_DspL.Nav_ident(0);
  cdu_DspR.Nav_ident(1);
  cdu_DspL.Prog_timer();
  cdu_DspR.Prog_timer();
}

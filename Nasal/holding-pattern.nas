########################################
#  HOLDING PATTERN
#  C. Le Moigne (clm76) - 2020
########################################

var hold_activ = ["instrumentation/cdu/hold/active",
                  "instrumentation/cdu[1]/hold/active"];
var direct = ["instrumentation/cdu/direct",
              "instrumentation/cdu[1]/direct"];
var fms = "autopilot/settings/nav-source";
var wp = "autopilot/route-manager/route/wp[";
var h_path = ["instrumentation/cdu/hold/",
              "instrumentation/cdu[1]/hold/"];
var htree = "autopilot/locks/hold/";
var exit = "autopilot/locks/hold/exit";
var enable_exit = "autopilot/locks/hold/enable-exit";
var bank = "autopilot/settings/bank-limit";
var ind_alt = "instrumentation/altimeter/indicated-altitude-ft";
var tg_alt = "autopilot/settings/tg-alt-ft";
var crs_defl = "autopilot/internal/course-deflection";
var cdi_defl = "instrumentation/gps/cdi-deflection";

var activ = 0;
var coord = nil;
var coord_dist = nil;
var course = nil;
var CourseError = nil;
var enable_update = 0;
var geoCoord = nil;
var h_dist = nil;
var h_entry = nil;
var h_inbound = nil;
var h_turn = nil;
var heading = nil;
var grd_spd = nil;
var phase = 0;
var pos_lat = nil;
var pos_lon = nil;
var tg_lat = nil;
var tg_lon = nil;
var left0=left1=left2 = nil;
var right0=right1=right2 = nil;
var x0=x1=x2=x3=x4 = nil;
var y0=y1=y2=y3=y4 = nil;
var diff1=diff2 = nil;
var turn = [nil,nil,nil];
var turn_diam = nil;
var wpt = nil;

var Hold = {
	new: func () {
		var m = {parents:[Hold]};
    return m;
  }, # end of new

  init : func {
    setprop(enable_exit,0);
    setprop(exit,0);
    setprop(htree~"phase",0);
  }, # end of init
  
  listen : func(x) {
		setlistener(hold_activ[x], func(n) {
      if (n.getValue() and getprop(fms) == "FMS"~(x+1)) {
        setprop("autopilot/settings/target-speed-kt",getprop(h_path[x] ~"speed"));
        setprop(htree~"phase",0);
        me.pattern_calc(x);
        enable_update = 1;
        me.update(x);
       # me.plot_hold(x); for test
      }
    },0,0);
  }, # end of listen

  update : func (x) {
	  phase = getprop(htree ~"phase");
    heading = getprop("orientation/heading-deg");
#	  heading = getprop("/orientation/heading-magnetic-deg");
		geoCoord = geo.aircraft_position();

  # ###### HOLD POINTS LAYOUT ########
  #             phase 4              #
  #          3----------> 0 FIX      #
  # phase 3 (              ) phase 1 #
  #          2 <----------1          #
  #             phase 2              #
  ####################################

    if (phase == 0) { ## Fly to Fix
      if(me.flyto(y0,x0) == 0) {
        coord.set_latlon(y0,x0);
        coord_dist = geoCoord.distance_to(coord);
        if (coord_dist < 2000) {
          setprop("autopilot/settings/fms",0);
          setprop(enable_exit,1);
        }
      }
      else if(me.flyto(y0,x0) == 1) {
        setprop(tg_alt,math.round(getprop(ind_alt),100));
        if (h_entry == "DIRECT") phase = 1;
        else if (h_entry == "TEARDROP") phase = 2;
        else phase = 3; # parallel
      }
      if (getprop(exit)) me.exit_hold(x);
    }
    else if (phase == 1) { ## Fly to point 1
      if (getprop(exit)) me.exit_hold(x);
      if (me.flyto(y1,x1) == 1) phase = 2;
    } 
    else if (phase == 2) { ## Fly to point 2
      if (getprop(exit)) {
        if (h_entry == "DIRECT") phase = 4;
      }
      else if (me.flyto(y2,x2) == 1) {
        if (h_entry == "PARALLEL") phase = 4;
        else phase = 3;
      }
    } 
    else if (phase == 3) { ## Fly to point 3
      if (me.flyto(y3,x3) == 1) {
        if (h_entry == "PARALLEL") phase = 2;
        else phase = 4;
      }
    }
    else if (phase == 4) { ## Return to point 0
      coord.set_latlon(y0,x0);
      if (getprop(exit)) {
        if (h_entry == "PARALLEL") me.exit_hold(x);
      }
      if (me.flyto(y0,x0) == 1) {
        if (getprop(exit)) me.exit_hold(x);
        else phase = 1;
      }
    } 

    setprop(htree~"phase",phase);
    if (enable_update) settimer(func {me.update(x);},0.1);

  }, # end of update

  flyto : func(tg_lat, tg_lon) {
    pos_lat = getprop("/position/latitude-deg");
    pos_lon = getprop("/position/longitude-deg");
    if (!getprop("autopilot/settings/fms")) {
      coord.set_latlon(tg_lat, tg_lon);
      course = geoCoord.course_to(coord);
      CourseError = geo.normdeg180(course - heading);
      setprop("autopilot/settings/selected-crs",course);
	    setprop("autopilot/internal/course-offset",CourseError);
      setprop(crs_defl,getprop(cdi_defl));
      setprop("autopilot/locks/from-flag",0);
    }
    # Check if Target is Reached
    if (pos_lat <= tg_lat + 0.0075 and pos_lat >= tg_lat - 0.0075 and pos_lon <= tg_lon + 0.0075 and pos_lon >= tg_lon - 0.0075) { 
      return 1; # target reached
    } else return 0; # target not reached

  }, # end of flyto

  pattern_calc : func(x) {
	  h_turn = getprop(h_path[x] ~"turn");
	  h_inbound = getprop(h_path[x] ~"inbound");
	  h_entry = getprop(h_path[x] ~"entry");
	  wpt = getprop(h_path[x] ~"wpt");
	  h_dist = getprop(h_path[x] ~"leg-dist-nm");
	  left0 = geo.normdeg(h_inbound - 90);
	  left1 = geo.normdeg(h_inbound - 180);
	  right0 = geo.normdeg(h_inbound + 90);
	  right1 = geo.normdeg(h_inbound + 180);
    grd_spd = getprop("instrumentation/cdu["~x~"]/hold/speed") + 20;
      ### R = V*V/tg(°incl in rad)*9.81 in meters
	  turn_diam = 2*math.pow(grd_spd*0.5144,2)/(math.tan(getprop(bank)*D2R)*9.81); 
    x0 = getprop(wp~wpt~"]/longitude-deg");
    y0 = getprop(wp~wpt~"]/latitude-deg");

    coord = geo.Coord.new();
    coord.set_latlon(y0,x0);
    coord.apply_course_distance(h_turn == "L" ? left0 : right0,turn_diam);
    x1 = coord.lon();
    y1 = coord.lat();

    coord.set_latlon(y1,x1);
    coord.apply_course_distance(h_turn == "L" ? left1 : right1,h_dist*1852);
    x2 = coord.lon();
    y2 = coord.lat();

    coord.set_latlon(y2,x2);
    coord.apply_course_distance(h_turn == "L" ? right0 : left0,turn_diam);
    x3 = coord.lon();
    y3 = coord.lat();

  }, # end of pattern_calc

  exit_hold : func(x) {
    setprop("autopilot/settings/fms",1);
    setprop("autopilot/locks/hold/active",0);
    setprop(enable_exit,0);
    setprop(htree~"phase",0);
    setprop(hold_activ[x],0);
    setprop(direct[x],0);
    enable_update = 0;
    setprop(exit,0);
  }, # end of exit_hold

  plot_hold : func(x) { # for tests, not used
    var fp = flightplan();
    var wp = createWP(y1,x1,"1");
    fp.insertWP(wp,wpt+1);
    wp = createWP(y2,x2,"2");
    fp.insertWP(wp,wpt+2);
    wp = createWP(y3,x3,"3");
    fp.insertWP(wp,wpt+3);
  }, # end of plot_hold

}; # end of Hold

var setl_hold = setlistener("/sim/signals/fdm-initialized", func {
  var hld_pat = Hold.new();
  hld_pat.init();
  hld_pat.listen(0);
  hld_pat.listen(1);
	removelistener(setl_hold);
},0,0);


########################################
# HOLDING PATTERN
# Based on 787-8 Holding Pattern
# Adapted by C. Le Moigne (clm76) - 2020
########################################

var hold_activ = ["instrumentation/cdu/hold/active",
                  "instrumentation/cdu[1]/hold/active"];
var direct = ["instrumentation/cdu/direct",
              "instrumentation/cdu[1]/direct"];
var fms = "autopilot/settings/nav-source";
var wp = "autopilot/route-manager/route/wp[";
var inpt = "autopilot/route-manager/input";
var h_path = ["instrumentation/cdu/hold/",
              "instrumentation/cdu[1]/hold/"];
var htree = "autopilot/auto-hold/";
var exit = "autopilot/auto-hold/exit";
var enable_exit = "autopilot/auto-hold/enable-exit";

var courseCoord = nil;
var CourseError = nil;
var enable_update = 0;
var geoCoord = nil;
var h_bearing = nil;
var h_clear = 0;
var h_dist = nil;
var h_entry = nil;
var h_inbound = nil;
var h_id = nil;
var h_time = nil;
var h_turn = nil;
var heading = nil;
var coord = nil;
var gs = nil;
var phase = 0;
var pos_lat = nil;
var pos_lon = nil;
var tg_lat = nil;
var tg_lon = nil;
var track_error = nil;
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
        setprop("autopilot/settings/fms",0);
        setprop(htree~"phase",0);
        me.pattern_calc(x);
        enable_update = 1;
        me.update(x);
#        me.plot_hold(x);
      }
    },0,0);

  }, # end of listen

  update : func (x) {
	  phase = getprop(htree ~"phase");
    heading = getprop("orientation/heading-deg");
#	  heading = getprop("/orientation/heading-magnetic-deg");
		geoCoord = geo.aircraft_position();

  # ###### HOLD POINTS LAYOUT ######
  #             phase 4            #
  #         3----------> 0 FIX     #
  # phase 3 |            | phase 1 #
  #         2 <----------1         #
  #             phase 2            #
  ##################################

    if (phase == 0) { ## Fly to Fix
      if(me.flyto(y0,x0) == 0) {
        coord.set_latlon(y0,x0);
        if (geoCoord.distance_to(coord) < 8000) setprop(enable_exit,1);
      }
      else if(me.flyto(y0,x0) == 1) {
        setprop("autopilot/settings/tg-alt-ft",math.round(getprop("instrumentation/altimeter/indicated-altitude-ft"),100));
        if (h_entry == "DIRECT") phase = 1;
        else if (h_entry == "TEARDROP") phase = 2;
        else phase = 3; # parallel
      }
      if (getprop(exit)) me.exit_hold(x);
    }
    else if (phase == 1) { ## Fly to point 1
      if (me.flyto(y1,x1) == 1) phase = 2;
    } 
    else if (phase == 2) { ## Fly to point 2
      if (getprop(exit)) phase = 4;
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
      courseCoord = coord.set_latlon(tg_lat, tg_lon);
      CourseError = geoCoord.course_to(courseCoord) - heading;
      CourseError = geo.normdeg180(CourseError);
	    setprop("autopilot/internal/course-offset",CourseError);
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
	  h_dist = getprop(h_path[x] ~"leg-distance-nm");
	  left0 = geo.normdeg(h_inbound - 90);
	  left1 = geo.normdeg(h_inbound - 180);
	  right0 = geo.normdeg(h_inbound + 90);
	  right1 = geo.normdeg(h_inbound + 180);
	  gs = getprop("instrumentation/cdu["~x~"]/hold/speed");
      ### R = V*V/tg(°incl in rad)*9.81
	  turn_diam = 2*math.pow(gs*0.5144,2)/(math.tan(40*D2R)*9.81); # in meters
    setprop(htree~"turn-diam",turn_diam/1852); # in nm
    setprop(htree~"speed",gs);
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
    coord.apply_course_distance((h_turn == "L" ? right0 : left0),turn_diam);
    x3 = coord.lon();
    y3 = coord.lat();

		setprop(htree~"point[0]/x", x0);
		setprop(htree~"point[0]/y", y0);
		setprop(htree~"point[1]/x", x1);
		setprop(htree~"point[1]/y", y1);
		setprop(htree~"point[2]/x", x2);
		setprop(htree~"point[2]/y", y2);
		setprop(htree~"point[3]/x", x3);
		setprop(htree~"point[3]/y", y3);
  }, # end of pattern_calc

  exit_hold : func(x) {
    setprop("autopilot/settings/fms",1);
    setprop(enable_exit,0);
    setprop(htree~"phase",0);
    setprop(hold_activ[x],0);
    setprop(direct[x],0);
    enable_update = 0;
    setprop(exit,0);
#    for (var n=1;n<5;n+=1) 
#      setprop("autopilot/route-manager/input","@DELETE"~(wpt+1));
  }, # end of exit_hold

  plot_hold : func(x) { # not used
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


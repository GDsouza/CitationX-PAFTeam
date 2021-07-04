########################################
#  PROCEDURE TURN
#  C. Le Moigne (clm76) - 2020
########################################

var coord = nil;
var courseCoord = nil;
var courseError = nil;
var fp = nil;
var geocoord = nil;
var gs = nil;
var heading = nil;
var left0 = nil;
var p_turn = nil;
var p_inbound = nil;
var p_outbound = nil;
var phase = 0;
var pos_lat = nil;
var pos_lon = nil;
var right0 = nil;
var sel_crs = nil;
var turn_diam = nil;
var wp1 = nil;
var wp2 = nil;

var p_activ = "instrumentation/cdu/pcdr/active";
var fms = "autopilot/settings/nav-source";
var wp = "autopilot/route-manager/route/wp[";
var p_path = "instrumentation/cdu/pcdr/";
var bank = "autopilot/settings/bank-limit";

var Pcdr = {
	new: func () {
		var m = {parents:[Pcdr]};
    return m;
  }, # end of new
  
  listen : func {
		setlistener(p_activ, func(n) {
      if (n.getValue()) {
        phase = 0;
        me.pcdr_calc();
        me.plot_pcdr();
      }
      setprop("autopilot/locks/pcdr-turn-active",n.getValue());
    },0,0);
  }, # end of listen

  # ###### PCDR POINTS LAYOUT #######
  #                                 #
  #                      2          #
  #                    /    )       #
  #      FIX 0 ----> 1 <---3        #
  #                                 #
  ###################################

  pcdr_calc : func {
	  p_turn = getprop(p_path ~"turn");
	  p_inbound = getprop(p_path ~"inbound");
    p_outbound = geo.normdeg(p_inbound + 180);
	  wpt = getprop(p_path ~"wpt");
	  left0 = geo.normdeg(p_outbound - 45);
	  right0 = geo.normdeg(p_outbound + 45);
    x0 = getprop(wp~wpt~"]/longitude-deg");
    y0 = getprop(wp~wpt~"]/latitude-deg");

    coord = geo.Coord.new();
    coord.set_latlon(y0,x0);
    coord.apply_course_distance(p_outbound,getprop(p_path~"dist")*1852);
    x1 = coord.lon();
    y1 = coord.lat();

    coord.set_latlon(y1,x1);
    coord.apply_course_distance(p_turn == "L" ? left0 : right0,5*1852);
    x2 = coord.lon();
    y2 = coord.lat();

    var dest_apt = getprop("autopilot/route-manager/destination/airport");
    var dest_rwy = getprop("autopilot/route-manager/destination/runway");
    var dest_heading = airportinfo(dest_apt).runways[dest_rwy].heading;
    var dest_lon = airportinfo(dest_apt).lon;
    var dest_lat = airportinfo(dest_apt).lat;
    coord.set_latlon(dest_lat,dest_lon);
    coord.apply_course_distance(dest_heading,-7.5*1852);
    x3 = coord.lon();
    y3 = coord.lat();

  }, # end of procedure_calc

  plot_pcdr : func {
    fp = flightplan();
    fp.getWP(wpt);
    fp.getWP(wpt);
    wp1 = createWP(y1,x1,"*int01");
    fp.insertWP(wp1,wpt+1).setAltitude(2500,'at');
    wp2 = createWP(y2,x2,"*int02");
    fp.insertWP(wp2,wpt+2).setAltitude(2500,'at');
    wp3 = createWP(y3,x3,"*int03");
    fp.insertWP(wp3,wpt+3).setAltitude(2500,'at');
  }, # end of plot_hold
}; # end of Pcdr

var setl_pcdr = setlistener("/sim/signals/fdm-initialized", func {
  var turn = Pcdr.new();
  turn.listen();
	removelistener(setl_pcdr);
},0,0);


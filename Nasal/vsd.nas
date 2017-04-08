#### Citation X - Vertical Situation Display ####
#### Narendran M (c) 2014 - Adapted by C. Le Moigne (clm76) - 2017 ####

props.globals.initNode("instrumentation/efis/inputs/vsd",0,"BOOL");

var alt = 0;
var	alt_ind = "/instrumentation/altimeter/indicated-altitude-ft";
var asel = "/autopilot/settings/asel";
var	curWpt = "/autopilot/route-manager/current-wp";
var dep_alt = "/autopilot/route-manager/departure/field-elevation-ft";
var dest_alt = "/autopilot/route-manager/destination/field-elevation-ft";
var dist_rem = "autopilot/route-manager/distance-remaining-nm";
var fp_active = "/autopilot/route-manager/active";
var	heading_ind =	"/instrumentation/heading-indicator/indicated-heading-deg";
var num_wpts = "/autopilot/route-manager/route/num";
var set_range = "/instrumentation/efis//inputs/range-nm";
var svg_path = "/Aircraft/CitationX/Models/Instruments/MFD/canvas/Images/vsd.svg"; 
var tg_alt = "autopilot/settings/tg-alt-ft";
var tod = "/autopilot/locks/TOD";
var tod_dist = "/autopilot/locks/TOD-dist";
var toggle_vsd = "/instrumentation/efis//inputs/vsd";
var tot_dist = "autopilot/route-manager/total-distance";
var	vert_spd = "/velocities/vertical-speed-fps";

		#### VSD CLASS ###
var vsd = {
	terrain_color: 	[0.44, 0.19, 0.09, 0.5], 	# A brownish color
	path_color: 	[1,0,1,1],		# Magenta
	cstr_color: 	[0,1,0,1],		# Green
	tod_color :		[1,1,0,1],		# Yellow
	elev_pts: 21,								# Number of elevation data points
	elev_profile: [],
	range: 20,
	lastalt:0,
	lastaltset:0,
	alt_ceil: 10000,
	altitude: 0,
	peak: 0,
	alt_ceil_px: 180,		# Pixel length of vertical axis
	max_range_px: 810,	# Pixel length of horizontal axis
	terr_offset: 22,		# Offset between start of terrain polygon y and bottom_left corner
	bottom_left: {x:190, y:294},	# {x:x,y:y_max - y} of bottom-left corner of plot area - looks like canvas starts it's y axis from the top going down - old 233,294

	new: func() {
		var m = {parents:[vsd]};
		m.display = canvas.new({
			"name": "vsdScreen",
			"size": [1024, 320],
			"view": [1024, 320],
			"mipmapping": 1
		});
	
		m.display.addPlacement({"node": "Vsd.screen"});
	
		### Create canvas group
		m.group = m.display.createGroup();				# Group for canvas elements and paths
		m.text = m.display.createGroup();					# Group for waypoints text
		m.terrain = m.group.createChild("path");	# Terrain Polygon
		m.path = m.group.createChild("path");			# Flightplan Path
	
		### Load Vertical Situation Display
		canvas.parsesvg(m.group, svg_path);	
		setsize(m.elev_profile,m.elev_pts);

		### Create empty geo.Coord object for waypoints calculation
		m.wpt_this = geo.Coord.new();
		m.wpt_next = geo.Coord.new();
		m.wpt_tod = geo.Coord.new();

		### Display init ###
		m.h_range = getprop(set_range);
		m.group.getElementById("text_range1").setText(sprintf("%3.0f",m.h_range*0.25));
		m.group.getElementById("text_range2").setText(sprintf("%3.0f",m.h_range*0.5));
		m.group.getElementById("text_range3").setText(sprintf("%3.0f",m.h_range*0.75));
		m.group.getElementById("text_range4").setText(sprintf("%3.0f",m.h_range));
		m.group.getElementById("tgt_altitude").setText(sprintf("%5.0f",getprop(tg_alt)));

		m.fpc = flightplan().clone(); # Create a clone of actual Flightplan
		m.tod_ind =0;
		m.alt_set = getprop(tg_alt);

		return m;
	}, # end of new

			### Listeners ###
	listen : func {		
		setlistener(fp_active, func(n) {
			if (n.getValue()) {
				me.fpc = flightplan().clone();
				me.update();
			}
		});

		setlistener(set_range, func(n) {
			me.range = n.getValue();
			if(me.range > 10) {
				me.group.getElementById("text_range1").setText(sprintf("%3.0f",me.range*0.25));
				me.group.getElementById("text_range2").setText(sprintf("%3.0f",me.range*0.5));
				me.group.getElementById("text_range3").setText(sprintf("%3.0f",me.range*0.75));
				me.group.getElementById("text_range4").setText(sprintf("%3.0f",me.range));
			} else {
				me.group.getElementById("text_range1").setText(sprintf("%1.1f",me.range*0.25));
				me.group.getElementById("text_range2").setText(sprintf("%1.0f",me.range*0.5));
				me.group.getElementById("text_range3").setText(sprintf("%1.1f",me.range*0.75));
				me.group.getElementById("text_range4").setText(sprintf("%1.0f",me.range));
			}
		});

		setlistener(tg_alt, func(n) {
			me.alt_set = n.getValue();
			me.group.getElementById("tgt_altitude").setText(sprintf("%5.0f",me.alt_set));
			me.newSetPos = -me.alt_ceil_px*(me.alt_set/me.alt_ceil);
			me.group.getElementById("altitude_set").setTranslation(0,me.newSetPos-me.lastaltset);
			me.lastaltset = me.newSetPos;
		});

		setlistener(tod_dist, func(n) {
			me.tod_lat = getprop("autopilot/route-manager/vnav/td/latitude-deg");
			me.tod_lon = getprop("autopilot/route-manager/vnav/td/longitude-deg");
			me.wpt_tod.set_latlon(me.tod_lat,me.tod_lon);
			me.rteLenTod = geo.aircraft_position().distance_to(me.wpt_tod)*M2NM;
			var wp = createWP(me.tod_lat,me.tod_lon,"TOD","pseudo");
			me.fpc.insertWP(wp,me.currWpt+1);
			var td_timer = maketimer(2,func() { # delay to get tod_dist after tg_alt
				me.fpc.getWP(me.currWpt).setAltitude(getprop(tg_alt),'at');
			});
			td_timer.singleShot = 1;
			td_timer.start();	
			me.rteLen = me.rteLenTod;

		});			

		setlistener(tod, func(n) {
#			if (n.getValue() and getprop(dist_rem) >50) {me.tod_ind +=1}
			if (n.getValue()) {me.tod_ind +=1}
		});

	}, # end of listen

	update: func {

		# Generate elevation profile		
		me.altitude = getprop(alt_ind);
		if(me.altitude == nil) {
			me.altitude = 0;
		}
		me.alt_ceil = (getprop(asel)*100 == 0 ? 1 :getprop(asel)*100); 

		me.new_markerPos = -me.alt_ceil_px*(me.altitude/me.alt_ceil);
		var rangeHdg = [];

		# Vertical Flight Path
			var numWpts = me.fpc.getPlanSize();
			me.currWpt = getprop(curWpt)+ me.tod_ind;
		if(getprop(toggle_vsd) == 1) {
			if (numWpts > 1 and me.currWpt >= 0) {
				me.path.del();
				me.text.removeAllChildren();
				me.path = me.group.createChild("path");
				me.path.setColor(me.path_color)
						 .moveTo(me.bottom_left.x,me.bottom_left.y-4+me.new_markerPos)
						 .setStrokeLineWidth(2)
						 .show();

				me.wpt_this.set_latlon(me.fpc.getWP(me.currWpt).lat, me.fpc.getWP(me.currWpt).lon);
				me.rteLen = geo.aircraft_position().distance_to(me.wpt_this)*M2NM;
				var brk_next = 0;

				# Calculate distance between waypoints
				for(var i=me.currWpt; i<numWpts; i=i+1) {
					if (i == 0) {alt = getprop(dep_alt)}
					else if (i == numWpts-1) {alt = getprop(dest_alt)}
					else {
						#### BASIC ###
						if(me.fpc.getWP(i).wp_type == "basic" and me.fpc.getWP(i).wp_role == nil) {
							### SIDS ###
							if (me.fpc.getWP(i).distance_along_route < getprop(tot_dist)/2) {
								if (me.fpc.getWP(i).alt_cstr <= 0) {
									alt = getprop(asel)*100;
								} else {
									alt = me.fpc.getWP(i).alt_cstr;
								}
							} else {
							### STARS ###
								if (me.fpc.getWP(i).alt_cstr <= 0) {
									alt = me.fpc.getWP(i+1).alt_cstr;
								} else {
									alt = me.fpc.getWP(i).alt_cstr;
								}
							}
						} else {
						### NAVAIDS ###
							if (i == me.currWpt and me.fpc.getWP(me.currWpt).alt_cstr <= 0) {
								alt = me.alt_set;
							} else {
								if (me.fpc.getWP(i).alt_cstr <= 0) {
									alt = getprop(asel)*100;
								} else {
									alt = me.fpc.getWP(i).alt_cstr;
								}
							}
						}
					}
					if(me.rteLen > me.range) {brk_next = 1}
					me.path.lineTo(me.bottom_left.x + me.max_range_px*(me.rteLen/me.range), me.bottom_left.y - me.alt_ceil_px*(alt/me.alt_ceil));

					# Add waypoint ident
					if (me.fpc.getWP(i).wp_name == "TOD") {
						var color = me.tod_color;
						var text = "TOD";
					} else {
						var color = me.path_color;
						var text = me.fpc.getWP(i).id;
					}

					me.text.createChild("text")
							 .setAlignment("left-bottom")
							 .setColor(color)
							 .setFontSize(24,1.0)
							 .setTranslation(me.bottom_left.x + 10 + me.max_range_px*(me.rteLen/me.range), me.bottom_left.y - 10 - me.alt_ceil_px*(alt/me.alt_ceil))
							 .setText(text);

					me.text.createChild("text")
							 .setAlignment("center-center")
							 .setColor(color)
							 .setFontSize(28,1.2)
							 .setTranslation(me.bottom_left.x + me.max_range_px*(me.rteLen/me.range), me.bottom_left.y - me.alt_ceil_px*(alt/me.alt_ceil))
							 .setText("*");

					if(i<numWpts-1) {
						me.wpt_this.set_latlon(me.fpc.getWP(i).lat, me.fpc.getWP(i).lon);
						me.wpt_next.set_latlon(me.fpc.getWP(i+1).lat, me.fpc.getWP(i+1).lon);
						append(rangeHdg, {range: me.rteLen, course: me.wpt_this.course_to(me.wpt_next)});
						me.rteLen = me.rteLen + me.wpt_this.distance_to(me.wpt_next)*M2NM;
					}
					if(brk_next == 1) {break}
				}
			} else {
				me.path.hide();
				me.text.removeAllChildren();
			}
		} else {
			me.path.hide();
			me.text.removeAllChildren();
		}
	
		var pos = geo.aircraft_position();
	
		# Get terrain profile along the flightplan route if WPT is enabled. If WPT is not enabled, the rangeHdg vector should be empty, so it's just going to get the elevation profile along the indicated aircraft heading
		
		me.peak = 0;
		forindex(var j; me.elev_profile) {
			var check_hdg = getprop(heading_ind);
			foreach(var wpt; rangeHdg) {
				if(j*(me.range/me.elev_pts) > wpt.range) {
					check_hdg = wpt.course;
				} else {
					break;
				}
			}
			pos.apply_course_distance(check_hdg,(me.range/me.elev_pts)*NM2M);
			var elev = me.get_elevation(pos.lat(), pos.lon());
			me.elev_profile[j] = elev;
			if(elev > me.peak) {
				me.peak = elev;
			}
		}
		# Set Altitude Numbers
		me.terrain.del();
		me.terrain = me.group.createChild("path");
		me.terrain
				.setColorFill(me.terrain_color)
				.moveTo(me.bottom_left.x,me.bottom_left.y + me.terr_offset);
	
		# Draw Terrain
		forindex(var k; me.elev_profile) {
			me.terrain.lineTo(me.bottom_left.x+(k*(me.max_range_px/(me.elev_pts-1))), me.bottom_left.y -6- me.alt_ceil_px*(me.elev_profile[k]/me.alt_ceil));
		}
	
		me.terrain.lineTo(me.bottom_left.x+me.max_range_px,me.bottom_left.y+ me.terr_offset);
	
		me.group.getElementById("text_alt1").setText(sprintf("%5.0f",me.alt_ceil/2));
		me.group.getElementById("text_alt2").setText(sprintf("%5.0f",me.alt_ceil));
		me.group.getElementById("aircraft_marker").setTranslation(0,me.new_markerPos-me.lastalt); 

		### Speed Arrow ###
		var vs_fps = getprop(vert_spd);
		if(vs_fps == nil) {
			vs_fps = 0;
		}
		var gs_fps = getprop("/velocities/groundspeed-kt")*1.46667; # KTS to FPS
		if(gs_fps > 60) {
			var fpa = math.atan2(vs_fps, gs_fps);
			me.group.getElementById("speed_arrow")
						.setTranslation(0,me.new_markerPos-me.lastalt)
						.setRotation(-fpa)
						.show();			
		} else {
			me.group.getElementById("speed_arrow").hide();
		}
		me.lastalt = me.new_markerPos;

		settimer(func me.update(),1);

	}, # end of update

	get_elevation : func (lat, lon) {
		var info = geodinfo(lat, lon);
		if (info != nil) {var elevation = info[0] * M2FT;}
		else {var elevation = -1.0; }
		return elevation;
	}, # end of get_elevation

}; # end of VSD

### START ###
var vsd_stl = setlistener("sim/signals/fdm-initialized", func { 
	print("VSD ... Ok");
	var init = vsd.new();
	init.listen();
	removelistener(vsd_stl);
});



# [Airbus] Vertical Situation Display
# Narendran M (c) 2014

# Scroll to the end of the file for object instantiations

# If you just want a quick and dirty edit/port to your aircraft, just edit the model object names, svg path, switches and props
var objName_capt = 'vsd.l';		# Model object name for captain's side VSD
var objName_fo = 'vsd.r';		# Model object name for first officer's side VSD
var svg_path = '/Aircraft/A380/Models/Instruments/ND/vsd.svg'; # VSG File Path

# It is very important to note that the below switches and props defines will ONLY work on the A380 by theOmegaHangar (http://theomegahangar.flymerlion.org) and other derived aircraft. If you would like to add this to your aircraft, please change the switches and interface properties to connect it to your aircraft!

# Define custom aircraft cockpit switches to be interfaced
var mySwitches = {
	'set_range': 			{	path: '/inputs/range-nm'	, value: 10	},
	'toggle_waypoints':		{	path: '/inputs/wpt'			, value: 0	},
	'toggle_constraints':	{	path: '/inputs/cstr'		, value: 0	}
};

# Define interface props and functions to use the flightplan management system and aircraft instrumentation

# A380 Flightplan management system properties
var myProps_A380 = {
	curWptId:	'/flight-management/flightplan/currentWpt',
	wpt_data: 	{
		# Change the return properties to suit your custom route manager system
		ident: func(n) {
			return '/flight-management/flightplan/wpt['~n~']/ident';
		},
		latitude: func(n) {
			return '/flight-management/flightplan/wpt['~n~']/latitude';
		},
		longitude: func(n) {
			return '/flight-management/flightplan/wpt['~n~']/longitude';
		},
		alt_cstr: func(n) {
			return '/flight-management/flightplan/wpt['~n~']/altitude';
		}
	},
	num_wpts:			'/flight-management/flightplan/num-wpts',
	altitude_ind:		'/instrumentation/altimeter/indicated-altitude-ft',
	heading_ind:		'/instrumentation/heading-indicator/indicated-heading-deg',
	ap_altitude_set:	'/flight-management/fcu-values/alt',
	vertSpd_ind:		'/instrumentation/vertical-speed-indicator/indicated-speed-kts'
};

# FGRouteManager and generic autopilot system properties
var myProps = {
	curWptId:	'/autopilot/route-manager/current-wp',
	wpt_data: 	{
		# Change the return properties to suit your custom route manager system
		ident: func(n) {
			return '/autopilot/route-manager/route/wp['~n~']/id';
		},
		latitude: func(n) {
			return '/autopilot/route-manager/route/wp['~n~']/latitude-deg';
		},
		longitude: func(n) {
			return '/autopilot/route-manager/route/wp['~n~']/longitude-deg';
		},
		alt_cstr: func(n) {
			return '/autopilot/route-manager/route/wp['~n~']/altitude-ft';
		}
	},
	num_wpts:			'/autopilot/route-manager/route/num',
	altitude_ind:		'/instrumentation/altimeter/indicated-altitude-ft',
	heading_ind:		'/instrumentation/heading-indicator/indicated-heading-deg',
	ap_altitude_set:	'/autopilot/settings/target-altitude-ft',
	vertSpd_ind:		'/velocities/vertical-speed-fps'
};

############################## GET ELEVATION DATA ##############################

var get_elevation = func (lat, lon) {
	var info = geodinfo(lat, lon);
	if (info != nil) {var elevation = info[0] * M2FT;}
	else {var elevation = -1.0; }
	return elevation;
};

################################### VSD CLASS ##################################

var vsd = {
	terrain_color: 	[0.44, 0.19, 0.09, 0.5], 	# A brownish color
	path_color: 	[0, 1, 0, 1],				# Bright Green
	cstr_color: 	[1, 0, 1, 1],				# Bright Green
	elev_pts: 21,								# Number of elevation data points
	# Just some variables required by the update() function
	elev_profile: [],
	range: 10,
	lastalt:0,
	lastaltset:0,
	alt_ceil: 10000,
	altitude: 0,
	peak: 0,
	# Contants dependent on SVG file
	alt_ceil_px: 181,							# Pixel length of vertical axis
	max_range_px: 710,							# Pixel length of horizontal axis
	terr_offset: 22,							# Offset between start of terrain polygon y and bottom_left corner
	bottom_left: {x:233, y:294},				# {x:x,y:y_max - y} of bottom-left corner of plot area - looks like canvas starts it's y axis from the top going down
	# sym_names: ["aircraft_marker", "speed_arrow", "text_range1", "text_range2", "text_range3", "text_range4", "text_alt1", "text_alt2", "altitude_set"],
	new: func(efis_id, obj_name, switches, interface_props, svg_path) {
		var t = {parents:[vsd]};
		
		# Initialize VSD Display
		t.display = canvas.new({
			"name": "vsdScreen",
			"size": [1024, 320],
			"view": [1024, 320],
			"mipmapping": 1
		});
		
		t.efis_id = efis_id;
		t.switches = switches;
		t.interface_props = interface_props;
		
		# Add placement onto 3D model
		t.display.addPlacement({"node": obj_name});
		
		# Create canvas group
		t.group = t.display.createGroup();			# Group for canvas elements and paths
		t.text = t.display.createGroup();			# Group for waypoints text
		t.terrain = t.group.createChild("path");	# Terrain Polygon
		t.path = t.group.createChild("path");		# Flightplan Path
		t.cstr = t.group.createChild("path");		# Altitude constraints (?)
		
		# Load Vertical Situation Display
		canvas.parsesvg(t.group, svg_path);
		
		setsize(t.elev_profile,t.elev_pts);
		
		# Set cockpit switch listeners
		# Range Numbers
		setlistener("/instrumentation/efis["~t.efis_id~"]"~t.switches['set_range'].path, func(n) {
			var range = n.getValue();
			if(range > 10) {
				t.group.getElementById("text_range1").setText(sprintf("%3.0f",range*0.25));
				t.group.getElementById("text_range2").setText(sprintf("%3.0f",range*0.5));
				t.group.getElementById("text_range3").setText(sprintf("%3.0f",range*0.75));
				t.group.getElementById("text_range4").setText(sprintf("%3.0f",range));
			} else {
				t.group.getElementById("text_range1").setText(sprintf("%1.1f",range*0.25));
				t.group.getElementById("text_range2").setText(sprintf("%1.0f",range*0.5));
				t.group.getElementById("text_range3").setText(sprintf("%1.1f",range*0.75));
				t.group.getElementById("text_range4").setText(sprintf("%1.0f",range));
			}
			t.range = range;
		});
		
		# Autopilot Altitude Setting
		setlistener(t.interface_props.ap_altitude_set, func(n) {
			t.alt_set = n.getValue();
			if((t.alt_set == nil) or (t.alt_set > 2.5*t.alt_ceil)) {
				t.group.getElementById("altitude_set").hide();
			} else {
				t.group.getElementById("altitude_set").show();
			}
			# Move Altitude Setting Line
			t.newSetPos = -t.alt_ceil_px*(t.alt_set/t.alt_ceil);
			t.group.getElementById("altitude_set").setTranslation(0,t.newSetPos-t.lastaltset);
			t.lastaltset = t.newSetPos;
			t.group.getElementById("tgt_altitude").setText(sprintf("%5.0f",t.alt_set));
		});
		
		# Create 2 empty geo.Coord object for waypoint calculations
		t.wpt_this = geo.Coord.new();
		t.wpt_next = geo.Coord.new();

		return t;
	},
	init: func {
		me.UPDATE_INTERVAL = 1;
		me.loopid = 0;
		me.reset();
	},
	update: func {
		# Generate elevation profile
		
		me.altitude = getprop(me.interface_props.altitude_ind);
		if(me.altitude == nil) {
			me.altitude = 0;
		}
		foreach(var alt; [5000, 10000, 20000, 30000, 40000]) {
			if((me.altitude <= alt) and (me.peak <= alt)) {
				me.alt_ceil = alt;
				break;
			}
		}
		
		me.new_markerPos = -me.alt_ceil_px*(me.altitude/me.alt_ceil);
		
		var rangeHdg = [];		# To change the scan course to get vertical profile along the flight path
		var cstrAlts = [];		# Get Constraint altitudes for plotting
		
		# Vertical Flight Path
		if(getprop("/instrumentation/efis["~me.efis_id~"]"~me.switches.toggle_waypoints.path) == 1) {
			var numWpts = getprop(me.interface_props.num_wpts);
			var currWpt = getprop(me.interface_props.curWptId);
			if((numWpts > 1) and (currWpt >= 0)) {
				me.path.del();
				me.text.removeAllChildren();
				me.path = me.group.createChild("path");
				me.path.setColor(me.path_color)
					   .moveTo(me.bottom_left.x,me.bottom_left.y+me.new_markerPos)
					   .setStrokeLineWidth(2)
					   .show();
				me.wpt_this.set_latlon(getprop(me.interface_props.wpt_data.latitude(currWpt)), getprop(me.interface_props.wpt_data.longitude(currWpt)));
				var rteLen = geo.aircraft_position().distance_to(me.wpt_this)*M2NM;
				var brk_next = 0;
				# Calculate distance between waypoints
				for(var id=currWpt; id<numWpts; id=id+1) {
					var alt = getprop(me.interface_props.wpt_data.alt_cstr(id));
					if(alt != nil) {
						if(rteLen > me.range) {
							brk_next = 1;
						}
						if(alt > 0) {
							# Plot it if it's in range!
							me.path.lineTo(me.bottom_left.x + me.max_range_px*(rteLen/me.range), me.bottom_left.y -me.alt_ceil_px*(alt/me.alt_ceil));
							if(getprop("/instrumentation/efis["~me.efis_id~"]"~me.switches.toggle_constraints.path) == 1) {
								append(cstrAlts, {range: me.bottom_left.x + me.max_range_px*(rteLen/me.range),	cstr: me.bottom_left.y -me.alt_ceil_px*(alt/me.alt_ceil)});
							}
							# Add circle and waypoint ident
							# FIXME - Figure out the best way of dynamically drawing circles at waypoint OR just load the wpt symbol from an SVG file
							me.text.createChild("text")
								   .setAlignment("left-bottom")
								   .setColor(me.path_color)
								   .setFontSize(28,1.2)
								   .setTranslation(me.bottom_left.x + 12 + me.max_range_px*(rteLen/me.range), me.bottom_left.y - 12 - me.alt_ceil_px*(alt/me.alt_ceil))
								   .setText(getprop(me.interface_props.wpt_data.ident(id)));
							if(id<(numWpts-1)) {
								me.wpt_this.set_latlon(getprop(me.interface_props.wpt_data.latitude(id)), getprop(me.interface_props.wpt_data.longitude(id)));
								me.wpt_next.set_latlon(getprop(me.interface_props.wpt_data.latitude(id+1)), getprop(me.interface_props.wpt_data.longitude(id+1)));
								append(rangeHdg, {range: rteLen, course: me.wpt_this.course_to(me.wpt_next)});
								rteLen = rteLen + me.wpt_this.distance_to(me.wpt_next)*M2NM;
							}
			# FIXME - This is a little messy, need to clean it up
						} else {
							break;
						}
					} else {
						break;
					}
					if(brk_next == 1) {
						break;
					}
				}
			} else {
				me.path.hide();
			}
		} else {
			me.path.hide();
			me.text.removeAllChildren();
		}
		
		# Draw Altitude Constraints
		if(getprop("/instrumentation/efis["~me.efis_id~"]"~me.switches.toggle_constraints.path) == 1) {
			me.cstr.del();
			me.cstr = me.group.createChild("path");
			me.cstr.setColor(me.cstr_color)
				   .moveTo(me.bottom_left.x,me.bottom_left.y+me.new_markerPos)
				   .setStrokeLineWidth(2)
				   .setStrokeDashArray([10, 10, 10, 10, 10])
				   .show();
			forindex(var i; cstrAlts) {
				me.cstr.vertTo(cstrAlts[i].cstr).horizTo(cstrAlts[i].range);
			}
		} else {
			me.cstr.hide();
		}
		
			
		var pos = geo.aircraft_position();
		
		# Get terrain profile along the flightplan route if WPT is enabled. If WPT is not enabled, the rangeHdg vector should be empty, so it's just going to get the elevation profile along the indicated aircraft heading
			
		me.peak = 0;
		forindex(var i; me.elev_profile) {
			var check_hdg = getprop(me.interface_props.heading_ind);
			foreach(var wpt; rangeHdg) {
				if(i*(me.range/me.elev_pts) > wpt.range) {
					check_hdg = wpt.course;
				} else {
					break;
				}
			}
			pos.apply_course_distance(check_hdg,(me.range/me.elev_pts)*NM2M);
			var elev = get_elevation(pos.lat(), pos.lon());
			me.elev_profile[i] = elev;
			if(elev > me.peak) {
				me.peak = elev; # Update Peak Point
			}
		}
		# Set Altitude Numbers
		me.terrain.del();
		me.terrain = me.group.createChild("path");
		me.terrain.setColorFill(me.terrain_color).moveTo(me.bottom_left.x,me.bottom_left.y + me.terr_offset);
		
		# Draw Terrain
		forindex(var i; me.elev_profile) {
			me.terrain.lineTo(me.bottom_left.x+(i*(me.max_range_px/(me.elev_pts-1))), me.bottom_left.y - me.alt_ceil_px*(me.elev_profile[i]/me.alt_ceil));
		}
		
		me.terrain.lineTo(me.bottom_left.x+me.max_range_px,me.bottom_left.y+me.terr_offset);
		
		me.group.getElementById("text_alt1").setText(sprintf("%5.0f",me.alt_ceil/2));
		me.group.getElementById("text_alt2").setText(sprintf("%5.0f",me.alt_ceil));
		
		me.group.getElementById("aircraft_marker").setTranslation(0,me.new_markerPos-me.lastalt); 
		
		var vs_fps = getprop(me.interface_props.vertSpd_ind);
		if(vs_fps == nil) {
			vs_fps = 0;
		}
		var gs_fps = getprop("/velocities/groundspeed-kt")*1.46667; # KTS to FPS
		if(gs_fps > 60) {
			var fpa = math.atan2(vs_fps, gs_fps);
			# FIXME - something wrong with the center of the speed arrow
			me.group.getElementById("speed_arrow").setTranslation(0,me.new_markerPos-me.lastalt)
												  .setCenter(me.bottom_left.x + 12,740 + (2*me.new_markerPos))
												  .setRotation(-fpa)
												  .show();			
		} else {
			me.group.getElementById("speed_arrow").hide();
		}
		
		me.lastalt = me.new_markerPos;
		
	},
	reset: func {
		me.loopid += 1;
		me._loop_(me.loopid);
	},
	_loop_: func(id) {
		id = me.loopid or return;
		me.update();
		settimer(func {me._loop_(id); }, me.UPDATE_INTERVAL);
	},
	showDlg: func {
		if(getprop("sim/instrument-options/canvas-popup-enable")) {
		    var dlg = canvas.Window.new([400, 128], "dialog");
		    dlg.setCanvas(me.display);
		}
	}
};

############################### INSTANTIATE VSDs ###############################

var capt_vsd = vsd.new(0, objName_capt, mySwitches, myProps, svg_path);
var fo_vsd = vsd.new(1, objName_fo, mySwitches, myProps, svg_path);

setlistener("sim/signals/fdm-initialized", func {
	capt_vsd.init();
	fo_vsd.init();
	print("Vertical Situation Displays Initialized");
});

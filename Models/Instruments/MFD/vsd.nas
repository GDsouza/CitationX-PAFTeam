#### Citation X - Vertical Situation Display ####
#### Narendran M (c) 2014 - Adapted by C. Le Moigne (clm76) - 2017 ####

props.globals.initNode("instrumentation/efis/inputs/vsd",0,"BOOL");
var svg_path = "/Aircraft/CitationX/Models/Instruments/MFD/canvas/Images/vsd.svg"; 
var num_wpts = "/autopilot/route-manager/route/num";
var	alt_ind = "/instrumentation/altimeter/indicated-altitude-ft";
var	heading_ind =	"/instrumentation/heading-indicator/indicated-heading-deg";
var	tg_alt = "/autopilot/settings/target-altitude-ft";
var	vert_spd = "/velocities/vertical-speed-fps";
var	curWpt = "/autopilot/route-manager/current-wp";
var asel = "/autopilot/settings/asel";
var dep_alt = "/autopilot/route-manager/departure/field-elevation-ft";
var dest_alt = "/autopilot/route-manager/destination/field-elevation-ft";
var tod = "/autopilot/locks/TOD";
var set_range = "/instrumentation/efis//inputs/range-nm";
var toggle_vsd = "/instrumentation/efis//inputs/vsd";
var alt = 0;

		#### GET ELEVATION DATA ####

var get_elevation = func (lat, lon) {
	var info = geodinfo(lat, lon);
	if (info != nil) {var elevation = info[0] * M2FT;}
	else {var elevation = -1.0; }
	return elevation;
};

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
	alt_ceil_px: 180,		# Pixel length of vertical axis - old 181
	max_range_px: 810,	# Pixel length of horizontal axis - old 710
	terr_offset: 22,		# Offset between start of terrain polygon y and bottom_left corner - old 22
	bottom_left: {x:190, y:294},	# {x:x,y:y_max - y} of bottom-left corner of plot area - looks like canvas starts it's y axis from the top going down - old 233,294

	new: func() {
		var m = {parents:[vsd]};
		m.display = canvas.new({
			"name": "vsdScreen",
			"size": [1024, 320],
			"view": [1024, 320],
			"mipmapping": 1
		});
	
		m.efis_id = 0;
	
		### Add placement onto 3D model
		m.display.addPlacement({"node": "Vsd.screen"});
	
		### Create canvas group
		m.group = m.display.createGroup();			# Group for canvas elements and paths
		m.text = m.display.createGroup();			# Group for waypoints text
		m.terrain = m.group.createChild("path");	# Terrain Polygon
		m.path = m.group.createChild("path");		# Flightplan Path
		m.cstr = m.group.createChild("path");		# Altitude constraints (?)
	
		### Load Vertical Situation Display
		canvas.parsesvg(m.group, svg_path);	
		setsize(m.elev_profile,m.elev_pts);

		### Create 2 empty geo.Coord object for waypoint calculations
		m.wpt_this = geo.Coord.new();
		m.wpt_next = geo.Coord.new();

		### Display init ###
		m.h_range = getprop(set_range);
		m.group.getElementById("text_range1").setText(sprintf("%3.0f",m.h_range*0.25));
		m.group.getElementById("text_range2").setText(sprintf("%3.0f",m.h_range*0.5));
		m.group.getElementById("text_range3").setText(sprintf("%3.0f",m.h_range*0.75));
		m.group.getElementById("text_range4").setText(sprintf("%3.0f",m.h_range));
		m.group.getElementById("tgt_altitude").setText(sprintf("%5.0f",getprop(tg_alt)));

		return m;
	}, # end of new

			### Listeners ###
	listen : func {		
		setlistener(toggle_vsd, func(n) {
			var vsd = n.getValue();
			var fp_activ = getprop("autopilot/route-manager/active");
			if (vsd and fp_activ) {
				me.alt_ceil = getprop(asel)*100;
				me.fp = flightplan();
				var coord = geo.Coord.new();
				for (var i=0;i<me.fp.getPlanSize();i+=1) {
					var lat = me.fp.getWP(i).lat;
					var lon = me.fp.getWP(i).lon;
					var from = coord.new().set_latlon(lat,lon);
					var to = coord.new().set_latlon(me.fp.getWP(me.fp.getPlanSize()-1).lat, me.fp.getWP(me.fp.getPlanSize()-1).lon);
					var (course,dist) = courseAndDistance(from,to);
				}
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
			if((me.alt_set == nil) or (me.alt_set > 2.5*me.alt_ceil)) {
				me.group.getElementById("altitude_set").hide();
			} else {
				me.group.getElementById("altitude_set").show();
			}
			me.newSetPos = -me.alt_ceil_px*(me.alt_set/me.alt_ceil);
			me.group.getElementById("altitude_set").setTranslation(0,me.newSetPos-me.lastaltset);
			me.lastaltset = me.newSetPos;
			me.group.getElementById("tgt_altitude").setText(sprintf("%5.0f",me.alt_set));
		});

		setlistener(asel,func(n) {
			var asel = n.getValue();		
			me.fp = flightplan();
			for (var i=0;i<me.fp.getPlanSize();i+=1) {
				var lat = me.fp.getWP(i).lat;
				var lon = me.fp.getWP(i).lon;
				var from = geo.Coord.new().set_latlon(lat,lon);
				var to = geo.Coord.new().set_latlon(me.fp.getWP(me.fp.getPlanSize()-1).lat, me.fp.getWP(me.fp.getPlanSize()-1).lon);
				var (course,dist) = courseAndDistance(from,to);
			}
		});
	}, # end of listen

	update: func {
		# Generate elevation profile		
		me.altitude = getprop(alt_ind);
		if(me.altitude == nil) {
			me.altitude = 0;
		}
		me.alt_ceil = getprop(asel)*100;

		me.new_markerPos = -me.alt_ceil_px*(me.altitude/me.alt_ceil);
		var rangeHdg = []; # To change the scan course to get vertical profile along the flight path

		# Vertical Flight Path
		if(getprop(toggle_vsd) == 1) {
			var numWpts = me.fp.getPlanSize();
			var currWpt = getprop(curWpt);
#			me.tod_lat = getprop("autopilot/route-manager/vnav/td/latitude-deg");
#			me.tod_lon = getprop("autopilot/route-manager/vnav/td/longitude-deg");

			if (numWpts > 1 and currWpt >= 0) {
				me.path.del();
				me.text.removeAllChildren();
				me.path = me.group.createChild("path");
				me.path.setColor(me.path_color)
					   .moveTo(me.bottom_left.x,me.bottom_left.y-4+me.new_markerPos)
					   .setStrokeLineWidth(2)
					   .show();

				me.wpt_this.set_latlon(me.fp.getWP(currWpt).lat, me.fp.getWP(currWpt).lon);
				var rteLen = geo.aircraft_position().distance_to(me.wpt_this)*M2NM;
				var brk_next = 0;

				# Calculate distance between waypoints
				for(var i=currWpt; i<numWpts; i=i+1) {
					if (i == 0) {alt = getprop(dep_alt)}
					else if (i == numWpts-1) {alt = getprop(dest_alt)}
					else {
						if (i == currWpt and me.fp.getWP(currWpt).alt_cstr <= 0) {
							alt = getprop(tg_alt);
						} else {
							if (me.fp.getWP(i).alt_cstr <= 0) {
								alt = getprop(asel)*100;
							} else {alt = me.fp.getWP(i).alt_cstr}				
						}
					}
					if(rteLen > me.range) {brk_next = 1}
					me.path.lineTo(me.bottom_left.x + me.max_range_px*(rteLen/me.range), me.bottom_left.y - me.alt_ceil_px*(alt/me.alt_ceil));

					# Add waypoint ident
					me.text.createChild("text")
						   .setAlignment("left-bottom")
						   .setColor(me.path_color)
						   .setFontSize(24,1.0)
						   .setTranslation(me.bottom_left.x + 10 + me.max_range_px*(rteLen/me.range), me.bottom_left.y - 10 - me.alt_ceil_px*(alt/me.alt_ceil))
						   .setText(me.fp.getWP(i).id);

					me.text.createChild("text")
						   .setAlignment("center-center")
						   .setColor(me.path_color)
						   .setFontSize(28,1.2)
						   .setTranslation(me.bottom_left.x + me.max_range_px*(rteLen/me.range), me.bottom_left.y - me.alt_ceil_px*(alt/me.alt_ceil))
						   .setText("*");

					if(i<numWpts-1) {
						me.wpt_this.set_latlon(me.fp.getWP(i).lat, me.fp.getWP(i).lon);
						me.wpt_next.set_latlon(me.fp.getWP(i+1).lat, me.fp.getWP(i+1).lon);
						append(rangeHdg, {range: rteLen, course: me.wpt_this.course_to(me.wpt_next)});
						rteLen = rteLen + me.wpt_this.distance_to(me.wpt_next)*M2NM;
					}
					if(brk_next == 1) {break}
				}
			} else {me.path.hide()}
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
			var elev = get_elevation(pos.lat(), pos.lon());
			me.elev_profile[j] = elev;
			if(elev > me.peak) {
				me.peak = elev; # Update Peak Point
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
			var fp1 = math.atan2(vs_fps*2, gs_fps);
			var fp2 = math.atan2(vs_fps, gs_fps*2);
			me.group.getElementById("speed_arrow")
						.setTranslation(0,me.new_markerPos-me.lastalt)
					  .setRotation(-fpa)
					  .show();			
		} else {
			me.group.getElementById("speed_arrow").hide();
		}
		
		me.lastalt = me.new_markerPos;

		settimer(func me.update(),1);

	}, #end of update

	Draw_tod : func {
			me.text.createChild("text")
					 .setAlignment("left-bottom")
					 .setColor(me.tod_color)
					 .setFontSize(24,1.0)
					 .setTranslation(me.bottom_left.x + 10 + me.max_range_px*(me.rteLenTod/me.range), me.bottom_left.y - 10 - me.alt_ceil_px*(me.altTod/me.alt_ceil))
					 .setText("TOD");
			me.text.createChild("text")
					 .setAlignment("center-center")
					 .setColor(me.tod_color)
					 .setFontSize(28,1.2)
					 .setTranslation(me.bottom_left.x + me.max_range_px*(me.rteLenTod/me.range), me.bottom_left.y - me.alt_ceil_px*(me.altTod/me.alt_ceil))
					 .setText("*");
	}, # end of Draw_tod

}; # end of VSD

### START ###
var vsd_stl = setlistener("sim/signals/fdm-initialized", func { 
	var init = vsd.new();
	init.listen();
	print("VSD ... Ok");
	removelistener(vsd_stl);
});

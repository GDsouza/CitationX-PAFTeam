##
##### Citation X - Canvas NdDisplay #####
##### Christian Le Moigne (clm76) - oct 2016 ###

io.include('init.nas');

var placement_front = "ND.screen";
var placement_back = "Layers.screen";

var clk_hour = props.globals.getNode("sim/time/real/hour");
var clk_min = props.globals.getNode("sim/time/real/minute");
var clk_sec = props.globals.getNode("sim/time/real/second");
var chr_hour = props.globals.getNode("instrumentation/clock/chrono-hour");
var chr_min = props.globals.getNode("instrumentation/clock/chrono-min");
var chr_sec = props.globals.getNode("instrumentation/clock/chrono-sec");
var wx = props.globals.getNode("instrumentation/efis/inputs/range-nm");
var bank = props.globals.getNode("autopilot/settings/bank-limit");
var tcas = props.globals.getNode("instrumentation/primus2000/dc840/tcas");
var sat = props.globals.getNode("environment/temperature-degc");
var tas = props.globals.getNode("instrumentation/airspeed-indicator/true-speed-kt");
var gspd = props.globals.getNode("velocities/groundspeed-kt");
var etx = props.globals.getNode("instrumentation/primus2000/dc840/etx");
var nav_dist = props.globals.getNode("autopilot/internal/nav-distance");
var nav_id = props.globals.getNode("autopilot/internal/nav-id");
var nav_type = props.globals.getNode("autopilot/internal/nav-type");
var nav_type = props.globals.getNode("autopilot/internal/nav-type");
var hdg_ann = props.globals.getNode("autopilot/settings/heading-bug-deg");
var v1 = props.globals.getNode("controls/flight/v1");
var vr = props.globals.getNode("controls/flight/vr");
var v2 = props.globals.getNode("controls/flight/v2");
var vref = props.globals.getNode("controls/flight/vref");
var va = props.globals.getNode("controls/flight/va");
var mag_hdg = props.globals.getNode("orientation/heading-magnetic-deg");
#var range = props.globals.getNode("instrumentation/nd/range");
var map = props.globals.getNode("instrumentation/primus2000/dc840/mfd-map");
var dist_rem = props.globals.getNode("autopilot/route-manager/distance-remaining-nm");

var nd_display = {};

var myCockpit_switches = {
'toggle_range':         {path: '/inputs/range-nm', value:20, type:'INT'},
'toggle_weather':       {path: '/inputs/wxr', value:0, type:'BOOL'},
'toggle_weather_live':  {path: '/mfd/wxr-live-enabled', value: 0, type: 'BOOL'},
'toggle_airports':      {path: '/inputs/arpt', value:0, type:'BOOL'},
'toggle_stations':      {path: '/inputs/sta', value:0, type:'BOOL'},
'toggle_waypoints':     {path: '/inputs/wpt', value:0, type:'BOOL'},
'toggle_position':      {path: '/inputs/pos', value:0, type:'BOOL'},
'toggle_data':          {path: '/inputs/data',value:0, type:'BOOL'},
'toggle_terrain':       {path: '/inputs/terr',value:0, type:'BOOL'},
'toggle_traffic':       {path: '/inputs/tfc',value:0, type:'BOOL'},
'toggle_centered':      {path: '/inputs/nd-centered',value:0, type:'BOOL'},
'toggle_lh_vor_adf':    {path: '/inputs/lh-vor-adf',value:0, type:'INT'},
'toggle_rh_vor_adf':    {path: '/inputs/rh-vor-adf',value:0, type:'INT'},
'toggle_display_mode':  {path: '/mfd/display-mode', value:'MAP', type:'STRING'}, # valid values are: APP, MAP, PLAN or VOR
'toggle_display_type':  {path: '/mfd/display-type', value:'LCD', type:'STRING'}, # valid values are: CRT or LCD
'toggle_true_north':    {path: '/mfd/true-north', value:0, type:'BOOL'},
'toggle_rangearc':      {path: '/mfd/rangearc', value:0, type:'BOOL'},
'toggle_track_heading': {path: '/hdg-trk-selected', value:0, type:'BOOL'},
'toggle_hdg_bug_only':  {path: '/hdg-bug-only', value:0, type:'BOOL'},
'toggle_cruise_alt' : 	{path: '/cruise-alt', value: 100, type: 'DOUBLE'},
'toggle_fp_active' :		{path: '/fp-active',value:0,type:'BOOL'},
};

var _list = setlistener("sim/signals/fdm-initialized", func {
	var ND = NdDisplay;
	var NDcpt_B = ND.new("instrumentation/efis", myCockpit_switches, "Citation");

	nd_display.cpt_B = canvas.new({
		  "name": "ND",
		  "size": [1024,1024],
		  "view": [900,1024],
		  "mipmapping": 1
	});
	nd_display.cpt_B.addPlacement({"node": placement_back});
	var group = nd_display.cpt_B.createGroup();
	NDcpt_B.newMFD(group, nd_display.cpt_B);
	NDcpt_B.update();

	var MFD_canvas = {
		new: func() {
			var m = {parents:[MFD_canvas]};
			m.canvas = canvas.new({
				"name": "MFD", 
				"size": [1024, 1024],
				"view": [900, 1024],
				"mipmapping": 1 
			});
			m.canvas.addPlacement({"node": placement_front});
			m.canvas.setColorBackground(0,0,0,0);
			m.mfd = m.canvas.createGroup();
			canvas.parsesvg(m.mfd, get_local_path("Images/ND_F.svg"));

			### Texts init ###
			m.text = {};
			m.text_val = ["wx","bank","sat","tas","gspd","clock",
										"chrono","navDist","navId","navTtw","navType",
										"hdgAnn","main","range","distRem"];
			foreach(var element;m.text_val) {
				m.text[element] = m.mfd.getElementById(element);
			}

			### Menus init ###
			m.menu = props.globals.getNode("instrumentation/primus2000/mfd/menu-num");
			m.s_menu = props.globals.getNode("instrumentation/primus2000/mfd/s-menu");

			m.menus = {};
			m.menu_val = ["menu1","menu2","menu3","menu4","menu5","menu1b",
										"menu2b","menu3b","menu4b","menu5b"];
			foreach(var element;m.menu_val) {
				m.menus[element] = m.mfd.getElementById(element);
			}

			m.rect = {};
			m.cdr = ["cdr1","cdr2","cdr3","cdr4","cdr5"];
			foreach(var element;m.cdr) {
				m.rect[element] = m.mfd.getElementById(element);
			}

			m.design = {}; 
			m.pat = ["trueNorth"];
			foreach(var element;m.pat) {
				m.design[element] = m.mfd.getElementById(element);
			}
			m.design.trueNorth.hide(); # initialisation

			m.tod = m.mfd.createChild("text","TOD")
				.setTranslation(450,250)
				.setAlignment("center-center")
				.setText("TOD")
				.setFont("LiberationFonts/LiberationMono-Bold.ttf")
				.setFontSize(36)
				.setColor(1,1,0)
				.setScale(1.5);
			m.tod.hide();

			m.tod_timer = nil;

			return m;	
		},

		listen : func { 
			setlistener("instrumentation/efis/mfd/display-mode", func {
				if (cmdarg().getValue() == "PLAN") {me.design.trueNorth.show()}
				else {me.design.trueNorth.hide()}
			},0,0);

			setlistener("autopilot/locks/alm-tod", func (n) {
				if (n.getValue()) {
					var t = 0;
					me.tod_timer = maketimer(0.5,func() {
						if (t==0) {me.tod.hide()}
						if (t==1) {me.tod.show()}					
						t+=1;
						if(t==2) {t=0}
					});
					me.tod_timer.start();
				} else { 
					if (me.tod_timer != nil and me.tod_timer.isRunning) {
					me.tod_timer.stop()}
					me.tod.hide();
				}
			},0,0);

			setlistener("autopilot/route-manager/active", func (n) {
				setprop("instrumentation/efis/fp-active",n.getValue());
			},0,0);

		}, # end of listen

		update: func {
			### values ###
			me.text.clock.setText(sprintf("%02d",clk_hour.getValue())~":"~sprintf("%02d",clk_min.getValue())~ ":"~sprintf("%02d",clk_sec.getValue()));
			me.text.chrono.setText(sprintf("%02d",chr_hour.getValue())~":"~sprintf("%02d",chr_min.getValue())~ ":"~sprintf("%02d",chr_sec.getValue()));
			if (etx.getValue()!=0) {me.text.chrono.show()}
			else {me.text.chrono.hide()}
			me.text.wx.setText(sprintf("%2d",wx.getValue()));
			me.text.bank.setText(sprintf("%2d",bank.getValue()));
			me.text.sat.setText(sprintf("%2d",sat.getValue()));
			me.text.tas.setText(sprintf("%3d",tas.getValue()));
			me.text.gspd.setText(sprintf("%3d",gspd.getValue()));
	#		if (tcas.getValue()) {me.text.tcas.setText("AUTO");
	#		} else {me.text.tcas.setText("OFF")}
			me.text.navDist.setText(sprintf("%3.1f",nav_dist.getValue())~" NM");			
			me.text.navId.setText(nav_id.getValue());
			me.text.navType.setText(nav_type.getValue());
			me.text.hdgAnn.setText(sprintf("%03d",hdg_ann.getValue()));
			me.text.navTtw.setText(getprop("autopilot/internal/nav-ttw"));
			if (!getprop("instrumentation/primus2000/mfd/menu-num")) {
				me.text.main.setText("MAIN 1/2");
			} else {me.text.main.setText("MAIN 2/2")}
			if (dist_rem.getValue() >0) {
				me.text.distRem.setText(sprintf("%.0f",dist_rem.getValue())~" NM");
			} else {me.text.distRem.setText("")}

		### Menus ###
			if (me.menu.getValue() == 0) {
				if (me.s_menu.getValue() == 0) {
					me.menus.menu1.setText("PFD");
					me.menus.menu1b.setText("SETUP");
					me.menus.menu1b.setColor(1,1,1);
					me.menus.menu2.setText("MFD");
					me.menus.menu2b.setText("SETUP");
					me.menus.menu2b.setColor(1,1,1);
					me.menus.menu3.setText("ET/FT");
					me.menus.menu3b.setText("TIMER");
					me.menus.menu3b.setColor(1,1,1);
					me.menus.menu4.setText("EICAS");
					me.menus.menu4b.setText("SYS");
					me.menus.menu4b.setColor(1,1,1);
					me.menus.menu5.setText("V");
					me.menus.menu5b.setText("SPEED");
					me.menus.menu5b.setColor(1,1,1);
					me.show_rect();
				}
				if (me.s_menu.getValue() == 2) {
					me.menus.menu1.setText("VOR");
					me.menus.menu1b.setText("");
					me.menus.menu2.setText("APT");
					me.menus.menu2b.setText("");
					me.menus.menu3.setText("FIX");
					me.menus.menu3b.setText("");
					me.menus.menu4.setText("TRAFF");
					me.menus.menu4b.setText("");
					me.menus.menu5.setText("V");
					me.menus.menu5b.setText("PROF");
					me.menus.menu5b.setColor(1,1,1);
					me.show_rect();
				}
				if (me.s_menu.getValue() == 5) {
					me.menus.menu1.setText("V1");
					me.menus.menu1b.setText(sprintf("%03d",v1.getValue()));
					me.menus.menu1b.setColor(0,1,0.9);
					me.menus.menu2.setText("Vr");
					me.menus.menu2b.setText(sprintf("%03d",vr.getValue()));
					me.menus.menu2b.setColor(0,1,0.9);
					me.menus.menu3.setText("V2");
					me.menus.menu3b.setText(sprintf("%03d",v2.getValue()));
					me.menus.menu3b.setColor(0,1,0.9);
					me.menus.menu4.setText("Vref");
					me.menus.menu4b.setText(sprintf("%03d",vref.getValue()));
					me.menus.menu4b.setColor(0,1,0.9);
					me.menus.menu5.setText("Vapp");
					me.menus.menu5b.setText(sprintf("%03d",va.getValue()));
					me.menus.menu5b.setColor(0,1,0.9);
					me.show_rect();
				}

			} else if (me.menu.getValue() == 1){
				me.menus.menu1.setText("SRC");
				me.menus.menu1b.setText("1 FMS 2");
				me.menus.menu1b.setColor(1,1,1);
				me.menus.menu2.setText("");
				me.menus.menu2b.setText("");
				me.menus.menu3.setText("LRU");
				me.menus.menu3b.setText("TEST");
				me.menus.menu3b.setColor(1,1,1);
				me.menus.menu4.setText("");
				me.menus.menu4b.setText("");
				me.menus.menu5.setText("MAINT");
				me.menus.menu5b.setText("");
				me.show_rect();
			}

##### Design #####
			if (getprop("instrumentation/efis/mfd/display-mode")=="PLAN") {
				me.design.trueNorth.show();
			}else{
				me.design.trueNorth.hide()}

##### Update Timer #####			
#			settimer(func me.update(),0.1);
			settimer(func me.update(),0);
		},

		show_rect: func() {
			var n = 0;
			foreach(var element;me.cdr) {
				if (getprop("instrumentation/primus2000/mfd/cdr"~n)) {
					me.rect[element].show();
				} else {me.rect[element].hide()}
				n+=1;
			}
		}
	};

###### Main #####
	var mfd = MFD_canvas.new();
	mfd.listen();
	mfd.update();
	print('MFD Canvas ... Ok');
#################

	removelistener(_list); # run ONCE
});


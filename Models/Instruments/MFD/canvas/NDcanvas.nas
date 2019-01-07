##
##### Citation X - Canvas NdDisplay #####
##### Christian Le Moigne (clm76) - oct 2016 - Nov 2018 ###

var nasal_dir = getprop("/sim/aircraft-dir") ~ "/Models/Instruments/MFD/canvas";
io.load_nasal(nasal_dir ~ '/NavMap.nas', "fgMap");
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
var mag_hdg = props.globals.getNode("orientation/heading-magnetic-deg");
#var range = props.globals.getNode("instrumentation/nd/range");
var dist_rem = props.globals.getNode("autopilot/route-manager/distance-remaining-nm");
var Wtot = nil;
var Flaps = nil;
var v1 = nil;
var vr = nil;
var v2 = nil;
var vref = nil;
var v1_m = "controls/flight/v1";
var vr_m = "controls/flight/vr";
var v2_m = "controls/flight/v2";
var vref_m = "controls/flight/vref";
var va = "controls/flight/va";

var _list = setlistener("sim/signals/fdm-initialized", func {
  fgMap.NavMap.new(); # To navMap.nas for background

	var MFDDisplay = {
		new: func() {
			var m = {parents:[MFDDisplay]};
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
			m.menu = "instrumentation/primus2000/mfd/menu-num";
			m.s_menu = "instrumentation/primus2000/mfd/s-menu";

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
      m.ete = nil;
      m.white = [1,1,1];
      m.blue = [0,1,0.9];

			return m;	
		}, # end of new

		listen : func { 
			setlistener("instrumentation/primus2000/dc840/mfd-map", func(n) {
				if (n.getValue()) me.design.trueNorth.show();
				else me.design.trueNorth.hide();
			},0,0);

			setlistener("autopilot/locks/alm-tod", func (n) {
				if (n.getValue()) {
					var t = 0;
					me.tod_timer = maketimer(0.5,func() {
						if (t==0) {me.tod.show()}
						if (t==1) {me.tod.hide()}					
						t+=1;
						if(t==2) {t=0}
					});
					me.tod_timer.start();
				} else { 
					if (me.tod_timer != nil and me.tod_timer.isRunning) {
					  me.tod_timer.stop();
					  me.tod.hide();
          }
				}
			},0,0);

			setlistener("autopilot/route-manager/active", func (n) {
				setprop("instrumentation/efis/fp-active",n.getValue());
			},0,0);

      setlistener(me.menu, func {
        me.razMenu();
        me.selectMenu();
        me.VspeedMenu();
      },0,0);

      setlistener(me.s_menu, func {
        me.razMenu();
        me.selectMenu();
        me.VspeedMenu();
      },0,0);

      setlistener("instrumentation/primus2000/mfd/cdr-tot", func {
        me.showRect();
      },0,0);

      setlistener("/controls/flight/flaps", func {
        me.VspeedUpdate();
        me.VspeedMenu();
      },0,0);

      setlistener("/controls/flight/v1", func {
        me.VspeedMenu();
      },0,0);

      setlistener("/controls/flight/v2", func {
        me.VspeedMenu();
      },0,0);

      setlistener("/controls/flight/vr", func {
        me.VspeedMenu();
      },0,0);

      setlistener("/controls/flight/vref", func {
        me.VspeedMenu();
      },0,0);

      setlistener("/controls/flight/va", func {
        me.VspeedMenu();
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

      me.ete = getprop("autopilot/internal/nav-ttw");
		  if (!me.ete or size(me.ete) > 10) {me.ete = "ETE 0:00"}
#		  else {
#        me.vec_ete = split(":",me.ete);
#        me.vec_ete = split("ETE ",me.vec_ete[0]);
#        me.h_ete = int(me.vec_ete[1]/60);
#        me.mn_ete = me.vec_ete[1]-me.h_ete*60;
#        me.ete = "ETE "~me.h_ete~":"~sprintf("%02i",me.mn_ete);
#      }
			me.text.navTtw.setText(me.ete);
			if (dist_rem.getValue() > 0) {
				me.text.distRem.setText(sprintf("%.0f",dist_rem.getValue())~" NM");
			} else {me.text.distRem.setText("")}

          ##### Update Timer #####			
			settimer(func me.update(),0);

		}, # end of update

    selectMenu : func {
      me.setColor(me.white);
			if (getprop(me.menu) == 0) {
				me.text.main.setText("MAIN 1/2");
				if (getprop(me.s_menu) == 0) {
					me.menus.menu1.setText("PFD");
					me.menus.menu1b.setText("SETUP");
					me.menus.menu2.setText("MFD");
					me.menus.menu2b.setText("SETUP");
					me.menus.menu3.setText("ET/FT");
					me.menus.menu3b.setText("TIMER");
					me.menus.menu4.setText("EICAS");
					me.menus.menu4b.setText("SYS");
					me.menus.menu5.setText("V");
					me.menus.menu5b.setText("SPEED");
				}
				if (getprop(me.s_menu) == 1) {
					me.menus.menu1.setText("BARO");
					me.menus.menu2.setText("M-ALT");
				}
				if (getprop(me.s_menu) == 2) {
					me.menus.menu1.setText("VOR");
					me.menus.menu2.setText("APT");
					me.menus.menu3.setText("FIX");
					me.menus.menu4.setText("TRAFF");
					me.menus.menu5.setText("V");
					me.menus.menu5b.setText("PROF");
				}
			} else {
        me.text.main.setText("MAIN 2/2");
				me.menus.menu1.setText("SRC");
				me.menus.menu1b.setText("1 FMS 2");
				me.menus.menu3.setText("LRU");
				me.menus.menu3b.setText("TEST");
				me.menus.menu5.setText("MAINT");
			}
    }, # end of selectMenu

    VspeedUpdate : func {
	    Wtot = getprop("yasim/gross-weight-lbs");
	    Flaps = getprop("controls/flight/flaps");
	    if (Flaps > 0.142) {
		    if (Wtot <31000) {v1=115;vr=118;v2=129}
		    if (Wtot >=31000 and Wtot <33000) {v1=116;vr=120;v2=128}
		    if (Wtot >=33000 and Wtot <34000) {v1=121;vr=126;v2=131}
		    if (Wtot >=34000 and Wtot <35000) {v1=124;vr=128;v2=133}
		    if (Wtot >=35000 and Wtot <36100) {v1=126;vr=131;v2=135}
		    if (Wtot >=36100) {v1=129;vr=133;v2=137}
	    }
	    else {
		    if (Wtot <27000) {v1=122;vr=126;v2=139}
		    if (Wtot >=27000 and Wtot <29000) {v1=123;vr=126;v2=139}
		    if (Wtot >=29000 and Wtot <31000) {v1=125;vr=126;v2=138}
		    if (Wtot >=31000 and Wtot <33000) {v1=126;vr=126;v2=138}
		    if (Wtot >=33000 and Wtot <34000) {v1=127;vr=127;v2=138}
		    if (Wtot >=34000 and Wtot <35000) {v1=130;vr=130;v2=140}
		    if (Wtot >=35000 and Wtot <36100) {v1=132;vr=132;v2=143}
		    if (Wtot >=36100) {v1=134;vr=134;v2=144}
	    }
	    setprop("controls/flight/v1",v1);
	    setprop("controls/flight/vr",vr);
	    setprop("controls/flight/v2",v2);
	    setprop("controls/flight/vf5",180);
	    setprop("controls/flight/vf15",160);
	    setprop("controls/flight/vf35",140);
    }, # end of VspeedUpdate

    VspeedMenu : func {      
			if (getprop(me.menu) == 0 and getprop(me.s_menu) == 5) {
				me.menus.menu1.setText("V1");
				me.menus.menu1b.setText(sprintf("%03d",getprop(v1_m)));
				me.menus.menu2.setText("Vr");
				me.menus.menu2b.setText(sprintf("%03d",getprop(vr_m)));
				me.menus.menu3.setText("V2");
				me.menus.menu3b.setText(sprintf("%03d",getprop(v2_m)));
				me.menus.menu4.setText("Vref");
				me.menus.menu4b.setText(sprintf("%03d",getprop(vref_m)));
				me.menus.menu5.setText("Vapp");
				me.menus.menu5b.setText(sprintf("%03d",getprop(va)));
        me.setColor(me.blue);
			}
    }, # end of VspeedMenu

    setColor : func(color) {
      for (var n=5;n<10;n+=1) {
        me.menus[me.menu_val[n]].setColor(color);
      }
    }, # end of setColor

    razMenu : func {
      for (var n=1;n<10;n+=1) me.menus[me.menu_val[n]].setText("");
    }, # end of razMenu

		showRect: func() {
			var n = 0;
			foreach(var element;me.cdr) {
				if (getprop("instrumentation/primus2000/mfd/cdr"~n)) {
					me.rect[element].show();
				} else {me.rect[element].hide()}
				n+=1;
			}
		}, # end of showRect

	}; # end of MFDDisplay

###### Main #####
	var mfd = MFDDisplay.new();
	mfd.listen();

	var v_speed = func() {		
		mfd.VspeedUpdate();
    mfd.VspeedMenu();
	}
	var timer = maketimer(10,v_speed);
	timer.singleShot = 1;
	timer.start();

  mfd.selectMenu();
#  mfd.VspeedUpdate();
#  mfd.VspeedMenu();
  mfd.showRect();
	mfd.update();
	print('MFD Canvas ... Ok');
#################

	removelistener(_list); # run ONCE
}); # end of list


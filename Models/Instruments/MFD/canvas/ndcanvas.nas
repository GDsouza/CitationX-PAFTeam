##
##### Citation X - Canvas NdDisplay #####
##### Christian Le Moigne (clm76) - oct 2016 - release Jan 2021 ###

var nasal_dir = getprop("/sim/aircraft-dir") ~ "/Models/Instruments/MFD/canvas";
io.load_nasal(nasal_dir ~ '/navmap.nas', "fgMap");
io.include('init.nas');

var clk_gmt = "sim/time/gmt-string";
var chrono = ["instrumentation/mfd/chrono",
                "instrumentation/mfd[1]/chrono"];
var wx = ["instrumentation/mfd/range-nm","instrumentation/mfd[1]/range-nm"];
var bank = "autopilot/settings/bank-limit";
var sat = "environment/temperature-degc";
var tas = "instrumentation/airspeed-indicator/true-speed-kt";
var gspd = "velocities/groundspeed-kt";
var etx = ["instrumentation/mfd/etx","instrumentation/mfd[1]/etx"];
var nav_dist = "autopilot/internal/nav-distance";
var nav_id = "autopilot/settings/nav-id";
var nav_type = "autopilot/settings/nav-type";
var hdg_ann = "autopilot/settings/heading-bug-deg";
var dist_rem = "autopilot/route-manager/distance-remaining-nm";
var dme_dist = ["instrumentation/dme/indicated-distance-nm",
              "instrumentation/dme[1]/indicated-distance-nm"];
var dme_id = ["instrumentation/dme/dme-id",
             "instrumentation/dme[1]/dme-id"];
var dme_ir = ["instrumentation/dme/in-range",
             "instrumentation/dme[1]/in-range"];
var Wtot = nil;
var flaps = nil;
var v1 = nil;
var vr = nil;
var v2 = nil;
var vref = nil;
var chronH = nil;
var chronM = nil;
var chronS = nil;
var nav_src = "NAV";
var nav_num = 0;
var v1_m = "controls/flight/v1";
var vr_m = "controls/flight/vr";
var v2_m = "controls/flight/v2";
var vref_m = "controls/flight/vref";
var va = "controls/flight/va";

	var MFDDisplay = {
		new: func(x) {
			var m = {parents:[MFDDisplay]};
      if (!x) {
			  m.canvas = canvas.new({
				  "name": "MFD_L", 
				  "size": [1024, 1024],
				  "view": [900, 1024],
				  "mipmapping": 1 
			  });
			  m.canvas.addPlacement({"node": "screenL_F"});
			  m.canvas.setColorBackground(0,0,0,0);
      } else {
			  m.canvas = canvas.new({
				  "name": "MFD_R", 
				  "size": [1024, 1024],
				  "view": [900, 1024],
				  "mipmapping": 1 
			  });
			  m.canvas.addPlacement({"node": "screenR_F"});
			  m.canvas.setColorBackground(0,0,0,0);
      }
			  m.mfd = m.canvas.createGroup();
			  canvas.parsesvg(m.mfd, get_local_path("Images/nd-front.svg"));

			### Texts init ###
			m.text = {};
			m.text_val = ["wx","bank","sat","tas","gspd","clock",
										"chrono","navDist","navId","navTtw","navType",
										"hdgAnn","main","range","distRem","dmeTxt","dmeId","dmeDist"];
			foreach(var element;m.text_val) {
				m.text[element] = m.mfd.getElementById(element);
			}

			### Menus init ###
			m.menu = ["instrumentation/mfd/menu2",
                "instrumentation/mfd[1]/menu2"];
			m.s_menu = ["instrumentation/mfd/s-menu",
                  "instrumentation/mfd[1]/s-menu"];

			m.menus = {};
			m.menu_val = ["menu1","menu2","menu3","menu4","menu5",
                    "menu1b","menu2b","menu3b","menu4b","menu5b"];
			foreach(var element;m.menu_val) {
				m.menus[element] = m.mfd.getElementById(element);
			}

			m.rect = {};
			m.cdr = ["cdr1","cdr2","cdr3","cdr4","cdr5",
               "cdr1a","cdr1b","cdr5a","cdr5b"];
			foreach(var element;m.cdr) {
				m.rect[element] = m.mfd.getElementById(element);
			}

			m.trueNorth = m.mfd.getElementById("trueNorth").hide();

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
      m.magenta = [0.9,0,0.9];
      m.green = [0,1,0];

#      me.dme_enabled = 1; # electrical init
			return m;	
		}, # end of new

		listen : func(x) { 
			setlistener("instrumentation/dc840["~x~"]/mfd-map", func(n) {
        me.trueNorth.setVisible(n.getValue());
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

      setlistener(me.menu[x], func {
        me.razMenu();
        me.selectMenu(x);
        me.VspeedMenu(x);
      },0,0);

      setlistener(me.s_menu[x], func {
        me.razMenu();
        me.selectMenu(x);
        me.VspeedMenu(x);
      },0,0);

      setlistener("instrumentation/mfd["~x~"]/cdr-tot", func {
        me.showRect(x);
      },0,1);

      setlistener("/controls/flight/flaps-select", func {
        me.VspeedUpdate();
        me.VspeedMenu(x);
      },0,0);

      setlistener("/controls/flight/v1", func {
        me.VspeedMenu(x);
      },0,0);

      setlistener("/controls/flight/v2", func {
        me.VspeedMenu(x);
      },0,0);

      setlistener("/controls/flight/vr", func {
        me.VspeedMenu(x);
      },0,0);

      setlistener("/controls/flight/vref", func {
        me.VspeedMenu(x);
      },0,0);

      setlistener("/controls/flight/va", func {
        me.VspeedMenu();
      },0,0);

		  setlistener("systems/electrical/outputs/dme"~(x+1),func(n) {
        me.dme_enabled = n.getValue();
        me.dme_color = n.getValue() ? [1,0,0] : [0,1,0];
      },1,0);

      setlistener("autopilot/settings/nav-source",func(n) {
        nav_src = left(n.getValue(),3);
        nav_num = right(n.getValue(),1)-1;
      },0,0);
		}, # end of listen

		update: func(x) {
      me.DME();
			me.text.clock.setText(getprop(clk_gmt));
			if (getprop(etx[x])!=0) {
        chron = int(getprop(chrono[x]));
        chronS = math.fmod(chron,60);
        chronH = chron/3600;
        chronM = (chronH-int(chronH))*60;
        me.text.chrono.show();
      } else me.text.chrono.hide();
			me.text.chrono.setText(sprintf("%02d",chronH)~":"~sprintf("%02d",chronM)~ ":"~sprintf("%02d",chronS));
			me.text.wx.setText(sprintf("%2d",getprop(wx[x])));
			me.text.bank.setText(sprintf("%2d",getprop(bank)));
			me.text.sat.setText(sprintf("%2d",getprop(sat)));
			me.text.tas.setText(sprintf("%3d",getprop(tas)));
			me.text.gspd.setText(sprintf("%3d",getprop(gspd)));
			me.text.navDist.setText(sprintf("%3.1f",getprop(nav_dist))~" NM");			
			me.text.navId.setText(getprop(nav_id));
			me.text.navType.setText(getprop(nav_type)).setColor(left(getprop(nav_type),3) == "FMS" ? me.magenta : me.green);
			me.text.hdgAnn.setText(sprintf("%03d",getprop(hdg_ann)));
			if (getprop(dist_rem) > 0 and left(getprop(nav_type),3) == "FMS")
				me.text.distRem.setText(sprintf("%.0f",getprop(dist_rem))~" NM");
			else me.text.distRem.setText("");

      me.ete = getprop("autopilot/internal/nav-ttw");
		  if (!me.ete or size(me.ete) > 11) me.ete = "ETE 0+00";
      else {
        me.vec_ete = split(":",me.ete);
        me.vec_ete = split("ETE ",me.vec_ete[0]);
        me.h_ete = int(me.vec_ete[1]/60);
        me.mn_ete = me.vec_ete[1]-me.h_ete*60;
        me.ete = "ETE "~me.h_ete~"+"~sprintf("%02i",me.mn_ete);
      }
      setprop("autopilot/internal/nav-ete",me.ete);
			me.text.navTtw.setText(me.ete);

			settimer(func me.update(x),0.1);

		}, # end of update

    DME : func {
      if (!me.dme_enabled) {
        me.text.dmeTxt.show().setColor(1,0,0);
        me.text.dmeId.hide();
        me.text.dmeDist.hide();
      } else {
        if (nav_src == "NAV" and getprop(dme_id[nav_num]) != "") {
          me.text.dmeTxt.show().setColor(0,1,0);
          me.text.dmeId.show().setText(getprop(dme_id[nav_num]));
          if (getprop(dme_ir[nav_num])) 
            me.text.dmeDist.show().setText(sprintf("%.1f",getprop(dme_dist[nav_num]))~" NM");
          else me.text.dmeDist.show().setText("--- NM");
        } else {
          me.text.dmeTxt.hide();
          me.text.dmeId.hide();
          me.text.dmeDist.hide();
        }
      }
    }, # end of DME

    selectMenu : func (x) {
      me.setColor(me.white);
			if (getprop(me.menu[x]) == 0) { # menus 1
				me.text.main.setText("MAIN 1/2");
				if (getprop(me.s_menu[x]) == 0) {
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
				if (getprop(me.s_menu[x]) == 1) {
					me.menus.menu1.setText("BARO");
					me.menus.menu2.setText("M-ALT");
				}
				if (getprop(me.s_menu[x]) == 2) {
					me.menus.menu1.setText("VOR");
					me.menus.menu2.setText("APT");
					me.menus.menu3.setText("FIX");
					me.menus.menu4.setText("TRAFF");
					me.menus.menu5.setText("V");
					me.menus.menu5b.setText("PROF");
				}
			} else { # menus 2
        me.text.main.setText("MAIN 2/2");
				me.menus.menu1.setText("SRC");
				me.menus.menu1b.setText("1 FMS 2");
				me.menus.menu3.setText("LRU");
				me.menus.menu3b.setText("TEST");
				me.menus.menu5.setText("FGC");
				me.menus.menu5b.setText("A SRC B");
			}
    }, # end of selectMenu

    VspeedUpdate : func {
	    Wtot = getprop("yasim/gross-weight-lbs");
	    flaps = getprop("controls/flight/flaps-select");
	    if (flaps > 2) {
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

    VspeedMenu : func(x) {      
			if (getprop(me.menu[x]) == 0 and getprop(me.s_menu[x]) == 5) {
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

		showRect: func(x) {
			var n = 0;
			foreach(var element;me.cdr) {
				if (getprop("instrumentation/mfd["~x~"]/cdr"~n)) {
          me.rect[element].show();
				} else {me.rect[element].hide()}
				n+=1;
			}
		}, # end of showRect

	}; # end of MFDDisplay

###### Main #####
var mfd_setl = setlistener("sim/signals/fdm-initialized", func() {
  for (var x=0;x<2;x+=1) {
    fgMap.NavMap.new(x); # To navMap.nas for background
	  var mfd = MFDDisplay.new(x);
	  mfd.listen(x);
    mfd.selectMenu(x);
    mfd.showRect(x);
	  mfd.update(x);
  }
	var v_speed = func {		
		mfd.VspeedUpdate();
    mfd.VspeedMenu(0);
    mfd.VspeedMenu(1);
	}
	var timer = maketimer(10,v_speed);
	timer.singleShot = 1;
	timer.start();
	print('MFD Canvas ... Ok');
	removelistener(mfd_setl); 
},0,0);


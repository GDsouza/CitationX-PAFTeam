#==========================================================
# Citation X - PFD Canvas
# Christian Le Moigne (clm76) Feb 2019
# =========================================================

var AdfHeading = ["instrumentation/adf/indicated-bearing-deg",
                  "instrumentation/adf[1]/indicated-bearing-deg"];
var AltDiff = "instrumentation/pfd/target-altitude-diff";
var AltFt = "instrumentation/altimeter/indicated-altitude-ft";
var AltMeters = "instrumentation/mfd/alt-meters";
var AltTrd = "instrumentation/pfd/alt-trend-ft";
var ApAlt = "autopilot/locks/altitude";
var ApDist = "autopilot/internal/nav-distance";
var ApHarmed = "autopilot/locks/heading-arm";
var ApHeading = "autopilot/locks/heading";
var ApNavSource = "autopilot/settings/nav-source";
var ApStatus = "autopilot/locks/AP-status";
var ApVarmed = "autopilot/locks/altitude-arm";
var Asel = "autopilot/settings/asel";
var Baro_inhg = "instrumentation/altimeter/setting-inhg";
var Baro_hpa = "instrumentation/altimeter/setting-hpa";
var BaroMode = "instrumentation/mfd/baro-hpa";
var crsDefl_fms = "autopilot/internal/course-deflection";
var crsDefl_nav = ["instrumentation/nav/heading-needle-deflection",
                   "instrumentation/nav[1]/heading-needle-deflection"];
var crsOffset = "autopilot/internal/course-offset";
var dispCtrl = "systems/electrical/outputs/disp-cont1";
var FpActive = "autopilot/route-manager/active";
var FmsAltDsp = "autopilot/settings/tg-alt-ft";
var FmsHeading = "instrumentation/gps/wp/wp[1]/bearing-mag-deg";
var FmsSet = "autopilot/settings/fms";
var FromFlag = "autopilot/locks/from-flag";
var GsDefl = "autopilot/internal/gs-deflection";
var GsInRange = "autopilot/internal/gs-in-range";
var Hdg = "autopilot/settings/heading-bug-deg";
var Heading = "orientation/heading-magnetic-deg";
var hold_active = "autopilot/locks/hold/active";
var Iac = ["systems/electrical/outputs/iac1",
           "systems/electrical/outputs/iac2"];
var Ias = "velocities/airspeed-kt";
var InRange = "autopilot/internal/in-range";
var Mach = "velocities/mach";
var Marker_i = "instrumentation/marker-beacon/inner";
var Marker_m = "instrumentation/marker-beacon/middle";
var Marker_o = "instrumentation/marker-beacon/outer";
var MinDiff = "instrumentation/pfd/minimum-diff";
var MinimumsMode = "autopilot/settings/minimums-mode";
var MinimumsValue = "autopilot/settings/minimums";
var navErr = ["autopilot/internal/nav1-heading-error-deg",
              "autopilot/internal/nav2-heading-error-deg"];
var NavData = ["instrumentation/nav/data-is-valid",
               "instrumentation/nav[1]/data-is-valid"];
var NavDist = ["instrumentation/nav/nav-distance",
               "instrumentation/nav[1]/nav-distance"];
var NavHeading = ["instrumentation/nav/heading-deg",
                  "instrumentation/nav[1]/heading-deg"];
var NavId = ["instrumentation/nav/nav-id",
             "instrumentation/nav[1]/nav-id"];
var NavInRange = ["instrumentation/nav/in-range",
                  "instrumentation/nav[1]/in-range"];
var Nav1Sel = "instrumentation/pfd/nav1ptr";
var Nav2Sel = "instrumentation/pfd/nav2ptr";
var Nav1Val = "instrumentation/pfd/nav1-value";
var Nav2Val = "instrumentation/pfd/nav2-value";
var NavSrc = "autopilot/settings/nav-source";
var NavTyp = "autopilot/settings/nav-type";
var PfdCrs = "instrumentation/pfd/selected-deg";
var PfdHdg = "instrumentation/pfd/heading-deg";
var PfdHdgErr = "instrumentation/pfd/heading-error-deg";
var PfdHsi = "instrumentation/dc840/hsi";
var PfdOffset = "instrumentation/pfd/course-offset";
var PfdSel = "instrumentation/pfd/pfd-sel";
var PitchBars = "autopilot/internal/pitch-bars";
var PitchDeg = "orientation/pitch-deg";
var RollBars = "autopilot/internal/roll-filter";
var RollDeg = "orientation/roll-deg";
var SelCrs = ["instrumentation/nav/radials/selected-deg",
              "instrumentation/nav[1]/radials/selected-deg"];
var SgRev = "instrumentation/eicas/sg-rev";
var SgTest = "instrumentation/reversionary/sg-test";
var SpdCtrl = "autopilot/locks/speed-ctrl";
var SpdTgKt = "autopilot/settings/target-speed-kt";
var SpdTgMc = "autopilot/settings/target-speed-mach";
var SpdTrd = "instrumentation/pfd/speed-trend-kt";
var StallDiff = "instrumentation/pfd/stall-diff";
var ToFlag = "autopilot/locks/to-flag";
var V1 = "controls/flight/v1";
var V2 = "controls/flight/v2";
var VA = "controls/flight/va";
var VE = "controls/flight/ve";
var VR = "controls/flight/vr";
var Vf = "controls/flight/flaps-select";
var Vne = "instrumentation/pfd/max-airspeed-kts";
var Vref = "controls/flight/vref";
var Vert_spd = "autopilot/internal/vert-speed-fpm";
var alt = nil;
var alt_corr = nil;
var alt_diff = nil;
var alt_trend = nil;
var crs_defl = nil;
var crs_offset = nil;
var disp_cont = [nil,nil];
var dst = nil;
var fms = 0;
var fms_num = [0,0];
var from_flag = [0,0];
var gs_defl = nil;
var hdg = nil;
var hdg_bug = nil;
var ias = nil;
var ias_corr = nil;
var loc_defl = nil;
var min_diff = nil;
var min_mode = "RA";
var n = nil;
var nav_num = [0,0];
var nav_src = nil;
var pfd_hsi = [0,0];
var pfd_src = nil;
var sel = 0;
var sgnl = "NAV1";
var spd_trend = nil;
var to_flag = nil;
var v_dis = nil;
var Vflaps = nil;
var v_ind = nil;
var v_spd = nil;
var wow = nil;

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.fmod(n,m)) > (m/2))
			x = x + m;
	return x;
}

var PFDDisplay = {
  COLORS : {
      green : [0, 1, 0],
      white : [1, 1, 1],
      black : [0, 0, 0],
      lightblue : [0, 1, 1],
      darkblue : [0, 0, 1],
      red : [1, 0, 0],
      magenta : [1, 0, 1],
      orange : [1,0.4,0],
      yellow : [1,1,0]
  },

	new: func {
		var m = {parents: [PFDDisplay]};
    var font_mapper = func (family, weight) {
      if (weight == "bold") return "LiberationFonts/LiberationSans-Bold.ttf";
      else return "LiberationFonts/LiberationSansNarrow-Bold.ttf";
		}
    m.canvas = canvas.new({
	    "name": "PFD", 
	    "size": [1024, 1024],
	    "view": [900, 1024],
	    "mipmapping": 1 
    });
    m.canvas.addPlacement({"node": "screen"});
    m.pfd = m.canvas.createGroup();
	  canvas.parsesvg(m.pfd, "/Models/Instruments/PFD/pfd.svg", {'font-mapper': font_mapper});

    m.AltTrend = m.pfd.createChild("path");
    m.AltTrend.setColorFill(me.COLORS.magenta);

    m.Alt = {};
    m.Alt_keys = ["Alt11100","AltTape","AltLadder","BAROtext",
                  "AltSelText","AltSel00","MinMode","MinValue",
                  "MinBug","AltBug","IaBg"];
    foreach(var i;m.Alt_keys) m.Alt[i] = m.pfd.getElementById(i);

    m.Hor = {};
    m.Hor_keys = ["Horizon","Vbars","BankPtr","GsIls","GsScale",
                  "LocDefl","LocScale"];
    foreach(var i;m.Hor_keys) m.Hor[i] = m.pfd.getElementById(i);

    m.SpdTrend = m.pfd.createChild("path");
    m.SpdTrend.setColorFill(me.COLORS.green);

    m.Spd = {};
    m.Spd_keys = ["SpdTape","CurSpd","CurSpdTen","TgSpd","Vmo",
                  "Vstall","LocScale","IasBg","BottomRect","ER21",
                  "Ind1","Ind2","IndR","IndE","SPEED","SpdBackground"];
    foreach(var i;m.Spd_keys) m.Spd[i] = m.pfd.getElementById(i);

    m.Hsi = {};
    m.Hsi_keys = ["Rose","Ptr1","Ptr2","CrsDeflect","CrsNeedle","scale",
                  "HdgBug","To","From","COMPASS","Lh","Lb","Fl"];
    foreach(var i;m.Hsi_keys) m.Hsi[i] = m.pfd.getElementById(i);

    m.Hsi1 = {};
    m.Hsi1_keys = ["Rose1","Ptr11","Ptr21","CrsDeflect1","CrsNeedle1","scale1",
                  "HdgBug1","To1","From1","COMPASS1","ArrowL","ArrowR",
                  "Lh1","Lb1","Fl1"];
    foreach(var i;m.Hsi1_keys) m.Hsi1[i] = m.pfd.getElementById(i);

    m.Txt = {};
    m.Txt_keys = ["NavType","NavId","NavDst","Ptr1Ind","Ptr1Txt",
                  "Ptr2Ind","Ptr2Txt","HdgVal","DtkVal","McVal",
                  "AltMet","ApStat","ApVert","ApLat","ApVarm",
                  "ApLarm","MarkerI","MarkerM","MarkerO","FmsAlt"];
    foreach(var i;m.Txt_keys) m.Txt[i] = m.pfd.getElementById(i);

    m.Fail  = {};
    m.Fail_keys = ["HorizScale","HorizGnd","AttFail","HdgFail","HdgFailCross",
                   "HdgFailCross1","MadcFail"];
    foreach(var i;m.Fail_keys) m.Fail[i] = m.pfd.getElementById(i);

    m.Vspd = {};
    m.Vspd_keys = ["Arrow","VSpdVal","VSpdInd"];
    foreach(var i;m.Vspd_keys) m.Vspd[i] = m.pfd.getElementById(i);
    m.Vspd.Arrow.setCenter(900,792);

    m.Sg = {};
    m.Sg_keys = ["sg","sgTxt","sgCdr"];
    foreach(var i;m.Sg_keys) m.Sg[i] = m.pfd.getElementById(i);
    m.Sg.sg.hide();

    m.SpdVal = [V1,V2,VR,VA,VE,Vref,Vflaps];
    m.SpdInks = [];
      append(m.SpdInks,m.pfd.getElementById("v1"));
      append(m.SpdInks,m.pfd.getElementById("v2"));
      append(m.SpdInks,m.pfd.getElementById("vr"));
      append(m.SpdInks,m.pfd.getElementById("va"));
      append(m.SpdInks,m.pfd.getElementById("ve"));
      append(m.SpdInks,m.pfd.getElementById("vref"));
      append(m.SpdInks,m.pfd.getElementById("vf"));
      append(m.SpdInks,m.pfd.getElementById("vfTxt"));

    m.pfdSelL = m.pfd.getElementById("pfdSelL");
    m.pfdSelR = m.pfd.getElementById("pfdSelR");

    m.Nav1Ptr = ["","VOR1","ADF1","FMS1"];
    m.Nav2Ptr = ["","VOR2","ADF2","FMS2"];

    ### Horizon center ###
		m.h_trans = m.Hor.Horizon.createTransform();
		m.h_rot = m.Hor.Horizon.createTransform();

    ### Clips : top, right, bottom, left ###
    m.Alt.AltTape.set("clip", "rect(113,850,564,710)");
    m.Alt.AltLadder.set("clip", "rect(297,845,382,800)");
		m.Hor.Horizon.set("clip", "rect(150, 610, 525, 270)");
    m.Spd.SpdTape.set("clip", "rect(113, 200, 560, 10)");
    m.Spd.CurSpdTen.set ("clip", "rect(288, 200, 388, 100)");
    m.Spd.Vmo.set ("clip", "rect(113, 200, 340, 100)");
    m.Spd.Vstall.set ("clip", "rect(300, 200, 561, 100)");

    ### Electrical init ###
    me.radioAlt_enabled = 1;
    me.atthdg_enabled = 1;
    me.atthdgAux_enabled = 1;
    me.madc_enabled = 1;

    return m;
  }, # end of new

  listen : func {
      ##### Electrical #####
		setlistener("systems/electrical/outputs/radio-alt1",func (n) {
      me.radioAlt_enabled = n.getValue();
    },0,0);

		setlistener("systems/electrical/outputs/att-hdg1",func (n) {
      me.atthdg_enabled = n.getValue();
    },0,0);

		setlistener("systems/electrical/outputs/att-hdg-aux1",func (n) {
      me.atthdgAux_enabled = n.getValue();
    },0,0);

		setlistener("systems/electrical/outputs/madc1",func (n) {
      me.madc_enabled = n.getValue();
      me.Fail.MadcFail.setVisible(!me.madc_enabled or getprop(SgTest));
      me.Alt.AltTape.setVisible(me.madc_enabled);
      me.Alt.AltBug.setVisible(me.madc_enabled);
      me.Alt.IaBg.setVisible(me.madc_enabled);
      me.Alt.Alt11100.setVisible(me.madc_enabled);
      me.Alt.AltLadder.setVisible(me.madc_enabled);
      me.Spd.SPEED.setVisible(me.madc_enabled);
      me.Spd.SpdBackground.show();
    },0,0);

      ##### Others #####

		setlistener(MinimumsMode, func(n) {	
			me.Alt.MinMode.setText(n.getValue());
		},1,0);

		setlistener(MinimumsValue, func(n) {	
			me.Alt.MinValue.setText(sprintf("%.0f",n.getValue()));
		},1,0);

		setlistener("/gear/gear[1]/wow", func(n) {
      wow = n.getValue();
		},1,0);

		setlistener(Vf, func(n) {
      if (n.getValue() == 2) {
        me.SpdVal[6] = 180; me.SpdInks[7].setText("FS5");
      } else if (n.getValue() == 3) {
          me.SpdVal[6] = 160; me.SpdInks[7].setText("F15");
      } else if (n.getValue() == 4) {
          me.SpdVal[6] = 140; me.SpdInks[7].setText("F35");
      } else {
          me.SpdVal[6] = 500; me.SpdInks[7].hide # to be out of display range
      }
		},1,0);

    setlistener(FmsSet,func(n) {
      fms = n.getValue();
    },1,0);

		setlistener(ToFlag, func(n) {
      to_flag = n.getValue();
    },1,0);

		setlistener(FromFlag, func(n) {
      from_flag = n.getValue();
    },1,0);

		setlistener(PfdHsi, func(n) {
      pfd_hsi = n.getValue();
    },1,0);

		setlistener(PfdHdg, func(n) {
      setprop(Hdg,getprop(PfdHdg));
      me.Txt.HdgVal.setText(sprintf("%03i",n.getValue()));
    },1,0);

		setlistener(ApStatus, func(n) {
      if (n.getValue()!="") me.Txt.ApStat.setText(n.getValue()).show();
      else me.Txt.ApStat.setText(n.getValue()).hide();
    },1,0);

		setlistener(ApHeading, func(n) {
      me.Txt.ApLat.setText(n.getValue());
    },1,0);

		setlistener(ApAlt, func(n) {
      me.Txt.ApVert.setText(n.getValue());
    },1,0);

		setlistener(ApHarmed, func(n) {
      me.Txt.ApLarm.setText(n.getValue());
    },1,0);

		setlistener(ApVarmed, func(n) {
      me.Txt.ApVarm.setText(n.getValue());
    },1,0);

		setlistener(dispCtrl, func(n) {
      disp_cont = n.getValue();
    },0,0);

		setlistener(NavSrc, func(n) {
      nav_src = left(n.getValue(),3);
      if (nav_src == "NAV") nav_num = right(n.getValue(),1)-1;
      else fms_num = right(n.getValue(),1)-1;
      citation.nav_src_set(n.getValue());
      if (nav_src == "NAV") {
        me.Hsi.CrsNeedle.setColor(me.COLORS.green);
        me.Hsi.Fl.setColorFill(me.COLORS.green);
        me.Hsi.To.setColorFill(me.COLORS.green);
        me.Hsi.From.setColorFill(me.COLORS.green);
        me.Hsi1.CrsNeedle1.setColor(me.COLORS.green);
        me.Hsi1.Fl1.setColorFill(me.COLORS.green);
        me.Hsi1.To1.setColorFill(me.COLORS.green);
        me.Hsi1.From1.setColorFill(me.COLORS.green);
        me.Txt.NavType.setColor(me.COLORS.green);
        me.Txt.NavId.setColor(me.COLORS.green);
        me.Txt.NavDst.setColor(me.COLORS.green);
     } else if (getprop(FpActive)) {
        me.Hsi.CrsNeedle.setColor(me.COLORS.magenta);
        me.Hsi.Fl.setColorFill(me.COLORS.magenta);
        me.Hsi1.CrsNeedle1.setColor(me.COLORS.magenta);
        me.Hsi1.Fl1.setColorFill(me.COLORS.magenta);
        me.Txt.NavType.setColor(me.COLORS.magenta);
        me.Txt.NavId.setColor(me.COLORS.magenta);
        me.Txt.NavDst.setColor(me.COLORS.magenta);
     }
    },1,0);

    setlistener(PfdSel,func(n) {
      me.pfdSelL.setVisible(!n.getValue());
      me.pfdSelR.setVisible(n.getValue());
    },1,0);

		setlistener(Asel, func(n) {
      me.Alt.AltSelText.setText(sprintf("%.0f",n.getValue()));
		},1,0);

    setlistener(SgTest,func(n) {
      me.Txt.ApStat.setText("AP").setVisible(n.getValue());
      me.Fail.MadcFail.setVisible(n.getValue());
    },0,0);
  }, # end of listen

  update_PFD : func {
    pfd_crs = getprop(PfdCrs);
    me.Txt.DtkVal.setText(sprintf("%03i",pfd_crs));
    if (nav_src == "FMS") setprop(PfdOffset,getprop(crsOffset) or 0);
    else if (getprop(ApHeading) == "LOC") setprop(PfdOffset,getprop(navErr[nav_num]));
    else setprop(PfdOffset,geo.normdeg180(pfd_crs-getprop(Heading)));
    if (getprop(Nav1Sel) == 1) setprop(Nav1Val,geo.normdeg(getprop(NavHeading[0])-getprop(Heading)));
    if (getprop(Nav2Sel) == 1) setprop(Nav2Val,geo.normdeg(getprop(NavHeading[1])-getprop(Heading)));
    if (getprop(Nav1Sel) == 2) setprop(Nav1Val,getprop(AdfHeading[0]));
    if (getprop(Nav2Sel) == 2) setprop(Nav2Val,getprop(AdfHeading[1]));
    if (getprop(Nav1Sel) == 3) setprop(Nav1Val,geo.normdeg(getprop(FmsHeading)-getprop(Heading)));
    if (getprop(Nav2Sel) == 3) setprop(Nav2Val,geo.normdeg(getprop(FmsHeading)-getprop(Heading)));
    me.update_ALT();
    me.update_HOR();
    me.update_SPD();
    me.update_HSI();
    me.update_VSP();
    me.update_Markers();
    me.update_Iac();
    ##### set PFD selected values -> autopilot #####
    setprop(SelCrs[nav_num],pfd_crs);

		settimer(func {me.update_PFD();},0.1);
  }, # end of update_PFD

  update_ALT : func {
    if (!me.madc_enabled) return;
    else {
      alt = getprop(AltFt);
      alt_corr = int(roundToNearest(alt/100,0.1));
      if (me.radioAlt_enabled) {
        me.Alt.Alt11100.setText(sprintf("%03.0f",alt_corr)).setColor(0,1,0);
        me.Alt.IaBg.setColor(1,1,1);
      } else {
        me.Alt.Alt11100.setText("RA").setColor(1,0,0);
        me.Alt.IaBg.setColor(1,0,0);
      }
	    me.Alt.AltTape.setTranslation(0,alt*0.284)
                    .setVisible(me.radioAlt_enabled);
      me.Alt.AltLadder.setTranslation(0,math.fmod(alt,100) * 1.24)
                      .setVisible(me.radioAlt_enabled);

      ### Altitude Diff ###
      alt_diff = -0.280 * (getprop(AltDiff) or 0);
      alt_diff = math.clamp(alt_diff,-170,170);
	    me.Alt.AltBug.setTranslation(0,alt_diff)
                   .setVisible(me.radioAlt_enabled);
      ### Altitude Trend (look ahead 6s) ###
      alt_trend = 0.36 * (getprop(AltTrd) or 0);
      alt_trend = math.clamp(alt_trend, -225, 225);
      me.AltTrend.reset()
                 .rect(705,338,12,-alt_trend)
                 .setVisible(me.radioAlt_enabled);
      ### Minimums ###
      min_diff = getprop(MinDiff) or 0;
      me.Alt.MinBug.setColor(min_diff > 0 ? me.COLORS.orange : me.COLORS.green);
      me.Alt.MinBug.setTranslation(0, min_diff * -0.174);
      if (min_diff <= -600) me.Alt.MinBug.hide();
      else me.Alt.MinBug.setVisible(me.radioAlt_enabled);

      ### Alt Meters ###
      if (getprop(AltMeters)) {
        me.Txt.AltMet.setText(sprintf("%03i",alt*0.3048)~"M")
                     .setVisible(me.radioAlt_enabled);
      } else me.Txt.AltMet.hide();

       ### Fms Target Altitude ###
      if (getprop(NavSrc) == "FMS")
         me.Txt.FmsAlt.setText(sprintf("%.0f",getprop(FmsAltDsp))).show();
      else me.Txt.FmsAlt.hide();
    }
      ### Baro ###
      if (getprop(BaroMode)) me.Alt.BAROtext.setText(sprintf("%.2f", getprop(Baro_inhg)));
      else me.Alt.BAROtext.setText(sprintf("%.0f", getprop(Baro_hpa)));
  }, # end of update_ALT

  update_HOR : func {
    if (me.atthdg_enabled and me.atthdgAux_enabled) {
      me.Fail.AttFail.setVisible(getprop(SgTest));
      me.Fail.HorizScale.show();
      me.Fail.HorizGnd.show();
		  me.h_trans.setTranslation(0,getprop(PitchDeg)*7.5);
		  me.h_rot.setRotation(-getprop(RollDeg)*D2R,me.Hor.Horizon.getCenter());
      me.Hor.BankPtr.setRotation(-getprop(RollDeg)*D2R);
      if (getprop("/autopilot/locks/FD-status")) {
        me.Hor.Vbars.show();
        me.Hor.Vbars.setTranslation(0,(getprop(PitchBars)-getprop(PitchDeg))*-5.711);
        me.Hor.Vbars.setRotation(((getprop(RollBars) or 0)-getprop(RollDeg))*D2R);
      } else me.Hor.Vbars.hide();

      if (getprop(GsInRange) and getprop(InRange) and !getprop("/gear/gear[1]/wow")) {
        me.Hor.GsScale.show();
        gs_defl = math.clamp(getprop(GsDefl),-1.25,1.25);
        me.Hor.GsIls.setTranslation(0,gs_defl* -115);
        me.Hor.LocScale.show();
        loc_defl = math.clamp(getprop(PfdOffset), -2.5, 2.5);
        me.Hor.LocDefl.setTranslation(loc_defl * 45, 0);
      } else {
        me.Hor.GsScale.setVisible(getprop(SgTest));
        me.Hor.LocScale.setVisible(getprop(SgTest));
      }
    } else {
      me.Fail.AttFail.show();
      me.Fail.HorizScale.hide();
      me.Fail.HorizGnd.hide();
    }

  }, # end of update_HOR

  update_SPD : func {
    if (!me.madc_enabled) return;
    else {
      if (fms or getprop(SpdCtrl)) {
        me.Spd.TgSpd.show();
        if (getprop(AltFt)  <= 30650) {
          me.Spd.TgSpd.setText(sprintf("%.0f",getprop(SpdTgKt)));
        } else me.Spd.TgSpd.setText(sprintf("%.2f",getprop(SpdTgMc)));
      } else me.Spd.TgSpd.hide();
      ias = getprop(Ias);
      ias_corr = int(roundToNearest(ias/10,0.1));
      me.Spd.CurSpd.setText(sprintf("%02i",ias_corr));
      me.Spd.CurSpdTen.setTranslation(0,(sprintf("%.2f",math.fmod(ias,10))* 32));
#      me.Spd.CurSpdTen.setTranslation(0,(roundToNearest(math.fmod(ias,10),0.1)* 32));
      me.Spd.SpdTape.setTranslation(0,ias * 5.143);
      me.Spd.Vmo.setTranslation(0,(ias-(getprop(Vne) or 0)) * 5.143);
      if (!wow) {
        me.Spd.Vstall.setTranslation(0,(getprop(StallDiff) or 0) * -5.143);
        me.Spd.Vstall.show();
      } else me.Spd.Vstall.hide();

      n=0;
      foreach (var v;["V1","V2","VR","VA","VE","Vref","VF"]) {
        if (v == "VF") spd = me.SpdVal[n];
        else spd = getprop(me.SpdVal[n]);
        v_dis = ias-spd > 0 ? 0 : 1;
        if (abs(ias-spd) < 38) {
          if (v == "VA" or v == "VE" or v == "Vref" or v== "VF") {
            if (wow) {me.SpdInks[n].hide(); me.SpdInks[7].hide()}
            else {
              me.SpdInks[n].setTranslation(0,(ias-spd) * 5.143).show();
              me.SpdInks[7].show();
            }
          } else me.SpdInks[n].setTranslation(0,(ias-spd) * 5.143)
                              .setVisible(v_dis);
        } else {me.SpdInks[n].hide();me.SpdInks[7].hide()}
        n+=1;
      }

      vne = getprop(Vne) ? getprop(Vne) : 210;
      if (ias > vne) me.Spd.IasBg.setColorFill(1,0,0);
      else me.Spd.IasBg.setColorFill(0,0,0);

      ### Speed Trend (look ahead 6s) ###
      spd_trend = 6 * (getprop(SpdTrd) or 0);
      spd_trend = math.clamp(spd_trend, -228, 228);
      me.SpdTrend.reset();
      me.SpdTrend.rect(180,338,12,-spd_trend);              

      ### V markers ###
      if (ias < 30) {    
        v_ind = 1;
        me.Spd.Ind1.setText(sprintf("%.0f",getprop(V1)));
        me.Spd.Ind2.setText(sprintf("%.0f",getprop(V2)));
        me.Spd.IndE.setText(sprintf("%.0f",getprop(VE)));
        me.Spd.IndR.setText(sprintf("%.0f",getprop(VR)));
      } else v_ind = 0;
      me.Spd.BottomRect.setVisible(v_ind);
      me.Spd.ER21.setVisible(v_ind);
      me.Spd.Ind1.setVisible(v_ind);
      me.Spd.Ind2.setVisible(v_ind);
      me.Spd.IndR.setVisible(v_ind);
      me.Spd.IndE.setVisible(v_ind);

      ### Mach ###
      me.Txt.McVal.setText(sprintf("%.3f",getprop(Mach))~" M");
    }
  }, # end of update_SPD

  update_HSI : func {
    hdg = getprop(Heading);
    hdg_bug = geo.normdeg180(getprop(PfdHdg) - hdg);
    setprop(PfdHdgErr,hdg_bug);
    crs_offset = getprop(PfdOffset) or 0;
    me.Hsi.To.setVisible(to_flag and !fms and !pfd_hsi);
    me.Hsi.From.setVisible(from_flag and !fms and !pfd_hsi);
    me.Hsi1.To1.setVisible(to_flag and !fms and pfd_hsi);
    me.Hsi1.From1.setVisible(from_flag and !fms and pfd_hsi);
    if (getprop(FpActive) and nav_src == "FMS") {
      crs_defl = getprop(crsDefl_fms);
      dst = getprop("instrumentation/gps/wp/wp[1]/distance-nm");
      nav_id = getprop("instrumentation/gps/wp/wp[1]/ID");
      sgnl = "FMS"~(fms_num+1);
    } else {
#      crs_defl = getprop(NavInRange[nav_num]) ? getprop(crsDefl_nav[nav_num]) : -10;
      crs_defl = getprop(crsDefl_nav[nav_num]) or -10;
      sgnl = getprop(NavData[nav_num]) ? "VOR"~(nav_num+1) : "?";
      if(getprop("instrumentation/nav["~nav_num~"]/nav-loc")) sgnl="LOC"~(nav_num+1);
      if(getprop("instrumentation/nav["~nav_num~"]/has-gs")) sgnl="ILS"~(nav_num+1);       
      nav_id = getprop("instrumentation/nav["~nav_num~"]/nav-id");
      crs_defl = math.clamp(crs_defl,-10,10);
      dst = getprop(NavId[nav_num]) ? getprop(NavDist[nav_num])*0.000539 : 0;
    }
    me.Txt.NavType.setText(sgnl);
    setprop(NavTyp,sgnl);
    me.Txt.NavId.setText(nav_id ? nav_id : "?");
    me.Txt.NavDst.setText(nav_id ? sprintf("%.1f",dst)~" NM" : "--- NM");
    me.Txt.Ptr1Txt.setText(me.Nav1Ptr[getprop(Nav1Sel)])
                  .setVisible(disp_cont);
    me.Txt.Ptr1Ind.setVisible(getprop(Nav1Sel) and disp_cont);
    me.Txt.Ptr2Txt.setText(me.Nav2Ptr[getprop(Nav2Sel)])
                  .setVisible(disp_cont);
    me.Txt.Ptr2Ind.setVisible(getprop(Nav2Sel) and disp_cont);
    if (me.atthdg_enabled and me.atthdgAux_enabled) { # attHdg-attHdgAux fuses
      me.Fail.HdgFail.setVisible(getprop(SgTest));
      me.Fail.HdgFailCross.setVisible(getprop(SgTest));
      me.Fail.HdgFailCross1.setVisible(getprop(SgTest));
      if (!pfd_hsi) { # Button PFD HSI
        me.Hsi.Rose.setRotation(-hdg * D2R);
        me.Hsi.HdgBug.setRotation(hdg_bug * D2R);
        me.Hsi.CrsNeedle.setRotation(crs_offset * D2R).show();
        me.Hsi.scale.setRotation(crs_offset * D2R).show();
        me.Hsi.CrsDeflect.setTranslation(crs_defl * 10.5,0);
        ### Vor Adf Fms ###
        me.Hsi.Ptr1.setRotation((getprop(Nav1Val) or 0) * D2R);
        me.Hsi.Ptr2.setRotation((getprop(Nav2Val) or 0) * D2R);
      } else {
        me.Hsi1.Rose1.setRotation(-hdg * D2R);
        me.Hsi1.HdgBug1.setRotation(hdg_bug * D2R);
        me.Hsi1.CrsNeedle1.setRotation(crs_offset * D2R).show();
        me.Hsi1.scale1.setRotation(crs_offset * D2R).show();
        me.Hsi1.CrsDeflect1.setTranslation(crs_defl * 10.5,0);
        me.Hsi1.ArrowL.setVisible(hdg_bug < -53);
        me.Hsi1.ArrowR.setVisible(hdg_bug > 53);
        ### Vor Adf Fms ###
        me.Hsi1.Ptr11.setRotation((getprop(Nav1Val) or 0) * D2R);
        me.Hsi1.Ptr21.setRotation((getprop(Nav2Val) or 0) * D2R);
      }
      me.Hsi.COMPASS.setVisible(!pfd_hsi);
      me.Hsi1.COMPASS1.setVisible(pfd_hsi);
      if (getprop(Nav1Sel)) {
        if (pfd_hsi) {me.Hsi.Ptr1.hide();me.Hsi1.Ptr11.show()}
        else {me.Hsi.Ptr1.show();me.Hsi1.Ptr11.hide()}
      } else {me.Hsi.Ptr1.hide();me.Hsi1.Ptr11.hide()}
      if (getprop(Nav2Sel)) {
        if (pfd_hsi) {me.Hsi.Ptr2.hide();me.Hsi1.Ptr21.show()}
        else {me.Hsi.Ptr2.show();me.Hsi1.Ptr21.hide()}
      } else {me.Hsi.Ptr2.hide();me.Hsi1.Ptr21.hide()}
    } else {    # atthdg (IAC) fail
      me.Fail.HdgFail.show();
      if (!pfd_hsi) {
        me.Fail.HdgFailCross.show();
        me.Fail.HdgFailCross1.setVisible(getprop(SgTest));
        me.Hsi.Ptr1.hide();
        me.Hsi.Ptr2.hide();
        me.Hsi.CrsNeedle.hide();
      } else {
        me.Fail.HdgFailCross1.show();
        me.Fail.HdgFailCross.setVisible(getprop(SgTest));
        me.Hsi1.Ptr11.hide();
        me.Hsi1.Ptr21.hide();
        me.Hsi1.CrsNeedle1.hide();
      }
    }
  }, # end of update_HSI

  update_VSP : func {
    v_spd = getprop(Vert_spd) or 0;
    me.Vspd.VSpdVal.setText(sprintf("%+.0f",v_spd)).setVisible(me.madc_enabled);
    me.Vspd.Arrow.setRotation(v_spd * 0.0188 * D2R).setVisible(me.madc_enabled);
    me.Vspd.VSpdInd.setVisible(me.madc_enabled);
  }, # end of update_VSP

  update_Markers : func {
    me.Txt.MarkerO.setVisible(getprop(Marker_o) or getprop(SgTest));
    me.Txt.MarkerM.setVisible(getprop(Marker_m));
    me.Txt.MarkerI.setVisible(getprop(Marker_i));
  },

  update_Iac : func {
    if (!getprop(Iac[0])) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG2")}
    else if (!getprop(Iac[1])) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG1")}
    else {
      if (getprop(SgRev) == 0) me.Sg.sg.setVisible(getprop(SgTest));
      if (getprop(SgRev) == -1) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG1")}
      if (getprop(SgRev) == 1) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG2")}
    }
  },
  
}; # end of PFDDisplay

###### Main #####
var pfd_setl = setlistener("sim/signals/fdm-initialized", func() {
  var pfd = PFDDisplay.new();
  pfd.listen();
  pfd.update_PFD();
	print('PFD Canvas ... Ok');
	removelistener(pfd_setl); 
},0,0);




#==========================================================
# Citation X - PFD Canvas
# Christian Le Moigne (clm76) Feb 2019
# =========================================================

var AltDiff = "instrumentation/pfd/target-altitude-diff";
var AltFt = "/instrumentation/altimeter/indicated-altitude-ft";
var AltMeters = "/instrumentation/efis/alt-meters";
var AltTrd = "/instrumentation/pfd/alt-trend-ft";
var ApAlt = "/autopilot/locks/altitude";
var ApHarmed = "/autopilot/locks/heading-arm";
var ApHeading = "/autopilot/locks/heading";
var ApStatus = "/autopilot/locks/AP-status";
var ApVarmed = "/autopilot/locks/altitude-arm";
var Asel = "/autopilot/settings/asel";
var Baro = "/instrumentation/altimeter/setting-inhg";
var BaroMode = "/instrumentation/efis/baro-hpa";
var CrsOffset = "/autopilot/internal/course-offset";
var CrsDefl = "/autopilot/internal/course-deflection";
var DmeDst = ["/instrumentation/dme/indicated-distance-nm",
              "/instrumentation/dme[1]/indicated-distance-nm"];
var DmeID = ["/instrumentation/dme/dme-id",
             "/instrumentation/dme[1]/dme-id"];
var DmeIR = ["/instrumentation/dme/in-range",
             "/instrumentation/dme[1]/in-range"];
var FmsAltDsp = "/autopilot/settings/target-altitude-ft";
var GsDefl = "/autopilot/internal/gs-deflection";
var GsInRange = "/autopilot/internal/gs-in-range";
var Hdg = "/autopilot/settings/heading-bug-deg";
var Heading = "/orientation/heading-deg";
var HeadingBug = "/autopilot/internal/heading-bug-error-deg";
var Ias = "/instrumentation/airspeed-indicator/indicated-speed-kt";
var InRange = "/autopilot/internal/in-range";
var InRange = "/autopilot/internal/in-range";
var LocDefl = "/autopilot/internal/heading-deflection-deg";
var Mach = "/velocities/mach";
var Marker_i = "/instrumentation/marker-beacon/inner";
var Marker_m = "/instrumentation/marker-beacon/middle";
var Marker_o = "/instrumentation/marker-beacon/outer";
var MinDiff = "/instrumentation/pfd/minimum-diff";
var MinimumsMode = "/autopilot/settings/minimums-mode";
var MinimumsValue = "/autopilot/settings/minimums";
var NavFrom = "/autopilot/locks/from-flag";
var NavDist = "/autopilot/internal/nav-distance";
var NavId = "/autopilot/internal/nav-id";
var Nav1Ptr = "/autopilot/internal/nav1-pointer";
var Nav2Ptr = "/autopilot/internal/nav2-pointer";
var NavPtr1 = "/instrumentation/primus2000/sc840/nav1ptr";
var NavPtr2 = "/instrumentation/primus2000/sc840/nav2ptr";
var NavSrc = "/autopilot/settings/nav-source";
var NavType = "/autopilot/internal/nav-type";
var PfdHsi = "/instrumentation/primus2000/dc840/pfd-hsi";
var pitch = "/orientation/pitch-deg";
var PitchBars = "/autopilot/internal/pitch-bars";
var PitchDeg = "/orientation/pitch-deg";
var roll =  "/orientation/roll-deg";
var RollBars = "/autopilot/internal/roll-bars";
var RollDeg = "/orientation/roll-deg";
var SelAlt = "/autopilot/settings/altitude-setting-ft";
var SelCrs = "/autopilot/settings/selected-crs";
var SelHdg = "/autopilot/settings/heading-bug-deg";
var Sg = "/instrumentation/eicas/sg-rev";
var SpdTgKt = "/autopilot/settings/target-speed-kt";
var SpdTrd = "/instrumentation/pfd/speed-trend-kt";
var StallDiff = "/instrumentation/pfd/stall-diff";
var V1 = "/controls/flight/v1";
var V2 = "/controls/flight/v2";
var VA = "/controls/flight/va";
var VE = "/controls/flight/ve";
var VR = "/controls/flight/vr";
var Vf = "/controls/flight/flaps-select";
var Vne = "/instrumentation/pfd/max-airspeed-kts";
var Vref = "/controls/flight/vref";
var Vspd = "/autopilot/internal/vert-speed-fpm";
var alt = nil;
var alt_corr = nil;
var alt_diff = nil;
var alt_trend = nil;
var crs_offset = nil;
var dme_ind = nil;
var hdg = nil;
var hdg_bug = nil;
var ias = nil;
var ias_corr = nil;
var loc_defl = nil;
var min_diff = nil;
var n = nil;
var pfd_hsi = 0;
var spd_trend = nil;
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

	new: func(x) {
		var m = {parents: [PFDDisplay]};
    var font_mapper = func (family, weight) {
      if (weight == "bold") return "LiberationFonts/LiberationSans-Bold.ttf";
      else return "LiberationFonts/LiberationSansNarrow-Bold.ttf";
		}
    if(!x) {
	    m.canvas = canvas.new({
		    "name": "PFD_L", 
		    "size": [1024, 1024],
		    "view": [900, 1024],
		    "mipmapping": 1 
	    });
	    m.canvas.addPlacement({"node": "screenL"});
    } else {
	    m.canvas = canvas.new({
		    "name": "PFD_R", 
		    "size": [1024, 1024],
		    "view": [900, 1024],
		    "mipmapping": 1 
	    });
	    m.canvas.addPlacement({"node": "screenR"});
    }
	    m.pfd = m.canvas.createGroup();
		  canvas.parsesvg(m.pfd, "/Models/Instruments/PFD/PFD.svg", {'font-mapper': font_mapper});

    m.AltTrend = m.pfd.createChild("path");
    m.AltTrend.setColorFill(me.COLORS.magenta);

    m.Alt = {};
    m.Alt_keys = ["Alt11100","AltTape","AltLadder","BAROtext",
                  "AltSelText","AltSel00","MinMode","MinValue",
                  "MinBug","AltBug"];
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
                  "Ind1","Ind2","IndR","IndE"];
    foreach(var i;m.Spd_keys) m.Spd[i] = m.pfd.getElementById(i);

    m.Hsi = {};
    m.Hsi_keys = ["Rose","Ptr1","Ptr2","CrsDeflect","CrsNeedle",
                  "HdgBug","To","From","COMPASS","Lh","Lb","Fl"];
    foreach(var i;m.Hsi_keys) m.Hsi[i] = m.pfd.getElementById(i);

    m.Hsi1 = {};
    m.Hsi1_keys = ["Rose1","Ptr11","Ptr21","CrsDeflect1","CrsNeedle1",
                  "HdgBug1","To1","From1","COMPASS1","ArrowL","ArrowR",
                  "Lh1","Lb1","Fl1"];
    foreach(var i;m.Hsi1_keys) m.Hsi1[i] = m.pfd.getElementById(i);

    m.Txt = {};
    m.Txt_keys = ["NavType","NavId","NavDst","Ptr1Ind","Ptr1Txt",
                  "Ptr2Ind","Ptr2Txt","HdgVal","DtkVal","McVal",
                  "AltMet","ApStat","ApVert","ApLat","ApVarm",
                  "ApLarm","MarkerI","MarkerM","MarkerO","Dme","DmeId",
                  "DmeDist","FmsAlt"];
    foreach(var i;m.Txt_keys) m.Txt[i] = m.pfd.getElementById(i);

    m.Vspd = {};
    m.Vspd_keys = ["Arrow","VSpdVal"];
    foreach(var i;m.Vspd_keys) m.Vspd[i] = m.pfd.getElementById(i);
    m.Vspd.Arrow.setCenter(900,792);

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

    m.sgTxt = m.pfd.getElementById("sgTxt");
    m.sgCdr = m.pfd.getElementById("sgCdr");

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
    
    return m;
  }, # end of new

  listen : func(x) {
		setlistener(MinimumsMode, func(n) {	
			me.Alt.MinMode.setText(n.getValue());
		},1,0);

		setlistener(MinimumsValue, func(n) {	
			me.Alt.MinValue.setText(sprintf("%.0f",n.getValue()));
		},1,0);

		setlistener(Baro, func {
      if (getprop(BaroMode)) me.Alt.BAROtext.setText(sprintf("%.2f", getprop("instrumentation/altimeter/setting-inhg")));
      else me.Alt.BAROtext.setText(sprintf("%.0f", getprop("instrumentation/altimeter/setting-hpa")));
		},1,0);

		setlistener(BaroMode, func(n) {
      if (n.getValue()) me.Alt.BAROtext.setText(sprintf("%.2f", getprop("instrumentation/altimeter/setting-inhg")));
      else me.Alt.BAROtext.setText(sprintf("%.0f", getprop("instrumentation/altimeter/setting-hpa")));
		},1,0);

		setlistener(Asel, func(n) {
      me.Alt.AltSelText.setText(sprintf("%.0f",n.getValue()));
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

		setlistener(NavFrom, func(n) {
      if (!pfd_hsi) {
        me.Hsi.To.setVisible(!n.getValue());
        me.Hsi.From.setVisible(n.getValue());
      } else {
        me.Hsi1.To1.setVisible(!n.getValue());
        me.Hsi1.From1.setVisible(n.getValue());
      }
    },1,0);

		setlistener(NavType, func(n) {
      me.Txt.NavType.setText(n.getValue());
    },1,0);

		setlistener(NavId, func(n) {
      me.Txt.NavId.setText(n.getValue());
    },1,0);

		setlistener(NavPtr1, func(n) {
      me.Txt.Ptr1Txt.setText(me.Nav1Ptr[n.getValue()]);
      me.Txt.Ptr1Ind.setVisible(n.getValue());
      if (n.getValue()) {
        if (getprop(PfdHsi)) {me.Hsi.Ptr1.hide();me.Hsi1.Ptr11.show()}
        else {me.Hsi.Ptr1.show();me.Hsi1.Ptr11.hide()}
      } else {me.Hsi.Ptr1.hide();me.Hsi1.Ptr11.hide()}
    },1,0);

		setlistener(NavPtr2, func(n) {
      me.Txt.Ptr2Txt.setText(me.Nav2Ptr[n.getValue()]);
      me.Txt.Ptr2Ind.setVisible(n.getValue());
      if (n.getValue()) {
        if (getprop(PfdHsi)) {me.Hsi.Ptr2.hide();me.Hsi1.Ptr21.show()}
        else {me.Hsi.Ptr2.show();me.Hsi1.Ptr21.hide()}
      } else {me.Hsi.Ptr2.hide();me.Hsi1.Ptr21.hide()}
    },1,0);

		setlistener(SelCrs, func(n) {
      me.Txt.DtkVal.setText(sprintf("%03i",n.getValue()));
    },1,0);

		setlistener(Hdg, func(n) {
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

		setlistener(PfdHsi, func(n) {
      me.Hsi.COMPASS.setVisible(!n.getValue());
      me.Hsi1.COMPASS1.setVisible(n.getValue());
      pfd_hsi = n.getValue();
    },1,0);

		setlistener(NavSrc, func(n) {
      if (left(n.getValue(),3) != "FMS") {
        me.Hsi.CrsNeedle.setColor(me.COLORS.green);
        me.Hsi.Fl.setColorFill(me.COLORS.green);
        me.Hsi.To.setColorFill(me.COLORS.green);
        me.Hsi.From.setColorFill(me.COLORS.green);
        me.Hsi1.CrsNeedle1.setColor(me.COLORS.green);
        me.Hsi1.Fl1.setColorFill(me.COLORS.green);
        me.Hsi1.To1.setColorFill(me.COLORS.green);
        me.Hsi1.From1.setColorFill(me.COLORS.green);
      } else {
        me.Hsi.CrsNeedle.setColor(me.COLORS.magenta);
        me.Hsi.Fl.setColorFill(me.COLORS.magenta);
        me.Hsi.To.setColorFill(me.COLORS.magenta);
        me.Hsi.From.setColorFill(me.COLORS.magenta);
        me.Hsi1.CrsNeedle1.setColor(me.COLORS.magenta);
        me.Hsi1.Fl1.setColorFill(me.COLORS.magenta);
        me.Hsi1.To1.setColorFill(me.COLORS.magenta);
        me.Hsi1.From1.setColorFill(me.COLORS.magenta);
      }
    },1,0);

    setlistener(Sg, func(n) {
      if (n.getValue() == 0) {me.sgTxt.hide();me.sgCdr.hide()}
      else {
        if (n.getValue() == -1) me.sgTxt.setText("SG1").show();
        if (n.getValue() == 1) me.sgTxt.setText("SG2").show();
        me.sgCdr.show();
      }
    },1,0);

  }, # end of listen

  update_PFD : func(x) {
    me.update_ALT();
    me.update_HOR();
    me.update_SPD();
    me.update_HSI();
    me.update_VSP();
    me.update_DME();
    me.update_Markers();
		settimer(func {me.update_PFD(x);},0.1);
  }, # end of update_PFD

  update_ALT : func {
    alt = getprop(AltFt);
    alt_corr = int(roundToNearest(alt/100,0.1));
    me.Alt.Alt11100.setText(sprintf("%03.0f",alt_corr));
		me.Alt.AltTape.setTranslation(0,alt*0.284);
    me.Alt.AltLadder.setTranslation(0,math.fmod(alt,100) * 1.24);

    ### Altitude Diff ###
    alt_diff = -0.280 * (getprop(AltDiff) or 0);
    alt_diff = math.clamp(alt_diff,-170,170);
		me.Alt.AltBug.setTranslation(0,alt_diff);

    ### Altitude Trend (look ahead 6s) ###
    alt_trend = 0.36 * (getprop(AltTrd) or 0);
    alt_trend = math.clamp(alt_trend, -225, 225);
    me.AltTrend.reset();
    me.AltTrend.rect(705,338,12,-alt_trend);              

    ### Minimums ###
    min_diff = getprop(MinDiff) or 0;
    me.Alt.MinBug.setColor(min_diff > 0 ? me.COLORS.orange : me.COLORS.green);
    me.Alt.MinBug.setTranslation(0, min_diff * -0.174);
    if (min_diff <= -600) me.Alt.MinBug.hide();
    else me.Alt.MinBug.show();

    ### Alt Meters ###
    if (getprop(AltMeters)) {
      me.Txt.AltMet.setText(sprintf("%03i",alt*0.3048)~"M").show();
    } else me.Txt.AltMet.hide();

    ### Fms Target Altitude ###
    if (getprop(NavSrc) == "FMS1" or getprop(NavSrc) == "FMS2") {
        me.Txt.FmsAlt.setText(sprintf("%.0f",getprop(FmsAltDsp))).show();
    } else me.Txt.FmsAlt.hide();

  }, # end of update_ALT

  update_HOR : func {
		me.h_trans.setTranslation(0,getprop(pitch)*7.5);
		me.h_rot.setRotation(-getprop(roll)*D2R,me.Hor.Horizon.getCenter());
    me.Hor.BankPtr.setRotation(-getprop(roll)*D2R);
    if (getprop("/autopilot/internal/show-bars")) {
      me.Hor.Vbars.show();
      me.Hor.Vbars.setTranslation(0,(getprop(PitchBars)-getprop(PitchDeg))*-5.711);
      me.Hor.Vbars.setRotation((getprop(RollBars)-getprop(RollDeg))*D2R);
    } else me.Hor.Vbars.hide();

    if (getprop(GsInRange) and getprop(InRange) and !getprop("/gear/gear[1]/wow")) {
      me.Hor.GsScale.show();
      me.Hor.GsIls.setTranslation(0,getprop(GsDefl)*0.7 * -115);
      me.Hor.LocScale.show();
      loc_defl = math.clamp(getprop(LocDefl), -1.25, 1.25);
      me.Hor.LocDefl.setTranslation(loc_defl * 90, 0);
    } else {me.Hor.GsScale.hide();me.Hor.LocScale.hide()}

  }, # end of update_HOR

  update_SPD : func {
    if ((getprop("/autopilot/locks/altitude") == "FLC" or getprop("/autopilot/locks/altitude") == "VFLC" or getprop("/autopilot/settings/fms") or getprop("/autopilot/locks/speed")) and getprop("instrumentation/altimeter/indicated-altitude-ft") <= 30650) {
      me.Spd.TgSpd.show();
      me.Spd.TgSpd.setText(sprintf("%.0i",getprop(SpdTgKt)));
    } else me.Spd.TgSpd.hide();
    ias = getprop(Ias);
    ias_corr = int(roundToNearest(ias/10,0.1));
    me.Spd.CurSpd.setText(sprintf("%02i",ias_corr));
    me.Spd.CurSpdTen.setTranslation(0,(math.fmod(ias,10)* 32));
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
            me.SpdInks[7].setTranslation(0,(ias-spd) * 5.143).show();
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

  }, # end of update_SPD

  update_HSI : func {
    hdg = getprop(Heading) or 0;
    hdg_bug = getprop(HeadingBug) or 0;
    crs_offset = getprop(CrsOffset) or 0;
    if (!pfd_hsi) {
      me.Hsi.Rose.setRotation(-hdg * D2R);
      me.Hsi.HdgBug.setRotation(hdg_bug * D2R);
      me.Hsi.CrsNeedle.setRotation(crs_offset * D2R);
      me.Hsi.CrsDeflect.setTranslation(getprop(CrsDefl) * 10.5,0);
      ### Vor Adf Fms ###
      me.Hsi.Ptr1.setRotation((getprop(Nav1Ptr) or 0) * D2R);
      me.Hsi.Ptr2.setRotation((getprop(Nav2Ptr) or 0) * D2R);
    } else {
      me.Hsi1.Rose1.setRotation(-hdg * D2R);
      me.Hsi1.HdgBug1.setRotation(hdg_bug * D2R);
      me.Hsi1.CrsNeedle1.setRotation(crs_offset * D2R);
      me.Hsi1.CrsDeflect1.setTranslation(getprop(CrsDefl) * 10.5,0);
      me.Hsi1.ArrowL.setVisible(hdg_bug < -53);
      me.Hsi1.ArrowR.setVisible(hdg_bug > 53);
      ### Vor Adf Fms ###
      me.Hsi1.Ptr11.setRotation((getprop(Nav1Ptr) or 0) * D2R);
      me.Hsi1.Ptr21.setRotation((getprop(Nav2Ptr) or 0) * D2R);
    }
      me.Txt.NavDst.setText(sprintf("%.1f",getprop(NavDist))~" NM");

  }, # end of update_HSI

  update_VSP : func {
    v_spd = getprop(Vspd) or 0;
    me.Vspd.VSpdVal.setText(sprintf("%+.0f",v_spd));
    me.Vspd.Arrow.setRotation(v_spd * 0.0188 * D2R);
  }, # end of update_VSP

  update_DME : func {
    if (getprop(NavSrc) == "NAV1" and getprop(DmeID[0]) != "") {
      me.Txt.Dme.show();
      me.Txt.DmeId.setText(getprop(DmeID[0]));
      if (getprop(DmeIR[0]) > 0) {
        me.Txt.DmeDist.setText(sprintf("%.1f",getprop(DmeDst[0]))~" NM");
      } else me.Txt.DmeDist.setText("--- NM");
    } else if (getprop(NavSrc) == "NAV2" and getprop(DmeID[1]) != "") {
      me.Txt.Dme.show();
      me.Txt.DmeId.setText(getprop(DmeID[1]));
      if (getprop(DmeIR[1]) > 0) {
        me.Txt.DmeDist.setText(sprintf("%.1f",getprop(DmeDst[1]))~" NM");
      } else me.Txt.DmeDist.setText("--- NM");
    } else me.Txt.Dme.hide();
  }, # end of update_DME

  update_Markers : func {
    me.Txt.MarkerO.setVisible(getprop(Marker_o));
    me.Txt.MarkerM.setVisible(getprop(Marker_m));
    me.Txt.MarkerI.setVisible(getprop(Marker_i));
  },

}; # end of PFDDisplay

###### Main #####
var pfd_setl = setlistener("sim/signals/fdm-initialized", func() {
  for (var x=0;x<2;x+=1) {
    var pfd = PFDDisplay.new(x);
    pfd.listen(x);
    pfd.update_PFD(x);
  }
	print('PFD Canvas ... Ok');
	removelistener(pfd_setl); 
},0,0);




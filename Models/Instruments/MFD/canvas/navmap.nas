# Copyright 2018 Stuart Buchanan
# This file is part of FlightGear.
#
# FlightGear is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# FlightGear is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FlightGear.  If not, see <http://www.gnu.org/licenses/>.
#
#   Navigation Map Functions 
#   Adapted to the Citation X by C. Le Moigne (clm76)  Dec 2018 - jan 2019

var nasal_dir = getprop("/sim/aircraft-dir") ~ "/Models/Instruments/MFD/canvas";
io.load_nasal(nasal_dir ~ '/navmap-styles.nas', "fgMap");
io.include('init.nas');

var hdg = "/orientation/heading-deg";
var hdg_mag = "/orientation/heading-magnetic-deg";
var rangeNm = "instrumentation/mfd/range-nm";
var Iac = ["/systems/electrical/outputs/iac1",
           "/systems/electrical/outputs/iac2"];
var dispCtrl = ["/systems/electrical/outputs/disp-cont1",
                "/systems/electrical/outputs/disp-cont2"];
var SgRev = "/instrumentation/eicas/sg-rev";
var sgTest = "instrumentation/reversionary/sg-test";
var decl_mag = "environment/magnetic-variation-deg";
var Hdg = nil;
var HdgBug = nil;
var HdgVis = nil;
var Range = nil;
var Tcas = nil;
var El_tcas = nil;
var AltDiff = nil;
var AltRange = nil;
var AltRangePx = nil;
var Vspd = nil;
var GndSpd = nil;
var source = nil;
var Tfc = [0,0];
var aircraft_heading = 0;

var NavMap = {
  # ENABLE - only create the map element when the page becomes visible,
  # and delete afterwards.
  ENABLE : 1,

  # Layer display configuration:
  # enabled   - whether this layer has been enabled by the user
  # declutter - the maximum declutter level (0-3) that this layer is visible in
  # range     - the maximum range this layer is visible (configured by user)
  # max_range - the maximum range value that a user can configure for this layer.
  # static - whether this layer should be displayed on static maps (as opposed to the moving maps)
  # factory - name of the factory to use for creating the layer
  # priority - layer priority

  layerRanges : {
    DME  : { enabled: 1, declutter: 3, range: 20, max_range: 80, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    VOR_cit  : { enabled: 1, declutter: 1, range: 80, max_range: 160, static : 1, factory : canvas.SymbolLayer, priority : 4, vis : 1},
    NDB_cit  : { enabled: 1, declutter: 1, range: 40, max_range: 80, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    FIX  : { enabled: 1, declutter: 1, range: 10, max_range: 30, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    RTE  : { enabled: 1, declutter: 3, range: 2000, max_range: 2000, static : 1, factory : canvas.SymbolLayer, priority : 2, vis :1},
    WPT_cit  : { enabled: 1, declutter: 3, range: 2000, max_range: 2000, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    FLT  : { enabled: 1, declutter: 4, range: 2000, max_range: 2000, static : 1, factory : canvas.SymbolLayer, priority : 3, vis :0},
    WXR  : { enabled: 1, declutter: 2, range: 2000, max_range: 2000, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    APT_cit  : { enabled: 1, declutter: 3, range: 80, max_range: 80, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    TFC  : { enabled: 1, declutter: 3, range: 160, max_range: 2000, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    APS  : { enabled: 1, declutter: 3, range: 2000, max_range: 2000, static : 1,  factory : canvas.SymbolLayer, priority : 4, vis :1},
    STAMEN_terrain  : { enabled: 1, declutter: 3, range: 500, max_range: 2000, static : 1, factory : canvas.OverlayLayer, priority : 1, vis :0},
    OpenAIP : { enabled: 1, declutter: 1, range: 80, max_range: 150, static : 1, factory : canvas.OverlayLayer, priority : 1, vis :0},
    STAMEN  : { enabled: 1, declutter: 3, range: 500, max_range: 2000, static : 1, factory : canvas.OverlayLayer, priority : 1, vis :0},
  },

  new : func {
    var m = {parents : [NavMap],
      center : [450,475], #old 450,475
      zoom : 20,
      mp : nil,
      plan : nil,
      layerRan : {},
      vor : 0,
      apt : 0,
      fix : 0,
      wxr : 0,
      ndb : 0,
      white : [1,1,1],
      amber : [0.9,0.5,0],
    };

	  m.canvas = canvas.new({
		  "name": "ND", 
		  "size": [1024, 1024],
		  "view": [900, 1024],
		  "mipmapping": 1 
	  });
	  m.canvas.addPlacement({"node": "screen_B"});
  	m.nd = m.canvas.createGroup();
	  canvas.parsesvg(m.nd, get_local_path("Images/nd-back.svg"));

    m.layer = {};
    m.layer_val = ["layerMap","layerPlan"];
		foreach(var element;m.layer_val) {
			m.layer[element] = m.nd.getElementById(element);
		}
    m.layer.layerMap.setTranslation(m.center[0], m.center[1]).hide();
    m.layer.layerPlan.show();

    m.symbols = {};
		foreach(var element;["hsi","compass","hdgIndex","hdgBug",
				                "arrowL","arrowR","rangeL","rangeLtxt",
									      "rangeR","rangeRtxt","hdgLine",
										    "tcasLabel","tcasValue","tfcRangeInt",
                        "altArc","traffic"]) 
			m.symbols[element] = m.nd.getElementById(element);

    m.Sg = {};
    foreach(var element;["sg","sgTxt","sgCdr"]) 
      m.Sg[element] = m.nd.getElementById(element);
    m.Sg.sg.hide();

    m.Styles = fgMap.NavMapStyles.new();

    foreach (var i; keys(NavMap.layerRanges)) {
      m.layerRan[i] = NavMap.layerRanges[i];
    }

    if (NavMap.ENABLE == 1) {
      m.createMapElement();
      m.animateSymbols();
    }

    return m;
  }, # end of new

  createMapElement : func {
    if (me.mp != nil) return;
    me.mp = me.layer.layerMap.createChild("map");
    me.mp.setScreenRange(277);
    me.plan = me.layer.layerPlan.createChild("map");
    me.plan.setScreenRange(360);

    # Initialize the controllers:
    var ctrl_ns = canvas.Map.Controller.get("Aircraft position");
    source = ctrl_ns.SOURCES["current-pos"] = {
      getPosition: func subvec(geo.aircraft_position().latlon(), 0, 2),
      getAltitude: func getprop('/position/altitude-ft'),
      getHeading: func {me.aircraft_heading ? getprop(hdg) : 0},
      aircraft_heading: 1
    };

      # Make it move with our aircraft:
      me.mp.setController("Aircraft position", "current-pos"); # from aircraftpos.controller
      me.plan.setController("Aircraft position", "current-pos");

    foreach (var layer_name; me.getLayerNames()) {
      var layer = me.getLayer(layer_name);
      if (layer.static == 1) {
        me.mp.addLayer(
          factory: layer.factory,
          type_arg: layer_name,
          priority: layer.priority,
          style: me.Styles.getStyle(layer_name),
          options: nil,
          visible: 0);
        me.plan.addLayer(
          factory: layer.factory,
          type_arg: layer_name,
          priority: layer.priority,
          style: me.Styles.getStyle(layer_name),
          options: nil,
          visible: 0);
        me.plan.setTranslation(450,475); # old 450,475
      }
    }

    setlistener("instrumentation/dc840/mfd-map", func(n) {
        source.aircraft_heading = n.getValue() ? 0 : 1;
        me.layer.layerPlan.setVisible(!n.getValue());
        me.layer.layerMap.setVisible(n.getValue());
    },0,0);  

    setlistener(rangeNm, func(n) {
      me.setZoom(n.getValue() or 20);
   },1,0);

    setlistener("instrumentation/mfd/outputs/vor", func(n) {
      me.vor = n.getValue();
      me.updateVisibility();
    },0,0);

    setlistener("instrumentation/mfd/outputs/apt", func(n) {
      me.apt = n.getValue();
      me.updateVisibility();
    },0,0);

    setlistener("instrumentation/mfd/outputs/fix", func(n) {
      me.fix = n.getValue();
      me.updateVisibility();
    },0,0);

    setlistener("instrumentation/efis/wxr", func(n) {
      me.wxr = n.getValue();
      me.updateVisibility();
    },0,0);

    setlistener("instrumentation/tcas/tfc", func(n) {
      Tfc = n.getValue();
      if (n.getValue()) setprop("/sim/traffic-manager/enabled",1);
      else if (!Tfc) setprop("/sim/traffic-manager/enabled",0);
      me.updateVisibility();
    },0,0);

    setlistener("instrumentation/pfd/nav1ptr", func(n) {
      if (n.getValue() == 2) me.ndb = 1;
      else me.ndb = 0;
      me.updateVisibility();
    },0,0);

    setlistener("instrumentation/pfd/nav2ptr", func(n) {
      if (n.getValue() == 2) me.ndb = 1;
      else me.ndb = 0;
      me.updateVisibility();
    },0,0);

    setlistener("instrumentation/tcas/outputs/traffic-alert", func (n) {
      me.symbols.traffic.setVisible(n.getValue());
    },1,0);

    setlistener(sgTest, func (n) {
      me.symbols.traffic.setVisible(n.getValue());
    },1,0);

  }, # end of createMapElement

  setZoom : func(zoom) {
    me.mp.setRange(zoom);
    me.plan.setRange(zoom);
    me.updateVisibility();
  },

  updateVisibility : func {
    # Determine which layers should be visible.
    foreach (var layer_name; me.getLayerNames()) {
      var layer = me.getLayer(layer_name);
      if (me.mp.getLayer(layer_name) == nil) continue;

      # Layers are only displayed if:
      # 1) the user has enabled them.
      # 2) The current zoom level is _less than the maximum range for the layer
      #    (i.e. as the range gets larger, we remove layers).  
      if (layer.enabled and me.zoom <= layer.range) {
            me.mp.getLayer(layer_name).setVisible(1);
        if (layer.vis){
          me.plan.getLayer(layer_name).setVisible(1);
          me.mp.getLayer('FIX').setVisible(me.fix);
          me.plan.getLayer('FIX').setVisible(me.fix);
          me.mp.getLayer('VOR_cit').setVisible(me.vor);
          me.plan.getLayer('VOR_cit').setVisible(me.vor);
          me.mp.getLayer('APT_cit').setVisible(me.apt);
          me.plan.getLayer('APT_cit').setVisible(me.apt);
          me.plan.getLayer('DME').setVisible(me.zoom > 80 ? 0 : me.vor);
          me.mp.getLayer('NDB_cit').setVisible(me.ndb);
          me.plan.getLayer('NDB_cit').setVisible(me.ndb);
          me.mp.getLayer('TFC').setVisible(Tfc);
          me.plan.getLayer('TFC').setVisible(Tfc);
          me.mp.getLayer('WXR').setVisible(me.wxr);
          me.plan.getLayer('WXR').setVisible(me.wxr);
        } else me.mp.getLayer(layer_name).setVisible(1);
      } else {
        me.mp.getLayer(layer_name).setVisible(0);
        me.plan.getLayer(layer_name).setVisible(0);
      }
    }
  }, # end of updateVisibility

  getLayerNames : func() {
    return keys(me.layerRan);
  },

  getLayer : func (name) {
    return me.layerRan[name];
  },

  setVisible : func(visible) {
    if (visible) {
      me.mp.setVisible(visible);
      me.plan.setVisible(visible);
    } else {
      if (me.mp != nil) me.mp.setVisible(visible);
      if (me.plan != nil) me.plan.setVisible(visible);
      if (NavMap.ENABLE) me.mp = nil;
      if (NavMap.ENABLE) me.plan = nil;
    }
  },
  
  animateSymbols : func {
    me.update_Iac();
    Hdg = getprop(hdg_mag) or 0;
    HdgBug = getprop("/autopilot/internal/heading-bug-error-deg") or 0;
    Range = getprop(rangeNm) or 20;
    Tcas = getprop("instrumentation/tcas/tfc");
    El_tcas = getprop("systems/electrical/outputs/tcas");
    Vspd = getprop("/velocities/vertical-speed-fps");
    GndSpd = getprop("/velocities/groundspeed-kt");
    hdgVis = (getprop("autopilot/locks/heading")== "ROLL" |
              getprop("autopilot/locks/heading")== "HDG") ? 1 : 0;

    me.symbols.compass.setRotation(-Hdg*D2R);
    me.symbols.hdgBug.setCenter(450,490);    
    me.symbols.hdgBug.setRotation(HdgBug*D2R);
    me.symbols.hsi.setText(sprintf("%03d",Hdg));
    me.symbols.rangeLtxt.setText(sprintf("%d",Range/2));
    me.symbols.rangeRtxt.setText(sprintf("%d",Range/2));
    me.symbols.arrowL.setVisible(HdgBug < -53);
    me.symbols.arrowR.setVisible(HdgBug > 53);
    me.symbols.hdgLine.setCenter(450,490).setVisible(hdgVis);
    me.symbols.hdgLine.setRotation(HdgBug*D2R);
    if (El_tcas) {
      me.symbols.tcasLabel.setColor(me.white);
      me.symbols.tcasValue.setText(Tcas ? "AUTO" : "OFF").setColor(me.white);
      me.symbols.tfcRangeInt.setVisible(Tcas);
    } else {
      me.symbols.tcasLabel.setColor(me.amber);
      me.symbols.tcasValue.setText("FAIL").setColor(me.amber);
      me.symbols.tfcRangeInt.setVisible(Tcas);
    }

    AltDiff = (getprop("autopilot/settings/tg-alt-ft") or 0)-(getprop("instrumentation/altimeter/indicated-altitude-ft") or 0);
		if (abs(Vspd) > 1 and AltDiff/Vspd > 0) {
			AltRange = AltDiff/Vspd*GndSpd*KT2MPS*M2NM;
			if(AltRange > 1) {
				AltRangePx = (350/Range)*AltRange;
				if (AltRangePx > 700) AltRangePx = 700;
				me.symbols.altArc.setTranslation(0,-AltRangePx);
			}
			me.symbols.altArc.show();
		} else me.symbols.altArc.hide();
   settimer(func me.animateSymbols(),0.1);
  }, # end of animateSymbols

  update_Iac : func {
    if (!getprop(Iac[0])) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG2")}
    else if (!getprop(Iac[1])) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG1")}
    else {
      if (getprop(SgRev) == 0) me.Sg.sg.setVisible(getprop(sgTest));
      if (getprop(SgRev) == -1) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG1")}
      if (getprop(SgRev) == 1) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG2")}
    }
  },

}; # end of NavMap

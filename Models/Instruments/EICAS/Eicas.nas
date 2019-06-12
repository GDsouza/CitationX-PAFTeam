#==========================================================
# Citation X - EICAS Canvas 
# Christian Le Moigne (clm76) March 2019
# =========================================================

var Aileron = ["surface-positions/left-aileron-pos-norm",
                "surface-positions/right-aileron-pos-norm"];
var ApuRun = "controls/APU/running";
var Bleed = "controls/APU/bleed";
var Bus = ["systems/electrical/left-bus","systems/electrical/right-bus"];
var Elevator = "surface-positions/elevator-pos-norm";
var Cycle_up = ["engines/engine/cycle-up","engines/engine[1]/cycle-up"];
var Dau = ["instrumentation/eicas/dau1","instrumentation/eicas/dau2"];
var Fadec = ["controls/engines/engine/fadec","controls/engines/engine[1]/fadec"];
var Fan = ["engines/engine/fan","engines/engine[1]/fan"];
var N1 = ["engines/engine/n1","engines/engine[1]/n1"];
var Flaps = "controls/flight/flaps";
var FuelF = ["engines/engine/fuel-flow-pph",
             "engines/engine[1]/fuel-flow-pph"];
var FuelT = "consumables/fuel/total-fuel-lbs";
var Gear = "controls/gear/gear-down";
var Hydr = ["systems/hydraulics/psi-norm",
            "systems/hydraulics/psi-norm[1]"];
var Ignit = ["controls/engines/engine/ignition",
            "controls/engines/engine[1]/ignition"];
var Itt = ["engines/engine/itt-norm",
            "engines/engine[1]/itt-norm"];
var OilP = ["engines/engine/oil-pressure-psi",
            "engines/engine[1]/oil-pressure-psi"];
var OilT = ["engines/engine/oilt-norm",
            "engines/engine[1]/oilt-norm"];
var Rat = "environment/temperature-degc";
var Rev = ["controls/engines/engine/reverser",
            "controls/engines/engine[1]/reverser"];
var Rudder = "surface-positions/rudder-pos-norm";
var Sg = "instrumentation/eicas/sg-rev";
var SpdBrakes = "controls/flight/speedbrake";
var Stab = "controls/flight/elevator-trim";
var Sync = "controls/engines/synchro";
var Throt = ["controls/engines/engine/throttle",
            "controls/engines/engine[1]/throttle"];
var TkLvl = ["consumables/fuel/tank/level-lbs",
             "consumables/fuel/tank[1]/level-lbs",
             "consumables/fuel/total-ctrtk-lbs"];
var Turb = ["engines/engine/turbine","engines/engine[1]/turbine"];
var Warn = "instrumentation/eicas/warn";
var Wow = "gear/gear/wow";

var cdr = nil;
var ctrlPos = nil;
var elec = nil;
var eng = nil;
var fuelHydr = nil;
var line = nil;
var upd_val = nil;

var EICASdsp = {
  COLORS : {
      green : [0, 1, 0],
      white : [1, 1, 1],
      black : [0, 0, 0],
      lightblue : [0, 1, 1],
      darkblue : [0, 0, 1],
      cyan : [0,0.9,0.9],
      red : [1, 0, 0],
      magenta : [1, 0, 1],
      amber : [0.9,0.5,0],
      orange : [1,0.4,0],
      yellow : [1,1,0]
  },

	new: func() {
		var m = {parents: [EICASdsp]};

	  m.canvas = canvas.new({
		  "name": "EICAS", 
		  "size": [1024, 1024],
		  "view": [900, 1024],
		  "mipmapping": 1 
	  });

	  m.canvas.addPlacement({"node": "Eicas.screen","capture-events":1});
    m.l_click = m.canvas.addEventListener("click", func(e) {me.click(e);});
	  m.eicas = m.canvas.createGroup();
    canvas.parsesvg(m.eicas,"/Models/Instruments/EICAS/Eicas.svg");
    m.msgDsp = m.canvas.createGroup();

    m.fan = [];
    m.fan_keys = ["fan0Val","fan1Val","fan0To","fan1To","fanScale",
                  "fanDev0","fanDev1","ignL","ignR"];
    foreach(var i;m.fan_keys) append(m.fan,m.eicas.getElementById(i));

    m.n1 = [];
    m.n1_keys = ["fanBug0","fanBug1"];
    foreach(var i;m.n1_keys) append(m.n1,m.eicas.getElementById(i));

    m.itt = [];
    m.itt_keys = ["ittDev0","ittDev1","itt0Dig","itt1Dig",
                  "itt0Val","itt1Val","ittPtr0","ittPtr1"];
    foreach(var i;m.itt_keys) append(m.itt,m.eicas.getElementById(i));
    m.itt[2].hide();

    m.oilT = [];
    m.oilT_keys = ["oilT0","oilT1","oilTv0","oilTv1"];
    foreach(var i;m.oilT_keys) append(m.oilT,m.eicas.getElementById(i));

    m.oilP = [];
    m.oilP_keys = ["oilP0","oilP1","oilPv0","oilPv1"];
    foreach(var i;m.oilP_keys) append(m.oilP,m.eicas.getElementById(i));

    m.fuel = [];
    m.fuel_keys = ["fuel0","fuel1","fuelT","tank0","tank1","tankC"];
    foreach(var i;m.fuel_keys) append(m.fuel,m.eicas.getElementById(i));

    m.elec = [];
    m.elec_keys = ["lbusV","rbusV","lbusA","rbusA"];
    foreach(var i;m.elec_keys) append(m.elec,m.eicas.getElementById(i));

    m.hydr = [];
    m.hydr_keys = ["hydr0","hydr1"];
    foreach(var i;m.hydr_keys) append(m.hydr,m.eicas.getElementById(i));

    m.turb = [];
    m.turb_keys = ["turb0","turb1"];
    foreach(var i;m.turb_keys) append(m.turb,m.eicas.getElementById(i));

    m.flaps = {};
    m.flaps_keys = ["Flaps","flapsNeedle"];
    foreach(var i;m.flaps_keys) m.flaps[i] = m.eicas.getElementById(i);
    m.flaps.flapsNeedle.setCenter(75,822);

    m.stab = {};
    m.stab_keys = ["stabVal","arc5","arc15","stabNeedle"];
    foreach(var i;m.stab_keys) m.stab[i] = m.eicas.getElementById(i);

    cdr = {};
    m.cdr_keys = ["cdr0","cdr1","cdr2","cdr3","cdr4","cdr5"];
    foreach(var i;m.cdr_keys) cdr[i] = m.eicas.getElementById(i);

    ctrlPos = {};
    m.pos_keys = ["CtrlPos","aileronL","aileronR","elevator",
                  "rudderT","rudderB","rudderLimit"];
    foreach(var i;m.pos_keys) ctrlPos[i] = m.eicas.getElementById(i);

    fuelHydr = {};
    m.fuel_keys = ["FuelHydr","tank1Tmp","tank2Tmp","eng1Tmp","eng2Tmp",
                    "hydrA","hydrRss","hydrB","qtyA","qtyB","tempA","tempB"];
    foreach(var i;m.fuel_keys) fuelHydr[i] = m.eicas.getElementById(i);

    elec = {};
    m.elec_keys = ["ELEC","batt0V","batt0T","batt1V","batt1T"];
    foreach(var i;m.elec_keys) elec[i] = m.eicas.getElementById(i);
    
    eng = {};
    m.eng_keys = ["ENG","oil0qty","oil1qty","apuSP","apuBAV","apuON",
                  "fadec0","fadec1"];
    foreach(var i;m.eng_keys) eng[i] = m.eicas.getElementById(i);
    
    m.fanTgt = m.eicas.getElementById("fanTgt");
    m.rat = m.eicas.getElementById("rat");
    m.gear = m.eicas.getElementById("Gear");
    m.sync = m.eicas.getElementById("sync");
    m.dau1 = m.eicas.getElementById("DAU1").hide();
    m.dau2 = m.eicas.getElementById("DAU2").hide();
    m.speedBrakes = m.eicas.getElementById("SpeedBrakes");
    m.sgTxt = m.eicas.getElementById("sgTxt");
    m.sgCdr = m.eicas.getElementById("sgCdr");

    ##### Values #####
    m.keys = [
      {name: 'oilT0', val: OilT[0],  form:"%.0f"},
      {name: 'oilT1', val: OilT[1],  form:"%.0f"},
      {name: 'oilP0', val: OilP[0],  form:"%.0f"},
      {name: 'oilP1', val: OilP[1],  form:"%.0f"},
      {name: 'fuel0', val: FuelF[0], form:"%.0f"},
      {name: 'fuel1', val: FuelF[1], form:"%.0f"},
      {name: 'fuelT', val: FuelT,    form:"%.0f"},
      {name: 'tank0', val: TkLvl[0], form:"%.0f"},
      {name: 'tank1', val: TkLvl[1], form:"%.0f"},
      {name: 'tankC', val: TkLvl[2], form:"%.0f"},
      {name: 'lbusV', val: Bus[0],   form:"%.0f"},
      {name: 'rbusV', val: Bus[1],   form:"%.0f"},
      {name: 'lbusA', val: Bus[0],   form:"%.0f"},
      {name: 'rbusA', val: Bus[1],   form:"%.0f"},
      {name: 'hydr0', val: Hydr[0],  form:"%.0f"},
      {name: 'hydr1', val: Hydr[1],  form:"%.0f"},
      {name: 'fan0',  val: Fan[0],   form:"%.1f"},
      {name: 'fan1',  val: Fan[1],   form:"%.1f"},
      {name: 'n1_0',  val: N1[0],    form:"%.0f"},
      {name: 'n1_1',  val: N1[1],    form:"%.0f"},
      {name: 'turb0', val: Turb[0],  form:"%.0f"},
      {name: 'turb1', val: Turb[1],  form:"%.0f"},
      {name: 'rat',   val: Rat,      form:"%.0f *C"},
      {name: 'stab',  val: Stab,     form:"%.1f"}];

    ##### Messages #####
    m.lcolor = [me.COLORS.red,me.COLORS.amber,me.COLORS.cyan,me.COLORS.white];

    return m;
  }, # end of new

  listen : func {
    setlistener(Warn, func(n) {
      if (n.getValue()) me.dsp_msg = 1;
      else {me.dsp_msg = 0;me.msgDsp.removeAllChildren()}
    },1,0);

    setlistener(Flaps, func(n) {
      me.flaps.Flaps.setVisible(n.getValue() > 0);
      if (n.getValue() == 0.142) {
        me.flaps.flapsNeedle.setRotation(25*D2R);
        me.fl = 1;
     } else if (n.getValue() == 0.428) {
        me.flaps.flapsNeedle.setRotation(45*D2R);
        me.fl = 2;
      } else if (n.getValue() == 1) {
        me.flaps.flapsNeedle.setRotation(85*D2R);
        me.fl = 0;
      } else {
        me.flaps.flapsNeedle.setRotation(0);
        me.fl = 0;
      }
    },1,0);

    setlistener(Gear, func(n) {
      me.gear.setVisible(n.getValue());
    },1,0);

    setlistener(Wow, func(n) {
      me.wow = n.getValue();
    },1,0);

    setlistener(Sync, func(n) {
      if (n.getValue() != 0) me.sync.show();
      else me.sync.hide();
    },1,0);

    setlistener(SpdBrakes, func(n) {
      if (n.getValue() != 0) me.speedBrakes.show();
      else me.speedBrakes.hide();
    },1,0);

    setlistener(Sg, func(n) {
      if (n.getValue() == 0) {me.sgTxt.hide();me.sgCdr.hide()}
      else {
        if (n.getValue() == -1) me.sgTxt.setText("SG1").show();
        if (n.getValue() == 1) me.sgTxt.setText("SG2").show();
        me.sgCdr.show();
      }
    },1,0);

    setlistener(Dau[0], func(n) {
      if (n.getValue()) {
        if (!me.dau1.getVisible()) me.dau1.setVisible(1);
        else me.dau1.setVisible(0);
      }
    },1,0);

    setlistener(Dau[1], func(n) {
      if (n.getValue()) {
        if (!me.dau2.getVisible()) me.dau2.setVisible(1);
        else me.dau2.setVisible(0);
      }
    },1,0);

    setlistener(Fadec[0], func(n) {
      eng.fadec0.setText(n.getValue());
    },1,0);

    setlistener(Fadec[1], func(n) {
      eng.fadec1.setText(n.getValue());
    },1,0);

    setlistener(ApuRun, func(n) {
      if (n.getValue()) eng.apuON.setText("APU ON").show();
      else eng.apuON.hide();
    },1,0);

  }, # end of listen

  update : func {
    if (me.dsp_msg) me.messages();
    for(var i=0;i<size(me.keys);i+=1) {
      if (getprop(me.keys[i].val) != nil) {
        upd_val = getprop(me.keys[i].val);

        ### Oil Temperature
        if (i<2) {
          upd_val = upd_val <= 0.21 ? 21 : upd_val*100;
          if (upd_val > 21) me.oilT[i].setTranslation(0,-(upd_val-21)*1.2);
          else me.oilT[i].setTranslation(0,0);         
          if (upd_val > 127) {
            me.color = me.COLORS.red;
            me.oilT[i].setColor(me.color).setColorFill(me.color);
          } else {
            me.color = me.COLORS.green;
            me.oilT[i].setColor(me.color).setColorFill(0,0,0);
          }
         me.oilT[i+2].setText(sprintf(me.keys[i].form, upd_val))
                     .setColor(me.color)
                     .setVisible(getprop(Turb[i]) < 56 or cdr.cdr2.getVisible());
        }
        ### Oil pressure
        else if (i==2 or i==3) {
          if (upd_val > 16 and upd_val < 90) {
            me.color = me.COLORS.green;
            me.oilP[i-2].setColor(me.color).setColorFill(0,0,0);
          }
          if (upd_val < 95 and upd_val >= 90) {
            me.color = me.COLORS.amber;
            me.oilP[i-2].setColor(me.color).setColorFill(me.color);
          }
          if (upd_val <= 16 or upd_val >= 95) {
            me.color = me.COLORS.red;
            me.oilP[i-2].setColor(me.color).setColorFill(me.color);
          }
          me.oilP[i-2].setTranslation(0,-upd_val);
          me.oilP[i].setText(sprintf(me.keys[i].form, upd_val))
                    .setColor(me.color)
                    .setVisible((getprop(Turb[i-2]) < 56) or cdr.cdr2.getVisible());
        }
        ### Fuel ###
        else if (i>3 and i<10) {
          me.fuel[i-4].setText(sprintf(me.keys[i].form, upd_val));
        }
        ### Elec ###
        else if (i>9 and i<14) {
          if (right(me.keys[i].name,4) == "busA") upd_val = upd_val*8.928;
          me.elec[i-10].setText(sprintf(me.keys[i].form, upd_val));
        }
        ### Hydraulics ###
        else if (i>13 and i<16) {
          upd_val = upd_val*3000;
            me.hydr[i-14].setText(sprintf(me.keys[i].form, upd_val));
        }
        ### Fans ###
        else if (i>15 and i<18) {
          if (upd_val > 90) me.trans = (upd_val*2.86)+(upd_val-90)*2.86;
          else me.trans = upd_val *2.86;
          if (upd_val >= 100) {
            me.fan[i-16].setColor(me.COLORS.red);
            me.fan[i-14].setColor(me.COLORS.red);            
            me.fan[4].setColor(me.COLORS.red); 
          } else {
            me.fan[i-16].setColor(me.COLORS.green);
            me.fan[4].setColor(me.COLORS.white);
          }
          me.rect = i==16 ? "rect(123,114,425,60)" : "rect(123,260,425,220)";
          me.fan[i-11].setTranslation(0,-me.trans).set("clip",me.rect);
          me.fan[i-16].setText(sprintf(me.keys[i].form, upd_val));
          if((getprop(Ignit[i-16]) == 0 and getprop(Cycle_up[i-16])) or
              getprop(Ignit[i-16]) == 2) me.fan[i-9].show();
          else me.fan[i-9].hide();
            
          if(getprop(Wow) and !getprop(Rev[i-16]) 
              and getprop(Throt[i-16]) < 0.80) {
            me.txt = "T/O";
            me.color = me.COLORS.white;
          } else {
            me.color = me.COLORS.green;
            if (getprop(Rev[i-16])) me.txt = "REV";
            else if (getprop(Throt[i-16]) > 0.30 
                and getprop(Throt[i-16]) < 0.70) me.txt = "CRU";
            else if (getprop(Throt[i-16]) >= 0.70 
                and getprop(Throt[i-16]) < 0.80) me.txt = "CLB";
            else if (getprop(Throt[i-16]) >= 0.80 
                and getprop(Throt[i-16]) < 0.90) me.txt = "T/O";
            else if (getprop(Throt[i-16]) >= 0.90) me.txt = "MTO";
            else me.txt = "";
          }
          me.fan[i-14].setText(me.txt).setColor(me.color);
        }
        ### N1 ###
        else if (i>17 and i<20) {
          if (upd_val > 90) me.trans = (upd_val*2.86)+(upd_val-90)*2.86;
          else me.trans = upd_val *2.86;
          me.rect = i==18 ? "rect(123,114,425,60)" : "rect(123,260,425,220)";
          me.n1[i-18].setTranslation(0,-me.trans).set("clip",me.rect);
          if (getprop(N1[0]) >= getprop(N1[1])) {
            me.fanTgt.setText(sprintf("%3.1f",getprop(N1[0])));
          } else me.fanTgt.setText(sprintf("%3.1f",getprop(N1[1])));
        }
        ### ITT - Turbines ###
        else if (i>19 and i<22) {
          me.trans = (getprop(Itt[i-20]) or 0)*100;
          me.color = me.trans > 85.7 ? me.COLORS.red : me.COLORS.white;  
          me.color1 = upd_val >= 102 ? me.COLORS.red : me.COLORS.green;  
          if (me.trans > 70) me.trans = (me.trans*2.85)+(me.trans-70)*2.85;
          else me.trans = me.trans*2.85;
          me.rect = i==20 ? "rect(75,347,450,320)" : "rect(75,480,450,450)";
          me.itt[i-20].setTranslation(0,-me.trans)
                      .set("clip",me.rect)
                      .setColor(me.color);
          me.itt[i-14].setColorFill(me.color);
          me.turb[i-20].setText(sprintf(me.keys[i].form, upd_val))
                       .setColor(me.color1);
          if((getprop(Ignit[i-20]) == 0 and getprop(Cycle_up[i-20])) or
              getprop(Ignit[i-20]) == 2) {
            me.itt[i-18].show();
            me.itt[i-16].setText(sprintf("%.0f",upd_val));
          } else me.itt[i-18].hide();
        }
        ### Rat ###
        else if (me.keys[i].name == "rat") {
          me.rat.setText(sprintf(me.keys[i].form, upd_val));
        }
        ### Stabilizer ###
        else if (me.keys[i].name == "stab") {
          me.stab.stabNeedle.setCenter(171,648)
                            .setRotation(upd_val*90*D2R);
          if (me.wow) {
            if (me.fl == 1) {
              me.stab.arc5.show();me.stab.arc15.hide();
              if (upd_val < 0.43 and upd_val >= 0.0) {
                me.color = me.COLORS.green;
              } else me.color = me.COLORS.white;
            }
            else if (me.fl == 2) {
                me.stab.arc5.hide();me.stab.arc15.show();
              if (upd_val <= 0.0 and upd_val > -0.43) {
                me.color = me.COLORS.green;
              } else me.color = me.COLORS.white;
            } else {
                me.color = me.COLORS.white;
                me.stab.arc5.hide();me.stab.arc15.hide();
            }
          } else {
            me.stab.arc5.hide();me.stab.arc15.hide();
            me.color = me.COLORS.white;
          }
          me.stab.stabNeedle.setColor(me.color);
        } else me.color = me.COLORS.green;
        me.stab.stabVal.setText(sprintf(me.keys[i].form, 2-(1-upd_val)*7));
      }
    }

    ### FUEL HYDR ###
    if (cdr.cdr2.getVisible()) {
      fuelHydr.FuelHydr.show();
      fuelHydr.tank1Tmp.setText('30');
      fuelHydr.tank2Tmp.setText('30');
      fuelHydr.eng1Tmp.setText('32');
      fuelHydr.eng2Tmp.setText('32');
      fuelHydr.hydrA.setText(sprintf("%4.0f", getprop(Hydr[0])*3000));
      fuelHydr.hydrRss.setText(sprintf("%4.0f", getprop(Hydr[0])*2900));
      fuelHydr.hydrB.setText(sprintf("%4.0f", getprop(Hydr[1])*3000));
      fuelHydr.qtyA.setText('95');
      fuelHydr.qtyB.setText('95');
      fuelHydr.tempA.setText(sprintf("%.0f",getprop(OilT[0])*50 < 21 ? 21 : getprop(OilT[0])*50));
      fuelHydr.tempB.setText(sprintf("%.0f",getprop(OilT[1])*50 < 21 ? 21 : getprop(OilT[0])*50));
    } else  fuelHydr.FuelHydr.hide();

    ### ELEC ###
    if (cdr.cdr3.getVisible()) {
      elec.ELEC.show();
      elec.batt0V.setText('24');
      elec.batt1V.setText('24');
      elec.batt0T.setText('37');
      elec.batt1T.setText('37');
    } else elec.ELEC.hide();

    ### CTRL POS ###
    if (cdr.cdr4.getVisible()) {
      ctrlPos.CtrlPos.show();
      ctrlPos.aileronL.setTranslation(0,getprop(Aileron[0])*50);
      ctrlPos.aileronR.setTranslation(0,getprop(Aileron[1])*50);
      ctrlPos.elevator.setTranslation(0,getprop(Elevator)*50);
      ctrlPos.rudderT.setTranslation(-getprop(Rudder)*85,0);
      ctrlPos.rudderB.setTranslation(getprop(Rudder)*85,0);
      ctrlPos.rudderLimit.setVisible(getprop(Rudder)>0.90 or getprop(Rudder)<-0.90 );
    } else  ctrlPos.CtrlPos.hide();

    ### ENG ###
    if (cdr.cdr5.getVisible()) {
      eng.ENG.show();
      eng.apuSP.setText("35");
      eng.oil0qty.setText("2.8");
      eng.oil1qty.setText("2.8");
      eng.apuBAV.setText(getprop(Bleed) == 0 ? "BLD AIR VLV CLOSED" : "BLD AIR VLV OPEN").setVisible(getprop(ApuRun));
    } else eng.ENG.hide();

		settimer(func {me.update();},0.2);

  }, # end of update

  messages : func {
    me.msg = {};
    me.warn = citation.Warnings.EicasOutput();
    line = 0;
    me.msgDsp.removeAllChildren();
    for (var i=0;i<4;i+=1) {
     for (var j=0;j<size(me.warn[i]);j+=1) {
        me.msg[j] = me.msgDsp.createChild("text")
          .setAlignment("left-baseline")
          .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
          .setFontSize(30)
          .setText(me.warn[i][j])
          .setTranslation(210,540+line)
          .setColor(me.lcolor[i]);
        line+=30;
      }
    }
  }, # end of messages

  menu : func(btn) {
    btn == 1 ? cdr.cdr1.show() : cdr.cdr1.hide();
    btn == 2 ? cdr.cdr2.show() : cdr.cdr2.hide();
    btn == 3 ? cdr.cdr3.show() : cdr.cdr3.hide();
    btn == 4 ? cdr.cdr4.show() : cdr.cdr4.hide();
    btn == 5 ? cdr.cdr5.show() : cdr.cdr5.hide();
  }, # end of menu

  click : func(e) { # for devel: clicks positions
#    print("Click client ",sprintf("X : %.0f",e.clientX)," ",sprintf("Y : %.0f",e.clientY));
#    print("Click screen",sprintf("X : %.0f",e.screenX)," ",sprintf("Y : %.0f",e.screenY));
  },

}; # end of EICASdsp

var eicas_setl = setlistener("sim/signals/fdm-initialized", func() {
  var eicas = EICASdsp.new();
  eicas.listen();
  eicas.update();
  eicas.menu(1);
	print('EICAS Canvas ... Ok');
	removelistener(eicas_setl); 
},0,0);


#==========================================================
# Citation X - EICAS Canvas
# Christian Le Moigne (clm76) March 2019 - modified oct 2023
# =========================================================

var AcftBtn = ["instrumentation/dc840/acft-btn",
               "instrumentation/dc840[1]/acft-btn"];
var AcftSys = ["instrumentation/dc840/acft-sys",
               "instrumentation/dc840[1]/acft-sys"];
var Aileron = ["surface-positions/left-aileron-pos-norm",
                "surface-positions/right-aileron-pos-norm"];
var ApuRun = "controls/APU/running";
var Bat1V = "systems/electrical/batt1-volts";
var Bat2V = "systems/electrical/batt2-volts";
var Bleed = "controls/APU/bleed";
var BusV = ["systems/electrical/left-main-bus-volts",
            "systems/electrical/right-main-bus-volts"];
var BusA = ["systems/electrical/left-main-bus-amps",
            "systems/electrical/right-main-bus-amps"];
var Elevator = "controls/flight/elevator";
var Cycle_up = ["engines/engine/cycle-up","engines/engine[1]/cycle-up"];
var Dau_rev = ["instrumentation/eicas/dau1","instrumentation/eicas/dau2"];
var Dau_el1 = ["systems/electrical/outputs/dau1A",
               "systems/electrical/outputs/dau1B"];
var Dau_el2 = ["systems/electrical/outputs/dau2A",
               "systems/electrical/outputs/dau2B"];
var DispCtrl = ["systems/electrical/outputs/disp-cont1",
                "systems/electrical/outputs/disp-cont2"];
var Eng = ["controls/engines/engine/running",
           "controls/engines/engine[1]/running"];
var Fadec = ["controls/engines/engine/fadec","controls/engines/engine[1]/fadec"];
var Fan = ["engines/engine/fan","engines/engine[1]/fan"];
var N1 = ["engines/engine/n1","engines/engine[1]/n1"];
var Flaps_sel = "controls/flight/flaps-select";
var FuelF = ["engines/engine/fuel-flow-pph",
             "engines/engine[1]/fuel-flow-pph"];
var FuelT = "consumables/fuel/total-fuel-lbs";
var Fuel_qty = ["systems/electrical/outputs/lh-fuel-quantity",
                "systems/electrical/outputs/rh-fuel-quantity",
                "systems/electrical/outputs/ctr-fuel-quantity"];
var Fwc = ["systems/electrical/outputs/annun1",
            "systems/electrical/outputs/annun2"];
var Gear = "controls/gear/gear-down";
var Hydr = ["systems/hydraulics/psi-norm",
            "systems/hydraulics/psi-norm[1]"];
var Ignit = ["controls/engines/engine/ignition",
            "controls/engines/engine[1]/ignition"];
var Itt = ["engines/engine/itt-norm",
            "engines/engine[1]/itt-norm"];
var Madc = ["systems/electrical/outputs/madc1",
            "systems/electrical/outputs/madc2"];
var MsgKnob = "instrumentation/eicas/knob";
var OilP = ["engines/engine/oil-pressure-psi",
            "engines/engine[1]/oil-pressure-psi"];
var OilT = ["engines/engine/oilt-norm",
            "engines/engine[1]/oilt-norm"];
var Rat = "environment/temperature-degc";
var Rev = ["controls/engines/engine/reverser",
            "controls/engines/engine[1]/reverser"];
var LowerRudder = "surface-positions/rudder-pos-norm";
var UpperRudder = "surface-positions/upper-rudder-pos-norm";
var RudderLimit = "controls/flight/rudder-limit-norm";
var RudderLimit_A = "systems/electrical/outputs/rudder-limit-A";
var RudderLimit_B = "systems/electrical/outputs/rudder-limit-B";
var Iac = ["/systems/electrical/outputs/iac1",
           "/systems/electrical/outputs/iac2"];
var SgRev = "instrumentation/eicas/sg-rev";
var SpdBrakes = "controls/flight/spoilers";
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

var batt = nil;
var cdr = nil;
var ctrlPos = nil;
var dau1 = dau2 = nil;
var dsp_size = nil;
var eng = nil;
var fuelHydr = nil;
var hidden_lines = nil;
var kb = nil;
var line = nil;
var msg_kb = 0;
var msg_diff = nil;
var page = nil;
var upd_val = nil;
var hide_msg = nil;
var rudder_fail1 = nil;
var rudder_fail2 = nil;
var sort_msg = nil;
var spad_color = nil;
var warn = nil;

var dsp0 = std.Vector.new();
var dsp1 = std.Vector.new();

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
    canvas.parsesvg(m.eicas,"/Models/Instruments/EICAS/eicas.svg");
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
    m.flaps_keys = ["Flaps","flapsNeedle","Slats"];
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
                  "upperRudder","lowerRudder","rudderLimit","rudderLimitValue",
                  "greenLine","whiteLine"];
    foreach(var i;m.pos_keys) ctrlPos[i] = m.eicas.getElementById(i);

    fuelHydr = {};
    m.fuel_keys = ["FuelHydr","tank1Tmp","tank2Tmp","eng1Tmp","eng2Tmp",
                    "hydrA","hydrRss","hydrB","qtyA","qtyB","tempA","tempB"];
    foreach(var i;m.fuel_keys) fuelHydr[i] = m.eicas.getElementById(i);

    batt = {};
    m.batt_keys = ["ELEC","batt1V","batt1T","batt2V","batt2T"];
    foreach(var i;m.batt_keys) batt[i] = m.eicas.getElementById(i);

    eng = {};
    m.eng_keys = ["ENG","oil0qty","oil1qty","apuSP","apuBAV","apuON",
                  "fadec0","fadec1"];
    foreach(var i;m.eng_keys) eng[i] = m.eicas.getElementById(i);

    m.Sg = {};
    foreach(var i;["sg","sgTxt","sgCdr"]) m.Sg[i] = m.eicas.getElementById(i);
    m.Sg.sg.hide();

    m.fanTgt = m.eicas.getElementById("fanTgt");
    m.rat = m.eicas.getElementById("rat");
    m.gear = m.eicas.getElementById("Gear");
    m.sync = m.eicas.getElementById("sync");
    m.dau1 = m.eicas.getElementById("DAU1").hide();
    m.dau2 = m.eicas.getElementById("DAU2").hide();
    m.speedBrakes = m.eicas.getElementById("SpeedBrakes");
    m.glCenter=  ctrlPos.greenLine.getCenter();
    m.fwcFail = m.eicas.getElementById("FwcFail");
    m.fwcFail.hide();
    m.acftSys = 1;
    m.dsp_msg = 0;

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
      {name: 'lbusV', val: BusV[0],  form:"%.0f"},
      {name: 'rbusV', val: BusV[1],  form:"%.0f"},
      {name: 'lbusA', val: BusA[0],  form:"%.0f"},
      {name: 'rbusA', val: BusA[1],  form:"%.0f"},
      {name: 'hydr0', val: Hydr[0],  form:"%.0f"},
      {name: 'hydr1', val: Hydr[1],  form:"%.0f"},
      {name: 'fan0',  val: Fan[0],   form:"%.1f"},
      {name: 'fan1',  val: Fan[1],   form:"%.1f"},
      {name: 'n1_0',  val: N1[0],    form:"%.0f"},
      {name: 'n1_1',  val: N1[1],    form:"%.0f"},
      {name: 'turb0', val: Turb[0],  form:"%.0f"},
      {name: 'turb1', val: Turb[1],  form:"%.0f"},
      {name: 'rat',   val: Rat,      form:"%.0f °C"},
      {name: 'stab',  val: Stab,     form:"%.1f"}];

    ##### Messages #####
    m.lcolor = [me.COLORS.white,me.COLORS.cyan,me.COLORS.amber,me.COLORS.red];
    return m;
  }, # end of new

  listen : func {
    setlistener(Warn, func(n) {
      if (n.getValue()) me.messages();
    },0,0);

    setlistener(MsgKnob, func(n) {
      if (n.getValue() > msg_kb) msg_diff = 1;
      if (n.getValue() < msg_kb) msg_diff =-1;
        msg_kb = n.getValue();
        me.scroll_msg();
    },0,0);

    setlistener(Flaps_sel, func(n) {
      if (n.getValue() == 1) {
        me.flaps.flapsNeedle.setRotation(25*D2R).setVisible(dau2);
        me.fl = 1;
     } else if (n.getValue() == 2) {
        me.flaps.flapsNeedle.setRotation(45*D2R).setVisible(dau2);
        me.fl = 2;
      } else if (n.getValue() == 3) {
        me.flaps.flapsNeedle.setRotation(85*D2R).setVisible(dau2);
        me.fl = 0;
      } else {
        me.flaps.flapsNeedle.setRotation(0).setVisible(dau2);
        me.fl = 0;
      }
    },1,0);

    setlistener(Wow, func(n) {
      me.wow = n.getValue();
    },1,0);

    setlistener(Sync, func(n) {
      if (n.getValue() != 0) me.sync.show();
      else me.sync.hide();
    },1,0);

    setlistener(Dau_rev[0], func(n) {
      if (n.getValue()) {
        if (!me.dau1.getVisible()) me.dau1.setVisible(1);
        else me.dau1.setVisible(0);
      }
    },1,0);

    setlistener(Dau_rev[1], func(n) {
      if (n.getValue()) {
        if (!me.dau2.getVisible()) me.dau2.setVisible(1);
        else me.dau2.setVisible(0);
      }
    },1,0);

    setlistener(ApuRun, func(n) {
      if (n.getValue()) eng.apuON.setText("APU ON").show();
      else eng.apuON.hide();
    },1,0);

    setlistener(AcftBtn[0], func(n) {
      if (n.getValue() and getprop(DispCtrl[0])) {
        me.acftSys = getprop(AcftSys[0]);
        if (me.acftSys < 5) me.acftSys += 1;
        else me.acftSys = 1;
        me.menu(me.acftSys);
      }
    },0,0);

    setlistener(AcftBtn[1], func(n) {
      if (n.getValue() and getprop(DispCtrl[1])) {
        if (me.acftSys < 5) me.acftSys +=1;
        else me.acftSys = 1;
        setprop(AcftSys[1],me.acftSys);
        me.menu(me.acftSys);
      }
    },0,0);

  }, # end of listen

  update : func {
    me.update_Iac();
    me.update_Fwc();
    me.update_Dau();
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
          me.oilT[i].setVisible(i==0 ? getprop(Dau_el1[0]) : getprop(Dau_el2[0]));
          me.oilT[i+2].setText(sprintf(me.keys[i].form, upd_val))
                     .setColor(me.color)
                     .setVisible((getprop(Turb[i]) < 56 or cdr.cdr2.getVisible())
                        and i==0 ? getprop(Dau_el1[0]) : getprop(Dau_el2[0]));
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
          me.oilP[i-2].setTranslation(0,-upd_val)
                      .setVisible(i==2 ? getprop(Dau_el1[0]) : getprop(Dau_el2[0]));
          me.oilP[i].setText(sprintf(me.keys[i].form, upd_val))
                    .setColor(me.color)
                    .setVisible((getprop(Turb[i-2]) < 56 or cdr.cdr2.getVisible())
                      and i==2 ? getprop(Dau_el1[0]) : getprop(Dau_el2[0]));
        }
        ### Fuel ###
        else if (i>3 and i<10) {
          if (i>6 and !getprop(Fuel_qty[i-7])) {
            upd_val = -999;
            me.color = me.COLORS.red;
          } else me.color = me.COLORS.green;
          me.fuel[i-4].setText(sprintf(me.keys[i].form, upd_val)).setColor(me.color);
          if (i == 4 or i == 7) me.fuel[i-4].setVisible(dau1);
          if (i == 5 or i == 8) me.fuel[i-4].setVisible(dau2);
          if (i == 6 or i == 9) me.fuel[i-4].setVisible(dau1 and dau2 ? 1 : 0);
        }
        ### Elec ###
        else if (i>9 and i<14) {
          me.elec[i-10].setText(sprintf(me.keys[i].form, upd_val))
                       .setVisible(i==10 or i==12 ? dau1 : dau2);
        }
        ### Hydraulics ###
        else if (i>13 and i<16) {
          upd_val = upd_val*3000;
            me.hydr[i-14].setText(sprintf(me.keys[i].form, upd_val))
                         .setVisible(i==14 ? dau1 : dau2);
        }
        ### Fans ###
        else if (i>15 and i<18) {
          if (upd_val > 90) me.trans = (upd_val*2.86)+(upd_val-90)*2.86;
          else me.trans = upd_val *2.86;
          if (upd_val > 100) {
            me.fan[i-16].setColor(me.COLORS.red);
            me.fan[i-14].setColor(me.COLORS.red);
            me.fan[4].setColor(me.COLORS.red);
          } else {
            me.fan[i-16].setColor(me.COLORS.green);
            me.fan[4].setColor(me.COLORS.white);
          }
          me.rect = i==16 ? "rect(123,114,425,60)" : "rect(123,260,425,220)";
          me.fan[i-11].setTranslation(0,-me.trans).set("clip",me.rect)
                      .setVisible(i==16 ? dau1 : dau2);
          me.fan[i-16].setText(sprintf(me.keys[i].form, upd_val))
                      .setVisible(i==16 ? dau1 : dau2);
          if((getprop(Ignit[i-16]) == 0 and getprop(Cycle_up[i-16])) or
              getprop(Ignit[i-16]) == 2) me.fan[i-9].setVisible(i==16 ? dau1 : dau2);
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
          me.n1[i-18].setTranslation(0,-me.trans).set("clip",me.rect)
                     .setVisible(i==18 ? dau1 : dau2);
          if (getprop(N1[0]) >= getprop(N1[1])) {
            me.fanTgt.setText(sprintf("%3.1f",getprop(N1[0])));
          } else me.fanTgt.setText(sprintf("%3.1f",getprop(N1[1])));
          me.fanTgt.setVisible(dau1 or dau2);
        }
        ### ITT - Turbines ###
        else if (i>19 and i<22) {
          if (getprop(Eng[i-20]))
            me.trans = math.clamp(getprop(Itt[i-20])*78.6,10,100);
          else me.trans = (getprop(Itt[i-20]) or 0)*78.6;
          if (me.trans > 90.7) me.color = me.COLORS.red;
          else if (me.trans > 85.7) me.color = me.COLORS.amber;
          else me.color = me.COLORS.white;
          me.color1 = upd_val >= 103 ? me.COLORS.red : me.COLORS.green;
          if (me.trans > 70) me.trans = (me.trans*2.85)+(me.trans-70)*2.85;
          else me.trans = me.trans*2.85;
          me.rect = i==20 ? "rect(75,347,450,320)" : "rect(75,480,450,450)";
          me.itt[i-20].setVisible(i==20 ? dau1 : dau2)
                      .setTranslation(0,-me.trans)
                      .set("clip",me.rect)
                      .setColor(me.color);
          me.itt[i-14].setColorFill(me.color);
          me.turb[i-20].setText(sprintf(me.keys[i].form, upd_val))
                       .setColor(me.color1)
                       .setVisible(i==20 ? dau1 : dau2);
          if((getprop(Ignit[i-20]) == 0 and getprop(Cycle_up[i-20])) or
              getprop(Ignit[i-20]) == 2) {
            me.itt[i-18].setVisible(i==20 ? dau1 : dau2);
            me.itt[i-16].setText(sprintf("%.0f",upd_val))
                        .setVisible(i==20 ? dau1 : dau2);
          } else me.itt[i-18].hide();
        }
        ### Rat ###
        else if (me.keys[i].name == "rat") {
          if (!getprop(Madc[0]) and !getprop(Madc[1])) me.rat.setText("---");
          else me.rat.setText(sprintf(me.keys[i].form, upd_val));
        }
        ### Stabilizer ###
        else if (me.keys[i].name == "stab") {
          me.stab.stabNeedle.setCenter(171,648)
                            .setRotation(upd_val*90*D2R);
          if (me.wow) {
            if (me.fl == 1) {
              me.stab.arc5.setVisible(dau2);me.stab.arc15.hide();
              if (upd_val < 0.43 and upd_val >= 0.0) {
                me.color = me.COLORS.green;
              } else me.color = me.COLORS.white;
            }
            else if (me.fl == 2) {
                me.stab.arc5.hide();me.stab.arc15.setVisible(dau2);
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
          me.stab.stabNeedle.setColor(me.color).setVisible(dau2);
        } else me.color = me.COLORS.green;
        me.stab.stabVal.setText(sprintf(me.keys[i].form, 2-(1-upd_val)*7))
                       .setVisible(dau2);
      }
    }
    ### Speedbrakes ###
    me.speedBrakes.setVisible(getprop(SpdBrakes)> 0.125);

    ### Gears ###
    me.gear.setVisible(getprop(Gear));

    ### FUEL HYDR ###
    if (cdr.cdr2.getVisible()) {
      fuelHydr.FuelHydr.show();
      fuelHydr.tank1Tmp.setText('30').setVisible(getprop(Dau_el1[0]));
      fuelHydr.tank2Tmp.setText('30').setVisible(getprop(Dau_el2[0]));
      fuelHydr.eng1Tmp.setText('32').setVisible(getprop(Dau_el1[0]));
      fuelHydr.eng2Tmp.setText('32').setVisible(getprop(Dau_el2[0]));
      fuelHydr.hydrA.setText(sprintf("%4.0f", getprop(Hydr[0])*3000))
                    .setVisible(getprop(Dau_el1[0]));
      fuelHydr.hydrRss.setText(sprintf("%4.0f", getprop(Hydr[0])*2900))
                      .setVisible(getprop(Dau_el2[0]));
      fuelHydr.hydrB.setText(sprintf("%4.0f", getprop(Hydr[1])*3000))
                    .setVisible(getprop(Dau_el2[0]));
      fuelHydr.qtyA.setText('95').setVisible(getprop(Dau_el1[0]));
      fuelHydr.qtyB.setText('95').setVisible(getprop(Dau_el2[0]));
      fuelHydr.tempA.setText(sprintf("%.0f",getprop(OilT[0])*50 < 21 ? 21 : getprop(OilT[0])*50)).setVisible(getprop(Dau_el1[0]));
      fuelHydr.tempB.setText(sprintf("%.0f",getprop(OilT[1])*50 < 21 ? 21 : getprop(OilT[0])*50)).setVisible(getprop(Dau_el2[0]));
    } else  fuelHydr.FuelHydr.hide();

    ### ELEC ###
    if (cdr.cdr3.getVisible()) {
      batt.ELEC.show();
      batt.batt1V.setText(sprintf("%.0f",getprop(Bat1V))).setVisible(dau1);
      batt.batt2V.setText(sprintf("%.0f",getprop(Bat2V))).setVisible(dau2);
      batt.batt1T.setText('37').setVisible(getprop(Dau_el1[0]));
      batt.batt2T.setText('37').setVisible(getprop(Dau_el2[0]));
    } else batt.ELEC.hide();

    ### CTRL POS ###
    if (cdr.cdr4.getVisible()) {
      ctrlPos.CtrlPos.show();
      ctrlPos.aileronL.setTranslation(0,getprop(Aileron[0])*50);
      ctrlPos.aileronR.setTranslation(0,getprop(Aileron[1])*50);
      ctrlPos.elevator.setTranslation(0,getprop(Elevator)*50);
      ctrlPos.upperRudder.setTranslation(-getprop(UpperRudder)*85,0);
      ctrlPos.lowerRudder.setTranslation(getprop(LowerRudder)*85,0);
      ctrlPos.greenLine.setScale(getprop(RudderLimit),1);
      ctrlPos.greenLine.setTranslation(685-getprop(RudderLimit)*685,1);
      if (!getprop(RudderLimit_A) and !getprop(RudderLimit_B)) {
        rudder_fail = 2;
        me.color = me.COLORS.red;
        ctrlPos.whiteLine.setColor(me.color);
        ctrlPos.lowerRudder.setColor(abs(getprop(LowerRudder)) > getprop(RudderLimit) ? me.color : me.COLORS.green);
      } else if (!getprop(RudderLimit_A) or !getprop(RudderLimit_B)) {
        rudder_fail = 1;
        me.color = me.COLORS.amber;
        ctrlPos.whiteLine.setColor(me.COLORS.white);
      } else rudder_fail = 0;
      ctrlPos.rudderLimit.setVisible(rudder_fail > 0).setColor(me.color);
      ctrlPos.rudderLimitValue.setText(sprintf("%.0f",getprop(RudderLimit)*100)~"%")
              .setVisible(rudder_fail > 0).setColor(me.color);
    } else  ctrlPos.CtrlPos.hide();

    ### ENG ###
    if (cdr.cdr5.getVisible()) {
      eng.ENG.show();
      eng.apuSP.setText(getprop(Dau_el2[0]) ? "35" : "");
      eng.oil0qty.setText(getprop(Dau_el1[0]) ? "2.8" : "");
      eng.oil1qty.setText(getprop(Dau_el2[0]) ? "2.8" : "");
      eng.apuBAV.setText(getprop(Bleed) == 0 ? "BLD AIR VLV CLOSED" : "BLD AIR VLV OPEN").setVisible(getprop(ApuRun));
    } else eng.ENG.hide();

    ###########
		settimer(func {me.update();},0.2);

  }, # end of update

  messages : func {
    warn = citation.Warnings.EicasOutput();
    line = 0;
    dsp0.clear();
    dsp1.clear();
    for (var i=0;i<4;i+=1) {
      for (var j=0;j<size(warn[i]);j+=1) {
        i==0 ? dsp0.append(warn[i][j]) : dsp1.append(warn[i][j]);
        line+=1;
      }
    }
    me.display_msg();
  },

  display_msg : func {
    line = 0;
    dsp_size = size(dsp0.vector)+size(dsp1.vector);
    setprop("instrumentation/eicas/messages",dsp_size); # for checklists
    hidden_lines = dsp_size -12 > 0 ? dsp_size -12 : 0;
#    setprop("instrumentation/eicas/hidden-lines",hidden_lines);
    me.msgDsp.removeAllChildren();
    if (size(dsp0.vector) > 0) {
      for (var i=0;i<size(dsp0.vector);i+=1) {
        me.msgDsp.createChild("text","dsp0")
          .setAlignment("left-baseline")
          .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
          .setFontSize(30)
          .setText(substr(dsp0.vector[i],1))
          .setTranslation(210,540+line)
          .setColor(me.lcolor[3]);
        line+=30;
      }
    }
    if (size(dsp1.vector) > 0) {
      for (var i=0;i<size(dsp1.vector);i+=1) {
        me.msgDsp.createChild("text","dsp1")
          .setAlignment("left-baseline")
          .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
          .setFontSize(30)
          .setText(substr(dsp1.vector[i],1))
          .setTranslation(210,540+line)
          .setColor(me.lcolor[left(dsp1.vector[i],1)]);
        line+=30;
        if (line > 330) break; # 11 lignes x 30 pix
      }
    }
    if (dsp_size > 12) {
      me.msgDsp.createChild("text","spad")
        .setAlignment("center-baseline")
        .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
        .setFontSize(30)
        .setText("MESSAGES")
        .setTranslation(350,930);
      hide_msg = [];
      for (var i=12;i<dsp_size;i+=1) {
        append(hide_msg,dsp1.vector[i-size(dsp0.vector)]);
      }
      sort_msg = sort(hide_msg,func(a,b) cmp(b,a));
      spad_color = me.lcolor[left(sort_msg[0],1)];
      me.msgDsp.getElementById("spad").setColor(spad_color);

      me.msgDsp.createChild("path","spadRarrow")
        .moveTo(475,900)
        .vert(30)
        .line(-8,-15)
        .horiz(16)
        .line(-8,15)
        .setStrokeLineWidth(4)
        .setColor(spad_color)
        .setColorFill(spad_color);

        me.msgDsp.createChild("text","spadRnb")
          .setAlignment("center-baseline")
          .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
          .setFontSize(30)
          .setText(size(hide_msg)-msg_kb)
          .setTranslation(450,930)
          .setColor(spad_color);

      if (msg_kb > 0) {
        me.msgDsp.createChild("path","spadLarrow")
          .moveTo(250,930)
          .vert(-30)
          .line(-8,15)
          .horiz(16)
          .line(-8,-15)
          .setStrokeLineWidth(4)
          .setColor(spad_color)
          .setColorFill(spad_color);

        me.msgDsp.createChild("text","spadLnb")
          .setAlignment("center-baseline")
          .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
          .setFontSize(30)
          .setText(msg_kb)
          .setTranslation(225,930)
          .setColor(spad_color);
      }
    } else if (dsp_size > 0) {
      me.msgDsp.createChild("text","end")
        .setAlignment("center-baseline")
        .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
        .setFontSize(30)
        .setText("END")
        .setTranslation(350,540 + line)
        .setColor(me.lcolor[0]);
    }
  }, # end of display_msg

  scroll_msg : func {
    if (msg_diff == 1) {
      dsp1.append(dsp1.vector[0]);
      dsp1.pop(0);
    }
    if (msg_diff == -1) {
      dsp1.insert(0,dsp1.vector[size(dsp1.vector)-1]);
      dsp1.pop(-1);
    }
    me.display_msg();
  },

  msg_knob : func(x) {
    kb = getprop(MsgKnob)+x;
    if (kb < 0) kb = 0;
    if (kb > hidden_lines) kb = hidden_lines;
    setprop(MsgKnob,kb);
  }, # end of msg_knob

  menu : func(btn) {
    btn == 1 ? cdr.cdr1.show() : cdr.cdr1.hide();
    btn == 2 ? cdr.cdr2.show() : cdr.cdr2.hide();
    btn == 3 ? cdr.cdr3.show() : cdr.cdr3.hide();
    btn == 4 ? cdr.cdr4.show() : cdr.cdr4.hide();
    btn == 5 ? cdr.cdr5.show() : cdr.cdr5.hide();
    me.acftSys = btn;
    setprop(AcftSys[0],me.acftSys);
    setprop(AcftSys[1],me.acftSys);
  }, # end of menu

  click : func(e) { # for devel: clicks positions
#    print("Click client ",sprintf("X : %.0f",e.clientX)," ",sprintf("Y : %.0f",e.clientY));
#    print("Click screen",sprintf("X : %.0f",e.screenX)," ",sprintf("Y : %.0f",e.screenY));
  },

  update_Iac : func {
    if (!getprop(Iac[0])) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG2")}
    else if (!getprop(Iac[1])) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG1")}
    else {
      if (getprop(SgRev) == 0) me.Sg.sg.hide();
      if (getprop(SgRev) == -1) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG1")}
      if (getprop(SgRev) == 1) {me.Sg.sg.show();me.Sg.sgTxt.setText("SG2")}
    }
  },

  update_Fwc : func {
    if ((getprop(Fwc[0]) and getprop(Fwc[1]))
        or (getprop(Fwc[0]) and getprop(SgRev) == -1)
        or (getprop(Fwc[1]) and getprop(SgRev) == 1)) {
      me.fwcFail.hide();me.msgDsp.show();
    }
    else {me.fwcFail.show(); me.msgDsp.hide()}
  },

  update_Dau : func {
    if (!getprop(Dau_el1[0]) and !getprop(Dau_el1[1])) dau1 = 0;
    else dau1 = 1;
    if (!getprop(Dau_el2[0]) and !getprop(Dau_el2[1])) dau2 = 0;
    else dau2 = 1;
    eng.fadec0.setText(dau1 ? getprop(Fadec[0]) : "");
    eng.fadec1.setText(dau2 ? getprop(Fadec[1]) : "");
    me.flaps.Flaps.setVisible(dau2 and getprop(Flaps_sel) > 0);
    me.flaps.Slats.setVisible(dau2 and getprop(Flaps_sel) > 0);
    me.flaps.flapsNeedle.setVisible(dau2);
  },

}; # end of EICASdsp

var eicas_setl = setlistener("sim/signals/fdm-initialized", func() {
  var eicas = EICASdsp.new();
  eicas.listen();
  eicas.update();
  eicas.menu(1);
	print('EICAS ... Ok');
	removelistener(eicas_setl);
},0,0);

### Canvas Air Conditioning Display ###
### C. Le Moigne (clm76) - Dec 2019 ###

var Cab_auto = "controls/air-conditioning/cabin/auto";
var Cab_deg = "controls/air-conditioning/cabin/degC";
var Cab_rot = "controls/air-conditioning/cabin/rotation";
var Cab_sel = "controls/air-conditioning/cabin/temp-sel";
var Ckpt_auto = "controls/air-conditioning/cockpit/auto";
var Ckpt_deg = "controls/air-conditioning/cockpit/degC";
var Ckpt_rot = "controls/air-conditioning/cockpit/rotation";
var Ckpt_sel = "controls/air-conditioning/cockpit/temp-sel";
var Mode = "controls/air-conditioning/select";
var tmp = nil;
var dsp = nil;
var sel = nil;
var rot = nil;
var init = nil;

var AC = {
	new: func() {
		var m = {parents:[AC]};
		m.canvas = canvas.new({
			"name": "Tpre", 
			"size": [1024, 1024],
			"view": [250,150],
			"mipmapping": 1 
		});
		m.canvas.addPlacement({"node": "tpre.screen"});
		m.ac = m.canvas.createGroup();
		canvas.parsesvg(m.ac,"Models/Instruments/Air-conditioning/ac.svg");
    tmp = m.ac.getElementById("tpre");

    setprop(Ckpt_deg,21);
    setprop(Cab_deg,21);
		return m;
	}, # end of new

  listen : func {
    setlistener(Ckpt_rot, func(n) {
      if (n.getValue() >= 180 or n.getValue() == 0) setprop(Ckpt_auto,1);
      else {
        setprop(Ckpt_auto,0);
        if (n.getValue() == 82.5 or n.getValue() == 97.5) {
          setprop(Ckpt_rot,90);
        }
      }
    },0,0);

    setlistener(Ckpt_deg, func {
      me.display();
    },0,0);

    setlistener(Cab_rot, func(n) {
      if (n.getValue() >= 180 or n.getValue() == 0) setprop(Cab_auto,1);
      else {
        setprop(Cab_auto,0);
        if (n.getValue() == 82.5 or n.getValue() == 97.5) {
          setprop(Cab_rot,90);
        }
      }
    },0,0);

    setlistener(Cab_deg, func {
      me.display();
    },0,0);

    setlistener(Mode, func {
      me.display();
    },0,0);

  }, # end of listen

  display : func {
    if (getprop(Mode) == 0) dsp = getprop(Ckpt_deg)*3;
    if (getprop(Mode) == 1) dsp = getprop(Ckpt_sel);
    if (getprop(Mode) == 2) dsp = getprop(Ckpt_deg);
    if (getprop(Mode) == 3) dsp = getprop(Cab_deg);
    if (getprop(Mode) == 4) dsp = getprop(Cab_sel);
    if (getprop(Mode) == 5) dsp = getprop(Cab_deg)*3;
    tmp.setText(sprintf("%.1f",dsp));
  },
}; # end of AC

var control_auto = func(knob) {
  sel = knob == 0 ? Ckpt_sel : Cab_sel;
  rot = knob == 0 ? Ckpt_rot : Cab_rot;
  setprop(sel,(-12/180)*((getprop(rot) == 0 ? 360 : getprop(rot))-180)+30);
  AC.display();
};

var control_man = func(x,knob) {
  sel = knob == 0 ? Ckpt_sel : Cab_sel;
  if (x == "inc") {if (getprop(Cab_sel) < 30) setprop(sel,getprop(sel)+ 0.5)}
  else {if (getprop(sel) > 18) setprop(sel,getprop(sel)- 0.5)}
  AC.display();
};

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	init = AC.new();
  init.listen();
  init.display();
removelistener(setl);
});


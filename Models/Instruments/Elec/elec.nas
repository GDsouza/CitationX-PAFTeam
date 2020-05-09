### Electrical Display ###
### C. Le Moigne (clm76) - apr 2020 ###

var volts_sel = "controls/electric/dc-volts-sel";
var l_amps = "systems/electrical/left-main-bus-amps";
var r_amps = "systems/electrical/right-main-bus-amps";
var batt1_v = "systems/electrical/batt1-volts";
var batt2_v = "systems/electrical/batt2-volts";
var avionics = "controls/electric/avionics-switch";

var Elec = {
	new: func() {
		var m = {parents:[Elec]};
		m.canvas = canvas.new({
			"name": "Elec", 
			"size": [1024, 1024],
			"view": [240,400],
			"mipmapping": 1 
		});
		m.canvas.addPlacement({"node": "elec.screen"});
		m.apu = m.canvas.createGroup();
		canvas.parsesvg(m.apu,"Aircraft/CitationX/Models/Instruments/Elec/elec.svg");
    m.lh_amps = m.apu.getElementById("lh-amps").hide();
    m.rh_amps = m.apu.getElementById("rh-amps").hide();
    m.dc_volts = m.apu.getElementById("volts").hide();
    m.enable = 0;
    m.batt = batt1_v;

		return m;
	}, # end of new

  listen : func {
    setlistener(volts_sel, func(n) {
      me.batt = n.getValue() ? batt2_v : batt1_v;
    },0,0);

    setlistener(avionics, func(n) {
      me.enable = n.getValue() > 0 ? 1 : 0;
    },0,0);

  }, # end of listen

  update : func {
    me.lh_amps.setText(sprintf("%.0f",getprop(l_amps))).setVisible(me.enable);
    me.rh_amps.setText(sprintf("%.0f",getprop(r_amps))).setVisible(me.enable);
    me.dc_volts.setText(sprintf("%.1f",getprop(me.batt))).setVisible(me.enable);
    settimer(func me.update(),0.2);
  }, # end of update

}; # end of Elec

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var init = Elec.new();
	init.listen();
  init.update();
removelistener(setl);
});


### Canvas Engines Indicator ###
### C. Le Moigne (clm76) - 2018 ###

var ENG = {
	new: func() {
		var m = {parents:[ENG]};
		m.canvas = canvas.new({
			"name": "ENG", 
			"size": [1024, 1024],
			"view": [620,365],
			"mipmapping": 1 
		});

		m.canvas.addPlacement({"node": "ENG.screen"});
		m.eng = m.canvas.createGroup();
		canvas.parsesvg(m.eng,"Aircraft/CitationX/Models/Instruments/Engines/ENG.svg");

    m.fan_l = "engines/engine/fan";         # N1
    m.fan_r = "engines/engine[1]/fan";
    m.itt_l = "engines/engine/itt-norm";    # ITT
    m.itt_r = "engines/engine[1]/itt-norm";
    m.turb_l = "engines/engine/turbine";    # N2
    m.turb_r = "engines/engine[1]/turbine";
    m.elec = "systems/electrical/left-bus-norm";
    m.tmp_ext = "environment/temperature-degc";
    m.l_fan = nil;
    m.r_fan = nil;
    m.l_itt = nil;
    m.r_itt = nil;
    m.l_turb = nil;
    m.r_turb = nil;

		m.text = {};
		m.text_val = ["N1l","N1r","ITTl","ITTr","N2l","N2r"];
		foreach(var i;m.text_val) {
			m.text[i] = m.eng.getElementById(i);
      m.text[i].setFont("led.txf");
      m.text[i].setColor(0.9,0.5,0); # amber
      m.text[i].setVisible(0);
		}
		return m
	},

  listen : func {
		setlistener(me.elec,func(n) {
      if (n.getValue()) {me.update();me.textVisible(1)}
      else {me.textVisible(0)}
		},0,0);

  }, # end of Listen

  update : func {
    me.l_fan = getprop(me.fan_l) < 0 ? 0 : getprop(me.fan_l);
		me.text.N1l.setText(sprintf("%.1f",me.l_fan));
    me.r_fan = getprop(me.fan_r) < 0 ? 0 : getprop(me.fan_r);
		me.text.N1r.setText(sprintf("%.1f",me.r_fan));

    me.l_itt = getprop(me.itt_l)*888 < getprop(me.tmp_ext) ? getprop(me.tmp_ext) : getprop(me.itt_l)*888;
	  me.text.ITTl.setText(sprintf("%.0f",me.l_itt));
    me.r_itt = getprop(me.itt_r)*888 < getprop(me.tmp_ext) ? getprop(me.tmp_ext) : getprop(me.itt_r)*888;
	  me.text.ITTr.setText(sprintf("%.0f",me.r_itt));

    me.l_turb = getprop(me.turb_l) < 0 ? 0 : getprop(me.turb_l);
		me.text.N2l.setText(sprintf("%.1f",me.l_turb));
    me.r_turb = getprop(me.turb_r) < 0 ? 0 : getprop(me.turb_r);
		me.text.N2r.setText(sprintf("%.1f",me.r_turb));

		settimer(func me.update(),0);

  }, # end of update

  textVisible : func(v) {
		foreach(var i;me.text_val) {
      me.text[i].setVisible(v);
		}
  }, # end of textVisible

}; # end of RCU

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var init = ENG.new();
	init.listen();
removelistener(setl);
});


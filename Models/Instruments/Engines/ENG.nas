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
    m.val = nil;

		m.text = {};
		m.text_val = ["N1l","N1r","ITTl","ITTr","N2l","N2r"];
		foreach(var i;m.text_val) {
			m.text[i] = m.eng.getElementById(i);
      m.text[i].setVisible(0);
		}
    m.amber = [0.9,0.5,0];
		return m
	},


  listen : func {
		setlistener(me.elec,func(n) {
      if (n.getValue()) {me.visibility(1)}
      else {me.visibility(0)}
		},0,0);

		setlistener(me.fan_l,func(n) {
      me.val = n.getValue() < 0 ? 0 : n.getValue();
			me.text.N1l.setText(sprintf("%.1f",me.val))
                 .setFont("led.txf")
                 .setColor(me.amber);
		},1,0);

		setlistener(me.fan_r,func(n) {
      me.val = n.getValue() < 0 ? 0 : n.getValue();
			me.text.N1r.setText(sprintf("%.1f",me.val))
                 .setFont("led.txf")
                 .setColor(me.amber);
		},1,0);

		setlistener(me.itt_l,func(n) {
      if (n.getValue()) {
        me.val = n.getValue()*888 < getprop(me.tmp_ext) ? getprop(me.tmp_ext) : n.getValue()*888;
			  me.text.ITTl.setText(sprintf("%.0f",me.val))
                   .setFont("led.txf")
                   .setColor(me.amber);
      }
		},0,1);

		setlistener(me.itt_r,func(n) {
      if (n.getValue()) {
        me.val = n.getValue()*888 < getprop(me.tmp_ext) ? getprop(me.tmp_ext) : n.getValue()*888;
  			me.text.ITTr.setText(sprintf("%.0f",me.val))
                 .setFont("led.txf")
                 .setColor(me.amber);
      }
		},0,1);

		setlistener(me.turb_l,func(n) {
      me.val = n.getValue() < 0 ? 0 : getprop(me.turb_l);
			me.text.N2l.setText(sprintf("%.1f",me.val))
                 .setFont("led.txf")
                 .setColor(me.amber);
		},1,0);

		setlistener(me.turb_r,func(n) {
      me.val = n.getValue() < 0 ? 0 : getprop(me.turb_r);
			me.text.N2r.setText(sprintf("%.1f",me.val))
                 .setFont("led.txf")
                 .setColor(me.amber);
		},1,0);

  }, # end of Listen

  visibility : func(v) {
		foreach(var i;me.text_val) {
      me.text[i].setVisible(v);
		}
  }, # end of visibility

}; # end of RCU

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var init = ENG.new();
	init.listen();
removelistener(setl);
});


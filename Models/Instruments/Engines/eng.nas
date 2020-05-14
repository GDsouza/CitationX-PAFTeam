### Canvas Engines Indicator ###
### C. Le Moigne (clm76) - 2018 - modified 2019 ###

var ENG = {
	new: func {
		var m = {parents:[ENG]};
		m.canvas = canvas.new({
			"name": "ENG", 
			"size": [1024, 1024],
			"view": [620,365],
			"mipmapping": 1 
		});

		m.canvas.addPlacement({"node": "ENG.screen"});
		m.eng = m.canvas.createGroup();
		canvas.parsesvg(m.eng,"Aircraft/CitationX/Models/Instruments/Engines/eng.svg");

    m.Fan = ["engines/engine/fan","engines/engine[1]/fan"]; # N1
    m.Itt = ["engines/engine/itt-norm","engines/engine[1]/itt-norm"]; # ITT
    m.Turb = ["engines/engine/turbine","engines/engine[1]/turbine"];  # N2
    m.Elec = ["systems/electrical/outputs/stby-lh-eng-instr",
              "systems/electrical/outputs/stby-rh-eng-instr"];
    m.Eng = ["controls/engines/engine/running",
             "controls/engines/engine[1]/running"];
    m.rh_main_bus = "systems/electrical/right-main-bus";
    m.tmp_ext = "environment/temperature-degc";
    m.fan = nil;
    m.itt = nil;
    m.turb = nil;
    m.upd = 0;

    m.text = [[],[]];
      append(m.text[0],m.eng.getElementById("N1l"));
      append(m.text[0],m.eng.getElementById("ITTl"));
      append(m.text[0],m.eng.getElementById("N2l"));
      append(m.text[1],m.eng.getElementById("N1r"));
      append(m.text[1],m.eng.getElementById("ITTr"));
      append(m.text[1],m.eng.getElementById("N2r"));

		return m
	},

  listen : func (eng_num) {
		setlistener(me.Elec[eng_num],func(n) {
      if (n.getValue()) {
        me.textVisible(1,eng_num);
        if (!me.upd) {me.upd = 1;me.update()};
      } 
      else me.textVisible(0,eng_num);
		},1,0);

  }, # end of Listen

  update : func {
    for(var n=0;n<2;n+=1) {
      me.fan = getprop(me.Fan[n]) < 0 ? 0 : getprop(me.Fan[n]);
		  me.text[n][0].setText(sprintf("%.1f",me.fan));
      if (getprop(me.Eng[n])) 
        me.itt = math.clamp(getprop(me.Itt[n])*788,120,1000);
      else me.itt = getprop(me.tmp_ext);
	    me.text[n][1].setText(sprintf("%.0f",me.itt));

      me.turb = getprop(me.Turb[n]) < 0 ? 0 : getprop(me.Turb[n]);
		  me.text[n][2].setText(sprintf("%.1f",me.turb));
    }
		settimer(func me.update(),0.1);

  }, # end of update

  textVisible : func(v,eng_num) {
		for(var i=0;i<size(me.text[eng_num]);i+=1) me.text[eng_num][i].setVisible(v);
  }, # end of textVisible

}; # end of ENG

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var init = ENG.new();
	init.listen(0);
  init.listen(1);
removelistener(setl);
});


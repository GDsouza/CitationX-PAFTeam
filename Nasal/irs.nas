### Canvas IRS (Inertial Reference System) Light version ###
### C. Le Moigne (clm76) - 2021 ###

var align = "instrumentation/irs/align";
var stbyBatt_fail = "controls/electric/stby-batt-fail";
var cdu_dsp = "instrumentation/cdu/display";
var irs_failure = "instrumentation/irs/failure";
var irs_pwr = "systems/electrical/outputs/att-hdg1";
var irsAux_pwr = "systems/electrical/outputs/att-hdg-aux1";
var posit = "instrumentation/irs/positioned";
var selected = "instrumentation/irs/selected";
var test = "instrumentation/irs/test";
var fault = 0;
var navready = 0;
var t = nil;

var IRS = {
	new: func {
		var m = {parents:[IRS]};
	  m.canvas = canvas.new({
			  "name": "IRS", 
			  "size": [1024, 1024],
			  "view": [620,290],
			  "mipmapping": 1 
	  });
	  m.canvas.addPlacement({"node": "IRS.screen"});
	  m.irs = m.canvas.createGroup();
	  canvas.parsesvg(m.irs,"Aircraft/CitationX/Models/Instruments/IRS/irs.svg");
		m.text = {};
		m.text_val = ["Align","Fault","NavRdy","NoAir","OnBatt","BattFail"];
		foreach(var i;m.text_val) m.text[i] = m.irs.getElementById(i);
    foreach (var i;m.text_val) m.text[i].hide();
		return m
	},

  listen : func {
    setlistener(irsAux_pwr, func(n) {
      if (n.getValue()) me.text.OnBatt.hide();
      else me.text.OnBatt.show();
		},0,0);

    setlistener(stbyBatt_fail, func(n) {
      if (n.getValue()) me.text.BattFail.show();
      else me.text.BattFail.hide();
		},0,0);

		setlistener(cdu_dsp, func(n) {
			if (n.getValue() == "POS-INIT" and !getprop(posit)) me.align();
		},0,0);

		setlistener(selected, func(n) {
      if (n.getValue() == -2) {
        settimer(func {
          me.text.Fault.hide();
          fault = 0;
          me.text.NavRdy.hide();
          navready = 0;
          setprop(align,0);
          setprop(posit,0);
          setprop(irs_failure,1);
        },3);
      } else {
        setprop(irs_failure,0);
			  if (n.getValue() == -1 or n.getValue() == 1) {
          settimer(func {
				    me.text.Fault.hide();
            fault = 0;
            me.align();
          },2);
        } else if (n.getValue() == 0) {me.text.Fault.hide();fault=0}
      }
    },0,0);

		setlistener(test, func(n) {
			if (n.getValue()) {
				me.text.Align.show();
				me.text.Fault.show();
				me.text.NavRdy.show();
				me.text.NoAir.show();
				me.text.OnBatt.show();
				me.text.BattFail.show();
			} else {
				if (!getprop(align)) me.text.Align.hide();
				if (!fault) me.text.Fault.hide();
				if (!navready) me.text.NavRdy.hide();
				me.text.NoAir.hide();
				me.text.OnBatt.hide();
				me.text.BattFail.hide();
			}
		},0,0);

  }, # end of listen

  align : func {
    if (getprop(selected) == -2) return;
    else {
      setprop(align,1);
      setprop(posit,0);
      me.text.Align.show();
      me.text.NavRdy.hide();
      navready = 0;
      settimer(func {
        me.text.Align.hide();
        setprop(posit,1);
        setprop(align,0);
        me.text.NavRdy.show();
        navready = 1;
        if (getprop(selected) == -1 and getprop(posit)) me.fault();        
        else {me.text.Fault.hide();fault = 0}
      },5);
    }
  }, # end of align

	fault : func {
		t = 0;
		var fault_timer = maketimer(0.5,func() {
			if (t==0) me.text.Fault.show();
			if (t==1) me.text.Fault.hide();		
			t+=1;
			if(t==2 or getprop(test)) t=0;
			if (getprop(selected)== 0 or getprop(selected) == -2) {
				fault_timer.stop();
				me.text.Fault.hide();
			}
		});
		fault_timer.start();
	}, # end of fault

}; # end of IRS

#### Startup ####
var irs_stl = setlistener("/sim/signals/fdm-initialized", func () {	
  var irs = nil;
  	irs = IRS.new();
    irs.listen();
	removelistener(irs_stl);
},0,0);


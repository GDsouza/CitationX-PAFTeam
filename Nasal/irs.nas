### Canvas IRS (Inertial Reference System) ###
### C. Le Moigne (clm76) - 2017 ###

var align = ["instrumentation/irs/align",
             "instrumentation/irs[1]/align"];
var stbyBatt_fail = "controls/electric/stby-batt-fail";
var cdu_dsp = ["instrumentation/cdu/display",
               "instrumentation/cdu[1]/display"];
var irs_failure = ["instrumentation/irs/failure",
                  "instrumentation/irs[1]/failure"];
var irs_pwr = ["systems/electrical/outputs/att-hdg1",
            "systems/electrical/outputs/att-hdg2"];
var irsAux_pwr = ["systems/electrical/outputs/att-hdg-aux1",
            "systems/electrical/outputs/att-hdg-aux2"];
var posit = ["instrumentation/irs/positionned",
             "instrumentation/irs[1]/positionned"];
var selected = ["instrumentation/irs/selected",
                "instrumentation/irs[1]/selected"];
var test = ["instrumentation/irs/test",
            "instrumentation/irs[1]/test"];
var t = nil;

var IRS = {
	new: func(x) {
		var m = {parents:[IRS]};
    if (!x) {
		  m.canvas = canvas.new({
			  "name": "IRS1", 
			  "size": [1024, 1024],
			  "view": [620,290],
			  "mipmapping": 1 
		  });
		  m.canvas.addPlacement({"node": "IRS.screenL"});
		  m.irs = m.canvas.createGroup();
		  canvas.parsesvg(m.irs,"Aircraft/CitationX/Models/Instruments/IRS/irs.svg");
    } else {
		  m.canvas = canvas.new({
			  "name": "IRS2", 
			  "size": [1024, 1024],
			  "view": [620,290],
			  "mipmapping": 1 
		  });
		  m.canvas.addPlacement({"node": "IRS.screenR"});
		  m.irs = m.canvas.createGroup();
		  canvas.parsesvg(m.irs,"Aircraft/CitationX/Models/Instruments/IRS/irs.svg");
    }

		m.text = {};
		m.text_val = ["Align","Fault","NavRdy","NoAir","OnBatt","BattFail"];
		foreach(var i;m.text_val) m.text[i] = m.irs.getElementById(i);
    foreach (var i;m.text_val) m.text[i].hide();
		return m
	},

  listen : func(x) {
    setlistener(irsAux_pwr[x], func(n) {
      if (n.getValue()) me.text.OnBatt.hide();
      else me.text.OnBatt.show();
		},0,0);

    setlistener(stbyBatt_fail, func(n) {
      if (n.getValue()) me.text.BattFail.show();
      else me.text.BattFail.hide();
		},0,0);

		setlistener(cdu_dsp[x], func(n) {
			if (n.getValue() == "POS-INIT") me.align(x);
		},0,0);

		setlistener(selected[x], func(n) {
      if (n.getValue() == -2) {
        settimer(func {
          me.text.Fault.hide();
          me.text.NavRdy.hide();
          setprop(align[x],0);
          setprop(posit[x],0);
          setprop(irs_failure[x],1);
        },3);
      } else {
        setprop(irs_failure[x],0);
			  if (n.getValue() == -1 or n.getValue() == 1) {
          settimer(func {
				    me.text.Fault.hide();
            me.align(x);
          },2);
        } else if (n.getValue() == 0) me.text.Fault.hide();
      }
    },0,0);
  }, # end of listen

  align : func(x) {
    if (getprop(selected[x]) == -2) return;
    else {
      setprop(align[x],1);
      setprop(posit[x],0);
      me.text.Align.show();
      me.text.NavRdy.hide();
      settimer(func {
        me.text.Align.hide();
        setprop(posit[x],1);
        setprop(align[x],0);
        me.text.NavRdy.show();
        if (getprop(selected[x]) == -1 and getprop(posit[x])) me.fault(x);        
        else me.text.Fault.hide();
      },5);
    }
  }, # end of align

	fault : func(x) {
		t = 0;
		var fault_timer = maketimer(0.5,func() {
			if (t==0) {me.text.Fault.show()}
			if (t==1) {me.text.Fault.hide()}					
			t+=1;
			if(t==2) t=0;
			if (getprop(selected[x])== 0 or getprop(selected[x]) == -2) {
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
  for (var x=0;x<2;x+=1) {
  	irs = IRS.new(x);
    irs.listen(x);
  }
	removelistener(irs_stl);
},0,0);


### Canvas IRS (Inertial Reference System) ###
### C. Le Moigne (clm76) - 2017 ###

props.globals.initNode("instrumentation/irs/positionned",0,"BOOL",1);
props.globals.initNode("instrumentation/irs/align",0,"BOOL",1);
props.globals.initNode("instrumentation/irs/test",0,"BOOL",1);
var align = "instrumentation/irs/align";
var cdu_init = "instrumentation/cdu/pos-init";
var selected = "instrumentation/irs/selected";
var posit = "instrumentation/irs/positionned";
var test = "instrumentation/irs/test";
var f_align = 0; # flag
var f_fault = 0; # flag
var f_navready = 0; # flag
var t = nil;

var IRS = {
	new: func() {
		var m = {parents:[IRS]};
		m.canvas = canvas.new({
			"name": "IRS", 
			"size": [1024, 1024],
			"view": [620,290],
			"mipmapping": 1 
		});

		m.canvas.addPlacement({"node": "IRS.screen"});
		m.irs = m.canvas.createGroup();
		canvas.parsesvg(m.irs,"Aircraft/CitationX/Models/Instruments/IRS/IRS.svg");
		m.text = {};
		m.text_val = ["Align","Fault","NavRdy","NoAir","OnBatt","BattFail"];
		foreach(var i;m.text_val) {
			m.text[i] = m.irs.getElementById(i);
		}
		m.text.Align.hide();
		m.text.Fault.hide();
		m.text.NavRdy.hide();
		m.text.NoAir.hide();
		m.text.OnBatt.hide();
		m.text.BattFail.hide();

		m.irs.setVisible(1);
		setprop(selected,0);

		return m
	},

	### Listeners ###
	listen : func {
		setlistener(cdu_init, func(n) {
			if (n.getValue()) {
				me.text.NavRdy.hide();
				setprop(align,1);
				me.navReady();
				me.irsMain();
				f_align = 1;
				f_navready = 1;
			} else {
				me.text.Align.hide();
				me.text.NavRdy.hide();
				setprop(posit,0);
			}
		},0,0);

	}, # end of listen

	irsMain : func {
		setlistener(posit, func(n) {
			if (n.getValue()) {setprop(align,0)}
		},0,0);
					
		setlistener(selected, func(n) {
			if (n.getValue() == -1 or n.getValue() == 1) {
				me.text.Fault.hide();
				f_fault = 0;
				var delay_timer = maketimer(2,func() {
					if (n.getValue() == -1 or n.getValue() == 1) {
						setprop(align,1);
						f_align = 1;
					}
					else {
						delay_timer.stop();
						setprop(align,0);
						
					}
				});
				delay_timer.singleShot = 1;
				delay_timer.start();
			} else if (n.getValue() == 0) {
				if (!getprop(posit)) {me.text.Fault.show();f_fault = 1}
				else {me.text.Fault.hide();f_fault = 0}
			} else if (n.getValue() == -2) {
				var off_timer = maketimer(3,func() {
					if (n.getValue() != -2) {off_timer.stop()}
					else {
						me.text.Align.hide();
						me.text.NavRdy.hide();
						me.text.Fault.hide();			
						setprop(posit,0);
						f_align = 0;
						f_fault = 0;
						f_navready = 0;
					}
				});
				off_timer.singleShot = 1;
				off_timer.start();
			}
		},0,0);

		setlistener(align, func(n) {
			if (n.getValue()) {
				setprop(posit,0);
				me.text.NavRdy.hide();
				me.navReady();				
				f_align = 1;
			} else {f_align = 0}
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
				if (!f_align) {me.text.Align.hide()}
				if (!f_fault) {me.text.Fault.hide()}
				if (!f_navready) {me.text.NavRdy.hide()}
				me.text.NoAir.hide();
				me.text.OnBatt.hide();
				me.text.BattFail.hide();
			}
		},0,0);

	}, # end of irsMain

	navReady : func {
		me.text.Align.show();			
		f_navready = 0;
		me.align_timer = maketimer(5,func() {
			me.text.Align.hide();
			me.text.NavRdy.show();
			f_navready = 1;
			setprop(posit,1);
			if (getprop(selected) != 0) {
				f_fault = 1;
				me.fault();
			} else {f_fault = 0}
		});
		me.align_timer.singleShot = 1;
		me.align_timer.start();	
	}, # end of display

	fault : func {
		t = 0;
		me.fault_timer = maketimer(0.5,func() {
			if (t==0) {me.text.Fault.show()}
			if (t==1) {me.text.Fault.hide()}					
			t+=1;
			if(t==2) {t=0}
			if (getprop(selected)== 0 or getprop(selected) == -2 or !getprop(cdu_init)) {
				me.fault_timer.stop();
				me.text.Fault.hide();
			}
		});
		me.fault_timer.start();
	}, # end of fault

}; # end of IRS

#### Main ####
var irs_stl = setlistener("/sim/signals/fdm-initialized", func () {	
	var irs = IRS.new();
	irs.listen();
	removelistener(irs_stl);
},0,0);


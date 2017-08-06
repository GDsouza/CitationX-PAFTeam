### Canvas RCU ###
### C. Le Moigne (clm76) - 2017 ###

var com_freq1 = props.globals.getNode("instrumentation/comm/frequencies/selected-mhz");
var nav_freq1 = props.globals.getNode("instrumentation/nav/frequencies/selected-mhz");
var com_freq2 = props.globals.getNode("instrumentation/comm[1]/frequencies/selected-mhz");
var nav_freq2 = props.globals.getNode("instrumentation/nav[1]/frequencies/selected-mhz");
var selected = props.globals.getNode("instrumentation/rcu/selected");
var mode = props.globals.getNode("instrumentation/rcu/mode");
var sq = props.globals.getNode("instrumentation/rcu/squelch");
var navAud = props.globals.getNode("instrumentation/rcu/nav-audio");
var tx1 = props.globals.getNode("instrumentation/comm/ptt");
var tx2 = props.globals.getNode("instrumentation/comm[1]/ptt");
var emrg = props.globals.getNode("instrumentation/rcu/emrg");

var RCU = {
	new: func() {
		var m = {parents:[RCU]};
		m.canvas = canvas.new({
			"name": "RCU", 
			"size": [1024, 1024],
			"view": [600,256],
			"mipmapping": 1 
		});

		m.canvas.addPlacement({"node": "RCU.screen"});
		m.rcu = m.canvas.createGroup();
		canvas.parsesvg(m.rcu,"Aircraft/CitationX/Models/Instruments/RCU/RCU.svg");
		m.text = {};
		m.text_val = ["comFreq","navFreq","navAudio","sq","tx",
									"comInd","navInd","emrg"];
		foreach(var i;m.text_val) {
			m.text[i] = m.rcu.getElementById(i);
		}

		m.rcu.setVisible(1);

	### Display init ###
		m.text.comFreq.setText(sprintf("%.3f",com_freq1.getValue()));
		m.text.navFreq.setText(sprintf("%.3f",nav_freq1.getValue()));
		m.text.comInd.show();
		m.text.navInd.hide();
		m.text.navAudio.hide();
		m.text.sq.show();
		m.text.tx.hide();
		m.text.emrg.hide();
		return m
	},

	### Listeners ###
	listen : func {

		setlistener(com_freq1, func(n) {
			if (!mode.getValue()) {
				me.text.comFreq.setText(sprintf("%.3f",n.getValue()));
			}
		});
		setlistener(com_freq2, func(n) {
			if (mode.getValue()) {
				me.text.comFreq.setText(sprintf("%.3f",n.getValue()));
			}
		});

		setlistener(nav_freq1, func(n) {
			if (!mode.getValue()) {
				me.text.navFreq.setText(sprintf("%.3f",n.getValue()));
			}
		});
		setlistener(nav_freq2, func(n) {
			if (mode.getValue()) {
				me.text.navFreq.setText(sprintf("%.3f",n.getValue()));
			}
		});

		setlistener(selected, func(n) {
			if (n.getValue() == "COM") {
				me.text.comInd.show();				
				me.text.navInd.hide();
			} else {
				me.text.comInd.hide();				
				me.text.navInd.show();
			}
		});

		setlistener(mode, func(n) {
			if (n.getValue()) {
				me.text.comFreq.setText(sprintf("%.3f",com_freq2.getValue()));
				me.text.navFreq.setText(sprintf("%.3f",nav_freq2.getValue()));
			} else {
				me.text.comFreq.setText(sprintf("%.3f",com_freq1.getValue()));
				me.text.navFreq.setText(sprintf("%.3f",nav_freq1.getValue()));
			}
		});

		setlistener(sq, func(n) {
			if (n.getValue()) {
				me.text.sq.hide();				
			} else {
				me.text.sq.show();				
			}
		});

		setlistener(navAud, func(n) {
			if (n.getValue()) {
				me.text.navAudio.show();				
			} else {
				me.text.navAudio.hide();				
			}
		});

		setlistener(tx1, func(n) {
			if (n.getValue()) {
				me.text.tx.show();				
			} else {
				me.text.tx.hide();				
			}
		});

		setlistener(tx2, func(n) {
			if (n.getValue()) {
				me.text.tx.show();				
			} else {
				me.text.tx.hide();				
			}
		});

		setlistener(emrg, func(n) {
			if (n.getValue()) {me.text.emrg.show()}
			else {me.text.emrg.hide()}
		});

	}, # end of listen
}; # end of RCU

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var init = RCU.new();
	init.listen();
removelistener(setl);
});


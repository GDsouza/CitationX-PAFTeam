### Canvas Apu Display ###
### C. Le Moigne (clm76) - Dec 2019 ###

var Bleed = "controls/APU/bleed";
var Bleed_air = "controls/APU/bleed-air";
var Ecu = "systems/electrical/outputs/apu-ecu";
var Fire_fuse = "systems/electrical/cb/apu-fireDetect-fuse-tripped";
var Master = "controls/APU/master";
var Master_fuse = "systems/electrical/outputs/apu-master";
var Max_cool = "controls/APU/max-cool";
var Rpm = "controls/APU/rpm";
var Running = "controls/APU/running";
var Relay = "controls/APU/relay";
var Test = "controls/APU/test";
var Volts = "systems/electrical/apu-gen-volts";
var Volts_test = "systems/electrical/right-emer-bus-volts";

var update_timer = nil;
var rpm_txt = nil;
var egt_txt = nil;
var volts_txt = nil;

var APU = {
	new: func() {
		var m = {parents:[APU]};
		m.canvas = canvas.new({
			"name": "Apu", 
			"size": [1024, 1024],
			"view": [240,400],
			"mipmapping": 1 
		});
		m.canvas.addPlacement({"node": "apu.screen"});
		m.apu = m.canvas.createGroup();
		canvas.parsesvg(m.apu,"Aircraft/CitationX/Models/APU/apu.svg");
    m.rpm = m.apu.getElementById("rpm").hide();
    m.egt = m.apu.getElementById("egt").hide();
    m.volts = m.apu.getElementById("volts").hide();
    m.master = 0;
    m.ecu = 0;
    m.fire = 0;

		return m;
	}, # end of new

  listen : func {
    setlistener(Master, func(n) {
      me.master = n.getValue();
      if (me.master and !update_timer.isRunning) update_timer.start();
    },0,0);

    setlistener(Test, func(n) {
      if (me.master) {
        setprop("controls/APU/fire",me.fire ? 0 :n.getValue());
        setprop("controls/APU/relay",n.getValue());
        setprop("controls/APU/fail",n.getValue());
      }
    },0,0);

    setlistener(Rpm, func(n) {me.bleedAir();},0,0);

    setlistener(Bleed, func(n) {me.bleedAir();},0,0);

    ### ELECTRICAL ###
    setlistener(Master_fuse, func(n) {
      setprop("controls/APU/fail",1-n.getValue());
      if (!n.getValue()) setprop("controls/APU/running",0);
    },0,0);

    setlistener(Ecu, func(n) {
      me.ecu = n.getValue();
      setprop("controls/APU/fail",n.getValue() ? 0 : 1);
      if (!n.getValue()) setprop("controls/APU/running",0);
    },0,0);

    setlistener(Master_fuse, func(n) {
      setprop("controls/APU/fail",n.getValue());
      if (!n.getValue()) setprop("controls/APU/running",0);
    },0,0);

    setlistener(Fire_fuse, func(n) {
      me.fire = n.getValue();
    },0,0);

  }, # end of listen

  updateTimer : func {
    update_timer = maketimer(0.1,func() {me.update();});
  }, # end of update_timer

  update : func {
    if (getprop(Test)) {
      rpm_txt = 49;
      egt_txt = 500;
      volts_txt = getprop(Volts_test);
    } else if (!getprop(Ecu)) {
      rpm_txt = 0;
      egt_txt = 0;
      volts_txt = 0;
    } else {
      rpm_txt = getprop(Rpm)*100;
      egt_txt = getprop(Rpm)*650;
      volts_txt = getprop(Volts);
    }
    me.rpm.setText(sprintf("%.0f",rpm_txt)).setVisible(me.master);
    me.egt.setText(sprintf("%.0f",egt_txt)).setVisible(me.master);
    me.volts.setText(sprintf("%.1f",volts_txt)).setVisible(me.master);
    if (!getprop(Test)) {
      if (getprop(Rpm) < 0.99 and getprop(Running)) setprop(Relay,1);
      else setprop(Relay,0);
    }
    if (!me.master and update_timer.isRunning) update_timer.stop();
  }, # end of update

  bleedAir : func {
    if (getprop(Rpm) >= 0.99) {        
      if (getprop(Bleed) == 0) {
        setprop(Bleed_air,0);
        setprop(Max_cool,0);
      }
      if (getprop(Bleed) > 0) setprop(Bleed_air,1);
      if (getprop(Bleed) == 2) setprop(Max_cool,1);
      else setprop(Max_cool,0);
    } else {
      setprop(Bleed_air,0);
      setprop(Max_cool,0);
    }
  }, # end of bleedAir

}; # end of APU

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var init = APU.new();
	init.listen();
  init.updateTimer();
removelistener(setl);
});


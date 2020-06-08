### Tyres Smoke ###

### Timer ###

UPDATE_PERIOD = 0.3;
var registerTimer = func {settimer(arg[0], UPDATE_PERIOD)}
var run_tyresmoke0 = 0;
var run_tyresmoke1 = 0;
var run_tyresmoke2 = 0;
var tyresmoke_0 = aircraft.tyresmoke.new(0);
var tyresmoke_1 = aircraft.tyresmoke.new(1);
var tyresmoke_2 = aircraft.tyresmoke.new(2);
var update_tyresmoke = nil;
var alt_gear = "position/gear-agl-ft";
var speed = "velocities/airspeed-kt";

var TyreSmoke = {
	new: func () {
		var m = {parents:[TyreSmoke]};
    return m;
  }, # end of new

### Listeners ###
  listen : func {
    setlistener("gear/gear[0]/position-norm", func(n) {
	    if (n.getValue() and getprop(alt_gear) < 200 and getprop(speed) > 20){
        run_tyresmoke0 = 1;
        if (!me.update_tyresmoke.isRunning) {me.update_tyresmoke.start()}
	    } else {run_tyresmoke0 = 0;me.update_tyresmoke.stop()}
    },0,1);

    setlistener("gear/gear[1]/position-norm", func(n) {
	    if (n.getValue() and getprop(alt_gear) < 200 and getprop(speed) > 20){
        run_tyresmoke1 = 1;
        if (!me.update_tyresmoke.isRunning) {me.update_tyresmoke.start()}
	    } else {run_tyresmoke1 = 0;me.update_tyresmoke.stop()}
    },0,1);

    setlistener("gear/gear[2]/position-norm", func(n) {
	    if (n.getValue() and getprop(alt_gear) < 200 and getprop(speed) > 20){
        run_tyresmoke2 = 1;
        if (!me.update_tyresmoke.isRunning) {me.update_tyresmoke.start()}
	    } else {run_tyresmoke2 = 0;me.update_tyresmoke.stop()}
    },0,1);

  }, # end of listen

### Tyre Smoke ###

  t_smoke : func {
		if (run_tyresmoke0) {tyresmoke_0.update()}
		if (run_tyresmoke1) {tyresmoke_1.update()}
		if (run_tyresmoke2) {tyresmoke_2.update()}
  }, # end of t_smoke

  updateTyresmoke : func {
    me.update_tyresmoke = maketimer(0,func() {
    me.t_smoke();
    });
  }, # end of updateTyresmoke
};

### Rain ###
aircraft.rain.init();
var rain = func {
	aircraft.rain.update();
	settimer(rain, 0.3);
}

### Main ###
var ts = TyreSmoke.new();
var setl_tyre = setlistener("/sim/signals/fdm-initialized", func () {
  settimer(run_ts,3);
	removelistener(setl_tyre);
},0,0);

var run_ts = func {
  ts.listen();
  ts.updateTyresmoke();
  rain();
}

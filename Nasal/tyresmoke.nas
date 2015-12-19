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

### Listeners ###

setlistener("gear/gear[0]/position-norm", func {
	var gear = getprop("gear/gear[0]/position-norm");
	if (gear == 1 ){run_tyresmoke0 = 1}
	else {run_tyresmoke0 = 0}
},1,0);

setlistener("gear/gear[1]/position-norm", func {
	var gear = getprop("gear/gear[1]/position-norm");
	if (gear == 1 ){run_tyresmoke1 = 1}
	else {run_tyresmoke1 = 0}
},1,0);

setlistener("gear/gear[2]/position-norm", func {
	var gear = getprop("gear/gear[2]/position-norm");
	if (gear == 1 ){run_tyresmoke2 = 1}
	else{run_tyresmoke2 = 0}
},1,0);

### Tyre Smoke ###

var tyresmoke = func {
	if (run_tyresmoke0) {tyresmoke_0.update()}
	if (run_tyresmoke1) {tyresmoke_1.update()}
	if (run_tyresmoke2) {tyresmoke_2.update()}
	settimer(tyresmoke, 0);
}
tyresmoke();

### Rain ###

aircraft.rain.init();
var rain = func {
	aircraft.rain.update();
	settimer(rain, 0);
}
rain()

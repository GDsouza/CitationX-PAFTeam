### Voice Recorder ###
### C. Le Moigne (clm76) - 2018 ###

props.globals.initNode("instrumentation/vcr/light",0,"BOOL");
var t=0;

var test = "instrumentation/vcr/test";
var vcr = maketimer(5,func() {
  t=1;
  if (!getprop(test)) {vcr.stop();t=0}
  setprop("instrumentation/vcr/light",t);
});

setlistener(test,func(n) {
  if (n.getValue() and !vcr.isRunning) vcr.start();
  if (!n.getValue()) setprop("instrumentation/vcr/light",0);
},0,0);



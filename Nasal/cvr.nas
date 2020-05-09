### Voice Recorder ###
### C. Le Moigne (clm76) - 2018 ###

var t=0;

var test = "instrumentation/cvr/test";

var cvr = maketimer(5,func() {
  t=1;
  if (!getprop(test)) {cvr.stop();t=0}
  setprop("instrumentation/cvr/light",t);
});

setlistener(test,func(n) {
  if (n.getValue() and !cvr.isRunning) cvr.start();
  if (!n.getValue()) setprop("instrumentation/cvr/light",0);
},0,0);



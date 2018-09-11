### Audio Panel ###
### C. Le Moigne (clm76) - 2018 ###

props.globals.initNode("instrumentation/audio/id-voice",0.5,"DOUBLE");
props.globals.initNode("instrumentation/audio/id",1,"BOOL");
props.globals.initNode("instrumentation/audio/voice",1,"BOOL");
props.globals.initNode("instrumentation/audio/nav1",0,"BOOL");
props.globals.initNode("instrumentation/audio/nav2",0,"BOOL");
props.globals.initNode("instrumentation/audio/adf1",0,"BOOL");
props.globals.initNode("instrumentation/audio/adf2",0,"BOOL");
props.globals.initNode("instrumentation/audio/dme1",0,"BOOL");
props.globals.initNode("instrumentation/audio/dme2",0,"BOOL");
props.globals.initNode("instrumentation/audio/mls1",0,"BOOL");
props.globals.initNode("instrumentation/audio/mls2",0,"BOOL");
props.globals.initNode("instrumentation/audio/mkr",0,"BOOL");
props.globals.initNode("instrumentation/audio/mkr-vol",0.5,"DOUBLE");
props.globals.initNode("instrumentation/audio/mute",0,"BOOL");
props.globals.initNode("instrumentation/audio/com1",0,"BOOL");
props.globals.initNode("instrumentation/audio/com1-vol",1,"DOUBLE");
props.globals.initNode("instrumentation/audio/com2",0,"BOOL");
props.globals.initNode("instrumentation/audio/com2-vol",1,"DOUBLE");
props.globals.initNode("instrumentation/audio/hf",0,"BOOL");
props.globals.initNode("instrumentation/audio/hf-vol",1,"DOUBLE");
props.globals.initNode("instrumentation/audio/speaker",0.7,"DOUBLE");

var id_voice = "instrumentation/audio/id-voice";
var com1 = "instrumentation/audio/com1";
var com1_vol = "instrumentation/audio/com1-vol";
var com2 = "instrumentation/audio/com2";
var com2_vol = "instrumentation/audio/com2-vol";
var nav1 = "instrumentation/audio/nav1";
var nav1_id = "instrumentation/nav/ident";
var nav2 = "instrumentation/audio/nav2";
var nav2_id = "instrumentation/nav[1]/ident";
var dme1 = "instrumentation/audio/dme1";
var dme1_id = "instrumentation/dme/ident";
var dme2 = "instrumentation/audio/dme2";
var dme2_id = "instrumentation/dme[1]/ident";
var adf1 = "instrumentation/audio/adf1";
var adf1_id = "instrumentation/adf/ident-audible";
var adf2 = "instrumentation/audio/adf2";
var adf2_id = "instrumentation/adf[1]/ident-audible";
var hf = "instrumentation/audio/hf";
var hf_vol = "instrumentation/audio/hf-vol";
var id_set = "instrumentation/audio/id";
var voice_set = "instrumentation/audio/voice";
var spkr = "instrumentation/audio/speaker";
var mkr_vol = "instrumentation/audio/mkr-vol";
var mkr_mute = "instrumentation/audio/mute";
var mkr_audio = nil;
var com1_audio = nil;
var com2_audio = nil;
var hf_audio = nil;

var AudioPanel = {
	new: func() {
		var m = {parents:[AudioPanel]};
		return m;
	},

  init : func {
    setprop(nav1_id,1);
    setprop(nav2_id,1);
    setprop(dme1_id,1);
    setprop(dme2_id,1);
    setprop(adf1_id,1);
    setprop(adf2_id,1);
    setprop("instrumentation/comm/volume",0.7);
    setprop("instrumentation/comm[1]/volume",0.7);
    setprop("instrumentation/nav/volume",0);
    setprop("instrumentation/nav[1]/volume",0);
    setprop("instrumentation/dme/volume",0);
    setprop("instrumentation/dme[1]/volume",0);
    setprop("instrumentation/adf/volume-norm",0);
    setprop("instrumentation/adf[1]/volume-norm",0);
    setprop("instrumentation/marker-beacon/volume",0.5);
    setprop("instrumentation/kfs-594/volume",0.7);

    me.mkr_timer = maketimer(5,func() {
      setprop("instrumentation/marker-beacon/volume",mkr_audio);
    });

  }, # end of init

	listen : func {
		setlistener(id_voice, func(n) {
      if (n.getValue() <= 0.6) setprop(id_set,1);
      else setprop(id_set,0);
      if (n.getValue() >= 0.4) setprop(voice_set,1);
      else setprop(voice_set,0);
		},1,0);

    setlistener(id_set,func(n){
      if (!getprop(nav1) and n.getValue()) setprop(nav1_id,1);
      else setprop(nav1_id,0);
      if (!getprop(nav2) and n.getValue()) setprop(nav2_id,1);
      else setprop(nav2_id,0);
      if (!getprop(dme1) and n.getValue()) setprop(dme1_id,1);
      else setprop(dme1_id,0);
      if (!getprop(dme2) and n.getValue()) setprop(dme2_id,1);
      else setprop(dme2_id,0);
      if (!getprop(adf1) and n.getValue()) setprop(adf1_id,1);
      else setprop(adf1_id,0);
      if (!getprop(adf2) and n.getValue()) setprop(adf2_id,1);
      else setprop(adf2_id,0);
    },1,0);

    setlistener(com1,func(n){
      if (n.getValue()) com1_audio = 0;
      else com1_audio = getprop(com1_vol);
      setprop("instrumentation/comm/volume",com1_audio*getprop(spkr));
    },1,0);

    setlistener(com1_vol,func(n){
      setprop("instrumentation/comm/volume",getprop(spkr)*n.getValue());
    },1,0);

    setlistener(com2,func(n){
      if (n.getValue()) com2_audio = 0;
      else com2_audio = getprop(com2_vol);
      setprop("instrumentation/comm[1]/volume",com2_audio*getprop(spkr));
    },1,0);

    setlistener(com2_vol,func(n){
      setprop("instrumentation/comm[1]/volume",getprop(spkr)*n.getValue());
    },1,0);

    setlistener(hf,func(n){
      if (n.getValue()) hf_audio = 0;
      else hf_audio = getprop(hf_vol);
      setprop("instrumentation/kfs-594/volume",hf_audio*getprop(spkr));
    },1,0);

    setlistener(hf_vol,func(n){
      setprop("instrumentation/kfs-594/volume",getprop(spkr)*n.getValue());
    },1,0);

    setlistener(spkr,func(n){
      setprop("instrumentation/comm/volume",com1_audio*n.getValue());
      setprop("instrumentation/comm[1]/volume",com2_audio*n.getValue());
      setprop("instrumentation/kfs-594/volume",hf_audio*n.getValue());
    },1,0);

    setlistener(mkr_vol,func(n){
      setprop("instrumentation/marker-beacon/volume",getprop(mkr_vol));
    },1,0);

    setlistener(mkr_mute,func(n){
      if (n.getValue()) {
        if (!me.mkr_timer.isRunning) {
          mkr_audio = getprop("instrumentation/marker-beacon/volume");
          setprop("instrumentation/marker-beacon/volume",0.2);
          me.mkr_timer.singleShot = 1;
          me.mkr_timer.start();
        }
      } 
    },1,0);

	}, # end of listen

}; # end of AudioPanel

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var main = AudioPanel.new();
  main.init();
	main.listen();
removelistener(setl);
});


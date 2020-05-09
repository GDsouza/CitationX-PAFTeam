### Audio Panel ###
### C. Le Moigne (clm76) 2018 - modified 2019 ###

var com1 = "instrumentation/audio/com1";
var com1_knob = "instrumentation/audio/com1-knob";
var com2 = "instrumentation/audio/com2";
var com2_knob = "instrumentation/audio/com2-knob";
var nav1 = "instrumentation/audio/nav1";
var nav1_knob = "instrumentation/audio/nav1-knob";
var nav1_id = "instrumentation/nav/ident";
var nav2 = "instrumentation/audio/nav2";
var nav2_knob = "instrumentation/audio/nav2-knob";
var nav2_id = "instrumentation/nav[1]/ident";
var dme1 = "instrumentation/audio/dme1";
var dme1_knob = "instrumentation/audio/dme1-knob";
var dme1_id = "instrumentation/dme/ident";
var dme2 = "instrumentation/audio/dme2";
var dme2_knob = "instrumentation/audio/dme2-knob";
var dme2_id = "instrumentation/dme[1]/ident";
var adf1 = "instrumentation/audio/adf1";
var adf1_knob = "instrumentation/audio/adf1-knob";
var adf1_id = "instrumentation/adf/ident-audible";
var adf2 = "instrumentation/audio/adf2";
var adf2_knob = "instrumentation/audio/adf2-knob";
var adf2_id = "instrumentation/adf[1]/ident-audible";
var hf = "instrumentation/audio/hf";
var hf_knob = "instrumentation/audio/hf-knob";
var id_set = "instrumentation/audio/id";
var id_voice = "instrumentation/audio/id-voice";
var voice_set = "instrumentation/audio/voice";
var spkr = "instrumentation/audio/speaker";
var mkr_knob = "instrumentation/audio/mkr-knob";
var mkr_mute = "instrumentation/audio/mute";
var elec_audio1 = "systems/electrical/outputs/audio1";
var elec_audio2 = "systems/electrical/outputs/audio2";
var kfs594_knob = "instrumentation/kfs-594/vol-knob";

var com1Vol = "instrumentation/comm/volume";
var com2Vol = "instrumentation/comm[1]/volume";
var nav1Vol = "instrumentation/nav/volume";
var nav2Vol = "instrumentation/nav[1]/volume";
var dme1Vol = "instrumentation/dme/volume";
var dme2Vol = "instrumentation/dme[1]/volume";
var adf1Vol = "instrumentation/adf/volume-norm";
var adf2Vol = "instrumentation/adf[1]/volume-norm";
var mkrVol = "instrumentation/marker-beacon/volume";
var hfVol = "instrumentation/kfs-594/volume";

var com1_audio = nil;
var com2_audio = nil;
var nav1_audio = nil;
var nav2_audio = nil;
var hf_audio = nil;
var adf1_audio = nil;
var adf2_audio = nil;
var dme1_audio = nil;
var dme2_audio = nil;
var mkr_audio = nil;

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
    setprop(com1Vol,0);
    setprop(com2Vol,0);
    setprop(nav1Vol,0);
    setprop(nav2Vol,0);
    setprop(dme1Vol,0);
    setprop(dme2Vol,0);
    setprop(adf1Vol,0);
    setprop(adf2Vol,0);
    setprop(mkrVol,0.5);
    setprop(hfVol,0);

    me.elecAudio1_enabled = 0;
    me.elecAudio2_enabled = 0;
    
    me.mkr_timer = maketimer(5,func() {
      setprop(mkrVol,mkr_audio);
    });

  }, # end of init

	listen : func {
		setlistener(elec_audio1, func(n) {
      me.elecAudio1_enabled = n.getValue() ? 1 : 0;
      com1_audio = me.elecAudio1_enabled ? getprop(com1_knob) : 0;
      setprop(com1Vol,com1_audio*getprop(spkr));
      nav1_audio = me.elecAudio1_enabled ? getprop(nav1_knob) : 0;
      setprop(nav1Vol,nav1_audio*getprop(spkr));
      adf1_audio = me.elecAudio1_enabled ? getprop(adf1_knob) : 0;
      setprop(adf1Vol,adf1_audio*getprop(spkr));
      dme1_audio = me.elecAudio1_enabled ? getprop(dme1_knob) : 0;
      setprop(dme1Vol,dme1_audio*getprop(spkr));
      hf_audio = me.elecAudio1_enabled ? getprop(hf_knob) : 0;
      setprop(hfVol,hf_audio*getprop(kfs594_knob)*getprop(spkr));
      mkr_audio = me.elecAudio1_enabled ? getprop(mkr_knob) : 0;
      setprop(mkrVol,mkr_audio);
		},0,0);

		setlistener(elec_audio2, func(n) {
      me.elecAudio2_enabled = n.getValue() ? 1 : 0;
      com2_audio = me.elecAudio2_enabled ? getprop(com2_knob) : 0;
      setprop(com2Vol,com2_audio*getprop(spkr));
      nav2_audio = me.elecAudio2_enabled ? getprop(nav2_knob) : 0;
      setprop(nav2Vol,nav2_audio*getprop(spkr));
      adf2_audio = me.elecAudio2_enabled ? getprop(adf2_knob) : 0;
      setprop(adf2Vol,adf2_audio*getprop(spkr));
      dme2_audio = me.elecAudio2_enabled ? getprop(dme2_knob) : 0;
      setprop(dme2Vol,dme2_audio*getprop(spkr));
		},0,0);
        
    setlistener(com1,func(n){
      if (n.getValue() or !me.elecAudio1_enabled) com1_audio = 0;
      else com1_audio = getprop(com1_knob);
      setprop(com1Vol,com1_audio*getprop(spkr));
    },0,0);

    setlistener(com1_knob,func(n){
      if (me.elecAudio1_enabled) setprop(com1Vol,getprop(spkr)*n.getValue());
      else setprop(com1Vol,0);
    },0,0);

    setlistener(com2,func(n){
      if (n.getValue() or !me.elecAudio2_enabled) com2_audio = 0;
      else com2_audio = getprop(com2_knob);
      setprop(com2Vol,com2_audio*getprop(spkr));
    },0,0);

    setlistener(com2_knob,func(n){
      if (me.elecAudio2_enabled) setprop(com2Vol,getprop(spkr)*n.getValue());
      else setprop(com2Vol,0);
    },0,0);

    setlistener(nav1,func(n){
      if (n.getValue() or !me.elecAudio1_enabled) nav1_audio = 0;
      else nav1_audio = getprop(nav1_knob);
      setprop(nav1Vol,nav1_audio*getprop(spkr));
    },0,0);

    setlistener(nav1_knob,func(n){
      if (me.elecAudio1_enabled) setprop(nav1Vol,getprop(spkr)*n.getValue());
      else setprop(nav1Vol,0);
    },0,0);

    setlistener(nav2,func(n){
      if (n.getValue() or !me.elecAudio2_enabled) nav2_audio = 0;
      else nav2_audio = getprop(nav2_knob);
      setprop(nav2Vol,nav2_audio*getprop(spkr));
    },0,0);

    setlistener(nav2_knob,func(n){
      if (me.elecAudio2_enabled) setprop(nav2Vol,getprop(spkr)*n.getValue());
      else setprop(nav2Vol,0);
    },0,0);

    setlistener(adf1,func(n){
      if (n.getValue() or !me.elecAudio1_enabled) adf1_audio = 0;
      else adf1_audio = getprop(adf1_knob);
      setprop(adf1Vol,adf1_audio*getprop(spkr));
    },0,0);

    setlistener(adf1_knob,func(n){
      if (me.elecAudio1_enabled) setprop(adf1Vol,getprop(spkr)*n.getValue());
      else setprop(adf1Vol,0);
    },0,0);

    setlistener(adf2,func(n){
      if (n.getValue() or !me.elecAudio2_enabled) adf2_audio = 0;
      else adf2_audio = getprop(adf2_knob);
      setprop(adf2Vol,adf2_audio*getprop(spkr));
    },0,0);

    setlistener(adf2_knob,func(n){
      if (me.elecAudio2_enabled) setprop(adf2Vol,getprop(spkr)*n.getValue());
      else setprop(adf2Vol,0);
    },0,0);

    setlistener(dme1,func(n){
      if (n.getValue() or !me.elecAudio1_enabled) dme1_audio = 0;
      else dme1_audio = getprop(dme1_knob);
      setprop(dme1Vol,dme1_audio*getprop(spkr));
    },0,0);

    setlistener(dme1_knob,func(n){
      if (me.elecAudio1_enabled) setprop(dme1Vol,getprop(spkr)*n.getValue());
      else setprop(dme1Vol,0);
    },0,0);

    setlistener(dme2,func(n){
      if (n.getValue() or !me.elecAudio2_enabled) dme2_audio = 0;
      else dme2_audio = getprop(dme2_knob);
      setprop(dme2Vol,dme2_audio*getprop(spkr));
    },0,0);

    setlistener(dme2_knob,func(n){
      if (me.elecAudio2_enabled) setprop(dme2Vol,getprop(spkr)*n.getValue());
      else setprop(dme2Vol,0);
    },0,0);

    setlistener(hf,func(n){
      if (n.getValue() or !me.elecAudio1_enabled) hf_audio = 0;
      else hf_audio = getprop(hf_knob);
      setprop(hfVol,hf_audio*getprop(kfs594_knob)*getprop(spkr));
    },0,0);

    setlistener(hf_knob,func(n){
      if (me.elecAudio1_enabled) {
        setprop(hfVol,getprop(kfs594_knob)*getprop(spkr)*n.getValue());
      } else setprop(hfVol,0);
    },0,0);

    setlistener(spkr,func(n){
      setprop(com1Vol,getprop(com1_knob)*n.getValue());
      setprop(com2Vol,getprop(com2_knob)*n.getValue());
      setprop(nav1Vol,getprop(nav1_knob)*n.getValue());
      setprop(nav2Vol,getprop(nav2_knob)*n.getValue());
      setprop(dme1Vol,getprop(dme1_knob)*n.getValue());
      setprop(dme2Vol,getprop(dme2_knob)*n.getValue());
      setprop(hfVol,getprop(hf_knob)*getprop(kfs594_knob)*n.getValue());
    },0,0);

    setlistener(mkr_knob,func(n){
      if (me.elecAudio1_enabled) setprop(mkrVol,n.getValue());
      else setprop(mkrVol,0);
    },0,0);

    setlistener(mkr_mute,func(n){
      if (n.getValue()) {
        if (!me.mkr_timer.isRunning) {
          mkr_audio = getprop(mkrVol);
          setprop(mkrVol,0.2);
          me.mkr_timer.singleShot = 1;
          me.mkr_timer.start();
        }
      } 
    },1,0);

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

	}, # end of listen

}; # end of AudioPanel

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var audio = AudioPanel.new();
  audio.init();
	audio.listen();
removelistener(setl);
});


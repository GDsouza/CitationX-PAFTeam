### Canvas HF Comm ###
### C. Le Moigne (clm76) - 2018 ###

props.globals.initNode("instrumentation/kfs-594/mode",0,"INT");
props.globals.initNode("instrumentation/kfs-594/store",0,"BOOL");
props.globals.initNode("instrumentation/kfs-594/volume",0.7,"DOUBLE");
props.globals.initNode("instrumentation/kfs-594/squelch",0.4,"DOUBLE");
props.globals.initNode("instrumentation/kfs-594/freq-nb",0,"INT");
props.globals.initNode("instrumentation/kfs-594/prog",0,"INT");
props.globals.initNode("instrumentation/kfs-594/channel-nb",1,"INT");
props.globals.initNode("instrumentation/kfs-594/xfer",0,"BOOL");

var freq_nb = "instrumentation/kfs-594/freq-nb";
var chn = "instrumentation/kfs-594/channel-nb";
var sto = "instrumentation/kfs-594/store";
var freq_chan = "instrumentation/kfs-594/freq-chan";
var mode = "instrumentation/kfs-594/mode";
var prog = 0;
var t = 0;
var path = getprop("/sim/fg-home")~"/Export/CitationX/";
var memPath = [nil];
var memVec = [];
var hf_mem = nil;
var hfVec = nil;
var name = nil;
var data = nil;

var HF = {
	new: func() {
		var m = {parents:[HF]};
		m.canvas = canvas.new({
			"name": "HF", 
			"size": [1024, 1024],
			"view": [420,420],
			"mipmapping": 1 
		});

		m.canvas.addPlacement({"node": "HFscreen"});
		m.HF = m.canvas.createGroup();
		canvas.parsesvg(m.HF,"Aircraft/CitationX/Models/Instruments/HF/HF.svg");
    m.digit = {};
		m.text = {};
		m.text_dg = ["dg1","dg2","dg3","dg4","dg5","dg6"];
    m.text_oth = ["channel","ch","dash","err"];
		foreach(var i;m.text_dg) {
			m.digit[i] = m.HF.getElementById(i);
		}
		foreach(var i;m.text_oth) {
			m.text[i] = m.HF.getElementById(i);
		}
    m.text_dot = m.HF.getElementById("dot");
    
		return m;
	},

  init : func {
    me.text.dash.hide();
    me.text.err.hide();
    setprop("instrumentation/kfs-594/freq-chan","CHAN");

		var HFpath = os.path.new(getprop("/sim/fg-home")~"/Export/CitationX/create.txt");
    if (!HFpath.exists()) {
      HFpath.create_dir();
    }

  	### Create Memories if missing ###
    memPath = path~"HFmem.xml";
    var xfile = subvec(directory(path),2);
    var v = std.Vector.new(xfile);
    if (!v.contains("HFmem.xml")) {
	    var base = props.Node.new({
		    chan1 : "020000",chan2 : "020000",chan3 : "020000",chan4 : "020000",
        chan5 : "020000",chan6 : "020000",chan7 : "020000",chan8 : "020000",
        chan9 : "020000",chan10 : "020000",chan11 : "020000",chan12 :"020000",
        chan13 : "020000",chan14 : "020000",chan15 : "020000",
        chan16 : "020000",chan17 : "020000",chan18 : "020000",chan19 : "020000"
	    });		
	    io.write_properties(memPath,base);
    } 

	  ### Load Memories ###
    hfVec = {};
    hf_mem = ["chan1","chan2","chan3","chan4","chan5","chan6","chan7",
              "chan8","chan9","chan10","chan11","chan12","chan13","chan14",
              "chan15","chan16","chan17","chan18","chan19"];
    data = io.read_properties(memPath);
    foreach(var i;hf_mem) {
	    hfVec[i] = data.getValue(i);
    }
    me.frq = hfVec[hf_mem[0]];

    ### For Frequency Mode ###
    me.freq = "020000";

    ### For A3A - A3J Modes ###
    me.a3 = "   401";
    me.th = " 4";
    me.diz = "0";
    me.unit = "1";

	  ### Display Frequency ###
    me.display_freq(me.frq);

	  ### Prog Timer ###
    me.dg_timer = maketimer(0.3,func() {
      if (t==0) {
        me.digit[me.text_dg[prog-1]].hide();
        if (getprop(mode)>=2 and prog==4) me.digit[me.text_dg[prog-2]].hide();
      }
      if (t==1) {
        me.digit[me.text_dg[prog-1]].show();
        if (getprop(mode)>=2 and prog==4) me.digit[me.text_dg[prog-2]].show();
      }
      t+=1;
      if (t==2) {t=0}
    });

	  ### Error Timer ###
    me.err_timer = maketimer(0.3,func() {
      if (t==0) me.text.err.hide();
      if (t==1) me.text.err.show();
      t+=1;
      if (t==2) {t=0}
    });

  }, # end of init

	listen : func {
		setlistener(freq_chan, func(n) {
      prog = 0;
      me.text.dash.hide();
      if (me.dg_timer.isRunning) me.dg_timer.stop();
			if (n.getValue()=="FREQ") {
        me.text.channel.hide();
        me.text.ch.hide();
        me.display_freq(me.freq);
        me.save_freq();
      } else {
        me.text.channel.show();
        me.text.ch.show();
        me.display_freq(me.frq);        
      }
		},1,0);

		setlistener(mode, func(n) {
      prog = 0;
      me.text.err.hide();
      if (me.dg_timer.isRunning) me.dg_timer.stop();
      if (me.err_timer.isRunning) me.err_timer.stop();
        if (n.getValue()==-1 or n.getValue()==3) {
          if (!me.err_timer.isRunning) me.err_timer.start();
        }
      if (n.getValue()>=2) {
        me.text.channel.show();
        me.text.ch.hide();
        me.text_dot.hide();
        me.display_freq(me.a3);        
        setprop(freq_nb,0);
      } else {
        me.text_dot.show();
  			if (getprop(freq_chan)=="FREQ") {
          me.text.channel.hide();
          me.text.ch.hide();
          me.display_freq(me.freq);
        } else {        
          me.text.channel.show();
          me.text.ch.show();
          me.text_dot.show();
          me.display_freq(me.frq);        
        }
      }
		},1,0);

		setlistener(chn, func(n) {
      if (me.dg_timer.isRunning) me.dg_timer.stop();
      me.text.ch.setText(sprintf("%.0f",getprop(chn)));
      me.frq = hfVec[hf_mem[getprop(chn)-1]];
      me.display_freq(me.frq);
		},1,0);

		setlistener("instrumentation/kfs-594/prog", func(n) {
			if (n.getValue()) {
        if (prog > 5) {
          prog = 0;
          me.dg_timer.stop();
          me.text.dash.hide();
          me.digit[me.text_dg[5]].show();
          if (getprop(freq_chan) == "FREQ") me.save_freq();
        } else {
          if (getprop(mode) > 1 and prog < 3) prog = 3;
          me.text.dash.show();
          if (!me.dg_timer.isRunning) me.dg_timer.start();
          me.digit[me.text_dg[prog-1]].show();
          me.digit[me.text_dg[prog-2]].show();
          if (getprop(freq_chan) == "FREQ") me.save_freq();
          prog+=1;
          if (prog > 0 and !prog ==4 and !getprop(mode)>=2) {
            setprop(freq_nb,me.digit[me.text_dg[prog-1]].getText());
          }
        }
      }
		},1,0);

		setlistener(freq_nb, func(n) {
      if (getprop(mode) < 2) {
        if (prog > 0) {
          if (prog == 1 and n.getValue() > 2) setprop(freq_nb,0);
          else if (n.getValue() > 9) setprop(freq_nb,0);
          me.digit[me.text_dg[prog-1]].setText(sprintf("%.0f",n.getValue()));
          if (getprop(freq_chan) == "FREQ") me.save_freq();
        } else setprop(chn,getprop(freq_nb)+1);
      } else {
        if (prog == 4) {
          if (n.getValue()==0) me.th = " 4";
          if (n.getValue()==1) me.th = " 6";
          if (n.getValue()==2) me.th = " 8";
          if (n.getValue()==3) me.th = "12";
          if (n.getValue()==4) me.th = "16";
          if (n.getValue()==5) me.th = "18";
          if (n.getValue()==6) me.th = "22";
          if (n.getValue()>=7) me.th = "25";
        }
        if (prog == 5) {
          if (me.th==" 4" and n.getValue()>2) n.setValue(0);
          if (me.th==" 6" and n.getValue()>0) n.setValue(0);
          if (me.th==" 8" and n.getValue()>3) n.setValue(0);
          if (me.th=="12" and n.getValue()>4) n.setValue(0);
          if (me.th=="16" and n.getValue()>5) n.setValue(0);
          if (me.th=="18" and n.getValue()>1) n.setValue(0);
          if (me.th=="22" and n.getValue()>5) n.setValue(0);
          if (me.th=="25" and n.getValue()>1) n.setValue(0);
          me.diz = n.getValue();
        }
        if (prog == 6) {
          if (me.th==" 4" and me.diz==2 and n.getValue()>8) n.setValue(0);
          if (me.th==" 6" and n.getValue()>8) n.setValue(0);
          if (me.th==" 8" and me.diz==3 and n.getValue()>7) n.setValue(0);
          if (me.th=="12" and me.diz==4 and n.getValue()>1) n.setValue(0);
          if (me.th=="16" and me.diz==5 and n.getValue()>6) n.setValue(0);
          if (me.th=="18" and me.diz==1 and n.getValue()>5) n.setValue(0);
          if (me.th=="22" and me.diz==5 and n.getValue()>3) n.setValue(0);
          if (me.th=="25" and n.getValue()>0) n.setValue(0);
          me.unit = n.getValue();
        }
        me.a3 = "  "~me.th~me.diz~me.unit;
        me.display_freq(me.a3);
      }
		},1,0);

		setlistener(sto, func(n) {
      if (n.getValue() and getprop(freq_chan) == "CHAN" and getprop(mode)<2) {
        me.frq = "";
        for (var i=0;i<6;i+=1) {
          me.frq = me.frq~me.digit[me.text_dg[i]].getText();
        }
        name = data.getChild(hf_mem[getprop(chn)-1]);
        name.setValue(me.frq);
        io.write_properties(memPath,data);
        hfVec[hf_mem[getprop(chn)-1]] = me.frq;        
        if (me.dg_timer.isRunning) me.dg_timer.stop();
        me.text.dash.hide();
        me.digit[me.text_dg[prog-1]].show();
        prog = 0;
      }
		},1,0);

	}, # end of listen

  display_freq : func(display) {
    for (var i=0;i<6;i+=1) {
      me.digit[me.text_dg[i]].setText(substr(display,i,1));
      me.digit[me.text_dg[i]].show();
    }
  }, # end of display_freq

  save_freq : func {
    me.freq = "";
    for (var i=0;i<6;i+=1) {
      me.freq = me.freq~me.digit[me.text_dg[i]].getText();
    }
  }, # end of save_freq


}; # end of HF

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var main = HF.new();
  main.init();
	main.listen();
removelistener(setl);
});


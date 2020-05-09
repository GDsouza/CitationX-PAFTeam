### Engines Fire   ###
### C. Le Moigne (clm76) - 2020 ###

var eng_running = ["controls/engines/engine/running",
                   "controls/engines/engine[1]/running"];
var path = "controls/fire/";

var Engines_fire = {
  new : func () {
    var m = {parents:[Engines_fire]};
    return m
  }, # end of new

  listen : func {
    setlistener(path~"engines-fire", func (n) {
	    if (n.getValue()) {
        if (getprop(eng_running[0]) or getprop(eng_running[1])) {
          gui.popupTip("Engine Fire activated",10);
          me.engine_sel();
        } else {
          gui.popupTip("No engine running",3);
          setprop(path~"engines-fire",0);
        }
      }
    },0,0);

    setlistener(path~"left-eng-pushed", func(n){
      if (n.getValue()) {
        if (getprop(path~"left-eng-fire-detect")) {
          setprop(path~"bottles",1);
          setprop("controls/engines/engine/cutoff",1);
          setprop("controls/electric/engine/generator",0);
        } else setprop(path~"bottles",0);  
      }
    },0,0);

    setlistener(path~"right-eng-pushed", func(n){
      if (n.getValue()) {
        if (getprop(path~"right-eng-fire-detect")) {
          setprop(path~"bottles",1);
          setprop("controls/engines/engine[1]/cutoff",1);
          setprop("controls/electric/engine[1]/generator",0);
        } else setprop(path~"bottles",0);  
      }
    },0,0);

    setlistener(path~"bottle1-pushed", func(n){
      if (n.getValue()) {me.bottle_sel = 1;me.bottle.start()}
    },0,0);

    setlistener(path~"bottle2-pushed", func(n){
      if (n.getValue()){me.bottle_sel = 2;me.bottle.start()}
    },0,0);

  }, # end of listen

  fire_timer : func {
    me.fire = maketimer(15 + rand()*45,func() {me.start_fire();});
  }, # end of update_timer

  bottle_timer : func {
    me.bottle = maketimer(20,func() {me.stop_fire();});
  }, # end of update_timer

  engine_sel : func {
    if (getprop(eng_running[0]) and getprop(eng_running[1]))
      me.eng_sel = rand() < 0.5 ? "left" : "right";
    else if (getprop(eng_running[0]) and !getprop(eng_running[1]))
      me.eng_sel = "left";
    else if (!getprop(eng_running[0]) and getprop(eng_running[1]))
      me.eng_sel = "right";
    else return;
    me.eng = me.eng_sel == "left" ? 0 : 1;
    me.fire.start();
  }, # end of engine_sel

  start_fire : func {
      setprop(path~ me.eng_sel~"-eng-fire-detect",1);
      me.fire.stop();
  }, # end of start_fire

  stop_fire : func {
    setprop(path~me.eng_sel~"-eng-fire-detect",0);
    me.bottle.stop();
    setprop(path~"bottle"~me.bottle_sel~"-low",1);
    setprop(path~"bottles",0);
  }, # end of stop_fire

}; # end of Engines_fire

var fire_stl = setlistener("/sim/signals/fdm-initialized", func {
    var fire = Engines_fire.new();
    fire.listen();
    fire.fire_timer();
    fire.bottle_timer();
    removelistener(fire_stl);
},0,0);


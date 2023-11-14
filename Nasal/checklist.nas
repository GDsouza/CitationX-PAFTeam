## Citation X ##
## Checklists System ##
## Christian Le Moigne (clm76) - Mai 2020 ##

var abn = ["instrumentation/dc840/abn",
             "instrumentation/dc840[1]/abn"];
var elec = ["systems/electrical/outputs/disp-cont1",
            "systems/electrical/outputs/disp-cont2"];
var norm = ["instrumentation/checklists/chklst-pilot",
            "instrumentation/checklists/chklst-copilot"];
var nr_page = ["instrumentation/checklists/nr-page",
               "instrumentation/checklists/nr-page[1]"];
var skp = ["instrumentation/dc840/skip-btn",
            "instrumentation/dc840[1]/skip-btn"];
var throttle = ["controls/engines/engine/throttle",
                "controls/engines/engine[1]/throttle"];

var root = getprop("/sim/aircraft-dir")~"/Sounds/Checklists/";
var pge = [0,0];
var page = 0;
var tittle = "";
var chklst = 0;
var nr_voice = nil;
var nr_ligne = nil;
var upd = [0,0];
var nb = 0;
var np = nil;
var prop = nil;
var running = nil;
var skip = [0,0];

var L = [
  var L0 = [
    {titre: 'COLD START WITH EXT PWR',                          check : nil},
    {name: 'External Preflight',    val : 'COMPLETE',           check : 0},
    {name: 'Documents',             val : 'ON BOARD',           check : 0},
    {name: 'Parking Brake',         val : 'SET',                check : 0},
    {name: 'Throttles',             val : 'CUT-OFF',            check : 0},
    {name: 'Standby Power',         val : 'ON',                 check : 0},
    {name: 'Batteries 1 - 2',       val : 'ON',                 check : 0},
    {name: 'External Power',        val : 'ON',                 check : 0},
    {name: 'Avionics Switch',       val : 'ON',                 check : 0},
  ],
  var L1 = [
    {titre: 'COLD START WITH APU',                              check : nil},
    {name: 'External Preflight',    val : 'COMPLETE',           check : 0},
    {name: 'Documents',             val : 'ON BOARD',           check : 0},
    {name: 'Parking Brake',         val : 'SET',                check : 0},
    {name: 'Throttles',             val : 'CUT-OFF',            check : 0},
    {name: 'Standby Power',         val : 'ON',                 check : 0},
    {name: 'Batteries 1 - 2',       val : 'ON',                 check : 0},
    {name: 'APU Master Switch',     val : 'ON',                 check : 0},
    {name: 'APU Test Button',       val : 'VERIFY',             check : 0},
    {name: 'APU Start Switch',      val : 'ON',                 check : 0},
    {name: 'APU Ready To Load',     val : 'ILLUMINATED',        check : 0},
    {name: 'APU Generator Switch',  val : 'ON',                 check : 0},
    {name: 'APU DC Volts',          val : 'CHECK 28v',          check : 0},
    {name: 'APU Bleed Air',         val : 'ON',                 check : 0},
    {name: 'Bleed Valve Open',      val : 'ILLUMINATED',        check : 0},
    {name: 'Avionics Switch',       val : 'ON',                 check : 0},
  ],
  var L2 = [
    {titre: 'BEFORE ENGINES START-UP',                          check : nil},
    {name: 'Passengers',            val : 'BOARD and BRIEF',    check : 0},
    {name: 'Cabin Door',            val : 'CLOSE and LATCH',    check : 0},
    {name: 'Emergency Lights',      val : 'ARM',                check : 0},
    {name: 'Seat Belts Lights',     val : 'PASS SAFETY',        check : 0},
    {name: 'Radio',                 val : 'CHECK',              check : 0},
    {name: 'Fuel Quantity',         val : 'CHECK',              check : 0},
    {name: 'Warnings Test',         val : 'COMPLETE',           check : 0},
    {name: 'Gnd Rec Lights',        val : 'ON',                 check : 0},
    {name: 'Engines Area',          val : 'CLEAR',              check : 0},
  ],
  var L3 = [
    {titre: 'RIGHT ENGINE START-UP',                            check : nil},
    {name: 'Right Throttle',        val : 'IDLE',               check : 0},
    {name: 'Ignition Switch',       val : 'NORMAL',             check : 0},
    {name: 'Starter',               val : 'ON',                 check : 0},
    {name: 'Right Generator',       val : 'ON',                 check : 0},
    {name: 'N2 at 56 pct',          val : 'VERIFY',             check : 0},
    {name: 'N1 Rotation',           val : 'CONFIRM',            check : 0},
    {name: 'Oil Pressure',          val : 'CHECK',              check : 0},
    {name: 'ITT Stable',            val : 'VERIFY',             check : 0},
    {name: 'Volts Amp Oil',         val : 'CHECK',              check : 0},
  ],
  var L4 = [
    {titre: 'LEFT ENGINE START-UP',                             check : nil},
    {name: 'Left Throttle',         val : 'IDLE',               check : 0},
    {name: 'Ignition Switch',       val : 'NORMAL',             check : 0},
    {name: 'Starter',               val : 'ON',                 check : 0},
    {name: 'Left Generator',        val : 'ON',                 check : 0},
    {name: 'N2 at 56 pct',          val : 'VERIFY',             check : 0},
    {name: 'N1 Rotation',           val : 'CONFIRM',            check : 0},
    {name: 'Oil Pressure',          val : 'CHECK',              check : 0},
    {name: 'ITT Stable',            val : 'VERIFY',             check : 0},
    {name: 'Volts Amp Oil',         val : 'CHECK',              check : 0},
  ],
  var L5 = [
    {titre: 'BEFORE TAXIING',                                   check : nil},
    {name: 'External Power',        val : 'OFF',                check : 0},
    {name: 'Flight Controls',       val : 'FREE',               check : 0},
    {name: 'L-R Pitot Heat',        val : 'ON',                 check : 0},
    {name: 'L-R WSHD Heat',         val : 'ON',                 check : 0},
    {name: 'Pressurization',        val : 'CHECK',              check : 0},
    {name: 'Seat Belts Lights',     val : 'ON',                 check : 0},
    {name: 'Passengers Oxygen',     val : 'AUTO',               check : 0},
    {name: 'Transponder',           val : 'CODE SET STBY',      check : 0},
    {name: 'Altimeter',             val : 'SET',                check : 0},
    {name: 'Flight Plan Clearance', val : 'COPY',               check : 0},
    {name: 'Taxi Instructions',     val : 'RECEIVE',            check : 0},
    {name: 'Anti Coll Lights',      val : 'ON',                 check : 0},
    {name: 'Navigation Lights',     val : 'ON',                 check : 0},
  ],
  var L6 = [
    {titre: 'TAXIING',                                          check : nil},
    {name: 'Parking Brake',         val : 'RELEASE',            check : 0},
    {name: 'Flaps',                 val : '15 deg',             check : 0},
    {name: 'Speed Brakes',          val : 'RETRACT',            check : 0},
    {name: 'Taxi Lights',           val : 'ON',                 check : 0},
    {name: 'Landing Lights',        val : 'ON',                 check : 0},
    {name: 'Annunciator Panel',     val : 'CLEAR',              check : 0},
    {name: 'Transponder',           val : 'ATC ALT',            check : 0},
  ],
  var L7 = [
    {titre: 'TAKE-OFF',                                         check : nil},
    {name: 'Flight Timer',          val : 'SET',                check : 0},
    {name: 'Brakes',                val : 'HOLD',               check : 0},
    {name: 'Throttles',             val : 'TAKEOFF THRUST',     check : 0},
    {name: 'Brakes',                val : 'RELEASE',            check : 0},
  ],
  var L8 = [
    {titre: 'AFTER TAKE-OFF',                                   check : nil},
    {name: 'Landing Gear',          val : 'RETRACT',            check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: '        Above 170 KIAS',val : '',                   check : 0},
    {name: 'Flaps',                 val : 'RETRACT',            check : 0},
    {name: 'EICAS',                 val : 'CHECK NORMAL',       check : 0},
    {name: 'Annunciator Panel',     val : 'CHECK',              check : 0},
    {name: 'Instruments',           val : 'CHECK',              check : 0},
    {name: 'Both Engines',          val : 'N1 max 98 pct',      check : 0},
  ],
  var L9 = [
    {titre: 'CLIMB',                                            check : nil},
    {name: 'Climb speed 250 KIAS/2500 fpm',val : '',            check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: 'Autopilot',             val : 'CHECK',              check : 0},
    {name: 'Fuel Quantity',         val : 'CHECK',              check : 0},
    {name: 'Taxi Lights',           val : 'OFF',                check : 0},
    {name: 'Landing Lights',        val : 'OFF',                check : 0},
    {name: 'Pressurization',        val : 'CHECK',              check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: 'Above FL180 set altimeter to 29.92',val : '',       check : 0},
  ],
  var L10 = [
    {titre: 'APU SHUTDOWN',                                     check : nil},
    {name: 'APU Generator',         val : 'OFF',                check : 0},
    {name: 'APU Bleed Air',         val : 'OFF',                check : 0},
    {name: 'APU Start Switch',      val : 'STOP',               check : 0},
    {name: 'READY TO LOAD',         val : 'EXTINGUISHED',       check : 0},
    {name: 'APU Master Switch',     val : 'OFF',                check : 0},
  ],
  var L11 = [
    {titre: 'CRUISE',                                           check : nil},
    {name: 'Seat Belts Lights',     val : 'PASS SAFETY',        check : 0},
    {name: 'Engines Instruments',   val : 'CHECK',              check : 0},
    {name: 'Fuel Quantity',         val : 'CHECK',              check : 0},
    {name: 'Pressurization',        val : 'CHECK',              check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: 'Max Spd below 8000 ft is 270 KIAS', val : '',       check : 0},
    {name: 'Max Spd FL 80 to FL 310 is 350 KIAS', val : '',     check : 0},
    {name: 'Max Spd above FL 310 is 0.92 MACH', val : '',       check : 0},
  ],
  var L12 = [
    {titre: 'DESCENT',                                          check : nil},
    {name: 'Seat Belts lights',     val : 'ON',                 check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: 'APU AS DESIRED below FL310', val : '',              check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: 'Max Spd above FL 310 is 0.92 MACH', val : '',       check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: 'Max Spd FL 310 to FL 80 is 350 KIAS', val : '',     check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: 'Max Spd below 8,000 ft is 270 KIAS', val : '',      check : 0},
  ],
  var L13 = [
    {titre: 'APPROACH',                                         check : nil},
    {name: 'Altimeter',             val : 'SET TO LOCAL',       check : 0},
    {name: 'Seat Belts Lights',     val : 'ON',                 check : 0},
    {name: 'Landing lights',        val : 'ON',                 check : 0},
    {name: 'Speedbrakes as required', val : '',                 check : 0},
    {name: 'Airspeed',              val : 'MAX 250 KIAS',       check : 0},
    {name: 'At approximately 7nm from Runway',val : '',         check : 0},
    {name: 'Flaps',                 val : 'SET 5 deg',          check : 0},
    {name: 'Slats',                 val : 'DEPLOYED',             check : 0},
    {name: 'Airspeed',              val : 'MAX 210 KIAS',       check : 0},
    {name: 'Flaps',                 val : 'SET 15 deg',         check : 0},
    {name: 'Landing Gear',          val : 'DOWN',               check : 0},
    {name: '           Short Final',val : '',                   check : 0},
    {name: 'Airspeed',              val : 'MAX 180 KIAS',       check : 0},
    {name: 'Flaps',                 val : 'FULL 35 deg',        check : 0},
    {name: 'Parking Brake',         val : 'OFF',                check : 0},
  ],
  var L14 = [
    {titre: 'BEFORE LANDING',                                   check : nil},
    {name: 'Landing Gear',          val : '3 GREEN LIGHTS',     check : 0},
    {name: 'Autopilot',             val : 'DISENGAGE',          check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: '     Landing Speed is 120 KIAS',val : '',           check : 0},
  ],
  var L15 = [
    {titre: 'LANDING',                                          check : nil},
    {name: 'Throttles',             val : 'IDLE',               check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: '    After Nose Wheel Touchdown',val : '',           check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: 'Brakes as required',    val : '',                   check : 0},
    {name: 'Reverse Thrust as required',val : '',               check : 0},
    {name: '',                      val : '',                   check : 0},
    {name: 'At 65 kts Disengage Reverse Thrust',val : '',       check : 0},
  ],
  var L16 = [
    {titre: 'TAXIING AFTER LANDING',                            check : nil},
    {name: 'Flaps',                 val : 'RETRACT',            check : 0},
    {name: 'Landing Lights',        val : 'OFF',                check : 0},
    {name: 'Taxi Lights',           val : 'ON',                 check : 0},
    {name: 'Flight Timer',          val : 'STOP',               check : 0},
    {name: 'Transponder',           val : 'STANDBY',            check : 0},
  ],
  var L17 = [
    {titre: 'SHUTDOWN',                                         check : nil},
    {name: 'Parking Brake',         val : 'SET',                check : 0},
    {name: 'Throttles',             val : 'CUT-OFF',            check : 0},
    {name: 'Seat Belts Lights',     val : 'OFF',                check : 0},
    {name: 'Ice Equipment',         val : 'OFF',                check : 0},
    {name: 'Passengers Oxygen',     val : 'OFF',                check : 0},
    {name: 'L-R Ignition Switches', val : 'OFF',                check : 0},
    {name: 'L-R Generator Switches',val : 'OFF',                check : 0},
    {name: 'Emergency Lights',      val : 'OFF',                check : 0},
    {name: 'Standby Power',         val : 'OFF',                check : 0},
    {name: 'Navigation Lights',     val : 'OFF',                check : 0},
    {name: 'Landing Lights',        val : 'OFF',                check : 0},
    {name: 'Taxi Lights',           val : 'OFF',                check : 0},
    {name: 'Anti Coll Lights',      val : 'OFF',                check : 0},
    {name: 'APU',                   val : 'SHUTDOWN',           check : 0},
    {name: 'Avionics Switch',       val : 'OFF',                check : 0},
    {name: 'Batteries 1 - 2',       val : 'OFF',                check : 0},
  ],
];

var CHKLIST = {
  new: func(x) {
    var m = {parents:[CHKLIST]};
    if (!x) {
      m.canvas = canvas.new({
        "name": "CHKLIST",
        "size" : [1024,1024],
        "view" : [900,1024],
		    "mipmapping": 1
	    });
  	  m.canvas.addPlacement({"node": "chklist.screenL"});
    } else {
      m.canvas = canvas.new({
        "name": "CHKLIST",
        "size" : [1024,1024],
        "view" : [900,1024],
		    "mipmapping": 1
	    });
  	  m.canvas.addPlacement({"node": "chklist.screenR"});
    }
	  m.chklst = m.canvas.createGroup();
    m.tittle = m.chklst.createChild("text")
      .setTranslation(450,50)
      .setAlignment("center-center")
      .setFont("helvetica_bold.txf")
      .setFontSize(36)
      .setColor(0.9,0,0.9)
      .setScale(1.5);

    m.loop = nil;
    m.timer = [nil,nil];
    m.sound = nil;
    return m;
  }, # end of new

  init : func(x) {
    me.timer[x] = maketimer(1.8,func() {
      np = size(L[page])*2-2;
	    if (nb <= np) {
        nr_ligne = int((nb+1)/2);
        if (L[page][nr_ligne].val !="") {
          if (math.mod(nb,2) == 1)
        	  me.sound = {path : root~'copilot-voices/',file : string.lc(L[page][nr_ligne].name)~'.wav', volume : 0.5};
          else
        	  me.sound = {path : root~'pilot-voices/',file : string.lc(L[page][nr_ligne].val)~'.wav', volume : 0.5};
          fgcommand("play-audio-sample",me.sound);
        }
        me.check_prop(x);
        nb+=1;
      } else {
        upd[x] = 0;
        me.timer[x].stop();
        setprop(abn[x],0);
      }
    });
  }, # end of init

  listen : func(x) {
    ### Listener Norm Buttons ###
    setlistener(norm[x], func(n) {
	    if (n.getValue()) {
        setprop("/sim/sound/chatter/enabled",1);
		    pge[x] = getprop(nr_page[x]);
		    me.display(pge[x]);
	    } else {
		      if (me.timer[x].isRunning) me.timer[x].stop();
		      nb = 0;
		      upd[x] = 0;
          setprop(abn[x],0);
          setprop("/sim/sound/chatter/enabled",0);
	    }
    },0,0);

    ### Listener Page Button ###
    setlistener(nr_page[x], func(n) {
	    if (getprop(norm[x])) {
		    if (me.timer[x].isRunning) me.timer[x].stop();
		    pge[x] = n.getValue();
		    setprop("instrumentation/checklists/nr-voice",0);
        setprop(abn[x],0);
		    upd[x] = 0;
		    me.display(pge[x]);
		    me.clear_voice(x);
	    }
    },0,0);

    ### Listener abn Button ###
    setlistener(abn[x], func(n) {
	    if (n.getValue()) {
        x == 0 ? setprop(abn[1],0) : setprop(abn[0],0);
        if (me.timer[x].isRunning) me.timer[x].stop();
			    me.clear_voice(x);
			    upd[x] = 1;
			    nb = 1;
          nr_ligne = 1;
          page = pge[x];
          setprop("instrumentation/checklists/page",pge[x]);
			    me.timer[x].start();
	    } else {
			    upd[x] = 0;
			    nb = 0;
			    me.clear_voice(x);
			    me.timer[x].stop();
      }
    },0,0);

    setlistener(skp[x], func(n) {
      skip[x] = (getprop(elec[x]) and n.getValue()) ? n.getValue() : 0;
    },0,0);

  }, # end of listen

  clear_voice : func(x) {
    for (var i=0;i<size(L);i+=1) {
      for (var j=0;j<size(L[i]);j+=1) {
        if (L[i][j].check != nil) L[i][j].check = 0;
      }
    }
  }, # end of clear_voice

  display : func(page) {
    me.chklst.removeAllChildren(); # clear display
    me.pos_l = 150;
    me.tittle = me.chklst.createChild("text")
      .setTranslation(450,50)
      .setAlignment("center-center")
      .setFont("helvetica_bold.txf")
      .setFontSize(36)
      .setColor(0.9,0,0.9)
      .setScale(1.5)
      .setText(L[page][0].titre);

    forindex (var ind; L[page]) {
      if (L[page][ind].check != nil) {
        me.line = me.chklst.createChild("text")
          .setTranslation(50,me.pos_l)
          .setAlignment("left-center")
          .setFont("helvetica_bold.txf")
          .setFontSize(48,1.1)
          .setColor(L[page][ind].val == "" ? [1,0.4,0] : [0.9,0.9,0])
          .setScale(1.0)
          .setText(L[page][ind].name);

        me.answer = me.chklst.createChild("text")
          .setTranslation(850,me.pos_l)
          .setAlignment("right-center")
          .setFont("helvetica_bold.txf")
          .setFontSize(48,1.1)
          .setColor(0,0.9,0.9)
          .setScale(1.0)
          .setText(L[page][ind].val);
        me.pos_l += 50;
      }
    }

  }, # end of display

  next_page : func(x) {
    if (getprop(elec[x])) {
	    pge[x] = getprop(nr_page[x]);
	    if (pge[x] < 17) {
		    pge[x] += 1;
		    setprop(nr_page[x],pge[x]);
	    }
    }
  }, # end of next_page

  prev_page : func(x) {
    if (getprop(elec[x]))	{
      pge[x] = getprop(nr_page[x]);
	    if (pge[x] >= 1) {
		    pge[x] -= 1;
		    setprop(nr_page[x],pge[x]);
	    }
    }
  }, # end of prev_page

  check_prop : func(x) {
    if (upd[x]) {
      if (!L[page][nr_ligne].check) {
        me.timer[x].stop();
			  running = 1;
			  me.loop = func {   ### boucle d'attente de validation ###
				  if (running and upd[x]) {
            me.prop_table(x);
					  if (L[page][nr_ligne].check or L[page][nr_ligne].val == "" or skip[x]) {
              if (skip[x]) {nb+=1;skip[x]=0}
              if (L[page][nr_ligne].val == "") nb+=1;
						  running = 0;
						  me.timer[x].restart(1.8);
					  }
					  settimer(me.loop,0);
				  }
			  }
			  me.loop();
      }
    }
  }, # end of check_prop

  prop_table : func(x) {
    if (upd[x]) {
	    if (page == 0) {   ### Cold Start with Ext Pwr ###
        if (nr_ligne == 1
          or nr_ligne == 2
		      or nr_ligne == 3 and getprop("controls/gear/brake-parking")
		      or nr_ligne == 4 and getprop("controls/engines/engine/cutoff") and getprop("controls/engines/engine[1]/cutoff")
		      or nr_ligne == 5 and getprop("controls/electric/stby-pwr")
		      or nr_ligne == 6 and getprop("controls/electric/batt1-switch") and getprop("controls/electric/batt2-switch")
		      or nr_ligne == 7 and getprop("controls/electric/external-power")
		      or nr_ligne == 8 and getprop("controls/electric/avionics-switch") == 2)
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 1) {   ### Cold Start with APU ###
        if (nr_ligne == 1
          or nr_ligne == 2
		      or nr_ligne == 3 and getprop("controls/gear/brake-parking")
		      or nr_ligne == 4 and getprop("controls/engines/engine/cutoff") and getprop("controls/engines/engine[1]/cutoff")
		      or nr_ligne == 5 and getprop("controls/electric/stby-pwr")
		      or nr_ligne == 6 and getprop("controls/electric/batt1-switch") and
            getprop("controls/electric/batt2-switch")
		      or nr_ligne == 7 and getprop("controls/APU/master")
		      or nr_ligne == 8 and getprop("controls/APU/test")
		      or nr_ligne == 9 and getprop("controls/APU/start-stop")
		      or nr_ligne == 10 and getprop("controls/APU/rpm") > 0.99
		      or nr_ligne == 11 and getprop("controls/APU/generator")
		      or nr_ligne == 12 and getprop("systems/electrical/apu-gen-volts") > 24
		      or nr_ligne == 13 and getprop("controls/APU/bleed-air")
		      or nr_ligne == 14 and getprop("controls/APU/bleed-air")
		      or nr_ligne == 15 and getprop("controls/electric/avionics-switch") == 2)
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 2) {   ### Before Engines Start-up ###
        if (nr_ligne == 1
          or nr_ligne == 2 and !getprop("controls/cabin-door/open")
		      or nr_ligne == 3 and getprop("controls/lighting/emer-lights")
		      or nr_ligne == 4 and getprop("controls/lighting/seat-belts") == -1
		      or nr_ligne == 5
		      or nr_ligne == 6
		      or nr_ligne == 7 and getprop("instrumentation/annunciators/test-select")==9
		      or nr_ligne == 8 and getprop("controls/lighting/anti-coll") == 1
		      or nr_ligne == 9)
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 3) {   ### Right Engine Start-up ###
        if (nr_ligne == 1 and !getprop("controls/engines/engine[1]/cutoff") and getprop(throttle[1]) == 0
		      or nr_ligne == 2 and getprop("controls/engines/engine[1]/ignition") == 0
		      or nr_ligne == 3 and getprop("controls/engines/engine[1]/starter")
		      or nr_ligne == 4 and getprop("controls/electric/engine[1]/generator")
		      or nr_ligne == 5 and getprop("engines/engine[1]/turbine") >= 56
		      or nr_ligne == 6 and getprop("engines/engine[1]/fan") >= 40
		      or nr_ligne == 7 and getprop("engines/engine[1]/oil-pressure-psi") > 20
		      or nr_ligne == 8
		      or nr_ligne == 9 and getprop("systems/electrical/right-main-bus-volts") > 24 and getprop("systems/electrical/right-main-bus-amps") > 0 and getprop("systems/hydraulics/psi-norm[1]") == 1)
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 4) {   ### Left Engine Start-up ###
        if (nr_ligne == 1 and !getprop("controls/engines/engine/cutoff") and getprop(throttle[0]) == 0
		      or nr_ligne == 2 and getprop("controls/engines/engine/ignition") == 0
		      or nr_ligne == 3 and getprop("controls/engines/engine/starter")
		      or nr_ligne == 4 and getprop("controls/electric/engine/generator")
		      or nr_ligne == 5 and getprop("engines/engine/turbine") >= 56
		      or nr_ligne == 6 and getprop("engines/engine/fan") >= 40
		      or nr_ligne == 7 and getprop("engines/engine/oil-pressure-psi") > 20
		      or nr_ligne == 8
		      or nr_ligne == 9 and getprop("systems/electrical/left-main-bus-volts") > 24 and getprop("systems/electrical/left-main-bus-amps") > 0 and getprop("systems/hydraulics/psi-norm") == 1)
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 5) {   ### Before Taxiing ###
        if (nr_ligne == 1 and !getprop("controls/electric/external-power")
		      or nr_ligne == 2
		      or nr_ligne == 3 and getprop("controls/anti-ice/lh-pitot") and getprop("controls/anti-ice/rh-pitot")
		      or nr_ligne == 4 and getprop("controls/anti-ice/lh-ws") and getprop("controls/anti-ice/rh-ws")
		      or nr_ligne == 5
          or nr_ligne == 6 and getprop("controls/lighting/seat-belts") == 1
		      or nr_ligne == 7 and getprop("controls/oxygen/pass-oxy") == 1
		      or nr_ligne == 8 and getprop("instrumentation/transponder/unit/display-mode") == "STANDBY" and getprop("instrumentation/transponder/unit/id-code") != 7777 or getprop("instrumentation/transponder/unit[1]/display-mode") == "STANDBY" and getprop("instrumentation/transponder/unit[1]/id-code") != 7777
		      or nr_ligne == 9 and getprop("instrumentation/altimeter/indicated-altitude-ft") < 20 and getprop("instrumentation/altimeter/indicated-altitude-ft") > -20
		      or nr_ligne == 10
		      or nr_ligne == 11
		      or nr_ligne == 12 and getprop("controls/lighting/anti-coll") == 2
		      or nr_ligne == 13 and getprop("controls/lighting/nav-lights"))
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 6) {   ### Taxiing ###
        if (nr_ligne == 1 and !getprop("controls/gear/brake-parking")
		      or nr_ligne == 2 and getprop("controls/flight/flaps-select") == 2
		      or nr_ligne == 3 and !getprop("controls/flight/spoilers")
		      or nr_ligne == 4 and getprop("controls/lighting/taxi-light")
		      or nr_ligne == 5 and getprop("controls/lighting/landing-light") and getprop("controls/lighting/landing-light[1]")
		      or nr_ligne == 6 and getprop("instrumentation/eicas/messages") == 0
		      or nr_ligne == 7 and getprop("instrumentation/transponder/unit/display-mode") == "ATC ALT" or getprop("instrumentation/transponder/unit[1]/display-mode") == "ATC ALT")
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 7) {   ### Take-off ###
        if (nr_ligne == 1 and getprop("instrumentation/mfd/etx") == 1 or getprop("instrumentation/mfd[1]/etx") == 1
		      or nr_ligne == 2 and getprop("controls/gear/brake-left") and getprop("controls/gear/brake-right")
		      or nr_ligne == 3 and getprop(throttle[0]) >= 0.7 and getprop(throttle[1]) >= 0.7
		      or nr_ligne == 4 and !getprop("controls/gear/brake-left") and !getprop("controls/gear/brake-right"))
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 8) {   ### After Take-off ###
        if (nr_ligne == 1 and !getprop("controls/gear/gear-down")
		      or nr_ligne == 4 and getprop("controls/flight/flaps-select") == 0
		      or nr_ligne == 5
		      or nr_ligne == 6 and getprop("instrumentation/eicas/messages") == 0
		      or nr_ligne == 7
		      or nr_ligne == 8 and getprop("engines/engine/n1") < 98 and getprop("engines/engine[1]/n1") < 98)
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 9) {   ### Climb ###
        if (nr_ligne == 3
		      or nr_ligne == 4 and getprop("consumables/fuel/total-fuel-lbs") > 1200
		      or nr_ligne == 5 and !getprop("controls/lighting/taxi-light")
		      or nr_ligne == 6 and !getprop("controls/lighting/landing-light") and !getprop("controls/lighting/landing-light[1]")
		      or nr_ligne == 7)
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 10) {   ### APU Shutdown ###
        if (nr_ligne == 1 and !getprop("controls/APU/generator")
		      or nr_ligne == 2 and !getprop("controls/APU/bleed-air")
		      or nr_ligne == 3 and getprop("controls/APU/start-stop")== -1
		      or nr_ligne == 4 and getprop("controls/APU/rpm") < 0.99
		      or nr_ligne == 5 and !getprop("controls/APU/master"))
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 11) {   ### Cruise ###
        if (nr_ligne == 1 and getprop("controls/lighting/seat-belts") == -1
		      or nr_ligne == 2
		      or nr_ligne == 3 and getprop("consumables/fuel/total-fuel-lbs") > 1200
		      or nr_ligne == 4)
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 12) {   ### Descent ###
        if (nr_ligne == 1 and getprop("controls/lighting/seat-belts") == 1)
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 13) {   ### Approach ###
        if (nr_ligne == 1
		      or nr_ligne == 2 and getprop("controls/lighting/seat-belts") == 1
		      or nr_ligne == 3 and getprop("controls/lighting/landing-light") and getprop("controls/lighting/landing-light[1]")
		      or nr_ligne == 5 and getprop("velocities/airspeed-kt") < 250


		      or nr_ligne == 7 and getprop("controls/flight/flaps-select") == 1
		      or nr_ligne == 8 and getprop("controls/flight/slats") == 1
		      or nr_ligne == 9 and getprop("velocities/airspeed-kt") < 210
          or nr_ligne == 10 and getprop("controls/flight/flaps-select") == 2
          or nr_ligne == 11 and getprop("controls/gear/gear-down")
		      or nr_ligne == 13 and getprop("velocities/airspeed-kt") < 180
          or nr_ligne == 14 and getprop("controls/flight/flaps-select") == 3
 		      or nr_ligne == 15 and !getprop("controls/gear/brake-parking"))
       L[page][nr_ligne].check = 1;
	    }
	    if (page == 14) {   ### Before Landing ###
        if (nr_ligne == 1 and getprop("controls/gear/gear-down")
		      or nr_ligne == 2 and getprop("autopilot/locks/disengage"))
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 15) {   ### Landing ###
        if (nr_ligne == 1 and getprop(throttle[0]) == 0 and getprop(throttle[1]) == 0)
       L[page][nr_ligne].check = 1;
	    }
	    if (page == 16) {   ### Taxiing after Landing ###
        if (nr_ligne == 1 and getprop("controls/flight/flaps-select") == 0
		      or nr_ligne == 2 and !getprop("controls/lighting/landing-light") and !getprop("controls/lighting/landing-light[1]")
		      or nr_ligne == 3 and getprop("controls/lighting/taxi-light")
		      or nr_ligne == 4 and getprop("instrumentation/mfd/etx") != 1 and getprop("instrumentation/mfd[1]/etx") != 1
		      or nr_ligne == 5 and getprop("instrumentation/transponder/unit/display-mode") == "STANDBY" and getprop("instrumentation/transponder/unit[1]/display-mode") == "STANDBY")
        L[page][nr_ligne].check = 1;
	    }
	    if (page == 17) {   ### Shutdown ###
        if (nr_ligne == 1 and getprop("controls/gear/brake-parking")
		      or nr_ligne == 2 and getprop("controls/engines/engine/cutoff") and getprop("controls/engines/engine[1]/cutoff")
		      or nr_ligne == 3 and getprop("controls/lighting/seat-belts") == 0
		      or nr_ligne == 4 and !getprop("controls/anti-ice/lh-pitot") and !getprop("controls/anti-ice/rh-pitot") and !getprop("controls/anti-ice/lh-ws") and !getprop("controls/anti-ice/rh-ws")
		      or nr_ligne == 5 and getprop("controls/oxygen/pass-oxy") == 0
		      or nr_ligne == 6 and getprop("controls/engines/engine/ignition") == 1 and getprop("controls/engines/engine[1]/ignition") == 1
		      or nr_ligne == 7 and !getprop("controls/electric/engine/generator") and !getprop("controls/electric/engine[1]/generator")
		      or nr_ligne == 8 and !getprop("controls/lighting/emer-lights")
		      or nr_ligne == 9 and !getprop("controls/electric/stby-pwr")
		      or nr_ligne == 10 and !getprop("controls/lighting/nav-lights")
		      or nr_ligne == 11 and !getprop("controls/lighting/landing-light") and !getprop("controls/lighting/landing-light[1]")
		      or nr_ligne == 12 and !getprop("controls/lighting/taxi-light")
		      or nr_ligne == 13 and getprop("controls/lighting/anti-coll") == 0
		      or nr_ligne == 14 and !getprop("controls/APU/master")
		      or nr_ligne == 15 and getprop("controls/electric/avionics-switch") == 0
		      or nr_ligne == 16 and !getprop("controls/electric/batt1-switch") and !getprop("controls/electric/batt2-switch"))
        L[page][nr_ligne].check = 1;
	    }
    }
  }, # end of prop_table

}; # end of CHKLIST

#### Main ####
var chklist_setl = setlistener("/sim/signals/fdm-initialized", func () {
  for (var x=0;x<2;x+=1) {
    var checklist = CHKLIST.new(x);
    checklist.init(x);
    checklist.listen(x);
  }
  print("Vocal Checklists ... Ok");
  removelistener(chklist_setl);
});

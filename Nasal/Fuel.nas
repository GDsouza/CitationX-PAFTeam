## Fuel System  ##
## Christian Le Moigne - octobre 2015 ##

### Chaque réacteur est alimenté par le réservoir d'aile correspondant. Le réservoir central, dans le fuselage, est fictivement séparé en 2 compartiments (tank2 & tank3), reliés entre eux. Chaque compartiment alimente le réacteur correspondant jusqu'à ce qu'il ne reste plus que 500 lbs dans le réservoir central. Les réservoirs d'ailes prennent ensuite le relais.
###

props.globals.initNode("controls/fuel/xfer-L",0,"INT");
props.globals.initNode("controls/fuel/xfer-R",0,"INT");
props.globals.initNode("controls/engines/engine/feed-tank",0,"INT");
props.globals.initNode("controls/engines/engine[1]/feed-tank",0,"INT");
var diffLevel2_3 = nil;
var fgph = nil;
var xflow_switch = nil;
var level_L = nil;
var level_R = nil;
var efis = nil;
var v = nil;

var fuelsys = {
    new : func {
        m = { parents : [fuelsys] };

		m.engine = "controls/engines";
		m.fuel = "consumables/fuel";
		m.Xfuel = "controls/fuel"; 

		m.sel = [m.engine~"/engine[0]/feed-tank",	m.engine~"/engine[1]/feed-tank"];
		m.cutoff = [m.engine~"/engine[0]/cutoff",	m.engine~"/engine[1]/cutoff"];
		m.tank = [ m.fuel~"/tank[0]/selected",m.fuel~"/tank[1]/selected",
               m.fuel~"/tank[2]/selected",m.fuel~"/tank[3]/selected"];
		m.xfer = [m.Xfuel~"/xfer-L",m.Xfuel~"/xfer-R"];
		m.level0 = m.fuel~"/tank[0]/level-lbs";
		m.level1 = m.fuel~"/tank[1]/level-lbs";
		m.level2 = m.fuel~"/tank[2]/level-lbs";
		m.level3 = m.fuel~"/tank[3]/level-lbs";
		m.totalCtrTk = m.fuel~"/total-ctrtk-lbs";
    m.bp0 = 0;
    m.bp1 = 0;
    m.bpTimer = maketimer(1, func() {
  		fgph = [getprop("engines/engine[0]/fuel-flow-gph"),
  					  getprop("engines/engine[1]/fuel-flow-gph")];				
		  if (m.bp0) {setprop("engines/engine[0]/fuel-flow-gph",fgph[0] * 1.1)}
      if (m.bp1) {setprop("engines/engine[1]/fuel-flow-gph",fgph[1] * 1.1)}
    });
		return m
    },

	init_fuel : func{
		setprop(me.tank[0],0); 	
		setprop(me.tank[1],0);		
		setprop(me.tank[2],0);		
		setprop(me.tank[3],0);
    setprop(me.level0,2000);
    setprop(me.level1,2000);
    setprop(me.level2,2000);
    setprop(me.level3,2000);
	},

  listen : func {
    setlistener("controls/fuel/tank[0]/boost_pump",func(n) { 
		  if (n.getValue() == 2 ) {
        me.bp0 = 1;
        if (!me.bpTimer.isRunning) me.bpTimer.start();
      } else {me.bp0 = 0; if (!me.bp1) me.bpTimer.stop()}
    },0,0);

    setlistener("controls/fuel/tank[1]/boost_pump",func(n) { 
		  if (n.getValue() == 2 ) {
        me.bp1 = 1;
        if (!me.bpTimer.isRunning) me.bpTimer.start();
      } else {me.bp1 = 0;if (!me.bp0) me.bpTimer.stop()}
    },0,0);

  },

	update : func{		
		setprop(me.totalCtrTk,getprop(me.level2) + getprop(me.level3));
		diffLevel2_3 = abs((getprop(me.level2) - getprop(me.level3))/2);		

			### TANK 2-3 BALANCE ###
		if (getprop(me.level2) > getprop(me.level3)) {
				setprop(me.level2,getprop(me.level2) - diffLevel2_3);
				setprop(me.level3,getprop(me.level3) + diffLevel2_3);
		}
		if (getprop(me.level2) < getprop(me.level3)) {
				setprop(me.level2,getprop(me.level2) + diffLevel2_3);
				setprop(me.level3,getprop(me.level3) - diffLevel2_3);
		}

			### XFER ###	

		if (getprop(me.totalCtrTk) > 500) {
			if (getprop(me.xfer[0]) == 2) {
				setprop(me.tank[0],1);		
				setprop(me.tank[2],0);			
				me.oof();
			} else {
				setprop(me.tank[0],0);		
				setprop(me.tank[2],1);							
			}
			if (getprop(me.xfer[1]) == 2) {
				setprop(me.tank[1],1);		
				setprop(me.tank[3],0);			
				me.oof();
			} else {
				setprop(me.tank[1],0);		
				setprop(me.tank[3],1);			
			}
		}
		if (getprop(me.totalCtrTk) <= 500) {
			if (getprop(me.totalCtrTk) > 0.5) {
				if (getprop(me.xfer[0]) == 1) {
					setprop(me.tank[0],0);		
					setprop(me.tank[2],1);			
				} else {
					if (getprop(me.sel[0]) == 0 and !getprop(me.cutoff[0])){
						setprop(me.tank[0],1);		
						setprop(me.tank[2],0);					
					} else {
							me.xfeed();										
							me.oof();
					}
				}
				if (getprop(me.xfer[1]) == 1) {
					setprop(me.tank[1],0);		
					setprop(me.tank[3],1);			
				}	else {
					if (getprop(me.sel[1]) == 0 and !getprop(me.cutoff[1])){
						setprop(me.tank[1],1);		
						setprop(me.tank[3],0);					
					} else {
							me.xfeed();										
							me.oof();
					}
				}
				if (getprop(me.xfer[0]) == 0 and getprop(me.xfer[1]) == 0) {
					me.xfeed();
					me.oof();
				}					 
			} else {											### TK 2-3 EMPTY ###
					me.xfeed();	
					me.oof();
			}
		}
		settimer(func {me.update();},0.3);
	},

	xfeed : func { 					### CROSSFEED ###
		setprop(me.tank[2],0);			
		setprop(me.tank[3],0);			
		if (getprop(me.sel[0]) == 1) {
			setprop(me.tank[0],0);		
			setprop(me.tank[1],1);		
		} else if (getprop(me.sel[1]) == 1) {
				setprop(me.tank[0],1);		
				setprop(me.tank[1],0);				
		} else {
				if (getprop(me.cutoff[0]) == 1) {setprop(me.tank[0],0)}
					else {setprop(me.tank[0],1)}		
				if (getprop(me.cutoff[1]) == 1) {setprop(me.tank[1],0)}	
					else {setprop(me.tank[1],1)}		
		}
	},		

	oof : func {						### OUT OF FUEL ###
		if (getprop(me.level0) <= 0.5 and (getprop(me.sel[0]) == 0 or getprop(me.sel[1]) == 1)) {
			setprop("engines/engine[0]/out-of-fuel",1);
		}
		if (getprop(me.level1) <= 0.5 and (getprop(me.sel[1]) == 0 or getprop(me.sel[0]) == 1) ) {
			setprop("engines/engine[1]/out-of-fuel",1);
		}
	},

};

var gravity_xflow = func{
		xflow_switch = getprop("controls/fuel/gravity-xflow");
		level_L = getprop("consumables/fuel/tank[0]/level-lbs");		
		level_R = getprop("consumables/fuel/tank[1]/level-lbs");
		efis = getprop("systems/electrical/outputs/efis");

		var timer = maketimer(0.1,func {	
			if(level_L > level_R + 1) {
				level_L -= 1;
				level_R += 1;
				setprop("consumables/fuel/tank[0]/level-lbs",level_L);				
				setprop("consumables/fuel/tank[1]/level-lbs",level_R);
			}	else if (level_R > level_L + 1){
				level_R -= 1;
				level_L += 1;
				setprop("consumables/fuel/tank[0]/level-lbs",level_L);				
				setprop("consumables/fuel/tank[1]/level-lbs",level_R);	
			} else {timer.stop()}
		});

		if (efis and xflow_switch) {timer.start()}
};	

var crossfeed = func {
		v = getprop("controls/engines/xfeed");
    if (v == 0) {
			setprop("controls/engines/engine[0]/feed-tank",0);
			setprop("controls/engines/engine[1]/feed-tank",0);
		}
    if (v == -1) {
			setprop("controls/engines/engine[1]/feed-tank",1);
			setprop("controls/engines/engine[0]/feed-tank",0);
		}
    if (v == 1) {
			setprop("controls/engines/engine[0]/feed-tank",1);
			setprop("controls/engines/engine[1]/feed-tank",0);
		}
}

var fuel = fuelsys.new();
	setlistener("/sim/signals/fdm-initialized", func {
	fuel.init_fuel();
	fuel.listen();
	fuel.update();
},0,0);

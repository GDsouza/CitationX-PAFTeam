## Fuel System  ##
## Christian Le Moigne - octobre 2015 ##

### Chaque réacteur est alimenté par le réservoir d'aile correspondant. Le réservoir central, dans le fuselage, est fictivement séparé en 2 compartiments (tank2 & tank3), reliés entre eux. Chaque compartiment alimente le récteur correspondant jusqu'à ce qu'il ne reste plus que 500 lbs dans le réservoir central. Les réservoirs d'ailes prennent ensuite le relais.
###

props.globals.initNode("controls/fuel/xfer-L",0,"INT");
props.globals.initNode("controls/fuel/xfer-R",0,"INT");

var fuelsys = {
    new : func {
        m = { parents : [fuelsys] };

		m.engine = props.globals.getNode("controls/engines",1);
		m.fuel = props.globals.getNode("consumables/fuel",1);
		m.Xfuel = props.globals.getNode("controls/fuel",1); 

		m.sel = [ m.engine.getNode("engine[0]/feed-tank",1),
			m.engine.getNode("engine[1]/feed-tank",1) ];
		m.cutoff = [ m.engine.getNode("engine[0]/cutoff",1),
			m.engine.getNode("engine[1]/cutoff",1) ];	
		m.tank = [ m.fuel.getNode("tank[0]/selected",1),
			m.fuel.getNode("tank[1]/selected",1),
			m.fuel.getNode("tank[2]/selected",1),		
			m.fuel.getNode("tank[3]/selected",1) ];		
		m.xfer = [m.Xfuel.getNode("xfer-L"),m.Xfuel.getNode("xfer-R")];
		m.level0 = m.fuel.getNode("tank[0]/level-lbs");
		m.level1 = m.fuel.getNode("tank[1]/level-lbs");
		m.level2 = m.fuel.getNode("tank[2]/level-lbs");
		m.level3 = m.fuel.getNode("tank[3]/level-lbs");
		m.totalCtrTk = m.fuel.getNode("total-ctrtk-lbs");

		return m
    },

	init_fuel : func{
		me.tank[0].setBoolValue(0); 	
		me.tank[1].setBoolValue(0);		
		me.tank[2].setBoolValue(1);		
		me.tank[3].setBoolValue(1);
		me.sel[0].setIntValue(0);
		me.sel[1].setIntValue(0);
	},

	update : func{		
		me.totalCtrTk.setValue(me.level2.getValue() + me.level3.getValue());
		var diffLevel2_3 = abs((me.level2.getValue() - me.level3.getValue())/2);		

			### TANK 2-3 BALANCE ###
		if (me.level2.getValue() > me.level3.getValue()) {
				me.level2.setValue(me.level2.getValue() - diffLevel2_3);
				me.level3.setValue(me.level3.getValue() + diffLevel2_3);
		}
		if (me.level2.getValue() < me.level3.getValue()) {
				me.level2.setValue(me.level2.getValue() + diffLevel2_3);
				me.level3.setValue(me.level3.getValue() - diffLevel2_3);
		}

			### XFER ###	

		if (me.totalCtrTk.getValue() > 500) {
			if (me.xfer[0].getValue() == 2) {
				me.tank[0].setBoolValue(1);		
				me.tank[2].setBoolValue(0);			
				me.oof();
			} else {
				me.tank[0].setBoolValue(0);		
				me.tank[2].setBoolValue(1);							
			}
			if (me.xfer[1].getValue() == 2) {
				me.tank[1].setBoolValue(1);		
				me.tank[3].setBoolValue(0);			
				me.oof();
			} else {
				me.tank[1].setBoolValue(0);		
				me.tank[3].setBoolValue(1);			
			}
		}
		if (me.totalCtrTk.getValue() <= 500) {
			if (me.totalCtrTk.getValue() > 0.5) {
				if (me.xfer[0].getValue() == 1) {
					me.tank[0].setBoolValue(0);		
					me.tank[2].setBoolValue(1);			
				} else {
					if (me.sel[0].getValue() == 0 and !me.cutoff[0].getValue()){
						me.tank[0].setBoolValue(1);		
						me.tank[2].setBoolValue(0);					
					} else {
							me.xfeed();										
							me.oof();
					}
				}
				if (me.xfer[1].getValue() == 1) {
					me.tank[1].setBoolValue(0);		
					me.tank[3].setBoolValue(1);			
				}	else {
					if (me.sel[1].getValue() == 0 and !me.cutoff[1].getValue()){
						me.tank[1].setBoolValue(1);		
						me.tank[3].setBoolValue(0);					
					} else {
							me.xfeed();										
							me.oof();
					}
				}
				if (me.xfer[0].getValue() == 0 and me.xfer[1].getValue() == 0) {
					me.xfeed();
					me.oof();
				}					 
			} else {											### TK 2-3 EMPTY ###
					me.xfeed();	
					me.oof();
			}
		}
		settimer(func {me.update();},0);
	},

	xfeed : func { 					### CROSSFEED ###
		me.tank[2].setBoolValue(0);			
		me.tank[3].setBoolValue(0);			
		if (me.sel[0].getValue() == 1) {
			me.tank[0].setBoolValue(0);		
			me.tank[1].setBoolValue(1);		
		} else if (me.sel[1].getValue() == 1) {
				me.tank[0].setBoolValue(1);		
				me.tank[1].setBoolValue(0);				
		} else {
				if (me.cutoff[0].getValue() == 1) {me.tank[0].setBoolValue(0)}
					else {me.tank[0].setBoolValue(1)}		
				if (me.cutoff[1].getValue() == 1) {me.tank[1].setBoolValue(0)}	
					else {me.tank[1].setBoolValue(1)}		
		}
	},		

	oof : func {						### OUT OF FUEL ###
		if (me.level0.getValue() <= 0.5 and (me.sel[0].getValue() == 0 or me.sel[1].getValue() == 1)) {
			setprop("engines/engine[0]/out-of-fuel",1);
		}
		if (me.level1.getValue() <= 0.5 and (me.sel[1].getValue() == 0 or me.sel[0].getValue() == 1) ) {
			setprop("engines/engine[1]/out-of-fuel",1);
		}
	},

	boostpump : func {			### BOOST PUMPS ###
		var fgph = [ getprop("engines/engine[0]/fuel-flow-gph"),
					getprop("engines/engine[1]/fuel-flow-gph") ];				

		if (getprop("controls/fuel/tank[0]/boost_pump") == 2 ){
			setprop("engines/engine[0]/fuel-flow-gph",fgph[0] * 1.1);
		}

		if (getprop("controls/fuel/tank[1]/boost_pump") == 2) {
			setprop("engines/engine[1]/fuel-flow-gph",fgph[1] * 1.1);
		}

		settimer(func {me.boostpump();},1);
	},
};

var gravity_xflow = func{
		var xflow_switch = getprop("controls/fuel/gravity-xflow");
		var level_L = getprop("consumables/fuel/tank[0]/level-lbs");		
		var level_R = getprop("consumables/fuel/tank[1]/level-lbs");
		var efis = getprop("systems/electrical/outputs/efis");

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
		var v = getprop("controls/engines/xfeed");
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
	fuel.update();
	fuel.boostpump();
},0,0);

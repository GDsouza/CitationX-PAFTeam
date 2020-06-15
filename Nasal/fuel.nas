## Fuel System  ##
## Christian Le Moigne - octobre 2015 ##

### Chaque réacteur est alimenté par le réservoir d'aile correspondant. Le réservoir central, dans le fuselage, est fictivement séparé en 2 compartiments (tank2 & tank3), reliés entre eux. Chaque compartiment alimente le réacteur correspondant jusqu'à ce qu'il ne reste plus que 500 lbs dans le réservoir central. Les réservoirs d'ailes prennent ensuite le relais.
###

var diffLevel2_3 = nil;
var fgph = nil;
var xflow_switch = nil;
var level_L = nil;
var level_R = nil;
var fuel_control = nil;
var lh_fuel_elec = nil;
var rh_fuel_elec = nil;
var v = nil;

var fuelsys = {
    new : func {
        m = { parents : [fuelsys] };

		m.engine = "controls/engines";
		m.fuel = "consumables/fuel";
		m.Xfuel = "controls/fuel"; 
    m.elec = "systems/electrical/outputs";

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
    m.boost_pump = [m.Xfuel~"tank/boost-pump",m.Xfuel~"tank[1]/boost-pump"];
    m.el_boost_pumpL = m.elec~"/lh-boost-pump";
    m.el_boost_pumpR = m.elec~"/rh-boost-pump";

		return m
    },

	init_fuel : func{
		setprop(me.tank[0],0); 	
		setprop(me.tank[1],0);		
		setprop(me.tank[2],0);		
		setprop(me.tank[3],0);
    setprop(me.level0,2160);
    setprop(me.level1,2160);
    setprop(me.level2,1840);
    setprop(me.level3,1840);
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
		fuel_control = getprop("systems/electrical/outputs/left-fuel-control");

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
  lh_fuel_elec = getprop("systems/electrical/outputs/lh-fuel-transfer");
  rh_fuel_elec = getprop("systems/electrical/outputs/rh-fuel-transfer");
	v = getprop("controls/engines/xfeed");
  if (v == 0) {
		setprop("controls/engines/engine[0]/feed-tank",0);
		setprop("controls/engines/engine[1]/feed-tank",0);
	}
  if (v == -1 and lh_fuel_elec) {
		setprop("controls/engines/engine[1]/feed-tank",1);
		setprop("controls/engines/engine[0]/feed-tank",0);
	}
  if (v == 1 and rh_fuel_elec) {
		setprop("controls/engines/engine[0]/feed-tank",1);
		setprop("controls/engines/engine[1]/feed-tank",0);
	}
}

var fuel = fuelsys.new();
var fuel_stl = setlistener("/sim/signals/fdm-initialized", func {
	fuel.init_fuel();
	fuel.update();
  removelistener(fuel_stl);
},0,0);

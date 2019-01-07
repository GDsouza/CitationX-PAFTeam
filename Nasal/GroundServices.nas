var update_timer = nil;
var wow = "/gear/gear/wow";
var spd = "/velocities/groundspeed-kt";

var ground_services = {
	init : func {

	  # Chokes and Parking Brakes	
	  props.globals.initNode("/services/chokes", 0, "BOOL");	
	
	  # External Power
	  props.globals.initNode("/services/ext-pwr/enable", 0, "BOOL");
	
	  # Fuel Truck
	  props.globals.initNode("/services/fuel-truck/enable", 0, "BOOL");
	  props.globals.initNode("/services/fuel-truck/connect", 0, "BOOL");
	  props.globals.initNode("/services/fuel-truck/transfer", 0, "BOOL");
	  props.globals.initNode("/services/fuel-truck/clean", 0, "BOOL");
	  props.globals.initNode("/services/fuel-truck/request-lbs", 0, "DOUBLE");
	
	  # Set them all to 0 if the aircraft is not stationary
	  if (getprop("/velocities/groundspeed-kt") > 10) {
		  setprop("/services/chokes", 0);
		  setprop("/services/fuel-truck/enable", 0);
		  setprop("/services/ext-pwr/enable", 0);
	  }
    me.update();
	}, # end of init

  listen : func {
    setlistener("/services/chokes", func(n) {
      if (n.getValue()) me.update_controls();
    },0,0);

    setlistener("/services/fuel-truck/enable", func(n) {
      if (n.getValue()) me.update_controls();
    },0,0);

    setlistener("/services/fuel-truck/connect", func(n) {
      if (n.getValue()) me.update_controls();
    },0,0);

    setlistener("/services/ext-pwr/enable", func(n) {
      if (n.getValue()) me.update_controls();
    },0,0);
  }, # end of listen

  updateTimer : func {
    update_timer = maketimer(0.1,func(){me.update();});
  }, # end of update_timer

  update_controls : func {
    if (getprop(wow) & getprop(spd) < 1) {
      if(!update_timer.isRunning) update_timer.start();
    } else {
      setprop("/services/chokes",0); 
	    setprop("/services/fuel-truck/enable",0);
	    setprop("/services/fuel-truck/connect",0);
	    setprop("/services/ext-pwr/enable",0);
      if(update_timer.isRunning) update_timer.stop();
    }	
  }, # end of update_controls

	update : func {
		  if(getprop("/services/chokes") | 
		     getprop("/services/fuel-truck/enable") |
		     getprop("/services/ext-pwr/enable")){		   
		        setprop("controls/gear/brake-parking",1);
      } else {
		    if(!getprop("services/chokes") & 
		       !getprop("/services/fuel-truck/enable") &
		       !getprop("/services/ext-pwr/enable")){		   
            if(update_timer.isRunning) update_timer.stop();
        }
      }
	
		  # External Power Stuff	
		  if (!getprop("/services/ext-pwr/enable"))
			  setprop("/controls/electric/external-power", 0);
		
		  # Fuel Truck Controls
		  if (getprop("/services/fuel-truck/enable") and getprop("/services/fuel-truck/connect")) {
			  if (getprop("/services/fuel-truck/transfer")) {
				  if (getprop("consumables/fuel/total-fuel-lbs") < getprop("/services/fuel-truck/request-lbs")) {
					  if (getprop("/consumables/fuel/tank/level-m3") < getprop("/consumables/fuel/tank/capacity-m3")) {
						  setprop("/consumables/fuel/tank/level-kg", getprop("/consumables/fuel/tank/level-kg") + 20);
					  }
					  if (getprop("/consumables/fuel/tank[1]/level-m3") < getprop("/consumables/fuel/tank[1]/capacity-m3")) {
						  setprop("/consumables/fuel/tank[1]/level-kg", getprop("/consumables/fuel/tank[1]/level-kg") + 20);
					  }
					  if (getprop("/consumables/fuel/tank[2]/level-m3") < getprop("/consumables/fuel/tank[2]/capacity-m3")) {
						  setprop("/consumables/fuel/tank[2]/level-kg", getprop("/consumables/fuel/tank[2]/level-kg") + 20);
					  }
					  if (getprop("/consumables/fuel/tank[3]/level-m3") < getprop("/consumables/fuel/tank[3]/capacity-m3")) {
						  setprop("/consumables/fuel/tank[3]/level-kg", getprop("/consumables/fuel/tank[3]/level-kg") + 20);
					  }
				  } else {
					  setprop("/services/fuel-truck/transfer", 0);
					  screen.log.write("Refueling complete! Have a nice flight...", 1, 1, 1);
				  }						
			  }
			
			  if (getprop("/services/fuel-truck/clean")) {			
				  if (getprop("consumables/fuel/total-fuel-kg") > 90) {				
					  setprop("/consumables/fuel/tank/level-kg", getprop("/consumables/fuel/tank/level-kg") - 80);
					  setprop("/consumables/fuel/tank[1]/level-kg", getprop("/consumables/fuel/tank/level-kg") - 80);
					  setprop("/consumables/fuel/tank[2]/level-kg", getprop("/consumables/fuel/tank/level-kg") - 80);
					  setprop("/consumables/fuel/tank[3]/level-kg", getprop("/consumables/fuel/tank/level-kg") - 80);				
				  } else {
					  setprop("/services/fuel-truck/clean", 0);
					  screen.log.write("Finished draining the fuel tanks...", 1, 1, 1);
				  }			
			  }	
		  }		
      if (!getprop("/services/fuel-truck/enable"))
        setprop("/services/fuel-truck/connect",0);
	}, # end of update

  fuel_truck : func(n) {
    if (getprop("gear/gear/wow")) {
		  if (getprop("services/fuel-truck/enable") and getprop("services/fuel-truck/connect")) {
        if (n) {
				  if (getprop("/services/fuel-truck/transfer"))
					  screen.log.write("You can't clean the tanks while loading fuel!'", 1, 0, 0);
				  else {
					  setprop("/services/fuel-truck/clean", 1);
					  screen.log.write("Cleaning Fuel Tanks...", 0, 0.584, 1);
				  }
        } else {
			    setprop("/services/fuel-truck/transfer", 1);
			    screen.log.write("Re-fueling process started...", 0, 0.584, 1);
        }      
	    } else
		    screen.log.write("Please Enable and Connect the Fuel Truck First!", 1, 0, 0);
    } else return;
  }, # end of fuel_truck

}; # end of ground_services

var serv_stl = setlistener("sim/signals/fdm-initialized", func {
	ground_services.updateTimer();
	ground_services.init();
	ground_services.listen();
	print("Ground Services ... Ok");
	removelistener(serv_stl);	
},0,0);

##
### Mfd-Wx radar for Citation X ###
### C. Le Moigne (clm76) - 2016 ###

var old_scenario = getprop("/environment/weather-scenario");

var mfd_wx = func(wx) {
    # Clear any local weather that might be running
    if (getprop("/nasal/local_weather/loaded")) local_weather.clear_all();

    # Re-initialize local weather.
    setprop("/nasal/local_weather/enabled", "true");
		settimer( func {local_weather.set_tile();}, 0.2);

	if (wx) {
		var scenarioName = "Thunderstorm";
    # General weather settings based on scenario
		setprop( "/environment/params/metar-updates-environment", 1 );
		setprop( "/environment/realwx/enabled", 0 );
		setprop( "/environment/config/enabled", 1 );
	}
	else {
		var scenarioName = old_scenario;
	}
	setprop("/environment/weather-scenario", scenarioName);
};


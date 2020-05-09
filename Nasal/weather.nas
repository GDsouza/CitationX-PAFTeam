##
### Mfd-Wx radar for Citation X ###
### C. Le Moigne (clm76) - 2016, modified 2018 ###

var range_nm = nil;
var wx_listen = nil;
var scenarioName = "/environment/weather-scenario";
var mess_flag = nil;

var mfd_wx = func(wx) {
    if (wx) {
      mess_flag = 1;
      wx_listen = setlistener(scenarioName,func {
        if (getprop(scenarioName) != "Thunderstorm" 
            and getprop(scenarioName) != "Stormy Monday"
            and mess_flag) {
              canvas.MessageBox.warning(
                "Warning",
                "Weather Engine must be on Detailed Weather and Weather Conditions must be Thunderstorm or Stormy Monday to emulate the Weather Radar",
                func(sel) {
                  if (sel == canvas.MessageBox.Ok) emul_range();
                },
              );
        } else {mess_flag = 0;emul_range()}
      },1,1);
    } else {emul_range();mess_flag = 0}
};

var emul_range = func {
  # To display storms, we must simulate a change of range
  range_nm = getprop("instrumentation/mfd/range-nm");
  settimer(func {
    setprop("instrumentation/mfd/range-nm",range_nm*2);
    range_nm = getprop("instrumentation/mfd/range-nm");
  },0.5);
  settimer(func {setprop("instrumentation/mfd/range-nm",range_nm/2);},1);
};

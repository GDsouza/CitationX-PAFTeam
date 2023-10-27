# **  Specific Properties Initialization      **
# ********************************************
#         This file is part of SpokenATC.
# ** Copyright Rodolfo Leibner (rleibner@gmail.com) 2017, 2020 **
# ** under GPL licence, see <http://www.gnu.org/licenses/>
#
# ** Adapted by Christian Le Moigne (clm76) - janv 2018, janv 2019, sept 2020  **


var init = func {
  var root = getprop("/sim/aircraft-dir")~"/Nasal/Spoken_ATC";
  foreach(var f; ['atc_tools.nas', 'voice.nas']) {
    io.load_nasal( root ~ "/" ~ f, "spoken_atc" );
  };

  io.read_properties(root ~ "/" ~"addon-config.xml","");
  io.read_properties(root ~ "/" ~"phraseology.xml", "/satc/phrases");
  io.read_properties(root ~ "/" ~"except.apt.xml", "/satc/exceptions");
  print("Spoken ATC       ... Ok");
}

var setl = setlistener("/sim/signals/fdm-initialized", func () {
  init();
	removelistener(setl);
},0,0);

# **  Specific Properties Initialization      **
# ********************************************
#         This file is part of SpokenATC.
# ** Copyright Rodolfo Leibner (rleibner@gmail.com) 2017 **
# ** under GPL licence, see <http://www.gnu.org/licenses/>
#
# ** Adapted by Christian Le Moigne (clm76) - janv 2018    **


var init = func {
  var root = getprop("/sim/fg-aircraft")~"/CitationX/Nasal/Spoken_ATC"; 
  foreach(var f; ['atc_tools.nas','phraseology.nas', 'voice.nas']) {
    io.load_nasal( root ~ "/" ~ f, "atc" );
  };
  io.read_properties(root ~ "/" ~"props.xml", "/instrumentation/comm/atc");
  print("Spoken ATC ... Ok");
}

var setl = setlistener("/sim/signals/fdm-initialized", func () {
  init();
	removelistener(setl);
},0,0);


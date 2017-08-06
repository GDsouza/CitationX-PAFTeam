# **  Specific Properties Initialization      **
# ********************************************
#         This file is part of SpokenATC.
# ** Copyright Rodolfo Leibner (rleibner@gmail.com) 2017 **
# ** under GPL licence, see <http://www.gnu.org/licenses/>


var ls = setlistener("/nasal/spoken_atc/enabled", func() {
    var path = getprop("/sim/fg-aircraft") ~ '/Nasal/spoken_atc/props.xml';
    io.read_properties(path, "/instrumentation/comm/atc");
#    print("Spoken-ATC properties loaded.");
    },1);
removelistener(ls);


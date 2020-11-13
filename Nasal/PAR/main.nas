# **       Precision Approach Radar                      **
# *********************************************************
#         This file is part of FlightGear.
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or any later version.

# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

var main = func {
  var root = getprop("/sim/aircraft-dir")~"/Nasal/PAR"; 
  foreach(var f; ['par.nas','tools.nas', 'controller.nas'] ) {
    io.load_nasal( root ~ "/" ~ f, "par" );
  };
  io.read_properties(root ~ "/" ~"config.xml", "/");
  io.read_properties(root ~ "/" ~"phraseology.xml", "/gca/phrases");
  print("PAR ... Ok");
}

var setl = setlistener("/sim/signals/fdm-initialized", func () {
  main();
	removelistener(setl);
},0,0);


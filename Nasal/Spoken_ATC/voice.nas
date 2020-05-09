# **                    Spoken ATC.                      **
# **          by rleibner (rleibner@gmail.com)           **
# ** Adapted by Christian Le Moigne (clm76) - jan 2018 rev :jan 2019 #
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


#print("voice.nas v.2.2 loaded.");
var speak = func(secs=0) {

  # 0) Check dependencies
  var needConf = 2.2;
  var needPhras = 2.1;
  var actVer = getprop("/satc/version");
  var actPhrasVer = getprop("/satc/phrases/version");
  if(actVer<needConf) {
      gui.popupTip("error:\nconfig.xml Must be version " ~sprintf("%.2f", needConf)
           ~" or later.\n(You have " ~sprintf("%.2f", actVer)~").", 10);
      return; 
  } 

  if(actPhrasVer<needPhras) {
      gui.popupTip("error:\nphraseology.xml Must be version " ~sprintf("%.2f", needPhras)
           ~" or later.\n(You have " ~sprintf("%.2f", actPhrasVer)~").", 10);
      return; 
  } 

  # 1) Check comm frequency
  if(! getprop("/instrumentation/comm/serviceable") or getprop("/instrumentation/comm/volume")<0.1 ) {
      gui.popupTip("Turn Comm1 on. Set volume",3);
      return ;
  }

  var ICAOexc = func(arg) { # ICAO exceptions
		var station_name = getprop("/instrumentation/comm/station-name"); 
		if (arg == "LFPB" and left(station_name,9) == "DE GAULLE") icao = "LFPG";
		return icao;
	}

  var station = getprop("/instrumentation/comm/station-type"); 
  var tunned = getprop("/instrumentation/comm/frequencies/selected-mhz");
  var icao = getprop("/instrumentation/comm/airport-id");   
  ICAOexc(icao);
  var info = airportinfo(icao);

  if(info.name==nil or getprop("/instrumentation/comm/signal-quality-norm")<0.01) {
    # if invalid freq or out of range
      gui.popupTip("Check comm freq.!",3);
      return ;
  }
      
  # 2) Get properties
  var aux1 = getprop("/instrumentation/comm/station-name");
  var aux =(string.match(aux1,"* *"))? capit(aux1) : string.replace(info.name,"Intl","International") ;
  setprop("/satc/station-name", aux);
  getfreqs(info);

  # 3) Get env. values
  var q_ =  getprop("/environment/pressure-sea-level-inhg");
  var q =  pnt(sprintf("%.2f",q_));
  var qnh = sprintf("%d",q_/0.02953);
  var rws = info.runways;

  # 4) choose best rwy
  var best = "";
  var ang = 180.0;
  var dest_rwy = nil;
  var rm = 0;
  if (getprop("/autopilot/route-manager/active")) {
    dest_rwy = getprop("/autopilot/route-manager/destination/runway");
        rm = 1;  }

  foreach(var rw; keys(rws)){
    if (rw == getprop("sim/atc/runway") or (dest_rwy != nil and dest_rwy == rw)) {
	    best = rw;
	    break;
    } else {
      var a = abs(info.runways[rw].heading - getprop("/environment/wind-from-heading-deg"));
      if(a<ang) {ang = a;best = rw}
    }
  }

  # 5) Check current position
  var (crse, dist) = courseAndDistance(info.runways[best]);
  var headg =  getprop("/orientation/heading-magnetic-deg");
  var hand =(geo.normdeg(crse-headg)<180)? "right " : "left ";

  var elev = info.elevation * M2FT ;
  var e = int(elev/1000);
  var a =(isEven(e))? 2500+e*1000 : 3500+e*1000 ;
  var depalt =(headg<180)? sprintf(a+1000) : sprintf(a) ;

  # 5.5) Update props
  setprop("/satc/callsign-fmt", alpha(getprop("/sim/multiplay/callsign")) );
  setprop("/satc/dist-to-rwy", dist);
  setprop("/satc/course-to-rwy", spell(sprintf("%03.0f",crse),3));
  setprop("/satc/qnh-hpa", qnh);
  setprop("/satc/qnh-inches", q);
  setprop("/satc/wind-dir-fmt", spell(sprintf("%d",getprop("/environment/wind-from-heading-deg")),3));
  setprop("/satc/wind-speed-fmt", sprintf("%d",getprop("/environment/wind-speed-kt")));
  setprop("/satc/rwy-in-use", spell(best, 0));
  setprop("/satc/dep-altitude", depalt);
  setprop("/satc/delta-hdg-deg", abs(info.runways[best].heading - crse));

  var aux = (right(best,1)=="R")? "right" :  "left" ;
  setprop("/satc/pattern-hand", aux);

  aux =(getprop("/position/altitude-ft")<int(depalt))? "Continue climbing " : "Descend " ;
  setprop("/satc/dep-instr", aux);

  setprop("/satc/hand-to-rwy", hand);
  if(getprop("/satc/prev-apt-name")!=info.name) {
       setprop("/satc/prev-msg-type", ""); }
       
  # 6) Choose pertinent instruction
  #    Relative Position:
  var relPos = ["onCTR","cruising","onground","hold"];
  for(var i=0;i<size(relPos);i=i+1) { 
    if(props.condition(sprintf("/satc/logic/condition[%i]",i))) {
       setprop("/satc/relpos",relPos[i]);
    }
  }

  #    Choose ATC Reply:
  var choose = ["report","taxi2plat","exitrwy","exrwygnd","taxigotwr",
			  "taxi2rwy","gognd","gotwr","takeoff",
		      "gotwr","departure","godep","makefinal","joinpttn",
		      "land","gotwr","app","goapp","none"];
      
  for(var i=4;i<4+size(choose);i=i+1) { 
    if(props.condition(sprintf("/satc/logic/condition[%i]",i)))   break;
  }
  var choosed = choose[i-4];
  var p0 = join("short");
  if(getprop("/satc/freq")!=tunned) p0 ~= join("thisis");
  if(!(left(station,8)=="approach" or right(station,9)=="departure"
        or getprop("/satc/freq")==tunned)){
             p0 ~= "\n" ~join("qnh") ;
  }
  var p1 = join(choosed);
  var p2 = p1;
  var window = screen.window.new(nil,-50,10,secs);
  window.write(p0,1,1,1);  
  var fs = props.globals.getNode("/satc/phrases").getChildren("replace");
  foreach (var f; fs) {
	   var str = split(":",f.getValue());
	   p2 = string.replace(p2,str[0],str[1]);
  }
  window.write(p2,1,1,1);   

  # 7) Speach instruction and save previous
  voice = string.replace(p0,"\n","") ~p1;
  setprop("/sim/sound/voices/atc", voice);
  setprop("/satc/freq", tunned);
  setprop("/satc/prev-msg-type", choosed);
  setprop("/satc/prev-apt-name", info.name);

  # 8) 'Exit runway' automatic instruction
  if(choosed=="land") {
	  var i =1;
	  var timer = maketimer(3, func(){
  	  if((getprop("/gear/gear/rollspeed-ms") or 1) and getprop("/position/altitude-agl-ft")<20){speak(10);timer.stop();}
	    if(i>160) timer.stop(); # wait 8 minutes
      i +=1;
    });
    timer.start();
  }; 
}; # end of speak


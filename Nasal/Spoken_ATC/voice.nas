# **              Spoken ATC                    **
# **   by rleibner (rleibner@gmail.com)         **
# ** Modified by C. Le Moigne (clm76) nov 2020  **
# ************************************************

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
# along with this program; if 97, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#var addon = addons.getAddon("org.flightgear.addons.SpokenATC");
#print("Spoken ATC loaded");
#print("Press '<' key to request clearance.");
#print("Press 'Ctrl-<' to request a runway with ILS.");
#print("Press 'Alt-<' to toggle between Comm1 and Comm2.");
#print("Press 'Ctrl-Alt-<' to request a vector to the closest airport.");

var atcname = nil;
var aux = nil;
var aux1 = nil;
var closest = nil;
var commN = nil;
var needConf = nil;
var needPhras = nil;
var tunned = nil;
var actVer = nil;
var actPhrasVer = nil;
var station = nil;
var icao = nil;
var info = nil;

var window = screen.window.new(nil,-50,10,15);
var YELLOW = [1, .9, 0, 1];
var GREEN = [0, 1, 0, 1];
var WHITE = [1, 1, 1, 1];
var DKRED = [0.49,0.14,0.07,1];
var CONDITIONS = ["onCTR","cruising","onground","hold",
                  "report","taxi2plat","exitrwy","exrwygnd","taxigotwr",
                  "taxi2rwy","gognd","gotwr","takeoff",
                  "gotwr","departure","godep","makefinal","joinpttn",
                  "land","gotwr","app","goapp","none"];

setprop("/satc/comm2",0); # using Comm1 by default.

var speak = func(secs=3) {
  setprop("/sim/atc/using", "sact");
  if(getprop("/devices/status/keyboard/alt") and getprop("/devices/status/keyboard/ctrl"))    closest=1; # Vector to closest airport
  else closest=0;

  if(getprop("/devices/status/keyboard/alt") and ! getprop("/devices/status/keyboard/ctrl")) { # Toggle Comm1 <--> Comm2
    if(getprop("/satc/comm2")) {
      setprop("/satc/comm2",0);
      gui.popupTip("ATC on Comm1");
    } else {
      setprop("/satc/comm2",1);
      gui.popupTip("ATC on Comm2");
    }
    return;
  }

  # 0) Check dependencies
  needConf = 2.2;
  needPhras = 2.1;
  actVer = getprop("/satc/version");
  actPhrasVer = getprop("/satc/phrases/version");
  if(actVer<needConf) {
    gui.popupTip("error:\nconfig.xml Must be version " ~sprintf("%.2f", needConf)
         ~" or later.\n(You have " ~sprintf("%.2f", actVer)~").", 10);
    return; 
  } 
  if(actPhrasVer<needPhras) {
    gui.popupTip("error:\nphraseology.xml Must be version " ~sprintf("%.2f", needPhras)~" or later.\n(You have " ~sprintf("%.2f", actPhrasVer)~").", 10);
    return;
  } 

  # Using Comm1 or Comm2 ?
  commN = getprop("/satc/comm2")? '/instrumentation/comm[1]' : '/instrumentation/comm[0]';
  tunned =  getprop(sprintf("%s/frequencies/selected-mhz", commN));
  setprop(sprintf("%s/frequencies/selected-mhz", commN), math.round(tunned,0.01));

  # 1) Check comm frequency
  if(! getprop(sprintf("%s/serviceable", commN)) or getprop(sprintf("%s/volume", commN))<0.1 ) {
    gui.popupTip(sprintf("Turn Comm%i on. Set volume",1+getprop("/satc/comm2")),3);
    return ;
  }
      
  station = getprop(sprintf("%s/station-type", commN)); 
  icao = getprop(sprintf("%s/airport-id", commN));
  info = airportinfo(icao);

  if(info.name==nil or getprop(sprintf("%s/signal-quality-norm", commN))<0.01) {
    # if invalid freq or out of range
    gui.popupTip(sprintf("Check Comm%i freq.!",1+getprop("/satc/comm2")),3);
    return ;
  }
      
  # 2) Get properties
  aux1 = getprop(sprintf("%s/station-name", commN));
  aux =(string.match(aux1,"* *"))? capit(aux1) : string.replace(info.name,"Intl","International") ;
  setprop("/satc/station-name", aux);
  setprop("/satc/freq", tunned);
  # ~ var atcname = string.replace(aux,"International","")~" "~station~", ";
  atcname = sprintf("%s %s, ", string.replace(aux,"International",""),station );
  getfreqs(info);

  # 3) Get env. values
  var q_ =  getprop("/environment/pressure-sea-level-inhg");
  # ~ var q =  pnt(sprintf("%.2f",q_));
  var q =  sprintf("%.2f",q_);
  var qnh = sprintf("%d",q_/0.02953);
  var rws = info.runways;

  # 4) choose best rwy
  var best = "";
  var ang = 180.0;
  var dest_rwy = nil;
  var rm = 0;
  if (getprop("/autopilot/route-manager/active")) {
    dest_rwy = getprop("/autopilot/route-manager/destination/runway");
    rm = 1;
  }

  foreach(var rw; keys(rws)) {
    var cond = (rw == getprop("sim/atc/runway") and getprop("/devices/status/keyboard/event/modifier/ctrl")==0);
    if (cond or (dest_rwy != nil and dest_rwy == rw)) {
      best = rw;
      break;
    } else {
      var a = abs(info.runways[rw].heading - getprop("/environment/wind-from-heading-deg"));
      if(a<ang) {
        var recp = info.runways[rw].reciprocal;
        if(getprop("/devices/status/keyboard/event/modifier/ctrl") and  info.runways[rw].ils_frequency_mhz==nil and recp.ils_frequency_mhz==nil) continue;
        else {
         ang = a;
         best = rw;
        }
      }
    }
  }
  var noils = 0;
  if(best==""){ # no ILS available
    noils = 1;
    foreach(var rw; keys(rws)){
      var a = abs(info.runways[rw].heading - getprop("/environment/wind-from-heading-deg"));
      if(a<ang) {
        ang = a;
        best = rw;
      }
    }
  }
   
  # 5) Check current position
  var (crse, dist) = courseAndDistance(info.runways[best]);
  var geofinal = geo.Coord.new().set_latlon(info.runways[best].lat, info.runways[best].lon).apply_course_distance(info.runways[best].heading, -10*NM2M);
#  var (fcrse, fdist) = courseAndDistance(geofinal);
#  fcrse = getprop("/orientation/track-magnetic-deg") + geo.aircraft_position().course_to(geofinal);
#  fcrse = geo.aircraft_position().course_to(geofinal);
  var fcrse = geofinal.course_to(geo.aircraft_position());
  fcrse = geo.normdeg(fcrse-getprop("/orientation/track-magnetic-deg"));
  var geohold = geo.Coord.new().set_latlon(info.runways[best].lat, info.runways[best].lon).apply_course_distance(info.runways[best].heading, info.runways[best].threshold);
  var (hcrse,hdist) = courseAndDistance(geohold);
  var headg =  getprop("/orientation/heading-magnetic-deg");
  var hand =(geo.normdeg(crse-headg)<180)? "right " : "left ";

  var elev = info.elevation * M2FT ;
  var falt = math.clamp(100* int(elev/100+26), 1500, 2500);
  var e = int(elev/1000);
  var a = (isEven(e))? 2500+e*1000 : 3500+e*1000 ;
  var depalt = (headg<180)? a+1000 : a ;

  # 5.5) Update props
  setprop("/satc/callsign-fmt", " "~alpha(substr(getprop("/sim/multiplay/callsign"),-4) ));
  setprop("/satc/dist-to-rwy", dist);
  setprop("/satc/dist-to-hold", hdist);
  setprop("/satc/course-to-rwy", spell(sprintf("%03.0f",crse),3));
  setprop("/satc/course-to-final", spell(sprintf("%03.0f",fcrse),3));

  setprop("/satc/qnh-hpa", qnh);
  setprop("/satc/qnh-inches", q);
  setprop("/satc/wind-dir-fmt", spell(sprintf("%d",getprop("/environment/wind-from-heading-deg")),3));
  setprop("/satc/wind-speed-fmt", sprintf("%d",getprop("/environment/wind-speed-kt")));
  setprop("/satc/rwy-in-use", spell(best, 0));
  setprop("/satc/dep-altitude", depalt);
  setprop("/satc/final-altitude",  falt); #     sprintf("%d", geo.normdeg(falt)));
  setprop("/satc/delta-hdg-deg", abs(info.runways[best].heading - crse));

  var aux = (right(best,1)=="R")? "right" :  "left" ;
  setprop("/satc/pattern-hand", aux);

  aux =(getprop("/position/altitude-ft")<int(depalt))? "Continue climbing " : "Descend " ;
  setprop("/satc/dep-instr", aux);

  setprop("/satc/hand-to-rwy", hand);
  if(getprop("/satc/prev-apt-name")!=info.name) setprop("/satc/prev-msg-type", ""); 
       
  if( closest){
    var near = airportinfo();
    var (c,d) = courseAndDistance(near);
    d = sprintf("%.1f",d);
    var msg = sprintf("%s, nearest airport is %s, about %s miles heading %i.", getprop("/satc/callsign-fmt"),near.name,pnt(d),c);
    speach("atc",msg,secs,WHITE);
    var near = airportinfo();
    foreach (var hash; near.comms()) {
      if(string.lc(split(" ",hash.ident)[-1])=="twr") { 
        var freq = sprintf("%.2f",hash.frequency);
        break;
      }
    }
    var msg = "When approching, contact tower on "~ pnt(freq);
    settimer(func(){speach("atc",msg,secs,WHITE);}, 1);
    return;
  }

  # 6) Choose pertinent instruction
      #    Relative Position:
  for(var i=0;i<size(CONDITIONS);i=i+1) { 
    if(props.condition(sprintf("/satc/logic/condition[%i]",i))){
     setprop("/satc/relpos",CONDITIONS[i]);
     break;
    }
  }
#  print("/satc/relpos =",CONDITIONS[i]);

      #    Choose ATC Reply:
  for(var i=4;i<size(CONDITIONS);i=i+1) {
    if(props.condition(sprintf("/satc/logic/condition[%i]",i))) break;
  }
  var choosed = CONDITIONS[i];
#  print("choosed=",choosed);
  var mycs = join("short");
  var atcinstr = join(choosed);
  var preinstr = (noils)? join("noils") : "";

  if(getprop("/satc/freq")!=getprop("/satc/prev-freq")) {
    if(left(choosed,2)!='go')    
      preinstr = string.join("",[preinstr, join("thisis"), join("qnh")]) ;     
    else preinstr = string.join("",[preinstr, join("thisis")]);
  }
#  print("atcinstr="~atcinstr); 
  var instruction = string.join("\n",[mycs,preinstr,atcinstr]);
  # Requestings
  var req = sprintf("%s%s%s",atcname, join("R"~choosed), mycs);
  if(noils) req =string.replace(req,'landing',' IFR landing');
  speach("pilot",req ,3,DKRED);

  # 7) Speach instruction and save previous
  setprop("/satc/prev-freq", tunned);
  setprop("/satc/prev-msg-type", choosed);
  setprop("/satc/prev-apt-name", info.name);

  var delayed = 1+size(req)*.09;
  var timer0 = maketimer(delayed, func(){speach("atc",instruction,secs,WHITE);});
  timer0.singleShot = 1; # timer will only be run once
  timer0.start();

  # 8) Automatic instructions
      # 'Exit runway'
  if(choosed=="land") {
    var i =1;
    var timer = maketimer(5, func(){
      if((getprop("/position/altitude-agl-ft")<30)){
        speach("atc",mycs~join("exitrwy"),secs,WHITE);
        setprop("/satc/prev-msg-type", "exitrwy");
        timer.stop();
      }
#      printf("landing %i seg,  alt=%d", i*10,getprop("/position/altitude-agl-ft"));
      if(i>96) timer.stop(); # wait 8 minutes
      i +=1;
    });
    timer.start();
  }

      # 'Bye'
  if(choosed=="takeoff") {
    var i =1;
    var timer2 = maketimer(10, func(){
      if(getprop("/position/altitude-agl-ft")>400){
        speach("atc",mycs~join("bye"),secs,WHITE);
        setprop("/satc/prev-msg-type", "bye");
        timer2.stop();
      }
      if(i>24) timer2.stop(); # wait 4 minutes
      i +=1;
    });
    timer2.start();
  }

  # 9) Aknowledge msg
  var i = find("QNH",instruction);
  var q = i ? substr(instruction,i,9)~". " : "";
  var timer1 = maketimer(delayed+1+.109*size(instruction), func(){acknowledge(choosed,mycs,q) });
  timer1.singleShot = 1; # timer will only be run once
  timer1.start();

}; # end of speak


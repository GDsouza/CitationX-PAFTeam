# **     atc_tools.nas  v.: 2.2                 **
# **   by rleibner (rleibner@gmail.com)         **
# ** Modified by C. Le Moigne (clm76) nov 2020  **
# ************************************************
#         This file is part of FlightGear.
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or any later version.

var fs = nil;
var info = nil;
var j = nil;
var k = nil;
var lenth = nil;
var out = nil;
var prop = nil;
var r = nil;
var repl = nil;
var s = nil;
var strg = nil;
var tag = nil;
var text_w = nil;
var vec = nil;

# **** point func. **************************
var pnt = func(str) {
  str = sprintf("%.3f",str);  # accept numbers
  if(right(str,1)=="0") str=left(str,size(str)-1);
  return string.replace(str,"."," point ");
}
# **** spell func. ***************************
# used to spell <str> numbers forced to<dig> digits. (dig=0 means no force). 
var spell = func(str, dig) {
  if(dig>0 and size(str)<dig) str = right("000000" ~str ,dig);
  s = split("",str);
  for(var i=0;i<size(s);i=i+1) {
  # ~ if(streq(s[i],"."))  s[i]="point" ;
  }
  return string.join(" ",s);
}
      
# **** alpha func. *****************************
var alpha = func(str) {
  repl = {A:"Alpha", B:"Bravo", C:"Charlie", D:"Delta", E:"Echo", F:"Foxtrot",
          G:"Golf", H:"Hotel", I:"India", J:"Juliet", K:"Kilo", L:"Lima", M:"Mike",
          N:"November", O:"Oscar", P:"Papa",Q:"Quebec", R:"Romeo", S:"Sierra", 
          T:"Tango", U:"Uniform", V:"Victor", W:"Whiskey", X:"X-ray", Y:"Yanki",                  Z:"Zulu"};
  
  s = "";
  for(var i=0;i<size(str);i=i+1) {
    if(str[i]<91 and str[i]>64) s ~=repl[substr(str,i,1)] ~" ";   # Translate only capital letters  
    if(str[i]<58 and str[i]>47) s ~=substr(str,i,1) ~" ";   # and digits  
  };
  return s;
}

# **** isEven func. *****************************
var isEven = func(n) {
  if(int(n/2)==n/2) return 1;
  else return 0; 
}

# **** getfreqs func. *****************************
var getfreqs = func(apt) { # apt may be an airportinfo() ghost, an ICAO or any other parm accepted by airportinfo() .
  prop = ["twr","gnd","app","dep"];
  foreach (var p; prop)  setprop("/satc/freqs/"~p, 0);
  info =(typeof(apt)=="ghost")? apt : airportinfo(apt);
  foreach (var hash; info.comms()) {
    if(!getprop("/satc/freqs/"~string.lc(split(" ",hash.ident)[-1]))) {
     setprop("/satc/freqs/" ~string.lc(split(" ",hash.ident)[-1]),num(sprintf("%.3f",hash.frequency))); 
     setprop("/satc/freqs/" ~string.lc(split(" ",hash.ident)[-1])~"-fmt", pnt(hash.frequency)); 
    }
  }
  foreach(var station;["gnd","app"]){
    if(!getprop("/satc/freqs/"~station)){
      setprop("/satc/freqs/"~station, getprop("/satc/freqs/twr"));
      setprop("/satc/freqs/"~station~"-fmt", getprop("/satc/freqs/twr-fmt"));
    }
    if(!getprop("/satc/freqs/dep")){
      setprop("/satc/freqs/dep", getprop("/satc/freqs/app"));
      setprop("/satc/freqs/dep-fmt", getprop("/satc/freqs/app-fmt"));
      }
  }
  if(size(props.globals.getNode("/satc/exceptions").getChildren(string.lc(info.id)))> 0){
    setprop("/satc/station-name", getprop("/satc/exceptions/"~string.lc(info.id)~"/"~"name"));
    var val = nil;
    foreach (var p; prop) {
       val = pnt(getprop("/satc/exceptions/"~string.lc(info.id)~"/"~p));
        if(val !=nil) setprop("/satc/freqs/"~p, val);
    }
  } # exception executed
};

# **** capit func. *****************************
var capit = func(str) { # Rtrim 'TWR', 'APP',etc. and Capitalize words.
  lenth = size(str) - 4;
  out = str;
  if(string.match(str,"*APP-DEP") or string.match(str,"*DEP-APP"))  
     out = left(str,lenth-4);
  if(string.match(str,"*TWR") or string.match(str,"*GND") or string.match(str,"*APP")
     or string.match(str,"*DEP")) out = left(str,lenth);
  out = string.lc(out);
  vec = split(" ",out);
  for(var i=0;i<size(vec);i=i+1) 
    vec[i] = string.uc(left(vec[i],1)) ~substr(vec[i],1);
  return string.join(" ",vec);
}
 
# **** join func. Joins /satc/phrases/key[] props ************
var join = func(key="none", p="") {
  if(string.match(key,"*[][]?[][]")) {
    j = num(substr(key,-2,1));
    key = left(key,size(key)-3);
  } else j = 0;
  fs = props.globals.getNode("/satc/phrases").getChildren(key);
  strg = "";
  k = 0;
  foreach (var f; fs) {
    if(k>=j){
     strg = f.getValue();
     if(strg==nil or strg=="") continue;
     if(left(strg,1)=="%") strg=getprop(string.trim(strg, 0, func(c) c == `%` or c == ` `));
     strg = sprintf(strg); # double-->string
     if(left(strg,1)=="~") strg= " " ~join(right(strg,size(strg)-1));
     p ~= strg;
    }
    k+=1;
  }
  return p;    
}    
# **** say func. to test TTS phrases.
#  (key may be a /satc/phrases/xxx prop or any literal string. ************
var say = func(key) {
  p = join(key);
  if(size(p)==0) setprop("/sim/sound/voices/atc", key);
  else setprop("/sim/sound/voices/atc", p);
}   

# ***********************************
var pronounce = func(msg) {
  r = "";
  foreach(var f ; split(". ", msg)){
    if(string.match(f,"*[0-9].[0-9]*")) f=string.replace(f,'.',' point ');
    r ~= f~". ";
  }
  if(right(r,8)=="point . ") r=left(r, size(r)-8);
  r=string.replace(r,"\n","");
  r=string.replace(r,'runway','runwaide');
  return r~". ";
}

# ***********************************
var speach = func(who,text,secs,color=WHITE) {
  window.fg = color;
#  text_w = who == "pilot" ? "Pilot -> "~text: "Twr -> "~text; 
  window.write(string.replace(text,"..", "."));
  setprop("/sim/sound/voices/"~who, pronounce(text));
}
# ***********************************
var acknowledge = func(received,mycs,qnh) {
  tag = "A"~received;
  if(join(tag) ==nil) speach("pilot","Roger. "~getprop("/satc/callsign-fmt"),4,DKRED);
  else speach("pilot",join(tag)~". "~qnh~mycs,4,DKRED);
  return 
}



# **              atc_tools.nas  v.: 2.2                 **
# **          by rleibner (rleibner@gmail.com)           **
# *********************************************************
#         This file is part of FlightGear.
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or any later version.

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
  var s = split("",str);
  for(var i=0;i<size(s);i=i+1) {
  # ~ if(streq(s[i],"."))  s[i]="point" ;
  }
  return string.join(" ",s);
}
      
# **** alpha func. *****************************
var alpha = func(str) {
  var repl = {A:"Alpha", B:"Bravo", C:"Charlie", D:"Delta", E:"Echo", F:"Foxtrot",
             G:"Golf", H:"Hotel", I:"India", J:"Juliet", K:"Kilo", L:"Lima", M:"Mike",
             N:"November", O:"Oscar", P:"Papa",Q:"Quebec", R:"Romeo", S:"Sierra", 
             T:"Tango", U:"Uniform", V:"Victor", W:"Whiskey", X:"X-ray", Y:"Yanki",                Z:"Zulu"};
  
  var s = "";
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
  var prop = ["twr","gnd","app","dep"];
  foreach (var p; prop)  setprop("/satc/freqs/"~p, 0);
  var info =(typeof(apt)=="ghost")? apt : airportinfo(apt);
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
  var len = size(str) - 4;
  var out = str;
  if(string.match(str,"*APP-DEP") or string.match(str,"*DEP-APP"))  
     out = left(str,len-4);
  if(string.match(str,"*TWR") or string.match(str,"*GND") or string.match(str,"*APP")
     or string.match(str,"*DEP")) out = left(str,len);
  out = string.lc(out);
  var vec = split(" ",out);
  for(var i=0;i<size(vec);i=i+1) 
    vec[i] = string.uc(left(vec[i],1)) ~substr(vec[i],1);
  return string.join(" ",vec);
}
 
# **** join func. Joins /satc/phrases/key[] props ************
var join = func(key="none", p="") {
  if(string.match(key,"*[][]?[][]")) {
    var j = num(substr(key,-2,1));
    key = left(key,size(key)-3);
  } else var j = 0;
  var fs = props.globals.getNode("/satc/phrases").getChildren(key);
  var str = "";
  var i = 0;
  foreach (var f; fs) {
    if(i>=j){
     str = f.getValue();
     if(str==nil or str=="") continue;
     if(left(str,1)=="%") str=getprop(string.trim(str, 0, func(c) c == `%` or c == ` `));
     str = sprintf(str); # double-->string
     if(left(str,1)=="~") str= " " ~join(right(str,size(str)-1));
     p ~= str;
    }
    i +=1;
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
  var r="";
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
var speach = func(who,text,secs,color=YELLOW) {
  window.fg = color;
  window.write(string.replace(text,"..", "."));
# print(size(text)~" ch: "~text);
  setprop("/sim/sound/voices/"~who, pronounce(text));
}
# ***********************************
var acknowledge = func(received,mycs,qnh) {
  var tag = "A"~received;
  if(join(tag) ==nil) speach("pilot","Roger. "~getprop("/satc/callsign-fmt"),3,GREEN);
  else speach("pilot",join(tag)~". "~qnh~mycs,3,GREEN);
  return 
}

#print("atc_tools loaded."); 



# **** general debug flag **************************
var myDbg = 0;
var dbg = func() {
	myDbg = myDbg? 0:1;
	if(myDbg) printf("debug is %s.", myDbg ? "On" : "Off");
}
# **** point func. **************************
var pnt = func(str) {
    str = sprintf("%.3f",str);  # accept numbers
    if(right(str,1)=="0") str=left(str,size(str)-1);
    return string.replace(str,"."," point ");
}
# **** spell func. ***************************
# used to spell <str> numbers forced to<dig> digits. (dig=0 means no force). 
var spell = func(str, dig) {
    if(dig>0 and size(str)<dig) { str = right("000000" ~str ,dig);}
    var s = split("",str);
    for(var i=0;i<size(s);i=i+1) {
    if(streq(s[i],"."))  s[i]="point" ;
    }
    return string.join(" ",s);
}
      
# **** alpha func. *****************************
var alpha = func(str) {
    var repl = {A:"Alpha", B:"Bravo", C:"Charlie", D:"Delta", E:"Echo", F:"Foxtrot",
                 G:"Golf", H:"Hotel", I:"India", J:"Juliet", K:"Kilo", L:"Lima", M:"Mike",
                 N:"November", O:"Oscar", P:"Papa",Q:"Quebec", R:"Romeo", S:"Sierra", 
                 T:"Tango", U:"Uniform", V:"Victor", W:"Whiskey", X:"X-ray", Y:"Yanki", Z:"Zulu"};
    
    var s = "";
    for(var i=0;i<size(str);i=i+1) {
      if(str[i]<91 and str[i]>64) { s ~=repl[substr(str,i,1)] ~" ";}   # Translate only capital letters  
      if(str[i]<58 and str[i]>47) { s ~=substr(str,i,1) ~" ";}   # and digits  
    };
    return s;
};

# **** isEven func. *****************************
var isEven = func(n) {
    if(int(n/2)==n/2) {
       return 1;
    } else { 
       return 0; }
}



# **** join func. Joins /gca/phrases/key[] props ************
var join = func(key="none", p="") {
if(string.match(key,"*[][]?[][]")) {
   var j = num(substr(key,-2,1));
   key = left(key,size(key)-3);
   } else {
     var j = 0;}
	var fs = props.globals.getNode("/gca/phrases").getChildren(key);
	if(fs==[]) print("Error: node /gca/phrases/" ~key ~"not found !");
	var str = "";
	var i = 0;
    foreach (var f; fs) {
    if(i>=j){
       str = f.getValue();
       if(str==nil or str=="") continue;
      if(left(str,1)=="%") {
           str=getprop(string.trim(str, 0, func(c) c == `%` or c == ` `));
	  }
   if(left(str,1)=="~"){
	 str= " " ~join(right(str,size(str)-1));}
       p ~= str;}
    i +=1;
       }
	return p;    
} 

# **** capit func. *****************************
var capit = func(str) { # Rtrim 'TWR', 'APP',etc. and Capitalize words.
    var len = size(str) - 4;
    var out = str;
    if(string.match(str,"*APP-DEP") or string.match(str,"*DEP-APP")) { 
       out = left(str,len-4); }
    if(string.match(str,"*TWR") or string.match(str,"*GND") or string.match(str,"*APP")
       or string.match(str,"*DEP")) { 
       out = left(str,len); }
    out = string.lc(out);
    var vec = split(" ",out);
    for(var i=0;i<size(vec);i=i+1) {
       vec[i] = string.uc(left(vec[i],1)) ~substr(vec[i],1);
    }
   return string.join(" ",vec);
 }
   

# **** say func. to test TTS phrases.
#  (key may be a /gca/phrases/xxx prop or any literal string. ************
var say = func(key) {
	p = join(key);
	if(size(p)==0){
		setprop("/sim/sound/voices/atc", key);
   } else {
		setprop("/sim/sound/voices/atc", p);
	}
}	

# **** getVertProfile func. returns h[ <terrain elevation(feet)> ...] (each <resolution> nm).
var getVertProfile = func(geoObj,direction,resolution,dist=32) {
#  direction in deg, resolution in nm, optional dist in nm.
var x0 = geo.Coord.new().set_latlon(geoObj.lat(), geoObj.lon()).latlon();
var x1 = geo.Coord.new().set_latlon(geoObj.lat(), geoObj.lon())
  .apply_course_distance(direction, dist*NM2M).latlon();
var dlat = (x1[0]-x0[0])/(32/resolution);
var dlon = (x1[1]-x0[1])/(32/resolution);
var h = [];
for(var i=0; i<=(32/resolution); i+=1) append(h, geo.elevation(x0[0]+i*dlat, x0[1]+i*dlon));
# got h with elevations (m)
var from = 999;
var to=999;
for(var i=0;i<size(h);i+=1){
if(h[i]==nil and from==999) from=i;
if(h[i]==nil and from!=999) to=i;
}
if(from !=999){
 printf("Warning: found nils between %.2fnm and %.2fnm from rwy.",from*0.1,to*0.1);
}
for(var i=0; i<=(32/resolution); i+=1) if(h[i]!=nil) h[i]=(h[i]-geoObj.alt())*M2FT;
return h;
}

# **** chooseRwy func. 
#  (rwys: airportinfo().runways object.) ************
var chooseRwy = func(rwys) {
  var best = "";
  var ang = 180.0;
  if (getprop("/autopilot/route-manager/active") and left(getprop("autopilot/settings/nav-source"),3) =="FMS") {
    best = getprop("/autopilot/route-manager/destination/runway");
  } else {
  # Choose best rwy
    foreach(var rw; keys(rwys)){
#      if (rw == getprop("sim/atc/runway") or (dest_rwy != nil and dest_rwy == rw)) {
#	      best = rw;
#  	    break;
#      } else {
        var a = abs(rwys[rw].heading - getprop("/environment/wind-from-heading-deg"));
        if(a<ang) {ang = a;best = rw;}
#      }
    }
  }
  return best;
}
# **** maxVect func. 
var maxVect = func(vector) {
var max = vector[0];
var idx = 0;
for(var i=1; i<size(vector); i+=1)   if(vector[i]>max) {max = vector[i]; idx=i;}
 return [max,idx];
}

# **** minSlope func. 
var minSlope = func(vertProfile, resolution, final) { # vertProfile as vector, resolution and final in nm
 var slp = [];
 for(var i=1; i<final*resolution; i+=1) append(slp, vertProfile[i]/i);
 var (max,idx) = maxVect(slp);
 return math.atan2(max, idx);
}


# ***********************************
var NM2FT =6076;
var XYscale =nil;
var Zscale =nil;
var Track1 =nil;
var Track2 =nil;
#print("GCA tools loaded."); 



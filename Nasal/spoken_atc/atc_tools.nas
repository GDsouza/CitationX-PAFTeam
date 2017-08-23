# ** atc_tools.nas (save in $FG_ROOT/Nasal/spoken_atc) **
# **                v.: 1.22                           **
# *******************************************************
#         This file is part of SpokenATC.
# ** Copyright Rodolfo Leibner (rleibner@gmail.com) 2017 **
# ** under GPL licence, see <http://www.gnu.org/licenses/>

# **** point func. **************************
var pnt = func(str) {
    return string.replace(str,"."," point ");
}
# **** spell func. **used to spell numbers. ***
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
      if(str[i]<91 and str[i]>64)  s ~=repl[substr(str,i,1)] ~" ";   # Translate capital letters only 
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

# **** getfreqs func. *****************************
var getfreqs = func(apt) { # apt may be an airportinfo() ghost, an ICAO or any other parm accepted by airportinfo() .
    var info =(typeof(apt)=="ghost")? apt : airportinfo(apt);
    var comms = info.comms();
    if(size(comms)>0) {
         # Airport has one or more frequencies assigned to it.
        var freqs = {};
        foreach (var hash; comms) {
            var typ = hash.ident;
            if(hash["TWR"]==nil and (string.match(hash.ident,"*TWR") or string.match(hash.ident,"*ower"))) typ ="TWR";
            if(hash["APP"]==nil and (string.match(hash.ident,"A/G") or string.match(hash.ident,"*pproach"))) typ ="APP";
            freqs[typ] = sprintf("%.2f", hash.frequency);}
    }
		return freqs;  
}
      

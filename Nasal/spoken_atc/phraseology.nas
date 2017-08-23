#**  phraseology.nas (save in $FG_ROOT/Nasal/spoken_atc)    **
#         This file is part of SpokenATC.
# ** Copyright Rodolfo Leibner (rleibner@gmail.com) 2017   **
# ** under GPL licence, see <http://www.gnu.org/licenses/> **
#
#** (misspelling is to increase inteligibility)
#   To customize phraseology, refer to wiki.flightgear.org/Spoken_ATC
#                                      ------------------------------
# Available data:
#      - from arg hash:
#          arg.ac      - a/c callsign in "alpha/bravo" style. 
#          arg.apt     - airportinfo() hash (from tunned station). 
#          arg.qnh     - QNH in hPa (as string). 
#          arg.q       - QNH in inches Hg (as string). 
#          arg.depalt  - altitude ordered by DEPP (as string). 
#          arg.torwy   - course from a/c to Runway threshold. 
#          arg.headg   - a/c heading. 
#          arg.rwy     - Runway in use (as spelled string). 
#   - locals:
#       name      - tunned airport name. 
#       type      - tunned station type. 
#       f         - frequencies availables at tunned apt. (as hash)
#       GND       - GND frequency of tunned apt. (as string)
#       TWR       - TWR frequency of tunned apt. (as string)
#       APP       - APP frequency of tunned apt. (as string)
#       DEP       - DEP frequency of tunned apt. (as string)
#       wd        - wind direction (as string).
#       wv        - wind speed (as string).

#print("phraseology.nas loaded.");

# ** phrase function(key,arg)  **
#********************************
var phrase = func(key, arg) {
    var name = string.replace(arg.apt.name,"Intl","International");
    var type = " " ~getprop("/instrumentation/comm/station-type");
    var hand =(geo.normdeg(arg.torwy-arg.headg)<180)? "right " : "left ";
    var f = getfreqs(arg.apt);
    var GND = (f["GND"]==nil)? "" : pnt(f.GND);
    var TWR = pnt(f.TWR);
    var APP = (f["APP"]==nil)? "" : pnt(f.APP);
    var DEP = (f["DEP"]==nil)? "" : pnt(f.DEP);
    var wd = sprintf("%d",getprop("/environment/metar/base-wind-dir-deg"));
    var wv = sprintf("%d",getprop("/environment/metar/base-wind-speed-kt"));

    var ph = {
 # redirect to other freq:
       gognd: "Contact ground at " ~GND ~".",
       gotwr: "Contact tower at " ~TWR ~".",
       goapp: "Contact approach at " ~APP ~".",
 # Cleared to approach:
       app: "Turn " ~hand ~spell(sprintf("%i",arg.torwy),3)
               ~"degrees. Cleared to approach. Report on CTR.",
       apptwr: "Turn " ~hand ~spell(sprintf("%i",arg.torwy),3)
              ~"degrees. Arriving CTR contact tower at " ~TWR ~".",
 # introduction:
       start: arg.ac ~", this is " ~name ~type ~". ",
       short: arg.ac ~". ",
 # qnh:
       qnh: "QNH " ~arg.qnh ~" or " ~arg.q ~" inches. ",
 # Cleared to land:
       land: "Wind "~spell(wd,3) ~" degrees, " ~wv ~" knots. Runwaid "
                 ~arg.rwy~". Cleared to land.",
 # after landing:
       exitrwy: "Exit Runwaid at first taxiway.",
       exrwygnd: "Exit Runwaid at first taxiway and contact ground " ~GND ~".",
 # departure:
       climb: "Continue climb " ~arg.depalt ~" feet. Report leaving CTR.",
       descend: "Descend " ~arg.depalt ~" feet. Report leaving CTR.",
 # tower:
       lpttn: "Join left pattern Runwaid " ~arg.rwy ~" and report.",
       rpttn: "Join right pattern Runwaid " ~arg.rwy ~" and report.",
       pttn: "and join pattern Runwaid " ~arg.rwy,
       makefinal: "Join final Runwaid " ~arg.rwy ~" and report.",
 # Cleared to takeoff:
       takeoff: "Wind "~spell(wd,3) ~" degrees, " ~wv ~" knots. Runwaid "
                 ~arg.rwy~". Cleared to take off.",
 # ground:
       taxiplat: "Taxi to platform.",
       taxi: "Taxi to holding point Runwaid " ~arg.rwy ~" and report when ready.",
       taxitwr: "Taxi to holding point Runwaid " ~arg.rwy 
              ~". Contact tower at " ~TWR ~" when ready.",
 # others:
       unknown: "Report your position." ,
       bye: "Good day."

		};
		return ph[key];
}

var phrase_test = func(str,icao) {
    var h = {ac:"Alpha Bravo Delta", apt:airportinfo(icao), qnh:"1013", q:"29 point 92", deppalt:"3500",
           torwy:182, headg:108, station:"tower", rwy:"1 0 R "
            };
    var test = phrase(str,h);
    setprop("/sim/sound/voices/atc", test);
    print("phrase_test(",str,",",icao,"): ", test);
}

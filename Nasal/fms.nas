##########################################
# FMS CLASS - Speed & Altitude Controls
# C. Le Moigne (clm76) - 2017
##########################################

var almTod = nil;
var altInd = nil;
var altWP_curr = nil;
var altWP_next = nil;
var apr_set = 0;
var asel = nil;
var cruise_kt = nil;
var cruise_mc = nil;
var curr_wp = nil;
var dist_b_tod = 4; # alarm distance before TOD
var f_dist = nil;
var flag_tod = nil;
var fms_app = 0;
var ind = nil;
var in_range = 0;
var leg_dist = nil;
var lock_gs = 0;
var slope = nil;
var tod_dist = nil;
var tod = nil;
var tot_dist = nil;
var topDescent = nil;
var top_of_descent = nil;
var v_tod = []; # for tod distances and altitudes
var v_ind = 0; # index for v_tod vector
var v_alt = std.Vector.new(); # for wp altitudes
var wp = nil;
var wp_alt = nil;
var wp_dist = nil;
var x = nil;

var FMS = {
	new : func () {
		var m = {parents:[FMS]};

		m.vmo = 0;
		m.mmo = 0.92;
		m.set_tgAlt = 0;
		m.fp = nil; # flightplan
    m.gs_calc = nil;
    m.gs_climb = nil;
		m.lastWp_alt = 0;
		m.lastWp_dist = 0;
		m.prevWp_alt = 0;
		m.prevWp_dist = 0;
		m.tod = 0;
    m.dist = nil; # for fps limit function
    m.desc_flag = 0;
    m.active = "autopilot/route-manager/active";
    m.alm_tod = "autopilot/locks/alm-tod";
		m.alt_ind = "instrumentation/altimeter/indicated-altitude-ft";
		m.ap_stat = "autopilot/locks/AP-status";
		m.app5_spd = "autopilot/settings/app5-speed-kt";
		m.app15_spd = "autopilot/settings/app15-speed-kt";
		m.app35_spd = "autopilot/settings/app35-speed-kt";
		m.asel = "autopilot/settings/asel";
		m.climb_kt = "autopilot/settings/climb-speed-kt";
		m.climb_mc = "autopilot/settings/climb-speed-mc";
		m.cruise_alt = "autopilot/route-manager/cruise/altitude-ft";
		m.cruise_kt = "autopilot/settings/cruise-speed-kt";
		m.cruise_mc = "autopilot/settings/cruise-speed-mc";
    m.current_wp = "autopilot/route-manager/current-wp";
		m.dep_agl = "autopilot/settings/dep-agl-limit-ft";
		m.dep_lim = "autopilot/settings/dep-limit-nm";
		m.dep_spd = "autopilot/settings/dep-speed-kt";
		m.desc_angle = "autopilot/settings/descent-angle";
		m.desc_kt = "autopilot/settings/descent-speed-kt";
		m.desc_mc = "autopilot/settings/descent-speed-mc";
		m.dest_alt = "autopilot/route-manager/destination/field-elevation-ft";
		m.dist_rem = "autopilot/route-manager/distance-remaining-nm";
    m.flaps = "controls/flight/flaps-select";
		m.fms = "autopilot/settings/fms";
    m.gs_in_range = "autopilot/internal/gs-in-range";
		m.lock_alt = "autopilot/locks/altitude";
		m.nav_dist = "autopilot/internal/nav-distance";
		m.NAVSRC = "autopilot/settings/nav-source";
#    m.tas = "instrumentation/airspeed-indicator/true-speed-kt";
    m.spd_ctrl = "autopilot/locks/speed-ctrl";
    m.tas = "velocities/groundspeed-kt";
		m.tg_alt = "autopilot/settings/tg-alt-ft";
    m.tg_climb = "autopilot/internal/target-climb-rate-fps";
		m.tg_spd_kt = "autopilot/settings/target-speed-kt";
		m.tg_spd_mc = "autopilot/settings/target-speed-mach";
		m.tot_dist = "autopilot/route-manager/total-distance";
    setprop(m.tg_alt,getprop(m.asel)*100);
    setprop("autopilot/settings/fps-limit",-40);
		return m;
	}, # end of new

	listen : func { 
		setlistener(me.active, func(n) {
			if (n.getValue()) {
				me.fp = flightplan();
#        me.rwy_length = me.fp.destination_runway.length*0.00054;
				me.highest_alt = 0;
				me.update();
				for (var i=0;i<me.fp.getPlanSize();i+=1) {
					if (me.fp.getWP(i).alt_cstr > me.highest_alt){
						me.highest_alt = me.fp.getWP(i).alt_cstr;
					}
				}
				if (me.highest_alt > getprop(me.asel)*100) {
					setprop(me.asel,me.highest_alt/100);
				}
				me.fp.clearWPType('pseudo');
				v_alt.clear();
				me.fpCalc();
			}	else {
				setprop(me.fms,0);
			}
		},0,1);

		setlistener(me.asel, func(n) {
      if (!getprop(me.fms)) setprop(me.tg_alt,n.getValue()*100);
      me.fpChange();
		},0,1);

		setlistener(me.fms, func(n) {
      if (!n.getValue()) {
        setprop(me.tg_alt,getprop(me.asel)*100);
        setprop("autopilot/settings/fps-limit",-40);
      }
		},0,0);

		setlistener(me.desc_angle, func {
 			if (getprop(me.active)){
				me.fpChange();
      }
		},0,0);     

	}, # end of listen

  fpChange : func {
			if (getprop(me.active)){
				curr_wp = me.fp.current;
				me.fp.clearWPType('pseudo'); # reset TOD
				v_tod = [];
				v_ind = 0;
				v_alt.clear();
				me.fpCalc();

        ### Aircraft pos ###
  			me.dist_dep = getprop(me.tot_dist)-getprop(me.dist_rem);
        ### Search Current Wp ###
				for (var i=0;i<me.fp.getPlanSize()-1;i+=1) {
          if (me.dist_dep < me.fp.getWP(i).distance_along_route) {
             curr_wp = i;
             break;
          }
        }
				setprop(me.current_wp,curr_wp);
			}
  }, # end of fpChange

	fpCalc : func {
		asel = getprop(me.asel)*100;
		wp_alt = asel;
		altWP_curr = 0;
		altWP_next = 0;
		wp_dist = 0;
		f_dist = 0;
		leg_dist = 0;
		tot_dist = getprop(me.tot_dist);
		tod_dist = tot_dist;
		tod = 0;
		flag_tod = 0;
		topDescent = 0;
		wp = nil;
		top_of_descent = 0;
		v_alt.append(0);

		### Calculate altitudes and insert in a vector ###
		for (var i=1;i<me.fp.getPlanSize()-1;i+=1) {
				### Departure ###
			if (me.fp.getWP(i).wp_type == 'basic' and me.fp.getWP(i).distance_along_route < tot_dist/2) {
				if (me.fp.getWP(i).alt_cstr <= 0) wp_alt = asel;
				else if (me.fp.getWP(i).alt_cstr > 0 and me.fp.getWP(i+1).distance_along_route > tot_dist/2) wp_alt = asel;
				else wp_alt = me.fp.getWP(i).alt_cstr;
			} 
				### Navaids ###
			if (me.fp.getWP(i).wp_type == 'navaid') {
				if (me.fp.getWP(i).alt_cstr > 0) wp_alt = me.fp.getWP(i).alt_cstr;
				else if (me.fp.getWP(i).alt_cstr <= 0 and me.fp.getWP(i-1).wp_type == 'basic') 
					wp_alt = asel; 
			}
				### Approach ###
			if (me.fp.getWP(i).wp_type == 'basic' and me.fp.getWP(i).distance_along_route > tot_dist/2) { 
				if (me.fp.getWP(i).alt_cstr <= 0) wp_alt = v_alt.vector[i-1];
				else wp_alt = me.fp.getWP(i).alt_cstr;
			} 

			 ### Store Altitudes in a vector ###
			v_alt.append(wp_alt);
		}
		v_alt.append(0); # last for destination

		### TOD Calc ###
		for (var i=1;i<me.fp.getPlanSize()-1;i+=1) {
			if (asel < me.highest_alt) {
				if (v_alt.vector[i] <= 0) {
					for (var j=i;j<me.fp.getPlanSize()-1;j+=1) {
						if (v_alt.vector[j] > 0) {
							v_alt.vector[i] = v_alt.vector[j];					
							break;
						}
					}
				}
			}
			else {
				altWP_curr = v_alt.vector[i];
				f_dist = 	me.fp.getWP(i).distance_along_route;			
				### Search for tod ###
				for (var j=i+1;j<me.fp.getPlanSize()-1;j+=1) {
					if (v_alt.vector[j] < altWP_curr) {
						altWP_next = v_alt.vector[j];
						wp_dist = me.fp.getWP(j).distance_along_route;
						leg_dist = wp_dist - f_dist;
            tod = (altWP_curr-altWP_next)/(math.sin(getprop(me.desc_angle)*D2R)*6076.12);
						### Create tod ###
						if (leg_dist > tod*1.20 and leg_dist > 10) {
#						if (leg_dist > tod*1.15 and leg_dist > 5) {
							flag_tod = 0;
							top_of_descent = tot_dist-wp_dist+tod;
							tod_dist = wp_dist-tod;
							topdescent = me.fp.pathGeod(-1, - top_of_descent);
							wp = createWP(topdescent.lat,topdescent.lon,"TOD",'pseudo');
						}
						break;
					} 					
				}
				### Insert tod in the flightplan ###
						# parabolic functions to calculate TOD position versus ASEL #		
				if (asel <= 420000) {
					x = 1.5/100000000*math.pow(asel,2)+0.00163*asel + 9.24;
				} else { 
					x = 6.25/10000000*math.pow(asel,2)+0.039225*asel + 647;
				}
				if (tod_dist < me.fp.getWP(i+1).distance_along_route and flag_tod == 0 and tod_dist > x) {
          if (wp != nil) {
					  me.fp.insertWP(wp,i+1);
					  v_alt.insert(i+1,altWP_curr);
					  flag_tod = 1;
          }
				}	else wp = nil;

				if (me.fp.getWP(i).wp_name == 'TOD') {
					me.prevWp_dist = tot_dist-me.fp.getWP(i).distance_along_route;
					me.prevWp_alt = v_alt.vector[i];
					for (var j=i+1;j<me.fp.getPlanSize()-1;j+=1) {
						if (v_alt.vector[j] < v_alt.vector[i]) {
							me.lastWp_dist = tot_dist-me.fp.getWP(j).distance_along_route;
							me.lastWp_alt = v_alt.vector[j];
							break;
						}
					}
					append(v_tod,me.prevWp_dist);
					append(v_tod,me.lastWp_dist);
					append(v_tod,me.lastWp_alt);
				}
				
				### Calculate intermediates altitudes for VSD ###
				me.altCalc(tot_dist,i);
			}
		}
	}, # end of fpCalc

	altCalc : func (tot_dist,i) {
			var dist_wp = tot_dist - me.fp.getWP(i).distance_along_route;
			if (dist_wp < me.prevWp_dist and dist_wp > me.lastWp_dist) {
				var l = dist_wp-me.lastWp_dist;
				var L = me.prevWp_dist - me.lastWp_dist;
				var h = me.prevWp_alt - me.lastWp_alt;
				alt = l*h/L + me.lastWp_alt;
				v_alt.vector[i] = int(alt);
			}
	}, # end of altCalc

	update : func {
		if (getprop(me.fms)) {
			me.dist_dep = getprop(me.tot_dist)-getprop(me.dist_rem);
			setprop(me.cruise_alt,getprop(me.asel)*100);
      curr_wp = getprop(me.current_wp);
      me.speed();

				### Takeoff ###
			if (getprop(me.lock_alt) == "VALT" and getprop(me.ap_stat) != "AP") {
          in_range = 0;			
				if (v_alt.vector[curr_wp] > 0)
					me.set_tgAlt = math.round(v_alt.vector[curr_wp],100);
			}
				### En route ###
			if (getprop(me.ap_stat) == "AP") {
				if (left(getprop(me.NAVSRC),3) == "FMS" and getprop(me.lock_alt) == "VALT" or lock_gs) {

          ### Descent Flag ###
          if (v_alt.vector[curr_wp] < v_alt.vector[curr_wp-1] or (v_alt.vector[curr_wp+1] < v_alt.vector[curr_wp] and me.fp.getWP(curr_wp).leg_distance <= 5)) me.desc_flag = 1;
          else me.desc_flag = 0;

					### Alarm before TOD ###
					if (me.fp.getWP(curr_wp).wp_name == 'TOD' and getprop(me.nav_dist) >= 0 and getprop(me.nav_dist) < dist_b_tod) almTod = 1;
					else if (size(v_tod) > 0 and getprop(me.dist_rem) <= v_tod[v_ind] + dist_b_tod and  getprop(me.dist_rem) > v_tod[v_ind]) almTod = 1;
					else almTod = 0;
					if (almTod != getprop(me.alm_tod)) {
						setprop(me.alm_tod,almTod);
					}

					### Between TOD and last reference Wp ###
					if (size(v_tod) > 0 and getprop(me.dist_rem) <= v_tod[v_ind] and getprop(me.dist_rem) >= v_tod[v_ind+1]) me.tod = 1;
					else me.tod = 0;

					### Approach
					if (getprop(me.NAVSRC) == "FMS1") ind=0;
					if (getprop(me.NAVSRC) == "FMS2") ind=1;
            
                ### Switch FMS --> GS ###
          me.gs_climb = getprop("instrumentation/nav["~ind~"]/gs-rate-of-climb");
          if (in_range) {
            me.set_tgAlt = getprop(me.dest_alt);
            if (!apr_set) {
              if (lock_gs) {citation.set_apr();apr_set = 1}
            }
            if (!lock_gs) {
              me.gs_calc = getprop(me.tg_climb);
              if (abs(me.gs_climb - getprop(me.tg_climb)) <= 5 or getprop(me.dist_rem) < 9)
                 lock_gs = 1;
              else lock_gs = 0;
            } else me.gs_calc = me.gs_climb;
            setprop(me.tg_climb,me.gs_calc);
          } else {
            if (getprop(me.gs_in_range) and getprop(me.dist_rem) <= 20) in_range = 1;
                ### Without GS ###
            else if (getprop(me.dist_rem) < 9 and !me.tod) {
              fms_app = 1;
              me.set_tgAlt = getprop(me.dest_alt);             
              me.fps_lim(1);
            } else {
              fms_app = 0;

						  ### Last Wp reference ###
						  if (size(v_tod) > 0 and int(getprop(me.dist_rem)) == int(v_tod[v_ind+1])-1) {
							  me.tod = 0;
							  if (v_ind < size(v_tod)-3) v_ind+=3;
						  }

						  ### Setting target altitude ###
						  if (!me.tod) {
                if (getprop(me.dist_rem) < me.prevWp_dist and getprop(me.dist_rem) > me.lastWp_dist) me.set_tgAlt = math.round(me.lastWp_alt,100);
                else me.set_tgAlt = math.round(v_alt.vector[curr_wp],100);
						  } else me.set_tgAlt = math.round(v_tod[v_ind+2],100);
            }
          }
        }
        setprop("autopilot/locks/fms-gs",lock_gs);
        setprop("autopilot/locks/fms-app",fms_app);
			} # end of AP
      setprop(me.tg_alt,me.set_tgAlt);
		}
		settimer(func me.update(),0.1);
	}, # end of update

  speed : func {
    if (!getprop(me.spd_ctrl)) {
				      ### Departure ###
      if (me.dist_dep < getprop(me.dep_lim) and getprop(me.alt_ind) < getprop(me.dep_agl)) {
	      setprop(me.tg_spd_kt,getprop(me.dep_spd));
      } else if (me.dist_dep < 10) {
		      setprop(me.tg_spd_kt,getprop(me.climb_kt));
      } else {
              ### Holding patterns ###
        if (getprop("autopilot/auto-hold/enable-exit"))
          setprop(me.tg_spd_kt,getprop("autopilot/auto-hold/speed")); 
				      ### Near before TOD ###
	      else if (getprop(me.alm_tod)) {
		      setprop(me.tg_spd_mc,getprop(me.desc_mc));
		      setprop(me.tg_spd_kt,getprop(me.desc_kt));
	      } else {
				      ### After tod ###
          if (me.tod) {
            setprop(me.tg_spd_mc,getprop(me.desc_mc));
            setprop(me.tg_spd_kt,getprop(me.desc_kt));
            me.fps_lim(0);
		      } else {
			      ### Climb ###
			      if (getprop(me.alt_ind) < getprop(me.tg_alt)-100) {
				      setprop(me.tg_spd_mc,getprop(me.climb_mc));
			        setprop(me.tg_spd_kt,getprop(me.climb_kt));
				      ### Descent ###
			      } else if (getprop(me.dist_rem) <= 20) {
					      setprop(me.tg_spd_kt,200);
                me.fps_lim(0);
			      }	else if (me.desc_flag){
					      setprop(me.tg_spd_mc,getprop(me.desc_mc));
					      setprop(me.tg_spd_kt,getprop(me.desc_kt));
                me.fps_lim(0);
			      } else if (me.fp.getWP(curr_wp).wp_name == 'TOD' and me.fp.getWP(curr_wp).leg_distance < 8) {
                setprop(me.tg_spd_mc,getprop(me.tg_spd_mc));
					      setprop(me.tg_spd_kt,getprop(me.tg_spd_kt));
			      }	else {
					      ### Cruise ###
				      if (getprop(me.cruise_kt)) {
					      if (me.fp.getWP(curr_wp).speed_cstr) {
                  setprop(me.cruise_kt,me.fp.getWP(curr_wp).speed_cstr);
                }
                me.cruise_spd();
				      }
			      }	
          }
		    }
      }
	    if (getprop(me.flaps)==2)	
        setprop(me.tg_spd_kt,getprop(me.app5_spd));
	    else if (getprop(me.flaps)==3)
    	  setprop(me.tg_spd_kt,getprop(me.app15_spd));
	    else if (getprop(me.flaps)==4)
		    setprop(me.tg_spd_kt,getprop(me.app35_spd));
    }
  }, # end of speed

	cruise_spd : func {
		cruise_kt = getprop(me.cruise_kt);
		cruise_mc = getprop(me.cruise_mc);
		if (getprop(me.alt_ind) <= 7800) me.vmo = 270;
		if (getprop(me.alt_ind) > 7800 and getprop(me.alt_ind) < 30650) me.vmo = 350;
		if (getprop(me.cruise_kt) >= me.vmo) cruise_kt = me.vmo-10;
		if (getprop(me.cruise_mc) > me.mmo) cruise_mc = me.mmo-0.02;
    setprop(me.tg_spd_mc,cruise_mc);
    setprop(me.tg_spd_kt,cruise_kt);
	}, # end of cruise_spd

  fps_lim : func(x) {  ### Descent fps limit ###
    if (me.tod) me.dist = getprop(me.dist_rem)-v_tod[v_ind+1];
    else {
      if (x == 0) me.dist = getprop("autopilot/internal/nav-distance");
      else me.dist = getprop("autopilot/route-manager/distance-remaining-nm");
    }
    altInd = x == 1 ? getprop("position/altitude-ft") : getprop(me.alt_ind);
    if (x==1) {
      slope = -math.atan2(altInd-me.set_tgAlt,me.dist*6076.12) * R2D;
      setprop("autopilot/settings/target-pitch-deg",slope);
    } else {me.fps_limit = -(altInd-me.set_tgAlt)*getprop(me.tas)/(me.dist*3600);
      setprop("autopilot/settings/target-pitch-deg",getprop("autopilot/internal/pitch-filter"));}
    if (me.fps_limit > 0) me.fps_limit = -5;
    if (me.fps_limit < -70) me.fps_limit = -70;
    setprop("autopilot/settings/fps-limit",me.fps_limit);
  }, # end of fps_lim

}; # end of FMS

var vsd_alt = func { # for VSD
	return (v_alt);
}
###  START ###
var fms_stl = setlistener("sim/signals/fdm-initialized", func {
	var fms = FMS.new();
	fms.listen();
	print("FMS ... Ok");
	removelistener(fms_stl);
},0,0);


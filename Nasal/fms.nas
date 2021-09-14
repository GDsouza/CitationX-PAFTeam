#############################################
# FMS CLASS - Speed & Altitude Controls
# C. Le Moigne (clm76) - 2017  - release 2020
#############################################

var almTod = nil;
var altInd = nil;
var altWP_curr = nil;
var altWP_next = nil;
var apr_set = 0;
var asel = nil;
var cr_kt = nil;
var cr_mc = nil;
var curr_wp = nil;
var desc_flag = 0;
var dist = nil; # for fps limit function
var dist_b_tod = 4; # alarm distance before TOD
var dist_dep = nil;
var f_dist = nil;
var flag_pcdr = 0;
var flag_tod = nil;
var fms_app = 0;
var fp = nil; # flightplan
var fps_limit = 0;
var gs_calc = nil;
var gs_climb = nil;
var ind = nil;
var in_range = 0;
var lastWp_alt = 0;
var lastWp_dist = 0;
var leg_dist = nil;
var lock_gs = 0;
var mmo = 0.92;
var prevWp_alt = 0;
var prevWp_dist = 0;
var slope = nil;
var set_tgAlt = 0;
var tod = 0;
var tod_dist = nil;
var top_d = nil;
var tot_dist = nil;
var topDescent = nil;
var top_of_descent = nil;
var v = nil;
var v_tod = []; # for tod distances and altitudes
var v_ind = 0; # index for v_tod vector
var v_alt = std.Vector.new(); # for wp altitudes
var vmo = 0;
var wp = nil;
var wp_alt = nil;
var wp_dist = nil;

var alm_tod = "autopilot/locks/alm-tod";
var alt_ind = "instrumentation/altimeter/indicated-altitude-ft";
var ap_stat = "autopilot/locks/AP-status";
var app5_spd = "autopilot/settings/app5-speed-kt";
var app15_spd = "autopilot/settings/app15-speed-kt";
var app35_spd = "autopilot/settings/app35-speed-kt";
var climb_kt = "autopilot/settings/climb-speed-kt";
var climb_mc = "autopilot/settings/climb-speed-mc";
var cr_asel = "autopilot/settings/asel";
var cruise_alt = "autopilot/route-manager/cruise/altitude-ft";
var cruise_kt = "autopilot/settings/cruise-speed-kt";
var cruise_mc = "autopilot/settings/cruise-speed-mc";
var current_wp = "autopilot/route-manager/current-wp";
var dep_agl = "autopilot/settings/dep-agl-limit-ft";
var dep_lim = "autopilot/settings/dep-limit-nm";
var dep_spd = "autopilot/settings/dep-speed-kt";
var desc_angle = "autopilot/settings/descent-angle";
var desc_kt = "autopilot/settings/descent-speed-kt";
var desc_mc = "autopilot/settings/descent-speed-mc";
var dest_alt = "autopilot/route-manager/destination/field-elevation-ft";
var dist_rem = "autopilot/route-manager/distance-remaining-nm";
var flaps = "controls/flight/flaps-select";
var fms = "autopilot/settings/fms";
var fp_active = "autopilot/route-manager/active";
var fps_lim = "autopilot/settings/fps-limit";
var gs_in_range = "autopilot/internal/gs-in-range";
var lock_alt = "autopilot/locks/altitude";
var nav_dist = "autopilot/internal/nav-distance";
var navsrc = "autopilot/settings/nav-source";
var pcdr_active = "autopilot/locks/pcdr-turn-active";
var spd_ctrl = "autopilot/locks/speed-ctrl";
var tas = "velocities/groundspeed-kt";
var tg_alt = "autopilot/settings/tg-alt-ft";
var tg_climb = "autopilot/settings/target-climb-rate-fps";
var tg_spd_kt = "autopilot/settings/target-speed-kt";
var tg_spd_mc = "autopilot/settings/target-speed-mach";
var toga = "autopilot/locks/to-ga";
var tot_dst = "autopilot/route-manager/total-distance";

var FMS = {
	new : func () {
		var m = {parents:[FMS]};

    setprop(tg_alt,getprop(cr_asel)*100);
    setprop(fps_lim,-40);
		return m;
	}, # end of new

	listen : func { 
		setlistener(fp_active, func(n) {
			if (n.getValue()) {
				fp = flightplan();
				me.highest_alt = 0;
				me.update();
				for (var i=0;i<fp.getPlanSize();i+=1) {
					if (fp.getWP(i).alt_cstr > me.highest_alt){
						me.highest_alt = fp.getWP(i).alt_cstr;
					}
				}
				if (me.highest_alt > getprop(cr_asel)*100) {
					setprop(cr_asel,me.highest_alt/100);
				}
				fp.clearWPType('pseudo');
				v_alt.clear();
			  v_tod = [];
				me.fpCalc();
			}	else {
				setprop(fms,0);
			}
		},0,1);

		setlistener(cr_asel, func(n) {
      if (!getprop(fms)) setprop(tg_alt,n.getValue()*100);
      me.fpChange();
		},0,1);

		setlistener(fms, func(n) {
      if (!n.getValue()) {
        setprop(tg_alt,getprop(cr_asel)*100);
        setprop("autopilot/settings/fps-limit",-40);
      }
		},0,0);

		setlistener(desc_angle, func {
 			if (getprop(fp_active)){
				me.fpChange();
      }
		},0,0);     

		setlistener(pcdr_active, func(n) {
 			if (n.getValue()) {
        f_dist = 0;
        v_alt.vector[-2] = fp.getWP(fp.getPlanSize()-5).alt_cstr;
        v_alt.pop(-1);
        for (i=4;i>=1;i-=1) {;
				  v_alt.append(fp.getWP(fp.getPlanSize()-i).alt_cstr);
          f_dist += fp.getWP(fp.getPlanSize()-i).leg_distance;
        }
        ### Recreate TOD Vector ###
        v_tod[size(v_tod)-1] = 2500;
        v_tod[size(v_tod)-2] += fp.getWP(fp.getPlanSize()-1).leg_distance;
        v_tod[size(v_tod)-3] += f_dist;
      }
		},0,0);     

	}, # end of listen

  fpChange : func {
		if (getprop(fp_active)){
			curr_wp = fp.current;
			fp.clearWPType('pseudo'); # reset TOD
			v_tod = [];
			v_ind = 0;
			v_alt.clear();
			me.fpCalc();
      ### Aircraft pos ###
			dist_dep = getprop(tot_dst)-getprop(dist_rem);
      ### Search Current Wp ###
			for (var i=0;i<fp.getPlanSize()-1;i+=1) {
        if (dist_dep < fp.getWP(i).distance_along_route) {
          curr_wp = i;
          break;
        }
      }
			setprop(current_wp,curr_wp);
		}
  }, # end of fpChange

	fpCalc : func {
		asel = getprop(cr_asel)*100;
		wp_alt = asel;
		altWP_curr = 0;
		altWP_next = 0;
		wp_dist = 0;
		f_dist = 0;
		leg_dist = 0;
		tot_dist = getprop(tot_dst);
		top_d = 0;
		flag_tod = 0;
		topDescent = 0;
		wp = nil;
		top_of_descent = 0;
    dest_apt = getprop("autopilot/route-manager/destination/airport");
    dest_rwy = getprop("autopilot/route-manager/destination/runway");

		### Calculate altitudes and insert in a vector ###
		for (var i=0;i<fp.getPlanSize()-1;i+=1) {
				### Departure ###
      if (fp.current == 0) wp_alt = fp.getWP(i+1).alt_cstr;
			if (fp.getWP(i).wp_type == 'basic' and fp.getWP(i).distance_along_route < tot_dist/2) {
				if (fp.getWP(i).alt_cstr <= 0) wp_alt = asel;
				else if (fp.getWP(i).alt_cstr > 0 and fp.getWP(i+1).distance_along_route > tot_dist/2) wp_alt = asel;
				else wp_alt = fp.getWP(i).alt_cstr;
			} 
				### Navaids ###
			if (fp.getWP(i).wp_type == 'navaid') {
				if (fp.getWP(i).alt_cstr > 0) wp_alt = fp.getWP(i).alt_cstr;
				else if (fp.getWP(i).alt_cstr <= 0 and fp.getWP(i-1).wp_type == 'basic') 
					wp_alt = asel; 
			}
				### Approach ###
			if (fp.getWP(i).wp_type == 'basic' and fp.getWP(i).distance_along_route > tot_dist/2) { 
				if (fp.getWP(i).alt_cstr <= 0) wp_alt = v_alt.vector[i-1];
				else wp_alt = fp.getWP(i).alt_cstr;
			} 

			 ### Store Altitudes in a vector ###
			v_alt.append(wp_alt);
		}
		v_alt.append(0); # last for destination
		### TOD Calc ###
		for (var i=1;i<fp.getPlanSize()-1;i+=1) {
			if (asel < me.highest_alt) {
				if (v_alt.vector[i] <= 0) {
					for (var j=i;j<fp.getPlanSize()-1;j+=1) {
						if (v_alt.vector[j] > 0) {
							v_alt.vector[i] = v_alt.vector[j];					
							break;
						}
					}
				}
			}	else {
				altWP_curr = v_alt.vector[i];
				f_dist = 	fp.getWP(i).distance_along_route;			
				### Search for tod ###
				for (var j=i+1;j<fp.getPlanSize()-1;j+=1) {
					if (v_alt.vector[j] < altWP_curr) {
						altWP_next = v_alt.vector[j];
						wp_dist = fp.getWP(j).distance_along_route;
						leg_dist = wp_dist - f_dist;
            top_d = (altWP_curr-altWP_next)/(math.sin(getprop(desc_angle)*D2R)*6076.12);
						### Create tod ###
						if (leg_dist > top_d*1.20 and leg_dist > 10) {
							flag_tod = 0;
							top_of_descent = tot_dist-wp_dist+top_d;
							tod_dist = wp_dist-top_d;
							topdescent = fp.pathGeod(-1, - top_of_descent);
							wp = createWP(topdescent.lat,topdescent.lon,"TOD",'pseudo');
						}
						break;
					} 					
				}
				### Insert tod in the flightplan ###
						# parabolic functions to calculate TOD position versus ASEL #		
				if (asel <= 420000) {
					v = 1.5/100000000*math.pow(asel,2)+0.00163*asel + 9.24;
				} else { 
					v = 6.25/10000000*math.pow(asel,2)+0.039225*asel + 647;
				}
				if (tod_dist != nil and tod_dist < fp.getWP(i+1).distance_along_route 
            and flag_tod == 0 and tod_dist > v) {
          if (wp != nil) {
					  fp.insertWP(wp,i+1);
					  v_alt.insert(i+1,altWP_curr);
					  flag_tod = 1;
          }
				}	else wp = nil;

				if (fp.getWP(i).wp_name == 'TOD') {
					prevWp_dist = tot_dist-fp.getWP(i).distance_along_route;
					prevWp_alt = v_alt.vector[i];
					for (var j=i+1;j<fp.getPlanSize()-1;j+=1) {
						if (v_alt.vector[j] < v_alt.vector[i]) {
							lastWp_dist = tot_dist-fp.getWP(j).distance_along_route;
							lastWp_alt = v_alt.vector[j];
							break;
						}
					}
					append(v_tod,prevWp_dist);
					append(v_tod,lastWp_dist);
					append(v_tod,lastWp_alt);
				}
				
				### Calculate intermediates altitudes for VSD ###
				me.altCalc(tot_dist,i);
			}
		}
	}, # end of fpCalc

	altCalc : func (tot_dist,i) {
		var dist_wp = tot_dist - fp.getWP(i).distance_along_route;
		if (dist_wp < prevWp_dist and dist_wp > lastWp_dist) {
			var l = dist_wp-lastWp_dist;
			var L = prevWp_dist - lastWp_dist;
			var h = prevWp_alt - lastWp_alt;
			alt = l*h/L + lastWp_alt;
			v_alt.vector[i] = int(alt);
		}
	}, # end of altCalc

	update : func {
		if (getprop(fms)) {
			dist_dep = getprop(tot_dst)-getprop(dist_rem);
			setprop(cruise_alt,getprop(cr_asel)*100);
      curr_wp = fp.current;
      if (!getprop(spd_ctrl)) me.speed();

				### Takeoff ###
			if (getprop(lock_alt) == "VALT" and getprop(ap_stat) != "AP") {
          in_range = 0;			
				if (v_alt.vector[curr_wp] > 0)
					set_tgAlt = math.round(v_alt.vector[curr_wp],100);
			}
				### En route ###
			if (getprop(ap_stat) == "AP") {
				if (left(getprop(navsrc),3) == "FMS" and getprop(lock_alt) == "VALT" or lock_gs) {

          ### Descent Flag ###
          if (v_alt.vector[curr_wp] < v_alt.vector[curr_wp-1] or (v_alt.vector[curr_wp+1] < v_alt.vector[curr_wp] and fp.getWP(curr_wp).leg_distance <= 5)) desc_flag = 1;
          else desc_flag = 0;

					### Alarm before TOD ###
					if (fp.getWP(curr_wp).wp_name == 'TOD' and getprop(nav_dist) >= 0 
              and getprop(nav_dist) < dist_b_tod) almTod = 1;
					else almTod = 0;
					if (almTod != getprop(alm_tod)) setprop(alm_tod,almTod);

					### Between TOD and last reference Wp ###
					if (size(v_tod) > 0 and getprop(dist_rem) <= v_tod[v_ind] 
              and getprop(dist_rem) >= v_tod[v_ind+1]) {
            tod = 1;
            flag_pcdr = 1;
					} else {
            tod = 0;
            if (flag_pcdr) {
              setprop(pcdr_active,0);
              flag_pcdr = 0;
            }
          }
					### Approach
          ind = getprop(navsrc) == "FMS1" ? 0 : 1;
            
                ### Switch FMS --> GS ###
          gs_climb = getprop("instrumentation/nav["~ind~"]/gs-rate-of-climb");
          if (in_range) {
            set_tgAlt = getprop(dest_alt);
            if (!apr_set) {
              if (lock_gs) {citation.set_apr();apr_set = 1}
            }
            if (!lock_gs) {
              gs_calc = getprop(tg_climb);
              if (abs(gs_climb - getprop(tg_climb)) <= 5 or getprop(dist_rem) <= 9.5)
                lock_gs = 1;
              else lock_gs = 0;
            } else gs_calc = gs_climb;
            setprop(tg_climb,gs_calc);
          } else {
            if (getprop(gs_in_range) and getprop(dist_rem) <= 9.5
                and !getprop(pcdr_active)) in_range = 1;

                ### Without GS ###
            else if (getprop(dist_rem) < 9 and !tod) {
              fms_app = 1;
              set_tgAlt = getprop(dest_alt);             
              me.fpsLim(1);
            } else {
              fms_app = 0;

				      ### Last Wp reference ###
				      if (size(v_tod) > 0 
                  and int(getprop(dist_rem)) == int(v_tod[v_ind+1])-1) {
					      tod = 0;
					      if (v_ind < size(v_tod)-3) v_ind+=3;
				      }
				      ### Setting target altitude ###
				      if (!tod) {
                if (getprop(dist_rem) < prevWp_dist 
                    and getprop(dist_rem) > lastWp_dist) 
                  set_tgAlt = math.round(lastWp_alt,100);
                else set_tgAlt = math.round(v_alt.vector[curr_wp],100);
				      } else set_tgAlt = math.round(v_tod[v_ind+2],100);
            }
          }
        }
        setprop("autopilot/locks/fms-gs",lock_gs);
        setprop("autopilot/locks/fms-app",fms_app);
			} # end of AP
      setprop(tg_alt,set_tgAlt);
		}
		settimer(func me.update(),0.1);
	}, # end of update

  speed : func {
				      ### Departure ###
    if (dist_dep < getprop(dep_lim) and getprop(alt_ind) < getprop(dep_agl)) {
      setprop(tg_spd_kt,getprop(dep_spd));
    } else if (dist_dep < 10) {
	      setprop(tg_spd_kt,getprop(climb_kt));
    } else {
            ### Holding patterns ###
      if (getprop("autopilot/locks/hold/enable-exit"))
        setprop(tg_spd_kt,getprop("autopilot/locks/hold/speed")); 
			      ### Near before TOD ###
      else if (getprop(alm_tod)) {
	      setprop(tg_spd_mc,getprop(desc_mc));
	      setprop(tg_spd_kt,getprop(desc_kt));
      } else {
			      ### After tod ###
        if (tod) {
          setprop(tg_spd_mc,getprop(desc_mc));
          setprop(tg_spd_kt,getprop(desc_kt));
          me.fpsLim(0);
	      } else {
			      ### Descent ###
          if (getprop(toga)) setprop(tg_spd_kt,getprop(climb_kt));
		      else if (getprop(dist_rem) <= 20) {
              if (getprop(flaps)==2) setprop(tg_spd_kt,getprop(app5_spd));
              else if (getprop(flaps)==3) setprop(tg_spd_kt,getprop(app15_spd));
              else if (getprop(flaps)==4) setprop(tg_spd_kt,getprop(app35_spd));
              else setprop(tg_spd_kt,200);
              me.fpsLim(0);
		      }	else if (desc_flag){
				      setprop(tg_spd_mc,getprop(desc_mc));
				      setprop(tg_spd_kt,getprop(desc_kt));
              me.fpsLim(0);
		      } else if (fp.getWP(curr_wp).wp_name == 'TOD' and fp.getWP(curr_wp).leg_distance < 8) {
              setprop(tg_spd_mc,getprop(tg_spd_mc));
				      setprop(tg_spd_kt,getprop(tg_spd_kt));

		            ### Climb ###
		      }	else if (getprop(alt_ind) < getprop(tg_alt)-100) {
			        setprop(tg_spd_mc,getprop(climb_mc));
		          setprop(tg_spd_kt,getprop(climb_kt));
		      } else {
				        ### Cruise ###
            if (getprop(cruise_kt)) {
				        if (fp.getWP(curr_wp).speed_cstr)
                  setprop(cruise_kt,fp.getWP(curr_wp).speed_cstr);
                me.cruise_spd();
			      }
		      }	
        }
	    }
    }
  }, # end of speed

	cruise_spd : func {
    cr_kt = getprop(cruise_kt);
    cr_mc = getprop(cruise_mc);
		if (getprop(alt_ind) <= 7800) vmo = 270;
		if (getprop(alt_ind) > 7800 and getprop(alt_ind) < 30650) vmo = 350;
		if (cr_kt >= vmo) cr_kt = vmo-10;
		if (cr_mc > mmo) cr_mc = mmo-0.02;
    setprop(tg_spd_kt,cr_kt);
    setprop(tg_spd_mc,cr_mc);
	}, # end of cruise_spd

  fpsLim : func(v) {  ### Descent fps limit ###
    if (tod) dist = getprop(dist_rem)-v_tod[v_ind+1];
    else {
      if (v == 0) dist = getprop("autopilot/internal/nav-distance");
      else dist = getprop("autopilot/route-manager/distance-remaining-nm");
    }
    altInd = v == 1 ? getprop("position/altitude-ft") : getprop(alt_ind);
    if (v == 1) {
      slope = -math.atan2(altInd-set_tgAlt,dist*6076.12) * R2D;
      setprop("autopilot/settings/target-pitch-deg",slope);
    } else {
      fps_limit = -(altInd-set_tgAlt)*getprop(tas)/(dist*3600);
      setprop("autopilot/settings/target-pitch-deg",getprop("autopilot/internal/pitch-filter"));
    }
    if (fps_limit > 0) fps_limit = -5;
    if (fps_limit < -40) me.fps_limit = -40;
    setprop(fps_lim,fps_limit);
  }, # end of fpsLim

}; # end of FMS

var vsd_alt = func { # for VSD
	return (v_alt);
}
###  START ###
var fms_stl = setlistener("sim/signals/fdm-initialized", func {
	var _fms = FMS.new();
	_fms.listen();
	print("FMS ... Ok");
	removelistener(fms_stl);
},0,0);


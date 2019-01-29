### Canvas RMU ###
### C. Le Moigne (clm76) - 2016-2017 ###

props.globals.initNode("instrumentation/rmu/trsp-num",1,"INT");
props.globals.initNode("instrumentation/rmu/unit/delete",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/insert",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/mem-dsp",-1,"INT");
props.globals.initNode("instrumentation/rmu/unit/mem-freq",0,"DOUBLE");
props.globals.initNode("instrumentation/rmu/unit/mem-nav",0,"INT");
props.globals.initNode("instrumentation/rmu/unit/pge",0,"INT");
props.globals.initNode("instrumentation/rmu/unit/selected",0,"INT");
props.globals.initNode("instrumentation/rmu/unit/sto",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/swp1",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/swp2",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/test",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/dme-selected",0,"INT");
props.globals.initNode("instrumentation/dme/dme-id","","STRING");
props.globals.initNode("instrumentation/tacan/frequencies/selected-channel","","STRING");
props.globals.initNode("instrumentation/tacan/frequencies/selected-mhz",0,"DOUBLE");
props.globals.initNode("instrumentation/tacan/id","","STRING");
props.globals.initNode("instrumentation/transponder/unit/ident",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/delete",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/insert",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/mem-dsp",-1,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/mem-freq",0,"DOUBLE");
props.globals.initNode("instrumentation/rmu/unit[1]/mem-nav",0,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/pge",0,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/selected",0,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/sto",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/swp1",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/swp2",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/test",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/dme-selected",0,"INT");
props.globals.initNode("instrumentation/transponder/unit[1]/ident",0,"BOOL");
props.globals.initNode("instrumentation/dme[1]/dme-id","","STRING");
props.globals.initNode("instrumentation/tacan[1]/frequencies/selected-channel","","STRING");
props.globals.initNode("instrumentation/tacan[1]/frequencies/selected-mhz",0,"DOUBLE");
props.globals.initNode("instrumentation/tacan[1]/id","","STRING");

setprop("instrumentation/dme/frequencies/source","instrumentation/dme/frequencies/selected-mhz");
setprop("instrumentation/dme[1]/frequencies/source","instrumentation/dme[1]/frequencies/selected-mhz");

var nav_freq = ["instrumentation/nav/frequencies/selected-mhz","instrumentation/nav[1]/frequencies/selected-mhz"];
var nav_id = ["instrumentation/nav/nav-id","instrumentation/nav[1]/nav-id"];
var dme_freq = ["instrumentation/dme/frequencies/selected-mhz","instrumentation/dme[1]/frequencies/selected-mhz"];
var dme_id = ["instrumentation/dme/dme-id","instrumentation/dme[1]/dme-id"];
var dme_sel = ["instrumentation/rmu/unit/dme-selected","instrumentation/rmu/unit[1]/dme-selected"];
var tac_freq = ["instrumentation/tacan/frequencies/selected-mhz","instrumentation/tacan[1]/frequencies/selected-mhz"];
var tac_id = ["instrumentation/tacan/id","instrumentation/tacan[1]/id"];
var rmu_sel = ["instrumentation/rmu/unit/selected","instrumentation/rmu/unit[1]/selected"];
var path = getprop("/sim/fg-home")~"/aircraft-data/";
var nav_src = "autopilot/settings/nav-source";
var tcas_mode = "instrumentation/tcas/inputs/mode";
var full = nil;
var memo = nil;
var mem_1 = nil;
var com_mem = nil;
var nav_mem = nil;
var more = nil;
var memVec = [nil,nil];
var comVec = [nil,nil];
var navVec = [nil,nil];
var data = [nil,nil];
var memPath = [nil,nil];
var dme = [0,0];
var tacan = [nil,nil,nil,nil,nil];
var navaid = nil;
var nav_dme = nil;
var freq = nil;

var RMU = {
	new: func(x) {
		var m = {parents:[RMU]};
    if (!x) {
		  m.rmu = canvas.new({
			  "name": "RMU-L", 
			  "size": [1024, 1024],
			  "view": [800, 1024],
			  "mipmapping": 1 
		  });
		  m.rmu.addPlacement({"node": "RMU.screenL"});
		  m.group = m.rmu.createGroup();
		  canvas.parsesvg(m.group, "Aircraft/CitationX/Models/Instruments/RMU/RMU.svg");
    } else {
		  m.rmu = canvas.new({
			  "name": "RMU-R", 
			  "size": [1024, 1024],
			  "view": [800, 1024],
			  "mipmapping": 1 
		  });
		  m.rmu.addPlacement({"node": "RMU.screenR"});
		  m.group = m.rmu.createGroup();
		  canvas.parsesvg(m.group, "Aircraft/CitationX/Models/Instruments/RMU/RMU.svg");
    }

		m.cdr =	m.group.createChild("path")
					.moveTo(98,237)
					.horiz(286)
					.vert(88)
					.horiz(-286)
					.close()
					.setColor(0.95,0.75,0)
					.setStrokeLineWidth(10)			
          .setVisible(1);

		m.mem = m.rmu.createGroup();
		canvas.parsesvg(m.mem, "Aircraft/CitationX/Models/Instruments/RMU/mem.svg");
		m.fra =	m.mem.createChild("path")
					.moveTo(95,130)
					.horiz(420)
					.vert(90)
					.horiz(-420)
					.close()
					.setColor(0.95,0.75,0)
					.setStrokeLineWidth(10)			
					.setVisible(0);

		m.mem.setVisible(0);

		m.test = m.rmu.createGroup();
		canvas.parsesvg(m.test, "Aircraft/CitationX/Models/Instruments/RMU/test.svg");
		m.test.setVisible(0);

		m.text = {};
		m.text_val = ["comFreq","navFreq","comStby", "navStby",
										"trspCode","trspMode","trspNum","adfFreq","adfMode",
										"memCom","memNav","comNum","navNum","adfNum","mlsNum",
										"full","ident","dmeFreq","dmeId","dmeHold","tacChan"];
		foreach(var i;m.text_val) {
			m.text[i] = m.group.getElementById(i);
		}

#    if (getprop("/sim/version/flightgear") != "2017.4.0") { # bug with 2017.4.0
      var info = airportinfo(getprop("/autopilot/route-manager/departure/airport"));
      var fcom = nil;
      if (size(info.comms()) > 0) {
        foreach (var freq;info.comms()) {
          if (find("TWR",freq.ident)!=-1 or find("ower",freq.ident)!=-1) {
            fcom = freq.frequency;
            break;
          }
          else if (find("MULT",freq.ident)!=-1) {
            if (find("LIGHTS",freq.ident)!=-1) continue;
            fcom = freq.frequency;
            break;
          }
        }
        if (fcom != nil) {
          setprop("instrumentation/comm/frequencies/selected-mhz",fcom);
        }
      }
#    }

		return m;
	}, # end of new

  init : func(x) {
  	### Create Memories if not exist ###
    memPath[x] = path~"CitationX-RMUmem"~x~".xml";
    var xfile = subvec(directory(path),2);
    var v = std.Vector.new(xfile);
    if (!v.contains("CitationX-RMUmem"~x~".xml")) {
	    var base = props.Node.new({
		    comMem1 : 0,comMem2 : 0,comMem3 : 0,comMem4 : 0,comMem5 : 0,
		    comMem6 : 0,comMem7 : 0,comMem8 : 0,comMem9 : 0,comMem10 : 0,
		    comMem11 : 0,comMem12 : 0,
		    navMem1 : 0,navMem2 : 0,navMem3 : 0,navMem4 : 0,navMem5 : 0,
		    navMem6 : 0,navMem7 : 0,navMem8 : 0,navMem9 : 0,navMem10 : 0,
		    navMem11 : 0,navMem12 : 0
	    });		
	    io.write_properties(memPath[x],base);
    } 

  	### Create vector for memories ###
    memVec[x] = std.Vector.new();
    for (var i=0;i<12;i+=1) {
	    memVec[x].append(0);
    }

	  ### Load comm memories ###
    comVec[x] = {};
    com_mem = ["comMem1","comMem2","comMem3","comMem4",
							    "comMem5","comMem6","comMem7","comMem8",
							    "comMem9","comMem10","comMem11","comMem12"];
    data[x] = io.read_properties(memPath[x]);
    foreach(var i;com_mem) {
	    comVec[x][i] = data[x].getValue(i);
    }

	  ### Load nav memories ###
    navVec[x] = {};
    nav_mem = ["navMem1","navMem2","navMem3","navMem4",
							    "navMem5","navMem6","navMem7","navMem8",
							    "navMem9","navMem10","navMem11","navMem12"];
    data[x] = io.read_properties(memPath[x]);
    foreach(var i;nav_mem) {
	    navVec[x][i] = data[x].getValue(i);
    }
    
    ### Dme Init ###
    me.text.dmeFreq.hide();
    me.text.dmeId.hide();
    me.text.dmeHold.hide();
    me.text.tacChan.hide();

    ### Creating Tacan[1] ###
    var src = props.globals.getNode("/instrumentation/tacan");
    var dst = props.globals.getNode("/instrumentation/tacan[1]");
    props.copy(src,dst);
    
    ### Init Tacan[0] ###   
    var path = "instrumentation/tacan/frequencies/selected-channel[";
    setprop(path~1~"]","0");
    setprop(path~2~"]","9");
    setprop(path~3~"]","9");
    setprop(path~4~"]","X");

    ### Init Tacan[1] ###   
    path = "instrumentation/tacan[1]/frequencies/selected-channel[";
    setprop(path~1~"]","0");
    setprop(path~2~"]","7");
    setprop(path~3~"]","1");
    setprop(path~4~"]","X");

  }, # end of init

	listen : func(x) {
		setlistener("instrumentation/rmu/unit["~x~"]/pge",func (n) {
			setprop("instrumentation/rmu/unit["~x~"]/mem-dsp",-1);
			if (n.getValue()) {
				me.group.setVisible(0);
				me.mem.setVisible(1);
				if (getprop(rmu_sel[x])==0){
          var n = 0;
					foreach(var i;com_mem) {
						memVec[x].vector[n] = comVec[x][i];	
            n+=1;
  				}
        }
				if (getprop(rmu_sel[x])==1){
          var n = 0;
					foreach(var i;nav_mem) {
						memVec[x].vector[n] = navVec[x][i];
            n+=1;
					}
				}
				me.update(x);
				me.refreshMem(x);
				if (memVec[x].vector[0] == 0) {me.fra.hide()}
			} else {
				me.timer.stop();
				setprop("instrumentation/rmu/unit["~x~"]/more",0);
				setprop("instrumentation/rmu/unit["~x~"]/insert",0);
				me.group.setVisible(1);
				me.mem.setVisible(0);
			}
		},0,1);

		setlistener(rmu_sel[x],func(n) {
			if (n.getValue() == 0) me.cdr.setTranslation(0,0);
			if (n.getValue() == 1) {
        if (dme[x] == 0) me.cdr.setTranslation(325,0);
        else me.cdr.setTranslation(325,80);
      }
			if (n.getValue() == 2) me.cdr.setTranslation(0,230);
			if (n.getValue() == 3) me.cdr.setTranslation(325,230);
			if (n.getValue() == 4) me.cdr.setTranslation(0,335);
			if (n.getValue() == 5) me.cdr.setTranslation(325,335);
		},0,1);	

		setlistener("instrumentation/comm["~x~"]/frequencies/selected-mhz", func(n) {
			me.text.comFreq.setText(sprintf("%.3f",n.getValue()));
		},0,0);

		setlistener("instrumentation/comm["~x~"]/frequencies/standby-mhz", func(n) {
      me.freqLimits(x);
			me.text.comStby.setText(sprintf("%.3f",n.getValue()));
			for (var i=0;i<12;i+=1) {
				if (sprintf("%.3f",comVec[x][com_mem[i]]) == sprintf("%.3f",n.getValue())) {
					me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));							
					break;
				}	else {
					me.text.memCom.setText("TEMP-"~sprintf("%d",i+1));
					if (comVec[x][com_mem[i]] == 0) {
						break;
					}					
  			}
			}
		},0,0);

		setlistener("instrumentation/rmu/unit["~x~"]/mem-com", func(n) {
			var i = n.getValue();
			if (comVec[x][com_mem[0]] == 0) {
					me.text.comStby.setText(sprintf("%.3f",getprop("instrumentation/comm["~x~"]/frequencies/standby-mhz")));
			} else {
				if (comVec[x][com_mem[i]] != 0) {
					me.text.comStby.setText(sprintf("%07.3f",comVec[x][com_mem[i]]));
					setprop("instrumentation/comm["~x~"]/frequencies/standby-mhz",comVec[x][com_mem[i]]);
					me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));
				}	else {
					setprop("instrumentation/rmu/unit["~x~"]/mem-com",0);
					me.text.comStby.setText(sprintf("%07.3f",comVec[x][com_mem[0]]));
					me.text.memCom.setText("MEMORY-"~sprintf("%d",1));
				}
			}
		},0,0);

		setlistener(nav_freq[x], func(n) {
			me.text.navFreq.setText(sprintf("%.3f",n.getValue()));
      if (dme[x] == 0) setprop(dme_freq[x],getprop(nav_freq[x]));     
      else me.dmeDisplay(x,0);
		},0,0);

		setlistener("instrumentation/nav["~x~"]/frequencies/standby-mhz", func(n) {
      me.freqLimits(x);
			me.text.navStby.setText(sprintf("%.3f",n.getValue()));
			for (var i=0;i<12;i+=1) {
				if (sprintf("%.3f",navVec[x][nav_mem[i]]) == sprintf("%.3f",n.getValue())) {
					me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));							
					break;
				}	else {
					me.text.memNav.setText("TEMP-"~sprintf("%d",i+1));
					if (navVec[x][nav_mem[i]] == 0) {
						break;
					}					
				}
			}
		},0,0);

		setlistener("instrumentation/rmu/unit["~x~"]/mem-nav", func(n) {
			var i = n.getValue();
			if (navVec[x][nav_mem[0]] == 0) {
					me.text.navStby.setText(sprintf("%.3f",getprop("instrumentation/nav["~x~"]/frequencies/standby-mhz")));
			} else {
				if (navVec[x][nav_mem[i]] != 0) {
					me.text.navStby.setText(sprintf("%07.3f",navVec[x][nav_mem[i]]));
					setprop("instrumentation/nav["~x~"]/frequencies/standby-mhz",navVec[x][nav_mem[i]]);
					me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));
				}	else {
					setprop("instrumentation/rmu/unit["~x~"]/mem-nav",0);
					me.text.navStby.setText(sprintf("%07.3f",navVec[x][nav_mem[0]]));
					me.text.memNav.setText("MEMORY-"~sprintf("%d",1));
				}
			}
		},0,0);

		setlistener("instrumentation/rmu/unit["~x~"]/sto", func(n) {	
			if (n.getValue()) {
				if (getprop(rmu_sel[x]) == 0) {
					if (comVec[x][com_mem[0]] == 0) {
						comVec[x][com_mem[0]] = getprop("instrumentation/comm["~x~"]/frequencies/standby-mhz");
						var name = data[x].getChild(com_mem[0]);
						name.setDoubleValue(sprintf("%07.3f",comVec[x][com_mem[0]]));
						io.write_properties(memPath[x],data[x]);
						me.text.memCom.setText("MEMORY-1");
					} else if (comVec[x][com_mem[0]] != getprop("instrumentation/comm["~x~"]/frequencies/standby-mhz")) {
						if (comVec[x][com_mem[11]] != 0) {
							full = me.text.full;
							me.memFull();
						}
						else {
							for (var i=0;i<12;i+=1) {
								if (comVec[x][com_mem[i]] == 0) {
									comVec[x][com_mem[i]] = getprop("instrumentation/comm["~x~"]/frequencies/standby-mhz");
									var name = data[x].getChild(com_mem[i]);
									name.setDoubleValue(comVec[x][com_mem[i]]);
									io.write_properties(memPath[x],data[x]);
									me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));
									memVec[x].vector[i] = comVec[x][com_mem[i]];
									break;
								}
							}
						}
					}
				}

				if (getprop(rmu_sel[x]) == 1) {
					if (navVec[x][nav_mem[0]] == 0) {
						navVec[x][nav_mem[0]] = getprop("instrumentation/nav["~x~"]/frequencies/standby-mhz");
						var name = data[x].getChild(nav_mem[0]);
						name.setDoubleValue(sprintf("%07.3f",navVec[x][nav_mem[0]]));
						io.write_properties(memPath[x],data[x]);
						me.text.memNav.setText("MEMORY-1");
					} else if (navVec[x][nav_mem[0]] != getprop("instrumentation/nav["~x~"]/frequencies/standby-mhz")) {
						if (navVec[x][nav_mem[11]] != 0) {
							full = me.text.full;
							me.memFull()}
						else {
							for (var i=0;i<12;i+=1) {
								if (navVec[x][nav_mem[i]] == 0) {
									navVec[x][nav_mem[i]] = getprop("instrumentation/nav["~x~"]/frequencies/standby-mhz");
									var name = data[x].getChild(nav_mem[i]);
									name.setDoubleValue(navVec[x][nav_mem[i]]);
									io.write_properties(memPath[x],data[x]);
									me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));
									memVec[x].vector[i] = navVec[x][nav_mem[i]];
									break;
								}
							}
						}
					}
				}
			}
		},0,0);

		setlistener("instrumentation/rmu/unit["~x~"]/insert",func(n) {
			if (n.getValue() and getprop("instrumentation/rmu/unit["~x~"]/mem-dsp") != -1) {
					me.ins.setColor(1,0.35,1);
					if (memVec[x].vector[11] == 0) {
            var mem_dsp = getprop("instrumentation/rmu/unit["~x~"]/mem-dsp");
            more = getprop("instrumentation/rmu/unit["~x~"]/more");
						memVec[x].insert(mem_dsp+1+more,getprop(rmu_sel[x]) == 0 ? 117.975 : 108.000);
            if (mem_dsp == 5) {
              setprop("instrumentation/rmu/unit["~x~"]/more",6);
              mem_dsp = -1;
            } 
            setprop("instrumentation/rmu/unit["~x~"]/mem-dsp",mem_dsp+1);
					} else {
						full = me.full;
						me.memFull();
						setprop("instrumentation/rmu/unit["~x~"]/insert",0);
						me.ins.setColor(1,1,1);
					}
			} else {
				me.ins.setColor(1,1,1);
					if (getprop(rmu_sel[x]) == 0) {
						for (var i=0;i<12;i+=1) {
							comVec[x][com_mem[i]] = memVec[x].vector[i];
							var name = data[x].getChild(com_mem[i]);
							name.setDoubleValue(comVec[x][com_mem[i]]);
							io.write_properties(memPath[x],data[x]);
						}										
					}
				if (getprop(rmu_sel[x]) == 1) {
					for (var i=0;i<12;i+=1) {
						navVec[x][nav_mem[i]]=memVec[x].vector[i];
						var name = data[x].getChild(nav_mem[i]);
						name.setDoubleValue(navVec[x][nav_mem[i]]);
						io.write_properties(memPath[x],data[x]);
					}										
				}
				me.refreshMem(x);
			}
		},0,1);

		setlistener("instrumentation/rmu/unit["~x~"]/mem-freq", func(n) {	
			if (getprop("instrumentation/rmu/unit["~x~"]/insert")) {
        more = getprop("instrumentation/rmu/unit["~x~"]/more");
				memVec[x].vector[getprop("instrumentation/rmu/unit["~x~"]/mem-dsp")+more] = n.getValue();
			}
			
		},0,0);

		setlistener("instrumentation/rmu/unit["~x~"]/delete", func(n) {	
			if (n.getValue()) {
				if (!getprop("instrumentation/rmu/unit["~x~"]/insert")) {
					me.sel = getprop("instrumentation/rmu/unit["~x~"]/mem-dsp");
					more = getprop("instrumentation/rmu/unit["~x~"]/more");
					if (more == 6) {me.sel = me.sel+more}
					if (getprop(rmu_sel[x]) == 0) {					
						memVec[x].remove(comVec[x][com_mem[me.sel]]);
						memVec[x].insert(11,0);
						for (var i=0;i<12;i+=1) {
							comVec[x][com_mem[i]]=memVec[x].vector[i];
							var name = data[x].getChild(com_mem[i]);
							name.setDoubleValue(comVec[x][com_mem[i]]);
							io.write_properties(memPath[x],data[x]);
						}										
					}
					if (getprop(rmu_sel[x]) == 1) {					
						memVec[x].remove(navVec[x][nav_mem[me.sel]]);
						memVec[x].insert(11,0);
						for (var i=0;i<12;i+=1) {
							navVec[x][nav_mem[i]]=memVec[x].vector[i];
							var name = data[x].getChild(nav_mem[i]);
							name.setDoubleValue(navVec[x][nav_mem[i]]);
							io.write_properties(memPath[x],data[x]);
						}										
					}
					me.refreshMem(x);
					if (memVec[x].vector[0] == 0) {me.fra.hide()}
				}
			}
		},0,0);

		setlistener("instrumentation/adf["~x~"]/frequencies/selected-khz", func(n) {	
			me.text.adfFreq.setText(sprintf("%d",n.getValue()));
		},0,0);

		setlistener("instrumentation/adf["~x~"]/mode", func(n) {	
			me.text.adfMode.setText(n.getValue());
		},0,0);

		setlistener("instrumentation/transponder/unit["~x~"]/knob-mode", func(n) {
			var mode = n.getValue();
			var mode_dsp = "";
			if (mode == 0) {mode_dsp = "STANDBY";setprop(tcas_mode,1)}
			if (mode == 1) {mode_dsp = "ATC ON";setprop(tcas_mode,2)}
			if (mode == 2) {mode_dsp = "ATC ALT";setprop(tcas_mode,2)}
			if (mode == 3) {mode_dsp = "TA ONLY";setprop(tcas_mode,2)}
			if (mode == 4) {mode_dsp = "TA/RA";setprop(tcas_mode,3)}
			setprop("instrumentation/transponder/unit["~x~"]/display-mode",mode_dsp);
		},0,1);

		setlistener("instrumentation/transponder/unit["~x~"]/id-code", func(n) {	
			me.text.trspCode.setText(sprintf("%04d",n.getValue()));
			setprop("instrumentation/transponder/id-code",n.getValue());
			setprop("instrumentation/transponder/transmitted-id",n.getValue());
		},0,0);

		setlistener("instrumentation/transponder/unit["~x~"]/display-mode", func {	
			me.trsp_mode(x);			
		},0,0);

		setlistener("instrumentation/transponder/ident", func() {	
      if (getprop("instrumentation/rmu/unit["~x~"]/btn-id")) {
        setprop("instrumentation/transponder/unit["~x~"]/ident",1);
      } else {setprop("instrumentation/transponder/unit["~x~"]/ident",0)}
      
		},0,0);

    setlistener("instrumentation/transponder/unit["~x~"]/ident",func(n) {
        var t = 0;
        var id_timer = maketimer (0.3, func() {
          if (t==0) {me.text.ident.setVisible(1)}
          if (t==1) {me.text.ident.setVisible(0)}
          t+=1;
          if (t==2) {t=0}
          if (!n.getValue()) {id_timer.stop();me.text.ident.setVisible(0)}
        });
      if (n.getValue()) {id_timer.start()}
			else {me.text.ident.setVisible(0)}
		},0,0);

    setlistener("instrumentation/transponder/unit["~x~"]/id-code[1]",func {
      me.idCode(x);
    },0,0);

    setlistener("instrumentation/transponder/unit["~x~"]/id-code[2]",func {
      me.idCode(x);
    },0,0);

		setlistener("instrumentation/rmu/trsp-num", func {	
			me.trsp_mode(x);
		},0,0);

		setlistener("instrumentation/rmu/unit["~x~"]/test", func(n) {	
			var p = 1;
			var timerTst = maketimer(2,func() {
				tstDsp(p,timerTst);
				p+=1;
				if (p==9) {timerTst.stop()}
			});

			if (n.getValue()){
				me.group.setVisible(0);
				me.mem.setVisible(0);
				me.test.setVisible(1);
				foreach(var i;me.tst_val) {
					me.tst[i].hide();
				}
				me.tst[me.tst_val[0]].show();
				var tstDsp = func(p,timerTst) {
					me.tst[me.tst_val[p]].show();
				};
				timerTst.start();

			} else {
				me.test.setVisible(0);
				me.group.setVisible(1);
				me.mem.setVisible(0);		
				if (timerTst.isRunning) {timerTst.stop()}
			}
		},0,0);

    ### Dme ###
		setlistener("instrumentation/rmu/unit["~x~"]/dme", func(n) {	
      if (n.getValue()) dme[x] +=1;
      if (dme[x] == 3) dme[x] = 0;
      setprop(dme_sel[x],dme[x]);
    },0,0);

		setlistener(dme_sel[x], func(n) {	
      if (n.getValue() == 0) {
        me.text.dmeFreq.hide();
        me.text.dmeId.hide();
        me.text.dmeHold.hide();
        me.text.tacChan.hide();
        me.text.navStby.show();
        me.text.memNav.show();
        setprop(rmu_sel[x],getprop(rmu_sel[x])); # To position the cdr
        setprop(dme_freq[x],getprop(nav_freq[x]));
        me.dmeDisplay(x,0);
      }
      if (n.getValue() == 1) {        
        me.text.dmeFreq.show();
        me.text.dmeId.show();
        me.text.tacChan.hide();
        me.text.navStby.hide();
        me.text.memNav.hide();
        setprop(rmu_sel[x],getprop(rmu_sel[x])); # to position the cdr
        setprop(dme_freq[x],getprop(nav_freq[x]));
        me.dmeDisplay(x,0);
      }
        ### Tacan
      if (n.getValue() == 2) {        
        me.text.dmeFreq.hide();
        me.text.dmeId.show();
        me.text.tacChan.show();
        me.text.memNav.hide();
        tacan[0] = "";
        for (var i=0;i<2;i+=1) {
          for (var j=1;j<5;j+=1) {
            tacan[0] = tacan[0]~getprop("instrumentation/tacan["~i~"]/frequencies/selected-channel["~j~"]");
          }
          setprop("instrumentation/tacan["~i~"]/frequencies/selected-channel",tacan[0]);
          tacan[0] = "";
        }
        me.tacFreq(x);
        me.dmeDisplay(x,1);
        setprop(dme_freq[x],getprop(tac_freq[x]));
      }
		},0,0);

		setlistener(dme_freq[x], func(n) {	
      if (dme_sel[x] == 2) me.dmeDisplay(x,1); # tacan
      else me.dmeDisplay(x,0); # dme
    },0,0);

    setlistener("instrumentation/tacan["~x~"]/frequencies/selected-channel", func(n){
      me.text.tacChan.setText(n.getValue());
      me.tacFreq(x);
      setprop(dme_freq[x],getprop(tac_freq[x]));
    },0,0);

		setlistener(nav_src, func(n) {	
      if (dme_sel[x] == 2) me.dmeColor(x,1); # tacan
      else me.dmeColor(x,0); # dme
    },0,0);

	}, # end of listen	

  display : func(x) {
    ### Display ###
		me.text.comFreq.setText(sprintf("%.3f",getprop("instrumentation/comm["~x~"]/frequencies/selected-mhz")));
		me.text.comNum.setText(sprintf("%i",x+1));
		me.text.navFreq.setText(sprintf("%.3f",getprop("instrumentation/nav["~x~"]/frequencies/selected-mhz")));
		me.text.navNum.setText(sprintf("%i",x+1));
		me.text.adfNum.setText(sprintf("%i",x+1));
		me.text.adfFreq.setText(sprintf("%d",getprop("instrumentation/adf["~x~"]/frequencies/selected-khz")));
		me.text.mlsNum.setText(sprintf("%i",x+1));
		me.text.comStby.setText(sprintf("%07.3f",comVec[x].comMem1));
		setprop("instrumentation/comm["~x~"]/frequencies/standby-mhz",comVec[x].comMem1);
		me.text.memCom.setText("MEMORY-1");
		me.text.navStby.setText(sprintf("%07.3f",navVec[x].navMem1));
		setprop("instrumentation/nav["~x~"]/frequencies/standby-mhz",navVec[x].navMem1);
		me.text.memNav.setText("MEMORY-1");
		me.text.trspCode.setText(sprintf("%04d",getprop("instrumentation/transponder/unit["~x~"]/id-code")));
		me.text.trspMode.setText(getprop("instrumentation/transponder/unit["~x~"]/display-mode"));
		me.text.full.hide();
    me.text.ident.hide();

	  ### Memories treatment	###
		me.freq = {};
		me.freq_val = ["freq1","freq2","freq3","freq4","freq5","freq6"];
		me.vfreq = std.Vector.new();
		foreach(var i;me.freq_val) {
			me.freq[i] = me.mem.getElementById(i);
			me.vfreq.append(me.mem.getElementById(i));
		}
		
		### Line number ###
		me.num_val = ["num1","num2","num3","num4","num5","num6"];
		me.vnum = std.Vector.new();
		foreach(var i;me.num_val) {
			me.vnum.append(me.mem.getElementById(i));
		}

		### Memories Texts ###
		me.tit = me.mem.getElementById("tittle");
		me.ins = me.mem.getElementById("ins");
		me.full = me.mem.getElementById("full");
		me.full.hide();

		### RMU Tests ###
		me.tst = {};
		me.tst_val = ["comTest","comOk","navTest","navOk","adfTest", 								"adfOk","atcTest","atcOk","success"];
		foreach(var i;me.tst_val) {
			me.tst[i] = me.test.getElementById(i);
		}
  }, # end of display

	update : func(x) { ### Memories runtime update ###
		me.timer = maketimer(0.1,func() {
			if (getprop(rmu_sel[x])!=1) {me.tit.setText("Com 1")}
			if (getprop(rmu_sel[x])==1) {me.tit.setText("Nav 1")}
			if (memVec[x].vector[6]==0) {
				setprop("instrumentation/rmu/unit["~x~"]/more",0);
			}
			me.mem_redraw(x);
			if (memVec[x].vector[0]!=0){me.mem_select(x)}
		});
		me.timer.start();
	}, # end of update

	mem_redraw : func(x) {
		for (var i=0;i<6;i+=1) { ### raz ###
			me.vfreq.vector[i].setText("");
			me.vnum.vector[i].setText("");
		}
    more = getprop("instrumentation/rmu/unit["~x~"]/more");
		for (var i=0;i<6;i+=1) {
			if (memVec[x].vector[i+more]== 0) {
				break;
			}
			else {
				me.vfreq.vector[i].setText(sprintf("%.3f",memVec[x].vector[i+more]));
				me.vnum.vector[i].setText(sprintf("%d",i+1+more));
			}
		}
	}, # end of mem_redraw

	mem_select : func(x) {
		for (var i=0;i<12;i+=1) {
			if (memVec[x].vector[i]== 0) {me.max_sel=i-1;break}
			else {me.max_sel = 11}
		}		
		me.select = getprop("instrumentation/rmu/unit["~x~"]/mem-dsp");
		var n=nil;
		if (getprop("instrumentation/rmu/unit["~x~"]/more") == 0) {n = 0}
		else {n = 6}
		for (var i=0;i<6;i+=1) {
			if (me.select > me.max_sel-n) {
				setprop("instrumentation/rmu/unit["~x~"]/mem-dsp",me.max_sel-n);
			}
			if (me.select == -1) {me.fra.hide()}
			if (me.select == 0) {me.fra.setTranslation(0,0);me.fra.show()}
			if (me.select == 1) {me.fra.setTranslation(0,120);me.fra.show()}
			if (me.select == 2) {me.fra.setTranslation(0,280);me.fra.show()}
			if (me.select == 3) {me.fra.setTranslation(0,400);me.fra.show()}
			if (me.select == 4) {me.fra.setTranslation(0,560);me.fra.show()}
			if (me.select == 5) {me.fra.setTranslation(0,680);me.fra.show()}
		}	
	}, # end of mem_select

	trsp_mode : func(x) { ### Transponder ###
    var unit_code = getprop("instrumentation/transponder/unit["~x~"]/id-code");
    setprop("instrumentation/transponder/id-code",unit_code);
		me.text.trspNum.setText(sprintf("%d",getprop("instrumentation/rmu/trsp-num")));
    if (x == 0) {
		  if (getprop("instrumentation/rmu/trsp-num") == 2) {				
			  me.text.trspMode.setText("STANDBY");
		  } else {
			  me.text.trspMode.setText(getprop("instrumentation/transponder/unit["~x~"]/display-mode"));
		  }			
    }
    if (x == 1) {
		  if (getprop("instrumentation/rmu/trsp-num") == 1) {				
			  me.text.trspMode.setText("STANDBY");
		  } else {
			  me.text.trspMode.setText(getprop("instrumentation/transponder/unit["~x~"]/display-mode"));
		  }			
    }
	}, # end of trsp_mode

	memFull : func {
		full.show();
		var fullTimer = maketimer(2,func() {
			full.hide();
			fullTimer.stop();
		});
		fullTimer.start();
	}, # end of memFull

  refreshMem : func(x) {	### Refresh memories ###
	  var n = 0;
	  if (getprop(rmu_sel[x]) != 1) {
      memo = comVec[x];
      mem_1 = com_mem;
      var ref = "comm";
    }
	  if (getprop(rmu_sel[x]) == 1) {
      memo = navVec[x];
      mem_1 = nav_mem;
      var ref = "nav";
    }
	  foreach(var i;mem_1) {
		  memVec[x].vector[n] = memo[i];
		  n+=1;
  	}
        ### to refresh memory number ###
    var freq_sel = getprop("instrumentation/"~ref~"["~x~"]/frequencies/standby-mhz");
    setprop("instrumentation/"~ref~"["~x~"]/frequencies/standby-mhz",freq_sel);

  }, # end of RefreshMem

  freqLimits : func(x) {
	  var com_freq = "instrumentation/comm["~x~"]/frequencies/standby-mhz";
	  var nav_stby = "instrumentation/nav["~x~"]/frequencies/standby-mhz";
	  if (getprop(com_freq)<117.975) {setprop(com_freq,117.975)}
	  if (getprop(com_freq)>137.000) {setprop(com_freq,137.000)}
	  if (getprop(nav_stby)<108.000) {setprop(nav_stby,108.000)}
	  if (getprop(nav_stby)>117.950) {setprop(nav_stby,117.950)}
  },# end of freqLimits

  idCode : func(x) {
		var diz = getprop("instrumentation/transponder/unit["~x~"]/id-code[1]");
		var cent = getprop("instrumentation/transponder/unit["~x~"]/id-code[2]");
		var dwn_1 = getprop("instrumentation/transponder/unit["~x~"]/down-1");
		var dwn_2 = getprop("instrumentation/transponder/unit["~x~"]/down-2");
		var dg_1 = diz-int(diz/10)*10;
		var dg_2 = int(diz/10);
		var dg_3 = cent-int(cent/10)*10;
		var dg_4 = int(cent/10);	
		var dg = [dg_1,dg_2,dg_3,dg_4];
		for (var i=0;i<4;i+=1) {
			if (i<2 and !dwn_1 and dg[i] >7) {dg[i]=0;dg[i+1]+=1}
			if (i<2 and dwn_1 and dg[i] >7) {dg[i]=7}
			if (i>1 and !dwn_2 and dg[i] >7) {dg[i]=0;dg[i+1]+=1}
			if (i>1 and dwn_2 and dg[i] >7) {dg[i]=7}
		}	
		diz = dg[0]+dg[1]*10;
		cent = dg[2]+dg[3]*10;
		setprop("instrumentation/transponder/unit["~x~"]/id-code[1]",diz);
		setprop("instrumentation/transponder/unit["~x~"]/id-code[2]",cent);
		setprop("instrumentation/transponder/unit["~x~"]/id-code",diz + (cent*100));
	}, # end of idCode

  dmeDisplay : func(x,dt) {
    freq = dt ? getprop(tac_freq[x]) : getprop(dme_freq[x]);
    if (left(getprop("/sim/version/flightgear"),4) < 2018) {
      navaid = findNavaidByFrequency(freq/10);
    } else navaid = findNavaidByFrequencyMHz(freq);
    if (navaid != nil) {
      nav_dme = navinfo('dme',navaid.id);
      if (size(nav_dme) > 0) {
        for (var i=0;i<size(nav_dme);i+=1) {
          if (nav_dme[i].frequency == navaid.frequency) { 
            if (dt) setprop(tac_id[x],navaid.id);
            else setprop(dme_id[x],navaid.id);
            break;
          } 
        }
      } else if (dt) setprop(tac_id[x],"");
        else setprop(dme_id[x],"");
    } else if (dt) setprop(tac_id[x],"");
      else setprop(dme_id[x],"");
    if (dt) me.text.dmeId.setText(getprop(tac_id[x]));
    else {
      me.text.dmeFreq.setText(sprintf("%.3f",getprop(dme_freq[x])));
      me.text.dmeId.setText(getprop(dme_id[x]));
    }
    if (sprintf("%.2f",freq) == sprintf("%.2f",getprop(nav_freq[x]))) {
      me.text.dmeHold.hide();
    } else if (getprop(dme_sel[x]) != 0) me.text.dmeHold.show();
    me.dmeColor(x,dt);
  }, # end of dmeDisplay

  dmeColor : func (x,dt) {
    var frq0 = dt ? getprop(tac_freq[0]) : getprop(dme_freq[0]);
    var frq1 = dt ? getprop(tac_freq[1]) : getprop(dme_freq[1]);
    frq0 = sprintf("%.3f",frq0);
    frq1 = sprintf("%.3f",frq1);
    me.text.dmeFreq.setColor(1,1,1);
    me.text.tacChan.setColor(1,1,1);
    if ((x and getprop(nav_src) == "NAV1") or (!x and getprop(nav_src) == "NAV2")) {
      if (frq0 == frq1) {
        me.text.dmeFreq.setColor(1,0.5,0.16);
        me.text.tacChan.setColor(1,0.5,0.16);
      }
    }
  }, # end of dmeColor

  tacChannel : func(x,c,u) {
    tacan[1] = getprop("instrumentation/tacan["~x~"]/frequencies/selected-channel[1]");
    tacan[2] = getprop("instrumentation/tacan["~x~"]/frequencies/selected-channel[2]");
    tacan[0] = tacan[1]~tacan[2];
    tacan[0] = tacan[0] + c;
    if (tacan[0] > 12) tacan[0] = 0;
    if (tacan[0] < 0) tacan[0] = 12;
    tacan[0] = sprintf("%02.0f",tacan[0]);
    setprop("instrumentation/tacan["~x~"]/frequencies/selected-channel[1]",left(tacan[0],1));
    setprop("instrumentation/tacan["~x~"]/frequencies/selected-channel[2]",right(tacan[0],1));
    tacan[3] = getprop("instrumentation/tacan["~x~"]/frequencies/selected-channel[3]");
    tacan[4] = getprop("instrumentation/tacan["~x~"]/frequencies/selected-channel[4]");
    if (u == 1 and tacan[4] == "X") tacan[4] = "Y";
    else if (u == 1 and tacan[4] == "Y") {tacan[3] = tacan[3] + 1;tacan[4] = "X"}
    if (u == -1 and tacan[4] == "X") {tacan[3] = tacan[3] - 1;tacan[4] = "Y"}
    else if (u == -1 and tacan[4] == "Y") tacan[4] = "X";
    if (tacan[3] > 9) {tacan[3] = 0;tacan[4] = "X"}
    if (tacan[3] < 0) {tacan[3] = 9;tacan[4] = "Y"}
    if (tacan[0] == 0 and tacan[3] == 0) tacan[3] = 1;
    setprop("instrumentation/tacan["~x~"]/frequencies/selected-channel[3]",sprintf("%.0f",tacan[3]));
    setprop("instrumentation/tacan["~x~"]/frequencies/selected-channel[4]",tacan[4]);
    setprop("instrumentation/tacan["~x~"]/frequencies/selected-channel",tacan[0]~tacan[3]~tacan[4]);
  }, # end of tacChan

  tacFreq : func(x) {
      ### Convert channels in frequencies ###
    tacan[0] = left(getprop("instrumentation/tacan["~x~"]/frequencies/selected-channel"),3);
    tacan[4] = right(getprop("instrumentation/tacan["~x~"]/frequencies/selected-channel"),1);
    if (tacan[4] == "X") {
      tacan[0] = left(getprop("instrumentation/tacan["~x~"]/frequencies/selected-channel"),3);
      if (tacan[0] < 17) tacan[0] = tacan[0]/10 + 134.3;
      else if (tacan[0] < 60) tacan[0] =tacan[0]/10 + 106.3;
      else if (tacan[0] < 70) tacan[0] = tacan[0]/10 + 127.3;
      else if (tacan[0] < 126) tacan[0] = tacan[0]/10 + 105.3;
    }
    if (tacan[4] == "Y") {
      if (tacan[0] < 17) tacan[0] = tacan[0]/10 + 134.35;
      else if (tacan[0] < 60) tacan[0] = tacan[0]/10 + 106.35;
      else if (tacan[0] < 70) tacan[0] = tacan[0]/10 + 127.35;
      else if (tacan[0] < 126) tacan[0] = tacan[0]/10 + 105.35;
    }
    setprop(tac_freq[x],sprintf("%.3f",tacan[0]));
  }, # end of tacFreq


}; # end of RMU


###### Main #####
var rmu_setl = setlistener("/sim/signals/fdm-initialized", func () {	
  for (var x=0;x<2;x+=1) {
    var rmu = RMU.new(x);
    rmu.init(x);
    rmu.listen(x);
    rmu.display(x);
  }
removelistener(rmu_setl);
},0,0);


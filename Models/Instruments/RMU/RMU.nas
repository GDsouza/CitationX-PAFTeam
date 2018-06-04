### Canvas RMU ###
### C. Le Moigne (clm76) - 2016-2017 ###

props.globals.initNode("instrumentation/rmu/trsp-num",1,"INT");
props.globals.initNode("instrumentation/rmu/unit/delete",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/insert",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/mem-dsp",-1,"INT");
props.globals.initNode("instrumentation/rmu/unit/mem-freq");
props.globals.getNode("instrumentation/rmu/unit/mem-nav",0,"INT");
props.globals.initNode("instrumentation/rmu/unit/pge",0,"INT");
props.globals.initNode("instrumentation/rmu/unit/selected",0,"INT");
props.globals.initNode("instrumentation/rmu/unit/sto",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/swp1",0,"BOOL");
props.globals.getNode("instrumentation/rmu/unit/swp2",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit/test",0,"BOOL");
props.globals.initNode("instrumentation/transponder/unit/ident",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/delete",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/insert",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/mem-dsp",-1,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/mem-freq");
props.globals.getNode("instrumentation/rmu/unit[1]/mem-nav",0,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/pge",0,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/selected",0,"INT");
props.globals.initNode("instrumentation/rmu/unit[1]/sto",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/swp1",0,"BOOL");
props.globals.getNode("instrumentation/rmu/unit[1]/swp2",0,"BOOL");
props.globals.initNode("instrumentation/rmu/unit[1]/test",0,"BOOL");
props.globals.initNode("instrumentation/transponder/unit[1]/ident",0,"BOOL");

var path = getprop("/sim/fg-home")~"/aircraft-data/";
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
										"full","ident"];
		foreach(var i;m.text_val) {
			m.text[i] = m.group.getElementById(i);
		}

    if (getprop("/sim/version/flightgear") != "2017.4.0") { # bug with 2017.4.0
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
    }

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
    
  }, # end of init

	listen : func(x) {
		setlistener("instrumentation/rmu/unit["~x~"]/pge",func (n) {
			setprop("instrumentation/rmu/unit["~x~"]/mem-dsp",-1);
			if (n.getValue()) {
				me.group.setVisible(0);
				me.mem.setVisible(1);
				if (getprop("instrumentation/rmu/unit["~x~"]/selected")==0){
          var n = 0;
					foreach(var i;com_mem) {
						memVec[x].vector[n] = comVec[x][i];	
            n+=1;
  				}
        }
				if (getprop("instrumentation/rmu/unit["~x~"]/selected")==1){
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

		setlistener("instrumentation/rmu/unit["~x~"]/selected",func(n) {
			if (n.getValue() == 0) {me.cdr.setTranslation(0,0)}
			if (n.getValue() == 1) {me.cdr.setTranslation(325,0)}
			if (n.getValue() == 2) {me.cdr.setTranslation(0,230)}
			if (n.getValue() == 3) {me.cdr.setTranslation(325,230)}
			if (n.getValue() == 4) {me.cdr.setTranslation(0,335)}
			if (n.getValue() == 5) {me.cdr.setTranslation(325,335)}
		},0,0);	

		setlistener("instrumentation/comm["~x~"]/frequencies/selected-mhz", func(n) {
			me.text.comFreq.setText(sprintf("%.3f",n.getValue()));
		},0,1);

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
		},0,1);

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
		},0,1);

		setlistener("instrumentation/nav["~x~"]/frequencies/selected-mhz", func(n) {
			me.text.navFreq.setText(sprintf("%.3f",n.getValue()));
		},0,1);

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
		},0,1);

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
		},0,1);

		setlistener("instrumentation/rmu/unit["~x~"]/sto", func(n) {	
			if (n.getValue()) {
				if (getprop("instrumentation/rmu/unit["~x~"]/selected") == 0) {
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

				if (getprop("instrumentation/rmu/unit["~x~"]/selected") == 1) {
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
						memVec[x].insert(mem_dsp+1+more,getprop("instrumentation/rmu/unit["~x~"]/selected") == 0 ? 117.975 : 108.000);
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
					if (getprop("instrumentation/rmu/unit["~x~"]/selected") == 0) {
						for (var i=0;i<12;i+=1) {
							comVec[x][com_mem[i]] = memVec[x].vector[i];
							var name = data[x].getChild(com_mem[i]);
							name.setDoubleValue(comVec[x][com_mem[i]]);
							io.write_properties(memPath[x],data[x]);
						}										
					}
				if (getprop("instrumentation/rmu/unit["~x~"]/selected") == 1) {
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
			
		},0,1);

		setlistener("instrumentation/rmu/unit["~x~"]/delete", func(n) {	
			if (n.getValue()) {
				if (!getprop("instrumentation/rmu/unit["~x~"]/insert")) {
					me.sel = getprop("instrumentation/rmu/unit["~x~"]/mem-dsp");
					more = getprop("instrumentation/rmu/unit["~x~"]/more");
					if (more == 6) {me.sel = me.sel+more}
					if (getprop("instrumentation/rmu/unit["~x~"]/selected") == 0) {					
						memVec[x].remove(comVec[x][com_mem[me.sel]]);
						memVec[x].insert(11,0);
						for (var i=0;i<12;i+=1) {
							comVec[x][com_mem[i]]=memVec[x].vector[i];
							var name = data[x].getChild(com_mem[i]);
							name.setDoubleValue(comVec[x][com_mem[i]]);
							io.write_properties(memPath[x],data[x]);
						}										
					}
					if (getprop("instrumentation/rmu/unit["~x~"]/selected") == 1) {					
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
		},0,1);

		setlistener("instrumentation/adf["~x~"]/frequencies/selected-khz", func(n) {	
			me.text.adfFreq.setText(sprintf("%d",n.getValue()));
		},0,1);

		setlistener("instrumentation/adf["~x~"]/mode", func(n) {	
			me.text.adfMode.setText(n.getValue());
		},0,1);

		setlistener("instrumentation/transponder/unit["~x~"]/knob-mode", func(n) {
			var mode = n.getValue();
			var mode_dsp = "";
			if (mode == 0) {mode_dsp = "STANDBY"}
			if (mode == 1) {mode_dsp = "ATC ON"}
			if (mode == 2) {mode_dsp = "ATC ALT"}
			if (mode == 3) {mode_dsp = "TA ONLY"}
			if (mode == 4) {mode_dsp = "TA/RA"}
			setprop("instrumentation/transponder/unit["~x~"]/display-mode",mode_dsp);
		},0,1);

		setlistener("instrumentation/transponder/unit["~x~"]/id-code", func(n) {	
			me.text.trspCode.setText(sprintf("%04d",n.getValue()));
			setprop("instrumentation/transponder/id-code",n.getValue());
			setprop("instrumentation/transponder/transmitted-id",n.getValue());
		},0,1);

		setlistener("instrumentation/transponder/unit["~x~"]/display-mode", func {	
			me.trsp_mode(x);			
		},0,1);

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
		},0,1);

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
			if (getprop("instrumentation/rmu/unit["~x~"]/selected")!=1) {me.tit.setText("Com 1")}
			if (getprop("instrumentation/rmu/unit["~x~"]/selected")==1) {me.tit.setText("Nav 1")}
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
	  if (getprop("instrumentation/rmu/unit["~x~"]/selected") != 1) {
      memo = comVec[x];
      mem_1 = com_mem;
      var ref = "comm";
    }
	  if (getprop("instrumentation/rmu/unit["~x~"]/selected") == 1) {
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
	  var nav_freq = "instrumentation/nav["~x~"]/frequencies/standby-mhz";
	  if (getprop(com_freq)<117.975) {setprop(com_freq,117.975)}
	  if (getprop(com_freq)>137.000) {setprop(com_freq,137.000)}
	  if (getprop(nav_freq)<108.000) {setprop(nav_freq,108.000)}
	  if (getprop(nav_freq)>117.950) {setprop(nav_freq,117.950)}
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
	},


}; # end of RMU

###### Main #####
var rmu_setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var rmu_L = RMU.new(0);
  var rmu_R = RMU.new(1);
  rmu_L.init(0);
  rmu_R.init(1);
	rmu_L.listen(0);
	rmu_R.listen(1);
  rmu_L.display(0);
  rmu_R.display(1);
removelistener(rmu_setl);
},0,0);


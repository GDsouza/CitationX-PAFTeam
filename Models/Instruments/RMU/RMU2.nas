### Canvas RMU2 ###
### C. Le Moigne (clm76) - 2016-2017 ###

var com_freq2 = props.globals.getNode("instrumentation/comm[1]/frequencies/selected-mhz");
var com_stby2 = props.globals.getNode("instrumentation/comm[1]/frequencies/standby-mhz");
var com_mem2 = props.globals.getNode("instrumentation/rmu/unit[1]/mem-com");
var nav_freq2 = props.globals.getNode("instrumentation/nav[1]/frequencies/selected-mhz");
var nav_stby2 = props.globals.getNode("instrumentation/nav[1]/frequencies/standby-mhz");
var nav_mem2 = props.globals.getNode("instrumentation/rmu/unit[1]/mem-nav");
var trsp_code2 = props.globals.getNode("instrumentation/transponder/unit[1]/id-code");
var trsp_mode2 = props.globals.getNode("instrumentation/transponder/unit[1]/display-mode");
var trsp_num = props.globals.getNode("instrumentation/rmu/trsp-num");
var adf_freq2 = props.globals.getNode("instrumentation/adf[1]/frequencies/selected-khz");
var adf_mode = props.globals.getNode("instrumentation/adf[1]/mode");
var selected = props.globals.getNode("instrumentation/rmu/unit[1]/selected");
var mem_dsp = props.globals.getNode("instrumentation/rmu/unit[1]/mem-dsp");
var mem_freq = props.globals.getNode("instrumentation/rmu/unit[1]/mem-freq");
var insert = props.globals.getNode("instrumentation/rmu/unit[1]/insert");
var test = props.globals.getNode("instrumentation/rmu/unit[1]/test");
var path = getprop("/sim/fg-home")~"/aircraft-data/";
var data = nil;
var mem2 = nil;
var mem_2 = nil;
var memV2 = nil;
var full = nil;

	### Create Memories if not exist ###
var memPath = path~"CitationX-RMUmem2.xml";
var xfile = subvec(directory(path),2);
var v = std.Vector.new(xfile);
if (!v.contains("CitationX-RMUmem2.xml")) {
	var data = props.Node.new({
		comMem1 : 0,comMem2 : 0,comMem3 : 0,comMem4 : 0,comMem5 : 0,
		comMem6 : 0,comMem7 : 0,comMem8 : 0,comMem9 : 0,comMem10 : 0,
		comMem11 : 0,comMem12 : 0,
		navMem1 : 0,navMem2 : 0,navMem3 : 0,navMem4 : 0,navMem5 : 0,
		navMem6 : 0,navMem7 : 0,navMem8 : 0,navMem9 : 0,navMem10 : 0,
		navMem11 : 0,navMem12 : 0
	});		
	io.write_properties(memPath,data);
} 

var memVec2 = std.Vector.new();
for (var i=0;i<12;i+=1) {
	memVec2.append(0);
}

	### Load comm memories ###
var com2 = {};
var com_mem2 = ["comMem1","comMem2","comMem3","comMem4",
							"comMem5","comMem6","comMem7","comMem8",
							"comMem9","comMem10","comMem11","comMem12"];
data = io.read_properties(memPath);
foreach(var i;com_mem2) {
	com2[i] = data.getValue(i);
}


	### Load nav memories ###
var nav2 = {};
var navVec2 = std.Vector.new();
var nav_mem2 = ["navMem1","navMem2","navMem3","navMem4",
							"navMem5","navMem6","navMem7","navMem8",
							"navMem9","navMem10","navMem11","navMem12"];
data = io.read_properties(memPath);
foreach(var i;nav_mem2) {
	nav2[i] = data.getValue(i);
}

var font_mapper = func(family,weight) {
	if(family == "'Liberation Mono'" and (weight == "normal" or weight == "bold")) {
		return "osifont.ttf";
	}
};

	### RMU ###
var RMU2 = {
	new: func() {
		var m = {parents:[RMU2]};
		m.canvas = canvas.new({
			"name": "RMU2", 
			"size": [1024, 1024],
			"view": [800, 1024],
			"mipmapping": 1 
		});

		m.canvas.addPlacement({"node": "RMU.screenR"});

	### RMU frame init ###
		m.rmu2 = m.canvas.createGroup();
		canvas.parsesvg(m.rmu2, "Aircraft/CitationX/Models/Instruments/RMU/RMU.svg");
		m.cdr =	m.rmu2.createChild("path")
					.moveTo(98,237)
					.horiz(286)
					.vert(88)
					.horiz(-286)
					.close()
					.setColor(0.95,0.75,0)
					.setStrokeLineWidth(10);			

		m.rmu2.setVisible(1);

	### Memories frame & text init ###
		m.mem2 = m.canvas.createGroup();
		canvas.parsesvg(m.mem2, "Aircraft/CitationX/Models/Instruments/RMU/mem.svg",{'font-mapper':font_mapper});
		m.fra =	m.mem2.createChild("path")
					.moveTo(95,130)
					.horiz(420)
					.vert(90)
					.horiz(-420)
					.close()
					.setColor(0.95,0.75,0)
					.setStrokeLineWidth(10)			
					.setVisible(0);

		m.mem2.setVisible(0);

	### Test init ###
		m.test2 = m.canvas.createGroup();
		canvas.parsesvg(m.test2, "Aircraft/CitationX/Models/Instruments/RMU/test.svg");
		m.test2.setVisible(0);

	### RMU initial display	###
		m.text = {};
		m.text_val = ["comFreq","navFreq","comStby", "navStby",
										"trspCode","trspMode","trspNum","adfFreq","adfMode",
										"memCom","memNav","comNum","navNum","adfNum","mlsNum",
										"full"];
		foreach(var i;m.text_val) {
			m.text[i] = m.rmu2.getElementById(i);
		}

		m.text.comFreq.setText(sprintf("%.3f",com_freq2.getValue()));
		m.text.comNum.setText("2");
		m.text.navFreq.setText(sprintf("%.3f",nav_freq2.getValue()));
		m.text.navNum.setText("2");
		m.text.adfNum.setText("2");
		m.text.adfFreq.setText(sprintf("%d",adf_freq2.getValue()));
		m.text.mlsNum.setText("2");
		m.text.trspNum.setText("2");
		m.text.comStby.setText(sprintf("%07.3f",com2.comMem2));
		com_stby2.setValue(com2.comMem2);
		m.text.memCom.setText("MEMORY-1");
		m.text.navStby.setText(sprintf("%07.3f",nav2.navMem2));
		nav_stby2.setValue(nav2.navMem2);
		m.text.memNav.setText("MEMORY-1");
		m.text.trspCode.setText(sprintf("%04d",trsp_code2.getValue()));
		m.text.trspMode.setText(trsp_mode2.getValue());
		m.text.full.hide();

	### Memories treatment	###
		m.freq = {};
		m.freq_val = ["freq1","freq2","freq3","freq4","freq5","freq6"];
		m.vfreq = std.Vector.new();
		foreach(var i;m.freq_val) {
			m.freq[i] = m.mem2.getElementById(i);
			m.vfreq.append(m.mem2.getElementById(i));
		}
		
		### Line number ###
		m.num_val = ["num1","num2","num3","num4","num5","num6"];
		m.vnum = std.Vector.new();
		foreach(var i;m.num_val) {
			m.vnum.append(m.mem2.getElementById(i));
		}

		### Memories Texts ###
		m.tit = m.mem2.getElementById("tittle");
		m.ins = m.mem2.getElementById("ins");
		m.cant = m.mem2.getElementById("cant");
		m.cant.hide();

		### RMU Tests ###
		m.tst = {};
		m.tst_val = ["comTest","comOk","navTest","navOk","adfTest", 								"adfOk","atcTest","atcOk","success"];
		foreach(var i;m.tst_val) {
			m.tst[i] = m.test2.getElementById(i);
		}

		return m;
	},

	### Memories runtime display ###
	update : func{
		me.timer = maketimer(0.1,func() {
			if (selected.getValue()!=1) {me.tit.setText("Com 2")}
			if (selected.getValue()==1) {me.tit.setText("Nav 2")}
			me.more = getprop("instrumentation/rmu/unit[1]/more");
			if (memVec2.vector[6]==0) {
				me.more = 0;
				setprop("instrumentation/rmu/unit[1]/more",0);
			}
			me.mem_redraw();
			if (memVec2.vector[0]!=0){me.mem_select()}
		});
		me.timer.start();
	},

	mem_redraw : func {
		for (var i=0;i<6;i+=1) { ### raz ###
			me.vfreq.vector[i].setText("");
			me.vnum.vector[i].setText("");
		}
		for (var i=0;i<6;i+=1) {
			if (memVec2.vector[i+me.more]== 0) {
				break;
			}
			else {
				me.vfreq.vector[i].setText(sprintf("%.3f",memVec2.vector[i+me.more]));
				me.vnum.vector[i].setText(sprintf("%d",i+1+me.more));
			}
		}
	},

	mem_select : func {
		for (var i=0;i<12;i+=1) {
			if (memVec2.vector[i]== 0) {me.max_sel=i-1;break}
			else {me.max_sel = 11}
		}		
		me.select = mem_dsp.getValue();
		var n=nil;
		if (me.more == 0) {n = 0}
		else {n = 6}
		for (var i=0;i<6;i+=1) {
			if (me.select > me.max_sel-n) {
				mem_dsp.setValue(me.max_sel-n);
			}
			if (me.select == -1) {me.fra.hide()}
			if (me.select == 0) {me.fra.setTranslation(0,0);me.fra.show()}
			if (me.select == 1) {me.fra.setTranslation(0,120);me.fra.show()}
			if (me.select == 2) {me.fra.setTranslation(0,280);me.fra.show()}
			if (me.select == 3) {me.fra.setTranslation(0,400);me.fra.show()}
			if (me.select == 4) {me.fra.setTranslation(0,560);me.fra.show()}
			if (me.select == 5) {me.fra.setTranslation(0,680);me.fra.show()}
		}	
	},

	### Listeners ###
	listen : func {
		setlistener("instrumentation/rmu/unit[1]/pge",func {
			mem_dsp.setValue(-1);
			if (getprop("instrumentation/rmu/unit[1]/pge")) {
				me.rmu2.setVisible(0);
				me.mem2.setVisible(1);
				if (selected.getValue()==0){
					foreach(var i;com_mem2) {
						memVec2.append(data.getValue(i));
					}
				}
				if (selected.getValue()==1){
					foreach(var i;nav_mem2) {
						memVec2.append(data.getValue(i));
					}
				}
				me.update();
				refreshMem();
				if (memVec2.vector[0] == 0) {me.fra.hide()}
			} else {
				me.timer.stop();
				setprop("instrumentation/rmu/unit[1]/more",0);
				insert.setValue(0);
				me.rmu2.setVisible(1);
				me.mem2.setVisible(0);
#				if (selected.getValue()!=1){
#					com_stby2.setValue(memVec2.vector[0]);
#				}
#				if (selected.getValue()==1){
#					nav_stby2.setValue(memVec2.vector[0]);
#				}
			}
		});

		setlistener("instrumentation/rmu/unit[1]/selected",func {
			if (selected.getValue() == 0) {me.cdr.setTranslation(0,0)}
			if (selected.getValue() == 1) {me.cdr.setTranslation(325,0)}
			if (selected.getValue() == 2) {me.cdr.setTranslation(0,230)}
			if (selected.getValue() == 3) {me.cdr.setTranslation(325,230)}
			if (selected.getValue() == 4) {me.cdr.setTranslation(0,335)}
			if (selected.getValue() == 5) {me.cdr.setTranslation(325,335)}
		});	

		setlistener("instrumentation/rmu/unit[1]/swp1", func {
			if (getprop("instrumentation/rmu/unit[1]/swp1")) {
				me.text.comFreq.setText(sprintf("%.3f",com_freq2.getValue()));
			}
		});

		setlistener("instrumentation/rmu/unit[1]/swp2", func {
			if (getprop("instrumentation/rmu/unit[1]/swp2")) {
				me.text.navFreq.setText(sprintf("%.3f",nav_freq2.getValue()));
			}
		});

		### Comm frequencies ###
		setlistener("instrumentation/comm[1]/frequencies/selected-mhz", func {
			me.text.comFreq.setText(sprintf("%.3f",com_freq2.getValue()));
		});

		setlistener("instrumentation/comm[1]/frequencies/standby-mhz", func {
			me.text.comStby.setText(sprintf("%.3f",com_stby2.getValue()));
			for (var i=0;i<12;i+=1) {
				if (sprintf("%.3f",com2[com_mem2[i]]) == sprintf("%.3f",com_stby2.getValue())) {
					me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));							
					break;
				}	else {
					me.text.memCom.setText("TEMP-"~sprintf("%d",i+1));
					if (com2[com_mem2[i]] == 0) {
						break;
					}					
				}
			}
		});

		setlistener("instrumentation/rmu/unit[1]/mem-com", func {
			var i = getprop("instrumentation/rmu/unit[1]/mem-com");
			if (com2[com_mem2[0]] == 0) {
					me.text.comStby.setText(sprintf("%.3f",com_stby2.getValue()));
			} else {
				if (com2[com_mem2[i]] != 0) {
					me.text.comStby.setText(sprintf("%07.3f",com2[com_mem2[i]]));
					com_stby2.setValue(com2[com_mem2[i]]);
					me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));
				}	else {
					setprop("instrumentation/rmu/unit[1]/mem-com",0);
					me.text.comStby.setText(sprintf("%07.3f",com2[com_mem2[0]]));
					me.text.memCom.setText("MEMORY-"~sprintf("%d",1));
				}
			}
		});

		### Nav frequencies ###
		setlistener("instrumentation/nav[1]/frequencies/selected-mhz", func {
			me.text.navFreq.setText(sprintf("%.3f",nav_freq2.getValue()));
		});

		setlistener("instrumentation/nav[1]/frequencies/standby-mhz", func {
			me.text.navStby.setText(sprintf("%.3f",nav_stby2.getValue()));
			for (var i=0;i<12;i+=1) {
				if (sprintf("%.3f",nav2[nav_mem2[i]]) == sprintf("%.3f",nav_stby2.getValue())) {
					me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));							
					break;
				}	else {
					me.text.memNav.setText("TEMP-"~sprintf("%d",i+1));
					if (nav2[nav_mem2[i]] == 0) {
						break;
					}					
				}
			}
		});

		setlistener("instrumentation/rmu/unit[1]/mem-nav", func {
			var i = getprop("instrumentation/rmu/unit[1]/mem-nav");
			if (nav2[nav_mem2[0]] == 0) {
					me.text.navStby.setText(sprintf("%.3f",nav_stby2.getValue()));
			} else {
				if (nav2[nav_mem2[i]] != 0) {
					me.text.navStby.setText(sprintf("%07.3f",nav2[nav_mem2[i]]));
					nav_stby2.setValue(nav2[nav_mem2[i]]);
					me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));
				}	else {
					setprop("instrumentation/rmu/unit[1]/mem-nav",0);
					me.text.navStby.setText(sprintf("%07.3f",nav2[nav_mem2[0]]));
					me.text.memNav.setText("MEMORY-"~sprintf("%d",1));
				}
			}
		});

	### Storage memories Com & Nav ###
		setlistener("instrumentation/rmu/unit[1]/sto", func {	
			if (getprop("instrumentation/rmu/unit[1]/sto")) {
				if (selected.getValue() == 0) {
					if (com2[com_mem2[0]] == 0) {
						com2[com_mem2[0]] = com_stby2.getValue();
						var name = data.getChild(com_mem2[0]);
						name.setDoubleValue(sprintf("%07.3f",com2[com_mem2[0]]));
						io.write_properties(memPath,data);
						me.text.memCom.setText("MEMORY-1");
					} else if (com2[com_mem2[0]] != com_stby2.getValue()) {
						if (com2[com_mem2[11]] != 0) {
							full = me.text.full;
							me.memFull();
						}
						else {
							for (var i=0;i<12;i+=1) {
								if (com2[com_mem2[i]] == 0) {
									com2[com_mem2[i]] = com_stby2.getValue();
									var name = data.getChild(com_mem2[i]);
									name.setDoubleValue(com2[com_mem2[i]]);
									io.write_properties(memPath,data);
									me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));
									memVec2.vector[i] = com2[com_mem2[i]];
									break;
								}
							}
						}
					}
				}

				if (selected.getValue() == 1) {
					if (nav2[nav_mem2[0]] == 0) {
						nav2[nav_mem2[0]] = nav_stby2.getValue();
						var name = data.getChild(nav_mem2[0]);
						name.setDoubleValue(sprintf("%07.3f",nav2[nav_mem2[0]]));
						io.write_properties(memPath,data);
						me.text.memNav.setText("MEMORY-2");
					} else if (nav2[nav_mem2[0]] != nav_stby2.getValue()) {
						if (nav2[nav_mem2[11]] != 0) {
							full = me.text.full;
							me.memFull()}
						else {
							for (var i=0;i<12;i+=1) {
								if (nav2[nav_mem2[i]] == 0) {
									nav2[nav_mem2[i]] = nav_stby2.getValue();
									var name = data.getChild(nav_mem2[i]);
									name.setDoubleValue(nav2[nav_mem2[i]]);
									io.write_properties(memPath,data);
									me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));
									memVec2.vector[i] = nav2[nav_mem2[i]];
									break;
								}
							}
						}
					}
				}
			}
		});

	### Insert memories ###
		setlistener("instrumentation/rmu/unit[1]/insert",func {
			if (insert.getValue() and mem_dsp.getValue() != -1) {
					me.ins.setColor(1,0.35,1);
					if (memVec2.vector[11] == 0) {
						memVec2.insert(mem_dsp.getValue()+me.more,selected.getValue() == 0 ? 117.975 : 108.000);
					} else {
						full = me.cant;
						me.memFull();
						insert.setValue(0);
						me.ins.setColor(1,1,1);
					}
			} else {
				me.ins.setColor(1,1,1);
					if (selected.getValue() == 0) {
						for (var i=0;i<12;i+=1) {
							com2[com_mem2[i]]=memVec2.vector[i];
							var name = data.getChild(com_mem2[i]);
							name.setDoubleValue(com2[com_mem2[i]]);
							io.write_properties(memPath,data);
						}										
					}
				if (selected.getValue() == 1) {
					for (var i=0;i<12;i+=1) {
						nav2[nav_mem2[i]]=memVec2.vector[i];
						var name = data.getChild(nav_mem2[i]);
						name.setDoubleValue(nav2[nav_mem2[i]]);
						io.write_properties(memPath,data);
					}										
				}
				refreshMem();
			}
		});

		setlistener("instrumentation/rmu/unit[1]/mem-freq", func {	
			if (insert.getValue()==1) {
				memVec2.vector[mem_dsp.getValue()+me.more] = mem_freq.getValue();
			}
			
		});

	### Delete memories ###
		setlistener("instrumentation/rmu/unit[1]/delete", func {	
			if (getprop("instrumentation/rmu/unit[1]/delete")) {
				if (insert.getValue()==0) {
					me.sel = mem_dsp.getValue();
					me.pge = getprop("instrumentation/rmu/unit[1]/more");
					if (me.pge == 6) {me.sel = me.sel+me.pge}
					if (selected.getValue() == 0) {					
						memVec2.remove(com2[com_mem2[me.sel]]);
						memVec2.insert(11,0);
						for (var i=0;i<12;i+=1) {
							com2[com_mem2[i]]=memVec2.vector[i];
							var name = data.getChild(com_mem2[i]);
							name.setDoubleValue(com2[com_mem2[i]]);
							io.write_properties(memPath,data);
						}										
					}
					if (selected.getValue() == 1) {					
						memVec2.remove(nav2[nav_mem2[me.sel]]);
						memVec2.insert(11,0);
						for (var i=0;i<12;i+=1) {
							nav2[nav_mem2[i]]=memVec2.vector[i];
							var name = data.getChild(nav_mem2[i]);
							name.setDoubleValue(nav2[nav_mem2[i]]);
							io.write_properties(memPath,data);
						}										
					}
					refreshMem();
					if (memVec2.vector[0] == 0) {me.fra.hide()}
				}
			}
		});

	### ADF ###
		setlistener("instrumentation/adf[1]/frequencies/selected-khz", func {	
			me.text.adfFreq.setText(sprintf("%d",adf_freq2.getValue()));
		});

		setlistener("instrumentation/adf[1]/mode", func {	
			me.text.adfMode.setText(adf_mode.getValue());
		});

	### ATC - Transponder ###
		setlistener("instrumentation/transponder/unit[1]/knob-mode", func {
			var mode = getprop("instrumentation/transponder/unit[1]/knob-mode");
			var mode_dsp = "";
			if (mode == 0) {mode_dsp = "STANDBY"}
			if (mode == 1) {mode_dsp = "ATC ON"}
			if (mode == 2) {mode_dsp = "ATC ALT"}
			if (mode == 3) {mode_dsp = "TA ONLY"}
			if (mode == 4) {mode_dsp = "TA/RA"}
			setprop("instrumentation/transponder/unit[1]/display-mode"/mode_dsp);
		});

		setlistener("instrumentation/transponder/unit[1]/id-code", func {	
			me.text.trspCode.setText(sprintf("%04d",trsp_code2.getValue()));
			if (trsp_num.getValue() == "2") {
				setprop("instrumentation/transponder/id-code",trsp_code2.getValue());
				setprop("instrumentation/transponder/transmitted-id",trsp_code2.getValue());
			}
		});

		setlistener("instrumentation/transponder/unit[1]/display-mode", func {	
			trspMode();			
		});

		setlistener("instrumentation/rmu/trsp-num", func {	
			trspMode();
		});

		var trspMode = func {
			me.text.trspNum.setText(trsp_num.getValue());
			if (trsp_num.getValue() == "1") {
				me.text.trspMode.setText("STANDBY");
			} else {
				me.text.trspMode.setText(trsp_mode2.getValue());
			}			
		};

	### Tests Display ###
		setlistener("instrumentation/rmu/unit[1]/test", func {	
			var n = 1;
			var timerTst = maketimer(2,func() {
				tstDsp(n,timerTst);
				n+=1;
				if (n==9) {timerTst.stop()}
			});

			if (test.getValue()){
				me.rmu2.setVisible(0);
				me.mem2.setVisible(0);
				me.test2.setVisible(1);
				foreach(var i;me.tst_val) {
					me.tst[i].hide();
				}
				me.tst[me.tst_val[0]].show();
				var tstDsp = func(n,timerTst) {
					me.tst[me.tst_val[n]].show();
				};
				timerTst.start();

			} else {
				me.test2.setVisible(0);
				me.rmu2.setVisible(1);
				me.mem2.setVisible(0);		
				if (timerTst.isRunning) {timerTst.stop()}
			}
		});

	}, # end of listen	

	### Memories bank full ###

	memFull : func {
		full.show();
		var fullTimer = maketimer(2,func() {
			full.hide();
			fullTimer.stop();
		});
		fullTimer.start();
	}, # end of memFull

}; # end of RMU2

	### Refresh memories ###
var refreshMem = func {
	var n = 0;
	if (selected.getValue() !=1) {mem2 = com2;mem_2 = com_mem2}
	if (selected.getValue() == 1) {mem2 = nav2;mem_2 = nav_mem2}
	foreach(var i;mem_2) {
		mem2[i] = data.getValue(i);
		memVec2.vector[n] = mem2[mem_2[n]];
		n+=1;
	}
}; # end of Refresh memories

###### Main #####
var rmu2_setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var init = RMU2.new();
	init.listen();
removelistener(rmu2_setl);
});


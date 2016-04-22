## Checklists System ##
## Christian Le Moigne (clm76) - Avril 2016 ##

var page = 0;
var tittle = "";
var lines_L = "";
var lines_R = "";
var chklst = 0;

####################### CHECKLISTS ######################

### PRESTART ###
var T0 = "PRESTART";
var L0 = ['External Preflight','Documents','Passengers','Parking Brake','Fuel Cutoff Switches','L / R Generator Switches','L / R Fuel Boost Switches','L / R Ignition Switches','Standby Power','L / R Center Wing Transfer','Engine Area','Cabin Doors','Seat Belts','Battery 1 / 2','Ground Recog Lights'];
var R0 = ['COMPLETE','ON BOARD','BOARD / BRIEF', 'SET','OFF','GEN','NORM','NORM','ON','OFF','CLEAR','CLOSE AND LATCH','FASTEN / ADJUST','ON','ON'];

### APU START ###
var T1 = "APU START";
var L1 = ['APU MasterSwitch','APU Test Button','APU Start Switch','APU Ready To Load','APU Generator Switch','APU DC Volts','APU Bleed Air','Bleed Valve Open'];
var R1 = ['ON','PUSH / VERIFY','ON','ILLUMINATED','ON','CHECK 22v min','ON', 'ILLUMINATED'];

### STARTUP ###
var T2 = "STARTUP";
var L2 = ['Avionics Switch','EICAS switch','Radio','Autopilot','Fuel','Warning Test','V-Speeds','Altimeter','Hydraulics','Seat Belt Lts'];
var R2 = ['ON','ON','CHECK','DISENGAGED','CHECK QTY LBS','COMPLETE','SET','SET','CHECK','PASS SAFETY'];

### CABIN PRESSURIZATION ###
var T3 = "CABIN PRESSURIZATION";
var L3 = ['Pressurization Switch','            or','Pressurization Control','Rate Control','ALT Select'];
var R3 = ['NORM','','ALT SELECT','SET 500 fpm','SET 1000 ab Cruise Alt'];

###  START ENGINES ###
var T4 = "LEFT ENGINE START";
var L4 = ['Throttle','Ignition','Left Engine','N2 stable at 56%','N1 Rotation','Oil Pressure','ITT Stable','Volts / Amp / Oil'];
var R4 = ['CUTOFF','ON','START','VERIFY','CONFIRM','CHECK','VERIFY','CHECK'];

var T5 = "RIGHT ENGINE START";
var L5 = ['Throttle','Ignition','Left Engine','N2 stable at 56%','N1 Rotation','Oil Pressure','ITT Stable','Volts / Amp / Oil'];
var R5 = ['CUTOFF','ON','START','VERIFY','CONFIRM','CHECK','VERIFY','CHECK'];

###  BEFORE TAXI ###
var T6 = "BEFORE TAXI";
var L6 = ['Flight Controls','FMC Data Entry','L / R Pitot Heat','Taxi Lights','Transponder','(AP) Initial Altitude','(AP) Initial HDG / CRS','Flight Plan Clearance','Taxi Instructions'];
var R6 = ['FREE & CORRECT','COMPLETE','ON','ON','CODE SET / STBY','SET','SET','COPIED','RECEIVED'];

### TAXIING ###
var T7 = "TAXIING";
var L7 = ['Parking Brake','Taxi Area','Throttles','Brakes','Flight Instruments','Taxi to Runway'];
var R7 = ['OFF','CLEAR','ADVANCE SLOWLY','CHECK','CHECK','Max 20 kts'];

### BEFORE TAKEOFF ###
var T8 = "BEFORE TAKEOFF";
var L8 = ['Flight Timer','Flaps Slats','Speed Brakes','Taxi Lights','Landing Lights','Navigation Lights','Annunciator Panel','Transponder'];
var R8 = ['RESET','AS REQUIRED','RETRACTED','OFF','ON','ON','CLEAR','SET ALT'];

### TAKEOFF ###
var T9 = "TAKEOFF";
var L9 = ['Brakes','Throttles','Brakes','V1','VR','V2','Landing Gear','','','Flaps / Slats','EICAS','Annunciator / Instruments','Throttles','EICAS:Both Engines'];
var R9 = ['HOLD','TAKEOFF THRUST','RELEASE','CLEAR','ROTATE','CLIMBOUT','RETRACT','','Above 170 KIAS         ','RETRACT','CHECK NORMAL','CHECK','SET CLIMB POWER','N1 max 98%'];

### APU SHUTDOWN ###
var T10 = "APU SHUTDOWN";
var L10 = ['APU Start Switch','APU Bleed Air','READY TO LOAD','APU Generator','APU Master'];
var R10 = ['STOP','OFF','EXTINGUISHED','OFF','OFF'];  

### CRUISE CLIMB ###
var T11 = "CRUISE CLIMB";
var L11 = ['Trim Initial Climb','Autopilot','Fuel Transfer','','','','Seat Belts Switch','','','','Landing Lights','Pressurization System','',''];
var R11 = ['250 KIAS/2200 fpm','CHECK','CHECK','','Max Speed below 8,000 is 250 KIAS','','OFF','','Climb Spd above 8,000 is 275 KIAS','','OFF','CHECK','','Above FL180 set altimeters to 29.92'];

### CRUISE ###
var T12 = "CRUISE";
var L12 = ['Engine Instruments','Fuel Quantity'];
var R12 = ['CHECK','CHECK'];

### DESCENT ###
var T13 = "DESCENT";
var L13 = ['LH / RH Windshield Anti-Ice','APU','Desc Airspeed to FL310','','','','','Seat Belt Switch','','',''];
var R13 = ['ON','AS DESIRED below FL310','0.65 mach','','Below FL180 set Altimeters to    ',' local settings            ','','ON','','Max Speed above 8,000 is 280 KIAS','Max Speed below 8,000 is 250 KIAS'];

### APPROACH ###
var T14 = "APPROACH";
var L14 = ['Altimeter','Seat Belt Lts','Landing Lights','Airspeed','Slats','Airspeed','','Flaps','Airspeed','Flaps','Airspeed','Landing Gear','','Flaps','Airspeed','Parking Brake'];
var R14 = ['SET TO LOCAL','PASS SAFETY','ON','200 KIAS','DEPLOY','180 KIAS','At approximately 7nm from Runway ','SET 5 deg','180 KIAS','SET 15 deg','160 KIAS','DOWN','Short Final              ','FULL 35 deg','140 KIAS','OFF'];

### BEFORE LANDING ###
var T15 = "BEFORE LANDING";
var L15 = ['Landing Gear','Autopilot','Landing Speed'];
var R15 = ['3 GREEN LIGHTS','DISENGAGE','120 KIAS'];

### LANDING ###
var T16 = "LANDING";
var L16 = ['Throttles','','','','Brakes','Reverse Thrust',''];
var R16 = ['IDLE','','After Nose Wheel Touchdown   ','','AS REQUIRED','AS REQUIRED','','At 65 kts Disengage Reverse Thrust '];

### AFTER LANDING ###
var T17 = "AFTER LANDING";
var L17 = ['Flaps','Landing / Taxi Lights','Transponder','Cabin Dump'];
var R17 = ['RETRACT','AS REQUIRED','STANDBY','OPEN'];

### SHUTDOWN ###
var T18 = "SHUTDOWN";
var L18 = ['Ice Equipment','Throttles','Parking Brake','Seat Belt Lts','Standby Power','Cockpit PAC','Cabin PAC','Exterior Lightings Switches','Beacon Light','Avionics Switch','APU','Battery 1 / 2'];
var R18 = ['OFF','CUTOFF','SET','OFF','OFF','OFF','OFF','OFF','OFF','OFF','SHUTDOWN','OFF'];
#################### MAIN PROGRAM #################

setlistener("instrumentation/checklist[0]/norm", func {
	if (getprop("instrumentation/checklist[0]/norm")) {
		chklst = 0;
		page = getprop("instrumentation/checklist[0]/nr-page");		
		display(chklst,page);
		setlistener("instrumentation/checklist[0]/nr-page", func {
			chklst = 0;
			page = getprop("instrumentation/checklist[0]/nr-page");
			display(chklst,page);
		});
	}
},);

setlistener("instrumentation/checklist[1]/norm", func {
	if (getprop("instrumentation/checklist[1]/norm")) {
		chklst = 1;
		page = getprop("instrumentation/checklist[1]/nr-page");		
		display(chklst,page);
		setlistener("instrumentation/checklist[1]/nr-page", func {
			chklst = 1;
			page = getprop("instrumentation/checklist[1]/nr-page");
			display(chklst,page);
		});
	}
});

var clear = func(chklst) {
	var init = [];
	for (var i=0; i<16; i+=1) {
		append(init,"");
	}
	var tittle = "";
	var lines_L = var lines_R = init;
	setprop("instrumentation/checklist["~chklst~"]/Tittle", tittle);
	forindex (var index; lines_L) {
		setprop("instrumentation/checklist["~chklst~"]/L["~index~"]",lines_L[index]);
	}
	forindex (var index; lines_R) {
		setprop("instrumentation/checklist["~chklst~"]/R["~index~"]",lines_R[index]);
	}
}

var display = func(chklst,page) {
	var T =[T0,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18];
	var L = [L0,L1,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15,L16,L17,L18];
	var R = [R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18];
	clear(chklst);
	setprop("instrumentation/checklist["~chklst~"]/Tittle", T[page]);
	forindex (var index; L[page]) {
		setprop("instrumentation/checklist["~chklst~"]/L["~index~"]",L[page][index]);
	}
	forindex (var index; R[page]) {
		setprop("instrumentation/checklist["~chklst~"]/R["~index~"]",R[page][index]);
	}
}

var next = func(dir) {
	if (dir == 0) {page = getprop("instrumentation/checklist[0]/nr-page")}
	if (dir == 1) {page = getprop("instrumentation/checklist[1]/nr-page")}
	if (page < 18) {
		page += 1;
		setprop("instrumentation/checklist["~dir~"]/nr-page", page);
	}
}

var previous = func(dir) {
	if (dir == 0) {page = getprop("instrumentation/checklist[0]/nr-page")}
	if (dir == 1) {page = getprop("instrumentation/checklist[1]/nr-page")}
	if (page > 1) {
			page -= 1;
			setprop("instrumentation/checklist["~dir~"]/nr-page", page);
	}
}

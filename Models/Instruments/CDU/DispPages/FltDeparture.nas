### Display FltDeparture ###
### C. LE MOIGNE (clm76) - 2015 ###

var fltDep = func(dep_airport,dep_rwy,nrPage,display) {
	var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
	var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var xfile = airportinfo(dep_airport).runways;
		cdu.dspPages(xfile,display);		
		var nbPage = getprop("/instrumentation/cdu/nbpage");
		if (size(display) < 12) {nrPage = substr(display,9,1)}
			else {nrPage = substr(display,9,2)}
		var displayPage = nrPage+1;
		page = "DEPT - RUNWAYS   "~displayPage~" / "~nbPage;;
		if (dep_rwy != "") {DspL.line7l = "< SIDs"};
		DspR.line7r = "FLT PLAN >";
		var ind = 0;
		foreach(var key;keys(xfile)) {
			if (key != "") {
				var n = ind-(6*nrPage);		
				if (n==0) {DspL.line2l = key};
				if (n==1) {DspL.line4l = key};
				if (n==2) {DspL.line6l = key};
				if (n==3) {DspR.line2r = key};
				if (n==4) {DspR.line4r = key};
				if (n==5) {DspR.line6r = key};
				ind+=1;	
			}	
		}
	cdu.DspSet(page,DspL,DspR);
}

var fltSids = func(dep_airport,dep_rwy,nrPage,display) {
	var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
	var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var DepARPT = procedures.fmsDB.new(dep_airport);
		var xfile = [];		
		append(xfile,"DEFAULT");
		if (DepARPT != nil) {
			var SList = DepARPT.getSIDList(dep_rwy);
			foreach(var SID; SList) {
				append(xfile, SID.wp_name);
			}
		}
		cdu.dspPages(xfile,display);		
		nbPage = getprop("/instrumentation/cdu/nbpage");
		if (size(display) < 12) {nrPage = substr(display,9,1)}
			else {nrPage = substr(display,9,2)}
		var displayPage = nrPage+1;
		page = "SIDS    "~displayPage~" / "~nbPage;
		DspL.line7l = "< FLT PLAN";
		var ind = 0;
		foreach(var key;xfile) {;
			if (key != "") {
				var n = ind-(6*nrPage);		
				if (n==0) {DspL.line2l = key};
				if (n==1) {DspL.line4l = key};
				if (n==2) {DspL.line6l = key};
				if (n==3) {DspR.line2r = key};
				if (n==4) {DspR.line4r = key};
				if (n==5) {DspR.line6r = key};
				ind+=1;	
			}	
		}
	cdu.DspSet(page,DspL,DspR);
}

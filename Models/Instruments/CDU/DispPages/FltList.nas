### Display CduStart ###
### C. LE MOIGNE (clm76) - 2015 ###


var fltList = func(display) {
	var DspL = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:""};
	var DspR = {line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var savePath = getprop("/sim/fg-home")~"/FlightPlans/";
		var xfile = subvec(directory(savePath),2);
		cdu.dspPages(xfile,display);				
		nbPage = getprop("/instrumentation/cdu/nbpage");
		if (size(display) < 12) {var nrPage = substr(display,9,1)}
			else {var nrPage = substr(display,9,2)}	
		displayPage = nrPage + 1;
		var nbFiles = size(xfile);
		if (nbFiles == 0) {
				setprop("instrumentation/cdu/input","*NO FILE*");		
				displayPage = 0;
		}
		page = "FLIGHT PLANS LIST   "~displayPage~" / "~nbPage;			
		DspL.line7l = "< FLT PLAN";
		forindex(ind;xfile) {		
				var n = ind-(6*nrPage);	
				if(n==0) {DspL.line2l = xfile[ind]};
				if(n==1) {DspL.line4l = xfile[ind]};
				if(n==2) {DspL.line6l = xfile[ind]};
				if(n==3) {DspR.line2r = xfile[ind]};
				if(n==4) {DspR.line4r = xfile[ind]};
				if(n==5) {DspR.line6r = xfile[ind]};			
		}
	cdu.DspSet(page,DspL,DspR);
}


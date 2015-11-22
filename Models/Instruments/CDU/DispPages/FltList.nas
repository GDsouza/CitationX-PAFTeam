### Display CduStart ###
### C. LE MOIGNE (clm76) - 2015 ###


var fltList = func(display) {
	var Dsp = {line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	var savePath = getprop("/sim/fg-home")~"/aircraft-data/FlightPlans/";
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
		Dsp.line7l = "< FLT PLAN";
		forindex(ind;xfile) {		
				var n = ind-(6*nrPage);	
				if(n==0) {Dsp.line2l = left(xfile[ind],size(xfile[ind])-4)};
				if(n==1) {Dsp.line4l = left(xfile[ind],size(xfile[ind])-4)};
				if(n==2) {Dsp.line6l = left(xfile[ind],size(xfile[ind])-4)};
				if(n==3) {Dsp.line2r = left(xfile[ind],size(xfile[ind])-4)};
				if(n==4) {Dsp.line4r = left(xfile[ind],size(xfile[ind])-4)};
				if(n==5) {Dsp.line6r = left(xfile[ind],size(xfile[ind])-4)};
		}
	cdu.DspSet(page,Dsp);
}


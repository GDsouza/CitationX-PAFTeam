### Canvas Callsign Display ###
### C. Le Moigne (clm76) - june 2019 ###

var CLS = {
	new: func() {
		var m = {parents:[CLS]};
		m.canvas = canvas.new({
			"name": "Callsign", 
			"size": [1024, 1024],
			"view": [600,128],
			"mipmapping": 1 
		});

		m.canvas.addPlacement({"node": "Callsign.screen"});
    m.canvas.setColorBackground(0.15,0.18,0.20,0.5);
		m.cls = m.canvas.createGroup();
    m.bord = m.cls.createChild("path")
                  .rect(4,4,592,120)
                  .setStrokeLineWidth(4)
                  .setStrokeLineJoin("round")
                  .setColor(1,1,1);

		m.txt = m.cls.createChild("text")
                 .setTranslation(300,64)
                 .setAlignment("center-center")
                 .setText("F-GCLM")
                 .setFont("LiberationFonts/LiberationSans-Bold.ttf")
                 .setFontSize(72,0.8)
                 .setScale(1.4) 
                 .setColor(1,1,1);

    m.callsign = "sim/multiplay/callsign";

		return m;
	},

  listen : func {
		setlistener(me.callsign,func(n) {
      if (n.getValue() != "") me.txt.setVisible(1);
      else me.txt.setVisible(0);
		},0,0);

  }, # end of Listen


}; # end of CLS

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var init = CLS.new();
	init.listen();
removelistener(setl);
});


### Canvas Pedestal Selcal Code ###
### C. Le Moigne (clm76) - 2018 ###

var Selcal = {
	new: func() {
		var m = {parents:[Selcal]};
		m.canvas = canvas.new({
			"name": "Selcal", 
			"size": [1024, 1024],
			"view": [200,200],
			"mipmapping": 1 
		});

		m.canvas.addPlacement({"node": "Selcal.screen"});
		m.selcal = m.canvas.createGroup();
    m.text = m.selcal.createChild("text")
      .setText("CH-LM")
		  .setFont("LiberationFonts/LiberationMono-Bold.ttf")
      .setFontSize(36)
      .setColor(1,1,1)
      .setAlignment("center-center")
      .setTranslation(105,85)
      .setScale(1.5);

		return m
	},

}; # end of Code

#### Main ####
var selcal_stl = setlistener("/sim/signals/fdm-initialized", func () {	
	Selcal.new();
	removelistener(selcal_stl);
},0,0);


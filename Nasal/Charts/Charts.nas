##########################################
# CHARTS Canvas Class
# C. Le Moigne (clm76) - 2019
##########################################

var Charts_key = func {
  print("7 W");
  Charts_dsp.init();
};

var Charts_dsp = {
  new : func() {
    var m = {parents:[Charts_dsp,canvas]};
    return m; 
  }, # end of new

  init : func {
    me.l_click = nil;
    me.l_wheel = nil;
    me.txtY = 524;
    me.window = canvas.Window.new([400,550], "dialog").set("title","Charts");
    me.canvas = me.window.createCanvas().set("background", "#f2f1f0");
    me.root = me.canvas.createGroup();
    me.path1 = getprop("sim/fg-aircraft")~"/CitationX/Models/charts.png";
    me.path2 = getprop("sim/fg-home")~"/aircraft-data/Charts/";
    var pos = geo.aircraft_position();
    me.icao = airportinfo(pos.lat(),pos.lon(),'airport').id;
print("28 icao : ",me.icao);
    me.dspCharts();
    me.skin = me.root.createChild("image")
        .set("src",me.path1)
        .set("size[0]",400)
        .set("size[1]",550)
        .set("z-index",0)
        .show();

    me.error = me.root.createChild("text")
        .setTranslation(200,135)
        .set("alignment", "center-center")
        .set("character-size", 20)
        .set("font", "LiberationFonts/LiberationSans-Bold.ttf")
        .set("fill","red")
        .set("z-index",0);

    me.btn_dsp = [
      {name:'ICAO', type:'click', x:43, tol: 17},
      {name:'RWY', type: 'click', x:88, tol: 17},
      {name:'APT', type: 'click',  x:132, tol: 17},
      {name:'APP', type: 'click', x:175, tol: 17},
      {name:'SID', type: 'click', x:220, tol: 17},
      {name:'STAR', type: 'click', x:263, tol: 17},
      {name:'H', type: 'wheel', x:300, tol: 12},
      {name:'V', type: 'wheel', x:333, tol: 12},
      {name:'Z', type: 'wheel', x:366, tol: 12},
    ];

    foreach (var btn;me.btn_dsp) {
      me.text = me.root.createChild("text")
          .setText(btn.name)
          .setTranslation(btn.x,me.txtY)
          .set("alignment", "center-center")
          .set("character-size", 14)
          .set("font", "LiberationFonts/LiberationSans-Bold.ttf")
          .set("max-width", 50)
          .set("fill", "white")
          .set("z-index",1);
      if (btn.type=='click' and me.l_click==nil) {
        me.l_click = me.canvas.addEventListener("click", func(e) {me.click(e);});
      }
      if (btn.type=='wheel' and me.l_wheel==nil) {
        me.l_wheel = me.canvas.addEventListener("click", func(e) {me.wheel(e);});
      }
    }
  }, # end of init

  click : func(e) {
   	foreach(var btn; me.btn_dsp) {
#print("67 clientX : ",e.clientX," - btnX : ",btn.x," - tol : ",btn.tol);
#print("68 clientY : ",e.clientY," - btnY : ",me.txtY," - tol : ",btn.tol);
		  if(btn.type =='click' and abs(e.clientX-btn.x)<btn.tol and abs(e.clientY-me.txtY)<btn.tol) call(me.actuate[btn.name],[nil],me);
		  me.window.clearFocus();
   	}
  }, # end of click

  wheel: func(e){
   	foreach(var btn; me.btn_dsp) {
		  if(btn.type =='wheel' and abs(e.clientX-btn.x)<btn.tol and abs(e.clientY-btn.y)<btn.tol) call(me.actuate[btn_name],[e.deltaY],me);
   	}
  }, # end of wheel

  actuate : {
    'ICAO' : func(parms) {
    	canvas.InputDialog.getText(sprintf('Charts setting'),
      'Enter a valid ICAO:', func(btn,value) {
          if(btn==1) me.setIcao(value);
      });
    }, # end of ICAO

    'RWY' : func(parms) {
    	canvas.InputDialog.getText(sprintf('Charts setting'),
      'Enter a valid Runway:', func(btn,value) {
#          if(btn==1) me.setIcao(value);
      });
    }, # end of RWY
  }, # end of actuate

  setIcao : func(icao) {
    me.icao = string.uc(icao);
    me.airport = airportinfo(me.icao); 
    if(typeof(me.airport)!='ghost') {
#      gui.popupTip(me.icao~' is Not a valid Icao.');
      me.error.setText(me.icao~' is not a valid Icao.').show();
      return;
    } else me.error.hide();  
    me.window.set("title",sprintf("Charts : %s",me.icao)).clearFocus();
    me.dspCharts();
	}, # end of setIcao

  dspCharts : func {
print("112 icao : ",me.icao);
    me.zoom = 1;
#    if (me.text[btn.name]btn.name == "Z") me.zoom = 2;
    me.charts  = me.root.createChild("image")
      .set("src",me.path2~me.icao~"-apt.png")
      .set("x",21) 
      .set("y",33) 
      .setSize(350*me.zoom,460*me.zoom) 
#      .setTranslation(0,-100)
      .set("z-index",-1)
      .show();
  }, # end of dspCharts

}; # end of Charts_dsp

###### Main #####
var charts_setl = setlistener("sim/signals/fdm-initialized", func() {
  var chart = Charts_dsp.new();
	removelistener(charts_setl); 
},0,0);


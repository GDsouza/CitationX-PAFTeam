##########################################
# CHARTS Canvas Class
# C. Le Moigne (clm76) - 2019
# Ref. Canvas Event Handling
#
# Initiated by 'w' key or by menu "Citation X -> Charts"
##########################################

var Charts_key = func {
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
    me.font = "LiberationFonts/LiberationSans-Bold.ttf";
    me.txtY = 524;
    me.tx = me.ty = 0;
    me.icao_flag = 1;
    me.zoom = 1;
    me.page = 0;
    me.width = 400;
    me.height = 550;
    me.factors = [1,1];
    me.rwy = me.old_rwy = nil;
    me.window = canvas.Window.new([me.width,me.height], "dialog").set("title","Charts");
    me.canvas = me.window.createCanvas().set("background", "#f2f1f0");
    me.root = me.canvas.createGroup();
    me.charts = me.root.createChild("image").setScale(1,1);
    me.runways = me.canvas.createGroup();
        ### Create Charts Path if not exists ### 
    me.pathCharts = getprop("/sim/fg-home")~"/Export/Charts/";
    var path = os.path.new(me.pathCharts~"create.txt");
    if (!path.exists()) {
      path.create_dir();
    }

    me.path1 = getprop("sim/aircraft-dir")~"/Nasal/Charts/charts.png";
#    var pos = geo.aircraft_position();
#    me.icao = airportinfo(pos.lat(),pos.lon(),'airport').id;
    me.icao = me.old_icao = getprop("autopilot/route-manager/departure/airport");
    me.rwy = getprop("autopilot/route-manager/departure/runway");

    me.skin = me.root.createChild("image")
        .set("src",me.path1)
        .set("size[0]",me.width)
        .set("size[1]",me.height)
        .set("z-index",0)
        .show();

    me.error = me.root.createChild("text")
        .setTranslation(200,135)
        .set("alignment", "center-center")
        .set("character-size", 20)
        .set("font", me.font)
        .set("fill","red")
        .set("z-index",0);

    me.btn_dsp = [
      {name:'ICAO', type:'click', x:43, tol: 17},
      {name:'RWY', type: 'click', x:88, tol: 17},
      {name:'APT', type: 'click',  x:132, tol: 17},
      {name:'APP', type: 'click', x:175, tol: 17},
      {name:'SID', type: 'click', x:220, tol: 17},
      {name:'STAR', type: 'click', x:263, tol: 17},
      {name:'H', type: 'click', x:300, tol: 12},
      {name:'H', type: 'wheel', x:300, tol: 12},
      {name:'V', type: 'click', x:333, tol: 12},
      {name:'V', type: 'wheel', x:333, tol: 12},
      {name:'Z', type: 'click', x:366, tol: 12},
      {name:'Z', type: 'wheel', x:366, tol: 12},
    ];

    foreach (var btn;me.btn_dsp) {
      me.text = me.root.createChild("text")
          .setText(btn.name)
          .setTranslation(btn.x,me.txtY)
          .set("alignment", "center-center")
          .set("character-size", 14)
          .set("font", me.font)
          .set("max-width", 50)
          .set("fill", "white")
          .set("z-index",1);
      if (btn.type=='click' and me.l_click==nil) {
        me.l_click = me.canvas.addEventListener("click",func(e) {
          me.click(e);});
      }
      if (btn.type=='wheel' and me.l_wheel==nil) {
        me.l_wheel = me.canvas.addEventListener("wheel", func(e) {
          me.wheel(e);});
      }
    }

    me.l_drag = me.canvas.addEventListener("drag", func(e) {me.drag(e);});
    me.sel = me.old_sel = "apt";    
    me.initFiles();
  }, # end of init

  click : func(e) {
   	foreach(var btn; me.btn_dsp) {
		  if(btn.type =='click' and abs(e.clientX-btn.x)<btn.tol and abs(e.clientY-me.txtY)<btn.tol) call(me.actuate[btn.name],[nil,0],me);
		  me.window.clearFocus();
   	}
  }, # end of click

  wheel: func(e) {
   	foreach(var btn; me.btn_dsp) {
		  if(btn.type =='wheel' and abs(e.clientX-btn.x)<btn.tol and abs(e.clientY-me.txtY)<btn.tol) call(me.actuate[btn.name],[e.deltaY,1],me);
   	}
  }, # end of wheel

  drag : func(e) {
    var (Tx,Ty) =  me.charts.getTranslation();
    me.tx = Tx+e.deltaX;
    me.ty = Ty+e.deltaY;
    me.tx = me.tx > 300 ? 300 : me.tx < -300 ? -300 : me.tx;
    me.ty = me.ty > 450 ? 450 : me.ty < -450 ? -450 : me.ty;
    me.charts.setTranslation(me.tx,me.ty);
  }, # end of drag

  actuate : {
    'ICAO' : func(param) {
    	canvas.InputDialog.getText(sprintf('Charts setting'),
      'Enter a valid ICAO:', func(btn,value) {
          if(btn==1) me.setIcao(value);
          else me.error.hide();
      });
    }, 

    'RWY' : func(param) {
        me.charts.hide();
        me.error.hide();
        me.airport = airportinfo(me.icao); 
        me.window.set("title",sprintf("Charts : %s",me.icao));
        var y = 10;
        var t = 22;
        me.Buttons = [];
        foreach (var Rwy; keys(me.airport.runways)) append(me.Buttons,Rwy);
        me.Buttons = sort(me.Buttons,func(a,b) cmp(a,b));
        for (var i=0;i<size(me.Buttons);i+=1) {
          me.runways.createChild("path")
            .rect(me.width/2-38,y+=43,76,24,{"border-radius":5})
            .setStrokeLineWidth(2)
            .setColor('#5F5F5F')
            .setColorFill('#A9A9A9')
            .addEventListener("click",func(e) {me.setRwy(e)});

          me.runways.createChild("text")
            .setText(me.Buttons[i])
            .setTranslation(me.width/2,t+=43)
            .setAlignment("center-center")
            .setFont(me.font)
            .setFontSize(22,1)
            .setColor(1,1,0)
            .addEventListener("click",func(e) {me.setRwy(e)});
        }
    },

    'APT' : func (param) {
      if (me.icao_flag) {me.sel = 'apt';me.initFiles()}
      else return;
    },
    'APP' : func (param) {
      if (me.icao_flag) {me.sel = 'app';me.initFiles()}
      else return;
    },
    'SID' : func (param) {
      if (me.icao_flag) {me.sel = 'sid';me.initFiles()}
      else return;
    },
    'STAR' : func (param) {
      if (me.icao_flag) {me.sel = 'star';me.initFiles()}
      else return;
    },

    'H' : func (deltaY,param) {
      if (!param) {me.tx = 0;me.charts.setTranslation(me.tx,me.ty)}
      else {
        var (Tx,Ty) =  me.charts.getTranslation();
        me.tx = Tx + deltaY*10;
        me.charts.setTranslation(me.tx,Ty);
      }
    },

    'V' : func (deltaY,param) {
      if (!param) {me.ty = 0;me.charts.setTranslation(me.tx,me.ty)}
      else {
        var (Tx,Ty) =  me.charts.getTranslation();
        me.ty = Ty + deltaY*10;
        me.charts.setTranslation(Tx,me.ty);      
      }
    },

    'Z' : func (deltaY,param) {
      if (!param) {
        me.tx = me.ty = 0;
        me.zoom = 1;
      } else {
        me.zoom += deltaY/10;
      }
      var (Xmin,Ymin,Xmax,Ymax) = me.charts.getBoundingBox();
      var x = (Xmin+Xmax)/2;
      var y = (Ymin+Ymax)/2;
      var u = me.tx + x;
      var v = me.ty + y;
      me.charts.setScale(me.zoom,me.zoom);
      me.charts.setTranslation(u-(x*me.zoom), v-(y*me.zoom));
    },
  }, # end of actuate

  setIcao : func(icao) {
    me.icao = string.uc(icao);
    me.airport = airportinfo(me.icao); 
    if(typeof(me.airport)!='ghost') {
      me.dspError(me.icao~' is not a valid Icao.');
      return;
    } else {
      me.error.hide();
      me.page = 0;
      me.window.set("title",sprintf("Charts : %s",me.icao));
      me.path = me.pathCharts~me.icao;
      if (directory(me.path) != nil) {
        me.icao_flag = 1;
        me.sel = me.old_sel;
        me.rwy = nil;
        me.initFiles();
      } else {
        me.icao_flag = 0;
        me.dspError('No Charts for '~me.icao);
      }
    }
	}, # end of setIcao

  setRwy : func(e) {
    me.rwy = me.Buttons[int(e.clientY/43)-1];
    me.initFiles();
  }, # end of setRwy

  initFiles : func {
    me.path = me.pathCharts~me.icao;
    if (directory(me.path) != nil) {
      me.xfile = subvec(directory(me.path),2);
      for (var n=0;n<size(me.xfile);n+=1) {
        me.xfile[n] = string.truncateAt(me.xfile[n],".png");
      }
      me.searchFiles();
    } else {me.xfile = [];me.dspError('No Charts for '~me.icao)}
  }, # end of initFiles

  searchFiles : func {
    if (me.old_sel != me.sel) me.page = 0;
    me.old_sel = me.sel;
    me.vec = [];
    me.error.hide();
    me.runways.removeAllChildren();
    if (me.sel == 'apt') me.file = me.sel;
    else {
      if (me.rwy == nil) {
        me.dspError('You must choose a runway');
        return;
      } else me.file = me.rwy~"-"~me.sel;
    }
    for (var n = 0;n<size(me.xfile);n+=1) {
      if (find(me.file,me.xfile[n]) != -1) append(me.vec,me.xfile[n]);
    }
    if (size(me.vec) == 0) {
      me.dspError('No Charts for '~me.icao~' '~me.file);
      me.page = 0;
    } else {
      me.file = me.file~me.page;
      me.dspCharts();
      me.page+=1;
      if (me.page == size(me.vec)) me.page = 0;
    }
  }, # end of searchFiles

  dspCharts : func {  
    me.window.set("title",sprintf("Charts : %s",me.icao~" "~me.file)).clearFocus();
    me.charts.set("src",me.path~"/"~me.file~".png")
      .set("x",21) 
      .set("y",30) 
      .setSize(355,470) 
      .set("z-index",-1)
      .show();
  }, # end of dspCharts

  dspError : func (txt) {
    me.error.setText(txt).show();
    me.charts.hide();
    me.runways.removeAllChildren();
  }, # end of dspError

}; # end of Charts_dsp

###### Main #####
var charts_setl = setlistener("sim/signals/fdm-initialized", func() {
  var chart = Charts_dsp.new();
	removelistener(charts_setl); 
},0,0);


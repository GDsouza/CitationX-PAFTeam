#var addon = addons.getAddon("org.flightgear.addons.PAR");
var root = getprop("/sim/aircraft-dir")~"/Nasal/PAR"; 
foreach(helper;['plot2D','graph','skinnable'])  if (canvas[helper]==nil) io.load_nasal(root ~'/'~ helper~'.nas', "canvas" );
var (white,grey,dark,red,green,blue,yellow,mauve,brown,sky) = 
  ['#eeeeee','#777777','#355535','#ee0000','#00aa00','#0000ee','#fcf800',
  '#ffaaff','#a87010','#50eaed'];
#print("Precision Approach Radar (v:" ~ addon.version.str() ~ ") loaded. Press '>' key to instantiate it.");
var gcaCtrl = nil;
var err = [];
var dt = nil;

var instrument = func(){ # Shows hidden screens (if any) or instanciate a new one.
 var instanced = props.globals.getNode('/instrumentation').getChildren('par');
   var hidden = 0;
   foreach(i;instanced) if(i.getChild('visible').getValue()==0) hidden = 1;
   if(hidden) { # show all
   foreach(i;instanced) if(i.getChild('visible').getValue()==0) 
       i.getChild('visible').setValue(1);
   } else # new one
   par.show.new(size(instanced));
};

var show =  {
  new: func(n) {
    var m = {parents:[show,canvas.graph] };
    m.destination = {airport:'', runway:'', elevation:0.00, glidepath:0.00, 
                    safety_slope:0.00, decision_height:0.00, offset:0.00, 
                    rwy_object:'', final:10 };
    m.TerrainResolution = 0.2;
    m.maxX = 16;
    m.asph = nil;
    m.terrain = nil;
    m.Hcone = nil;
    m.Vcone = nil;
    m.Hcenter = nil;
    m.Vcenter = nil;
    m.xyGrid = nil;
    m.xzGrid = nil;
    m.basePts = nil;
		var sk = canvas.skinnable.new([540,376]);
    sk.canvas.set("background", '#224422');
    var myGroup =  sk.root.createChild("group");
    var marksGroup =  sk.root.createChild("group");
    m.xzGraph = canvas.graph.new(myGroup, [61,138,25.625,-.025]);
    m.xyGraph = canvas.graph.new(myGroup, [61,229,25.625,-25.625]);
#    m.skin = sk.addSkin(root~"/skin.png");
    m.skin = sk.addSkin(root~"/skin.png").set("size[0]",540)
                                         .set("size[1]",376);
    m.bttn = sk.addSkin(root~"/skin_b1.png").setTranslation(202,333).hide();
    m.Hmarks = canvas.graph.new(marksGroup, [61,229,25.625,-25.625]);
    m.Vmarks = canvas.graph.new(marksGroup, [61,138,25.625,-.0222]);
    m.frontGroup =  sk.root.createChild("group").set("font","LiberationFonts/LiberationMono-Regular.ttf");
    m.sk = sk;
    m.positionNode = props.getNode('/position');
    m.init(n);
    return m;
  }, # new()

  init: func(n) {
  	me.sound = {path : root ~ "/sounds",file : "click.wav", volume : 1.0};
    me.alert = {path : root ~ "/sounds",file: "cabinalert.wav", volume: 1.0};
  	props.globals.getNode("/sim/sound/chatter/enabled").setValue(1);
	#	fgcommand("play-audio-sample", props.Node.new(me.sound) );  
  	me.n = n;
    me.node = props.globals.getNode(sprintf('/instrumentation/par[%i]',n),1);
    me.node.addChild('visible').setIntValue(1);
    var myNode = me.node.getChild('visible');
    setlistener(myNode, func {
      if(myNode.getValue()) me.sk.window.move(2000,0); 
      else  me.sk.window.move(-2000,0);
    }, 0, 0);
    me.callsign = getprop("/sim/multiplay/callsign") ;
    me.HTrack = me.xyGraph.group.createChild("path").setColor(sky);
    me.VTrack = me.xzGraph.group.createChild("path").setColor(sky);
    me.Hmark = me.xyGraph.group.createChild("text", 'mark').setColor(sky);
    me.Vmark = me.xzGraph.group.createChild("text", 'mark').setColor(sky);
    me.Hmark.setText(sprintf("o\n%s",right( me.callsign,3))).setFontSize(8,.8).setAlignment('left-top');
    me.Vmark.setText(sprintf("%s\no",right( me.callsign,3))).setFontSize(8,.8).setAlignment('left-baseline');
	  var wheelHots = [
			{type:'wheel', action:'wheelFinal', x:500, y:194, tol:9 },
			{type:'cursor', style:'hand', tip:'Final Distance', x:500, y:194, tol:9 },
			{type:'click', action:'wheelFinal',         parms:1,  x:512, y:194, tol:6  },
			{type:'click', action:'wheelFinal',         parms:-1,  x:488, y:194, tol:6  },
			{type:'wheel', action:'wheelSlope', x:500, y:75, tol:10 },
			{type:'cursor', style:'hand', tip:'Glide Slope', x:500, y:75, tol:10 },
			{type:'click', action:'wheelSlope',         parms:1,  x:512, y:75, tol:6  },
			{type:'click', action:'wheelSlope',         parms:-1,  x:488, y:75, tol:6  },
			{type:'wheel', action:'changeZoom', x:500, y:287, tol:10 },
			{type:'cursor', style:'hand', tip:'Zoom', x:500, y:287, tol:10 },
			{type:'click', action:'changeZoom',         parms:1,  x:512, y:287, tol:6  },
			{type:'click', action:'changeZoom',         parms:-1,  x:488, y:287, tol:6  },
			{type:'click', action:'changeIcao',         parms:nil,  x:52, y:348, tol:10  },
			{type:'click', action:'changeRwy',       parms:nil, x:109, y:348, tol:10  },
			{type:'click', action:'toggleGCA',         parms:nil,  x:224, y:348, tol:10  },
			{type:'click', action:'settings',         parms:nil,  x:286, y:348, tol:10  },
			{type:'click', action:'flip',         parms:nil,  x:350, y:348, tol:10  },
			{type:'cursor', style:'hand', tip:'',  x:350, y:348, tol:10  },
			{type:'click', action:'hide',         parms:nil,  x:413, y:348, tol:10  },
			];
		me.sk.listen_mouse_events(caller:me, Hots:wheelHots);
    me.aptText = canvas.plot2D.text(me.frontGroup,'',[20,315],nil,white);
		me.rwyText = canvas.plot2D.text(me.frontGroup,'',[109,326],nil,yellow,'center-baseline');
		me.hdgText = canvas.plot2D.text(me.frontGroup,'',[52,278],[10,1],yellow,'left-baseline');
    me.altText = canvas.plot2D.text(me.frontGroup,'',[52,291],[10,1],yellow,'left-baseline');
		me.dataText = canvas.plot2D.text(me.frontGroup,'',[52,265],[10,1],yellow,'left-baseline');
		me.noTerrain = canvas.plot2D.text(me.frontGroup,'Too Far : Terrain data is not available yet.',[246,148],[12,0.8],brown,'center-baseline');
		me.noTerrain.hide();

    me.finalText = canvas.plot2D.text(me.frontGroup,sprintf('%i nm',me.destination.final),[163,326],nil,yellow,'center-baseline');
    me.callsignText = canvas.plot2D.text(me.frontGroup,me.callsign,[224,326],nil,sky,'center-baseline');
    me.gsText  = canvas.plot2D.text(me.frontGroup,'',[500,100],nil,white,'center-center');
		me.zoomText  = canvas.plot2D.text(me.frontGroup,sprintf('%i',me.maxX),[500,314],nil,white,'center-center');

				# Choose destination from route-manager
    if(getprop("/autopilot/route-manager/active")){
				me.setIcao(getprop("/autopilot/route-manager/destination/airport"));
		} else {
		    # Choose destination from comm freq
   		if(getprop("/instrumentation/comm/airport-id")!=''){
		    me.setIcao(getprop("/instrumentation/comm/airport-id"));
		    if(getprop("/instrumentation/comm/volume")<0.1) {
		      gui.popupTip("Turn Comm1 on. Set volume",3);
		      return ;
		    } else if(me.airport.name==nil or getprop("/instrumentation/comm/signal-quality-norm")<0.01) { # if invalid freq or out of range
		      gui.popupTip("Check comm freq.!",3);
		      return ;
		    }
      } else me.setIcao(airportinfo().id); # Choose nearest destination
		} 
   	me.timer = maketimer(2,func {me.update();});
    me.timer.stop();
    me.timer.simulatedTime=1;
    me.timer.start();
    me.DrawScreen();
  }, # end of init
 
  setWnode: func(s) {
    me.live = props.getNode(string.replace(s,'canvas:/','/canvas'));
  }, # end of setWnode
  
 
  actuate : {
    'changeRwy': func(parms) {
      if(me.bttn.getVisible()) me.modal(text:'runway', function:func(sel) {
	      if(sel == canvas.MessageBox.Yes) {call(me.actuate['toggleGCA'],nil,me);fgcommand("pause");
        } else {fgcommand("pause");  return "cancel.";} });
      else call(me.actuate.rwy,nil,me);
    }, # end of changeRwy

    rwy: func{
      var runways = keys(me.airport.runways);
      for(var i=0; i<size(runways);i+=1) if(runways[i] == me.rwyObj.id) break;
      if(i == size(runways)-1) i = -1;
      me.rwyObj = me.airport.runways[runways[i+1]];
      me.touch();
      foreach(obj;[me.HTrack,me.VTrack]) obj.reset();
      me.rwyText.setText("Rwy "~ me.rwyObj.id);
			me.hdgText.setText(sprintf("hdg: %i deg", me.rwyObj.heading));
			me.dataText.setText(sprintf("%i x %i m", me.rwyObj.length, me.rwyObj.width));
#      me.newRwy = 1;
			fgcommand("play-audio-sample", props.Node.new(me.sound));
      me.drawTerrain();
#      me.drawCones();
      #~TODO: me.compass.setRotation((180-me.rwyObj.heading)*D2R);
    }, # end of rwy

    'changeIcao': func(parms) {
      if(me.bttn.getVisible()) me.modal(text:'airport', function:func(sel) {
		      if(sel == canvas.MessageBox.Yes){ call(me.actuate['toggleGCA'],nil,me); call(me.actuate.icao,nil,me); fgcommand("pause");}
		      else {fgcommand("pause");  return "cancel.";} });
      else call(me.actuate.icao,nil,me);
    },# changeIcao

    icao: func{
      	canvas.InputDialog.getText(sprintf('PAR setting'),
      'Enter a valid ICAO:', func(btn,value) {
        if(btn==1) call(me.setIcao,[value],me);
      }, me.icao);
    }, # icao

		'wheelFinal': func(delta) {
			 if(me.bttn.getVisible())
				  me.modal(text:'final', function:func(sel) {
						if(sel == canvas.MessageBox.Yes){ call(me.actuate['toggleGCA'],nil,me); call(me.actuate.incfinal,[delta],me); fgcommand("pause");}
						else {fgcommand("pause");  return "cancel.";} });
				else call(me.actuate.incfinal,[delta],me);
		}, # wheelFinal

		incfinal: func(d) {
			fgcommand("play-audio-sample", props.Node.new(me.sound));
			me.destination.final += d;
			me.finalText.setText(sprintf('%i nm',me.destination.final));
			me.Vcenter.del();
			me.Vcenter = me.xzGraph.line([0,0],[me.destination.final,me.destination.final * math.tan(me.slope*D2R)*6076],red);
			if(isa(gcaCtrl, Controller) ) gcaCtrl.destination.final=me.destination.final;
		}, # incfinal

		'wheelSlope': func(delta) {
			 if(me.bttn.getVisible())
			me.modal(text:'glideSlope', function:func(sel) {
			if(sel == canvas.MessageBox.Yes){ call(me.actuate['toggleGCA'],nil,me); call(me.actuate.gs,[delta/10],me); fgcommand("pause");}
			else {fgcommand("pause");  return "cancel.";} });
			else call(me.actuate.gs,[delta/10],me);
		}, # wheelSlope

		gs: func(i){
			fgcommand("play-audio-sample", props.Node.new(me.sound));
			me.Vcenter.del();
			var min =  math.atan2(me.mSlope()/6076,1)*R2D;
			if(me.slope+i >= min) me.slope += i;
			me.Vcenter = me.xzGraph.line([0,0],[me.destination.final,me.destination.final * math.tan(me.slope*D2R)*6076],red);
		 me.gsText.setText(sprintf('%.1f',me.slope));
		}, # gs

    'toggleGCA': func(parms=nil) {
      if(!me.bttn.getVisible() and gcaCtrl !=nil){
        gui.popupTip('GCA is already active');
	      return;
  	  }
			fgcommand("play-audio-sample", props.Node.new(me.sound));
	    me.bttn.toggleVisibility();
	    if(gcaCtrl !=nil and gcaCtrl.phrase !='bye') {
	      setprop("/sim/sound/voices/atc", 'Controlled Approach aborts here.');
	      gcaCtrl = nil;
	    }
    }, # end of toggleGCA

    'settings': func(parms) {
			fgcommand("play-audio-sample", props.Node.new(me.sound));
      gui.popupTip('Not implemented yet');
			me.skin.toggleVisibility(); #R
    }, # end of settings

    'flip': func(parms) {
			fgcommand("play-audio-sample", props.Node.new(me.sound));
      var x0 = me.xyGraph.view[0]==61? 460 : 61;
      foreach(graph;[me.xyGraph,me.xzGraph,me.Hmarks,me.Vmarks]) {
	      graph.view[0] = x0;
	      graph.view[2] *=-1;
      }
      me.DrawScreen();
    }, # end of flip

    'hide': func(parms) {
      me.node.getChild('visible').setValue(0);
      gui.popupTip('To make PAR visible again, press ">" key.');
    }, # end of hide

    'changeZoom': func(delta) {
			fgcommand("play-audio-sample", props.Node.new(me.sound));
			var f = delta==1? 2 : 0.5 ;
	    foreach(graph;[me.xyGraph,me.xzGraph,me.Hmarks,me.Vmarks]) {
		    graph.view[2] /= f;
		    graph.view[3] /= f;
		    }
	    me.maxX *= f;
			me.zoomText.setText(sprintf('%i',me.maxX));
	    me.DrawScreen();
	    me.update();
    }, # end of changeZoom
 
 }, # end of actuate

  IcaoExceptions : func(icao) {
		var station_name = getprop("/instrumentation/comm/station-name"); 
		if (icao == "LFPB" and left(station_name,9) == "DE GAULLE") me.icao = "LFPG";
		return me.icao;
	}, # end of IcaoExceptions

  setIcao: func(icao){
    me.icao = icao;
    me.IcaoExceptions(me.icao);
    me.airport = airportinfo(me.icao); 
    if(typeof(me.airport)!='ghost') {
      gui.popupTip(me.icao~' is Not a valid Icao.');
      return;
    }  
 		me.winTitle();
    var best = chooseRwy(me.airport.runways);
    me.rwyObj = me.airport.runways[best];
    me.touch();
    me.rwyText.setText("Rwy "~ me.rwyObj.id);
		me.hdgText.setText(sprintf("hdg: %i deg", me.rwyObj.heading));
		me.dataText.setText(sprintf("%i x %i m", me.rwyObj.length, me.rwyObj.width));
    me.altText.setText(sprintf("alt: %i ft",me.airport.elevation*M2FT));
    me.aptText.setText(me.airport.name);
#  	me.newRwy = 1;
		me.DrawScreen(); 
    foreach(obj;[me.HTrack,me.VTrack]) obj.reset();
	}, # end of setIcao

	winTitle: func(warn=''){
	 me.sk.window.set("title",sprintf("PAR %i: %s %s",me.n+1, string.uc(me.icao), warn )).clearFocus();
	},

  touch: func(){
    me.touchObj = geo.Coord.new().set_latlon(me.rwyObj.lat, me.rwyObj.lon)
      .apply_course_distance(me.rwyObj.heading, 250);
		var elev = geo.elevation(me.rwyObj.lat, me.rwyObj.lon);
		var e = elev==nil? me.airport.elevation : elev ;
		me.touchObj.set_alt(1+e);
  }, # end of touch

  drawTerrain: func(){
    if(me.terrain!=nil) me.terrain.del();
# 		var max = math.max(me.destination.final, me.maxX);
    me.profile = par.getVertProfile(me.touchObj,me.rwyObj.heading+180, me.TerrainResolution,me.maxX);
    var xset = [];
    var base = 10/me.xzGraph.view[3];
    forindex(i;me.profile){
      if(me.profile[i]==nil) me.profile[i]= base;
      append(xset,i);
    }
    append(xset,xset[-1],-0.5,-0.5); # closure to fill
    append(me.profile,base,base,0);
    me.terrain = call(me.xzGraph.polyline,[xset,me.profile,brown],me.xzGraph);
    me.terrain.setStrokeLineWidth(2).setColorFill(brown);
  }, # end of drawTerrain

  drawCones: func(){
    foreach(obj;[me.Vcone,me.Vcenter,me.asph]) if(obj!=nil) obj.del();
		 var mS = me.mSlope(); # as ft/nm
    var tan_mS = mS/6076;#  (6076 ft = 1 nm)
#    if(me.newRwy){ # recalc slope
#      var tan_gS = (tan_mS+.0349)/(1-tan_mS * .0349);# .0349 = tan(2°)
#      var tan_gS = (tan_mS+.0524)/(1-tan_mS * .0524);# .0524 = tan(3°)
      var tan_gS = 0.0524; # .0524 = tan(3°)
      me.slope = math.atan2(tan_gS,1)*R2D; 
#      me.newRwy = 0;
#    }
    me.minSlope = math.atan2(tan_mS,1)*R2D; 
    var xvec = [10, 0, 10];
    # var yvec = [10*mS, 0, 10*(mS+425)]; # 425 ft = tan(4°)
    var yvec = [10*mS, 0, 10*(mS+532)]; # 532 ft = tan(5°)
    me.Vcone = me.xzGraph.polyline( xvec, yvec, white);
    yvec = [10*math.tan(6*D2R), 0, -10*math.tan(6*D2R)];
		me.asph = me.xyGraph.rectangle([0.8,0.3],[-0.4,-0.15],grey,grey);
    me.Hcone = me.xyGraph.polyline( xvec, yvec, white);
    me.Hcenter = me.xyGraph.line([0,0],[10,0],red);
    var z = me.destination.final * math.tan(me.slope*D2R)*6076;
    me.Vcenter = me.xzGraph.line([0,0],[me.destination.final,z],red);
    me.gsText.setText(sprintf('%.1f',me.slope));
  }, # end of drawCones

  drawGrids: func(){
    var Abs = func(graph,axis,n){return n*graph.view[axis]; }
    var sgn = math.sgn(me.xzGraph.view[2]);
    var (maxX,maxY,maxZ) = [me.maxX,me.maxX*.1875,me.maxX*250,];
    var size = [ sgn*Abs(me.xzGraph,2,maxX), Abs(me.xzGraph,3,-maxZ)];
    var (dx,dy) = [sgn*Abs(me.xzGraph,2,1), Abs(me.xzGraph,3,-1000)];
    var origin = me.xzGraph.view[2]>0? me.xzGraph.xy([0,maxZ]):me.xzGraph.xy([maxX,maxZ]);
    me.xzGrid = canvas.plot2D.grid(me.xzGraph.group,size,dx,dy,origin,grey);   
    size = [ sgn*Abs(me.xyGraph,2,maxX), Abs(me.xyGraph,3,-maxY*2)];
    dy = Abs(me.xyGraph,3,-1);
    origin = me.xyGraph.view[2]>0? me.xyGraph.xy([0,maxY]):me.xyGraph.xy([maxX,maxY]);
    me.xyGrid = canvas.plot2D.grid(me.xyGraph.group,size,dx,dy,origin,grey);
  }, # end of drawGrids

  setFinal: func(nm){
    me.destination.final = num(nm);
    me.finalText.setText(sprintf('%i nm',me.destination.final));
    if(isa(gcaCtrl, Controller) ) gcaCtrl.destination.final=nm;
 }, # end of setFinal

  DrawScreen: func(){
    foreach(obj;[me.xyGrid,me.xzGrid,me.terrain,me.Hcone,me.Vcone,
            me.Hcenter,me.Vcenter,me.asph])
    if(obj!=nil) obj.del();
    foreach(obj;[me.HTrack,me.VTrack]) obj.reset();
    me.drawTerrain();
    me.drawGrids();
    me.drawCones();
    me.Hmark.setTranslation(0,0); # hide mark
    me.Vmark.setTranslation(0,0); # hide mark
  }, # end of DrawScreen

  update: func() { # called by me.timer
		if (geo.elevation(me.rwyObj.lat, me.rwyObj.lon) == nil) {
		me.touch();
		dt = 0; 
#		me.winTitle('Terrain profile is not available yet.');
		me.terrain.hide();
		me.noTerrain.show();

		}
			else {
				if (!dt) {
			me.drawTerrain();
			me.drawCones();
			dt = 1; 
#			me.winTitle(); 
			me.noTerrain.hide();
			me.terrain.show();
#			fgcommand("play-audio-sample", props.Node.new(me.alert));
			}
		}     
    var nodes = me.validNodes(range:me.maxX);
    me.Hmarks.group.removeAllChildren();
    me.Vmarks.group.removeAllChildren();
    if(size(nodes)){
      for(var i=1; i<size(nodes); i+=1) call(me.updateMark,[nodes[i]],me,err = []);
      if (size(err)) {
#		    print("Closing instrument");
		    var instance = props.globals.getNode(sprintf('/instrumentation/par[%i]',me.n));
		    if(instance !=nil) instance.remove();
				if(me.bttn.getVisible()){
					me.bttn.hide();
					gcaCtrl =nil;
      	}
      me.timer.stop();
	    }
		}
    me.appendTrack(me.positionNode);
    if(me.bttn.getVisible()) me.service();
  }, # end of update 

  appendTrack: func(node) { 
    var (x,y,z) =  me.xyz(node);
    var absH =  me.xyGraph.xy([x,y]);
    if (absH[1] < 150) absH[1] = 150; # To avoid vertical line
    var absV =  me.xzGraph.xy([x,z]);
    if(me.HTrack.getNumSegments()==0) {
	    me.HTrack.moveTo(absH);
	    me.VTrack.moveTo(absV);
    }
    if(y>me.maxX*.1875){ # if y > maxY
      y = me.maxX*.1875;
      me.Hmark.hide();
    } else {
      me.Hmark.show();
    }   
	  me.xyGraph.appendPath(me.HTrack,[x,y]);
	  me.xzGraph.appendPath(me.VTrack,[x,z]);
	  me.Hmark.setTranslation(absH[0]-4,absH[1]-5);
	  me.Vmark.setTranslation(absV[0]-4,absV[1]-6);

  }, # end of appendTrack

  validNodes: func(range=100) { # for me and AI traffic (if flying, dist < range)
    var v = [props.globals.getNode("/position")];
    var AIList = props.globals.getNode("/ai/models").getChildren( 'aircraft' );
    for(var i=0; i<size(AIList); i+=1) {
      var (rho,delta,alt) = me.rhoDeltaAlt(AIList[i].getNode("position"));
      var tas = AIList[i].getNode('velocities',1).getNode('true-airspeed-kt',1).getValue();
      if(rho <range and tas > 1) append(v, AIList[i].getNode("position")); # ignore not flying and far ones.
    }
    return v;
  }, # end of validNodes

  rhoDeltaAlt: func(node) { # Relatives to touchObj
    var lat = node.getValue('latitude-deg');
    var lon = node.getValue('longitude-deg');
    var plane = {lat: lat, lon: lon};
    var (delta, rho) = courseAndDistance(me.touchObj, plane); # to touch
    delta = 180 + me.rwyObj.heading - delta;
    var alt = node.getValue('altitude-ft');
    return [rho,delta,alt];
  }, # rhoDeltaAlt

  updateMark: func(node) {
    var (x,y,z) =  me.xyz(node);
    var cs = node.getParent().getValue("callsign");
      if(y<me.maxX*.1875){ # if y< maxY
        var absH =  me.xyGraph.xy([x,y]);
        var absV =  [absH[0], me.xzGraph.xy([x,z])[1]];
        me.Hmarks.text(text:sprintf("o\n%s",right(cs,3)), origin:[x,y], size:[10,1], color:yellow, align:"left-top")
					.setTranslation(absH[0]-4,absH[1]-5);
        me.Vmarks.text(text:sprintf("%s\no",right(cs,3)), origin:[x,y], size:[10,1], color:yellow, align:"left-baseline")
					.setTranslation(absV[0]-4,absV[1]-6);
     }
  }, # updateMark

  service: func(){
    if( !isa(gcaCtrl, Controller)){# Instance Controller 
      gcaCtrl = par.Controller.new(me);
      gcaCtrl.setDestination(me.icao,me.rwyObj.id,me.destination.final,me.minSlope);#,me.touchObj.alt());
      gcaCtrl.setPositionNode(me.positionNode);
    }
    gcaCtrl.updatePosition();
    gcaCtrl.updateStage();
    gcaCtrl.computeRequiredHeading();
    gcaCtrl.computeRequiredAltitude();
    var instruction = gcaCtrl.buildInstruction();
    gcaCtrl.notify(instruction);
  },# end of service

  xyz: func(node) { # Relatives to touchObj
    var (dist,delta,altitude) = me.rhoDeltaAlt(node);
    var x = dist*math.cos(delta*D2R);
    var y = dist*math.sin(delta*D2R);
		var z = altitude - me.touchObj.alt()*M2FT;
    return [x,y,z]; # as nm,nm,ft
  }, # end of xyz

  modal: func(text,function){
    fgcommand("pause");
    canvas.MessageBox.question( "GCA is active",
    "Changing "~text~" will abort the current GCA service. \n(Instead, you can open other PAR screen)\n\nAbort GCA ?",
    function);
  }, # end of modal

	mSlope: func(){ 
		var ret = 0;
		for(i=1; i<=me.destination.final/me.TerrainResolution; i+=1) 
			if(i<size(me.profile) and me.profile[i]/i>ret) ret=me.profile[i]/i;
			return ret/me.TerrainResolution; # mSlope as (ft/nm)
	}, # enf of mSlope

}; # end of show



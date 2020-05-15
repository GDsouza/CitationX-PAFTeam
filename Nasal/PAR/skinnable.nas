 var skinnable = {
 new: func(size,title='') { # size as [width, height]
 var m = {parents:[skinnable, canvas] };
 m.size = size;
 m.l_clicks = nil;
 m.l_wheel = nil;
 m.window = canvas.Window.new(size,"dialog").set('title',title).clearFocus();
 m.canvas = m.window.createCanvas();
 m.root = m.canvas.createGroup();
 return m;
 }, # new()
 
addSkin: func(filename){
me.root.createChild("image").set("src", filename);
},

listen_mouse_events: func(caller,Hots){
	me.caller = caller;
	me.Hots = Hots;
	foreach(hot; Hots) {
		if(hot.type=='click' and me.l_clicks==nil) me.l_clicks =me.canvas.addEventListener("click", func(e) { me.clicked(e);});
		if(hot.type=='wheel' and me.l_wheel ==nil) me.l_wheel = me.canvas.addEventListener("wheel", func(e) { me.wheel(e) ; });
		if(hot.type=='tip') me.createTip(hot);
		if(hot.type=='cursor') me.cursor(hot);
	}
},

clicked: func(e){
	if(e.ctrlKey) printf('click at client(%.1f , %.1f)  screen(%i , %i)', e.clientX, e.clientY, e.screenX, e.screenY);
 	foreach(hot; me.Hots) {
		if(hot.type =='click' and abs(e.clientX-hot.x)<hot.tol and abs(e.clientY-hot.y)<hot.tol) {
		call(me.caller.actuate[hot.action],[hot.parms],me.caller);
		}
		me.window.clearFocus();
 	}
},

createTip: func(hot) {
 var region = canvas.plot2D.rectangle(me.root,[2*hot.tol, 2*hot.tol],[hot.x-hot.tol,hot.y-hot.tol],'#01010101','#01010101',hot.tol*.75);
 region.addEventListener("mouseover", func(e) {globals.gui.popupTip(hot.text,3);});
 #~ region.addEventListener("mouseover", func(e) {globals.gui.popupTip(hot.text,3,nil,{'x':e.screenX, 'y':e.screenY})}); #????
},

cursor: func(hot) {
 var region = canvas.plot2D.rectangle(me.root,[2*hot.tol, 2*hot.tol],[hot.x-hot.tol,hot.y-hot.tol],'#01010101','#01010101',hot.tol*.75);
 region.addEventListener("mouseenter", func(e) {fgcommand("set-cursor", props.Node.new({'cursor':hot.style}));
		if(hot.tip!='') globals.gui.popupTip(hot.tip,3);});
 region.addEventListener("mouseleave", func(e) {fgcommand("set-cursor", props.Node.new({'cursor':'inherit'}));});
},

wheel: func(e){
 	foreach(hot; me.Hots) {
		if(hot.type =='wheel' and abs(e.clientX-hot.x)<hot.tol and abs(e.clientY-hot.y)<hot.tol) {
		call(me.caller.actuate[hot.action],[e.deltaY],me.caller);
		}
 	}
},

}; # skinnable class 
 

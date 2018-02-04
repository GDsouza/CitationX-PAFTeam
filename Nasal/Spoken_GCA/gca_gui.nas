###
#
# UI code starts here
#
###
	setprop("/gca/gui-version",0.2);
var ssr = nil;
var UIwindow = nil;
var STATUS = {SUCCESS:0 , FAILURE:1};

var configureGCA = func( gcaObject=nil, defValues=nil, mask=nil)  {
if(defValues==nil) defValues = {callsign:'', icao:'KSFO', rwy:'28R', safety_slope:0.0, 
					  channel:'/sim/messages/approach', interval:5.00};
if(mask==nil) mask = {};

# listing valid callsigns:
 var callsignTip = getprop("/sim/multiplay/callsign");
 var AIList = props.globals.getNode("/ai/models").getChildren( 'aircraft' );
 #~ printf("AI: %i aircrafts founded", size(AIList));
 for(var i=0; i<size(AIList); i+=1) {
	var currentCallsign = AIList[i].getNode('callsign',1).getValue();
	var tas = AIList[i].getNode('velocities',1).getNode('true-airspeed-kt',1).getValue();
	if(tas > 1) callsignTip ~= "\n"~currentCallsign; # ignore not flying ones.
 }
 
 #~ fgcommand("pause");
if( !(getprop("/sim/freeze/clock") or getprop("/sim/freeze/master")) ) {
	setprop("/sim/freeze/clock",1);
	setprop("/sim/freeze/master",1);
	}
# processing arguments:
var defaults = {callsign:getprop("/sim/multiplay/callsign"), icao: 'KSFO' , rwy:'28R'
			,safety_slope:0.0, channel:'/sim/messages/approach', interval:5.00};
foreach(var key; keys(defValues)) {
	defaults[key] = defValues[key];
	if(myDbg) printf("%s <- %s",key,defValues[key]);
	}
if(UIwindow !=nil) UIwindow.del();
var (width,height) = (240,550);
var title = 'GCA Dialog ';

UIwindow = canvas.Window.new([width,height],"dialog").set('title',title).clearFocus();

UIwindow.del = func(){
#  print("Cleaning up window:",title,"\n");
#  print("Cleaning up window:",title);
  call(canvas.Window.del, [], me);
};

# adding a canvas to the new window and setting up background colors/transparency
var myCanvas = UIwindow.createCanvas().set("background", canvas.style.getColor("bg_color"));

# creating the top-level/root group which will contain all other elements/group
var root = myCanvas.createGroup();

# create a new layout
var myLayout = canvas.VBoxLayout.new();
# assign it to the Canvas
myCanvas.setLayout(myLayout);

var setupWidgetTooltip = func(widget, tooltip) {
 widget._view._root.addEventListener("mouseover", func gui.popupTip(tooltip) );
} # setupWidgetTooltip


var setupLabeledInput = func(root, layout, input) {


var label = canvas.gui.widgets.Label.new(root, canvas.style, {wordWrap: 0}); 
var unit_suffix = sprintf(" (%s):", input.unit);
label.setText(input.text~unit_suffix);
layout.addItem(label);

var field = canvas.gui.widgets.LineEdit.new(root, canvas.style, {});
layout.addItem(field);
field.setText(sprintf(input.default_value));

if (input.focus)
field.setFocus();

setupWidgetTooltip(widget:field, tooltip: input.tooltip);
var el = field._view._root;
el.addEventListener("keypress", func (e) {

# colorize valid/invalid inputs
var color = (validationHelpers[input.validate]( field.text() ) == 0) ? [0,1,0] : [1,0,0];
field._view._root.setColorFill(color);

});
    

return field; # return to caller
} # setupLabeledInput()

var validationHelpers = {
_internalState: {airport:airportinfo(defaults.icao)},

'Callsign': func(input) {
 if (input == getprop("/sim/multiplay/callsign")) {
	#~ positionNode = "/position";
	return STATUS.SUCCESS ;
	}
 if(positionNode(input) != '/position') {
	return STATUS.SUCCESS ;
	} else {
	return STATUS.FAILURE;
	}
},

'Airport': func(input) {
var match = airportinfo(input);
if (match == nil or typeof(match) != 'ghost') return STATUS.FAILURE;
validationHelpers._internalState.airport = match; 
return STATUS.SUCCESS;;

},

'Runway': func(input) {

var runways = validationHelpers._internalState.airport.runways;
if (typeof(runways)!="hash" or !size(keys(runways))) return STATUS.FAILURE;
if (runways[input] == nil) return STATUS.FAILURE;
validationHelpers._internalState.rwy = input; 

return STATUS.SUCCESS;
},

'FinalApproach': func(input) {
if (input <3) return STATUS.FAILURE;
validationHelpers._internalState.final = input; 
return STATUS.SUCCESS;
},

'Glidepath': func(input) {
if (input <1 or input>180) return STATUS.FAILURE;
return STATUS.SUCCESS;
},

'SafetySlope': func(input) {
if (input <0 or input>180) return STATUS.FAILURE;
return STATUS.SUCCESS;
}, 

'TerrainResolution': func(input) {
if (input <0 or input>10) return STATUS.FAILURE;
return STATUS.SUCCESS;
},

'DecisionHeight': func(input) {
if (input <0) return STATUS.FAILURE;
return STATUS.SUCCESS;
},

'TouchdownOffset': func(input) {
if (input <0) return STATUS.FAILURE;
return STATUS.SUCCESS;
}, 

'TransmissionInterval': func(input) {
if (input <0 ) return STATUS.FAILURE;
return STATUS.SUCCESS;
}, 

'TransmissionProperty': func(input) {
if (getprop(input) == nil) return STATUS.FAILURE;
return STATUS.SUCCESS;
}, 

'VertGrid': func(input) {
if (input <100 or input >4000) return STATUS.FAILURE;
return STATUS.SUCCESS;
}, 

'HzGrid': func(input) {
if (input <0.1 or input >10) return STATUS.FAILURE;
return STATUS.SUCCESS;
}, 

}; # validationHelpers;


var inputs = [
{text: 'Callsign', default_value:defaults.callsign, focus:0, callback:gcaObject.setCallsign, tooltip:callsignTip, validate: 'Callsign', convert:nil, unit: 'any AI/MP callsign'},
{text: 'Airport', default_value:defaults.icao, focus:0, callback:gcaObject.setAirport, tooltip:'ICAO ID, e.g. KSFO', validate: 'Airport', convert:nil, unit:'ICAO'},
{text: 'Runway', default_value:defaults.rwy, focus:0, callback:gcaObject.setRunway, tooltip:'runway identifier, e.g. 28L', validate: 'Runway', convert:nil, unit:'rwy'},
{text: 'Touchdown Offset', default_value:'500', focus:0, callback:gcaObject.setTouchdownOffset, tooltip:'touchdown offset', validate: 'TouchdownOffset', convert:num, unit:'m'},
{text: 'Final Approach', default_value:'10.00', focus:0, callback:gcaObject.setFinalApproach, tooltip:'length of final approach leg', validate: 'FinalApproach', convert:num, unit:'nm'},
{text: 'Glidepath', default_value:'3.00', focus:0, callback:gcaObject.setGlidepath, tooltip:'glidepath in degrees, e.g. 3', validate: 'Glidepath', convert:num, unit:'degrees'},

{text: 'Safety Slope', default_value:defaults.safety_slope, focus:0, callback:gcaObject.setSafetySlope, tooltip:'safety slope in degrees', validate: 'SafetySlope', convert:num, unit:'degrees'},
{text: 'Decision Height', default_value:'200.00', focus:0, callback:gcaObject.setDecisionHeight, tooltip:'decision height (vertical offset)', validate: 'DecisionHeight', convert:num, unit:'ft'},
{text: 'Terrain Resolution', default_value:'0.25', focus:0, callback:gcaObject.setTerrainResolution, tooltip:'granularity/resolution of the terrain sampling', validate: 'TerrainResolution', convert:num, unit:'nm'},
{text: 'Horizontal Grid', default_value:'1.00', focus:0, callback:gcaObject.setHzGrid, tooltip:'horizontal grid resolution in Radar screen', validate: 'HzGrid', convert:num, unit:'nm/div'},
{text: 'Vertical Grid', default_value:'1000', focus:0, callback:gcaObject.setVertGrid, tooltip:'vertical grid resolution in Radar screen', validate: 'VertGrid', convert:num, unit:'feet/div'},

{text: 'Transmission channel', default_value:defaults.channel, focus:0, callback:gcaObject.setTransmissionChannel, tooltip:'property to use for transmissions. For example: /sim/multiplay/chat or /sim/sound/voices/approach', validate: 'TransmissionProperty', convert:nil, unit:'property'},
{text: 'Transmission interval', default_value:defaults.interval, focus:0, callback:gcaObject.setTransmissionInterval, tooltip:'Controller/timer resolution', validate: 'TransmissionInterval', convert:num, unit:'secs'},
# Warning: 'Transmission interval' must be the last one, since it launches the timer !!
]; # input fields

for(var i=0; i<size(inputs); i+=1) {
 if(!contains(mask, inputs[i].text)){
   inputs[i].widget = setupLabeledInput(root, myLayout, inputs[i]);
 }
}
var validateFields = func() {
var ret = STATUS.SUCCESS; # by default
foreach(var f; inputs) {
 if(contains(mask, f.text)) continue;
 var result = validationHelpers[f.validate] ( f.widget.text() );
 if (result == STATUS.FAILURE) {

canvas.MessageBox.critical(
  "Validation error",
  "Error validating "~f.text,
  cb = nil,
  buttons = canvas.MessageBox.Ok
); # MessageBox

ret = STATUS.FAILURE;
 } # error handling
} # foreach
return ret; # all validations passed
} # validateFields()


###
# global stuff
#

var gcaRunning = 0;

var toggleFields = func(enabled) {
call(gcaObject.setRoot, [positionNode(inputs[0].widget.text())], gcaObject );
foreach(var i; inputs) {
  if(!contains(mask, i.text))  i.widget.setEnabled(enabled);
}
}

var createPar = func () {
call(gcaObject.setRoot, [positionNode(inputs[0].widget.text())], gcaObject );
for(var i=0; i<size(inputs)-1; i+=1) { # all except "Transmission Interval"
var value = (contains(mask, inputs[i].text)) ? inputs[i].default_value : inputs[i].widget.text();
if (inputs[i].convert != nil and typeof(inputs[i].convert)=='func') {
var converted = inputs[i].convert( value );
}
call(inputs[i].callback, [value], gcaObject );
} # for

	if(Par !=nil) Par.wndow.del();
	gcaObject.updatePosition();
	gcaObject.updateStage();
	Par = PAR(icao:gcaObject.destination.airport, rwy:gcaObject.destination.runway, final:gcaObject.destination.final);
	Par.wndow.move(500,0);
	Par.setPositionNode(gcaObject.root);
	Par.setGrid(gcaObject.HzGrid, gcaObject.VertGrid);
	Par.setOffset(gcaObject.destination.offset);
	Par.setSlope(gcaObject.destination.glidepath);
} # createPar

var buildCGA = func() {
if(Par == nil)	createPar();
# Now call "Transmission Interval", launching the timer:	
call(inputs[-1].callback, [num(inputs[-1].widget.text())], gcaObject );

fgcommand("pause");
	UIwindow.clearFocus();
	UIwindow.del();
#print("demo starts");

} # buildCGA

var toggleGCA = func() {
 if (gcaRunning) {
	gcaObject.stop();
	gcaRunning = 0;
	toggleFields(!gcaRunning); # set editable
	return;
 }
 if (!gcaRunning and validateFields()==STATUS.SUCCESS) {
	gcaRunning = 1;
	toggleFields(!gcaRunning); # set readonly
	buildCGA();
	return;
 }
} # toggleGCA()

var button = canvas.gui.widgets.Button.new(root, canvas.style, {})
	.setText("Start/Stop")
	.setFixedSize(75, 25)
	.listen("clicked", toggleGCA);

var apply = canvas.gui.widgets.Button.new(root, canvas.style, {})
	.setText("Apply")
	.setFixedSize(55, 25)
	.listen("clicked", createPar);

if (gcaRunning) Pause();
setupWidgetTooltip(widget:button, tooltip: "toggle GCA on/off");
setupWidgetTooltip(widget:apply, tooltip: "view Par screen");
myLayout.addItem(apply);
myLayout.addItem(button);

}; # configureGCA();

var positionNode = func(callsign) { # returns <position_Path> if matches, or <'/position'> if not.
 var AIList = props.globals.getNode("/ai/models").getChildren( 'aircraft' );
 for(var i=0; i<size(AIList); i+=1) {
	var AIcs = AIList[i].getNode('callsign',1).getValue();
	if (AIcs == callsign) return sprintf('/ai/models/aircraft[%i]/position',i) ;
 }
 return '/position';
 }


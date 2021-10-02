var Radio = gui.Dialog.new("/sim/gui/dialogs/radios/dialog",
        "Systems/tranceivers.xml");
var ap_settings = gui.Dialog.new("/sim/gui/dialogs/autopilot/dialog",
        "Systems/autopilot-dlg.xml");
var options = gui.Dialog.new("/sim/gui/dialogs/options/dialog",
        "Systems/options.xml");

#gui.menuBind("radio", "dialogs.Radio.open()");
gui.menuBind("autopilot-settings", "dialogs.ap_settings.open()");

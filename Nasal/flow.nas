### Aircraft/CitationX/Nasal/Flow.nas
#
# Concepts:
#
#           | Electric | Hydraulic / Pneumatic / Fuel
# ----------------------------------------------------------------
# Potential | voltage  | pressure
# Intensity | current  | flow
#
# Then there are named Components, which may have any number of
# Inputs and zero or one Output (although many Inputs may be
# connected to this one Output).
#
# Then there are unidirectional Connections. Each of them connects one
# Output to one Input.
#
# Following predefined Components are provided:
#  + Battery
#  + Supply
#  + Switch
#  + Circuit Breaker
#  + Bus
#  + Actuator
#  + OnOffOutput
#  + LinearOutput
#
# Each device must be able to:
#  - Compute intensities (flow) on each of the inputs, given potentials on all
#    inputs.
#  - Update controlled properties and compute the new potential of the output,
#    given current potential and total intensity flowing out of the output,
#    and the computation time step.
# This is implemented as the update method.
#
# The system is defined in an XML file, see ... for examples.
#
# There may be more that one instance of FlowSystem present, for example for the
# electrical, hydraulic and bleed air stuff.
#
# Author: Szymon Acedanski ; Rev : C. Le Moigne (clm76) - 2019
#

#### Variables ###
var charge = nil;
var charging_intensity = nil;
var charging_potential = nil;
var chosen = nil;
var chosen_potential = nil;
var cmd = nil;
var cmd_property = nil;
var factor = nil;
var input = nil;
var input_intensities = nil;
var input_intensity = nil;
var input_value = nil;
var inputs = nil;
var inputs_by_component = nil;
var input_tripped = nil;
var intensities_by_component = nil;
var intensity = nil;
var name = nil;
var on = nil;
var output_property = nil;
var output_value_type = nil;
var pos = nil;
var pos_property = nil;
var potential = nil;
var source = nil;
var state_root = nil;
var total_intensity = nil;
var trippedNode = nil;

### Functions ###
var _single_input = func(inputs) {
  if (size(inputs) > 1) {
         die("More than one input connected to single-input component");
  }
  if (size(inputs) == 0) return nil;
  return inputs[0];
};

var _nonnil = func {
  foreach(var a; arg) {
    if (a != nil) return a;
  }
  return nil;
};

var _clip = func(value, min = 0.0, max = 1.0) {
  if (value < min) return min;
  else if (value > max) return max;
  else return value;
};

var Connection = {
  new : func(system, state_root, from, to) {
    m = { parents : [Connection] };
    m.from = from;
    m.to = to;
    return m;
  }
};

var Component = {
  new : func(system, name, component_node, state_root, has_output = 0) {
    m = { parents : [Component] };
    m.system = system;
    m.name = name;
    m.has_output = has_output;
    if (has_output) {
      m.output_potential_node = state_root.initNode(
         name ~ "-" ~ system.potential_unit, 0, "DOUBLE");
    }
    m.intensity_node = state_root.initNode(
         name ~ "-" ~ system.intensity_unit, 0, "DOUBLE");
    m.enabled_condition_node = component_node.getNode("condition");
    return m;
  },

  is_enabled : func() {
    return props.condition(me.enabled_condition_node);
  },

  get_potential : func() {
    if (!me.has_output) return 0;
    return me.output_potential_node.getValue();
  },

  set_potential : func(value) {
    if (!me.has_output) {
      die("Setting potential of a component without outputs: " ~ me.name);
    }
    me.output_potential_node.setDoubleValue(value);
  },

  get_intensity : func() {
    return me.intensity_node.getValue();
  },
  set_intensity : func(value) {
    me.intensity_node.setDoubleValue(value);
  },

  update : func(dt, input_potentials) {
    # input_potentials is a hash which maps input component names
    # to their current potentials. The function should return
    # a hash mapping the same names to the intensities consumed from
    # these sources. If the component has output, this function
    # should also compute the output potential and set it using
    # me.set_potential().
    die("update_state must be implemented in all subclasses");
  }
};

var Battery = {
  new : func(system, name, component_node, state_root) {
    m = { parents : [Battery, Component.new(system, name, component_node, state_root, 1)] };

    m.nominal_potential = _nonnil(component_node.getValue("nominal-" ~ system.potential_unit), 24.0);
    m.low_potential = _nonnil(component_node.getValue("low-" ~ system.potential_unit), m.nominal_potential * 0.8);
    m.full_capacity = _nonnil(component_node.getValue("capacity-" ~ system.intensity_unit ~ "-seconds"), 144000);
    m.charging_constant = _nonnil(component_node.getValue("charging-constant"), 0.2);

    # Normally the battery is charged when the input potential is above
    # the battery potential. But this may be overridden by specifying
    # charging_potential.
    m.charging_potential = component_node.getValue("charging-" ~ system.potential_unit);

    # Charge when the potential drops below low_potential.
    m.low_charge = 0.1;

    # Converter efficiency when in charging mode.
    m.converter_efficiency = 0.8;

    m.charge_node = state_root.initNode(name ~ "-charge-norm", 1.0, "DOUBLE");

    return m;
  },

  update : func(dt, inputs) {
    if (!me.is_enabled()) {
      me.set_potential(0);
      return {};
    }

    charge = me.charge_node.getValue();
    potential = charge < me.low_charge ?
      (me.low_potential * charge / me.low_charge) :
      (me.low_potential + (charge - me.low_charge)
             / (1 - me.low_charge)
             * (me.nominal_potential - me.low_potential));
    me.set_potential(potential);

    charging_potential = _nonnil(me.charging_potential, potential);

    input = _single_input(inputs);
    input_intensities = {};
    if (input != nil and input.get_potential() > charging_potential) {
      # Constant-current charging at me.charging_constant C and
      # also the input supplies power to the load.
      input_intensity = me.get_intensity();
      if (charge < 1.0) {
        charging_intensity = me.full_capacity / 3600 * me.charging_constant;
        charge += charging_intensity * dt / me.full_capacity;
        me.charge_node.setDoubleValue(charge);
        input_intensity += charging_intensity;
      }
      input_intensity *= charging_potential / input.get_potential();
      input_intensity /= me.converter_efficiency;
      input_intensities[input.name] = input_intensity;
      return input_intensities;
    } else {
      # Supplying load from the battery.
      charge -= me.get_intensity() * dt / me.full_capacity;
      me.charge_node.setDoubleValue(charge);
      return {};
    }
  }
};

var Supply = {
  new : func(system, name, component_node, state_root) {
    m = { parents : [Supply, Component.new(system, name, component_node, state_root, 1)] };

    m.nominal_intensity = _nonnil(component_node.getValue("nominal-" ~ system.intensity_unit), 300.0);
    m.overload_intensity = _nonnil(component_node.getValue("overload-" ~ system.intensity_unit),
           m.nominal_intensity * 1.5);
    m.nominal_potential = _nonnil(component_node.getValue( "nominal-" ~ system.potential_unit), 26.0);

    m.input_property = component_node.getValue("input");
    m.input_node = m.input_property == nil ? nil : props.globals.getNode(m.input_property);
    m.nominal_input = _nonnil(component_node.getValue("nominal-input-value"), 1.0);
    m.threshold_input = _nonnil(component_node.getValue("threshold-input-value"), 0.0);

    m.potential_norm_node = state_root.initNode(name ~ "-" ~ system.potential_unit ~ "-norm",
           0, "DOUBLE");

    return m;
  },

  update : func(dt, inputs) {
    if (size(inputs) > 0) die("Supply must not have inputs: " ~ me.name);
    if (!me.is_enabled()) {
      me.set_potential(0);
      me.potential_norm_node.setDoubleValue(0);
      return {};
    }

    input_value = (me.input_node == nil) ? me.nominal_input
           : me.input_node.getValue();
    factor = _clip((input_value - me.threshold_input)
           / (me.nominal_input - me.threshold_input));
    if (factor > 0) {
      # We simulate overload by reducing output potential linearly when
      # intensity is between nominal_intensity and overload_intensity.
      # If we already have some factor, we scale the output intensity
      # so that a 30%-good supply will have also 30%-reduced nominal
      # intensity.
      factor *= _clip((me.overload_intensity - me.get_intensity() / factor)
             / (me.overload_intensity - me.nominal_intensity));
    }
    me.potential_norm_node.setDoubleValue(factor);
    me.set_potential(me.nominal_potential * factor);
    return {};
  }
};

var Switch = {
  new : func(system, name, component_node, state_root) {
    m = { parents : [Switch, Component.new(system, name, component_node, state_root, 1)] };
    return m;
  },

  update : func(dt, inputs) {
    input = _single_input(inputs);
#print("275 input : ",input.name," enabled = ",me.is_enabled());
    if (input == nil or !me.is_enabled()) {
      me.set_potential(0);
      return {};
    }

    me.set_potential(input.get_potential());
    input_intensities = {};
    input_intensities[input.name] = me.get_intensity();
    return input_intensities;
  }
};

var CircuitBreaker = {
  new : func(system, name, component_node, state_root) {
    m = { parents : [CircuitBreaker, Switch.new(system, name, component_node, state_root)] };
    m.threshold = component_node.getValue("threshold-" ~ system.intensity_unit);
    m.tripped_node = state_root.initNode("cb/"~name ~ "-tripped", 0, "BOOL");
    return m;
  },

  update : func(dt, inputs) {
    if (me.get_intensity() > me.threshold) me.tripped_node.setBoolValue(1);
    return me.parents[1].update(dt, inputs);
  }
};

var Bus = {
  new : func(system, name, component_node, state_root) {
    m = { parents : [Bus, Component.new(system, name, component_node, state_root, 1)] };
    m.source_node = state_root.initNode(name ~ "-source", "", "STRING");
    m.nominal_potential = _nonnil(component_node.getValue("nominal-" ~ system.potential_unit), 1.0e10);
    return m;
  },

  choose_source : func(inputs) {
    # By default the first input with the potential >= the nominal
    # potential; if none, then the input with the highest potential is
    # chosen.
    if (!me.is_enabled()) return nil;
    chosen = nil;
    chosen_potential = 0;
    foreach (var input; inputs) {
      potential = input.get_potential();
      if (potential > me.nominal_potential) potential = me.nominal_potential;
      if (potential > chosen_potential) {
        chosen = input.name;
        chosen_potential = potential;
      }
    }
    return chosen;
  },

  update : func(dt, inputs) {
    source = me.choose_source(inputs);
    if (source == nil) {
      me.set_potential(0);
      me.source_node.setValue("");
      return {};
    }
    me.source_node.setValue(source);
    input_intensities = {};
    foreach (var input; inputs) {
      name = input.name;
      if (name == source) {
             input_intensities[name] = me.get_intensity();
             me.set_potential(input.get_potential());
      }
    }
    return input_intensities;
  }
};

var Output = {
  new : func(system, name, component_node, state_root) {
    m = { parents : [Output, Component.new(system, name, component_node, state_root, 0)] };

    m.on_intensity = _nonnil(component_node.getValue(system.intensity_unit),
           system.defaults_node.getValue("output-" ~ system.intensity_unit),
           1.0);

    m.on_value = component_node.getValue("on-value");
    if (m.on_value == nil) m.on_value = 1;
    m.off_value = component_node.getValue("off-value");
    if (m.off_value == nil) m.off_value = 0;
    output_value_type = component_node.getType("on-value") or "BOOL";
    output_property = component_node.getValue("output");
    m.output_node = output_property
       ? props.globals.initNode(output_property, m.off_value, output_value_type)
       : state_root.initNode("outputs/" ~ name, m.off_value, output_value_type);
    m.output_type = component_node.getValue("output-type")
       or system.defaults_node.getValue("output-type") or "value";

    return m;
  },

  update : func(dt, inputs) {
    input = _single_input(inputs);
    on = (input == nil or !me.is_enabled()) ? 0 : me.compute_on_factor(input);
    if (me.output_type == "value") {
      # We assign the passed values directly to allow discrete outputs
      # to specify non-double on/off values.
      if (on == 1) me.output_node.setValue(me.on_value); 
      else if (on == 0) me.output_node.setValue(me.off_value); 
      else me.output_node.setDoubleValue(
            on * me.on_value + (1 - on) * me.off_value);
    } else if (me.output_type == me.system.potential_unit)
       me.output_node.setDoubleValue(on > 0 ? input.get_potential() : 0);
    else die("Unknown output_type: " ~ me.output_type);
    input_intensities = {};
    if (input != nil) input_intensities[input.name] = on * me.on_intensity;
    return input_intensities;
  },

  compute_on_factor : func(input) {
         die("compute_on_factor must be implemented in all subclasses");
  }
};

var LinearOutput = {
  new : func(system, name, component_node, state_root) {
    m = { parents : [LinearOutput, Output.new(system, name, component_node, state_root)] };
    m.nominal_intensity = component_node.getValue("nominal-" ~ system.intensity_unit)
       or system.defaults_node.getValue("output-nominal-" ~ system.intensity_unit)
       or 1.0;
    m.threshold_potential = component_node.getValue("threshold-" ~ system.potential_unit)
       or system.defaults_node.getValue("output-threshold-" ~ system.potential_unit)
       or 0.0;
    m.nominal_potential = component_node.getValue("nominal-" ~ system.potential_unit)
       or system.defaults_node.getValue("output-nominal-" ~ system.potential_unit)
       or 24.0;

    return m;
  },

  compute_on_factor : func(input) {
    on = (input.get_potential() - me.threshold_potential)
           / (me.nominal_potential - me.threshold_potential);
    if (on > 1.0) on = 1.0;
    else if (on < 0.0) on = 0.0;
    return on;
  }
};

var Actuator = {
  new : func(system, name, component_node, state_root) {
    m = { parents : [Actuator, LinearOutput.new(system, name, component_node, state_root)] };

    cmd_property = component_node.getValue("cmd");
    if (cmd_property == nil) die("Actuator must have <cmd> specified: " ~ name);

    m.cmd_node = props.globals.getNode(cmd_property);
    if (m.cmd_node == nil) die("Invalid <cmd> for '" ~ name ~ "': " ~ cmd_property);

    pos_property = component_node.getValue("pos");
    if (pos_property == nil) die("Actuator must have <pos> specified: " ~ name);

    m.pos_node = props.globals.getNode(pos_property);
    if (m.pos_node == nil) die("Invalid <pos> for '" ~ name ~ "': " ~ pos_property);

    m.epsilon = _nonnil(component_node.getValue("epsilon"), 0);
    return m;
  },

  compute_on_factor : func(input) {
    pos = me.pos_node.getValue();
    cmd = me.cmd_node.getValue();
    if (pos == nil or pos == "" or cmd == nil or cmd == ""
                   or abs(pos - cmd) < me.epsilon) {
     return 0.0;
    }
    return me.parents[1].compute_on_factor(input);
  }
};

var OnOffOutput = {
  new : func(system, name, component_node, state_root) {
    m = { parents : [OnOffOutput, Output.new(system, name, component_node, state_root, 0)] };
    m.threshold_potential = component_node.getValue("threshold-" ~ system.potential_unit)
       or system.defaults_node.getValue("output-threshold-" ~ system.potential_unit)
       or 0.0;
    return m;
  },

  compute_on_factor : func(input) {
    return input.get_potential() >= me.threshold_potential;
  }
};

var FlowSystem = {
  new : func(path, extra_kinds=nil,
                 potential_unit="volts", intensity_unit="amps") {
    m = { parents : [FlowSystem] };
    #print("Initializing system ", path, "...");

    m.potential_unit = potential_unit;
    m.intensity_unit = intensity_unit;

    var root = props.globals.getNode(path);
    var definition_root = root.getNode("definition");
    state_root = root;
    var kinds = {};
    foreach (var k; keys(DEFAULT_KINDS)) kinds[k] = DEFAULT_KINDS[k];
    if (extra_kinds != nil) {
      foreach (var k; keys(extra_kinds)) kinds[k] = extra_kinds[k];
    }

    m.defaults_node = definition_root.getNode("defaults");

    m.components = {};
    m.connections = [];
    m.load_system(definition_root, state_root, kinds);

    #print("done.");

    return m;
  },

  load_system : func(definition_root, state_root, kinds) {
    var component_nodes = definition_root.getChildren("component");
    foreach (var component_node; component_nodes) {
      name = component_node.getValue("name");
      if (name == nil) die("Unnamed component");
      #print("  " ~ name);
      var kind = component_node.getValue("kind");
      if (kind == nil) die("No kind specified for component: " ~ name);

      var class = kinds[kind];
      var instance = class.new(me, name, component_node, state_root);
      me.components[name] = instance;
    }
    var connections_defs = definition_root.getChildren("connections");
    var connected_components = {};
    foreach(var connections_def; connections_defs) {
      foreach(var line; split("\n", connections_def.getValue())) {
        line = string.trim(line);
        foreach(var def; split(" ", line)) {
          if (!def) continue;
          var prev = nil;
          foreach(var token; split(">", def)) {
            var component = me.components[token];
            if (component == nil) {
              die("Unknown component '" ~ token ~ "' referenced in connections: " ~ line);
            }
            if (prev != nil) {
              var connection = Connection.new(me, state_root, prev, component);
              append(me.connections, connection);
              connected_components[prev.name] = 1;
              connected_components[component.name] = 1;
            }
            prev = component;
          }
        }
      }
    }

    # Check if all components are connected somewhere.
    foreach(var name; keys(me.components)) {
      if (!connected_components[name]) {
             die("Unconnected component, this is certainly a bug "
                     ~ "in the configuration XML: " ~ name);
      }
    }
  },

  update : func(dt) {
    inputs_by_component = {};
    intensities_by_component = {};
    foreach(var component; values(me.components)) {
      inputs_by_component[component.name] = [];
      if (component.has_output) intensities_by_component[component.name] = 0;
    }
    foreach(var connection; me.connections) {
      append(inputs_by_component[connection.to.name], connection.from);
    }
    foreach(var component; values(me.components)) {
      inputs = inputs_by_component[component.name];
      input_intensities = component.update(dt, inputs);
      total_intensity = 0;
      foreach(var input_name; keys(input_intensities)) {
             intensity = input_intensities[input_name];
             intensities_by_component[input_name] += intensity;
             total_intensity += intensity;
      }
      if (!component.has_output) component.set_intensity(total_intensity);
    }
    foreach(var component; values(me.components)) {
      if (component.has_output) component.set_intensity(
            intensities_by_component[component.name]);
    }
  },

  start_updates : func() {
    var update_fn = func {
      me.update(getprop("sim/time/delta-sec"));
      settimer(update_fn, 0.2);
    }
    settimer(update_fn, 0);
  }
};

DEFAULT_KINDS = {
  battery: Battery,
  supply: Supply,
  switch: Switch,
  cb: CircuitBreaker,
  bus: Bus,
  onoffoutput: OnOffOutput,
  linearoutput: LinearOutput,
  actuator: Actuator,
};


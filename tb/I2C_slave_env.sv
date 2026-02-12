`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_slave_env extends uvm_env;
  `uvm_component_utils(I2C_slave_env)

  // Sub-components
  I2C_slave_agent       agt;
  I2C_slave_scoreboard  sb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agt = I2C_slave_agent      ::type_id::create("agt", this);
    sb  = I2C_slave_scoreboard ::type_id::create("sb",  this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Monitor transactions -> Scoreboard
    // agent.ap is re-exported from mon.ap in your agent
    agt.ap.connect(sb.mon_ap);
  endfunction

endclass

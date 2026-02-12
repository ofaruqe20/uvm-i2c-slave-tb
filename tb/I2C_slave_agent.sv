`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_slave_agent extends uvm_agent;
  `uvm_component_utils(I2C_slave_agent)

  I2C_slave_sequencer  seqr;
  I2C_slave_driver     drv;
  I2C_slave_monitor    mon;

  // Re-export monitor transactions to env/scoreboard
  uvm_analysis_port #(I2C_slave_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Monitor is always present (active or passive agent)
    mon  = I2C_slave_monitor   ::type_id::create("mon", this);

    // If you are using an ACTIVE agent (master BFM driving the bus)
    // keep these enabled. If you later support passive mode, you can
    // conditionalize creation with is_active.
    seqr = I2C_slave_sequencer ::type_id::create("seqr", this);
    drv  = I2C_slave_driver    ::type_id::create("drv",  this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Driver <-> Sequencer connection
    drv.seq_item_port.connect(seqr.seq_item_export);

    // Monitor -> Agent analysis port (so env can connect scoreboard easily)
    mon.ap.connect(ap);
  endfunction

endclass

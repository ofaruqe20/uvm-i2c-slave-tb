`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_slave_test extends uvm_test;
  `uvm_component_utils(I2C_slave_test)

  I2C_slave_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = I2C_slave_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    I2C_slave_seq seq;   // your sequence class name
    phase.raise_objection(this);

    seq = I2C_slave_seq::type_id::create("seq");
    seq.start(env.agt.seqr);

    phase.drop_objection(this);
  endtask

endclass


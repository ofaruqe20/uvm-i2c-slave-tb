`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_slave_scoreboard extends uvm_component;
  `uvm_component_utils(I2C_slave_scoreboard)

  // Receive transactions from monitor
  uvm_analysis_imp #(I2C_slave_txn, I2C_slave_scoreboard) mon_ap;

  // Golden register model (256 x 16-bit)
  bit [15:0] reg_model [bit [7:0]];

  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction

  // Called automatically when monitor does ap.write(txn)
  virtual function void write(I2C_slave_txn tx);
    bit [7:0] r;

    r = tx.reg_addr;

    // WRITE transaction (current implementation)
    if (tx.w_data !== 'x) begin
      reg_model[r] = tx.w_data;

      `uvm_info("SB",
        $sformatf("WRITE: reg[0x%02h] <= 0x%04h",
                  r, tx.w_data),
        UVM_MEDIUM)
    end
  endfunction
endclass

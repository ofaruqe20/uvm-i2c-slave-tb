`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_slave_sequencer extends uvm_sequencer #(I2C_slave_txn);
	`uvm_component_utils (I2C_slave_sequencer)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
endclass
	


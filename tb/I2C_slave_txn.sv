`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_slave_txn extends uvm_sequence_item;
	// chip address
	rand bit [6:0] chip_addr;
	
	// register address
	rand bit [7:0] reg_addr;

	// Data to write 
	rand bit [15:0] w_data;

	//Data to be read, fill by Monitor
	bit [15:0] r_data;
	

	//---Constraints (Optional but realistics)
	constraint chip_addr_range {chip_addr inside {[7'h08:7'h67]};}
	
	`uvm_object_utils_begin (I2C_slave_txn)
		`uvm_field_int(chip_addr, UVM_ALL_ON)
		`uvm_field_int(reg_addr, UVM_ALL_ON)
		`uvm_field_int(w_data, UVM_ALL_ON)
		`uvm_field_int(r_data, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "I2C_slave_txn");
		super.new(name);
	endfunction
	

	function string convert2string();
		return $sformatf("chip=0x%02h reg=0x%02h w_data=0x%04h r_data=0x%04h", chip_addr, reg_addr, w_data, r_data);
	endfunction
endclass


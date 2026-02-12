`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_slave_seq extends uvm_sequence #(I2C_slave_txn);
	`uvm_object_utils (I2C_slave_seq)

	int unsigned num_times = 20;

	function new(string name = "I2C_slave_seq");
		super.new(name);
	endfunction


	virtual task body();
	I2C_slave_txn tx;


	repeat(num_times) begin
		tx = I2C_slave_txn::type_id::create("tx");

		start_item(tx);
	//keep chip_add fixed
	tx.chip_addr = 7'h22;
	
	//Randomize what exists in in the transaction
	if(!tx.randomize() with {chip_addr == 7'h22;}) begin
		`uvm_error(get_type_name(), "Write txn randomize() failed")
	end

	finish_item(tx);

	`uvm_info(get_type_name(),
		$sformatf("WRITE: chip=0x%0h reg=0x%0h w_data=0x%0h",
			tx.chip_addr, tx.reg_addr, tx.w_data),
		UVM_LOW)

	end
   endtask
endclass

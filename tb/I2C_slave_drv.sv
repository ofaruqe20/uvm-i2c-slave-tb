`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_slave_driver extends uvm_driver #(I2C_slave_txn);
	`uvm_component_utils (I2C_slave_driver)

	// virtual interface handle
	virtual I2C_if vif;


	//timing knob
	time t_half = 100ns; //

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);


	if(!uvm_config_db#(virtual I2C_if)::get(this, "", "vif", vif))
		`uvm_fatal("DRV", "Failed to get virtual interface 'vif'")
	endfunction

 	task run_phase(uvm_phase phase);
	I2C_slave_txn tx;
	
	// Optional: Initialize bus to idle
	drive_bus_idle();

	forever begin
	seq_item_port.get_next_item(tx);   //block until sequence provides item

	`uvm_info("DRV",
		$sformatf("Driving WRITE: chip=0x%0h reg=0x%0h w_data=0x%0h",
			tx.chip_addr, tx.reg_addr, tx.w_data), UVM_LOW)

	drive_write(tx);
	
	seq_item_port.item_done();

	end
	endtask


	task drive_bus_idle();
		// I2C_idle: SCL=1, SDA=1 both released
		vif.m_scl_oen <= 1'b1;
		vif.m_sda_oen <= 1'b1;
	endtask

	task sda_release();
		vif.m_sda_oen <= 1'b1;
	endtask

	task sda_low();
		vif.m_sda_out <= 1'b0;
		vif.m_sda_oen <= 1'b0;
	endtask

	task scl_release();
		vif.m_scl_oen <= 1'b1;
	endtask


	task scl_low ();
		vif.m_scl_out <= 1'b0;
		vif.m_scl_oen <= 1'b0;
	endtask

	task i2c_start();
		sda_release();
		scl_release();
		#(t_half);

		//SDA 1>0 while SCL high
		sda_low();
		#(t_half);

		//Then pull clock low to start transfer
		scl_low();
		#(t_half);

	endtask

	task i2c_stop();
		sda_low();
		scl_low();
		#(t_half);

		//SDA 1>0 while SCL high
		scl_release();
		#(t_half);

		//Then pull clock low to start transfer
		sda_release();
		#(t_half);

	endtask


	task send_bit (bit b);
		scl_low();
		if (b == 1'b0) 
			sda_low();
		else 
			sda_release();
		#(t_half);
		scl_release();
		#(t_half);
		#(t_half);
		
		scl_low();

		#(t_half);
		sda_release();
	endtask


	task read_ack (output bit ack);
		scl_low();
		sda_release();

		#(t_half);
		scl_release();
		#(t_half);
		ack = (vif.sda_in == 1'b0);
		#(t_half)
		scl_low();
		#(t_half);
		sda_low();
	endtask

	task send_byte (input byte data, output bit ack);
		for (int i=7; i>=0; i--)
		begin
			send_bit(data[i]);
		end
		read_ack(ack);
	endtask


	task drive_write(I2C_slave_txn tx);
  		bit ack;

  		i2c_start();

  		// 1) Address + W
 		 send_byte({tx.chip_addr, 1'b0}, ack);
 		 if (!ack) `uvm_error("DRV", $sformatf("NACK on address 0x%0h", tx.chip_addr))

 		 // 2) Register address
  		send_byte(tx.reg_addr, ack);
 		 if (!ack) `uvm_error("DRV", $sformatf("NACK on reg_addr 0x%0h", tx.reg_addr))

 		 // 3) Data bytes (MSB then LSB)
 		 send_byte(tx.w_data[15:8], ack);
 		 if (!ack) `uvm_error("DRV", $sformatf("NACK on data MSB 0x%0h", tx.w_data[15:8]))

  		send_byte(tx.w_data[7:0], ack);
 		 if (!ack) `uvm_error("DRV", $sformatf("NACK on data LSB 0x%0h", tx.w_data[7:0]))

  		i2c_stop();

  		// return bus to idle
  		drive_bus_idle();
	endtask		


endclass
	
	



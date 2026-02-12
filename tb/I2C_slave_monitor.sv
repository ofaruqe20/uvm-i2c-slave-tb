`include "uvm_macros.svh"
import uvm_pkg::*;

class I2C_slave_monitor extends uvm_monitor;
  `uvm_component_utils(I2C_slave_monitor)

  // Virtual interface handle
  virtual I2C_if vif;

  // Analysis port to publish observed transactions
  uvm_analysis_port #(I2C_slave_txn) ap;

  // No defaults (as you requested)
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual I2C_if)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Failed to get virtual interface 'vif'")
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      monitor_write_transfer();
    end
  endtask

  // -----------------------------
  // I2C protocol helper tasks
  // -----------------------------

  // START: SDA 1->0 while SCL high
  task wait_for_start();
    wait (vif.scl_in == 1'b1);
    @(negedge vif.sda_in iff (vif.scl_in == 1'b1));
  endtask

  // STOP: SDA 0->1 while SCL high
  task wait_for_stop();
    wait (vif.scl_in == 1'b1);
    @(posedge vif.sda_in iff (vif.scl_in == 1'b1));
  endtask

  // Sample 8 bits on posedge SCL (MSB first)
  task automatic sample_byte(output bit [7:0] b);
    b = 8'h00;
    for (int i = 7; i >= 0; i--) begin
      @(posedge vif.scl_in);
      b[i] = vif.sda_in;
    end
  endtask

  // Sample ACK/NACK on the 9th clock
  // ACK = SDA low (0), NACK = SDA high (1)
  task automatic sample_ack(output bit ack);
    @(posedge vif.scl_in);
    ack = (vif.sda_in == 1'b0); // 1 means ACK received
  endtask

  // -----------------------------
  // Main monitor (WRITE only)
  // Matches your driver exactly:
  // START -> {chip_addr,0} -> reg -> data[15:8] -> data[7:0] -> STOP
  // -----------------------------
  task monitor_write_transfer();
    I2C_slave_txn tx;
    bit [7:0] addr_rw;
    bit [7:0] reg_b;
    bit [7:0] d_msb, d_lsb;
    bit ack;

    // 1) Wait for START
    wait_for_start();
    `uvm_info("MON", "START detected", UVM_HIGH)

    tx = I2C_slave_txn::type_id::create("tx");
    tx.r_data = '0; // monitor doesn't fill read data yet (write-only path)

    // 2) Address + R/W
    sample_byte(addr_rw);
    tx.chip_addr = addr_rw[7:1];

    // Check R/W bit: we expect write (0) because your driver only writes
    if (addr_rw[0] !== 1'b0) begin
      `uvm_warning("MON", $sformatf("Observed R/W=1 (READ) for addr byte 0x%02h; this monitor currently decodes WRITE only.", addr_rw))
      // Still wait for STOP and publish what we saw
      wait_for_stop();
      ap.write(tx);
      return;
    end

    // ACK after address
    sample_ack(ack);
    if (!ack) begin
      `uvm_info("MON", $sformatf("NACK after address (chip=0x%02h). Ending transfer.", tx.chip_addr), UVM_MEDIUM)
      wait_for_stop();
      ap.write(tx);
      return;
    end

    // 3) Register address
    sample_byte(reg_b);
    tx.reg_addr = reg_b;

    sample_ack(ack);
    if (!ack) begin
      `uvm_info("MON", $sformatf("NACK after reg_addr (reg=0x%02h). Ending transfer.", tx.reg_addr), UVM_MEDIUM)
      wait_for_stop();
      ap.write(tx);
      return;
    end

    // 4) Data MSB then LSB
    sample_byte(d_msb);
    sample_ack(ack);
    if (!ack) begin
      `uvm_info("MON", $sformatf("NACK after data MSB (0x%02h). Ending transfer.", d_msb), UVM_MEDIUM)
      tx.w_data = {d_msb, 8'h00};
      wait_for_stop();
      ap.write(tx);
      return;
    end

    sample_byte(d_lsb);
    sample_ack(ack);
    tx.w_data = {d_msb, d_lsb};

    // 5) STOP
    wait_for_stop();
    `uvm_info("MON", "STOP detected", UVM_HIGH)

    // Publish txn
    ap.write(tx);

    `uvm_info("MON",
      $sformatf("Observed WRITE txn: %s", tx.convert2string()),
      UVM_MEDIUM)

  endtask

endclass


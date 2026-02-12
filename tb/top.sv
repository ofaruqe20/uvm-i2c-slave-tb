module top;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  logic clk, reset;

  // TB clock/reset (independent of I2C t_half)
  initial clk = 1'b0;
  always #5 clk = ~clk;   // 100 MHz

  initial begin
    reset = 1'b1;
    #50;
    reset = 1'b0;
    #10
    reset = 1'b1;
  end

  // Instantiate interface
  I2C_if #(
    .DATA_BYTES(2),
    .REG_ADDR_WIDTH(8)
  ) i2c_if (
    .clk   (clk),
    .reset (reset)
  );

  // IMPORTANT: pullups for open-drain bus
  pullup(i2c_if.SDA);
  pullup(i2c_if.SCL);

  // Instantiate DUT and connect via the interface signals
  I2C_slave #(
    .ADDR_BYTES(1),
    .DATA_BYTES(2)
  ) dut (
    .clk       (clk),
    .reset     (reset),

    // config inputs
    .enable    (i2c_if.enable),
    .open_drain(i2c_if.open_drain),
    .data_size (i2c_if.data_size),

    // I2C directional pins
    .sda_in    (i2c_if.sda_in),
    .sda_out   (i2c_if.s_sda_out),
    .sda_oen   (i2c_if.s_sda_oen),

    .scl_in    (i2c_if.scl_in),
    .scl_out   (i2c_if.s_scl_out),
    .scl_oen   (i2c_if.s_scl_oen),

    // register side
    .chip_addr (i2c_if.chip_addr),
    .data_in   (i2c_if.data_in),

    .write_en  (i2c_if.write_en),
    .reg_addr  (i2c_if.reg_addr),
    .data_out  (i2c_if.data_out),

    .done      (i2c_if.done),
    .busy      (i2c_if.busy)
  );

  // Give UVM access to the interface
  initial begin

    i2c_if.enable = 1'b1;
    i2c_if.open_drain = 1'b1;
    i2c_if.data_size = 1'b0;
    i2c_if.chip_addr = 7'h22;
    i2c_if.data_in = 16'hBEEF;
    uvm_config_db#(virtual I2C_if)::set(null, "*", "vif", i2c_if);
    run_test("I2C_slave_test");
  end

endmodule


interface I2C_if #(
	parameter int DATA_BYTES = 2,
	parameter int REG_ADDR_WIDTH =8
)(
	input logic clk,
	input logic reset
);

// Configuration Register
	logic enable;
        logic open_drain; // For open drain
        logic data_size;
        logic write_en;    // Write enable

	tri SDA;
	tri SCL;


	// Master side (UVM driver drives these)
	logic m_sda_out, m_sda_oen;
	logic m_scl_out, m_scl_oen;

	// Slave side (DUT drives these)
	logic s_sda_out, s_sda_oen;
	logic s_scl_out, s_scl_oen; // optional, slave usually doesn't drive SCL

	// Determine if each side is actively pulling LOW (open drain)
	wire m_sda_low = (m_sda_oen == 1'b0) && (m_sda_out == 1'b0);
	wire s_sda_low = (s_sda_oen == 1'b0) && (s_sda_out == 1'b0);

	wire m_scl_low = (m_scl_oen == 1'b0) && (m_scl_out == 1'b0);
	wire s_scl_low = (s_scl_oen == 1'b0) && (s_scl_out == 1'b0);

	// Resolve onto the bus: if anyone pulls low -> 0 else Z (pullup makes it 1)
	assign SDA = (m_sda_low || s_sda_low) ? 1'b0 : 1'bz;
	assign SCL = (m_scl_low || s_scl_low) ? 1'b0 : 1'bz;

	// Sample bus
	logic sda_in, scl_in;
	assign sda_in = SDA;
	assign scl_in = SCL;

// I2C signals
/*     logic sda_in;    // SDA Input
        logic sda_out;   // SDA Output
        logic sda_oen;   // SDA Output Enable

        logic scl_in;    // SCL Input
        logic scl_out;   // SCL Output
        logic scl_oen;   // SCL Output Enable

	assign SDA = sda_oen ? 1'bz:sda_out;
	assign SCL = scl_oen ? 1'bz:scl_out;
	assign sda_in = SDA;
	assign scl_in = SCL;

//	pullup (SDA);
//	pullup (SCL);
//	*/
// Configuration registers

        logic [6:0] chip_addr;  // Slave Address
        logic [8 * DATA_BYTES - 1:0] data_in;    // Data read from register

       	logic [REG_ADDR_WIDTH - 1:0] reg_addr;  // Register address
        logic [8 * DATA_BYTES - 1:0] data_out;  // Data to write to register

// Status Register

        logic done;
        logic busy;

endinterface


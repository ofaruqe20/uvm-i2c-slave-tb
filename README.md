# UVM I2C Slave Verification Environment
Developed by: 
Omar Faruqe
PhD Candidate, EE, University of Virginia
email: rhm7uh@virginia.edu

## Overview
This repository contains a UVM-based I2C Master verification environment
used to verify an external I2C Slave RTL implementation.

The testbench includes:
- UVM Agent (Driver, Sequencer, Monitor)
- Scoreboard with simple register model
- Open-drain I2C bus modeling using `tri` + pullups
- Configurable I2C timing
- Clean directory hierarchy

⚠️ The I2C Slave RTL is NOT included in this repository.

---

## External Dependency

Download the I2C slave RTL from:

https://github.com/csus-senior-design/i2c/blob/master/i2c_slave.v

Place the file inside:
```
rtl/i2c_slave.v
```
Notes: Please rename the i2c_slave as I2C_slave.sv
There are two additional parameters named enable and data_size. Please add them as input in the I2C_slave.sv 


Do NOT commit the external RTL into this repository.

---

## Directory Structure

```
uvm-i2c-slave-tb/
 ├── rtl/               # Place external I2C slave RTL here
 ├── tb/                # UVM testbench components
 ├── scripts/           # Run scripts
 ├── filelist.f         # Compilation order
 ├── README.md
 └── .gitignore
```

---

## Build and Run (Cadence Xcelium)

Compile and run:

```bash
./scripts/run_xcelium.sh
```

Or manually:

```bash
xrun -sv -uvm -f filelist.f -access +rwc +UVM_TESTNAME=I2C_slave_test
```

Run with GUI:

```bash
xrun -sv -uvm -f filelist.f -access +rwc -gui +UVM_TESTNAME=I2C_slave_test
```

---

## Debug Tips

- If you see NACK after address:
  - Check that slave address matches sequence address.
  - Ensure pullups exist on SDA/SCL.
  - Ensure no contention between master and slave drivers.

- If `vif` not found:
  - Ensure `uvm_config_db` is set in `top.sv`.

---


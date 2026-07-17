// Testbench for the cfs_aligner module

`include "cfs_algn_test_pkg.sv"
module testbench();
  
  import uvm_pkg::*;
  import cfs_algn_test_pkg::*;
  
  reg clk;

  // Instance of the APB interface
  cfs_apb_if apb_if(.pclk(clk));

  // Instance of the MD RX interface
  cfs_md_if#(32) md_rx_if(.clk(clk));

  // Instance of the MD TX interface
  cfs_md_if#(32) md_tx_if(.clk(clk));

  
  initial begin
    clk = 0;
    forever begin
      #5ns clk = ~clk; //100MHz
    end
  end
  
  initial begin
    apb_if.preset_n = 1;
    #3ns;
    apb_if.preset_n = 0;
    #30ns;
    apb_if.preset_n = 1;
  end

  assign md_rx_if.reset_n = apb_if.preset_n;
  assign md_tx_if.reset_n = apb_if.preset_n;
  

  initial begin
    // To see the waveforms:
    $dumpfile("dump.vcd");
    $dumpvars; // tells the simulator to record signal value changes to
               // a .vcd file (opened with $dumpfile)

    // APB interface to the database: the first argument is the type of the object being set, in this case a virtual interface
    // The first argument of the set method is the component where the object is configured (the context)
    // The second argument is the instance name of the component where the object will be used,
    // The third argument is the field name, which is a string that can be used to identify the object in the component
    // The fourth argument is the object being set, in this case the APB interface instance
    uvm_config_db#(virtual cfs_apb_if)::set(null, "uvm_test_top.env.apb_agent", "vif", apb_if);

    // MD interface to the database
    uvm_config_db#(virtual cfs_md_if#(32))::set(null, "uvm_test_top.env.md_rx_agent", "vif", md_rx_if);
    uvm_config_db#(virtual cfs_md_if#(32))::set(null, "uvm_test_top.env.md_tx_agent", "vif", md_tx_if);

    // Run the test
    //The test name can be passed as an argument when running the simulation
    // +access+r +UVM_TESTNAME=cfs_algn_test_reg_access +UVM_MAX_QUIT_COUNT=1 -coverage_functional
    run_test("");
  end 
  
  cfs_aligner dut(
    .clk(clk),
    .reset_n(apb_if.preset_n),
    .paddr(apb_if.paddr),
    .psel(apb_if.psel),
    .penable(apb_if.penable),
    .pwrite(apb_if.pwrite),
    .pwdata(apb_if.pwdata),
    .pready(apb_if.pready),
    .prdata(apb_if.prdata),
    .pslverr(apb_if.pslverr),

    .md_rx_valid(md_rx_if.valid),
    .md_rx_data(md_rx_if.data),
    .md_rx_ready(md_rx_if.ready),
    .md_rx_offset(md_rx_if.offset),
    .md_rx_size(md_rx_if.size),
    .md_rx_err(md_rx_if.err),

    .md_tx_valid(md_tx_if.valid),
    .md_tx_data(md_tx_if.data),
    .md_tx_ready(md_tx_if.ready),
    .md_tx_offset(md_tx_if.offset),
    .md_tx_size(md_tx_if.size),
    .md_tx_err(md_tx_if.err)
  );
  
endmodule
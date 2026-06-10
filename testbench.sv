// Testbench for the cfs_aligner module

`include "cfs_algn_test_pkg.sv"
module testbench();
  
  import uvm_pkg::*;
  import cfs_algn_test_pkg::*;
  
  reg clk;

  // Instance of the APB interface
  cfs_apb_if apb_if(.pclk(clk));
  
  initial begin
    clk = 0;
    forever begin
      #5ns clk = ~clk; //100MHz
    end
  end
  
  initial begin
    apb_if.preset_n = 1;
    #6ns;
    apb_if.preset_n = 0;
    #30ns;
    apb_if.preset_n = 1;
  end
  

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
      
    // Run the test
    //The test name can be passed as an argument when running the simulation
    // +UVM_TESTNAME=cfs_algn_test_reg_access +UVM_MAX_QUIT_COUNT=1
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
    .pslverr(apb_if.pslverr)
  );
  
endmodule
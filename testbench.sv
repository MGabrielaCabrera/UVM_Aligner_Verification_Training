// Testbench for the cfs_aligner module

`include "cfs_algn_test_pkg.sv"
module testbench();
  
  import uvm_pkg::*;
  import cfs_algn_test_pkg::*;
  
  reg clk;
  reg reset_n;
  
  initial begin
    clk = 0;
    forever begin
      #5ns clk = ~clk; //100MHz
    end
  end
  
  initial begin
    reset_n = 1;
    #6ns;
    reset_n = 0;
    #30ns;
    reset_n= 1;
  end
  
  //The test name can be passed as an argument when running the simulation
  // +UVM_TESTNAME=cfs_algn_test_reg_access
  initial begin
    run_test("");
  end 
  
  cfs_aligner dut(
    .clk(clk),
    .reset_n(reset_n)
  );
  
endmodule
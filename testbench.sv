module testbench();
  
  reg clk;
  reg reset_n;
  
  initial begin
    clk = 0;
    forever begin
      #5ns clk = ~clk;
    end
  end
  
  initial begin
    reset_n = 1;
    #6ns;
    reset_n = 0;
    #30ns;
    reset_n= 1;
  end
  
  initial begin
    run_test("");
  end 
  
  cfs_aligner dut(
    .clk(clk),
    .reset_n(reset_n)
  );
  
endmodule
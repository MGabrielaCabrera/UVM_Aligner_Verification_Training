`ifndef CFS_MD_IF_SV
    `define CFS_MD_IF_SV
    
    interface cfs_md_if#(int unsigned DATA_WIDTH = 32)(input clk);

        //width of the offset signal
        localparam OFFSET_WIDTH = $clog2(DATA_WIDTH/8) < 1 ? 1 : $clog2(DATA_WIDTH/8);
        
        //width of the size signal
        localparam SIZE_WIDTH = $clog2(DATA_WIDTH/8) +1;   
    
        logic reset_n;
        logic valid;
        logic[DATA_WIDTH-1:0] data;
        logic ready;
        logic[OFFSET_WIDTH-1:0] offset;
        logic[SIZE_WIDTH-1:0] size;
        logic err;  

        bit has_checks;

        initial begin
            has_checks = 1;
        end

        // Rules
        // 1. DATA_WIDTH must be a power of 2. We don't need this check to be executed in every clock
        // cycle, so we can use an initial block.
        initial begin
            if($countones(DATA_WIDTH) != 1) begin
                $error("DATA_WIDTH is not a power of two - value in binary: 'b%0b, in hex is 'h%0h, in dec is %0d", DATA_WIDTH, DATA_WIDTH, DATA_WIDTH);
            end
        end

        // 2. DATA_WIDTH must be at least 8. We don't need this check to be executed in every clock
        // cycle, so we can use an initial block.
        initial begin
            if(DATA_WIDTH < 8) begin
                $error("DATA_WIDTH is less than 8 - value in binary: 'b%0b, in hex is 'h%0h, in dec is %0d", DATA_WIDTH, DATA_WIDTH, DATA_WIDTH);
            end
        end

        // 3. Valid must stay high until ready is high
        property valid_high_until_ready_p;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            $fell(valid) |-> $past(ready) == 1; // When valid fallas, ready must have been high in the previous clock cycle.
        endproperty
    
        VALID_HIGH_UNTIL_READY_A : assert property(valid_high_until_ready_p) else
            $error("valid signal did not stay high until ready became high");

        // 4. Data is valid while valid is high
        property unknown_data_valid_p;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            valid |-> $isunknown(data) == 0; // When valid is high, data must not have unknown values.
        endproperty

        UNKNOWN_DATA_VALID_A : assert property(unknown_data_valid_p) else
            $error("Data signal has unknown values while valid is high");
        
        // 5. Data must remain constant until ready is high
        property data_stable_until_ready_p;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            valid & $past(valid) & !$past(ready) |-> $stable(data); // When valid is high, data must remain constant until ready is high.
        endproperty

        DATA_STABLE_UNTIL_READY_A : assert property(data_stable_until_ready_p) else
            $error("Data signal did not remain constant until ready became high");

        // 6. Offset is valid while valid is high
        property unknown_offset_valid_p;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            valid |-> $isunknown(offset) == 0; // When valid is high, offset must not have unknown values.
        endproperty

        UNKNOWN_OFFSET_VALID_A : assert property(unknown_offset_valid_p) else
            $error("Offset signal has unknown values while valid is high");

        // 7. Offset must remain constant until ready is high
        property offset_stable_until_ready_p;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            valid & $past(valid) & !$past(ready) |-> $stable(offset); // When valid is high, offset must remain constant until ready is high.
        endproperty

        OFFSET_STABLE_UNTIL_READY_A : assert property(offset_stable_until_ready_p) else
            $error("Offset signal did not remain constant until ready became high");

        // 8. Size is valid while valid is high
        property unknown_size_valid_p;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            valid |-> $isunknown(size) == 0; // When valid is high, size must not have unknown values.  
        endproperty

        UNKNOWN_SIZE_VALID_A : assert property(unknown_size_valid_p) else
            $error("Size signal has unknown values while valid is high");

        // 9. Size must remain constant until ready is high
        property size_stable_until_ready_p;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            valid & $past(valid) & !$past(ready) |-> $stable(size); // When valid is high, size must remain constant until ready is high. 
        endproperty

        SIZE_STABLE_UNTIL_READY_A : assert property(size_stable_until_ready_p) else
            $error("Size signal did not remain constant until ready became high");
        
        // 11. Err is valid when valid and ready are high
        property err_valid_p;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            valid && ready |-> $isunknown(err) == 0; // When valid and ready are high, err must not have unknown values.
        endproperty

        ERR_VALID_A : assert property(err_valid_p) else
            $error("Err signal has unknown values when valid and ready are high");
        
        // 13. Valid cannot have a unknown value

        property unknown_value_valid_p;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            $isunknown(valid) == 0; // valid must not have unknown values.
        endproperty

        UNKNOWN_VALUE_VALID_A : assert property(unknown_value_valid_p) else
            $error("Valid signal has unknown values");

        // 14. Ready is valid when valid is high
        property ready_valid_p;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            valid |-> $isunknown(ready) == 0; // When valid is high, ready must not have unknown values.
        endproperty

        READY_VALID_A : assert property(ready_valid_p) else
            $error("Ready signal has unknown values when valid is high");

    endinterface
`endif
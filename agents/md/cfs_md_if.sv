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



    endinterface
`endif
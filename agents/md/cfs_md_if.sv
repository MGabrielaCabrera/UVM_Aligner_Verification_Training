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

    endinterface
`endif
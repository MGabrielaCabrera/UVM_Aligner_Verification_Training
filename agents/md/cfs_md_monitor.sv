`ifndef CFS_MD_MONITOR_SV
    `define CFS_MD_MONITOR_SV

    // We need the DATA_WIDTH parameter to be able to access the interface
    class cfs_md_monitor#(int unsigned DATA_WIDTH = 32) extends uvm_monitor implements cfs_md_reset_handler;

        `uvm_component_param_utils(cfs_md_monitor#(DATA_WIDTH))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            output_port = new("output_port", this);
        endfunction

        virtual function void handler_reset(uvm_phase phase);

        endfunction

    endclass
`endif
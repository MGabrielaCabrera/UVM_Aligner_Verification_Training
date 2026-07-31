`ifndef CFS_MD_SEQUENCER_SV
    `define CFS_MD_SEQUENCER_SV

    class cfs_md_sequencer#(type ITEM_DRV = cfs_md_item_drv) extends uvm_sequencer#(.REQ(ITEM_DRV)) implements cfs_md_reset_handler;

        `uvm_component_utils(cfs_md_sequencer#(ITEM_DRV))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void handler_reset(uvm_phase phase);
            // Standard code to stop and start the sequencer
            int objections_count;

            stop_sequences();

            objections_count = uvm_test_done.get_objection_count(this);

            if(objections_count > 0) begin
                uvm_test_done.drop_objection(this, $sformatf("Dropping %0d objections at reset", objections_count), objections_count);
            end 

            start_phase_sequence(phase);
        endfunction

        virtual function int unsigned get_data_width();
            `uvm_fatal("get_data_width", "get_data_width() must be implemented in the derived class");
        endfunction
    endclass
`endif
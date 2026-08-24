`ifndef CFS_MD_SEQUENCER_SLAVE_BASE_SV
    `define CFS_MD_SEQUENCER_SLAVE_BASE_SV

    class cfs_md_sequencer_slave_base extends cfs_md_sequencer_base#(.ITEM_DRV(cfs_md_item_drv_slave));

        // Port for receiving item from the monitor
        uvm_analysis_imp#(cfs_md_item_mon, cfs_md_sequencer_base_slave) port_from_mon;

        // Pending items FIFO
        uvm_tlm_fifo#(cfs_md_item_mon) pending_items;

        `uvm_component_utils(cfs_md_sequencer_slave_base)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            // Arguments: name, parent and size 
            // We can only have one item started by the master
            // (the md protocol does not allow to start a new item 
            //when the previos one has not finished)
            pending_items = new("pending_items", this, 1);

            port_from_mon = new("port_from_mon", this);
        endfunction

        virtual function void write(cfs_md_item_mon item);
            if(item.is_active()) begin
                if(pending_items.is_full()) begin
                    `uvm_fatal("ALGORITHM_ISSUE", 
                                $sformatf("FIFO %0s is full (size: %0d) - a possible cause is that
                                    there is no sequence started which pulls information from this FIFO",
                                    pending_items.get_full_name(), pending_items.size()))
                end

                if(pending_items.try_put(item) == 0) begin
                    `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Failed to push a new item in FIFO %0s",
                        pending_items.get_full_name()))
                end
            end
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            super.handle_reset(phase);
            pending_items.flush();
        endfunction

    endclass
`endif
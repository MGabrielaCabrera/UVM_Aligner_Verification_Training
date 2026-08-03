`ifndef CFS_MD_SEQUENCE_SIMPLE_MASTER_SV
    `define CFS_MD_SEQUENCE_SIMPLE_MASTER_SV

    class cfs_md_sequence_simple_master extends cfs_md_sequence_base#(cfs_md_item_drv_master);
        rand cfs_md_item_drv_master item;

        constraint item_hard {
            item.data.size() > 0;
            item.data.size() <= p_sequencer.get_data_width() / 8;
            item.offset < p_sequencer.get_data_width() / 8;
            item.offset + item.data.size() <= p_sequencer.get_data_width() / 8;
        }

        `uvm_object_utils(cfs_md_sequence_simple_master)

        function new(string name = "");
            super.new(name);
            
            item = cfs_md_item_drv_master::type_id::create("item");

            // Disabling item constraints
            item.data_default_c.constraint_mode(0);
            item.offset_default_c.constraint_mode(0);
        endfunction

        virtual task body();
            // Start the sequence by sending the item to the sequencer
            //start_item(item);
            //finish_item(item);
            // We can also use the `uvm_do macro to do the same thing in one line
            // The problem is that the uvm_do regenerates the item, so the previous
            // constraints are not applied. 
            //`uvm_do(item)
            // To avoid this, we can use:
            `uvm_send(item)
        endtask

    endclass
`endif
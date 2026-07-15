`ifndef CFS_APB_SEQUENCE_RW_SV
    `define CFS_APB_SEQUENCE_RW_SV

    class cfs_apb_sequence_rw extends cfs_apb_sequence_base;
        
        rand cfs_apb_addr addr;
        rand cfs_apb_data wr_data;

        `uvm_object_utils(cfs_apb_sequence_rw)

        function new(string name = "");
            super.new(name);

        endfunction

        virtual task body();
            cfs_apb_item_drv item;
            //item = cfs_apb_item_drv::type_id::create("item");
            
            /*void'(item.randomize() with { 
                dir == CFS_APB_READ;
                addr == local::addr; 
            });*/
            
            // Start the sequence by sending the item to the sequencer
            //start_item(item);
            //finish_item(item);

            // We can use a macro
            `uvm_do_with(item, { dir == CFS_APB_READ; addr == local::addr; })
        
            // We do the same to write
            `uvm_do_with(item, { dir == CFS_APB_WRITE; addr == local::addr; data == local::wr_data; })
        endtask

    endclass
`endif
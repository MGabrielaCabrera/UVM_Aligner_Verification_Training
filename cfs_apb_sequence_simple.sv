`ifndef CFS_APB_SEQUENCE_SIMPLE_SV
    `define CFS_APB_SEQUENCE_SIMPLE_SV

    class cfs_apb_sequence_simple extends cfs_apb_sequence_base;
        rand cfs_apb_item_drv item;

        `uvm_object_utils(cfs_apb_sequence_simple)

        function new(string name = "");
            super.new(name);
            
            item = cfs_apb_item_drv::type_id::create("item");
        endfunction

        task body();
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
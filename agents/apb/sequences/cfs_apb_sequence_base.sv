`ifndef CFS_APB_SEQUENCE_BASE_SV
    `define CFS_APB_SEQUENCE_BASE_SV

    class cfs_apb_sequence_base extends uvm_sequence#(cfs_apb_item_drv);
        
        // Declaring p_sequecer using a macro
        `uvm_declare_p_sequencer(cfs_apb_sequencer)
        // We can also declare the sequencer as a variable, but we need to connect it in the body of the sequence
        // cfs_apb_sequencer p_sequencer;

        // Sequence is an object:
        `uvm_object_utils(cfs_apb_sequence_base)

        function new(string name = "");
            super.new(name);
        endfunction

    endclass
`endif
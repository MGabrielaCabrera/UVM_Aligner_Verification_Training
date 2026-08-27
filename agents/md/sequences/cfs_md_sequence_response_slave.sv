`ifndef CFS_MD_SEQUENCE_RESPONSE_SLAVE_SV
    `define CFS_MD_SEQUENCE_RESPONSE_SLAVE_SV

    class cfs_md_sequence_response_slave extends cfs_md_sequence_base_slave;


        `uvm_object_utils(cfs_md_sequence_response_slave)

        function new(string name = "");
            super.new(name);

        endfunction

        virtual task body();
            cfs_md_item_mon item_mon;

            p_sequencer.pending_items.get(item_mon);

            begin
                cfs_md_sequence_simple_slave seq;
                
                `uvm_do_with(seq, {
                })
            end
        endtask
    endclass
`ifndef CFS_MD_SEQUENCE_RESPONSE_FOREVER_SLAVE_SV
    `define CFS_MD_SEQUENCE_RESPONSE_FOREVER_SLAVE_SV

    class cfs_md_sequence_response_forever_slave extends cfs_md_sequence_base_slave;


        `uvm_object_utils(cfs_md_sequence_response_forever_slave)

        function new(string name = "");
            super.new(name);

        endfunction

        virtual task body();
            forever begin
                cfs_md_sequence_response_slave seq;
                `uvm_do_on(seq, p_sequencer)
            end

        endtask
    endclass
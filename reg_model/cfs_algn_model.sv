`ifndef CFS_ALGN_MODEL_SV
    `define CFS_ALGN_MODEL_SV

    class cfs_algn_model extends uvm_component implements uvm_ext_reset_handler;

        `uvm_component_utils(cfs_algn_model)

        // The register block must be declared as rand
        rand cfs_algn_reg_block reg_block;

        function new(string name = "", uvm_component parent = null);
            super.new(.name(name), .parent(parent));
        endfunction

        function  void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (reg_block ==null) begin
                reg_block = cfs_algn_reg_block::type_id::create(.name("reg_block"), .parent(this));
                reg_block.build();
                reg_block.lock_model(); // No more changes are wanted
            end
        endfunction 

        virtual function void handler_reset(uvm_phase phase);
            reg_block.reset("HARD");
        endfunction

    endclass


`endif
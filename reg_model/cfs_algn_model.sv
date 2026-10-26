`ifndef CFS_ALGN_MODEL_SV
    `define CFS_ALGN_MODEL_SV

    class cfs_algn_model extends uvm_component;

        `uvm_component_utils(cfs_algn_model)

        // The register block must be declared as rand
        rand cfs_algn_reg_block reg_block;

        function new(string name = "", uvm_component parent = null);
            super.new(.name(name), .parent(parent));
        endfunction

        function  voidbuild_phase(uvm_phase phase);
            super.build_phase(phase);

            if (reg_block ==null) begin
                reg_block = cfs_algn_reg_block::type_id::create(.name("reg_block"), .parent(this));
                reg_block.build();
                reg_block.lock_model(); // No more changes are wanted
            end
        endfunction 
    
    endclass


`endif
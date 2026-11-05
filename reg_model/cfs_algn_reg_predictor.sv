`ifndef CFS_ALGN_REG_PREDICTOR_SV
    `define CFS_ALGN_REG_PREDICTOR_SV

    class cfs_algn_reg_predictor#(type BUSTYPE = uvm_sequence_item) extends uvm_reg_predictor#(.BUSTYPE(BUSTYPE));

        cfs_algn_env_config env_config;

        `uvm_component_param_utils(cfs_algn_reg_predictor#(BUSTYPE))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        // The write function is overwritten
        virtual function void write(BUSTYPE tr);
            uvm_reg_bus_op operation;

            adapter.bus2reg(tr, operation);

            if (operation.status == UVM_IS_OK) begin
                super.write(tr);
            end
        endfunction


    endclass
`endif
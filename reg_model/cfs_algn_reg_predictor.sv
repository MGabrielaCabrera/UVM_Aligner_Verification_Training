`ifndef CFS_ALGN_REG_PREDICTOR_SV
    `define CFS_ALGN_REG_PREDICTOR_SV

    class cfs_algn_reg_predictor#(type BUSTYPE = uvm_sequence_item) extends uvm_reg_predictor#(.BUSTYPE(BUSTYPE));

        `uvm_component_param_utils(cfs_algn_reg_predictor#(BUSTYPE))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

    endclass
`endif
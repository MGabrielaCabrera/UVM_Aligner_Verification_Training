`ifndef UVM_EXT_COVER_INDEX_WRAPPER_SV
    `define UVM_EXT_COVER_INDEX_WRAPPER_SV

    class uvm_ext_cover_index_wrapper#(int unsigned MAX_VALUE_PLUS_1 = 16) extends uvm_component;
        `uvm_component_param_utils(uvm_ext_cover_index_wrapper#(MAX_VALUE_PLUS_1))

        covergroup cover_index with function sample(int unsigned value);
            option.per_instance = 1; // One covergroup instance per agent instance

            index: coverpoint value {
                option.comment = "Index";

                bins values[MAX_VALUE_PLUS_1] = {[0:MAX_VALUE_PLUS_1-1]};
            } 
        endgroup

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            cover_index = new();
            cover_index.set_inst_name($sformatf("%s_%s",get_full_name(), "cover_index"));

        endfunction

        // Method to visualize the coverage result in edaplayground
        virtual function string coverage2string();
            string result = {$sformatf("\n            cover_index:               %03.2f%%", cover_index.get_inst_coverage()),
                            $sformatf("\n               index:                   %03.2f%%", cover_index.index.get_inst_coverage())
                            };
            return result;
        endfunction

        virtual function void sample(int unsigned value);
            cover_index.sample(value);

            //`uvm_info("DEBUG", $sformatf("\n Index %0s: \n %0s", this.get_full_name(), coverage2string()), UVM_NONE)

        endfunction


    endclass
`endif
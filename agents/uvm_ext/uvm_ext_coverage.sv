`ifndef UVM_EXT_COVERAGE_SV
    `define UVM_EXT_COVERAGE_SV

    // Analysis port
    `uvm_analysis_imp_decl(_item)

    class uvm_ext_coverage#(type VIRTUAL_INTF = int, type ITEM_MON = uvm_sequence_item) extends uvm_component implements uvm_ext_reset_handler;
        uvm_ext_agent_config#(VIRTUAL_INTF) agent_config;
        
        //Port to receiving the collected items
        uvm_analysis_imp_item#(ITEM_MON, uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON)) port_item;

        `uvm_component_param_utils(uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
            
            port_item = new("port_item", this);
        endfunction

        virtual function void write_item(ITEM_MON item);

        endfunction

        virtual function void handler_reset(uvm_phase phase);
        endfunction

        virtual function string coverage2string();
            string result = "";

            return result;
        endfunction


        // This is not needed in a real project with the proper tools
        virtual function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("DEBUG", $sformatf("\n Coverage report for %0s: \n %0s", this.get_full_name(), coverage2string()), UVM_NONE)
        endfunction



    endclass
`endif
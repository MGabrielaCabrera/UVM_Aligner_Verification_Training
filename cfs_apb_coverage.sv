`ifndef CFS_APB_COVERAGE_SV
    `define CFS_APB_COVERAGE_SV

    // Analysis port
    `uvm_analysis_imp_decl(_item)

    class cfs_apb_coverage extends uvm_component;
        
        //Port to receiving the collected items
        uvm_analysis_imp_item#(cfs_apb_item_mon, cfs_apb_coverage) port_item;

        `uvm_component_utils(cfs_apb_coverage)

        covergroup cover_item with function sample(cfs_apb_item_mon item);
            option.per_instance = 1; // One covergroup instance per agent instance

            direction: coverpoint item.dir {
                option.comment = "Direction of the APB transfer";

            }
        endgroup


        function new(string name = "", uvm_component parent);
            super.new(name, parent);
            
            port_item = new("port_item", this);
            cover_item = new();
            cover_item.set_inst_name($sformatf("%s_%s",get_full_name(), "cover_item"));
        endfunction
        
        // Function associated with port_item port
        virtual function void write_item(cfs_apb_item_mon item);
            cover_item.sample(item);
        endfunction
        
  

    endclass


`endif
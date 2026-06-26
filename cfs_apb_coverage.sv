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

            length: coverpoint item.length {
                option.comment = "Length of the APB transfer";

                bins length_eq_2 = {2}; // Shortest length possible
                bins length_le_20[8] = {[3:10]};
                bins length_gt_10 = {[11:$]};
            }

            prev_item_delay: coverpoint item.prev_item_delay {
                option.comment = "Delay, in clock cycles, between two consecutive APB accesses";

                bins back2back = {0};
                bins delay_le_5[5] = {[1:5]};
                bins delay_gt_6 = {[6:$]};
            }
        endgroup


        function new(string name = "", uvm_component parent);
            super.new(name, parent);
            
            port_item = new("port_item", this);
            cover_item = new();
            cover_item.set_inst_name($sformatf("%s_%s",get_full_name(), "cover_item"));
        endfunction
        

        // Method to visualize the coverage result in edaplayground
        virtual function string coverage2string();
            string result = {$sformatf("\n   cover_item:               %03.2f%%", cover_item.get_inst_coverage()),
                            $sformatf("\n      direction:              %03.2f%%", cover_item.direction.get_inst_coverage()),
                            $sformatf("\n      length:                 %03.2f%%", cover_item.length.get_inst_coverage()),
                            $sformatf("\n      prev_item_delay:        %03.2f%%", cover_item.prev_item_delay.get_inst_coverage())
                            };
            return result;
        endfunction

        // Function associated with port_item port (fixed callback method name)
        virtual function void write_item(cfs_apb_item_mon item);
            cover_item.sample(item);

            // This is done because the coverage cannot be seen in edaplayground
            `uvm_info("DEBUG", $sformatf("Coverage: %0s", coverage2string()), UVM_NONE)
        endfunction
        
  

    endclass


`endif
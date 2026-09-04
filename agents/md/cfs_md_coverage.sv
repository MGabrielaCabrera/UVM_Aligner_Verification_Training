`ifndef CFS_MD_COVERAGE_SV
    `define CFS_MD_COVERAGE_SV

    // Analysis port
    `uvm_analysis_imp_decl(_item)

    class cfs_md_cover_index_wrapper#(int unsigned MAX_VALUE_PLUS_1 = 16) extends uvm_component;
        `uvm_component_param_utils(cfs_md_cover_index_wrapper#(MAX_VALUE_PLUS_1))

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


    class cfs_md_coverage#(int unsigned DATA_WIDTH = 32) extends uvm_component implements cfs_md_reset_handler;

        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

        cfs_md_agent_config#(DATA_WIDTH) agent_config;
        
        //Port to receiving the collected items
        uvm_analysis_imp_item#(cfs_md_item_mon, cfs_md_coverage#(DATA_WIDTH)) port_item;

        // Wrapper over the coverage group covering the indices of data signal
        cfs_md_cover_index_wrapper#(DATA_WIDTH) wrap_cover_data_0;

        cfs_md_cover_index_wrapper#(DATA_WIDTH) wrap_cover_data_1;

        `uvm_component_param_utils(cfs_md_coverage#(DATA_WIDTH))

        covergroup cover_item with function sample(cfs_md_item_mon item);
            option.per_instance = 1; // One covergroup instance per agent instance

            offset: coverpoint item.offset {
                option.comment = "Offset of the MD access";
                bins values[] = {[0:(DATA_WIDTH/8)-1]};
            }

            size: coverpoint item.size {
                option.comment = "Size of the MD access";
                bins values[] = {[1:(DATA_WIDTH/8)]};
            }

            response: coverpoint item.response {
                option.comment = "Response of the MD access";
            }

            length: coverpoint item.length {
                option.comment = "Length of the MD access";

                bins length_eq_1 = {1}; // Shortest length possible
                bins length_le_20[8] = {[2:10]};
                bins length_gt_10 = {[11:$]};

                illegal_bins length_lt_1 = {0}; // Length cannot be 0
            }

            prev_item_delay: coverpoint item.prev_item_delay {
                option.comment = "Delay, in clock cycles, between two consecutive MD accesses";

                bins back2back = {0};
                bins delay_le_5[5] = {[1:5]};
                bins delay_gt_6 = {[6:$]};
            }

            offset_x_size: cross offset, size {
                ignore_bins ignore_offset_plus_size_gt_data_width = offset_x_size with (offset + size > (DATA_WIDTH/8));
            }
        endgroup

        covergroup cover_reset with function sample(bit valid);
            option.per_instance = 1; // One covergroup instance per agent instance

            access_ongoing: coverpoint valid {
                option.comment = "An MD access was ongoing at reset";
            }
        endgroup


        function new(string name = "", uvm_component parent);
            super.new(name, parent);
            
            port_item = new("port_item", this);
            cover_item = new();
            cover_item.set_inst_name($sformatf("%s_%s",get_full_name(), "cover_item"));
            cover_reset = new();
            cover_reset.set_inst_name($sformatf("%s_%s",get_full_name(), "cover_reset"));
        endfunction
        
        virtual function void build_phase(uvm_phase phase);
            wrap_cover_data_0 = cfs_md_cover_index_wrapper#(DATA_WIDTH)::type_id::create("wrap_cover_data_0", this);
            wrap_cover_data_1 = cfs_md_cover_index_wrapper#(DATA_WIDTH)::type_id::create("wrap_cover_data_1", this);
        
        endfunction

        virtual function void handler_reset(uvm_phase phase);
            cfs_md_vif vif = agent_config.get_vif();
            cover_reset.sample(vif.valid);

        endfunction

        // Method to visualize the coverage result in edaplayground
        virtual function string coverage2string();
            string result = {$sformatf("\n   cover_item:               %03.2f%%", cover_item.get_inst_coverage()),
                            $sformatf("\n      offset:                 %03.2f%%", cover_item.offset.get_inst_coverage()),
                            $sformatf("\n      size:                   %03.2f%%", cover_item.size.get_inst_coverage()),
                            $sformatf("\n      prev_item_delay:        %03.2f%%", cover_item.prev_item_delay.get_inst_coverage()),
                            $sformatf("\n      offset_x_size:          %03.2f%%", cover_item.offset_x_size.get_inst_coverage()),
                            $sformatf("\n      response:               %03.2f%%", cover_item.response.get_inst_coverage()),
                            $sformatf("\n      cover_reset:            %03.2f%%", cover_reset.get_inst_coverage()),
                            $sformatf("\n      access_ongoing:         %03.2f%%", cover_reset.access_ongoing.get_inst_coverage()),
                            $sformatf("\n      wrap_cover_data_0:      %0s", wrap_cover_data_0.coverage2string()),
                            $sformatf("\n      wrap_cover_data_1:      %0s", wrap_cover_data_1.coverage2string())

                            };
            return result;
        endfunction

        // Function associated with port_item port (fixed callback method name)
        virtual function void write_item(cfs_md_item_mon item);
        cover_item.sample(item);

        foreach(item.data[byte_index]) begin
            for(int bit_index = 0; bit_index < 8; bit_index++) begin
            if(item.data[byte_index][bit_index]) begin
                wrap_cover_data_1.sample((item.offset * 8) + (byte_index * 8) + bit_index);
            end
            else begin
                wrap_cover_data_0.sample((item.offset * 8) + (byte_index * 8) + bit_index);
            end
            end
        end

        endfunction

        virtual function void report_phase(uvm_phase phase);
            `uvm_info("DEBUG", $sformatf("\n Coverage report for %0s: \n %0s", this.get_full_name(), coverage2string()), UVM_NONE)
        endfunction
        
  

    endclass


`endif

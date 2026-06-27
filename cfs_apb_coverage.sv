`ifndef CFS_APB_COVERAGE_SV
    `define CFS_APB_COVERAGE_SV

    // Analysis port
    `uvm_analysis_imp_decl(_item)

    // Wrapper component to collect coverage of the data and address
    class cfs_apb_cover_index_wrapper#(int unsigned MAX_VALUE_PLUS_1 = 16) extends uvm_component;
        `uvm_component_param_utils(cfs_apb_cover_index_wrapper#(MAX_VALUE_PLUS_1))

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

    class cfs_apb_coverage extends uvm_component;
        
        //Port to receiving the collected items
        uvm_analysis_imp_item#(cfs_apb_item_mon, cfs_apb_coverage) port_item;

        // Wrapper over the coverage group covering the indices of PADDR signal
        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH) wrap_cover_addr_0;

        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH) wrap_cover_addr_1;

        // Wrapper over the coverage group covering the indices of PWDATA signal
        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_wr_data_0;

        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_wr_data_1;

        // Wrapper over the coverage group covering the indices of PRDATA signal
        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_rd_data_0;

        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_rd_data_1;


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

            response: coverpoint item.response {
                option.comment = "Response of the APB access";
            }

            response_x_direction: cross response, direction;

            trans_direction: coverpoint item.dir {
                option.comment = "Transition of the APB direction";
                bins direction_trans[] = (CFS_APB_READ, CFS_APB_WRITE => CFS_APB_READ, CFS_APB_WRITE);
            }

        endgroup


        function new(string name = "", uvm_component parent);
            super.new(name, parent);
            
            port_item = new("port_item", this);
            cover_item = new();
            cover_item.set_inst_name($sformatf("%s_%s",get_full_name(), "cover_item"));
        endfunction
        
        virtual function void build_phase(uvm_phase phase);
            wrap_cover_addr_0 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH)::type_id::create("wrap_cover_addr_0", this);
            wrap_cover_addr_1 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH)::type_id::create("wrap_cover_addr_1", this);
            wrap_cover_wr_data_0 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_wr_data_0", this);
            wrap_cover_wr_data_1 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_wr_data_1", this);
            wrap_cover_rd_data_0 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_rd_data_0", this);
            wrap_cover_rd_data_1 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_rd_data_1", this);
        
        endfunction

        // Method to visualize the coverage result in edaplayground
        virtual function string coverage2string();
            string result = {$sformatf("\n   cover_item:               %03.2f%%", cover_item.get_inst_coverage()),
                            $sformatf("\n      direction:              %03.2f%%", cover_item.direction.get_inst_coverage()),
                            $sformatf("\n      length:                 %03.2f%%", cover_item.length.get_inst_coverage()),
                            $sformatf("\n      prev_item_delay:        %03.2f%%", cover_item.prev_item_delay.get_inst_coverage()),
                            $sformatf("\n      response_x_direction:   %03.2f%%", cover_item.response_x_direction.get_inst_coverage()),
                            $sformatf("\n      trans_direction:        %03.2f%%", cover_item.trans_direction.get_inst_coverage()),
                            $sformatf("\n      wrap_cover_addr_0:      %0s", wrap_cover_addr_0.coverage2string()),
                            $sformatf("\n      wrap_cover_addr_1:      %0s", wrap_cover_addr_1.coverage2string()),
                            $sformatf("\n      wrap_cover_wr_data_0:   %0s", wrap_cover_wr_data_0.coverage2string()),
                            $sformatf("\n      wrap_cover_wr_data_1:   %0s", wrap_cover_wr_data_1.coverage2string()),
                            $sformatf("\n      wrap_cover_rd_data_0:   %0s", wrap_cover_rd_data_0.coverage2string()),
                            $sformatf("\n      wrap_cover_rd_data_1:   %0s", wrap_cover_rd_data_1.coverage2string())
                            };
            return result;
        endfunction

        // Function associated with port_item port (fixed callback method name)
        virtual function void write_item(cfs_apb_item_mon item);
            cover_item.sample(item);

            for(int i = 0; i < `CFS_APB_MAX_ADDR_WIDTH; i++) begin
                if (item.addr[i]) begin
                    wrap_cover_addr_1.sample(i);
                end
                else begin
                    wrap_cover_addr_0.sample(i);
                end
            end

            for(int i = 0; i < `CFS_APB_MAX_DATA_WIDTH; i++) begin
                if (item.dir == CFS_APB_WRITE) begin
                    if (item.data[i]) begin
                        wrap_cover_wr_data_1.sample(i);
                    end
                    else begin
                        wrap_cover_wr_data_0.sample(i);
                    end
                end
                else begin
                    if (item.data[i]) begin
                        wrap_cover_rd_data_1.sample(i);
                    end
                    else begin
                        wrap_cover_rd_data_0.sample(i);
                    end
                end
            end

            // This is done because the coverage cannot be seen in edaplayground
            `uvm_info("DEBUG", $sformatf("Coverage: %0s", coverage2string()), UVM_NONE)
        endfunction
        
  

    endclass


`endif
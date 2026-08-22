`ifndef CFS_MD_DRIVER_SLAVE_SV
    `define CFS_MD_DRIVER_SLAVE_SV

    class cfs_md_driver_slave#(int unsigned DATA_WIDTH = 32) extends cfs_md_driver#(.ITEM_DRV(cfs_md_item_drv_slave)) implements cfs_md_reset_handler;

        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

        `uvm_component_param_utils(cfs_md_driver_slave#(DATA_WIDTH))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        protected virtual task driver_transaction(cfs_md_item_drv_slave item);
            cfs_md_vif vif = agent_config.get_vif();

            `uvm_info("DEBUG", $sformatf("Driving \"%0s\": %0s", item.get_full_name(), item.convert2string()), UVM_NONE)

            if (vif.valid !== 1) begin
                `uvm_error("ALGORITHM_ISSUE", $sformatf("Trying to drive a slave item when there is no item started by the master - item: %0s", item.convert2string()))
            end

            for(int i = 0; i < item.length; i++) begin
                @(posedge vif.clk);
            end

            vif.ready <= 1;
            vif.err   <= bit'(item.response);
            
            @(posedge vif.clk);
            
            vif.ready <= item.ready_at_end;
            vif.err   <= 0;

        endtask

        virtual function void handler_reset(uvm_phase phase);
            
            super.handler_reset(phase);
            
        endfunction


    endclass

`endif
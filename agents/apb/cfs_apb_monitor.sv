`ifndef CFS_APB_MONITOR_SV
    `define CFS_APB_MONITOR_SV

    class cfs_apb_monitor extends uvm_monitor implements cfs_apb_reset_handler;

        // Declaring agent config class to have access to the virtual 
        // interface through a pointer (in the agent class)
        cfs_apb_agent_config agent_config;
        
        // UVM Analysis port to send the collected transactions 
        // to other components
        uvm_analysis_port#(cfs_apb_item_mon) output_port;

        // Process for collect_Transactions() task
        protected process process_collect_transactions;

        `uvm_component_utils(cfs_apb_monitor)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            output_port = new("output_port", this);
        endfunction
        
        virtual task run_phase(uvm_phase phase);
            forever begin
                fork
                    begin
                        wait_reset_end();
                        collect_transactions();
                        disable fork;
                    end
                join
            end
        endtask

        // Task for waiting the reset to end (synchronous)
        virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

        protected virtual task collect_transactions();
           fork
                begin
                    process_collect_transactions = process::self();

                    forever begin
                        collect_transaction();
                    end
                end
           join
        endtask

        protected virtual task collect_transaction();
            // Pointer to the virtual interface
            cfs_apb_vif vif = agent_config.get_vif();

            cfs_apb_item_mon item = cfs_apb_item_mon::type_id::create("item", this);

            while(vif.psel == 0) begin
                @(posedge vif.pclk);
                item.prev_item_delay++;
            end
            
            // We sample the address and data
            item.addr = vif.paddr;
            item.dir = cfs_apb_dir'(vif.pwrite);

            if (item.dir == CFS_APB_WRITE) begin
                item.data = vif.pwdata;
            end

            // The length is initialize to one
            item.length = 1;

            @(posedge vif.pclk);
            item.length++;

            // We wait for the transaction to complete by waiting for pready to be high
            while(vif.pready == 0) begin
                @(posedge vif.pclk);
                item.length++;

                if (agent_config.get_has_checks()) begin
                    if (item.length > agent_config.get_stuck_threshold()) begin
                        `uvm_error("PROTOCOL_ERROR", $sformatf("APB transfer reached the stuck threshold of %0d clock cycles", item.length))
                    end
                end
            end

            // We sample the response
            item.response = cfs_apb_response'(vif.pslverr);

            if (item.dir == CFS_APB_READ) begin
                item.data = vif.prdata;
            end

            output_port.write(item);
            
            
            `uvm_info("DEBUG", $sformatf("Monitored item:: %0s", item.convert2string()), UVM_NONE)

            // Waiting one clock cycle before exiting the task
            @(posedge vif.pclk);
        endtask

        virtual function void handler_reset(uvm_phase phase);
           if(process_collect_transactions != null) begin
                process_collect_transactions.kill();
                process_collect_transactions = null;
            end
        endfunction
    endclass
`endif
`ifndef CFS_MD_MONITOR_SV
    `define CFS_MD_MONITOR_SV

    // We need the DATA_WIDTH parameter to be able to access the interface
    class cfs_md_monitor#(int unsigned DATA_WIDTH = 32) extends uvm_monitor implements cfs_md_reset_handler;

        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

        // interface through a pointer (in the agent class)
        cfs_md_agent_config#(DATA_WIDTH) agent_config;
        
        // UVM Analysis port to send the collected transactions 
        // to other components
        uvm_analysis_port#(cfs_md_item_mon) output_port;

        // Process for collect_Transactions() task
        protected process process_collect_transactions;


        `uvm_component_param_utils(cfs_md_monitor#(DATA_WIDTH))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            output_port = new("output_port", this);
        endfunction


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

        protected virtual task collect_transaction();
            cfs_md_vif vif = agent_config.get_vif();

            int unsigned data_width_in_bytes = DATA_WIDTH / 8;
            cfs_md_item_mon item = cfs_md_item_mon::type_id::create("item");

            #(agent_config.get_sample_delay_start_tr());
            
            while(vif.valid !== 1) begin
                @(posedge vif.clk);
                item.prev_item_delay++;
                #(agent_config.get_sample_delay_start_tr());
            end
            
            item.offset = vif.offset;
            
            for(int i = 0; i < vif.size; i++) begin
                item.data.push_back((vif.data >> ((item.offset + i) * 8)) & 8'hFF);
            end
            
            item.length = 1;
            
            void'(begin_tr(item)); // Setting the start time of the transaction
            
            `uvm_info("DEBUG", $sformatf("Monitor started collecting item: %0s", item.convert2string()), UVM_NONE)

            output_port.write(item); // Sending the item to the analysis port to be collected by other components
            
            @(posedge vif.clk);

            while(vif.ready !== 1) begin
                @(posedge vif.clk);
                item.length++;

                if (agent_config.get_has_checks()) begin
                    if (item.length > agent_config.get_stuck_threshold()) begin
                        `uvm_error("PROTOCOL_ERROR", $sformatf("MD transfer reached the stuck threshold of %0d clock cycles", item.length))
                    end
                end
            end

            item.response = cfs_md_response'(vif.err);
            
            end_tr(item); // Setting the end time of the transaction

            output_port.write(item);

            `uvm_info("DEBUG", $sformatf("Monitored item: %0s", item.convert2string()), UVM_NONE)
        
        endtask

        virtual function void handler_reset(uvm_phase phase);
           if(process_collect_transactions != null) begin
                process_collect_transactions.kill();
                process_collect_transactions = null;
            end
        endfunction

    endclass
`endif
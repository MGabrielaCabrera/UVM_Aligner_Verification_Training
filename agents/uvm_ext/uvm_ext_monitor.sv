`ifndef UVM_EXT_MONITOR_SV
    `define UVM_EXT_MONITOR_SV

    class uvm_ext_monitor#(type VIRTUAL_INTF = int, type ITEM_MON = uvm_sequence_item) extends uvm_monitor implements uvm_ext_reset_handler;

        // Declaring agent config class to have access to the virtual 
        // interface through a pointer (in the agent class)
        uvm_ext_agent_config#(VIRTUAL_INTF) agent_config;
        
        // UVM Analysis port to send the collected transactions 
        // to other components
        uvm_analysis_port#(ITEM_MON) output_port;

        // Process for collect_Transactions() task
        protected process process_collect_transactions;

        `uvm_component_param_utils(uvm_ext_monitor#(VIRTUAL_INTF, ITEM_MON))

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

        virtual function void handler_reset(uvm_phase phase);
           if(process_collect_transactions != null) begin
                process_collect_transactions.kill();
                process_collect_transactions = null;
            end
        endfunction

        protected virtual task collect_transaction();
            `uvm_fatal("ALGORITHM_ISSUE", "collect_transaction() is a pure virtual task and must be implemented in the derived class") 
        endtask

    endclass
`endif